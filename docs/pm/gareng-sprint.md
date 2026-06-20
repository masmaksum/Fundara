# Sprint Plan — Gareng (DevOps & Infrastruktur)

**Role:** DevOps & Infrastruktur  
**Akun:** gareng  
**Server dev:** server ini (`/opt/fundara/`) — Semar dan Petruk bekerja simultan di sini  
**Dokumen ini:** rencana kerja Gareng per sprint, terpisah dari complexity.md yang fokus ke Dev 1 & Dev 2 (Semar & Petruk).  
**Last updated:** 2026-06-20

---

## Prinsip Penyusunan

1. **Infra harus siap sebelum dev mulai** — Sprint 1 dev tidak bisa jalan tanpa environment yang hidup.
2. **Urutan: install base → staging → backup dasar → monitoring → production.**
3. **Skip dulu yang post-development:** `upgrade-runbook.md` dan `multisite-guide.md` tidak relevan sebelum ada production yang berjalan — ditunda ke post-MVP.
4. Gareng bekerja **paralel** dengan sprint dev, bukan setelahnya.

---

## Peta Dokumen Infra vs Prioritas

| Dokumen | Ada? | Prioritas | Kapan Dieksekusi |
|---|---|---|---|
| Base install guide (bench + ERPNext + Fundara) | **BELUM ADA** | **KRITIS** | Pre-Sprint / Sprint 0 |
| `environment-spec.md` | ✅ | Referensi | Dibaca sebelum install |
| `deploy.sh` | ✅ | Tinggi | Sprint 0 & Sprint 1 |
| `backup-recovery.md` + `backup.sh` | ✅ | Tinggi | Sprint 2 |
| `monitoring-spec.md` + `setup-monitoring.sh` | ✅ | Sedang | Sprint 5 |
| `upgrade-runbook.md` | ✅ | **SKIP — post-MVP** | Setelah ada versi pertama di prod |
| `multisite-guide.md` | ✅ | **SKIP — post-MVP** | Setelah org kedua onboard |

---

## Sprint 0 — Minggu 0 (Sebelum Sprint 1 Dev Mulai)

**Tujuan:** `/opt/fundara/` hidup sebagai shared dev bench. Semar dan Petruk bisa mulai coding di hari pertama Sprint 1.

**Konteks server:**
- Server ini IS the dev server — Semar, Petruk, Gareng bekerja simultan di sini
- Working directory: `/opt/fundara/` (sudah ada, permission `2775`, group `fundara`)
- Semua tim sudah dalam group `fundara`: `bagong, semar, petruk, gareng`
- Python 3.12.3 sudah ada. Yang belum: Node.js, MariaDB, Redis, bench

### Tugas

**0-A. Install base dependencies (sudo)**

Referensi versi: `docs/infra/environment-spec.md` section 1.3

```bash
# Node.js 18.x LTS
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs
sudo npm install -g yarn

# MariaDB 10.11 + konfigurasi charset utf8mb4
sudo apt install -y mariadb-server mariadb-client

# Redis 7
sudo apt install -y redis-server

# wkhtmltopdf 0.12.6 patched Qt  ← VERSI SPESIFIK, versi lain merusak PDF
# (download manual dari github.com/wkhtmltopdf/packaging/releases)

# Dependencies bench
sudo apt install -y git xvfb libfontconfig supervisor nginx

# frappe-bench
pip3 install frappe-bench
```

**0-B. Inisialisasi bench di `/opt/fundara/`**

`/opt/fundara/` IS the bench — bukan subdirektori di dalamnya.

```bash
# Hapus isi dulu jika ada (direktori harus kosong untuk bench init)
cd /opt
sudo bench init --frappe-branch version-16 fundara

# Install apps
cd /opt/fundara
bench get-app --branch version-16 erpnext
bench get-app fundara https://github.com/masmaksum/Fundara
bench new-site fundara-dev.local --install-app erpnext --install-app fundara
bench --site fundara-dev.local set-config developer_mode 1
```

**0-C. Permission untuk kerja simultan**

```bash
# Semua file bisa ditulis group fundara
sudo chown -R bagong:fundara /opt/fundara/
sudo chmod -R g+w /opt/fundara/
sudo find /opt/fundara/ -type d -exec chmod g+s {} \;

# Supervisor: bench dikelola Gareng — tim tidak perlu start sendiri
bench setup supervisor
sudo supervisorctl reread && sudo supervisorctl update
```

**0-D. Akses tim**

- `/etc/hosts` di server: `127.0.0.1  fundara-dev.local`
- Semar dan Petruk akses Frappe via browser (SSH tunnel atau satu jaringan)
- Buat akun Frappe untuk Semar dan Petruk (bukan akun Linux)
- Git: masing-masing checkout branch sendiri di `/opt/fundara/apps/fundara/`

**0-E. Verifikasi**

