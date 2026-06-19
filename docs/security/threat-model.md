# Fundara Threat Model

**Version:** 1.0
**Last Updated:** 2026-06-19
**Audience:** Tech Lead, Security Reviewer, DevOps
**Methodology:** STRIDE (Spoofing, Tampering, Repudiation, Information Disclosure, Denial of Service, Elevation of Privilege)

This document identifies what Fundara is protecting, who might attack it, all entry points, and the specific threats against each. Each threat is mapped to existing mitigations and residual risk.

Related documents:
- `docs/security/security-requirements.md` — technical controls that address the mitigations listed here
- `docs/spec/permissions.md` — role and permission definitions referenced in threat actors and privilege escalation
- `docs/infra/environment-spec.md` — infrastructure topology referenced in attack surface

---

## 1. Aset yang Dilindungi

| Aset | Sensitivitas | Contoh Data | Lokasi Teknis |
|---|---|---|---|
| Data donor individu | Tinggi | Nama, NIK/NPWP, alamat, jumlah donasi | DocType: Donor, Donation; GL Entry |
| Data benefisiari | Sangat Tinggi | Nama, usia, nomor ID, kondisi kesehatan (program kesehatan), lokasi | DocType: Beneficiary |
| Data keuangan organisasi | Sangat Tinggi | Saldo fund, GL Entry, laporan ISAK 35, aset organisasi | DocType: Fund, GL Entry, Balance Sheet, Fund Utilization Report |
| Data grant dan donor relation | Tinggi | Jumlah grant, syarat penggunaan dana, jadwal pelaporan | DocType: Grant, Grant Agreement, Grant Budget Line, Grant Reporting Schedule |
| Data staf dan payroll | Tinggi | Gaji, nomor rekening bank staf | DocType: Staff Profile (salary/bank fields) |
| Kredensial sistem | Kritis | Database password, Redis password, API keys, session tokens, Frappe admin password | `site_config.json`, environment variables, Redis session store |
| Laporan kepada donor | Tinggi | Fund utilization report, donor report (bukti audit) | DocType: Donor Report, Fund Utilization Report; private file storage |
| Backup database | Sangat Tinggi | Seluruh data produksi dalam satu file terenkripsi | Disk lokal produksi + offsite (S3-compatible) |
| Konfigurasi sistem | Tinggi | Frappe workflow config, role permissions, approval threshold | ERPNext System Settings, Role Permission Manager, Workflow DocType |

---

## 2. Actors dan Trust Level

| Actor | Trust Level | Akses Teknis | Catatan |
|---|---|---|---|
| DevOps / System Admin | Paling Tinggi | Full SSH + DB + Frappe administrator | Akses tidak terbatas — harus di-audit secara personal |
| Finance Manager | Tinggi | Semua transaksi keuangan; submit dan amend GL Entry | Target serangan social engineering bernilai tinggi |
| Management / Executive | Tinggi | Read semua dokumen; approve transaksi strategis (> 500 juta IDR) | Akun yang paling sering menjadi target phishing |
| Finance Officer | Medium-Tinggi | Buat dan submit transaksi di bawah threshold; tidak bisa amend setelah period lock | Bisa menjadi insider threat untuk over-submission |
| Project Manager | Medium | Hanya dokumen milik proyeknya; submit Cash Advance dan PR proyek sendiri | Scope dibatasi server-side |
| Procurement Officer | Medium | RFQ, Purchase Order, Vendor management; tidak bisa submit PO di atas 200 juta tanpa co-approval | Risiko vendor fraud |
| Field Staff / Program Officer | Rendah | Hanya dokumen milik sendiri (Cash Advance, Activity, Evidence) | Volume akun paling banyak; risiko credential sharing |
| Audit / Internal Control | Rendah-Medium | Read-only semua catatan keuangan; tidak ada write permission | Harus dijaga agar benar-benar read-only |
| Donor Relationship Manager | Rendah-Medium | Grant dan Donor Report yang ia kelola | Akses ke data grant dan donor yang sensitif |
| Mantan karyawan | Tidak ada | Akun harus dinonaktifkan di hari yang sama dengan offboarding | Sumber risiko insider jika proses offboarding gagal |
| Pengguna anonim (internet) | Tidak ada | Tidak ada akses ke Frappe desk tanpa autentikasi | Hanya API publik jika ada (saat ini tidak ada) |
| Penyerang eksternal | Tidak ada | Permukaan serangan: HTTPS (443), SSH (22 restricted) | Lihat Attack Surface di seksi 3 |

