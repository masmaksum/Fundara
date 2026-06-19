# Kebijakan Keamanan Informasi — Fundara

**Nomor Dokumen:** ISP-001  
**Versi:** 1.0  
**Tanggal Berlaku:** _(diisi saat ditandatangani)_  
**Status:** Draft — menunggu persetujuan Pimpinan  
**Pemilik Dokumen:** Project Manager  
**Disetujui oleh:** _(Direktur Eksekutif / Product Owner)_  
**Tinjauan berikutnya:** 12 bulan setelah tanggal berlaku  
**Referensi standar:** ISO/IEC 27001:2022 Klausul 5.2, A.5.1

---

## 1. Pendahuluan

Fundara adalah platform perangkat lunak manajemen keuangan berbasis ERPNext yang dikembangkan khusus untuk organisasi nirlaba (NGO/Yayasan) di Indonesia. Sistem ini memproses data keuangan sensitif, data pribadi donatur, data program, dan data penerima manfaat yang dipercayakan oleh organisasi pengguna.

Kepercayaan organisasi pengguna adalah fondasi keberlanjutan Fundara. Keamanan informasi bukan pilihan operasional — melainkan kewajiban etis dan hukum yang melekat pada sifat data yang diproses.

Kebijakan ini menetapkan komitmen, prinsip, dan arah strategis keamanan informasi bagi seluruh pihak yang terlibat dalam pengembangan, pengujian, penerapan, dan operasional Fundara.

---

## 2. Tujuan

Kebijakan ini bertujuan untuk:

1. Menyatakan komitmen pimpinan terhadap keamanan informasi sebagai prioritas organisasi.
2. Menetapkan prinsip-prinsip keamanan informasi yang mengikat seluruh anggota tim.
3. Memastikan perlindungan atas kerahasiaan (*confidentiality*), keutuhan (*integrity*), dan ketersediaan (*availability*) aset informasi Fundara dan data yang dipercayakan oleh pengguna.
4. Memenuhi kewajiban hukum yang berlaku, termasuk UU PDP No. 27 Tahun 2022 dan standar ISO/IEC 27001:2022.
5. Menjadi landasan bagi seluruh kebijakan, prosedur, dan kontrol keamanan turunan.

---

## 3. Ruang Lingkup

Kebijakan ini berlaku untuk:

**Pihak yang terikat:**
- Seluruh anggota tim Fundara: Project Manager, Tech Lead, Developer, QA Engineer, Domain Expert, UX Designer, dan DevOps/SysAdmin.
- Pihak ketiga yang mendapat akses ke aset informasi Fundara: kontraktor, konsultan, vendor layanan, dan auditor — tunduk pada NDA dan ketentuan keamanan yang setara.

**Aset yang dicakup:**
- Kode sumber Fundara dan repositori (`masmaksum/Fundara`).
- Dokumentasi teknis, spesifikasi, dan dokumen desain.
- Infrastruktur pengembangan, staging, dan produksi (server, database, backup, monitoring).
- Data uji coba dan demo (termasuk data sintetis yang mewakili data NGO nyata).
- Data NGO yang diproses selama layanan dukungan teknis atau migrasi.
- Kredensial, API key, dan secret management.

**Lingkungan yang dicakup:**
- Lingkungan pengembangan lokal seluruh developer.
- Lingkungan staging dan UAT.
- Lingkungan produksi yang dioperasikan untuk organisasi pengguna.

---

## 4. Definisi

| Istilah | Definisi |
|---|---|
| **Aset Informasi** | Data, sistem, dokumen, atau infrastruktur yang memiliki nilai bagi Fundara atau penggunanya |
| **ISMS** | *Information Security Management System* — sistem pengelolaan keamanan informasi yang terstruktur |
| **Data Pribadi** | Informasi yang dapat mengidentifikasi individu secara langsung atau tidak langsung (UU PDP Pasal 1) |
| **Insiden Keamanan** | Kejadian yang mengancam atau melanggar kerahasiaan, keutuhan, atau ketersediaan aset informasi |
| **Risk Treatment** | Tindakan yang dipilih untuk mengelola risiko: mitigasi, transfer, penerimaan, atau penghindaran |
| **Pemroses Data** | Pihak yang memproses data pribadi atas instruksi pemilik data (Fundara dalam konteks layanan ke NGO) |
| **Pemilik Data** | Organisasi NGO yang menggunakan Fundara dan bertanggung jawab atas data yang dikelolanya |

