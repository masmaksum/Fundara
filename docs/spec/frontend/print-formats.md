# Print Format Specifications

**Version:** 1.0
**Last Updated:** 2026-06-19
**Target:** ERPNext v16 / Frappe Print Format (Jinja2 + CSS)
**Audience:** Frontend Developer

---

## How to Read This Document

Each section defines one printable document. All print formats are implemented as **Frappe Custom Print Formats** using Jinja2 templates. Key conventions:

- **Paper size:** A4 portrait unless noted otherwise
- **Base language:** Bahasa Indonesia. English labels appear in parentheses on documents intended for international donors.
- **Font:** system-safe sans-serif stack — `'Helvetica Neue', Arial, sans-serif`
- **Currency formatting:** `Rp X.XXX.XXX` for IDR; `USD X,XXX.XX` / `EUR X,XXX.XX` for foreign currencies
- **Watermark:** "LUNAS" (paid), "DIAJUKAN" (submitted), or "DIBATALKAN" (cancelled) as a diagonal red/gray stamp overlaid on the page body via CSS `::before` pseudo-element on `body`, `opacity: 0.08`, `font-size: 72px`, `transform: rotate(-45deg)`.
- **Print trigger:** Each format is accessible via the **Print** button on the relevant DocType form when the document is in the specified status.

---

## Print Format 1: Kuitansi Penerimaan Donasi (Donation Receipt)

**Triggered from:** Donation Receipt  
**Condition:** Status = Verified or Submitted (doc_status ≥ 0)  
**Paper size:** A4 (210 × 297 mm)  
**Orientation:** Portrait  
**Language:** Bahasa Indonesia (donor name printed as entered; if donor is foreign, amount also shown in donation currency)

### Header Section

| Element | Source Field | Format | Notes |
|---|---|---|---|
| Logo organisasi | `company.company_logo` | max-height 60px, kiri atas | Fallback: nama organisasi dalam teks |
| Judul dokumen | static | **KUITANSI PENERIMAAN DONASI** | Center, bold, 16px |
| Nomor kuitansi | `donation_receipt.name` | `KD-YYYY-XXXXX` | Kanan atas |
| Tanggal kuitansi | `donation_receipt.posting_date` | `DD MMMM YYYY` | Kanan atas, di bawah nomor |
| Nama organisasi | `company.company_name` | Subheading center | Di bawah judul |
| Alamat organisasi | `company.address` | Normal, center | Di bawah nama |

### Body Sections

**Identitas Donor (Donor Information)**

| Field Label | Source Field | Format | Notes |
|---|---|---|---|
| Diterima dari (Received from) | `donation_receipt.donor_name` | String | Jika anonim: "Donatur Anonim" |
| Nomor KTP / Identitas | `donation_receipt.donor_id_number` | String | Tampilkan hanya jika terisi |
| Alamat (Address) | `donation_receipt.donor_address` | String | Opsional |
| Email | `donation_receipt.donor_email` | String | Opsional |
| Telepon | `donation_receipt.donor_phone` | String | Opsional |

**Detail Donasi (Donation Detail)**

| Field Label | Source Field | Format | Notes |
|---|---|---|---|
| Jumlah donasi (Amount) | `donation_receipt.amount` | `Rp X.XXX.XXX` atau `USD X,XXX.XX` | Currency sesuai `donation_currency` |
| Jumlah dalam huruf (In words) | computed | Terbilang IDR | Terbilang IDR dari `amount_idr` |
| Campaign / Tujuan | `donation_receipt.campaign` or `fund` | String | "Donasi Umum" jika tidak ada campaign |
| Jenis donasi (Type) | `donation_receipt.donation_type` | String | Tunai / Transfer / QRIS / Lainnya |
| Nomor referensi (Reference) | `donation_receipt.payment_reference` | String | Nomor transfer bank / bukti |
| Tanggal penerimaan (Received date) | `donation_receipt.received_date` | `DD MMMM YYYY` | |
| Catatan (Notes) | `donation_receipt.notes` | String | Tampilkan hanya jika terisi |

**Peruntukan Dana (Fund Designation)**

