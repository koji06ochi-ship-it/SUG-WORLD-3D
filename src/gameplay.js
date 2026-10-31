// S.u.G WORLD: deterministic gameplay state; no paid AI or external services.
export const defaultState=()=>({version:2,position:{x:0,z:0},inventory:{fish:0,seeds:0,coins:0,insight:0,key:0},garden:{planted:0},quests:{lake:false,house:false,gate:false,pinkEncounter:0},events:[],elapsed:0});
export function loadState(storage){try{const s=JSON.parse(storage.getItem('sug_world_v2'));return s?.version===2?s:defaultState()}catch{return defaultState()}}
export function saveState(storage,state){storage.setItem('sug_world_v2',JSON.stringify(state));return true}
export function distance(a,b){return Math.hypot(a.x-b.x,a.z-b.z)}
export function addEvent(s,type,message){s.events.push({type,message,at:Math.round(s.elapsed)});if(s.events.length>100)s.events.shift();return message}
export function act(s,type){
 const p=s.position,i=s.inventory;
 if(type==='fish'){
  if(distance(p,{x:-12,z:22})>15)return addEvent(s,'hint','湖に近づいてみよう');
  i.fish++;if(i.fish===2){i.key++;return addEvent(s,'discover','魚ではなく古い鍵が釣れた！')}
  return addEvent(s,'fish','魚を釣った。何を運ぶかは自分で決める。');
 }
 if(type==='garden'){
  if(distance(p,{x:8,z:22})>7)return addEvent(s,'hint','家の庭に近づいてみよう');
  if(!i.seeds)return addEvent(s,'hint','まず種を探そう');
  i.seeds--;s.garden.planted++;s.quests.house=true;return addEvent(s,'garden','種を植えた。明日には何が変わるだろう');
 }
 if(type==='search'){
  if(distance(p,{x:-6.5,z:37})<5){s.quests.gate=true;return addEvent(s,'gate',i.key?'鍵が反応した。扉の向こうへ進めそうだ':'古い門には鍵穴がある')}
  i.seeds++;i.insight++;return addEvent(s,'discovery','道端に種を見つけた。気づかなかっただけかもしれない');
 }
 if(type==='pink'){
  s.quests.pinkEncounter++;const n=s.quests.pinkEncounter;
  if(n%3===1){i.coins++;return addEvent(s,'pink','ピンクハゲが全力疾走して転んだ。コインを落としていった！')}
  if(n%3===2){i.insight++;return addEvent(s,'pink','ピンクハゲがバトンを持って走り去った。誰に渡すつもり？')}
  return addEvent(s,'pink','釣りの途中でピンクハゲが湖に飛び込んだ！ なにしとんねん！');
 }
 return addEvent(s,'hint','知らないなら、まずやってみよう');
}
export function step(s,seconds){s.elapsed+=seconds;return s}
