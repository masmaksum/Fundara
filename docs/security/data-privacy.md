# Data Privacy Specification — Fundara

**Version:** 1.0
**Last Updated:** 2026-06-19
**Audience:** Tech Lead, Legal/Compliance, PM, DevOps
**Status:** Draft — review before go-live

Dokumen ini mendefinisikan bagaimana Fundara menangani data pribadi dalam konteks UU PDP No. 27 Tahun 2022 (Undang-Undang Pelindungan Data Pribadi), yang mulai berlaku efektif November 2024.

---

## 1. Landasan Hukum

### UU PDP No. 27 Tahun 2022

UU PDP adalah regulasi perlindungan data pribadi pertama Indonesia yang komprehensif, berlaku penuh November 2024. Regulasi ini mengatur dua pihak utama:

**Pemilik Data Pribadi (Data Controller):**
YPN/LSM/NGO yang menggunakan Fundara sebagai sistem operasionalnya. Organisasi inilah yang bertanggung jawab atas kepatuhan UU PDP — termasuk menetapkan tujuan pemrosesan, mendapatkan consent, menjawab permintaan hak subjek data, dan melaporkan insiden ke Kominfo/BSSN.

**Pemroses Data Pribadi (Data Processor):**
Tim pengembang Fundara memproses data atas instruksi pemilik data. Kewajiban pemroses mencakup: mengimplementasikan langkah teknis keamanan, tidak memproses data di luar instruksi pemilik, dan mendukung pemilik data dalam memenuhi hak subjek data.

**Prinsip-prinsip yang relevan dari UU PDP (Pasal 16):**

| Prinsip | Relevansi untuk Fundara |
|---|---|
| Minimasi data | Hanya kumpulkan field PII yang benar-benar dibutuhkan fungsi sistem |
| Tujuan yang jelas | Setiap data dikumpulkan dengan tujuan spesifik yang dinyatakan eksplisit |
| Keakuratan | Mekanisme koreksi tersedia bagi subjek data |
| Keamanan | Kontrol teknis dan organisasi — lihat `security-requirements.md` |
| Retensi terbatas | Data tidak disimpan lebih lama dari yang dibutuhkan |
| Akuntabilitas | Audit trail melalui Frappe version history |

> **Catatan penting:** Fundara adalah platform perangkat lunak. Kepatuhan UU PDP adalah tanggung jawab organisasi yang menggunakannya, bukan Fundara project. Fundara menyediakan fitur teknis untuk *membantu* kepatuhan — field consent, anonymization, export data, audit log — tetapi tidak secara otomatis menjamin kepatuhan. Organisasi harus menetapkan kebijakan privasi mereka sendiri, menunjuk DPO jika diperlukan, dan memastikan proses operasional sesuai regulasi.

---

## 2. Inventaris Data PII

Tabel berikut mendaftar seluruh kategori data pribadi yang diproses Fundara, DocType tempat data tersimpan, dan dasar pemrosesan yang berlaku.

| Kategori Data | DocType | Field | Sensitivitas | Dasar Pemrosesan |
|---|---|---|---|---|
| Identitas donor individu | Donor | `donor_name`, `nik`, `npwp`, `address`, `email`, `phone` | Tinggi | Kewajiban hukum (penerimaan donasi), consent |
| Data keuangan donor | Donation | `amount`, `payment_method`, `bank_account` | Tinggi | Kewajiban hukum, kontrak |
| Data benefisiari | Beneficiary (post-MVP) | `full_name`, `age`, `location`, `program_notes` | Sangat Tinggi | Consent eksplisit + kebutuhan program |
| Data benefisiari anak | Beneficiary (program anak) | semua field anak di bawah umur | Sangat Tinggi | Consent wali yang sah + perlindungan anak |
| Data staf (identitas) | User, Staff Profile | `full_name`, `email`, `jabatan`, `department` | Sedang | Kontrak kerja |
| Data staf (finansial) | Cash Advance, Advance Liquidation | `requester`, `amount`, nama dalam field terkait | Tinggi | Kontrak kerja, kewajiban audit |
| Data vendor / mitra | Vendor | `contact_person`, `email`, `npwp`, `address` | Sedang | Kontrak pengadaan |
| Data akses sistem | User, Activity Log | `email`, `ip_address`, `login_history` | Sedang | Keamanan sistem, akuntabilitas |