---

## 3. Attack Surface

Semua entry point yang dapat diakses ke sistem Fundara:

| Entry Point | Protokol/Port | Diekspos ke Internet? | Catatan |
|---|---|---|---|
| Frappe Desk (web UI) | HTTPS / 443 | Ya (via Nginx) | Login form adalah target utama credential attack |
| REST API (`/api/method/`, `/api/resource/`) | HTTPS / 443 | Ya (via Nginx) | Semua endpoint yang di-`@frappe.whitelist()` dapat dipanggil tanpa navigasi UI |
| WebSocket / Socket.IO | HTTPS / 443 (Nginx proxy ke 9000) | Ya (via Nginx) | Real-time update; session token dikirim saat handshake |
| SSH | TCP / 22 (atau non-standard) | Dibatasi ke DevOps IPs via UFW | Key-only auth; root login disabled |
| MariaDB | TCP / 3306 | Tidak — localhost only | Tidak exposed; tidak ada public binding |
| Redis (semua port) | TCP / 6379, 11000, 12000, 13000 | Tidak — localhost only | Tidak exposed; tidak ada public binding |
| File upload (attachment) | HTTPS / 443 | Ya (melalui Frappe file upload API) | Risiko upload file berbahaya |
| Email inbound (jika dikonfigurasi) | SMTP / 25, 465, 587 | Outbound only dari server | Inbound belum dikonfigurasi di MVP |
| bench CLI | Lokal (SSH) | Tidak | Hanya bisa dijalankan via SSH dari DevOps |
| Backup file (offsite) | HTTPS / 443 ke S3-compatible | Outbound only | Backup dienkripsi sebelum transfer |

---

## 4. Threat Matrix — STRIDE

---

### Spoofing (TM-S) — Menyamar sebagai entitas lain

#### TM-S-01: Credential Stuffing pada Frappe Login

| Atribut | Detail |
|---|---|
| **Deskripsi** | Penyerang menggunakan daftar username/password yang bocor dari breach lain untuk mencoba login massal ke Frappe Desk. NGO Indonesia sering menggunakan email yang sama di banyak layanan. |
| **Entry point** | `/api/method/login` via HTTPS |
| **Likelihood** | Tinggi — tool otomatis mudah tersedia; login endpoint Frappe bersifat standar dan dikenal |
| **Impact** | Tinggi — kompromi akun Finance Manager atau System Admin membuka seluruh data keuangan |
| **Mitigasi saat ini** | SR-AUTH-04: lockout setelah 5 gagal / 30 menit; `fail2ban` di level OS; password policy minimum 12 karakter (SR-AUTH-01) |
| **Residual risk** | Medium — lockout per-akun efektif tapi tidak mencegah distributed attack dari banyak IP. Tanpa rate-limiting di Nginx layer, serangan besar masih mungkin. |

#### TM-S-02: Session Token Theft via XSS

| Atribut | Detail |
|---|---|
| **Deskripsi** | Penyerang menyuntikkan JavaScript ke halaman Frappe (misalnya melalui input nama donor yang tidak di-sanitasi) untuk mencuri session cookie dan mengambil alih sesi pengguna yang sudah login. |
| **Entry point** | Frappe Desk — field input yang me-render HTML; atau melalui file attachment yang dibuka |
| **Likelihood** | Rendah — Frappe memiliki output escaping bawaan; Fundara tidak mengizinkan HTML editor di DocType keuangan |
| **Impact** | Tinggi — session theft memberikan akses penuh sebagai pengguna yang tokennya dicuri |
| **Mitigasi saat ini** | Frappe output escaping; `X-Content-Type-Options: nosniff`; `X-Frame-Options: SAMEORIGIN` (SR-ENC-02); session cookie HttpOnly. CSP header (SR-SEC tabel section 5) membatasi sumber script. |
| **Residual risk** | Rendah — bergantung pada konsistensi implementasi CSP. Perlu verifikasi CSP header di semua respons Nginx. |

#### TM-S-03: Phishing Targeting Finance Manager atau System Admin

