// Lightweight Three.js mirror of the procedural Godot test map.
const C = THREE.Color;
const V3 = THREE.Vector3;

function material(color, roughness = 0.92, extra = {}) {
  return new THREE.MeshStandardMaterial({ color, roughness, metalness: 0, ...extra });
}
function mesh(geometry, mat, parent, position = [0, 0, 0]) {
  const item = new THREE.Mesh(geometry, mat);
  item.position.set(...position);
  item.castShadow = false;
  item.receiveShadow = false;
  parent.add(item);
  return item;
}
function box(parent, size, position, color, mat = null) {
  return mesh(new THREE.BoxGeometry(...size), mat || material(color), parent, position);
}
function groundPlane(parent, width, depth, position, color, opacity = 1) {
  const mat = material(color, 1, opacity < 1 ? { transparent: true, opacity, depthWrite: false } : {});
  const plane = mesh(new THREE.PlaneGeometry(width, depth), mat, parent, position);
  plane.rotation.x = -Math.PI / 2;
  return plane;
}
function cylinder(parent, radiusTop, radiusBottom, height, position, color, segments = 8, rotation = [0, 0, 0]) {
  const item = mesh(new THREE.CylinderGeometry(radiusTop, radiusBottom, height, segments), material(color), parent, position);
  item.rotation.set(...rotation);
  return item;
}
function sphere(parent, radius, position, color, scale = [1, 1, 1], segments = 10) {
  const item = mesh(new THREE.SphereGeometry(radius, segments, Math.max(5, segments - 2)), material(color), parent, position);
  item.scale.set(...scale);
  return item;
}
function seeded(seed) {
  let value = seed >>> 0;
  return () => { value = (value * 1664525 + 1013904223) >>> 0; return value / 4294967296; };
}

function treeGroup(height, spread, tint) {
  const root = new THREE.Group();
  const trunkHeight = height * 0.61;
  cylinder(root, spread * 0.11, spread * 0.15, trunkHeight, [0, trunkHeight / 2, 0], '#60472f');
  const crownY = trunkHeight + height * 0.19;
  sphere(root, spread, [0, crownY, 0], tint, [1.12, 0.88, 0.98], 8);
  sphere(root, spread * 0.69, [spread * 0.52, crownY - 0.26, 0.05], new C(tint).offsetHSL(0, 0, 0.045), [1, .85, 1], 7);
  sphere(root, spread * 0.66, [-spread * 0.48, crownY - 0.18, -0.08], new C(tint).offsetHSL(0, 0, -0.04), [1, .87, 1], 7);
  return root;
}

function buildForestInstances(scene) {
  const rand = seeded(90317);
  const positions = [];
  for (let zi = 0; zi < 15; zi++) for (let xi = 0; xi < 18; xi++) {
    const x = -40 + xi * 4.75 + (rand() * 2 - 1) * 1.4;
    const z = -33 + zi * 4.65 + (rand() * 2 - 1) * 1.4;
    if (Math.abs(z) < 2.5) continue;
    if (x > -5 && x < 21 && z > -1 && z < 21) continue;
    if (x > -31 && x < -10 && z > 5 && z < 23.5) continue;
    if (Math.hypot(x - 8, z - 10) < 17) continue;
    if (x < -36 || x > 39 || z < -31 || z > 32) continue;
    positions.push({ x, z, h: 4.5 + rand() * 3.2, s: 1.05 + rand() * .6, t: rand() });
  }
  const trunkGeo = new THREE.CylinderGeometry(.09, .13, 1, 7);
  const crownGeo = new THREE.SphereGeometry(1, 9, 6);
  const sideGeo = new THREE.SphereGeometry(1, 8, 5);
  const trunk = new THREE.InstancedMesh(trunkGeo, material('#60472f'), positions.length);
  const crown = new THREE.InstancedMesh(crownGeo, material('#668047'), positions.length);
  const side = new THREE.InstancedMesh(sideGeo, material('#668047'), positions.length);
  const temp = new THREE.Object3D();
  positions.forEach((p, i) => {
    const trunkH = p.h * .59;
    temp.position.set(p.x, trunkH * .5, p.z);
    temp.scale.set(p.s, trunkH, p.s);
    temp.rotation.set(0, p.t * Math.PI * 2, 0);
    temp.updateMatrix(); trunk.setMatrixAt(i, temp.matrix);
    const shade = .94 + p.t * .15;
    const color = new C('#486840').multiplyScalar(shade);
    temp.position.set(p.x, trunkH + p.s * .48, p.z);
    temp.scale.set(p.s, p.s * .78, p.s * .91);
    temp.updateMatrix(); crown.setMatrixAt(i, temp.matrix); crown.setColorAt(i, color);
    temp.position.set(p.x + (i % 2 ? -.37 : .38) * p.s, trunkH + p.s * .38, p.z + p.s * .17);
    temp.scale.set(p.s * .62, p.s * .59, p.s * .66);
    temp.updateMatrix(); side.setMatrixAt(i, temp.matrix); side.setColorAt(i, color.clone().offsetHSL(0, 0, .04));
  });
  trunk.instanceMatrix.needsUpdate = crown.instanceMatrix.needsUpdate = side.instanceMatrix.needsUpdate = true;
  scene.add(trunk, crown, side);
}

