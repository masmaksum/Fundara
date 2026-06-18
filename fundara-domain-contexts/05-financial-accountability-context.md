# Financial Accountability Context

## 1. Ringkasan

**Financial Accountability Context** adalah domain Fundara yang mengelola bagaimana dana digunakan, dicatat, dikontrol, direkonsiliasi, dilaporkan, dan dipertanggungjawabkan sesuai konteks organisasi misi sosial.

Context ini bukan sekadar general ledger. Accounting mencatat debit dan kredit, sedangkan Financial Accountability memastikan setiap transaksi memiliki konteks misi: dana dari mana, untuk program atau activity apa, memakai budget line apa, berada dalam batasan dana apa, disetujui siapa, buktinya apa, status rekonsiliasi bagaimana, dan apakah siap masuk laporan donor, laporan manajemen, laporan audit, maupun laporan keuangan nirlaba.

Dalam Fundara, transaksi keuangan harus menjadi jembatan antara **Fund Stewardship**, **Mission Delivery**, **Evidence & Compliance**, dan **Reporting**.

Prinsip utamanya:

> Simple input, proper accounting, fund-aware reporting.

Artinya, pengguna dapat mencatat penerimaan dan pengeluaran melalui form yang sederhana, tetapi sistem tetap menghasilkan pencatatan double-entry, audit trail, fund balance, donor report, dan laporan keuangan nirlaba yang benar.

---

## 2. Tujuan Context

Financial Accountability Context bertujuan untuk:

1. Mendukung pelaporan keuangan nirlaba berbasis **ISAK 35** untuk konteks Indonesia.
2. Mengadopsi prinsip konseptual **FASB ASC 958 / ASU 2016-14** untuk klasifikasi aset neto dan pelaporan not-for-profit secara global.
3. Menyediakan template Chart of Account yang sesuai dengan organisasi nirlaba.
4. Mengelola budget program, project, grant, campaign, business unit, dan activity.
5. Mengelola penerimaan kas/bank dan pengeluaran kas/bank dengan antarmuka sederhana tetapi tetap menghasilkan double-entry accounting.
6. Mengelola jurnal umum, jurnal penyesuaian, jurnal alokasi, jurnal depresiasi, dan jurnal pelepasan pembatasan dana.
7. Mengelola uang muka, pembayaran tambahan, pertanggungjawaban, refund, reimbursement, dan aging uang muka.
8. Mengelola fixed asset dan depresiasi bulanan.
9. Mengelola rekonsiliasi bank melalui import statement, auto-match, manual match, dan reconciliation report.
10. Menghasilkan laporan per donor, per fund, per project, per campaign, dan per business unit.
11. Menyediakan opening balance assistant dan balance otomatis per fund, donor, restriction class, dan aset neto.
12. Menyediakan data health check untuk memeriksa sinkronisasi data, transaksi tanpa dimensi, evidence tidak lengkap, transaksi tidak balance, dan fund balance bermasalah.
13. Mendukung import anggaran/transaksi dari Excel serta export laporan ke Excel, CSV, PDF, dan format dokumen lain.
14. Menyediakan grafik dan dashboard finansial untuk monitoring keputusan.
15. Mendukung dual bahasa Indonesia dan Inggris pada interface, label, status, workflow, dan laporan standar.

---

## 3. Accounting Standards Position

Fundara perlu memiliki posisi standar akuntansi yang jelas.

### 3.1 ISAK 35 sebagai standar utama Indonesia

Untuk organisasi nirlaba di Indonesia, Fundara mengacu pada **ISAK 35: Penyajian Laporan Keuangan Entitas Berorientasi Nonlaba**. ISAK 35 membantu entitas nonlaba menyesuaikan deskripsi pos dan deskripsi laporan keuangan agar sesuai dengan karakteristik organisasi nonlaba.

Implikasi desain Fundara:

- istilah **aset neto** digunakan sebagai pengganti narasi ekuitas;
- laporan keuangan mendukung pemisahan aset neto dengan pembatasan dan tanpa pembatasan;
- format laporan disiapkan untuk yayasan, NGO, komunitas, lembaga sosial, lembaga pendidikan, lembaga keagamaan, dan organisasi misi sosial lain;
- Fundara menyediakan template laporan utama nirlaba.