| Atribut | Detail |
|---|---|
| **Deskripsi** | Penyerang mengirim email palsu yang meniru Fundara atau mitra donor, mengarahkan Finance Manager atau Management ke halaman login palsu untuk mencuri kredensial. |
| **Entry point** | Di luar sistem teknis — via email klien |
| **Likelihood** | Medium — NGO Indonesia menjadi target phishing donor/grant; Finance Manager dan Management adalah target bernilai tinggi |
| **Impact** | Kritis — kompromi akun Finance Manager mengekspos semua GL Entry, Fund, dan Grant |
| **Mitigasi saat ini** | SR-AUTH-03: 2FA wajib untuk Finance Manager dan Management — kredensial saja tidak cukup untuk login bahkan jika dicuri. HSTS mencegah downgrade ke HTTP. |
| **Residual risk** | Medium — TOTP dapat di-bypass oleh real-time phishing proxy (evilginx-style). Residual risk ini diterima; tidak ada mitigasi teknis yang sempurna. Dialamatkan dengan pelatihan pengguna. |

---

### Tampering (TM-T) — Modifikasi data tanpa autorisasi

#### TM-T-01: Direct Database Manipulation (Bypass Frappe Permission Layer)

| Atribut | Detail |
|---|---|
| **Deskripsi** | Pengguna dengan akses SSH atau akses DB langsung (DevOps yang nakal, atau attacker yang sudah masuk ke server) memodifikasi data keuangan langsung via MariaDB, tanpa melalui Frappe sehingga tidak ada audit trail. |
| **Entry point** | SSH + `mysql -u frappe -p` atau koneksi DB langsung |
| **Likelihood** | Rendah — akses SSH dibatasi ketat ke DevOps IPs; MariaDB tidak exposed ke internet |
| **Impact** | Kritis — modifikasi GL Entry langsung dapat mengubah saldo fund tanpa jejak di version history Frappe |
| **Mitigasi saat ini** | MariaDB hanya di localhost (SR-ENC-02); SSH akses dibatasi ke DevOps IPs via UFW; audit log akses server di level OS. Untuk Profile C (separated DB): koneksi SSL. |
| **Residual risk** | Medium — insider DevOps yang authorized memiliki kemampuan teknis untuk ini. Mitigasi residual: pemisahan tugas (DevOps tidak memiliki akun Frappe Finance Manager), review berkala akses SSH, dan backup offsite terenkripsi sebagai bukti audit independen. |

#### TM-T-02: Manipulasi GL Entry Setelah Posting

| Atribut | Detail |
|---|---|
| **Deskripsi** | Pengguna dengan izin amend (Finance Manager atau System Admin) berupaya mengubah GL Entry yang sudah disubmit untuk menyembunyikan transaksi atau mengubah nilai. |
| **Entry point** | Frappe Desk — GL Entry amend flow; atau melalui Frappe REST API |
| **Likelihood** | Rendah — Frappe melarang edit langsung pada submitted GL Entry; hanya reversal yang tersedia |
| **Impact** | Kritis — manipulasi data keuangan yang berhasil merusak integritas laporan ISAK 35 dan laporan donor |
| **Mitigasi saat ini** | SR-LOG-03: GL Entry immutable setelah submit di Frappe accounting layer; reversal menciptakan entry baru (audit trail terjaga); SR-LOG-01: Document Versioning mencatat semua perubahan state |
| **Residual risk** | Rendah — mekanisme reversal Frappe sudah didesain untuk ini. Residual risk: `frappe.flags.ignore_permissions = True` di custom code bisa bypass ini — dicegah oleh SR-AUTHZ-02 dan SR-DEV-07. |

#### TM-T-03: Tampering dengan Audit Log (Hapus atau Modifikasi Version History)

| Atribut | Detail |
|---|---|
| **Deskripsi** | Pengguna atau penyerang berupaya menghapus atau memodifikasi Frappe Activity Log atau Version History untuk menutupi jejak tindakan yang tidak sah. |
| **Entry point** | Frappe Desk (jika ada UI untuk delete log), direct DB manipulation |
| **Likelihood** | Rendah — Frappe tidak menyediakan UI delete untuk version history; membutuhkan akses DB langsung |
| **Impact** | Tinggi — hilangnya audit trail membuat investigasi forensik tidak mungkin dilakukan; melanggar persyaratan donor dan regulasi |
| **Mitigasi saat ini** | SR-LOG-04: tidak ada role yang memiliki delete permission pada Activity Log dan Document Version via Frappe UI; akses DB langsung dicegah oleh kontrol di TM-T-01 |
| **Residual risk** | Rendah — sama dengan TM-T-01: insider DevOps dapat memodifikasi DB langsung. Backup offsite terenkripsi menjadi evidence independen. |

