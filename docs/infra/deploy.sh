#!/usr/bin/env bash
# =============================================================================
# deploy.sh — Fundara Deployment Script
# =============================================================================
# Skrip ini menyiapkan server Ubuntu 24.04 LTS baru dengan:
#   - System dependencies (git, python3, nodejs, mariadb, redis, nginx, dll.)
#   - Frappe Bench
#   - ERPNext v16
#   - Fundara custom app (github.com/masmaksum/Fundara)
#   - Konfigurasi Nginx dan Supervisor
#   - SSL opsional via Let's Encrypt
#   - Cron otomatis untuk backup bench
#
# Penggunaan:
#   1. Salin deploy-vars.example ke deploy-vars.sh dan sesuaikan nilainya.
#   2. source deploy-vars.sh
#   3. sudo bash deploy.sh
#
# Atau jalankan langsung (script akan meminta variabel yang belum diset):
#   sudo bash deploy.sh
#
# Lihat --help untuk opsi lebih lanjut.
# =============================================================================

set -euo pipefail
IFS=$'\n\t'

# =============================================================================
# Fungsi utilitas
# =============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info()    { echo -e "${BLUE}[INFO]${NC}  $*"; }
log_ok()      { echo -e "${GREEN}[OK]${NC}    $*"; }
log_warn()    { echo -e "${YELLOW}[WARN]${NC}  $*"; }
log_error()   { echo -e "${RED}[ERROR]${NC} $*" >&2; }
log_section() { echo -e "\n${GREEN}========================================${NC}"; \
                echo -e "${GREEN} $*${NC}"; \
                echo -e "${GREEN}========================================${NC}\n"; }

die() {
    log_error "$*"
    exit 1
}

# =============================================================================
# Flag --help
# =============================================================================

show_help() {
cat <<'HELPEOF'
Fundara Deployment Script
=========================

PENGGUNAAN:
  sudo bash deploy.sh [OPTIONS]

OPSI:
  --help          Tampilkan bantuan ini dan keluar.
  --skip-ssl      Lewati langkah SSL Let's Encrypt (berguna untuk server internal
                  atau jika SSL sudah dikonfigurasi terpisah).
  --dry-run       Cetak langkah-langkah tanpa menjalankannya (untuk review).

VARIABEL (set via deploy-vars.sh atau environment):
  SITE_NAME           Nama Frappe site (contoh: yayasanabc.fundara.id)
  ADMIN_PASSWORD      Password Administrator Frappe
  DB_ROOT_PASSWORD    Password root MariaDB
  BENCH_DIR           Direktori bench (default: /home/frappe/frappe-bench)
  FRAPPE_USER         User OS yang menjalankan bench (default: frappe)
  FRAPPE_BRANCH       Branch Frappe (default: version-16)
  ERPNEXT_BRANCH      Branch ERPNext (default: version-16)
  APP_NAME            Nama custom app (default: fundara)
  APP_REPO            URL repo custom app
  APP_BRANCH          Branch custom app (default: main)
  INSTALL_APPS        Daftar app yang di-install, dipisah spasi
  ENABLE_SSL          yes/no — aktifkan Let's Encrypt (default: no)
  SSL_EMAIL           Email untuk Let's Encrypt (wajib jika ENABLE_SSL=yes)
  GUNICORN_WORKERS    Jumlah gunicorn workers (default: 2)

LANGKAH YANG DIJALANKAN:
  1. Validasi prasyarat
  2. Install system dependencies
  3. Setup user OS 'frappe'
  4. Install MariaDB dan konfigurasi
  5. Install Redis
  6. Install Node.js, npm, yarn
  7. Install Frappe Bench (pip)
  8. Init bench dan install Frappe
  9. Install ERPNext
  10. Install Fundara custom app
  11. Buat site Frappe
  12. Konfigurasi production (Nginx + Supervisor)
  13. Setup SSL opsional
  14. Setup cron backup otomatis
  15. Tampilkan ringkasan instalasi

