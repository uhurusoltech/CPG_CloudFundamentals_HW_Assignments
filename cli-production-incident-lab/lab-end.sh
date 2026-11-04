#!/usr/bin/env bash
set -euo pipefail

LAB_PARENT="$HOME/Documents/Theowaf/cpg/cloudfundamentals/hwlabs"
LAB_DIR="$LAB_PARENT/cli-production-incident-lab"
MARKER="$LAB_DIR/.cli-lab-owner"

if [[ ! -d "$LAB_PARENT" ]]; then
    echo "No lab parent directory found. Nothing to remove."
    exit 0
fi
cd "$LAB_PARENT"

if [[ -L "$LAB_DIR" ]]; then
    echo "ERROR: Lab path is a symbolic link; refusing deletion." >&2
    exit 1
fi
if [[ ! -e "$LAB_DIR" ]]; then
    echo "Lab workspace does not exist. Nothing to remove."
    exit 0
fi
if [[ ! -d "$LAB_DIR" || ! -f "$MARKER" || -L "$MARKER" ]]; then
    echo "ERROR: Missing or invalid lab ownership marker; refusing deletion." >&2
    exit 1
fi
if [[ "$(cat "$MARKER")" != 'cli-production-incident-lab-v1' ]]; then
    echo "ERROR: Unexpected workspace marker; refusing deletion." >&2
    exit 1
fi

printf 'This will permanently delete the entire lab workspace:\n%s\n' "$LAB_DIR"
printf 'The README and scripts in your downloaded repository will not be removed.\n'
read -r -p 'Type DELETE to confirm: ' response || { echo 'Cancelled.'; exit 1; }
if [[ "$response" != 'DELETE' ]]; then
    echo 'Cancelled. No files were removed.'
    exit 0
fi

rm -rf -- "$LAB_DIR"
echo 'Lab workspace removed.'