---

## 5. Kebijakan Keamanan Informasi

### 5.1 Prinsip Dasar

Seluruh keputusan, rancangan, dan tindakan dalam lingkup Fundara harus memperhatikan tiga pilar keamanan informasi:

- **Kerahasiaan (*Confidentiality*):** Informasi hanya dapat diakses oleh pihak yang berwenang. Data donatur, benefisiari, dan keuangan tidak boleh terekspos ke pihak yang tidak berkepentingan.
- **Keutuhan (*Integrity*):** Informasi hanya dapat diubah oleh pihak yang berwenang melalui proses yang terdefinisi dan tercatat. Catatan jurnal akuntansi bersifat permanen dan tidak dapat dihapus.
- **Ketersediaan (*Availability*):** Sistem tersedia bagi pengguna yang berwenang sesuai kebutuhan operasional NGO, dengan RTO 4 jam dan RPO 24 jam sebagai target minimal.

Prinsip tambahan yang mengikat dalam pengembangan Fundara:

- **Security by Design:** Keamanan dipertimbangkan sejak tahap perancangan, bukan ditambahkan setelah sistem selesai.
- **Least Privilege:** Setiap pengguna dan komponen sistem hanya mendapat akses minimum yang dibutuhkan untuk menjalankan fungsinya.
- **Defense in Depth:** Keamanan tidak bergantung pada satu lapisan kontrol — kegagalan satu kontrol tidak boleh mengakibatkan kompromi penuh.
- **Audit Trail:** Semua transaksi keuangan dan perubahan data sensitif harus meninggalkan jejak yang dapat diaudit.

### 5.2 Tujuan Keamanan Informasi

Tujuan keamanan informasi Fundara yang terukur:

| # | Tujuan | Target | Penanggung Jawab |
|---|---|---|---|
| 1 | Tidak ada kebocoran data produksi yang disebabkan oleh kelemahan kode atau konfigurasi | 0 insiden Critical go-live | Tech Lead |
| 2 | Seluruh akses ke lingkungan produksi menggunakan autentikasi dua faktor | 100% user Finance Manager ke atas | Tech Lead |
| 3 | Backup terenkripsi tersedia dan terbukti dapat dipulihkan | Restore drill berhasil setiap bulan | Tech Lead / DevOps |
| 4 | Seluruh anggota tim menandatangani NDA sebelum mendapat akses ke staging | 100% sebelum staging aktif | Project Manager |
| 5 | Kerentanan Critical pada dependensi ditangani dalam 7 hari | SLA 7 hari, 0 exception tanpa persetujuan | Tech Lead |
| 6 | Tidak ada penggunaan `ignore_permissions` di kode produksi tanpa justifikasi terdokumentasi | 0 undocumented | Tech Lead |

Tujuan ini ditinjau setiap kuartal dalam Management Review ISMS.

### 5.3 Klasifikasi dan Pengelolaan Informasi

Seluruh aset informasi Fundara diklasifikasikan berdasarkan sensitivitas:

| Klasifikasi | Definisi | Contoh | Perlakuan |
|---|---|---|---|
| **Rahasia** | Data yang jika terekspos dapat merugikan individu atau organisasi secara signifikan | Data pribadi donatur (NIK, NPWP), data benefisiari, data kesehatan, kredensial produksi | Enkripsi wajib saat disimpan dan dikirim; akses hanya dengan otorisasi eksplisit; tidak boleh ada di log |
| **Internal** | Data operasional yang tidak ditujukan untuk publik | Kode sumber, dokumen spec, data keuangan organisasi, laporan internal | Akses terbatas pada tim; tidak dibagikan tanpa persetujuan PM atau TL |
| **Publik** | Informasi yang dapat dibagikan ke publik tanpa risiko | Dokumentasi pengguna yang dipublikasikan, release notes publik | Tidak ada pembatasan distribusi |