```
[ ] supervisor / bench berjalan tanpa error
[ ] http://fundara-dev.local:8000 bisa diakses
[ ] Login Administrator berhasil
[ ] ERPNext terinstall (cek Installed Apps)
[ ] Fundara app terinstall
[ ] Developer mode aktif (DocType bisa di-export)
[ ] Semar bisa login dengan akun Frappe-nya
[ ] Petruk bisa login dengan akun Frappe-nya
[ ] File baru di /opt/fundara/ group-nya fundara (touch /opt/fundara/test && ls -la)
```

**Exit criteria Sprint 0:** Semar dan Petruk bisa buka browser, login, dan mulai buat DocType di hari pertama Sprint 1.

---

## Sprint 1 (Paralel dengan Dev Sprint 1)

**Tujuan:** Staging server siap. Dev tim tidak perlu tunggu infra saat butuh environment non-dev.

### Tugas

**1-A. Provisioning staging server**

Spec minimum (dari `environment-spec.md` section 2.2):
```
4 vCPU, 4–8 GB RAM, 80 GB SSD
Ubuntu Server 24.04.4 LTS
```

**1-B. Install base di staging** (sama dengan Sprint 0, tapi `developer_mode = 0`)

Jalankan `deploy.sh` dengan flag yang sesuai:
```bash
bash deploy.sh --skip-ssl   # sementara, sampai domain ready
```

Atau install manual mengikuti urutan di `deploy.sh`.

**1-C. Nginx + Supervisor**

```bash
bench setup nginx
bench setup supervisor
sudo bench setup production frappe
```

**1-D. SSL staging** (jika domain sudah ready)

```bash
sudo certbot --nginx -d staging-fundara.DOMAIN.id
```

Nama site mengikuti konvensi `docs/infra/environment-spec.md` section 4:
```
staging-[orgname].fundara.id
```

**1-E. UFW rules staging**

```bash
ufw default deny incoming
ufw allow from <devops_ip> to any port 22
ufw allow 80/tcp
ufw allow 443/tcp
ufw enable
```

**1-F. Akses tim ke staging**

- SSH key: hanya Gareng dan TL
- Frappe user: Semar dan Petruk punya akun Frappe (bukan SSH) untuk testing

**Exit criteria Sprint 1:** `staging-fundara.DOMAIN.id` bisa diakses via HTTPS. Dev bisa push ke staging untuk integration test.

---

## Sprint 2 (Paralel dengan Dev Sprint 2–3)

**Tujuan:** Backup otomatis jalan. Tim tidak kehilangan data staging jika terjadi masalah.

### Tugas

**2-A. Setup backup otomatis staging**

Dari `docs/infra/backup-recovery.md` dan `backup.sh`:

```bash
# Cron job di staging server
0 2 * * * /path/to/backup.sh >> /var/log/fundara-backup.log 2>&1
```

Backup scope: MariaDB dump + private files + public files + site config.

**2-B. Test restore staging**

Prosedur dari `backup-recovery.md` section "Prosedur Restore — DB-only":
```bash
bench --site staging-fundara.DOMAIN.id restore /path/to/backup.sql.gz
```

Pastikan restore berhasil sebelum production setup dimulai.

**2-C. Konfigurasi GPG untuk backup offsite** (jika offsite storage sudah ada)

```bash
gpg --symmetric --cipher-algo AES256 backup.tar.gz
```

**2-D. Notifikasi backup**

Konfigurasi alert email/Telegram jika backup cron gagal (dari `backup.sh`).

**Exit criteria Sprint 2:** Backup staging berjalan otomatis tiap malam. Restore pernah dicoba dan berhasil.

---

## Sprint 5 (Sebelum Demo Pertama / UAT Milestone 1)

**Tujuan:** Staging dalam kondisi production-like untuk UAT. Monitoring dasar aktif.

### Tugas

**5-A. Monitoring dasar — Uptime Kuma**

Dari `docs/infra/monitoring-spec.md` dan `setup-monitoring.sh`:

```bash
bash setup-monitoring.sh
```

Setup monitor untuk:
- HTTP(S) site staging — alert jika down
- Port 3306, 6379 (internal check)

**5-B. Health endpoint check**

Verify endpoint Fundara yang akan dimonitor:
```
/api/method/fundara.api.health
```

Endpoint ini harus return `200 OK` sebelum UAT.

**5-C. Staging data reset**

Reset data staging ke kondisi bersih + load demo dataset (dari `docs/qa/demo-data.md`) untuk UAT Milestone 1.

**5-D. 2FA check staging**

Pastikan Finance Manager dan Executive Director role di staging sudah enforce 2FA (sesuai `environment-spec.md` section 2.7).

**Exit criteria Sprint 5:** UAT bisa jalan di staging. Gareng bisa terima alert jika site down selama sesi UAT.

---

## Sprint 7–8 (Paralel dengan Dev Sprint 6–8)

**Tujuan:** Monitoring penuh aktif. Infra siap untuk production.

### Tugas

**7-A. Netdata monitoring**

```bash
bash setup-monitoring.sh   # bagian Netdata
```

Metric yang harus terpantau (dari `monitoring-spec.md`):
```
System: CPU, RAM, disk, network
App: gunicorn workers, background queue length, scheduler
Business: overdue advance count, pending GL entries
```

