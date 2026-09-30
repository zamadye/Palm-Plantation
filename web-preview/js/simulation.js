// Browser-side preview of the Prototype 0.1 simulation.
// Kept separate from rendering, following the data/view split in the Godot project.
export const LAND = Object.freeze({ FOREST: 0, CLEARING: 1, CLEARED: 2, PREPARING: 3, PREPARED: 4 });

const FIELD = { x: 8, z: 10, width: 24, depth: 18 };
const DAY_SECONDS = 3;
const STAGE_NAMES = ['Seedling', 'Young palm', 'Developing palm', 'Mature palm'];

export class PlantationSimulation {
  constructor(onToast = () => {}) {
    this.onToast = onToast;
    this.resources = { money: 1800, wood: 28, seedlings: 16, fertilizer: 30, pesticide: 12 };
    this.speed = 2;
    this.days = 0;
    this.day = 1;
    this.landState = LAND.FOREST;
    this.landProgress = 0;
    this.preparationProgress = 0;
    this.shelter = null;
    this.palms = [];
    this.reservedSlots = new Set();
    this.plantedSlots = new Map();
    this.slots = [];
    for (let row = 0; row < 4; row++) {
      for (let col = 0; col < 4; col++) {
        this.slots.push({ x: FIELD.x + (col - 1.5) * 5.4, z: FIELD.z + (row - 1.5) * 4.3, row, col });
      }
    }
    this.player = { x: -22, z: 18, tx: -22, tz: 18, state: 'IDLE' };
    this.worker = { x: -22, z: 13, tx: -22, tz: 13, state: 'IDLE', jobType: '', progress: 0, experience: 0 };
    this.activeJob = null;
    this.jobQueue = [];
  }

  toast(message, kind = 'info') { this.onToast(message, kind); }
  setSpeed(value) { this.speed = Math.max(1, Math.min(6, Number(value) || 1)); }

  isValidShelterSite(point) {
    const inside = point.x >= -30 && point.x <= -11 && point.z >= 6 && point.z <= 23;
    const nearCamp = Math.hypot(point.x + 26, point.z - 17) < 4.4;
    const nearLogs = Math.hypot(point.x + 14, point.z - 19.5) < 2.6;
    return inside && !nearCamp && !nearLogs;
  }

  insideField(point) {
    return Math.abs(point.x - FIELD.x) <= FIELD.width / 2 && Math.abs(point.z - FIELD.z) <= FIELD.depth / 2;
  }

  buildShelter(point) {
    if (this.shelter) return this.toast('The starter shelter is already placed.', 'info'), false;
    if (!this.isValidShelterSite(point)) return this.toast('Choose a clear site inside the camp clearing.', 'warning'), false;
    if (this.resources.money < 300 || this.resources.wood < 10) return this.toast('The shelter needs $300 and 10 timber.', 'warning'), false;
    this.resources.money -= 300;
    this.resources.wood -= 10;
    this.shelter = { x: point.x, z: point.z, progress: 0, complete: false };
    this.enqueue('BUILDING', point, 8, {});
    this.toast('Shelter site chosen. Your crew is on the way.', 'success');
    return true;
  }

  clearField(point) {
    if (!this.shelter?.complete) return this.toast('Build the starter shelter before clearing land.', 'warning'), false;
    if (this.landState !== LAND.FOREST) return this.toast('This block is already being worked.', 'info'), false;
    if (!this.insideField(point)) return this.toast('Select the marked forest block.', 'warning'), false;
    this.landState = LAND.CLEARING;
    this.landProgress = 0;
    this.enqueue('CLEARING', { x: FIELD.x, z: FIELD.z }, 12, {});
    this.toast('Land clearing started. Trees will recede as the crew works.', 'success');
    return true;
  }

  prepareRows() {
    if (this.landState !== LAND.CLEARED) return this.toast('Clear the block before preparing rows.', 'warning'), false;
    this.landState = LAND.PREPARING;
    this.preparationProgress = 0;
    this.enqueue('PREPARATION', { x: FIELD.x, z: FIELD.z }, 5, {});
    this.toast('The worker is marking four planting rows.', 'success');
    return true;
  }

