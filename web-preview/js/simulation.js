// Browser-side simulation port. Rendering reads these data records; it never owns task logic.
export const LAND = Object.freeze({ FOREST: 0, CLEARING: 1, PREPARED: 2 });
export const TASK_STATUS = Object.freeze({ QUEUED: 'QUEUED', ASSIGNED: 'ASSIGNED', IN_PROGRESS: 'IN_PROGRESS', COMPLETED: 'COMPLETED' });
export const TASK_STATE = Object.freeze({
  IDLE: 'IDLE', WALKING: 'WALKING', CLEARING: 'CLEARING', PLANTING: 'PLANTING',
  FERTILIZING: 'FERTILIZING', TREATING: 'TREATING', BUILDING: 'BUILDING',
  HARVESTING: 'HARVESTING', DELIVERING: 'DELIVERING',
});
export const FRUIT_STATE = Object.freeze({
  NONE: 'NONE', DEVELOPING: 'DEVELOPING', READY: 'READY', HARVESTED: 'HARVESTED', RECOVERING: 'RECOVERING',
});

const FIELD = { id: 'block_01', x: 8, z: 10, width: 24, depth: 18 };
const DAY_SECONDS = 3;
const CLEARING_COST = 150;
const HARVEST_DURATION = 5;
const DELIVERY_DURATION = 2;
const BASE_FFB_YIELD_KG = 180;
const PROTOTYPE_FFB_PRICE_PER_KG = 1;
const STAGE_NAMES = ['Seedling', 'Young palm', 'Mature palm'];
const ACTIVE_STATUSES = new Set([TASK_STATUS.QUEUED, TASK_STATUS.ASSIGNED, TASK_STATUS.IN_PROGRESS]);

export class PlantationSimulation {
  constructor(onToast = () => {}) {
    this.onToast = onToast;
    this.resources = {
      money: 1800, wood: 28, seedlings: 16, fertilizer: 30, pesticide: 12, harvested_ffb_kg: 0,
    };
    this.speed = 2;
    this.days = 0;
    this.day = 1;
    this.landState = LAND.FOREST;
    this.landProgress = 0;
    this.shelter = null;
    this.palms = [];
    this.reservedSlots = new Set();
    this.harvestReservations = new Set();
    this.plantedSlots = new Map();
    this.slots = [];
    this._createPlantingSlots();
    this.player = { x: -22, z: 18, tx: -22, tz: 18, state: TASK_STATE.IDLE };
    this.worker = {
      id: 'worker_01', name: 'Rafi', role: 'Field worker', state: TASK_STATE.IDLE,
      current_task: null, productivity: 1, x: -22, z: 13, tx: -22, tz: 13,
      progress: 0, experience: 0, energy: 100, morale: 100,
      carrying_ffb: false, carried_ffb_kg: 0,
      get activeTaskId() { return this.current_task?.id ?? null; },
    };
    this.tasks = [];
    this.activeTask = null;
    this.taskQueue = [];
    this.taskSequence = 0;
    this.transactionSequence = 0;
    this.transactions = [];
    this.latestTransaction = null;
    this.collectionPoint = { id: 'ffb_collection_01', name: 'FFB Collection', x: 26, z: 10 };
    this.pricePerKg = PROTOTYPE_FFB_PRICE_PER_KG;
    this.zone = { id: FIELD.id, position: { x: FIELD.x, z: FIELD.z }, size: { width: FIELD.width, depth: FIELD.depth }, state: LAND.FOREST, clearingProgress: 0 };
  }

  toast(message, kind = 'info') { this.onToast(message, kind); }
  setSpeed(value) { this.speed = Math.max(1, Math.min(6, Number(value) || 1)); }

