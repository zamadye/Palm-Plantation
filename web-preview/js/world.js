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
function disposeObjectTree(root) {
  root.traverse((item) => {
    if (item.geometry) item.geometry.dispose();
    if (Array.isArray(item.material)) item.material.forEach((entry) => entry.dispose());
    else if (item.material) item.material.dispose();
  });
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

function createPalm(stage, fruitState = 'NONE', harvestReady = false) {
  const root = new THREE.Group();
  // Exactly three data stages: seedling, young palm, mature palm.
  const heights = [.33, .82, 2.8];
  const radii = [.48, .9, 1.95];
  const leaves = [5, 6, 8];
  const stageIndex = Math.max(0, Math.min(2, stage));
  const h = heights[stageIndex], r = radii[stageIndex];
  cylinder(root, h < .5 ? .055 : h * .065, h < .5 ? .055 : h * .065, h, [0, h / 2, 0], '#765333', 9);
  const crown = new THREE.Group();
  crown.position.y = h + .02;
  sphere(crown, r * .18, [0, 0, 0], '#5c702d', [1, .68, 1], 7);
  for (let i = 0; i < leaves[stageIndex]; i++) {
    const angle = Math.PI * 2 * i / leaves[stageIndex] + .17;
    const len = r * (i % 2 === 0 ? 1.12 : .96);
    const frond = buildPalmFronds(len, r * .42, i % 2 ? '#547b2d' : '#466e27');
    frond.rotation.y = -angle;
    crown.add(frond);
  }
  root.add(crown);
  if (stageIndex === 2 && ['DEVELOPING', 'READY'].includes(fruitState)) {
    const ripe = fruitState === 'READY';
    const fruitColor = ripe ? '#df4b19' : '#a77931';
    for (let i = 0; i < 3; i++) {
      const angle = Math.PI * 2 * i / 3 + .35;
      const fruit = sphere(
        root, .26,
        [Math.cos(angle) * .28, h * .61 - (i % 2) * .13, Math.sin(angle) * .28],
        fruitColor, [1, 1.15, .9], 9,
      );
      fruit.name = `FruitBunch_${i}`;
      if (ripe) fruit.material.emissive = new C('#862608');
    }
  }
  return root;
}

function createCollectionPoint(scene, position) {
  const root = new THREE.Group();
  root.name = 'FFBCollectionPoint';
  root.position.set(position.x, 0, position.z);
  box(root, [3.2, .2, 2.5], [0, .1, 0], '#695034');
  box(root, [.9, .78, 1.05], [-.82, .58, 0], '#795b38');
  box(root, [.9, .78, 1.05], [.82, .58, 0], '#715333');
  box(root, [2.45, .86, .1], [0, 1.9, -.95], '#536044');
  for (let i = 0; i < 5; i++) {
    const angle = Math.PI * 2 * i / 5;
    sphere(root, .27, [Math.cos(angle) * .56, 1.06 + (i % 2) * .11, Math.sin(angle) * .48], '#c24e20', [1, .88, .92], 8);
  }
  const canvas = document.createElement('canvas');
  canvas.width = 512; canvas.height = 160;
  const context = canvas.getContext('2d');
  context.fillStyle = 'rgba(32, 45, 34, .90)';
  context.fillRect(0, 0, canvas.width, canvas.height);
  const texture = new THREE.CanvasTexture(canvas);
  texture.minFilter = THREE.LinearFilter;
  const label = new THREE.Sprite(new THREE.SpriteMaterial({ map: texture, transparent: true, depthWrite: false }));
  label.position.set(0, 1.98, -.87);
  label.scale.set(3.05, .95, 1);
  root.add(label);
  scene.add(root);
  return { root, canvas, context, texture, label, amount: -1 };
}

function updateCollectionLabel(collectionView, amount) {
  if (!collectionView || collectionView.amount === amount) return;
  const { canvas, context, texture } = collectionView;
  context.clearRect(0, 0, canvas.width, canvas.height);
  context.fillStyle = 'rgba(32, 45, 34, .92)';
  context.fillRect(0, 0, canvas.width, canvas.height);
  context.fillStyle = '#efe4bd';
  context.textAlign = 'center';
  context.textBaseline = 'middle';
  context.font = '700 33px sans-serif';
  context.fillText('FFB COLLECTION', canvas.width / 2, 48);
  context.font = '700 48px sans-serif';
  context.fillText(`${Math.max(0, Math.round(amount)).toLocaleString()} KG`, canvas.width / 2, 111);
  texture.needsUpdate = true;
  collectionView.amount = amount;
}

function createSelectionMarker(field) {
  const root = new THREE.Group();
  root.visible = false;
  const gold = new THREE.MeshBasicMaterial({ color: '#efd27f', transparent: true, opacity: .92, depthWrite: false });
  const soft = new THREE.MeshBasicMaterial({ color: '#e4c775', transparent: true, opacity: .12, depthWrite: false, side: THREE.DoubleSide });
  const ring = new THREE.Mesh(new THREE.TorusGeometry(1, .065, 8, 36), gold);
  ring.rotation.x = -Math.PI / 2;
  ring.position.y = .075;
  root.add(ring);
  const ground = new THREE.Mesh(new THREE.CircleGeometry(1, 32), soft);
  ground.rotation.x = -Math.PI / 2;
  ground.position.y = .035;
  root.add(ground);
  const zone = new THREE.Group();
  const edge = (width, depth, x, z) => {
    const line = new THREE.Mesh(new THREE.BoxGeometry(width, .035, depth), gold);
    line.position.set(x, .09, z);
    zone.add(line);
  };
  edge(field.w, .07, 0, -field.d / 2); edge(field.w, .07, 0, field.d / 2);
  edge(.07, field.d, -field.w / 2, 0); edge(.07, field.d, field.w / 2, 0);
  const wash = new THREE.Mesh(new THREE.PlaneGeometry(field.w, field.d), soft);
  wash.rotation.x = -Math.PI / 2; wash.position.y = .025; zone.add(wash);
  root.add(zone);
  return { root, ring, ground, zone };
}

function syncSelection(world, sim, selection) {
  const marker = world.selection;
  marker.root.visible = Boolean(selection);
  if (!selection) return;
  marker.zone.visible = false;
  marker.ring.visible = true;
  marker.ground.visible = true;
  let x = 0, z = 0, radius = 1.2;
  if (selection.kind === 'zone') {
    x = world.field.x; z = world.field.z;
    marker.zone.visible = true; marker.ring.visible = false; marker.ground.visible = false;
  } else if (selection.kind === 'worker') {
    x = sim.worker.x; z = sim.worker.z; radius = .95;
  } else if (selection.kind === 'palm') {
    const palm = sim.palms.find((entry) => entry.id === selection.id);
    if (!palm) { marker.root.visible = false; return; }
    x = palm.position.x; z = palm.position.z;
    radius = palm.growth_stage === 2 ? 2.05 : palm.growth_stage === 1 ? 1.12 : .7;
  } else if (selection.kind === 'shelter') {
    if (!sim.shelter) { marker.root.visible = false; return; }
    x = sim.shelter.position.x; z = sim.shelter.position.z; radius = 3.4;
  } else if (selection.kind === 'collection') {
    x = sim.collectionPoint.x; z = sim.collectionPoint.z; radius = 2.25;
  } else {
    marker.root.visible = false; return;
  }
  marker.root.position.set(x, 0, z);
  marker.ring.scale.setScalar(radius);
  marker.ground.scale.setScalar(radius);
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
    const load = new THREE.Group(); load.name = 'FFBLoad'; load.position.set(0, .91, .28); load.visible = false;
    box(load, [.62, .32, .4], [0, .13, 0], '#684b2d');
    for (let i = 0; i < 3; i++) sphere(load, .16, [(i - 1) * .18, .39, -.03], '#c94b1f', [1, 1.05, .9], 7);
    root.add(load); parts.load = load;
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
  // Planting row markers and guide lines are present as lightweight nodes, but hidden until land is prepared.
  const rowGuides = new THREE.Group();
  for (let row = 0; row < 4; row++) {
    const z = field.z + (row - 1.5) * 4.3;
    box(rowGuides, [17.2, .025, .045], [field.x, .035, z], '#aa8b54');
  }
  rowGuides.visible = false;
  scene.add(rowGuides);
  const markers = sim.slots.map((slot) => {
    const root = new THREE.Group();
    const disc = cylinder(root, .42, .42, .055, [0, .055, 0], '#c5a761', 16);
    cylinder(root, .055, .06, .2, [0, .16, 0], '#927946', 8);
    root.position.set(slot.x, 0, slot.z); root.visible = false; scene.add(root); return { root, disc, slot };
  });
  // Temporary camp and player/worker silhouettes.
  addCamp(scene);
  const player = createPerson(true); player.position.set(sim.player.x, 0, sim.player.z); scene.add(player);
  const worker = createPerson(false); worker.position.set(sim.worker.x, 0, sim.worker.z); scene.add(worker);
  const shelter = createShelter();
  scene.add(shelter.root); shelter.root.visible = false;
  const collection = createCollectionPoint(scene, sim.collectionPoint);
  const palmViews = new Map();
  const selection = createSelectionMarker(field);
  scene.add(selection.root);
  return { scene, clearingTrees, soil, markers, rowGuides, player, worker, shelter, collection, palmViews, field, stakes, selection };
}

export function syncWorld(world, sim, clock, selected = null) {
  world.soil.visible = sim.landState !== 0;
  world.soil.material.opacity = sim.landState === 1 ? .25 + .75 * sim.landProgress : 1;
  const hiddenCount = sim.landState === 1 ? Math.floor(sim.landProgress * world.clearingTrees.length) : (sim.landState === 2 ? world.clearingTrees.length : 0);
  world.clearingTrees.forEach((tree, i) => { tree.visible = sim.landState === 0 || i >= hiddenCount; });
  const showGrid = sim.landState === 2;
  world.rowGuides.visible = showGrid;
  world.markers.forEach((entry, i) => {
    entry.root.visible = showGrid && !sim.plantedSlots.has(i);
    if (sim.plantedSlots.has(i)) entry.disc.material.color.set('#5b8b50');
    else if (sim.reservedSlots.has(i)) entry.disc.material.color.set('#d39c49');
    else entry.disc.material.color.set('#c5a761');
  });
  if (sim.shelter && !world.shelter.root.visible) {
    world.shelter.root.position.set(sim.shelter.position.x, 0, sim.shelter.position.z);
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
    const fruitState = palm.fruit_state ?? 'NONE';
    if (
      !existing || existing.stage !== palm.growth_stage || existing.fruitState !== fruitState
      || existing.harvestReady !== Boolean(palm.harvest_ready)
    ) {
      if (existing) {
        world.scene.remove(existing.root);
        disposeObjectTree(existing.root);
      }
      const root = createPalm(palm.growth_stage, fruitState, Boolean(palm.harvest_ready));
      root.position.set(palm.position.x, 0, palm.position.z);
      root.userData.palmId = palm.id;
      world.palmViews.set(palm.id, {
        root, stage: palm.growth_stage, fruitState, harvestReady: Boolean(palm.harvest_ready),
      });
      world.scene.add(root);
    }
  }
  for (const [id, view] of world.palmViews) {
    const data = sim.palms.find((palm) => palm.id === id);
    if (data) view.root.position.set(data.position.x, 0, data.position.z);
  }
  world.player.position.set(sim.player.x, 0, sim.player.z);
  world.worker.position.set(sim.worker.x, 0, sim.worker.z);
  animatePerson(world.player, sim.player.state, clock);
  animatePerson(world.worker, sim.worker.state, clock + .7);
  world.worker.userData.parts.load.visible = sim.worker.carrying_ffb;
  updateCollectionLabel(world.collection, sim.resources.harvested_ffb_kg);
  syncSelection(world, sim, selected);
}

function animatePerson(root, state, clock) {
  const p = root.userData.parts;
  const walking = state === 'WALKING';
  const working = ['BUILDING', 'CLEARING', 'PLANTING', 'FERTILIZING', 'TREATING', 'HARVESTING'].includes(state);
  const swing = Math.sin(clock * 8) * .48;
  const cycle = Math.sin(clock * (state === 'CLEARING' ? 6.2 : 4.4));
  p.legs[0].rotation.x = walking ? swing : state === 'PLANTING' ? -.18 : 0;
  p.legs[1].rotation.x = walking ? -swing : state === 'PLANTING' ? -.12 : 0;
  if (walking) {
    p.arms[0].rotation.x = -swing;
    p.arms[1].rotation.x = swing;
  } else if (state === 'CLEARING') {
    p.arms[0].rotation.x = -.65 + cycle * .47;
    p.arms[1].rotation.x = -.3 + cycle * .35;
  } else if (state === 'PLANTING') {
    p.arms[0].rotation.x = .6 + cycle * .08;
    p.arms[1].rotation.x = .75 - cycle * .1;
  } else if (state === 'FERTILIZING') {
    p.arms[0].rotation.x = .25;
    p.arms[1].rotation.x = -.78 + cycle * .12;
  } else if (state === 'TREATING') {
    p.arms[0].rotation.x = -.08;
    p.arms[1].rotation.x = -.4 + cycle * .14;
  } else if (state === 'HARVESTING') {
    p.arms[0].rotation.x = -.48 + cycle * .16;
    p.arms[1].rotation.x = -1 + cycle * .62;
  } else {
    p.arms[0].rotation.x = Math.sin(clock * 1.7) * .03;
    p.arms[1].rotation.x = 0;
  }
  if (p.tool) p.tool.visible = working;
  root.position.y = walking ? Math.abs(Math.sin(clock * 8)) * .035 : state === 'PLANTING' ? -.07 : 0;
}
