# Intermediate Linux CLI Lab — Production Incident File Triage

## Scenario

You are a junior Linux operations engineer supporting the **Northstar Commerce** order gateway. The incident manager has assigned you ticket **INC-2048** after checkout timeouts, gateway errors, failed administrator logins, and delayed shipments were reported.

You must investigate a **simulated** production export using only the terminal. Your job is to inventory the files, preserve untouched evidence, move incoming incident material into organized working folders, examine different sections of logs, filter important events, and prepare a sanitized configuration and brief incident summary.

**This is a command-selection assessment.** The assignment deliberately describes *results*, not the commands to achieve them. Determine which commands and flags to use. You may consult help/manual pages and your own notes. There are no step-by-step solutions to the actual exercises in this README.

### Required CLI command families

`ls`, `mkdir`, `cp`, `mv`, `head`, `tail`, `sed`, and `grep`, including relevant flags. You can also use supporting shell features such as redirection (`>`), `cd`, `pwd`, quotes, and pipes.

### Supported environments

- macOS Terminal (Bash or Zsh for manual commands; starter scripts run with Bash)
- Windows Git Bash
- Linux with Bash

**No sudo, package installs, root permissions, or real server connections are required.** All input is fictional and confined to the exercise workspace.

---

## 1. Files in this repository

```text
README.md
lab-start.sh
lab-check.sh
lab-end.sh
```

These scripts should remain in your local repository folder. `lab-start.sh` will build a separate, transient workspace under your course folder. It does **not** require you to copy the repository into that workspace.

## 2. First-time setup and startup

1. Open **Terminal** (macOS) or **Git Bash** (Windows).
2. Navigate into the repository containing this README and its `.sh` files. Example, if you cloned the repo to a folder named `cli-incident-assignment` beneath your course homework directory:

   ```bash
   cd ~/Documents/Theowaf/cpg/cloudfundamentals/hw/cli-incident-assignment
   ```

   Replace that example path with the **actual path to your repository**. If you just opened a terminal inside the repository folder, no navigation is needed.
3. Confirm that the required files are present:

   ```bash
   pwd
   ls -la
   ```

4. Start the lab:

   ```bash
   bash lab-start.sh
   ```

   The script automatically creates any missing directories in this **exact path (including capitalization)**:

   ```text
   ~/Documents/Theowaf/cpg/cloudfundamentals/hwlabs/
   ```

   It changes to that directory and creates:

   ```text
   ~/Documents/Theowaf/cpg/cloudfundamentals/hwlabs/cli-production-incident-lab/
   ```

   You do **not** need to pre-create either folder. If you have previously used a differently capitalized folder such as `TheoWAF`, be aware that some systems treat `TheoWAF` and `Theowaf` as different directory names.
5. Navigate to the new workspace using the path shown by the startup script:

   ```bash
   cd ~/Documents/Theowaf/cpg/cloudfundamentals/hwlabs/cli-production-incident-lab
   ```

6. Confirm your current directory and inspect the seeded material:

   ```bash
   pwd
   ls -la
   ```

### What startup creates

```text
cli-production-incident-lab/
├── .cli-lab-owner
└── source/
    ├── config/
    │   └── gateway.conf
    ├── data/
    │   └── shipments.csv
    ├── incoming/
    │   ├── incident_INC-2048.txt
    │   ├── old_gateway_trace.tmp
    │   └── vendor_notice.txt
    └── logs/
        ├── .rotation-state
        ├── auth.log
        ├── gateway.log
        └── worker.log
```

**Important:** The `work/` and `reports/` folders do not initially exist. Creating the required nested folders is part of the assignment. The `.cli-lab-owner` file is used to ensure teardown only affects a workspace created by this lab; do not edit or remove it.

**If startup says the workspace already exists**, it will stop without overwriting files. Continue in that workspace, or follow the teardown instructions below and explicitly start over. Restarting does not automatically reset or destroy completed work.

---

## 3. Assignment requirements (independent work)

Complete the deliverables below *within the generated workspace*. Use the appropriate CLI utilities and flags; do not use a file manager or manually type expected report text in place of a command's output. Preserve the original source logs, CSV, and config file unless a requirement specifically says to move an incoming file.

### A — Directory creation and file inventory

1. Create the following **nested** working directories:

   ```text
   work/evidence/
   work/triage/
   work/archive/
   reports/
   ```

2. Produce `reports/log_inventory.txt`, a detailed inventory of `source/logs/` that includes hidden entries, permissions, timestamps and readable sizes. This tests listing commands with multiple flags.
3. Produce `reports/log_recent_first.txt`, a detailed listing of the files in `source/logs/` ordered by most recently modified first.

### B — Preserve evidence and organize incoming material

4. Copy the following files into `work/evidence/`, preserving their original contents and filenames:

   ```text
   source/logs/gateway.log       → work/evidence/gateway.log
   source/logs/auth.log          → work/evidence/auth.log
   source/config/gateway.conf    → work/evidence/gateway.conf
   ```

5. Move `source/incoming/incident_INC-2048.txt` to `work/triage/`.
6. Move `source/incoming/old_gateway_trace.tmp` to `work/archive/`.
7. Leave `source/incoming/vendor_notice.txt` where it is.

