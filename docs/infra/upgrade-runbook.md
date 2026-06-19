# Fundara Upgrade Runbook

**Audience:** DevOps engineer / system administrator  
**Last updated:** 2026-06-19  
**Stack:** Ubuntu 24.04.4 LTS · Frappe Framework · ERPNext v16 · Fundara custom app

---

## Overview

Fundara runs as a custom Frappe app (`fundara`) layered on top of ERPNext. Every upgrade touches multiple components that must move in lock-step: Frappe Framework, ERPNext, the Fundara app, and the MariaDB schema. This runbook covers three upgrade risk tiers and a special section for custom-app-only updates and multi-site environments.

**Golden rules that apply to every upgrade scenario:**

- No core ERPNext modification exists in this codebase. All Fundara customisation lives in the `fundara` app and in fixture files. This makes upgrades significantly safer than setups that patch core files.
- Always test in staging before applying to production.
- Always take a verified backup immediately before the production upgrade window begins.
- Pin versions in `apps.json` / `requirements.txt` — never run `bench update` blindly on production.

---

## Upgrade Risk Matrix

| Scenario | Example | Risk | Staging required? | Downtime expected |
|---|---|---|---|---|
| A — Patch | v16.x.1 → v16.x.2 | Low | Recommended | < 15 min |
| B — Minor | v16.1 → v16.2 | Medium | Required | 15–45 min |
| C — Major | v16 → v17 | High | Required (full cycle) | 1–4 hours |

---

## Scenario A: Patch Upgrade

**Example:** ERPNext v16.3.1 → v16.3.2

Patch releases contain bug fixes and security patches. They rarely introduce new DocTypes or field changes. The risk of breaking Fundara custom fields or reports is low, but a backup and verification pass are still mandatory.

### Pre-upgrade Checklist

- [ ] Backup taken and verified (restore test recommended for production)
- [ ] Staging environment tested first with the same patch version
- [ ] Change window communicated to users (even a short one)
- [ ] Rollback plan confirmed and documented
- [ ] Fundara app compatibility reviewed (check Fundara changelog for any noted incompatibility)
- [ ] No active background jobs running (check queue is empty or drained)
- [ ] All pending advances and approval workflows are in a stable state (not mid-approval)

### Upgrade Steps

Run all commands as the `frappe` user (or whichever OS user owns the bench). Do not run as root.

**1. Identify the target version and prepare**

```bash
cd /home/frappe/frappe-bench

# Review what will change before pulling
git -C apps/erpnext log --oneline HEAD..origin/version-16

# Check current versions
bench version
```

**2. Put the site in maintenance mode**

```bash
bench --site <sitename> set-maintenance-mode on
```

For multi-site servers, put each site into maintenance mode:

```bash
bench --site site1.fundara.id set-maintenance-mode on
bench --site site2.fundara.id set-maintenance-mode on
```

**3. Take a backup and verify it**

```bash
bench --site <sitename> backup --with-files

# Verify the backup file was created and is non-zero
ls -lh sites/<sitename>/private/backups/ | tail -5
```

Copy the backup to a remote location before proceeding:

```bash
rsync -avz sites/<sitename>/private/backups/ backup-server:/backups/<sitename>/
```

**4. Pull the patch update**

```bash
# Pull only the patch — do not run a generic bench update
cd apps/frappe && git fetch origin && git checkout version-16 && git pull
cd ../erpnext && git fetch origin && git checkout version-16 && git pull

# If the fundara app has a patch-compatible release, pull it too
cd ../fundara && git fetch origin && git pull
```

For version-pinned deployments:

```bash
cd apps/erpnext && git checkout v16.3.2
cd ../frappe && git checkout v16.3.2
```

**5. Install any new Python dependencies**

```bash
cd /home/frappe/frappe-bench
./env/bin/pip install -e apps/frappe -e apps/erpnext -e apps/fundara --quiet
```

**6. Run database migrations**

```bash
bench --site <sitename> migrate
```

