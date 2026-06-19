# Incident Response Plan — Fundara

**Version:** 1.0
**Last Updated:** 2026-06-19
**Audience:** Tech Lead, DevOps, System Manager, PM
**Status:** Aktif — review tahunan, atau setelah setiap insiden nyata

Dokumen ini adalah playbook respons insiden untuk Fundara production. Ikuti fase-fase di bawah secara berurutan. Jangan skip fase.

---

## 1. Definisi Insiden

| Klasifikasi | Contoh | Response Time Target |
|---|---|---|
| **Critical** | Breach data donor/keuangan, ransomware, akses tidak sah ke production DB, data exfiltration | 1 jam |
| **High** | Akun privileged (Finance Manager, System Admin) dikompromis, vulnerability kritis ditemukan di production, defacement | 4 jam |
| **Medium** | Login anomali yang belum terkonfirmasi sebagai breach, file mencurigakan ditemukan di server, laporan user tentang perubahan data yang tidak diotorisasi | 24 jam |
| **Low** | Spike failed login yang belum ada indikasi breach, vulnerability ditemukan di staging, akun dengan aktivitas tidak biasa | 3 hari kerja |

**Aturan eskalasi:** Jika ada keraguan antara dua klasifikasi, pilih yang lebih tinggi. Lebih baik over-respond ke Low daripada under-respond ke Critical.

---

## 2. Tim Respons

| Peran | Tanggung Jawab | Siapa (isi saat onboarding) |
|---|---|---|
| **Incident Commander** | Koordinasi keseluruhan, keputusan eskalasi ke manajemen, sign-off pada containment dan recovery | Tech Lead: _______________ |
| **Technical Responder** | Investigasi teknis, eksekusi containment, remediation, restore | DevOps: _______________ + Dev yang relevan |
| **Communication Lead** | Komunikasi ke stakeholder internal, draft notifikasi ke subjek data terdampak, koordinasi notifikasi ke Kominfo/BSSN | PM: _______________ |
| **Evidence Collector** | Preserve log, screenshot, chain of custody — jangan izinkan siapapun mengubah atau menghapus evidence sebelum dikumpulkan | Tech Lead / QA: _______________ |

**Kontak darurat (isi sebelum go-live):**

| Pihak | Kontak | Metode |
|---|---|---|
| Tech Lead | _______________ | WhatsApp / Telegram |
| DevOps | _______________ | WhatsApp / Telegram |
| PM | _______________ | WhatsApp / Telegram |
| Manajemen organisasi (CEO/Direktur) | _______________ | Telepon langsung |
| Kominfo (notifikasi UU PDP) | https://kominfo.go.id | Form online + surat resmi |
| BSSN (jika insiden siber) | https://bssn.go.id | Form online |

---

## 3. Alur Response — 5 Fase

### Fase 1: Identifikasi (Detection)

#### Sumber Penemuan

- **Uptime Kuma:** downtime alert atau anomali response time
- **Netdata:** spike CPU/memory/disk yang tidak wajar
- **Frappe Activity Log:** banyak failed login, akses dari IP asing, perubahan data massal di luar jam kerja
- **Laporan user:** "saya tidak bisa login", "ada data yang berubah sendiri", "ada akun yang tidak saya kenal"
- **Email/notifikasi backup:** backup gagal = bisa indikasi masalah disk atau proses yang terganggu
- **Notifikasi dari security scanner atau pihak eksternal** (misalnya laporan dari NGO lain)

#### Tindakan Pertama

> **Jangan shutdown server dulu.** Memory RAM menyimpan evidence penting (proses aktif, koneksi jaringan, kredensial yang sedang dipakai). Shutdown akan menghapusnya.

1. Screenshot semua yang terlihat — terminal, browser, Uptime Kuma alert, email.
2. Catat: waktu penemuan, siapa yang menemukan, dari mana informasi berasal.
3. Hubungi Incident Commander via telepon (bukan hanya pesan teks).
4. Incident Commander mengklasifikasikan insiden (Critical / High / Medium / Low) dan mengaktifkan tim.
5. Buka war room — grup chat khusus untuk insiden ini (jangan di channel umum).