Pengelolaan data Rahasia:
- Tidak boleh disimpan di repositori Git, termasuk repositori privat.
- Tidak boleh dikirim melalui aplikasi pesan instan tanpa enkripsi.
- Tidak boleh ada dalam demo data atau test fixture dalam bentuk asli — harus dianonimkan atau dibuat sintetis.
- Harus dihapus secara aman ketika tidak lagi dibutuhkan (lihat `docs/security/data-privacy.md` § Retensi).

### 5.4 Kontrol Akses dan Identitas

- Setiap individu memiliki satu akun yang tidak dapat dibagikan. Akun bersama (*shared account*) dilarang.
- Pemberian akses mengikuti prinsip *least privilege* — hak akses disesuaikan dengan peran, bukan lebih.
- Akses ke lingkungan staging dan produksi memerlukan persetujuan Tech Lead.
- Seluruh akun yang tidak aktif lebih dari 60 hari dinonaktifkan secara otomatis atau manual.
- Autentikasi dua faktor (TOTP) wajib untuk peran Finance Manager, System Admin, dan Pimpinan.
- Akses SSH ke server produksi hanya melalui SSH key — autentikasi password dilarang.
- Seluruh API key dan secret disimpan sebagai environment variable di server, tidak pernah di kode sumber atau repositori.
- Hak akses ditinjau setiap kuartal oleh Project Manager.

Detail implementasi teknis: `docs/security/security-requirements.md` § SR-AUTH dan SR-AUTHZ.

### 5.5 Keamanan Sumber Daya Manusia

**Sebelum bergabung:**
- Seluruh anggota tim dan pihak ketiga yang mendapat akses ke aset Fundara wajib menandatangani Perjanjian Kerahasiaan (NDA) sebelum menerima akses apa pun.
- NDA mencakup: kewajiban kerahasiaan selama dan setelah masa kerja, larangan penggunaan data untuk kepentingan pribadi, dan sanksi pelanggaran.
- NDA harus ditandatangani **sebelum** staging environment diaktifkan.

**Selama masa kerja:**
- Seluruh anggota tim mendapatkan orientasi keamanan informasi yang mencakup kebijakan ini dan prosedur pelaporan insiden.
- Pelanggaran kebijakan keamanan wajib dilaporkan kepada PM dan TL dalam 24 jam.
- Developer tidak boleh menggunakan data produksi nyata untuk pengujian lokal — gunakan data sintetis dari `docs/qa/demo-data.md`.

**Saat berakhirnya hubungan kerja:**
- Seluruh akses dicabut pada hari terakhir bekerja, mengikuti Offboarding Checklist yang ditetapkan.
- Offboarding Checklist mencakup: revoke GitHub access, nonaktifkan akun Frappe, cabut API key, transfer credentials ke vault baru, dan notifikasi PM.
- Kewajiban kerahasiaan dalam NDA berlanjut setelah berakhirnya hubungan kerja.

### 5.6 Keamanan Fisik dan Lingkungan

Fundara dioperasikan pada infrastruktur cloud yang dikelola oleh penyedia layanan hosting terpercaya. Keamanan fisik pusat data adalah tanggung jawab penyedia layanan hosting.

Kewajiban tim Fundara terkait keamanan fisik:
- Perangkat kerja (laptop/PC) yang digunakan untuk pengembangan harus dilindungi dengan enkripsi disk (FileVault/BitLocker/LUKS).
- Perangkat kerja tidak boleh ditinggalkan dalam keadaan tidak terkunci di tempat umum.
- Kredensial tidak boleh ditulis di tempat yang dapat dilihat pihak lain.
- Layar harus dikunci saat developer meninggalkan workstation, meskipun hanya sebentar.

### 5.7 Keamanan Operasional

**Pengelolaan perubahan:**
- Setiap perubahan pada kode produksi melalui proses review dan persetujuan TL sebelum merge (lihat `docs/dev/git-branching.md`).
- Perubahan pada konfigurasi infrastruktur produksi didokumentasikan dan disetujui TL sebelum diterapkan.
- Pembaruan ERPNext/Frappe mengikuti prosedur upgrade tertulis (`docs/infra/upgrade-runbook.md`).

