# Skrip UAT — Fundara

**Proyek:** Fundara — Fund-centric ERP untuk Organisasi Nirlaba  
**Versi:** 1.0  
**Tanggal:** 2026-06-19  
**Pemilik dokumen:** Project Manager  
**Ditujukan untuk:** PM Fasilitator + Staf NGO Penguji (bukan developer)

---

## Tujuan UAT Ini

UAT (User Acceptance Testing) dilakukan untuk memastikan bahwa Fundara benar-benar cocok dengan cara kerja sehari-hari staf NGO — bukan untuk mengecek apakah kode berfungsi secara teknis. Pertanyaan kuncinya adalah: *"Apakah sistem ini membantu pekerjaan kalian, atau malah menyulitkan?"*

---

## Bagian 1: Persiapan Sebelum Sesi

### Peserta yang Dibutuhkan

| Role di Sesi UAT | Siapa | Keterangan |
|---|---|---|
| **Fasilitator** | PM proyek atau QA lead | Membaca instruksi, mencatat, tidak membantu klik |
| **Pengamat** | Tech Lead | Mencatat bug dan confusion dari sudut teknis, tidak boleh membantu peserta |
| **Penguji 1** | Staf Program / Field Staff | Login sebagai Field Staff |
| **Penguji 2** | Manajer Program | Login sebagai Project Manager |
| **Penguji 3** | Staf Keuangan | Login sebagai Finance Officer |
| **Penguji 4** | Kepala Keuangan | Login sebagai Finance Manager |
| **Penguji 5** | Direktur Eksekutif | Login sebagai Executive Viewer |

### Durasi

- **Total:** 2–3 hari kerja
- **Per hari:** 3–4 jam sesi aktif (jangan lebih, peserta kelelahan dan data jadi tidak valid)
- **Hari 1:** Skenario 1–3 (Field Staff + Finance Officer)
- **Hari 2:** Skenario 4–6 (Finance Manager + Grant Manager + Direktur)
- **Hari 3 (opsional):** Skenario tambahan atau pengulangan jika ada temuan kritis

### Lingkungan

- Server staging sudah berjalan dan dapat diakses
- Demo data realistis sudah diload (nama NGO fiktif, dana program fiktif, transaksi contoh)
- Setiap peserta sudah punya akun dengan role yang sesuai
- Laptop peserta sudah bisa membuka URL staging di browser

### Checklist Fasilitator Sebelum Sesi Dimulai

- [ ] Test login dengan semua 5 akun peserta — pastikan berhasil
- [ ] Verifikasi demo data ada: ada minimal 1 dana program aktif, ada transaksi contoh
- [ ] Cetak formulir feedback (1 lembar per peserta per skenario)
- [ ] Cetak lembar pencatatan fasilitator
- [ ] Siapkan stopwatch / timer
- [ ] Siapkan bolpoin dan kertas untuk peserta coret-coret
- [ ] Pastikan ruangan cukup tenang — tidak ada interupsi dari rekan kerja peserta

---

## Bagian 2: Briefing untuk Peserta

Teks berikut dibacakan fasilitator di awal setiap sesi, sebelum peserta menyentuh laptop:

> "Selamat datang di sesi uji coba Fundara. Terima kasih sudah meluangkan waktu.
>
> Hari ini kita akan mencoba sistem bersama-sama. Tujuannya bukan untuk mencari siapa yang salah, bukan untuk menguji kemampuan kalian pakai komputer, tapi untuk memastikan sistem ini benar-benar cocok dengan cara kerja kalian sehari-hari.
>
> Tidak ada jawaban yang salah. Kalau ada sesuatu yang membingungkan, tolong katakan dengan keras — itu justru yang paling berguna bagi kami. Kalau kalian tidak tahu harus klik apa, itu bukan salah kalian. Itu artinya sistem perlu diperbaiki, dan masukan kalian yang membantu kami memperbaikinya.
>
> Cara saya memfasilitasi: saya akan membacakan instruksi, tapi saya tidak akan membantu klik-klik atau menunjuk ke mana harus pergi. [Pengamat] juga hadir dan akan mencatat dari sudut yang berbeda, tapi juga tidak akan membantu.
>
> Satu hal penting: coba ceritakan apa yang ada di pikiran kalian saat mengerjakan tugas — 'saya cari menu ini', 'saya bingung tombol ini maksudnya apa', 'saya kira harusnya ada di sini'. Itu sangat membantu.
>
> Ada pertanyaan sebelum kita mulai?"

