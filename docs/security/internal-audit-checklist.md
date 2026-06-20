# Program dan Checklist Internal Audit ISMS

**Nomor Dokumen:** ISP-006  
**Versi:** 1.0  
**Status:** Aktif  
**Berlaku Sejak:** (diisi setelah ditandatangani)  
**Terakhir Diperbarui:** 2026-06-20  
**Pemilik Dokumen:** Project Manager  
**Referensi:** ISP-001 § 5.8, ISO/IEC 27001:2022 Klausul 9.2

---

## 1. Tujuan

Dokumen ini menetapkan program audit internal ISMS Fundara sesuai ISO 27001:2022 Klausul 9.2. Tujuannya adalah memverifikasi secara independen bahwa kontrol keamanan yang terdokumentasi benar-benar diimplementasikan dan berfungsi — bukan sekadar ada di atas kertas.

Audit internal bukan untuk mencari kesalahan individu, melainkan untuk menemukan celah sistemis sebelum ditemukan oleh pihak luar atau sebelum terjadi insiden.

---

## 2. Program Audit

### 2.1 Frekuensi

| Jenis Audit | Frekuensi | Pemicu |
|-------------|-----------|--------|
| **Audit Tahunan Penuh** | 1× per tahun | Kalender — idealnya Q1 setiap tahun |
| **Audit Terfokus** | Sesuai kebutuhan | Insiden keamanan signifikan, perubahan scope ISMS (lihat ISP-002), penambahan environment baru, pergantian DevOps/TL |
| **Audit Akses (Quarterly)** | 4× per tahun | Kalender — setiap akhir kuartal |

Audit pertama dijadwalkan **3 bulan setelah go-live production**, kemudian tahunan.

### 2.2 Auditor

**Persyaratan:**
- Auditor internal harus **bukan** orang yang bertanggung jawab atas kontrol yang diaudit (prinsip independensi — Klausul 9.2.1)
- Untuk Fundara dengan tim kecil: TL mengaudit aspek governance/proses; PM mengaudit aspek teknis (dengan panduan TL); atau gunakan anggota tim QA yang tidak terlibat langsung di implementasi kontrol yang diaudit
- Jika tidak ada personel yang memenuhi syarat independensi: pertimbangkan melibatkan pihak ketiga untuk audit tahunan

**Penetapan auditor:** PM menetapkan auditor minimal 2 minggu sebelum tanggal audit, dikonfirmasi secara tertulis.

### 2.3 Pelaksanaan

1. **Perencanaan (D-14):** PM menetapkan auditor, scope, dan tanggal audit; auditor membaca dokumen ISMS terkini
2. **Persiapan (D-7):** Auditor menyiapkan daftar bukti yang akan diminta; tim diberitahu audit akan dilaksanakan
3. **Pelaksanaan (D-0):** Auditor mengisi checklist ini; mengumpulkan bukti (screenshot, log, output command); mewawancarai anggota tim jika diperlukan
4. **Laporan (D+3):** Auditor menyerahkan laporan temuan (lihat Bagian 9) kepada PM
5. **Tindak Lanjut (D+14):** PM dan TL menetapkan corrective action untuk temuan; timeline perbaikan ditetapkan
6. **Verifikasi (D+30 s/d D+90):** PM memverifikasi corrective action sudah diimplementasikan

---

## 3. Checklist Audit

**Petunjuk pengisian:**
- Status: **S** = Sesuai | **P** = Sebagian | **T** = Tidak Sesuai | **N** = N/A
- Kolom "Cara Verifikasi" menunjukkan perintah atau tindakan konkret untuk mengumpulkan bukti
- Catat nomor temuan di kolom Notes jika status P atau T; uraikan di Bagian 10

---

### A. Dokumen Governance ISMS

*Memverifikasi bahwa seluruh dokumen kebijakan masih mutakhir, ditandatangani, dan dikomunikasikan.*