  _createPlantingSlots() {
    this.slots = [];
    // The visible markers stay hidden until clearing completes; positions are deliberately orderly.
    for (let row = 0; row < 4; row++) for (let col = 0; col < 4; col++) {
      this.slots.push({ x: FIELD.x + (col - 1.5) * 5.4, z: FIELD.z + (row - 1.5) * 4.3, row, col });
    }
  }

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
    this.shelter = { id: 'starter_shelter', position: { x: point.x, z: point.z }, progress: 0, complete: false };
    this.enqueueTask('BUILDING', point, 8, { buildingId: 'starter_shelter' });
    this.toast('Shelter site chosen. Your crew is on the way.', 'success');
    return true;
  }

  clearField(point) {
    if (!this.shelter?.complete) return this.toast('Build the starter shelter before clearing land.', 'warning'), false;
    if (this.landState !== LAND.FOREST) return this.toast('This block is already being worked.', 'info'), false;
    if (!this.insideField(point)) return this.toast('Select the marked forest block.', 'warning'), false;
    if (this.resources.money < CLEARING_COST) return this.toast(`Land clearing needs $${CLEARING_COST}.`, 'warning'), false;
    this.resources.money -= CLEARING_COST;
    this.landState = LAND.CLEARING;
    this.zone.state = LAND.CLEARING;
    this.landProgress = 0;
    this.zone.clearingProgress = 0;
    this.enqueueTask('CLEARING', FIELD, 12, { zoneId: FIELD.id });
    this.toast(`Land clearing started · $${CLEARING_COST} crew and equipment cost.`, 'success');
    return true;
  }

  plant(slotIndex) {
    if (this.landState !== LAND.PREPARED) return this.toast('Clear the block before planting.', 'warning'), false;
    if (slotIndex < 0 || slotIndex >= this.slots.length) return false;
    if (this.plantedSlots.has(slotIndex) || this.reservedSlots.has(slotIndex)) return this.toast('That planting point is occupied or queued.', 'info'), false;
    if (this._available('seedlings') < 1) return this.toast('No free seedlings remain.', 'warning'), false;
    this.reservedSlots.add(slotIndex);
    this.enqueueTask('PLANTING', this.slots[slotIndex], 3, { slotIndex, resource: 'seedlings', cost: 1 });
    this.toast(`Planting order queued · row ${Math.floor(slotIndex / 4) + 1}, position ${slotIndex % 4 + 1}.`, 'success');
    return true;
  }

  maintenance(action, targetType, targetId) {
    const type = action === 'FERTILIZE' ? 'FERTILIZING' : (action === 'TREAT' || action === 'TREAT PEST') ? 'TREATING' : '';
    if (!type) return false;
    const costKey = type === 'FERTILIZING' ? 'fertilizer' : 'pesticide';
    const cost = type === 'FERTILIZING' ? 5 : 2;
    const palm = targetType === 'palm' ? this.palms.find((item) => item.id === targetId) : null;
    if (targetType === 'palm' && !palm) return false;
    if (targetType === 'block' && (this.landState !== LAND.PREPARED || this.palms.length === 0)) return this.toast('Plant a palm before maintaining the block.', 'warning'), false;
    if (!['palm', 'block'].includes(targetType)) return false;
    if (this._available(costKey) < cost) return this.toast(`Not enough ${costKey}. Need ${cost} units.`, 'warning'), false;
    const target = palm ? { x: palm.position.x, z: palm.position.z } : FIELD;
    this.enqueueTask(type, target, 2.5, { targetType, targetId: palm?.id ?? FIELD.id, resource: costKey, cost });
    this.toast(`${type === 'FERTILIZING' ? 'Fertilizing' : 'Pest treatment'} assigned to Rafi.`, 'success');
    return true;
  }

  requestHarvest(palmId, showToast = true) {
    const palm = this.palms.find((entry) => entry.id === palmId);
    if (!palm || !palm.harvest_ready || palm.fruit_state !== FRUIT_STATE.READY) {
      if (showToast) this.toast('This palm is not ready to harvest.', 'warning');
      return false;
    }
    if (this.harvestReservations.has(palmId)) {
      if (showToast) this.toast('A harvest task is already assigned to this palm.', 'info');
      return false;
    }
    this.harvestReservations.add(palmId);
    const workPosition = { x: palm.position.x, z: palm.position.z + 1.1 };
    this.enqueueTask('HARVESTING', workPosition, HARVEST_DURATION, {
      palmId, fruitQuantity: palm.fruit_quantity,
    });
    if (showToast) this.toast('Harvest assigned. Rafi is walking to the ready palm.', 'success');
    return true;
  }

  requestHarvestBlock() {
    let queued = 0;
    for (const palm of this.palms) {
      if (palm.harvest_ready && !this.harvestReservations.has(palm.id) && this.requestHarvest(palm.id, false)) queued++;
    }
    if (!queued) this.toast('No unreserved palms are ready to harvest.', 'info');
    else this.toast(`${queued} harvest task${queued === 1 ? '' : 's'} queued for the ready block.`, 'success');
    return queued;
  }

  getReadyHarvestCount() {
    return this.palms.filter((palm) => palm.harvest_ready && !this.harvestReservations.has(palm.id)).length;
  }

  estimateFFBYield(palm) {
    if (!palm || palm.growth_stage !== 2) return 0;
    const healthFactor = Math.max(.25, Math.min(1, palm.health / 100));
    return Math.round(BASE_FFB_YIELD_KG * healthFactor);
  }

  sellFFB() {
    const kilograms = this.resources.harvested_ffb_kg;
    if (kilograms <= 0) {
      this.toast('There is no FFB in the collection point to sell.', 'warning');
      return false;
    }
    const revenue = Math.round(kilograms * PROTOTYPE_FFB_PRICE_PER_KG);
    this.resources.money += revenue;
    this.resources.harvested_ffb_kg = 0;
    const transaction = {
      id: `sale_${String(++this.transactionSequence).padStart(3, '0')}`,
      day: this.day,
      ffb_kg: kilograms,
      price_per_kg: PROTOTYPE_FFB_PRICE_PER_KG,
      revenue,
      funds_after: this.resources.money,
    };
    this.transactions.push(transaction);
    this.latestTransaction = transaction;
    this.toast(`HARVEST SOLD · ${kilograms} kg FFB · Revenue +$${revenue} · Funds $${this.resources.money}`, 'success');
    return transaction;
  }

  _available(resource) {
    const reserved = this.tasks.reduce((sum, task) => {
      return sum + (ACTIVE_STATUSES.has(task.status) && task.payload.resource === resource ? task.payload.cost : 0);
    }, 0);
    return this.resources[resource] - reserved;
  }

  enqueueTask(taskType, target, duration, payload = {}, highPriority = false) {
    const task = {
      id: `task_${String(++this.taskSequence).padStart(3, '0')}`,
      task_type: taskType,
      target: { x: target.x, z: target.z },
      assigned_worker: null,
      duration: Math.max(.1, duration / Math.max(.1, this.worker.productivity)),
      elapsed: 0,
      progress: 0,
      status: TASK_STATUS.QUEUED,
      payload,
    };
    this.tasks.push(task);
    if (!this.activeTask && this.worker.state === TASK_STATE.IDLE) this._assignTask(task);
    else if (highPriority) this.taskQueue.unshift(task);
    else this.taskQueue.push(task);
    return task;
  }

  _assignTask(task) {
    task.assigned_worker = this.worker.id;
    task.status = TASK_STATUS.ASSIGNED;
    this.activeTask = task;
    this.worker.current_task = task;
    this.worker.tx = task.target.x;
    this.worker.tz = task.target.z;
    this.worker.progress = 0;
    this.worker.state = TASK_STATE.WALKING;
    this.player.tx = task.target.x;
    this.player.tz = task.target.z;
    this.player.state = TASK_STATE.WALKING;
  }

  _startNextTask() {
    while (!this.activeTask && this.taskQueue.length) {
      const next = this.taskQueue.shift();
      if (next.status === TASK_STATUS.QUEUED) this._assignTask(next);
    }
  }

  update(delta) {
    const scaled = delta * this.speed;
    const dayDelta = scaled / DAY_SECONDS;
    this.days += dayDelta;
    this.day = Math.floor(this.days) + 1;
    this._advanceGrowth(dayDelta);

    this.moveActor(this.player, delta, 4.4);
    this._startNextTask();
    const task = this.activeTask;
    if (!task) {
      this.worker.state = TASK_STATE.IDLE;
      this.worker.current_task = null;
      this.worker.progress = 0;
      return;
    }
    if (this.worker.state === TASK_STATE.WALKING) {
      const arrived = this.moveActor(this.worker, delta, 3.5);
      if (arrived) {
        this.worker.state = this._stateForTask(task.task_type);
        this.player.state = this.worker.state;
        task.status = TASK_STATUS.IN_PROGRESS;
      }
      return;
    }

    task.elapsed += scaled;
    task.progress = Math.min(1, task.elapsed / Math.max(.01, task.duration));
    this.worker.progress = task.progress;
    if (task.task_type === 'BUILDING' && this.shelter) this.shelter.progress = task.progress;
    if (task.task_type === 'CLEARING') {
      this.landProgress = task.progress;
      this.zone.clearingProgress = task.progress;
    }
    if (task.progress >= 1) this._finishTask(task);
  }

  _advanceGrowth(dayDelta) {
    if (dayDelta <= 0) return;
    for (const palm of this.palms) {
      const previousStage = palm.growth_stage;
      const previousFruitState = palm.fruit_state;
      palm.age += dayDelta;
      palm.fertilizer = Math.max(0, palm.fertilizer - .55 * dayDelta);
      palm.health = Math.max(0, palm.health - .28 * dayDelta);
      palm.pest_risk = Math.min(100, palm.pest_risk + .4 * dayDelta);
      palm.growth_stage = palm.age >= 45 ? 2 : palm.age >= 8 ? 1 : 0;

      if (palm.growth_stage === 2 && !palm.harvest_ready) {
        palm.fruit_cycle_days += dayDelta;
        if (palm.fruit_state === FRUIT_STATE.NONE && palm.fruit_cycle_days >= 4) {
          palm.fruit_state = FRUIT_STATE.DEVELOPING;
        } else if (palm.fruit_state === FRUIT_STATE.HARVESTED && palm.fruit_cycle_days >= 1) {
          palm.fruit_state = FRUIT_STATE.RECOVERING;
        } else if (palm.fruit_state === FRUIT_STATE.RECOVERING && palm.fruit_cycle_days >= 8) {
          palm.fruit_state = FRUIT_STATE.DEVELOPING;
        } else if (palm.fruit_state === FRUIT_STATE.DEVELOPING) {
          const readyDay = palm.harvest_count === 0 ? 15 : 20;
          if (palm.fruit_cycle_days >= readyDay) {
            palm.fruit_quantity = this.estimateFFBYield(palm);
            palm.harvest_ready = palm.fruit_quantity > 0;
            if (palm.harvest_ready) palm.fruit_state = FRUIT_STATE.READY;
          }
        }
      }
      if (palm.growth_stage !== previousStage || palm.fruit_state !== previousFruitState) {
        palm.last_changed_day = this.days;
      }
    }
  }

  moveActor(actor, delta, speed) {
    const dx = actor.tx - actor.x, dz = actor.tz - actor.z;
    const length = Math.hypot(dx, dz);
    if (length < .2) { actor.x = actor.tx; actor.z = actor.tz; return true; }
    const step = Math.min(length, speed * delta);
    actor.x += dx / length * step;
    actor.z += dz / length * step;
    if (length - step < .2) { actor.x = actor.tx; actor.z = actor.tz; return true; }
    return false;
  }

  _stateForTask(type) {
    if (type === 'BUILDING') return TASK_STATE.BUILDING;
    if (type === 'CLEARING') return TASK_STATE.CLEARING;
    if (type === 'PLANTING') return TASK_STATE.PLANTING;
    if (type === 'FERTILIZING') return TASK_STATE.FERTILIZING;
    if (type === 'TREATING') return TASK_STATE.TREATING;
    if (type === 'HARVESTING') return TASK_STATE.HARVESTING;
    if (type === 'FFB_DELIVERY') return TASK_STATE.DELIVERING;
    return TASK_STATE.IDLE;
  }

  _finishTask(task) {
    const payload = task.payload;
    let harvestedKg = 0;
    if (task.task_type === 'BUILDING' && this.shelter) {
      this.shelter.progress = 1;
      this.shelter.complete = true;
      this.toast('Starter shelter complete. The plantation can expand.', 'success');
    } else if (task.task_type === 'CLEARING') {
      this.landProgress = 1;
      this.zone.clearingProgress = 1;
      this.landState = LAND.PREPARED;
      this.zone.state = LAND.PREPARED;
      this.toast('Land prepared. Four organized planting rows are now marked.', 'success');
    } else if (task.task_type === 'PLANTING') {
      const index = payload.slotIndex;
      this.reservedSlots.delete(index);
      this.resources.seedlings--;
      const slot = this.slots[index];
      const palm = {
        id: `palm_${String(index + 1).padStart(2, '0')}`,
        age: 0,
        growth_stage: 0,
        health: 100,
        fertilizer: 0,
        pest_risk: 0,
        position: { x: slot.x, z: slot.z },
        slot_index: index,
        fruit_state: FRUIT_STATE.NONE,
        harvest_ready: false,
        fruit_quantity: 0,
        last_harvest: null,
        harvest_count: 0,
        fruit_cycle_days: 0,
      };
      this.plantedSlots.set(index, palm);
      this.palms.push(palm);
      this.toast(`Seedling planted · row ${slot.row + 1}, position ${slot.col + 1}.`, 'success');
    } else if (task.task_type === 'FERTILIZING' || task.task_type === 'TREATING') {
      this.resources[payload.resource] -= payload.cost;
      const targets = payload.targetType === 'palm'
        ? this.palms.filter((palm) => palm.id === payload.targetId)
        : this.palms.filter((palm) => this.insideField(palm.position));
      targets.forEach((palm) => {
        if (task.task_type === 'FERTILIZING') {
          palm.fertilizer = 100;
          palm.health = Math.min(100, palm.health + 10);
        } else {
          palm.pest_risk = Math.max(0, palm.pest_risk - 25);
          palm.health = Math.min(100, palm.health + 10);
        }
      });
      this.toast(task.task_type === 'FERTILIZING' ? 'Fertilizing complete · health +10.' : 'Pest treatment complete · health +10.', 'success');
    } else if (task.task_type === 'HARVESTING') {
      const palm = this.palms.find((entry) => entry.id === payload.palmId);
      this.harvestReservations.delete(payload.palmId);
      if (palm) {
        harvestedKg = Math.max(0, Math.round(payload.fruitQuantity ?? palm.fruit_quantity));
        palm.harvest_ready = false;
        palm.fruit_state = FRUIT_STATE.HARVESTED;
        palm.fruit_quantity = 0;
        palm.last_harvest = this.days;
        palm.harvest_count++;
        palm.fruit_cycle_days = 0;
        this.worker.carried_ffb_kg += harvestedKg;
        this.worker.carrying_ffb = this.worker.carried_ffb_kg > 0;
        this.toast(`Harvested ${harvestedKg} kg FFB. Rafi is carrying it to collection.`, 'success');
      }
    } else if (task.task_type === 'FFB_DELIVERY') {
      const depositKg = Math.min(Math.max(0, Math.round(payload.kg ?? this.worker.carried_ffb_kg)), Math.round(this.worker.carried_ffb_kg));
      if (depositKg > 0) {
        this.resources.harvested_ffb_kg += depositKg;
        this.worker.carried_ffb_kg = Math.max(0, this.worker.carried_ffb_kg - depositKg);
        this.worker.carrying_ffb = this.worker.carried_ffb_kg > 0;
        this.toast(`Rafi deposited ${depositKg} kg FFB at the collection point.`, 'success');
      }
    }

    task.status = TASK_STATUS.COMPLETED;
    task.progress = 1;
    this.worker.experience++;
    this.activeTask = null;
    this.worker.current_task = null;
    this.worker.state = TASK_STATE.IDLE;
    this.worker.progress = 0;
    this.player.state = TASK_STATE.IDLE;
    if (task.task_type === 'HARVESTING' && harvestedKg > 0) {
      this.enqueueTask('FFB_DELIVERY', this.collectionPoint, DELIVERY_DURATION, { kg: harvestedKg }, true);
    }
  }

  stageName(palm) { return STAGE_NAMES[palm.growth_stage] || STAGE_NAMES[0]; }

  progressInfo() {
    const round = (value) => value >= 1 ? 100 : Math.floor(value * 4) * 25;
    if (this.shelter && !this.shelter.complete) return { label: 'SHELTER BUILD', value: round(this.shelter.progress) };
    if (this.landState === LAND.CLEARING) return { label: 'LAND CLEARING', value: round(this.landProgress) };
    if (this.activeTask && this.worker.state !== TASK_STATE.WALKING) return { label: this.activeTask.task_type, value: round(this.activeTask.progress) };
    return { label: `DAY ${String(this.day).padStart(2, '0')} · SPEED ${this.speed}×`, value: 0 };
  }

  phaseInfo() {
    if (!this.shelter) return ['01 · ESTABLISH A BASE', 'Build the starter shelter', 'Choose a clear spot in camp. Your crew will build it in stages.'];
    if (!this.shelter.complete) return ['01 · ESTABLISH A BASE', 'Build the starter shelter', 'Rafi is constructing the field base.'];
    if (this.landState === LAND.FOREST || this.landState === LAND.CLEARING) return ['02 · OPEN THE LAND', 'Clear the surveyed forest block', 'Select the marked block east of camp to begin clearing.'];
    if (!this.palms.length) return ['03 · PLANT THE FIRST ROWS', 'Plant your first seedlings', 'Tap an open row marker to assign the worker.'];
    if (this.resources.harvested_ffb_kg > 0) return ['06 · SELL THE FIRST HARVEST', 'Turn FFB into revenue', 'Open the FFB collection point and sell the stored bunches.'];
    if (this.getReadyHarvestCount() > 0 || this.palms.some((palm) => palm.harvest_ready)) return ['05 · FIRST HARVEST', 'Harvest ready fresh fruit bunches', 'Select a mature palm or the block to assign a harvesting task.'];
    if (this.palms.some((palm) => palm.growth_stage === 2)) return ['04 · GROW & MAINTAIN', 'Mature palms are developing fruit', 'Fruit ripens over accelerated game time; maintain palm health to support yield.'];
    return ['04 · GROW & MAINTAIN', 'Keep the block healthy', 'Select a palm to fertilize or treat pests while it grows.'];
  }
}
