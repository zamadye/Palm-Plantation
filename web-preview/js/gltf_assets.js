const GLB_MAGIC = 0x46546c67;
const JSON_CHUNK = 0x4e4f534a;
const BIN_CHUNK = 0x004e4942;

const COMPONENTS = {
  5120: { bytes: 1, Type: Int8Array, read: 'getInt8' },
  5121: { bytes: 1, Type: Uint8Array, read: 'getUint8' },
  5122: { bytes: 2, Type: Int16Array, read: 'getInt16' },
  5123: { bytes: 2, Type: Uint16Array, read: 'getUint16' },
  5125: { bytes: 4, Type: Uint32Array, read: 'getUint32' },
  5126: { bytes: 4, Type: Float32Array, read: 'getFloat32' },
};
const ITEM_SIZES = { SCALAR: 1, VEC2: 2, VEC3: 3, VEC4: 4, MAT2: 4, MAT3: 9, MAT4: 16 };
const ATTRIBUTE_NAMES = {
  POSITION: 'position',
  NORMAL: 'normal',
  TANGENT: 'tangent',
  TEXCOORD_0: 'uv',
  TEXCOORD_1: 'uv1',
  COLOR_0: 'color',
};

const assetUrl = (path) => new URL(`../../assets/${path}`, import.meta.url).href;
export const WORLD_ASSET_URLS = Object.freeze({
  palmStandard: assetUrl('environment/palms/tree-palm.glb'),
  palmBent: assetUrl('environment/palms/tree-palmbend.glb'),
  palmYoung: assetUrl('environment/palms/tree-palmdetailedshort.glb'),
  palmMature: assetUrl('environment/palms/tree-palmdetailedtall.glb'),
  tractor: assetUrl('environment/operations/kenney-car-kit/tractor.glb'),
  truck: assetUrl('environment/operations/kenney-car-kit/truck.glb'),
  millBuilding: assetUrl('environment/operations/kenney-city-kit-industrial/building-c.glb'),
  millChimney: assetUrl('environment/operations/kenney-city-kit-industrial/chimney-large.glb'),
  millTank: assetUrl('environment/operations/kenney-city-kit-industrial/detail-tank-large.glb'),
  millConveyor: assetUrl('environment/operations/kenney-factory-kit/conveyor-v1.glb'),
  millHopper: assetUrl('environment/operations/kenney-factory-kit/hopper-high-round.glb'),
  millPipe: assetUrl('environment/operations/kenney-factory-kit/pipe-large-valve.glb'),
});

function asArrayBuffer(value) {
  if (value instanceof ArrayBuffer) return value;
  if (ArrayBuffer.isView(value)) {
    return value.buffer.slice(value.byteOffset, value.byteOffset + value.byteLength);
  }
  throw new TypeError('GLB input must be an ArrayBuffer or typed-array view.');
}

export function parseGLB(value) {
  const buffer = asArrayBuffer(value);
  if (buffer.byteLength < 20) throw new Error('GLB is too small to contain a header and JSON chunk.');
  const view = new DataView(buffer);
  if (view.getUint32(0, true) !== GLB_MAGIC) throw new Error('Asset is not a binary glTF (GLB) file.');
  const version = view.getUint32(4, true);
  const declaredLength = view.getUint32(8, true);
  if (version !== 2) throw new Error(`Only GLB 2.0 is supported; received version ${version}.`);
  if (declaredLength > buffer.byteLength || declaredLength < 20) throw new Error('GLB header has an invalid declared length.');

  let json = null;
  let binary = null;
  let offset = 12;
  while (offset + 8 <= declaredLength) {
    const chunkLength = view.getUint32(offset, true);
    const chunkType = view.getUint32(offset + 4, true);
    offset += 8;
    if (offset + chunkLength > declaredLength) throw new Error('GLB contains a truncated chunk.');
    if (chunkType === JSON_CHUNK) {
      const text = new TextDecoder().decode(new Uint8Array(buffer, offset, chunkLength)).replace(/\0+$/g, '').trim();
      json = JSON.parse(text);
    } else if (chunkType === BIN_CHUNK) {
      binary = buffer.slice(offset, offset + chunkLength);
    }
    offset += chunkLength;
  }
  if (!json?.asset?.version?.startsWith('2')) throw new Error('GLB has no supported glTF 2.x JSON asset.');
  if (json.buffers?.some((entry) => entry.uri)) throw new Error('External binary buffers are not supported in this curated GLB subset.');
  if (json.buffers?.length && !binary) throw new Error('GLB declares a binary buffer but has no BIN chunk.');
  return { json, binary: binary ?? new ArrayBuffer(0) };
}

