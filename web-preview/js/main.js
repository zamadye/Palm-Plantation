import { PlantationSimulation, LAND } from './simulation.js';
import { createWorld, loadWorldAssets, syncWorld } from './world.js';

const canvas = document.querySelector('#world');
const renderer = new THREE.WebGLRenderer({ canvas, antialias: true, powerPreference: 'high-performance' });
renderer.setPixelRatio(Math.min(window.devicePixelRatio || 1, 1.5));
renderer.setSize(window.innerWidth, window.innerHeight);
renderer.outputEncoding = THREE.sRGBEncoding;
renderer.setClearColor(0x687860, 1);

const scene = new THREE.Scene();
scene.background = new THREE.Color('#72836b');
scene.fog = new THREE.Fog('#72836b', 115, 195);
const camera = new THREE.PerspectiveCamera(43, window.innerWidth / window.innerHeight, .1, 260);
scene.add(new THREE.HemisphereLight('#e6e5ce', '#424d38', 1.55));
const sun = new THREE.DirectionalLight('#fff0cc', 2.1);
sun.position.set(-32, 58, 24);
scene.add(sun);
const fill = new THREE.DirectionalLight('#a8bda0', .58);
fill.position.set(30, 25, -30);
scene.add(fill);

let toastTimer = 0;
function toast(message, kind = 'info') {
  const el = document.querySelector('#toast');
  el.textContent = message;
  el.dataset.kind = kind;
  el.classList.add('show');
  clearTimeout(toastTimer);
  toastTimer = setTimeout(() => el.classList.remove('show'), 2600);
}

const sim = new PlantationSimulation(toast);
const world = createWorld(scene, sim);
const assetStatus = document.querySelector('#asset-status');
function updateAssetStatus(progress) {
  if (!assetStatus) return;
  assetStatus.dataset.state = progress.completed >= progress.total ? (progress.failed ? 'partial' : 'ready') : 'loading';
  const label = progress.failed
    ? `3D ASSETS · ${progress.loaded}/${progress.total} LOADED`
    : `3D ASSETS · ${progress.completed >= progress.total ? 'READY' : `${progress.loaded}/${progress.total} LOADING`}`;
  assetStatus.querySelector('span:last-child').textContent = label;
}
loadWorldAssets(world, updateAssetStatus).then(({ loaded, failed, total }) => {
  if (failed === 0) toast(`Downloaded 3D assets loaded · ${loaded}/${total} models ready in the web preview.`, 'info');
  else toast(`Some 3D assets did not load · ${loaded}/${total} models available. Check the asset server path.`, 'warning');
}).catch((error) => {
  console.error('Web preview could not initialize downloaded 3D assets.', error);
  updateAssetStatus({ completed: 1, total: 1, loaded: 0, failed: 1 });
  toast('Downloaded 3D assets are unavailable. Start the preview from the repository root.', 'warning');
});
let activeAction = '';
let selection = null;
let detailSignature = '';
let focus = new THREE.Vector3(-8, 0, 5);
let distance = 91;
let yaw = 40 * Math.PI / 180;
const pitch = 48 * Math.PI / 180;
const raycaster = new THREE.Raycaster();
const ndc = new THREE.Vector2();
const ground = new THREE.Plane(new THREE.Vector3(0, 1, 0), 0);
const hit = new THREE.Vector3();

function updateCamera() {
  const offset = new THREE.Vector3(
    Math.sin(yaw) * Math.cos(pitch) * distance,
    Math.sin(pitch) * distance,
    Math.cos(yaw) * Math.cos(pitch) * distance,
  );
  camera.position.copy(focus).add(offset);
  camera.lookAt(focus.x, focus.y + 1, focus.z);
}
updateCamera();

function groundPoint(clientX, clientY) {
  const rect = canvas.getBoundingClientRect();
  ndc.set(((clientX - rect.left) / rect.width) * 2 - 1, -((clientY - rect.top) / rect.height) * 2 + 1);
  raycaster.setFromCamera(ndc, camera);
  return raycaster.ray.intersectPlane(ground, hit) ? hit.clone() : null;
}
function setAction(action = '') {
  activeAction = action;
  document.querySelectorAll('.action').forEach((button) => button.classList.toggle('active', button.dataset.action === action));
}
function showDetails(kind, data = null) {
  selection = { kind, id: data?.id ?? null };
  detailSignature = '';
  renderDetails();
}
function closeDetails() {
  selection = null;
  detailSignature = '';
  document.querySelector('#details').classList.add('hidden');
}