Laporan utama yang perlu didukung:

```text
Laporan Posisi Keuangan
Laporan Penghasilan Komprehensif / Laporan Aktivitas
Laporan Perubahan Aset Neto
Laporan Arus Kas
Catatan atas Laporan Keuangan
```

### 3.2 FASB ASC 958 / ASU 2016-14 sebagai rujukan konseptual global

Fundara juga mengadopsi prinsip konseptual dari FASB ASC 958 dan ASU 2016-14 untuk organisasi not-for-profit, terutama klasifikasi:

```text
Net Assets With Donor Restrictions
Net Assets Without Donor Restrictions
```

Pemetaan ke Fundara:

| FASB / ASC 958 | Fundara |
|---|---|
| Net assets with donor restrictions | Aset Neto Dengan Pembatasan |
| Net assets without donor restrictions | Aset Neto Tanpa Pembatasan |
| Donor restriction | Fund Restriction |
| Release from restriction | Pelepasan Pembatasan Dana |
| Statement of activities | Laporan Aktivitas / Penghasilan Komprehensif |
| Statement of financial position | Laporan Posisi Keuangan |

### 3.3 Standards-aware, bukan standards-locked

Fundara harus standards-aware tetapi tidak standards-locked.

Artinya:

- Fundara menyediakan template ISAK 35 untuk Indonesia;
- Fundara mendukung pola klasifikasi FASB untuk deployment global;
- organisasi dapat menyesuaikan nama laporan, account, dan mapping sesuai regulasi lokal;
- accounting standard profile dapat dikonfigurasi per organisasi.

---

## 4. Pertanyaan Domain yang Dijawab

Context ini harus mampu menjawab:

- Transaksi ini memakai fund apa?
- Sumber dana berasal dari donor, campaign, unit usaha, atau unrestricted fund?
- Transaksi ini termasuk aset neto dengan pembatasan atau tanpa pembatasan?
- Project dan activity mana yang menerima biaya ini?
- Budget line apa yang dikonsumsi?
- Apakah budget masih tersedia?
- Apakah transaksi ini masih commitment atau sudah actual?
- Apakah transaksi sudah dibayar?
- Apakah transaksi sudah direkonsiliasi dengan bank?
- Apakah bukti transaksi lengkap?
- Apakah advance sudah dilikuidasi?
- Apakah asset yang dibeli dari donor tertentu sudah tercatat?
- Apakah depresiasi bulanan sudah dijalankan?
- Apakah transaksi siap masuk laporan donor?
- Apakah laporan utama ISAK 35 dapat dihasilkan?
- Apakah saldo awal sudah seimbang per fund dan per donor?
- Apakah ada data yang tidak sinkron sebelum audit atau donor reporting?

---

## 5. Subdomain dalam Financial Accountability Context

Financial Accountability Context terdiri dari subdomain berikut:

```text
Financial Accountability Context
├── Accounting Standards
├── Chart of Accounts
├── Cash & Bank
├── General Journal
├── Budgeting
├── Advance & Liquidation
├── Donor Reporting
├── Fixed Assets
├── Depreciation
├── Bank Reconciliation
├── Opening Balance
├── Data Health Check
├── Import / Export
├── Financial Dashboard
└── Localization
```

Untuk tahap awal, seluruh subdomain ini tetap berada di bawah Financial Accountability Context. Pada fase berikutnya, beberapa subdomain dapat dipisahkan menjadi context tersendiri, misalnya Asset Management Context, Localization Context, atau Data Quality Context.

---

## 6. Entitas Utama

### 6.1 Accounting Standard Profile

Profil standar akuntansi yang digunakan organisasi.

Atribut konseptual:

- profile name
- country
- reporting framework
- default net asset classification
- default report templates
- fiscal year rule
- currency policy
- status

Contoh profile:

- Indonesia - ISAK 35
- Global NFP - FASB ASC 958 Inspired
- Custom NGO Reporting

