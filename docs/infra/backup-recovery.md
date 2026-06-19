# Backup and Recovery Plan — Fundara Production

**Audience:** DevOps engineer, system administrator  
**Platform:** Ubuntu Server 24.04.4 LTS, ERPNext v16 / Frappe Framework, custom app `fundara`  
**Last updated:** 2026-06-19

---

## Overview

Fundara stores sensitive financial and beneficiary data: donor records, grant agreements, staff advance documents, program evidence, and ISAK 35-compliant accounting entries. A backup failure is not merely an operational inconvenience — it is a fiduciary and compliance risk.

This plan covers what to back up, when, where, how to restore, and how to verify that restores actually work.

---

## 1. What to Back Up

### 1.1 MariaDB Database (per site)

Each Frappe site has its own database. The database name matches the site name (e.g., `fundara_ngo_a`).

- All DocType tables — transactions, configurations, user records
- GL entries, Fund, Grant, Advance, Liquidation, Evidence records
- Frappe system tables — sessions, file references, workflow states, audit logs

**Tool:** `bench backup` wraps `mysqldump` with site-aware credentials.

### 1.2 Frappe Private Files

Path: `/home/frappe/frappe-bench/sites/<site>/private/files/`

Contains:
- Document attachments uploaded by users
- Evidence files (photos, scanned receipts, contracts)
- Grant agreements, donor reports
- Import/export files

These files are **not** in the database. Loss of private files means loss of compliance evidence.

### 1.3 Frappe Public Files

Path: `/home/frappe/frappe-bench/sites/<site>/public/files/`

Contains:
- User-uploaded images visible in the portal
- Logo files, report templates with embedded assets

Lower criticality than private files, but must be backed up for full site restore.

### 1.4 Custom App Code

The `fundara` app lives in `/home/frappe/frappe-bench/apps/fundara/` and is tracked in a Git repository (GitHub: `masmaksum/Fundara`).

**Custom app code is NOT included in bench backup.** Recovery of app code is via `git clone` / `git checkout` to the pinned release tag. However, document the exact version (commit hash or tag) deployed at the time of each backup so you know which code version matches which data snapshot.

Record this in your backup log:
```
fundara_version=$(cd /home/frappe/frappe-bench/apps/fundara && git rev-parse HEAD)
```

### 1.5 Site Configuration Files

| File | Path |
|---|---|
| Per-site config | `/home/frappe/frappe-bench/sites/<site>/site_config.json` |
| Common config | `/home/frappe/frappe-bench/sites/common_site_config.json` |
| Apps list | `/home/frappe/frappe-bench/sites/<site>/apps.txt` |

`site_config.json` contains the database name, database password, Redis URLs, email settings, and custom configuration keys. **This file contains secrets.** Encrypt before storing remotely.

### 1.6 Nginx Configuration

Path: `/etc/nginx/conf.d/` and `/etc/nginx/sites-enabled/`

Frappe writes Nginx config via `bench setup nginx`. Back up the generated files so you can restore the web server configuration without re-running setup.

### 1.7 SSL Certificates

Path: `/etc/letsencrypt/`

Contains private keys and certificates for all domains. Back up this entire directory. Without it, you must re-issue certificates after a server rebuild (usually fast, but adds to RTO).

### 1.8 Cron Jobs

Two sources:
- **System cron** for the `frappe` user: `crontab -u frappe -l`
- **Bench scheduler**: managed by Supervisor, not cron — back up Supervisor config instead

Supervisor config path: `/etc/supervisor/conf.d/` (or wherever `bench setup supervisor` wrote it)

---

## 2. Backup Schedule

### 2.1 Database Backup Schedule

| Type | Frequency | Retention | Notes |
|---|---|---|---|
| Daily full dump | Every day at 02:00 | 14 daily copies | Per site, compressed |
| Weekly archive | Every Sunday at 03:00 | 8 weekly copies (2 months) | Separate retention bucket |
| Monthly archive | 1st of month at 04:00 | 12 monthly copies (1 year) | Long-term compliance archive |

Frappe does not support native incremental/differential dumps. For MariaDB binary log-based point-in-time recovery (PITR), enable `binlog` separately (see Section 5.5).

### 2.2 File Backup Schedule