Watch for errors. A successful migration ends with "Migrations: 0 skipped, N applied" (or similar). Any Python traceback here means stop and investigate before continuing.

**7. Build frontend assets**

```bash
bench build --app frappe --app erpnext --app fundara
```

For production, use the production build flag:

```bash
bench build --production
```

**8. Restart services**

```bash
sudo supervisorctl restart all
```

Or, if using systemd:

```bash
sudo systemctl restart supervisor
```

**9. Verify (see Verification Steps below)**

**10. Exit maintenance mode**

```bash
bench --site <sitename> set-maintenance-mode off
```

### Verification Steps

Run these checks before communicating all-clear to users.

```bash
# 1. Check that the site loads and returns HTTP 200
curl -s -o /dev/null -w "%{http_code}" https://<sitename>

# 2. Check scheduler is running
bench --site <sitename> scheduler status

# 3. Check background workers
sudo supervisorctl status | grep frappe

# 4. Check error logs for new exceptions
tail -100 logs/frappe.log | grep -i "error\|exception\|traceback"
```

In the browser (log in as Administrator):

- [ ] Open Fund list — all Fund records load without error
- [ ] Create a test Fund (save as Draft, do not submit)
- [ ] Open Cash Advance list — records load
- [ ] Create a test Cash Advance in Draft — verify fund and budget fields render correctly
- [ ] Open at least one Donor Report and verify it generates without error
- [ ] Check Scheduled Jobs in **Setup → System Settings → Scheduled Jobs** — confirm last run timestamps are recent
- [ ] Check **Background Jobs** panel — confirm no stuck jobs

Delete any test records created during verification.

### Rollback Procedure

**Estimated rollback time:** 10–20 minutes

**1. Put site back in maintenance mode (if not already)**

```bash
bench --site <sitename> set-maintenance-mode on
```

**2. Revert application code to the previous version**

```bash
cd apps/erpnext && git checkout <previous-commit-hash>
cd ../frappe && git checkout <previous-commit-hash>
cd ../fundara && git checkout <previous-commit-hash>
```

**3. Restore the pre-upgrade backup**

```bash
bench --site <sitename> restore <path-to-database-backup>.sql.gz --with-public-files <path-to-public-files>.tar --with-private-files <path-to-private-files>.tar
```

**4. Rebuild assets and restart**

```bash
bench build
sudo supervisorctl restart all
```

**5. Exit maintenance mode and verify**

```bash
bench --site <sitename> set-maintenance-mode off
```

**Communicating rollback to users:**
Send a brief message through your notification channel (email / WhatsApp group / Slack) stating: system has been restored to the previous version, the upgrade will be rescheduled, and any changes made during the maintenance window (if users were allowed in) should be re-entered. Patch upgrades typically have no change window long enough for user data entry, so this is usually moot.

---

## Scenario B: Minor Version Upgrade

**Example:** ERPNext v16.1 → v16.2

Minor releases may include new DocTypes, schema changes, renamed fields, altered JavaScript controllers, or changes to Frappe Workflow internals. Fundara custom fields, reports, and fixtures must be tested for compatibility before production deployment.

### Pre-upgrade Checklist

- [ ] Backup taken and verified with a test restore on staging
- [ ] ERPNext v16.1 → v16.2 release notes reviewed (check `CHANGELOG.md` in ERPNext repo)
- [ ] Frappe v16.1 → v16.2 release notes reviewed
- [ ] Fundara custom DocTypes checked against any renamed or removed ERPNext fields they reference
- [ ] Fundara fixtures (workflow, custom fields, print formats) tested on staging
- [ ] Staging environment upgraded and tested for at least 2 business days
- [ ] Finance team and key users have signed off on staging test
- [ ] Change window communicated at least 48 hours in advance
- [ ] Rollback plan confirmed and documented
- [ ] Backup of Fundara fixture files committed to version control

### Upgrade Steps

**1. Freeze production and take backup**

```bash
bench --site <sitename> set-maintenance-mode on
bench --site <sitename> backup --with-files
rsync -avz sites/<sitename>/private/backups/ backup-server:/backups/<sitename>/pre-v16.2/
```

