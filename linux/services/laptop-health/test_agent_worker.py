import pathlib,tempfile,time,unittest,datetime
from unittest.mock import patch
import healthctl as h
import agent_worker as w
import codex_isolated as a
class AgentTests(unittest.TestCase):
 def setUp(self):
  self.tmp=tempfile.TemporaryDirectory();self.old=h.STATE;h.STATE=pathlib.Path(self.tmp.name);c=h.db();now=time.time()
  c.execute("INSERT INTO incidents VALUES('cpu',?,?,'open','CPU high',5,0,0)",(now,now));h.put(c,'heartbeat',now);h.put(c,'latest',[{'id':'probe:test','ok':True,'message':'HTTP 200'},{'id':'cpu','ok':False,'message':'CPU high'}]);c.commit();c.close()
 def tearDown(self):h.STATE=self.old;self.tmp.cleanup()
 def test_catalog_tool_metadata_rejected(self):
  import json,hashlib,os
  root=pathlib.Path(self.tmp.name);exe=root/'codex';exe.write_text('fake');exe.chmod(0o700)
  cat=root/'catalog.json';cat.write_text(json.dumps({'models':[{'shell_type':'unified_exec','apply_patch_tool_type':'freeform','tool_mode':'normal','experimental_supported_tools':[]}]}));cat.chmod(0o600)
  cfg=root/'config.json';cfg.write_text(json.dumps({'enabled':True,'executable':str(exe),'catalog':str(cat),'executable_sha256':a.sha(exe),'catalog_sha256':a.sha(cat)}))
  with patch.object(a,'CFG',cfg):
   with self.assertRaises(ValueError):a.validated_config()
 def test_offline_queue_does_not_invoke(self):
  c=h.db();h.put(c,'latest',[]);c.commit();c.close()
  with patch.object(a,'validated_config',return_value={'transport_verified':True}),patch.object(a,'diagnose') as d:w.tick();d.assert_not_called()
  c=h.db();self.assertEqual(c.execute('SELECT status FROM diagnostics').fetchone()[0],'queued');c.close()
 def test_budget_blocks_invocation(self):
  c=h.db();h.put(c,'agent_budget',{'day':datetime.datetime.now().date().isoformat(),'runs':6});c.commit();c.close()
  with patch.object(a,'validated_config',return_value={'transport_verified':True}),patch.object(a,'diagnose') as d:w.tick();d.assert_not_called()
 def test_completed_incident_runs_once(self):
  result={'status':'completed','diagnosis':{'summary':'test'},'automatic_repairs':False}
  with patch.object(a,'validated_config',return_value={'transport_verified':True}),patch.object(a,'diagnose',return_value=result) as d,patch.object(h,'dispatch_notifications'):
   w.tick();w.tick();self.assertEqual(d.call_count,1)
 def test_isolated_argv_no_host_workspace_or_socket(self):
  cmd=a.args({'executable':'/safe/codex','catalog':'/safe/catalog','model':'gpt-6.1-sol'},pathlib.Path('/safe/work'),pathlib.Path('/safe/auth'))
  self.assertNotIn('--ro-bind / /',' '.join(cmd));self.assertIn('--clearenv',cmd)
  self.assertIn('shell_tool',cmd);self.assertIn('plugins',cmd);self.assertIn('--ignore-user-config',cmd)
  self.assertNotIn('/run/docker.sock',cmd);self.assertNotIn('danger-full-access',cmd)
if __name__=='__main__':unittest.main()