function detailStateSignature() {
  if (!selection) return '';
  if (selection.kind === 'worker') {
    const task = sim.worker.current_task;
    return `worker|${sim.worker.state}|${task?.id}|${task?.status}|${Math.floor((task?.progress ?? 0) * 4)}|${sim.taskQueue.length}|${sim.worker.experience}|${Math.round(sim.worker.carried_ffb_kg)}`;
  }
  if (selection.kind === 'palm') {
    const palm = sim.palms.find((entry) => entry.id === selection.id);
    if (!palm) return 'missing-palm';
    return `palm|${palm.id}|${palm.growth_stage}|${palm.fruit_state}|${palm.harvest_ready}|${palm.fruit_quantity}|${palm.harvest_count}|${palm.age.toFixed(1)}|${Math.round(palm.health)}|${Math.round(palm.fertilizer)}|${Math.round(palm.pest_risk)}|${sim.harvestReservations.has(palm.id)}|${sim._available('fertilizer')}|${sim._available('pesticide')}`;
  }
  if (selection.kind === 'zone') {
    return `zone|${sim.landState}|${Math.floor(sim.landProgress * 4)}|${sim.palms.length}|${sim.reservedSlots.size}|${sim.resources.money}|${sim._available('seedlings')}|${sim._available('fertilizer')}|${sim._available('pesticide')}|${sim.getReadyHarvestCount()}|${Boolean(sim.shelter?.complete)}`;
  }
  if (selection.kind === 'shelter') return `shelter|${Math.floor((sim.shelter?.progress ?? 0) * 4)}|${Boolean(sim.shelter?.complete)}`;
  if (selection.kind === 'collection') return `collection|${sim.resources.harvested_ffb_kg}|${sim.latestTransaction?.id}|${sim.latestTransaction?.revenue}|${sim.resources.money}`;
  return `management|${sim.landState}|${sim.day}|${sim.speed}|${sim.palms.length}|${sim.tasks.filter((task) => task.status === 'QUEUED').length}|${sim.activeTask?.id}`;
}

