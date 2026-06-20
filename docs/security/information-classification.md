# Kebijakan Klasifikasi Informasi

**Nomor Dokumen:** ISP-005  
**Versi:** 1.0  
**Status:** Aktif  
**Berlaku Sejak:** (diisi setelah ditandatangani)  
**Terakhir Diperbarui:** 2026-06-20  
**Pemilik Dokumen:** Tech Lead  
**Referensi:** ISP-001 § 5.3, ISO/IEC 27001:2022 A.5.12–A.5.13, UU PDP No. 27 Tahun 2022

---

## 1. Tujuan dan Lingkup

Dokumen ini menetapkan skema klasifikasi informasi yang seragam untuk seluruh aset informasi dalam lingkup ISMS Fundara — mencakup data aplikasi, dokumentasi proyek, kode sumber, dan credential sistem.

Tanpa klasifikasi yang konsisten, penanganan data sensitif (NIK/NPWP donor, data kesehatan benefisiari, credential production) bergantung pada penilaian individu masing-masing anggota tim, yang menghasilkan perlindungan yang tidak merata. Kebijakan ini menghilangkan ambiguitas tersebut.

**Berlaku untuk:** seluruh anggota tim (Developer, DevOps, QA, PM, Domain Expert) dan seluruh aset informasi dalam Lingkup ISMS sebagaimana didefinisikan di ISP-002.

---

## 2. Tingkat Klasifikasi

Fundara menggunakan **4 tingkat klasifikasi**, diurutkan dari paling terbatas ke paling terbuka:

| Label | Kode | Deskripsi Singkat |
|-------|------|-------------------|
| **Terbatas** | L4 | Informasi paling sensitif — bocor = dampak hukum dan reputasi besar |
| **Rahasia** | L3 | Informasi sensitif operasional — akses berdasarkan kebutuhan tugas |
| **Internal** | L2 | Informasi untuk penggunaan tim proyek — tidak untuk publik |
| **Publik** | L1 | Informasi yang boleh dibagikan secara bebas |

### 2.1 L4 — Terbatas (Restricted)

**Definisi:** Informasi yang jika bocor dapat menimbulkan dampak hukum serius, kerugian finansial signifikan bagi NGO atau individu, atau membahayakan keselamatan fisik benefisiari.

**Kriteria klasifikasi:**
- Mengandung data identitas pribadi yang sangat sensitif (NIK, NPWP, nomor paspor)
- Mengandung data kesehatan, kondisi sosial, atau data anak yang dilindungi hukum
- Memberikan akses langsung ke sistem production (credential, private key, passphrase)
- Jika terungkap dapat melanggar UU PDP Pasal 67 (ancaman pidana)

**Contoh data Fundara:**

| Data | DocType / Lokasi |
|------|-----------------|
| NIK dan NPWP donor individu | DocType: Donor (field `nik`, `npwp`) |
| Data kesehatan benefisiari | DocType: Beneficiary (field kondisi kesehatan) |
| Identitas anak benefisiari | DocType: Beneficiary (program anak) |
| Database password MariaDB | `site_config.json`, environment variables |
| Private key SSH server | `~/.ssh/id_*` di workstation / server |
| GPG passphrase enkripsi backup | Credentials vault |
| API key backup offsite (write) | Environment variables server |
| Frappe admin password production | Credentials vault |
| Nomor rekening bank staf | DocType: Staff Profile (salary fields) |

**Label pada dokumen:** `[TERBATAS]` di header dan footer setiap halaman.

---

### 2.2 L3 — Rahasia (Confidential)

**Definisi:** Informasi operasional sensitif yang penyebarannya di luar tim yang berwenang dapat merugikan kepercayaan pemangku kepentingan, mengganggu operasional, atau membuka celah keamanan.

**Kriteria klasifikasi:**
- Data keuangan NGO yang belum dipublikasikan (saldo fund, laporan internal)
- Data donor yang tidak termasuk L4 (nama, email, nomor telepon, jumlah donasi)
- Data grant dan hubungan donor yang bersifat strategis
- Credential dengan privilege terbatas (API key monitoring, staging credentials)
- Kode sumber dan arsitektur sistem (sebelum dirilis publik)
- Laporan insiden keamanan dan hasil audit internal

