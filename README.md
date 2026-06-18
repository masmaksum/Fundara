# Fund-centric ERP for Mission-driven Organizations

## Paparan Konsep ERP untuk NGO, Yayasan, Organisasi Sosial, dan Social Enterprise

---

## 1. Executive Summary

**Fund-centric ERP for Mission-driven Organizations** adalah konsep sistem ERP yang dirancang untuk organisasi berbasis misi sosial, seperti NGO, yayasan, lembaga filantropi, organisasi kemanusiaan, lembaga dakwah/sosial, koperasi sosial, dan social enterprise.

Berbeda dari ERP komersial yang biasanya berpusat pada penjualan, produk, customer, atau profit center, Fund-centric ERP berpusat pada pertanyaan utama:

> Dana berasal dari mana, sifatnya terikat atau bebas, boleh digunakan untuk apa, dipakai oleh program mana, menghasilkan dampak apa, dan harus dipertanggungjawabkan kepada siapa?

Dalam konteks NGO modern, sumber dana tidak hanya berasal dari grant donor. Banyak organisasi juga memiliki:

- grant institutional donor,
- donasi publik,
- fundraising campaign,
- corporate giving,
- individual donor,
- zakat/infaq/wakaf atau dana keagamaan tertentu,
- membership contribution,
- dana cadangan internal,
- pendapatan unit usaha,
- social enterprise revenue,
- fee-for-service,
- consulting atau training berbayar.

Karena itu, sistem ERP yang hanya **grant-centric** belum cukup. Pendekatan yang lebih luas adalah **fund-centric**, dengan grant sebagai salah satu jenis fund.

---

## 2. Dari Grant-centric ke Fund-centric

### 2.1 Grant-centric ERP

Grant-centric ERP berpusat pada grant donor.

Alurnya:

```text
Donor
  -> Grant
      -> Project
          -> Activity
              -> Budget Line
                  -> Transaction
                      -> Evidence
                          -> Donor Report
```

Pendekatan ini cocok untuk NGO yang sebagian besar pendanaannya berasal dari institutional donor, seperti lembaga PBB, pemerintah, foundation internasional, atau donor bilateral.

Fokus utama Grant-centric ERP:

- grant agreement,
- donor budget,
- eligible dan ineligible cost,
- donor compliance,
- procurement rule,
- budget vs actual,
- reporting schedule,
- supporting document,
- audit trail,
- grant closeout.

### 2.2 Keterbatasan Grant-centric ERP

Dalam praktik, banyak organisasi tidak hanya menerima grant. Mereka juga menggalang dana publik, menerima donasi rutin, menjalankan unit usaha, atau menggunakan dana internal.

Jika sistem terlalu grant-centric, maka dana non-grant sering diperlakukan sebagai pengecualian atau dicatat manual di luar sistem.

Akibatnya:

- laporan dana umum tidak rapi,
- campaign fundraising sulit dipertanggungjawabkan,
- surplus unit usaha tidak terhubung ke program sosial,
- dana unrestricted tidak terlihat secara strategis,
- bridging fund tidak terlacak,
- co-funding sulit dikontrol,
- organisasi tetap bergantung pada spreadsheet.

### 2.3 Fund-centric ERP

Fund-centric ERP memperluas pusat sistem dari grant menjadi fund.

Alurnya:

```text
Funding Source
  -> Fund
      -> Program / Project
          -> Activity
              -> Budget / Allocation
                  -> Transaction
                      -> Evidence
                          -> Report
```

Dengan pendekatan ini, semua sumber dana diperlakukan secara sistematis, baik dana donor maupun dana swadaya.

---

## 3. Definisi Konsep Utama

## 3.1 Funding Source

**Funding Source** adalah asal dana.

Contoh:

- institutional donor,
- individual donor,
- corporate donor,
- public fundraising,
- crowdfunding platform,
- membership contribution,
- government contract,
- business unit,
- social enterprise,
- internal reserve,
- investment return.

Funding Source menjawab pertanyaan:

> Uang ini berasal dari siapa atau dari aktivitas apa?

## 3.2 Fund

**Fund** adalah kantong dana yang memiliki tujuan, batasan, aturan, dan akuntabilitas tertentu.

Contoh:

- EU Education Grant 2026,
- Campaign Banjir Jakarta 2026,
- Dana Donasi Umum,
- Emergency Reserve Fund,
- Business Surplus Fund,
- Co-Funding Fund,
- Dana Operasional Yayasan,
- Dana Wakaf Produktif,
- Scholarship Fund.

Fund menjawab pertanyaan:

> Dana ini boleh dipakai untuk apa, dalam periode apa, oleh siapa, dan harus dilaporkan bagaimana?

## 3.3 Program dan Project

**Program** adalah area kerja strategis organisasi.

Contoh:

- pendidikan,
- kesehatan,
- perlindungan anak,
- pemberdayaan ekonomi,
- respon bencana,
- lingkungan,
- advokasi kebijakan.

**Project** adalah unit implementasi yang lebih spesifik, biasanya memiliki target, periode, lokasi, anggaran, dan penanggung jawab.

Contoh:

- Program Literasi Anak Desa 2026,
- Respon Banjir Jakarta,
- Training UMKM Perempuan,
- Klinik Mobile untuk Lansia,
- Pengembangan Kurikulum Sekolah Alternatif.