---

### Repudiation (TM-R) — Penyangkalan tindakan yang telah dilakukan

#### TM-R-01: Staff Menyangkal Approve Transaksi yang Tercatat di Sistem

| Atribut | Detail |
|---|---|
| **Deskripsi** | Project Manager atau Finance Officer mengklaim tidak pernah menyetujui Cash Advance atau Purchase Order, padahal sistem mencatat approval dari akun mereka. Bisa karena berbagi password atau klaim credential theft. |
| **Entry point** | Workflow approval action di Frappe Desk |
| **Likelihood** | Medium — password sharing umum terjadi di NGO; "lupa" approval juga mungkin |
| **Impact** | Medium — sengketa akuntabilitas; potensi fraud jika dimanfaatkan untuk menyembunyikan korupsi |
| **Mitigasi saat ini** | SR-LOG-01: Document Versioning mencatat `modified_by` dan timestamp untuk setiap state transition; SR-AUTH-01: no shared accounts (satu akun per manusia); SR-AUTH-03: 2FA untuk peran approver utama membuat penyangkalan lebih sulit |
| **Residual risk** | Medium — tanpa 2FA di semua approver role, penyangkalan berbasis "akun saya dipakai orang lain" masih mungkin. Diterima sebagai residual risk; dialamatkan dengan kebijakan no-account-sharing yang dikomunikasikan saat onboarding. |

#### TM-R-02: Admin Menyangkal Perubahan System Settings

| Atribut | Detail |
|---|---|
| **Deskripsi** | System Admin mengubah konfigurasi penting (permission, workflow, approval threshold) lalu menyangkal telah melakukan perubahan tersebut. |
| **Entry point** | Frappe Desk — System Settings, Role Permission Manager, Workflow configuration |
| **Likelihood** | Rendah — jumlah System Admin sedikit; akses sangat terbatas |
| **Impact** | Tinggi — perubahan permission atau workflow yang tidak ter-audit dapat menyembunyikan fraud |
| **Mitigasi saat ini** | SR-LOG-02: System Settings changes di-log ke Frappe Activity Log; Document Versioning aktif pada Workflow DocType; jumlah System Admin dibatasi minimal |
| **Residual risk** | Rendah — Activity Log tidak dapat dihapus via UI; residual risk hanya dari insider DevOps dengan akses DB. |

---

### Information Disclosure (TM-I) — Kebocoran data ke pihak yang tidak berhak

#### TM-I-01: Akses Tidak Sah ke PII Donor oleh Role Rendah

| Atribut | Detail |
|---|---|
| **Deskripsi** | Field Staff atau Fundraising Officer mengakses NIK/NPWP donor atau data sensitif benefisiari yang seharusnya tidak visible untuk role mereka — melalui Frappe Desk, API, atau laporan yang tidak di-filter dengan benar. |
| **Entry point** | Frappe Desk list view, REST API (`/api/resource/Donor`), laporan kustom |
| **Likelihood** | Medium — kesalahan konfigurasi permission mudah terjadi; custom report mungkin tidak melalui layer permission |
| **Impact** | Tinggi — pelanggaran UU PDP; kehilangan kepercayaan donor |
| **Mitigasi saat ini** | SR-AUTHZ-03: field masking untuk PII via `before_load` hook; SR-AUTHZ-02: Role Permission Manager per DocType; SR-DEV-03: semua `@frappe.whitelist()` harus ada `has_permission()` check |
| **Residual risk** | Medium — custom report yang dibuat ad-hoc oleh admin bisa bypass field masking jika tidak hati-hati. Mitigasi: code review wajib untuk semua custom report yang mengakses Donor atau Beneficiary. |

#### TM-I-02: Data Keuangan Terekspos via API Endpoint yang Tidak Aman

