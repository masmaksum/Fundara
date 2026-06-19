# Offboarding Checklist — Staf & Developer

**Nomor Dokumen:** ISP-003  
**Versi:** 1.0  
**Status:** Aktif  
**Berlaku Sejak:** (diisi setelah ditandatangani)  
**Terakhir Diperbarui:** 2026-06-20  
**Pemilik Dokumen:** Project Manager  
**Referensi:** ISP-001 § 5.5 (HR Security — Offboarding), ISO/IEC 27001:2022 A.6.5

---

## 1. Tujuan

Dokumen ini memastikan bahwa setiap anggota tim yang meninggalkan proyek Fundara — baik karena kontrak selesai, pengunduran diri, pergantian vendor, maupun alasan lain — dilakukan dengan cara yang menjaga keamanan sistem dan data NGO. Seluruh akses harus dicabut dalam **24 jam sejak hari terakhir bekerja**.

## 2. Lingkup

Checklist ini berlaku untuk semua peran yang memiliki akses ke sistem Fundara:

| Peran | Akses Tipikal |
|-------|---------------|
| Developer | GitHub, Frappe dev/staging, SSH dev VM |
| DevOps / Tech Lead | GitHub, Frappe semua environment, SSH semua server, API keys, monitoring |
| QA Engineer | GitHub, Frappe staging, SSH staging |
| Project Manager | GitHub (read), Frappe production (terbatas) |
| Domain Expert / Konsultan | GitHub (read), Frappe staging (demo) |

---

## 3. Identitas Offboarding

*Diisi oleh PM pada saat proses offboarding dimulai.*

| Field | Isi |
|-------|-----|
| Nama lengkap | |
| Peran / Role | |
| Hari terakhir bekerja (D-0) | |
| Batas waktu pencabutan akses (D+1) | |
| Alasan offboarding | |
| Dilaksanakan oleh (PM) | |
| Diverifikasi oleh (TL) | |
| Tanggal checklist diisi | |

---

## 4. Inventarisasi Akses — Diisi D-2

*Lakukan inventarisasi ini 2 hari sebelum hari terakhir bersama TL. Centang sistem yang dimiliki oleh orang yang bersangkutan.*

| Sistem | Dimiliki? | Catatan |
|--------|-----------|---------|
| GitHub collaborator (`masmaksum/Fundara`) | ☐ Ya / ☐ Tidak | |
| GitHub Personal Access Token (PAT) aktif | ☐ Ya / ☐ Tidak | |
| Akun Frappe — Development | ☐ Ya / ☐ Tidak | |
| Akun Frappe — Staging | ☐ Ya / ☐ Tidak | |
| Akun Frappe — Production | ☐ Ya / ☐ Tidak | |
| API Key Frappe (otomasi/monitoring) | ☐ Ya / ☐ Tidak | |
| SSH key di dev VM | ☐ Ya / ☐ Tidak | |
| SSH key di staging server | ☐ Ya / ☐ Tidak | |
| SSH key di production server | ☐ Ya / ☐ Tidak | |
| Akses langsung ke database MariaDB | ☐ Ya / ☐ Tidak | |
| GPG passphrase backup enkripsi | ☐ Ya / ☐ Tidak | |
| API key backup offsite (write-only) | ☐ Ya / ☐ Tidak | |
| Akun monitoring (Netdata/Uptime Kuma) | ☐ Ya / ☐ Tidak | |
| Credentials vault (Bitwarden/KeePass) | ☐ Ya / ☐ Tidak | |
| Grup komunikasi (WhatsApp/Telegram) | ☐ Ya / ☐ Tidak | |
| Tools manajemen proyek (Notion/Linear) | ☐ Ya / ☐ Tidak | |
| SMTP relay credentials | ☐ Ya / ☐ Tidak | |

---

## 5. Checklist Hari Terakhir (D-0)

### 5.1 Transfer Pengetahuan

- [ ] Semua pekerjaan yang sedang berjalan terdokumentasi (branch, PR, status bug)
- [ ] Handover notes diserahkan ke TL secara tertulis
- [ ] Tidak ada branch aktif yang di-abandon tanpa penjelasan
- [ ] Open PR di-review disposisi: dilanjutkan oleh siapa, atau di-close?
- [ ] Akses staging untuk demo tidak sedang dipakai untuk proses yang belum selesai

### 5.2 Return Aset