---

## Bagian 3: Skenario UAT

### Skenario 1: Field Staff Mengajukan Uang Muka (Cash Advance)

**Peserta:** Staf Program / Field Staff  
**Durasi estimasi:** 15–25 menit  
**Skenario ini menguji:** Kemudahan mengajukan uang muka dari sudut pandang staf lapangan

---

**Konteks yang dibacakan fasilitator:**

> "Anda adalah Aditya, staf program di organisasi ini. Minggu depan Anda akan melakukan kunjungan lapangan ke 3 desa di Kabupaten Ngawi selama 3 hari untuk kegiatan penyuluhan kesehatan. Anda membutuhkan uang muka untuk biaya perjalanan, penginapan, dan makan.
>
> Dana yang akan digunakan adalah dana program 'Kesehatan Komunitas 2025' dan Anda membutuhkan Rp 2.500.000."

**Tugas yang dibacakan fasilitator (kata per kata):**

> "Silakan ajukan permintaan uang muka sebesar Rp 2.500.000 dari dana program 'Kesehatan Komunitas 2025' untuk kunjungan lapangan Anda minggu depan. Tujuan penggunaan: kunjungan lapangan ke Kabupaten Ngawi, 3 hari. Silakan mulai."

**Fasilitator mencatat (jangan diucapkan ke peserta):**
- Di mana peserta pertama kali mengklik?
- Berapa lama sampai menemukan menu Cash Advance?
- Apakah peserta membaca atau langsung klik?
- Apakah ada field yang membingungkan?
- Apa yang dikatakan peserta saat mengisi form?

**Checklist keberhasilan (diisi fasilitator):**

| # | Kriteria | Status |
|---|---|---|
| 1 | Peserta menemukan menu pengajuan uang muka tanpa petunjuk verbal | ☐ Ya / ☐ Tidak |
| 2 | Peserta berhasil memilih dana yang benar ('Kesehatan Komunitas 2025') | ☐ Ya / ☐ Tidak |
| 3 | Peserta mengisi jumlah, tanggal, dan tujuan dengan benar | ☐ Ya / ☐ Tidak |
| 4 | Peserta berhasil submit tanpa error | ☐ Ya / ☐ Tidak |
| 5 | Status berubah menjadi "Pending Approval" atau setara | ☐ Ya / ☐ Tidak |
| 6 | Peserta tahu cara mengecek status pengajuannya | ☐ Ya / ☐ Tidak |

**Pertanyaan refleksi (tanyakan setelah tugas selesai atau gagal):**

1. "Seberapa mudah tadi menemukan menu pengajuan uang muka? Skala 1–5."
2. "Ada informasi yang menurut Anda seharusnya ada di form tapi tidak ada tadi?"
3. "Setelah submit, apa yang Anda bayangkan terjadi selanjutnya?"
4. "Kalau dibandingkan dengan cara Anda mengajukan uang muka sekarang, mana yang lebih mudah?"

---

### Skenario 2: Finance Officer Memproses dan Menyetujui Uang Muka

**Peserta:** Staf Keuangan / Finance Officer  
**Durasi estimasi:** 20–30 menit  
**Skenario ini menguji:** Alur kerja persetujuan dan pencatatan pembayaran dari sisi keuangan

---

**Konteks yang dibacakan fasilitator:**

> "Anda adalah Sari, staf keuangan. Hari ini ada beberapa pengajuan uang muka yang perlu Anda proses. Salah satunya dari Aditya untuk kunjungan lapangan (Rp 2.500.000) dan satu lagi dari Budi untuk kegiatan pelatihan (Rp 1.800.000). Keduanya menunggu persetujuan Anda."