## 3.4 Activity

**Activity** adalah kegiatan nyata di lapangan atau operasional.

Contoh:

- pelatihan guru,
- distribusi paket pangan,
- asesmen kebutuhan,
- kunjungan lapangan,
- workshop komunitas,
- produksi modul,
- kampanye digital,
- mentoring UMKM.

## 3.5 Transaction

**Transaction** adalah transaksi keuangan atau operasional yang memengaruhi penggunaan dana.

Contoh:

- purchase request,
- purchase order,
- purchase invoice,
- payment entry,
- cash advance,
- liquidation,
- expense claim,
- reimbursement,
- sales invoice,
- donation receipt,
- journal entry,
- payroll allocation.

## 3.6 Evidence

**Evidence** adalah bukti pendukung penggunaan dana atau pencapaian kegiatan.

Contoh:

- invoice,
- receipt,
- kuitansi,
- attendance list,
- foto kegiatan,
- laporan kegiatan,
- kontrak,
- quotation,
- berita acara,
- delivery note,
- payment proof,
- beneficiary list,
- monitoring report.

## 3.7 Report

**Report** adalah pertanggungjawaban kepada pihak internal atau eksternal.

Contoh:

- donor financial report,
- donor narrative report,
- campaign utilization report,
- public accountability report,
- business unit profit and loss,
- fund utilization report,
- board report,
- audit pack,
- impact report.

---

## 4. Jenis Sumber Dana dalam Fund-centric ERP

## 4.1 Grant Fund

Grant Fund adalah dana yang berasal dari perjanjian grant formal.

Ciri utama:

- ada donor agreement,
- ada nilai kontrak,
- ada periode implementasi,
- ada budget line yang disetujui,
- ada aturan eligible cost,
- ada kewajiban laporan,
- ada audit requirement,
- biasanya restricted.

Contoh:

- UNICEF Child Protection Grant,
- EU Women Empowerment Grant,
- USAID Health Program Grant,
- Government Social Service Grant.

Kebutuhan sistem:

- grant master,
- donor master,
- grant budget,
- donor budget line,
- procurement rule,
- reporting calendar,
- budget revision,
- compliance checklist,
- grant closeout.

## 4.2 Campaign Fund

Campaign Fund adalah dana yang dikumpulkan melalui fundraising campaign untuk tujuan tertentu.

Ciri utama:

- biasanya bersifat restricted,
- tujuan penggunaan spesifik,
- tidak selalu memiliki grant agreement formal,
- perlu transparansi ke publik,
- perlu campaign report,
- sering terkait emergency response atau program populer.

Contoh:

- Campaign Bantu Korban Banjir,
- Campaign Beasiswa Anak Desa,
- Campaign Bangun Klinik Komunitas,
- Campaign Paket Pangan Ramadhan.

Kebutuhan sistem:

- campaign master,
- donation receipt,
- donor acknowledgment,
- fundraising cost tracking,
- net fund available,
- utilization tracking,
- public report,
- campaign closure.

## 4.3 Unrestricted General Fund

Unrestricted General Fund adalah dana yang dapat digunakan secara fleksibel untuk mendukung misi organisasi.

Ciri utama:

- tidak dibatasi donor untuk project tertentu,
- bisa digunakan untuk operasional,
- bisa digunakan untuk co-funding,
- bisa digunakan sebagai bridging fund,
- penting untuk keberlanjutan organisasi.

Contoh sumber:

- donasi umum,
- individual giving tanpa earmark,
- membership contribution umum,
- surplus unit usaha yang sudah dialokasikan,
- pendapatan jasa umum.

Kebutuhan sistem:

- organizational budget,
- internal approval,
- reserve policy,
- allocation plan,
- cash flow dashboard,
- unrestricted fund utilization report.

## 4.4 Business Unit Fund / Social Enterprise Revenue

Business Unit Fund berasal dari unit usaha atau aktivitas komersial organisasi.

Ciri utama:

- ada revenue,
- ada cost of goods sold atau direct cost,
- ada operating expense,
- ada margin atau surplus,
- surplus dapat dialokasikan untuk misi sosial,
- bisa memiliki kewajiban pajak atau legal tertentu.

Contoh:

- training center berbayar,
- jasa konsultansi,
- penjualan produk komunitas,
- café sosial,
- merchandise,
- penerbitan buku,
- event berbayar,
- rental fasilitas,
- koperasi atau unit bisnis.

Kebutuhan sistem:

- sales invoice,
- customer,
- item atau service,
- inventory,
- cost center,
- business unit P&L,
- surplus calculation,
- surplus allocation,
- tax handling bila relevan.

## 4.5 Reserve Fund

Reserve Fund adalah dana cadangan internal.

Ciri utama:

- disiapkan untuk menjaga keberlanjutan organisasi,
- bisa berasal dari unrestricted surplus,
- penggunaannya biasanya memerlukan approval tinggi,
- dapat digunakan untuk emergency, cash flow gap, atau investasi strategis.

Contoh:

- operating reserve 6 bulan,
- emergency response reserve,
- digital transformation fund,
- matching fund reserve,
- staff severance reserve.

Kebutuhan sistem:

- reserve policy,
- board-designated status,
- utilization approval,
- minimum balance alert,
- reserve movement report.

## 4.6 Co-Funding Fund