- [ ] Perangkat keras milik organisasi dikembalikan (jika ada)
- [ ] Data proyek di perangkat pribadi dihapus dan dikonfirmasi

### 5.3 Pernyataan Kerahasiaan

- [ ] Orang yang bersangkutan diingatkan bahwa NDA tetap berlaku setelah offboarding
- [ ] Tidak ada salinan kode sumber, data NGO, atau dokumen internal di perangkat pribadi

---

## 6. Checklist Pencabutan Akses — Selesai Paling Lambat D+1 Pukul 17:00

### 6.1 GitHub

> Eksekutor: PM (dibantu TL untuk akses admin)

- [ ] Remove sebagai collaborator di `masmaksum/Fundara`: Settings → Collaborators → Remove
- [ ] Verifikasi tidak ada PAT atas nama user ini yang masih beredar (tanyakan langsung, tidak bisa dilihat dari repo settings)
- [ ] Cek pending PR yang di-assign ke user: alihkan reviewer atau tutup
- [ ] Cek branch yang dibuat user: hapus jika sudah di-merge, archive jika masih relevan

### 6.2 Frappe — Development Environment

> Eksekutor: TL  
> Akses: `bench` di dev VM

- [ ] Login ke Frappe dev sebagai Administrator
- [ ] Buka: Setup → Users → [nama user]
- [ ] Klik **Disable** (jangan hapus — pertahankan riwayat audit log)
- [ ] Pastikan status berubah jadi **Disabled**
- [ ] Revoke semua API Key milik user: buka tab "API Access" → hapus semua key

### 6.3 Frappe — Staging Environment

> Eksekutor: TL  
> Akses: SSH ke staging server, kemudian `bench`

- [ ] Login ke Frappe staging sebagai Administrator
- [ ] Buka: Setup → Users → [nama user]
- [ ] Klik **Disable**
- [ ] Revoke API Key di tab "API Access" (jika ada)
- [ ] Verifikasi: coba login sebagai user tersebut — harus gagal dengan pesan "User is disabled"

### 6.4 Frappe — Production Environment

> Eksekutor: TL (dengan approval PM)  
> Akses: SSH ke production server

- [ ] Login ke Frappe production sebagai Administrator
- [ ] Buka: Setup → Users → [nama user]
- [ ] Klik **Disable**
- [ ] Revoke API Key di tab "API Access" (jika ada)
- [ ] Verifikasi via Frappe Audit Log: login attempt setelah disable harus muncul sebagai "User is disabled"

### 6.5 SSH Key — Dev VM

> Eksekutor: TL  
> File: `/home/frappe/.ssh/authorized_keys` di shared dev VM

- [ ] SSH ke dev VM sebagai admin
- [ ] Jalankan: `sudo nano /home/frappe/.ssh/authorized_keys`
- [ ] Hapus baris yang berisi public key milik user (identifiable dari komentar `user@hostname` di akhir baris)
- [ ] Simpan file
- [ ] Konfirmasi: `cat /home/frappe/.ssh/authorized_keys` — pastikan key sudah tidak ada

### 6.6 SSH Key — Staging Server

> Eksekutor: TL

- [ ] SSH ke staging server sebagai admin
- [ ] Edit `/home/frappe/.ssh/authorized_keys`
- [ ] Hapus public key milik user
- [ ] Konfirmasi key sudah tidak ada
- [ ] Jika user punya akses sudo langsung: hapus juga dari `/etc/sudoers.d/`

### 6.7 SSH Key — Production Server

> Eksekutor: TL (dengan approval PM)

- [ ] SSH ke production server sebagai admin
- [ ] Edit `/home/frappe/.ssh/authorized_keys`
- [ ] Hapus public key milik user
- [ ] Konfirmasi key sudah tidak ada
- [ ] Jika user punya akses sudo langsung: hapus juga dari `/etc/sudoers.d/`

### 6.8 Rotasi Credential yang Dibagikan

*Hanya dilakukan jika user memiliki akses ke credential berikut.*

- [ ] **Database password** (jika user pernah akses langsung MariaDB): Rotasi `db_password` di `site_config.json` semua site + update di credentials vault + restart bench
- [ ] **GPG backup key passphrase** (jika user pernah memegang passphrase): Generate keypair baru, re-encrypt backup terbaru, update di credentials vault + update backup script
- [ ] **API key backup offsite** (jika user pernah memiliki key ini): Rotate via panel hosting provider, update di environment variable server, test backup script
- [ ] **SMTP relay credentials** (jika user pernah akses): Rotate password SMTP, update di `site_config.json`, test pengiriman email dari Frappe