  plant(slotIndex) {
    if (this.landState !== LAND.PREPARED) return this.toast('Clear and prepare the block before planting.', 'warning'), false;
    if (slotIndex < 0 || slotIndex >= this.slots.length) return false;
    if (this.plantedSlots.has(slotIndex) || this.reservedSlots.has(slotIndex)) return this.toast('That planting point is occupied or queued.', 'info'), false;
    if (this.resources.seedlings <= 0) return this.toast('No seedlings remain.', 'warning'), false;
    this.resources.seedlings--;
    this.reservedSlots.add(slotIndex);
    this.enqueue('PLANTING', this.slots[slotIndex], 3, { slotIndex });
    this.toast(`Planting order queued · row ${Math.floor(slotIndex / 4) + 1}, position ${slotIndex % 4 + 1}.`, 'success');
    return true;
  }

  maintenance(action, palmId) {
    const palm = this.palms.find((entry) => entry.id === palmId);
    if (!palm) return false;
    if (action === 'FERTILIZE') {
      if (this.resources.fertilizer < 5) return this.toast('Need 5 fertilizer units.', 'warning'), false;
      this.resources.fertilizer -= 5;
    } else if (action === 'TREAT') {
      if (this.resources.pesticide < 2) return this.toast('Need 2 treatment units.', 'warning'), false;
      this.resources.pesticide -= 2;
    } else if (action !== 'INSPECT') return false;
    this.enqueue(action, palm, action === 'INSPECT' ? 1.5 : 2.5, { palmId });
    this.toast(`${action === 'TREAT' ? 'Pest treatment' : action.toLowerCase()} queued for the worker.`, 'success');
    return true;
  }

  enqueue(type, target, duration, payload) {
    const job = { type, target: { x: target.x, z: target.z }, duration, elapsed: 0, payload };
    if (!this.activeJob) this.assign(job);
    else this.jobQueue.push(job);
  }

  assign(job) {
    this.activeJob = job;
    this.worker.tx = job.target.x;
    this.worker.tz = job.target.z;
    this.worker.jobType = job.type;
    this.worker.progress = 0;
    this.worker.state = 'WALKING';
    this.player.tx = job.target.x;
    this.player.tz = job.target.z;
    this.player.state = 'WALKING';
  }

  update(delta) {
    const scaled = delta * this.speed;
    const dayDelta = scaled / DAY_SECONDS;
    this.days += dayDelta;
    this.day = Math.floor(this.days) + 1;
    for (const palm of this.palms) {
      palm.age += dayDelta;
      palm.fertilizer = Math.max(0, palm.fertilizer - 0.55 * dayDelta);
      palm.health = Math.max(0, palm.health - 0.28 * dayDelta);
      palm.pests = Math.min(100, palm.pests + 0.4 * dayDelta);
      palm.stage = palm.age >= 45 ? 3 : palm.age >= 22 ? 2 : palm.age >= 8 ? 1 : 0;
    }

    this.moveActor(this.player, delta, 4.4);
    if (!this.activeJob && this.jobQueue.length) this.assign(this.jobQueue.shift());
    if (!this.activeJob) {
      this.worker.state = 'IDLE';
      this.worker.jobType = '';
      this.worker.progress = 0;
      return;
    }
    if (this.worker.state === 'WALKING') {
      const arrived = this.moveActor(this.worker, delta, 3.5);
      if (arrived) {
        this.worker.state = this.stateForJob(this.activeJob.type);
        this.player.state = this.activeJob.type;
      }
      return;
    }

    this.activeJob.elapsed += scaled;
    const progress = Math.min(1, this.activeJob.elapsed / this.activeJob.duration);
    this.worker.progress = progress;
    if (this.activeJob.type === 'BUILDING' && this.shelter) this.shelter.progress = progress;
    if (this.activeJob.type === 'CLEARING') this.landProgress = progress;
    if (this.activeJob.type === 'PREPARATION') this.preparationProgress = progress;
    if (progress >= 1) this.finishJob();
  }

  moveActor(actor, delta, speed) {
    const dx = actor.tx - actor.x;
    const dz = actor.tz - actor.z;
    const length = Math.hypot(dx, dz);
    if (length < 0.2) { actor.x = actor.tx; actor.z = actor.tz; return true; }
    const step = Math.min(length, speed * delta);
    actor.x += dx / length * step;
    actor.z += dz / length * step;
    if (length - step < 0.2) { actor.x = actor.tx; actor.z = actor.tz; return true; }
    return false;
  }

