# Perjanjian Kerahasiaan (Non-Disclosure Agreement)
## Template Fundara

**Nomor Dokumen:** ISP-004  
**Versi:** 1.0  
**Status:** Aktif  
**Berlaku Sejak:** (diisi setelah ditandatangani)  
**Terakhir Diperbarui:** 2026-06-20  
**Pemilik Dokumen:** Project Manager  
**Referensi:** ISP-001 § 5.5, UU PDP No. 27 Tahun 2022, KUHPerdata Pasal 1313–1320, UU ITE No. 11 Tahun 2008

---

## Panduan Penggunaan Template

Dokumen ini menyediakan dua template perjanjian kerahasiaan:

**Template A — Developer / Contributor / DevOps**  
Digunakan untuk setiap individu yang mendapatkan akses ke satu atau lebih dari berikut: source code Fundara, environment staging, environment production, credential sistem, atau data NGO. Ditandatangani sebelum akses diberikan.

**Template B — Klausul Staf NGO**  
Klausul singkat untuk diintegrasikan ke dalam surat perjanjian kerja atau kontrak engagement staf NGO yang akan menggunakan sistem Fundara. Tidak berdiri sendiri — menjadi bagian dari dokumen kontrak yang lebih besar.

PM menyimpan salinan NDA yang sudah ditandatangani di folder dokumentasi proyek (bukan di repository — berisi informasi pihak ketiga).

---

---

# TEMPLATE A
# PERJANJIAN KERAHASIAAN DAN KEAMANAN INFORMASI
## (Developer / Contributor / DevOps)

---

**PERJANJIAN KERAHASIAAN DAN KEAMANAN INFORMASI** ini ("Perjanjian") dibuat dan ditandatangani pada tanggal _____________________, oleh dan antara:

**PIHAK PERTAMA**

| | |
|---|---|
| Nama Organisasi | |
| Diwakili oleh | |
| Jabatan | Project Manager / Product Owner |
| Alamat | |

selanjutnya disebut **"Pihak Pertama"** atau **"Organisasi"**;

**PIHAK KEDUA**

| | |
|---|---|
| Nama Lengkap | |
| Nomor Identitas (KTP/Paspor) | |
| Alamat | |
| Peran dalam Proyek | ☐ Developer  ☐ DevOps / System Admin  ☐ QA Engineer  ☐ Konsultan / Domain Expert  ☐ Lainnya: ________ |

selanjutnya disebut **"Pihak Kedua"** atau **"Penerima"**;

Pihak Pertama dan Pihak Kedua secara bersama-sama disebut **"Para Pihak"**.

---

## Pasal 1 — Latar Belakang

1.1 Pihak Pertama sedang mengembangkan sistem perangkat lunak **Fundara** — platform ERP berbasis dana untuk organisasi nirlaba — yang dibangun di atas ERPNext v16 dan Frappe Framework ("Sistem").

1.2 Dalam rangka pelaksanaan pekerjaan sebagaimana disepakati dalam __________________ (nama kontrak/perjanjian kerja) tanggal __________________, Pihak Kedua akan diberikan akses ke Informasi Rahasia milik Pihak Pertama.

1.3 Sebagai syarat diberikannya akses tersebut, Para Pihak sepakat untuk mengikatkan diri dalam perjanjian ini.

---

## Pasal 2 — Definisi

**"Informasi Rahasia"** berarti seluruh informasi yang tidak tersedia untuk publik, yang diungkapkan oleh Pihak Pertama kepada Pihak Kedua dalam kaitannya dengan Sistem, termasuk namun tidak terbatas pada:

a. **Source code** Fundara, arsitektur sistem, desain DocType, skema database, algoritma, dan dokumentasi teknis non-publik;

b. **Data NGO** — data donor (termasuk nama, NIK, NPWP, jumlah donasi), data benefisiari (termasuk kondisi kesehatan, data anak, lokasi), data keuangan organisasi (Fund, General Ledger, Grant), dan data program operasional;

c. **Credential dan secret** — password database, API key, private key SSH, token autentikasi, passphrase enkripsi backup, dan konfigurasi server;