CONTOH:
  # Cara cepat (interaktif):
  sudo bash deploy.sh

  # Dengan variabel pre-set:
  source deploy-vars.sh && sudo bash deploy.sh

  # Tanpa SSL (server internal / staging):
  ENABLE_SSL=no sudo bash deploy.sh

HELPEOF
    exit 0
}

# =============================================================================
# Parse argumen
# =============================================================================

SKIP_SSL=false
DRY_RUN=false

for arg in "$@"; do
    case "$arg" in
        --help|-h)    show_help ;;
        --skip-ssl)   SKIP_SSL=true ;;
        --dry-run)    DRY_RUN=true ; log_warn "Mode dry-run: tidak ada perubahan yang akan dilakukan." ;;
        *)            log_warn "Argumen tidak dikenal: $arg — diabaikan." ;;
    esac
done

# =============================================================================
# Nilai default variabel
# =============================================================================

: "${FRAPPE_USER:=frappe}"
: "${BENCH_DIR:=/home/${FRAPPE_USER}/frappe-bench}"
: "${FRAPPE_BRANCH:=version-16}"
: "${ERPNEXT_BRANCH:=version-16}"
: "${APP_NAME:=fundara}"
: "${APP_REPO:=https://github.com/masmaksum/Fundara}"
: "${APP_BRANCH:=main}"
: "${INSTALL_APPS:=erpnext ${APP_NAME}}"
: "${ENABLE_SSL:=no}"
: "${GUNICORN_WORKERS:=2}"
: "${NODE_VERSION:=18}"

# =============================================================================
# Fungsi prompt variabel wajib yang belum diset
# =============================================================================

prompt_if_unset() {
    local var_name="$1"
    local prompt_msg="$2"
    local is_secret="${3:-no}"

    if [[ -z "${!var_name:-}" ]]; then
        if [[ "$is_secret" == "yes" ]]; then
            read -rsp "${prompt_msg}: " val
            echo
        else
            read -rp "${prompt_msg}: " val
        fi
        [[ -z "$val" ]] && die "Nilai untuk ${var_name} tidak boleh kosong."
        export "$var_name"="$val"
    fi
}

# =============================================================================
# Kumpulkan variabel wajib sebelum memulai instalasi
# =============================================================================

collect_required_vars() {
    log_section "Konfigurasi Deployment"
    log_info "Mengumpulkan variabel yang diperlukan..."

    prompt_if_unset SITE_NAME        "Nama site Frappe (contoh: yayasanabc.fundara.id)"
    prompt_if_unset ADMIN_PASSWORD   "Password Administrator Frappe" "yes"
    prompt_if_unset DB_ROOT_PASSWORD "Password root MariaDB" "yes"

    if [[ "$ENABLE_SSL" == "yes" ]] && [[ -z "${SSL_EMAIL:-}" ]]; then
        prompt_if_unset SSL_EMAIL "Email untuk registrasi SSL Let's Encrypt"
    fi

    echo
    log_info "Konfigurasi yang akan digunakan:"
    echo "  SITE_NAME        : ${SITE_NAME}"
    echo "  BENCH_DIR        : ${BENCH_DIR}"
    echo "  FRAPPE_USER      : ${FRAPPE_USER}"
    echo "  FRAPPE_BRANCH    : ${FRAPPE_BRANCH}"
    echo "  ERPNEXT_BRANCH   : ${ERPNEXT_BRANCH}"
    echo "  APP_NAME         : ${APP_NAME}"
    echo "  APP_REPO         : ${APP_REPO}"
    echo "  APP_BRANCH       : ${APP_BRANCH}"
    echo "  ENABLE_SSL       : ${ENABLE_SSL}"
    echo "  GUNICORN_WORKERS : ${GUNICORN_WORKERS}"
    echo "  NODE_VERSION     : ${NODE_VERSION}.x LTS"
    echo

    if [[ "$DRY_RUN" == "false" ]]; then
        read -rp "Lanjutkan instalasi? (yes/no): " confirm
        [[ "$confirm" == "yes" ]] || die "Instalasi dibatalkan oleh pengguna."
    fi
}

