# Dokumen Ruang Lingkup ISMS — Fundara

**Nomor Dokumen:** ISP-002  
**Versi:** 1.0  
**Tanggal Berlaku:** _(diisi saat ditandatangani)_  
**Status:** Draft — menunggu persetujuan Pimpinan  
**Pemilik Dokumen:** Project Manager  
**Disetujui oleh:** _(Direktur Eksekutif / Product Owner)_  
**Tinjauan berikutnya:** 12 bulan setelah tanggal berlaku  
**Referensi standar:** ISO/IEC 27001:2022 Klausul 4.1, 4.2, 4.3, 4.4  
**Dokumen induk:** `docs/security/is-policy.md` (ISP-001)

---

## 1. Tujuan Dokumen

Dokumen ini menetapkan batas dan konteks Information Security Management System (ISMS) Fundara secara formal, sebagaimana disyaratkan oleh ISO/IEC 27001:2022 Klausul 4.3. Dokumen ini menjawab tiga pertanyaan mendasar:

1. **Apa** — aset, proses, dan sistem mana yang dikelola oleh ISMS ini?
2. **Siapa** — pihak mana yang tunduk pada ISMS ini dan berkepentingan terhadapnya?
3. **Mengapa** — apa konteks organisasi dan regulasi yang membentuk kebutuhan ISMS ini?

Tanpa batas yang jelas, audit keamanan tidak dapat menentukan apa yang harus diperiksa, dan tim tidak dapat fokus pada aset yang paling kritis.

---

## 2. Konteks Organisasi (Klausul 4.1)

### 2.1 Deskripsi Organisasi

Fundara adalah platform perangkat lunak manajemen keuangan berbasis ERPNext v16 / Frappe Framework yang dikembangkan khusus untuk organisasi nirlaba (NGO, Yayasan, LSM) di Indonesia. Fundara dibangun sebagai *custom app* yang berjalan di atas ERPNext dan menyediakan modul: manajemen dana, program dan aktivitas, advance dan liquidasi, campaign dan donasi, laporan kepatuhan donor, dan rekonsiliasi bank.

**Tim pengembang dan operator Fundara** adalah subjek utama ISMS ini — bukan organisasi NGO yang menggunakannya. NGO adalah *klien* yang mempercayakan data mereka kepada platform yang dibangun dan dioperasikan tim ini.

### 2.2 Isu Internal yang Relevan untuk ISMS

| Isu Internal | Relevansi untuk Keamanan Informasi |
|---|---|
| Tim kecil (2 developer, 1 PM, 1 TL) | Tidak ada dedicated security officer — TL merangkap tanggung jawab keamanan teknis. Risiko single point of failure pada pengetahuan keamanan. |
| Platform berbasis ERPNext (open source) | Ketergantungan pada security patch upstream ERPNext/Frappe — kerentanan di upstream mempengaruhi Fundara. Jalur patch harus terstruktur. |
| Tahap pengembangan aktif | Kode berubah cepat, permukaan serangan (*attack surface*) berkembang di setiap sprint. Keamanan harus diintegrasikan ke dalam siklus development, bukan hanya di akhir. |
| Developer bekerja remote / distributed | Tidak ada kontrol fisik terpusat atas workstation developer. Setiap workstation adalah titik masuk potensial. |
| Penggunaan GitHub untuk version control | Repositori kode adalah aset kritis — kebocoran kode dapat mengekspos logika bisnis dan potensi kerentanan. |

### 2.3 Isu Eksternal yang Relevan untuk ISMS