| Type | Frequency | Retention |
|---|---|---|
| Private files | Daily at 02:30 | 14 copies |
| Public files | Daily at 02:45 | 7 copies |

Files change less frequently than the database. A daily file backup is sufficient for most NGO deployments.

### 2.3 Configuration Backup Schedule

| Type | Frequency | Retention |
|---|---|---|
| Site configs | Daily with DB backup | 14 copies |
| Nginx config | Weekly | 4 copies |
| SSL certificates | Weekly | 2 copies |
| Cron/Supervisor | Weekly | 4 copies |

### 2.4 Retention Policy Summary

```
Local (on-server):     3 days of daily backups
Remote daily:          14 days
Remote weekly:         8 weeks
Remote monthly:        12 months
```

Do not keep more than 3 days of backups on the production server itself — disk space is a finite resource and large backup files can fill the disk and crash the application.

---

## 3. Backup Destinations

### 3.1 Local Backup (Tier 1)

`bench backup` writes to: `/home/frappe/frappe-bench/sites/<site>/private/backups/`

Files are retained locally for 3 days for quick access. This is NOT a substitute for remote backup.

### 3.2 Remote S3-Compatible Storage (Tier 2 — Required)

Options ranked by cost for NGO deployments:

| Provider | Notes |
|---|---|
| Backblaze B2 | Cheapest (S3-compatible, ~$0.006/GB/month) |
| Wasabi | No egress fees, S3-compatible |
| MinIO (self-hosted) | Free if you have a second server or VPS |
| AWS S3 | More expensive, but reliable; use Glacier for monthly archives |
| Cloudflare R2 | Zero egress fees, S3-compatible |

Use `rclone` to upload to any of the above. Configure one remote named `fundara-backup`.

### 3.3 SFTP to Separate Server (Tier 2 alternative)

If S3-compatible storage is unavailable, rsync/SFTP to a second VPS works. Configure SSH key authentication. Ensure the backup server is in a different data center or provider than production.

### 3.4 Encryption Requirements

Fundara backups contain:
- Financial records (donor, grant, fund, GL entries)
- Beneficiary data
- Staff personal and salary data
- Contract and legal documents

**All backups transmitted or stored on remote storage MUST be encrypted.**

Encryption method: GPG symmetric encryption (AES-256) with a strong passphrase.

```bash
gpg --symmetric --cipher-algo AES256 --batch --passphrase-file /etc/fundara/backup.key backup.tar.gz
```

Store the passphrase in a secrets manager (Bitwarden, Vault, or at minimum a physically secured document). Loss of the passphrase = loss of all encrypted backups.

### 3.5 3-2-1 Rule Compliance

| Rule | Implementation |
|---|---|
| 3 copies | Local + Remote S3 + Monthly offsite archive |
| 2 different media | Server disk + Cloud object storage |
| 1 offsite | Cloud storage (different provider/region from server) |

---

## 4. Automated Backup Script

The complete backup script is at:

**`/home/bagong/Fundara/docs/infra/backup.sh`**

See that file for the full implementation. Summary of what it does:

1. Iterates over all Frappe sites in the bench
2. Runs `bench backup --with-files` for each site
3. Packages the database dump + files into a single `.tar.gz` archive
4. Encrypts with GPG symmetric encryption using a key file
5. Uploads to the configured rclone remote
6. Purges local backups older than the retention period
7. Logs all operations with timestamps to `/var/log/fundara-backup.log`
8. Sends a notification (webhook or email) on completion or failure

**Cron entry (as `frappe` user):**

```cron
# Daily backup at 02:00
0 2 * * * /home/frappe/fundara-backup.sh >> /var/log/fundara-backup.log 2>&1

# Weekly archive on Sunday at 03:00 (set BACKUP_TYPE=weekly in environment)
0 3 * * 0 BACKUP_TYPE=weekly /home/frappe/fundara-backup.sh >> /var/log/fundara-backup.log 2>&1

# Monthly archive on 1st at 04:00
0 4 1 * * BACKUP_TYPE=monthly /home/frappe/fundara-backup.sh >> /var/log/fundara-backup.log 2>&1
```

---

## 5. Recovery Procedures

### Prerequisites for All Restore Procedures