| Field Label | Source Field | Format | Notes |
|---|---|---|---|
| Fund / Dana | `donation_receipt.fund` | String | |
| Restriction | `donation_receipt.restriction_type` | "Terbatas / Tidak Terbatas" | Dari fund master |
| Periode | `donation_receipt.grant_period` atau campaign period | String | Tampilkan jika terkait grant/campaign |

### Footer Section

- Kalimat ucapan terima kasih (static): *"Terima kasih atas kepercayaan Anda kepada [Nama Organisasi]. Donasi Anda akan digunakan sesuai dengan ketentuan yang berlaku."*
- Kotak tanda tangan kanan bawah:
  - Tanda tangan Finance Officer / Fundraising Officer
  - Nama dan jabatan
  - Tanggal
- Kotak tanda tangan kiri bawah (jika diperlukan):
  - Tanda tangan penerima donasi (Donor atau kuasanya)
- Stempel organisasi: tempat stempel di atas tanda tangan penerbit
- Nomor halaman: `Halaman 1 dari 1`
- Timestamp cetak: `Dicetak pada: DD MMMM YYYY HH:mm WIB`

### Conditional Elements

- **Jumlah dalam currency asing:** Ditampilkan sebagai baris tambahan `"(USD X,XXX.XX — setara Rp X.XXX.XXX pada kurs tanggal [date])"` hanya jika `donation_currency != 'IDR'`
- **Logo campaign:** Ditampilkan di sebelah logo organisasi jika `donation_receipt.campaign` terisi dan campaign memiliki logo
- **Kalimat restriction:** Muncul hanya jika `restriction_type = 'Restricted'`: *"Donasi ini bersifat terbatas dan hanya dapat digunakan untuk [tujuan]."*
- **Watermark LUNAS:** Hanya jika `payment_verified = 1`

---

## Print Format 2: Bukti Pembayaran Uang Muka (Cash Advance Receipt)

**Triggered from:** Cash Advance  
**Condition:** `workflow_state = 'Paid'`  
**Paper size:** A5 (148 × 210 mm) atau A4 potong dua  
**Orientation:** Portrait  
**Language:** Bahasa Indonesia

### Header Section

| Element | Source Field | Format | Notes |
|---|---|---|---|
| Logo organisasi | `company.company_logo` | max-height 50px, kiri atas | |
| Judul dokumen | static | **BUKTI PEMBAYARAN UANG MUKA** | Center, bold, 14px |
| Nomor dokumen | `cash_advance.name` | `CA-YYYY-XXXXX` | Kanan atas |
| Tanggal bayar | `cash_advance.payment_date` | `DD MMMM YYYY` | Kanan atas |

### Body Sections

**Identitas Penerima (Recipient)**

| Field Label | Source Field | Format | Notes |
|---|---|---|---|
| Diterima oleh (Received by) | `cash_advance.employee_name` | String | |
| Jabatan (Position) | `cash_advance.designation` | String | |
| Departemen | `cash_advance.department` | String | |
| Nomor karyawan | `cash_advance.employee` | String | |

**Detail Uang Muka (Advance Detail)**

| Field Label | Source Field | Format | Notes |
|---|---|---|---|
| Keperluan (Purpose) | `cash_advance.purpose` | String | |
| Kegiatan (Activity) | `cash_advance.activity` | String | |
| Fund | `cash_advance.fund` | String | |
| Budget Line | `cash_advance.budget_line` | String | |
| Jumlah (Amount) | `cash_advance.amount_requested` | Currency format | |
| Jumlah dalam huruf | computed | Terbilang | |
| Metode pembayaran | `cash_advance.payment_method` | String | Transfer / Tunai / Cek |
| Referensi pembayaran | `cash_advance.payment_reference` | String | Nomor transfer / cek |
| Batas waktu pertanggungjawaban | `cash_advance.liquidation_due_date` | `DD MMMM YYYY` | **Bold, warna merah** |

### Footer Section

- Kotak tanda tangan kiri: Penerima uang muka (staff)
  - Label: "Yang Menerima"
  - Nama + tanda tangan + tanggal
- Kotak tanda tangan tengah: Finance Officer
  - Label: "Dibayarkan oleh"
  - Nama + tanda tangan + tanggal