**Tugas yang dibacakan fasilitator:**

> "Silakan cek pengajuan uang muka yang sedang menunggu persetujuan. Tinjau detailnya, setujui yang menurut Anda layak, lalu catat bahwa uang sudah dibayarkan kepada pengaju."

**Checklist keberhasilan:**

| # | Kriteria | Status |
|---|---|---|
| 1 | Peserta menemukan daftar pengajuan yang menunggu persetujuan | ☐ Ya / ☐ Tidak |
| 2 | Peserta bisa melihat detail pengajuan sebelum menyetujui | ☐ Ya / ☐ Tidak |
| 3 | Peserta bisa melihat saldo dana sebelum menyetujui | ☐ Ya / ☐ Tidak |
| 4 | Peserta berhasil menyetujui pengajuan | ☐ Ya / ☐ Tidak |
| 5 | Peserta berhasil mencatat bahwa uang sudah dibayarkan (status → Paid) | ☐ Ya / ☐ Tidak |
| 6 | Peserta memahami bahwa saldo dana baru berkurang setelah pembayaran, bukan setelah persetujuan | ☐ Ya / ☐ Tidak |

**Pertanyaan refleksi:**

1. "Informasi apa yang paling penting Anda lihat sebelum menyetujui pengajuan tadi?"
2. "Apakah jelas dari mana melihat saldo dana yang tersedia sebelum menyetujui?"
3. "Apa yang akan Anda lakukan jika dana tidak mencukupi?"
4. "Seberapa yakin Anda bahwa tindakan yang baru dilakukan sudah benar? Skala 1–5."

---

### Skenario 3: Field Staff Membuat Laporan Pertanggungjawaban (Likuidasi)

**Peserta:** Staf Program / Field Staff  
**Durasi estimasi:** 20–30 menit  
**Skenario ini menguji:** Kemudahan pelaporan penggunaan uang muka dan konsep sisa pengembalian

---

**Konteks yang dibacakan fasilitator:**

> "Anda adalah Aditya yang baru saja kembali dari kunjungan lapangan 3 hari di Kabupaten Ngawi. Anda menerima uang muka Rp 2.500.000 sebelum berangkat. Sekarang Anda perlu melaporkan penggunaan uang tersebut dan mengembalikan sisa yang tidak terpakai."

**Tugas yang dibacakan fasilitator:**

> "Anda membawa kwitansi-kwitansi berikut dari lapangan:
> - Sewa motor: Rp 450.000
> - Bensin: Rp 180.000
> - Makan 3 hari: Rp 270.000
> - Penginapan 2 malam: Rp 700.000
> - Transport lokal ke desa: Rp 700.000
>
> Total pengeluaran: Rp 2.300.000. Ada sisa Rp 200.000 yang harus dikembalikan.
>
> Silakan laporkan penggunaan uang muka ini di sistem."

**Checklist keberhasilan:**

| # | Kriteria | Status |
|---|---|---|
| 1 | Peserta menemukan pengajuan uang muka yang sebelumnya | ☐ Ya / ☐ Tidak |
| 2 | Peserta menemukan cara untuk mengisi laporan pertanggungjawaban | ☐ Ya / ☐ Tidak |
| 3 | Peserta bisa mengisi rincian pengeluaran (per item) | ☐ Ya / ☐ Tidak |
| 4 | Peserta memahami bahwa ada sisa Rp 200.000 yang perlu dikembalikan | ☐ Ya / ☐ Tidak |
| 5 | Peserta berhasil submit laporan | ☐ Ya / ☐ Tidak |
| 6 | Status uang muka berubah menunjukkan laporan sudah dikirim | ☐ Ya / ☐ Tidak |

**Pertanyaan refleksi:**

1. "Bagaimana cara Anda tahu bahwa laporan sudah berhasil terkirim?"
2. "Apakah jelas apa yang harus dilakukan dengan sisa uang Rp 200.000?"
3. "Kalau Anda tidak punya akses komputer setelah pulang dari lapangan, bagaimana cara terbaik melaporkan ini?"
4. "Ada yang kurang di form pelaporan tadi? Informasi apa yang biasanya Anda catat tapi tidak ada di sini?"

