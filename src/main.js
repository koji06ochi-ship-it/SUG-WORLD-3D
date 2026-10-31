import {loadState,saveState,act,step} from './gameplay.js';
import * as THREE from 'three';
const scene=new THREE.Scene();scene.background=new THREE.Color('#9fd4e8');scene.fog=new THREE.Fog('#9fd4e8',45,120);
const camera=new THREE.PerspectiveCamera(60,innerWidth/innerHeight,.1,180);
const renderer=new THREE.WebGLRenderer({antialias:true});renderer.setSize(innerWidth,innerHeight);renderer.setPixelRatio(Math.min(devicePixelRatio,1.5));document.body.prepend(renderer.domElement);
scene.add(new THREE.HemisphereLight('#e7f6ff','#657747',2));const light=new THREE.DirectionalLight('#fff1c5',2);light.position.set(12,28,8);scene.add(light);
const material=c=>new THREE.MeshStandardMaterial({color:c,roughness:.85});
function mesh(geometry,mat,x,y,z){const m=new THREE.Mesh(geometry,mat);m.position.set(x,y,z);scene.add(m);return m}
const ground=mesh(new THREE.PlaneGeometry(100,100),material('#72a95e'),0,0,0);ground.rotation.x=-Math.PI/2;
const road=mesh(new THREE.PlaneGeometry(5,65),material('#d7bd8b'),0,.015,16);road.rotation.x=-Math.PI/2;
const lake=mesh(new THREE.CircleGeometry(10,64),new THREE.MeshStandardMaterial({color:'#46b9cb',transparent:true,opacity:.9}),-12,.03,22);lake.rotation.x=-Math.PI/2;lake.scale.set(1.3,.7,1);
let seed=19;function rand(){seed=(seed*1664525+1013904223)>>>0;return seed/4294967296}
for(let i=0;i<90;i++){const x=(rand()-.5)*90,z=(rand()-.5)*90;if(Math.abs(x)<4||Math.hypot(x+12,z-22)<14||Math.hypot(x-8,z-22)<7)continue;mesh(new THREE.CylinderGeometry(.17,.23,2,7),material('#715239'),x,1,z);mesh(new THREE.IcosahedronGeometry(1.5,1),material('#438d51'),x,3,z)}
mesh(new THREE.BoxGeometry(5,3.2,4),material('#e8c99b'),8,1.6,22);mesh(new THREE.BoxGeometry(6,.65,5),material('#965b49'),8,3.5,22);
for(const x of [-8,-5])mesh(new THREE.BoxGeometry(.7,3.3,.7),material('#7b7b73'),x,1.65,37);mesh(new THREE.BoxGeometry(3.8,.7,.7),material('#7b7b73'),-6.5,3.4,37);
const avatar=new THREE.Group();scene.add(avatar);const body=new THREE.Mesh(new THREE.CapsuleGeometry(.42,.8,5,10),material('#438064'));body.position.y=1;avatar.add(body);const head=new THREE.Mesh(new THREE.SphereGeometry(.42,16,12),material('#efc39c'));head.position.y=2;avatar.add(head);
let state={x:0,z:0,yaw:0,fish:0,seed:false,key:false};try{Object.assign(state,JSON.parse(localStorage.getItem('world3d')||'{}'))}catch{}
const gameplay=loadState(localStorage);gameplay.position={x:state.x,z:state.z};
const status=document.getElementById('status');const say=s=>status.textContent=s;
for(const [id,type] of [['fish','fish'],['garden','garden'],['inspect','search'],['pink','pink']]){const b=document.getElementById(id);if(b)b.onclick=()=>{gameplay.position={x:state.x,z:state.z};say(act(gameplay,type))}}
document.getElementById('save').onclick=()=>{try{gameplay.position={x:state.x,z:state.z};saveState(localStorage,gameplay);say('保存した')}catch(e){say('保存に失敗した')}};
const keys=new Set();onkeydown=e=>keys.add(e.key.toLowerCase());onkeyup=e=>keys.delete(e.key.toLowerCase());
let stick={x:0,y:0};const pad=document.getElementById('pad');function updatePad(e){const r=pad.getBoundingClientRect();stick.x=Math.max(-1,Math.min(1,(e.clientX-r.left-60)/45));stick.y=Math.max(-1,Math.min(1,(e.clientY-r.top-60)/45))}pad.onpointerdown=e=>{pad.setPointerCapture(e.pointerId);updatePad(e)};pad.onpointermove=e=>{if(e.buttons)updatePad(e)};pad.onpointerup=pad.onpointercancel=()=>stick={x:0,y:0};
const clock=new THREE.Clock();function frame(){const dt=Math.min(clock.getDelta(),.05);step(gameplay,dt);state.yaw+=(stick.x+(keys.has('arrowright')?1:0)-(keys.has('arrowleft')?1:0))*dt*2;const forward=(-stick.y+(keys.has('arrowup')?1:0)-(keys.has('arrowdown')?1:0))*dt*4;state.x+=Math.sin(state.yaw)*forward;state.z+=Math.cos(state.yaw)*forward;avatar.position.set(state.x,0,state.z);avatar.rotation.y=state.yaw;camera.position.lerp(new THREE.Vector3(state.x-Math.sin(state.yaw)*8,5,state.z-Math.cos(state.yaw)*8),.08);camera.lookAt(state.x,1.5,state.z+2);renderer.render(scene,camera);requestAnimationFrame(frame)}frame();onresize=()=>{camera.aspect=innerWidth/innerHeight;camera.updateProjectionMatrix();renderer.setSize(innerWidth,innerHeight)};