Before starting any restore:

- [ ] Identify the backup file to restore (date, site name, type)
- [ ] Confirm the backup file decrypts successfully: `gpg --decrypt backup.tar.gz.gpg | tar -tzf -`
- [ ] Notify stakeholders that a restore is in progress
- [ ] Document the incident: what failed, when, what data may be affected
- [ ] For production restores: get explicit approval from the system owner

---

### 5.1 Full Site Restore (Worst Case: Server Destroyed)

**Use case:** Production server is gone — hardware failure, provider issue, accidental deletion.

**Prerequisites:**
- A new Ubuntu 24.04.4 server is provisioned and SSH-accessible
- You have the backup archive file (from remote storage)
- You have the GPG passphrase / key file
- You have DNS access to point the domain to the new server

**Estimated time:** 2–4 hours for a typical NGO deployment

**Steps:**

1. **Provision and harden the new server** (if not already done):
   ```bash
   # On new server as root
   apt update && apt upgrade -y
   apt install -y git curl python3-dev python3-pip
   # Follow full Frappe/ERPNext installation guide
   ```

2. **Install Frappe bench and dependencies:**
   ```bash
   pip install frappe-bench
   bench init --frappe-branch version-16 frappe-bench
   cd frappe-bench
   bench get-app --branch version-16 erpnext
   bench get-app https://github.com/masmaksum/Fundara.git
   ```
   > Pin to the exact commit hash documented at backup time.

3. **Create a blank site:**
   ```bash
   bench new-site <site-name> --install-app erpnext --install-app fundara
   ```

4. **Download and decrypt the backup archive:**
   ```bash
   rclone copy fundara-backup:daily/<site>/<date>/ /tmp/restore/
   gpg --batch --passphrase-file /etc/fundara/backup.key \
       --decrypt /tmp/restore/backup.tar.gz.gpg > /tmp/restore/backup.tar.gz
   tar -xzf /tmp/restore/backup.tar.gz -C /tmp/restore/
   ```

5. **Restore the database:**
   ```bash
   cd /home/frappe/frappe-bench
   bench --site <site-name> restore /tmp/restore/<site>-database.sql.gz
   ```

6. **Restore private files:**
   ```bash
   cp -r /tmp/restore/private/files/* \
       /home/frappe/frappe-bench/sites/<site-name>/private/files/
   chown -R frappe:frappe /home/frappe/frappe-bench/sites/<site-name>/private/files/
   ```

7. **Restore public files:**
   ```bash
   cp -r /tmp/restore/public/files/* \
       /home/frappe/frappe-bench/sites/<site-name>/public/files/
   chown -R frappe:frappe /home/frappe/frappe-bench/sites/<site-name>/public/files/
   ```

8. **Restore site_config.json:**
   ```bash
   cp /tmp/restore/site_config.json \
       /home/frappe/frappe-bench/sites/<site-name>/site_config.json
   # Update db_host, redis_cache, redis_queue if they changed on the new server
   ```

9. **Run migrations:**
   ```bash
   bench --site <site-name> migrate
   ```

10. **Set up Nginx, Supervisor, SSL:**
    ```bash
    bench setup nginx
    bench setup supervisor
    sudo nginx -t && sudo systemctl reload nginx
    sudo supervisorctl reread && sudo supervisorctl update
    # Re-issue SSL cert:
    bench setup lets-encrypt <site-name>
    ```

11. **Update DNS** to point to the new server IP.

**Verification:**
- [ ] `bench --site <site-name> doctor` — no errors
- [ ] Log in as System Manager — confirm you reach the correct data
- [ ] Check a known recent transaction (e.g., last journal entry date)
- [ ] Verify file attachments open correctly
- [ ] Run `bench --site <site-name> scheduler status` — scheduler is active

**Rollback:** If restore fails at step 5 or later, the blank site is unharmed. Try a different backup date, or restore to a different site name for investigation.

---

### 5.2 Database-Only Restore (Data Corruption or Accidental Deletion)

**Use case:** A bulk operation corrupted records, or someone deleted a batch of documents. The server and files are intact.

**Prerequisites:**
- Production site is accessible (or put in maintenance mode)
- You know the approximate time the corruption occurred
- You have a backup from before the corruption event

