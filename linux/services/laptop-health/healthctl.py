#!/usr/bin/env python3
"""Local read-only health collection, inventory, incidents and deduplicated notifications."""
import argparse, datetime, fcntl, json, os, pathlib, re, shutil, sqlite3, subprocess, sys, time
BASE=pathlib.Path(__file__).resolve().parent
CONFIG=pathlib.Path(os.environ.get('HEALTH_CONFIG',str(pathlib.Path.home()/'.config/laptop-health/config.json')))
STATE=pathlib.Path(os.environ.get('HEALTH_STATE',str(pathlib.Path.home()/'.local/state/laptop-health')))

def redact(text):
    text=re.sub(r'(?i)(api[_-]?key|password|token|secret)([=: ]+)[^\s,;]+', r'\1\2[REDACTED]', str(text))
    text=re.sub(r'(?i)(https?://)[^/\s:@]+:[^/\s@]+@', r'\1[REDACTED]@', text)
    return text[:1024]

def run(args, timeout=12):
    try:
        p=subprocess.run(args,text=True,capture_output=True,timeout=timeout)
        return p.returncode,p.stdout[:262144],p.stderr[:1024]
    except (OSError,subprocess.TimeoutExpired) as e:return 124,'',type(e).__name__
def config():
    return json.loads((CONFIG if CONFIG.exists() else BASE/'defaults.json').read_text())
def db():
    STATE.mkdir(parents=True,exist_ok=True,mode=0o700)
    c=sqlite3.connect(STATE/'health.db'); c.execute('PRAGMA journal_mode=WAL')
    c.executescript('CREATE TABLE IF NOT EXISTS kv(k TEXT PRIMARY KEY,v TEXT); CREATE TABLE IF NOT EXISTS incidents(id TEXT PRIMARY KEY, opened REAL, last REAL, status TEXT, message TEXT, count INTEGER, notified REAL, healthy INTEGER DEFAULT 0); CREATE TABLE IF NOT EXISTS events(ts REAL,id TEXT,kind TEXT,message TEXT);')
    return c
def get(c,k,default=None):
    r=c.execute('SELECT v FROM kv WHERE k=?',(k,)).fetchone();return json.loads(r[0]) if r else default
def put(c,k,v):c.execute('INSERT OR REPLACE INTO kv VALUES(?,?)',(k,json.dumps(v,ensure_ascii=False)))
def container_issue(status,health,delta,threshold):
    return status=='restarting' or delta>=threshold or (status=='running' and health=='unhealthy')