| Isu Eksternal | Relevansi untuk Keamanan Informasi |
|---|---|
| UU PDP No. 27 Tahun 2022 | Kewajiban hukum perlindungan data pribadi donatur, benefisiari, dan staf NGO. Notifikasi pelanggaran 14 hari ke Kominfo/BSSN. |
| Ekosistem NGO Indonesia (kepercayaan donatur) | Data donor dan keuangan adalah fondasi kepercayaan publik. Kebocoran data dapat merusak reputasi NGO pengguna secara permanen. |
| Ancaman siber terhadap platform keuangan | ERPNext/Frappe adalah target potensial — ada komunitas attacker yang memahami arsitektur Frappe. Risiko credential stuffing, SSRF, dan privilege escalation spesifik Frappe terdokumentasi di `docs/security/threat-model.md`. |
| Hosting provider (cloud VPS) | Keamanan fisik data center dan hypervisor adalah tanggung jawab provider, bukan tim Fundara. Ketergantungan pada SLA dan kebijakan keamanan provider. |
| ERPNext/Frappe upstream (Frappe Technologies) | Fundara bergantung pada integritas rilis ERPNext. Kompromi pada upstream supply chain akan mempengaruhi Fundara. |

---

## 3. Pihak Berkepentingan (Klausul 4.2)

### 3.1 Daftar Pihak Berkepentingan dan Kebutuhan Keamanan

| Pihak Berkepentingan | Hubungan | Kebutuhan Keamanan yang Relevan untuk ISMS |
|---|---|---|
| **Organisasi NGO / Yayasan pengguna** | Klien — mempercayakan data operasional kepada Fundara | Kerahasiaan data keuangan dan program; ketersediaan sistem saat dibutuhkan; keutuhan data akuntansi (GL tidak boleh berubah setelah posting); notifikasi jika ada insiden yang mempengaruhi data mereka |
| **Donatur individu dan institusi** | Subjek data — data pribadi dan keuangan diproses oleh sistem | Kerahasiaan identitas dan jumlah donasi; hak akses, koreksi, dan penghapusan data sesuai UU PDP; tidak ada penyalahgunaan data untuk tujuan lain |
| **Benefisiari program NGO** | Subjek data — data pribadi (termasuk data sensitif kondisi kesehatan/sosial) | Perlindungan data sensitif dengan kontrol akses ketat; data anak di bawah umur dengan perlindungan tertinggi |
| **Tim pengembang Fundara** (PM, TL, DEV, QA, domain expert) | Internal — membangun dan mengoperasikan platform | Kejelasan tanggung jawab keamanan; prosedur yang tidak ambigu; perlindungan agar tidak menjadi vektor serangan secara tidak sengaja |
| **Regulator** (Kominfo, BSSN) | Pengawas hukum | Kepatuhan UU PDP; notifikasi insiden sesuai Pasal 46; ketersediaan informasi untuk audit regulasi |
| **Auditor eksternal / penetration tester** | Verifikasi independen | Akses terbatas dan terkontrol ke lingkungan pengujian; dokumentasi scope yang jelas (`docs/security/pentest-scope.md`) |
| **Penyedia layanan hosting** | Infrastruktur fisik | SLA ketersediaan; keamanan fisik data center; prosedur notifikasi insiden infrastruktur |
| **Frappe Technologies (upstream)** | Vendor perangkat lunak inti | Distribusi security patch yang tepat waktu; CVE disclosure yang transparan |

### 3.2 Kebutuhan yang Relevan untuk Scope ISMS

Dari analisis pihak berkepentingan, ISMS Fundara harus mencakup:

- Perlindungan data Rahasia (donatur, benefisiari, keuangan) — terdefinisi dalam `docs/security/data-privacy.md`
- Ketersediaan sistem operasional minimal dengan RTO 4 jam dan RPO 24 jam
- Keutuhan catatan akuntansi yang tidak dapat dimodifikasi setelah posting
- Mekanisme notifikasi insiden yang memenuhi kewajiban UU PDP
- Kontrol akses yang memisahkan peran pengaju, penyetuju, dan pembayar

---

## 4. Ruang Lingkup ISMS (Klausul 4.3)

### 4.1 Pernyataan Ruang Lingkup

