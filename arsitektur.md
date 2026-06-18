# Arsitektur Teknis Fundara

Fundara adalah **Mission Impact Platform** berbasis ERPNext/Frappe yang dirancang untuk membantu organisasi misi sosial menghubungkan sumber dana, operasi, akuntabilitas, dan dampak dalam satu alur kerja yang transparan.

Dokumen ini menjelaskan rancangan arsitektur teknis Fundara dengan asumsi deployment utama menggunakan **Ubuntu Server 24.04.4 LTS**, ERPNext/Frappe sebagai fondasi backend, dan custom app Fundara sebagai domain layer untuk kebutuhan NGO, yayasan, komunitas, social enterprise, dan organisasi berbasis misi sosial.

---

## 1. Premis Arsitektur Fundara

Fundara bukan sekadar aplikasi ERP. Secara teknis ia adalah:

> **Mission Impact Platform berbasis ERPNext/Frappe, dengan custom domain layer untuk fund stewardship, grant management, program delivery, financial accountability, evidence, compliance, dan impact reporting.**

Arsitektur Fundara harus menjaga dua hal sekaligus:

1. **Memanfaatkan kekuatan ERPNext/Frappe** untuk accounting, workflow, DocType, permission, report, role, API, dan extensibility.
2. **Tidak mencampur semua domain NGO langsung ke core ERPNext**, agar Fundara tetap upgrade-friendly, modular, dan sehat sebagai project open-source.

Prinsip teknis utama:

```text
No core modification.
ERPNext sebagai accounting dan ERP engine.
Fundara sebagai mission-impact domain layer.
Konfigurasi sebelum kustomisasi.
Domain Fundara modular dan dapat dikembangkan.
```

---

## 2. Stack Teknis Utama

Rekomendasi stack awal Fundara:

```text
Operating System       : Ubuntu Server 24.04.4 LTS
Application Framework  : Frappe Framework
ERP Core               : ERPNext
Custom App             : fundara
Database               : MariaDB
Cache / Queue          : Redis
Web Server             : Nginx
Process Manager        : Supervisor
Background Jobs        : Frappe Workers + Scheduler
Runtime                : Python + Node.js
Frontend Assets        : Frappe build system
SSL                    : Let's Encrypt / Certbot
Backup                 : bench backup + database/file backup
Monitoring             : Netdata / Prometheus + Grafana / Uptime Kuma
BI Optional            : Metabase / Apache Superset
Object Storage Optional: S3-compatible storage / MinIO
```

---

## 3. Arsitektur Konseptual Fundara

Secara konseptual:

```text
User
 ↓
Fundara UI / Portal / Dashboard
 ↓
Frappe Framework
 ↓
ERPNext Core + Fundara Custom App
 ↓
MariaDB + Redis + File Storage
 ↓
Reporting / Integration / Backup / Monitoring
```

Lebih detail:

```text
Fundara
├── Presentation Layer
│   ├── Desk UI
│   ├── Role-based Workspace
│   ├── Portal
│   ├── Dashboard
│   └── Report UI
│
├── Application Layer
│   ├── ERPNext Core
│   ├── Fundara Custom App
│   ├── Workflow Engine
│   ├── Permission Layer
│   ├── Notification Layer
│   └── Background Job Layer
│
├── Domain Layer
│   ├── Organization Context
│   ├── Funding Context
│   ├── Fund Stewardship Context
│   ├── Mission Delivery Context
│   ├── Financial Accountability Context
│   ├── Procurement & Operations Context
│   ├── Evidence & Compliance Context
│   ├── Impact & Learning Context
│   └── Reporting Context
│
├── Data Layer
│   ├── MariaDB
│   ├── Redis Cache
│   ├── Redis Queue
│   ├── File Attachments
│   └── Audit Logs
│
├── Integration Layer
│   ├── REST API
│   ├── Webhooks
│   ├── Import / Export
│   ├── Bank Statement Import
│   ├── Kobo / ODK
│   ├── Payment Gateway
│   └── BI Tools
│
└── Operations Layer
    ├── Nginx
    ├── Supervisor
    ├── SSL
    ├── Backup
    ├── Monitoring
    ├── Logging
    └── Security Hardening
```

---

## 4. Arsitektur Aplikasi: ERPNext Core + Fundara App

Fundara sebaiknya dibuat sebagai **custom Frappe app**, misalnya:

```text
fundara
```

Struktur app dalam bench:

