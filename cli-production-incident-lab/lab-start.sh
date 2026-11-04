#!/usr/bin/env bash
set -euo pipefail

LAB_PARENT="$HOME/Documents/Theowaf/cpg/cloudfundamentals/hwlabs"
mkdir -p "$LAB_PARENT"
cd "$LAB_PARENT"

LAB_DIR="$LAB_PARENT/cli-production-incident-lab"
MARKER="$LAB_DIR/.cli-lab-owner"

if [[ -e "$LAB_DIR" || -L "$LAB_DIR" ]]; then
    echo "ERROR: Lab workspace already exists at: $LAB_DIR" >&2
    echo "Run the lab checker, or use lab-end.sh if you intend to remove it." >&2
    exit 1
fi

mkdir -p "$LAB_DIR/source/logs" "$LAB_DIR/source/config" "$LAB_DIR/source/data" "$LAB_DIR/source/incoming"
printf '%s\n' 'cli-production-incident-lab-v1' > "$MARKER"

cat > "$LAB_DIR/source/logs/gateway.log" <<'EOF'
2026-10-22 08:00:00 INFO gateway boot complete
2026-10-22 08:01:02 INFO gateway /health 200
2026-10-22 08:03:11 WARN gateway latency above target
2026-10-22 08:04:25 ERROR gateway checkout timeout
2026-10-22 08:05:03 INFO gateway retry scheduled
2026-10-22 08:06:32 ERROR gateway upstream timeout
2026-10-22 08:08:10 INFO gateway request accepted
2026-10-22 08:09:17 WARN gateway queue depth high
2026-10-22 08:10:44 CRITICAL gateway circuit breaker open
2026-10-22 08:12:23 ERROR gateway connection refused
2026-10-22 08:13:07 INFO gateway health probe 503
2026-10-22 08:15:59 INFO gateway incident escalated
EOF

cat > "$LAB_DIR/source/logs/auth.log" <<'EOF'
2026-10-22 08:01:00 INFO LOGIN SUCCESS user=amiller ip=10.4.0.10
2026-10-22 08:03:07 WARN LOGIN FAILED user=admin ip=10.4.0.44
2026-10-22 08:04:16 INFO LOGIN SUCCESS user=kchan ip=10.4.0.11
2026-10-22 08:06:21 WARN LOGIN FAILED user=root ip=10.4.0.44
2026-10-22 08:10:05 WARN LOGIN FAILED user=admin ip=10.4.0.99
2026-10-22 08:14:30 INFO LOGIN SUCCESS user=jdoe ip=10.4.0.12
EOF

cat > "$LAB_DIR/source/logs/worker.log" <<'EOF'
2026-10-22 08:00:10 INFO worker task processor ready
2026-10-22 08:02:45 INFO worker received shipment job
2026-10-22 08:07:30 WARN worker queue length increased
2026-10-22 08:11:21 ERROR worker job failed after retry
2026-10-22 08:16:42 INFO worker backlog recorded
EOF

printf '%s\n' 'rotation=enabled' > "$LAB_DIR/source/logs/.rotation-state"

cat > "$LAB_DIR/source/config/gateway.conf" <<'EOF'
SERVICE_NAME=order-gateway
ENVIRONMENT=production
PORT=8080
MAINTENANCE_MODE=on
RETRY_LIMIT=0
LOG_LEVEL=DEBUG
API_TOKEN=TRAINING_VALUE_ONLY
EOF

cat > "$LAB_DIR/source/data/shipments.csv" <<'EOF'
shipment_id,region,status,priority
SHP-101,east,DELIVERED,normal
SHP-102,west,DELAYED,high
SHP-103,east,IN_TRANSIT,normal
SHP-104,central,DELAYED,critical
SHP-105,west,DELIVERED,normal
SHP-106,central,DELAYED,high
EOF

cat > "$LAB_DIR/source/incoming/incident_INC-2048.txt" <<'EOF'
Ticket: INC-2048
Service: order-gateway
Severity: SEV-2
Customer reports intermittent checkout failures.
Operations reports elevated latency and failed administrator logins.
Preserve original evidence, prepare a sanitized working configuration,
and create an incident summary before the workspace is removed.
EOF

cat > "$LAB_DIR/source/incoming/old_gateway_trace.tmp" <<'EOF'
TRAINING DEBUG TRACE - OLD - NOT REQUIRED FOR INCIDENT REPORT
EOF

cat > "$LAB_DIR/source/incoming/vendor_notice.txt" <<'EOF'
Vendor status unchanged. Keep this file in the incoming directory.
EOF

printf '\nLab workspace created successfully.\n'
printf 'Location: %s\n' "$LAB_DIR"
printf 'Navigate there with:\n  cd "%s"\n' "$LAB_DIR"
printf 'Complete the requirements in README.md, then run lab-check.sh.\n'
printf 'Use lab-end.sh only after reviewing or submitting your work.\n'
