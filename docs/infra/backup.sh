#!/usr/bin/env bash
# =============================================================================
# Fundara Production Backup Script
# =============================================================================
# Usage:
#   ./backup.sh                    # daily backup (default)
#   BACKUP_TYPE=weekly ./backup.sh # weekly archive
#   BACKUP_TYPE=monthly ./backup.sh # monthly archive
#
# Cron (as frappe user):
#   0 2 * * *   /home/frappe/fundara-backup.sh >> /var/log/fundara-backup.log 2>&1
#   0 3 * * 0   BACKUP_TYPE=weekly /home/frappe/fundara-backup.sh >> /var/log/fundara-backup.log 2>&1
#   0 4 1 * *   BACKUP_TYPE=monthly /home/frappe/fundara-backup.sh >> /var/log/fundara-backup.log 2>&1
#
# Requirements:
#   - rclone configured with a remote named $RCLONE_REMOTE
#   - gpg installed
#   - GPG passphrase stored in $GPG_KEY_FILE (chmod 600, owned by frappe)
#   - bench CLI available at $BENCH_PATH
#   - Notification webhook or SMTP configured below
# =============================================================================

set -euo pipefail

# ---------------------------------------------------------------------------
# CONFIGURATION — edit these values for your deployment
# ---------------------------------------------------------------------------

BENCH_PATH="/home/frappe/frappe-bench"
BACKUP_TYPE="${BACKUP_TYPE:-daily}"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
LOG_PREFIX="[$(date '+%Y-%m-%d %H:%M:%S')]"

# GPG encryption
GPG_KEY_FILE="/etc/fundara/backup.key"   # chmod 600, owned by frappe

# rclone remote and destination bucket/path
RCLONE_REMOTE="fundara-backup"           # name of configured rclone remote
RCLONE_BASE_PATH="backups"              # path inside the remote

# Local retention (days)
LOCAL_RETENTION_DAYS=3

# Remote retention (days per backup type)
REMOTE_RETENTION_DAILY=14
REMOTE_RETENTION_WEEKLY=56              # 8 weeks
REMOTE_RETENTION_MONTHLY=365           # 12 months

# Notification (set one method; leave others empty to disable)
NOTIFY_WEBHOOK_URL=""                   # e.g., https://hooks.slack.com/... or Telegram
NOTIFY_EMAIL_TO=""                      # e.g., ops@yourorg.org
NOTIFY_EMAIL_FROM="backup@yourorg.org"

# Temp directory for staging backups before upload
STAGING_DIR="/tmp/fundara-backup-staging"

# ---------------------------------------------------------------------------
# FUNCTIONS
# ---------------------------------------------------------------------------

log() {
    echo "${LOG_PREFIX} $*"
}

log_error() {
    echo "${LOG_PREFIX} [ERROR] $*" >&2
}

notify() {
    local status="$1"
    local message="$2"

    if [[ -n "$NOTIFY_WEBHOOK_URL" ]]; then
        local payload
        payload=$(printf '{"text": "Fundara Backup %s: %s"}' "$status" "$message")
        curl -s -X POST -H 'Content-type: application/json' \
            --data "$payload" "$NOTIFY_WEBHOOK_URL" || true
    fi

    if [[ -n "$NOTIFY_EMAIL_TO" ]]; then
        echo "$message" | mail -s "Fundara Backup ${status} — $(hostname) — ${TIMESTAMP}" \
            -r "$NOTIFY_EMAIL_FROM" "$NOTIFY_EMAIL_TO" || true
    fi
}

check_prerequisites() {
    log "Checking prerequisites..."

    if [[ ! -f "$GPG_KEY_FILE" ]]; then
        log_error "GPG key file not found: $GPG_KEY_FILE"
        log_error "Create it: echo 'your-strong-passphrase' > $GPG_KEY_FILE && chmod 600 $GPG_KEY_FILE"
        exit 1
    fi

    if [[ "$(stat -c '%a' "$GPG_KEY_FILE")" != "600" ]]; then
        log_error "GPG key file has insecure permissions. Run: chmod 600 $GPG_KEY_FILE"
        exit 1
    fi

    for cmd in gpg rclone bench tar gzip; do
        if ! command -v "$cmd" &>/dev/null; then
            log_error "Required command not found: $cmd"
            exit 1
        fi
    done

    if ! rclone lsd "${RCLONE_REMOTE}:" &>/dev/null; then
        log_error "rclone remote '${RCLONE_REMOTE}' is not accessible. Run: rclone listremotes"
        exit 1
    fi

    log "Prerequisites OK."
}

