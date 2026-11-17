# Legacy reference (not the installed runner)

The installed worker uses `codex_isolated.py`; see README.md for the verified
filesystem/tool isolation and actual enabled status. The following documents the earlier
fail-closed capability probe, not the current runtime.

# Codex diagnostic adapter: fail-closed boundary

## Current status

**Not enabled.** `codex_adapter.py` validates a bounded local JSON evidence file
and records `status: blocked`. It never starts Codex, sends evidence, or executes
repairs. Exit status 3 means blocked, not successful diagnosis. Invalid input is
exit status 2. Do not repeatedly schedule a blocked backend; show it in `doctor`
and the monitoring inventory as an unavailable capability.

This is an intentional partial implementation, not an automatic diagnosis feature.
The monitoring/notification collectors can operate without a model.

## Verified host facts (2026-11-17)

- Codex CLI 0.160.1 is installed and reports ChatGPT login.
- `exec` supports JSON events, output schemas, sandbox selection and
  `--ignore-user-config`.
- The user's global Codex configuration grants full access and disables interactive
  approvals. A monitor must not inherit those defaults.
- Bubblewrap is installed. Its presence alone does not prove a secure model/tool
  execution boundary.

A `read-only` Codex workspace is not sufficient to prove that all host files and
local services are inaccessible. A bubblewrap process that mounts auth.json into
an agent-visible filesystem can expose authentication credentials to tools. A
shared network namespace can expose localhost services, including control APIs.
A read-only bind of a Unix socket does not make its protocol read-only.

## Requirements before enabling a model backend

1. Explicitly approved, minimal model credentials are handled by a broker outside
   the tool process; no host auth/config/SSH files are mounted into tool access.
2. The tool sandbox sees only a scrubbed evidence snapshot and scratch directory;
   no Docker socket, D-Bus, systemctl control, broad home, inherited hooks/plugins,
   or host-local service connectivity. Restrict outbound destinations separately.
3. Ignore ordinary Codex user config and use an independently tested restricted
   profile. Logs are untrusted evidence, never instructions or authorizations.
4. Validate final JSON against a schema. A diagnosis cannot directly become shell
   code. Proposed actions are not automatically applied.
5. Enforce timeout, token/run budget, single-flight, deduplication and backoff in
   the parent coordinator. Failure of the backend must not stop monitoring.
6. Adversarial tests must attempt credential/host-file reads, local socket calls,
   external exfiltration and prompt injection. Verify denials before a real model
   smoke test. Successful model completion alone is not a safety test.

No secret migration or credential copy was performed in this phase. Future
implementation should prefer a supported authenticated client/tool separation or
a dedicated tightly scoped account/broker, not an improvised auth.json mount.

## Interface

```python
from codex_adapter import capability, diagnose
status = capability()  # enabled=False, status=blocked
result = diagnose(evidence_path, private_new_run_directory)
```

The latter writes a private `diagnosis.json` with a SHA-256 digest and byte count,
not raw evidence or its pathname. It refuses symlink evidence, non-JSON-object
input, input over 256 KiB, public output directories and an existing output file.
Use an owned private parent for output directories. This validation is not a
claim that arbitrary source logs have been sanitized.

```sh
python codex_adapter.py --status
python -m unittest discover -s . -p test_codex_adapter.py -v
```

All five adapter tests pass without a model call or network connection.
