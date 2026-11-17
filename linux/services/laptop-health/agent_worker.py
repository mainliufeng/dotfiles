#!/usr/bin/env python3
"""One bounded evidence-only reasoning job. Never executes proposed actions."""
import fcntl,json,pathlib,time,datetime
from contextlib import closing
import healthctl as h
import codex_isolated as agent

def tick():
 with closing(h.db()) as c:return _tick(c)

def _tick(c):
 cfg=h.config();now=time.time()
 c.execute('CREATE TABLE IF NOT EXISTS diagnostics(id TEXT,opened REAL,attempts INTEGER,status TEXT,next REAL,result TEXT,PRIMARY KEY(id,opened))')
 if h.get(c,'paused',False):return
 with (h.STATE/'agent.lock').open('w') as lock:
  try:fcntl.flock(lock,fcntl.LOCK_EX|fcntl.LOCK_NB)
  except BlockingIOError:return
  allowed=cfg.get('agent_check_ids',['cpu','memory','disk:','docker:','watched:','task:','probe:','tailscale','veth'])
  for i,opened in c.execute("SELECT id,opened FROM incidents WHERE status='open'").fetchall():
   if not any(i.startswith(v) if v.endswith(':') else i==v for v in allowed):continue
   c.execute("INSERT OR IGNORE INTO diagnostics VALUES(?,?,0,'queued',?,'{}')",(i,opened,now))
  c.execute("UPDATE diagnostics SET status='obsolete' WHERE status IN ('queued','retry') AND NOT EXISTS (SELECT 1 FROM incidents WHERE incidents.id=diagnostics.id AND incidents.opened=diagnostics.opened AND incidents.status='open')")
  c.execute("UPDATE diagnostics SET status=CASE WHEN attempts>=3 THEN 'exhausted' ELSE 'retry' END WHERE status='running' AND next<=?",(now,))
  c.commit()
  try:
   if not agent.validated_config().get('transport_verified'):raise ValueError('transport unverified')
  except Exception:
   h.put(c,'agent_status',{'status':'blocked','reason':'Pinned safe configuration unavailable or changed','at':now});c.commit();return
  latest=h.get(c,'latest',[])
  if now-h.get(c,'heartbeat',0)>180 or not any(x['id'].startswith('probe:') and x['ok'] is True for x in latest):
   h.put(c,'agent_status',{'status':'waiting_for_network_or_fresh_evidence','at':now});c.commit();return
  day=datetime.datetime.now().date().isoformat();budget=h.get(c,'agent_budget',{'day':day,'runs':0})
  if budget['day']!=day:budget={'day':day,'runs':0}
  if budget['runs']>=6:
   h.put(c,'agent_status',{'status':'daily_run_limit','at':now});c.commit();return
  row=c.execute("SELECT id,opened,attempts FROM diagnostics WHERE status IN ('queued','retry') AND next<=? AND attempts<3 ORDER BY opened LIMIT 1",(now,)).fetchone()
  if not row:return
  i,opened,attempts=row
  # Persist attempt before invoking transport, so crashes cannot bypass the budget.
  budget['runs']+=1;h.put(c,'agent_budget',budget)
  c.execute("UPDATE diagnostics SET attempts=?,status='running',next=? WHERE id=? AND opened=?",(attempts+1,now+300,i,opened));c.commit()
  evidence={'incident':{'id':i,'opened':opened},'checks':[{'id':x['id'],'ok':x['ok'],'message':h.redact(x['message'])} for x in latest if x['id']==i or x['id'] in ('cpu','memory','tailscale','veth') or x['id'].startswith('probe:')][:12]}
  try:result=agent.diagnose(evidence)
  except Exception as e:result={'status':'failed','error_type':type(e).__name__,'automatic_repairs':False}
  final=result.get('status')=='completed'
  status='completed' if final else ('exhausted' if attempts+1>=3 else 'retry')
  c.execute('UPDATE diagnostics SET status=?,next=?,result=? WHERE id=? AND opened=?',(status,time.time()+[300,900,3600][min(attempts,2)],json.dumps(result,ensure_ascii=False),i,opened))
  h.put(c,'agent_status',{'status':status,'incident':i,'at':time.time(),'automatic_repairs':False});c.commit()
  if final:
   msg='只读诊断: '+h.redact(result['diagnosis']['summary'])+'（未执行修复）'
   h.dispatch_notifications(c,[(i,'diagnosis',msg)],cfg,time.time())
  print(json.dumps({'incident':i,'status':status,'automatic_repairs':False}))
if __name__=='__main__':tick()