# =============================================================================
# Fungsi idempoten: jalankan perintah hanya jika kondisi belum terpenuhi
# =============================================================================

command_exists()  { command -v "$1" &>/dev/null; }
user_exists()     { id "$1" &>/dev/null; }
dir_exists()      { [[ -d "$1" ]]; }
file_exists()     { [[ -f "$1" ]]; }
site_exists()     { sudo -u "${FRAPPE_USER}" bash -c "cd '${BENCH_DIR}' && bench --site '${SITE_NAME}' version" &>/dev/null 2>&1; }
app_installed()   { sudo -u "${FRAPPE_USER}" bash -c "cd '${BENCH_DIR}' && ls apps/" 2>/dev/null | grep -q "^${1}$"; }

run_as_frappe() {
    # Jalankan perintah sebagai user frappe di direktori bench
    sudo -u "${FRAPPE_USER}" bash -c "cd '${BENCH_DIR}' && $*"
}

# =============================================================================
# LANGKAH 1 — Validasi prasyarat
# =============================================================================

step_validate() {
    log_section "Langkah 1: Validasi Prasyarat"

    [[ "$EUID" -eq 0 ]] || die "Script harus dijalankan sebagai root (sudo bash deploy.sh)."

    # Cek OS
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        [[ "$ID" == "ubuntu" ]] || log_warn "OS bukan Ubuntu. Script dioptimasi untuk Ubuntu 24.04 LTS."
        [[ "$VERSION_ID" == "24.04" ]] || log_warn "Versi Ubuntu bukan 24.04 (terdeteksi: ${VERSION_ID:-unknown}). Lanjutkan dengan hati-hati."
    else
        log_warn "Tidak dapat membaca /etc/os-release. Pastikan ini Ubuntu 24.04 LTS."
    fi

    log_ok "Validasi prasyarat selesai."
}

# =============================================================================
# LANGKAH 2 — Install system dependencies
# =============================================================================

step_system_deps() {
    log_section "Langkah 2: Install System Dependencies"

    log_info "Update apt package list..."
    apt-get update -qq

    log_info "Install package dasar..."
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        git \
        curl \
        wget \
        gnupg2 \
        ca-certificates \
        lsb-release \
        software-properties-common \
        apt-transport-https \
        python3 \
        python3-pip \
        python3-venv \
        python3-dev \
        python3-setuptools \
        build-essential \
        libssl-dev \
        libffi-dev \
        libjpeg-dev \
        libpq-dev \
        libtiff-dev \
        libfreetype6-dev \
        libwebp-dev \
        zlib1g-dev \
        fonts-liberation \
        supervisor \
        nginx \
        ufw \
        cron \
        xvfb \
        libxrender1 \
        libxext6 \
        libfontconfig1

    log_ok "System dependencies terinstall."
}

# =============================================================================
# LANGKAH 3 — Setup user OS 'frappe'
# =============================================================================

step_setup_user() {
    log_section "Langkah 3: Setup User OS '${FRAPPE_USER}'"

    if user_exists "${FRAPPE_USER}"; then
        log_info "User '${FRAPPE_USER}' sudah ada — dilewati."
    else
        log_info "Membuat user '${FRAPPE_USER}'..."
        useradd -m -s /bin/bash "${FRAPPE_USER}"
        log_ok "User '${FRAPPE_USER}' berhasil dibuat."
    fi

    # Tambahkan ke grup sudo agar bisa menjalankan bench setup production
    if ! groups "${FRAPPE_USER}" | grep -q sudo; then
        usermod -aG sudo "${FRAPPE_USER}"
        log_info "User '${FRAPPE_USER}' ditambahkan ke grup sudo."
    fi

    # Aktifkan sudo tanpa password untuk perintah bench production setup
    local sudoers_file="/etc/sudoers.d/frappe-bench"
    if ! file_exists "$sudoers_file"; then
        echo "${FRAPPE_USER} ALL=(ALL) NOPASSWD: /usr/bin/bench, /usr/local/bin/bench" > "$sudoers_file"
        chmod 440 "$sudoers_file"
        log_info "Sudoers entry untuk bench dibuat."
    fi

    log_ok "User setup selesai."
}