---

### 6.2 Chart of Account Template

Template CoA bawaan untuk organisasi nirlaba.

Prinsip:

> CoA harus stabil dan generik. Donor, project, campaign, fund, activity, dan budget line tidak dimasukkan sebagai account, tetapi dikelola sebagai dimensi.

Contoh struktur CoA:

```text
Aset
├── Kas dan Setara Kas
├── Piutang
├── Uang Muka
├── Persediaan
├── Aset Tetap
└── Aset Lainnya

Liabilitas
├── Utang Usaha
├── Utang Pajak
├── Utang Gaji
├── Dana Diterima di Muka
└── Liabilitas Lainnya

Aset Neto
├── Aset Neto Tanpa Pembatasan
├── Aset Neto Dengan Pembatasan
└── Aset Neto Ditetapkan Pengurus

Pendapatan
├── Pendapatan Grant
├── Pendapatan Donasi
├── Pendapatan Fundraising Campaign
├── Pendapatan Unit Usaha
├── Pendapatan Jasa
└── Pendapatan Lainnya

Beban
├── Beban Program
├── Beban Personalia
├── Beban Kegiatan
├── Beban Perjalanan
├── Beban Pengadaan
├── Beban Fundraising
├── Beban Administrasi dan Umum
├── Beban Unit Usaha
└── Beban Penyusutan
```

---

### 6.3 Account

Akun akuntansi untuk pencatatan double-entry.

Atribut konseptual:

- account code
- account name
- account type
- parent account
- normal balance
- report group
- active status

---

### 6.4 Net Asset Class

Klasifikasi aset neto.

Jenis awal:

```text
Aset Neto Tanpa Pembatasan
Aset Neto Dengan Pembatasan
Aset Neto Ditetapkan Pengurus / Board-designated
```

Net Asset Class harus terhubung dengan Fund Restriction.

---

### 6.5 Budget

Budget adalah rencana penggunaan dana.

Jenis budget:

- organizational budget
- program budget
- project budget
- grant budget
- campaign utilization budget
- business unit budget
- activity budget

Atribut konseptual:

- budget name
- budget type
- fund
- project
- period
- currency
- total amount
- status

---

### 6.6 Budget Line

Budget Line adalah kategori anggaran yang dipakai untuk kontrol dan pelaporan.

Contoh:

- Personnel
- Training
- Travel
- Equipment
- Sub-grant
- Monitoring & Evaluation
- Indirect Cost
- Program Supplies
- Distribution Cost

Budget line tidak harus sama dengan Chart of Accounts.

Atribut konseptual:

- budget line name
- budget code
- parent budget line
- allowed accounts
- allowed cost category
- fund restriction
- donor report category
- status

---

### 6.7 Cash Receipt / Bank Receipt

Transaksi penerimaan kas atau bank dengan UI single-entry.

Atribut konseptual:

- receipt number
- receipt date
- cash/bank account
- source type
- fund
- donor/campaign/business unit
- amount
- currency
- receipt category
- reference number
- evidence
- posting status

Contoh posting otomatis:

```text
Dr Bank
    Cr Pendapatan Donasi
```

Untuk grant yang dicatat sebagai dana diterima di muka:

```text
Dr Bank
    Cr Dana Diterima di Muka
```

---

### 6.8 Cash Disbursement / Bank Disbursement

Transaksi pengeluaran kas atau bank dengan UI single-entry.

Atribut konseptual:

- disbursement number
- disbursement date
- cash/bank account
- payee
- fund
- project
- activity
- budget line
- expense account
- amount
- evidence
- approval status
- posting status

Contoh posting otomatis:

```text
Dr Beban Program / Aset / Uang Muka
    Cr Bank / Kas
```

---

### 6.9 General Journal

Jurnal umum untuk transaksi non-kas/bank.

Jenis jurnal:

- Adjustment Journal
- Accrual Journal
- Allocation Journal
- Correction Journal
- Depreciation Journal
- Opening Balance Journal
- Fund Transfer Journal
- Restriction Release Journal

Prinsip:

> Jurnal umum boleh digunakan, tetapi tetap wajib membawa dimensi fund, cost center, project, dan alasan penyesuaian bila relevan.

---

### 6.10 Commitment

Commitment adalah biaya yang sudah dijanjikan atau diikat, tetapi belum menjadi actual expense.

Contoh:

- approved purchase request
- purchase order
- signed contract
- approved travel request
- approved cash advance request, tergantung kebijakan

---

### 6.11 Expense

Expense adalah biaya aktual yang sudah terjadi.

Atribut konseptual:

- expense number
- fund
- project
- activity
- budget line
- account
- cost center
- amount
- currency
- expense date
- vendor/staff
- evidence status
- approval status

---

### 6.12 Payment

Payment adalah pembayaran kas atau bank.

Atribut konseptual:

- payment number
- payment date
- payee
- amount
- bank/cash account
- linked expense/invoice/advance
- payment method
- reconciliation status

---

### 6.13 Cash Advance

Cash Advance adalah uang muka yang diberikan kepada staff atau tim untuk activity tertentu.

Atribut konseptual:

- advance number
- requester
- fund
- project
- activity
- budget line
- amount requested
- amount approved
- purpose
- due date for liquidation
- aging status
- status

Status cash advance:

```text
Requested → Approved → Paid → Pending Liquidation → Liquidation Submitted → Reviewed → Closed
```

---

### 6.14 Additional Advance Payment

Pembayaran tambahan untuk advance jika realisasi kebutuhan lebih besar dari advance awal dan disetujui.

---

### 6.15 Liquidation

Liquidation adalah pertanggungjawaban penggunaan cash advance.

Atribut konseptual:

- liquidation number
- cash advance
- actual expense amount
- receipts
- refund amount
- reimbursement amount
- review status
- finance approval

---

### 6.16 Reimbursement

Reimbursement adalah penggantian biaya yang sudah dibayar terlebih dahulu oleh staff.

---

### 6.17 Fixed Asset

Fixed Asset adalah aset tetap yang dimiliki organisasi.

Atribut konseptual:

- asset code
- asset name
- asset category
- acquisition date
- acquisition cost
- funding source
- fund
- donor
- project
- location
- custodian
- useful life
- depreciation method
- residual value
- status
- evidence

Prinsip NGO:

> Aset perlu tahu dibeli dari dana siapa.

---

### 6.18 Depreciation Schedule

Jadwal depresiasi bulanan untuk fixed asset.

Atribut konseptual:

- asset
- depreciation month
- depreciation amount
- accumulated depreciation
- book value
- posting status

Contoh jurnal:

```text
Dr Beban Penyusutan
    Cr Akumulasi Penyusutan
```

Fundara perlu membedakan:

```text
Accounting Depreciation
Donor Reporting Treatment
```

Karena donor tertentu mungkin mengakui pembelian aset sebagai biaya langsung, bukan depresiasi.

---

### 6.19 Bank Statement

Data mutasi bank yang diimpor.

Atribut konseptual:

- bank account
- statement period
- transaction date
- description
- debit
- credit
- reference number
- import batch
- matching status

---

### 6.20 Bank Reconciliation

Proses mencocokkan transaksi Fundara dengan mutasi bank.

Status:

```text
Recorded
Matched
Unmatched
Partially Matched
Reconciled
Exception
```

---

### 6.21 Opening Balance

Saldo awal organisasi ketika mulai menggunakan Fundara.

Atribut konseptual:

- fiscal year
- account
- fund
- donor
- restriction class
- project, jika relevan
- opening debit
- opening credit
- validation status

---

### 6.22 Data Health Check

Pemeriksaan kualitas dan sinkronisasi data.

Contoh check:

- transaksi tanpa fund;
- transaksi tanpa budget line;
- expense tanpa evidence wajib;
- advance overdue;
- jurnal tidak balance;
- fund balance negatif;
- transaksi donor tanpa reporting period;
- asset tanpa depreciation schedule;
- bank transaction unreconciled.

---

### 6.23 Import Batch

Batch import data dari Excel/CSV.

Atribut konseptual:

- import type
- uploaded file
- mapping configuration
- validation result
- error count
- created records
- import log

---

### 6.24 Export Template

Template export laporan.

Format yang ditargetkan:

```text
Excel
CSV
PDF
Word / DOCX
```

Untuk MVP, minimal:

```text
CSV / XLSX import
CSV / XLSX / PDF export
```

---

### 6.25 Language Pack

Paket bahasa untuk UI dan laporan standar.

Bahasa awal:

```text
Indonesia
English
```

Fundara menerjemahkan label sistem, bukan menerjemahkan data input user.

---

## 7. Relasi Antar Entitas

```text
Accounting Standard Profile
 ├── defines Chart of Account Template
 ├── defines Net Asset Class
 └── defines Report Template

Fund
 ├── has Budget
 ├── has Commitment
 ├── has Expense
 ├── has Payment
 ├── has Opening Balance
 └── has Fund Balance

Budget
 └── contains Budget Line

Budget Line
 ├── maps to Account
 ├── receives Allocation
 ├── consumed by Commitment
 └── consumed by Expense

Cash / Bank Account
 ├── receives Cash Receipt / Bank Receipt
 ├── pays Cash Disbursement / Bank Disbursement
 └── reconciled with Bank Statement

Activity
 ├── creates Commitment
 ├── creates Expense
 ├── requests Cash Advance
 └── receives Liquidation

Cash Advance
 ├── linked to Activity
 ├── paid by Payment
 ├── may receive Additional Advance Payment
 └── closed by Liquidation

Fixed Asset
 ├── acquired from Fund
 ├── assigned to Location / Custodian
 └── depreciated through Depreciation Schedule

Data Health Check
 ├── scans Transaction
 ├── scans Budget
 ├── scans Fund Balance
 ├── scans Evidence
 └── creates Correction Task
```

---

## 8. Batasan Context

Financial Accountability Context menangani:

- accounting standard profile;
- chart of accounts;
- net asset classification;
- budget dan budget line;
- cash/bank receipt;
- cash/bank disbursement;
- general journal;
- commitment;
- expense;
- payment;
- advance;
- liquidation;
- reimbursement;
- fixed asset;
- depreciation;
- bank reconciliation;
- opening balance;
- donor financial reporting;
- import/export;
- data health check;
- financial dashboard;
- localization finansial.

Context ini tidak menangani secara detail:

- vendor selection dan procurement committee detail;
- donor relationship management;
- public campaign communication;
- impact methodology;
- evidence requirement definition, meskipun memakai evidence status;
- tax compliance detail yang sangat spesifik per negara, kecuali sebagai extension.

---

## 9. Workflow Utama

### 9.1 Budget Approval

```text
Draft Budget
→ Add Budget Lines
→ Link to Fund / Project
→ Review by Program
→ Review by Finance
→ Approve Budget
→ Activate Budget
```

### 9.2 Cash / Bank Receipt

```text
Create Receipt
→ Select Cash/Bank Account
→ Select Funding Source / Fund
→ Enter Amount and Category
→ Attach Evidence
→ Validate Accounting Mapping
→ Submit
→ Auto-create Double Entry
→ Update Fund Balance
```

### 9.3 Cash / Bank Disbursement

```text
Create Disbursement
→ Select Cash/Bank Account
→ Select Payee
→ Select Fund / Project / Activity / Budget Line
→ Check Budget Availability
→ Check Evidence Requirement
→ Submit for Approval
→ Approve
→ Auto-create Double Entry
→ Update Budget Actual / Advance / Asset
```

### 9.4 General Journal

```text
Create Journal
→ Select Journal Type
→ Enter Debit/Credit Lines
→ Add Fund / Cost Center / Project Dimensions
→ Validate Balance
→ Add Adjustment Reason
→ Submit for Approval
→ Post Journal
```

### 9.5 Expense Request

```text
Create Expense Request
→ Select Fund
→ Select Project / Activity
→ Select Budget Line
→ Enter Amount and Purpose
→ Check Budget Availability
→ Check Fund Restriction
→ Submit for Approval
→ Approve Request
→ Create Commitment or Expense
```