function readComponent(view, offset, componentType) {
  const info = COMPONENTS[componentType];
  if (!info) throw new Error(`Unsupported glTF accessor component type ${componentType}.`);
  return info.bytes === 1 ? view[info.read](offset) : view[info.read](offset, true);
}

function readAccessor(parsed, accessorIndex) {
  const { json, binary } = parsed;
  const accessor = json.accessors?.[accessorIndex];
  if (!accessor) throw new Error(`Missing glTF accessor ${accessorIndex}.`);
  if (accessor.sparse) throw new Error('Sparse glTF accessors are not used by the curated asset set.');
  const info = COMPONENTS[accessor.componentType];
  const itemSize = ITEM_SIZES[accessor.type];
  if (!info || !itemSize) throw new Error(`Unsupported accessor layout at index ${accessorIndex}.`);

  const array = new info.Type(accessor.count * itemSize);
  if (accessor.bufferView === undefined) return { array, itemSize, normalized: Boolean(accessor.normalized) };
  const bufferView = json.bufferViews?.[accessor.bufferView];
  if (!bufferView || (bufferView.buffer ?? 0) !== 0) throw new Error(`Accessor ${accessorIndex} references an unavailable buffer view.`);
  const stride = bufferView.byteStride ?? info.bytes * itemSize;
  const start = (bufferView.byteOffset ?? 0) + (accessor.byteOffset ?? 0);
  const bytes = new DataView(binary);
  for (let row = 0; row < accessor.count; row += 1) {
    for (let column = 0; column < itemSize; column += 1) {
      const sourceOffset = start + row * stride + column * info.bytes;
      if (sourceOffset + info.bytes > binary.byteLength) throw new Error(`Accessor ${accessorIndex} reads beyond the GLB BIN chunk.`);
      array[row * itemSize + column] = readComponent(bytes, sourceOffset, accessor.componentType);
    }
  }
  return { array, itemSize, normalized: Boolean(accessor.normalized) };
}

function textureWrap(THREE, gltfWrap) {
  if (gltfWrap === 33071) return THREE.ClampToEdgeWrapping;
  if (gltfWrap === 33648) return THREE.MirroredRepeatWrapping;
  return THREE.RepeatWrapping;
}

function textureFilter(THREE, gltfFilter, fallback) {
  const filters = {
    9728: THREE.NearestFilter,
    9729: THREE.LinearFilter,
    9984: THREE.NearestMipmapNearestFilter,
    9985: THREE.LinearMipmapNearestFilter,
    9986: THREE.NearestMipmapLinearFilter,
    9987: THREE.LinearMipmapLinearFilter,
  };
  return filters[gltfFilter] ?? fallback;
}

async function imageBlob(parsed, imageDef, glbUrl) {
  if (imageDef.bufferView !== undefined) {
    const view = parsed.json.bufferViews?.[imageDef.bufferView];
    if (!view) throw new Error('Embedded glTF image references a missing buffer view.');
    const bytes = parsed.binary.slice(view.byteOffset ?? 0, (view.byteOffset ?? 0) + view.byteLength);
    return new Blob([bytes], { type: imageDef.mimeType || 'image/png' });
  }
  if (imageDef.uri) {
    const imageUrl = imageDef.uri.startsWith('data:') ? imageDef.uri : new URL(imageDef.uri, glbUrl).href;
    const response = await fetch(imageUrl);
    if (!response.ok) throw new Error(`Could not load GLB texture (${response.status}): ${imageUrl}`);
    return response.blob();
  }
  throw new Error('glTF image has neither an embedded buffer view nor a URI.');
}