Co-Funding Fund adalah dana pendamping untuk memenuhi kewajiban matching fund atau kontribusi internal terhadap project tertentu.

Ciri utama:

- sering digunakan bersama grant,
- bisa berasal dari unrestricted fund atau unit usaha,
- perlu dilacak agar tidak terjadi double counting,
- penting dalam donor reporting.

Contoh:

- donor meminta 20% kontribusi lokal,
- grant hanya membiayai program cost, sementara lembaga membiayai admin cost,
- project strategis dibiayai gabungan grant dan donasi publik.

---

## 5. Klasifikasi Pembatasan Dana

Fund-centric ERP harus mampu membedakan tingkat pembatasan dana.

## 5.1 Restricted Fund

Dana hanya boleh digunakan untuk tujuan tertentu.

Contoh:

- grant donor,
- campaign bencana,
- corporate donation untuk sekolah,
- wakaf untuk pembangunan aset tertentu.

Kontrol sistem:

- expense harus sesuai tujuan,
- periode penggunaan dibatasi,
- budget line dikontrol,
- laporan khusus diperlukan.

## 5.2 Temporarily Restricted Fund

Dana dibatasi sampai kondisi tertentu terpenuhi.

Contoh:

- campaign fund yang belum selesai digunakan,
- dana project dengan periode tertentu,
- pledge yang belum dicairkan,
- dana yang harus dipakai sebelum tanggal tertentu.

Kontrol sistem:

- expiry date,
- release condition,
- remaining balance,
- reminder penggunaan dana.

## 5.3 Unrestricted Fund

Dana dapat digunakan untuk misi organisasi secara umum.

Contoh:

- donasi umum,
- surplus unit usaha,
- membership fee umum.

Kontrol sistem:

- internal budget,
- governance approval,
- allocation policy,
- cash flow control.

## 5.4 Board-designated Fund

Dana secara hukum/internal mungkin unrestricted, tetapi manajemen atau board menetapkan tujuan tertentu.

Contoh:

- emergency reserve,
- innovation fund,
- technology investment fund,
- matching fund reserve.

Kontrol sistem:

- board approval,
- designation purpose,
- release approval,
- movement report.

---

## 6. Fund-centric Operating Model

Fund-centric ERP menghubungkan tiga domain besar:

```text
Funding Management
  -> Mission Delivery
      -> Accountability & Reporting
```

## 6.1 Funding Management

Mengelola semua sumber dana organisasi.

Termasuk:

- donor,
- grant,
- campaign,
- donation,
- pledge,
- unit usaha,
- reserve,
- unrestricted fund,
- co-funding,
- internal allocation.

Pertanyaan yang dijawab:

- Dana berasal dari mana?
- Dana masuk berapa?
- Dana ini restricted atau unrestricted?
- Dana ini boleh dipakai untuk apa?
- Dana ini tersedia sampai kapan?
- Dana ini harus dilaporkan ke siapa?

## 6.2 Mission Delivery

Mengelola penggunaan dana untuk menjalankan misi organisasi.

Termasuk:

- program,
- project,
- activity,
- workplan,
- procurement,
- cash advance,
- liquidation,
- field report,
- beneficiary,
- MEAL,
- asset,
- inventory.

Pertanyaan yang dijawab:

- Dana digunakan untuk project apa?
- Activity apa yang dijalankan?
- Siapa PIC-nya?
- Berapa planned cost dan actual cost?
- Bukti kegiatan lengkap atau tidak?
- Output atau impact apa yang dihasilkan?

## 6.3 Accountability & Reporting

Mengelola pertanggungjawaban internal dan eksternal.

Termasuk:

- donor report,
- campaign report,
- public report,
- management dashboard,
- board report,
- financial statement,
- business unit P&L,
- fund utilization report,
- impact report,
- audit pack.

Pertanyaan yang dijawab:

- Dana sudah digunakan berapa?
- Sisa dana berapa?
- Apakah ada overspending?
- Apakah ada dana idle?
- Apakah ada laporan overdue?
- Apakah evidence lengkap?
- Apa dampak yang sudah dicapai?

---

## 7. Data Model Konseptual

```text
Funding Source
  |-- Donor
  |-- Individual Donor
  |-- Corporate Donor
  |-- Public Campaign
  |-- Business Unit
  |-- Internal Allocation

Fund
  |-- Grant Fund
  |-- Campaign Fund
  |-- Unrestricted Fund
  |-- Business Surplus Fund
  |-- Reserve Fund
  |-- Co-Funding Fund

Fund Allocation
  |-- Fund
  |-- Program
  |-- Project
  |-- Activity
  |-- Budget Line
  |-- Amount
  |-- Period

Revenue Transaction
  |-- Grant Disbursement
  |-- Donation Receipt
  |-- Sales Invoice
  |-- Membership Fee
  |-- Other Income

Expense Transaction
  |-- Purchase Request
  |-- Purchase Order
  |-- Purchase Invoice
  |-- Expense Claim
  |-- Cash Advance
  |-- Liquidation
  |-- Payment Entry
  |-- Journal Entry

Evidence
  |-- Invoice
  |-- Receipt
  |-- Attendance List
  |-- Photo
  |-- Report
  |-- Contract
  |-- Quotation
  |-- Delivery Note

Report
  |-- Donor Report
  |-- Campaign Report
  |-- Fund Utilization Report
  |-- Business Unit P&L
  |-- Board Report
  |-- Public Accountability Report
  |-- Audit Pack
```