**Field yang mengandung PII sensitif (wajib dilindungi dengan field-level masking):**
- `nik` (Nomor Induk Kependudukan)
- `npwp` (Nomor Pokok Wajib Pajak)
- Semua field di Beneficiary yang berkaitan dengan kondisi kesehatan
- Semua data anak di bawah umur

Field masking diimplementasikan via Frappe field-level permission atau `before_load` hook — lihat `security-requirements.md` SR-AUTHZ-04.

---

## 3. Prinsip Penanganan Data

### 3.1 Minimasi Data

Hanya kumpulkan field yang benar-benar dibutuhkan fungsi sistem:

- **Donor individu:** nama dan email wajib. NPWP hanya wajib jika donasi melebihi threshold pajak (Rp 5.000.000 untuk kebutuhan pelaporan zakat/donasi; ikuti aturan perpajakan berlaku). NIK tidak dikumpulkan kecuali ada kewajiban hukum spesifik.
- **Benefisiari:** batasi field ke apa yang dibutuhkan monitoring program. Field kondisi kesehatan hanya dikumpulkan jika program secara eksplisit membutuhkannya.
- **Review wajib:** setiap DocType baru yang mengandung field PII harus melalui privacy review — apakah setiap field benar-benar dibutuhkan, dan apa dasar pemrosesannya.

### 3.2 Tujuan yang Jelas

Data hanya digunakan untuk tujuan yang dinyatakan saat pengumpulan:

- **Data donor:** pemrosesan donasi, pelaporan keuangan, komunikasi program (hanya jika ada consent).
- **Data benefisiari:** monitoring dan evaluasi program, pelaporan kepada donor (data agregat, bukan individual kecuali diperlukan).
- **Data staf:** administrasi kepegawaian, pertanggungjawaban transaksi keuangan.
- Data tidak boleh digunakan untuk tujuan lain tanpa consent baru. Contoh: data donor tidak boleh digunakan untuk kampanye fundraising baru tanpa consent opt-in.

### 3.3 Keakuratan

- Donor dan benefisiari dapat mengajukan koreksi data melalui koordinator program.
- Proses koreksi: koordinator memverifikasi, kemudian update via Frappe UI.
- Frappe Version Control secara otomatis menyimpan riwayat perubahan setiap record — setiap edit tercatat dengan user, timestamp, dan nilai lama/baru.
- Untuk data staf: HR Manager dapat melakukan koreksi via Staff Profile.

### 3.4 Keamanan

Kontrol teknis keamanan data PII diatur lengkap di `docs/security/security-requirements.md`. Ringkasan yang relevan untuk privasi:

- Field PII sensitif di-mask untuk role yang tidak memiliki akses (tampil sebagai `***`)
- Semua akses ke Beneficiary record dibatasi ke Project Manager dan Field Staff proyek terkait
- Backup terenkripsi GPG-AES256 sebelum disimpan di remote storage
- Akses database tidak pernah diberikan langsung dari luar server (localhost only)

### 3.5 Retensi Terbatas

Data tidak disimpan lebih lama dari yang dibutuhkan. Lihat Section 5 untuk tabel retensi lengkap.

---

## 4. Hak Subjek Data

UU PDP memberikan hak-hak berikut kepada subjek data (donor, benefisiari, staf). Tabel ini mendefinisikan kewajiban organisasi dan dukungan teknis yang tersedia di Fundara.