**Contoh data Fundara:**

| Data | DocType / Lokasi |
|------|-----------------|
| Nama, email, telepon donor | DocType: Donor |
| Jumlah donasi individual | DocType: Donation |
| Saldo dan mutasi Fund | DocType: Fund, GL Entry |
| Detail Grant (jumlah, syarat, jadwal) | DocType: Grant, Grant Agreement |
| Cash Advance dan Advance Liquidation | DocType: Cash Advance, Advance Liquidation |
| Laporan penggunaan dana (donor report) | DocType: Fund Utilization Report, Donor Report |
| Kode sumber Fundara (custom app) | GitHub masmaksum/Fundara |
| Seluruh dokumentasi `docs/security/` | Repository Fundara |
| Credential staging (Frappe, SSH) | Credentials vault |
| API key monitoring (Netdata, Uptime Kuma) | Environment variables staging |
| Backup database (terenkripsi) | Disk lokal + offsite storage |
| Laporan insiden keamanan | `docs/security/incident-response.md` + laporan aktual |

**Label pada dokumen:** `[RAHASIA]` di header dokumen.

---

### 2.3 L2 — Internal

**Definisi:** Informasi yang dimaksudkan untuk penggunaan internal tim proyek. Tidak mengandung data sensitif, namun tidak seharusnya beredar di luar tim tanpa pertimbangan.

**Kriteria klasifikasi:**
- Dokumentasi teknis dan spesifikasi proyek
- Estimasi biaya, jadwal, dan keputusan arsitektur
- Prosedur operasional yang tidak mengandung credential
- Komunikasi internal tim (meeting notes, rencana sprint)

**Contoh data Fundara:**

| Data | Lokasi |
|------|--------|
| Spesifikasi DocType (`docs/spec/`) | Repository Fundara |
| Estimasi kompleksitas (`docs/pm/complexity.md`) | Repository Fundara |
| RACI dan risk register (`docs/pm/`) | Repository Fundara |
| Panduan developer (`docs/dev/`) | Repository Fundara |
| Dokumen QA (`docs/qa/`) | Repository Fundara |
| DECISIONS.md, READINESS.md | Repository Fundara |
| Demo data fiktif YPN Harapan Bangsa | Repository Fundara |
| Environment spec (`docs/infra/environment-spec.md`) | Repository Fundara |
| Log komunikasi internal tim (chat, email) | Saluran komunikasi internal |
| Catatan retrospektif dan meeting notes | Saluran komunikasi internal |

**Label pada dokumen:** Cukup header dokumen standar tanpa label khusus, atau cantumkan `[INTERNAL]` jika dokumen berpotensi disalah-artikan sebagai publik.

---

### 2.4 L1 — Publik (Public)

**Definisi:** Informasi yang secara aktif atau pasif telah tersedia untuk umum, atau yang dapat dibagikan tanpa risiko terhadap keamanan, privasi, atau kepercayaan pemangku kepentingan.

**Kriteria klasifikasi:**
- Sudah dipublikasikan secara resmi oleh Pihak Pertama
- Tidak mengandung data individu, credential, atau informasi strategis

**Contoh data Fundara:**

| Data | Lokasi |
|------|--------|
| README.md (deskripsi umum Fundara) | GitHub (publik) |
| Lisensi software (LICENSE) | GitHub (publik) |
| Laporan tahunan NGO yang sudah dipublikasikan | Website NGO |
| Siaran pers / press release | Website NGO |
| Informasi program (tanpa data benefisiari) | Website / media sosial NGO |

**Label pada dokumen:** Tidak perlu label — absensi label berarti Publik, atau cantumkan `[PUBLIK]` untuk kejelasan.

---

## 3. Pemetaan dari Skema Lama ke Skema Ini

Dokumen Fundara yang ada menggunakan terminologi sensitivitas yang berbeda-beda. Tabel berikut memetakan terminologi lama ke skema resmi L1–L4.