- Kotak tanda tangan kanan: Finance Manager (jika amount > 50 juta IDR)
  - Label: "Disetujui oleh"
  - Nama + tanda tangan + tanggal
- Catatan (static): *"Uang muka ini harus dipertanggungjawabkan selambat-lambatnya [liquidation_due_date]. Keterlambatan akan mengakibatkan pemblokiran pengajuan uang muka baru."*
- Timestamp cetak: `Dicetak pada: DD MMMM YYYY HH:mm`

### Conditional Elements

- **Kolom approver ketiga:** Muncul hanya jika `amount_requested > 50,000,000 IDR` (Finance Manager)
- **Kotak multi-currency:** Jika `currency != 'IDR'`, tampilkan baris tambahan: `"Setara: [currency] [amount_in_fund_currency] (kurs: [exchange_rate])"` 
- **Peringatan overdue:** Jika tanggal cetak sudah melewati `liquidation_due_date`, tambahkan banner merah di atas body: **"PERHATIAN: Batas pertanggungjawaban telah terlewati."**

---

## Print Format 3: Purchase Order (Surat Pesanan)

**Triggered from:** Purchase Order  
**Condition:** `workflow_state = 'Approved'` atau `'Ordered'`  
**Paper size:** A4  
**Orientation:** Portrait  
**Language:** Bahasa Indonesia dengan label Inggris dalam kurung untuk PO internasional

### Header Section

| Element | Source Field | Format | Notes |
|---|---|---|---|
| Logo organisasi | `company.company_logo` | max-height 60px, kiri atas | |
| Judul | static | **SURAT PESANAN / PURCHASE ORDER** | Center, bold, 16px |
| Nomor PO | `purchase_order.name` | `PO-YYYY-XXXXX` | Kanan atas |
| Tanggal PO | `purchase_order.transaction_date` | `DD MMMM YYYY` | Kanan atas |
| Tanggal berlaku s/d | `purchase_order.valid_till` | `DD MMMM YYYY` | Kanan atas |
| Nomor PR referensi | `purchase_order.purchase_request` | String | Kanan atas |

**Blok Alamat Dua Kolom:**

| Kiri: Pembeli (Buyer) | Kanan: Penjual (Vendor) |
|---|---|
| Nama organisasi | `purchase_order.supplier_name` |
| Alamat lengkap organisasi | `purchase_order.supplier_address` |
| NPWP organisasi | `purchase_order.supplier_tax_id` |
| Telepon / Email | Kontak vendor |
| Attn: Procurement Officer | Attn: Contact Person vendor |

### Body Sections

**Tabel Item (Line Items)**

| Kolom | Source Field | Format | Notes |
|---|---|---|---|
| No. | Row index | Integer | |
| Kode Barang (Item Code) | `item.item_code` | String | |
| Deskripsi (Description) | `item.description` | String | Bisa multiline |
| Satuan (UoM) | `item.uom` | String | |
| Kuantitas (Qty) | `item.qty` | Decimal 2 | |
| Harga Satuan (Unit Price) | `item.rate` | Currency | |
| Jumlah (Amount) | `item.amount` | Currency | |
| Fund / Dana | `item.fund` | String | Tampilkan jika terisi |
| Budget Line | `item.budget_line` | String | Tampilkan jika terisi |

**Ringkasan Harga:**

| Label | Value |
|---|---|
| Subtotal | Sum `item.amount` |
| Pajak (PPN) | `purchase_order.total_taxes_and_charges` |
| **Total (Grand Total)** | `purchase_order.grand_total` |
| Terbilang | Computed terbilang dari grand total |
| Mata uang (Currency) | `purchase_order.currency` |

**Syarat dan Ketentuan (Terms & Conditions)**

| Field Label | Source Field | Notes |
|---|---|---|
| Syarat pembayaran (Payment Terms) | `purchase_order.payment_terms_template` | |
| Syarat pengiriman (Delivery Terms) | `purchase_order.delivery_date` | "Jadwal pengiriman: DD MMMM YYYY" |
| Metode pengiriman | `purchase_order.shipping_address` | |
| Syarat lainnya | `purchase_order.terms` | Free text dari PO |