---

### Skenario 4: Finance Officer Menyetujui Laporan Pertanggungjawaban

**Peserta:** Staf Keuangan / Finance Officer  
**Durasi estimasi:** 15–20 menit  
**Skenario ini menguji:** Verifikasi laporan pertanggungjawaban dan penanganan sisa pengembalian

---

**Konteks yang dibacakan fasilitator:**

> "Anda adalah Sari, staf keuangan. Aditya sudah mengirimkan laporan pertanggungjawaban uang mukanya. Laporan menunjukkan pengeluaran Rp 2.300.000 dari uang muka Rp 2.500.000, dengan sisa Rp 200.000 yang akan dikembalikan."

**Tugas yang dibacakan fasilitator:**

> "Silakan cek laporan pertanggungjawaban dari Aditya, verifikasi kewajaran pengeluarannya, dan proses penyelesaiannya. Pastikan saldo dana sudah terperbaharui setelah Anda selesai."

**Checklist keberhasilan:**

| # | Kriteria | Status |
|---|---|---|
| 1 | Peserta menemukan laporan pertanggungjawaban yang menunggu review | ☐ Ya / ☐ Tidak |
| 2 | Peserta bisa melihat rincian pengeluaran per item | ☐ Ya / ☐ Tidak |
| 3 | Peserta berhasil menyetujui laporan | ☐ Ya / ☐ Tidak |
| 4 | Peserta memahami cara mencatat penerimaan sisa uang kembali (Rp 200.000) | ☐ Ya / ☐ Tidak |
| 5 | Status uang muka berubah ke "Closed" atau setara setelah selesai | ☐ Ya / ☐ Tidak |
| 6 | Saldo dana yang berkurang mencerminkan pengeluaran aktual (Rp 2.300.000), bukan jumlah uang muka (Rp 2.500.000) | ☐ Ya / ☐ Tidak |

**Pertanyaan refleksi:**

1. "Apakah Anda tahu dengan jelas apa yang harus dilakukan setelah menyetujui laporan ini?"
2. "Bagaimana cara memastikan bahwa sisa uang sudah benar-benar diterima kembali?"
3. "Apakah ada informasi yang biasanya Anda butuhkan saat mengverifikasi laporan tapi tidak tersedia di sini?"

---

### Skenario 5: Finance Manager Melihat Posisi Keuangan untuk Rapat

**Peserta:** Kepala Keuangan / Finance Manager  
**Durasi estimasi:** 20–25 menit  
**Skenario ini menguji:** Kemudahan mendapatkan gambaran posisi keuangan untuk kebutuhan manajerial

---

**Konteks yang dibacakan fasilitator:**

> "Anda adalah Bu Rini, Kepala Keuangan. Besok pagi ada rapat koordinasi mingguan dan Anda perlu menyiapkan ringkasan posisi keuangan untuk dilaporkan ke Direktur dan tim program."

**Tugas yang dibacakan fasilitator:**

> "Sebelum rapat besok, Anda perlu mengetahui tiga hal:
> 1. Berapa saldo yang tersedia di masing-masing dana program?
> 2. Siapa saja staf yang masih punya uang muka belum dilunasi?
> 3. Apakah ada dana yang penggunaannya sudah mendekati batas anggaran?
>
> Silakan cari informasi ini di sistem."

**Checklist keberhasilan:**

| # | Kriteria | Status |
|---|---|---|
| 1 | Peserta menemukan halaman atau laporan untuk melihat saldo per dana | ☐ Ya / ☐ Tidak |
| 2 | Peserta bisa melihat saldo tersedia di setiap dana (bukan hanya saldo total) | ☐ Ya / ☐ Tidak |
| 3 | Peserta menemukan daftar uang muka yang masih outstanding | ☐ Ya / ☐ Tidak |
| 4 | Peserta bisa mengidentifikasi dana yang mendekati batas anggaran | ☐ Ya / ☐ Tidak |
| 5 | Informasi yang ditemukan cukup untuk dibawa ke rapat tanpa harus keluar dari sistem | ☐ Ya / ☐ Tidak |