| Terminologi Lama | Dokumen Sumber | Klasifikasi Baru |
|-----------------|----------------|-----------------|
| Kritis | `threat-model.md` (aset: credential sistem) | **L4 — Terbatas** |
| Sangat Tinggi | `threat-model.md` (benefisiari, keuangan, backup) | **L4 — Terbatas** untuk identitas/kesehatan; **L3 — Rahasia** untuk keuangan |
| Tinggi | `threat-model.md`, `data-privacy.md` | **L3 — Rahasia** |
| Sedang | `data-privacy.md` | **L2 — Internal** |
| Rendah | implisit di berbagai dokumen | **L1 — Publik** |

**Catatan penting:** Backup database diklasifikasikan **L4** (bukan L3) meskipun terenkripsi, karena berisi seluruh data production termasuk komponen L4. Enkripsi adalah kontrol perlindungan, bukan dasar penurunan klasifikasi.

---

## 4. Aturan Penanganan per Tingkat

### 4.1 Penyimpanan (Storage)

| Aspek | L4 — Terbatas | L3 — Rahasia | L2 — Internal | L1 — Publik |
|-------|--------------|-------------|--------------|------------|
| Enkripsi at-rest | **Wajib** (AES-256 minimum) | **Wajib** untuk data di server; dianjurkan di workstation | Dianjurkan | Tidak diperlukan |
| Lokasi yang diizinkan | Credentials vault + server terenkripsi + backup terenkripsi | Server Fundara + credentials vault | Repository proyek + tools kolaborasi internal | Tidak dibatasi |
| Cloud storage pribadi | **Dilarang keras** | **Dilarang** | Diperbolehkan dengan enkripsi | Diperbolehkan |
| Perangkat pribadi | **Dilarang keras** | **Dilarang** | Diperbolehkan jika dienkripsi | Diperbolehkan |
| Hardcopy (cetak) | **Dilarang** kecuali keperluan hukum/audit dengan pengawasan | Diperbolehkan dengan pelabelan; harus disimpan terkunci | Diperbolehkan | Diperbolehkan |

### 4.2 Transmisi (Pengiriman)

| Aspek | L4 — Terbatas | L3 — Rahasia | L2 — Internal | L1 — Publik |
|-------|--------------|-------------|--------------|------------|
| Email | **Dilarang** mengirim data L4 via email biasa | Enkripsi email (TLS) wajib; lebih baik hindari email untuk data keuangan | Diperbolehkan via email tim | Tidak dibatasi |
| Messaging (WhatsApp, Telegram) | **Dilarang keras** | **Dilarang** | Diperbolehkan untuk komunikasi rutin | Diperbolehkan |
| Transfer antar sistem | Hanya via HTTPS/TLS 1.2+ dan SSH | HTTPS/TLS wajib | HTTPS dianjurkan | Tidak dibatasi |
| Kepada pihak ketiga | **Dilarang** tanpa DPA tertulis dan persetujuan Pimpinan | Memerlukan NDA (ISP-004) dan otorisasi PM | Memerlukan pertimbangan PM | Tidak dibatasi |

### 4.3 Akses

| Aspek | L4 — Terbatas | L3 — Rahasia | L2 — Internal | L1 — Publik |
|-------|--------------|-------------|--------------|------------|
| Prinsip | Minimum privilege yang secara teknis tidak dapat dihindari | *Need-to-know* — sesuai peran dan tugas | Seluruh anggota tim aktif | Siapa saja |
| Otorisasi | Tech Lead + PM secara eksplisit per individu | PM atau Tech Lead per peran | Otomatis dengan bergabungnya tim | Tidak diperlukan |
| Review akses | Setiap ada perubahan tim; diverifikasi saat offboarding | Quarterly (per ISP-003) | Quarterly | Tidak diperlukan |
| Log akses | **Wajib** — dicatat di Frappe Audit Log + server access log | Wajib di Frappe Audit Log | Dianjurkan | Tidak diperlukan |

### 4.4 Pencetakan dan Penyalinan