#### Checklist Fase 1

- [ ] Waktu penemuan dicatat
- [ ] Sumber informasi dicatat
- [ ] Screenshot awal diambil
- [ ] Incident Commander sudah dihubungi
- [ ] Klasifikasi insiden sudah ditentukan
- [ ] War room sudah dibuat

---

### Fase 2: Penahanan (Containment)

Tujuan: hentikan penyebaran. Jangan remediation dulu — remediation setelah investigasi.

#### Containment: Akun Dikompromis

Nonaktifkan akun via Frappe UI:
**HR > User > [username] > Disabled = 1 > Save**

Atau via bench console jika UI tidak bisa diakses:

```bash
bench --site [site-name] console
```

```python
user = frappe.get_doc("User", "email@contoh.com")
user.enabled = 0
user.save(ignore_permissions=True)
frappe.db.commit()
```

Lanjutkan dengan:
- Invalidate semua sesi aktif user tersebut:
  ```python
  frappe.cache().delete_key(f"user_auth_string:{user.name}")
  ```
- Revoke API keys jika user memiliki API access:
  ```python
  frappe.db.delete("API Key", {"user": user.name})
  frappe.db.commit()
  ```

#### Containment: Akses Tidak Sah ke Server / DB

```bash
# Lihat koneksi aktif ke MariaDB
ss -tnp | grep 3306

# Block IP mencurigakan di UFW
ufw deny from [suspicious-ip] to any
ufw status numbered  # verifikasi rule masuk

# Lihat proses aktif yang mencurigakan
ps aux | grep -E "(mysql|python|php|bash)" | sort -k 3 -rn | head -20

# Lihat file yang baru dimodifikasi dalam 1 jam terakhir
find /home/frappe/frappe-bench -newer /tmp/benchmark -type f 2>/dev/null
# (buat /tmp/benchmark dulu: touch -t $(date -d '1 hour ago' +%Y%m%d%H%M) /tmp/benchmark)
```

#### Containment: File Mencurigakan / Webshell

```bash
# Cari file PHP mencurigakan di direktori Frappe
find /home/frappe/frappe-bench -name "*.php" -newer /home/frappe/frappe-bench/apps/fundara -type f
# Cari file dengan permission eksekusi yang tidak wajar
find /home/frappe/frappe-bench/sites -perm /111 -type f -not -name "*.sh"
```

Jangan hapus file mencurigakan dulu — preserve sebagai evidence. Rename dengan ekstensi `.bak` untuk neutralisasi:
```bash
mv suspicious_file.php suspicious_file.php.bak
```

#### Containment: Production Harus Dioffline

Aktifkan maintenance mode (pengguna melihat halaman maintenance, bukan error):

```bash
bench --site [site-name] set-maintenance-mode on
```

Atau jika bench tidak responsif, stop Nginx:
```bash
sudo systemctl stop nginx
# Aktifkan kembali: sudo systemctl start nginx
```

Untuk containment maksimal (izolasi jaringan) — hanya jika situasi sangat ekstrem (ransomware aktif):
- **Cloud/VPS:** ubah Security Group / Firewall rule untuk block semua inbound kecuali IP DevOps
- **Dedicated server:** `ufw deny incoming` (block semua, biarkan DevOps masuk via existing SSH session)

#### Checklist Fase 2

- [ ] Akun yang dikompromis sudah dinonaktifkan
- [ ] IP mencurigakan sudah di-block di UFW
- [ ] Koneksi aktif yang tidak sah sudah diputus
- [ ] Evidence (file, log) sudah di-preserve — tidak dihapus
- [ ] Mode maintenance diaktifkan jika diperlukan
- [ ] Incident Commander dikonfirmasi bahwa containment selesai

---

### Fase 3: Investigasi (Analysis)

Tujuan: pahami apa yang terjadi sebelum melakukan remediation. Jangan remediate dulu.

#### Log Nginx — Akses HTTP

