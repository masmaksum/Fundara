# Local Development Setup — Fundara

Panduan ini membawa developer dari mesin kosong ke Fundara berjalan di laptop/desktop dalam waktu kurang dari 60 menit. Ikuti seluruh langkah secara berurutan — jangan loncat ke tengah.

**Stack yang akan diinstall:**
- Python 3.11+ · Node.js 18 LTS · MariaDB 10.11 · Redis 7
- Frappe Framework (version-16) · ERPNext (version-16) · Fundara custom app

---

## 1. Prerequisites Check

### 1.1 Minimum hardware

| Komponen | Minimum | Recommended |
|---|---|---|
| RAM | 8 GB | 16 GB |
| Storage | 20 GB free | 40 GB free |
| CPU | 2 core | 4 core |

MariaDB, Redis, dan tiga Frappe worker process semuanya berjalan bersamaan. Dengan RAM 4 GB, `bench start` akan terasa sangat lambat.

### 1.2 Cek port yang dibutuhkan

Port berikut harus bebas sebelum mulai:

```bash
# Cek apakah port sudah dipakai
ss -tlnp | grep -E '8000|8002|3306|6379'
# Atau pakai lsof jika ss tidak tersedia
lsof -i :8000 -i :8002 -i :3306 -i :6379 2>/dev/null
```

Jika ada port yang dipakai, identifikasi prosesnya dan hentikan dulu sebelum melanjutkan.

| Port | Dipakai oleh |
|---|---|
| 8000 | Frappe web server |
| 8002 | Frappe socketio |
| 3306 | MariaDB |
| 6379 | Redis |

### 1.3 Cek versi tools yang diperlukan

```bash
git --version     # minimal 2.x
curl --version    # minimal 7.x
python3 --version # akan diinstall — cek saja apakah ada konflik
```

---

## 2. OS-Specific Dependency Installation

Pilih bagian sesuai OS Anda. Jika menggunakan Windows, baca bagian WSL2 dulu sebelum lanjut ke bagian Ubuntu.

---

### 2A. Ubuntu / Debian

Diuji pada Ubuntu 22.04 LTS, Ubuntu 24.04 LTS, dan Debian 12.

#### Update sistem dan install dependencies dasar

```bash
sudo apt update && sudo apt upgrade -y

sudo apt install -y \
  git curl wget \
  build-essential \
  python3-dev python3-pip python3-venv \
  libssl-dev libffi-dev \
  libmariadb-dev libmariadb-dev-compat \
  libjpeg-dev zlib1g-dev \
  fontconfig libxrender1 libxtst6 libxi6 \
  xfonts-75dpi xfonts-base \
  software-properties-common \
  redis-server
```

#### Python 3.11+

Ubuntu 24.04 sudah menyertakan Python 3.12. Pada Ubuntu 22.04, install via deadsnakes PPA:

```bash
# Ubuntu 22.04 saja — lewati ini jika Ubuntu 24.04
sudo add-apt-repository ppa:deadsnakes/ppa -y
sudo apt update
sudo apt install -y python3.11 python3.11-dev python3.11-venv

# Set python3.11 sebagai default (opsional, lihat catatan di bawah)
sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1
```

> **Catatan Ubuntu 22.04:** Jika sistem menggunakan python3.10 untuk tools OS, lebih aman menggunakan pyenv daripada `update-alternatives`. Lihat catatan pyenv di bagian macOS — caranya sama di Linux.

```bash
# Install pip untuk Python 3.11
python3.11 -m ensurepip --upgrade
python3.11 -m pip install --upgrade pip virtualenv
```

#### Node.js 18 LTS via nvm

nvm (Node Version Manager) lebih disarankan daripada install Node langsung, karena memudahkan pergantian versi.

```bash
# Install nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

# Reload shell
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Install dan gunakan Node.js 18 LTS
nvm install 18
nvm use 18
nvm alias default 18

# Verifikasi
node --version   # harus v18.x.x
npm --version    # harus 9.x atau lebih
```

```bash
# Install yarn
npm install -g yarn
yarn --version
```

#### MariaDB 10.11

```bash
# Tambah repository MariaDB resmi
curl -LsS https://r.mariadb.com/downloads/mariadb_repo_setup | sudo bash -s -- --mariadb-server-version="mariadb-10.11"

sudo apt update
sudo apt install -y mariadb-server mariadb-client

# Start dan enable MariaDB
sudo systemctl start mariadb
sudo systemctl enable mariadb
```

