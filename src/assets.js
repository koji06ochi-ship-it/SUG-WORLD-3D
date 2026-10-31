import * as THREE from 'three';
import { GLTFLoader } from 'three/addons/loaders/GLTFLoader.js';
// Temporary CC0 GLB assets. These are NOT official S.u.G WORLD character models.
// Third-party hosting must be replaced with vetted self-hosted files before release.
const base='https://hidencod.github.io/tge-assets/';
export const assetManifest=[
 {id:'tree',file:'packs/nature-kit/tree-pinerounda.glb',source:'Kenney Nature Kit',license:'CC0-1.0'},
 {id:'tree2',file:'packs/nature-kit/tree-pinetalla.glb',source:'Kenney Nature Kit',license:'CC0-1.0'},
 {id:'tree3',file:'packs/nature-kit/tree-small.glb',source:'Kenney Nature Kit',license:'CC0-1.0'},
 {id:'avatar-placeholder',file:'packs/mini-characters/character-male-a.glb',source:'Kenney Mini Characters',license:'CC0-1.0'}
];
export async function loadCC0Assets(scene,avatar){
 const loader=new GLTFLoader();const results={loaded:[],failed:[]};
 const load=(entry)=>new Promise((resolve,reject)=>loader.load(base+entry.file,resolve,undefined,reject));
 for(const entry of assetManifest){
  try{
   const gltf=await load(entry),object=gltf.scene;
   const bounds=new THREE.Box3().setFromObject(object);const size=bounds.getSize(new THREE.Vector3());
   if(size.y<=0)throw new Error('invalid model bounds');
   const scale=(entry.id==='avatar-placeholder'?2.3:4.3)/size.y;object.scale.setScalar(scale);
   if(entry.id==='avatar-placeholder'){
    // Place on player root, replacing the primitive avatar silhouette only after GLB loads.
    object.position.y=-bounds.min.y*scale;
    avatar.add(object);avatar.userData.cc0AvatarLoaded=true;
   }else{
    const n=entry.id==='tree'?16:entry.id==='tree2'?12:12;
    for(let i=0;i<n;i++){
     const instance=object.clone(true);
     const angle=i*2.39996;const radius=8+Math.sqrt(i+1)*5;
     instance.position.set(Math.cos(angle)*radius,0,15+Math.sin(angle)*radius);
     scene.add(instance);
    }
   }
   results.loaded.push(entry.id);
  }catch(e){results.failed.push({id:entry.id,error:String(e)});}
 }
 return results;
}