| # | Item Audit | Cara Verifikasi | Bukti yang Diharapkan | Status | Notes |
|---|-----------|-----------------|----------------------|--------|-------|
| A.1 | IS Policy (ISP-001) sudah ditandatangani Pimpinan (PO) | Periksa blok tanda tangan di `docs/security/is-policy.md` | Tanda tangan + tanggal di dokumen | | |
| A.2 | IS Policy versi terkini dikomunikasikan ke seluruh tim aktif | Konfirmasi via PM: apakah seluruh anggota tim telah menerima salinan/link? | Catatan distribusi atau email konfirmasi | | |
| A.3 | ISMS Scope (ISP-002) masih mencerminkan kondisi aktual | Bandingkan ISP-002 dengan environment yang berjalan; tanyakan TL apakah ada perubahan scope yang belum dicatat | Tidak ada discrepancy antara ISP-002 dan kondisi nyata | | |
| A.4 | Offboarding Checklist (ISP-003) digunakan saat ada offboarding | Tanyakan PM: apakah ada offboarding sejak audit terakhir? Jika ya, cek checklist terisi | Salinan checklist ISP-003 terisi + tanda tangan PM + TL | | |
| A.5 | NDA (ISP-004) ditandatangani sebelum akses diberikan ke anggota tim baru | Minta PM menunjukkan salinan NDA yang sudah ditandatangani per anggota tim | Satu NDA per anggota tim yang punya akses ke sistem | | |
| A.6 | Klasifikasi informasi (ISP-005) diterapkan pada dokumen baru yang dibuat sejak audit terakhir | Sampling: periksa 5 dokumen baru — apakah ada label klasifikasi yang benar? | Label [TERBATAS]/[RAHASIA] ada di dokumen yang seharusnya | | |
| A.7 | Dokumen ISMS di-review sesuai jadwal (tahunan atau saat trigger) | Periksa tanggal "Terakhir Diperbarui" di seluruh ISP-001 s/d ISP-006 | Semua dokumen diperbarui dalam 12 bulan terakhir (atau ada justifikasi) | | |

---

### B. Manajemen Akses dan Identitas

*Memverifikasi kontrol akses ke sistem Fundara di semua environment.*

| # | Item Audit | Cara Verifikasi | Bukti yang Diharapkan | Status | Notes |
|---|-----------|-----------------|----------------------|--------|-------|
| B.1 | Tidak ada akun Frappe yang aktif milik mantan anggota tim | Login Frappe (dev/staging/prod) → Setup → Users → filter Disabled = No; bandingkan dengan daftar tim aktif saat ini | Tidak ada akun aktif milik orang yang sudah offboarding | | |
| B.2 | Tidak ada akun Frappe yang tidak aktif > 60 hari tanpa di-disable | Frappe → Setup → Users → urutkan berdasarkan Last Active; flag akun dengan last login > 60 hari yang masih Enabled | Semua akun dengan last login > 60 hari berstatus Disabled | | |
| B.3 | Seluruh anggota tim dengan akses privileged (System Admin, Finance Manager) mengaktifkan 2FA | Frappe → Setup → Users → cek kolom "Two Factor Auth" untuk role privileged | 100% privileged user punya 2FA aktif | | |
| B.4 | Tidak ada shared account (satu akun digunakan oleh lebih dari satu orang) | Wawancara TL dan beberapa anggota tim; cross-check last login pattern di Activity Log | Setiap individu punya akun terpisah | | |
| B.5 | Role assignment mengikuti prinsip least privilege | Sampling: pilih 3 user, bandingkan role mereka dengan kebutuhan aktual tugasnya per `docs/spec/permissions.md` | Role sesuai dengan tugas; tidak ada over-privilege | | |
| B.6 | API key yang ada sesuai dengan daftar integrasi yang diotorisasi | Frappe → Setup → Users → pilih user dengan API key; bandingkan dengan integrasi yang diotorisasi TL | Tidak ada API key yang tidak dikenali atau tidak terpakai | | |
| B.7 | SSH authorized_keys di seluruh server hanya berisi key anggota tim aktif | SSH ke setiap server: `cat /home/frappe/.ssh/authorized_keys`; bandingkan dengan daftar anggota tim aktif | Setiap key teridentifikasi milik anggota tim aktif | | |
| B.8 | Akses SSH menggunakan key authentication (bukan password) | SSH ke server: `grep "^PasswordAuthentication" /etc/ssh/sshd_config` | Output: `PasswordAuthentication no` | | |
| B.9 | Root login via SSH dinonaktifkan | SSH ke server: `grep "^PermitRootLogin" /etc/ssh/sshd_config` | Output: `PermitRootLogin no` | | |