```bash
# Login attempts dalam 24 jam terakhir
grep "POST /api/method/login" /var/log/nginx/access.log | \
    awk '{print $1, $2, $7, $9}' | tail -200

# Semua request dari IP mencurigakan
grep "[suspicious-ip]" /var/log/nginx/access.log | \
    awk '{print $4, $7, $9}' | sort | uniq -c | sort -rn

# Request 4xx dan 5xx yang tidak biasa (scanning?)
awk '$9 ~ /^[45]/' /var/log/nginx/access.log | \
    awk '{print $1, $7, $9}' | sort | uniq -c | sort -rn | head -50

# Request besar yang mungkin exfiltration (bytes sent > 1MB)
awk '$10 > 1000000' /var/log/nginx/access.log | \
    awk '{print $1, $7, $9, $10}' | sort -k4 -rn | head -20
```

#### Log Frappe Activity Log — Aktivitas Aplikasi

Via bench console:

```python
# Login history 48 jam terakhir (semua user)
frappe.db.get_all("Activity Log",
    filters={"operation": "Login", "creation": [">", frappe.utils.add_days(frappe.utils.now(), -2)]},
    fields=["user", "creation", "ip_address", "status"],
    order_by="creation desc",
    limit=200
)

# Login gagal saja
frappe.db.get_all("Activity Log",
    filters={"operation": "Login", "status": "Failed"},
    fields=["user", "creation", "ip_address"],
    order_by="creation desc",
    limit=100
)

# Semua aktivitas dari user yang dicurigai
frappe.db.get_all("Activity Log",
    filters={"user": "email@contoh.com"},
    fields=["operation", "reference_doctype", "reference_name", "creation", "ip_address"],
    order_by="creation desc",
    limit=500
)

# Perubahan data keuangan yang tidak biasa (submit/amend GL Entry)
frappe.db.get_all("Activity Log",
    filters={"reference_doctype": ["in", ["GL Entry", "Journal Entry", "Cash Advance"]]},
    fields=["user", "operation", "reference_name", "creation", "ip_address"],
    order_by="creation desc",
    limit=100
)
```

#### MariaDB Binary Log — Perubahan Database Langsung

Hanya tersedia jika binary logging diaktifkan (lihat `backup-recovery.md` Section 5.5):

```bash
# Lihat operasi tulis dalam window waktu tertentu
mysqlbinlog --start-datetime="2026-06-18 22:00:00" \
            --stop-datetime="2026-06-18 23:59:00" \
            /var/log/mysql/mariadb-bin.000001 | \
    grep -E "(UPDATE|DELETE|INSERT)" | head -100

# Cari perubahan pada tabel keuangan spesifik
mysqlbinlog /var/log/mysql/mariadb-bin.000001 | \
    grep -i "tabGL Entry\|tabJournal Entry\|tabCash Advance" | head -50
```

#### Frappe Version Control — Riwayat Perubahan Record

Via Frappe UI (tidak perlu console): buka record yang mencurigakan, klik **View Versions** di sidebar kanan. Setiap perubahan tercatat dengan user dan timestamp.

Via console untuk audit massal:

```python
# Siapa yang mengubah record tertentu
frappe.db.get_all("Version",
    filters={"ref_doctype": "GL Entry", "docname": "ACC-JV-2026-00123"},
    fields=["owner", "creation", "data"],
    order_by="creation desc"
)
```

#### Checklist Investigasi

- [ ] Timeline insiden terbentuk: kapan pertama kali terjadi
- [ ] Akun / IP yang terlibat sudah diidentifikasi
- [ ] Data apa yang diakses — DocType apa, record mana
- [ ] Apakah ada perubahan data yang tidak sah?
- [ ] Apakah ada data yang kemungkinan di-exfiltrate (request besar ke luar)?
- [ ] Apakah masih ada akses aktif yang belum diputus?
- [ ] Apakah ada webshell atau backdoor yang tertinggal?
- [ ] Semua evidence sudah dicopy ke lokasi aman (bukan hanya di server yang mungkin dikompromis)

---

### Fase 4: Remediasi (Eradication dan Recovery)

Fase ini hanya dimulai setelah Fase 3 selesai. Incident Commander menyatakan investigasi selesai sebelum remediasi dimulai.

#### 4.1 Eradication

Hapus penyebab insiden:

**Reset credential yang mungkin terkompromis:**
```bash
# Reset password via bench
bench --site [site-name] set-admin-password [new-strong-password]

# Reset password user tertentu via console
frappe.utils.password.update_password("email@contoh.com", "NewStrongPassword123!")
frappe.db.commit()
```

**Revoke dan regenerate semua API keys yang mungkin terekspos:**
```python
# Hapus semua API keys existing
frappe.db.delete("API Key", {})
frappe.db.commit()
# Keys baru dibuat oleh masing-masing user setelah recovery
```

**Patch vulnerability yang dieksploitasi:**
```bash
# Update Frappe/ERPNext ke versi yang sudah dipatch
bench update --pull --patch --build --restart
# Atau update apps spesifik:
bench update --apps fundara
```

**Scan untuk webshell dan backdoor:**
```bash
# Cari file PHP tidak dikenal di direktori publik
find /home/frappe/frappe-bench/sites -name "*.php" -type f | \
    while read f; do echo "=== $f ==="; head -3 "$f"; done

# Cari file yang baru dibuat (bukan oleh bench update)
find /home/frappe/frappe-bench -newer /home/frappe/frappe-bench/apps/frappe/setup.py \
    -type f -not -path "*/__pycache__/*" | grep -v ".pyc"

# Verifikasi integritas app code
cd /home/frappe/frappe-bench/apps/fundara
git status  # ada file tidak terduga?
git diff    # ada perubahan yang tidak dicommit?
git log --oneline -10  # commit history sesuai?
```

**Hardening tambahan pasca-insiden (jika relevan):**
```bash
# Ganti SSH port (jika port 22 terlibat dalam insiden)
# Edit /etc/ssh/sshd_config: Port 2222
# Tambah UFW rule baru sebelum hapus yang lama

# Reset fail2ban
fail2ban-client reload
fail2ban-client status sshd

# Regenerate DH params jika TLS terlibat
openssl dhparam -out /etc/nginx/dhparam.pem 2048
```

#### 4.2 Recovery

Setelah eradication selesai dan Incident Commander menyatakan server bersih:

1. **Pilih restore point yang bersih** — backup dari sebelum insiden terjadi. Gunakan timeline yang dibangun di Fase 3 untuk menentukan timestamp bersih.

2. **Verifikasi integritas backup sebelum restore:**
   ```bash
   gpg --batch --passphrase-file /etc/fundara/backup.key \
       --decrypt backup.tar.gz.gpg > /dev/null
   echo "GPG exit: $?"  # Harus 0
   ```

3. **Jalankan restore** sesuai prosedur di `docs/infra/backup-recovery.md`:
   - Full restore: Section 5.1
   - Database only: Section 5.2
   - Pilih prosedur sesuai scope insiden

4. **Uji fungsionalitas setelah restore:**
   ```bash
   bench --site [site-name] doctor
   bench --site [site-name] scheduler status
   ```
   - Login sebagai System Manager
   - Verifikasi record keuangan terakhir sebelum insiden
   - Cek satu file attachment

5. **Monitor intensif 24 jam pertama setelah recovery:**
   - Pantau Netdata secara aktif
   - Cek Nginx access log setiap jam
   - Aktifkan notifikasi real-time dari Uptime Kuma

6. **Matikan maintenance mode:**
   ```bash
   bench --site [site-name] set-maintenance-mode off
   ```

#### Checklist Fase 4

- [ ] Semua credential terkompromis sudah di-reset
- [ ] API keys sudah di-revoke dan regenerate
- [ ] Vulnerability sudah dipatch atau di-mitigate
- [ ] Scan webshell/backdoor selesai — tidak ada temuan (atau temuan sudah dihapus)
- [ ] Integritas app code diverifikasi via git
- [ ] Backup yang akan di-restore sudah diverifikasi integritas GPG-nya
- [ ] Restore selesai dan `bench doctor` bersih
- [ ] Fungsionalitas sistem dikonfirmasi
- [ ] Maintenance mode dimatikan
- [ ] Monitoring intensif aktif

---

### Fase 5: Lessons Learned (Post-Incident Review)

Dilakukan dalam **5 hari kerja** setelah insiden dinyatakan tertutup. Wajib dihadiri: Incident Commander, Technical Responder, Communication Lead.

