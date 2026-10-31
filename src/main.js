import {buildValley} from './valley.js';
import {addScenery} from './environment.js';
import {loadCC0Assets} from './assets.js';
import {loadState,saveState,act,step} from './gameplay.js';
import * as THREE from 'three';
const scene=new THREE.Scene();scene.background=new THREE.Color('#9fd4e8');scene.fog=new THREE.Fog('#9fd4e8',45,120);
const camera=new THREE.PerspectiveCamera(60,innerWidth/innerHeight,.1,180);
const renderer=new THREE.WebGLRenderer({antialias:true});renderer.setSize(innerWidth,innerHeight);renderer.setPixelRatio(Math.min(devicePixelRatio,1.5));document.body.prepend(renderer.domElement);
scene.add(new THREE.HemisphereLight('#e7f6ff','#657747',2));const light=new THREE.DirectionalLight('#fff1c5',2);light.position.set(12,28,8);scene.add(light);
const material=c=>new THREE.MeshStandardMaterial({color:c,roughness:.85});
function mesh(geometry,mat,x,y,z){const m=new THREE.Mesh(geometry,mat);m.position.set(x,y,z);scene.add(m);return m}
const valley=buildValley(scene);
const avatar=new THREE.Group();scene.add(avatar);const body=new THREE.Mesh(new THREE.CapsuleGeometry(.42,.8,5,10),material('#438064'));body.position.y=1;avatar.add(body);const head=new THREE.Mesh(new THREE.SphereGeometry(.42,16,12),material('#efc39c'));head.position.y=2;avatar.add(head);
loadCC0Assets(scene,avatar).then(result=>{
 if(avatar.userData.cc0AvatarLoaded){body.visible=false;head.visible=false;}
 console.info('CC0 asset loading',result);
 const info=document.getElementById('asset-status');
 if(info)info.textContent=result.failed.length?'3D素材の一部が読めませんでした':'3D素材を読み込みました';
}).catch(e=>console.error('CC0 assets',e));
let state={x:0,z:0,yaw:0,fish:0,seed:false,key:false};try{Object.assign(state,JSON.parse(localStorage.getItem('world3d')||'{}'))}catch{}
const gameplay=loadState(localStorage);gameplay.position={x:state.x,z:state.z};
const status=document.getElementById('status');const say=s=>status.textContent=s;
for(const [id,type] of [['fish','fish'],['garden','garden'],['inspect','search'],['pink','pink']]){const b=document.getElementById(id);if(b)b.onclick=()=>{gameplay.position={x:state.x,z:state.z};say(act(gameplay,type))}}
document.getElementById('save').onclick=()=>{try{gameplay.position={x:state.x,z:state.z};saveState(localStorage,gameplay);say('保存した')}catch(e){say('保存に失敗した')}};
const keys=new Set();onkeydown=e=>keys.add(e.key.toLowerCase());onkeyup=e=>keys.delete(e.key.toLowerCase());
let stick={x:0,y:0};const pad=document.getElementById('pad');function updatePad(e){const r=pad.getBoundingClientRect();stick.x=Math.max(-1,Math.min(1,(e.clientX-r.left-60)/45));stick.y=Math.max(-1,Math.min(1,(e.clientY-r.top-60)/45))}pad.onpointerdown=e=>{pad.setPointerCapture(e.pointerId);updatePad(e)};pad.onpointermove=e=>{if(e.buttons)updatePad(e)};pad.onpointerup=pad.onpointercancel=()=>stick={x:0,y:0};
const clock=new THREE.Clock();function frame(){const dt=Math.min(clock.getDelta(),.05);step(gameplay,dt);state.yaw+=(stick.x+(keys.has('arrowright')?1:0)-(keys.has('arrowleft')?1:0))*dt*2;const forward=(-stick.y+(keys.has('arrowup')?1:0)-(keys.has('arrowdown')?1:0))*dt*4;state.x+=Math.sin(state.yaw)*forward;state.z+=Math.cos(state.yaw)*forward;avatar.position.set(state.x,valley.height(state.x,state.z),state.z);avatar.rotation.y=state.yaw;camera.position.lerp(new THREE.Vector3(state.x-Math.sin(state.yaw)*8,valley.height(state.x,state.z)+5,state.z-Math.cos(state.yaw)*8),.08);camera.lookAt(state.x,valley.height(state.x,state.z)+1.5,state.z+2);renderer.render(scene,camera);requestAnimationFrame(frame)}frame();onresize=()=>{camera.aspect=innerWidth/innerHeight;camera.updateProjectionMatrix();renderer.setSize(innerWidth,innerHeight)};