---

## 8. Master Data yang Dibutuhkan

| Area | Master Data |
|---|---|
| Organization | Company, Branch, Department, Cost Center, Location |
| Funding | Funding Source, Fund, Fund Type, Fund Restriction |
| Grant | Donor, Grant, Grant Agreement, Grant Budget, Budget Line |
| Fundraising | Campaign, Donor, Donation Channel, Donation Receipt |
| Business Unit | Business Unit, Product, Service, Customer, Price List |
| Program | Program, Project, Activity, Workplan, Milestone |
| Finance | Chart of Accounts, Fiscal Year, Currency, Bank Account |
| Procurement | Supplier, Item, Procurement Method, Threshold Rule |
| Operation | Warehouse, Asset, Vehicle, Inventory Location |
| HR | Employee, Role, Project Assignment, Timesheet |
| MEAL | Indicator, Output, Outcome, Beneficiary Group |
| Compliance | Approval Matrix, Document Requirement, Audit Checklist |

---

## 9. Accounting Design

## 9.1 Chart of Accounts Jangan Terlalu Detail

Kesalahan umum adalah memasukkan semua donor, project, campaign, dan fund ke Chart of Accounts.

Contoh yang kurang ideal:

```text
Expense - UNICEF
Expense - EU
Expense - Campaign Banjir
Expense - Unit Usaha A
Expense - Unit Usaha B
```

Struktur seperti ini akan sulit dipelihara karena jumlah akun akan terus bertambah.

## 9.2 Chart of Accounts Sebaiknya Generik

Contoh struktur yang lebih sehat:

```text
Income
  |-- Grant Income
  |-- Donation Income
  |-- Fundraising Income
  |-- Business Revenue
  |-- Membership Income
  |-- Other Income

Expense
  |-- Program Expense
  |-- Personnel Expense
  |-- Travel Expense
  |-- Training Expense
  |-- Procurement Expense
  |-- Fundraising Expense
  |-- Business Operating Expense
  |-- Admin Expense
  |-- Monitoring & Evaluation Expense
```

Detail analisis dilakukan menggunakan accounting dimensions.

## 9.3 Accounting Dimensions

Dimensi yang disarankan:

### Dimensi wajib

- Fund,
- Project,
- Cost Center.

### Dimensi tambahan

- Grant,
- Campaign,
- Business Unit,
- Activity,
- Budget Line,
- Location,
- Donor,
- Reporting Period.

Dengan pendekatan ini, satu transaksi bisa dianalisis dari berbagai sudut tanpa membuat Chart of Accounts membengkak.

---

## 10. Budget dan Allocation Model

Fund-centric ERP perlu membedakan beberapa konsep anggaran.

## 10.1 Approved Budget

Anggaran yang disetujui oleh donor, board, campaign manager, atau manajemen.

## 10.2 Revised Budget

Anggaran yang sudah mengalami revisi resmi.

## 10.3 Allocated Budget

Bagian dana yang dialokasikan ke program, project, activity, atau cost center tertentu.

## 10.4 Committed Amount

Nilai yang sudah menjadi komitmen, misalnya melalui purchase order, kontrak, atau approved request, tetapi belum menjadi actual expense.

## 10.5 Actual Amount

Nilai yang sudah menjadi transaksi aktual di accounting.

## 10.6 Available Budget

Sisa dana yang masih tersedia.

Rumus umum:

```text
Available Budget = Revised Budget - Committed Amount - Actual Amount
```

Namun sistem perlu menghindari double counting. Jika purchase order sudah menjadi invoice, nilai tersebut harus berpindah dari committed ke actual.

---

## 11. Multi-source Funding dan Cost Sharing

Dalam praktik, satu project dapat didanai oleh beberapa fund.

Contoh:

| Project | Funding Source | Kontribusi |
|---|---|---:|
| Program Literasi Anak | Grant A | 60% |
| Program Literasi Anak | Campaign Fund | 25% |
| Program Literasi Anak | Business Surplus Fund | 15% |

Sistem perlu mendukung **split funding**.

Contoh transaksi Rp100.000.000:

| Fund | Amount |
|---|---:|
| Grant A | Rp60.000.000 |
| Campaign Fund | Rp25.000.000 |
| Business Surplus Fund | Rp15.000.000 |

Kebutuhan fitur:

- cost sharing rule,
- split funding transaction,
- co-funding tracker,
- matching fund report,
- allocation validation,
- fund settlement.

---

## 12. Bridging Fund

NGO sering mengalami situasi di mana grant sudah disetujui, tetapi dana belum cair. Organisasi menggunakan dana internal terlebih dahulu.

Alur bridging fund:

```text
Expense dibayar dari Unrestricted Fund
  -> Ditandai sebagai recoverable from Grant X
      -> Grant disbursement diterima
          -> Dana internal direimburse
              -> Settlement antar fund tercatat
```

Manfaat:

- dana internal tetap terlacak,
- grant tetap menanggung biaya eligible,
- cash flow lebih transparan,
- tidak terjadi double counting,
- finance dapat melihat outstanding recoverable.

Kebutuhan fitur:

- bridging fund request,
- recoverable tagging,
- settlement journal,
- outstanding bridging report,
- approval matrix.

---