**2. Update application code**

```bash
cd /home/frappe/frappe-bench

cd apps/frappe && git fetch origin && git checkout v16.2.x
cd ../erpnext && git fetch origin && git checkout v16.2.x
cd ../fundara && git fetch origin && git checkout <fundara-release-tag-compatible-with-erpnext-v16.2>
```

**3. Install updated dependencies**

```bash
./env/bin/pip install -e apps/frappe -e apps/erpnext -e apps/fundara

# Update Node dependencies if package.json changed
cd apps/frappe && yarn install --frozen-lockfile
cd ../erpnext && yarn install --frozen-lockfile
cd ../fundara && yarn install --frozen-lockfile
cd /home/frappe/frappe-bench
```

**4. Run database migrations**

```bash
bench --site <sitename> migrate
```

Read migration output carefully. Look for:
- `Applied patch: erpnext.patches.*` — normal
- `Applied patch: fundara.patches.*` — normal
- Any `ERROR` or `FAILED` line — stop and investigate

**5. Reload Frappe fixtures**

If Fundara ships fixture updates in this release:

```bash
bench --site <sitename> reload-doc fundara
# Or reload specific doctypes:
bench --site <sitename> import-fixtures --app fundara
```

**6. Build frontend assets**

```bash
bench build --production
```

**7. Restart all services**

```bash
sudo supervisorctl restart all
```

**8. Run verification (extended)**

**9. Exit maintenance mode**

```bash
bench --site <sitename> set-maintenance-mode off
```

### Verification Steps (Extended for Minor Upgrade)

All steps from Scenario A, plus:

```bash
# Check that no custom fields were silently dropped
bench --site <sitename> console
# In the console:
# frappe.get_meta("Fund").fields  — look for fund-specific fields
# frappe.get_meta("Advance").fields  — look for Fundara Advance fields
# exit()
```

In the browser:

- [ ] All Fund records load and all custom fund fields are visible
- [ ] All Advance records load — status field reflects correct lifecycle states
- [ ] Submit a test Advance through the full approval workflow (Draft → Submitted → Approved → Paid)
- [ ] Verify Cash Advance triggers correct GL entries (check Journal Entry created)
- [ ] Open Fund Utilization Report — confirm it generates with correct figures
- [ ] Open Donor Financial Report — confirm it generates without error
- [ ] Check all scheduled tasks ran within the expected window after restart
- [ ] Check custom print formats still render correctly
- [ ] Verify Frappe Workflow states are intact for Advance, Purchase Request, and Fund Transfer

### Rollback Procedure

**Estimated rollback time:** 20–40 minutes

Minor version rollbacks carry more risk because schema migrations may have run. The safest approach is always a full database restore.

**1. Put site in maintenance mode**

```bash
bench --site <sitename> set-maintenance-mode on
```

**2. Revert code**

```bash
cd apps/erpnext && git checkout <v16.1.x-commit>
cd ../frappe && git checkout <v16.1.x-commit>
cd ../fundara && git checkout <previous-fundara-tag>
```

**3. Restore the pre-upgrade database backup**

```bash
bench --site <sitename> restore \
  sites/<sitename>/private/backups/<pre-upgrade-db-backup>.sql.gz \
  --with-public-files sites/<sitename>/private/backups/<pre-upgrade-public>.tar \
  --with-private-files sites/<sitename>/private/backups/<pre-upgrade-private>.tar
```

**4. Rebuild and restart**

```bash
bench build
sudo supervisorctl restart all
bench --site <sitename> set-maintenance-mode off
```

**Communicating rollback to users:**
Notify users that the upgrade has been rolled back due to a compatibility issue found during verification. State that the system is back on the previous version and is fully operational. Provide an estimated timeline for the rescheduled upgrade.

---

## Scenario C: Major Version Upgrade

**Example:** ERPNext v16 → v17