| Atribut | Detail |
|---|---|
| **Deskripsi** | Custom `@frappe.whitelist()` method yang dibuat untuk integrasi atau dashboard mereturn data keuangan (GL Entry, Fund balance, Grant amount) tanpa memeriksa izin pengguna yang memanggil. |
| **Entry point** | `/api/method/<custom_method>` via HTTPS |
| **Likelihood** | Medium — umum terjadi dalam pengembangan Frappe custom app; mudah terlewat saat review |
| **Impact** | Tinggi — data keuangan NGO adalah aset sensitif; eksposur dapat merusak kepercayaan donor |
| **Mitigasi saat ini** | SR-DEV-03: semua `@frappe.whitelist()` wajib ada `frappe.has_permission()` atau `frappe.only_for()` — enforced di code review |
| **Residual risk** | Medium — bergantung pada konsistensi code review. Direkomendasikan: automated linter rule untuk mendeteksi whitelist tanpa permission check. |

#### TM-I-03: Intersepsi Backup File yang Tidak Terenkripsi

| Atribut | Detail |
|---|---|
| **Deskripsi** | Backup database yang dikirim ke offsite storage (S3-compatible) diintersepsi dalam transit atau diakses oleh pihak ketiga yang memiliki akses ke storage bucket — mengekspos seluruh data produksi. |
| **Entry point** | Network transit (HTTPS ke S3) atau storage bucket (credentials bocor) |
| **Likelihood** | Rendah — koneksi ke S3 menggunakan HTTPS; backup terenkripsi sebelum upload |
| **Impact** | Kritis — satu backup file berisi semua data donor, keuangan, dan benefisiari |
| **Mitigasi saat ini** | SR-ENC-01: GPG AES-256 sebelum upload (per `environment-spec.md` section 3.10); S3 bucket credentials disimpan di environment variable (SR-ENC-03); HTTPS transport |
| **Residual risk** | Rendah — enkripsi end-to-end dengan GPG. Residual risk: kehilangan GPG private key berarti backup tidak bisa di-restore. Mitigasi: GPG private key di-escrow di password manager dengan akses terkontrol. |

#### TM-I-04: Data Sensitif Muncul di Server Log (Debug Mode Aktif)

| Atribut | Detail |
|---|---|
| **Deskripsi** | `developer_mode = 1` secara tidak sengaja aktif di produksi, atau Frappe error log dikonfigurasi terlalu verbose, menyebabkan nilai field sensitif (NPWP, jumlah transaksi, stack trace dengan data) muncul di bench log. |
| **Entry point** | `/home/frappe/frappe-bench/logs/` — accessible via SSH |
| **Likelihood** | Rendah — `developer_mode = 0` dikonfigurasi di production `common_site_config.json` |
| **Impact** | Tinggi — log yang bocor ke pihak luar mengekspos PII dan data keuangan |
| **Mitigasi saat ini** | `developer_mode = 0` di production (SR-SEC tabel section 5); SR-DEV-02: larangan `frappe.log_error()` dengan data sensitif; SR-LOG-04: akses log hanya via SSH untuk DevOps |
| **Residual risk** | Rendah — risiko terbesar adalah human error saat deploy. Mitigasi: deployment checklist memverifikasi `developer_mode = 0` sebelum setiap release. |

---

### Denial of Service (TM-D) — Membuat sistem tidak tersedia

#### TM-D-01: Heavy Report Generation yang Membebani Server

| Atribut | Detail |
|---|---|
| **Deskripsi** | Pengguna yang sah (atau penyerang yang sudah masuk) memicu report besar berulang kali — misalnya Fund Utilization Report untuk semua fund sepanjang tahun — yang menghabiskan CPU dan RAM server sehingga sistem menjadi lambat atau crash. |
| **Entry point** | Frappe Desk — Report module; REST API report endpoint |
| **Likelihood** | Medium — report berat adalah pola umum di ERPNext; tidak ada rate limiting bawaan |
| **Impact** | Medium — degradasi performa untuk semua pengguna; tidak ada kehilangan data |
| **Mitigasi saat ini** | Report berat diproses via Frappe background job (long worker) bukan synchronous request; server sizing per Profile B/C (8–16 GB RAM) memberikan headroom; Nginx timeouts membatasi durasi request |
| **Residual risk** | Medium — tidak ada queue limit atau per-user rate limit untuk background jobs. Rekomendasi: tambahkan `frappe.utils.background_jobs` rate limiting per user untuk heavy reports di future release. |

