import * as THREE from 'three';
// Purpose-built valley geometry, no background-image substitution.
const mat=(color,roughness=0.88)=>new THREE.MeshStandardMaterial({color,roughness,flatShading:false});
export function buildValley(scene){
 const group=new THREE.Group();scene.add(group);
 const rng=(()=>{let s=20261101;return ()=>((s=(1664525*s+1013904223)>>>0)/4294967296)})();
 const lakeX=-12,lakeZ=22;
 function height(x,z){
  const side=Math.max(0,(Math.abs(x)-11)/24);
  const ridge=side*side*(7+3*Math.sin(z*.095+x*.045));
  const hills=.24*Math.sin(x*.27)*Math.cos(z*.19);
  const lake=Math.hypot((x-lakeX)/15,(z-lakeZ)/10);
  const flatten=lake<1.13?0:1;
  const road=Math.abs(x)<3.4?0:1;
  return Math.max(0,(ridge+hills*road)*flatten);
 }
 const geom=new THREE.PlaneGeometry(180,180,110,110);geom.rotateX(-Math.PI/2);
 const pos=geom.attributes.position,colors=[];
 const green=new THREE.Color('#648f55'),dark=new THREE.Color('#456c47'),sand=new THREE.Color('#c2b488'),stone=new THREE.Color('#8d9589');
 for(let i=0;i<pos.count;i++){
  const x=pos.getX(i),z=pos.getZ(i),y=height(x,z);
  pos.setY(i,y);
  const slope=Math.min(1,Math.max(0,(y-2)/12));
  const c=green.clone().lerp(dark,Math.min(1,y/10)).lerp(stone,slope*.65);
  if(Math.abs(x)<3.4&&z>-14&&z<46)c.lerp(sand,.85);
  colors.push(c.r,c.g,c.b);
 }
 geom.setAttribute('color',new THREE.Float32BufferAttribute(colors,3));geom.computeVertexNormals();
 const ground=new THREE.Mesh(geom,new THREE.MeshStandardMaterial({vertexColors:true,roughness:1,side:THREE.DoubleSide}));ground.receiveShadow=true;group.add(ground);
 // An irregular lake mesh, instead of a perfectly circular blue disk.
 const lakeShape=new THREE.Shape();for(let i=0;i<=80;i++){const a=i*Math.PI*2/80;const ripple=1+.055*Math.sin(a*7)+.035*Math.cos(a*11);const x=lakeX+15*Math.cos(a)*ripple,z=lakeZ+9*Math.sin(a)*ripple;if(i===0)lakeShape.moveTo(x,z);else lakeShape.lineTo(x,z)}
 const lakeGeom=new THREE.ShapeGeometry(lakeShape,48);lakeGeom.rotateX(-Math.PI/2);const lake=new THREE.Mesh(lakeGeom,new THREE.MeshPhysicalMaterial({color:'#3a9db2',metalness:.05,roughness:.21,transparent:true,opacity:.88,clearcoat:.55}));lake.position.y=.09;group.add(lake);
 const shore=new THREE.Mesh(new THREE.RingGeometry(1,1.06,96),mat('#c5b88b'));shore.rotation.x=-Math.PI/2;shore.position.set(lakeX,.06,lakeZ);shore.scale.set(15,9,1);group.add(shore);
 function mesh(g,m,x,y,z){const o=new THREE.Mesh(g,m);o.position.set(x,y,z);o.castShadow=true;o.receiveShadow=true;group.add(o);return o}
 const wood=mat('#75523b'),leaf=[mat('#477c4d'),mat('#3d7651'),mat('#648e55')],flower=[mat('#f3e6ae'),mat('#ec9d99'),mat('#c9b4e9')];
 function pine(x,z,s){const y=height(x,z);mesh(new THREE.CylinderGeometry(.13*s,.23*s,2.2*s,7),wood,x,y+1.1*s,z);for(let k=0;k<3;k++)mesh(new THREE.ConeGeometry((1.5-k*.28)*s,2.5*s,8),leaf[k%3],x,y+(2.2+k*.75)*s,z)}
 function deciduous(x,z,s){const y=height(x,z);mesh(new THREE.CylinderGeometry(.14*s,.25*s,2*s,7),wood,x,y+s,z);for(let k=0;k<3;k++)mesh(new THREE.IcosahedronGeometry((1.1-k*.16)*s,1),leaf[k],x+(.45-k*.25)*s,y+(2.5+k*.3)*s,z+(.25-k*.2)*s)}
 for(let i=0;i<140;i++){const x=(rng()-.5)*155,z=(rng()-.5)*140;if(Math.abs(x)<5||Math.hypot((x-lakeX)/17,(z-lakeZ)/12)<1||Math.hypot(x-8,z-22)<8)continue;const s=.65+rng()*.8;(rng()>.47?pine:deciduous)(x,z,s)}
 for(let i=0;i<230;i++){const x=(rng()-.5)*110,z=(rng()-.5)*105;if(Math.abs(x)<3.8||Math.hypot((x-lakeX)/16,(z-lakeZ)/10)<1)continue;const y=height(x,z);const r=.15+rng()*.22;const rock=mesh(new THREE.DodecahedronGeometry(r,0),i%7===0?mat('#a0a08a'):flower[i%3],x,y+r*.4,z);rock.scale.y=.6}
 // Timber-and-plaster cottage with pitched roof, windows and entrance.
 const houseX=8,houseZ=22,base=height(houseX,houseZ);
 const plaster=mat('#dfc39a'),roof=mat('#845342'),trim=mat('#5d4536'),glass=mat('#a6d2ca',.18);
 mesh(new THREE.BoxGeometry(6,3.4,5),plaster,houseX,base+1.7,houseZ);
 for(const dz of [-2.65,2.65]){const slope=mesh(new THREE.BoxGeometry(4.4,.28,3.75),roof,houseX,base+4.45,houseZ+dz*.48);slope.rotation.z=dz<0?-.62:.62}
 for(const dx of [-2.85,2.85])for(const dz of [-2.35,2.35])mesh(new THREE.BoxGeometry(.24,3.7,.25),trim,houseX+dx,base+1.9,houseZ+dz);
 mesh(new THREE.BoxGeometry(1.2,2.1,.16),trim,houseX,base+1.05,houseZ-2.58);
 for(const dx of [-1.9,1.9]){mesh(new THREE.BoxGeometry(.95,1.1,.15),glass,houseX+dx,base+2.05,houseZ-2.6);mesh(new THREE.BoxGeometry(.12,1.2,.22),trim,houseX+dx,base+2.05,houseZ-2.65)}
 // The gate remains at the same gameplay coordinates.
 for(const x of [-8,-5])mesh(new THREE.CylinderGeometry(.34,.45,3.7,8),mat('#9b9585'),x,height(x,37)+1.85,37);
 mesh(new THREE.BoxGeometry(4.1,.75,.85),mat('#9b9585'),-6.5,4,37);
 return {group,height,lake};
}