**Informasi Fund & Proyek:**

| Field Label | Source Field | Notes |
|---|---|---|
| Fund yang dibebankan | `purchase_order.fund` | |
| Proyek / Kegiatan | `purchase_order.project` | |
| Grant / Campaign | `purchase_order.grant` | Tampilkan jika terisi |

### Footer Section

- Kalimat pembuka (static): *"Dengan ini kami memesan barang/jasa sesuai rincian di atas. Mohon konfirmasi penerimaan Purchase Order ini dan jadwal pengiriman."*
- Tiga kotak tanda tangan:
  - Kiri: "Dibuat oleh" — Procurement Officer
  - Tengah: "Disetujui oleh" — Finance Manager
  - Kanan: "Untuk dan atas nama [Vendor]" — Tanda tangan vendor (kosong untuk ditandatangani vendor)
- Stempel organisasi
- Nomor halaman: `Halaman X dari Y`
- Timestamp cetak

### Conditional Elements

- **Bid Analysis reference:** Ditampilkan sebagai footer note jika `purchase_order.bid_analysis` terisi: *"Dokumen Analisis Penawaran: [bid_analysis.name] tertanggal [date]"*
- **Watermark "DIBATALKAN":** Jika `workflow_state = 'Cancelled'`
- **Kolom Kurs:** Muncul di bawah tabel jika `currency != 'IDR'`: *"Kurs pada tanggal PO: 1 [currency] = Rp [rate]. Nilai IDR: Rp [grand_total_idr]"*
- **Tanda tangan ketiga approver:** Ditambahkan jika `grand_total_idr > 200,000,000`

---

## Print Format 4: Laporan Penggunaan Dana (Fund Utilization Report)

**Triggered from:** Fund (melalui tombol cetak di Fund form atau report view)  
**Condition:** `fund.status = 'Active'` atau `'Closed'`  
**Paper size:** A4  
**Orientation:** Portrait (atau Landscape jika banyak kolom budget line)  
**Language:** Bahasa Indonesia. Label Inggris dalam kurung ditambahkan jika `fund.currency != 'IDR'`

### Header Section

| Element | Source Field | Format | Notes |
|---|---|---|---|
| Logo | `company.company_logo` | Kiri atas | |
| Judul | static | **LAPORAN PENGGUNAAN DANA** | Center, bold |
| Sub-judul | `fund.fund_name` | Center, 14px | |
| Periode laporan | Dipilih saat generate | `DD MMMM YYYY s/d DD MMMM YYYY` | |
| Tanggal cetak | computed | `DD MMMM YYYY` | Kanan atas |
| Fund type | `fund.fund_type` | String | |
| Restriction | `fund.restriction_type` | String | |
| Status fund | `fund.status` | String | |
| Funding source | `fund.funding_source` | String | |
| Grant terkait | `fund.grant` | String | Tampilkan jika terisi |
| Mata uang | `fund.currency` | String | |

### Body Sections

**Ringkasan Saldo Dana (Fund Balance Summary)**

| Label | Field | Format |
|---|---|---|
| Saldo Awal | `fund.opening_balance` | Currency |
| Penerimaan Dana | Sum income entries dalam periode | Currency |
| Transfer Masuk | Sum fund transfer in | Currency |
| Transfer Keluar | Sum fund transfer out | Currency |
| Total Pengeluaran (Actual Paid) | Sum paid expenses | Currency |
| **Saldo Akhir Tersedia** | Computed | Currency, **bold** |
| Saldo dalam IDR (jika multi-currency) | Computed at latest rate | `(Rp X.XXX.XXX — kurs: [rate] per [date])` |

**Budget vs Realisasi per Budget Line**

| Budget Line | Anggaran Disetujui | Realisasi (Actual) | Saldo Tersedia | % Terserap |
|---|---|---|---|---|
| [Budget line 1] | Amount | Paid actual | Remaining | Percentage |
| [Budget line 2] | ... | ... | ... | ... |
| **Total** | **Sum** | **Sum** | **Sum** | **Avg %** |

- Baris dengan % terserap > 90% dicetak dengan background kuning muda
- Baris dengan saldo negatif dicetak merah