> **ISMS ini mencakup pengembangan, pengujian, penerapan, dan operasional platform Fundara — termasuk seluruh aset informasi, infrastruktur, proses, dan personel yang terlibat dalam siklus hidup tersebut — untuk melindungi kerahasiaan, keutuhan, dan ketersediaan data yang dipercayakan oleh organisasi pengguna dan subjek data terkait.**

### 4.2 Batas Teknologi — Dalam Lingkup

Komponen berikut **termasuk** dalam lingkup ISMS:

| Komponen | Deskripsi | Kategori |
|---|---|---|
| **Kode sumber Fundara** | Repositori `masmaksum/Fundara` di GitHub — custom app, fixtures, migration scripts, konfigurasi | Aset Informasi |
| **Dokumentasi dan spesifikasi** | Seluruh dokumen di repositori: `docs/spec/`, `docs/pm/`, `docs/security/`, `docs/infra/`, `docs/dev/`, `docs/qa/` | Aset Informasi |
| **Lingkungan pengembangan lokal** | Workstation developer yang menjalankan bench/ERPNext lokal dan memiliki akses ke repositori kode | Aset Teknologi |
| **Lingkungan staging** | Server Ubuntu 24.04 (Profile B: 4 vCPU, 8 GB RAM) yang menjalankan ERPNext v16 + Fundara, digunakan untuk UAT dan QA | Aset Teknologi |
| **Lingkungan produksi** | Server Ubuntu 24.04 (Profile B/C) yang menjalankan ERPNext v16 + Fundara untuk organisasi pengguna aktif | Aset Teknologi |
| **Sistem backup** | File backup terenkripsi GPG yang disimpan di offsite storage; skrip `bench backup`, `rclone` | Aset Teknologi |
| **Sistem monitoring** | Netdata (metrik server), Uptime Kuma (availability monitoring), alert channels (email/Telegram) | Aset Teknologi |
| **Database MariaDB** | Instans database yang menyimpan seluruh data transaksi, akun pengguna, dan data NGO | Aset Teknologi |
| **Redis** | Session store dan task queue (port 13000/11000/12000) | Aset Teknologi |
| **Nginx / SSL** | Reverse proxy dan terminasi TLS untuk semua lingkungan | Aset Teknologi |
| **Kredensial dan secret** | API keys, SSH keys, GPG keys, database passwords, `common_site_config.json`, environment variables | Aset Informasi (Rahasia) |
| **Pipeline CI/CD** | GitHub Actions atau mekanisme deployment yang digunakan untuk release Fundara | Aset Teknologi |
| **SMTP relay** | Konfigurasi pengiriman email notifikasi sistem (Frappe Email) | Aset Teknologi |
| **Data NGO yang diproses** | Seluruh data yang dimasukkan organisasi pengguna ke dalam sistem: data donatur, transaksi keuangan, data program, data benefisiari | Aset Informasi (Rahasia) |

### 4.3 Batas Fisik — Dalam Lingkup

| Lokasi | Status | Keterangan |
|---|---|---|
| Server staging (cloud VPS) | **Dalam lingkup** | Dikonfigurasi dan dioperasikan oleh tim Fundara |
| Server produksi (cloud VPS) | **Dalam lingkup** | Dikonfigurasi dan dioperasikan oleh tim Fundara |
| Workstation developer (remote) | **Dalam lingkup — parsial** | Dalam lingkup untuk aspek: enkripsi disk, kunci layar, tidak menyimpan secret di plaintext, tidak mengakses data produksi dari jaringan tidak aman |
| Kantor tim Fundara (jika ada) | **Dalam lingkup — parsial** | Keamanan layar dan perangkat yang digunakan untuk pekerjaan Fundara |

### 4.4 Batas Organisasi — Dalam Lingkup

Seluruh anggota tim Fundara yang memiliki akses ke aset informasi yang tercakup:
- Project Manager
- Tech Lead / DevOps
- Developer(s)
- QA Engineer
- Domain Expert (Finance, Program)
- UX Designer (akses terbatas ke dokumen desain)
- Pihak ketiga dengan akses terkontrol (auditor, penetration tester) — tunduk pada NDA dan scope terbatas