```text
apps/
├── frappe
├── erpnext
└── fundara
```

Struktur internal Fundara:

```text
fundara/
├── fundara/
│   ├── organization/
│   ├── funding/
│   ├── fund_stewardship/
│   ├── mission_delivery/
│   ├── financial_accountability/
│   ├── procurement_operations/
│   ├── evidence_compliance/
│   ├── impact_learning/
│   ├── reporting/
│   ├── integrations/
│   ├── public/
│   ├── templates/
│   └── hooks.py
│
├── docs/
├── tests/
├── patches/
├── fixtures/
└── README.md
```

---

## 5. Pemetaan ERPNext Core dan Custom Fundara

Agar tidak terjadi over-customization, domain Fundara perlu dipetakan dengan jelas ke ERPNext core.

| Kebutuhan Fundara | ERPNext Core | Custom Fundara |
|---|---:|---:|
| General Ledger | Ya | Konfigurasi nonprofit |
| Chart of Account | Ya | Template NGO/ISAK 35 |
| Bank/Cash transaction | Ya | UI sederhana + fund-aware wrapper |
| Payment Entry | Ya | Fund dimension & donor reporting |
| Journal Entry | Ya | Journal type nonprofit |
| Project | Ya | Perluasan fund/activity/impact |
| Task | Ya | Bisa dipakai |
| Purchase Request | Ya | Tambahan fund/budget/compliance |
| Purchase Order | Ya | Tambahan donor rule |
| Purchase Invoice | Ya | Tambahan evidence requirement |
| Asset | Ya | Tambahan donor/fund/project tagging |
| Depreciation | Ya | Kebijakan nonprofit/donor treatment |
| Stock | Ya | Untuk inventory dan distribusi |
| Selling | Ya | Untuk unit usaha |
| CRM | Opsional | Donor/fundraising lebih baik custom |
| Fund | Tidak | Custom |
| Grant | Tidak cukup | Custom |
| Donor reporting | Tidak cukup | Custom |
| Campaign fund | Tidak cukup | Custom |
| Advance/liquidation NGO | Sebagian | Custom workflow |
| Evidence requirement | Tidak | Custom |
| Impact indicator | Tidak | Custom |
| ISAK 35 reports | Tidak cukup | Custom report |

Prinsipnya:

> ERPNext menangani accounting engine dan business document standar. Fundara menangani konteks dana, misi, compliance, evidence, dan impact.

---

## 6. Arsitektur Domain Module Fundara

### 6.1 Organization Module

Bertanggung jawab untuk:

- organisasi;
- cabang;
- department;
- cost center mapping;
- user role;
- approval matrix;
- fiscal year;
- language profile.

DocType awal:

```text
Organization Profile
Office
Department Profile
Approval Matrix
Delegation of Authority
Localization Profile
```

ERPNext sudah memiliki Company, Branch, Department, Cost Center, dan User. Fundara tidak perlu menduplikasi semuanya. Fundara cukup membuat extension dan mapping.

---

### 6.2 Funding Module

Bertanggung jawab untuk sumber dana.

DocType:

```text
Funding Source
Donor
Fundraising Campaign
Business Unit Profile
Donation Receipt
Pledge
Funding Agreement
```

Fungsi:

- mencatat asal dana;
- membedakan grant, donasi, campaign, unit usaha, internal reserve;
- mencatat donor/campaign/business source;
- menjadi basis pembentukan Fund.

---

### 6.3 Fund Stewardship Module

Ini adalah jantung Fundara.

DocType:

```text
Fund
Fund Restriction
Fund Allocation
Fund Transfer
Fund Balance Snapshot
Bridging Fund Settlement
Restriction Release
```

Fungsi:

- mengelola dana sebagai kantong amanah;
- restricted/unrestricted/board-designated;
- alokasi ke project/activity;
- transfer antar fund;
- release from restriction;
- saldo per fund.

---

### 6.4 Mission Delivery Module

DocType:

```text
Program
Project Extension
Activity
Workplan
Deliverable
Field Report
Location Profile
Beneficiary Group
```

Fungsi:

- menghubungkan fund ke kerja program;
- activity planning;
- workplan;
- output;
- field report;
- evidence kegiatan.

---

### 6.5 Financial Accountability Module

DocType/custom report:

```text
Accounting Standard Profile
Chart of Account Template
Cash Receipt
Cash Disbursement
Journal Type
Program Budget
Project Budget
Budget Line
Budget Revision
Advance
Advance Payment
Liquidation
Refund
Opening Balance Assistant
Net Asset Class
Data Health Check
Bank Reconciliation Extension
Donor Financial Report
```

