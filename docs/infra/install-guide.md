# Panduan Instalasi Dev Server — Fundara

**Versi dokumen:** 1.0.0  
**Tanggal:** 20 Juni 2026  
**Penulis:** Gareng (DevOps)  
**Berlaku untuk:** Sprint 0 — Setup dev server

---

## Catatan Penting: Versi yang Digunakan

> **⚠ environment-spec.md saat ini TIDAK AKURAT untuk Frappe v16.23+**
>
> `docs/infra/environment-spec.md` mencantumkan Python 3.12.x dan Node.js 18.x.
> Frappe v16.23.0 ke atas mensyaratkan:
> - **Python ≥ 3.14, < 3.15** (bukan 3.12)
> - **Node.js ≥ 24** (bukan 18.x)
>
> Gunakan panduan di bawah ini — bukan environment-spec.md — untuk instalasi baru.
> Issue update untuk environment-spec.md ada di action item AI-SPEC-01.

### Versi yang terverifikasi berjalan

| Komponen       | Versi           | Catatan                              |
|----------------|-----------------|--------------------------------------|
| OS             | Ubuntu 24.04.4  | LTS                                  |
| Python         | 3.14.6          | Dari PPA deadsnakes                  |
| Node.js        | 24.17.0         | Dari NodeSource                      |
| Yarn           | 1.22.22         | Classic                              |
| MariaDB        | 10.11.18        | utf8mb4 + utf8mb4_unicode_ci         |
| Redis          | 7.0.15          | System service                       |
| wkhtmltopdf    | 0.12.6.1        | Patched Qt                           |
| frappe-bench   | 5.31.0          | pip install --break-system-packages  |
| Frappe         | 16.23.0         | Branch version-16                    |
| ERPNext        | 16.23.1         | Branch version-16                    |
| Fundara app    | 0.0.1 (scaffold)| bench new-app fundara                |

---

## Prasyarat

- Ubuntu Server 24.04.4 LTS (fresh install)
- Akses sudo
- Koneksi internet
- User dengan home directory (dokumen ini menggunakan user `gareng`)
- Group `fundara` sudah ada dengan anggota: `bagong`, `semar`, `petruk`, `gareng`

Buat group jika belum ada:

```bash
sudo groupadd fundara
sudo usermod -aG fundara bagong
sudo usermod -aG fundara semar
sudo usermod -aG fundara petruk
sudo usermod -aG fundara gareng
```

---

## 1. Instalasi System Dependencies

```bash
sudo apt-get update && sudo apt-get upgrade -y

sudo apt-get install -y \
  git curl wget software-properties-common \
  build-essential pkg-config libssl-dev \
  python3-pip python3-venv \
  nginx supervisor \
  libmariadb-dev libffi-dev libjpeg-dev libpng-dev \
  redis-server
```

---

## 2. Instalasi Python 3.14

Ubuntu 24.04 hanya menyertakan Python 3.12.x. Frappe 16.23+ membutuhkan Python 3.14. Gunakan PPA deadsnakes:

```bash
sudo add-apt-repository -y ppa:deadsnakes/ppa
sudo apt-get update
sudo apt-get install -y python3.14 python3.14-venv python3.14-dev
```

Verifikasi:

```bash
python3.14 --version
# Python 3.14.6
```

---

## 3. Instalasi Node.js 24.x

Jangan gunakan Node.js dari apt default (versinya terlalu lama). Gunakan NodeSource:

```bash
curl -fsSL https://deb.nodesource.com/setup_24.x | sudo -E bash -
sudo apt-get install -y nodejs
```

Install Yarn:

```bash
sudo npm install -g yarn
```

Verifikasi:

```bash
node --version   # v24.x.x
yarn --version   # 1.22.x
```

---

## 4. Instalasi MariaDB 10.11

```bash
sudo apt-get install -y mariadb-server mariadb-client
sudo systemctl enable --now mariadb
```

Konfigurasi karakter set untuk kompatibilitas Frappe:

```bash
sudo tee /etc/mysql/mariadb.conf.d/99-frappe.cnf > /dev/null <<'EOF'
[mysqld]
character-set-client-handshake = FALSE
character-set-server            = utf8mb4
collation-server                = utf8mb4_unicode_ci

[mysql]
default-character-set = utf8mb4
EOF

sudo systemctl restart mariadb
```

Set password root MariaDB (bench memerlukan password untuk membuat database site):

```bash
sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'GANTI_DENGAN_PASSWORD_KUAT'; FLUSH PRIVILEGES;"
```

> **Catatan keamanan:** Password MariaDB root tidak boleh sama dengan password lain.
> Simpan di password manager tim. Tidak boleh di-commit ke git.

---

## 5. Instalasi wkhtmltopdf

Frappe membutuhkan wkhtmltopdf versi patched-Qt untuk generate PDF:

```bash
wget https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-3/wkhtmltox_0.12.6.1-3.jammy_amd64.deb
sudo apt-get install -y ./wkhtmltox_0.12.6.1-3.jammy_amd64.deb
rm wkhtmltox_0.12.6.1-3.jammy_amd64.deb
```

Verifikasi:

```bash
wkhtmltopdf --version
# wkhtmltopdf 0.12.6.1 (with patched qt)
```

---

## 6. Instalasi Frappe Bench

Karena Ubuntu 24.04 menggunakan PEP 668 (externally-managed-environment), diperlukan flag `--break-system-packages`:

```bash
pip3 install frappe-bench --break-system-packages
```

Verifikasi:

```bash
bench --version
# 5.31.0
```

---

## 7. Inisialisasi Bench di /opt/fundara

Bench harus diinit langsung di `/opt/fundara/` (bukan subdirektori). Sebelum init, pastikan direktori tidak ada atau kosong:

```bash
# Jika /opt/fundara sudah ada dan ingin mulai ulang:
sudo rm -rf /opt/fundara

# Beri write sementara ke /opt agar user non-root bisa membuat direktori:
sudo chmod o+w /opt

bench init /opt/fundara \
  --frappe-branch version-16 \
  --python python3.14

# Cabut write ke /opt segera setelah selesai:
sudo chmod o-w /opt
```

> **Mengapa `--python python3.14`?** Bench membuat virtualenv menggunakan Python yang ditentukan. Tanpa flag ini, bench menggunakan python3 default sistem (3.12) yang tidak kompatibel dengan Frappe 16.23+.

Verifikasi bench init berhasil:

```bash
ls /opt/fundara/
# apps  config  env  logs  Procfile  patches.txt  sites
```

---

## 8. Install ERPNext

```bash
cd /opt/fundara
bench get-app --branch version-16 erpnext
```

Proses ini membutuhkan waktu ~5-15 menit tergantung koneksi.

---

## 9. Membuat Fundara Custom App

> **Penting:** GitHub repo `masmaksum/Fundara` adalah repository dokumentasi, bukan kode Frappe app.
> Gunakan `bench new-app` untuk membuat scaffold app yang proper.

```bash
cd /opt/fundara
printf "Fundara\nFund-centric ERP for Indonesian NGOs\nFundara Team\nbagong@combine.id\nmit\nN\nmain\n" | bench new-app fundara
```

Jawaban untuk setiap prompt:
- App Title: `Fundara`
- App Description: `Fund-centric ERP for Indonesian NGOs`
- App Publisher: `Fundara Team`
- App Email: `bagong@combine.id`
- App License: `mit`
- Create GitHub Workflow: `N`
- Branch Name: `main`

---

## 10. Setup Redis untuk Bench

Bench membutuhkan instance Redis tersendiri (port 11000 dan 13000), berbeda dari Redis sistem (port 6379):

```bash
cd /opt/fundara
bench setup redis
```

Start Redis bench:

```bash
redis-server /opt/fundara/config/redis_cache.conf --daemonize yes
redis-server /opt/fundara/config/redis_queue.conf --daemonize yes
```

Verifikasi:

```bash
redis-cli -p 13000 ping  # PONG
redis-cli -p 11000 ping  # PONG
```

> **Catatan:** Pada production, ini dikelola oleh Supervisor. Pada dev, jalankan manual atau tambahkan ke `rc.local` / systemd unit.