**Panel Pending Payment (D-02 Disclosure):**

Kotak informasi terpisah dengan border putus-putus:

*"Catatan: Anggaran di atas mencerminkan transaksi yang telah dibayar (Actual). Berikut adalah transaksi yang sudah disetujui namun belum dibayar (Pending Payment) — tidak termasuk dalam kolom Realisasi di atas:"*

| Jenis | Nomor Dokumen | Penerima / Vendor | Budget Line | Jumlah |
|---|---|---|---|---|
| Uang Muka Disetujui | CA-YYYY-XXX | Nama staf | Travel | Amount |
| Purchase Order | PO-YYYY-XXX | Nama vendor | Equipment | Amount |
| **Total Pending** | | | | **Sum** |

**Rincian Transaksi (Transaction Detail)**

Tabel detail (bisa multi-halaman):

| Tanggal | Nomor Dokumen | Jenis Transaksi | Deskripsi | Budget Line | Jumlah | Ref Bukti |
|---|---|---|---|---|---|---|
| DD-MM-YY | CA-001 | Cash Advance | Field visit Solo | Travel | Amount | Receipt attached |
| ... | ... | ... | ... | ... | ... | ... |

**Advance Outstanding (jika ada):**

| Nomor Advance | Penerima | Tanggal Bayar | Jumlah | Batas Pertanggungjawaban | Status |
|---|---|---|---|---|---|
| CA-YYYY-XXX | Nama staf | Date | Amount | Date | Pending / Overdue |

### Footer Section

- Nama penyusun laporan dan tanggal penyusunan
- Kotak tanda tangan:
  - "Disusun oleh" — Finance Officer
  - "Diperiksa oleh" — Finance Manager
  - "Diketahui oleh" — Executive Director (jika laporan untuk board)
- Catatan disclaimer (static): *"Laporan ini disusun berdasarkan transaksi yang telah diposting ke sistem per tanggal cetak. Angka dapat berubah jika ada transaksi yang masih dalam proses."*
- Nomor halaman: `Halaman X dari Y`
- Timestamp cetak

### Conditional Elements

- **Panel Variance Explanation:** Muncul jika ada budget line dengan variance > 20%: menampilkan teks dari field `budget_line.variance_explanation`
- **Peringatan saldo rendah:** Jika saldo tersedia < 10% anggaran disetujui, muncul box merah: *"PERINGATAN: Saldo tersedia di bawah 10% dari anggaran yang disetujui."*
- **Nomor Grant / Reporting Period:** Ditampilkan di header jika `fund.fund_type = 'Grant Fund'`

---

## Print Format 5: Laporan Donor (Donor Report)

**Triggered from:** Donor Report DocType  
**Condition:** `donor_report.status = 'Ready for Submission'` atau `'Submitted'`  
**Paper size:** A4  
**Orientation:** Portrait  
**Language:** Bahasa Indonesia dengan label Inggris dalam kurung (dokumen ini sering dikirim ke donor internasional)

### Header Section

| Element | Source Field | Format | Notes |
|---|---|---|---|
| Logo organisasi | `company.company_logo` | Kiri atas | |
| Logo donor (jika ada) | `donor.logo` | Kanan atas | |
| Judul | static | **LAPORAN KEUANGAN DONOR / DONOR FINANCIAL REPORT** | Center, bold |
| Nama grant | `grant.grant_name` | Center, 13px | |
| Nomor grant | `grant.grant_reference` | Center | |
| Nama donor | `donor.donor_name` | Center | |
| Periode laporan | `donor_report.reporting_period` | Center | |
| Tanggal penyusunan | computed | Kanan atas | |
| Nomor laporan | `donor_report.name` | Kanan atas | |

### Body Sections

**Ringkasan Eksekutif (Executive Summary)**

| Label (ID) | Label (EN) | Source | Format |
|---|---|---|---|
| Total anggaran disetujui | Total approved budget | `grant.total_budget` | Currency |
| Total realisasi periode ini | Total expenditure this period | Computed | Currency |
| Total realisasi kumulatif | Cumulative expenditure | Computed | Currency |
| Saldo tersedia | Available balance | Computed | Currency |
| Persentase penyerapan | Absorption rate | Computed | `XX.X%` |
| Mata uang laporan | Report currency | `donor_report.report_currency` | String |
| Kurs yang digunakan | Exchange rate used | historical or stated | String |