function buildPalmFronds(length, drop, color) {
  const vertices = [];
  const segments = 10;
  for (const side of [-1, 1]) for (let i = 0; i < segments; i++) {
    const t = (i + .45) / segments;
    const spine = [length * t, -drop * t * t, 0];
    const ll = length * (.4 - .16 * t);
    const tip = [spine[0] - ll * .48, spine[1] - ll * .24, side * ll];
    const a = [spine[0] - ll * .42, spine[1] - ll * .12, side * ll * .42];
    const b = [spine[0] - ll * .12, spine[1] - ll * .14, side * ll * .78];
    vertices.push(...spine, ...a, ...tip, ...spine, ...tip, ...b);
  }
  const geometry = new THREE.BufferGeometry();
  geometry.setAttribute('position', new THREE.Float32BufferAttribute(vertices, 3));
  geometry.computeVertexNormals();
  const frond = new THREE.Mesh(geometry, material(color, .95, { side: THREE.DoubleSide }));
  frond.castShadow = false;
  return frond;
}

function createPalm(stage) {
  const root = new THREE.Group();
  const heights = [.33, .78, 1.65, 2.8];
  const radii = [.48, .88, 1.38, 1.95];
  const leaves = [5, 6, 7, 8];
  const h = heights[stage] ?? heights[0], r = radii[stage] ?? radii[0];
  cylinder(root, h < .5 ? .055 : h * .065, h < .5 ? .055 : h * .065, h, [0, h / 2, 0], '#765333', 9);
  const crown = new THREE.Group();
  crown.position.y = h + .02;
  sphere(crown, r * .18, [0, 0, 0], '#5c702d', [1, .68, 1], 7);
  for (let i = 0; i < leaves[stage]; i++) {
    const angle = Math.PI * 2 * i / leaves[stage] + .17;
    const len = r * (i % 2 === 0 ? 1.12 : .96);
    const frond = buildPalmFronds(len, r * .42, i % 2 ? '#547b2d' : '#466e27');
    frond.rotation.y = -angle;
    crown.add(frond);
  }
  root.add(crown);
  return root;
}

