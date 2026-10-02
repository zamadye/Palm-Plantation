import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import { fileURLToPath } from 'node:url';
import { createRequire } from 'node:module';
import test from 'node:test';
import { buildGLBScene, parseGLB, WORLD_ASSET_URLS } from '../js/gltf_assets.js';
import { PlantationSimulation } from '../js/simulation.js';

const require = createRequire(import.meta.url);
const THREE = require('../vendor/three.min.js');
const assetEntries = Object.entries(WORLD_ASSET_URLS);

test('browser catalog points at all twelve shared palm and operation GLBs', () => {
  assert.equal(assetEntries.length, 12);
  assert.equal(assetEntries.filter(([key]) => key.startsWith('palm')).length, 4);
  assert.equal(assetEntries.filter(([key]) => !key.startsWith('palm')).length, 8);
  for (const [key, url] of assetEntries) {
    assert.ok(url.startsWith('file:'), `${key} resolves to a local source asset in this test`);
    assert.ok(!url.includes('/web-preview/assets/'), `${key} is shared from the repository assets directory`);
  }
});

test('every reviewed GLB parses and builds a textured-ready Three.js mesh hierarchy', async () => {
  for (const [key, url] of assetEntries) {
    const bytes = await readFile(fileURLToPath(url));
    const parsed = parseGLB(bytes);
    assert.equal(parsed.json.asset.version, '2.0', `${key} is glTF 2.0`);

    const root = buildGLBScene(parsed, { THREE, textures: [] });
    let meshCount = 0;
    let vertexCount = 0;
    root.traverse((node) => {
      if (!node.isMesh) return;
      meshCount += 1;
      vertexCount += node.geometry.getAttribute('position')?.count ?? 0;
    });
    assert.ok(meshCount > 0, `${key} creates visible mesh nodes`);
    assert.ok(vertexCount > 0, `${key} includes geometry vertices`);
  }
});

test('the GLB parser rejects corrupt or non-binary inputs with useful errors', () => {
  assert.throws(() => parseGLB(new Uint8Array([0, 1, 2, 3])), /too small/);
  const notGlb = new ArrayBuffer(24);
  new DataView(notGlb).setUint32(8, 24, true);
  assert.throws(() => parseGLB(notGlb), /not a binary glTF/);
});

test('world integration loads shared textures, landmarks, vehicles, and mill models', async (t) => {
  const originalFetch = globalThis.fetch;
  const originalImageBitmap = globalThis.createImageBitmap;
  const originalDocument = globalThis.document;
  globalThis.THREE = THREE;
  globalThis.fetch = async (input) => {
    const url = new URL(String(input));
    const body = await readFile(fileURLToPath(url));
    return new Response(body, { status: 200 });
  };
  globalThis.createImageBitmap = async () => ({ width: 128, height: 128, close() {} });
  globalThis.document = {
    createElement(tag) {
      assert.equal(tag, 'canvas');
      const context = { fillRect() {}, clearRect() {}, fillText() {}, strokeRect() {} };
      return { width: 1, height: 1, getContext: () => context };
    },
  };
  t.after(() => {
    globalThis.fetch = originalFetch;
    globalThis.createImageBitmap = originalImageBitmap;
    globalThis.document = originalDocument;
  });

  const { createWorld, loadWorldAssets, syncWorld } = await import('../js/world.js');
  const simulation = new PlantationSimulation();
  const world = createWorld(new THREE.Scene(), simulation);
  const result = await loadWorldAssets(world);
  assert.deepEqual(result, { loaded: 12, failed: 0, total: 12 });
  assert.equal(world.downloadedPalms.children.length, 3);
  assert.equal(world.downloadedOperations.children.length, 8);
  assert.equal(world.assetVersion, 1);
  assert.equal(world.millYardFallback.visible, false);
  assert.equal(world.camp.truck.visible, false);

  simulation.palms.push({
    id: 'palm_fixture', growth_stage: 2, fruit_state: 'READY', harvest_ready: true,
    position: { x: 8, z: 10 }, slot_index: 0,
  });
  syncWorld(world, simulation, 0);
  const palmView = world.palmViews.get('palm_fixture');
  assert.ok(palmView?.root.userData.sharedAssetResources, 'mature crop uses the downloaded palm GLB');
  assert.ok(palmView.root.children.some((child) => child.userData.generatedFruitCues), 'state-driven FFB cues remain attached');
  let mappedMeshes = 0;
  world.downloadedOperations.traverse((node) => {
    if (node.isMesh && node.material?.map) mappedMeshes += 1;
  });
  assert.ok(mappedMeshes > 0, 'downloaded vehicle/industrial textures are assigned to meshes');
});
