#!/usr/bin/env bash
# =============================================================================
# Fundara Monitoring Setup Script
# =============================================================================
# Installs and configures:
#   - Netdata (system + application monitoring + alerting)
#   - Uptime Kuma (uptime/HTTP monitoring, via Docker)
#   - MariaDB slow query log
#   - Logrotate for Frappe logs
#
# Tested on: Ubuntu Server 24.04.4 LTS
#
# Usage:
#   sudo ./setup-monitoring.sh
#
# Options (set as env vars before running):
#   SKIP_NETDATA=1       Skip Netdata installation
#   SKIP_UPTIME_KUMA=1   Skip Uptime Kuma installation
#   TELEGRAM_BOT_TOKEN   Telegram bot token for alerts
#   TELEGRAM_CHAT_ID     Telegram group chat ID (negative for groups)
#   ALERT_EMAIL          Email address for alert notifications
#   BENCH_PATH           Path to frappe-bench (default: /home/frappe/frappe-bench)
#   MONITORING_DOMAIN    Optional domain for Uptime Kuma (e.g., status.yourorg.org)
# =============================================================================

set -euo pipefail

# ---------------------------------------------------------------------------
# CONFIGURATION
# ---------------------------------------------------------------------------

BENCH_PATH="${BENCH_PATH:-/home/frappe/frappe-bench}"
FRAPPE_USER="frappe"
TELEGRAM_BOT_TOKEN="${TELEGRAM_BOT_TOKEN:-}"
TELEGRAM_CHAT_ID="${TELEGRAM_CHAT_ID:-}"
ALERT_EMAIL="${ALERT_EMAIL:-}"
MONITORING_DOMAIN="${MONITORING_DOMAIN:-}"
UPTIME_KUMA_PORT=3001
NETDATA_CONFIG_DIR="/etc/netdata"
UPTIME_KUMA_DATA_DIR="/opt/uptime-kuma"

SKIP_NETDATA="${SKIP_NETDATA:-0}"
SKIP_UPTIME_KUMA="${SKIP_UPTIME_KUMA:-0}"

LOG_PREFIX="[$(date '+%Y-%m-%d %H:%M:%S')]"

# ---------------------------------------------------------------------------
# HELPERS
# ---------------------------------------------------------------------------

log() { echo "${LOG_PREFIX} $*"; }
log_section() { echo ""; echo "=== $* ==="; }
require_root() {
    if [[ "$EUID" -ne 0 ]]; then
        echo "This script must be run as root (sudo)."
        exit 1
    fi
}
confirm() {
    read -r -p "$1 [y/N] " response
    [[ "$response" =~ ^[Yy]$ ]]
}

# ---------------------------------------------------------------------------
# SECTION 1: System prerequisites
# ---------------------------------------------------------------------------

install_prerequisites() {
    log_section "Installing prerequisites"
    apt-get update -qq
    apt-get install -y -qq \
        curl \
        wget \
        git \
        jq \
        logrotate \
        ca-certificates \
        gnupg \
        lsb-release
    log "Prerequisites installed."
}

# ---------------------------------------------------------------------------
# SECTION 2: Netdata
# ---------------------------------------------------------------------------

install_netdata() {
    log_section "Installing Netdata"

    if command -v netdata &>/dev/null; then
        log "Netdata is already installed. Skipping installation."
        return
    fi

    log "Downloading and running Netdata kickstart..."
    wget -O /tmp/netdata-kickstart.sh https://get.netdata.cloud/kickstart.sh
    bash /tmp/netdata-kickstart.sh --non-interactive --stable-channel \
        --disable-telemetry \
        2>&1 | tail -20
    rm -f /tmp/netdata-kickstart.sh

    systemctl enable netdata
    systemctl start netdata
    log "Netdata installed and started."
    log "Dashboard available at: http://$(hostname -I | awk '{print $1}'):19999"
}