function createPerson(isPlayer) {
  const root = new THREE.Group();
  const shirt = isPlayer ? '#315a60' : '#c66a2c';
  const pants = '#3d4137';
  const skin = '#a87853';
  box(root, [.46, .62, .31], [0, 1.18, 0], shirt);
  box(root, [.38, .2, .29], [0, .77, 0], pants);
  if (!isPlayer) box(root, [.48, .055, .325], [0, 1.16, 0], '#d2b85f');
  sphere(root, .205, [0, 1.69, 0], skin, [.92, 1, .88], 10);
  cylinder(root, .2, .24, .12, [0, 1.88, 0], isPlayer ? '#536244' : '#d0a53d', 10);
  box(root, [.48, .045, .44], [0, 1.85, 0], isPlayer ? '#536244' : '#d0a53d');
  const parts = { arms: [], legs: [] };
  for (const sign of [-1, 1]) {
    const leg = new THREE.Group();
    leg.position.set(sign * .13, .74, 0);
    cylinder(leg, .13, .105, .64, [0, -.34, 0], pants, 7);
    box(leg, [.2, .12, .31], [0, -.68, .045], '#302b24');
    root.add(leg); parts.legs.push(leg);
    const arm = new THREE.Group();
    arm.position.set(sign * .29, 1.42, 0);
    cylinder(arm, .115, .09, .61, [0, -.32, 0], shirt, 7);
    sphere(arm, .09, [0, -.66, 0], skin, [.9, 1, .9], 7);
    root.add(arm); parts.arms.push(arm);
  }
  if (!isPlayer) {
    const tool = new THREE.Group(); tool.position.set(.2, .89, .12);
    cylinder(tool, .025, .025, .75, [0, -.1, 0], '#745337', 5);
    box(tool, [.16, .2, .05], [0, -.47, 0], '#838981');
    root.add(tool); parts.tool = tool;
  }
  root.userData.parts = parts;
  return root;
}

function createShelter() {
  const root = new THREE.Group();
  const floor = box(root, [5, .2, 4], [0, .12, 0], '#766348');
  const frame = new THREE.Group();
  const timber = '#69472c';
  for (const x of [-2.28, 2.28]) for (const z of [-1.75, 1.75]) box(frame, [.17, 2.55, .17], [x, 1.48, z], timber);
  for (const z of [-1.75, 1.75]) box(frame, [4.75, .17, .17], [0, 2.72, z], timber);
  for (const x of [-2.28, 2.28]) box(frame, [.17, .17, 3.65], [x, 2.72, 0], timber);
  root.add(frame);
  const walls = new THREE.Group();
  box(walls, [4.45, 2.02, .12], [0, 1.3, -1.72], '#9b815b');
  box(walls, [1.58, 2.02, .12], [-1.44, 1.3, 1.72], '#9b815b');
  box(walls, [1.58, 2.02, .12], [1.44, 1.3, 1.72], '#9b815b');
  box(walls, [.12, 2.02, 3.42], [-2.25, 1.3, 0], '#9b815b');
  box(walls, [.12, 2.02, 3.42], [2.25, 1.3, 0], '#9b815b');
  root.add(walls);
  const roofFrame = new THREE.Group();
  for (const z of [-1.4, 0, 1.4]) box(roofFrame, [4.9, .12, .13], [0, 3.03, z], timber);
  root.add(roofFrame);
  const roof = new THREE.Group();
  const left = box(roof, [5.5, .18, 2.45], [0, 3.34, -.79], '#565940'); left.rotation.x = -.4;
  const right = box(roof, [5.5, .18, 2.45], [0, 3.34, .79], '#646348'); right.rotation.x = .4;
  box(roof, [5.7, .19, .2], [0, 3.85, 0], '#6b674a');
  root.add(roof);
  return { root, floor, frame, walls, roofFrame, roof };
}

function addCamp(scene) {
  const camp = new THREE.Group();
  box(camp, [2.1, .18, 1.45], [0, .18, 0], '#694c31');
  const tarp = box(camp, [2.65, .12, 1.8], [0, 1.78, -.05], '#727a54'); tarp.rotation.x = -.13;
  for (const x of [-1.18, 1.18]) cylinder(camp, .045, .045, 1.68, [x, .91, 0], '#694a2e', 6);
  box(camp, [.7, .62, .62], [1.35, .32, .7], '#82613b');
  camp.position.set(-27, 0, 17); scene.add(camp);
  // Rain barrel, stacked timber and a small utility pickup.
  const barrel = new THREE.Group(); cylinder(barrel, .35, .38, .9, [0, .45, 0], '#59614b', 10); barrel.position.set(-24.9, 0, 17); scene.add(barrel);
  for (let i = 0; i < 3; i++) {
    const log = cylinder(scene, .16, .16, 2.4, [-14 + i * .25, .2, 19.5 + (i % 2) * .28], '#76583a', 8, [Math.PI / 2, 0, 0]);
    log.rotation.z = Math.PI / 2;
  }
  const truck = new THREE.Group();
  box(truck, [3.5, .62, 1.68], [0, .86, 0], '#4b5943');
  box(truck, [1.18, .35, 1.58], [-1.12, 1.24, 0], '#59684d');
  box(truck, [1.43, .9, 1.48], [.35, 1.49, 0], '#455642');
  box(truck, [.055, .65, 1.2], [-.3, 1.52, 0], '#41595a');
  box(truck, [.95, .2, 1.52], [1.55, 1.27, 0], '#394638');
  for (const x of [-1.12, 1.12]) for (const z of [-.9, .9]) cylinder(truck, .39, .39, .22, [x, .39, z], '#292a25', 10, [Math.PI / 2, 0, 0]);
  truck.position.set(-31, 0, -.8); scene.add(truck);
}