d. **Informasi environment** — alamat IP server production, konfigurasi infrastruktur, dan parameter deployment;

e. **Rencana bisnis dan roadmap** — estimasi biaya, prioritas fitur, dan strategi pengembangan produk yang belum dipublikasikan;

f. Seluruh informasi yang diterima Pihak Kedua dalam kapasitasnya sebagai anggota tim proyek, baik secara lisan, tertulis, elektronik, maupun dalam bentuk lainnya.

**"Lingkup Akses"** adalah sistem-sistem yang secara spesifik diberikan aksesnya kepada Pihak Kedua, sebagaimana ditandai di bawah:

| Sistem | Diberikan Akses |
|--------|-----------------|
| Source code repository (GitHub masmaksum/Fundara) | ☐ Ya  ☐ Tidak |
| Environment development (lokal / shared dev VM) | ☐ Ya  ☐ Tidak |
| Environment staging | ☐ Ya  ☐ Tidak |
| Environment production | ☐ Ya  ☐ Tidak |
| Database langsung (MariaDB) | ☐ Ya  ☐ Tidak |
| Credentials vault | ☐ Ya  ☐ Tidak |
| Data NGO (anonymized untuk testing) | ☐ Ya  ☐ Tidak |
| Data NGO (production — hanya dengan justifikasi khusus) | ☐ Ya  ☐ Tidak |

---

## Pasal 3 — Kewajiban Kerahasiaan

3.1 Pihak Kedua dengan ini berjanji dan mengikatkan diri untuk:

a. Menjaga kerahasiaan seluruh Informasi Rahasia dengan tingkat kehati-hatian yang tidak kurang dari yang digunakan untuk melindungi informasi rahasianya sendiri, dan dalam keadaan apapun tidak kurang dari standar kewajaran;

b. Menggunakan Informasi Rahasia **hanya untuk keperluan pelaksanaan pekerjaan** dalam proyek Fundara sesuai dengan Lingkup Akses yang diberikan;

c. Tidak mengungkapkan, mendistribusikan, mempublikasikan, atau mentransfer Informasi Rahasia kepada pihak mana pun tanpa persetujuan tertulis dari Pihak Pertama;

d. Tidak menggunakan Informasi Rahasia untuk kepentingan pribadi, kepentingan pihak ketiga, atau tujuan apa pun di luar pekerjaan yang ditugaskan;

e. Membatasi akses terhadap Informasi Rahasia hanya kepada individu yang secara langsung membutuhkannya untuk pelaksanaan pekerjaan ("*need-to-know basis*");

f. Segera melaporkan kepada Pihak Pertama jika Pihak Kedua mengetahui atau menduga adanya pengungkapan Informasi Rahasia yang tidak sah.

3.2 Pihak Kedua menyatakan telah membaca dan memahami isi `docs/security/security-requirements.md` (Security Requirements Fundara) dan berkomitmen untuk mematuhi seluruh ketentuan teknis yang berlaku, termasuk namun tidak terbatas pada SR-DEV-06 (tidak ada credential hardcoded di source code), SR-DEV-07 (pembatasan penggunaan `frappe.flags.ignore_permissions`), dan SR-AUTH-05 (pengelolaan API key).

---

## Pasal 4 — Larangan Khusus

Selain kewajiban umum dalam Pasal 3, Pihak Kedua secara khusus dilarang untuk:

a. Menyalin, mengunduh, atau menyimpan data NGO (termasuk data donor dan benefisiari) ke perangkat pribadi, layanan penyimpanan cloud pribadi, atau media penyimpanan eksternal mana pun, kecuali secara eksplisit diizinkan dan didokumentasikan oleh Pihak Pertama;

b. Mengakses sistem atau data di luar Lingkup Akses yang ditetapkan dalam Pasal 2, termasuk mengakses environment production tanpa otorisasi jika Lingkup Akses Pihak Kedua hanya mencakup staging;

c. Membuat salinan source code atau dokumentasi proyek yang melebihi kebutuhan teknis pekerjaan yang ditugaskan;

d. Menggunakan data NGO untuk melatih model kecerdasan buatan, melakukan analitik di luar kebutuhan proyek, atau kepentingan riset tanpa persetujuan tertulis;