def sample(c,cfg,now):
    out=[]
    def add(i,ok,msg,data=None):out.append({'id':i,'ok':ok,'message':redact(msg),'data':data or {}})
    last=get(c,'last_sample',0); gap=now-last
    cpu=list(map(int,pathlib.Path('/proc/stat').read_text().splitlines()[0].split()[1:9])); prev=get(c,'cpu')
    busy=None
    if prev and 0<gap<180:
        total=sum(cpu)-sum(prev);idle=(cpu[3]+cpu[4])-(prev[3]+prev[4]);busy=100*(total-idle)/total if total else 0
    put(c,'cpu',cpu);add('cpu',None if busy is None else busy<cfg['cpu_percent'],'CPU baseline pending' if busy is None else f'CPU {busy:.1f}%',{'percent':busy})
    mem={l.split(':')[0]:int(l.split()[1]) for l in pathlib.Path('/proc/meminfo').read_text().splitlines()}
    available=100*mem['MemAvailable']/mem['MemTotal'];add('memory',available>cfg['memory_available_percent'],f'Available memory {available:.1f}%',{'available_percent':available})
    for path in cfg['disks']:
        try:
            s=os.statvfs(path);pct=100*s.f_bavail/s.f_blocks;ino=100*s.f_favail/s.f_files if s.f_files else 100
            add('disk:'+path,min(pct,ino)>cfg['disk_available_percent'],f'{path}: space {pct:.1f}%, inodes {ino:.1f}% available')
        except OSError as e:add('disk:'+path,False,type(e).__name__)
    rc,raw,_=run(['docker','ps','-a','--format','{{.ID}}'])
    add('collector:docker',rc==0,'Docker readable' if rc==0 else 'Docker unavailable or access denied')
    containers=[]
    if rc==0:
        ids=raw.split()[:300]
        if not ids:
            add('collector:docker-inspect',True,'No containers')
            for name in cfg.get('expected_running_containers',[]):add('docker:'+name,False,'Expected container missing: '+name)
        if ids:
            rc,raw,_=run(['docker','inspect','--format','{{json .Name}} {{.RestartCount}} {{json .State.Status}} {{if .State.Health}}{{json .State.Health.Status}}{{else}}"none"{{end}}']+ids)
            add('collector:docker-inspect',rc==0,'Docker state query' if rc==0 else 'Docker inspect failed')
            if rc==0:
                history=get(c,'docker_history',{})
                for line in raw.splitlines():
                    try:name,count,status,health=line.split();name=json.loads(name).lstrip('/');count=int(count);status=json.loads(status);health=json.loads(health)
                    except (ValueError,json.JSONDecodeError):continue
                    h=[x for x in history.get(name,[]) if now-x[0]<=cfg['restart_window_seconds'] and x[1]<=count] if gap<180 else []
                    h.append([now,count]);history[name]=h
                    delta=count-min(x[1] for x in h)
                    planned=name in cfg.get('planned_stopped_containers',[])
                    expected=name in cfg.get('expected_running_containers',[])
                    issue=container_issue(status,health,delta,cfg['restart_threshold'])
                    # Planned-stop only suppresses the stopped state, never a new restart storm.
                    ok=not issue
                    if status not in ('running','restarting'):
                        ok=False if expected else (True if planned else None)
                    add('docker:'+name,ok,f'{name}: {status}, health={health}, restarts in window={delta}; expectation={"running" if expected else "stopped" if planned else "unmanaged"}')
                    containers.append({'name':name,'status':status,'health':health,'planned_stop':planned,'expected_running':expected,'managed':planned or expected})
                put(c,'docker_history',history)
                present={v['name'] for v in containers}
                for name in cfg.get('expected_running_containers',[]):
                    if name not in present:add('docker:'+name,False,'Expected container missing: '+name)
    put(c,'containers',containers)
    for scope in ['user','system']:
        cmd=['systemctl']+(['--user'] if scope=='user' else [])
        rc,raw,_=run(cmd+['list-units','--state=failed','--no-legend','--plain','--no-pager'])
        add('collector:systemd-'+scope,rc==0,'systemd readable' if rc==0 else 'systemd access unavailable')
        units=[]
        if rc==0:
            for line in raw.splitlines():
                fields=line.split()
                if fields:units.append(fields[0])
            put(c,'failed:'+scope,units)
            for u in units:
                if u not in cfg.get('ignored_failed_units',[]):add('unit:'+scope+':'+u,False,'Failed unit: '+u)
        for u in cfg.get('watched_units',{}).get(scope,[]):
            rc,raw,_=run(cmd+['show',u,'-p','ActiveState','-p','LoadState','-p','Result'])
            props=dict(l.split('=',1) for l in raw.splitlines() if '=' in l)
            add('watched:'+scope+':'+u,rc==0 and props.get('ActiveState')=='active',f'{u}: '+props.get('ActiveState','unknown'))
    # Scheduled oneshots: inactive is normal; Result failure is not.
    for u in cfg.get('scheduled_units',[]):
        rc,raw,_=run(['systemctl','--user','show',u,'-p','Result','-p','LoadState','-p','ExecMainExitTimestamp'])
        props=dict(l.split('=',1) for l in raw.splitlines() if '=' in l)
        add('task:'+u,rc==0 and props.get('LoadState')=='loaded' and props.get('Result')=='success',f'{u}: result={props.get("Result","unknown")}; last exit={props.get("ExecMainExitTimestamp","")}')
    rc,raw,_=run(['tailscale','status','--json']);ts={}
    if rc==0:
        try:ts=json.loads(raw)
        except json.JSONDecodeError:pass
    add('tailscale',rc==0 and ts.get('BackendState')=='Running',f'Tailscale backend: {ts.get("BackendState","unavailable")}')
    # Deliberately explicit proxy: no inherited environment/NO_PROXY bypass.
    for p in cfg.get('probes',[]):
        args=['curl','--silent','--output','/dev/null','--max-time','8','--write-out','%{http_code} %{time_total}','--noproxy','']
        args+=['--proxy',p.get('proxy','') ,p['url']]
        rc,raw,_=run(args,10);code=raw.split()[0] if raw.split() else ''
        add('probe:'+p['id'],rc==0 and code in [str(x) for x in p.get('statuses',[p.get('status',200)])],f'{p["id"]}: HTTP {code or "unavailable"}',{'elapsed':raw.split()[1] if len(raw.split())>1 else None})
    # Device churn is observed from current kernel interfaces, plus journal when readable.
    rc,raw,_=run(['journalctl','-u','NetworkManager','--since',f'@{int(max(now-60,last))}','--no-pager','-o','cat'])
    n=sum('new Veth device' in l for l in raw.splitlines())
    add('veth',None if rc else n<cfg['veth_per_minute'],f'New virtual interfaces: {n}' if rc==0 else 'NetworkManager journal unavailable',{'count':n})
    put(c,'last_sample',now);return out