## 13. Workflow Utama

## 13.1 Grant Fund Workflow

```text
Grant Pipeline
  -> Grant Awarded
      -> Grant Setup
          -> Budget Setup
              -> Project Allocation
                  -> Activity Planning
                      -> Expense / Procurement
                          -> Evidence Collection
                              -> Donor Report
                                  -> Grant Closeout
```

Kontrol utama:

- grant period,
- eligible cost,
- budget line,
- procurement rule,
- donor reporting,
- audit requirement.

## 13.2 Fundraising Campaign Workflow

```text
Campaign Created
  -> Target Set
      -> Donation Collected
          -> Receipt / Acknowledgment Sent
              -> Net Fund Available
                  -> Program Utilization
                      -> Evidence Collection
                          -> Campaign Report
                              -> Campaign Closure
```

Kontrol utama:

- campaign purpose,
- donation channel,
- restricted use,
- fundraising cost ratio,
- public accountability,
- remaining balance.

## 13.3 Business Unit Workflow

```text
Product / Service Setup
  -> Sales Transaction
      -> Invoice
          -> Payment Received
              -> Cost Recorded
                  -> Margin Calculated
                      -> Surplus Allocated
                          -> Program / Reserve Funding
```

Kontrol utama:

- revenue,
- cost of goods sold,
- operating expense,
- receivable,
- inventory,
- tax,
- surplus allocation.

## 13.4 Cash Advance and Liquidation Workflow

```text
Advance Request
  -> Budget Check
      -> Approval
          -> Payment
              -> Activity Implementation
                  -> Liquidation Submitted
                      -> Evidence Review
                          -> Refund / Reimbursement
                              -> Expense Posted
                                  -> Advance Closed
```

Kontrol utama:

- fund availability,
- activity approval,
- evidence completeness,
- overdue liquidation,
- refund/reimbursement calculation.

## 13.5 Procurement Workflow

```text
Purchase Request
  -> Budget Check
      -> Procurement Rule Check
          -> Quotation / Tender
              -> Bid Analysis
                  -> Approval
                      -> Purchase Order
                          -> Goods / Service Receipt
                              -> Invoice
                                  -> Payment
```

Kontrol utama:

- procurement threshold,
- donor rule,
- supplier eligibility,
- conflict of interest,
- required quotation,
- approval matrix.

---

## 14. Reporting Framework

## 14.1 Fund Utilization Report

Menjawab:

- dana masuk berapa,
- dana keluar berapa,
- sisa dana berapa,
- digunakan untuk project apa,
- bukti lengkap atau tidak.

Contoh format:

| Fund | Opening | Income | Expense | Balance |
|---|---:|---:|---:|---:|
| Grant EU | 0 | 1.000.000 | 650.000 | 350.000 |
| Campaign Banjir | 0 | 500.000 | 420.000 | 80.000 |
| General Fund | 200.000 | 150.000 | 180.000 | 170.000 |
| Business Surplus Fund | 50.000 | 120.000 | 60.000 | 110.000 |

## 14.2 Source and Use of Funds Report

Menjawab:

> Dari mana dana berasal dan digunakan untuk apa?

Contoh:

| Source | Amount | Main Use |
|---|---:|---|
| Grant | 60% | Program restricted |
| Public Donation | 20% | Campaign and program |
| Unit Usaha | 15% | Program and reserve |
| Other Income | 5% | Admin and general support |

## 14.3 Campaign Report

Isi laporan:

- total donation collected,
- number of donors,
- fundraising cost,
- net fund available,
- amount used,
- remaining balance,
- beneficiaries reached,
- activity evidence,
- campaign closure status.

## 14.4 Business Unit Report

Isi laporan:

- revenue,
- cost of goods sold,
- gross margin,
- operating expense,
- net surplus,
- surplus allocated to mission,
- receivables,
- inventory,
- cash position.

## 14.5 Restriction Report

Menjawab:

- berapa dana restricted,
- berapa unrestricted,
- berapa board-designated,
- dana mana yang akan expire,
- dana mana yang idle,
- dana mana yang overspent,
- dana mana yang perlu segera digunakan.

## 14.6 Grant Dashboard

Indikator utama:

- total grant budget,
- actual spent,
- committed amount,
- available budget,
- burn rate,
- time elapsed,
- upcoming report due,
- overdue liquidation,
- missing evidence,
- budget variance,
- closeout status.

## 14.7 Executive Dashboard

Indikator utama:

- total funds by source,
- restricted vs unrestricted balance,
- cash runway,
- grant health,
- campaign performance,
- business unit contribution,
- project burn rate,
- overdue reports,
- compliance risk,
- impact achievement.

---

## 15. Implementasi dengan ERPNext

ERPNext dapat digunakan sebagai backend/core ERP karena sudah memiliki modul standar yang relevan.

## 15.1 Modul ERPNext yang Dapat Digunakan

| Kebutuhan | Modul / Komponen ERPNext |
|---|---|
| Accounting | Accounts, GL Entry, Journal Entry, Payment Entry |
| Procurement | Purchase Request, Supplier Quotation, Purchase Order, Purchase Invoice |
| Project | Project, Task, Timesheet |
| Unit Usaha | Selling, Sales Invoice, Customer, Item, Stock |
| Inventory | Stock, Warehouse, Item |
| Asset | Asset |
| HR | Employee, Payroll, Expense Claim |
| Approval | Workflow |
| Permission | Role Permission Manager |
| Reporting | Query Report, Script Report, Dashboard |
| Customization | Custom Field, Custom DocType, Server Script, Custom App |