Major version upgrades carry the highest risk. ERPNext v16 → v17 will include breaking API changes, DocType restructuring, potential removal of deprecated features, and Frappe Framework changes. This scenario requires a full testing cycle spanning weeks, not hours.

### Pre-upgrade Checklist

- [ ] ERPNext v17 release notes read in full and documented for team review
- [ ] Frappe v17 changelog reviewed — check for any removed APIs that Fundara uses
- [ ] Fundara codebase audited against breaking changes: `hooks.py`, all `frappe.get_doc`, all `frappe.db.get_value`, all JavaScript form events
- [ ] All Fundara DocType definitions verified against v17 schema requirements
- [ ] All Fundara custom reports tested on a v17 staging environment
- [ ] All Frappe Workflows tested on a v17 staging environment
- [ ] Staging has been running v17 for at least 2 weeks with representative data
- [ ] Finance team has completed full User Acceptance Testing on staging
- [ ] Fundara v17-compatible release tagged and reviewed by a second developer
- [ ] Database backup taken, verified with a test restore, and stored offsite
- [ ] Rollback plan approved by technical lead
- [ ] Change window communicated to all users at least 1 week in advance
- [ ] Extended downtime window reserved (minimum 4 hours)
- [ ] Emergency escalation contact available during the upgrade window

### Upgrade Steps

**1. Schedule and communicate the change window**

Reserve a minimum 4-hour window. Major upgrades on large datasets (many GL entries, large file attachments) can take longer. Test migration time on staging first and add a 50% buffer.

**2. Take a comprehensive pre-upgrade backup**

```bash
bench --site <sitename> set-maintenance-mode on

# Database backup with files
bench --site <sitename> backup --with-files

# Additionally dump the database directly as a raw safety net
mysqldump -u root -p --single-transaction --routines \
  $(bench --site <sitename> show-config | grep db_name | awk '{print $2}') \
  | gzip > /backup/raw-pre-v17-$(date +%Y%m%d-%H%M).sql.gz

# Store site config
cp sites/<sitename>/site_config.json /backup/site_config_pre_v17.json

# Record exact commit hashes before upgrade
git -C apps/frappe rev-parse HEAD > /backup/pre-v17-versions.txt
git -C apps/erpnext rev-parse HEAD >> /backup/pre-v17-versions.txt
git -C apps/fundara rev-parse HEAD >> /backup/pre-v17-versions.txt

# Copy to remote storage
rsync -avz /backup/ backup-server:/backups/<sitename>/pre-v17/
```

**3. Update Frappe Framework first**

Major upgrades must follow the sequence: Frappe → ERPNext → Fundara. Never upgrade ERPNext before Frappe.

```bash
cd apps/frappe && git fetch origin && git checkout version-17
./env/bin/pip install -e apps/frappe
```

**4. Update ERPNext**

```bash
cd /home/frappe/frappe-bench/apps/erpnext
git fetch origin && git checkout version-17
cd /home/frappe/frappe-bench
./env/bin/pip install -e apps/erpnext
```

**5. Update Fundara to the v17-compatible release**

```bash
cd apps/fundara
git fetch origin && git checkout <fundara-v17-release-tag>
cd /home/frappe/frappe-bench
./env/bin/pip install -e apps/fundara
```

**6. Update Node dependencies**

```bash
cd apps/frappe && yarn install --frozen-lockfile
cd /home/frappe/frappe-bench/apps/erpnext && yarn install --frozen-lockfile
cd /home/frappe/frappe-bench/apps/fundara && yarn install --frozen-lockfile
cd /home/frappe/frappe-bench
```

**7. Run database migrations**

```bash
bench --site <sitename> migrate --verbose
```

Major migrations can take 30–60 minutes on databases with years of GL entries. Monitor the output in a second terminal:

```bash
# In a second terminal
tail -f logs/worker.log
```

**8. Build frontend assets**

```bash
bench build --production
```

**9. Restart all services**

```bash
sudo supervisorctl restart all
```

**10. Run comprehensive verification (see below)**

**11. Exit maintenance mode only after full sign-off**