---

## 11. Membuat Site Dev

```bash
cd /opt/fundara
bench new-site fundara-dev.local \
  --admin-password GANTI_ADMIN_PASSWORD \
  --mariadb-root-username root \
  --mariadb-root-password GANTI_DB_ROOT_PASSWORD \
  --install-app erpnext \
  --install-app fundara
```

Tambahkan ke `/etc/hosts`:

```bash
echo "127.0.0.1 fundara-dev.local" | sudo tee -a /etc/hosts
```

---

## 12. Aktifkan Developer Mode

```bash
cd /opt/fundara
bench --site fundara-dev.local set-config developer_mode 1
```

Verifikasi di `sites/fundara-dev.local/site_config.json`:
```json
{
 "developer_mode": 1,
 ...
}
```

---

## 13. Set Permissions Group

Agar semua anggota tim (semar, petruk, bagong) bisa bekerja di bench yang sama:

```bash
sudo chown -R bagong:fundara /opt/fundara/
sudo chmod -R g+w /opt/fundara/
sudo find /opt/fundara -type d -exec chmod g+s {} \;
```

Verifikasi:

```bash
ls -la /opt/fundara/
# Semua entry harus: owner=bagong, group=fundara, permission drwxrwsr-x
```

---

## 14. Buat Akun User Frappe

Setelah Redis bench aktif (langkah 10):

```bash
cd /opt/fundara
bench --site fundara-dev.local add-user "semar@fundara.id" \
  --first-name "Semar" --last-name "Dev" --password "GANTI_PASSWORD"

bench --site fundara-dev.local add-user "petruk@fundara.id" \
  --first-name "Petruk" --last-name "Dev" --password "GANTI_PASSWORD"
```

---

## 15. Menjalankan Dev Server

```bash
cd /opt/fundara
bench start
```

Akses di browser: `http://fundara-dev.local:8000`

Login default: `Administrator` / (password yang disetel saat `bench new-site`)

---

## Ringkasan Exit Criteria Sprint 0

| # | Kriteria                                           | Status |
|---|-----------------------------------------------------|--------|
| 1 | Node.js 24.x terinstall                            | ✅     |
| 2 | MariaDB 10.11 terinstall + utf8mb4                 | ✅     |
| 3 | Redis 7.x terinstall                               | ✅     |
| 4 | bench init di /opt/fundara/ dengan Python 3.14     | ✅     |
| 5 | ERPNext v16 terinstall                             | ✅     |
| 6 | Fundara app scaffold terinstall                    | ✅     |
| 7 | Site fundara-dev.local dibuat + developer_mode=1   | ✅     |
| 8 | Group permission fundara:2775 di /opt/fundara/     | ✅     |
| 9 | User semar dan petruk dibuat di Frappe             | ✅     |

---

## Troubleshooting

### bench init gagal: "Bench instance already exists"

`/opt/fundara/` sudah ada (dari sesi sebelumnya). Hapus dulu:

```bash
sudo rm -rf /opt/fundara
sudo chmod o+w /opt
bench init /opt/fundara --frappe-branch version-16 --python python3.14
sudo chmod o-w /opt
```

### bench init gagal: pkg-config not found

```bash
sudo apt-get install -y pkg-config
```

### bench get-app / bench new-site gagal: Redis connection refused

Redis bench belum jalan. Jalankan langkah 10 terlebih dahulu.

### bench new-site gagal: EOF / password prompt tidak bisa diisi

MariaDB root menggunakan unix_socket auth (tidak ada password). Set password dulu:

```bash
sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'PASSWORD_BARU'; FLUSH PRIVILEGES;"
```

### Fundara app: FileNotFoundError setup.py

Ini terjadi jika mencoba `bench get-app https://github.com/masmaksum/Fundara` — repo tersebut adalah dokumentasi, bukan Frappe app. Gunakan `bench new-app fundara` seperti di langkah 9.

---

*Dokumen ini dibuat berdasarkan instalasi aktual di dev server pada 20 Juni 2026.*
*Jika ada perbedaan dengan `environment-spec.md`, gunakan dokumen ini — spec sedang dalam proses update.*
