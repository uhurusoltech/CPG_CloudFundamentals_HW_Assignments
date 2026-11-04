#!/usr/bin/env bash
set -euo pipefail

LAB_DIR="$HOME/Documents/Theowaf/cpg/cloudfundamentals/hwlabs/cli-production-incident-lab"
cd "$LAB_DIR" || { echo 'Lab workspace missing. Run lab-start.sh first.' >&2; exit 1; }

passed=0
failed=0
pass() { printf 'PASS  %s\n' "$1"; passed=$((passed + 1)); }
fail() { printf 'FAIL  %s\n' "$1"; failed=$((failed + 1)); }
file_exists() { if [[ -f "$2" ]]; then pass "$1"; else fail "$1"; fi; }
folder_exists() { if [[ -d "$2" ]]; then pass "$1"; else fail "$1"; fi; }
contains() { if [[ -f "$2" ]] && grep -Fq -- "$3" "$2"; then pass "$1"; else fail "$1"; fi; }
compare() { if [[ -f "$2" ]] && cmp -s "$2" "$3"; then pass "$1"; else fail "$1"; fi; }

folder_exists 'Nested evidence folder' 'work/evidence'
folder_exists 'Nested triage folder' 'work/triage'
folder_exists 'Nested archive folder' 'work/archive'
folder_exists 'Reports folder' 'reports'

contains 'Log inventory includes hidden entry' 'reports/log_inventory.txt' '.rotation-state'
contains 'Log inventory includes gateway.log' 'reports/log_inventory.txt' 'gateway.log'
contains 'Recent-first log listing includes worker.log' 'reports/log_recent_first.txt' 'worker.log'

compare 'Gateway log evidence matches original' 'work/evidence/gateway.log' 'source/logs/gateway.log'
compare 'Auth log evidence matches original' 'work/evidence/auth.log' 'source/logs/auth.log'
compare 'Config evidence matches original' 'work/evidence/gateway.conf' 'source/config/gateway.conf'

if [[ -f 'work/triage/incident_INC-2048.txt' && ! -e 'source/incoming/incident_INC-2048.txt' ]]; then
  pass 'Incident ticket moved into triage'
else
  fail 'Incident ticket moved into triage'
fi
if [[ -f 'work/archive/old_gateway_trace.tmp' && ! -e 'source/incoming/old_gateway_trace.tmp' ]]; then
  pass 'Old trace moved to archive'
else
  fail 'Old trace moved to archive'
fi

if [[ -f 'reports/gateway_opening.txt' ]] && cmp -s 'reports/gateway_opening.txt' <(head -n 4 'source/logs/gateway.log'); then
  pass 'Opening four log lines correct'
else
  fail 'Opening four log lines correct'
fi
if [[ -f 'reports/gateway_recent.txt' ]] && cmp -s 'reports/gateway_recent.txt' <(tail -n 5 'source/logs/gateway.log'); then
  pass 'Final five log lines correct'
else
  fail 'Final five log lines correct'
fi
if [[ -f 'reports/gateway_window.txt' ]] && cmp -s 'reports/gateway_window.txt' <(sed -n '3,7p' 'source/logs/gateway.log'); then
  pass 'Log lines 3 through 7 correct'
else
  fail 'Log lines 3 through 7 correct'
fi
if [[ -f 'reports/gateway_alerts.txt' ]] && cmp -s 'reports/gateway_alerts.txt' <(grep -nE 'ERROR|CRITICAL' 'source/logs/gateway.log'); then
  pass 'Numbered gateway alerts correct'
else
  fail 'Numbered gateway alerts correct'
fi
if [[ -f 'reports/auth_failures.txt' ]] && cmp -s 'reports/auth_failures.txt' <(grep -n 'FAILED' 'source/logs/auth.log'); then
  pass 'Numbered authentication failures correct'
else
  fail 'Numbered authentication failures correct'
fi
if [[ -f 'reports/timeout_lines.txt' ]] && cmp -s 'reports/timeout_lines.txt' <(grep -ni 'timeout' 'source/logs/gateway.log'); then
  pass 'Case-insensitive timeout matches correct'
else
  fail 'Case-insensitive timeout matches correct'
fi
if [[ -f 'reports/non_info_events.txt' ]] && cmp -s 'reports/non_info_events.txt' <(grep -v ' INFO ' 'source/logs/gateway.log'); then
  pass 'Non-INFO event report correct'
else
  fail 'Non-INFO event report correct'
fi
if [[ -f 'reports/delayed_shipments.txt' ]] && cmp -s 'reports/delayed_shipments.txt' <(grep -n ',DELAYED,' 'source/data/shipments.csv'); then
  pass 'Numbered delayed shipments correct'
else
  fail 'Numbered delayed shipments correct'
fi
if [[ -f 'reports/gateway_alert_count.txt' ]] && [[ "$(tr -d '[:space:]' < reports/gateway_alert_count.txt)" == 4 ]]; then
  pass 'Gateway alert count correct'
else
  fail 'Gateway alert count correct'
fi
if [[ -f 'reports/auth_failure_count.txt' ]] && [[ "$(tr -d '[:space:]' < reports/auth_failure_count.txt)" == 3 ]]; then
  pass 'Authentication failure count correct'
else
  fail 'Authentication failure count correct'
fi

if [[ -f 'work/triage/gateway.conf' ]] && cmp -s 'work/triage/gateway.conf' <(cat <<'EXPECTED'
SERVICE_NAME=order-gateway
ENVIRONMENT=production
PORT=8080
MAINTENANCE_MODE=off
RETRY_LIMIT=3
LOG_LEVEL=DEBUG
API_TOKEN=REDACTED
EXPECTED
); then
  pass 'Sanitized working config correct'
else
  fail 'Sanitized working config correct'
fi
if [[ -f 'source/config/gateway.conf' ]] && grep -Fqx 'MAINTENANCE_MODE=on' 'source/config/gateway.conf' && grep -Fqx 'API_TOKEN=TRAINING_VALUE_ONLY' 'source/config/gateway.conf'; then
  pass 'Original configuration remains unchanged'
else
  fail 'Original configuration remains unchanged'
fi
if [[ -f 'source/incoming/vendor_notice.txt' ]]; then
  pass 'Vendor notice remains in incoming'
else
  fail 'Vendor notice remains in incoming'
fi

if [[ -f 'reports/incident_summary.txt' ]] && grep -iq 'INC-2048' reports/incident_summary.txt && grep -iq 'gateway' reports/incident_summary.txt && grep -iq 'failed' reports/incident_summary.txt; then
  pass 'Incident summary includes required context'
else
  fail 'Incident summary includes required context'
fi

printf '\nResults: %d passed, %d failed (%d checks).\n' "$passed" "$failed" "$((passed + failed))"
if ((failed > 0)); then exit 1; fi
echo 'Lab checks passed.'