```bash
bench --site <sitename> set-maintenance-mode off
```

### Verification Steps (Comprehensive for Major Upgrade)

Do not skip any step. Major upgrades may have subtle regressions.

```bash
# Check no Python import errors
python -c "import frappe; import erpnext; import fundara; print('imports OK')"

# Check site health
bench --site <sitename> doctor

# Check scheduler
bench --site <sitename> scheduler status

# Check background workers
sudo supervisorctl status
```

In the browser (all steps require Administrator access):

**DocType integrity:**
- [ ] Fund — open list, open a record, all fields visible
- [ ] Grant — open list, open a record
- [ ] Advance — open list, open a record, all status fields correct
- [ ] Liquidation — open list, open a record
- [ ] Fund Allocation — open list, open a record
- [ ] Program — open list, open a record
- [ ] Evidence Checklist — open list, open a record

**Workflow integrity:**
- [ ] Advance workflow: create Draft → submit → check Pending Approval state → approve → confirm state transitions work
- [ ] Cash Receipt workflow: Draft → submit → verify GL entry created
- [ ] Purchase Request workflow: Draft → submit → approve → confirm state

**Report integrity:**
- [ ] Fund Utilization Report — run with date range, verify figures
- [ ] Donor Financial Report — run for one donor
- [ ] ISAK 35 Statement of Financial Position — run for current fiscal year
- [ ] Budget vs Actual Report — run for one fund
- [ ] Advance Aging Report — run, verify data matches expectations

**Accounting integrity:**
- [ ] Chart of Accounts loads correctly
- [ ] Trial Balance for current fiscal year generates without error
- [ ] One GL entry opened and all fields correct

**Background jobs:**
- [ ] Send a test email notification and confirm it arrives
- [ ] Check that scheduled Fund Balance Snapshot job ran or can be triggered manually

### Rollback Procedure

**Estimated rollback time:** 30–90 minutes (depends on database size)

Major version rollback is the highest-risk operation. The database schema may have changed significantly. A raw restore is the only safe path — do not attempt to "downgrade" migrations.

**1. Keep maintenance mode on**

**2. Revert code to pre-upgrade state**

```bash
# Use the exact commit hashes recorded before upgrade
OLD_FRAPPE=$(grep frappe /backup/pre-v17-versions.txt | awk '{print $1}')
OLD_ERPNEXT=$(grep erpnext /backup/pre-v17-versions.txt | awk '{print $1}')
OLD_FUNDARA=$(grep fundara /backup/pre-v17-versions.txt | awk '{print $1}')

cd /home/frappe/frappe-bench/apps/frappe && git checkout $OLD_FRAPPE
cd ../erpnext && git checkout $OLD_ERPNEXT
cd ../fundara && git checkout $OLD_FUNDARA
```

**3. Restore the raw database backup**

```bash
# Drop the current (partially migrated) database
mysql -u root -p -e "DROP DATABASE \`$(bench --site <sitename> show-config | grep db_name | awk '{print $2}')\`"
mysql -u root -p -e "CREATE DATABASE \`$(bench --site <sitename> show-config | grep db_name | awk '{print $2}')\`"

# Restore from raw SQL dump
zcat /backup/raw-pre-v17-<timestamp>.sql.gz | mysql -u root -p \
  $(bench --site <sitename> show-config | grep db_name | awk '{print $2}')
```

**4. Restore site config if altered**

```bash
cp /backup/site_config_pre_v17.json sites/<sitename>/site_config.json
```

**5. Restore file attachments**

```bash
bench --site <sitename> restore \
  /path/to/pre-upgrade-db-backup.sql.gz \
  --with-public-files /path/to/public-files.tar \
  --with-private-files /path/to/private-files.tar
```

Or restore files directly from the backup archive if you are using the raw SQL restore above:

```bash
tar -xzf sites/<sitename>/private/backups/<pre-upgrade-private>.tar -C sites/<sitename>/
tar -xzf sites/<sitename>/private/backups/<pre-upgrade-public>.tar -C sites/<sitename>/
```