**Pertanyaan refleksi:**

1. "Informasi ini cukup untuk rapat besok, atau masih ada yang perlu Anda cari di tempat lain?"
2. "Seberapa mudah menemukan semua informasi tadi? Skala 1–5."
3. "Biasanya Anda mempersiapkan informasi ini dari mana? Berapa lama?"
4. "Ada laporan atau ringkasan yang Anda butuhkan tapi tidak Anda temukan tadi?"

---

### Skenario 6: Grant Manager Menyiapkan Laporan Donor

**Peserta:** Grant Manager / Kepala Keuangan (tergantung struktur NGO)  
**Durasi estimasi:** 20–25 menit  
**Skenario ini menguji:** Pembuatan laporan penggunaan dana untuk kebutuhan pelaporan ke donor

---

**Konteks yang dibacakan fasilitator:**

> "Anda adalah Pak Dimas, Grant Manager. Donor USAID meminta laporan penggunaan dana triwulan pertama (Januari–Maret 2025) untuk program 'USAID Health 2025'. Dana ini dalam mata uang USD dan USAID minta laporan dalam USD juga."

**Tugas yang dibacakan fasilitator:**

> "Buatkan laporan penggunaan dana 'USAID Health 2025' untuk periode Januari–Maret 2025, dalam mata uang USD. USAID ingin melihat berapa yang sudah digunakan per kategori anggaran dan berapa yang masih tersisa. Silakan cari cara membuat laporan ini di sistem."

**Checklist keberhasilan:**

| # | Kriteria | Status |
|---|---|---|
| 1 | Peserta menemukan menu atau fitur laporan donor | ☐ Ya / ☐ Tidak |
| 2 | Peserta bisa memfilter laporan per dana (USAID Health 2025) dan per periode | ☐ Ya / ☐ Tidak |
| 3 | Laporan menampilkan angka dalam USD (bukan IDR) | ☐ Ya / ☐ Tidak |
| 4 | Laporan menampilkan rincian per kategori anggaran | ☐ Ya / ☐ Tidak |
| 5 | Peserta bisa mengeksport atau mencetak laporan | ☐ Ya / ☐ Tidak |

**Pertanyaan refleksi:**

1. "Apakah format laporan ini sesuai dengan yang biasanya diminta oleh donor?"
2. "Ada informasi yang biasanya Anda tambahkan manual ke laporan donor tapi tidak ada di sini?"
3. "Seberapa mudah membuat laporan ini untuk donor lain atau periode yang berbeda?"

---

### Skenario 7: Executive Director Melihat Gambaran Organisasi

**Peserta:** Direktur Eksekutif  
**Durasi estimasi:** 10–15 menit  
**Skenario ini menguji:** Kemudahan membaca gambaran besar tanpa perlu masuk ke detail transaksi

---

**Konteks yang dibacakan fasilitator:**

> "Anda adalah Direktur Eksekutif organisasi ini. Anda baru saja selesai meeting eksternal dan punya 10 menit sebelum meeting berikutnya. Anda ingin tahu kondisi organisasi secara cepat — tidak perlu detail, cukup gambaran besar untuk memastikan tidak ada hal mendesak yang perlu perhatian Anda."

**Tugas yang dibacakan fasilitator:**

> "Masuk ke sistem dan cari tahu: bagaimana kondisi keuangan organisasi saat ini? Dana mana yang paling aktif? Adakah sesuatu yang memerlukan perhatian atau keputusan Anda?"

**Checklist keberhasilan:**