export function createWorld(scene, sim) {
  // Raised map slab and muted grass surface.
  const island = box(scene, [86, .45, 72], [0, -.34, 0], '#343d2d');
  groundPlane(scene, 82, 68, [0, -.1, 0], '#596b43');
  const rand = seeded(721);
  for (let z = -32; z <= 32; z += 8) for (let x = -40; x <= 40; x += 8) {
    const tile = groundPlane(scene, 7.9, 7.9, [x + .1, -.091, z + .1], rand() > .5 ? '#5b6d45' : '#5e7047', .14);
    tile.material.depthWrite = false;
  }
  // Access road, camp clearing, track, and small pond.
  groundPlane(scene, 83, 4, [0, -.045, 0], '#7b7057');
  groundPlane(scene, 3.2, 12, [-1.5, -.035, 7.8], '#716a4e');
  groundPlane(scene, 21, 15, [-21, -.055, 14], '#68704c');
  const pond = groundPlane(scene, 9, 5.5, [29, -.025, -25], '#315e5e'); pond.scale.set(1, 1, 1);
  const pondRim = groundPlane(scene, 10, 6.5, [29, -.04, -25], '#6f7654', .7); pondRim.material.depthWrite = false;
  // Survey field border and corner stakes.
  const field = { x: 8, z: 10, w: 24, d: 18 };
  const borderMat = material('#93805b');
  box(scene, [field.w, .06, .08], [field.x, .02, field.z - field.d / 2], '#93805b', borderMat);
  box(scene, [field.w, .06, .08], [field.x, .02, field.z + field.d / 2], '#93805b', borderMat);
  box(scene, [.08, .06, field.d], [field.x - field.w / 2, .02, field.z], '#93805b', borderMat);
  box(scene, [.08, .06, field.d], [field.x + field.w / 2, .02, field.z], '#93805b', borderMat);
  const stakes = [];
  for (const sx of [-1, 1]) for (const sz of [-1, 1]) {
    const stake = new THREE.Group();
    cylinder(stake, .052, .065, 1.05, [0, .52, 0], '#75593b', 6);
    box(stake, [.32, .2, .045], [.15, .8, 0], '#ad7e42');
    stake.position.set(field.x + sx * (field.w / 2 - .1), 0, field.z + sz * (field.d / 2 - .1));
    scene.add(stake); stakes.push(stake);
  }
  const soil = groundPlane(scene, field.w, field.d, [field.x, -.015, field.z], '#765938', 0);
  soil.visible = false;
  // Background forest uses instancing; the in-field trees remain separate to clear progressively.
  buildForestInstances(scene);
  const randField = seeded(1882);
  const clearingTrees = [];
  for (let z = 0; z < 5; z++) for (let x = 0; x < 7; x++) {
    const tx = field.x - 10 + x * 3.25 + (randField() * 1.4 - .7);
    const tz = field.z - 6.8 + z * 3.4 + (randField() * 1.3 - .65);
    const tint = randField() > .5 ? '#486840' : '#587746';
    const tree = treeGroup(4.1 + randField() * 2.2, .93 + randField() * .52, tint);
    tree.position.set(tx, 0, tz); tree.userData.distance = Math.hypot(tx - field.x, tz - field.z);
    scene.add(tree); clearingTrees.push(tree);
  }
  clearingTrees.sort((a, b) => a.userData.distance - b.userData.distance);
  // Planting row markers.
  const markers = sim.slots.map((slot) => {
    const root = new THREE.Group();
    const disc = cylinder(root, .42, .42, .055, [0, .055, 0], '#c5a761', 16);
    cylinder(root, .055, .06, .2, [0, .16, 0], '#927946', 8);
    root.position.set(slot.x, 0, slot.z); scene.add(root); return { root, disc, slot };
  });
  // Temporary camp and player/worker silhouettes.
  addCamp(scene);
  const player = createPerson(true); player.position.set(sim.player.x, 0, sim.player.z); scene.add(player);
  const worker = createPerson(false); worker.position.set(sim.worker.x, 0, sim.worker.z); scene.add(worker);
  const shelter = createShelter();
  scene.add(shelter.root); shelter.root.visible = false;
  const palmViews = new Map();
  return { scene, clearingTrees, soil, markers, player, worker, shelter, palmViews, field, stakes };
}