**6. Reinstall old Python dependencies and rebuild**

```bash
./env/bin/pip install -e apps/frappe -e apps/erpnext -e apps/fundara
bench build
sudo supervisorctl restart all
bench --site <sitename> set-maintenance-mode off
```

**Communicating rollback to users:**
Send a formal communication: "We have encountered a compatibility issue during the major upgrade to ERPNext v17. The system has been fully restored to v16 and all data is intact. We will conduct additional testing and reschedule the upgrade. We will notify you at least 1 week before the next attempt."

---

## Fundara Custom App Upgrade

Sometimes you need to update only the Fundara app — for example, to deploy a new report, a bug fix in a Fundara DocType, or new fixtures — without touching ERPNext or Frappe.

### When a Fundara-Only Upgrade is Safe

A Fundara-only upgrade is safe when:

- The release notes state no new Python or Node dependencies were added
- No new migrations are in `fundara/patches/` (check `patches.txt`)
- No changes to ERPNext DocTypes (custom fields on ERPNext doctypes are in fixtures)
- The Fundara version being deployed is tagged as compatible with the currently installed ERPNext version

A Fundara-only upgrade is risky (treat as Scenario B) when:

- New custom fields are added to ERPNext DocTypes (requires `migrate`)
- New DocTypes are introduced in the Fundara app
- Workflow fixture files have changed
- New patches appear in `patches.txt`

### Steps for a Safe Fundara-Only Upgrade

```bash
cd /home/frappe/frappe-bench

# Optional but recommended: maintenance mode for short window
bench --site <sitename> set-maintenance-mode on

# Backup
bench --site <sitename> backup

# Pull new Fundara release
cd apps/fundara && git fetch origin && git checkout <new-fundara-tag>

# Reinstall Python package (picks up any new module)
cd /home/frappe/frappe-bench
./env/bin/pip install -e apps/fundara

# Run migrate (safe even if there are no new patches — it's idempotent)
bench --site <sitename> migrate

# Rebuild only the Fundara assets
bench build --app fundara

# Restart
sudo supervisorctl restart all

# Verify and exit maintenance mode
bench --site <sitename> set-maintenance-mode off
```

### Handling Database Migrations in Fundara (patches.txt)

Fundara database migrations live in `fundara/patches/` and are registered in `fundara/patches.txt`. Frappe runs each patch exactly once per site, tracked in the `__PatchLog` table.

**Adding a new patch (for Fundara developers):**

1. Create the patch file: `fundara/patches/v1_x/my_patch_name.py`
2. Add the dotted module path to the end of `patches.txt`:
   ```
   fundara.patches.v1_x.my_patch_name
   ```
3. Test on development with `bench --site dev.local migrate`
4. Test on staging before deploying to production

**Checking which patches have run on a site:**

```bash
bench --site <sitename> console
# In console:
# frappe.db.sql("SELECT * FROM __PatchLog WHERE patched_file LIKE '%fundara%' ORDER BY applied_on DESC LIMIT 20")
# exit()
```

**If a patch fails mid-run:**
Do not re-run `migrate` without investigating. A failed patch may have left the database in a partial state. Restore from backup and fix the patch code before trying again.

---

## Multi-site Upgrade

When the server hosts multiple organisation sites (e.g., `ngoa.fundara.id`, `ngob.fundara.id`), you have two strategies: **rolling upgrade** and **simultaneous upgrade**.

### Rolling Upgrade (Recommended for Minor and Major Upgrades)

Upgrade one site first, verify it fully, then upgrade the next. This limits blast radius.

```
Stage 1: ngoa.fundara.id (lowest-traffic org, or internal test org)
   ↓ verify fully
Stage 2: ngob.fundara.id
   ↓ verify
Stage 3: ngoc.fundara.id
   ...
```

**Important:** Application code (`apps/frappe`, `apps/erpnext`, `apps/fundara`) is **shared** across all sites in a bench. You cannot run different versions of the code for different sites simultaneously. Rolling upgrade here means running migrations on one site at a time, not running different code versions.