**Estimated time:** 30–90 minutes

**Steps:**

1. **Put site in maintenance mode:**
   ```bash
   bench --site <site-name> set-maintenance-mode on
   ```

2. **Take a current backup before overwriting anything:**
   ```bash
   bench --site <site-name> backup
   ```
   > This is your safety net. If the restore makes things worse, you can re-restore from this point.

3. **Download and decrypt the target backup:**
   ```bash
   rclone copy fundara-backup:daily/<site>/<target-date>/ /tmp/restore/
   gpg --batch --passphrase-file /etc/fundara/backup.key \
       --decrypt /tmp/restore/backup.tar.gz.gpg > /tmp/restore/backup.tar.gz
   tar -xzf /tmp/restore/backup.tar.gz -C /tmp/restore/
   ```

4. **Stop background workers to prevent writes during restore:**
   ```bash
   sudo supervisorctl stop all
   ```

5. **Restore the database:**
   ```bash
   bench --site <site-name> restore /tmp/restore/<site>-database.sql.gz
   ```

6. **Run migrations (in case schema changed between backup and restore):**
   ```bash
   bench --site <site-name> migrate
   ```

7. **Restart workers and disable maintenance mode:**
   ```bash
   sudo supervisorctl start all
   bench --site <site-name> set-maintenance-mode off
   ```

**Verification:**
- [ ] Confirm the corrupted/deleted records are restored
- [ ] Confirm no newer legitimate records were lost (check the last transaction before the corruption event)
- [ ] If newer records are missing, proceed to Section 5.4 (single document restore) to recover them from the pre-restore backup taken in step 2

**Rollback:** Restore the backup taken in step 2.

---

### 5.3 File-Only Restore (Uploaded Files Lost, Database Intact)

**Use case:** The files directory was accidentally deleted or corrupted. The database is intact and records show correct attachment references.

**Prerequisites:**
- Database is healthy
- You know which site and approximately when the files were last known-good

**Estimated time:** 15–60 minutes (depending on total file size)

**Steps:**

1. **Identify which files are missing:**
   ```bash
   # List all file references in DB
   bench --site <site-name> execute frappe.client.get_list \
       --kwargs '{"doctype":"File","fields":["name","file_url","is_private"],"limit_page_length":0}' \
       > /tmp/file-list.json
   ```

2. **Download and decrypt the backup archive:**
   ```bash
   rclone copy fundara-backup:daily/<site>/<date>/ /tmp/restore/
   gpg --batch --passphrase-file /etc/fundara/backup.key \
       --decrypt /tmp/restore/backup.tar.gz.gpg > /tmp/restore/backup.tar.gz
   tar -xzf /tmp/restore/backup.tar.gz -C /tmp/restore/
   ```

3. **Restore private files:**
   ```bash
   # Merge, do not overwrite existing files
   rsync -av --ignore-existing /tmp/restore/private/files/ \
       /home/frappe/frappe-bench/sites/<site-name>/private/files/
   chown -R frappe:frappe /home/frappe/frappe-bench/sites/<site-name>/private/files/
   ```

4. **Restore public files:**
   ```bash
   rsync -av --ignore-existing /tmp/restore/public/files/ \
       /home/frappe/frappe-bench/sites/<site-name>/public/files/
   chown -R frappe:frappe /home/frappe/frappe-bench/sites/<site-name>/public/files/
   ```

**Verification:**
- [ ] Open a document with a known attachment — file loads correctly
- [ ] Check an evidence file from a Fund transaction
- [ ] Spot-check 5 random attachments from the file list

**Rollback:** No rollback needed — you merged, not replaced. Remove any incorrectly restored files manually.

---

### 5.4 Single Document Restore (One Record Deleted)

**Use case:** A single document (e.g., one Advance, one Journal Entry, one Grant record) was deleted and needs to be recovered without affecting any other live data.

**Prerequisites:**
- You know the document name (e.g., `ADV-2026-00123`)
- You have a backup from before the deletion

**Estimated time:** 30–60 minutes

**Steps:**