# =============================================================================
# LANGKAH 4 — Install dan konfigurasi MariaDB
# =============================================================================

step_mariadb() {
    log_section "Langkah 4: Install MariaDB"

    if command_exists mariadb; then
        log_info "MariaDB sudah terinstall — melewati instalasi."
    else
        log_info "Menambahkan repository MariaDB 10.11..."
        curl -LsS https://downloads.mariadb.com/MariaDB/mariadb_repo_setup \
            | bash -s -- --mariadb-server-version="mariadb-10.11" --skip-key-import=false

        log_info "Install MariaDB Server..."
        DEBIAN_FRONTEND=noninteractive apt-get install -y mariadb-server mariadb-client libmariadb-dev

        systemctl enable mariadb
        systemctl start mariadb
        log_ok "MariaDB terinstall dan berjalan."
    fi

    # Konfigurasi karakter set untuk Frappe (wajib utf8mb4)
    local mariadb_conf="/etc/mysql/mariadb.conf.d/99-frappe.cnf"
    if ! file_exists "$mariadb_conf"; then
        log_info "Menulis konfigurasi MariaDB untuk Frappe..."
        cat > "$mariadb_conf" <<'MARIADBCONF'
[mysqld]
character-set-client-handshake = FALSE
character-set-server            = utf8mb4
collation-server                = utf8mb4_unicode_ci

[mysql]
default-character-set = utf8mb4
MARIADBCONF
        systemctl restart mariadb
        log_ok "Konfigurasi MariaDB ditulis."
    else
        log_info "Konfigurasi MariaDB sudah ada — dilewati."
    fi

    # Set password root MariaDB (idempoten: hanya jika belum di-set)
    log_info "Mengamankan instalasi MariaDB..."
    mysql -u root -e "
        ALTER USER IF EXISTS 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
        DELETE FROM mysql.user WHERE User='';
        DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
        DROP DATABASE IF EXISTS test;
        FLUSH PRIVILEGES;
    " 2>/dev/null || \
    mysql -u root -p"${DB_ROOT_PASSWORD}" -e "SELECT 1;" 2>/dev/null || \
    die "Tidak dapat terhubung ke MariaDB. Periksa DB_ROOT_PASSWORD."

    log_ok "MariaDB konfigurasi selesai."
}

# =============================================================================
# LANGKAH 5 — Install Redis
# =============================================================================

step_redis() {
    log_section "Langkah 5: Install Redis"

    if command_exists redis-server; then
        log_info "Redis sudah terinstall — dilewati."
    else
        log_info "Install Redis..."
        DEBIAN_FRONTEND=noninteractive apt-get install -y redis-server
        systemctl enable redis-server
        systemctl start redis-server
        log_ok "Redis terinstall dan berjalan."
    fi
}

# =============================================================================
# LANGKAH 6 — Install Node.js, npm, Yarn
# =============================================================================

