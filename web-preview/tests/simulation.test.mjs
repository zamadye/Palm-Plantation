import assert from 'node:assert/strict';
import test from 'node:test';
import {
  FRUIT_STATE,
  LAND,
  TASK_STATE,
  TASK_STATUS,
  PlantationSimulation,
} from '../js/simulation.js';

const STEP_SECONDS = 0.05;

function advanceUntil(simulation, predicate, label, maxTicks = 50000) {
  for (let tick = 0; tick < maxTicks; tick += 1) {
    if (predicate()) return;
    simulation.update(STEP_SECONDS);
  }
  assert.fail(`Timed out waiting for ${label} (day ${simulation.day}, worker ${simulation.worker.state}).`);
}

function preparePlantingBlock(simulation) {
  // These focused tests start after the establishment gate; the end-to-end test
  // below covers the full fresh-state path through clearing.
  simulation.landState = LAND.PREPARED;
  simulation.zone.state = LAND.PREPARED;
}

test('fresh state has bounded resources and sixteen distinct planting positions', () => {
  const simulation = new PlantationSimulation();

  assert.equal(simulation.resources.money, 1800);
  assert.equal(simulation.resources.seedlings, 16);
  assert.equal(simulation.landState, LAND.FOREST);
  assert.equal(simulation.slots.length, 16);
  assert.equal(new Set(simulation.slots.map(({ x, z }) => `${x},${z}`)).size, 16);
});

test('shelter and clearing prerequisites charge exactly once and reach prepared land', () => {
  const simulation = new PlantationSimulation();
  const initialMoney = simulation.resources.money;

  assert.equal(simulation.clearField({ x: 8, z: 10 }), false);
  assert.equal(simulation.resources.money, initialMoney);
  assert.equal(simulation.buildShelter({ x: -20, z: 11 }), true);
  assert.equal(simulation.resources.money, initialMoney - 300);
  assert.equal(simulation.resources.wood, 18);
  assert.equal(simulation.buildShelter({ x: -20, z: 11 }), false);
  assert.equal(simulation.resources.money, initialMoney - 300);

  advanceUntil(simulation, () => simulation.shelter.complete, 'shelter completion');
  assert.equal(simulation.clearField({ x: 80, z: 80 }), false);
  assert.equal(simulation.resources.money, initialMoney - 300);
  assert.equal(simulation.clearField({ x: 8, z: 10 }), true);
  assert.equal(simulation.resources.money, initialMoney - 450);
  assert.equal(simulation.clearField({ x: 8, z: 10 }), false);
  assert.equal(simulation.resources.money, initialMoney - 450);

  advanceUntil(simulation, () => simulation.landState === LAND.PREPARED, 'prepared land');
  assert.equal(simulation.zone.state, LAND.PREPARED);
  assert.equal(simulation.landProgress, 1);
});

test('planting reservations prevent duplicates and consume one seedling per completed slot', () => {
  const simulation = new PlantationSimulation();
  preparePlantingBlock(simulation);

  for (let slot = 0; slot < simulation.slots.length; slot += 1) {
    assert.equal(simulation.plant(slot), true, `slot ${slot} should be queueable`);
  }
  assert.equal(simulation.plant(0), false);
  assert.equal(simulation.plant(16), false);
  assert.equal(simulation.resources.seedlings, 16);
  assert.equal(simulation.reservedSlots.size, 16);

  advanceUntil(simulation, () => simulation.palms.length === 16, 'all planting tasks');
  assert.equal(simulation.resources.seedlings, 0);
  assert.equal(simulation.reservedSlots.size, 0);
  assert.equal(new Set(simulation.palms.map((palm) => palm.id)).size, 16);
  assert.equal(new Set(simulation.palms.map((palm) => palm.slot_index)).size, 16);
  assert.equal(simulation.plant(0), false);
});

test('maintenance reserves inventory and consumes it once when queued tasks finish', () => {
  const simulation = new PlantationSimulation();
  preparePlantingBlock(simulation);
  simulation.palms.push({
    id: 'palm_fixture',
    age: 60,
    growth_stage: 2,
    health: 50,
    fertilizer: 0,
    pest_risk: 30,
    position: { x: 8, z: 10 },
    fruit_state: FRUIT_STATE.NONE,
    harvest_ready: false,
    fruit_quantity: 0,
    harvest_count: 0,
    fruit_cycle_days: 0,
  });

  for (let order = 0; order < 6; order += 1) {
    assert.equal(simulation.maintenance('FERTILIZE', 'palm', 'palm_fixture'), true);
  }
  assert.equal(simulation.maintenance('FERTILIZE', 'palm', 'palm_fixture'), false);
  assert.equal(simulation.resources.fertilizer, 30);
  assert.equal(simulation._available('fertilizer'), 0);

  advanceUntil(
    simulation,
    () => simulation.tasks.filter((task) => task.task_type === 'FERTILIZING' && task.status === TASK_STATUS.COMPLETED).length === 6,
    'all fertilizing tasks',
  );
  assert.equal(simulation.resources.fertilizer, 0);
  assert.equal(simulation.palms[0].fertilizer, 100);
  assert.equal(simulation.palms[0].health, 100);
});