e. Mengungkapkan keberadaan, identitas, atau data klien/NGO mana pun yang menggunakan sistem Fundara kepada pihak mana pun.

---

## Pasal 5 — Pengecualian

Kewajiban kerahasiaan dalam Perjanjian ini tidak berlaku terhadap informasi yang dapat dibuktikan oleh Pihak Kedua bahwa:

a. Informasi tersebut sudah tersedia untuk publik pada saat diterima oleh Pihak Kedua, bukan karena pelanggaran perjanjian ini;

b. Informasi tersebut telah diketahui secara sah oleh Pihak Kedua sebelum pengungkapan oleh Pihak Pertama, dibuktikan dengan catatan tertulis yang ada sebelum tanggal perjanjian ini;

c. Informasi tersebut diterima Pihak Kedua secara sah dari pihak ketiga yang tidak terikat kewajiban kerahasiaan terhadap Pihak Pertama; atau

d. Pengungkapan diwajibkan oleh ketentuan hukum, perintah pengadilan, atau perintah otoritas yang berwenang — dalam hal ini Pihak Kedua wajib segera memberitahukan Pihak Pertama secara tertulis sebelum pengungkapan dilakukan, selambat-lambatnya 2 (dua) hari kerja setelah menerima perintah tersebut, agar Pihak Pertama dapat mengambil langkah hukum yang diperlukan.

---

## Pasal 6 — Data Pribadi dan UU PDP

6.1 Pihak Kedua mengakui bahwa dalam pelaksanaan pekerjaan, ia mungkin memiliki akses terhadap data pribadi sebagaimana didefinisikan dalam **UU No. 27 Tahun 2022 tentang Pelindungan Data Pribadi** ("UU PDP"), termasuk data donor (NIK, NPWP, jumlah donasi) dan data benefisiari (nama, kondisi, lokasi).

6.2 Pihak Kedua berjanji untuk memproses data pribadi tersebut **hanya atas instruksi Pihak Pertama** dan hanya untuk keperluan yang secara langsung berkaitan dengan pelaksanaan pekerjaan dalam proyek Fundara, sesuai dengan ketentuan UU PDP Pasal 40 tentang kewajiban Pemroses Data Pribadi.

6.3 Pihak Kedua mengakui bahwa Pihak Pertama berperan sebagai Pengendali Data Pribadi yang wajib memastikan bahwa setiap pihak yang mengakses data pribadi terikat kewajiban kerahasiaan, sesuai dengan UU PDP Pasal 20.

6.4 Pihak Kedua wajib segera melaporkan kepada Pihak Pertama jika mengetahui atau menduga adanya insiden keamanan yang memengaruhi data pribadi yang ia kelola, dalam waktu **tidak lebih dari 4 jam** sejak mengetahuinya, agar Pihak Pertama dapat memenuhi kewajiban notifikasi kepada Kominfo/BSSN dalam 14 hari sebagaimana diatur dalam UU PDP.

---

## Pasal 7 — Pengembalian dan Penghapusan Informasi

7.1 Pada saat berakhirnya perjanjian kerja atau ketika diminta oleh Pihak Pertama, Pihak Kedua wajib:

a. Mengembalikan seluruh dokumen, media, dan materi yang mengandung Informasi Rahasia kepada Pihak Pertama;

b. Menghapus secara permanen seluruh salinan Informasi Rahasia yang tersimpan di perangkat pribadi, layanan cloud pribadi, atau media penyimpanan lainnya;

c. Memastikan bahwa akses ke seluruh sistem telah dicabut sesuai dengan prosedur dalam `docs/security/offboarding-checklist.md` (ISP-003).

7.2 Atas permintaan Pihak Pertama, Pihak Kedua wajib memberikan konfirmasi tertulis bahwa penghapusan tersebut telah dilakukan.

---

## Pasal 8 — Jangka Waktu

8.1 Perjanjian ini berlaku sejak tanggal penandatanganan dan berlanjut selama jangka waktu keterlibatan Pihak Kedua dalam proyek Fundara.