**Konfigurasi charset (wajib):** Frappe memerlukan `utf8mb4`. Buat file config:

```bash
sudo nano /etc/mysql/conf.d/fundara.cnf
```

Isi file:

```ini
[mysqld]
character-set-client-handshake = FALSE
character-set-server = utf8mb4
collation-server = utf8mb4_unicode_ci

[mysql]
default-character-set = utf8mb4
```

```bash
sudo systemctl restart mariadb
```

**Amankan MariaDB:**

```bash
sudo mysql_secure_installation
```

Jawab pertanyaannya:
- Enter current password for root: *(tekan Enter — belum ada password)*
- Switch to unix_socket authentication: `n`
- Change the root password: `Y` → masukkan password yang kuat, **ingat password ini** untuk langkah 7
- Remove anonymous users: `Y`
- Disallow root login remotely: `Y`
- Remove test database: `Y`
- Reload privilege tables: `Y`

**Buat file `~/.my.cnf` agar bench bisa connect ke MariaDB:**

```bash
cat > ~/.my.cnf << 'EOF'
[client]
default-character-set = utf8mb4
EOF
chmod 600 ~/.my.cnf
```

#### wkhtmltopdf 0.12.6 (versi tepat — jangan pakai yang lain)

```bash
# Ubuntu 22.04 / Debian 12 (amd64)
wget https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-3/wkhtmltox_0.12.6.1-3.jammy_amd64.deb
sudo apt install -y ./wkhtmltox_0.12.6.1-3.jammy_amd64.deb

# Ubuntu 24.04 (amd64)
wget https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-3/wkhtmltox_0.12.6.1-3.jammy_amd64.deb
sudo dpkg -i wkhtmltox_0.12.6.1-3.jammy_amd64.deb
sudo apt install -f -y

# Verifikasi — HARUS menampilkan wkhtmltopdf 0.12.6
wkhtmltopdf --version
```

> **Penting:** Versi lain (0.12.5, 0.12.4, atau versi dari apt default) akan menyebabkan PDF generation rusak. Selalu gunakan 0.12.6 dari link di atas.

---

### 2B. macOS (Intel dan Apple Silicon M1/M2/M3)

Diuji pada macOS 13 Ventura dan 14 Sonoma.

#### Homebrew

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Setelah install, ikuti instruksi yang ditampilkan untuk menambahkan Homebrew ke PATH (berbeda antara Intel dan Apple Silicon).

```bash
# Apple Silicon — tambahkan ke ~/.zprofile jika belum otomatis
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"

# Intel — path biasanya /usr/local
echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zprofile
```

#### Python 3.11+ via pyenv

pyenv sangat disarankan di macOS karena macOS system Python tidak boleh disentuh.

```bash
brew install pyenv

# Tambahkan ke ~/.zprofile
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.zprofile
echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.zprofile
echo 'eval "$(pyenv init -)"' >> ~/.zprofile

# Reload
source ~/.zprofile

# Install Python 3.11
pyenv install 3.11.9
pyenv global 3.11.9

# Verifikasi
python --version     # harus Python 3.11.x
pip --version

# Install virtualenv
pip install --upgrade pip virtualenv
```

#### Node.js 18 LTS via nvm

```bash
brew install nvm

# Tambahkan ke ~/.zprofile
echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.zprofile
echo '[ -s "$(brew --prefix nvm)/nvm.sh" ] && \. "$(brew --prefix nvm)/nvm.sh"' >> ~/.zprofile
source ~/.zprofile

nvm install 18
nvm use 18
nvm alias default 18

node --version
npm install -g yarn
```

#### MariaDB 10.11

```bash
brew install mariadb@10.11

# Tambahkan ke PATH
echo 'export PATH="$(brew --prefix mariadb@10.11)/bin:$PATH"' >> ~/.zprofile
source ~/.zprofile

# Start MariaDB
brew services start mariadb@10.11
```

**Konfigurasi charset:**