configure_netdata_alerts() {
    log_section "Configuring Netdata alerts"

    # Backup original notify config
    if [[ -f "${NETDATA_CONFIG_DIR}/health_alarm_notify.conf" ]]; then
        cp "${NETDATA_CONFIG_DIR}/health_alarm_notify.conf" \
           "${NETDATA_CONFIG_DIR}/health_alarm_notify.conf.bak.$(date +%Y%m%d)"
    fi

    # Configure Telegram if token is provided
    if [[ -n "$TELEGRAM_BOT_TOKEN" && -n "$TELEGRAM_CHAT_ID" ]]; then
        log "Configuring Telegram alerts..."
        sed -i "s/^SEND_TELEGRAM=.*/SEND_TELEGRAM=\"YES\"/" \
            "${NETDATA_CONFIG_DIR}/health_alarm_notify.conf" || true

        if ! grep -q "^SEND_TELEGRAM=" "${NETDATA_CONFIG_DIR}/health_alarm_notify.conf"; then
            echo 'SEND_TELEGRAM="YES"' >> "${NETDATA_CONFIG_DIR}/health_alarm_notify.conf"
        fi

        # Set the bot token and chat ID
        cat >> "${NETDATA_CONFIG_DIR}/health_alarm_notify.conf" << EOF

# Fundara Telegram configuration
TELEGRAM_BOT_TOKEN="${TELEGRAM_BOT_TOKEN}"
DEFAULT_RECIPIENT_TELEGRAM="${TELEGRAM_CHAT_ID}"
EOF
        log "Telegram alerts configured."
    else
        log "No Telegram token provided. Skipping Telegram alert configuration."
        log "To configure later: edit ${NETDATA_CONFIG_DIR}/health_alarm_notify.conf"
    fi

    # Configure email if provided
    if [[ -n "$ALERT_EMAIL" ]]; then
        log "Configuring email alerts to: ${ALERT_EMAIL}..."
        sed -i "s/^SEND_EMAIL=.*/SEND_EMAIL=\"YES\"/" \
            "${NETDATA_CONFIG_DIR}/health_alarm_notify.conf" || true

        if ! grep -q "^SEND_EMAIL=" "${NETDATA_CONFIG_DIR}/health_alarm_notify.conf"; then
            echo 'SEND_EMAIL="YES"' >> "${NETDATA_CONFIG_DIR}/health_alarm_notify.conf"
        fi

        sed -i "s/^DEFAULT_RECIPIENT_EMAIL=.*/DEFAULT_RECIPIENT_EMAIL=\"${ALERT_EMAIL}\"/" \
            "${NETDATA_CONFIG_DIR}/health_alarm_notify.conf" || true

        log "Email alerts configured."
    fi

    # Install custom Fundara health alert rules
    install_fundara_alert_rules

    # Restart Netdata to apply configuration
    systemctl restart netdata
    log "Netdata alert configuration complete."
}

install_fundara_alert_rules() {
    log "Installing custom Fundara alert rules..."

    cat > "${NETDATA_CONFIG_DIR}/health.d/fundara.conf" << 'EOF'
# Fundara Custom Alert Rules
# These supplement Netdata's built-in alerts with Fundara-specific thresholds

# ---------------------------------------------------------------------------
# Disk space — alert early, Frappe crashes silently when disk fills
# ---------------------------------------------------------------------------
alarm: fundara_disk_warning
  on: disk.space
  lookup: average -10m unaligned of used
  units: %
  every: 1m
  warn: $this > 75
  crit: $this > 88
  info: Disk usage is high. Fundara private files and backups may fill disk quickly.
  delay: up 5m down 15m multiplier 1.5 max 2h

# ---------------------------------------------------------------------------
# System load
# ---------------------------------------------------------------------------
alarm: fundara_system_load
  on: system.load
  lookup: average -5m unaligned of load1
  every: 1m
  warn: $this > (($system_cores) * 1.0)
  crit: $this > (($system_cores) * 2.0)
  info: System load average is high. Web workers may become unresponsive.
  delay: up 3m down 10m

# ---------------------------------------------------------------------------
# RAM pressure
# ---------------------------------------------------------------------------
alarm: fundara_ram_usage
  on: system.ram
  lookup: average -5m unaligned of used,buffers,cached
  units: %
  every: 1m
  warn: $this > 85
  crit: $this > 95
  info: RAM usage is critical. MariaDB or Redis may start evicting data.
  delay: up 3m down 10m

# ---------------------------------------------------------------------------
# Nginx — watch for upstream failures (502/503 from Frappe workers)
# ---------------------------------------------------------------------------
alarm: fundara_nginx_errors
  on: nginx.requests
  lookup: sum -5m unaligned of requests
  every: 5m
  info: Nginx is not receiving any requests. May indicate it is down.

# ---------------------------------------------------------------------------
# Supervisor processes — alert if any Frappe process stops
# ---------------------------------------------------------------------------
# Note: Netdata monitors supervisor via python.d/supervisord.d plugin
# Ensure /etc/netdata/python.d/supervisord.conf is configured if using python.d

EOF

    log "Custom alert rules written to ${NETDATA_CONFIG_DIR}/health.d/fundara.conf"
}