Format: meeting 60–90 menit. Bukan sesi menyalahkan — fokus pada sistem dan proses, bukan individu.

#### Template Post-Incident Report

Simpan file ini di `docs/security/incident-logs/[YYYY-MM-DD]-[deskripsi-singkat].md`:

```markdown
## Post-Incident Report

**Tanggal insiden:**
**Tanggal report:**
**Klasifikasi:**
**Diisi oleh:**

### Kronologi

| Waktu | Kejadian | Siapa |
|---|---|---|
| HH:MM | ... | ... |

### Root Cause

[Jelaskan penyebab utama. Bukan "human error" — cari akar sistemik.]

### Scope Terdampak

- Data yang mungkin diakses tanpa izin:
- Jumlah record terdampak:
- Pengguna yang terdampak:
- Downtime:

### Tindakan yang Diambil

| Fase | Tindakan | Waktu |
|---|---|---|
| Containment | ... | ... |
| Eradication | ... | ... |
| Recovery | ... | ... |

### Metrik Respons

- Waktu deteksi hingga containment:
- Waktu downtime total:
- Apakah RTO terpenuhi: Ya / Tidak

### Apa yang Berjalan Baik

- ...

### Apa yang Bisa Diperbaiki

- ...

### Tindakan Preventif

| Tindakan | PIC | Deadline |
|---|---|---|
| ... | ... | ... |
```

---

## 4. Kewajiban Notifikasi (UU PDP)

Jika insiden melibatkan data pribadi (donor, benefisiari, staf) yang terekspos atau kemungkinan terekspos:

### 4.1 Notifikasi ke Kominfo / BSSN

**Dasar:** UU PDP No. 27 Tahun 2022 Pasal 46
**Waktu:** Dalam **14 hari kalender** setelah insiden diketahui (tanggal Fase 1)
**Siapa yang melakukan:** Communication Lead (PM) bersama pimpinan organisasi
**Kanal:** Formulir online Kominfo dan/atau BSSN + surat resmi berorganisasi

Isi notifikasi minimal:
- Nama dan kontak organisasi pelapor
- Tanggal dan deskripsi insiden
- Jenis data pribadi yang terdampak
- Perkiraan jumlah subjek data terdampak
- Tindakan yang sudah dan sedang diambil

### 4.2 Notifikasi ke Subjek Data Terdampak

**Waktu:** Dalam 30 hari kalender (best practice; UU PDP tidak menentukan angka spesifik untuk subjek data)
**Siapa:** Direktur / pimpinan organisasi (bukan tim teknis)

Template notifikasi (Bahasa Indonesia):

```
Kepada Yth. [Nama Donor/Staf],

Kami perlu menginformasikan bahwa pada [tanggal], kami mendeteksi insiden keamanan
yang mungkin mempengaruhi data pribadi Anda yang tersimpan di sistem [Nama Organisasi].

Data yang mungkin terdampak:
[Sebutkan secara spesifik — contoh: nama dan alamat email Anda]

Tindakan yang sudah kami lakukan:
[Contoh: akses tidak sah sudah kami hentikan pada [tanggal], sistem sudah
kami pulihkan dari backup yang bersih, credential yang mungkin terkompromis
sudah kami reset seluruhnya]

Tindakan yang kami rekomendasikan untuk Anda:
[Jika relevan — contoh: waspada terhadap email mencurigakan yang mengatasnamakan
organisasi kami; kami tidak akan pernah meminta password Anda via email]

Kami mohon maaf atas insiden ini. Keamanan data Anda adalah prioritas kami dan
kami berkomitmen untuk terus meningkatkan perlindungan sistem.

Jika ada pertanyaan, hubungi [nama PIC] di [email/telepon].

Hormat kami,
[Nama Direktur]
[Nama Organisasi]
[Tanggal]
```

### 4.3 Notifikasi ke Donor Internasional