---

### C. Backup dan Pemulihan

*Memverifikasi backup berjalan dengan benar dan data dapat dipulihkan.*

| # | Item Audit | Cara Verifikasi | Bukti yang Diharapkan | Status | Notes |
|---|-----------|-----------------|----------------------|--------|-------|
| C.1 | Backup otomatis berjalan setiap hari | Cek log backup terbaru: `ls -lt ~/frappe-bench/sites/*/private/backups/ \| head -5`; atau cek log cron | File backup dalam 24 jam terakhir | | |
| C.2 | Backup terenkripsi dengan GPG sebelum upload offsite | Periksa output backup script; cek apakah file di offsite storage berekstensi `.gpg` | File backup di offsite berformat `.tar.gz.gpg` | | |
| C.3 | Integritas GPG backup dapat diverifikasi | Unduh 1 file backup terbaru dari offsite; jalankan: `gpg --decrypt backup_latest.gpg \| tar -tzf -` | Decrypt berhasil; isi tar listing terlihat | | |
| C.4 | Backup disimpan di minimal 2 lokasi (lokal + offsite) | Cek disk lokal server dan konfirmasi upload offsite di log backup | Ada backup di disk lokal dan ada di offsite storage | | |
| C.5 | Restore pernah diuji (minimal sekali sejak go-live) | Tanya TL: kapan terakhir restore test dilakukan? Minta catatan hasilnya | Ada catatan restore test dengan timestamp dan hasilnya | | |
| C.6 | Retensi backup sesuai kebijakan (minimum 30 hari lokal, 90 hari offsite) | Cek jumlah file backup di lokal dan di offsite storage | File lokal ada minimal 30 hari; offsite minimal 90 hari | | |

---

### D. Patch dan Vulnerability Management

*Memverifikasi pengelolaan CVE dan update keamanan.*

| # | Item Audit | Cara Verifikasi | Bukti yang Diharapkan | Status | Notes |
|---|-----------|-----------------|----------------------|--------|-------|
| D.1 | Versi ERPNext/Frappe yang digunakan sudah di-pin dan terdokumentasi | Cek `apps.txt` atau `requirements.txt` di bench; bandingkan dengan `environment-spec.md` | Versi di-pin; tidak menggunakan floating `latest` | | |
| D.2 | Tidak ada CVE dengan severity HIGH atau CRITICAL yang belum ditangani > 30 hari | Jalankan: `pip-audit` di bench environment; cek advisory ERPNext/Frappe di GitHub releases | Tidak ada CVE HIGH/CRITICAL terbuka lebih dari SLA (7 hari Critical, 30 hari High) | | |
| D.3 | Security patch OS (Ubuntu) diterapkan secara reguler | SSH ke server: `last-apt-get-upgrade` atau cek `/var/log/apt/history.log \| grep "^Start-Date" \| tail -5` | Update dalam 30 hari terakhir | | |
| D.4 | `unattended-upgrades` aktif untuk security patch OS | SSH ke server: `systemctl status unattended-upgrades` | Status: active (running) | | |
| D.5 | Tidak ada paket Python yang diketahui rentan di environment production | SSH ke server: `cd frappe-bench && pip-audit` | Output: no known vulnerabilities; atau ada tapi sudah dalam rencana patch | | |