| Hak | Kewajiban Organisasi | Dukungan Teknis Fundara |
|---|---|---|
| **Mengakses data** | Berikan salinan data dalam 30 hari sejak permintaan | Export Donor record sebagai PDF atau CSV dari Frappe; Finance Officer / Donor Relationship Manager dapat menjalankan export |
| **Koreksi data** | Koreksi data yang tidak akurat tanpa penundaan | Update via Frappe UI; version history otomatis terjaga per edit |
| **Penghapusan data** | Hapus jika tidak ada kewajiban hukum yang mengharuskan retensi | Fungsi anonymization (lihat Section 6) — Fundara tidak hard-delete karena kewajiban akuntansi |
| **Membatasi pemrosesan** | Hentikan pemrosesan atas permintaan subjek data | Nonaktifkan Donor record (`disabled = 1`) tanpa menghapus data; donor tidak muncul di workflow aktif |
| **Portabilitas data** | Berikan data dalam format yang dapat dibaca mesin | Export CSV/JSON dari Frappe List View atau via REST API |
| **Menolak pemrosesan** | Khususnya untuk komunikasi marketing / non-essential | Field `opt_out_communication` di Donor; ketika diset, donor tidak masuk ke campaign mailing list |

**Cara memproses permintaan hak subjek data:**

1. Subjek data menghubungi organisasi (email, telepon, atau formulir tertulis)
2. Koordinator / Donor Relationship Manager memverifikasi identitas pemohon
3. Permintaan dilog di Compliance Checklist (DocType) untuk audit trail
4. Tindakan diambil dalam 30 hari (best practice UU PDP)
5. Konfirmasi tertulis dikirimkan ke subjek data

---

## 5. Data Retention Policy

Fundara tidak bisa melakukan hard-delete data keuangan karena kewajiban ISAK 35 (standar akuntansi entitas nirlaba Indonesia) dan regulasi perpajakan. GL Entry bersifat permanen. Oleh karena itu, penanganan data yang sudah melewati masa retensi dilakukan melalui **anonymization**, bukan penghapusan.

| Kategori Data | Periode Retensi | Dasar Hukum / Kebijakan | Tindakan Setelah Expired |
|---|---|---|---|
| Data donor + transaksi donasi | 10 tahun sejak transaksi terakhir | Kewajiban perpajakan Indonesia (UU KUP) | Anonymization (lihat Section 6) |
| Data benefisiari aktif (dewasa) | Selama program aktif + 5 tahun | Kebutuhan audit program, akuntabilitas donor | Anonymization |
| Data benefisiari anak | Sampai subjek berusia 18 tahun + 5 tahun | UU Perlindungan Anak No. 35 Tahun 2014 | Anonymization |
| Data staf — identitas | Selama hubungan kerja + 5 tahun | Regulasi ketenagakerjaan Indonesia | Archive read-only |
| Data staf — keuangan (advance, liquidation) | 10 tahun | Kewajiban audit keuangan | Archive read-only (tidak dihapus) |
| GL Entry / jurnal akuntansi | Permanen | ISAK 35 + regulasi perpajakan | Tidak pernah dihapus |
| Audit log / activity log Frappe | Minimum 2 tahun | Akuntabilitas internal, keamanan | Archive ke cold storage atau purge setelah 2 tahun |
| File backup harian | 14 hari (remote) | Disaster recovery | Hapus secara aman (`shred` / remote storage lifecycle policy) |
| File backup mingguan | 8 minggu | Disaster recovery + restore drill | Hapus secara aman |
| File backup bulanan | 12 bulan | Compliance audit | Hapus secara aman |
| File backup tahunan (jika ada) | 7 tahun | Audit keuangan jangka panjang | Hapus secara aman |

**Catatan backup:** Backup yang sudah melewati masa retensi dihapus menggunakan lifecycle policy di S3-compatible storage (Backblaze B2, Wasabi, dll.), bukan manual delete. Lihat `docs/infra/backup-recovery.md` untuk detail konfigurasi.