**Budget vs Realisasi per Budget Line Donor (Budget vs Actual by Donor Budget Line)**

| Budget Line Donor | Anggaran (Budget) | Realisasi Periode Ini (This Period Actual) | Realisasi Kumulatif (Cumulative) | Sisa Anggaran (Remaining) | % |
|---|---|---|---|---|---|
| Personnel | Amount | Amount | Amount | Amount | % |
| Travel | ... | ... | ... | ... | % |
| ... | | | | | |
| **Total** | **Sum** | **Sum** | **Sum** | **Sum** | **%** |

**Rincian Pengeluaran per Budget Line (Expenditure Detail)**

Untuk setiap budget line:

```
[Budget Line Name] — [Budget Line Code]
Anggaran: [amount] | Realisasi: [amount] | Sisa: [amount]

Transaksi:
| Tanggal | Nomor Dokumen | Deskripsi | Penerima/Vendor | Jumlah |
|---|---|---|---|---|
| DD-MM-YY | CA-001 | Hotel field visit | Nama staf | Amount |
```

**Advance Outstanding per Donor (per D-02):**

| Nomor Advance | Staf | Budget Line | Jumlah | Status | Batas Pertanggungjawaban |
|---|---|---|---|---|---|
| CA-YYYY-XXX | Nama | Travel | Amount | Pending | DD-MM-YY |

**Register Dokumen Pendukung (Supporting Document Register)**

| No. | Tanggal | Nomor Dokumen | Jenis Bukti | Keterangan | Status Verifikasi |
|---|---|---|---|---|---|
| 1 | DD-MM-YY | INV-001 | Invoice vendor | Office supplies | Verified |
| 2 | | | | | |

**Penjelasan Variance (Variance Explanation)** — jika ada budget line dengan selisih > 10%:

| Budget Line | Anggaran | Realisasi | Selisih | Penjelasan |
|---|---|---|---|---|
| Travel | Amount | Amount | Amount | Teks penjelasan dari Finance |

### Footer Section

- Pernyataan keaslian (static): *"Kami menyatakan bahwa laporan keuangan ini disusun berdasarkan transaksi yang telah diposting dan diverifikasi sesuai catatan akuntansi [Nama Organisasi]."*
- Tiga kotak tanda tangan:
  - "Disusun oleh / Prepared by" — Finance Officer
  - "Diperiksa oleh / Reviewed by" — Grant Manager / Finance Manager
  - "Disetujui oleh / Approved by" — Executive Director
- Stempel organisasi
- Nomor halaman dan timestamp cetak

### Conditional Elements

- **Multi-currency disclosure:** Selalu muncul jika `fund.currency != 'IDR'`: *"Laporan ini menggunakan kurs historis pada tanggal masing-masing transaksi. Laporan dalam mata uang [fund.currency]."*
- **Status Submitted:** Watermark "TELAH DISAMPAIKAN KE DONOR" diagonal jika `donor_report.status = 'Submitted'`
- **Flag transaksi tanpa bukti:** Baris transaksi tanpa evidence ditandai dengan simbol `⚠` dan catatan kaki: *"Dokumen pendukung belum terlampir — sedang dalam proses verifikasi."*
- **Nomor halaman per section:** Untuk laporan panjang (> 10 halaman), setiap section budget line dimulai di halaman baru

---

## Print Format 6: Laporan Pertanggungjawaban Campaign (Campaign Utilization Report)

**Triggered from:** Fundraising Campaign  
**Condition:** `workflow_state = 'Reporting'` atau `'Closed'`  
**Paper size:** A4  
**Orientation:** Portrait  
**Language:** Bahasa Indonesia (laporan publik — tidak ada label Inggris kecuali nama brand campaign)

### Header Section