step_nodejs() {
    log_section "Langkah 6: Install Node.js ${NODE_VERSION}.x LTS, npm, Yarn"

    if command_exists node && node --version | grep -q "^v${NODE_VERSION}"; then
        log_info "Node.js ${NODE_VERSION}.x sudah terinstall — dilewati."
    else
        log_info "Menambahkan NodeSource repository untuk Node.js ${NODE_VERSION}.x..."
        curl -fsSL "https://deb.nodesource.com/setup_${NODE_VERSION}.x" | bash -
        DEBIAN_FRONTEND=noninteractive apt-get install -y nodejs
        log_ok "Node.js $(node --version) terinstall."
    fi

    if command_exists yarn; then
        log_info "Yarn sudah terinstall — dilewati."
    else
        log_info "Install Yarn via npm..."
        npm install -g yarn
        log_ok "Yarn $(yarn --version) terinstall."
    fi
}

# =============================================================================
# LANGKAH 7 — Install wkhtmltopdf (untuk PDF export)
# =============================================================================

step_wkhtmltopdf() {
    log_section "Langkah 7: Install wkhtmltopdf"

    if command_exists wkhtmltopdf; then
        log_info "wkhtmltopdf sudah terinstall — dilewati."
        return
    fi

    log_info "Download dan install wkhtmltopdf 0.12.6 (patched Qt)..."
    local arch
    arch=$(dpkg --print-architecture)
    local wk_url="https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-3/wkhtmltox_0.12.6.1-3.jammy_${arch}.deb"

    wget -q -O /tmp/wkhtmltox.deb "$wk_url" || \
        die "Gagal download wkhtmltopdf dari ${wk_url}"

    DEBIAN_FRONTEND=noninteractive apt-get install -y /tmp/wkhtmltox.deb || \
        die "Gagal install wkhtmltopdf."

    rm -f /tmp/wkhtmltox.deb
    log_ok "wkhtmltopdf $(wkhtmltopdf --version 2>/dev/null | head -1) terinstall."
}

# =============================================================================
# LANGKAH 8 — Install Frappe Bench (pip) dan init bench
# =============================================================================

step_bench_install() {
    log_section "Langkah 8: Install Frappe Bench"

    if command_exists bench; then
        log_info "bench CLI sudah terinstall — dilewati."
    else
        log_info "Install frappe-bench via pip3..."
        pip3 install frappe-bench
        log_ok "bench terinstall: $(bench --version 2>/dev/null || echo 'versi tidak diketahui')"
    fi
}

step_bench_init() {
    log_section "Langkah 9: Init Bench dan Install Frappe"

    if dir_exists "${BENCH_DIR}"; then
        log_info "Direktori bench '${BENCH_DIR}' sudah ada — melewati bench init."
    else
        log_info "Membuat bench baru di '${BENCH_DIR}'..."
        sudo -u "${FRAPPE_USER}" bash -c "
            bench init \
                --frappe-branch '${FRAPPE_BRANCH}' \
                --skip-redis-config-generation \
                '${BENCH_DIR}'
        " || die "Gagal menginisialisasi bench."
        log_ok "Bench berhasil diinisialisasi di ${BENCH_DIR}."
    fi
}

# =============================================================================
# LANGKAH 9 — Install ERPNext
# =============================================================================

step_erpnext() {
    log_section "Langkah 10: Install ERPNext v16"

    if app_installed "erpnext"; then
        log_info "ERPNext sudah terinstall di bench — dilewati."
    else
        log_info "Mengambil ERPNext branch '${ERPNEXT_BRANCH}' dari GitHub..."
        run_as_frappe "bench get-app erpnext --branch '${ERPNEXT_BRANCH}'" || \
            die "Gagal mengambil ERPNext. Periksa koneksi internet dan nama branch."
        log_ok "ERPNext berhasil ditambahkan ke bench."
    fi
}

# =============================================================================
# LANGKAH 10 — Install Fundara custom app
# =============================================================================