### 9.6 Cash Advance

```text
Request Cash Advance
→ Link to Activity
→ Select Fund and Budget Line
→ Check Budget Availability
→ Supervisor Approval
→ Finance Approval
→ Payment Released
→ Pending Liquidation
```

### 9.7 Liquidation

```text
Submit Liquidation
→ Upload Receipts and Evidence
→ Compare Advance vs Actual
→ Calculate Refund or Reimbursement
→ Finance Review
→ Approve Liquidation
→ Post Actual Expense
→ Close Advance
```

### 9.8 Fixed Asset Acquisition

```text
Purchase / Receive Asset
→ Link Asset to Fund / Donor / Project
→ Register Fixed Asset
→ Assign Location and Custodian
→ Generate Depreciation Schedule
→ Attach Acquisition Evidence
```

### 9.9 Monthly Depreciation

```text
Run Monthly Depreciation
→ Select Accounting Period
→ Generate Depreciation Entries
→ Review Exceptions
→ Post Depreciation Journal
→ Update Asset Book Value
```

### 9.10 Bank Reconciliation

```text
Import Bank Statement
→ Auto-match Transactions
→ Review Unmatched Items
→ Create Missing Transaction / Manual Match
→ Confirm Reconciliation
→ Generate Bank Reconciliation Report
```

### 9.11 Opening Balance Assistant

```text
Input Opening Account Balances
→ Input Fund / Donor Balances
→ Validate Assets and Liabilities
→ Calculate Net Assets
→ Allocate Net Assets by Restriction
→ Validate Per Fund Balance
→ Generate Opening Balance Journal
```

### 9.12 Data Health Check

```text
Run Data Health Check
→ Scan Accounting Data
→ Scan Fund Dimensions
→ Scan Evidence Completeness
→ Scan Budget Consistency
→ Show Issues
→ Open Related Document
→ Fix Issue
→ Re-run Check
```

### 9.13 Import Data

```text
Upload File
→ Map Columns
→ Validate Data
→ Preview Errors
→ Fix / Re-upload
→ Confirm Import
→ Create Records
→ Generate Import Log
```

---

## 10. Aturan Bisnis

1. Setiap expense harus memiliki fund.
2. Setiap project expense harus memiliki project.
3. Setiap activity expense harus memiliki activity.
4. Setiap expense harus memiliki budget line.
5. Sistem harus mengecek budget availability sebelum approval.
6. Commitment harus mengurangi available budget.
7. Actual expense tidak boleh double count dengan commitment yang sudah dikonversi.
8. Cash advance harus memiliki due date liquidation.
9. Cash advance yang overdue harus muncul di dashboard finance.
10. Liquidation tidak boleh ditutup tanpa bukti minimum.
11. Payment harus terhubung ke dokumen sumber.
12. Budget revision harus menyimpan histori.
13. Transaksi yang sudah posted tidak boleh diubah tanpa reversal atau correction entry.
14. Penerimaan dan pengeluaran kas/bank dapat diinput sederhana, tetapi posting accounting harus tetap double-entry.
15. Jurnal umum harus balance sebelum diposting.
16. Jurnal umum yang menyentuh fund harus membawa dimensi fund.
17. Transaksi donor-funded harus memiliki reporting period bila donor report period aktif.
18. Fixed asset harus memiliki funding source, lokasi, custodian, dan depreciation policy.
19. Depresiasi bulanan harus dijalankan berdasarkan accounting period.
20. Bank reconciliation tidak boleh menutup periode jika masih ada exception material, kecuali diberi approval khusus.
21. Opening balance harus seimbang antara aset, liabilitas, dan aset neto.
22. Saldo awal fund restricted harus dapat ditelusuri per fund/donor.
23. Import data harus divalidasi sebelum membuat record permanen.
24. Export laporan harus menjaga format angka, periode, currency, dan dimensi.
25. Dual bahasa hanya menerjemahkan UI dan template sistem, bukan data input user.

---

## 11. Laporan yang Dihasilkan

### 11.1 Laporan Utama ISAK 35