**7-B. Custom business metrics scheduled job**

Wiring `fundara.api.health` ke Netdata custom metrics (dari `monitoring-spec.md` section "Business Metrics").

**7-C. Alert thresholds**

Konfigurasi alert di Netdata:
```
CPU > 80% selama 5 menit → alert
RAM > 85% → alert
Disk > 80% → alert
Site down → alert Uptime Kuma
```

**7-D. Backup offsite ke S3-compatible storage**

Konfigurasi rclone ke Wasabi/Backblaze B2 (dari `backup-recovery.md`):
```bash
rclone copy /backup/fundara/ remote:fundara-backup/
```

Retention: 30 hari daily, 12 bulan monthly (dari `environment-spec.md` section 3.10).

**Exit criteria Sprint 7–8:** Gareng menerima alert jika ada masalah. Backup offsite berjalan dan terverifikasi.

---

## Sprint 9–10 (Sebelum Go-live)

**Tujuan:** Production server siap. Security hardening selesai.

### Tugas

**9-A. Provisioning production server**

Spec Profile B atau C (dari `environment-spec.md` section 3.2):
```
Profile B (Small NGO): 4 vCPU, 8 GB RAM, 150 GB SSD
```

**9-B. Install production**

```bash
bash deploy.sh   # tanpa --skip-ssl, tanpa --dry-run
```

`developer_mode = 0`, password kuat, semua production config dari `environment-spec.md`.

**9-C. Security hardening production**

```bash
# fail2ban
apt install fail2ban
# SSH hardening
PasswordAuthentication no
PermitRootLogin no
AllowUsers gareng
# UFW
ufw allow from <gareng_ip> to any port 22
ufw allow 80/tcp && ufw allow 443/tcp
ufw enable
```

**9-D. 2FA enforcement production**

Mandatory untuk: Finance Manager, Finance Officer, System Manager, Executive Director.

**9-E. Restore drill production**

Dari backup staging, restore ke production clean instance. Verifikasi data intact.

**9-F. RPO/RTO test**

- RPO target: 24 jam (backup harian)
- RTO target: 4 jam (restore dari backup)
- Dokumentasikan waktu aktual restore di test ini

**9-G. pip audit + npm audit**

```bash
cd fundara-bench
./env/bin/pip audit
npm audit --prefix apps/frappe
npm audit --prefix apps/erpnext
```

Fix CVE CRITICAL dalam 7 hari, CVE HIGH dalam 30 hari.

**Exit criteria Sprint 9–10:** Production server live, HTTPS, backup running, monitoring active, 2FA enforced, security audit clean.

---

## Yang Dilewati Sekarang (Post-MVP)

| Dokumen | Alasan Skip | Kapan Diambil |
|---|---|---|
| `upgrade-runbook.md` | Tidak ada versi di production dulu yang perlu di-upgrade | Setelah production berjalan ≥ 1 sprint |
| `multisite-guide.md` | Multi-tenant belum jadi keputusan (D-06 deferred) | Setelah org kedua onboard, dan D-06 resolved |

---

## Ringkasan Timeline Gareng

```
Minggu 0       → Sprint 0: Dev server hidup (base install + bench + Fundara)
Minggu 1–2     → Sprint 1: Staging server live (deploy.sh + Nginx + SSL)
Minggu 3–6     → Sprint 2: Backup otomatis + restore drill staging
Minggu 9–10    → Sprint 5: Monitoring dasar (Uptime Kuma) + staging UAT-ready
Minggu 13–16   → Sprint 7–8: Monitoring penuh (Netdata) + backup offsite
Minggu 17–20   → Sprint 9–10: Production server + hardening + go-live
```

---

## Hal yang Perlu Diputuskan (Action Item untuk PM)

| # | Item | PIC | Deadline |
|---|---|---|---|
| AI-G1 | Domain production dan staging sudah ditetapkan? (`[org].fundara.id`) | Banas (PO) | Sebelum Sprint 1 |
| AI-G2 | Offsite backup storage: Wasabi / Backblaze / lainnya — siapa yang buka akun? | Bagong (PM) | Sebelum Sprint 2 |
| AI-G3 | SMTP relay untuk email notifikasi production — siapa yang setup? | Bagong (PM) | Sebelum Sprint 9 |
| AI-G4 | Server production: cloud provider mana, siapa yang bayar? | Banas (PO) | Sebelum Sprint 8 |

---

## Dokumen yang Perlu Dibuat Gareng (Belum Ada)

| Dokumen | Isi | Target |
|---|---|---|
| `docs/infra/install-guide.md` | Langkah install base dari nol di Ubuntu 24.04.4 (prose, bukan script) | Sprint 0 |
| `docs/infra/staging-runbook.md` | Prosedur harian Gareng di staging: reset data, sync dari prod, maintenance mode | Sprint 2 |

> `local-setup.md` di `docs/dev/` adalah untuk developer di mesin lokal, bukan untuk Gareng di server. Install server memerlukan dokumen terpisah.