| Aspek | L4 — Terbatas | L3 — Rahasia | L2 — Internal | L1 — Publik |
|-------|--------------|-------------|--------------|------------|
| Pencetakan | **Dilarang** tanpa kebutuhan hukum/audit yang terdokumentasi | Diperbolehkan dengan label `[RAHASIA]`; dokumen tidak boleh ditinggal di printer | Diperbolehkan | Diperbolehkan |
| Screenshot | **Dilarang** kecuali untuk keperluan debugging yang terdokumentasi | Hanya untuk keperluan tugas; tidak boleh disimpan lama | Diperbolehkan | Diperbolehkan |
| Copy-paste ke tools lain | **Dilarang** (misalnya: paste NIK ke dokumen Google Docs pribadi) | Hanya ke tools yang sudah disetujui | Diperbolehkan | Diperbolehkan |

### 4.5 Pemusnahan (Disposal)

| Aspek | L4 — Terbatas | L3 — Rahasia | L2 — Internal | L1 — Publik |
|-------|--------------|-------------|--------------|------------|
| Data digital | Hapus permanen + overwrite (minimal 1 pass); untuk SSD: secure erase atau enkripsi + hapus key | Hapus permanen; hapus dari recycle bin dan backup lokal | Hapus biasa sudah cukup | Tidak diperlukan prosedur khusus |
| Dokumen cetak | Dimusnahkan dengan shredder; tidak boleh dibuang di tempat sampah biasa | Dimusnahkan dengan shredder atau dibakar | Robek sebelum dibuang, atau shredder | Tidak diperlukan prosedur khusus |
| Media penyimpanan | Wipe kriptografis + konfirmasi TL tertulis; jika tidak memungkinkan: musnahkan media secara fisik | Wipe kriptografis | Format + hapus | Tidak diperlukan |
| Konfirmasi | TL wajib mengkonfirmasi pemusnahan secara tertulis (dicatat di log offboarding ISP-003) | PM mencatat pemusnahan | Tidak diperlukan | Tidak diperlukan |

---

## 5. Cara Mengklasifikasikan Informasi Baru

Gunakan urutan pertanyaan berikut saat menerima atau membuat informasi baru:

```
1. Apakah informasi ini mengandung NIK, NPWP, data kesehatan, atau credential production?
   → YA  → L4 TERBATAS

2. Apakah informasi ini mengandung data keuangan NGO, data donor (non-NIK/NPWP),
   atau memberikan akses ke sistem Fundara?
   → YA  → L3 RAHASIA

3. Apakah informasi ini hanya relevan untuk tim proyek dan tidak untuk publik?
   → YA  → L2 INTERNAL

4. Apakah informasi ini sudah dipublikasikan atau boleh dibagikan secara bebas?
   → YA  → L1 PUBLIK
```

**Aturan default:** Jika ragu, pilih klasifikasi **satu tingkat lebih tinggi** dari perkiraan awal, lalu konsultasikan dengan Tech Lead untuk konfirmasi dalam 1 hari kerja.

**Aturan komposit:** Dokumen yang mengandung campuran tingkat klasifikasi mendapat klasifikasi **tertinggi** dari seluruh komponennya. Laporan yang menampilkan nama donor (L3) sekaligus NIK donor (L4) diklasifikasikan **L4**.

---

## 6. Klasifikasi Komponen Utama Fundara

Tabel referensi cepat untuk komponen yang sering ditemui:

| Komponen | Klasifikasi | Dasar |
|---------|-------------|-------|
| NIK, NPWP donor | **L4** | UU PDP, data identitas |
| Data kesehatan / kondisi benefisiari | **L4** | UU PDP, data sensitif khusus |
| Data anak benefisiari | **L4** | UU PDP, perlindungan anak |
| Nomor rekening bank staf | **L4** | Data keuangan pribadi |
| Database password, private key, GPG passphrase | **L4** | Credential production |
| Backup database (terenkripsi sekalipun) | **L4** | Berisi data L4 |
| Nama, email, telepon donor | **L3** | Data pribadi non-L4 |
| Jumlah donasi individual | **L3** | Privasi finansial |
| Saldo Fund, GL Entry, laporan keuangan internal | **L3** | Keuangan NGO |
| Detail Grant dan perjanjian | **L3** | Strategis dan kontraktual |
| Cash Advance, Advance Liquidation | **L3** | Keuangan staf |
| Kode sumber Fundara | **L3** | Arsitektur + potensi vulnerability |
| Seluruh `docs/security/` | **L3** | Informasi keamanan sistem |
| Credential staging | **L3** | Akses sistem non-production |
| Spesifikasi teknis (`docs/spec/`) | **L2** | Dokumentasi internal |
| Panduan developer (`docs/dev/`) | **L2** | Dokumentasi internal |
| Estimasi dan keputusan PM (`docs/pm/`) | **L2** | Informasi proyek internal |
| Demo data fiktif YPN Harapan Bangsa | **L2** | Data tidak nyata, tetap internal |
| `environment-spec.md` (tanpa credential) | **L2** | Arsitektur internal |
| README.md | **L1** | Deskripsi publik |
| Laporan tahunan NGO yang dipublikasikan | **L1** | Sudah dibuat publik oleh NGO |