```text
Laporan Posisi Keuangan
Laporan Penghasilan Komprehensif / Laporan Aktivitas
Laporan Perubahan Aset Neto
Laporan Arus Kas
Catatan atas Laporan Keuangan
```

### 11.2 Laporan Management dan Fund

```text
Fund Utilization Report
Budget vs Actual Report
Fund Balance Report
Restricted vs Unrestricted Net Assets Report
Program Expense Report
Project Expense Report
Cash Position Report
Advance Aging Report
Bank Reconciliation Report
Fixed Asset Register
Depreciation Report
Data Health Report
```

### 11.3 Laporan Per Donor

```text
Donor Fund Utilization Report
Budget vs Actual per Donor
Expenditure by Donor Budget Line
Advance Outstanding per Donor
Procurement List per Donor
Asset Purchased by Donor Fund
Supporting Document Register
Variance Explanation
Donor Report Submission Status
```

Prinsip:

> Setiap angka di laporan donor harus bisa di-drill down sampai transaksi dan bukti.

---

## 12. Dashboard dan Grafik

Dashboard utama:

```text
Fund Balance Dashboard
Budget vs Actual Dashboard
Donor Utilization Dashboard
Advance Aging Dashboard
Cash Position Dashboard
Bank Reconciliation Dashboard
Grant Burn Rate Dashboard
Program Expense Dashboard
Asset Dashboard
Data Health Dashboard
```

Contoh grafik:

- budget vs actual per project;
- fund utilization per donor;
- cash balance trend;
- advance aging by staff;
- spending by budget line;
- restricted vs unrestricted net assets;
- monthly income and expense;
- program vs admin expense ratio;
- burn rate vs time elapsed.

---

## 13. Integrasi dengan Context Lain

| Context | Hubungan |
|---|---|
| Fund Stewardship Context | Transaksi mengonsumsi fund, memperbarui fund balance, dan mengikuti fund restriction |
| Mission Delivery Context | Activity menghasilkan request, expense, advance, liquidation, dan evidence |
| Procurement & Operations Context | Purchase order menghasilkan commitment; invoice menjadi actual expense; asset purchase masuk fixed asset |
| Evidence & Compliance Context | Expense, advance, procurement, dan asset membutuhkan evidence dan compliance check |
| Reporting Context | Transaksi menjadi sumber laporan keuangan, donor report, campaign report, fund utilization, dan audit pack |
| Organization Context | Approval mengikuti role, delegation of authority, office, department, dan cost center |
| Funding Context | Donor, campaign, dan business unit menjadi sumber penerimaan dan fund balance |
| Impact & Learning Context | Biaya program dapat dikaitkan dengan output, outcome, dan cost per output |

---

## 14. Implementasi di ERPNext/Frappe

Komponen ERPNext/Frappe yang relevan:

- Company
- Fiscal Year
- Account
- Cost Center
- Accounting Dimension
- Journal Entry
- Payment Entry
- Purchase Invoice
- Sales Invoice, untuk unit usaha
- Expense Claim
- Employee Advance
- Asset
- Asset Category
- Depreciation Schedule
- Bank Reconciliation
- Budget
- Workflow
- Report Builder / Query Report / Script Report
- Print Format
- Translation

Custom DocType yang mungkin dibutuhkan:

```text
Accounting Standard Profile
Fund Budget
Fund Budget Line
Commitment Register
Cash Receipt
Bank Receipt
Cash Disbursement
Bank Disbursement
Cash Advance
Additional Advance Payment
Liquidation
Reimbursement Request
Budget Availability Check
Budget Exception
Journal Allocation Rule
Opening Balance Assistant
Net Asset Class
Restriction Release Entry
Donor Financial Report
Bank Statement Import
Bank Reconciliation Review
Data Health Check
Import Batch
Export Template
Language Pack
```

Catatan implementasi:

- Gunakan ERPNext GL Entry sebagai sumber kebenaran accounting.
- Gunakan Accounting Dimension untuk fund, project, activity, budget line, donor/campaign/business unit bila relevan.
- Jangan membuat donor dan project sebagai account di CoA.
- Buat form kas/bank sederhana yang mem-posting Journal Entry/Payment Entry di belakang layar.
- Gunakan custom report untuk ISAK 35 dan donor reporting.

