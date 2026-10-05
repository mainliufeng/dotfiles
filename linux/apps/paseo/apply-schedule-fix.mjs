// Apply the same validated ESM patch to the running Node daemon, without restarting agents.
import { kill } from 'node:process';
import { pathToFileURL } from 'node:url';
const pid = Number(process.argv[2]);
if (!Number.isInteger(pid) || pid < 2) throw new Error('Pass the confirmed Paseo daemon worker PID');
kill(pid, 'SIGUSR1');
let endpoints;
for (let attempt = 0; attempt < 30; attempt++) {
  try { endpoints = await (await fetch('http://127.0.0.1:9229/json/list')).json(); break; }
  catch { await new Promise(resolve => setTimeout(resolve, 100)); }
}
if (!endpoints?.[0]?.webSocketDebuggerUrl) throw new Error('Paseo Node inspector did not open; no live patch applied');
const registerUrl = pathToFileURL(new URL('./schedule-register.mjs', import.meta.url).pathname).href;
const moduleUrl = 'file:///opt/Paseo/resources/app.asar/node_modules/@getpaseo/server/dist/server/server/schedule/service.js';
const expression = `(async()=>{
 const req=process.getBuiltinModule('node:module').createRequire('/opt/Paseo/resources/app.asar/package.json');
 const old = req(${JSON.stringify(moduleUrl.replace('file://',''))});
 req(${JSON.stringify(registerUrl.replace('file://',''))});
 const vm=req('node:vm');
 const fixed = await vm.compileFunction('return import('+${JSON.stringify(JSON.stringify(moduleUrl + '?schedule-snapshot-fix=20261005'))}+')',[],{importModuleDynamically:vm.constants.USE_MAIN_CONTEXT_DEFAULT_LOADER})();
 if (!fixed.ScheduleService.prototype.runSchedule.toString().includes('paseoScheduleSnapshotFix')) throw Error('Patch not loaded');
 old.ScheduleService.prototype.runSchedule = fixed.ScheduleService.prototype.runSchedule;
 old.ScheduleService.prototype.finishRun = fixed.ScheduleService.prototype.finishRun;
 globalThis.paseoScheduleSnapshotFix = { pid:process.pid, appliedAt:new Date().toISOString() };
 return { ...globalThis.paseoScheduleSnapshotFix, patched: old.ScheduleService.prototype.runSchedule.toString().includes('paseoScheduleSnapshotFix'), cadenceFromRun:old.ScheduleService.prototype.finishRun.toString().includes('completedRuns.find') };
})()`;
const socket = new WebSocket(endpoints[0].webSocketDebuggerUrl);
await new Promise((resolve, reject) => { socket.onopen=resolve; socket.onerror=reject; });
const response = new Promise((resolve,reject) => {
 socket.onmessage = event => { const message=JSON.parse(event.data); if(message.id===1) resolve(message); };
 socket.onerror=reject;
});
socket.send(JSON.stringify({id:1,method:'Runtime.evaluate',params:{expression,awaitPromise:true,returnByValue:true}}));
const result = await response;
socket.send(JSON.stringify({id:2,method:'Runtime.evaluate',params:{expression:"setTimeout(()=>process.getBuiltinModule('node:inspector').close(),500); true"}}));
socket.close();
if (result.result?.exceptionDetails || result.error) throw new Error(JSON.stringify(result));
console.log(JSON.stringify(result.result.result.value));