## 15.2 Custom App yang Disarankan

Buat custom Frappe app, misalnya:

```text
ngo_fund_erp
```

Custom app ini berisi logika khusus NGO dan mission-driven organization.

## 15.3 Custom DocType yang Disarankan

### Funding Management

- Funding Source,
- Fund,
- Fund Type,
- Fund Restriction,
- Fund Allocation,
- Fund Transfer,
- Fund Utilization Plan,
- Bridging Fund Settlement.

### Grant Management

- Donor,
- Grant,
- Grant Agreement,
- Grant Budget,
- Grant Budget Line,
- Grant Budget Revision,
- Donor Reporting Schedule,
- Grant Closeout Checklist.

### Fundraising

- Campaign,
- Donation Receipt,
- Donor Profile,
- Donor Acknowledgment,
- Fundraising Channel,
- Campaign Report.

### Business Unit

- Business Unit,
- Business Revenue Stream,
- Surplus Allocation Rule,
- Business Unit Surplus Allocation.

### Program and Operation

- Program,
- Activity Plan,
- Field Activity Report,
- Supporting Document Register,
- Cash Advance,
- Liquidation,
- Procurement Threshold Rule,
- Bid Analysis.

### MEAL and Impact

- Indicator,
- Indicator Target,
- Indicator Achievement,
- Beneficiary Group,
- Impact Report.

---

## 16. Role dan Permission

Fund-centric ERP memerlukan role-based access yang kuat.

## 16.1 Role Utama

- System Admin,
- Finance Officer,
- Finance Manager,
- Project Officer,
- Project Manager,
- Grant Manager,
- Fundraising Manager,
- Campaign Manager,
- Business Unit Manager,
- Procurement Officer,
- Operations Manager,
- MEAL Officer,
- HR Officer,
- Executive Director,
- Board Viewer,
- Auditor,
- Donor Viewer bila diperlukan.

## 16.2 Prinsip Permission

- Field staff tidak perlu melihat general ledger.
- Project manager perlu melihat budget dan progress project.
- Finance perlu melihat transaksi, budget, dan supporting document.
- Grant manager perlu melihat compliance dan reporting.
- Fundraising manager perlu melihat campaign dan donor receipt.
- Business unit manager perlu melihat revenue, cost, dan surplus.
- Executive perlu melihat dashboard lintas fund.
- Auditor perlu akses read-only ke dokumen dan audit trail.

---

## 17. User Experience Design

Fund-centric ERP harus menghindari form yang terlalu berat.

## 17.1 Conditional Fields

Field yang muncul sebaiknya tergantung jenis fund.

Contoh:

- Jika Fund Type = Grant Fund, tampilkan Grant, Donor Budget Line, Grant Reporting Period.
- Jika Fund Type = Campaign Fund, tampilkan Campaign, Public Report Category, Donation Restriction.
- Jika Fund Type = Business Unit Fund, tampilkan Business Unit, Product/Service, Revenue Stream.
- Jika Fund Type = Unrestricted Fund, tampilkan Allocation Purpose dan Internal Budget.

## 17.2 Role-based Dashboard

Setiap role melihat dashboard berbeda.

### Field Staff

- assigned activities,
- pending advances,
- liquidation due,
- activity report form.

### Project Manager

- workplan,
- activity progress,
- budget vs actual,
- pending approval,
- deliverables,
- indicator achievement.

### Finance Officer

- transaction review,
- payment queue,
- advance aging,
- budget exceptions,
- missing evidence.

### Grant Manager

- grant health,
- report due date,
- compliance issues,
- budget revision,
- closeout status.

### Fundraising Manager

- campaign collection,
- donor count,
- fundraising cost,
- campaign utilization,
- acknowledgment status.

### Business Unit Manager

- sales,
- receivables,
- operating cost,
- margin,
- inventory,
- surplus allocation.

### Executive Director

- total funds,
- restricted vs unrestricted,
- cash runway,
- program performance,
- compliance risk,
- impact summary.

---

## 18. Governance dan Approval Matrix

Setiap jenis fund memerlukan approval berbeda.

## 18.1 Grant Fund

Approval:

- Project Manager,
- Finance Manager,
- Grant Manager,
- Executive Director untuk exception.

Kontrol:

- donor budget,
- eligible cost,
- procurement rule,
- grant period,
- donor report.

## 18.2 Campaign Fund

Approval:

- Campaign Manager,
- Program Manager,
- Finance Manager,
- Executive Director untuk perubahan tujuan.

Kontrol:

- campaign restriction,
- public accountability,
- utilization report,
- remaining balance.

## 18.3 Business Unit Fund

Approval:

- Business Unit Manager,
- Finance Manager,
- Executive Director atau Board untuk surplus allocation.

Kontrol:

- revenue recognition,
- business expense,
- margin,
- tax,
- surplus policy.

## 18.4 Unrestricted Fund

Approval:

- Department Head,
- Finance Manager,
- Executive Director.

Kontrol:

- annual budget,
- cash flow,
- reserve policy,
- internal governance.

## 18.5 Reserve Fund

Approval:

- Executive Director,
- Board atau Trustee,
- Finance Manager.

