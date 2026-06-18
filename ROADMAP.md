# Fundara Roadmap

**Fundara** adalah *Mission Impact Platform* open-source untuk organisasi berbasis misi sosial.

Tagline:

> Helping mission-driven organizations turn trusted funds into measurable impact.

Roadmap ini menjelaskan arah pengembangan Fundara dari tahap MVP sampai v1.0. Fokus utamanya adalah membangun fondasi yang stabil untuk mengelola dana amanah, program, operasi, akuntabilitas keuangan, compliance, evidence, dan laporan dampak.

Fundara secara teknis dirancang sebagai custom app di atas ERPNext/Frappe, dengan prinsip:

- tidak memodifikasi core ERPNext;
- fund-centric sebagai pusat domain;
- akuntabilitas dan audit trail sejak awal;
- user experience sederhana untuk NGO;
- siap dikembangkan sebagai project open-source;
- mendukung konteks Indonesia, termasuk ISAK 35;
- tetap extensible untuk adopsi prinsip FASB ASC 958/ASU 2016-14.

---

## 1. Prinsip Roadmap

Roadmap Fundara mengikuti beberapa prinsip utama.

### 1.1 Mission-first, bukan ERP-first

Fundara tidak diposisikan sebagai ERP generik, tetapi sebagai platform untuk menghubungkan dana, program, kerja lapangan, bukti, laporan, dan dampak.

### 1.2 MVP harus menyelesaikan masalah nyata

MVP tidak harus lengkap, tetapi harus dapat menjawab masalah utama NGO:

- dana berasal dari mana;
- dana dialokasikan ke project apa;
- budget tersedia berapa;
- sudah digunakan berapa;
- uang muka siapa yang belum dipertanggungjawabkan;
- transaksi mana yang belum lengkap buktinya;
- laporan fund/donor bisa dihasilkan dari sistem.

### 1.3 Accounting engine kuat, input tetap sederhana

User boleh memakai form kas/bank yang sederhana, tetapi sistem tetap menghasilkan pencatatan double-entry yang benar melalui ERPNext accounting engine.

### 1.4 Fund sebagai pusat, bukan Chart of Account

Chart of Account harus tetap bersih dan stabil. Fund, donor, grant, project, activity, budget line, dan location dikelola sebagai dimensi dan domain object, bukan sebagai akun yang terus bertambah.

### 1.5 Open-source ready sejak awal

Dokumentasi, struktur repository, demo data, kontribusi komunitas, issue template, dan migration strategy harus disiapkan sejak awal.

---

## 2. Versi Roadmap

Roadmap Fundara dibagi menjadi:

```text
MVP        : Fondasi fund, project finance, advance, evidence, dan basic reporting
v0.2       : Grant & donor reporting
v0.3       : Fundraising, donation, dan campaign fund
v0.4       : Procurement & operations compliance
v0.5       : Accounting nonprofit, ISAK 35, fixed asset, bank reconciliation
v0.6       : Impact & learning
v0.7       : Reporting package, audit pack, dashboard
v0.8       : Integrasi, import/export, data health
v0.9       : Hardening, security, deployment, localization
v1.0       : Stable release untuk production NGO kecil-menengah
```

---

# 3. MVP — Fund & Project Accountability Core

## 3.1 Tujuan MVP

MVP Fundara bertujuan membuktikan konsep inti:

> Setiap dana dapat ditelusuri dari sumbernya, ke alokasi project/activity, ke transaksi, ke bukti, sampai ke laporan fund utilization.

MVP tidak mengejar semua fitur ERP. MVP berfokus pada *fund-to-accountability loop*.

---

## 3.2 Scope MVP

### Domain yang masuk MVP

```text
Organization Context
Funding Context
Fund Stewardship Context
Mission Delivery Context
Financial Accountability Context dasar
Evidence & Compliance Context dasar
Reporting Context dasar
```

### Domain yang belum menjadi fokus MVP