```bash
# Buat atau edit file config MariaDB
mkdir -p $(brew --prefix mariadb@10.11)/etc/conf.d
cat > $(brew --prefix mariadb@10.11)/etc/conf.d/fundara.cnf << 'EOF'
[mysqld]
character-set-client-handshake = FALSE
character-set-server = utf8mb4
collation-server = utf8mb4_unicode_ci

[mysql]
default-character-set = utf8mb4
EOF

brew services restart mariadb@10.11
```

**Set password root MariaDB:**

```bash
mysql -u root
```

Di dalam MySQL prompt:

```sql
ALTER USER 'root'@'localhost' IDENTIFIED BY 'password_kuat_anda';
FLUSH PRIVILEGES;
EXIT;
```

**Buat `~/.my.cnf`:**

```bash
cat > ~/.my.cnf << 'EOF'
[client]
default-character-set = utf8mb4
EOF
chmod 600 ~/.my.cnf
```

#### Redis 7

```bash
brew install redis
brew services start redis
redis-cli ping   # harus PONG
```

#### wkhtmltopdf 0.12.6 di macOS

```bash
# Download package macOS
curl -L https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-3/wkhtmltox-0.12.6.1-3.macos-cocoa.pkg -o wkhtmltox.pkg
sudo installer -pkg wkhtmltox.pkg -target /
wkhtmltopdf --version
```

> **Apple Silicon (M1/M2/M3):** wkhtmltopdf tidak punya native ARM build. Cara terbaik adalah install via Rosetta 2:
>
> ```bash
> # Pastikan Rosetta 2 sudah terinstall
> softwareupdate --install-rosetta --agree-to-license
>
> # Install wkhtmltopdf x86_64 package seperti di atas
> # macOS akan menjalankannya melalui Rosetta 2 secara otomatis
> ```
>
> PDF generation akan berjalan lebih lambat di Apple Silicon via Rosetta, tapi tetap berfungsi dengan benar.

#### Tools tambahan macOS

```bash
brew install git curl
# Xcode Command Line Tools (jika belum)
xcode-select --install
```

---

### 2C. Windows via WSL2

Frappe **tidak mendukung** Windows native. Gunakan WSL2 dengan Ubuntu 22.04 atau 24.04.

#### Install WSL2 dan Ubuntu

Buka PowerShell sebagai Administrator:

```powershell
wsl --install -d Ubuntu-22.04
```

Restart komputer jika diminta. Setelah restart, Ubuntu akan selesai setup dan meminta username/password Linux baru.

#### Konfigurasi WSL2

Buka Ubuntu terminal. Lanjutkan seluruh langkah dari **bagian 2A (Ubuntu/Debian)** di dalam terminal WSL2 ini.

**Catatan penting WSL2:**

1. **Jangan simpan project di path Windows** (`/mnt/c/...`). Selalu kerja di home directory Linux (`~/`). Performa filesystem Windows mount sangat lambat untuk development.

2. **Akses dari browser Windows:** Setelah `bench start`, buka `http://localhost:8000` di browser Windows (bukan di dalam WSL). Port forwarding WSL2 ke Windows berjalan otomatis.

3. **Hosts file:** Edit di Windows, bukan di WSL. Lihat langkah 7.

4. **Resource WSL2:** Secara default WSL2 mengambil setengah RAM Windows. Jika RAM terbatas, buat file `%USERPROFILE%\.wslconfig`:

```ini
[wsl2]
memory=6GB
processors=4
```

---

## 3. Install Frappe Bench CLI

Frappe Bench adalah tool CLI untuk mengelola seluruh siklus hidup Frappe apps: init bench, get app, new site, start, migrate, dan seterusnya.

```bash
pip install frappe-bench
```

Verifikasi:

```bash
bench --version
# contoh output: 5.x.x
```

Jika `bench` tidak ditemukan setelah install:

```bash
# Tambahkan pip bin ke PATH
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc   # atau ~/.zprofile di macOS
source ~/.bashrc
bench --version
```

---

## 4. Initialize Bench

Bench init membuat direktori kerja lengkap berisi semua apps, sites, config, dan virtual environment Python.

```bash
bench init --frappe-branch version-16 ~/fundara-dev
cd ~/fundara-dev
```

**Apa yang terjadi saat `bench init`:**

1. Membuat virtualenv Python di `env/`
2. Clone repository `frappe` dari GitHub
3. Install semua Python dependencies Frappe ke virtualenv
4. Install Node.js dependencies (`node_modules/`)
5. Build frontend assets awal