step_fundara_app() {
    log_section "Langkah 11: Install Fundara Custom App"

    if app_installed "${APP_NAME}"; then
        log_info "App '${APP_NAME}' sudah terinstall di bench — dilewati."
    else
        log_info "Mengambil Fundara dari '${APP_REPO}' branch '${APP_BRANCH}'..."
        run_as_frappe "bench get-app '${APP_REPO}' --branch '${APP_BRANCH}'" || \
            die "Gagal mengambil Fundara app. Periksa URL repo dan nama branch."
        log_ok "Fundara app berhasil ditambahkan ke bench."
    fi
}

# =============================================================================
# LANGKAH 11 — Buat Frappe site
# =============================================================================

step_create_site() {
    log_section "Langkah 12: Buat Frappe Site '${SITE_NAME}'"

    if site_exists; then
        log_info "Site '${SITE_NAME}' sudah ada — melewati pembuatan site."
    else
        log_info "Membuat site baru '${SITE_NAME}'..."
        run_as_frappe "bench new-site '${SITE_NAME}' \
            --db-root-password '${DB_ROOT_PASSWORD}' \
            --admin-password '${ADMIN_PASSWORD}' \
            --no-mariadb-socket" || \
            die "Gagal membuat site '${SITE_NAME}'."
        log_ok "Site '${SITE_NAME}' berhasil dibuat."
    fi

    # Install ERPNext ke site
    log_info "Install ERPNext ke site '${SITE_NAME}'..."
    run_as_frappe "bench --site '${SITE_NAME}' install-app erpnext" 2>/dev/null || \
        log_warn "ERPNext mungkin sudah terinstall di site ini."

    # Install Fundara ke site
    log_info "Install Fundara ke site '${SITE_NAME}'..."
    run_as_frappe "bench --site '${SITE_NAME}' install-app '${APP_NAME}'" 2>/dev/null || \
        log_warn "Fundara mungkin sudah terinstall di site ini."

    # Set sebagai default site
    run_as_frappe "bench use '${SITE_NAME}'"

    log_ok "Aplikasi berhasil terinstall di site '${SITE_NAME}'."
}

# =============================================================================
# LANGKAH 12 — Konfigurasi production: Nginx + Supervisor
# =============================================================================

step_production_setup() {
    log_section "Langkah 13: Konfigurasi Production (Nginx + Supervisor)"

    log_info "Mengatur jumlah gunicorn workers ke ${GUNICORN_WORKERS}..."
    run_as_frappe "bench config set-common-config -c gunicorn_workers ${GUNICORN_WORKERS}"

    log_info "Menjalankan bench setup production untuk user '${FRAPPE_USER}'..."
    bench setup production "${FRAPPE_USER}" --yes || \
        die "Gagal setup production bench."

    log_info "Memuat ulang Nginx dan Supervisor..."
    systemctl reload nginx || systemctl restart nginx
    supervisorctl reread
    supervisorctl update
    supervisorctl start all 2>/dev/null || true

    log_ok "Nginx dan Supervisor telah dikonfigurasi untuk production."
}

# =============================================================================
# LANGKAH 13 — SSL opsional via Let's Encrypt
# =============================================================================

step_ssl() {
    log_section "Langkah 14: Konfigurasi SSL Let's Encrypt"

    if [[ "$SKIP_SSL" == "true" ]] || [[ "${ENABLE_SSL}" != "yes" ]]; then
        log_info "SSL dilewati (ENABLE_SSL=${ENABLE_SSL}, SKIP_SSL=${SKIP_SSL})."
        return
    fi

    [[ -n "${SSL_EMAIL:-}" ]] || die "SSL_EMAIL wajib diisi untuk Let's Encrypt."

    # Install certbot jika belum ada
    if ! command_exists certbot; then
        log_info "Install Certbot via snap..."
        snap install --classic certbot 2>/dev/null || \
            DEBIAN_FRONTEND=noninteractive apt-get install -y certbot python3-certbot-nginx
        ln -sf /snap/bin/certbot /usr/bin/certbot 2>/dev/null || true
    fi

    log_info "Mendapatkan sertifikat SSL untuk '${SITE_NAME}'..."
    certbot --nginx \
        --non-interactive \
        --agree-tos \
        --email "${SSL_EMAIL}" \
        -d "${SITE_NAME}" || \
        die "Gagal mendapatkan sertifikat SSL. Pastikan DNS ${SITE_NAME} mengarah ke server ini dan port 80 terbuka."

    # Setup auto-renewal (certbot systemd timer biasanya sudah aktif)
    if systemctl list-timers 2>/dev/null | grep -q certbot; then
        log_info "Certbot auto-renewal timer sudah aktif."
    else
        log_info "Mengaktifkan cron certbot renewal..."
        (crontab -l 2>/dev/null; echo "0 3 * * * certbot renew --quiet --post-hook 'systemctl reload nginx'") | crontab -
    fi

    log_ok "SSL berhasil dikonfigurasi untuk ${SITE_NAME}."
}