def update(c,results,cfg,now):
    notices=[]; observed={r['id'] for r in results}
    # Missing dynamic failures recover only when their collector succeeded.
    collectors={r['id']:r['ok'] for r in results if r['id'].startswith('collector:')}
    for row in c.execute("SELECT id FROM incidents WHERE status IN ('open','pending')").fetchall():
        i=row[0]
        if i not in observed and ((i.startswith('unit:user:') and collectors.get('collector:systemd-user')) or (i.startswith('unit:system:') and collectors.get('collector:systemd-system')) or (i.startswith('docker:') and collectors.get('collector:docker-inspect'))):
            results.append({'id':i,'ok':True,'message':'Target no longer reports a failure','data':{}})
    for r in results:
        r['message']=redact(r['message']);i=r['id'];row=c.execute('SELECT opened,last,status,message,count,notified,healthy FROM incidents WHERE id=?',(i,)).fetchone()
        if r['ok'] is None:
            c.execute('UPDATE incidents SET healthy=0 WHERE id=?',(i,));continue
        if not r['ok']:
            count=(row[4]+1) if row and row[2] in ('pending','open') and now-row[1]<180 else 1
            opened=row[0] if row and row[2] in ('pending','open') else now
            threshold=cfg['cpu_consecutive_samples'] if i=='cpu' else cfg['consecutive_samples']
            status='open' if (row and row[2]=='open') or count>=threshold else 'pending';notified=row[5] if row else 0
            if status=='open' and (not row or row[2]!='open' or now-notified>=cfg['notification_cooldown_seconds']):
                notices.append((i,'problem',r['message']));notified=now
            c.execute('INSERT OR REPLACE INTO incidents VALUES(?,?,?,?,?,?,?,?)',(i,opened,now,status,r['message'],count,notified,0))
        elif row and row[2] in ('pending','open'):
            healthy=(row[6]+1) if 0<=now-row[1]<180 else 1
            if row[2]=='pending':
                c.execute("UPDATE incidents SET status='resolved',last=?,healthy=?,count=0 WHERE id=?",(now,healthy,i));continue
            if healthy>=cfg['recovery_samples']:
                if row[2]=='open':notices.append((i,'recovered',r['message']))
                c.execute("UPDATE incidents SET status='resolved',last=?,healthy=? WHERE id=?",(now,healthy,i))
            else:c.execute('UPDATE incidents SET healthy=?,last=?,count=0 WHERE id=?',(healthy,now,i))
    for i,kind,msg in notices:c.execute('INSERT INTO events VALUES(?,?,?,?)',(now,i,kind,msg))
    c.execute('DELETE FROM events WHERE ts<?',(now-30*86400,))
    return notices