```text
Procurement compliance penuh
Fundraising publik penuh
Unit usaha / social enterprise accounting penuh
Impact framework penuh
Advanced donor report template
Bank API integration
BI integration
Mobile/offline app
```

---

## 3.3 Fitur MVP

### A. Organization Setup

Fitur:

- Organization Profile;
- Office / Branch;
- Department;
- Cost Center mapping;
- role dasar;
- fiscal year;
- base currency.

Role MVP:

```text
System Manager
Finance Manager
Finance Officer
Program Manager
Project Officer
Executive Viewer
Auditor Viewer
```

Acceptance criteria:

- organisasi dapat dibuat;
- fiscal year dan currency dapat ditentukan;
- user dapat diberi role;
- cost center dapat digunakan dalam transaksi.

---

### B. Funding Source

Fitur:

- Funding Source master;
- tipe sumber dana:
  - donor;
  - campaign;
  - unrestricted donation;
  - internal fund;
  - business unit revenue;
- status aktif/nonaktif;
- contact person;
- catatan restriction umum.

Acceptance criteria:

- user dapat membuat sumber dana;
- setiap fund dapat dikaitkan dengan funding source;
- laporan dapat difilter berdasarkan funding source.

---

### C. Fund Master

Fitur:

- Fund master;
- fund type:
  - Grant Fund;
  - Campaign Fund;
  - Unrestricted Fund;
  - Business Surplus Fund;
  - Reserve Fund;
  - Bridging Fund;
- restriction type:
  - dengan pembatasan;
  - tanpa pembatasan;
  - board-designated;
- fund owner;
- start date/end date;
- currency;
- status lifecycle.

Lifecycle:

```text
Draft → Active → Suspended → Closing → Closed
```

Acceptance criteria:

- fund dapat dibuat dari funding source;
- fund memiliki restriction type;
- fund dapat dihubungkan dengan project dan transaksi;
- fund balance dapat dihitung.

---

### D. Project & Activity

Fitur:

- Program;
- Project;
- Activity;
- project manager;
- activity owner;
- planned budget;
- planned date;
- location;
- linked fund;
- linked budget line.

Lifecycle Activity:

```text
Planned → Approved → In Progress → Completed → Reported → Verified → Closed
```

Acceptance criteria:

- project dapat dibuat dan dikaitkan ke fund;
- activity dapat dibuat di bawah project;
- transaksi dapat dikaitkan dengan project dan activity;
- laporan project dapat menampilkan budget vs actual.

---

### E. Budget Line & Allocation

Fitur:

- Budget Line master;
- Project Budget;
- Activity Budget;
- Fund Allocation;
- approved budget;
- committed amount;
- actual amount;
- available amount.

Konsep angka:

```text
Available Budget = Approved Budget - Commitment - Actual
```

Catatan: sistem harus menghindari double counting ketika commitment berubah menjadi actual.

Acceptance criteria:

- fund dapat dialokasikan ke project/activity;
- transaksi mengurangi budget yang sesuai;
- budget vs actual dapat ditampilkan;
- sistem memberi peringatan jika transaksi melebihi budget.

---

### F. Cash / Bank Receipt & Disbursement Dasar

Fitur:

- form sederhana penerimaan kas/bank;
- form sederhana pengeluaran kas/bank;
- single-entry user experience;
- double-entry accounting output;
- fund-aware transaction;
- project/activity/budget line tagging.

Contoh penerimaan:

```text
Dr Bank
    Cr Pendapatan Donasi / Pendapatan Grant / Dana Diterima di Muka
```

Contoh pengeluaran:

```text
Dr Beban Program / Uang Muka / Aset
    Cr Bank
```

Acceptance criteria:

- user dapat mencatat penerimaan kas/bank;
- user dapat mencatat pengeluaran kas/bank;
- GL Entry terbentuk di ERPNext;
- transaksi membawa fund, project, activity, dan budget line;
- laporan fund utilization membaca transaksi tersebut.

---

### G. Advance & Liquidation Dasar

Fitur:

- Advance Request;
- approval;
- Advance Payment;
- Liquidation;
- Refund;
- Additional Payment;
- outstanding advance;
- advance aging.

Workflow:

```text
Request
→ Budget Check
→ Approval
→ Payment
→ Pending Liquidation
→ Liquidation Submitted
→ Finance Review
→ Closed / Refund / Additional Payment
```

Acceptance criteria:

- staff dapat mengajukan advance;
- finance dapat membayar advance;
- liquidation dapat dibuat dengan bukti;
- sistem menghitung selisih lebih/kurang;
- outstanding advance dapat dilaporkan per staff, fund, project, dan aging.

---

### H. Evidence Requirement Dasar

Fitur:

- Evidence Type;
- Evidence Requirement;
- attachment pada transaksi/activity;
- evidence completeness status;
- checklist sederhana.

Jenis evidence MVP:

```text
Invoice
Receipt
Payment Proof
Attendance List
Activity Report
Photo
Approval Memo
Quotation
Delivery Note
```

Acceptance criteria:

- transaksi dapat memiliki evidence;
- sistem dapat menandai evidence lengkap/tidak lengkap;
- laporan dapat menampilkan transaksi tanpa evidence wajib.

---

### I. Basic Reporting

Laporan MVP:

- Fund Utilization Report;
- Budget vs Actual Report;
- Project Expense Report;
- Advance Aging Report;
- Evidence Completeness Report;
- Cash/Bank Transaction Report;
- Basic Dashboard.

Acceptance criteria:

- laporan dapat difilter berdasarkan fund, project, period, dan budget line;
- setiap angka bisa di-drill down ke transaksi;
- transaksi bisa menampilkan evidence terkait.

---

## 3.4 MVP Non-goals

Hal yang sengaja belum menjadi target MVP:

- laporan ISAK 35 penuh;
- donor report template kompleks;
- procurement threshold rule penuh;
- fixed asset depreciation otomatis;
- bank reconciliation otomatis;
- fundraising payment gateway;
- mobile/offline field app;
- impact measurement penuh;
- multi-language polish penuh;
- hosted SaaS automation.

---

## 3.5 MVP Definition of Done

MVP dianggap selesai jika Fundara dapat:

1. membuat funding source;
2. membuat fund dengan restriction type;
3. mengalokasikan fund ke project/activity;
4. membuat budget line;
5. mencatat penerimaan kas/bank;
6. mencatat pengeluaran kas/bank;
7. menjalankan advance dan liquidation;
8. melampirkan evidence;
9. menghasilkan fund utilization report;
10. menghasilkan budget vs actual;
11. menghasilkan advance aging;
12. menunjukkan transaksi yang belum lengkap evidence;
13. berjalan stabil di Ubuntu Server 24.04.4;
14. memiliki dokumentasi instalasi awal;
15. memiliki demo dataset.

---

# 4. v0.2 — Grant & Donor Reporting

## 4.1 Tujuan

Membangun kemampuan grant management dan laporan donor yang lebih kuat.

## 4.2 Fitur

### Grant Management

- Donor master;
- Grant master;
- grant agreement metadata;
- grant period;
- grant currency;
- implementation period;
- reporting period;
- grant manager;
- finance focal point;
- lifecycle grant.

Lifecycle:

```text
Pipeline → Awarded → Active → Extended → Closing → Closed
```

### Grant Budget

- Grant Budget;
- Grant Budget Line;
- Budget Version;
- Budget Revision;
- donor budget mapping;
- budget transfer;
- variance explanation.

### Donor Reporting

- donor financial report;
- budget vs actual per donor;
- expenditure by budget line;
- supporting document register;
- advance outstanding per donor;
- donor report workflow.

Workflow:

```text
Generated → Finance Review → Program Review → Approved → Submitted → Archived
```

### Grant Compliance Dasar

- eligible/ineligible cost;
- grant period validation;
- required evidence by grant;
- warning transaksi di luar periode grant.

## 4.3 Acceptance Criteria