function renderDetails() {
  const panel = document.querySelector('#details');
  if (!selection) { panel.classList.add('hidden'); return; }
  const nextSignature = detailStateSignature();
  if (nextSignature === detailSignature) return;
  detailSignature = nextSignature;
  panel.classList.remove('hidden');
  if (selection.kind === 'worker') {
    const worker = sim.worker;
    const task = worker.current_task;
    const taskLabel = task ? `${task.task_type.replace('_', ' ')} · ${task.status}` : 'Available';
    const carrying = worker.carrying_ffb ? `<div class="detail-row"><span>Carrying</span><b>${Math.round(worker.carried_ffb_kg)} kg FFB</b></div>` : '';
    panel.innerHTML = `<button class="detail-close" aria-label="Close">×</button><h2>${worker.name.toUpperCase()} · FIELD WORKER</h2><p class="detail-sub">${worker.role} · ${worker.state}</p><div class="detail-row"><span>Active task</span><b>${taskLabel}</b></div><div class="detail-row"><span>Task progress</span><b>${task ? `${Math.round(task.progress * 100)}%` : '—'}</b></div><div class="meter"><i style="width:${task ? task.progress * 100 : 0}%"></i></div><div class="detail-row"><span>Productivity</span><b>${Math.round(worker.productivity * 100)}%</b></div><div class="detail-row"><span>Work queue</span><b>${sim.taskQueue.length} orders</b></div>${carrying}<div class="detail-row"><span>Completed jobs</span><b>${worker.experience}</b></div><div class="detail-actions"><button data-focus>FOCUS WORKER</button></div>`;
  } else if (selection.kind === 'palm') {
    const palm = sim.palms.find((entry) => entry.id === selection.id);
    if (!palm) return closeDetails();
    const canFertilize = sim._available('fertilizer') >= 5;
    const canTreat = sim._available('pesticide') >= 2;
    const fruitLabels = { NONE: palm.growth_stage === 2 ? 'Mature' : 'No fruit', DEVELOPING: 'Fruit developing', READY: 'Ready to harvest', HARVESTED: 'Harvested', RECOVERING: 'Recovery / growing' };
    const estimatedFFB = palm.harvest_ready ? Math.round(palm.fruit_quantity) : sim.estimateFFBYield(palm);
    const harvestReserved = sim.harvestReservations.has(palm.id);
    const harvestAction = palm.harvest_ready
      ? `<div class="detail-actions"><button data-harvest ${harvestReserved ? 'disabled' : ''}>${harvestReserved ? 'HARVEST ORDERED' : 'HARVEST'}</button></div>`
      : (palm.growth_stage === 2 ? '<p class="detail-note">Fruit is not ripe yet. Keep accelerated time running while it develops.</p>' : '');
    const lastHarvest = palm.last_harvest == null ? '' : `<div class="detail-row"><span>Last harvest / cycles</span><b>Day ${Math.floor(palm.last_harvest) + 1} · ${palm.harvest_count}</b></div>`;
    panel.innerHTML = `<button class="detail-close" aria-label="Close">×</button><h2>PALM · ${sim.stageName(palm).toUpperCase()}</h2><p class="detail-sub">${palm.id.replace('_', ' ')} · Age ${palm.age.toFixed(1)} game days</p><div class="detail-row"><span>Stage</span><b>${sim.stageName(palm).toUpperCase()}</b></div><div class="detail-row"><span>Health</span><b>${Math.round(palm.health)}%</b></div><div class="detail-row"><span>Fruit state</span><b>${fruitLabels[palm.fruit_state] ?? 'Mature'}</b></div><div class="detail-row"><span>Estimated FFB</span><b>${estimatedFFB} kg</b></div>${lastHarvest}${harvestAction}<div class="detail-row"><span>Fertilizer</span><b>${Math.round(palm.fertilizer)}%</b></div><div class="meter"><i style="width:${palm.fertilizer}%;background:#b8ad6a"></i></div><div class="detail-row"><span>Pest risk</span><b>${Math.round(palm.pest_risk)}%</b></div><div class="meter"><i style="width:${palm.pest_risk}%;background:#ce8961"></i></div><div class="detail-actions"><button data-maint="FERTILIZE" ${canFertilize ? '' : 'disabled'}>FERTILIZE · 5</button><button data-maint="TREAT" ${canTreat ? '' : 'disabled'}>TREAT PEST · 2</button></div>`;
    panel.querySelector('[data-harvest]')?.addEventListener('click', () => sim.requestHarvest(palm.id));
    panel.querySelectorAll('[data-maint]').forEach((button) => button.addEventListener('click', () => sim.maintenance(button.dataset.maint, 'palm', palm.id)));
  } else if (selection.kind === 'zone') {
    const state = ['Forest', 'Clearing', 'Prepared land'][sim.landState];
    let content = `<div class="detail-row"><span>Block state</span><b>${state}</b></div>`;
    if (sim.landState === LAND.FOREST) {
      content += `<p class="detail-note">Clear the marked forest block. A $150 crew and equipment fee is charged when the order starts.</p><div class="detail-actions"><button data-clear ${sim.shelter?.complete ? '' : 'disabled'}>CLEAR LAND · $150</button></div>`;
    } else if (sim.landState === LAND.CLEARING) {
      content += `<div class="detail-row"><span>Clearing progress</span><b>${Math.floor(sim.landProgress * 100)}%</b></div><div class="meter"><i style="width:${sim.landProgress * 100}%"></i></div><p class="detail-note">Rafi is removing the block vegetation. The planting grid appears when work is complete.</p>`;
    } else {
      content += `<div class="detail-row"><span>Planting positions</span><b>${sim.palms.length + sim.reservedSlots.size} / 16</b></div><p class="detail-note">Four evenly spaced rows are ready. Choose PLANT, then tap an open marker.</p><div class="detail-actions"><button data-plant>PLANT A SEEDLING</button></div>`;
      const readyCount = sim.getReadyHarvestCount();
      if (readyCount > 0) content += `<div class="detail-row"><span>Ready to harvest</span><b>${readyCount}</b></div><div class="detail-actions"><button data-harvest-block>HARVEST READY PALMS · ${readyCount}</button></div>`;
      if (sim.palms.length > 0) content += `<div class="detail-actions"><button data-maint="FERTILIZE">FERTILIZE BLOCK · 5</button><button data-maint="TREAT">TREAT BLOCK · 2</button></div>`;
    }
    panel.innerHTML = `<button class="detail-close" aria-label="Close">×</button><h2>BLOCK 01 · ${state.toUpperCase()}</h2><p class="detail-sub">${sim.landState === LAND.PREPARED ? 'Surveyed 4 × 4 planting grid' : 'Survey stakes · east of camp'}</p>${content}`;
    panel.querySelector('[data-clear]')?.addEventListener('click', () => {
      if (sim.clearField({ x: 8, z: 10 })) setAction('');
    });
    panel.querySelector('[data-plant]')?.addEventListener('click', () => { setAction('PLANT'); toast('Tap an open marker in the prepared grid.', 'info'); });
    panel.querySelector('[data-harvest-block]')?.addEventListener('click', () => sim.requestHarvestBlock());
    panel.querySelectorAll('[data-maint]').forEach((button) => button.addEventListener('click', () => sim.maintenance(button.dataset.maint, 'block', 'block_01')));
  } else if (selection.kind === 'shelter') {
    const shelter = sim.shelter;
    if (!shelter) return closeDetails();
    const percent = Math.floor(shelter.progress * 100);
    panel.innerHTML = `<button class="detail-close" aria-label="Close">×</button><h2>STARTER SHELTER</h2><p class="detail-sub">${shelter.complete ? 'Complete · field office established' : `Under construction · ${percent}%`}</p><div class="detail-row"><span>Construction</span><b>${percent}%</b></div><div class="meter"><i style="width:${percent}%"></i></div>`;
  } else if (selection.kind === 'collection') {
    const sale = sim.latestTransaction;
    const saleDetails = sale ? `<p class="detail-sub">Last sale · ${sale.id}</p><div class="detail-row"><span>Sold</span><b>${sale.ffb_kg} kg FFB</b></div><div class="detail-row"><span>Revenue</span><b>+$${sale.revenue}</b></div><div class="detail-row"><span>Funds after sale</span><b>$${sale.funds_after.toLocaleString('en-US')}</b></div>` : '';
    panel.innerHTML = `<button class="detail-close" aria-label="Close">×</button><h2>FFB COLLECTION</h2><p class="detail-sub">Fresh fruit bunch depot</p><div class="detail-row"><span>Stored FFB</span><b>${sim.resources.harvested_ffb_kg.toLocaleString('en-US')} kg</b></div><div class="detail-row"><span>Prototype price</span><b>$${sim.pricePerKg.toFixed(2)} / kg</b></div><p class="detail-note">Rafi delivers harvested bunches here before they can be sold.</p><div class="detail-actions"><button data-sell ${sim.resources.harvested_ffb_kg > 0 ? '' : 'disabled'}>SELL STORED FFB</button></div>${saleDetails}`;
    panel.querySelector('[data-sell]')?.addEventListener('click', () => sim.sellFFB());
  } else {
    const queued = sim.tasks.filter((task) => task.status === 'QUEUED').length;
    const state = ['Forest', 'Clearing', 'Prepared'][sim.landState];
    panel.innerHTML = `<button class="detail-close" aria-label="Close">×</button><h2>BLOCK MANAGEMENT</h2><p class="detail-sub">Compact estate report · Prototype 0.2</p><div class="detail-row"><span>Land</span><b>${state}</b></div><div class="detail-row"><span>Planting grid</span><b>${sim.landState === LAND.PREPARED ? '4 × 4 ready' : 'Not prepared'}</b></div><div class="detail-row"><span>Palms</span><b>${sim.palms.length} / 16</b></div><div class="detail-row"><span>Open worker orders</span><b>${queued + (sim.activeTask ? 1 : 0)}</b></div><div class="detail-row"><span>Day / speed</span><b>${sim.day} · ${sim.speed}×</b></div>`;
  }
  panel.querySelector('.detail-close')?.addEventListener('click', closeDetails);
  panel.querySelector('[data-focus]')?.addEventListener('click', () => { focus.set(sim.worker.x, 0, sim.worker.z); });
}

