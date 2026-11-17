import importlib.util, pathlib, sqlite3, tempfile, unittest
spec=importlib.util.spec_from_file_location('healthctl',pathlib.Path(__file__).with_name('healthctl.py'));h=importlib.util.module_from_spec(spec);spec.loader.exec_module(h)
class HealthTests(unittest.TestCase):
 def setUp(self):
  self.tmp=tempfile.TemporaryDirectory();h.STATE=pathlib.Path(self.tmp.name);self.c=h.db();self.cfg=h.config()
 def tearDown(self):self.c.close();self.tmp.cleanup()
 def test_diagnostics_safe_view(self):
  import json
  self.assertEqual(h.diagnostics(self.c),[])
  self.c.execute('CREATE TABLE diagnostics(id,opened,attempts,status,next,result)')
  result={'diagnosis':{'summary':'api_key=synthetic_secret','suggested_actions':['Inspect task result'],'needs_human':True,'extra':'hiddensecret'},'auth':'hiddensecret','usage':{'input_tokens':12,'unexpected':'hiddensecret'}}
  self.c.execute('INSERT INTO diagnostics VALUES(?,?,?,?,?,?)',('cpu',1000,1,'completed',0,json.dumps(result)))
  data=h.diagnostics(self.c);text=json.dumps(data)
  self.assertNotIn('synthetic_secret',text);self.assertNotIn('hiddensecret',text)
  self.assertEqual(data[0]['diagnosis']['suggested_actions'],['Inspect task result'])
  self.assertFalse(data[0]['automatic_repairs'])
 def result(self,ok):return [{'id':'test','ok':ok,'message':'test','data':{}}]
 def test_debounce_dedup_recovery(self):
  self.assertFalse(h.update(self.c,self.result(False),self.cfg,1000))
  self.assertFalse(h.update(self.c,self.result(False),self.cfg,1060))
  self.assertEqual(h.update(self.c,self.result(False),self.cfg,1120)[0][1],'problem')
  self.assertFalse(h.update(self.c,self.result(False),self.cfg,1180))
  self.assertFalse(h.update(self.c,self.result(True),self.cfg,1240))
  self.assertEqual(h.update(self.c,self.result(True),self.cfg,1300)[0][1],'recovered')
  self.assertFalse(h.update(self.c,self.result(True),self.cfg,1360))
 def test_intermittent_failure_not_consecutive(self):
  for t,ok in [(1000,False),(1060,True),(1120,False),(1180,True),(1240,False)]:
   self.assertFalse(h.update(self.c,self.result(ok),self.cfg,t))
  self.assertEqual(self.c.execute('SELECT status,count FROM incidents').fetchone(),('pending',1))
 def test_recovery_requires_fresh_consecutive_samples(self):
  for t in [1000,1060,1120]:h.update(self.c,self.result(False),self.cfg,t)
  self.assertFalse(h.update(self.c,self.result(True),self.cfg,1180))
  self.assertFalse(h.update(self.c,self.result(None),self.cfg,1240))
  self.assertFalse(h.update(self.c,self.result(True),self.cfg,2000))
  self.assertEqual(self.c.execute('SELECT status,healthy FROM incidents').fetchone(),('open',1))
  self.assertEqual(h.update(self.c,self.result(True),self.cfg,2060)[0][1],'recovered')
 def test_notification_failure_retries(self):
  from unittest.mock import patch
  with patch.object(h,'run',return_value=(1,'','')) as mocked:
   h.dispatch_notifications(self.c,[('test','problem','bad')],self.cfg,1000)
   self.assertEqual(len(h.get(self.c,'notification_queue')),1)
   h.dispatch_notifications(self.c,[],self.cfg,1010)
   self.assertEqual(mocked.call_count,1)
  with patch.object(h,'run',return_value=(0,'','')) as mocked:
   h.dispatch_notifications(self.c,[],self.cfg,1060)
   self.assertEqual(mocked.call_count,1)
   self.assertEqual(h.get(self.c,'notification_queue'),{})
 def test_large_notification_mentions_omissions(self):
  from unittest.mock import patch
  with patch.object(h,'run',return_value=(0,'','')) as mocked:
   h.dispatch_notifications(self.c,[(str(i),'problem','bad') for i in range(9)],self.cfg,1000)
   self.assertIn('3 more changes',mocked.call_args.args[0][-1])
 def test_independent_heartbeat_retries_notification_failure(self):
  import os,subprocess
  root=pathlib.Path(self.tmp.name);bin=root/'bin';bin.mkdir()
  exe=bin/'notify-send';exe.write_text('#!/bin/sh\nexit 1\n');exe.chmod(0o700)
  env=dict(os.environ,HEALTH_STATE=str(root/'state'),PATH=str(bin)+':'+os.environ['PATH'])
  script=pathlib.Path(__file__).with_name('heartbeat.sh')
  p=subprocess.run(['/bin/sh',str(script)],env=env,capture_output=True)
  self.assertEqual(p.returncode,1)
  self.assertFalse((root/'state/heartbeat-alert').exists())
 def test_gap_resets_pending(self):
  h.update(self.c,self.result(False),self.cfg,1000);h.update(self.c,self.result(False),self.cfg,1060)
  self.assertFalse(h.update(self.c,self.result(False),self.cfg,2000))
 def test_unknown_not_recovery(self):
  for t in [1000,1060,1120]:h.update(self.c,self.result(False),self.cfg,t)
  h.update(self.c,self.result(None),self.cfg,1180)
  self.assertEqual(self.c.execute('SELECT status FROM incidents').fetchone()[0],'open')
 def test_synthetic_credentials_never_persist_or_notify(self):
  secret='SYNTHETIC_DO_NOT_LEAK'
  result=[{'id':'test','ok':False,'message':'api_key='+secret+' proxy http://user:'+secret+'@host/','data':{}}]
  notices=[]
  for t in [1000,1060,1120]:notices+=h.update(self.c,result,self.cfg,t)
  self.assertNotIn(secret,str(notices))
  self.assertNotIn(secret,str(self.c.execute('SELECT * FROM events').fetchall()))
  self.assertNotIn(secret,str(self.c.execute('SELECT * FROM incidents').fetchall()))
 def test_stopped_container_retained_health_is_not_failure(self):
  self.assertFalse(h.container_issue('exited','unhealthy',0,3))
  self.assertTrue(h.container_issue('running','unhealthy',0,3))
  self.assertTrue(h.container_issue('restarting','none',0,3))
 def test_command_timeout(self):
  self.assertEqual(h.run(['python3','-c','import time;time.sleep(1)'],.01)[0],124)
 def test_failed_unit_recovery_requires_collector(self):
  r=[{'id':'unit:user:bad.service','ok':False,'message':'bad'}]
  for t in [1000,1060,1120]:h.update(self.c,r,self.cfg,t)
  h.update(self.c,[{'id':'collector:systemd-user','ok':False,'message':'denied'}],self.cfg,1180)
  self.assertEqual(self.c.execute("SELECT status FROM incidents WHERE id='unit:user:bad.service'").fetchone()[0],'open')
if __name__=='__main__':unittest.main()