def dispatch_notifications(c,notices,cfg,now):
    pending=get(c,'notification_queue',{})
    for i,kind,msg in notices:pending[i]={'kind':kind,'message':redact(msg)}
    if not cfg.get('desktop_notifications',True):
        put(c,'notification_delivery',{'status':'disabled','at':now});c.commit();return
    if not pending or now<get(c,'notification_retry_at',0):
        put(c,'notification_queue',pending);c.commit();return
    summary='\n'.join(f'{v["kind"]}: {v["message"]}' for v in list(pending.values())[:6])
    if len(pending)>6:summary+=f'\n… {len(pending)-6} more changes; run healthctl incidents to see all.'
    rc,_,_=run(['notify-send','--app-name=Laptop Health','Laptop health',summary],5)
    if rc==0:
        put(c,'notification_queue',{});put(c,'notification_attempts',0);put(c,'notification_retry_at',0)
        put(c,'notification_delivery',{'status':'accepted_by_desktop_service','at':now})
    else:
        attempts=get(c,'notification_attempts',0)+1
        put(c,'notification_queue',pending);put(c,'notification_attempts',attempts)
        put(c,'notification_retry_at',now+min(60*2**min(attempts-1,4),600))
        put(c,'notification_delivery',{'status':'failed','exit_code':rc,'at':now})
        print(json.dumps({'notification':'failed','exit_code':rc,'queued':len(pending)}))
    c.commit()

def collect():
    cfg=config();c=db()
    with (STATE/'collect.lock').open('w') as lock:
        try:fcntl.flock(lock,fcntl.LOCK_EX|fcntl.LOCK_NB)
        except BlockingIOError:return
        now=time.time()
        if get(c,'paused',False):
            put(c,'heartbeat',now);c.commit();(STATE/'heartbeat').touch();return
        results=sample(c,cfg,now);notices=update(c,results,cfg,now)
        put(c,'latest',results);put(c,'heartbeat',time.time());c.commit()
        (STATE/'heartbeat.tmp').write_text(str(time.time()))
        os.replace(STATE/'heartbeat.tmp',STATE/'heartbeat')
        for i,kind,msg in notices:
            print(json.dumps({'event':kind,'id':i,'message':msg},ensure_ascii=False))
        dispatch_notifications(c,notices,cfg,time.time())
        print(json.dumps({'checks':len(results),'events':len(notices),'heartbeat':get(c,'heartbeat')}))

def inventory():
    cfg=config();c=db();out={'containers':get(c,'containers',[]),'configured':{k:v for k,v in cfg.items() if k in ('cpu_percent','memory_available_percent','disk_available_percent','consecutive_samples','recovery_samples','notification_cooldown_seconds','desktop_notifications','watched_units','scheduled_units','planned_stopped_containers','expected_running_containers')},'discovered':{}}
    from urllib.parse import urlsplit
    out['configured']['probes']=[{'id':redact(p['id']),'target_host':urlsplit(p['url']).hostname,'proxy_configured':bool(p.get('proxy'))} for p in cfg.get('probes',[])]
    for scope in ('user','system'):
        prefix=['systemctl']+(['--user'] if scope=='user' else [])
        for typ in ('timer','service','path'):
            rc,s,_=run(prefix+['list-unit-files','--type='+typ,'--no-legend','--no-pager'])
            out['discovered'][scope+'_'+typ]={'available':rc==0,'units':[l.split()[0:2] for l in s.splitlines()]}
    rc,s,_=run(['crontab','-l']);out['discovered']['cron']={'available':rc==0,'entry_count':sum(bool(l.strip()) and not l.lstrip().startswith('#') and '=' not in l.split()[0] for l in s.splitlines())}
    print(json.dumps(out,ensure_ascii=False,indent=2))