**Struktur direktori yang dibuat:**

```
~/fundara-dev/
├── apps/
│   └── frappe/          ← Frappe Framework source code
├── sites/
│   └── assets/          ← compiled frontend assets
├── env/                 ← Python virtualenv
├── config/              ← Nginx, Redis, Supervisor config (generated)
├── logs/                ← Log files
├── Procfile             ← Process definitions untuk bench start
└── node_modules/        ← Node.js dependencies
```

**Berapa lama:** 5–10 menit tergantung koneksi internet dan kecepatan disk. Proses terlama adalah clone frappe repository dan install Python packages.

---

## 5. Get ERPNext

```bash
cd ~/fundara-dev
bench get-app --branch version-16 erpnext
```

Ini akan clone ERPNext ke `apps/erpnext/` dan install Python dependencies-nya. Estimasi waktu: 3–5 menit.

---

## 6. Get Fundara Custom App

```bash
bench get-app fundara https://github.com/masmaksum/Fundara
```

Ini akan clone Fundara ke `apps/fundara/` dan install dependencies-nya.

> **Developer yang akan berkontribusi:** Setelah `bench get-app`, set remote origin ke fork Anda sendiri:
>
> ```bash
> cd ~/fundara-dev/apps/fundara
> git remote rename origin upstream
> git remote add origin https://github.com/<username-anda>/Fundara
> git remote -v
> ```

---

## 7. Create Development Site

### 7.1 Tambahkan fundara.local ke hosts file

**Ubuntu/Debian/WSL2 (edit di sistem Linux):**

```bash
echo "127.0.0.1    fundara.local" | sudo tee -a /etc/hosts
```

**macOS:**

```bash
echo "127.0.0.1    fundara.local" | sudo tee -a /etc/hosts
```

**Windows (untuk WSL2 — edit di Windows):**

Buka Notepad sebagai Administrator, buka file `C:\Windows\System32\drivers\etc\hosts`, tambahkan:

```
127.0.0.1    fundara.local
```

Simpan dan tutup.

### 7.2 Buat site baru

```bash
cd ~/fundara-dev

bench new-site fundara.local \
  --mariadb-root-password <password-root-mariadb-anda> \
  --admin-password admin
```

Ganti `<password-root-mariadb-anda>` dengan password yang dibuat saat `mysql_secure_installation` di langkah 2.

Ini akan membuat database MariaDB baru untuk site ini dan menjalankan migrasi schema awal Frappe. Estimasi: 2–3 menit.

### 7.3 Install ERPNext ke site

```bash
bench --site fundara.local install-app erpnext
```

Proses ini menjalankan semua migrasi ERPNext. Estimasi: 2–4 menit.

### 7.4 Install Fundara ke site

```bash
bench --site fundara.local install-app fundara
```

---

## 8. Enable Developer Mode

```bash
bench --site fundara.local set-config developer_mode 1
bench --site fundara.local clear-cache
```

**Mengapa developer mode penting:**

| Fitur | Developer Mode OFF | Developer Mode ON |
|---|---|---|
| DocType export ke JSON | Tidak bisa | Bisa — perubahan DocType tersimpan ke file |
| Python traceback | Tersembunyi | Muncul di browser |
| Test runner | Tidak aktif | Aktif |
| Reload otomatis | Tidak | Ya |
| Edit Custom Script | Terbatas | Penuh |

Tanpa developer mode aktif, perubahan DocType yang Anda buat via UI tidak akan tersimpan ke file JSON di repository — artinya perubahan hilang saat `bench migrate` berikutnya.

---

## 9. Start the Development Server

```bash
cd ~/fundara-dev
bench start
```

Terminal akan menampilkan output berwarna dari beberapa proses secara bersamaan:

```
12:00:01 web.1            | * Running on http://0.0.0.0:8000
12:00:01 worker_short.1   | ready
12:00:01 worker_long.1    | ready
12:00:01 worker_default.1 | ready
12:00:01 schedule.1       | Scheduler is active
12:00:01 watch.1          | Watching...
12:00:01 socketio.1       | listening on port 8002
```

**Penjelasan setiap proses:**