Fungsi:

- ISAK 35;
- ASC 958 conceptual mapping;
- single-entry UI untuk kas/bank, double-entry engine;
- budget vs actual;
- advance/liquidation;
- fixed asset tagging;
- bank reconciliation;
- opening balance;
- donor financial report.

---

### 6.6 Procurement & Operations Module

Memperluas Buying, Stock, dan Asset ERPNext.

DocType:

```text
Procurement Threshold Rule
Procurement Method
Bid Analysis
Supplier Due Diligence
Conflict of Interest Declaration
Service Acceptance
Distribution Record
Travel Request
Vehicle Request
```

Fungsi:

- procurement rule per donor/fund;
- threshold;
- quotation requirement;
- PO compliance;
- asset/inventory distribution;
- travel/vehicle request.

---

### 6.7 Evidence & Compliance Module

DocType:

```text
Evidence Type
Evidence Requirement
Evidence Checklist
Compliance Rule
Compliance Check
Compliance Exception
Audit Pack
Document Register
```

Fungsi:

- bukti wajib per transaksi/activity/fund;
- checklist kelengkapan;
- rule compliance donor;
- audit-ready document pack;
- exception approval.

---

### 6.8 Impact & Learning Module

DocType:

```text
Impact Framework
Outcome
Output
Indicator
Indicator Target
Indicator Achievement
Beneficiary Summary
Feedback
Learning Note
```

Fungsi:

- logframe;
- outcome/output;
- target vs achievement;
- beneficiary reach;
- cost per output;
- feedback dan learning.

---

### 6.9 Reporting Module

DocType/report:

```text
Report Template
Reporting Period
Report Package
Report Submission
Fund Utilization Report
Donor Report
Campaign Report
Board Report
Public Impact Report
Audit Pack Report
```

Fungsi:

- generate laporan;
- workflow review;
- export PDF/XLSX/DOCX;
- report archive;
- submission tracking.

---

## 7. Arsitektur Data

### 7.1 Prinsip Data

Fundara harus menggunakan pendekatan:

```text
Core accounting data tetap di ERPNext.
Mission/accountability data ada di Fundara.
Relasi dilakukan melalui custom fields, accounting dimensions, dan linked DocTypes.
```

Contoh perluasan pada Payment Entry:

```text
Payment Entry
├── fund
├── project
├── activity
├── budget_line
├── donor
├── grant
├── reporting_period
└── evidence_status
```

### 7.2 Universal Dimensions

Dimensi wajib:

```text
Fund
Project
Cost Center
Budget Line
```

Dimensi conditional:

```text
Activity
Donor
Grant
Campaign
Business Unit
Location
Reporting Period
Restriction Class
```

### 7.3 Jangan Masukkan Semua ke Chart of Account

Chart of Account harus tetap generik. Donor, fund, campaign, project, dan activity jangan dijadikan akun. Gunakan accounting dimension dan report filter.

---

## 8. Arsitektur Accounting

Untuk accounting engine:

```text
User Form Sederhana
    ↓
Validation Fundara
    ↓
ERPNext Accounting Document
    ↓
GL Entry
    ↓
Fund / Donor / Project Report
```

Contoh penerimaan kas:

```text
Cash Receipt Form
    ↓
Validasi fund, restriction, donor/campaign
    ↓
Payment Entry / Journal Entry
    ↓
GL Entry
    ↓
Fund Balance + ISAK 35 Report + Donor Report
```

Contoh advance:

```text
Advance Request
    ↓
Budget Check
    ↓
Approval
    ↓
Payment Entry
    ↓
Outstanding Advance
    ↓
Liquidation
    ↓
Expense Posting / Refund / Additional Payment
```

Prinsip utama:

> User input sederhana, accounting engine tetap double-entry.

---

## 9. Arsitektur Deployment di Ubuntu 24.04.4

### 9.1 Single Server Production Awal

Untuk MVP dan organisasi kecil-menengah:

```text
Ubuntu 24.04.4 Server
├── Nginx
├── Frappe Bench
│   ├── frappe
│   ├── erpnext
│   └── fundara
├── Gunicorn / Web Workers
├── Background Workers
├── Scheduler
├── Redis Cache
├── Redis Queue
├── MariaDB
├── Supervisor
├── Certbot
└── Backup Script
```