**Pemantauan dan logging:**
- Seluruh akses dan aktivitas pada sistem produksi dicatat dan dipantau.
- Log tidak boleh dimodifikasi atau dihapus sebelum masa retensi berakhir (minimum 1 tahun).
- Stack monitoring (Netdata + Uptime Kuma) aktif di lingkungan produksi dengan alert yang dikonfigurasi untuk threshold kritis (disk >75%, memory >85%, CPU sustained >80%, SSL <30 hari, service down).

**Keamanan perangkat lunak:**
- Dependensi perangkat lunak (Python packages, npm) dipindai kerentanan secara berkala menggunakan `pip audit` dan `npm audit`.
- Kerentanan Critical pada dependensi ditangani dalam SLA 7 hari.
- Kode sumber tidak boleh mengandung secret, password, atau API key — gunakan environment variable.
- `developer_mode` dinonaktifkan di lingkungan produksi sebelum go-live.

**Backup:**
- Backup otomatis dilakukan setiap hari sesuai prosedur di `docs/infra/backup-recovery.md`.
- Backup dienkripsi menggunakan GPG sebelum disimpan di offsite storage.
- Prosedur restore diuji secara rutin — minimal satu kali sebulan setelah go-live — dan hasilnya dicatat dalam Drill Log bertanda tangan TL.

Detail implementasi: `docs/infra/backup-recovery.md`, `docs/infra/monitoring-spec.md`.

### 5.8 Perlindungan Data Pribadi

Fundara berkomitmen mematuhi UU PDP No. 27 Tahun 2022 sebagai **Pemroses Data Pribadi** yang bertindak atas instruksi organisasi pengguna (Pemilik Data).

Kewajiban Fundara sebagai Pemroses Data:
- Hanya memproses data pribadi sesuai instruksi yang diterima dari organisasi pengguna.
- Mengimplementasikan langkah teknis dan organisasi yang memadai untuk melindungi data pribadi.
- Tidak menggunakan data pribadi yang dipercayakan untuk kepentingan selain yang disepakati.
- Memberikan dukungan kepada organisasi pengguna dalam memenuhi kewajiban mereka terhadap subjek data (hak akses, koreksi, penghapusan).
- Melaporkan insiden keamanan yang berdampak pada data pribadi kepada organisasi pengguna dalam waktu yang memungkinkan notifikasi ke Kominfo/BSSN sesuai Pasal 46 UU PDP (14 hari setelah insiden diketahui).

Data pribadi yang diproses Fundara hanya disimpan selama yang diperlukan untuk tujuan pemrosesan, sesuai ketentuan retensi dalam `docs/security/data-privacy.md`.

### 5.9 Manajemen Risiko Keamanan Informasi

- Risiko keamanan informasi diidentifikasi, dinilai, dan ditangani secara sistematis menggunakan Risk Register (`docs/pm/risk-register.md`) dan Threat Model (`docs/security/threat-model.md`).
- Risk Treatment Plan (RTP) memetakan setiap risiko ke kontrol yang dipilih, PIC, dan timeline.
- Setiap risiko yang diterima (*risk acceptance*) memerlukan persetujuan eksplisit Pimpinan yang terdokumentasi.
- Risk Register ditinjau setiap kali terjadi perubahan signifikan pada sistem, infrastruktur, atau ancaman yang dikenal, dan minimal satu kali per kuartal.

### 5.10 Manajemen Insiden Keamanan

- Setiap anggota tim wajib melaporkan insiden atau dugaan insiden keamanan kepada Tech Lead dan Project Manager dalam waktu **4 jam** setelah mengetahuinya.
- Tidak ada sanksi bagi pelapor insiden yang dilakukan dengan itikad baik — budaya pelaporan terbuka diutamakan.
- Respons insiden mengikuti prosedur lima fase dalam `docs/security/incident-response.md`: Identifikasi → Penahanan → Investigasi → Remediasi → Lessons Learned.
- Insiden yang berdampak pada data pribadi ditangani dengan prioritas tertinggi dan mengikuti kewajiban notifikasi UU PDP.
- Seluruh insiden didokumentasikan dan Post-Incident Report diselesaikan dalam 5 hari kerja setelah insiden tertutup.