---

### E. Keamanan Server dan Jaringan

*Memverifikasi hardening server sesuai `docs/infra/environment-spec.md`.*

| # | Item Audit | Cara Verifikasi | Bukti yang Diharapkan | Status | Notes |
|---|-----------|-----------------|----------------------|--------|-------|
| E.1 | UFW aktif dengan rule yang sesuai | SSH ke server: `sudo ufw status verbose` | Status: active; port yang terbuka sesuai spec (22, 80, 443 dari publik; 8000/9000 dari localhost saja) | | |
| E.2 | fail2ban aktif dan memiliki jail untuk SSH | SSH ke server: `sudo fail2ban-client status sshd` | Status: active; banned IPs terlihat jika ada brute force | | |
| E.3 | SSL/TLS aktif dengan grade yang baik | Verifikasi dengan: `curl -I https://[domain]` — cek header; atau cek sertifikat Let's Encrypt tidak expired | HTTPS berfungsi; sertifikat valid > 30 hari | | |
| E.4 | Port internal (8000, 9000) tidak accessible dari internet | Dari luar jaringan: `curl http://[IP]:8000` harus timeout | Connection refused atau timeout | | |
| E.5 | `site_config.json` memiliki permission yang benar | SSH ke server: `ls -la ~/frappe-bench/sites/[site]/site_config.json` | Permission: 640, owner: frappe | | |
| E.6 | Tidak ada debug mode atau `developer_mode` aktif di production | Cek `site_config.json`: `grep "developer_mode\|debug" ~/frappe-bench/sites/[site]/site_config.json` | Tidak ada entry `developer_mode: 1` atau `debug: 1` | | |
| E.7 | Monitoring aktif dan alert dikonfigurasi | Buka Netdata/Uptime Kuma; verifikasi: CPU/RAM/disk alert terkonfigurasi; notifikasi alert aktif | Alert terkonfigurasi; test notifikasi berhasil | | |

---

### F. Keamanan Kode dan Development

*Memverifikasi praktik keamanan dalam proses development.*

| # | Item Audit | Cara Verifikasi | Bukti yang Diharapkan | Status | Notes |
|---|-----------|-----------------|----------------------|--------|-------|
| F.1 | Branch protection aktif di repository GitHub | GitHub → masmaksum/Fundara → Settings → Branches → Branch protection rules | Rule "main": require PR review, require status checks | | |
| F.2 | Tidak ada secret/credential di source code | Jalankan di local: `git log --all --oneline` + `git grep -i "password\|api_key\|secret\|token" -- '*.py' '*.json'` pada commit terbaru | Tidak ada string yang terlihat seperti credential nyata | | |
| F.3 | Pre-commit hook atau CI untuk deteksi secret aktif | Cek `.pre-commit-config.yaml` atau GitHub Actions workflow; verifikasi tool (gitleaks/detect-secrets) terkonfigurasi | Hook/workflow ada dan terkonfigurasi | | |
| F.4 | Pull Request direview sebelum merge ke main | Sampling: buka 5 PR terakhir di GitHub; cek apakah ada "Approved" review sebelum merge | Semua PR punya minimal 1 approval dari TL | | |
| F.5 | Tidak ada penggunaan `frappe.flags.ignore_permissions = True` tanpa komentar justifikasi | `grep -rn "ignore_permissions" fundara/` | Jika ada, semua disertai komentar alasan + approval TL | | |
| F.6 | `SR-DEV-06` dipatuhi: tidak ada hardcoded credential | `grep -rn "password\s*=\s*[\"'][^\"']\|api_key\s*=\s*[\"'][^\"']" fundara/` | Tidak ada hasil | | |

---

### G. Manajemen Insiden

*Memverifikasi kesiapan respons insiden.*

