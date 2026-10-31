import * as THREE from 'three';
import {GLTFLoader} from 'three/addons/loaders/GLTFLoader.js';
// CC0 scenery test only. These GLBs are hosted by an external mirror and must
// be mirrored locally with source/license records before an App Store release.
const root='https://hidencod.github.io/tge-assets/';
export const scenery=[
 ['house','packs/city-kit-suburban/building-type-a.glb',8,0,22,5],
 ['house2','packs/city-kit-suburban/building-type-c.glb',14,0,30,4],
 ['house3','packs/city-kit-suburban/building-type-e.glb',-4,0,42,4],
 ['fence','packs/nature-kit/fence-planks.glb',5,0,18,2],
 ['rock','packs/nature-kit/rock-largea.glb',-8,0,12,2],
 ['rock2','packs/nature-kit/rock-largeb.glb',-19,0,16,2],
 ['bush','packs/nature-kit/plant-bush.glb',12,0,16,1.2],
 ['flowers','packs/nature-kit/flower-yellowa.glb',6,0,18,1.2],
 ['mushroom','packs/nature-kit/mushroom-red.glb',-7,0,14,.8],
 ['grass','packs/nature-kit/grass-large.glb',10,0,11,1.3]
];
export async function addScenery(scene){
 const loader=new GLTFLoader();const report={loaded:[],failed:[]};
 const fetchModel=(url)=>new Promise((resolve,reject)=>loader.load(url,resolve,undefined,reject));
 for(const [id,file,x,y,z,height] of scenery){
  try{
   const model=(await fetchModel(root+file)).scene;
   const bounds=new THREE.Box3().setFromObject(model);
   const dimensions=bounds.getSize(new THREE.Vector3());
   if(dimensions.y<=0)throw Error('zero height');
   const scale=height/dimensions.y;
   model.scale.setScalar(scale);
   model.position.set(x,y-bounds.min.y*scale,z);
   model.traverse(node=>{if(node.isMesh){node.castShadow=true;node.receiveShadow=true;}});
   scene.add(model);report.loaded.push(id);
  }catch(e){report.failed.push({id,error:String(e)});}
 }
 return report;
}