1. **Restore the backup database to a temporary separate database** (do not overwrite production):
   ```bash
   # Create a temp database
   mysql -u root -p -e "CREATE DATABASE fundara_restore_temp;"

   # Extract and restore to temp DB
   zcat /tmp/restore/<site>-database.sql.gz | \
       sed 's/`<original-db-name>`/`fundara_restore_temp`/g' | \
       mysql -u root -p fundara_restore_temp
   ```

2. **Query the deleted document from the temp database:**
   ```bash
   mysql -u root -p fundara_restore_temp -e \
       "SELECT * FROM \`tabAdvance\` WHERE name='ADV-2026-00123'\G"
   ```

3. **Export the specific record and related child table rows:**
   ```bash
   # Export to SQL insert statements
   mysql -u root -p fundara_restore_temp \
       --execute="SELECT * FROM \`tabAdvance\` WHERE name='ADV-2026-00123'" \
       --xml > /tmp/advance-record.xml
   # Repeat for any child DocType tables (e.g., tabAdvance Item)
   ```

4. **Carefully insert back into production:**
   ```bash
   # Review the data first, then insert
   # Use bench console for safe insertion:
   bench --site <site-name> console
   # Inside console:
   # doc = frappe.get_doc({...}) # construct from exported data
   # doc.insert(ignore_permissions=True)
   # frappe.db.commit()
   ```

5. **Drop the temp database when done:**
   ```bash
   mysql -u root -p -e "DROP DATABASE fundara_restore_temp;"
   ```

**Verification:**
- [ ] The document appears in the production system with correct data
- [ ] Related records (GL entries, linked documents) are consistent
- [ ] Run `bench --site <site-name> doctor` to confirm no integrity issues

---

### 5.5 Point-in-Time Recovery

**Use case:** You need to restore data to a specific timestamp, not just the last backup.

**Option A: MariaDB Binary Log (if enabled)**

Enable binary logging in `/etc/mysql/conf.d/mariadb.cnf`:
```ini
[mysqld]
log_bin = /var/log/mysql/mariadb-bin
expire_logs_days = 7
max_binlog_size = 100M
binlog_format = ROW
```

Restore procedure:
1. Restore the last full backup before the target timestamp (procedure 5.2)
2. Apply binary logs up to the target time:
   ```bash
   mysqlbinlog --stop-datetime="2026-06-18 14:30:00" \
       /var/log/mysql/mariadb-bin.000001 | \
       mysql -u root -p <database-name>
   ```

**Option B: Select from Nearest Backup**

If binary logging is not enabled, PITR means restoring the closest daily backup before the target time, accepting data loss from that point until now. This is the expected mode for most NGO MVP deployments.

**Estimated additional data loss vs full restore:** Up to 24 hours (daily backup RPO).

---

## 6. RTO and RPO Targets

### 6.1 Definitions

- **RPO (Recovery Point Objective):** The maximum acceptable data loss measured in time. If RPO = 24h, you can accept losing up to 24 hours of data.
- **RTO (Recovery Time Objective):** The maximum acceptable downtime. If RTO = 4h, the system must be restored within 4 hours of a failure.

### 6.2 Recommended Targets for Fundara MVP

| Deployment Profile | RPO | RTO | Notes |
|---|---|---|---|
| Profile A — Community/Demo | 24 hours | 8 hours | Daily backup, manual restore |
| Profile B — Small NGO | 24 hours | 4 hours | Daily backup, documented runbook |
| Profile C — Medium NGO | 4 hours | 2 hours | 6-hourly backup + file sync |
| Profile D — Hosted SaaS | 1 hour | 1 hour | Frequent backup + standby server |

For MVP (Profile B), the recommended targets are:

```
RPO: 24 hours  (daily backup)
RTO: 4 hours   (with this runbook and a provisioned standby server image)
```

### 6.3 How Backup Schedule Maps to RPO

| RPO Target | Required Backup Frequency |
|---|---|
| 24 hours | Daily backup at 02:00 |
| 4 hours | Backup every 4 hours (6x/day) |
| 1 hour | Hourly backup + binary log streaming |
| < 1 hour | MariaDB replication + binary log + standby server |

For daily backups: if production fails at 23:59, you lose up to ~22 hours of data (from 02:00 backup). This is acceptable for MVP but should be reviewed as the organization's data volume and compliance requirements grow.

---

## 7. Backup Testing