function updateHud() {
  const { resources } = sim;
  document.querySelector('#res-money').textContent = resources.money.toLocaleString('en-US');
  document.querySelector('#res-wood').textContent = resources.wood;
  document.querySelector('#res-seedlings').textContent = resources.seedlings;
  document.querySelector('#res-fertilizer').textContent = resources.fertilizer;
  document.querySelector('#res-pesticide').textContent = resources.pesticide;
  document.querySelector('#res-ffb').textContent = Math.round(resources.harvested_ffb_kg).toLocaleString('en-US');
  document.querySelector('#day-label').textContent = String(sim.day).padStart(2, '0');
  document.querySelectorAll('[data-speed]').forEach((button) => button.classList.toggle('selected', Number(button.dataset.speed) === sim.speed));
  const [phase, title, hint] = sim.phaseInfo();
  document.querySelector('#phase-label').textContent = phase;
  document.querySelector('#objective-title').textContent = title;
  let activeHint = hint;
  if (activeAction === 'BUILD') activeHint = 'Tap a valid spot in the camp clearing to place the shelter.';
  if (activeAction === 'LAND') activeHint = sim.landState === LAND.FOREST ? 'Tap inside the survey stakes east of camp to clear the block.' : hint;
  if (activeAction === 'PLANT') activeHint = 'Tap an open marker in the prepared rows to queue a seedling.';
  if (sim.worker.state !== 'IDLE' && sim.worker.state !== 'WALKING') activeHint = `Rafi is ${sim.worker.state.toLowerCase().replace('_', ' ')}…`;
  document.querySelector('#objective-hint').textContent = activeHint;
  const progress = sim.progressInfo();
  document.querySelector('#progress-label').textContent = progress.label;
  document.querySelector('#progress-value').textContent = `${progress.value}%`;
  document.querySelector('#progress-fill').style.width = `${progress.value}%`;
  if (selection) renderDetails();
}