### 4.5 Sistem yang Dikecualikan — Di Luar Lingkup

| Komponen | Alasan Pengecualian |
|---|---|
| **Infrastruktur fisik data center** (server rack, jaringan fisik, power) | Dikelola sepenuhnya oleh penyedia layanan hosting. Fundara tidak memiliki akses fisik atau kontrol atas lapisan ini. Keamanan fisik adalah tanggung jawab dan jaminan provider (SLA, sertifikasi data center). |
| **Hypervisor dan lapisan virtualisasi** | Di bawah kendali penyedia hosting VPS. Fundara beroperasi pada lapisan OS ke atas. |
| **ERPNext / Frappe upstream codebase** | Dikembangkan dan dikelola oleh Frappe Technologies. Fundara mengkonsumsi rilis resmi dan memantau CVE upstream, tetapi tidak mengontrol proses keamanan pengembangan upstream. |
| **Infrastruktur internal IT organisasi NGO pengguna** | Jaringan internal, perangkat pengguna akhir, dan sistem IT lain milik NGO berada di luar kendali tim Fundara. |
| **Sistem email milik NGO** (SMTP server NGO sendiri) | Jika NGO menggunakan SMTP server sendiri, konfigurasi dan keamanannya adalah tanggung jawab NGO. |
| **Integrasi eksternal post-MVP** (payment gateway, KoboToolbox, bank API) | Belum dalam scope MVP. Jika diimplementasikan di masa depan, scope ISMS ini harus direvisi untuk mencakup antarmuka integrasi tersebut. |
| **Perangkat pribadi anggota tim** untuk aktivitas non-Fundara | Hanya aspek workstation yang digunakan untuk pekerjaan Fundara yang dalam lingkup (lihat 4.3). |

---

## 5. Antarmuka dan Dependensi Eksternal

Komponen berikut berada di luar scope ISMS tetapi memiliki antarmuka dengan sistem yang dicakup. Risiko di antarmuka ini dikelola melalui kontrol di sisi Fundara:

| Antarmuka Eksternal | Arah Data | Kontrol Fundara |
|---|---|---|
| **Penyedia hosting VPS** | Fundara → hosting (deploy, backup offsite) | Pilih provider dengan sertifikasi keamanan; enkripsi data sebelum keluar dari server Fundara (GPG backup); SSH key authentication; firewall UFW |
| **GitHub** (version control) | Kode → GitHub; GitHub → CI pipeline | Branch protection; tidak ada secret di kode; 2FA wajib untuk akun GitHub tim; akses repositori berbasis peran |
| **SMTP relay** (pengiriman email notifikasi) | Fundara → SMTP relay → inbox pengguna | Gunakan provider SMTP terpercaya; TLS wajib; tidak kirim data sensitif via email; validasi konfigurasi SMTP sebelum go-live |
| **Let's Encrypt** (sertifikat SSL) | Fundara ← Let's Encrypt (certbot renewal) | Monitoring expired certificate (<30 hari alert); fallback manual renewal procedure |
| **Browser pengguna akhir NGO** | Pengguna → Nginx → Frappe (HTTPS) | HSTS; X-Frame-Options; X-Content-Type-Options; CSP header |
| **Offsite backup storage** (rclone target) | Backup terenkripsi → cloud storage | GPG enkripsi sebelum upload; akses dengan API key terbatas (write-only jika memungkinkan); restore drill bulanan |

---

## 6. Perubahan yang Akan Mempengaruhi Scope

Scope ISMS ini harus ditinjau dan diperbarui jika terjadi salah satu kondisi berikut:

| Perubahan | Tindakan |
|---|---|
| Penambahan lingkungan baru (misalnya: multi-tenant hosting untuk beberapa NGO) | Revisi scope — tambahkan batas isolasi antar tenant |
| Integrasi dengan sistem eksternal (payment gateway, API donor management) | Revisi scope — tambahkan antarmuka eksternal baru dan analisis risiko terkait |
| Perpindahan penyedia hosting | Tinjauan scope — verifikasi kontrol keamanan pada provider baru |
| Penambahan anggota tim atau kontraktor | Verifikasi bahwa NDA dan akses terkontrol sesuai scope |
| Perubahan regulasi yang relevan (amandemen UU PDP, regulasi fintech NGO) | Revisi section 2 dan 3 untuk mencerminkan kewajiban baru |
| Keputusan D-06 (multi-tenancy) diimplementasikan | Revisi scope signifikan — pemisahan data antar tenant harus dicakup secara eksplisit |

---

## 7. Gambaran ISMS Fundara (Klausul 4.4)

ISMS Fundara dikelola menggunakan siklus PDCA (Plan-Do-Check-Act):

| Fase | Aktivitas | Dokumen / Proses |
|---|---|---|
| **Plan** | Identifikasi risiko, tetapkan kontrol, rencanakan governance | `docs/pm/risk-register.md`, `docs/security/threat-model.md`, Risk Treatment Plan (dalam pembuatan) |
| **Do** | Implementasikan kontrol teknis dan governance, jalankan proses operasional | `docs/security/security-requirements.md`, sprint development, Governance Track |
| **Check** | Audit internal, monitoring insiden, review risiko, regression testing keamanan | Internal Audit Checklist (dalam pembuatan), `docs/qa/regression-checklist.md` |
| **Act** | Tindak lanjut temuan audit, perbarui kebijakan, tingkatkan kontrol | Management Review, update DECISIONS.md, revisi dokumen keamanan |

Siklus ini dijalankan dengan ritme:
- **Per sprint:** security gate di Definition of Done (`docs/pm/definition-of-done.md`)
- **Per kuartal:** tinjauan akses dan risk register
- **Per tahun:** internal audit ISMS dan management review formal
- **On-demand:** setelah insiden keamanan atau perubahan scope signifikan

---

## 8. Referensi Dokumen Terkait

| Dokumen | Lokasi | Relasi ke Scope |
|---|---|---|
| Kebijakan Keamanan Informasi | `docs/security/is-policy.md` | Induk kebijakan — mendefinisikan prinsip dan tanggung jawab |
| Security Requirements | `docs/security/security-requirements.md` | Implementasi teknis kontrol untuk aset yang dicakup |
| Threat Model | `docs/security/threat-model.md` | Ancaman spesifik terhadap aset yang dicakup |
| Data Privacy Spec | `docs/security/data-privacy.md` | Pengelolaan data pribadi dalam scope |
| Environment Spec | `docs/infra/environment-spec.md` | Detail teknis aset teknologi yang dicakup |
| Pentest Scope | `docs/security/pentest-scope.md` | Subset dari scope ISMS untuk pengujian penetrasi |
| Risk Register | `docs/pm/risk-register.md` | Risiko yang berlaku pada aset dalam scope |
| ISO 27001 Audit | `docs/security/iso27001-audit.md` | Gap analysis terhadap standar untuk scope ini |

---

## 9. Persetujuan dan Pengesahan

Dengan menandatangani dokumen ini, Pimpinan menyatakan persetujuan terhadap batas dan konteks ISMS yang ditetapkan dalam dokumen ini sebagai acuan resmi untuk pengelolaan keamanan informasi Fundara.

---

**Disetujui oleh:**

&nbsp;

Nama&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;: _______________________________________________

Jabatan&nbsp;&nbsp;&nbsp;: _______________________________________________

Tanggal&nbsp;&nbsp;: _______________________________________________

Tanda Tangan: _______________________________________________

&nbsp;

**Disiapkan oleh:**

&nbsp;

Nama&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;: _______________________________________________

Jabatan&nbsp;&nbsp;&nbsp;: Project Manager

Tanggal&nbsp;&nbsp;: 20 Juni 2026

Tanda Tangan: _______________________________________________