---

## 6. Anonymization Procedure

Karena GL Entry tidak dapat dihapus (kewajiban ISAK 35), data PII yang terhubung ke transaksi keuangan di-*anonymize* — bukan dihapus. Anonymisasi menghilangkan identitas pribadi sambil mempertahankan integritas data akuntansi.

### 6.1 Kapan Anonymisasi Dilakukan

- Masa retensi data telah berakhir (lihat Section 5)
- Subjek data mengajukan hak penghapusan data dan tidak ada kewajiban hukum untuk retensi
- Sebelum export data ke lingkungan staging (lihat `environment-spec.md` Section 2.8)

### 6.2 Prosedur Anonymisasi Donor

```
Prasyarat:
- Approval Finance Manager DAN Tech Lead (tertulis, dicatat di Compliance Checklist)
- Verifikasi bahwa tidak ada kewajiban hukum yang mengharuskan retensi data asli
- Backup terbaru tersedia dan telah diverifikasi

Langkah:
1. Ganti field `donor_name` → "Anonim [donor_id]"
   Contoh: "Budi Santoso" → "Anonim D-00123"
   (pertahankan ID untuk mempertahankan linkage ke GL Entry)

2. Hapus field: email, phone, address, nik, npwp

3. Set field `is_anonymized = 1` pada Donor record

4. Set field `anonymization_date` = tanggal hari ini

5. Set field `anonymized_by` = user yang melakukan (untuk audit trail)

6. Pertahankan: jumlah donasi, tanggal donasi, fund tujuan, campaign
   (data ini dibutuhkan untuk laporan akuntansi dan pelaporan donor)

7. Catat tindakan di Compliance Checklist dengan referensi Donor ID
```

> **Peringatan:** Anonymisasi tidak dapat dibatalkan. Setelah dieksekusi, data identitas donor hilang permanen. Pastikan proses approval diikuti tanpa pengecualian.

### 6.3 Prosedur Anonymisasi Benefisiari

Prinsip sama dengan donor, dengan tambahan:
- Hapus semua field kondisi kesehatan/sosial
- Ganti nama → "Benefisiari [project_id]-[seq]"
- Untuk data anak: pastikan consent wali telah dicatat sebelumnya, dan sertakan dalam approval anonymisasi

### 6.4 Anonymisasi untuk Staging Export

Ketika data produksi diekspor ke staging untuk keperluan testing:
- Donor names → `Donor-XXXX` (hash-based, tidak reversible)
- Staff names → `Staff-XXXX`
- Email dan telepon → diganti placeholder staging
- NIK/NPWP → dihapus
- Jumlah keuangan → dipertahankan (dibutuhkan untuk volume testing)
- Proses ini harus dijalankan oleh lead engineer, bukan developer biasa

---

## 7. Consent Management

### 7.1 Kapan Consent Diperlukan

Consent eksplisit diperlukan untuk:
- Pengumpulan dan pemrosesan data donor individu (bukan badan hukum)
- Enrollment benefisiari ke program
- Komunikasi non-esensial (newsletter, update kampanye)
- Data anak di bawah umur (consent wali)

Consent **tidak** diperlukan (dasar pemrosesan lain berlaku) untuk:
- Pemrosesan keuangan yang diwajibkan hukum (UU Perpajakan, regulasi zakat)
- Data staf dalam konteks kontrak kerja
- Data vendor dalam konteks kontrak pengadaan

### 7.2 Cara Mencatat Consent di Fundara

Field consent pada DocType Donor:

| Field | Tipe | Keterangan |
|---|---|---|
| `consent_given` | Checkbox | Apakah consent telah diberikan |
| `consent_date` | Date | Tanggal consent diberikan |
| `consent_method` | Select | `online_form` / `physical_form` / `verbal_recorded` |
| `consent_document_ref` | Data | Nomor referensi atau path ke dokumen fisik yang discan |