| # | Kriteria | Status |
|---|---|---|
| 1 | Dashboard atau halaman ringkasan terbuka saat login atau mudah ditemukan | ☐ Ya / ☐ Tidak |
| 2 | Peserta mendapat gambaran kondisi organisasi dalam kurang dari 3 menit | ☐ Ya / ☐ Tidak |
| 3 | Informasi tersedia tanpa perlu mengklik banyak menu | ☐ Ya / ☐ Tidak |
| 4 | Alert atau peringatan (jika ada) terlihat jelas dan mudah dipahami | ☐ Ya / ☐ Tidak |
| 5 | Peserta bisa menjawab: "ada atau tidak ada sesuatu yang perlu perhatian saya?" | ☐ Ya / ☐ Tidak |

**Pertanyaan refleksi:**

1. "Apakah informasi yang tersedia cukup untuk membuat keputusan cepat?"
2. "Apa yang Anda harapkan ada di halaman pertama saat masuk, yang tadi tidak ada?"
3. "Seberapa sering Anda biasanya ingin melihat ringkasan seperti ini? Setiap hari? Mingguan?"

---

## Bagian 4: Formulir Feedback Peserta

*Cetak dan berikan ke setiap peserta setelah setiap skenario selesai. Peserta mengisi sendiri.*

---

```
╔══════════════════════════════════════════════════════════════╗
║               FORMULIR FEEDBACK UAT FUNDARA                  ║
╠══════════════════════════════════════════════════════════════╣
║ Skenario: _______________________________________________      ║
║ Nama peserta: __________________________________________      ║
║ Jabatan / Role: ________________________________________      ║
║ Tanggal: _______________________________________________      ║
╠══════════════════════════════════════════════════════════════╣
║                                                              ║
║  1. Seberapa mudah menyelesaikan tugas tadi?                 ║
║     (lingkari satu angka)                                    ║
║                                                              ║
║     1        2        3        4        5                    ║
║  Sangat                               Sangat                 ║
║   Sulit                               Mudah                  ║
║                                                              ║
╠══════════════════════════════════════════════════════════════╣
║                                                              ║
║  2. Apa yang paling membingungkan tadi?                      ║
║                                                              ║
║  ____________________________________________________________ ║
║  ____________________________________________________________ ║
║  ____________________________________________________________ ║
║                                                              ║
╠══════════════════════════════════════════════════════════════╣
║                                                              ║
║  3. Apa yang sudah berjalan baik dan memudahkan Anda?        ║
║                                                              ║
║  ____________________________________________________________ ║
║  ____________________________________________________________ ║
║  ____________________________________________________________ ║
║                                                              ║
╠══════════════════════════════════════════════════════════════╣
║                                                              ║
║  4. Saran perbaikan (kalau ada):                             ║
║                                                              ║
║  ____________________________________________________________ ║
║  ____________________________________________________________ ║
║  ____________________________________________________________ ║
║                                                              ║
╠══════════════════════════════════════════════════════════════╣
║                                                              ║
║  5. Apakah sistem ini lebih mudah dari cara Anda             ║
║     bekerja sekarang?                                        ║
║                                                              ║
║     ☐ Ya, lebih mudah                                        ║
║     ☐ Kurang lebih sama                                      ║
║     ☐ Lebih sulit                                            ║
║     ☐ Terlalu berbeda, belum bisa dibandingkan               ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
```

---

## Bagian 5: Lembar Pencatatan Fasilitator

*Satu lembar per peserta per skenario. Diisi fasilitator selama peserta mengerjakan tugas.*

```
Skenario: ___________________  Peserta: _____________________
Role: _______________________  Tanggal/Jam: _________________

WAKTU
Start: _______  Selesai: _______  Total: _______
[ ] Selesai tanpa bantuan  [ ] Selesai dengan satu petunjuk
[ ] Selesai dengan banyak bantuan  [ ] Tidak selesai

OBSERVASI (catat secara urut — apa yang terjadi, bukan interpretasi)
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________

TITIK CONFUSION (di mana peserta berhenti atau kelihatan bingung)
_________________________________________________________________
_________________________________________________________________

KUTIPAN PESERTA (kata-kata persis yang diucapkan — ini paling berharga)
"_________________________________________________________________"
"_________________________________________________________________"
"_________________________________________________________________"

FITUR YANG TIDAK DITEMUKAN
_________________________________________________________________

BUG ATAU ERROR YANG MUNCUL
_________________________________________________________________

CATATAN TAMBAHAN
_________________________________________________________________
```