Jika data donor dari program yang didanai USAID, EU, atau donor internasional lain terdampak:
- **GDPR (donor dari EU/EEA):** Notifikasi ke Data Protection Authority dalam **72 jam** jika terjadi breach data pribadi warga EU
- **USAID:** Cek grant agreement untuk persyaratan pelaporan data breach; umumnya 72 jam ke USAID AOR
- Koordinasi dengan Communication Lead dan pimpinan organisasi segera setelah insiden diklasifikasikan Critical atau High

---

## 5. Latihan Respons Insiden (Tabletop Exercise)

**Rekomendasi frekuensi:** Setidaknya satu kali per tahun, atau setelah ada perubahan signifikan pada tim atau sistem.

**Format:** 2 jam, tanpa laptop (simulasi situasi terbatas akses). Fasilitator — idealnya pihak di luar tim teknis — membacakan skenario dan injekan per interval waktu. Tim mendiskusikan keputusan secara lisan.

### Panduan Fasilitator

**Injekan waktu:**
- **T+0:** Baca skenario awal
- **T+15 menit:** Tambahkan informasi baru (contoh: ternyata akun kedua juga ikut dikompromis)
- **T+30 menit:** Tambahkan komplikasi (contoh: backup terakhir gagal — harus pakai backup 2 hari lalu)
- **T+60 menit:** Simulasi press question: "donor tanya apa data mereka aman?"
- **T+90 menit:** Debrief — apa yang berjalan baik, apa yang macet

### Skenario yang Direkomendasikan

**Skenario A — Akun Privileged Dikompromis**
> Senin pagi, Finance Manager melapor bahwa akunnya digunakan untuk login pada Minggu malam pukul 23:47 WIB dari IP yang tidak dikenali. Finance Manager tidak melakukan apapun pada waktu tersebut. Notification email masuk ke inbox Finance Manager, tapi baru dilihat Senin pagi.

Pertanyaan untuk tim: Apa yang dilakukan dalam 1 jam pertama? Bagaimana memastikan tidak ada transaksi keuangan yang dibuat tanpa izin? Kapan dan bagaimana menginformasikan manajemen?

**Skenario B — SQL Injection / Akses Database Langsung**
> Monitoring Netdata menunjukkan spike CPU pada pukul 03:15 WIB. Nginx access log menunjukkan ratusan request mencurigakan dari satu IP asing ke endpoint `/api/method/frappe.client.get_list` dengan parameter yang tidak wajar. IP tersebut sudah tidak aktif, tapi ada query besar yang baru saja selesai.

Pertanyaan: Bagaimana menentukan apakah data berhasil di-exfiltrate? Apa yang dicek di log? Kapan maintenance mode diaktifkan?

**Skenario C — Backup Failure Terdeteksi Terlambat**
> Tim baru menyadari bahwa backup script gagal selama 5 hari terakhir karena disk penuh. Saat ini produksi sedang berjalan normal, tapi tidak ada backup valid sejak 5 hari lalu. Tidak ada insiden breach, tapi ini adalah kondisi darurat recovery.

Pertanyaan: Apa tindakan pertama? Bagaimana membuat backup darurat sekarang? Bagaimana mencegah ini terulang?

---

## Appendix: Quick Reference — Perintah Darurat

Kumpulkan daftar ini di lokasi yang dapat diakses offline (bukan hanya di dalam sistem yang mungkin dikompromis).

```bash
# Nonaktifkan user via bench console
bench --site [site] console
# > user = frappe.get_doc("User", "email@contoh.com"); user.enabled=0; user.save(ignore_permissions=True); frappe.db.commit()

# Block IP di UFW
ufw deny from [IP] to any

# Aktifkan maintenance mode
bench --site [site] set-maintenance-mode on

# Matikan maintenance mode
bench --site [site] set-maintenance-mode off

# Cek status semua worker
sudo supervisorctl status

# Stop semua worker (hati-hati — ini menghentikan semua background jobs)
sudo supervisorctl stop all

# Restart semua worker
sudo supervisorctl start all

# Cek koneksi aktif ke MariaDB
ss -tnp | grep 3306

# Cek proses nginx
ps aux | grep nginx

# Cek log nginx real-time
tail -f /var/log/nginx/access.log

# Cek log backup
tail -100 /var/log/fundara-backup.log

# bench doctor
bench --site [site] doctor
```