Kontrol:

- minimum balance,
- emergency justification,
- strategic use,
- replenishment plan.

---

## 19. Compliance dan Audit Trail

Fund-centric ERP harus memastikan setiap transaksi dapat diaudit.

## 19.1 Audit Trail Minimum

Setiap transaksi harus mencatat:

- siapa yang membuat,
- siapa yang menyetujui,
- kapan disetujui,
- fund yang digunakan,
- project/activity terkait,
- budget line,
- dokumen pendukung,
- payment reference,
- perubahan status,
- revisi atau pembatalan.

## 19.2 Supporting Document Register

Sistem harus dapat menghasilkan daftar dokumen pendukung.

Contoh kolom:

- transaction ID,
- date,
- vendor/payee,
- amount,
- fund,
- project,
- activity,
- document type,
- attachment status,
- reviewer,
- remarks.

## 19.3 Exception Management

Sistem perlu menandai transaksi bermasalah.

Contoh exception:

- expense melebihi budget,
- expense di luar periode fund,
- missing receipt,
- missing quotation,
- vendor belum due diligence,
- liquidation overdue,
- report overdue,
- activity belum approved,
- fund balance negatif.

---

## 20. MVP yang Disarankan

MVP sebaiknya fokus pada loop inti:

```text
Fund Setup
  -> Project Allocation
      -> Expense / Advance / Procurement
          -> Evidence
              -> Budget vs Actual
                  -> Fund Utilization Report
```

## 20.1 MVP Scope

### Master Data

- Funding Source,
- Fund,
- Fund Type,
- Fund Restriction,
- Donor,
- Campaign,
- Business Unit,
- Project,
- Activity,
- Budget Line,
- Cost Center.

### Transaction

- Donation Receipt,
- Grant Disbursement,
- Sales Invoice untuk unit usaha,
- Expense Request,
- Purchase Request,
- Cash Advance,
- Liquidation,
- Payment,
- Journal Entry tagging.

### Control

- budget availability check,
- fund restriction check,
- fund period check,
- mandatory attachment,
- approval workflow,
- budget exception,
- liquidation aging.

### Report

- fund utilization report,
- budget vs actual per fund,
- advance aging,
- campaign donation report,
- business unit P&L sederhana,
- supporting document register,
- executive fund dashboard.

## 20.2 MVP Success Criteria

MVP berhasil jika sistem dapat menjawab pertanyaan berikut secara real-time:

1. Total dana per fund berapa?
2. Dana yang sudah digunakan berapa?
3. Dana yang sudah committed berapa?
4. Sisa dana per fund dan budget line berapa?
5. Dana mana yang restricted dan unrestricted?
6. Project mana yang didanai oleh fund mana?
7. Transaksi mana yang belum lengkap buktinya?
8. Advance siapa yang belum dilikuidasi?
9. Campaign fundraising terkumpul dan terpakai berapa?
10. Unit usaha menghasilkan surplus berapa dan dialokasikan ke mana?
11. Ada dana yang hampir expire atau idle?
12. Laporan fund utilization bisa ditarik dari sistem atau tidak?

---

## 21. Roadmap Produk

## Phase 1 - Fund Finance Core

Fokus:

- fund master,
- grant fund,
- campaign fund,
- unrestricted fund,
- project allocation,
- budget vs actual,
- expense request,
- cash advance,
- liquidation,
- approval workflow,
- fund utilization report.

Target:

> Organisasi dapat mengontrol sumber dan penggunaan dana secara terstruktur.

## Phase 2 - Procurement, Asset, and Operation

Fokus:

- procurement threshold,
- quotation comparison,
- purchase order,
- supplier due diligence,
- asset registry,
- inventory,
- travel request,
- field activity report.

Target:

> Penggunaan dana terhubung dengan procurement, asset, dan bukti operasional.

## Phase 3 - Fundraising and Business Unit

Fokus:

- campaign management,
- donor receipt,
- donor acknowledgment,
- fundraising channel,
- business unit P&L,
- inventory unit usaha,
- surplus allocation,
- public report.

Target:

> Dana swadaya, donasi publik, dan unit usaha dapat dikelola dalam sistem yang sama.

## Phase 4 - MEAL and Impact Reporting

Fokus:

- indicator framework,
- target vs achievement,
- beneficiary tracking,
- output and outcome reporting,
- cost per output,
- impact dashboard.

Target:

> Sistem tidak hanya mencatat uang, tetapi juga menghubungkan dana dengan dampak.

## Phase 5 - Advanced Compliance and Integration

Fokus:

- audit pack generator,
- bank reconciliation automation,
- payment gateway integration,
- KoboToolbox/ODK integration,
- BI dashboard,
- SSO,
- mobile/offline field forms,
- donor portal,
- public transparency portal.

Target:

> ERP menjadi platform akuntabilitas end-to-end untuk organisasi sosial.

---

## 22. Risiko Desain yang Harus Dihindari

## 22.1 Menjadikan Fund Hanya Field Teks

Fund harus menjadi master data dengan rule, restriction, budget, period, dan reporting requirement.

## 22.2 Chart of Accounts Terlalu Kompleks

Donor, campaign, dan project sebaiknya menjadi dimensi, bukan akun utama.

## 22.3 Tidak Membedakan Committed dan Actual

