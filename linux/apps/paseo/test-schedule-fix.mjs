import { readFileSync, openSync, readSync, closeSync } from 'node:fs';
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { patchScheduleSource } from './schedule-patch.mjs';
function packagedSource() {
 const fd=openSync('/opt/Paseo/resources/app.asar','r');
 try {
  const header=Buffer.alloc(16);readSync(fd,header,0,16,0);
  const raw=Buffer.alloc(header.readUInt32LE(12));readSync(fd,raw,0,raw.length,16);
  let entry=JSON.parse(raw.toString());
  for(const name of 'node_modules/@getpaseo/server/dist/server/server/schedule/service.js'.split('/')) entry=entry.files[name];
  const body=Buffer.alloc(entry.size);readSync(fd,body,0,body.length,8+header.readUInt32LE(4)+Number(entry.offset));return body.toString();
 } finally { closeSync(fd); }
}
const original = process.argv[2] ? readFileSync(process.argv[2],'utf8') : packagedSource();
const patched = patchScheduleSource(original);
const extract = (source, start, end) => source.slice(source.indexOf(start),source.indexOf(end));
const methods = extract(patched,'    async tick() {','    async completeScheduleIfDue(')
  + extract(patched,'    async runSchedule(schedule, now, options) {','    async updateRunMetadata(');
const Harness = new Function('randomUUID','shouldCompleteSchedule','computeNextRunAt','requireSchedule','completeSchedule','ScheduleTargetGoneError',`return class {${methods}}`)(
 ()=>String(Math.random()),()=>false,(_c,d)=>new Date(d.getTime()+86400000),x=>x,()=>{throw Error('Unexpected completion')},class extends Error {});
function harness() {
 const now=new Date('2026-10-04T16:00:00Z');
 const rows=['slow','fast'].map(id=>({id,status:'active',nextRunAt:now.toISOString(),cadence:{},runs:[]}));
 const h=new Harness();h.now=()=>now;h.runningScheduleIds=new Set();h.logger={error(){}};
 h.store={list:async()=>structuredClone(rows),get:async id=>structuredClone(rows.find(r=>r.id===id)),update:async(id,fn)=>{const i=rows.findIndex(r=>r.id===id);rows[i]=await fn(structuredClone(rows[i]));return structuredClone(rows[i]);}};
 return {h,rows,now};
}
test('patch is idempotent and refuses unknown source',()=>{assert.equal(patchScheduleSource(patched),patched);assert.throws(()=>patchScheduleSource('unknown version'));});
test('overlapping ticks do not replay a finished fast site from an old list',async()=>{
 const {h,rows}=harness();let release;const blocked=new Promise(r=>release=r);const calls=[];
 h.runner=async s=>{calls.push(s.id);if(s.id==='slow')await blocked;return {agentId:s.id,output:'done'};};
 const first=h.tick();await new Promise(r=>setImmediate(r));await h.tick();release();await first;
 assert.deepEqual(calls,['slow','fast']);assert.ok(rows.every(r=>r.runs.length===1));assert.ok(rows.every(r=>r.nextRunAt==='2026-10-05T16:00:00.000Z'));
});
test('simultaneous manual starts cannot run the same site twice',async()=>{
 const {h,rows,now}=harness();let release;const blocked=new Promise(r=>release=r);let calls=0;h.runner=async()=>{calls++;await blocked;return {agentId:'a',output:'done'};};
 const a=h.runSchedule(rows[0],now,{manual:true});await new Promise(r=>setImmediate(r));await assert.rejects(h.runSchedule(rows[0],now,{manual:true}),/already running/);release();await a;assert.equal(calls,1);
});
test('manual recovery preserves the next nightly date',async()=>{
 const {h,rows,now}=harness();h.runner=async()=>({agentId:'a',output:'done'});await h.runSchedule(rows[0],now,{manual:true});assert.equal(rows[0].nextRunAt,now.toISOString());
});
test('completion advances from the run date even if config was refreshed mid-run',async()=>{
 const {h,rows,now}=harness();h.runner=async()=>{rows[0].nextRunAt='2026-10-05T16:00:00Z';return {agentId:'a',output:'done'};};await h.runSchedule(rows[0],now);assert.equal(rows[0].nextRunAt,'2026-10-05T16:00:00.000Z');
});
test('a paused or deleted schedule from an old tick is not dispatched',async()=>{
 const {h,rows,now}=harness();const stale=structuredClone(rows[0]);rows[0].status='paused';h.runner=()=>{throw Error('Must not run');};await h.runSchedule(stale,now);assert.equal(rows[0].runs.length,0);rows.shift();await h.runSchedule(stale,now);
});