#### TM-D-02: Bulk File Upload yang Menghabiskan Disk Space

| Atribut | Detail |
|---|---|
| **Deskripsi** | Field Staff atau pengguna lain mengupload file berukuran besar atau jumlah besar (receipt scan, evidence document) yang mengisi disk produksi dan menyebabkan kegagalan DB write atau backup. |
| **Entry point** | Frappe file upload endpoint via Frappe Desk |
| **Likelihood** | Medium — Evidence Document dan lampiran receipt adalah use case normal; tanpa batas ukuran, bisa abuse |
| **Impact** | Medium — disk full menyebabkan kegagalan MariaDB write dan bench crash |
| **Mitigasi saat ini** | SR-DEV-05: validasi file type dan ukuran server-side; Frappe `max_file_size` setting; production disk 150 GB SSD per Profile B; backup volume terpisah (per `environment-spec.md` section 3.2) |
| **Residual risk** | Medium — tanpa monitoring disk usage yang aktif, disk full bisa terjadi secara perlahan. Mitigasi: alert disk usage > 80% ke DevOps (monitoring wajib per `environment-spec.md` section 3.1). |

#### TM-D-03: Redis Memory Exhaustion via Cache Flooding

| Atribut | Detail |
|---|---|
| **Deskripsi** | Penyerang yang sudah masuk ke sistem (atau bug di custom code) memicu cache write berulang ke Redis tanpa expiry, menghabiskan alokasi memori Redis dan menyebabkan kegagalan session lookup atau queue processing. |
| **Entry point** | Custom Frappe code yang menggunakan `frappe.cache().set_value()` tanpa TTL |
| **Likelihood** | Rendah — Redis di localhost only; tidak bisa diakses langsung dari luar |
| **Impact** | Medium — Redis OOM menyebabkan logout massal (session hilang) dan background job gagal |
| **Mitigasi saat ini** | Redis hanya di localhost (SR-ENC-02); Redis `maxmemory` dikonfigurasi dengan `allkeys-lru` eviction policy; Frappe framework menggunakan TTL pada cache key standar |
| **Residual risk** | Rendah — Redis tidak exposed; LRU eviction mencegah OOM permanen. |

---

### Elevation of Privilege (TM-E) — Mendapatkan akses lebih tinggi dari yang diizinkan

#### TM-E-01: Field Staff Mengeksploitasi Permission Check yang Hilang untuk Approve Cash Advance Sendiri

| Atribut | Detail |
|---|---|
| **Deskripsi** | Field Staff yang seharusnya hanya bisa Create/Read/Submit Cash Advance (bukan Approve) menemukan endpoint API atau workflow transition yang tidak memvalidasi role dengan benar, memungkinkan mereka men-submit ke status Approved tanpa persetujuan Project Manager atau Finance Officer. |
| **Entry point** | Frappe REST API (`/api/method/frappe.client.set_value` atau workflow transition endpoint) |
| **Likelihood** | Medium — Frappe workflow permission sering menjadi celah jika tidak dikonfigurasi dengan lengkap pada setiap transition |
| **Impact** | Tinggi — Field Staff bisa mendapat uang advance tanpa persetujuan; fraud keuangan langsung |
| **Mitigasi saat ini** | SR-AUTHZ-04: `has_permission` hook per DocType memvalidasi state transition; Frappe Workflow "Allowed" role dikonfigurasi per transition state (bukan hanya per DocType); SR-DEV-03: semua whitelist method ada permission check |
| **Residual risk** | Medium — implementasi `has_permission` hook yang tidak lengkap adalah risiko terbesar. Mitigasi: setiap Cash Advance workflow transition di-test eksplisit dalam QA dengan Field Staff role sebelum go-live. |

#### TM-E-02: SQL Injection via Input yang Dikontrol Pengguna ke frappe.db.sql