### 7.1 Monthly Restore Drill Procedure

Backup that is never tested is not a backup. Run this drill every month.

**Drill target:** A staging server or a separate test VM — never test restores on production.

**Drill steps:**

1. **Select a backup to test:**
   - Pick the most recent weekly backup
   - Confirm the file exists in remote storage: `rclone ls fundara-backup:weekly/<site>/`

2. **Verify file integrity:**
   ```bash
   gpg --batch --passphrase-file /etc/fundara/backup.key \
       --decrypt backup.tar.gz.gpg > /dev/null
   echo "Exit code: $?"  # Must be 0
   ```

3. **Restore to staging server:**
   - Follow procedure 5.1 (Full Site Restore) on the staging server
   - Use a test site name, e.g., `fundara-drill-YYYYMMDD`

4. **Verify data integrity:**
   ```bash
   bench --site fundara-drill-YYYYMMDD doctor
   bench --site fundara-drill-YYYYMMDD run-tests --app fundara
   ```

5. **Spot-check business data:**
   - Log in as a test user (System Manager role)
   - Confirm the most recent Fund Balance Snapshot is present
   - Confirm at least one Advance and its Liquidation are linked correctly
   - Open one Evidence file attachment — confirm it loads
   - Run one Donor Financial Report — confirm it generates

6. **Measure restore time** — record it in the test log below

7. **Clean up:**
   ```bash
   bench drop-site fundara-drill-YYYYMMDD --force
   ```

### 7.2 What to Test and How to Verify

| Test | Pass Criteria |
|---|---|
| GPG decryption | Exit code 0, no errors |
| Archive extraction | All expected files present |
| Database restore | `bench doctor` exits cleanly |
| Schema migration | `bench migrate` completes without errors |
| File attachment access | Evidence file opens in browser |
| Report generation | Donor Financial Report renders |
| Login | System Manager can log in |
| Background jobs | Scheduler shows as active |
| Restore time | Under the target RTO |

### 7.3 Drill Log Template

```
FUNDARA BACKUP RESTORE DRILL LOG
=================================
Date:               _______________
Conducted by:       _______________
Backup date tested: _______________
Backup file:        _______________
Target server:      _______________

Decryption check:   PASS / FAIL
Extraction check:   PASS / FAIL
DB restore:         PASS / FAIL  — Time: _____ min
File restore:       PASS / FAIL  — Time: _____ min
Migrations:         PASS / FAIL
Login check:        PASS / FAIL
Report check:       PASS / FAIL
Attachment check:   PASS / FAIL

Total restore time: _____ min
RTO target met:     YES / NO

Issues found:
_______________________________________________

Actions required:
_______________________________________________

Sign-off: _______________  Date: _______________
```

Store completed drill logs in `/home/bagong/Fundara/docs/infra/drill-logs/`.

---

## Appendix A: Backup File Naming Convention

```
<site-name>_<YYYYMMDD>_<HHMMSS>_<type>.tar.gz.gpg

Examples:
  fundara-ngo-a_20260618_020015_daily.tar.gz.gpg
  fundara-ngo-a_20260615_030000_weekly.tar.gz.gpg
  fundara-ngo-a_20260601_040000_monthly.tar.gz.gpg
```

---

## Appendix B: Key File Locations Reference

| Item | Path |
|---|---|
| Bench root | `/home/frappe/frappe-bench/` |
| Sites directory | `/home/frappe/frappe-bench/sites/` |
| Site config | `/home/frappe/frappe-bench/sites/<site>/site_config.json` |
| Common config | `/home/frappe/frappe-bench/sites/common_site_config.json` |
| Private files | `/home/frappe/frappe-bench/sites/<site>/private/files/` |
| Public files | `/home/frappe/frappe-bench/sites/<site>/public/files/` |
| Local backups | `/home/frappe/frappe-bench/sites/<site>/private/backups/` |
| Nginx config | `/etc/nginx/conf.d/` |
| SSL certs | `/etc/letsencrypt/` |
| Supervisor config | `/etc/supervisor/conf.d/` |
| Backup log | `/var/log/fundara-backup.log` |
| GPG key file | `/etc/fundara/backup.key` |
| Backup script | `/home/frappe/fundara-backup.sh` |