| Element | Source Field | Format | Notes |
|---|---|---|---|
| Logo organisasi | `company.company_logo` | Kiri atas | |
| Gambar/logo campaign | `campaign.campaign_image` | Kanan atas atau center | max-height 80px |
| Judul | static | **LAPORAN PERTANGGUNGJAWABAN PENGGUNAAN DANA** | Center, bold, 16px |
| Nama campaign | `campaign.campaign_name` | Center, 14px, bold | |
| Periode campaign | `campaign.start_date` — `campaign.end_date` | `DD MMMM – DD MMMM YYYY` | Center |
| Tanggal laporan | computed | Kanan atas | |

### Body Sections

**Ringkasan Campaign (Campaign Summary)**

Desain visual: kotak-kotak highlight (summary cards) untuk:

| Informasi | Source | Format |
|---|---|---|
| Total donasi terkumpul | `campaign.total_donations_received` | **Rp X.XXX.XXX** (bold, besar) |
| Target campaign | `campaign.target_amount` | Currency |
| Persentase pencapaian target | Computed | `XX%` |
| Jumlah donatur | `campaign.donor_count` | Integer |
| Periode campaign | Date range | String |

**Penggunaan Dana (Fund Utilization)**

| Keterangan | Jumlah | % dari Total Donasi |
|---|---|---|
| Total donasi diterima | Amount | 100% |
| Biaya penggalangan dana (Fundraising cost) | Amount | X% |
| **Dana bersih untuk program** | **Amount** | **X%** |
| Total pengeluaran program | Amount | X% |
| **Saldo akhir / Sisa dana** | **Amount** | **X%** |

**Rincian Penggunaan Dana Program (Program Expenditure)**

| Kegiatan | Deskripsi Singkat | Jumlah Penerima Manfaat | Pengeluaran |
|---|---|---|---|
| Distribusi makanan darurat | Deskripsi 1-2 kalimat | 1.200 orang | Rp X.XXX.XXX |
| Bantuan tempat tinggal | ... | 300 KK | Rp X.XXX.XXX |
| Bantuan medis | ... | 800 orang | Rp X.XXX.XXX |
| **Total** | | | **Rp X.XXX.XXX** |

**Rincian Biaya Penggalangan Dana (Fundraising Cost Detail)**

| Komponen | Keterangan | Jumlah |
|---|---|---|
| Platform fee / biaya transfer | Payment gateway | Amount |
| Materi promosi | Desain, cetak, distribusi | Amount |
| Biaya event | Acara penggalangan | Amount |
| **Total Biaya Penggalangan** | | **Amount** |

**Keterangan Saldo Sisa (Remaining Balance Explanation)**

Paragraf teks dari `campaign.remaining_balance_explanation`. Contoh: *"Saldo sisa sebesar Rp X.XXX.XXX akan digunakan untuk fase distribusi berikutnya yang dijadwalkan pada [tanggal]."*

**Ringkasan Bukti (Evidence Summary)**

| Jenis Bukti | Jumlah |
|---|---|
| Kuitansi/invoice | N |
| Laporan kegiatan | N |
| Daftar penerima manfaat | N |
| Foto dokumentasi | N |
| **Total dokumen pendukung** | **N** |

### Footer Section

- Pernyataan akuntabilitas (static): *"Laporan ini disusun dengan penuh tanggung jawab dan dapat dipertanggungjawabkan sesuai catatan keuangan [Nama Organisasi]. Data penerima manfaat telah dianonimkan sesuai ketentuan perlindungan data."*
- Dua kotak tanda tangan:
  - "Disusun oleh" — Fundraising Manager
  - "Diverifikasi oleh" — Finance Manager
- Nomor halaman dan timestamp cetak

### Conditional Elements

- **QR code:** Jika campaign memiliki URL laporan online, tampilkan QR code di pojok kanan bawah halaman 1 dengan label: *"Scan untuk laporan lengkap dengan dokumentasi foto"*
- **Watermark "FINAL":** Hanya jika `campaign.status = 'Closed'`
- **Kalimat pencapaian target:** Jika `total_donations >= target_amount`, muncul banner hijau: *"TARGET TERPENUHI — Terima kasih kepada seluruh donatur!"*

---

## Print Format 7: Ringkasan Pertanggungjawaban Uang Muka (Advance Liquidation Summary)