- grant dapat dibuat dan dikaitkan ke fund;
- grant budget dapat di-versioning;
- transaksi dapat masuk ke donor report;
- donor report dapat diekspor ke XLSX/PDF;
- supporting document register dapat dihasilkan.

---

# 5. v0.3 — Fundraising, Donation & Campaign Fund

## 5.1 Tujuan

Mendukung organisasi yang memiliki pendanaan dari fundraising publik, donasi individu, corporate giving, dan campaign restricted.

## 5.2 Fitur

### Campaign Management

- Fundraising Campaign;
- target amount;
- campaign period;
- restricted/unrestricted purpose;
- campaign manager;
- public message;
- campaign status.

### Donation Management

- Donation Receipt;
- donor individual/corporate;
- anonymous donation;
- donation channel;
- receipt number;
- acknowledgment status;
- recurring donation dasar.

### Campaign Fund Reporting

- collected amount;
- fundraising cost;
- net available fund;
- utilization by activity;
- remaining balance;
- public accountability report.

### Unrestricted Donation

- unrestricted donation fund;
- board allocation;
- transfer to project/program;
- usage report.

## 5.3 Acceptance Criteria

- campaign dapat dibuat dan menerima donasi;
- donasi dapat masuk ke fund;
- campaign utilization report dapat dibuat;
- unrestricted donation dapat dialokasikan ke project.

---

# 6. v0.4 — Procurement & Operations Compliance

## 6.1 Tujuan

Memperkuat kontrol pengadaan dan operasi agar sesuai dengan aturan organisasi, donor, dan fund restriction.

## 6.2 Fitur

### Procurement Rule

- Procurement Threshold Rule;
- Procurement Method;
- quotation requirement;
- donor-specific procurement rule;
- exception approval.

### Procurement Documents

- Purchase Request extension;
- Supplier Quotation extension;
- Bid Analysis;
- Purchase Order compliance check;
- Service Acceptance;
- Goods Receipt validation.

### Vendor Compliance

- Supplier Due Diligence;
- Conflict of Interest Declaration;
- vendor blacklist/warning;
- vendor document expiry.

### Operations

- Travel Request;
- Vehicle Request;
- Distribution Record;
- Asset assignment dasar;
- inventory movement by project/fund.

## 6.3 Acceptance Criteria

- purchase request dapat divalidasi terhadap budget dan procurement threshold;
- transaksi tertentu wajib quotation;
- bid analysis dapat dibuat;
- PO dapat dikaitkan ke fund/project/activity;
- procurement tracker dapat ditampilkan.

---

# 7. v0.5 — Nonprofit Accounting, ISAK 35, Fixed Asset & Bank Reconciliation

## 7.1 Tujuan

Membuat Fundara lebih siap untuk laporan keuangan organisasi nirlaba, khususnya di Indonesia.

## 7.2 Fitur

### Accounting Standards

- Accounting Standard Profile;
- ISAK 35 report template;
- FASB/ASC 958 conceptual mapping;
- net asset classification;
- restriction release.

### ISAK 35 Reports

- Laporan Posisi Keuangan;
- Laporan Penghasilan Komprehensif / Aktivitas;
- Laporan Perubahan Aset Neto;
- Laporan Arus Kas;
- Catatan atas Laporan Keuangan template dasar.

### Chart of Account Template

- template CoA nirlaba;
- mapping akun ke net asset class;
- mapping akun ke report line ISAK 35.

### Fixed Asset & Depreciation

- Fixed Asset fund tagging;
- asset per donor/project;
- monthly depreciation;
- depreciation schedule;
- donor reporting treatment vs accounting depreciation;
- disposal dasar.

### Bank Reconciliation

- bank statement import CSV/XLSX;
- auto matching dasar;
- manual matching;
- reconciliation status;
- bank reconciliation report.

### Opening Balance Assistant

- opening balance import;
- net asset balancing;
- opening fund balance;
- opening donor balance;
- validation report.

## 7.3 Acceptance Criteria