# =============================================================================
# LANGKAH 14 — Setup cron backup otomatis
# =============================================================================

step_backup_cron() {
    log_section "Langkah 15: Setup Cron Backup Otomatis"

    local backup_script="/home/${FRAPPE_USER}/fundara-backup.sh"
    local backup_log="/home/${FRAPPE_USER}/logs/backup.log"

    # Buat direktori log
    sudo -u "${FRAPPE_USER}" mkdir -p "/home/${FRAPPE_USER}/logs"

    # Tulis skrip backup
    log_info "Menulis skrip backup ke ${backup_script}..."
    cat > "$backup_script" <<BACKUPEOF
#!/usr/bin/env bash
# Fundara Backup Script — dijalankan otomatis via cron
# Backup site Frappe: database + private files + public files

set -euo pipefail

BENCH_DIR="${BENCH_DIR}"
SITE_NAME="${SITE_NAME}"
LOG_FILE="${backup_log}"
BACKUP_RETENTION_DAYS=7

timestamp() { date '+%Y-%m-%d %H:%M:%S'; }

log() { echo "\$(timestamp) \$*" >> "\${LOG_FILE}"; }

log "=== Mulai backup untuk site: \${SITE_NAME} ==="

cd "\${BENCH_DIR}"

# Jalankan backup bench dengan kompresi
if bench --site "\${SITE_NAME}" backup --with-files --compress >> "\${LOG_FILE}" 2>&1; then
    log "Backup berhasil."
else
    log "ERROR: Backup gagal."
    exit 1
fi

# Hapus backup lokal yang lebih tua dari BACKUP_RETENTION_DAYS hari
SITES_DIR="\${BENCH_DIR}/sites/\${SITE_NAME}/private/backups"
if [[ -d "\${SITES_DIR}" ]]; then
    find "\${SITES_DIR}" -type f -mtime +\${BACKUP_RETENTION_DAYS} -delete
    log "Backup lama (>7 hari) dihapus."
fi

log "=== Backup selesai ==="
BACKUPEOF

    chmod +x "$backup_script"
    chown "${FRAPPE_USER}:${FRAPPE_USER}" "$backup_script"

    # Daftarkan cron untuk user frappe (jalankan setiap hari pukul 02:00)
    local cron_entry="0 2 * * * ${backup_script} >> ${backup_log} 2>&1"
    local cron_marker="# fundara-backup-cron"

    if sudo -u "${FRAPPE_USER}" crontab -l 2>/dev/null | grep -q "fundara-backup-cron"; then
        log_info "Cron backup sudah terdaftar — dilewati."
    else
        log_info "Mendaftarkan cron backup (setiap hari pukul 02:00)..."
        (sudo -u "${FRAPPE_USER}" crontab -l 2>/dev/null; \
         echo "${cron_marker}"; \
         echo "${cron_entry}") | sudo -u "${FRAPPE_USER}" crontab -
        log_ok "Cron backup berhasil didaftarkan."
    fi
}