configure_netdata_nginx_monitoring() {
    log "Configuring Nginx stub_status for Netdata monitoring..."

    local nginx_stub_conf="/etc/nginx/conf.d/stub_status.conf"
    if [[ ! -f "$nginx_stub_conf" ]]; then
        cat > "$nginx_stub_conf" << 'EOF'
# Nginx stub_status for Netdata monitoring
# Only accessible from localhost
server {
    listen 127.0.0.1:8080;
    location /nginx_status {
        stub_status;
        allow 127.0.0.1;
        deny all;
    }
}
EOF
        nginx -t && systemctl reload nginx
        log "Nginx stub_status configured at http://127.0.0.1:8080/nginx_status"
    else
        log "Nginx stub_status already configured."
    fi
}

# ---------------------------------------------------------------------------
# SECTION 3: Docker (required for Uptime Kuma)
# ---------------------------------------------------------------------------

install_docker() {
    log_section "Installing Docker"

    if command -v docker &>/dev/null; then
        log "Docker is already installed ($(docker --version))."
        return
    fi

    log "Installing Docker from official repository..."
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
        -o /etc/apt/keyrings/docker.asc
    chmod a+r /etc/apt/keyrings/docker.asc

    echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
        https://download.docker.com/linux/ubuntu \
        $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
        > /etc/apt/sources.list.d/docker.list

    apt-get update -qq
    apt-get install -y -qq docker-ce docker-ce-cli containerd.io docker-compose-plugin

    systemctl enable docker
    systemctl start docker
    log "Docker installed ($(docker --version))."
}

# ---------------------------------------------------------------------------
# SECTION 4: Uptime Kuma
# ---------------------------------------------------------------------------

install_uptime_kuma() {
    log_section "Installing Uptime Kuma"

    mkdir -p "$UPTIME_KUMA_DATA_DIR"

    # Create docker-compose file
    cat > "${UPTIME_KUMA_DATA_DIR}/docker-compose.yml" << EOF
version: "3.8"
services:
  uptime-kuma:
    image: louislam/uptime-kuma:1
    container_name: uptime-kuma
    restart: unless-stopped
    volumes:
      - ${UPTIME_KUMA_DATA_DIR}/data:/app/data
    ports:
      - "127.0.0.1:${UPTIME_KUMA_PORT}:3001"
    environment:
      - UPTIME_KUMA_PORT=3001
EOF

    log "Starting Uptime Kuma via Docker Compose..."
    docker compose -f "${UPTIME_KUMA_DATA_DIR}/docker-compose.yml" up -d

    log "Uptime Kuma started on port ${UPTIME_KUMA_PORT}."

    # Configure Nginx reverse proxy for Uptime Kuma
    configure_uptime_kuma_nginx
}

configure_uptime_kuma_nginx() {
    if [[ -n "$MONITORING_DOMAIN" ]]; then
        log "Configuring Nginx reverse proxy for Uptime Kuma at ${MONITORING_DOMAIN}..."

        cat > "/etc/nginx/conf.d/uptime-kuma.conf" << EOF
# Uptime Kuma status page
server {
    listen 80;
    server_name ${MONITORING_DOMAIN};

    location / {
        proxy_pass         http://127.0.0.1:${UPTIME_KUMA_PORT};
        proxy_http_version 1.1;
        proxy_set_header   Upgrade \$http_upgrade;
        proxy_set_header   Connection "upgrade";
        proxy_set_header   Host \$host;
        proxy_set_header   X-Real-IP \$remote_addr;
        proxy_set_header   X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header   X-Forwarded-Proto \$scheme;
        proxy_read_timeout 86400;
    }
}
EOF
        nginx -t && systemctl reload nginx
        log "Nginx configured for Uptime Kuma at http://${MONITORING_DOMAIN}"
        log "Run: certbot --nginx -d ${MONITORING_DOMAIN} to enable HTTPS"
    else
        log "No MONITORING_DOMAIN set. Uptime Kuma accessible at:"
        log "  http://$(hostname -I | awk '{print $1}'):${UPTIME_KUMA_PORT}"
        log "Set MONITORING_DOMAIN to configure a public URL with Nginx proxy."
    fi
}