- laporan ISAK 35 dasar dapat dihasilkan;
- aset tetap dapat dicatat dengan fund/donor tagging;
- depresiasi bulanan dapat diposting;
- bank statement dapat direkonsiliasi;
- opening balance dapat diseimbangkan otomatis.

---

# 8. v0.6 — Impact & Learning

## 8.1 Tujuan

Menghubungkan dana dan aktivitas dengan hasil serta dampak program.

## 8.2 Fitur

### Impact Framework

- Impact Framework;
- Outcome;
- Output;
- Indicator;
- Indicator Target;
- Indicator Achievement.

### Activity Result

- output per activity;
- beneficiary summary;
- disaggregation dasar;
- evidence impact;
- field report integration.

### Learning

- Learning Note;
- issue/lesson learned;
- feedback/complaint dasar;
- recommendation tracking.

### Cost per Output

- cost by activity;
- output achievement;
- cost per participant/output;
- basic value-for-money insight.

## 8.3 Acceptance Criteria

- project dapat memiliki indicator;
- activity dapat mencatat output;
- report dapat menampilkan target vs achievement;
- sistem dapat menghitung cost per output sederhana.

---

# 9. v0.7 — Reporting Package, Dashboard & Audit Pack

## 9.1 Tujuan

Membuat Fundara kuat sebagai platform akuntabilitas dan pelaporan.

## 9.2 Fitur

### Report Package

- Report Template;
- Reporting Period;
- Report Package;
- report review workflow;
- report archive.

### Audit Pack

- audit pack generator;
- supporting document register;
- evidence completeness check;
- donor/project/fund audit package;
- export zip/pdf index.

### Dashboard

- Fund Balance Dashboard;
- Budget vs Actual Dashboard;
- Donor Utilization Dashboard;
- Advance Aging Dashboard;
- Cash Position Dashboard;
- Grant Burn Rate Dashboard;
- Data Health Dashboard;
- Evidence Completeness Dashboard.

## 9.3 Acceptance Criteria

- report package dapat dibuat per fund/project/donor;
- audit pack dapat menarik daftar transaksi dan evidence;
- dashboard utama dapat digunakan oleh finance, program, dan executive.

---

# 10. v0.8 — Integration, Import/Export & Data Health

## 10.1 Tujuan

Meningkatkan interoperabilitas Fundara dan kualitas data.

## 10.2 Fitur

### Import/Export

- import budget XLSX;
- import transaction XLSX;
- import bank statement;
- import asset;
- import indicator target;
- export XLSX/PDF;
- export report package;
- import validation log.

### Integration

- REST API documentation;
- webhook events;
- Kobo/ODK import prototype;
- payment gateway abstraction prototype;
- BI connector documentation.

### Data Health Check

- transaction without fund;
- transaction without budget line;
- missing evidence;
- unreconciled bank item;
- overdue advance;
- negative fund balance;
- transaction outside grant period;
- asset without depreciation schedule;
- data readiness score.

## 10.3 Acceptance Criteria

- user dapat import budget dan transaksi;
- error import dapat diperbaiki;
- data health check menghasilkan daftar masalah actionable;
- API awal terdokumentasi.

---

# 11. v0.9 — Hardening, Security, Localization & Deployment

## 11.1 Tujuan

Mempersiapkan Fundara menuju stable v1.0.

## 11.2 Fitur

### Security

- permission review;
- role matrix;
- fund/project-level access;
- audit trail review;
- 2FA recommendation;
- security checklist;
- backup encryption guide.

### Deployment

- Ubuntu 24.04.4 deployment guide;
- single-server production guide;
- staging guide;
- backup/restore guide;
- monitoring guide;
- upgrade guide;
- troubleshooting guide.

### Localization

- Bahasa Indonesia;
- English;
- bilingual report labels;
- Indonesian nonprofit CoA;
- ISAK 35 terminology;
- date/currency formatting.

### Testing & Stability

- automated test baseline;
- migration test;
- sample data test;
- report test;
- upgrade dry-run guide;
- release checklist.