async function decodeImage(blob) {
  if (typeof createImageBitmap === 'function') return createImageBitmap(blob);
  return new Promise((resolve, reject) => {
    const objectUrl = URL.createObjectURL(blob);
    const image = new Image();
    image.onload = () => { URL.revokeObjectURL(objectUrl); resolve(image); };
    image.onerror = () => { URL.revokeObjectURL(objectUrl); reject(new Error('Browser could not decode a glTF image.')); };
    image.src = objectUrl;
  });
}

async function loadTextures(parsed, glbUrl, THREE) {
  const images = parsed.json.images ?? [];
  const samplers = parsed.json.samplers ?? [];
  return Promise.all((parsed.json.textures ?? []).map(async (textureDef) => {
    const imageDef = images[textureDef.source];
    if (!imageDef) throw new Error(`Texture references missing image ${textureDef.source}.`);
    const blob = await imageBlob(parsed, imageDef, glbUrl);
    const image = await decodeImage(blob);
    const sampler = samplers[textureDef.sampler] ?? {};
    const texture = new THREE.Texture(image);
    texture.flipY = false;
    texture.encoding = THREE.sRGBEncoding;
    texture.wrapS = textureWrap(THREE, sampler.wrapS);
    texture.wrapT = textureWrap(THREE, sampler.wrapT);
    texture.magFilter = textureFilter(THREE, sampler.magFilter, THREE.LinearFilter);
    texture.minFilter = textureFilter(THREE, sampler.minFilter, THREE.LinearMipmapLinearFilter);
    texture.generateMipmaps = ![9728, 9729].includes(sampler.minFilter);
    texture.needsUpdate = true;
    return texture;
  }));
}

function textureForInfo(THREE, textureList, info) {
  if (info?.index === undefined || !textureList[info.index]) return null;
  const texture = textureList[info.index].clone();
  const transform = info.extensions?.KHR_texture_transform;
  if (transform) {
    const offset = transform.offset ?? [0, 0];
    const scale = transform.scale ?? [1, 1];
    texture.offset.set(offset[0], offset[1]);
    texture.repeat.set(scale[0], scale[1]);
    texture.rotation = transform.rotation ?? 0;
    texture.center.set(0, 0);
    texture.needsUpdate = true;
  }
  return texture;
}

function createMaterial(THREE, definition = {}, textures = []) {
  const pbr = definition.pbrMetallicRoughness ?? {};
  const factor = pbr.baseColorFactor ?? [1, 1, 1, 1];
  const unlit = Boolean(definition.extensions?.KHR_materials_unlit);
  const options = {
    color: new THREE.Color(factor[0], factor[1], factor[2]),
    opacity: factor[3] ?? 1,
    transparent: definition.alphaMode === 'BLEND' || (factor[3] ?? 1) < 1,
    side: definition.doubleSided ? THREE.DoubleSide : THREE.FrontSide,
    roughness: pbr.roughnessFactor ?? 1,
    metalness: pbr.metallicFactor ?? 0,
  };
  if (definition.alphaMode === 'MASK') options.alphaTest = definition.alphaCutoff ?? 0.5;
  const material = unlit
    ? new THREE.MeshBasicMaterial(options)
    : new THREE.MeshStandardMaterial(options);
  material.name = definition.name ?? 'GLB material';
  material.map = textureForInfo(THREE, textures, pbr.baseColorTexture);
  if (pbr.baseColorTexture) material.needsUpdate = true;
  return material;
}