### 5.11 Kelangsungan Layanan

- Business Continuity Plan (BCP) memastikan layanan Fundara dapat dipulihkan dalam RTO 4 jam dan RPO 24 jam setelah insiden yang mengganggu ketersediaan.
- BCP mencakup skenario: kegagalan server, kehilangan data, dan kompromi keamanan yang memerlukan isolasi sistem.
- Prosedur failover dan pemulihan diuji secara berkala — minimal satu kali per tahun.

### 5.12 Kepatuhan Hukum dan Regulasi

Fundara berkomitmen mematuhi peraturan dan standar yang berlaku:

| Regulasi / Standar | Relevansi |
|---|---|
| UU PDP No. 27 Tahun 2022 | Perlindungan data pribadi donatur, benefisiari, dan staf |
| ISO/IEC 27001:2022 | Kerangka ISMS yang diadopsi sebagai referensi praktik terbaik |
| OWASP Top 10 (2021) | Keamanan aplikasi web — checklist implementasi di `docs/security/owasp-checklist.md` |
| Peraturan akuntansi NGO Indonesia (ISAK 35) | Integritas dan ketepatan catatan keuangan |

Kepatuhan terhadap regulasi ditinjau dalam Internal Audit ISMS yang dilakukan minimal satu kali per tahun.

---

## 6. Peran dan Tanggung Jawab

| Peran | Tanggung Jawab Keamanan Informasi |
|---|---|
| **Pimpinan / Product Owner** | Menyetujui dan mengesahkan kebijakan ini. Menyetujui Risk Treatment Plan. Membuat keputusan penerimaan risiko (*risk acceptance*). Memberikan sumber daya yang diperlukan untuk ISMS. |
| **Project Manager** | Memastikan kebijakan ini dikomunikasikan dan dipahami seluruh tim. Mengelola proses NDA, onboarding, dan offboarding. Mengkoordinasikan audit internal ISMS. Memastikan Governance Track berjalan sesuai jadwal sprint. |
| **Tech Lead** | Memastikan implementasi teknis sesuai kebijakan ini dan `docs/security/security-requirements.md`. Melakukan code review dengan perspektif keamanan. Mengelola konfigurasi infrastruktur produksi. Memimpin respons insiden keamanan teknis. Memperbarui Risk Treatment Plan. |
| **Developer** | Mengimplementasikan kontrol keamanan dalam kode sesuai spesifikasi. Tidak menggunakan `ignore_permissions` tanpa justifikasi terdokumentasi. Melaporkan kerentanan atau insiden yang ditemukan. Tidak menyimpan secret di repositori. |
| **QA Engineer** | Menjalankan pengujian keamanan sesuai `docs/security/owasp-checklist.md`. Melaporkan temuan kerentanan dalam bug tracker. Berperan sebagai auditor internal ISMS. |
| **Domain Expert (FE / PE)** | Memastikan proses bisnis yang dispesifikasikan tidak menciptakan celah keamanan dalam alur kerja. Mengidentifikasi data sensitif dalam domain masing-masing. |

---

## 7. Pelanggaran Kebijakan

Pelanggaran terhadap kebijakan ini akan ditangani secara proporsional dengan mempertimbangkan:
- Sifat dan kesengajaan pelanggaran.
- Dampak aktual atau potensial terhadap keamanan informasi.
- Riwayat pelanggaran sebelumnya.

Contoh pelanggaran dan konsekuensi yang mungkin berlaku:

| Pelanggaran | Contoh | Konsekuensi |
|---|---|---|
| Tidak sengaja, dampak rendah | Meninggalkan layar tidak terkunci di kantor sendiri | Peringatan lisan, pengingat kebijakan |
| Lalai, dampak sedang | Menyimpan password di file teks di laptop | Peringatan tertulis, review akses |
| Sengaja atau dampak tinggi | Membagikan kredensial produksi kepada pihak tidak berwenang | Pencabutan akses segera, investigasi, dan tindakan disipliner hingga pemutusan hubungan kerja |
| Pelanggaran hukum | Menggunakan data donor untuk kepentingan pribadi | Pencabutan akses segera, investigasi, potensi pelaporan ke aparat hukum |