### 6.9 Credentials Vault

- [ ] Revoke akses user ke Bitwarden/KeePass organizational vault (jika berlaku)
- [ ] Audit vault items yang mungkin pernah dilihat user: pertimbangkan rotasi credential kritis
- [ ] Update catatan vault: tandai bahwa user sudah offboarding dan pada tanggal berapa

### 6.10 Monitoring

- [ ] Hapus akun user di Netdata (jika ada akun terpisah)
- [ ] Hapus akun user di Uptime Kuma (jika ada akun terpisah)
- [ ] Pastikan tidak ada alert notification yang masih dikirim ke email/nomor user tersebut

### 6.11 Komunikasi & Kolaborasi

- [ ] Remove dari grup WhatsApp / Telegram proyek
- [ ] Remove dari workspace Notion / Linear / Trello (jika digunakan)
- [ ] Hapus dari mailing list internal (jika ada)
- [ ] Informasikan ke seluruh tim bahwa user telah selesai dan tidak boleh berbagi informasi proyek dengannya

---

## 7. Notifikasi

- [ ] PM mengirim notifikasi tertulis ke PO bahwa offboarding [nama] selesai dilakukan pada [tanggal]
- [ ] PM menyimpan salinan checklist ini (terisi) di folder dokumentasi proyek
- [ ] Catat di DECISIONS.md atau catatan proyek jika ada implikasi terhadap sprint atau deliverable

---

## 8. Verifikasi Post-Offboarding — D+7

*TL melakukan verifikasi menyeluruh 7 hari setelah offboarding untuk memastikan tidak ada akses residual.*

- [ ] Coba akses GitHub dengan akun user (jika TL masih bisa koordinasi) — harus ditolak
- [ ] Cek Frappe Audit Log: tidak ada login berhasil dari user setelah tanggal disable
- [ ] Cek server access log (`/var/log/auth.log`) di staging dan production: tidak ada SSH login berhasil dari IP yang berhubungan dengan user
- [ ] Pastikan tidak ada PR baru yang dibuat dari akun user di GitHub setelah tanggal offboarding
- [ ] Jika ditemukan akses residual: eskalasi ke PO sebagai insiden keamanan (ikuti `incident-response.md`)

---

## 9. Catatan Khusus: Offboarding Tech Lead / DevOps

Jika yang offboarding adalah Tech Lead atau DevOps (role dengan privilege tertinggi), **terapkan prosedur tambahan**:

- [ ] Rotasi **semua** shared credentials tanpa pengecualian (bukan hanya yang terkait user)
- [ ] Audit branch protection rules di GitHub — pastikan masih sesuai
- [ ] Review dan rotasi API key monitoring (Netdata token, Uptime Kuma API key)
- [ ] Tinjau ulang semua file `authorized_keys` di semua server untuk memastikan kelengkapan
- [ ] PO dilibatkan secara langsung dalam verifikasi D+7
- [ ] Pertimbangkan review menyeluruh `security-requirements.md` jika ada perubahan arsitektur yang belum terdokumentasi

---

## 10. Rekam Jejak

*Untuk keperluan audit ISO 27001, semua bukti pencabutan akses harus disimpan.*

| Bukti | Format | Disimpan Oleh |
|-------|--------|---------------|
| Screenshot Frappe user disabled (staging + production) | PNG | PM |
| Screenshot GitHub collaborator removed | PNG | PM |
| Output `cat authorized_keys` setelah penghapusan (staging + production) | TXT / Screenshot | TL |
| Konfirmasi rotasi credential (jika dilakukan) | Catatan tertulis | TL |
| Checklist ini — terisi lengkap | MD / PDF | PM |

Simpan di: folder dokumen proyek (bukan di repository publik — berisi informasi sensitif).

---

## 11. Tanda Tangan

*Checklist ini dinyatakan selesai setelah ditandatangani oleh PM (eksekutor) dan TL (verifikator).*

| Peran | Nama | Tanggal | Tanda Tangan |
|-------|------|---------|--------------|
| Project Manager (Eksekutor) | | | |
| Tech Lead (Verifikator) | | | |

---

*Dokumen ini adalah bagian dari ISMS Fundara. Pertanyaan mengenai prosedur ini dapat diajukan kepada Project Manager atau merujuk ke ISP-001 (Information Security Policy).*