The correct sequence for rolling upgrade:

```bash
# 1. Pull new code (applies to all sites immediately — code is shared)
cd apps/frappe && git checkout <new-version>
cd ../erpnext && git checkout <new-version>
cd ../fundara && git checkout <new-version>
./env/bin/pip install -e apps/frappe -e apps/erpnext -e apps/fundara
bench build --production

# 2. Put all sites in maintenance mode
bench --site ngoa.fundara.id set-maintenance-mode on
bench --site ngob.fundara.id set-maintenance-mode on
bench --site ngoc.fundara.id set-maintenance-mode on

# 3. Migrate one site at a time
bench --site ngoa.fundara.id migrate
# Verify ngoa before proceeding
bench --site ngob.fundara.id migrate
# Verify ngob before proceeding
bench --site ngoc.fundara.id migrate

# 4. Restart services once (shared workers restart once)
sudo supervisorctl restart all

# 5. Exit maintenance mode site by site as verified
bench --site ngoa.fundara.id set-maintenance-mode off
# Verify
bench --site ngob.fundara.id set-maintenance-mode off
# Verify
bench --site ngoc.fundara.id set-maintenance-mode off
```

### Simultaneous Upgrade

For patch upgrades with low risk, you can migrate all sites in one pass:

```bash
# Migrate all sites at once
bench migrate  # without --site flag migrates all sites
```

Use this approach only for patch upgrades where staging has already been verified. Never use simultaneous migration for minor or major upgrades.

### Testing on One Site Before Applying to All

The recommended approach for minor upgrades:

1. Set up a designated "canary" site that mirrors a real organisation's data (anonymised or with consent).
2. Run the full upgrade on the canary site.
3. Have the organisation's admin or a finance team member verify the canary site.
4. If verified after 1–2 business days, proceed with remaining sites.

**Practical setup for a canary site:**

```bash
# Clone an existing site's database to a canary site
bench --site ngoa.fundara.id backup --with-files
bench new-site canary.fundara.id --install-app erpnext --install-app fundara
bench --site canary.fundara.id restore <backup-file>.sql.gz
```

### Automating Multi-site Upgrades

For servers with many sites (10+), consider a simple shell script:

```bash
#!/bin/bash
# upgrade-all-sites.sh
SITES=$(bench sites)
for SITE in $SITES; do
  echo "=== Migrating $SITE ==="
  bench --site $SITE set-maintenance-mode on
  bench --site $SITE backup
  bench --site $SITE migrate
  if [ $? -eq 0 ]; then
    echo "$SITE migration succeeded"
    bench --site $SITE set-maintenance-mode off
  else
    echo "ERROR: $SITE migration failed. Site remains in maintenance mode. Investigate before continuing."
    break
  fi
done
```

Review and test this script thoroughly on staging before using on production.

---

## Appendix: Version Pinning

Always pin versions in production. Store the current pinned versions in a `versions.txt` file in the bench root or in your infrastructure repository:

```
frappe==16.3.2
erpnext==16.3.2
fundara==1.2.1
```

Check actual installed versions at any time:

```bash
bench version
```

To check individual app versions:

```bash
cat apps/erpnext/erpnext/__version__.py
cat apps/fundara/fundara/__version__.py
```

---

## Appendix: Quick Reference Commands

| Action | Command |
|---|---|
| Check versions | `bench version` |
| Enter maintenance mode | `bench --site <site> set-maintenance-mode on` |
| Exit maintenance mode | `bench --site <site> set-maintenance-mode off` |
| Backup with files | `bench --site <site> backup --with-files` |
| Run migrations | `bench --site <site> migrate` |
| Build assets (production) | `bench build --production` |
| Restart all services | `sudo supervisorctl restart all` |
| Check scheduler | `bench --site <site> scheduler status` |
| Check worker status | `sudo supervisorctl status` |
| View error log | `tail -f logs/frappe.log` |
| List all sites | `bench sites` |
| Site doctor check | `bench --site <site> doctor` |