Purchase order dan approved request adalah commitment. Invoice/payment adalah actual.

## 22.4 Evidence Tidak Diwajibkan Sejak Awal

Jika evidence baru dikejar menjelang audit, sistem tidak menyelesaikan masalah utama NGO.

## 22.5 Tidak Mendukung Multi-fund Project

Banyak project didanai oleh beberapa sumber. Sistem harus mendukung cost sharing dan split funding.

## 22.6 Tidak Melacak Bridging Fund

Dana internal yang dipakai sementara untuk grant harus bisa direcover dan disettle.

## 22.7 Tidak Menghubungkan Unit Usaha ke Misi Sosial

Jika unit usaha hanya dicatat sebagai revenue biasa, kontribusinya terhadap misi organisasi tidak terlihat.

## 22.8 Terlalu Banyak Field untuk Semua User

Gunakan conditional fields dan role-based forms agar UX tetap sederhana.

---

## 23. Positioning Produk

### 23.1 Positioning Statement

**Fund-centric ERP for Mission-driven Organizations** adalah ERP yang mengelola berbagai sumber dana organisasi sosial—grant, donasi, fundraising, unit usaha, dana internal, dan reserve—serta menghubungkannya dengan program, project, aktivitas, procurement, pengeluaran, compliance, evidence, dan impact reporting dalam satu sistem yang dapat diaudit.

### 23.2 Tagline Alternatif

- Managing every fund from source to impact.
- From funding to fieldwork to accountability.
- One ERP for grants, donations, enterprise income, and mission impact.
- ERP untuk mengelola dana, program, dan dampak sosial.
- Sistem terpadu untuk dana, kegiatan, akuntabilitas, dan dampak.

### 23.3 Pembeda Produk

Dibanding ERP generik, pembeda utamanya:

1. fund-centric data model,
2. restricted vs unrestricted fund tracking,
3. grant dan campaign fund management,
4. business surplus allocation,
5. multi-source project funding,
6. bridging fund settlement,
7. budget control before spending,
8. evidence-driven accountability,
9. donor dan public reporting,
10. impact-linked finance.

---

## 24. Kesimpulan

Mission-driven organizations membutuhkan ERP yang berbeda dari perusahaan komersial biasa.

Mereka tidak hanya bertanya:

> Berapa revenue dan expense?

Tetapi juga:

> Dana berasal dari mana?  
> Dana ini boleh digunakan untuk apa?  
> Project mana yang menggunakan dana ini?  
> Apakah bukti lengkap?  
> Apakah sesuai restriction?  
> Apakah ada laporan ke donor atau publik?  
> Apakah penggunaan dana menghasilkan dampak?  
> Apakah organisasi semakin berkelanjutan?

Karena itu, konsep **Fund-centric ERP** lebih tepat untuk NGO dan organisasi sosial yang memiliki banyak sumber pendanaan.

Grant tetap penting, tetapi grant hanyalah salah satu jenis fund. Dengan pendekatan fund-centric, sistem dapat mengelola grant donor, donasi publik, campaign fundraising, unit usaha, dana internal, reserve, co-funding, dan bridging fund dalam satu arsitektur yang terintegrasi.

Tujuan akhirnya adalah:

> Membangun sistem yang menghubungkan sumber dana, penggunaan dana, bukti kegiatan, compliance, laporan, dan dampak sosial secara transparan, terkontrol, dan dapat diaudit.

---

## 25. Ringkasan Struktur Produk

```text
Fund-centric ERP for Mission-driven Organizations

1. Funding Management
   |-- Grant
   |-- Donation
   |-- Campaign
   |-- Business Unit Revenue
   |-- Unrestricted Fund
   |-- Reserve
   |-- Co-Funding
   |-- Bridging Fund

2. Mission Delivery
   |-- Program
   |-- Project
   |-- Activity
   |-- Procurement
   |-- Cash Advance
   |-- Liquidation
   |-- Field Report
   |-- Beneficiary
   |-- MEAL

3. Accountability & Reporting
   |-- Fund Utilization Report
   |-- Donor Report
   |-- Campaign Report
   |-- Business Unit P&L
   |-- Supporting Document Register
   |-- Audit Pack
   |-- Impact Report
   |-- Executive Dashboard
```

---

## 26. Recommended MVP Blueprint

```text
Core MVP

Funding Source
  -> Fund
      -> Fund Restriction
          -> Fund Budget / Allocation
              -> Project
                  -> Activity
                      -> Expense / Advance / Procurement
                          -> Evidence
                              -> Budget vs Actual
                                  -> Fund Utilization Report
```

Minimum modules:

1. Funding Source Master
2. Fund Master
3. Fund Restriction
4. Grant Fund
5. Campaign Fund
6. Unrestricted Fund
7. Business Unit Fund
8. Project and Activity
9. Fund Allocation
10. Expense Request
11. Cash Advance and Liquidation
12. Purchase Request
13. Fund Tagging in Transactions
14. Budget Availability Check
15. Supporting Document Register
16. Fund Utilization Report
17. Campaign Donation Report
18. Business Unit P&L Simple Report
19. Executive Dashboard
20. Role-based Approval Workflow

Dengan MVP ini, organisasi sudah dapat mengelola dana dari berbagai sumber dan menghubungkannya dengan project, aktivitas, transaksi, bukti, serta laporan pertanggungjawaban.