def diagnostics(c):
    """Bounded, allowlisted view; old malformed output cannot escape as raw text."""
    if not c.execute("SELECT 1 FROM sqlite_master WHERE type='table' AND name='diagnostics'").fetchone():return []
    out=[]
    for i,opened,attempts,status,nxt,raw in c.execute('SELECT id,opened,attempts,status,next,result FROM diagnostics ORDER BY opened DESC LIMIT 100'):
        item={'id':redact(i),'opened':opened,'attempts':attempts,'status':status,'next':nxt,'automatic_repairs':False}
        try:
            result=json.loads(raw) if len(raw)<=65536 else {}
            d=result.get('diagnosis',{})
            if isinstance(d,dict):
                item['diagnosis']={}
                for key in ('summary','confidence'):
                    if isinstance(d.get(key),str):item['diagnosis'][key]=redact(d[key][:4000])
                for key in ('probable_causes','suggested_actions'):
                    if isinstance(d.get(key),list):item['diagnosis'][key]=[redact(v[:2000]) for v in d[key][:12] if isinstance(v,str)]
                if isinstance(d.get('needs_human'),bool):item['diagnosis']['needs_human']=d['needs_human']
            usage=result.get('usage',{})
            if isinstance(usage,dict):item['usage']={k:v for k,v in usage.items() if k in ('input_tokens','output_tokens','reasoning_output_tokens','cached_input_tokens') and isinstance(v,int)}
        except (ValueError,TypeError,AttributeError):item['output_status']='unreadable'
        out.append(item)
    return out

def main():
    p=argparse.ArgumentParser();p.add_argument('command',choices=['collect','status','incidents','diagnostics','inventory','doctor','pause','resume']);a=p.parse_args()
    if a.command=='collect':collect();return
    if a.command=='inventory':inventory();return
    c=db()
    if a.command in ('pause','resume'):put(c,'paused',a.command=='pause');c.commit();print(a.command);return
    if a.command=='status':print(json.dumps({'paused':get(c,'paused',False),'heartbeat':get(c,'heartbeat'),'checks':get(c,'latest',[]),'notification_delivery':get(c,'notification_delivery'),'queued_notifications':len(get(c,'notification_queue',{})),'agent':get(c,'agent_status',{'status':'not_run'})},ensure_ascii=False,indent=2))
    elif a.command=='diagnostics':print(json.dumps({'note':'Suggestions only; no repairs executed. Latest 100 runs.','runs':diagnostics(c)},ensure_ascii=False,indent=2))
    elif a.command=='incidents':print(json.dumps([dict(zip(['id','opened','last','status','message','count','notified','healthy'],r)) for r in c.execute('SELECT * FROM incidents ORDER BY last DESC')],ensure_ascii=False,indent=2))
    else:
        age=time.time()-get(c,'heartbeat',0);healthy=age<180
        print(json.dumps({'heartbeat_age_seconds':age,'healthy':healthy,'scope':'collector heartbeat only, not whole-host health','config':str(CONFIG),'automatic_repairs':False,'agent':get(c,'agent_status',{'status':'not_run'})},ensure_ascii=False))
        if not healthy:
            if time.time()-get(c,'heartbeat_notified',0)>1800:
                run(['notify-send','--app-name=Laptop Health','Laptop monitor stalled','Health collection heartbeat is older than 3 minutes. No automatic repairs performed.'],5)
                put(c,'heartbeat_notified',time.time());c.commit()
            sys.exit(1)
if __name__=='__main__':main()