get_sites() {
    # List all active sites in the bench (directories with site_config.json)
    find "${BENCH_PATH}/sites" -maxdepth 1 -mindepth 1 -type d \
        -not -name "assets" \
        | while read -r site_dir; do
            if [[ -f "${site_dir}/site_config.json" ]]; then
                basename "$site_dir"
            fi
        done
}

backup_site() {
    local site="$1"
    local site_staging="${STAGING_DIR}/${site}_${TIMESTAMP}"

    log "--- Starting backup for site: ${site} ---"
    mkdir -p "$site_staging"

    # Step 1: bench backup --with-files
    log "Running bench backup --with-files for ${site}..."
    cd "$BENCH_PATH"
    bench --site "$site" backup --with-files --backup-path "$site_staging" 2>&1 \
        || { log_error "bench backup failed for site ${site}"; return 1; }

    # Step 2: Copy site_config.json (contains DB credentials — handle with care)
    log "Backing up site_config.json for ${site}..."
    cp "${BENCH_PATH}/sites/${site}/site_config.json" "${site_staging}/site_config.json"

    # Step 3: Record the deployed app versions (code audit trail)
    log "Recording app versions for ${site}..."
    {
        echo "Backup timestamp: ${TIMESTAMP}"
        echo "Site: ${site}"
        echo "Backup type: ${BACKUP_TYPE}"
        echo ""
        echo "App versions at backup time:"
        for app_dir in "${BENCH_PATH}/apps"/*/; do
            app_name=$(basename "$app_dir")
            app_commit=$(cd "$app_dir" && git rev-parse HEAD 2>/dev/null || echo "not-a-git-repo")
            echo "  ${app_name}: ${app_commit}"
        done
    } > "${site_staging}/backup-manifest.txt"

    # Step 4: Compress the staging directory
    local archive_name="${site}_${TIMESTAMP}_${BACKUP_TYPE}.tar.gz"
    local archive_path="${STAGING_DIR}/${archive_name}"

    log "Compressing backup archive: ${archive_name}..."
    tar -czf "$archive_path" -C "$STAGING_DIR" "$(basename "$site_staging")" \
        || { log_error "Compression failed for site ${site}"; return 1; }

    # Step 5: Encrypt with GPG
    local encrypted_path="${archive_path}.gpg"
    log "Encrypting backup: ${archive_name}.gpg..."
    gpg --batch \
        --yes \
        --symmetric \
        --cipher-algo AES256 \
        --passphrase-file "$GPG_KEY_FILE" \
        --output "$encrypted_path" \
        "$archive_path" \
        || { log_error "GPG encryption failed for site ${site}"; return 1; }

    # Remove unencrypted archive immediately after encryption
    rm -f "$archive_path"

    # Step 6: Upload to remote storage
    local remote_path="${RCLONE_REMOTE}:${RCLONE_BASE_PATH}/${BACKUP_TYPE}/${site}/"
    log "Uploading to remote: ${remote_path}..."
    rclone copy "$encrypted_path" "$remote_path" \
        --progress \
        --stats-one-line \
        2>&1 \
        || { log_error "rclone upload failed for site ${site}"; return 1; }

    log "Upload complete: ${archive_name}.gpg -> ${remote_path}"

    # Step 7: Verify remote file exists
    if ! rclone ls "${remote_path}$(basename "$encrypted_path")" &>/dev/null; then
        log_error "Remote verification failed — file not found after upload: ${remote_path}$(basename "$encrypted_path")"
        return 1
    fi
    log "Remote verification OK."

    # Step 8: Clean up staging
    rm -rf "$site_staging" "$encrypted_path"

    log "--- Backup completed for site: ${site} ---"
    return 0
}

backup_configs() {
    log "--- Backing up server configs ---"
    local config_staging="${STAGING_DIR}/server-configs_${TIMESTAMP}"
    mkdir -p "$config_staging"

    # common_site_config.json
    cp "${BENCH_PATH}/sites/common_site_config.json" \
        "${config_staging}/common_site_config.json" 2>/dev/null || true

    # Nginx config
    mkdir -p "${config_staging}/nginx"
    cp -r /etc/nginx/conf.d/ "${config_staging}/nginx/" 2>/dev/null || true
    cp -r /etc/nginx/sites-enabled/ "${config_staging}/nginx/" 2>/dev/null || true

    # Supervisor config
    mkdir -p "${config_staging}/supervisor"
    cp -r /etc/supervisor/conf.d/ "${config_staging}/supervisor/" 2>/dev/null || true

    # Cron jobs for frappe user
    crontab -u frappe -l > "${config_staging}/frappe-crontab.txt" 2>/dev/null || true

    # SSL certificates (only metadata — private keys are sensitive)
    # Back up the full letsencrypt dir; it's encrypted at rest on this server
    # but will be encrypted in the archive too
    if [[ -d /etc/letsencrypt ]]; then
        cp -r /etc/letsencrypt "${config_staging}/letsencrypt" 2>/dev/null || true
    fi

    local config_archive="${STAGING_DIR}/server-configs_${TIMESTAMP}.tar.gz"
    tar -czf "$config_archive" -C "$STAGING_DIR" "$(basename "$config_staging")"
    rm -rf "$config_staging"

    # Encrypt
    local config_encrypted="${config_archive}.gpg"
    gpg --batch --yes --symmetric --cipher-algo AES256 \
        --passphrase-file "$GPG_KEY_FILE" \
        --output "$config_encrypted" \
        "$config_archive"
    rm -f "$config_archive"

    # Upload
    local remote_path="${RCLONE_REMOTE}:${RCLONE_BASE_PATH}/configs/"
    rclone copy "$config_encrypted" "$remote_path" 2>&1
    rm -f "$config_encrypted"

    log "Server config backup complete."
}

purge_local_backups() {
    log "Purging local backups older than ${LOCAL_RETENTION_DAYS} days..."
    local sites
    sites=$(get_sites)
    for site in $sites; do
        local backup_dir="${BENCH_PATH}/sites/${site}/private/backups"
        if [[ -d "$backup_dir" ]]; then
            find "$backup_dir" -type f -mtime "+${LOCAL_RETENTION_DAYS}" -delete
            log "Purged old local backups for site: ${site}"
        fi
    done
}

purge_remote_backups() {
    local retention_days
    case "$BACKUP_TYPE" in
        daily)   retention_days=$REMOTE_RETENTION_DAILY ;;
        weekly)  retention_days=$REMOTE_RETENTION_WEEKLY ;;
        monthly) retention_days=$REMOTE_RETENTION_MONTHLY ;;
        *)       retention_days=$REMOTE_RETENTION_DAILY ;;
    esac

    log "Purging remote ${BACKUP_TYPE} backups older than ${retention_days} days..."
    rclone delete \
        "${RCLONE_REMOTE}:${RCLONE_BASE_PATH}/${BACKUP_TYPE}/" \
        --min-age "${retention_days}d" \
        2>&1 || log_error "Remote purge had errors (non-fatal)"
}

# ---------------------------------------------------------------------------
# MAIN
# ---------------------------------------------------------------------------

main() {
    log "======================================================"
    log "Fundara Backup Started — type: ${BACKUP_TYPE}"
    log "======================================================"

    # Create staging directory
    mkdir -p "$STAGING_DIR"

    check_prerequisites

    local failed_sites=()
    local success_sites=()

    # Get list of sites and back up each one
    local sites
    sites=$(get_sites)

    if [[ -z "$sites" ]]; then
        log_error "No sites found in bench at ${BENCH_PATH}/sites/"
        notify "FAILED" "No sites found in bench. Check BENCH_PATH configuration."
        exit 1
    fi

    for site in $sites; do
        if backup_site "$site"; then
            success_sites+=("$site")
        else
            failed_sites+=("$site")
        fi
    done

    # Back up server configs on weekly and monthly runs, or daily if requested
    if [[ "$BACKUP_TYPE" == "weekly" || "$BACKUP_TYPE" == "monthly" ]]; then
        backup_configs || log_error "Config backup failed (non-fatal for site backups)"
    fi

    # Purge old backups
    purge_local_backups
    purge_remote_backups

    # Clean up staging directory
    rm -rf "$STAGING_DIR"

    log "======================================================"
    log "Backup Summary — ${BACKUP_TYPE} — ${TIMESTAMP}"
    log "Succeeded: ${success_sites[*]:-none}"
    log "Failed:    ${failed_sites[*]:-none}"
    log "======================================================"

    if [[ ${#failed_sites[@]} -gt 0 ]]; then
        notify "FAILED" "Backup FAILED for sites: ${failed_sites[*]}. Succeeded: ${success_sites[*]:-none}. Check /var/log/fundara-backup.log on $(hostname)."
        exit 1
    else
        notify "OK" "Backup succeeded for all sites: ${success_sites[*]}. Type: ${BACKUP_TYPE}. Timestamp: ${TIMESTAMP}."
        log "All backups completed successfully."
    fi
}

main "$@"
