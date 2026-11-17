# Laptop Health (phase 1)

One read-only monitor, one per-host JSON registry, one incident store. No auto repair.

## Maintenance

- Generic source and systemd units live in this module.
- Host policy: `~/dotfiles-private/health/hosts/<hostname>.json` linked to
  `~/.config/laptop-health/config.json`; existing config is never overwritten by setup.
- SQLite state: `~/.local/state/laptop-health/health.db` (private, runtime only).
- `healthctl status`, `inventory`, `incidents`, `diagnostics`, `doctor`, `pause`, `resume`.
- `./setup.sh --check` runs tests; `./setup.sh` installs/enables; `./setup.sh --uninstall`
  disables timers but preserves evidence/config/source.
- No root unit, inbound listener, external notification or hosted service is installed.

## Implemented checks

CPU from consecutive /proc/stat samples; MemAvailable; filesystem space/inodes;
Docker restart deltas and health; failed user/system units; configured active units;
configured scheduled service Result; Tailscale backend; explicit HTTP proxy probes;
NetworkManager veth creation log count. `inventory` discovers services/timers/path units
and counts cron entries without copying their command lines into evidence.

Three consecutive bad samples open an incident (CPU: five), two healthy samples close
it. One collection produces one grouped desktop notification, repeated after at least
30 minutes, and one recovery notification. Events retained 30 days. Collection is
single-flight, subprocesses bounded, unit limited to 90 s/192 MB/15% CPU. Sampling
restarts after suspend/gaps rather than accumulating failures across sleep.

A separate 5-minute heartbeat timer checks collector freshness. It can alert via the
desktop if stale. Both depend on the user systemd manager: this is not an external
machine-offline heartbeat. Desktop notifications require a running notification daemon.

## Coverage limits (do not represent these as complete)

- Scheduled task result monitored, but schedule-aware missed-deadline detection is not
  yet implemented. Existing cron entry count is inventory only, not successful execution.
- Tailscale daemon state only: no target peer was assumed; per-peer reachability needs
  configured expected-online targets. It is not proof every tailnet path works.
- Proxy probes use the explicit local Clash proxy port, but Clash rule routing can still
  choose DIRECT. They verify proxy ingress + application URL reachability, not a pinned
  egress node or full Internet reachability. HTTP 403 from ChatGPT confirms an HTTP
  response, NOT login/voice/API usability.
- Resource checks do not yet include PSI, temperature, SMART, battery or per-process
  attribution. No full process arguments or environment are captured.
- Missing journal permissions report unknown, not a healthy zero. Unknown collector
  failures do not resolve existing incidents. Historical stopped containers are not
  treated as failures; a restarted planned-stop container can still trigger a storm.
- Collectors never invoke models. A separate optional verified agent worker sends only
  selected, redacted structured evidence to Codex. This uses model quota/cost; six starts
  per day is a call budget, not a guaranteed dollar cap.
- No action executor exists in phase 1; there is therefore no enabled repair whitelist.
  State changes are limited to this monitor's database/notifications.

## Security and validation

Collectors use field allowlists, never raw Docker inspect, environment variables,
process command lines or proxy config. Stored/notified messages redact common secret
assignments and URL basic authentication; this is defense in depth, not a substitute
for allowlists. Unit tests use synthetic secrets and check event/incident/notification
outputs. Raw evidence remains local; the optional worker sends only its bounded structured subset
to the configured Codex service. No production or container/network commands are changed.

Before extending, add tests for failures, gaps, unknown state and duplicate events.
Model tool permissions must be independently verified before enabling any agent.

### Review corrections
- CPU baseline/long gaps are unknown (not zero); guest fields excluded from total.
- Unknown or stale samples break recovery streaks.
- `expected_running_containers` and planned-stop lists are explicit; exited unmanaged
  containers are unknown, not healthy. Missing expected containers are failures even
  when Docker has no containers. Inventory includes managed/unmanaged status.
- Host registry expects the verified Hyprvoice, Knowledge and tailscaled services.
- Notification delivery failures are queued with bounded exponential backoff. More
  than six changes are summarized with an explicit omitted count.
- Heartbeat is a separate shell script using a successful-collection marker, independent
  of Python imports/SQLite. Delivery failure does not start its cooldown.
- `doctor` means collector heartbeat health, not that all host checks are healthy.

### Isolated Codex diagnosis
`codex_isolated.py` implements a pinned native CLI + pinned no-tools model catalog and
minimal bubblewrap filesystem. The trusted client reads a read-only auth-file bind;
no credentials are copied. Host home, Docker/user/system sockets are absent. Model
shell, patch, browser, app, MCP and other capabilities are absent from the tested
registry. The CLI and model catalog are pinned together. Local synthetic Responses testing verified that an unsolicited exec_command
is rejected, with no sentinel file created. The shared network is for the trusted
model transport; this is not a network namespace firewall.

`agent_worker.py` has a deduplicated incident queue, concurrency lock, six starts/day,
three attempts/incident, network/freshness gating, bounded runtime, strict JSON output
validation, and no action executor. The agent timer is enabled on this host after real transport verification with synthetic
evidence and a successful live incident diagnosis. Other hosts remain disabled until
verified. Diagnostic suggestions are data, never shell
commands to execute. A CLI/catalog hash mismatch blocks invocation after upgrades.

The old `codex_adapter.py` capability check is retained only as a legacy fail-closed
reference and test; it is not used by the installed agent worker.

`healthctl diagnostics` displays the latest 100 diagnosis jobs, full bounded summaries,
probable causes, suggested actions, confidence, and token usage. It filters unknown
fields and redacts secret patterns; suggestions are never executed.