**Triggered from:** Cash Advance Liquidation  
**Condition:** `workflow_state = 'Approved'` atau `'Closed'`  
**Paper size:** A4  
**Orientation:** Portrait  
**Language:** Bahasa Indonesia

### Header Section

| Element | Source Field | Format | Notes |
|---|---|---|---|
| Logo | `company.company_logo` | Kiri atas | |
| Judul | static | **RINGKASAN PERTANGGUNGJAWABAN UANG MUKA** | Center, bold |
| Nomor advance | `cash_advance.name` | Kanan atas | |
| Nomor liquidation | `liquidation.name` | Kanan atas | |
| Tanggal pertanggungjawaban | `liquidation.submission_date` | Kanan atas | |

### Body Sections

**Informasi Uang Muka (Advance Information)**

| Field Label | Source | Format |
|---|---|---|
| Nama penerima (Recipient) | `cash_advance.employee_name` | String |
| Jabatan | `cash_advance.designation` | String |
| Tanggal pencairan | `cash_advance.payment_date` | `DD MMMM YYYY` |
| Tujuan (Purpose) | `cash_advance.purpose` | String |
| Kegiatan (Activity) | `cash_advance.activity` | String |
| Fund | `cash_advance.fund` | String |
| Budget Line | `cash_advance.budget_line` | String |
| Jumlah uang muka diterima | `cash_advance.amount_paid` | Currency |

**Rincian Pertanggungjawaban (Liquidation Detail)**

| No. | Tanggal | Uraian Pengeluaran | Penerima / Vendor | Jumlah | Status Eligible | Bukti |
|---|---|---|---|---|---|---|
| 1 | DD-MM-YY | Hotel 2 malam | Hotel Melati | Rp X.XXX | Eligible | Kuitansi No. X |
| 2 | DD-MM-YY | Transport | Gojek | Rp X.XXX | Eligible | Screenshot |
| 3 | DD-MM-YY | Makan malam tim | Resto Y | Rp X.XXX | **Ineligible** | — |

**Rekonsiliasi (Reconciliation)**

| Keterangan | Jumlah |
|---|---|
| Uang muka diterima | Rp X.XXX.XXX |
| Total pengeluaran eligible | Rp X.XXX.XXX |
| Total pengeluaran ineligible | Rp X.XXX.XXX |
| **Selisih (Refund / Reimbursement)** | **Rp X.XXX.XXX** |
| Keterangan selisih | "Refund ke organisasi" / "Reimbursement ke staf" |

**Keputusan Finance (Finance Decision)**

| Field | Source |
|---|---|
| Status pertanggungjawaban | `liquidation.status` |
| Catatan Finance | `liquidation.finance_notes` |
| Penanganan ineligible | `liquidation.ineligible_handling` |
| Refund/Reimbursement amount | `liquidation.settlement_amount` |
| Tanggal settlement | `liquidation.settlement_date` |

### Footer Section

- Kotak tanda tangan:
  - "Yang Mempertanggungjawabkan" — Nama staf + tanda tangan + tanggal
  - "Diperiksa oleh" — Finance Officer + tanda tangan + tanggal
  - "Disetujui oleh" — Finance Manager + tanda tangan + tanggal (jika required)
- Catatan (static): *"Dokumen pertanggungjawaban ini berserta seluruh bukti pendukung disimpan sebagai arsip keuangan organisasi."*
- Nomor halaman dan timestamp cetak

### Conditional Elements

- **Baris Ineligible:** Dicetak dengan background merah muda dan teks "TIDAK ELIGIBLE" di kolom status
- **Kotak refund:** Muncul dengan border merah jika `refund_amount > 0`: *"Staf wajib mengembalikan Rp [refund_amount] ke kas organisasi selambat-lambatnya [settlement_deadline]."*
- **Kotak reimbursement:** Muncul dengan border hijau jika `reimbursement_amount > 0`: *"Organisasi akan mengganti kelebihan pengeluaran sebesar Rp [reimbursement_amount] kepada staf."*
- **Watermark "OVERDUE":** Jika liquidation disubmit setelah `liquidation_due_date`
- **Multi-currency:** Jika transaksi dalam currency asing, tampilkan kolom tambahan "Jumlah (IDR)" dengan konversi historis
