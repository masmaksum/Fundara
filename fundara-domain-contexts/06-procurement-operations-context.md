# Procurement & Operations Context

## 1. Ringkasan

**Procurement & Operations Context** adalah domain yang mengelola kebutuhan operasional organisasi: pembelian barang/jasa, vendor, quotation, purchase order, penerimaan barang/jasa, asset, inventory, travel, vehicle, dan kebutuhan logistik lainnya.

Dalam organisasi misi sosial, procurement bukan hanya proses membeli barang. Procurement adalah bagian dari akuntabilitas fund. Banyak donor dan campaign restricted memiliki aturan khusus tentang threshold pembelian, jumlah quotation, vendor eligibility, conflict of interest, dan dokumen pendukung.

Context ini menghubungkan kebutuhan lapangan dengan kontrol fund, budget, compliance, dan evidence.

---

## 2. Tujuan Context

Procurement & Operations Context bertujuan untuk:

1. Mengelola permintaan pembelian dan kebutuhan operasional.
2. Memastikan procurement mengikuti aturan fund, donor, dan organisasi.
3. Menghubungkan purchase request dengan fund, project, activity, dan budget line.
4. Mengelola vendor, quotation, bid analysis, purchase order, dan invoice.
5. Mendukung asset, inventory, travel, vehicle, dan logistics request.
6. Menyediakan audit trail procurement.

---

## 3. Pertanyaan Domain yang Dijawab

Context ini harus mampu menjawab:

- Barang atau jasa apa yang dibutuhkan?
- Activity atau project mana yang membutuhkan?
- Fund mana yang akan membiayai?
- Budget line apa yang dikonsumsi?
- Apakah procurement method sesuai threshold?
- Apakah quotation wajib?
- Vendor mana yang dipilih dan mengapa?
- Apakah barang/jasa sudah diterima?
- Apakah invoice sudah dibayar?
- Apakah asset atau inventory perlu dicatat?
- Apakah dokumen procurement lengkap untuk audit?

---

## 4. Entitas Utama

### 4.1 Purchase Request

Permintaan pembelian barang atau jasa.

Atribut konseptual:

- purchase request number
- requester
- project
- activity
- fund
- budget line
- item/service description
- estimated amount
- required date
- purpose
- status

Status:

```text
Draft → Submitted → Budget Checked → Approved → Procurement Processing → Closed
```

---

### 4.2 Supplier / Vendor

Penyedia barang atau jasa.

Atribut konseptual:

- vendor name
- vendor type
- contact
- tax number
- bank account
- due diligence status
- conflict of interest declaration
- active status

---

### 4.3 Quotation

Penawaran harga dari vendor.

Atribut konseptual:

- quotation number
- vendor
- purchase request
- amount
- currency
- validity date
- attachment
- evaluation status

---

### 4.4 Bid Analysis

Analisis perbandingan quotation.

Atribut konseptual:

- bid analysis number
- purchase request
- quotations compared
- selected vendor
- selection reason
- committee members
- approval status

---

### 4.5 Purchase Order

Pesanan resmi kepada vendor.

Atribut konseptual:

- purchase order number
- vendor
- purchase request
- fund
- project
- activity
- budget line
- amount
- delivery date
- status

---

### 4.6 Goods Receipt / Service Acceptance

Konfirmasi bahwa barang diterima atau jasa selesai.

Atribut konseptual:

- receipt number
- purchase order
- received by
- received date
- quantity / service confirmation
- acceptance note
- attachment
- status

---

### 4.7 Purchase Invoice

Tagihan dari vendor.

Atribut konseptual:

- invoice number
- vendor
- purchase order
- receipt reference
- invoice date
- amount
- tax
- payment status

---

### 4.8 Asset

Barang bernilai jangka panjang yang harus dicatat sebagai aset.

Atribut konseptual:

- asset name
- asset code
- fund
- project
- purchase reference
- assigned to
- location
- acquisition date
- value
- status

---

### 4.9 Inventory Item

Barang stok atau barang distribusi.

Atribut konseptual:

- item name
- item code
- item group
- unit of measure
- warehouse
- stock balance
- expiry date, jika relevan

---

### 4.10 Travel Request

Permintaan perjalanan untuk activity atau project.

Atribut konseptual:

- travel request number
- traveler
- project
- activity
- fund
- destination
- travel dates
- estimated cost
- approval status

---

### 4.11 Vehicle Request

Permintaan penggunaan kendaraan.

Atribut konseptual:

- vehicle request number
- requester
- project/activity
- destination
- date
- vehicle
- driver
- approval status

---

## 5. Relasi Antar Entitas

```text
Activity
 ├── creates Purchase Request
 ├── creates Travel Request
 └── creates Vehicle Request

Purchase Request
 ├── uses Fund
 ├── consumes Budget Line
 ├── follows Procurement Rule
 ├── may require Quotation
 ├── may create Bid Analysis
 ├── may create Purchase Order
 └── creates Commitment

Purchase Order
 ├── linked to Vendor
 ├── creates Commitment
 ├── followed by Goods Receipt
 ├── followed by Purchase Invoice
 └── becomes Actual Expense

Purchase Invoice
 └── paid by Payment
```