  stateForJob(type) {
    if (type === 'BUILDING') return 'BUILDING';
    if (type === 'CLEARING' || type === 'PREPARATION') return 'CLEARING';
    if (type === 'PLANTING') return 'PLANTING';
    return type;
  }

  finishJob() {
    const { type, payload } = this.activeJob;
    if (type === 'BUILDING') {
      this.shelter.progress = 1;
      this.shelter.complete = true;
      this.toast('Starter shelter complete. The plantation can expand.', 'success');
    } else if (type === 'CLEARING') {
      this.landProgress = 1;
      this.landState = LAND.CLEARED;
      this.toast('Forest cleared. Use LAND to prepare planting rows.', 'success');
    } else if (type === 'PREPARATION') {
      this.preparationProgress = 1;
      this.landState = LAND.PREPARED;
      this.toast('Four rows are ready. Select PLANT to place seedlings.', 'success');
    } else if (type === 'PLANTING') {
      const index = payload.slotIndex;
      this.reservedSlots.delete(index);
      const palm = { id: `palm_${index + 1}`, slotIndex: index, x: this.slots[index].x, z: this.slots[index].z, age: 0, stage: 0, health: 100, fertilizer: 0, pests: 0, inspected: false };
      this.plantedSlots.set(index, palm);
      this.palms.push(palm);
      this.toast(`Seedling planted in row ${Math.floor(index / 4) + 1}.`, 'success');
    } else {
      const palm = this.palms.find((entry) => entry.id === payload.palmId);
      if (palm && type === 'FERTILIZE') { palm.fertilizer = 100; palm.health = Math.min(100, palm.health + 10); this.toast('Palm fertilized · health +10.', 'success'); }
      if (palm && type === 'TREAT') { palm.pests = Math.max(0, palm.pests - 25); palm.health = Math.min(100, palm.health + 10); this.toast('Pest treatment complete · health +10.', 'success'); }
      if (palm && type === 'INSPECT') { palm.inspected = true; palm.lastInspectedDay = this.day; this.toast(`${STAGE_NAMES[palm.stage]} · ${Math.round(palm.health)}% health.`, 'success'); }
    }
    this.worker.experience++;
    this.activeJob = null;
    this.worker.state = 'IDLE';
    this.worker.jobType = '';
    this.worker.progress = 0;
    this.player.state = 'IDLE';
  }

  progressInfo() {
    const milestone = (value) => value >= 1 ? 100 : Math.floor(value * 4) * 25;
    if (this.shelter && !this.shelter.complete) return { label: 'SHELTER BUILD', value: milestone(this.shelter.progress) };
    if (this.landState === LAND.CLEARING) return { label: 'LAND CLEARING', value: milestone(this.landProgress) };
    if (this.landState === LAND.PREPARING) return { label: 'ROW PREPARATION', value: milestone(this.preparationProgress) };
    if (this.activeJob && !['WALKING'].includes(this.worker.state)) return { label: this.activeJob.type, value: milestone(this.worker.progress) };
    return { label: `DAY ${String(this.day).padStart(2, '0')} · SPEED ${this.speed}×`, value: 0 };
  }

  phaseInfo() {
    if (!this.shelter) return ['01 · ESTABLISH A BASE', 'Build the starter shelter', 'Choose a clear spot in camp. Your crew will build it in stages.'];
    if ([LAND.FOREST, LAND.CLEARING].includes(this.landState)) return ['02 · OPEN THE LAND', 'Clear the surveyed forest block', 'Select the marked block east of camp to begin clearing.'];
    if ([LAND.CLEARED, LAND.PREPARING].includes(this.landState)) return ['03 · PREPARE PLANTING ROWS', 'Prepare the planting block', 'Use LAND to have the worker lay out four orderly rows.'];
    if (!this.palms.length) return ['04 · PLANT THE FIRST ROWS', 'Plant your first seedlings', 'Tap an open row marker to queue a seedling with the worker.'];
    return ['05 · GROW & MAINTAIN', 'Keep the block healthy', 'Select a palm to inspect, fertilize, or treat pests.'];
  }

  stageName(palm) { return STAGE_NAMES[palm.stage] || STAGE_NAMES[0]; }
}