| # | Item Audit | Cara Verifikasi | Bukti yang Diharapkan | Status | Notes |
|---|-----------|-----------------|----------------------|--------|-------|
| G.1 | Incident Response Plan (IRP) masih mutakhir | Cek `docs/security/incident-response.md` — apakah contact, prosedur, dan command masih relevan dengan kondisi sistem saat ini? | Tidak ada referensi ke komponen yang sudah tidak ada; kontak masih aktif | | |
| G.2 | Seluruh anggota tim tahu cara melaporkan insiden | Tanya 2–3 anggota tim: "Apa yang kamu lakukan jika kamu curiga ada insiden keamanan?" | Jawaban menunjukkan pemahaman prosedur dasar (lapor ke TL, preserve evidence, jangan hapus log) | | |
| G.3 | Jika ada insiden sejak audit terakhir: Post-Incident Report tersedia | Tanya PM: apakah ada insiden dalam 12 bulan terakhir? Jika ya, minta Post-Incident Report | Laporan tersedia dalam 5 hari kerja setelah insiden tertutup | | |
| G.4 | Tabletop exercise pernah dilakukan (minimal sekali per tahun) | Tanya TL: kapan terakhir exercise dilakukan? Minta catatan singkat | Ada catatan/notulen exercise dari 12 bulan terakhir | | |

---

### H. Privasi Data dan Kepatuhan UU PDP

*Memverifikasi kontrol data pribadi sesuai `docs/security/data-privacy.md`.*

| # | Item Audit | Cara Verifikasi | Bukti yang Diharapkan | Status | Notes |
|---|-----------|-----------------|----------------------|--------|-------|
| H.1 | Field PII (NIK, NPWP) tersimpan terenkripsi di database | Cek implementasi: `grep -rn "encrypt\|frappe.utils.password.encrypt" fundara/` pada field NIK/NPWP | Ada enkripsi application-level pada field sensitif | | |
| H.2 | Tidak ada PII di source code atau log | `grep -rn "NIK\|NPWP\|KTP" fundara/*.py fundara/**/*.py` — tidak boleh ada nilai nyata | Tidak ada nilai PII nyata; hanya nama field | | |
| H.3 | Akses data donor dan benefisiari dibatasi sesuai permission matrix | Sampling: login sebagai Field Staff → coba buka donor record yang bukan record sendiri | Akses ditolak; Frappe menampilkan "Not permitted" | | |
| H.4 | Frappe Audit Log aktif dan tidak bisa dihapus oleh role biasa | Cek System Settings → Enable Document Versioning; coba hapus log record sebagai Finance Officer | Document Versioning aktif; delete ditolak untuk role non-Admin | | |
| H.5 | Data staging tidak mengandung data production nyata | Tanya TL: apakah staging menggunakan data fiktif atau anonymized? Jika anonymized, bagaimana prosesnya? | Staging menggunakan data fiktif (demo data ISP-005) atau data yang sudah dianonimisasi | | |
| H.6 | Kebijakan retensi data diterapkan | Cek apakah ada data yang melebihi retention period per `data-privacy.md` — misal: data donor yang sudah 10 tahun dan tidak ada legal hold | Tidak ada data yang melebihi retention period tanpa justifikasi | | |

---

### I. Review Akses Quarterly

*Bagian ini diisi setiap akhir kuartal (tidak harus menunggu audit tahunan).*

| # | Item | Cara Verifikasi | Status | Notes |
|---|------|-----------------|--------|-------|
| I.1 | Daftar akun Frappe aktif sesuai dengan daftar tim aktif saat ini | Ekspor user list dari Frappe; bandingkan dengan daftar tim | | |
| I.2 | Tidak ada role yang berubah tanpa otorisasi TL/PM | Review Git log untuk perubahan di `permissions.md` atau perubahan role di Frappe | | |
| I.3 | NDA tersedia untuk semua anggota tim yang bergabung dalam kuartal ini | Minta PM menunjukkan NDA baru yang ditandatangani | | |
| I.4 | Sertifikat SSL tidak akan expired dalam 30 hari ke depan | `openssl s_client -connect [domain]:443 -servername [domain] 2>/dev/null \| openssl x509 -noout -dates` | | |
| I.5 | API key monitoring masih valid dan berfungsi | Cek Netdata/Uptime Kuma masih menerima data; tidak ada alert "agent disconnected" | | |