---

## 8. Pengecualian

Pengecualian terhadap kebijakan ini dapat diberikan dalam keadaan luar biasa yang terdokumentasi, dengan ketentuan:

1. Permintaan pengecualian diajukan secara tertulis kepada Tech Lead dan Project Manager, dengan menyebutkan alasan bisnis yang mendesak.
2. Pengecualian memerlukan persetujuan Pimpinan jika berkaitan dengan kontrol keamanan yang berdampak langsung pada data Rahasia.
3. Setiap pengecualian dicatat dalam Risk Register sebagai risiko yang diterima dengan justifikasi dan batas waktu berlakunya.
4. Pengecualian bersifat sementara — harus ditinjau setiap tiga bulan.

---

## 9. Tinjauan dan Pembaruan

Kebijakan ini ditinjau:
- **Minimal satu kali per tahun** — terjadwal dalam Management Review ISMS.
- **Setelah insiden keamanan signifikan** — dalam 30 hari setelah Post-Incident Report diselesaikan.
- **Setelah perubahan signifikan** — perubahan ruang lingkup sistem, regulasi baru, atau perubahan struktur tim.
- **Setelah audit eksternal** — jika temuan audit memerlukan revisi kebijakan.

Perubahan kebijakan ini memerlukan persetujuan ulang dari Pimpinan sebelum berlaku. Riwayat versi dicatat di bawah.

### Riwayat Versi

| Versi | Tanggal | Perubahan | Disetujui oleh |
|---|---|---|---|
| 1.0 | _(diisi saat ditandatangani)_ | Versi pertama | _(Pimpinan)_ |

---

## 10. Referensi dan Dokumen Terkait

Kebijakan ini menjadi induk (*parent policy*) bagi dokumen-dokumen keamanan berikut:

| Dokumen | Lokasi | Isi |
|---|---|---|
| Security Requirements | `docs/security/security-requirements.md` | Spesifikasi teknis implementasi kontrol keamanan (SR-AUTH, SR-AUTHZ, SR-ENC, SR-LOG, SR-DEV, SR-DEP) |
| Threat Model | `docs/security/threat-model.md` | STRIDE: 9 aset sensitif, 11 aktor, 16 ancaman, mitigasi |
| Data Privacy Spec | `docs/security/data-privacy.md` | Inventaris PII, retensi data, prosedur anonymisasi, UU PDP |
| Incident Response Plan | `docs/security/incident-response.md` | 5 fase respons insiden, notifikasi UU PDP, tabletop exercise |
| OWASP Checklist | `docs/security/owasp-checklist.md` | OWASP Top 10 (2021) untuk Frappe/ERPNext custom app |
| Pentest Scope | `docs/security/pentest-scope.md` | Ruang lingkup, test accounts, rules of engagement |
| ISO 27001 Audit | `docs/security/iso27001-audit.md` | Gap analysis 93 kontrol Annex A + Klausul 4–10 |
| Risk Register | `docs/pm/risk-register.md` | 32 risiko teridentifikasi dengan rating, mitigasi, dan PIC |
| RACI Matrix | `docs/pm/raci.md` | Tanggung jawab per aktivitas termasuk Phase 6 Security Governance |

Dokumen yang perlu dibuat sebagai tindak lanjut (Risk Treatment Plan, Internal Audit Checklist, AUP, BCP, dst.) terdaftar dalam `docs/security/iso27001-audit.md` § Roadmap Dokumen.

---

## 11. Persetujuan dan Pengesahan

Dengan menandatangani dokumen ini, Pimpinan menyatakan:

1. Telah membaca dan memahami isi Kebijakan Keamanan Informasi ini.
2. Menyetujui dan mengesahkan kebijakan ini sebagai acuan resmi keamanan informasi Fundara.
3. Berkomitmen menyediakan sumber daya yang diperlukan untuk pelaksanaan kebijakan ini.
4. Mengarahkan seluruh anggota tim dan pihak yang relevan untuk mematuhi kebijakan ini.

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