---

## 15. MVP Scope

Untuk MVP, context ini harus mencakup:

```text
Accounting Standard Profile sederhana
Template CoA nirlaba
Net Asset Class
Budget Line
Budget Allocation
Cash/Bank Receipt
Cash/Bank Disbursement
General Journal
Expense Request
Commitment sederhana
Cash Advance
Liquidation
Payment status
Fixed Asset Register sederhana
Depresiasi bulanan sederhana
Bank reconciliation manual/import sederhana
Opening Balance Assistant sederhana
Budget vs Actual
Advance Aging
Fund Utilization Report
Donor Financial Report sederhana
Data Health Check dasar
Excel/CSV import-export
Dashboard dasar
Dual bahasa UI dasar
```

Belum perlu pada MVP:

```text
advanced accrual accounting
complex payroll allocation
automated bank API integration
multi-currency revaluation detail
sophisticated forecast engine
full DOCX narrative reporting
automated tax compliance per country
advanced asset impairment
```

---

## 16. Risiko Desain

Risiko yang perlu dihindari:

1. Menjadikan transaksi hanya sebagai accounting entry tanpa konteks misi.
2. Tidak membedakan commitment dan actual.
3. Tidak menghubungkan advance ke activity.
4. Tidak mengunci budget line di awal transaksi.
5. Tidak menyimpan evidence status.
6. Mengizinkan expense tanpa fund.
7. Membuat input finance terlalu kompleks bagi field staff.
8. Memaksa donor budget line sama dengan Chart of Accounts.
9. Membuat Chart of Account terlalu detail dengan donor, project, dan campaign sebagai account.
10. Mengabaikan klasifikasi aset neto dengan pembatasan dan tanpa pembatasan.
11. Tidak menyediakan opening balance assistant sehingga migrasi dari Excel sulit.
12. Tidak membedakan accounting depreciation dan donor reporting treatment.
13. Membiarkan jurnal umum menjadi shortcut tanpa audit trail.
14. Tidak menyediakan data health check sebelum laporan donor atau audit.
15. Mengklaim bilingual tetapi hanya sebagian label yang diterjemahkan.

---

## 17. Prinsip Desain

### 17.1 Standards-aware

Fundara mendukung pelaporan keuangan nirlaba berbasis ISAK 35 untuk Indonesia, serta mengadopsi prinsip pelaporan not-for-profit dari FASB ASC 958/ASU 2016-14 untuk konteks global.

### 17.2 Simple input, proper accounting

User dapat mencatat penerimaan dan pengeluaran kas/bank melalui form sederhana, tetapi sistem tetap menghasilkan pencatatan double-entry yang benar.

### 17.3 Fund-aware by design

Setiap transaksi keuangan harus dapat dikaitkan dengan fund, donor, project, activity, budget line, dan restriction status bila relevan.

### 17.4 Donor-reportable

Setiap transaksi donor-funded harus dapat ditelusuri hingga laporan donor dan bukti pendukung.

### 17.5 Audit-ready

Setiap transaksi, jurnal, koreksi, approval, dan attachment harus memiliki audit trail.

### 17.6 Migration-friendly

Fundara harus membantu organisasi berpindah dari Excel melalui import, opening balance assistant, dan data health check.

### 17.7 Localized but extensible

Fundara mendukung bahasa Indonesia dan Inggris, serta dapat dikembangkan untuk standar dan praktik lokal lain.

---

## 18. Prinsip Akhir

Financial Accountability Context harus mengikuti prinsip:

> Setiap transaksi adalah peristiwa keuangan yang membawa konteks misi, pembatasan dana, bukti, dan tanggung jawab.

Fundara harus memastikan bahwa angka keuangan tidak kehilangan cerita: dana dari mana, digunakan untuk apa, disetujui siapa, buktinya apa, sesuai batasan apa, dilaporkan ke siapa, dan dampaknya bagaimana.