print_uptime_kuma_monitors() {
    log_section "Uptime Kuma Monitor Configuration"
    log "After Uptime Kuma starts, create these monitors at:"
    log "  http://localhost:${UPTIME_KUMA_PORT}"
    echo ""
    echo "Recommended monitors to create manually in the Uptime Kuma UI:"
    echo ""
    echo "  1. Type: HTTP(s)"
    echo "     Name: Fundara App — <site-name>"
    echo "     URL: https://<site-name>/"
    echo "     Interval: 60 seconds"
    echo "     Expected Status: 200"
    echo ""
    echo "  2. Type: HTTP(s)"
    echo "     Name: Fundara API Ping — <site-name>"
    echo "     URL: https://<site-name>/api/method/ping"
    echo "     Interval: 60 seconds"
    echo "     Expected Status: 200"
    echo "     Keyword: pong"
    echo ""
    echo "  3. Type: HTTP(s)"
    echo "     Name: Fundara Health — <site-name>"
    echo "     URL: https://<site-name>/api/method/fundara.api.health"
    echo "     Interval: 60 seconds"
    echo "     Expected Status: 200"
    echo ""
    echo "  4. Type: TCP Port"
    echo "     Name: MariaDB Port"
    echo "     Host: 127.0.0.1"
    echo "     Port: 3306"
    echo "     Interval: 60 seconds"
    echo ""
    echo "  5. Type: TCP Port"
    echo "     Name: Redis Port"
    echo "     Host: 127.0.0.1"
    echo "     Port: 6379"
    echo "     Interval: 60 seconds"
    echo ""
}

# ---------------------------------------------------------------------------
# SECTION 5: MariaDB slow query log
# ---------------------------------------------------------------------------

configure_mariadb_slow_query_log() {
    log_section "Configuring MariaDB slow query log"

    local mariadb_conf="/etc/mysql/conf.d/fundara-monitoring.cnf"

    if [[ -f "$mariadb_conf" ]]; then
        log "MariaDB monitoring config already exists at ${mariadb_conf}. Skipping."
        return
    fi

    cat > "$mariadb_conf" << 'EOF'
# Fundara MariaDB monitoring configuration
[mysqld]
# Slow query log — queries slower than 2 seconds are logged
slow_query_log = 1
slow_query_log_file = /var/log/mysql/mariadb-slow.log
long_query_time = 2
log_queries_not_using_indexes = 0

# Binary log — enables point-in-time recovery (optional but recommended)
# Uncomment the following lines to enable PITR capability:
# log_bin = /var/log/mysql/mariadb-bin
# expire_logs_days = 7
# max_binlog_size = 100M
# binlog_format = ROW

# Performance schema — enables query analysis
performance_schema = ON
EOF

    # Create the slow query log file with correct permissions
    touch /var/log/mysql/mariadb-slow.log
    chown mysql:mysql /var/log/mysql/mariadb-slow.log
    chmod 640 /var/log/mysql/mariadb-slow.log

    systemctl restart mariadb
    log "MariaDB slow query log enabled at /var/log/mysql/mariadb-slow.log"
    log "Queries slower than 2 seconds will be logged."
}

# ---------------------------------------------------------------------------
# SECTION 6: Log rotation for Frappe
# ---------------------------------------------------------------------------