---

## 7. Pelabelan Dokumen

### Dokumen Digital

| Level | Label di Header Dokumen |
|-------|------------------------|
| L4 — Terbatas | `**[TERBATAS — ISP-005 L4]**` di baris pertama setelah judul |
| L3 — Rahasia | `**[RAHASIA — ISP-005 L3]**` di baris pertama setelah judul |
| L2 — Internal | `**[INTERNAL]**` opsional; atau tidak dilabeli (default internal) |
| L1 — Publik | Tidak perlu label; atau `**[PUBLIK]**` jika perlu kejelasan |

### Dokumen Cetak

Cantumkan label di header dan footer setiap halaman. Untuk L4, tambahkan nomor salinan dan nama penerima (copy control).

### Laporan yang Dihasilkan Sistem Fundara

Laporan yang di-export dari Fundara (PDF, Excel) secara otomatis mengikuti klasifikasi data yang paling tinggi di dalamnya. PM bertanggung jawab memastikan penerima laporan memiliki otorisasi akses yang sesuai.

---

## 8. Peran dan Tanggung Jawab

| Peran | Tanggung Jawab |
|-------|---------------|
| **Tech Lead** | Menetapkan klasifikasi untuk komponen teknis baru; mengkonfirmasi klasifikasi yang diragukan; memastikan kontrol teknis sesuai per level |
| **Project Manager** | Menetapkan klasifikasi untuk dokumen PM dan komunikasi eksternal; mengotorisasi akses L3 untuk anggota tim |
| **Developer / QA** | Mengklasifikasikan data/dokumen yang mereka buat; tidak menurunkan klasifikasi tanpa persetujuan TL |
| **DevOps** | Memastikan kontrol teknis penyimpanan dan transmisi sesuai klasifikasi di setiap environment |
| **Semua anggota tim** | Menerapkan aturan penanganan sesuai klasifikasi; melaporkan dokumen yang salah diklasifikasikan ke TL |

---

## 9. Pelanggaran Klasifikasi

Pelanggaran terhadap aturan penanganan di kebijakan ini (misalnya: mengirim data L4 via WhatsApp, menyimpan NIK donor di Google Sheets pribadi) diperlakukan sebagai insiden keamanan dan ditangani sesuai `docs/security/incident-response.md`.

Konsekuensi pelanggaran mengikuti ketentuan ISP-001 § 5.9 dan ISP-004 (NDA Template) — termasuk potensi sanksi hukum UU PDP Pasal 67 untuk penyalahgunaan data pribadi.

---

## 10. Review dan Pembaruan

Kebijakan ini direview dalam kondisi berikut:
- Setiap tahun (bersamaan dengan review IS Policy ISP-001)
- Saat ada perubahan signifikan pada jenis data yang diproses Fundara
- Saat ada regulasi baru yang relevan (perubahan UU PDP, dll.)
- Setelah insiden yang melibatkan misklasifikasi data

---

## 11. Tanda Tangan

| Peran | Nama | Tanggal | Tanda Tangan |
|-------|------|---------|--------------|
| Tech Lead (Pemilik Dokumen) | | | |
| Project Manager | | | |
| Product Owner (Pimpinan) | | | |

---

*Dokumen ini adalah bagian dari ISMS Fundara. Pertanyaan mengenai klasifikasi informasi spesifik dapat diajukan kepada Tech Lead atau merujuk ke ISP-001 (Information Security Policy).*