---

## 6. Batasan Context

Procurement & Operations Context menangani:

- purchase request
- vendor
- quotation
- bid analysis
- purchase order
- goods receipt
- purchase invoice
- asset
- inventory
- travel request
- vehicle request

Context ini tidak menangani:

- donor relationship detail
- fund balance calculation detail
- accounting posting detail
- impact measurement
- report generation detail

---

## 7. Workflow Utama

### 7.1 Purchase Request

```text
Create Purchase Request
→ Link to Project / Activity
→ Select Fund and Budget Line
→ Enter Estimated Amount
→ Budget Availability Check
→ Fund Restriction Check
→ Submit for Approval
→ Approve Request
→ Send to Procurement
```

### 7.2 Quotation and Bid Analysis

```text
Approved Purchase Request
→ Determine Procurement Method
→ Request Quotation from Vendors
→ Receive Quotations
→ Compare Quotations
→ Prepare Bid Analysis
→ Select Vendor
→ Approve Selection
```

### 7.3 Purchase Order to Payment

```text
Create Purchase Order
→ Vendor Confirms
→ Goods / Service Delivered
→ Record Receipt / Acceptance
→ Receive Invoice
→ Verify Documents
→ Approve Invoice
→ Create Payment
→ Close Purchase Cycle
```

### 7.4 Asset Registration

```text
Purchase Item Marked as Asset
→ Goods Received
→ Register Asset
→ Assign Asset Code
→ Assign Location / Custodian
→ Link Asset to Fund and Project
→ Activate Asset Record
```

### 7.5 Inventory Movement

```text
Goods Received into Warehouse
→ Update Stock Balance
→ Issue Stock to Activity / Distribution
→ Record Recipient / Location
→ Attach Evidence if Required
→ Update Inventory Report
```

---

## 8. Aturan Bisnis

1. Purchase request harus memiliki fund dan budget line.
2. Purchase request untuk activity harus memiliki activity reference.
3. Procurement method ditentukan oleh amount, fund rule, dan organization policy.
4. Jika threshold mewajibkan quotation, purchase order tidak boleh dibuat tanpa quotation.
5. Vendor dengan due diligence gagal tidak boleh dipakai kecuali ada exception.
6. Bid analysis wajib jika jumlah quotation lebih dari satu dan threshold terpenuhi.
7. Purchase order menciptakan commitment.
8. Purchase invoice mengubah commitment menjadi actual expense.
9. Barang yang memenuhi kriteria asset harus masuk asset register.
10. Barang stok harus masuk warehouse sebelum didistribusikan.
11. Semua dokumen procurement harus dapat masuk audit pack.

---

## 9. Integrasi dengan Context Lain

| Context | Hubungan |
|---|---|
| Mission Delivery Context | Activity memicu purchase, travel, dan logistics request |
| Fund Stewardship Context | Procurement memakai fund dan mengikuti restriction |
| Financial Accountability Context | Purchase order menjadi commitment, invoice menjadi expense |
| Evidence & Compliance Context | Procurement membutuhkan quotation, bid analysis, receipt, invoice, dan approval evidence |
| Organization Context | Approval mengikuti delegation of authority |
| Reporting Context | Procurement tracker dan asset report memakai data context ini |

---

## 10. Implementasi di ERPNext/Frappe

Komponen ERPNext/Frappe yang relevan:

- Supplier
- Item
- Material Request
- Request for Quotation
- Supplier Quotation
- Purchase Order
- Purchase Receipt
- Purchase Invoice
- Asset
- Stock Entry
- Warehouse
- Workflow

Custom DocType yang mungkin dibutuhkan:

- Procurement Threshold Rule
- Bid Analysis
- Conflict of Interest Declaration
- Vendor Due Diligence
- Service Acceptance Note
- Travel Request
- Vehicle Request
- Logistics Request
- Distribution Record

---

## 11. MVP Scope

Untuk MVP, context ini cukup mencakup:

- Purchase Request
- Supplier
- Quotation sederhana
- Bid Analysis sederhana
- Purchase Order
- Goods/Service Receipt
- Purchase Invoice link
- Procurement Threshold Rule

Belum perlu:

- full e-procurement portal
- vendor self-service portal
- advanced inventory distribution
- fleet management lengkap
- asset depreciation customization

---

## 12. Risiko Desain

Risiko yang perlu dihindari:

1. Procurement berdiri sendiri tanpa fund dan activity context.
2. Tidak membedakan request, commitment, dan actual expense.
3. Tidak menghubungkan procurement dengan evidence requirement.
4. Threshold rule hardcoded, tidak configurable.
5. Vendor due diligence diabaikan.
6. Barang distribusi tidak terlacak sampai activity atau penerima.
7. Asset yang dibeli dari grant tidak bisa dilaporkan ke donor.

---

## 13. Prinsip Desain

Procurement & Operations Context harus mengikuti prinsip:

> Operasi yang baik adalah operasi yang membantu kerja lapangan sekaligus menjaga amanah dana.

Fundara harus membuat procurement cukup tertib untuk akuntabilitas, tetapi tidak terlalu birokratis sehingga menghambat respon cepat organisasi misi sosial.