export function syncWorld(world, sim, clock) {
  const progress = sim.landState === 1 ? sim.landProgress : (sim.landState >= 2 ? 1 : 0);
  world.soil.visible = sim.landState !== 0;
  world.soil.material.opacity = sim.landState === 1 ? .25 + .75 * sim.landProgress : 1;
  const hiddenCount = sim.landState === 1 ? Math.floor(sim.landProgress * world.clearingTrees.length) : (sim.landState >= 2 ? world.clearingTrees.length : 0);
  world.clearingTrees.forEach((tree, i) => { tree.visible = sim.landState === 0 || i >= hiddenCount; });
  const showMarkers = sim.landState >= 3;
  world.markers.forEach((entry, i) => {
    entry.root.visible = showMarkers;
    if (sim.plantedSlots.has(i)) entry.disc.material.color.set('#5b8b50');
    else if (sim.reservedSlots.has(i)) entry.disc.material.color.set('#d39c49');
    else entry.disc.material.color.set('#c5a761');
  });
  if (sim.shelter && !world.shelter.root.visible) {
    world.shelter.root.position.set(sim.shelter.x, 0, sim.shelter.z);
    world.shelter.root.visible = true;
  }
  if (sim.shelter) {
    const p = sim.shelter.progress;
    world.shelter.frame.visible = p >= .25;
    world.shelter.walls.visible = p >= .5;
    world.shelter.roofFrame.visible = p >= .75 && p < 1;
    world.shelter.roof.visible = p >= 1;
  }
  for (const palm of sim.palms) {
    const existing = world.palmViews.get(palm.id);
    if (!existing || existing.stage !== palm.stage) {
      if (existing) world.scene?.remove(existing.root);
      const root = createPalm(palm.stage); root.position.set(palm.x, 0, palm.z);
      // Store the parent scene on first sync so stage upgrades can replace the mesh.
      root.userData.palmId = palm.id;
      world.palmViews.set(palm.id, { root, stage: palm.stage });
      if (world.scene) world.scene.add(root);
    }
  }
  for (const [id, view] of world.palmViews) {
    const data = sim.palms.find((p) => p.id === id);
    if (data) view.root.position.set(data.x, 0, data.z);
  }
  world.player.position.set(sim.player.x, 0, sim.player.z);
  world.worker.position.set(sim.worker.x, 0, sim.worker.z);
  animatePerson(world.player, sim.player.state, clock);
  animatePerson(world.worker, sim.worker.state, clock + .7);
}

function animatePerson(root, state, clock) {
  const p = root.userData.parts;
  const walking = state === 'WALKING';
  const working = ['BUILDING', 'CLEARING', 'PLANTING', 'FERTILIZE', 'TREAT', 'INSPECT'].includes(state);
  const swing = Math.sin(clock * 8) * .48;
  p.legs[0].rotation.x = walking ? swing : 0;
  p.legs[1].rotation.x = walking ? -swing : 0;
  p.arms[0].rotation.x = walking ? -swing : (working ? .15 : Math.sin(clock * 1.7) * .03);
  p.arms[1].rotation.x = walking ? swing : (working ? -.55 + Math.sin(clock * 5.8) * .4 : 0);
  if (p.tool) p.tool.visible = working;
  root.position.y = walking ? Math.abs(Math.sin(clock * 8)) * .035 : 0;
}