## 11.3 Acceptance Criteria

- Fundara bisa dipasang dari dokumentasi di Ubuntu 24.04.4;
- backup dan restore berhasil diuji;
- permission role dasar tervalidasi;
- UI utama tersedia dalam Indonesia dan Inggris;
- tidak ada blocker besar untuk production pilot.

---

# 12. v1.0 — Stable Production Release

## 12.1 Tujuan v1.0

v1.0 adalah rilis stabil pertama Fundara untuk digunakan oleh NGO kecil-menengah, yayasan, komunitas, dan social enterprise dengan kebutuhan fund, project, finance, evidence, dan reporting yang nyata.

v1.0 bukan berarti semua kemungkinan fitur sudah lengkap. v1.0 berarti Fundara cukup stabil, terdokumentasi, dan aman untuk production pilot.

---

## 12.2 Scope v1.0

v1.0 harus mencakup:

### Core Platform

- Fundara custom app;
- ERPNext/Frappe compatibility;
- installation guide;
- demo dataset;
- role-based workspace;
- basic dashboard;
- bilingual interface baseline.

### Fund Management

- Funding Source;
- Fund;
- Fund Restriction;
- Fund Allocation;
- Fund Transfer;
- Fund Balance;
- restriction classification.

### Program & Project

- Program;
- Project;
- Activity;
- Workplan dasar;
- Deliverable dasar;
- field report dasar.

### Financial Accountability

- Cash/Bank Receipt;
- Cash/Bank Disbursement;
- Journal Type;
- Budget Line;
- Program/Project Budget;
- Budget Revision;
- Advance;
- Liquidation;
- Refund/Additional Payment;
- Opening Balance Assistant;
- Data Health Check.

### Nonprofit Accounting

- nonprofit CoA template;
- ISAK 35 report baseline;
- net asset classification;
- basic restriction release;
- donor/fund dimension;
- fixed asset tagging;
- monthly depreciation;
- bank reconciliation baseline.

### Grant & Donor

- Donor;
- Grant;
- Grant Budget;
- Grant Reporting Period;
- Donor Financial Report;
- Supporting Document Register;
- Grant closeout checklist dasar.

### Fundraising & Campaign

- Campaign;
- Donation Receipt;
- restricted/unrestricted donation;
- campaign fund utilization;
- donor acknowledgment baseline.

### Procurement & Operations

- procurement threshold rule;
- bid analysis;
- purchase request extension;
- supplier due diligence baseline;
- service acceptance;
- travel request dasar;
- asset/inventory fund tagging.

### Evidence & Compliance

- Evidence Type;
- Evidence Requirement;
- Evidence Checklist;
- Compliance Rule;
- Compliance Check;
- Compliance Exception;
- Audit Pack baseline.

### Impact & Learning

- Impact Framework;
- Outcome;
- Output;
- Indicator;
- Indicator Target;
- Indicator Achievement;
- beneficiary summary;
- cost per output baseline.

### Reporting

- Fund Utilization Report;
- Budget vs Actual;
- Advance Aging;
- Donor Report;
- Campaign Report;
- ISAK 35 baseline reports;
- Evidence Completeness;
- Data Health;
- dashboard collection.

---

## 12.3 v1.0 Production Readiness Criteria

Fundara v1.0 dianggap production-ready jika memenuhi kriteria berikut.

### Functional Criteria

- Semua workflow utama berjalan dari draft sampai approved/closed.
- Transaksi fund-aware dan project-aware.
- Budget check berjalan untuk transaksi utama.
- Advance dan liquidation dapat digunakan end-to-end.
- Evidence requirement dapat divalidasi.
- Laporan utama dapat dihasilkan dan diekspor.

### Accounting Criteria

- GL Entry tetap balance.
- Transaksi kas/bank menghasilkan double-entry.
- CoA nonprofit tersedia.
- ISAK 35 baseline report tersedia.
- Fund balance dapat direkonsiliasi dengan GL.
- Opening balance dapat divalidasi.

