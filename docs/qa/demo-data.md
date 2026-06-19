# Demo Data Specification — Yayasan Peduli Nusantara (YPN)

**Dokumen ini:** Spesifikasi dataset demo kanonik Fundara  
**Digunakan untuk:** Staging environment, E2E testing, UAT  
**Yang ini bukan:** JSON fixtures (JSON fixtures dibuat developer dari dokumen ini)  
**Terakhir diperbarui:** 2026-06-19  
**Versi:** 1.0

---

## Daftar Isi

1. [Prinsip Demo Data](#1-prinsip-demo-data)
2. [Layer 0 — ERPNext Built-in Configuration](#2-layer-0--erpnext-built-in-configuration)
3. [Organization Setup](#3-organization-setup)
4. [Funding Sources dan Donors](#4-funding-sources-dan-donors)
5. [Grant Setup](#5-grant-setup)
6. [Fund Setup](#6-fund-setup)
7. [Programs, Projects, dan Activities](#7-programs-projects-dan-activities)
8. [Transaksi In-Progress](#8-transaksi-in-progress)
9. [Cara Load Demo Data](#9-cara-load-demo-data)
10. [Reset Prosedur](#10-reset-prosedur)
11. [Checklist Verifikasi](#11-checklist-verifikasi)

---

## 1. Prinsip Demo Data

- **Realistis:** nama, angka, dan tanggal mencerminkan situasi NGO Indonesia nyata. Tidak ada "Test User 1" atau "Dummy Fund".
- **Semua bounded context MVP terwakili:** Organization, Funding, Grant, Fund Stewardship, Mission Delivery, Financial Accountability semuanya punya data.
- **Edge case disengaja:** ada skenario yang sengaja di-setup untuk menguji kondisi batas (advance hampir melewati budget, grant mendekati deadline, cash advance overdue).
- **Semua angka dalam IDR** kecuali yang memang dalam mata uang asing (grant USD/EUR dan fund terkait).
- **Semua nama orang:** nama Indonesia.
- **Periode waktu:** tahun 2026.
- **D-02 observable:** dataset harus memungkinkan tester memverifikasi bahwa Cash Advance berstatus Approved (belum Paid) tidak mengurangi saldo fund.
- **D-04 observable:** dataset harus memungkinkan tester memverifikasi tampilan multi-currency (USD, EUR, IDR) pada fund dan transaksi.

---

## 2. Layer 0 — ERPNext Built-in Configuration

Konfigurasi ini dilakukan di ERPNext/Frappe core sebelum Fundara DocTypes dibuat. Semua item di sini adalah prerequisite.

### 2.1 Company

| Field | Value |
|---|---|
| Company Name | Yayasan Peduli Nusantara |
| Abbreviation | YPN |
| Default Currency | IDR |
| Country | Indonesia |
| Default Time Zone | Asia/Jakarta |

### 2.2 Fiscal Year

| Field | Value |
|---|---|
| Year Name | 2026 |
| Start Date | 2026-01-01 |
| End Date | 2026-12-31 |
| Is Default | Yes |

### 2.3 Currency Exchange Rates

Entri kurs mata uang yang realistis untuk tahun 2026. Developer perlu membuat Currency Exchange records di ERPNext untuk setiap pasangan currency yang digunakan dalam transaksi.

| From Currency | To Currency | Exchange Rate | Berlaku Sejak |
|---|---|---|---|
| USD | IDR | 16.200 | 2026-01-01 |
| EUR | IDR | 17.500 | 2026-01-01 |
| IDR | USD | 0.00006173 | 2026-01-01 |
| IDR | EUR | 0.00005714 | 2026-01-01 |

> Catatan: Rate ini digunakan sebagai default. Transaksi individual boleh menggunakan rate berbeda sesuai tanggal posting masing-masing.

### 2.4 Fund Type Master (Fixture Wajib)

Sesuai spec `03-fund-stewardship-doctypes.md`, delapan Fund Type berikut harus di-seed sebagai fixture sebelum Fund data bisa dibuat:

| Fund Type Name | Default Restriction Type | Requires Grant | Has End Date | Is Active |
|---|---|---|---|---|
| Grant Fund | Restricted | Yes | Yes | Yes |
| Campaign Fund | Restricted | No | Yes | Yes |
| Unrestricted Fund | Unrestricted | No | No | Yes |
| Business Surplus Fund | Unrestricted | No | No | Yes |
| Reserve Fund | Board-designated | No | No | Yes |
| Co-funding Fund | Restricted | No | Yes | Yes |
| Bridging Fund | Unrestricted | No | No | Yes |
| Board-designated Fund | Board-designated | No | No | Yes |
| Endowment Fund | Permanently Restricted | No | No | No (inactive MVP) |

### 2.5 Activity Type Master

| Activity Type Name | Requires Field Report | Description |
|---|---|---|
| Pelatihan | Yes | Workshop dan training untuk benefisiari atau kader |
| Kunjungan Lapangan | Yes | Monitoring dan field visit ke lokasi program |
| Pengadaan | No | Kegiatan pengadaan barang/jasa |
| Koordinasi | No | Rapat koordinasi internal atau dengan mitra |
| Distribusi | Yes | Distribusi bantuan atau perlengkapan ke benefisiari |

### 2.6 Accounting Standard Profile

| Field | Value |
|---|---|
| Profile Name | Indonesia - ISAK 35 |
| Country | Indonesia |
| Reporting Framework | ISAK 35 |
| Default Net Asset Class | Without Donor Restrictions |
| Default Currency | IDR |
| Fiscal Year Rule | January-December |
| Is Active | Yes |

### 2.7 Net Asset Class

| Class Name | Class Code | Classification Type |
|---|---|---|
| Aset Neto Dengan Pembatasan Donor | ANDPD | With Donor Restrictions |
| Aset Neto Tanpa Pembatasan | ANTP | Without Donor Restrictions |
| Aset Neto Ditetapkan Pengurus | ANDP | Board-Designated |

---

## 3. Organization Setup

### 3.1 Organization

| Field | Value |
|---|---|
| organization_name | Yayasan Peduli Nusantara |
| legal_name | Yayasan Peduli Nusantara |
| organization_type | Yayasan |
| registration_number | AHU-0012345.AH.01.04.2010 |
| legal_status | Badan Hukum Yayasan |
| country | Indonesia |
| base_currency | IDR |
| default_language | id |
| fiscal_year_start_month | January |
| website | https://www.ypnusantara.org |
| email | info@ypnusantara.org |
| phone | 021-31456789 |
| address | Jl. Kebon Sirih No. 45, Jakarta Pusat 10340 |
| mission_statement | Mewujudkan masyarakat Indonesia yang sehat, terdidik, dan berdaya melalui program berbasis komunitas yang berkelanjutan. |
| vision_statement | Indonesia yang adil dan sejahtera di mana setiap warga mendapatkan akses layanan kesehatan dan pendidikan berkualitas. |
| tax_profile | NPWP: 12.345.678.9-012.000. Status: Pengecualian Pajak Yayasan Sosial. |
| is_active | Yes |

**Organization Contact Items (tabel anak):**

| contact_name | contact_role | email | phone | is_primary |
|---|---|---|---|---|
| Irma Sulistyo | Executive Director | irma.sulistyo@ypnusantara.org | 08111234567 | Yes |
| Hendra Wijaya | Other | hendra.wijaya@ypnusantara.org | 08129876543 | No |

### 3.2 Offices

**Office 1 — Kantor Pusat:**

| Field | Value |
|---|---|
| office_name | Kantor Pusat Jakarta |
| office_code | HO-JKT |
| organization | Yayasan Peduli Nusantara |
| office_type | Head Office |
| address_line_1 | Jl. Kebon Sirih No. 45 |
| city | Jakarta Pusat |
| province | DKI Jakarta |
| country | Indonesia |
| postal_code | 10340 |
| manager | irma.sulistyo |
| is_active | Yes |
| opening_date | 2010-03-15 |

**Office 2 — Kantor Program Yogyakarta:**

| Field | Value |
|---|---|
| office_name | Kantor Program Yogyakarta |
| office_code | FO-YOG |
| organization | Yayasan Peduli Nusantara |
| office_type | Field Office |
| address_line_1 | Jl. Malioboro No. 123 |
| city | Yogyakarta |
| province | DI Yogyakarta |
| country | Indonesia |
| postal_code | 55271 |
| manager | budi.santoso |
| parent_office | Kantor Pusat Jakarta |
| is_active | Yes |
| opening_date | 2015-06-01 |

### 3.3 Departments

| department_name | department_code | organization | department_head | notes |
|---|---|---|---|---|
| Divisi Program | PROG | Yayasan Peduli Nusantara | budi.santoso | Mengelola implementasi program kesehatan dan pendidikan |
| Divisi Keuangan | FIN | Yayasan Peduli Nusantara | hendra.wijaya | Akuntansi, pelaporan keuangan, dan pengelolaan kas |
| Divisi Fundraising | FUND | Yayasan Peduli Nusantara | sari.dewi | Pengembangan donor dan pengelolaan kampanye |
| Divisi Administrasi | ADM | Yayasan Peduli Nusantara | irma.sulistyo | SDM, logistik, dan administrasi umum |

### 3.4 Cost Centers

Cost Centers dibuat di ERPNext sesuai hierarki organisasi. Semua di bawah "Yayasan Peduli Nusantara - YPN" (root cost center).

| Cost Center Name | Parent | fundara_cc_type | fundara_department | fundara_office |
|---|---|---|---|---|
| Divisi Program - YPN | Yayasan Peduli Nusantara - YPN | Organizational | Divisi Program | Kantor Pusat Jakarta |
| Divisi Keuangan - YPN | Yayasan Peduli Nusantara - YPN | Organizational | Divisi Keuangan | Kantor Pusat Jakarta |
| Divisi Fundraising - YPN | Yayasan Peduli Nusantara - YPN | Organizational | Divisi Fundraising | Kantor Pusat Jakarta |
| Divisi Administrasi - YPN | Yayasan Peduli Nusantara - YPN | Organizational | Divisi Administrasi | Kantor Pusat Jakarta |
| Program Kesehatan Komunitas - YPN | Divisi Program - YPN | Program | Divisi Program | Kantor Pusat Jakarta |
| Program Akses Pendidikan - YPN | Divisi Program - YPN | Program | Divisi Program | Kantor Program Yogyakarta |

### 3.5 Users dan Roles

Password demo standar untuk semua user: `FundaraDemo2026!`

Developer wajib membuat 8 user berikut dan assign role yang sesuai:

| username | first_name | last_name | email | Role Fundara | Jabatan | Department |
|---|---|---|---|---|---|---|
| aditya.surya | Aditya | Surya | aditya.surya@ypnusantara.org | Field Staff | Staf Program | Divisi Program |
| siti.rahma | Siti | Rahma | siti.rahma@ypnusantara.org | Field Staff | Staf Program Yogyakarta | Divisi Program |
| budi.santoso | Budi | Santoso | budi.santoso@ypnusantara.org | Project Manager | Koordinator Program Kesehatan | Divisi Program |
| rini.kusuma | Rini | Kusuma | rini.kusuma@ypnusantara.org | Finance Officer | Staf Keuangan | Divisi Keuangan |
| hendra.wijaya | Hendra | Wijaya | hendra.wijaya@ypnusantara.org | Finance Manager | Kepala Keuangan | Divisi Keuangan |
| dimas.pratama | Dimas | Pratama | dimas.pratama@ypnusantara.org | Grant Manager | Manajer Grant | Divisi Program |
| sari.dewi | Sari | Dewi | sari.dewi@ypnusantara.org | Fundraising Officer | Staf Fundraising | Divisi Fundraising |
| irma.sulistyo | Irma | Sulistyo | irma.sulistyo@ypnusantara.org | Executive Director | Direktur Eksekutif | Divisi Administrasi |

### 3.6 Delegation of Authority

Buat Delegation of Authority records berikut untuk mengaktifkan approval workflow dalam demo:

**DOA 1 — Finance Officer:**

| Field | Value |
|---|---|
| authority_name | Finance Officer — Pengeluaran Operasional |
| organization | Yayasan Peduli Nusantara |
| approver_role | Finance Officer |
| approval_level | 1 |
| currency | IDR |
| minimum_amount | 0 |
| maximum_amount | 10.000.000 |
| valid_from | 2026-01-01 |
| is_active | Yes |

Applicable Document Types (child rows): Cash Advance, Purchase Request

**DOA 2 — Finance Manager:**

| Field | Value |
|---|---|
| authority_name | Finance Manager — Pengeluaran Semua Jenis |
| organization | Yayasan Peduli Nusantara |
| approver_role | Finance Manager |
| approval_level | 2 |
| currency | IDR |
| minimum_amount | 0 |
| maximum_amount | 100.000.000 |
| valid_from | 2026-01-01 |
| is_active | Yes |

Applicable Document Types (child rows): Cash Advance, Purchase Request, Payment Request, Payment Voucher, Grant Agreement

**DOA 3 — Executive Director:**

| Field | Value |
|---|---|
| authority_name | Executive Director — Pengeluaran Strategis |
| organization | Yayasan Peduli Nusantara |
| approver_role | Executive Director |
| approval_level | 3 |
| currency | IDR |
| minimum_amount | 100.000.001 |
| maximum_amount | 999.999.999.999 |
| valid_from | 2026-01-01 |
| is_active | Yes |

Applicable Document Types (child rows): Cash Advance, Purchase Request, Grant Agreement, Budget Revision

---

## 4. Funding Sources dan Donors

### 4.1 Funding Sources

| source_name | source_code | source_type | default_restriction_type | reporting_expectation | country | is_active |
|---|---|---|---|---|---|---|
| USAID Indonesia | USAID-ID | Institutional Donor | Restricted | Full Financial Report | United States | Yes |
| European Union | EU-DELEGASI | Institutional Donor | Restricted | Full Financial Report | Belgium | Yes |
| Masyarakat Umum | DONASI-UMUM | Individual Donor | Unrestricted | Basic Receipt | Indonesia | Yes |
| CSR Bank Nusantara | CSR-BNI | Corporate Donor | Unrestricted | Narrative Report | Indonesia | Yes |

### 4.2 Donors

**Donor 1 — USAID Indonesia (Institutional):**

| Field | Value |
|---|---|
| donor_name | USAID Indonesia |
| donor_type | Multilateral Agency |
| organization | Yayasan Peduli Nusantara |
| contact_person | Dr. Sarah Mitchell |
| email | smitchell@usaid.gov |
| country | United States |
| preferred_language | en |
| reporting_preference | Email |
| acknowledgment_preference | Letter |
| relationship_owner | dimas.pratama |
| donor_status | Active |
| linked_funding_source | USAID Indonesia |

Donor Contact Items:
| contact_name | title | position | contact_type | email | is_primary |
|---|---|---|---|---|---|
| Dr. Sarah Mitchell | Dr. | Program Officer | Primary | smitchell@usaid.gov | Yes |
| John Anderson | Mr. | Grants Manager | Finance | janderson@usaid.gov | No |

**Donor 2 — European Union (Institutional):**

| Field | Value |
|---|---|
| donor_name | European Union — Delegasi Indonesia |
| donor_type | Multilateral Agency |
| organization | Yayasan Peduli Nusantara |
| contact_person | Marie Dupont |
| email | marie.dupont@eeas.europa.eu |
| country | Belgium |
| preferred_language | en |
| reporting_preference | Email |
| acknowledgment_preference | Letter |
| relationship_owner | dimas.pratama |
| donor_status | Active |
| linked_funding_source | European Union |

**Donor 3 — PT Bank Nusantara (Corporate):**

| Field | Value |
|---|---|
| donor_name | PT Bank Nusantara |
| donor_type | Corporate |
| organization | Yayasan Peduli Nusantara |
| contact_person | Teguh Prasetyo |
| email | csr@banknusantara.co.id |
| country | Indonesia |
| reporting_preference | Email |
| acknowledgment_preference | Certificate |
| relationship_owner | sari.dewi |
| donor_status | Active |
| linked_funding_source | CSR Bank Nusantara |

**Donor 4 — Hadi Santoso (Individual):**

| Field | Value |
|---|---|
| donor_name | Hadi Santoso |
| donor_type | Individual |
| organization | Yayasan Peduli Nusantara |
| email | hadi.santoso@gmail.com |
| country | Indonesia |
| preferred_language | id |
| reporting_preference | Email |
| acknowledgment_preference | Email |
| relationship_owner | sari.dewi |
| donor_status | Active |
| linked_funding_source | Masyarakat Umum |

**Donor 5 — Maria Yolanda (Individual):**

| Field | Value |
|---|---|
| donor_name | Maria Yolanda |
| donor_type | Individual |
| organization | Yayasan Peduli Nusantara |
| email | maria@example.com |
| country | Indonesia |
| preferred_language | id |
| reporting_preference | Email |
| acknowledgment_preference | Email |
| relationship_owner | sari.dewi |
| donor_status | Active |
| linked_funding_source | Masyarakat Umum |
| is_anonymous_allowed | Yes |

**Donor 6 — Anonim (Anonymous Donor):**

> Donor ini tidak mewakili orang nyata. Dibuat sebagai placeholder untuk donation yang masuk tanpa identitas donor (is_anonymous = 1 pada Donation record).

| Field | Value |
|---|---|
| donor_name | Donatur Anonim |
| donor_type | Individual |
| organization | Yayasan Peduli Nusantara |
| donor_status | Active |
| is_anonymous_allowed | Yes |
| linked_funding_source | Masyarakat Umum |
| notes | Record ini digunakan sebagai placeholder internal untuk donation anonim. Jangan ditampilkan di laporan publik. Pada Donation record, is_anonymous harus diset 1. |

### 4.3 Institutional Donor Profiles

**Institutional Donor Profile 1 — USAID Indonesia:**

| Field | Value |
|---|---|
| donor_legal_name | United States Agency for International Development — Indonesia Mission |
| donor_short_name | USAID Indonesia |
| linked_donor | USAID Indonesia |
| compliance_requirements | Program harus mengikuti ADS (Automated Directives System) USAID. Pengadaan barang dan jasa di atas USD 3,000 harus melalui proses kompetitif. Laporan keuangan menggunakan template SF-425. Semua aset yang dibeli dengan dana USAID harus ditandai dan dilacak. |
| audit_requirement | External Audit |
| procurement_preference | Competitive Bidding Required |
| branding_requirement | Logo USAID wajib ditampilkan di semua materi publikasi program. Tagline "Aid from the American People" wajib digunakan. |
| financial_reporting_format | Donor Template |
| narrative_reporting_format | Donor Template |
| reporting_frequency | Quarterly |
| special_conditions | No terrorism financing per USAID ADS 303. Restriced party list screening required for all subgrantees and vendors above threshold. |

**Institutional Donor Profile 2 — European Union:**

| Field | Value |
|---|---|
| donor_legal_name | European Union — Delegasi Uni Eropa untuk Indonesia |
| donor_short_name | EU Delegation |
| linked_donor | European Union — Delegasi Indonesia |
| compliance_requirements | Mengikuti regulasi EU Financial Regulation. Pengadaan mengikuti PRAG (Practical Guide to Contract Procedures). Minimum 3 penawaran untuk kontrak di atas EUR 10,000. |
| audit_requirement | External Audit |
| procurement_preference | Competitive Bidding Required |
| branding_requirement | Logo EU wajib ditampilkan. Pernyataan "Co-funded by the European Union" wajib dicantumkan di semua publikasi. |
| financial_reporting_format | Donor Template |
| narrative_reporting_format | Donor Template |
| reporting_frequency | Semi-annual |

---

## 5. Grant Setup

### 5.1 Grant 1 — USAID Community Health 2026

**Grant Record:**

| Field | Value |
|---|---|
| grant_name | USAID Community Health 2026 |
| grant_code | USAID-CH-2026 |
| donor | USAID Indonesia |
| grant_type | Bilateral |
| program_area | Program Kesehatan Komunitas |
| implementing_unit | Divisi Program |
| grant_manager | dimas.pratama |
| currency | USD |
| total_amount | 250.000 |
| exchange_rate_on_creation | 16.200 |
| total_amount_base | 4.050.000.000 (auto-computed) |
| start_date | 2026-01-01 |
| end_date | 2026-12-31 |
| status | Active |
| notes | Community health strengthening in rural Central Java. Focus areas: maternal and child health, community health worker (kader) capacity building, and primary health center (puskesmas) support. |

**Grant Agreement 1 (untuk Grant 1):**

| Field | Value |
|---|---|
| grant | USAID Community Health 2026 |
| agreement_number | AID-497-G-26-00001 |
| signing_date | 2025-12-15 |
| effective_date | 2026-01-01 |
| end_date | 2026-12-31 |
| currency | USD |
| total_amount_contracted | 250.000 |
| exchange_rate | 16.200 |
| total_amount_contracted_base | 4.050.000.000 (auto-computed) |
| eligible_cost_categories | Personnel; Program Activities (training, workshops, field activities); Equipment (medical supplies); Indirect Costs (max 10% of direct costs) |
| ineligible_cost_categories | Entertainment; Alcoholic beverages; Lobbying; Construction above USD 5,000 without prior approval |
| indirect_cost_rate | 10 |
| procurement_rules | Competitive bidding required for purchases above USD 3,000. Sole source justification required above threshold. US-manufactured goods preferred per Buy American Act where applicable. |
| audit_requirement | External audit required. Audit period: grant end date + 3 months. |
| branding_requirement | USAID branding mandatory on all publications and materials. |
| approved_by | irma.sulistyo |
| approval_date | 2025-12-20 |

**Grant Budget Lines (untuk Grant 1):**

| budget_line_code | budget_line_name | description | currency | amount_approved | exchange_rate | allowed_cost_types |
|---|---|---|---|---|---|---|
| BL-01 | Personnel | Gaji dan tunjangan staf program | USD | 80.000 | 16.200 | Salary, benefits, social security (BPJS), honorarium kader |
| BL-02 | Program Activities | Kegiatan lapangan, pelatihan, workshop | USD | 120.000 | 16.200 | Training costs, venue, materials, transport peserta, field operations |
| BL-03 | Equipment | Peralatan medis dan perlengkapan posyandu | USD | 30.000 | 16.200 | Medical equipment, supplies, consumables |
| BL-04 | Indirect Costs | Biaya overhead (10% dari direct costs) | USD | 20.000 | 16.200 | Office costs, utilities, admin staff portion |

**Grant Reporting Schedule (untuk Grant 1):**

| report_type | report_period | reporting_period_start | reporting_period_end | due_date | status |
|---|---|---|---|---|---|
| Combined | Quarterly | 2026-01-01 | 2026-03-31 | 2026-04-30 | Submitted |
| Combined | Quarterly | 2026-04-01 | 2026-06-30 | 2026-07-31 | Upcoming |
| Combined | Quarterly | 2026-10-01 | 2026-09-30 | 2026-10-31 | Upcoming |
| Combined | Final | 2026-01-01 | 2026-12-31 | 2027-01-31 | Upcoming |

> Catatan: Q1 sudah berstatus Submitted untuk demo. Q3 dibiarkan "Due Soon" (karena mendekati deadline Juni 2026). Ini menciptakan kondisi warning yang bisa diuji.

### 5.2 Grant 2 — EU Education Access 2026

**Grant Record:**

| Field | Value |
|---|---|
| grant_name | EU Education Access 2026 |
| grant_code | EU-EDU-2026 |
| donor | European Union — Delegasi Indonesia |
| grant_type | Multilateral |
| program_area | Program Akses Pendidikan |
| implementing_unit | Divisi Program |
| grant_manager | dimas.pratama |
| currency | EUR |
| total_amount | 150.000 |
| exchange_rate_on_creation | 17.500 |
| total_amount_base | 2.625.000.000 (auto-computed) |
| start_date | 2026-03-01 |
| end_date | 2027-02-28 |
| status | Active |
| notes | Improving education access for out-of-school children and quality of primary education in remote areas of Yogyakarta and surrounding provinces. |

**Grant Agreement 2 (untuk Grant 2):**

| Field | Value |
|---|---|
| grant | EU Education Access 2026 |
| agreement_number | CRIS/2026/001-234 |
| signing_date | 2026-02-15 |
| effective_date | 2026-03-01 |
| end_date | 2027-02-28 |
| currency | EUR |
| total_amount_contracted | 150.000 |
| exchange_rate | 17.500 |
| total_amount_contracted_base | 2.625.000.000 (auto-computed) |
| indirect_cost_rate | 7 |
| audit_requirement | External audit required at grant end. |
| approved_by | irma.sulistyo |
| approval_date | 2026-02-20 |

**Grant Budget Lines (untuk Grant 2):**

| budget_line_code | budget_line_name | currency | amount_approved | exchange_rate |
|---|---|---|---|---|
| EU-BL-01 | Human Resources | EUR | 60.000 | 17.500 |
| EU-BL-02 | Supplies and Materials | EUR | 35.000 | 17.500 |
| EU-BL-03 | External Services | EUR | 45.000 | 17.500 |
| EU-BL-04 | Indirect Costs (7%) | EUR | 10.000 | 17.500 |

---

## 6. Fund Setup

### 6.1 Fund 1 — Dana USAID Kesehatan Komunitas

| Field | Value |
|---|---|
| fund_name | Dana USAID Kesehatan Komunitas |
| fund_code | FUND-USAID-CH-2026 |
| fund_type | Grant Fund |
| restriction_type | Restricted |
| purpose | Dana untuk implementasi program community health strengthening di Jawa Tengah, bersumber dari hibah USAID AID-497-G-26-00001. |
| funding_source | USAID Indonesia |
| grant | USAID Community Health 2026 |
| fund_owner | dimas.pratama |
| approval_authority | hendra.wijaya |
| start_date | 2026-01-01 |
| end_date | 2026-12-31 |
| currency | USD |
| exchange_rate_on_creation | 16.200 |
| opening_balance | 250.000 |
| opening_balance_base | 4.050.000.000 (auto-computed) |
| status | Active |
| allowed_programs | Program Kesehatan Komunitas |
| reporting_requirement | Quarterly combined report (narrative + financial) ke USAID. Deadline: 30 hari setelah akhir kuartal. |
| procurement_requirement | Kompetitif untuk pembelian di atas USD 3,000. Sole source justification wajib di atas threshold. |

**Catatan D-02 untuk Fund ini:** Saldo available = 250.000 USD dikurangi hanya transaksi yang sudah berstatus Paid. Cash Advance berstatus Approved (belum Paid) TIDAK mengurangi saldo ini.

### 6.2 Fund 2 — Dana EU Pendidikan

| Field | Value |
|---|---|
| fund_name | Dana EU Pendidikan |
| fund_code | FUND-EU-EDU-2026 |
| fund_type | Grant Fund |
| restriction_type | Restricted |
| purpose | Dana untuk program peningkatan akses pendidikan, bersumber dari hibah EU CRIS/2026/001-234. |
| funding_source | European Union |
| grant | EU Education Access 2026 |
| fund_owner | dimas.pratama |
| approval_authority | hendra.wijaya |
| start_date | 2026-03-01 |
| end_date | 2027-02-28 |
| currency | EUR |
| exchange_rate_on_creation | 17.500 |
| opening_balance | 150.000 |
| opening_balance_base | 2.625.000.000 (auto-computed) |
| status | Active |
| allowed_programs | Program Akses Pendidikan |
| reporting_requirement | Semi-annual report ke EU Delegation. |
| procurement_requirement | PRAG compliant. Minimum 3 penawaran untuk kontrak di atas EUR 10,000. |

### 6.3 Fund 3 — Dana Donasi Umum

| Field | Value |
|---|---|
| fund_name | Dana Donasi Umum |
| fund_code | FUND-DON-UMUM |
| fund_type | Unrestricted Fund |
| restriction_type | Unrestricted |
| purpose | Kumpulan donasi dari masyarakat umum dan individu yang tidak terikat pada program spesifik. |
| funding_source | Masyarakat Umum |
| fund_owner | hendra.wijaya |
| approval_authority | irma.sulistyo |
| start_date | 2026-01-01 |
| currency | IDR |
| exchange_rate_on_creation | 1 |
| opening_balance | 350.000.000 |
| opening_balance_base | 350.000.000 |
| status | Active |

### 6.4 Fund 4 — Dana Operasional Yayasan

| Field | Value |
|---|---|
| fund_name | Dana Operasional Yayasan |
| fund_code | FUND-OPS |
| fund_type | Board-designated Fund |
| restriction_type | Board-designated |
| purpose | Dana cadangan operasional untuk membiayai kegiatan administratif dan overhead yayasan yang tidak bisa dibebankan ke grant donor. |
| funding_source | Masyarakat Umum |
| fund_owner | hendra.wijaya |
| approval_authority | irma.sulistyo |
| start_date | 2026-01-01 |
| currency | IDR |
| exchange_rate_on_creation | 1 |
| opening_balance | 150.000.000 |
| opening_balance_base | 150.000.000 |
| status | Active |

### 6.5 Fund 5 — Dana Bridge Talangan

| Field | Value |
|---|---|
| fund_name | Dana Bridge Talangan |
| fund_code | FUND-BRIDGE |
| fund_type | Bridging Fund |
| restriction_type | Unrestricted |
| purpose | Dana talangan sementara untuk membiayai pengeluaran program sebelum dana grant diterima. Wajib diganti oleh dana grant setelah pencairan. |
| funding_source | Masyarakat Umum |
| fund_owner | hendra.wijaya |
| approval_authority | irma.sulistyo |
| start_date | 2026-01-01 |
| currency | IDR |
| exchange_rate_on_creation | 1 |
| opening_balance | 50.000.000 |
| opening_balance_base | 50.000.000 |
| status | Active |
| is_bridging_fund | Yes |
| recoverable_from_fund | Dana USAID Kesehatan Komunitas |

---

## 7. Programs, Projects, dan Activities

### 7.1 Programs

**Program 1 — Program Kesehatan Komunitas:**

| Field | Value |
|---|---|
| program_name | Program Kesehatan Komunitas |
| program_code | HLTH |
| strategic_objective | Memperkuat sistem kesehatan berbasis komunitas di Jawa Tengah melalui peningkatan kapasitas kader posyandu, perbaikan sarana posyandu, dan penguatan akses layanan kesehatan ibu dan anak. |
| program_manager | budi.santoso |
| start_date | 2026-01-01 |
| end_date | 2026-12-31 |
| target_population | Kader posyandu, ibu hamil, dan anak balita di 15 desa sasaran Kabupaten Klaten dan Boyolali, Jawa Tengah. |
| is_active | Yes |

**Program 2 — Program Akses Pendidikan:**

| Field | Value |
|---|---|
| program_name | Program Akses Pendidikan |
| program_code | EDU |
| strategic_objective | Meningkatkan akses dan kualitas pendidikan dasar untuk anak-anak putus sekolah dan guru di daerah terpencil Yogyakarta dan sekitarnya. |
| program_manager | budi.santoso |
| start_date | 2026-03-01 |
| end_date | 2027-02-28 |
| target_population | Anak usia sekolah yang putus sekolah (7-15 tahun) dan guru SD di daerah terpencil Yogyakarta, Kulon Progo, dan Gunung Kidul. |
| is_active | Yes |

### 7.2 Projects

**Project 1 — Pelatihan Kader Kesehatan Desa:**

| Field | Value |
|---|---|
| project_name | Pelatihan Kader Kesehatan Desa |
| project_code | PROJ-HLTH-01 |
| program | Program Kesehatan Komunitas |
| project_manager | budi.santoso |
| status | Active |
| start_date | 2026-02-01 |
| end_date | 2026-11-30 |
| location | Kabupaten Klaten, Jawa Tengah |
| target_beneficiaries | 150 (kader posyandu dari 15 desa) |
| currency | USD |
| objective | Melatih 150 kader posyandu dalam deteksi dini malnutrisi, pemantauan tumbuh kembang bayi, dan pertolongan pertama kesehatan dasar. |

Fund Allocations (tabel anak):
| fund | currency | allocated_amount |
|---|---|---|
| Dana USAID Kesehatan Komunitas | USD | 45.000 |

**Project 2 — Pengadaan Alat Kesehatan Posyandu:**

| Field | Value |
|---|---|
| project_name | Pengadaan Alat Kesehatan Posyandu |
| project_code | PROJ-HLTH-02 |
| program | Program Kesehatan Komunitas |
| project_manager | budi.santoso |
| status | Active |
| start_date | 2026-03-01 |
| end_date | 2026-09-30 |
| location | Kabupaten Klaten dan Boyolali, Jawa Tengah |
| target_beneficiaries | 30 (posyandu) |
| currency | USD |
| objective | Melengkapi 30 posyandu dengan alat timbang bayi, tensimeter, dan perlengkapan kesehatan dasar. |

Fund Allocations (tabel anak):
| fund | currency | allocated_amount |
|---|---|---|
| Dana USAID Kesehatan Komunitas | USD | 28.000 |

**Project 3 — Beasiswa Anak Putus Sekolah:**

| Field | Value |
|---|---|
| project_name | Beasiswa Anak Putus Sekolah |
| project_code | PROJ-EDU-01 |
| program | Program Akses Pendidikan |
| project_manager | budi.santoso |
| status | Active |
| start_date | 2026-04-01 |
| end_date | 2027-01-31 |
| location | Kabupaten Gunung Kidul, Yogyakarta |
| target_beneficiaries | 200 (anak usia sekolah) |
| currency | EUR |
| objective | Memberikan beasiswa kepada 200 anak putus sekolah dan mendampingi reintegrasi mereka ke sistem pendidikan formal atau non-formal. |

Fund Allocations (tabel anak):
| fund | currency | allocated_amount |
|---|---|---|
| Dana EU Pendidikan | EUR | 40.000 |

**Project 4 — Pelatihan Guru SD Terpencil:**

| Field | Value |
|---|---|
| project_name | Pelatihan Guru SD Terpencil |
| project_code | PROJ-EDU-02 |
| program | Program Akses Pendidikan |
| project_manager | budi.santoso |
| status | Active |
| start_date | 2026-05-01 |
| end_date | 2026-12-31 |
| location | Kabupaten Kulon Progo, Yogyakarta |
| target_beneficiaries | 80 (guru SD) |
| currency | EUR |
| objective | Meningkatkan kompetensi pedagogi 80 guru SD di daerah terpencil melalui pelatihan metodologi pembelajaran aktif dan penggunaan media ajar sederhana. |

Fund Allocations (tabel anak):
| fund | currency | allocated_amount |
|---|---|---|
| Dana EU Pendidikan | EUR | 30.000 |

### 7.3 Locations

| location_name | administrative_level | province_state | district | risk_profile |
|---|---|---|---|---|
| Kabupaten Klaten, Jawa Tengah | District | Jawa Tengah | Klaten | Low |
| Kabupaten Boyolali, Jawa Tengah | District | Jawa Tengah | Boyolali | Low |
| Kabupaten Gunung Kidul, Yogyakarta | District | DI Yogyakarta | Gunung Kidul | Medium |
| Kabupaten Kulon Progo, Yogyakarta | District | DI Yogyakarta | Kulon Progo | Low |

### 7.4 Activities

Activities yang perlu dibuat untuk mendukung Cash Advance dan transaksi lainnya:

| activity_name | activity_code | activity_type | project | fund | responsible_person | status | planned_date |
|---|---|---|---|---|---|---|---|
| Kunjungan Lapangan 3 Desa Klaten | ACT-HLTH-001 | Kunjungan Lapangan | Pelatihan Kader Kesehatan Desa | Dana USAID Kesehatan Komunitas | aditya.surya | Approved | 2026-06-25 |
| Workshop Kader Kesehatan Batch 1 | ACT-HLTH-002 | Pelatihan | Pelatihan Kader Kesehatan Desa | Dana USAID Kesehatan Komunitas | budi.santoso | In Progress | 2026-06-20 |
| Training Guru SD Kulon Progo | ACT-EDU-001 | Pelatihan | Pelatihan Guru SD Terpencil | Dana EU Pendidikan | siti.rahma | In Progress | 2026-06-18 |
| Perjalanan Monitoring Q1 2026 | ACT-HLTH-003 | Kunjungan Lapangan | Pelatihan Kader Kesehatan Desa | Dana USAID Kesehatan Komunitas | aditya.surya | Completed | 2026-03-20 |
| Pengadaan ATK Kantor | ACT-OPS-001 | Koordinasi | Pelatihan Kader Kesehatan Desa | Dana Operasional Yayasan | rini.kusuma | Completed | 2026-02-10 |
| Field Visit Boyolali | ACT-HLTH-004 | Kunjungan Lapangan | Pengadaan Alat Kesehatan Posyandu | Dana USAID Kesehatan Komunitas | siti.rahma | In Progress | 2026-04-15 |

---

## 8. Transaksi In-Progress

Bagian ini mendefinisikan transaksi yang mencerminkan berbagai state untuk kebutuhan testing. Setiap transaksi memiliki tujuan testing yang jelas.

### 8.1 Fund Budget (prerequisite untuk Cash Advance)

Sebelum membuat Cash Advance, Fund Budget untuk Dana USAID harus ada dan Active.

**Fund Budget 1 — Dana USAID Kesehatan Komunitas:**

| Field | Value |
|---|---|
| budget_name | Anggaran Dana USAID 2026 |
| budget_type | Grant |
| fund | Dana USAID Kesehatan Komunitas |
| fiscal_year | 2026 |
| start_date | 2026-01-01 |
| end_date | 2026-12-31 |
| currency | USD |
| exchange_rate | 16.200 |
| status | Active |
| approved_by | irma.sulistyo |
| approved_on | 2026-01-10 |

Budget Lines (tabel anak):

| budget_line_name | approved_amount | donor_report_category |
|---|---|---|
| Personnel | 80.000 | BL-01 Personnel |
| Program Activities | 120.000 | BL-02 Program Activities |
| Equipment | 30.000 | BL-03 Equipment |
| Indirect Costs | 20.000 | BL-04 Indirect Costs |

**Fund Budget 2 — Dana EU Pendidikan:**

| Field | Value |
|---|---|
| budget_name | Anggaran Dana EU 2026-2027 |
| budget_type | Grant |
| fund | Dana EU Pendidikan |
| fiscal_year | 2026 |
| start_date | 2026-03-01 |
| end_date | 2027-02-28 |
| currency | EUR |
| exchange_rate | 17.500 |
| status | Active |
| approved_by | irma.sulistyo |
| approved_on | 2026-03-05 |

Budget Lines (tabel anak):

| budget_line_name | approved_amount | donor_report_category |
|---|---|---|
| Human Resources | 60.000 | EU-BL-01 Human Resources |
| Supplies and Materials | 35.000 | EU-BL-02 Supplies |
| External Services | 45.000 | EU-BL-03 External Services |
| Indirect Costs | 10.000 | EU-BL-04 Indirect Costs |

**Fund Budget 3 — Dana Operasional:**

| Field | Value |
|---|---|
| budget_name | Anggaran Operasional 2026 |
| budget_type | Organizational |
| fund | Dana Operasional Yayasan |
| fiscal_year | 2026 |
| start_date | 2026-01-01 |
| end_date | 2026-12-31 |
| currency | IDR |
| exchange_rate | 1 |
| status | Active |
| approved_by | irma.sulistyo |
| approved_on | 2026-01-05 |

Budget Lines (tabel anak):

| budget_line_name | approved_amount |
|---|---|
| Biaya ATK dan Perlengkapan Kantor | 20.000.000 |
| Biaya Transportasi Operasional | 30.000.000 |
| Biaya Utilitas dan Komunikasi | 15.000.000 |
| Biaya SDM dan Administrasi | 85.000.000 |

### 8.2 Cash Advances

Enam Cash Advance dengan state berbeda. Dibuat dalam urutan ini untuk memastikan dependency terpenuhi.

> **Catatan D-02 kritis:** Cash Advance #2 (Budi Santoso, status Approved) adalah test case utama untuk keputusan D-02. Pastikan saldo Dana USAID di dashboard Finance Officer menunjukkan hanya pengurangan dari Cash Advance yang sudah berstatus Paid (advance #3 Siti Rahma untuk Dana EU), bukan dari advance yang berstatus Approved.

---

**Cash Advance 1 — Aditya Surya (Draft):**

| Field | Value |
|---|---|
| requester | aditya.surya |
| fund | Dana USAID Kesehatan Komunitas |
| project | Pelatihan Kader Kesehatan Desa |
| activity | Kunjungan Lapangan 3 Desa Klaten |
| budget_line | Program Activities |
| currency | IDR |
| exchange_rate | 16.200 |
| requested_amount | 2.500.000 |
| purpose | Biaya perjalanan dan akomodasi untuk kunjungan lapangan ke 3 desa sasaran di Klaten — verifikasi lokasi pelatihan dan koordinasi dengan kades. |
| posting_date | 2026-06-18 |
| liquidation_due_date | 2026-07-05 |
| status | Draft |
| pending_payment_flag | 0 |

**Tujuan testing:** Verifikasi tampilan Draft advance di queue Finance Officer; pastikan budget tidak terpengaruh.

---

**Cash Advance 2 — Budi Santoso (Approved, belum Paid):**

| Field | Value |
|---|---|
| requester | budi.santoso |
| fund | Dana USAID Kesehatan Komunitas |
| project | Pelatihan Kader Kesehatan Desa |
| activity | Workshop Kader Kesehatan Batch 1 |
| budget_line | Program Activities |
| currency | IDR |
| exchange_rate | 16.200 |
| requested_amount | 5.000.000 |
| approved_amount | 5.000.000 |
| purpose | Biaya penyelenggaraan Workshop Kader Kesehatan Batch 1: venue, konsumsi, ATK peserta, dan narasumber lokal. |
| posting_date | 2026-06-10 |
| liquidation_due_date | 2026-07-10 |
| status | Approved |
| pending_payment_flag | 1 |
| supervisor_approved_by | budi.santoso |
| supervisor_approved_on | 2026-06-11 |
| finance_approved_by | hendra.wijaya |
| finance_approved_on | 2026-06-12 |

**Tujuan testing (D-02):** Cash Advance ini Approved tetapi BELUM dibayar. Saldo Dana USAID di dashboard HARUS menunjukkan 250.000 USD dikurangi hanya transaksi Paid. Cash Advance ini harus muncul sebagai "Pending Payment" (warning indicator), BUKAN sebagai pengurang saldo.

---

**Cash Advance 3 — Siti Rahma (Paid, belum Diliquidasi):**

| Field | Value |
|---|---|
| requester | siti.rahma |
| fund | Dana EU Pendidikan |
| project | Pelatihan Guru SD Terpencil |
| activity | Training Guru SD Kulon Progo |
| budget_line | Human Resources |
| currency | EUR |
| exchange_rate | 17.500 |
| requested_amount | 200 |
| approved_amount | 200 |
| paid_amount | 200 |
| purpose | Biaya transportasi Siti Rahma untuk Training Guru SD di Kulon Progo (3 hari). |
| posting_date | 2026-06-15 |
| payment_date | 2026-06-16 |
| liquidation_due_date | 2026-07-01 |
| status | Pending Liquidation |
| pending_payment_flag | 0 |
| finance_approved_by | hendra.wijaya |
| finance_approved_on | 2026-06-15 |
| payment_reference | TRF-BCA-20260616-0034 |

**Tujuan testing (D-02):** Cash Advance ini sudah Paid. Saldo Dana EU HARUS berkurang EUR 200 karena paid_amount sudah dicatat. Ini adalah kebalikan dari advance #2 — membuktikan bahwa hanya Paid yang mengurangi saldo.

---

**Cash Advance 4 — Aditya Surya (Liquidated):**

| Field | Value |
|---|---|
| requester | aditya.surya |
| fund | Dana Donasi Umum |
| project | Pelatihan Kader Kesehatan Desa |
| activity | Perjalanan Monitoring Q1 2026 |
| budget_line | Program Activities |
| currency | IDR |
| exchange_rate | 1 |
| requested_amount | 1.800.000 |
| approved_amount | 1.800.000 |
| paid_amount | 1.800.000 |
| purpose | Biaya perjalanan monitoring Q1: Jakarta - Klaten pp, penginapan 2 malam. |
| posting_date | 2026-03-18 |
| payment_date | 2026-03-19 |
| liquidation_due_date | 2026-04-05 |
| status | Liquidated |
| pending_payment_flag | 0 |
| finance_approved_by | hendra.wijaya |
| finance_approved_on | 2026-03-18 |
| payment_reference | TRF-BCA-20260319-0011 |

**Tujuan testing:** Advance completed lifecycle. Digunakan untuk demo alur lengkap liquidation dan verifikasi bahwa record yang Liquidated tampil dengan benar di history.

Advance Liquidation yang harus dibuat untuk Cash Advance 4:

| Field | Value |
|---|---|
| cash_advance | (link ke Cash Advance 4) |
| posting_date | 2026-04-02 |
| currency | IDR |
| exchange_rate | 1 |
| advance_paid_amount | 1.800.000 |
| review_status | Approved |
| finance_reviewed_by | rini.kusuma |
| finance_reviewed_on | 2026-04-03 |
| evidence_completeness | Complete |
| settlement_type | No Difference |

Expense Lines (tabel anak):

| expense_description | expense_date | amount |
|---|---|---|
| Tiket kereta Jakarta-Klaten pp | 2026-03-18 | 650.000 |
| Penginapan 2 malam (Rp 450.000/malam) | 2026-03-19 | 900.000 |
| Taksi lokal dan konsumsi selama tugas | 2026-03-20 | 250.000 |

---

**Cash Advance 5 — Rini Kusuma (Closed):**

| Field | Value |
|---|---|
| requester | rini.kusuma |
| fund | Dana Operasional Yayasan |
| project | Pelatihan Kader Kesehatan Desa |
| activity | Pengadaan ATK Kantor |
| budget_line | Biaya ATK dan Perlengkapan Kantor |
| currency | IDR |
| exchange_rate | 1 |
| requested_amount | 3.500.000 |
| approved_amount | 3.500.000 |
| paid_amount | 3.500.000 |
| purpose | Pengadaan ATK bulanan untuk kantor Jakarta: kertas, tinta printer, alat tulis, dan perlengkapan presentasi. |
| posting_date | 2026-02-08 |
| payment_date | 2026-02-09 |
| liquidation_due_date | 2026-02-28 |
| status | Closed |
| pending_payment_flag | 0 |
| finance_approved_by | hendra.wijaya |
| finance_approved_on | 2026-02-08 |

**Tujuan testing:** Demo advance yang sudah selesai penuh (Closed). Berguna untuk testing filter dan tampilan history transaksi.

---

**Cash Advance 6 — Siti Rahma (Overdue):**

| Field | Value |
|---|---|
| requester | siti.rahma |
| fund | Dana USAID Kesehatan Komunitas |
| project | Pengadaan Alat Kesehatan Posyandu |
| activity | Field Visit Boyolali |
| budget_line | Program Activities |
| currency | IDR |
| exchange_rate | 16.200 |
| requested_amount | 1.200.000 |
| approved_amount | 1.200.000 |
| paid_amount | 1.200.000 |
| purpose | Biaya perjalanan field visit ke Boyolali untuk verifikasi kebutuhan alat kesehatan posyandu. |
| posting_date | 2026-04-13 |
| payment_date | 2026-04-14 |
| liquidation_due_date | 2026-05-01 |
| status | Overdue |
| aging_category | >30 Days |
| days_outstanding | 49 (dihitung dari 2026-04-14 ke 2026-06-02, dikunci pada saat snapshot) |
| pending_payment_flag | 0 |
| finance_approved_by | hendra.wijaya |
| finance_approved_on | 2026-04-13 |
| payment_reference | TRF-BCA-20260414-0019 |

**Tujuan testing:** Advance ini melampaui liquidation_due_date tanpa diliquidasi. Dashboard Finance Officer harus menampilkan alert. Berguna untuk testing notifikasi overdue dan aging report.

### 8.3 Purchase Requests

**Purchase Request 1 — Laptop Staf Program (Approved):**

| Field | Value |
|---|---|
| item_description | 3 unit laptop untuk staf program baru (Divisi Program) |
| fund | Dana USAID Kesehatan Komunitas |
| project | Pelatihan Kader Kesehatan Desa |
| budget_line | Personnel |
| currency | IDR |
| estimated_amount | 22.500.000 |
| requester | budi.santoso |
| posting_date | 2026-05-20 |
| status | Approved |
| approved_by | hendra.wijaya |
| approved_on | 2026-05-22 |

**Tujuan testing (D-02):** Purchase Request Approved tidak mengurangi budget. Budget hanya berkurang ketika invoice dibayar.

---

**Purchase Request 2 — Servis Kendaraan (Draft):**

| Field | Value |
|---|---|
| item_description | Servis rutin kendaraan operasional Toyota Kijang Innova (B 1234 YPN) — 10.000 km service |
| fund | Dana Operasional Yayasan |
| budget_line | Biaya Transportasi Operasional |
| currency | IDR |
| estimated_amount | 2.800.000 |
| requester | rini.kusuma |
| posting_date | 2026-06-17 |
| status | Draft |

---

**Purchase Request 3 — Alat Kesehatan Posyandu (Converted to PO):**

| Field | Value |
|---|---|
| item_description | 30 set alat timbang bayi digital dan 30 unit tensimeter untuk posyandu sasaran |
| fund | Dana USAID Kesehatan Komunitas |
| project | Pengadaan Alat Kesehatan Posyandu |
| budget_line | Equipment |
| currency | IDR |
| estimated_amount | 48.600.000 |
| requester | budi.santoso |
| posting_date | 2026-04-10 |
| status | Converted to PO |
| approved_by | hendra.wijaya |
| approved_on | 2026-04-12 |

### 8.4 Donations

**Donation 1 — Hadi Santoso:**

| Field | Value |
|---|---|
| organization | Yayasan Peduli Nusantara |
| is_anonymous | 0 |
| donor | Hadi Santoso |
| funding_source | Masyarakat Umum |
| currency | IDR |
| amount | 5.000.000 |
| exchange_rate | 1 |
| date_received | 2026-03-10 |
| payment_channel | Bank Transfer |
| payment_reference | BCA-20260310-TRF-0089 |
| restriction_type | Unrestricted |
| receipt_number | YPN/DON/2026/001 |
| receipt_issued | Yes |
| receipt_date | 2026-03-11 |
| acknowledgment_status | Confirmed |
| acknowledgment_date | 2026-03-12 |

**Catatan:** Donation ini sudah Submitted dan Received. Masuk ke Dana Donasi Umum.

---

**Donation 2 — PT Bank Nusantara (CSR):**

| Field | Value |
|---|---|
| organization | Yayasan Peduli Nusantara |
| is_anonymous | 0 |
| donor | PT Bank Nusantara |
| funding_source | CSR Bank Nusantara |
| currency | IDR |
| amount | 50.000.000 |
| exchange_rate | 1 |
| date_received | 2026-04-05 |
| payment_channel | Bank Transfer |
| payment_reference | BNI-20260405-TRF-CSR-001 |
| restriction_type | Unrestricted |
| receipt_number | YPN/DON/2026/002 |
| receipt_issued | Yes |
| receipt_date | 2026-04-06 |
| acknowledgment_status | Confirmed |
| acknowledgment_date | 2026-04-08 |

---

**Donation 3 — Maria Yolanda:**

| Field | Value |
|---|---|
| organization | Yayasan Peduli Nusantara |
| is_anonymous | 0 |
| donor | Maria Yolanda |
| funding_source | Masyarakat Umum |
| currency | IDR |
| amount | 2.000.000 |
| exchange_rate | 1 |
| date_received | 2026-05-15 |
| payment_channel | Digital Wallet |
| payment_reference | GOPAY-20260515-0123456 |
| restriction_type | Unrestricted |
| receipt_number | YPN/DON/2026/003 |
| receipt_issued | Yes |
| receipt_date | 2026-05-15 |
| acknowledgment_status | Sent |

**Tujuan testing:** Pastikan Maria Yolanda tersedia sebagai pilihan di form Donation baru. Pastikan receipt menampilkan nama "Maria Yolanda".

---

**Donation 4 — Donatur Anonim:**

| Field | Value |
|---|---|
| organization | Yayasan Peduli Nusantara |
| is_anonymous | 1 |
| donor | (kosong — wajib kosong ketika is_anonymous = 1) |
| donor_display_name | Hamba Allah |
| funding_source | Masyarakat Umum |
| currency | IDR |
| amount | 500.000 |
| exchange_rate | 1 |
| date_received | 2026-06-01 |
| payment_channel | Cash |
| restriction_type | Unrestricted |
| receipt_number | YPN/DON/2026/004 |
| receipt_issued | Yes |
| receipt_date | 2026-06-01 |
| acknowledgment_status | Not Required |

**Tujuan testing:** Pastikan donation receipt menampilkan "Hamba Allah" (donor_display_name), bukan nama donor asli. Pastikan nama donor tidak tersimpan atau tampil di laporan publik.

---

## 9. Cara Load Demo Data

Ada tiga cara untuk meload demo data ke environment. Pilih sesuai kebutuhan.

### Cara A: Manual via Frappe UI

Ikuti urutan berikut (urutan penting — ada dependency antar DocType):

1. **ERPNext Core Config**
   - Setup Company "Yayasan Peduli Nusantara"
   - Setup Fiscal Year 2026
   - Tambahkan Currency Exchange rates (USD/IDR, EUR/IDR)
   - Setup Chart of Accounts (gunakan template Indonesia)

2. **Fundara Master Data (Layer 0)**
   - Seed Fund Type (9 records)
   - Seed Activity Type (5 records)
   - Buat Accounting Standard Profile dan Net Asset Class (3 records)

3. **Organization**
   - Buat Organization record
   - Buat 2 Office records (HQ dulu, lalu field office)
   - Buat 4 Department records
   - Buat Cost Centers di ERPNext (6 records)
   - Buat 8 User accounts dan assign roles
   - Buat 3 Delegation of Authority records

4. **Funding**
   - Buat 4 Funding Source records
   - Buat 2 Institutional Donor Profile records
   - Buat 6 Donor records (link ke Funding Source dan Institutional Profile)

5. **Grant**
   - Buat 2 Grant records (status Active)
   - Buat 2 Grant Agreement records (link ke Grant)
   - Buat 8 Grant Budget Line records (4 per grant)
   - Buat Grant Reporting Schedule records

6. **Fund**
   - Buat 5 Fund records (dalam urutan: Fund 1 dan 2 dulu karena Bridging Fund mereferensikan Fund 1)

7. **Mission Delivery**
   - Buat 4 Location records
   - Buat 2 Program records
   - Buat 4 Project records (dengan Fund Allocation child rows)
   - Buat 6 Activity records

8. **Financial Accountability**
   - Buat 3 Fund Budget records + budget lines
   - Buat 6 Cash Advance records (dalam urutan state: Closed → Liquidated → Approved → Paid → Draft → Overdue)
   - Buat Advance Liquidation untuk Cash Advance 4 (Aditya Surya, Liquidated)
   - Buat 3 Purchase Request records
   - Buat 4 Donation records (Submit semua)

### Cara B: Frappe Fixtures (JSON)

Developer mengekspor dataset sebagai JSON fixtures dari site yang sudah berisi demo data:

```bash
# Export dari site sumber
bench --site fundara.local export-fixtures
```

File JSON fixtures akan tersimpan di `{app_name}/fixtures/`. Import ke site target:

```bash
# Import ke staging
bench --site staging.fundara.org import-fixtures
```

Catatan: fixtures harus diimport dalam urutan yang menghormati FK dependency (sama seperti urutan manual di atas). Developer perlu memastikan `fixtures` key di `hooks.py` sudah dikonfigurasi dengan urutan yang benar.

### Cara C: Restore dari Backup Snapshot

Cara tercepat untuk UAT. Setelah demo data pertama kali diload dengan benar, ambil backup:

```bash
bench --site staging.fundara.org backup --with-files
```

Untuk restore ke keadaan demo data awal:

```bash
bench --site staging.fundara.org restore /path/to/backup/date-staging.fundara.org-database.sql.gz
```

---

## 10. Reset Prosedur

Untuk mengembalikan staging ke keadaan demo data awal setelah UAT atau E2E testing selesai:

### Cara Cepat — Restore dari Backup

```bash
# 1. Pastikan tidak ada user yang sedang aktif di site
bench --site staging.fundara.org console
# Cek active sessions di console jika perlu

# 2. Restore database dari backup snapshot demo data
bench --site staging.fundara.org restore /path/to/backup/demo-data-baseline.sql.gz

# 3. Restart services
bench restart
```

### Cara Lengkap — Drop dan Recreate

Gunakan ini jika backup tidak tersedia atau site perlu di-rebuild dari awal:

```bash
# PERHATIAN: Perintah ini menghapus seluruh data site. Pastikan tidak dijalankan di production.

# 1. Drop site
bench drop-site staging.fundara.org --force

# 2. Buat ulang site
bench new-site staging.fundara.org \
  --db-name staging_fundara \
  --admin-password <password>

# 3. Install Fundara app
bench --site staging.fundara.org install-app fundara

# 4. Import fixtures
bench --site staging.fundara.org import-fixtures

# 5. Jalankan setup script jika ada
bench --site staging.fundara.org execute fundara.setup.demo_data.load_all
```

### Catatan Keamanan

- Jangan pernah menjalankan `drop-site` tanpa konfirmasi eksplisit bahwa itu adalah site staging/testing.
- Simpan backup demo data baseline di lokasi yang aman dan beri label yang jelas: `demo-data-baseline-YYYYMMDD.sql.gz`.
- Password demo (`FundaraDemo2026!`) adalah password staging, bukan production. Jangan gunakan password ini di environment lain.

---

## 11. Checklist Verifikasi

Developer harus memverifikasi kondisi berikut setelah demo data diload. Tandai setiap item sebelum menyerahkan staging ke tim QA.

### 11.1 User dan Akses

- [ ] 8 user bisa login dengan password `FundaraDemo2026!`
- [ ] `aditya.surya` (Field Staff) tidak bisa mengakses menu Grant Management
- [ ] `hendra.wijaya` (Finance Manager) bisa approve Cash Advance
- [ ] `irma.sulistyo` (Executive Director) bisa melihat semua transaksi semua fund

### 11.2 Fund dan Saldo (D-02 Verification)

- [ ] 5 Fund tersedia di dropdown field "Fund" pada Cash Advance form baru
- [ ] Saldo **Dana USAID Kesehatan Komunitas** = 250.000 USD dikurangi hanya transaksi berstatus Paid. Cash Advance Budi Santoso (Approved, IDR 5.000.000) TIDAK mengurangi saldo.
- [ ] Saldo **Dana EU Pendidikan** = 150.000 EUR dikurangi EUR 200 (Cash Advance Siti Rahma yang sudah Paid). Total available = 149.800 EUR.
- [ ] Dashboard Finance Officer menampilkan **1 Cash Advance Overdue** (Siti Rahma, Dana USAID, IDR 1.200.000, status Overdue)
- [ ] Dashboard Finance Officer menampilkan **1 Cash Advance Pending Payment** (Budi Santoso, Dana USAID, IDR 5.000.000, status Approved) sebagai warning, bukan sebagai pengurang saldo

### 11.3 Multi-currency (D-04 Verification)

- [ ] Dana USAID menampilkan saldo dalam USD dengan ekuivalen IDR
- [ ] Dana EU menampilkan saldo dalam EUR dengan ekuivalen IDR
- [ ] Cash Advance 3 (Siti Rahma, EUR 200) menampilkan exchange_rate = 17.500 dan amount_in_base_currency = IDR 3.500.000

### 11.4 Grant

- [ ] Grant "USAID Community Health 2026" berstatus Active dengan 4 Grant Budget Lines
- [ ] Grant "EU Education Access 2026" berstatus Active dengan 4 Grant Budget Lines
- [ ] Grant Reporting Schedule Q1 untuk USAID berstatus Submitted
- [ ] Fund "Dana USAID Kesehatan Komunitas" ter-link ke Grant "USAID Community Health 2026"

### 11.5 Donation dan Donor

- [ ] Donor "Maria Yolanda" tersedia di dropdown Donor pada form Donation baru
- [ ] Donation #4 (anonim, IDR 500.000) — receipt menampilkan "Hamba Allah", BUKAN nama donor asli
- [ ] Donor "PT Bank Nusantara" tersedia dengan total donation IDR 50.000.000
- [ ] Semua 4 Donation berstatus Submitted dan ter-link ke Dana Donasi Umum

### 11.6 Organizational Structure

- [ ] 2 Office tersedia dan ter-link ke Organization yang benar
- [ ] 4 Department tersedia dengan department head yang benar
- [ ] Cost Centers ter-link ke Department yang sesuai
- [ ] 3 Delegation of Authority records berstatus Active

### 11.7 Integritas Data Lintas Bounded Context

- [ ] Semua Cash Advance ter-link ke Activity yang valid (Activity.status = Approved atau In Progress)
- [ ] Semua Fund ter-link ke Funding Source yang sesuai
- [ ] Grant Fund (Dana USAID, Dana EU) masing-masing ter-link ke Grant record yang benar via `fund.grant`
- [ ] Project fund allocations menjumlahkan angka yang masuk akal (tidak melebihi opening balance fund)

---

*Dokumen ini adalah spesifikasi — bukan fixtures. Developer menggunakan dokumen ini sebagai blueprint untuk membuat JSON fixtures di `/fundara/fixtures/`. Setiap perubahan pada demo data harus diupdate di dokumen ini terlebih dahulu, lalu baru diimplementasikan di fixtures.*