### C — Investigate log slices

Use `source/logs/gateway.log` or your identical preserved evidence copy as the input. Generate these reports from the actual lines in the logs:

| Required report | Required content |
|---|---|
| `reports/gateway_opening.txt` | First **4** lines of `gateway.log` |
| `reports/gateway_recent.txt` | Last **5** lines of `gateway.log` |
| `reports/gateway_window.txt` | Lines **3 through 7**, inclusive, of `gateway.log` |

### D — Search, filter, and count

Generate each file below with matching source records, retaining original line text unless stated otherwise:

| Required report | Required content |
|---|---|
| `reports/gateway_alerts.txt` | All `ERROR` and `CRITICAL` gateway events, **with original line numbers** |
| `reports/auth_failures.txt` | All `FAILED` authentication events, **with original line numbers** |
| `reports/timeout_lines.txt` | All gateway lines containing `timeout` in any letter case, **with line numbers** |
| `reports/non_info_events.txt` | All gateway lines **except** those containing the ` INFO ` event marker |
| `reports/delayed_shipments.txt` | All `DELAYED` rows in `shipments.csv`, **with line numbers** |
| `reports/gateway_alert_count.txt` | The numeric count of gateway `ERROR` or `CRITICAL` lines, and nothing else |
| `reports/auth_failure_count.txt` | The numeric count of authentication `FAILED` lines, and nothing else |

### E — Prepare a sanitized working configuration

Create `work/triage/gateway.conf` by transforming the **preserved evidence configuration**, using text-processing tools appropriate for editing streams. Keep all original lines in their original order, except for these intentional changes:

| Setting | Required final value |
|---|---|
| `MAINTENANCE_MODE` | `off` |
| `RETRY_LIMIT` | `3` |
| `API_TOKEN` | `REDACTED` |

Do **not** change `source/config/gateway.conf` or `work/evidence/gateway.conf`. The token in this exercise is only a fictional training value.

### F — Incident summary

Create `reports/incident_summary.txt`. In your own words, include the incident number, which gateway symptoms were observed, the failed-login activity, and the reasons for the configuration adjustments. Minimum length: approximately 4–6 lines. The checker verifies the file exists and contains relevant incident identifiers; the instructor should assess the quality of your explanation.

---

## 4. Acceptance criteria

Your submission is complete when:

- All required directories and report files exist with the correct names.
- The evidence files match the supplied originals byte-for-byte.
- Both incoming files have been moved to the required destinations and the vendor notice remains unchanged.
- The log extracts and filtered reports contain the exact lines requested, including line numbers where specified.
- Numeric reports contain only the requested counts.
- The revised configuration is correct, and the original remains unchanged.
- Your incident summary explains the investigation and findings.

The scoring script checks functional results, **not the keystrokes you typed**. You must be prepared to explain which commands and flags you used during the lab or in a short instructor walkthrough.

---

## 5. Checking your work

The checker is located in your *repository folder*, not the generated workspace. It reads the output but does not create or fix your answers.

When ready, return to the folder containing `lab-check.sh`. If that is still your previous working directory's location, you can navigate to it using its full path or open a terminal there. Then run:

```bash
bash lab-check.sh
```

You can run the checker multiple times. It prints `PASS` / `FAIL` messages for each requirement and finishes with a total. **A failing check does not remove your work.** Correct the assignment inside your workspace and run the checker again.

For evidence of completion, capture the final checker output and your incident summary **before** running teardown, or follow your instructor's submission instructions.

---

## 6. Teardown — remove transient resources

**Teardown deletes your whole generated lab workspace**, including evidence copies, reports, your completed summary, and all other files beneath it. It will not delete the `README.md`, `lab-start.sh`, `lab-end.sh`, or `lab-check.sh` in your repository.

1. Check that you have submitted your work or captured the evidence you need.
2. Open Terminal or Git Bash. Return to the repository directory where the scripts were downloaded or cloned.
3. Confirm you see `lab-end.sh`:

   ```bash
   pwd
   ls -l lab-end.sh
   ```

4. Run:

   ```bash
   bash lab-end.sh
   ```

5. You will be shown the **exact directory** that will be deleted. Review it carefully. Type:

   ```text
   DELETE
   ```

   and press Enter to confirm. Any other response cancels the deletion.
6. The script verifies that the target is the expected lab directory and contains the lab marker. It refuses to delete an unrecognized folder or symlink.
7. Verify cleanup if desired:

   ```bash
   ls -la ~/Documents/Theowaf/cpg/cloudfundamentals/hwlabs
   ```

   The `cli-production-incident-lab` folder should no longer be present. The `hwlabs` parent folder is intentionally preserved so that other course labs are not affected.

### Starting again after teardown

From your repository directory, run:

```bash
bash lab-start.sh
```

You will receive a clean, newly seeded workspace. **This cannot recover previous answers** removed during teardown.

---

## 7. Submission

Submit the deliverables requested by your instructor. Unless told otherwise, submit your final `reports/` folder, the sanitized configuration from `work/triage/`, and the result of `lab-check.sh`. Avoid committing or submitting any actual secrets; this exercise contains no real credentials.

**Reminder:** The case-sensitive course path for this specific assignment uses `Theowaf`, not `TheoWAF`.