8.2 Kewajiban kerahasiaan dalam Perjanjian ini **tetap berlaku selama 5 (lima) tahun** setelah berakhirnya keterlibatan Pihak Kedua dalam proyek, terlepas dari alasan berakhirnya keterlibatan tersebut.

8.3 Kewajiban kerahasiaan terkait **data pribadi NGO** (donor, benefisiari, staf) berlaku **tanpa batas waktu**, selama data tersebut tidak secara sah telah menjadi informasi publik.

---

## Pasal 9 — Konsekuensi Pelanggaran

9.1 Pihak Kedua mengakui bahwa pelanggaran terhadap Perjanjian ini dapat menimbulkan kerugian yang tidak dapat dikompensasi secara memadai dengan ganti rugi uang, dan bahwa Pihak Pertama berhak mengambil upaya hukum yang tersedia termasuk injunksi dan ganti rugi sesuai **KUHPerdata Pasal 1365** (perbuatan melanggar hukum).

9.2 Pelanggaran terkait akses tidak sah ke sistem elektronik dapat dikenakan sanksi pidana sesuai **UU ITE No. 11 Tahun 2008 jo. UU No. 19 Tahun 2016**, termasuk Pasal 30 (akses tidak sah) dan Pasal 32 (pengubahan atau pengrusakan informasi elektronik).

9.3 Pelanggaran terkait penyalahgunaan data pribadi dapat dikenakan sanksi pidana sesuai **UU PDP No. 27 Tahun 2022**, termasuk Pasal 67 (pengungkapan data pribadi tanpa hak) dengan ancaman pidana penjara sampai dengan 4 tahun dan/atau denda sampai dengan Rp 4.000.000.000,00 (empat miliar rupiah).

9.4 Pihak Pertama berhak mengajukan klaim ganti rugi atas seluruh kerugian nyata, kerugian tidak langsung, dan biaya yang timbul akibat pelanggaran Perjanjian ini, termasuk biaya hukum yang dikeluarkan untuk menegakkan hak-hak Pihak Pertama.

---

## Pasal 10 — Hukum yang Berlaku dan Penyelesaian Sengketa

10.1 Perjanjian ini tunduk pada dan ditafsirkan sesuai dengan **hukum Negara Republik Indonesia**.

10.2 Segala sengketa yang timbul dari atau sehubungan dengan Perjanjian ini akan diselesaikan secara musyawarah mufakat antara Para Pihak dalam waktu 30 (tiga puluh) hari kalender sejak salah satu pihak mengajukan pemberitahuan tertulis.

10.3 Apabila musyawarah tidak menghasilkan penyelesaian, sengketa akan diselesaikan melalui **Pengadilan Negeri Jakarta** sebagai domisili hukum yang dipilih Para Pihak.

---

## Pasal 11 — Ketentuan Umum

11.1 Perjanjian ini merupakan keseluruhan kesepakatan Para Pihak mengenai kerahasiaan informasi dan menggantikan seluruh perjanjian atau pemahaman sebelumnya mengenai hal yang sama.

11.2 Perubahan terhadap Perjanjian ini hanya sah jika dibuat secara tertulis dan ditandatangani oleh kedua belah pihak.

11.3 Jika salah satu ketentuan dalam Perjanjian ini dinyatakan tidak sah atau tidak dapat dilaksanakan oleh pengadilan yang berwenang, ketentuan lainnya tetap berlaku penuh.

11.4 Kegagalan salah satu pihak untuk menegakkan suatu ketentuan dalam Perjanjian ini tidak dianggap sebagai pengabaian hak tersebut.

---

## Tanda Tangan

Dengan menandatangani di bawah ini, Para Pihak menyatakan telah membaca, memahami, dan menyetujui seluruh ketentuan dalam Perjanjian ini.

**Pihak Pertama:**

| | |
|---|---|
| Nama | |
| Jabatan | |
| Tanggal | |
| Tanda Tangan | |

**Pihak Kedua:**

| | |
|---|---|
| Nama | |
| Jabatan / Peran | |
| Tanggal | |
| Tanda Tangan | |

*Perjanjian ini dibuat dalam rangkap 2 (dua), masing-masing bermaterai cukup dan memiliki kekuatan hukum yang sama.*