| Proses | Fungsi |
|---|---|
| `web` | Gunicorn HTTP server — melayani request browser |
| `worker_short` | Background job queue untuk tugas < 5 menit (kirim email, notif) |
| `worker_long` | Background job queue untuk tugas berat (generate laporan besar, import Excel) |
| `worker_default` | Background job queue default |
| `schedule` | Frappe Scheduler — menjalankan cron jobs (daily backup, recurring jobs) |
| `watch` | Memantau perubahan file JS/CSS dan rebuild assets otomatis |
| `socketio` | WebSocket server untuk real-time update di browser |

**Akses aplikasi:**

Buka browser dan navigasi ke: `http://fundara.local:8000`

Kredensial default:
- Username: `Administrator`
- Password: `admin`

**Menghentikan server:**

Tekan `Ctrl+C` di terminal. Semua proses akan berhenti dengan clean.

---

## 10. Verify Installation

Setelah login, lakukan checklist berikut:

- [ ] Bisa login ke `http://fundara.local:8000` dengan Administrator / admin
- [ ] Setelah login, tampil Frappe Desk dengan menu module
- [ ] ERPNext module terlihat di Module list (Accounts, HR, Manufacturing, dll.)
- [ ] Fundara module terlihat di Module list (Funding, Fund Stewardship, Grant, dll.)
- [ ] Developer mode aktif — terlihat dari adanya menu "Customize Form" dan "DocType" di search
- [ ] Bisa membuat DocType baru via Awesome Bar: ketik "New DocType"
- [ ] Background jobs berjalan — cek via bench console:

```bash
# Di terminal baru (sementara bench start masih berjalan di terminal lain)
cd ~/fundara-dev
bench --site fundara.local console
```

Di dalam console Python:

```python
# Cek status scheduler
import frappe
frappe.get_all("Scheduled Job Log", limit=3, order_by="creation desc")
# Harus menampilkan list, bukan error

# Keluar dari console
exit()
```

---

## 11. IDE Setup

### VS Code (Recommended)

Install VS Code dari https://code.visualstudio.com/

**Buka project di VS Code:**

```bash
code ~/fundara-dev/apps/fundara
```

**Extensions yang wajib:**

| Extension | Publisher | Fungsi |
|---|---|---|
| Python | Microsoft | Syntax highlight, go-to-definition |
| Pylance | Microsoft | Type checking, IntelliSense |
| ESLint | Microsoft | Linting JavaScript Frappe |
| Ruff | Astral Software | Fast Python linter (opsional, tapi sangat recommended) |

Install via Command Palette (`Ctrl+Shift+P` / `Cmd+Shift+P`) → "Extensions: Install Extensions".

**Konfigurasi Python path ke bench virtualenv:**

Buat file `.vscode/settings.json` di dalam direktori `apps/fundara/`:

```bash
mkdir -p ~/fundara-dev/apps/fundara/.vscode
```

Buat file `.vscode/settings.json`:

```json
{
  "python.defaultInterpreterPath": "${workspaceFolder}/../../../env/bin/python",
  "python.analysis.extraPaths": [
    "${workspaceFolder}/../../../apps/frappe",
    "${workspaceFolder}/../../../apps/erpnext",
    "${workspaceFolder}/../../../apps/fundara"
  ],
  "python.analysis.typeCheckingMode": "basic",
  "editor.formatOnSave": true,
  "python.formatting.provider": "none",
  "[python]": {
    "editor.defaultFormatter": "ms-python.python"
  },
  "eslint.workingDirectories": [
    "${workspaceFolder}/public"
  ],
  "files.exclude": {
    "**/__pycache__": true,
    "**/*.pyc": true
  }
}
```

> **Catatan path:** `${workspaceFolder}/../../../env/bin/python` mengasumsikan workspace dibuka di `apps/fundara/`. Path ini menunjuk ke virtualenv di `~/fundara-dev/env/`. Sesuaikan jika Anda membuka workspace dari direktori yang berbeda.

**Verifikasi Python interpreter:**

Tekan `Ctrl+Shift+P` → "Python: Select Interpreter" → pilih path yang menunjuk ke `~/fundara-dev/env/bin/python`. Status bar VS Code akan menampilkan versi Python yang benar.

**Linting untuk pattern Frappe:**

Frappe menggunakan beberapa pattern yang perlu dikecualikan dari linter standar. Buat atau edit `.vscode/settings.json` untuk menambahkan:

```json
{
  "python.analysis.ignore": [],
  "python.linting.pylintEnabled": false,
  "python.linting.flake8Enabled": false
}
```

Frappe menggunakan `frappe.db`, `frappe.get_doc()`, dan `frappe.get_all()` sebagai global — Pylance akan mendeteksi ini sebagai undefined jika `extraPaths` tidak dikonfigurasi dengan benar seperti di atas.

---

## 12. Useful Development Commands

Semua command bench dijalankan dari direktori bench (`~/fundara-dev`).

| Command | Fungsi |
|---|---|
| `bench start` | Start semua service (web, worker, scheduler, watch) |
| `bench restart` | Restart semua service tanpa keluar |
| `bench stop` | Stop semua service |
| `bench logs` | Tampilkan real-time log dari semua service |
| `bench --site fundara.local console` | Python REPL dengan konteks Frappe penuh — untuk debug dan eksplorasi data |
| `bench --site fundara.local mariadb` | Buka MariaDB shell langsung ke database site ini |
| `bench --site fundara.local clear-cache` | Hapus Redis cache — jalankan ini setelah ubah hooks.py atau config |
| `bench --site fundara.local migrate` | Jalankan pending database migrations — jalankan setelah pull perubahan DocType |
| `bench build --app fundara` | Rebuild frontend assets Fundara (JS/CSS) |
| `bench build --force` | Force rebuild semua assets semua app |
| `bench --site fundara.local run-tests --app fundara` | Jalankan seluruh test suite Fundara |
| `bench --site fundara.local run-tests --app fundara --module fund_stewardship` | Jalankan test untuk satu modul |
| `bench --site fundara.local execute fundara.fund_stewardship.doctype.fund.fund.some_method` | Jalankan satu fungsi Python dengan Frappe context |
| `bench --site fundara.local export-doc "DocType" "Fund"` | Export DocType definition ke JSON file di app |
| `bench get-app --branch version-16 erpnext` | Ambil atau update app dari Git |
| `bench update --apps fundara` | Update Fundara app dari Git dan jalankan migrate |
| `bench backup` | Backup database dan files site aktif |
| `bench --site fundara.local set-config key value` | Set satu config value di site_config.json |

**Contoh penggunaan bench console:**

```python
# Ambil satu document
fund = frappe.get_doc("Fund", "FUND-2026-0001")
print(fund.status)

# Query database
funds = frappe.get_all("Fund", filters={"status": "Active"}, fields=["name", "fund_type"])
print(funds)

# Debug GL entries
entries = frappe.get_all("GL Entry", filters={"voucher_no": "ACC-JV-2026-0001"})
print(entries)

# Jalankan fungsi custom
result = frappe.call("fundara.fund_stewardship.doctype.fund.fund.get_available_balance", fund="FUND-2026-0001")
print(result)
```

---

## 13. Troubleshooting Common Setup Issues

### MariaDB "Access denied for user 'root'"

**Gejala:** `bench new-site` gagal dengan error `Access denied for user 'root'@'localhost'`.

**Penyebab:** Password root MariaDB salah, atau MariaDB menggunakan unix socket authentication.

**Fix:**

```bash
# Masuk ke MariaDB sebagai root via sudo (bypass password)
sudo mysql -u root

# Di dalam MySQL prompt:
ALTER USER 'root'@'localhost' IDENTIFIED BY 'password_baru_anda';
FLUSH PRIVILEGES;
EXIT;
```

Kemudian ulangi `bench new-site` dengan password yang benar.

---

### Port 8000 Already in Use

**Gejala:** `bench start` langsung error "Address already in use port 8000".

**Fix:**

```bash
# Cari proses yang memakai port 8000
lsof -i :8000
# atau
ss -tlnp | grep 8000

# Kill proses tersebut (ganti PID dengan angka dari output di atas)
kill -9 <PID>

# Jika ada bench lain yang sudah berjalan di background:
bench stop
bench start
```

---

### wkhtmltopdf Version Mismatch

**Gejala:** Print/PDF generation gagal dengan error `wkhtmltopdf` atau PDF tampil kosong.

**Diagnosis:**

```bash
wkhtmltopdf --version
# Harus menampilkan: wkhtmltopdf 0.12.6 (with patched qt)
```