### Security Criteria

- Role permission dasar terdokumentasi.
- Project/fund-level visibility diuji.
- Audit trail aktif.
- Tidak ada database service yang terbuka ke publik.
- Deployment guide mencakup SSL, firewall, backup, dan restore.

### Data Quality Criteria

- Data health check tersedia.
- Transaksi tanpa fund dapat dideteksi.
- Missing evidence dapat dideteksi.
- Overdue advance dapat dideteksi.
- Unreconciled bank transaction dapat dideteksi.

### Documentation Criteria

- README tersedia.
- Installation guide tersedia.
- Architecture document tersedia.
- Domain model tersedia.
- Accounting documentation tersedia.
- User guide dasar tersedia.
- Contributor guide tersedia.

### Open-source Criteria

- LICENSE tersedia.
- CONTRIBUTING.md tersedia.
- CODE_OF_CONDUCT.md tersedia.
- SECURITY.md tersedia.
- issue template tersedia.
- demo data tersedia.
- roadmap publik tersedia.

---

# 13. Post-v1.0 Direction

Setelah v1.0, pengembangan dapat bergerak ke area berikut.

## v1.1 — Mobile & Field Experience

- mobile-friendly activity report;
- offline-first form exploration;
- photo evidence upload optimization;
- field staff simplified UI.

## v1.2 — Advanced Donor & Grant Compliance

- donor-specific report templates;
- indirect cost calculation;
- co-funding rules;
- multi-currency grant reporting;
- grant closeout automation.

## v1.3 — Advanced Fundraising

- payment gateway integration;
- recurring donation;
- donor portal;
- campaign public page;
- QRIS/VA integration.

## v1.4 — Social Enterprise & Business Unit

- unit usaha P&L;
- product/service revenue;
- surplus allocation;
- inventory costing;
- tax support baseline.

## v1.5 — BI & Advanced Analytics

- Metabase/Superset integration;
- data mart;
- impact dashboard;
- sustainability dashboard;
- cost-effectiveness analytics.

## v2.0 — Multi-organization Platform

- hosted SaaS automation;
- site provisioning;
- centralized monitoring;
- marketplace/plugins;
- localization packs;
- partner implementation toolkit.

---

# 14. Suggested Milestone Labels for GitHub

```text
mvp
v0.2-grant-donor
v0.3-fundraising
v0.4-procurement-ops
v0.5-accounting-isak35
v0.6-impact-learning
v0.7-reporting-audit
v0.8-integration-data-health
v0.9-hardening
v1.0-stable
```

Suggested issue labels:

```text
domain
accounting
fund-management
grant
fundraising
procurement
impact
reporting
security
deployment
documentation
good-first-issue
help-wanted
breaking-change
migration
```

---

# 15. Roadmap Summary

```text
MVP
└── Fund, project, budget, transaction, advance, evidence, basic report

v0.2
└── Grant management and donor reporting

v0.3
└── Fundraising, donation, and campaign fund

v0.4
└── Procurement and operations compliance

v0.5
└── Nonprofit accounting, ISAK 35, assets, depreciation, bank reconciliation

v0.6
└── Impact framework and learning

v0.7
└── Reporting package, dashboard, audit pack

v0.8
└── Integration, import/export, data health

v0.9
└── Security, deployment, localization, hardening

v1.0
└── Stable production release for small-to-medium mission-driven organizations
```

---

# 16. Closing Statement

Fundara v1.0 harus menjadi fondasi yang cukup kuat untuk organisasi misi sosial yang ingin berpindah dari spreadsheet terpisah menuju sistem yang lebih transparan, akuntabel, dan terhubung.

Fokus utama v1.0 bukan membangun semua fitur yang mungkin dibutuhkan NGO, tetapi membangun *core trust layer*:

> dana dapat ditelusuri, aktivitas dapat dipertanggungjawabkan, laporan dapat dihasilkan, dan dampak dapat mulai diukur.