test('first harvest conserves FFB through delivery and sale, then permits a repeat cycle', () => {
  const simulation = new PlantationSimulation();

  assert.equal(simulation.buildShelter({ x: -20, z: 11 }), true);
  advanceUntil(simulation, () => simulation.shelter.complete, 'shelter completion');
  assert.equal(simulation.clearField({ x: 8, z: 10 }), true);
  advanceUntil(simulation, () => simulation.landState === LAND.PREPARED, 'prepared land');
  assert.equal(simulation.plant(0), true);
  advanceUntil(simulation, () => simulation.palms.length === 1, 'first planted palm');

  const [palm] = simulation.palms;
  assert.equal(simulation.requestHarvest(palm.id), false, 'an immature palm cannot be harvested');
  assert.equal(simulation.tasks.some((task) => task.task_type === 'HARVESTING'), false);
  assert.equal(simulation.maintenance('FERTILIZE', 'palm', palm.id), true);
  advanceUntil(
    simulation,
    () => simulation.tasks.some((task) => task.task_type === 'FERTILIZING' && task.status === TASK_STATUS.COMPLETED),
    'fertilizing task',
  );
  assert.equal(simulation.maintenance('TREAT', 'palm', palm.id), true);
  advanceUntil(
    simulation,
    () => simulation.tasks.some((task) => task.task_type === 'TREATING' && task.status === TASK_STATUS.COMPLETED),
    'pest treatment task',
  );
  advanceUntil(simulation, () => palm.harvest_ready, 'first harvest readiness');
  assert.equal(palm.fruit_state, FRUIT_STATE.READY);

  const expectedKg = palm.fruit_quantity;
  const initialTaskCount = simulation.tasks.length;
  assert.equal(simulation.requestHarvest(palm.id), true);
  assert.equal(simulation.requestHarvest(palm.id), false);
  assert.equal(simulation.tasks.length, initialTaskCount + 1);
  assert.equal(simulation.harvestReservations.has(palm.id), true);
  assert.equal(simulation.worker.state, TASK_STATE.WALKING);
  assert.equal(palm.harvest_ready, true, 'harvest readiness should change only when work completes');
  assert.equal(simulation.resources.harvested_ffb_kg, 0);

  const workerStart = { x: simulation.worker.x, z: simulation.worker.z };
  simulation.update(STEP_SECONDS);
  assert.notDeepEqual(
    { x: simulation.worker.x, z: simulation.worker.z },
    workerStart,
    'worker should move toward the harvest task',
  );
  advanceUntil(
    simulation,
    () => simulation.activeTask?.task_type === 'HARVESTING' && simulation.activeTask.status === TASK_STATUS.IN_PROGRESS,
    'harvest task start',
  );
  assert.equal(simulation.worker.state, TASK_STATE.HARVESTING);
  advanceUntil(
    simulation,
    () => simulation.tasks.some((task) => task.task_type === 'HARVESTING' && task.status === TASK_STATUS.COMPLETED),
    'harvest completion',
  );
  assert.equal(simulation.harvestReservations.has(palm.id), false);
  assert.equal(palm.harvest_ready, false);
  assert.equal(simulation.worker.carrying_ffb, true);
  assert.equal(simulation.resources.harvested_ffb_kg, 0, 'FFB must not be in collection before delivery');
  assert.equal(simulation.activeTask.task_type, 'FFB_DELIVERY', 'delivery should take priority after harvest');

  advanceUntil(
    simulation,
    () => simulation.resources.harvested_ffb_kg === expectedKg && simulation.worker.state === TASK_STATE.IDLE,
    'FFB delivery',
  );
  assert.equal(simulation.worker.carried_ffb_kg, 0);
  assert.equal(simulation.worker.carrying_ffb, false);

  const moneyBeforeSale = simulation.resources.money;
  const sale = simulation.sellFFB();
  assert.equal(sale.ffb_kg, expectedKg);
  assert.equal(sale.revenue, expectedKg);
  assert.equal(simulation.resources.money, moneyBeforeSale + expectedKg);
  assert.equal(simulation.transactions.length, 1);
  assert.equal(simulation.resources.harvested_ffb_kg, 0);
  assert.equal(simulation.sellFFB(), false, 'empty stock cannot be sold twice');
  assert.equal(simulation.transactions.length, 1);
  assert.equal(simulation.resources.money, moneyBeforeSale + expectedKg);

  advanceUntil(simulation, () => palm.harvest_ready, 'repeat harvest readiness');
  assert.equal(palm.harvest_count, 1);
  assert.equal(simulation.palms.length, 1, 'harvesting must not remove the palm');
  const secondYieldKg = palm.fruit_quantity;
  const fundsBeforeSecondSale = simulation.resources.money;
  assert.equal(simulation.requestHarvest(palm.id), true);
  advanceUntil(simulation, () => palm.harvest_count === 2, 'second harvest completion');
  assert.equal(simulation.worker.carrying_ffb, true);
  assert.equal(simulation.activeTask.task_type, 'FFB_DELIVERY');
  advanceUntil(
    simulation,
    () => simulation.resources.harvested_ffb_kg === secondYieldKg && simulation.worker.state === TASK_STATE.IDLE,
    'second FFB delivery',
  );
  const secondSale = simulation.sellFFB();
  assert.equal(secondSale.ffb_kg, secondYieldKg);
  assert.equal(secondSale.revenue, secondYieldKg);
  assert.equal(simulation.transactions.length, 2);
  assert.equal(simulation.resources.money, fundsBeforeSecondSale + secondYieldKg);
  assert.equal(simulation.resources.harvested_ffb_kg, 0);
});