Cocok untuk:

- pilot project;
- demo;
- NGO kecil-menengah;
- staging;
- early production.

Kelebihan:

- sederhana;
- murah;
- mudah dikelola;
- sesuai pola standar Frappe/ERPNext.

Kekurangan:

- scaling terbatas;
- database dan aplikasi di mesin yang sama;
- backup/HA harus dirancang hati-hati.

---

## 10. Recommended Server Sizing

### 10.1 Pilot

```text
CPU     : 2 vCPU
RAM     : 4 GB minimum, 8 GB recommended
Storage : 80-100 GB SSD
OS      : Ubuntu Server 24.04.4 LTS
```

### 10.2 Production Kecil-Menengah

```text
CPU     : 4 vCPU
RAM     : 8-16 GB
Storage : 150-300 GB SSD
Backup  : remote backup wajib
```

### 10.3 Production Lebih Serius

```text
App Server      : 4-8 vCPU, 16 GB RAM
Database Server : 4-8 vCPU, 16-32 GB RAM
Storage         : SSD/NVMe
Object Storage  : S3-compatible untuk file
Backup          : offsite + tested restore
```

---

## 11. Arsitektur Production Bertahap

### Tahap 1 — Single VM

```text
[User]
  ↓ HTTPS
[Nginx]
  ↓
[Frappe/ERPNext/Fundara]
  ↓
[MariaDB + Redis + File Storage]
```

Ini cukup untuk MVP.

### Tahap 2 — Separate Database

```text
[User]
  ↓
[Nginx + App Server]
  ↓
[Frappe Workers]
  ↓
[MariaDB Server]
  ↓
[Backup Storage]
```

Redis bisa tetap di app server atau dipisah.

### Tahap 3 — Scalable Deployment

```text
[Load Balancer]
  ↓
[App Server 1] ─┐
[App Server 2] ─┼── [Redis]
[Worker Server] ┘
  ↓
[MariaDB Primary]
  ↓
[Replica / Backup]
  ↓
[S3-compatible File Storage]
```

Tahap ini cocok untuk multi-tenant, banyak organisasi, atau deployment nasional.

---

## 12. Multi-tenancy Strategy

Frappe mendukung konsep multi-site dalam satu bench. Untuk Fundara, ada dua pilihan.

### Opsi A — One Site Per Organization

```text
site-ngo-a.fundara.org
site-ngo-b.fundara.org
site-ngo-c.fundara.org
```

Kelebihan:

- isolasi data kuat;
- konfigurasi tiap organisasi bebas;
- backup/restore per organisasi lebih mudah;
- cocok untuk SaaS open-source hosted.

Kekurangan:

- maintenance lebih kompleks;
- resource lebih besar jika site banyak.

### Opsi B — One Site, Many Organizations

Satu site berisi banyak organisasi.

Kelebihan:

- lebih hemat resource;
- cocok untuk network organisasi dengan governance yang sama.

Kekurangan:

- permission lebih kompleks;
- risiko kebocoran data antar organisasi lebih besar;
- tidak ideal untuk SaaS publik.

Rekomendasi:

> Untuk Fundara, gunakan **one site per organization** sebagai default SaaS/hosted architecture.

---

## 13. Repository Architecture Open-source

Struktur repository yang disarankan:

```text
fundara/
├── README.md
├── LICENSE
├── CONTRIBUTING.md
├── CODE_OF_CONDUCT.md
├── SECURITY.md
├── ROADMAP.md
├── docker-compose.yml
├── docs/
│   ├── mission.md
│   ├── vision-principle.md
│   ├── domain.md
│   ├── architecture.md
│   ├── deployment/
│   ├── accounting/
│   └── domain-contexts/
├── fundara/
│   ├── organization/
│   ├── funding/
│   ├── fund_stewardship/
│   ├── mission_delivery/
│   ├── financial_accountability/
│   ├── procurement_operations/
│   ├── evidence_compliance/
│   ├── impact_learning/
│   ├── reporting/
│   └── integrations/
├── tests/
├── fixtures/
└── scripts/
```

---

## 14. Environment Strategy

Minimal environment:

```text
Development
Staging
Production
```

### Development

Untuk developer:

- bisa pakai local bench;
- bisa pakai Docker;
- sample dataset;
- developer mode on.

### Staging

Untuk testing:

- mirip production;
- dummy donor/project/fund;
- test migration;
- test backup/restore;
- test reports.