# =============================================================================
# LANGKAH 15 — Konfigurasi UFW firewall dasar
# =============================================================================

step_firewall() {
    log_section "Langkah 16: Konfigurasi UFW Firewall"

    if ! command_exists ufw; then
        log_warn "UFW tidak terinstall — melewati konfigurasi firewall."
        return
    fi

    log_info "Konfigurasi UFW..."
    ufw --force reset
    ufw default deny incoming
    ufw default allow outgoing
    ufw allow 22/tcp    comment 'SSH'
    ufw allow 80/tcp    comment 'HTTP'
    ufw allow 443/tcp   comment 'HTTPS'
    ufw --force enable

    log_ok "Firewall UFW dikonfigurasi (22, 80, 443 terbuka)."
    log_warn "PENTING: Pastikan SSH port 22 dapat diakses sebelum menutup sesi ini."
}

# =============================================================================
# Fungsi ringkasan instalasi
# =============================================================================

print_summary() {
    log_section "Ringkasan Instalasi"

    local site_url="http://${SITE_NAME}"
    [[ "${ENABLE_SSL}" == "yes" ]] && site_url="https://${SITE_NAME}"

    echo -e "${GREEN}"
    cat <<SUMMARY
╔══════════════════════════════════════════════════════════════╗
║              FUNDARA BERHASIL DIINSTALL                      ║
╠══════════════════════════════════════════════════════════════╣
║                                                              ║
║  Site URL        : ${site_url}
║  Site Name       : ${SITE_NAME}
║  Admin User      : Administrator
║  Bench Directory : ${BENCH_DIR}
║  Frappe User     : ${FRAPPE_USER}
║                                                              ║
║  Apps yang diinstall:                                        ║
║    - frappe  (${FRAPPE_BRANCH})
║    - erpnext (${ERPNEXT_BRANCH})
║    - ${APP_NAME}  (${APP_BRANCH})
║                                                              ║
║  Gunicorn Workers : ${GUNICORN_WORKERS}
║  SSL              : ${ENABLE_SSL}
║  Auto Backup      : Setiap hari pukul 02:00                  ║
║  Backup Retensi   : 7 hari lokal                             ║
║                                                              ║
║  Langkah berikutnya:                                         ║
║  1. Buka ${site_url}
║  2. Login sebagai Administrator                              ║
║  3. Jalankan setup wizard ERPNext                            ║
║  4. Aktifkan modul Fundara                                   ║
║  5. Konfigurasi monitoring (Uptime Kuma / Netdata)           ║
║  6. Verifikasi backup berjalan: sudo -u frappe crontab -l    ║
║                                                              ║
║  Log backup: ~/logs/backup.log                               ║
║  Supervisor : supervisorctl status                           ║
║  Bench logs : bench --site ${SITE_NAME} show-pending-patches ║
╚══════════════════════════════════════════════════════════════╝
SUMMARY
    echo -e "${NC}"
}

# =============================================================================
# MAIN — urutan eksekusi
# =============================================================================

main() {
    echo -e "\n${BLUE}╔═══════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║    Fundara Deployment Script               ║${NC}"
    echo -e "${BLUE}║    Ubuntu 24.04 LTS + ERPNext v16          ║${NC}"
    echo -e "${BLUE}╚═══════════════════════════════════════════╝${NC}\n"

    collect_required_vars

    if [[ "$DRY_RUN" == "true" ]]; then
        log_warn "Mode dry-run aktif. Langkah-langkah di atas akan dijalankan jika dry-run dinonaktifkan."
        exit 0
    fi

    step_validate
    step_system_deps
    step_setup_user
    step_mariadb
    step_redis
    step_nodejs
    step_wkhtmltopdf
    step_bench_install
    step_bench_init
    step_erpnext
    step_fundara_app
    step_create_site
    step_production_setup
    step_ssl
    step_backup_cron
    step_firewall

    print_summary
}

main "$@"