---

## Bagian 6: Kriteria UAT Pass / Fail

### UAT Dinyatakan PASS (lanjut ke release)

Semua kondisi berikut harus terpenuhi:

- **90% skenario** berhasil diselesaikan peserta tanpa bantuan verbal dari fasilitator
- **0 skenario Critical Fail** — tidak ada alur utama yang tidak bisa diselesaikan sama sekali oleh lebih dari satu peserta
- **Skor rata-rata kemudahan ≥ 3,5** dari skala 5 (dihitung dari semua formulir feedback)
- **Tidak ada bug blocking** yang ditemukan selama sesi (sistem error, halaman tidak bisa dibuka, data hilang)

### UAT Dinyatakan FAIL (perlu perbaikan sebelum release)

Salah satu kondisi berikut sudah cukup untuk FAIL:

| Kondisi | Tindakan |
|---|---|
| Ada skenario yang tidak bisa diselesaikan sama sekali oleh 2+ peserta | Hold release, fix Critical, retest skenario terkait |
| Rata-rata kemudahan < 3,0 | Hold release, evaluasi UX dengan Tech Lead dan domain expert |
| 3+ peserta melaporkan confusion di titik yang sama | Fix titik tersebut, retest dengan minimal 2 peserta baru |
| Bug Critical ditemukan selama sesi | Stop sesi, fix bug, jadwalkan ulang |

### Definisi Severity Temuan UAT

| Level | Definisi | Contoh |
|---|---|---|
| **Critical** | Alur tidak bisa diselesaikan sama sekali | Tombol submit tidak berfungsi, form tidak bisa dibuka |
| **High** | Alur bisa diselesaikan tapi dengan kesulitan signifikan yang akan terjadi di produksi | Field mandatory tidak jelas, error message tidak informatif |
| **Medium** | Fungsi berjalan tapi ada kebingungan atau langkah yang tidak efisien | Label menu membingungkan, urutan form kurang logis |
| **Low** | Isu kecil, tidak menghambat alur | Typo, warna tombol, saran kosmetik |

---

## Bagian 7: Proses Setelah Sesi UAT

### Timeline Pasca-UAT

| Waktu | Kegiatan | PIC |
|---|---|---|
| Hari H (sore, setelah sesi) | Kumpulkan semua formulir feedback dan catatan fasilitator | PM |
| Hari H+1 (pagi) | PM + Tech Lead mengkategorikan temuan per severity | PM + TL |
| Hari H+1 (siang) | Entry semua temuan ke issue tracker (minimal Critical dan High) | QA |
| Hari H+2 | Presentasi temuan ke stakeholder (PO + domain expert) | PM |
| Hari H+2 | Keputusan: release / hold / fix-then-retest | PO (keputusan final) |

### Format Presentasi Temuan ke Stakeholder

Struktur singkat untuk presentasi hasil UAT (maksimal 15 menit):

1. **Ringkasan angka:** Berapa skenario pass, berapa fail, skor rata-rata kemudahan
2. **3 temuan terpenting:** Critical dan High severity — deskripsi, contoh, dampak
3. **3 hal yang berjalan baik:** Apa yang dipuji peserta — penting untuk moral tim
4. **Rekomendasi:** Pass / Hold / Fix-then-retest — dengan alasan singkat
5. **Jika Hold:** Daftar item yang harus diselesaikan sebelum release, estimasi waktu

### Dokumentasi Hasil

Simpan di `docs/qa/uat-results-sprint-[N].md` (dibuat setelah setiap sesi UAT):
- Tanggal sesi, peserta, environment
- Ringkasan per skenario (Pass/Fail/Partial)
- Semua temuan termasuk bukti (screenshot jika ada)
- Keputusan akhir dan justifikasinya

---

*Dokumen ini diperbarui setiap kali ada perubahan skenario bisnis atau penambahan fitur baru yang memerlukan pengujian oleh end-user. Perubahan mayor harus disetujui oleh PM dan PO.*