### Production

Untuk user nyata:

- HTTPS wajib;
- backup wajib;
- monitoring wajib;
- restricted shell access;
- audit log aktif.

---

## 15. Security Architecture

Fundara akan menyimpan data sensitif:

- donor;
- beneficiary;
- staff advance;
- laporan keuangan;
- dokumen grant;
- kontrak;
- bukti transaksi;
- data program.

Security minimum:

```text
HTTPS only
Role-based access control
Permission by fund/project/office
Audit trail
Strong password policy
2FA untuk role kritikal
Regular backup
Encrypted backup storage
Server firewall
SSH key only
Disable root login
Database tidak exposed ke public
File permission hardening
Log review
```

Permission khusus:

```text
Finance dapat melihat semua transaksi keuangan.
Project Manager hanya melihat project sendiri.
Donor Viewer hanya melihat laporan yang disetujui.
Auditor read-only dengan scope tertentu.
Field Staff hanya melihat activity dan advance miliknya.
```

---

## 16. Backup Architecture

Backup tidak cukup hanya database.

Fundara harus backup:

```text
MariaDB database
Private files
Public files
Site config
Custom app version
Fixtures/configuration
```

Strategi:

```text
Daily backup
Weekly full backup
Monthly archive
Offsite storage
Restore test berkala
```

Minimal:

```text
bench backup --with-files
```

Untuk production:

```text
Local backup
→ Encrypted archive
→ Remote S3-compatible storage
→ Retention policy
→ Restore drill
```

---

## 17. Observability

Monitoring awal:

```text
Uptime
CPU
RAM
Disk usage
MariaDB health
Redis health
Nginx status
Supervisor process status
Background job queue
Scheduler health
Backup success/failure
SSL expiry
```

Tool ringan:

```text
Uptime Kuma
Netdata
Prometheus + Grafana
Loki untuk logs, bila perlu
```

Application-level health check:

```text
/health
Scheduler last run
Queue length
Failed jobs
Error log count
Data health score
```

---

## 18. Integration Architecture

Fundara perlu siap integrasi.

### 18.1 Bank Statement

Awal:

```text
CSV / XLSX import
```

Lanjut:

```text
Bank API / Open Banking jika tersedia
```

### 18.2 Fundraising / Payment

Integrasi potensial:

```text
Midtrans
Xendit
Stripe
PayPal
QRIS
Bank transfer virtual account
```

### 18.3 Field Data

Integrasi:

```text
KoboToolbox
ODK
Google Forms
CommCare
```

### 18.4 BI

Integrasi:

```text
Metabase
Apache Superset
Power BI
Looker Studio
```

### 18.5 Document Storage

Opsional:

```text
Local file storage
S3-compatible storage
MinIO
AWS S3
Wasabi
Backblaze B2
```

---

## 19. Arsitektur Reporting

Reporting Fundara terdiri dari beberapa jenis.

```text
Operational Reports
├── Advance aging
├── Pending approval
├── Budget utilization
├── Procurement tracker
└── Evidence completeness

Financial Reports
├── ISAK 35 reports
├── Statement of financial position
├── Activity report
├── Net asset report
├── Cash flow
└── Trial balance

Donor Reports
├── Budget vs actual
├── Expenditure by budget line
├── Supporting document register
├── Fund utilization
└── Variance explanation

Impact Reports
├── Indicator achievement
├── Beneficiary reach
├── Output report
├── Outcome progress
└── Cost per output
```

Secara teknis:

```text
MariaDB / ERPNext Data
    ↓
Query Report / Script Report
    ↓
Report Template
    ↓
Review Workflow
    ↓
Export XLSX / PDF / DOCX
    ↓
Report Archive
```

---

## 20. Arsitektur File dan Evidence

Evidence adalah bagian penting dari Fundara.

Rekomendasi:

```text
Files attached to transactions
Files categorized by Evidence Type
Evidence Requirement validates completeness
Audit Pack pulls files by report period/fund/project
```

Struktur metadata:

```text
Evidence
├── evidence_type
├── linked_doctype
├── linked_document
├── fund
├── project
├── activity
├── transaction
├── reporting_period
├── uploaded_by
├── uploaded_at
├── verification_status
└── retention_policy
```

Untuk production yang lebih besar, file attachment sebaiknya bisa diarahkan ke S3-compatible storage.

---

## 21. Arsitektur Background Jobs

Pekerjaan yang tidak boleh dilakukan secara synchronous:

```text
Generate large donor report
Generate audit pack
Run data health check
Import large Excel file
Export large report
Send email notifications
Post recurring depreciation
Create fund balance snapshot
Run bank auto-matching
```

Gunakan Frappe background jobs:

```text
Short queue
Long queue
Scheduled jobs
```

---

## 22. Arsitektur Data Quality

Data quality harus menjadi bagian arsitektur, bukan fitur tambahan.

```text
Input Validation
    ↓
Document Workflow Validation
    ↓
Data Health Check
    ↓
Report Readiness Score
    ↓
Audit Readiness Score
```

Contoh score:

```text
Fund Health Score
Grant Reporting Readiness
Evidence Completeness Score
Bank Reconciliation Score
Advance Risk Score
```

---

## 23. Deployment Baseline di Ubuntu 24.04.4

Dokumen teknis deployment sebaiknya dibagi menjadi:

```text
docs/deployment/
├── ubuntu-24.04.md
├── single-server.md
├── production-hardening.md
├── backup-restore.md
├── monitoring.md
├── ssl-domain.md
├── update-upgrade.md
└── troubleshooting.md
```

Komponen OS-level:

```text
Ubuntu Server 24.04.4 LTS
OpenSSH
UFW firewall
Nginx
MariaDB
Redis
Supervisor
Python runtime
Node.js runtime
Yarn
wkhtmltopdf / PDF dependencies if needed
Certbot
fail2ban optional
```

---

## 24. Rekomendasi Production Profile

### Profile A — Community / Demo

```text
1 VM
2 vCPU
4 GB RAM
80 GB SSD
Single site
Daily backup
```

### Profile B — Small NGO

```text
1 VM
4 vCPU
8 GB RAM
150 GB SSD
1-3 sites
Daily remote backup
Monitoring ringan
```

### Profile C — Medium NGO / Network

```text
App + DB separated
8-16 GB RAM app
16-32 GB RAM DB
S3 file storage
Monitoring
Backup retention
Staging environment
```

### Profile D — Hosted SaaS

```text
Load balancer
Multiple app servers
Dedicated DB server
Redis server
Object storage
Automated provisioning
Per-site backup
Central monitoring
Security review
```

---

## 25. Arsitektur Upgrade

Karena Fundara dibangun di atas ERPNext/Frappe, upgrade harus hati-hati.

Prinsip:

```text
No core modification.
Use custom app.
Use fixtures for configuration.
Use patches for migrations.
Test upgrade in staging.
Backup before update.
Pin versions.
```

Versioning:

```text
Frappe version
ERPNext version
Fundara version
Site schema version
```

CI/CD open-source:

```text
Lint
Unit tests
Migration tests
DocType validation
Report tests
Sample data test
```

---

## 26. Rekomendasi Keputusan Awal

Keputusan teknis awal Fundara:

```text
Backend foundation:
ERPNext/Frappe

OS production:
Ubuntu Server 24.04.4 LTS

Deployment awal:
Single-server production profile

Custom app:
fundara

Multi-tenancy:
One site per organization

Database:
MariaDB

Web server:
Nginx

Process manager:
Supervisor

Cache/queue:
Redis

Reporting:
Frappe Query Report + Script Report + export

File storage:
Local first, S3-compatible later

BI:
Optional external Metabase/Superset

Architecture principle:
No ERPNext core modification
```

---

## 27. Ringkasan Arsitektur Fundara

Fundara sebaiknya dibangun sebagai:

> **Custom Frappe app di atas ERPNext, berjalan di Ubuntu 24.04.4 LTS, dengan ERPNext sebagai accounting/ERP engine dan Fundara sebagai mission-impact domain layer.**

Arsitektur awal paling realistis:

```text
Ubuntu 24.04.4
└── Frappe Bench
    ├── frappe
    ├── erpnext
    └── fundara
        ├── Funding
        ├── Fund Stewardship
        ├── Mission Delivery
        ├── Financial Accountability
        ├── Procurement & Operations
        ├── Evidence & Compliance
        ├── Impact & Learning
        └── Reporting
```

Arsitektur ini memberi fondasi yang:

- cukup kuat untuk accounting dan workflow;
- cukup fleksibel untuk domain NGO;
- siap open-source;
- bisa dimulai dari single server;
- bisa tumbuh menjadi SaaS multi-site;
- tetap menjaga positioning Fundara sebagai **Mission Impact Platform**, bukan sekadar ERP.