function handleAction(action) {
  closeDetails();
  if (action === 'BUILD') {
    if (sim.shelter) return toast('The starter shelter is already placed.', 'info');
    setAction(activeAction === action ? '' : action);
    if (activeAction) toast('Tap a clear site inside the camp clearing.', 'info');
    return;
  }
  if (action === 'LAND') {
    showDetails('zone', sim.zone);
    if (sim.landState === LAND.FOREST && sim.shelter?.complete) {
      setAction(activeAction === action ? '' : action);
      if (activeAction) toast('Tap inside the surveyed block or use CLEAR LAND in its panel.', 'info');
      return;
    }
    setAction('');
    if (sim.landState === LAND.FOREST) toast('Complete the starter shelter first.', 'warning');
    else if (sim.landState === LAND.CLEARING) toast('The crew is already clearing this block.', 'info');
    return;
  }
  if (action === 'PLANT') {
    if (sim.landState !== LAND.PREPARED) { setAction(''); return toast('Prepare the land before planting.', 'warning'); }
    setAction(activeAction === action ? '' : action);
    if (activeAction) toast('Tap an open row marker to queue a seedling.', 'info');
    return;
  }
  if (action === 'WORKERS') {
    setAction('WORKERS'); showDetails('worker', sim.worker); focus.set(sim.worker.x, 0, sim.worker.z); return;
  }
  setAction('MANAGEMENT'); showDetails('management', null);
}

function nearestOpenSlot(point) {
  let best = -1, bestDistance = 2.1;
  sim.slots.forEach((slot, i) => {
    if (sim.plantedSlots.has(i) || sim.reservedSlots.has(i)) return;
    const d = Math.hypot(point.x - slot.x, point.z - slot.z);
    if (d < bestDistance) { best = i; bestDistance = d; }
  });
  return best;
}
function handleWorldClick(point) {
  if (Math.abs(point.x) > 45 || Math.abs(point.z) > 38) return;
  if (activeAction === 'BUILD') {
    if (sim.buildShelter(point)) setAction('');
    return;
  }
  if (activeAction === 'LAND') {
    if (sim.clearField(point)) { setAction(''); showDetails('zone', sim.zone); }
    else if (sim.insideField(point)) showDetails('zone', sim.zone);
    return;
  }
  if (activeAction === 'PLANT') {
    const slot = nearestOpenSlot(point);
    if (slot >= 0) sim.plant(slot);
    else toast('Choose one of the open planting markers.', 'warning');
    return;
  }
  // Select the collection point before the worker; Rafi returns to this spot after each delivery.
  if (Math.hypot(point.x - sim.collectionPoint.x, point.z - sim.collectionPoint.z) < 3.5) {
    setAction(''); showDetails('collection', sim.collectionPoint); return;
  }
  if (Math.hypot(point.x - sim.worker.x, point.z - sim.worker.z) < 1.7) {
    setAction('WORKERS'); showDetails('worker', sim.worker); return;
  }
  let nearestPalm = null, palmDist = 1.9;
  for (const palm of sim.palms) {
    const d = Math.hypot(point.x - palm.position.x, point.z - palm.position.z);
    if (d < palmDist) { nearestPalm = palm; palmDist = d; }
  }
  if (nearestPalm) { setAction(''); showDetails('palm', nearestPalm); return; }
  if (sim.shelter && Math.hypot(point.x - sim.shelter.position.x, point.z - sim.shelter.position.z) < 4) {
    setAction(''); showDetails('shelter', sim.shelter); return;
  }
  if (sim.insideField(point)) { setAction(''); showDetails('zone', sim.zone); return; }
  setAction(''); closeDetails();
}