configure_logrotate() {
    log_section "Configuring log rotation"

    cat > "/etc/logrotate.d/frappe-fundara" << EOF
# Frappe/Fundara log rotation
${BENCH_PATH}/logs/*.log {
    daily
    missingok
    rotate 14
    compress
    delaycompress
    notifempty
    copytruncate
    su ${FRAPPE_USER} ${FRAPPE_USER}
}

/var/log/fundara-backup.log {
    weekly
    missingok
    rotate 8
    compress
    delaycompress
    notifempty
    copytruncate
}
EOF

    log "Logrotate configured for Frappe logs."
    log "Configuration written to /etc/logrotate.d/frappe-fundara"

    # Test logrotate config
    logrotate --debug /etc/logrotate.d/frappe-fundara 2>&1 | head -20
}

# ---------------------------------------------------------------------------
# SECTION 7: GPG key setup for backup script
# ---------------------------------------------------------------------------

setup_backup_key_dir() {
    log_section "Setting up backup encryption key directory"

    if [[ ! -d /etc/fundara ]]; then
        mkdir -p /etc/fundara
        chmod 750 /etc/fundara
        chown root:"${FRAPPE_USER}" /etc/fundara
    fi

    if [[ ! -f /etc/fundara/backup.key ]]; then
        log "WARNING: No GPG backup key found at /etc/fundara/backup.key"
        log "Create it with:"
        echo ""
        echo "    echo 'your-very-strong-passphrase-here' > /etc/fundara/backup.key"
        echo "    chmod 600 /etc/fundara/backup.key"
        echo "    chown ${FRAPPE_USER}:${FRAPPE_USER} /etc/fundara/backup.key"
        echo ""
        log "Store the passphrase securely in a password manager."
        log "Without this key, encrypted backups cannot be decrypted."
    else
        log "GPG backup key exists at /etc/fundara/backup.key"
        chmod 600 /etc/fundara/backup.key
        chown "${FRAPPE_USER}":"${FRAPPE_USER}" /etc/fundara/backup.key
        log "Permissions set correctly."
    fi
}

# ---------------------------------------------------------------------------
# SECTION 8: Summary and next steps
# ---------------------------------------------------------------------------

print_summary() {
    log_section "Setup Complete — Next Steps"

    echo ""
    echo "WHAT WAS INSTALLED:"
    [[ "$SKIP_NETDATA" != "1" ]] && echo "  - Netdata: http://$(hostname -I | awk '{print $1}'):19999"
    [[ "$SKIP_UPTIME_KUMA" != "1" ]] && echo "  - Uptime Kuma: http://$(hostname -I | awk '{print $1}'):${UPTIME_KUMA_PORT}"
    echo "  - MariaDB slow query log: /var/log/mysql/mariadb-slow.log"
    echo "  - Logrotate config: /etc/logrotate.d/frappe-fundara"
    echo ""
    echo "NEXT STEPS:"
    echo ""
    echo "1. Netdata alerts:"
    echo "   Edit ${NETDATA_CONFIG_DIR}/health_alarm_notify.conf"
    echo "   Test: /usr/libexec/netdata/plugins.d/alarm-notify.sh test"
    echo ""
    echo "2. Uptime Kuma:"
    echo "   Open Uptime Kuma UI and create monitors (see list above)"
    echo "   Set up notification channels (Telegram/email) in Uptime Kuma settings"
    echo ""
    echo "3. Backup script:"
    echo "   Install: cp /home/bagong/Fundara/docs/infra/backup.sh /home/frappe/fundara-backup.sh"
    echo "   Permissions: chmod 750 /home/frappe/fundara-backup.sh && chown frappe:frappe /home/frappe/fundara-backup.sh"
    echo "   Configure rclone: sudo -u frappe rclone config"
    echo "   Set GPG key: echo 'your-passphrase' > /etc/fundara/backup.key && chmod 600 /etc/fundara/backup.key"
    echo "   Add cron: crontab -u frappe -e"
    echo "     0 2 * * * /home/frappe/fundara-backup.sh >> /var/log/fundara-backup.log 2>&1"
    echo ""
    echo "4. Custom health endpoint:"
    echo "   Implement fundara.api.health in apps/fundara/fundara/api.py"
    echo "   See: docs/infra/monitoring-spec.md Section 7.2"
    echo ""
    echo "5. SSL for monitoring domain (if configured):"
    echo "   certbot --nginx -d ${MONITORING_DOMAIN:-status.yourorg.org}"
    echo ""
    echo "FIREWALL NOTE:"
    echo "   Do not expose Netdata port 19999 to the public internet."
    echo "   Use SSH tunneling or place it behind Nginx with authentication:"
    echo "     ssh -L 19999:localhost:19999 user@your-server"
    echo ""
}

# ---------------------------------------------------------------------------
# MAIN
# ---------------------------------------------------------------------------

main() {
    require_root

    log "==================================================="
    log "Fundara Monitoring Setup"
    log "==================================================="
    log "Server: $(hostname)"
    log "OS: $(lsb_release -ds 2>/dev/null || uname -a)"
    log "Date: $(date)"
    log ""

    install_prerequisites

    if [[ "$SKIP_NETDATA" != "1" ]]; then
        install_netdata
        configure_netdata_nginx_monitoring
        configure_netdata_alerts
    else
        log "Skipping Netdata installation (SKIP_NETDATA=1)"
    fi

    if [[ "$SKIP_UPTIME_KUMA" != "1" ]]; then
        install_docker
        install_uptime_kuma
        print_uptime_kuma_monitors
    else
        log "Skipping Uptime Kuma installation (SKIP_UPTIME_KUMA=1)"
    fi

    configure_mariadb_slow_query_log
    configure_logrotate
    setup_backup_key_dir

    print_summary

    log "==================================================="
    log "Monitoring setup completed."
    log "==================================================="
}

main "$@"