| Atribut | Detail |
|---|---|
| **Deskripsi** | Custom Frappe code menggunakan string concatenation dalam `frappe.db.sql()` dengan nilai yang berasal dari input pengguna (nama donor, nama project, filter report) — memungkinkan penyerang menyuntikkan SQL untuk membaca atau memodifikasi data di luar permission mereka. |
| **Entry point** | Frappe Desk — filter input pada list view, report parameter, search field |
| **Likelihood** | Medium — kesalahan ini umum pada developer yang tidak familiar dengan Frappe; code review bisa melewatkannya |
| **Impact** | Kritis — SQL injection yang berhasil dapat membaca semua tabel termasuk `tabUser`, `tabGL Entry`, dan `tabSingles` (yang berisi `site_config` values) |
| **Mitigasi saat ini** | SR-DEV-04: semua `frappe.db.sql()` wajib parameterized query — enforced di code review; Frappe ORM (`frappe.get_doc`, `frappe.get_list`, `frappe.db.get_value`) auto-parameterized dan digunakan untuk semua operasi standar |
| **Residual risk** | Medium — bergantung pada kualitas code review. Mitigasi: tambahkan static analysis tool (Bandit untuk Python) dalam CI pipeline yang mendeteksi string concatenation di dekat `frappe.db.sql`. |

#### TM-E-03: Penyalahgunaan frappe.flags.ignore_permissions di Custom Code

| Atribut | Detail |
|---|---|
| **Deskripsi** | Developer menambahkan `frappe.flags.ignore_permissions = True` di custom server script atau DocType controller untuk "menyederhanakan" logika, tanpa menyadari bahwa flag ini berlaku untuk seluruh request context dan dapat dieksploitasi jika ada conditional logic yang tidak ketat. |
| **Entry point** | Custom code di Fundara app (`apps/fundara/`) — server script, DocType controller, scheduled job |
| **Likelihood** | Medium — pola ini umum ditemukan di kode ERPNext custom development; developer sering menggunakannya untuk "fix" error permission sementara |
| **Impact** | Kritis — satu method dengan `ignore_permissions = True` yang dapat dipanggil via whitelist API memberikan akses tak terbatas ke seluruh sistem untuk caller manapun |
| **Mitigasi saat ini** | SR-AUTHZ-02 dan SR-DEV-07: `ignore_permissions` dilarang di production code paths; penggunaan yang diizinkan (migration/fixture) wajib komentar justifikasi + approval Tech Lead; enforced di code review |
| **Residual risk** | Medium — bergantung pada konsistensi code review. Mitigasi: automated grep dalam CI pipeline untuk mendeteksi `ignore_permissions = True` di luar direktori migration/fixtures dan trigger fail jika ditemukan tanpa justifikasi comment. |

---

## 5. Risk Summary Table

Tabel diurutkan berdasarkan Risk Score menurun. Risk Score = Likelihood × Impact (skala 1–3: Low=1, Medium=2, High/Critical=3).

| ID | Threat | Likelihood | Impact | Risk Score | Status |
|---|---|---|---|---|---|
| TM-E-02 | SQL injection via frappe.db.sql | Medium (2) | Critical (3) | **6** | Partial — parameterized query policy ada; perlu static analysis di CI |
| TM-E-03 | ignore_permissions misuse di custom code | Medium (2) | Critical (3) | **6** | Partial — policy ada; perlu automated grep di CI |
| TM-I-03 | Backup file interception | Low (1) | Critical (3) | **3** | Mitigated — GPG AES-256 sebelum upload |
| TM-T-01 | Direct DB manipulation (bypass Frappe) | Low (1) | Critical (3) | **3** | Partial — localhost-only DB; residual insider risk |
| TM-T-02 | GL Entry manipulation post-submit | Low (1) | Critical (3) | **3** | Mitigated — Frappe immutable GL; reversal-only |
| TM-S-01 | Credential stuffing pada login | High (3) | High (3) | **9 → 3** | Mitigated — lockout + fail2ban + 2FA untuk privileged roles |
| TM-S-03 | Phishing Finance Manager / Admin | Medium (2) | Critical (3) | **6 → 3** | Partial — 2FA mengurangi dampak; social engineering residual |
| TM-E-01 | Field Staff approve Cash Advance sendiri | Medium (2) | High (3) | **6 → 3** | Partial — has_permission hook perlu test coverage penuh |
| TM-I-01 | Akses tidak sah ke PII donor | Medium (2) | High (3) | **6 → 3** | Partial — field masking ada; custom report perlu review |
| TM-I-02 | Data keuangan via API endpoint tidak aman | Medium (2) | High (3) | **6 → 3** | Partial — whitelist policy ada; perlu automated lint |
| TM-R-01 | Staff menyangkal approve transaksi | Medium (2) | Medium (2) | **4** | Partial — version history ada; 2FA tidak wajib semua role |
| TM-D-01 | Heavy report generation | Medium (2) | Medium (2) | **4** | Partial — background jobs; perlu rate limiting |
| TM-D-02 | Bulk file upload exhausting disk | Medium (2) | Medium (2) | **4** | Partial — file size limit + monitoring disk usage |
| TM-S-02 | Session token theft via XSS | Low (1) | High (3) | **3** | Mitigated — Frappe escaping + CSP + HttpOnly cookie |
| TM-T-03 | Audit log tampering | Low (1) | High (3) | **3** | Mitigated — no delete permission via UI; residual DB access |
| TM-R-02 | Admin menyangkal ubah System Settings | Low (1) | High (3) | **3** | Mitigated — Activity Log; sedikit System Admin |
| TM-I-04 | Sensitive data di server log | Low (1) | High (3) | **3** | Mitigated — developer_mode=0; deploy checklist |
| TM-D-03 | Redis memory exhaustion | Low (1) | Medium (2) | **2** | Mitigated — localhost-only; LRU eviction |