---

## 4. Ringkasan Temuan

*Diisi oleh auditor setelah seluruh checklist selesai.*

| No Temuan | Referensi Item | Deskripsi Temuan | Tingkat Risiko | Rekomendasi Tindakan | PIC | Target Selesai |
|-----------|---------------|-----------------|---------------|---------------------|-----|---------------|
| F-001 | | | ☐ Tinggi / ☐ Sedang / ☐ Rendah | | | |
| F-002 | | | ☐ Tinggi / ☐ Sedang / ☐ Rendah | | | |
| F-003 | | | ☐ Tinggi / ☐ Sedang / ☐ Rendah | | | |

*Tambah baris sesuai jumlah temuan. Temuan dengan risiko Tinggi harus diselesaikan dalam 30 hari; Sedang dalam 90 hari; Rendah dalam 180 hari.*

---

## 5. Skor Ringkasan Audit

*Dihitung otomatis dari hasil checklist.*

| Kategori | Total Item | S | P | T | N | % Sesuai |
|----------|-----------|---|---|---|---|---------|
| A. Governance | 7 | | | | | |
| B. Akses & Identitas | 9 | | | | | |
| C. Backup & Recovery | 6 | | | | | |
| D. Patch & Vulnerability | 5 | | | | | |
| E. Server & Jaringan | 7 | | | | | |
| F. Keamanan Kode | 6 | | | | | |
| G. Manajemen Insiden | 4 | | | | | |
| H. Privasi Data | 6 | | | | | |
| **TOTAL** | **50** | | | | | |

**Keterangan skor:**
- ≥ 90% Sesuai: ISMS berfungsi baik — pertahankan
- 75–89% Sesuai: Ada gap yang perlu diperbaiki — buat corrective action plan
- < 75% Sesuai: Gap signifikan — eskalasi ke PO dan buat improvement plan segera

---

## 6. Kesimpulan Auditor

*Diisi secara naratif oleh auditor.*

**Kekuatan yang ditemukan:**

**Area yang perlu perbaikan:**

**Rekomendasi prioritas:**

**Perbandingan dengan audit sebelumnya** (jika bukan audit pertama):

---

## 7. Jadwal Audit

| Audit | Tanggal Rencana | Auditor | Tanggal Aktual | Status |
|-------|----------------|---------|---------------|--------|
| Audit Pertama (post go-live) | 3 bulan setelah go-live | | | |
| Audit Quarterly Q1 (akses) | | | | |
| Audit Quarterly Q2 (akses) | | | | |
| Audit Quarterly Q3 (akses) | | | | |
| Audit Quarterly Q4 (akses) | | | | |
| Audit Tahunan Penuh | | | | |

---

## 8. Tanda Tangan dan Persetujuan

**Auditor:**

| Nama | Peran | Tanggal Audit | Tanda Tangan |
|------|-------|--------------|--------------|
| | | | |

**Penerima Laporan:**

| Nama | Peran | Tanggal Terima | Tanda Tangan |
|------|-------|---------------|--------------|
| | Project Manager | | |
| | Tech Lead | | |
| | Product Owner (Pimpinan) | | |

---

## 9. Riwayat Audit

*Diisi setelah setiap audit selesai.*

| Edisi | Tanggal | Auditor | Skor (% Sesuai) | Temuan Kritis | Status Tindak Lanjut |
|-------|---------|---------|----------------|--------------|---------------------|
| Audit #1 | | | | | |
| Audit #2 | | | | | |

---

*Dokumen ini adalah bagian dari ISMS Fundara. Pertanyaan dapat diajukan kepada Project Manager atau merujuk ke ISP-001 (Information Security Policy) dan ISO/IEC 27001:2022 Klausul 9.2.*