export function buildGLBScene(parsed, options = {}) {
  const THREE = options.THREE ?? globalThis.THREE;
  if (!THREE) throw new Error('Three.js must be available before building a GLB scene.');
  const { json } = parsed;
  const textures = options.textures ?? [];
  const materials = (json.materials ?? []).map((material) => createMaterial(THREE, material, textures));
  if (!materials.length) materials.push(new THREE.MeshStandardMaterial({ color: '#ffffff', roughness: 0.9 }));

  const meshTemplates = (json.meshes ?? []).map((meshDef) => {
    const group = new THREE.Group();
    group.name = meshDef.name ?? 'GLB mesh';
    for (const primitive of meshDef.primitives ?? []) {
      if ((primitive.mode ?? 4) !== 4) throw new Error(`Mesh ${group.name} uses unsupported primitive mode ${primitive.mode}.`);
      const geometry = new THREE.BufferGeometry();
      for (const [gltfName, threeName] of Object.entries(ATTRIBUTE_NAMES)) {
        const accessorIndex = primitive.attributes?.[gltfName];
        if (accessorIndex === undefined) continue;
        const attribute = readAccessor(parsed, accessorIndex);
        geometry.setAttribute(threeName, new THREE.BufferAttribute(attribute.array, attribute.itemSize, attribute.normalized));
      }
      if (!geometry.getAttribute('position')) throw new Error(`Mesh ${group.name} has no POSITION attribute.`);
      if (primitive.indices !== undefined) {
        const indices = readAccessor(parsed, primitive.indices);
        geometry.setIndex(new THREE.BufferAttribute(indices.array, 1, indices.normalized));
      }
      if (!geometry.getAttribute('normal')) geometry.computeVertexNormals();
      geometry.computeBoundingSphere();
      const material = materials[primitive.material] ?? materials[0];
      if (geometry.getAttribute('color')) material.vertexColors = true;
      const item = new THREE.Mesh(geometry, material);
      item.name = `${group.name}_primitive`;
      item.castShadow = true;
      item.receiveShadow = true;
      group.add(item);
    }
    return group;
  });

  const nodeDefinitions = json.nodes ?? [];
  const buildNode = (nodeIndex) => {
    const definition = nodeDefinitions[nodeIndex];
    if (!definition) throw new Error(`Missing glTF node ${nodeIndex}.`);
    if (definition.skin !== undefined || definition.weights) throw new Error('Skinned or morphed models are not used by this static asset subset.');
    const node = new THREE.Group();
    node.name = definition.name ?? `GLB node ${nodeIndex}`;
    if (definition.matrix) {
      node.matrix.fromArray(definition.matrix);
      node.matrixAutoUpdate = false;
    } else {
      if (definition.translation) node.position.fromArray(definition.translation);
      if (definition.rotation) node.quaternion.fromArray(definition.rotation);
      if (definition.scale) node.scale.fromArray(definition.scale);
    }
    if (definition.mesh !== undefined) {
      const mesh = meshTemplates[definition.mesh];
      if (!mesh) throw new Error(`Node ${node.name} references missing mesh ${definition.mesh}.`);
      node.add(mesh.clone(true));
    }
    for (const child of definition.children ?? []) node.add(buildNode(child));
    return node;
  };

  const sceneIndex = json.scene ?? 0;
  const sceneDefinition = json.scenes?.[sceneIndex];
  if (!sceneDefinition) throw new Error('GLB has no default scene.');
  const root = new THREE.Group();
  root.name = sceneDefinition.name ?? 'GLB asset';
  root.userData.gltfAsset = true;
  for (const nodeIndex of sceneDefinition.nodes ?? []) root.add(buildNode(nodeIndex));
  root.updateMatrixWorld(true);
  return root;
}

export async function loadGLBAsset(url) {
  const glbUrl = url instanceof URL ? url.href : new URL(url, import.meta.url).href;
  const response = await fetch(glbUrl);
  if (!response.ok) throw new Error(`Could not load GLB (${response.status}): ${glbUrl}`);
  const parsed = parseGLB(await response.arrayBuffer());
  const THREE = globalThis.THREE;
  if (!THREE) throw new Error('Three.js must be loaded before the web asset catalog.');
  const textures = await loadTextures(parsed, glbUrl, THREE);
  return {
    scene: buildGLBScene(parsed, { THREE, textures }),
    json: parsed.json,
    url: glbUrl,
  };
}