Jika versinya berbeda (misal 0.12.4 dari apt), uninstall dulu:

```bash
# Ubuntu/Debian
sudo apt remove wkhtmltopdf
# Install ulang versi 0.12.6 dari GitHub (lihat langkah 2A)
```

---

### `bench start` Hangs on Watchman

**Gejala:** `bench start` berjalan tapi proses `watch` tidak muncul atau hang.

**Penyebab:** watchman (file watcher daemon) crash atau tidak terinstall dengan benar.

**Fix:**

```bash
# Matikan watchman jika berjalan
watchman shutdown-server 2>/dev/null || true

# Atau skip watch process sepenuhnya (tidak rebuild assets otomatis)
# Edit Procfile di ~/fundara-dev/
# Comment atau hapus baris yang dimulai dengan "watch:"
```

Alternatif: rebuild assets secara manual saat diperlukan dengan `bench build --app fundara`.

---

### Apple Silicon (M1/M2/M3) Specific Issues

**Issue 1: `pip install frappe-bench` gagal dengan error kompilasi**

```bash
# Pastikan Xcode CLI tools terinstall
xcode-select --install

# Pastikan menggunakan Python dari pyenv (bukan system Python)
which python   # harus menunjuk ke ~/.pyenv/shims/python
```

**Issue 2: MariaDB tidak bisa start**

```bash
# Cek apakah port 3306 dipakai oleh MySQL (bukan MariaDB)
brew services list | grep mysql
brew services stop mysql   # jika ada MySQL yang berjalan

brew services restart mariadb@10.11
```

**Issue 3: node_modules build error untuk native modules**

```bash
# Pastikan menggunakan Node.js dari nvm, bukan system Node
which node   # harus ~/.nvm/versions/node/v18.x.x/bin/node

# Rebuild native modules
cd ~/fundara-dev
npm rebuild
```

**Issue 4: `bench init` lambat sekali**

Normal — npm install pada Apple Silicon kadang lebih lambat dari Intel. Tunggu hingga selesai. Pastikan tidak ada antivirus atau time machine backup yang scan directory `~/fundara-dev` saat proses install.

---

### WSL2 Clock Drift Causing Issues

**Gejala:** SSL certificate errors, git fetch gagal, atau JWT token invalid saat WSL2 dihidupkan kembali dari sleep.

**Penyebab:** WSL2 VM clock bisa drift saat laptop sleep/resume.

**Fix:**

```bash
# Sync clock WSL2 secara manual
sudo hwclock -s
# atau
sudo ntpdate pool.ntp.org
```

**Fix permanen** — buat script yang auto-sync saat WSL start. Tambahkan ke `~/.bashrc` atau `~/.zshrc`:

```bash
# Auto-sync clock on WSL start
if grep -q Microsoft /proc/version 2>/dev/null; then
    sudo hwclock -s 2>/dev/null || true
fi
```

Tambahkan juga ke `/etc/sudoers` agar tidak perlu password:

```bash
echo "$USER ALL=(ALL) NOPASSWD: /sbin/hwclock" | sudo tee -a /etc/sudoers.d/hwclock
```

---

### `node_modules` Not Found After bench init

**Gejala:** `bench start` gagal dengan "Cannot find module" atau `watch` process error.

**Penyebab:** `npm install` gagal di tengah jalan saat `bench init`.

**Fix:**

```bash
cd ~/fundara-dev

# Install ulang node dependencies
npm install

# Jika masih error, hapus node_modules dan install ulang
rm -rf node_modules
npm install

# Verifikasi
ls node_modules | head -5   # harus menampilkan folder
```

---

## Langkah Selanjutnya

Setelah setup selesai dan semua checklist di bagian 10 centang, Anda siap mulai coding.

Baca dokumen ini sebelum menulis kode pertama:

1. `DECISIONS.md` — 6 keputusan arsitektur yang sudah final dan tidak boleh dilanggar
2. `CONTRIBUTING.md` bagian 3 (struktur app) dan 4 (konvensi DocType)
3. `docs/spec/doctypes/` — field spec untuk DocType yang akan Anda kerjakan
4. `roadmap.md` — scope MVP dan prioritas fitur

Lihat juga tabel referensi lengkap di `CONTRIBUTING.md` bagian 10.