Untuk benefisiari (post-MVP), field yang sama ditambahkan ke DocType Beneficiary, dengan tambahan field `guardian_consent` untuk data anak.

### 7.3 Mekanisme Consent

| Kanal Pengumpulan Donasi | Mekanisme Consent |
|---|---|
| Donasi online (portal) | Checkbox eksplisit di form donasi sebelum submit; consent dicatat otomatis dengan timestamp server |
| Donasi offline (transfer bank) | Formulir fisik dengan tanda tangan donor; discan dan diunggah sebagai Evidence Document |
| Donasi melalui kampanye | Consent tercakup dalam terms kampanye; Fundraising Officer mencatat di Donor record |
| Penerimaan benefisiari | Formulir consent terpisah; ditandatangani oleh benefisiari (atau wali jika anak) |

### 7.4 Penarikan Consent

Jika donor atau benefisiari menarik consent:
1. Donor Relationship Manager mengubah `consent_given` → unchecked
2. Set `opt_out_communication = 1` jika berlaku
3. Evaluasi apakah ada dasar pemrosesan lain yang sah (misalnya kewajiban hukum)
4. Jika tidak ada dasar lain: proses anonymisasi sesuai Section 6

---

## 8. Data Transfer ke Pihak Ketiga

### 8.1 Transfer yang Diizinkan

| Penerima | Data yang Dikirim | Dasar | Perlindungan |
|---|---|---|---|
| Donor institusional (USAID, EU, dll.) | Data donasi donor yang bersangkutan + laporan program agregat | Kewajiban pelaporan grant | Laporan digenerate dari Frappe; tidak ada export database mentah |
| Kantor akuntan publik (audit) | Laporan keuangan, GL Summary | Kewajiban audit | Akses read-only terbatas; bukan export database |
| BAZNAS / otoritas zakat | Data donasi zakat tertentu | Kewajiban pelaporan zakat | Data minimal, sesuai format yang diwajibkan |

### 8.2 Transfer yang Tidak Diizinkan

- Tidak ada sharing data donor/benefisiari ke pihak ketiga untuk tujuan marketing atau analytics
- Tidak ada penjualan data
- Tidak ada transfer ke negara yang tidak memiliki perlindungan data memadai tanpa safeguard tambahan

### 8.3 Cloud Storage (Backup)

Backup terenkripsi GPG-AES256 dikirim ke S3-compatible storage (Backblaze B2, Wasabi, atau setara) via rclone. Enkripsi dilakukan sebelum upload — penyedia storage tidak memiliki akses ke konten. Lihat `docs/infra/backup-recovery.md` Section 3.4.

### 8.4 Integrasi Eksternal (Mendatang)

Jika integrasi baru ditambahkan (KoboToolbox, payment gateway, sistem SMS), wajib:
1. Menilai apakah integrasi melibatkan transfer data PII
2. Memastikan pihak ketiga memiliki kebijakan privasi yang memadai
3. Membuat Data Processing Agreement (DPA) jika pihak ketiga memproses data PII atas instruksi organisasi
4. Mendokumentasikan transfer di inventaris data (update Section 2 dokumen ini)

---

## 9. Referensi

| Dokumen | Lokasi |
|---|---|
| Persyaratan keamanan teknis | `docs/security/security-requirements.md` |
| Permission matrix | `docs/spec/permissions.md` |
| Spesifikasi lingkungan (data policy per env) | `docs/infra/environment-spec.md` |
| Prosedur backup dan enkripsi | `docs/infra/backup-recovery.md` |
| Incident response (termasuk data breach) | `docs/security/incident-response.md` |
| UU PDP No. 27 Tahun 2022 | https://peraturan.bpk.go.id |
| ISAK 35 (standar akuntansi nirlaba) | DSAK IAI |