---

---

# TEMPLATE B
# KLAUSUL KERAHASIAAN DAN KEAMANAN DATA
## (Untuk Diintegrasikan ke Kontrak Kerja / Surat Penugasan Staf NGO)

---

> **Petunjuk penggunaan:** Salin teks di bawah ini ke dalam surat perjanjian kerja atau kontrak engagement staf NGO, setelah ketentuan deskripsi pekerjaan. Sesuaikan `[NAMA NGO]` dengan nama organisasi. Klausul ini berlaku untuk semua staf yang mendapatkan akses ke sistem Fundara dalam peran apa pun.

---

**KLAUSUL KERAHASIAAN DAN KEAMANAN DATA**

Dalam melaksanakan tugasnya, Pihak Kedua (Tenaga Kerja/Konsultan) akan mendapatkan akses ke sistem informasi keuangan dan program **[NAMA NGO]** yang dikelola menggunakan platform Fundara. Sehubungan dengan akses tersebut, Pihak Kedua menyatakan dan berjanji sebagai berikut:

**1. Kewajiban Kerahasiaan.** Pihak Kedua wajib menjaga kerahasiaan seluruh informasi yang diperoleh dalam kapasitasnya sebagai staf/konsultan, termasuk namun tidak terbatas pada: data donor (identitas, jumlah donasi), data benefisiari (nama, kondisi, lokasi), data keuangan organisasi (anggaran, realisasi, Grant), data program, dan credential akses sistem. Kewajiban ini berlaku selama masa kerja dan **3 (tiga) tahun setelah berakhirnya hubungan kerja**.

**2. Penggunaan yang Diizinkan.** Pihak Kedua hanya boleh mengakses dan menggunakan informasi sistem **untuk keperluan pelaksanaan tugasnya** di [NAMA NGO]. Dilarang mengakses data yang tidak berkaitan dengan tanggung jawabnya.

**3. Larangan.** Pihak Kedua dilarang: (a) berbagi password akun dengan pihak lain; (b) menyimpan data donor atau benefisiari ke perangkat pribadi atau layanan cloud pribadi; (c) mengambil tangkapan layar atau mencetak laporan keuangan untuk kepentingan pribadi; (d) mengungkapkan data organisasi kepada pihak lain tanpa izin tertulis dari pimpinan organisasi.

**4. Keamanan Akun.** Pihak Kedua wajib: (a) menggunakan password yang kuat (minimum 12 karakter); (b) mengaktifkan autentikasi dua faktor (2FA) jika tersedia dan diperlukan; (c) mengunci perangkat saat meninggalkan tempat kerja; (d) segera melaporkan kepada IT/Sistem Admin jika menduga akun dikompromis.

**5. Dasar Hukum.** Pengelolaan data pribadi donor dan benefisiari tunduk pada **UU No. 27 Tahun 2022 tentang Pelindungan Data Pribadi**. Penyalahgunaan data pribadi dapat dikenakan sanksi pidana sesuai ketentuan UU PDP, termasuk ancaman pidana penjara dan denda.

**6. Pelaporan Insiden.** Pihak Kedua wajib segera melaporkan kepada Manajer/Koordinator apabila mengetahui atau menduga adanya insiden keamanan: akses tidak sah, kebocoran data, kehilangan perangkat yang berisi data organisasi, atau anomali sistem apa pun.

**7. Pengembalian Akses.** Pada saat berakhirnya hubungan kerja, seluruh akses ke sistem akan dicabut pada hari terakhir bekerja. Pihak Kedua wajib menghapus seluruh data organisasi yang mungkin tersimpan di perangkat pribadi.

Pihak Kedua menyatakan telah membaca, memahami, dan menyetujui klausul ini sebagai bagian tidak terpisahkan dari perjanjian kerja/penugasan ini.

**Nama:** _________________________  
**Tanda Tangan:** _________________________  
**Tanggal:** _________________________

---

*ISP-004 adalah bagian dari ISMS Fundara. Pertanyaan mengenai template ini dapat diajukan kepada Project Manager atau merujuk ke ISP-001 (Information Security Policy).*