document.querySelectorAll('.action').forEach((button) => button.addEventListener('click', () => handleAction(button.dataset.action)));
document.querySelectorAll('[data-speed]').forEach((button) => button.addEventListener('click', () => sim.setSpeed(button.dataset.speed)));

// Pointer controls: tap/click selects, drag pans, wheel or pinch zooms.
const pointers = new Map();
let pinchDistance = 0;
let gestureDragged = false;
let lastPan = null;
function pointerDistance() {
  const pts = [...pointers.values()];
  return pts.length < 2 ? 0 : Math.hypot(pts[0].x - pts[1].x, pts[0].y - pts[1].y);
}
canvas.addEventListener('pointerdown', (event) => {
  if (event.button !== 0) return;
  canvas.setPointerCapture(event.pointerId);
  pointers.set(event.pointerId, { x: event.clientX, y: event.clientY, startX: event.clientX, startY: event.clientY });
  if (pointers.size === 2) { pinchDistance = pointerDistance(); gestureDragged = true; }
  lastPan = { x: event.clientX, y: event.clientY };
  event.preventDefault();
});
canvas.addEventListener('pointermove', (event) => {
  if (!pointers.has(event.pointerId)) return;
  const current = pointers.get(event.pointerId);
  current.x = event.clientX; current.y = event.clientY;
  if (pointers.size >= 2) {
    const nextDistance = pointerDistance();
    if (pinchDistance > 0 && nextDistance > 0) distance = Math.max(42, Math.min(148, distance * pinchDistance / nextDistance));
    pinchDistance = nextDistance;
    return;
  }
  if (!lastPan) return;
  const dx = event.clientX - lastPan.x, dy = event.clientY - lastPan.y;
  if (Math.hypot(event.clientX - current.startX, event.clientY - current.startY) > 5) gestureDragged = true;
  if (gestureDragged) {
    const unitsPerPixel = (2 * distance * Math.tan(THREE.MathUtils.degToRad(camera.fov / 2))) / Math.max(1, window.innerHeight);
    const right = new THREE.Vector3(Math.cos(yaw), 0, -Math.sin(yaw));
    const forward = new THREE.Vector3(Math.sin(yaw), 0, Math.cos(yaw));
    focus.addScaledVector(right, -dx * unitsPerPixel);
    focus.addScaledVector(forward, dy * unitsPerPixel);
  }
  lastPan = { x: event.clientX, y: event.clientY };
});
canvas.addEventListener('pointerup', (event) => {
  const current = pointers.get(event.pointerId);
  if (current && !gestureDragged && pointers.size === 1) {
    const point = groundPoint(event.clientX, event.clientY);
    if (point) handleWorldClick(point);
  }
  pointers.delete(event.pointerId);
  if (pointers.size < 2) pinchDistance = 0;
  if (!pointers.size) { lastPan = null; gestureDragged = false; }
});
canvas.addEventListener('pointercancel', (event) => { pointers.delete(event.pointerId); lastPan = null; gestureDragged = false; });
canvas.addEventListener('wheel', (event) => {
  event.preventDefault();
  distance = Math.max(42, Math.min(148, distance * (event.deltaY > 0 ? 1.08 : .92)));
}, { passive: false });
window.addEventListener('keydown', (event) => {
  if (event.code === 'KeyQ') yaw -= .08;
  if (event.code === 'KeyE') yaw += .08;
  if (event.code === 'Escape') { setAction(''); closeDetails(); }
});
window.addEventListener('resize', () => {
  const width = window.innerWidth, height = window.innerHeight;
  camera.aspect = width / height; camera.updateProjectionMatrix();
  renderer.setPixelRatio(Math.min(window.devicePixelRatio || 1, 1.5));
  renderer.setSize(width, height);
});

let lastTime = performance.now();
let uiTime = 0;
let clock = 0;
function frame(now) {
  requestAnimationFrame(frame);
  const delta = Math.min(.05, Math.max(0, (now - lastTime) / 1000));
  lastTime = now; clock += delta;
  sim.update(delta);
  updateCamera();
  syncWorld(world, sim, clock, selection);
  uiTime += delta;
  if (uiTime > .12) { uiTime = 0; updateHud(); }
  renderer.render(scene, camera);
}
updateHud();
requestAnimationFrame(frame);
toast('Drag to scout the block · BUILD a starter shelter to begin.', 'info');