**Catatan kolom Status:**
- **Mitigated** = kontrol yang ada secara substansial mengurangi risk ke level yang dapat diterima
- **Partial** = kontrol ada tapi ada gap yang perlu ditutup sebelum go-live (lihat kolom Residual risk di seksi 4)
- **Open** = belum ada mitigasi yang signifikan

---

## 6. Security Assumptions dan Residual Risk yang Diterima

### Asumsi yang Tidak Bisa Dikontrol

| Asumsi | Catatan |
|---|---|
| Keamanan upstream Frappe/ERPNext | Fundara mengikuti patch release ERPNext v16; tidak mengaudit source code Frappe secara penuh. Mitigasi: ikuti Frappe security advisories; pin versi; update dalam 30 hari untuk patch CRITICAL. |
| Keamanan kernel Ubuntu 24.04 | Ubuntu kernel security updates di-handle via `unattended-upgrades`. Full kernel audit di luar scope. |
| Keamanan implementasi TLS di Nginx | Let's Encrypt + Mozilla SSL Configuration Generator digunakan sebagai baseline. Diasumsikan benar. |
| Keamanan penyedia datacenter / VPS | Keamanan fisik server adalah tanggung jawab penyedia (misalnya: Hetzner, AWS, Biznet). Physical access attack di luar scope teknis Fundara. |
| Keamanan S3-compatible offsite storage | Bucket credentials disimpan aman; backup terenkripsi. Keamanan platform storage (Wasabi, Backblaze B2) diasumsikan sesuai standar industri. |

### Residual Risk yang Diterima (Low Severity, Keputusan Terdokumentasi)

| Risk | Alasan Diterima |
|---|---|
| Phishing / social engineering staf | Di luar scope teknis. Dialamatkan dengan pelatihan keamanan saat onboarding dan refresher tahunan. Mitigasi teknis (2FA) sudah di-implement untuk peran kritis. |
| Insider threat dari DevOps dengan akses DB | Jumlah DevOps sangat terbatas; proses offboarding (revoke SSH key, nonaktifkan akun) wajib pada hari yang sama. Backup offsite terenkripsi memberikan audit evidence independen. Monitoring akses SSH direkomendasikan di future release. |
| TOTP bypass oleh real-time phishing proxy (evilginx-style) | Attack ini sangat targeted dan membutuhkan effort tinggi. Probabilitas rendah untuk NGO Indonesia yang tidak menjadi target spionase tingkat negara. Residual risk diterima; mitigasi tambahan (hardware key / FIDO2) bisa ditambahkan di future release jika threat level meningkat. |
| Password sharing antar staf | Kebijakan no-shared-accounts dikomunikasikan saat onboarding. Tidak bisa dikontrol secara teknis penuh tanpa biometrik. 2FA untuk peran kritis mengurangi dampak. |
| Custom report yang dibuat ad-hoc bypass field masking | Semua custom report yang mengakses DocType sensitif wajib melalui code review. Kepatuhan bergantung pada disiplin tim; bukan kontrol teknis otomatis. |
