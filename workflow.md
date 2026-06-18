# Workflow Fund-centric ERP for Mission-driven Organizations

## Dokumen Alur Proses untuk NGO, Yayasan, Organisasi Sosial, dan Social Enterprise

---

## 1. Tujuan Dokumen

Dokumen ini menjabarkan workflow utama dalam **Fund-centric ERP for Mission-driven Organizations**. Fokusnya adalah alur kerja operasional yang menghubungkan sumber dana, fund, program, project, activity, transaksi, evidence, compliance, dan reporting.

Workflow ini dapat digunakan sebagai dasar untuk:

- desain modul ERP,
- konfigurasi ERPNext/Frappe Workflow,
- penyusunan SOP organisasi,
- desain role dan approval matrix,
- desain dashboard,
- desain data model,
- desain MVP dan roadmap implementasi.

---

## 2. Prinsip Umum Workflow

Setiap workflow dalam sistem harus mengikuti prinsip berikut:

1. **Fund-aware**  
   Setiap transaksi harus mengetahui sumber dana atau fund yang digunakan.

2. **Budget-controlled**  
   Pengeluaran dikontrol sebelum transaksi terjadi, bukan hanya setelah dicatat.

3. **Evidence-based**  
   Setiap proses penting harus memiliki dokumen pendukung yang terhubung langsung ke transaksi atau activity.

4. **Role-based approval**  
   Persetujuan bergantung pada role, nilai transaksi, jenis fund, risiko, dan aturan donor/organisasi.

5. **Audit-ready**  
   Setiap perubahan status, approval, revisi budget, dan dokumen pendukung harus meninggalkan audit trail.

6. **Report-driven**  
   Data yang dimasukkan di workflow harus langsung mendukung donor report, campaign report, business unit report, financial report, dan impact report.

---

## 3. Role Utama

| Role | Fungsi Utama |
|---|---|
| Field Staff | Mengajukan request, menjalankan activity, mengunggah laporan dan evidence |
| Project Officer | Mengelola activity, task, field implementation, dan evidence |
| Project Manager | Menyetujui activity, request, penggunaan budget project, dan laporan program |
| Finance Officer | Melakukan review transaksi, pencatatan, pembayaran, liquidation, dan rekonsiliasi |
| Finance Manager | Menyetujui transaksi bernilai besar, budget exception, dan laporan keuangan |
| Procurement Officer | Mengelola RFQ, quotation, bid analysis, PO, vendor, dan procurement compliance |
| Operations Manager | Mengawasi asset, inventory, logistics, travel, dan operation request |
| Grant Manager | Mengelola grant, compliance donor, donor report, dan closeout |
| Fundraising Manager | Mengelola campaign, donor, receipt, fundraising cost, dan public report |
| Business Unit Manager | Mengelola sales, cost, margin, dan surplus unit usaha |
| MEAL Officer | Mengelola indicator, target, achievement, feedback, dan impact evidence |
| Executive Director | Approval strategis, exception, penggunaan reserve, dan final report |
| Board / Trustee | Approval kebijakan besar, reserve fund, audit, dan strategic allocation |
| Auditor | Melakukan review dokumen, audit trail, supporting document, dan compliance |

---

## 4. Status Umum Dokumen

Sebagian besar workflow dapat memakai pola status berikut:

```text
Draft
  -> Submitted
  -> Under Review
  -> Approved
  -> In Progress
  -> Completed
  -> Closed
```

Status tambahan sesuai kebutuhan:

```text
Rejected
Returned for Revision
Cancelled
On Hold
Budget Exception
Compliance Exception
Overdue
Pending Evidence
Pending Payment
Pending Liquidation
```

---

# 5. Workflow Funding Source Management

## 5.1 Tujuan

Mengelola sumber dana organisasi, baik grant donor, donasi publik, corporate giving, unit usaha, membership fee, maupun dana internal.

## 5.2 Alur Utama

```text
Funding Source Identified
  -> Funding Source Registered
  -> Due Diligence / Classification
  -> Finance Review
  -> Management Approval
  -> Active Funding Source
  -> Linked to Fund / Grant / Campaign / Business Unit
  -> Periodic Review
  -> Archived / Inactive
```

## 5.3 Langkah Detail

| Tahap | Aktor | Aktivitas | Output |
|---|---|---|---|
| Identifikasi | Program/Fundraising/Management | Mengidentifikasi sumber dana potensial | Draft Funding Source |
| Registrasi | Admin/Fundraising/Grant Manager | Membuat master data funding source | Funding Source Record |
| Klasifikasi | Finance/Management | Menentukan tipe: grant, campaign, donation, business, internal | Funding Source Type |
| Due Diligence | Finance/Compliance | Mengecek legalitas, reputasi, restriction, risiko | Due Diligence Note |
| Approval | Management | Menyetujui sumber dana untuk digunakan | Approved Funding Source |
| Aktivasi | Finance/System Admin | Menghubungkan ke fund, grant, campaign, atau unit usaha | Active Funding Source |
| Review Berkala | Finance/Management | Meninjau status dan risiko | Review Log |

## 5.4 Kontrol Sistem

- Funding source tidak boleh dipakai sebelum status **Approved**.
- Funding source harus memiliki kategori yang jelas.
- Funding source berisiko tinggi membutuhkan approval tambahan.
- Funding source yang inactive tidak boleh digunakan pada transaksi baru.

---

# 6. Workflow Fund Creation & Fund Setup

## 6.1 Tujuan

Membuat kantong dana atau **Fund** yang menjadi pusat kontrol penggunaan dana.

## 6.2 Jenis Fund

- Grant Fund
- Campaign Fund
- Unrestricted General Fund
- Business Surplus Fund
- Reserve Fund
- Co-Funding Fund
- Bridging Fund
- Board-designated Fund

## 6.3 Alur Utama

```text
Fund Request Created
  -> Fund Type Selected
  -> Restriction Defined
  -> Budget / Allocation Setup
  -> Finance Review
  -> Management Approval
  -> Fund Activated
  -> Transactions Linked
  -> Fund Monitoring
  -> Fund Closure
```

## 6.4 Langkah Detail

| Tahap | Aktor | Aktivitas | Output |
|---|---|---|---|
| Request | Grant/Fundraising/Finance/Management | Mengajukan pembuatan fund baru | Draft Fund |
| Klasifikasi | Finance | Menentukan fund type dan restriction | Fund Classification |
| Setup Rule | Finance/Grant Manager | Menentukan allowed cost, disallowed cost, periode, approval rule | Fund Rule |
| Budget Setup | Finance/Program | Membuat budget atau alokasi dana | Fund Budget |
| Review | Finance Manager | Mengecek struktur fund | Reviewed Fund |
| Approval | Executive Director/Board | Menyetujui fund | Approved Fund |
| Activation | Finance/System Admin | Mengaktifkan fund untuk transaksi | Active Fund |
| Monitoring | Finance/Manager | Memantau income, expense, balance, exception | Fund Dashboard |
| Closure | Finance/Manager | Menutup fund setelah selesai | Closed Fund |

## 6.5 Kontrol Sistem

- Fund wajib memiliki funding source.
- Fund wajib memiliki restriction status: restricted, unrestricted, temporarily restricted, atau board-designated.
- Fund restricted wajib memiliki purpose dan allowed usage.
- Fund tidak bisa digunakan di luar periode aktif, kecuali ada approval exception.
- Closed fund tidak bisa menerima transaksi baru.

---

# 7. Workflow Grant Lifecycle

## 7.1 Tujuan

Mengelola grant dari tahap peluang, award, implementasi, reporting, sampai closeout.

## 7.2 Alur Utama

```text
Grant Opportunity
  -> Proposal Development
  -> Proposal Submitted
  -> Award Notification
  -> Grant Agreement Review
  -> Grant Setup
  -> Budget Setup
  -> Implementation
  -> Periodic Reporting
  -> Amendment / Budget Revision if needed
  -> Closeout
  -> Archived
```

## 7.3 Status Grant

```text
Pipeline
Submitted
Awarded
Agreement Review
Active
Extended
Suspended
Closing
Closed
Rejected
Cancelled
```

## 7.4 Langkah Detail

| Tahap | Aktor | Aktivitas | Output |
|---|---|---|---|
| Opportunity | Grant Manager/Program | Mencatat peluang grant | Grant Pipeline |
| Proposal | Program/Finance/MEAL | Menyusun proposal, budget, logframe | Proposal Package |
| Submission | Grant Manager | Mengirim proposal ke donor | Submitted Proposal |
| Award | Donor/Management | Menerima notifikasi award | Award Notice |
| Agreement Review | Management/Legal/Finance | Review kontrak, compliance, budget, currency | Reviewed Agreement |
| Grant Setup | Grant Manager | Membuat Grant Fund dan master grant | Active Grant Record |
| Budget Setup | Finance/Program | Input approved budget dan budget line | Grant Budget |
| Implementation | Program/Finance/Ops | Menjalankan activity dan transaksi | Project Execution |
| Reporting | Finance/Program/MEAL | Menyusun laporan periodik | Donor Report |
| Amendment | Grant Manager | Mengelola revisi kontrak/budget | Amendment Record |
| Closeout | Grant/Finance/Program | Menutup grant, audit, final report | Closed Grant |

## 7.5 Kontrol Sistem

- Grant belum aktif tidak boleh digunakan untuk transaksi.
- Setiap grant harus memiliki start date, end date, donor, currency, budget, dan reporting schedule.
- Expense di luar periode grant masuk status **Compliance Exception**.
- Budget revision harus versioned, tidak boleh overwrite tanpa audit trail.
- Grant closeout tidak bisa dilakukan jika masih ada outstanding advance, unpaid invoice, missing evidence, atau pending report.

---

# 8. Workflow Fundraising Campaign

## 8.1 Tujuan

Mengelola campaign fundraising dari perencanaan, penerimaan donasi, penggunaan dana, pelaporan publik, sampai penutupan campaign.

## 8.2 Alur Utama

```text
Campaign Proposal
  -> Campaign Review
  -> Campaign Approval
  -> Campaign Launch
  -> Donation Collection
  -> Receipt / Acknowledgment
  -> Fund Allocation
  -> Program Utilization
  -> Campaign Reporting
  -> Campaign Closure
```

## 8.3 Status Campaign

```text
Draft
Under Review
Approved
Active
Paused
Completed
Reporting
Closed
Cancelled
```

## 8.4 Langkah Detail

| Tahap | Aktor | Aktivitas | Output |
|---|---|---|---|
| Proposal | Fundraising/Program | Membuat tujuan campaign, target, periode, narasi | Draft Campaign |
| Review | Finance/Program/Management | Mengecek purpose, restriction, biaya campaign | Reviewed Campaign |
| Approval | Management | Menyetujui campaign | Approved Campaign |
| Launch | Fundraising | Meluncurkan campaign ke channel publik | Active Campaign |
| Collection | Donor/Fundraising/Finance | Menerima donasi via bank, QRIS, payment gateway, event | Donation Receipt |
| Acknowledgment | Fundraising | Mengirim ucapan terima kasih/receipt | Donor Acknowledgment |
| Allocation | Finance | Membuat Campaign Fund dan mencatat net fund | Available Campaign Fund |
| Utilization | Program/Ops/Finance | Menggunakan dana untuk activity | Campaign Expense |
| Reporting | Program/Fundraising/MEAL | Membuat laporan penggunaan dan dampak | Campaign Report |
| Closure | Finance/Fundraising | Menutup campaign dan saldo sisa | Closed Campaign |

## 8.5 Kontrol Sistem

- Campaign restricted harus memiliki tujuan penggunaan yang jelas.
- Biaya fundraising harus dipisahkan dari dana yang tersedia untuk program.
- Donasi anonim tetap tercatat sebagai transaksi, tetapi identitas donor tidak wajib.
- Donasi untuk campaign tertentu tidak boleh digunakan untuk tujuan lain tanpa approval dan kebijakan yang jelas.
- Campaign tidak bisa ditutup jika masih ada transaksi pending atau report belum selesai.

---

# 9. Workflow Donation Receipt

## 9.1 Tujuan

Mencatat penerimaan donasi dari individu, corporate, event, online channel, transfer bank, atau channel lainnya.

## 9.2 Alur Utama

```text
Donation Received
  -> Donor Identified / Anonymous
  -> Campaign or Fund Selected
  -> Payment Verified
  -> Receipt Generated
  -> Acknowledgment Sent
  -> Accounting Entry Posted
  -> Donor Record Updated
```

## 9.3 Langkah Detail

| Tahap | Aktor | Aktivitas | Output |
|---|---|---|---|
| Receive | Finance/Fundraising | Menerima notifikasi donasi | Donation Draft |
| Identify | Fundraising | Menghubungkan ke donor/campaign/fund | Donor Link |
| Verify | Finance | Verifikasi pembayaran masuk | Verified Donation |
| Receipt | System/Finance | Membuat receipt number | Donation Receipt |
| Acknowledge | Fundraising/System | Kirim ucapan terima kasih | Acknowledgment Sent |
| Posting | Finance/System | Posting ke accounting | GL Entry |
| Update | System | Update donor history dan campaign progress | Donor/Campaign Dashboard |

## 9.4 Kontrol Sistem

- Donasi tidak boleh diposting sebelum pembayaran terverifikasi.
- Donasi restricted wajib ditautkan ke campaign atau fund tertentu.
- Receipt number harus unik.
- Refund donation harus melalui workflow khusus dan audit trail.

---

# 10. Workflow Unit Usaha / Social Enterprise

## 10.1 Tujuan

Mengelola pendapatan dan biaya unit usaha, menghitung surplus, dan mengalokasikan surplus ke misi organisasi.

## 10.2 Alur Utama

```text
Business Unit Setup
  -> Product / Service Setup
  -> Sales Transaction
  -> Invoice Issued
  -> Payment Received
  -> Cost Recorded
  -> Profit / Surplus Calculated
  -> Surplus Allocation Proposal
  -> Management Approval
  -> Fund Transfer / Allocation
  -> Business Unit Report
```

## 10.3 Status Business Transaction

```text
Draft
Submitted
Invoiced
Paid
Partially Paid
Closed
Cancelled
```

## 10.4 Langkah Detail

| Tahap | Aktor | Aktivitas | Output |
|---|---|---|---|
| Setup | Business Unit Manager/Finance | Membuat business unit, product/service, cost center | Active Business Unit |
| Sales | Business Unit Staff | Membuat sales order/invoice | Sales Invoice |
| Payment | Finance | Menerima pembayaran | Payment Entry |
| Costing | Business Unit/Finance | Mencatat COGS dan operating expense | Business Cost |
| P&L | Finance/System | Menghitung revenue, cost, margin, surplus | Business Unit P&L |
| Allocation Proposal | Business Unit Manager/Finance | Mengusulkan alokasi surplus | Surplus Allocation Draft |
| Approval | Management/Board | Menyetujui alokasi surplus | Approved Allocation |
| Fund Transfer | Finance | Memindahkan surplus ke fund tujuan | Fund Transfer |
| Reporting | Finance/Business Unit | Membuat laporan unit usaha | Business Unit Report |

## 10.5 Kontrol Sistem

- Revenue dan expense unit usaha wajib memakai cost center business unit.
- Surplus hanya bisa dialokasikan setelah periode ditutup atau setelah cut-off yang disepakati.
- Alokasi surplus ke program/reserve harus disetujui sesuai policy.
- Unit usaha dengan inventory harus memakai stock movement dan COGS.
- Unit usaha harus dipisahkan dari grant fund agar tidak mencampur dana restricted dan revenue usaha.

---

# 11. Workflow Annual Planning & Organizational Budget

## 11.1 Tujuan

Menyusun rencana kerja dan anggaran tahunan organisasi lintas fund, program, dan unit.

## 11.2 Alur Utama

```text
Strategic Priority Review
  -> Department / Program Planning
  -> Funding Availability Review
  -> Draft Annual Budget
  -> Finance Consolidation
  -> Management Review
  -> Board Approval
  -> Budget Published
  -> Periodic Forecast / Revision
```

## 11.3 Langkah Detail

| Tahap | Aktor | Aktivitas | Output |
|---|---|---|---|
| Priority | Management/Board | Menentukan prioritas tahunan | Strategic Direction |
| Planning | Program/Ops/HR/Business Unit | Menyusun rencana kerja dan kebutuhan budget | Department Plan |
| Funding Review | Finance/Grant/Fundraising | Mengecek grant, campaign, unrestricted, reserve, business surplus | Funding Forecast |
| Draft Budget | Finance | Konsolidasi budget organisasi | Draft Annual Budget |
| Review | Management | Review gap, risiko, cash flow, reserve | Reviewed Budget |
| Approval | Board | Menyetujui budget tahunan | Approved Budget |
| Publish | Finance/System Admin | Mengaktifkan budget di sistem | Active Budget |
| Forecast | Finance/Management | Update forecast berkala | Revised Forecast |

## 11.4 Kontrol Sistem

- Budget tahunan harus membedakan restricted dan unrestricted fund.
- Budget organisasi tidak boleh mengasumsikan grant belum pasti sebagai dana available kecuali diberi status forecast.
- Revisi budget harus memiliki alasan dan approval.
- Budget harus terhubung ke cost center, project, fund, dan activity.

---

# 12. Workflow Project Setup

## 12.1 Tujuan

Membuat project sebagai unit implementasi program yang dibiayai oleh satu atau lebih fund.

## 12.2 Alur Utama

```text
Project Concept
  -> Project Charter
  -> Funding Mapping
  -> Budget Allocation
  -> Workplan Setup
  -> Team Assignment
  -> Risk & Compliance Review
  -> Project Approval
  -> Project Activation
```

## 12.3 Langkah Detail

| Tahap | Aktor | Aktivitas | Output |
|---|---|---|---|
| Concept | Program | Membuat ide project | Project Concept Note |
| Charter | Project Manager | Menyusun tujuan, output, lokasi, periode, target beneficiary | Project Charter |
| Funding | Finance/Grant Manager | Menentukan fund yang membiayai project | Funding Map |
| Budget | Finance/Program | Mengalokasikan budget ke project/activity | Project Budget |
| Workplan | Project Team | Membuat activity, milestone, task | Project Workplan |
| Team | HR/Project Manager | Menetapkan PIC dan team | Team Assignment |
| Review | Finance/Compliance/MEAL | Review budget, compliance, indicator, risk | Review Note |
| Approval | Management | Menyetujui project | Approved Project |
| Activation | System Admin/Project Manager | Mengaktifkan project | Active Project |

## 12.4 Kontrol Sistem

- Project harus memiliki fund source atau funding plan.
- Project tidak boleh aktif jika budget belum disetujui.
- Project multi-fund harus memiliki cost sharing rule.
- Project restricted harus mengikuti rule fund terkait.
- Project wajib memiliki PIC, periode, lokasi, dan status.

---

# 13. Workflow Activity Planning

## 13.1 Tujuan

Merencanakan kegiatan lapangan atau kegiatan program yang akan menggunakan dana project/fund.

## 13.2 Alur Utama

```text
Activity Draft
  -> Budget Line Selected
  -> Fund / Project Linked
  -> Workplan Review
  -> Budget Availability Check
  -> Compliance Check
  -> Project Manager Approval
  -> Finance Review
  -> Activity Approved
  -> Implementation
  -> Activity Completion Report
  -> Activity Closed
```

## 13.3 Langkah Detail

| Tahap | Aktor | Aktivitas | Output |
|---|---|---|---|
| Draft | Project Officer | Membuat rencana activity | Draft Activity |
| Budget Link | Project Officer/Finance | Memilih fund, project, budget line | Activity Budget Link |
| Review | Project Manager | Mengecek relevansi activity dengan workplan | Reviewed Activity |
| Budget Check | System/Finance | Mengecek ketersediaan budget | Budget Check Result |
| Compliance | Grant/Finance/Ops | Mengecek rule donor/campaign/fund | Compliance Check |
| Approval | Project Manager/Finance | Menyetujui activity | Approved Activity |
| Implementation | Field Staff/Project Officer | Menjalankan activity | Activity in Progress |
| Report | Field Staff | Mengunggah laporan, attendance, foto, evidence | Activity Report |
| Closure | Project Manager/Finance/MEAL | Review hasil dan tutup activity | Closed Activity |

## 13.4 Kontrol Sistem

- Activity tidak bisa digunakan untuk request biaya jika belum approved.
- Activity harus memiliki budget estimate.
- Activity harus memiliki expected output dan indicator link jika relevan.
- Activity yang telah closed tidak bisa menerima biaya baru kecuali ada exception.

---

# 14. Workflow Budget Allocation

## 14.1 Tujuan

Mengalokasikan budget dari fund ke project, activity, budget line, cost center, atau location.

## 14.2 Alur Utama

```text
Budget Allocation Draft
  -> Source Fund Selected
  -> Project / Activity Selected
  -> Budget Line Mapping
  -> Amount Allocation
  -> Finance Review
  -> Manager Approval
  -> Budget Activated
  -> Budget Monitoring
```

## 14.3 Kontrol Sistem

- Alokasi tidak boleh melebihi available fund.
- Restricted fund hanya boleh dialokasikan ke tujuan yang sesuai restriction.
- Budget line donor/campaign dapat berbeda dari chart of accounts, sehingga harus ada mapping.
- Setiap perubahan budget harus versioned.

---

# 15. Workflow Budget Revision

## 15.1 Tujuan

Mengelola perubahan budget akibat perubahan project, donor approval, realokasi internal, atau perubahan kebutuhan lapangan.

## 15.2 Alur Utama

```text
Revision Request
  -> Reason Provided
  -> Current vs Proposed Budget Compared
  -> Donor / Fund Rule Check
  -> Finance Review
  -> Program Review
  -> Donor Approval if Required
  -> Management Approval
  -> New Budget Version Activated
```

## 15.3 Langkah Detail

| Tahap | Aktor | Aktivitas | Output |
|---|---|---|---|
| Request | Project Manager/Finance | Mengajukan revisi budget | Revision Draft |
| Justification | Requester | Menulis alasan dan dampak | Revision Justification |
| Comparison | System/Finance | Membandingkan budget lama vs baru | Budget Comparison |
| Rule Check | Grant Manager/Finance | Mengecek threshold donor/internal | Rule Check Result |
| Review | Program/Finance | Review teknis dan keuangan | Review Note |
| Donor Approval | Grant Manager | Mengirim ke donor jika wajib | Donor Approval Record |
| Management Approval | Management | Final approval | Approved Revision |
| Activation | Finance/System | Mengaktifkan versi budget baru | Active Budget Version |

## 15.4 Kontrol Sistem

- Budget revision tidak boleh menghapus histori budget lama.
- Sistem harus menyimpan versi budget.
- Revisi yang melebihi threshold wajib donor approval.
- Transaksi yang sudah posted tidak boleh otomatis berubah tanpa jurnal koreksi atau reclassification.

---

# 16. Workflow Expense Request

## 16.1 Tujuan

Mengajukan pengeluaran sebelum transaksi dilakukan, terutama untuk biaya program, operasional, atau activity.

## 16.2 Alur Utama

```text
Expense Request Draft
  -> Fund / Project / Activity / Budget Line Selected
  -> Supporting Details Added
  -> Budget Availability Check
  -> Compliance Check
  -> Supervisor / Project Manager Approval
  -> Finance Review
  -> Approved for Spending
  -> Payment / Procurement / Advance Process
```

## 16.3 Kontrol Sistem

- Expense request harus memiliki fund, project, activity, atau cost center yang jelas.
- Restricted fund harus melewati eligibility check.
- Jika budget tidak cukup, status menjadi **Budget Exception**.
- Jika dokumen pendukung tidak lengkap, status menjadi **Pending Evidence**.
- Approval matrix bergantung pada amount dan fund type.

---

# 17. Workflow Cash Advance

## 17.1 Tujuan

Mengelola uang muka untuk staff atau team yang akan melakukan activity/program/operasional.

## 17.2 Alur Utama

```text
Cash Advance Request
  -> Activity / Fund / Budget Line Linked
  -> Budget Check
  -> Outstanding Advance Check
  -> Supervisor Approval
  -> Project Manager Approval
  -> Finance Approval
  -> Payment Released
  -> Advance Outstanding
  -> Liquidation Due
```

## 17.3 Status Cash Advance

```text
Draft
Submitted
Under Review
Approved
Paid
Pending Liquidation
Overdue
Liquidated
Closed
Rejected
Cancelled
```

## 17.4 Langkah Detail

| Tahap | Aktor | Aktivitas | Output |
|---|---|---|---|
| Request | Staff | Mengajukan advance | Draft Cash Advance |
| Link | Staff/Project Officer | Memilih fund, project, activity, budget line | Tagged Advance |
| Budget Check | System/Finance | Mengecek budget tersedia | Budget Check |
| Outstanding Check | System | Mengecek advance lama yang belum selesai | Advance Risk Flag |
| Approval | Supervisor/PM | Menyetujui kebutuhan advance | Manager Approval |
| Finance Approval | Finance | Review cash flow, eligibility, dokumen | Finance Approved |
| Payment | Finance | Mencairkan dana | Payment Entry |
| Monitoring | Finance/System | Menandai due date liquidation | Advance Aging |

## 17.5 Kontrol Sistem

- Staff dengan advance overdue dapat diblokir dari advance baru.
- Advance harus memiliki due date liquidation.
- Advance restricted fund harus sesuai activity approved.
- Pencairan advance harus tercatat sebagai receivable/advance, bukan langsung expense.

---

# 18. Workflow Liquidation

## 18.1 Tujuan

Mempertanggungjawabkan penggunaan cash advance dengan receipt, evidence, dan perhitungan selisih.

## 18.2 Alur Utama

```text
Liquidation Draft
  -> Expense Details Entered
  -> Receipts Uploaded
  -> Activity Report Linked
  -> Finance Completeness Check
  -> Eligibility Check
  -> Amount Reconciliation
  -> Project Manager Review
  -> Finance Approval
  -> Expense Posted
  -> Refund / Reimbursement if needed
  -> Advance Closed
```

## 18.3 Status Liquidation

```text
Draft
Submitted
Under Finance Review
Returned for Revision
Approved
Refund Required
Reimbursement Required
Posted
Closed
Rejected
```

## 18.4 Kontrol Sistem

- Liquidation tidak boleh approved tanpa receipt/evidence wajib.
- Expense yang tidak eligible harus ditolak atau dialihkan ke unrestricted fund jika disetujui.
- Jika actual < advance, sistem membuat refund required.
- Jika actual > advance, sistem membuat reimbursement required.
- Setelah posted, actual expense mengurangi budget fund/project/activity.

---

# 19. Workflow Procurement Planning

## 19.1 Tujuan

Menyusun rencana pengadaan berdasarkan project, fund, activity, dan budget.

## 19.2 Alur Utama

```text
Procurement Need Identified
  -> Procurement Plan Draft
  -> Fund / Project / Activity Linked
  -> Budget Check
  -> Procurement Method Determined
  -> Procurement Plan Review
  -> Approval
  -> Plan Activated
```

## 19.3 Kontrol Sistem

- Procurement plan harus terkait dengan budget dan activity.
- Procurement method ditentukan oleh threshold organisasi atau donor/fund.
- Procurement plan untuk restricted grant harus mengikuti rule donor.
- Procurement di luar plan membutuhkan justification atau exception.

---

# 20. Workflow Purchase Request to Payment

## 20.1 Tujuan

Mengelola pembelian barang/jasa dari request sampai pembayaran.

## 20.2 Alur Utama

```text
Purchase Request
  -> Budget Check
  -> Procurement Method Check
  -> Manager Approval
  -> RFQ / Quotation Collection
  -> Bid Analysis
  -> Procurement Review
  -> Purchase Order
  -> Goods Receipt / Service Acceptance
  -> Supplier Invoice
  -> Finance Review
  -> Payment
  -> Expense Posted
  -> Evidence Archived
```

## 20.3 Status Purchase Request

```text
Draft
Submitted
Budget Checked
Approved
RFQ Required
Quotation Review
PO Created
Partially Received
Received
Invoiced
Paid
Closed
Cancelled
```

## 20.4 Langkah Detail

| Tahap | Aktor | Aktivitas | Output |
|---|---|---|---|
| PR | Requester | Mengajukan purchase request | Purchase Request |
| Budget Check | System/Finance | Mengecek fund/budget line | Budget Check |
| Method | System/Procurement | Menentukan metode pengadaan | Procurement Method |
| Approval | PM/Manager | Approve kebutuhan | Approved PR |
| RFQ | Procurement | Mengirim permintaan quotation | RFQ |
| Quotation | Supplier/Procurement | Menerima quotation | Supplier Quotation |
| Bid Analysis | Procurement Committee | Membandingkan penawaran | Bid Analysis |
| PO | Procurement | Membuat purchase order | Purchase Order |
| Receipt | Ops/Requester | Menerima barang/jasa | GRN / Service Acceptance |
| Invoice | Supplier/Finance | Menerima invoice | Purchase Invoice |
| Review | Finance | Review dokumen dan posting | Approved Invoice |
| Payment | Finance | Membayar supplier | Payment Entry |
| Archive | System | Menyimpan evidence | Supporting Document Register |

## 20.5 Kontrol Sistem

- PR harus memiliki fund, project, budget line, dan cost center.
- Sistem harus memblokir PR jika budget tidak cukup, kecuali exception approved.
- Procurement threshold menentukan dokumen wajib.
- PO tidak bisa dibuat jika quotation/bid analysis wajib belum lengkap.
- Payment tidak bisa dilakukan jika goods receipt atau service acceptance belum ada.

---

# 21. Workflow Vendor Management

## 21.1 Tujuan

Mengelola supplier/vendor termasuk due diligence dan compliance.

## 21.2 Alur Utama

```text
Vendor Registration
  -> Document Collection
  -> Due Diligence
  -> Conflict of Interest Check
  -> Finance / Procurement Review
  -> Vendor Approval
  -> Active Vendor
  -> Periodic Review
  -> Suspended / Archived
```

## 21.3 Kontrol Sistem

- Vendor belum approved tidak boleh digunakan untuk PO.
- Vendor tertentu perlu dokumen legal, rekening bank, NPWP/tax ID, dan compliance declaration.
- Conflict of interest harus dicatat.
- Vendor yang suspended tidak boleh menerima transaksi baru.

---

# 22. Workflow Travel Request

## 22.1 Tujuan

Mengelola perjalanan dinas program, operasional, fundraising, atau unit usaha.

## 22.2 Alur Utama

```text
Travel Request Draft
  -> Purpose / Activity Linked
  -> Itinerary Added
  -> Budget Estimate
  -> Fund / Project / Budget Line Selected
  -> Supervisor Approval
  -> Finance Review
  -> Travel Approved
  -> Advance / Booking / Payment
  -> Travel Completed
  -> Travel Report & Liquidation
  -> Closed
```

## 22.3 Kontrol Sistem

- Travel harus terkait tujuan kerja yang jelas.
- Perjalanan grant-funded harus berada dalam periode grant dan budget eligible.
- Per diem, tiket, hotel, dan transport mengikuti policy.
- Travel report dan liquidation wajib sebelum closed.

---

# 23. Workflow Asset Acquisition & Management

## 23.1 Tujuan

Mengelola asset dari pembelian, pencatatan, assignment, maintenance, sampai disposal.

## 23.2 Alur Utama

```text
Asset Need Identified
  -> Purchase / Donation / Transfer
  -> Asset Received
  -> Asset Registered
  -> Funding Source Tagged
  -> Asset Assigned
  -> Periodic Verification
  -> Maintenance if needed
  -> Transfer / Disposal Request
  -> Disposal Approval
  -> Asset Closed
```

## 23.3 Kontrol Sistem

- Asset harus memiliki funding source/fund, terutama jika dibeli dari grant atau campaign restricted.
- Asset grant-funded harus mengikuti donor rule untuk disposal atau transfer.
- Asset assignment harus tercatat ke staff/location/project.
- Disposal membutuhkan approval dan dokumen pendukung.

---

# 24. Workflow Inventory & Distribution

## 24.1 Tujuan

Mengelola barang persediaan, terutama untuk distribusi bantuan, program, atau unit usaha.

## 24.2 Alur Utama

```text
Stock Need / Procurement
  -> Goods Received
  -> Stock Entry
  -> Warehouse Assignment
  -> Distribution Plan
  -> Stock Issue
  -> Beneficiary / Location Receipt
  -> Distribution Evidence Uploaded
  -> Stock Reconciliation
  -> Distribution Report
```

## 24.3 Kontrol Sistem

- Stock harus ditag ke fund/project jika dibeli untuk program tertentu.
- Distribusi restricted fund harus sesuai target program/campaign.
- Stock issue harus memiliki recipient, location, dan evidence.
- Perbedaan stock opname harus melalui adjustment approval.

---

# 25. Workflow Payroll & Staff Cost Allocation

## 25.1 Tujuan

Mengalokasikan biaya personel ke fund, grant, project, atau unrestricted budget.

## 25.2 Alur Utama

```text
Employee Assignment
  -> Funding Allocation Rule
  -> Timesheet / Level of Effort if needed
  -> Payroll Processed
  -> Payroll Cost Split
  -> Finance Review
  -> Payroll Posted
  -> Donor / Fund Report Updated
```

## 25.3 Kontrol Sistem

- Staff cost funded by grant harus sesuai budget dan periode grant.
- Cost sharing antar fund harus memiliki allocation rule.
- Payroll allocation tidak boleh melebihi approved level of effort.
- Timesheet wajib jika donor mensyaratkan.

---

# 26. Workflow Cost Sharing & Multi-Fund Expense

## 26.1 Tujuan

Membagi satu expense ke beberapa fund/project sesuai aturan cost sharing.

## 26.2 Alur Utama

```text
Expense Identified
  -> Cost Sharing Rule Selected
  -> Fund Split Calculated
  -> Budget Availability Checked per Fund
  -> Finance Review
  -> Manager Approval
  -> Transaction Posted with Split Allocation
  -> Fund Reports Updated
```

## 26.3 Contoh

Expense Rp100.000.000 dibagi:

| Fund | Persentase | Amount |
|---|---:|---:|
| Grant A | 60% | Rp60.000.000 |
| Campaign Fund | 25% | Rp25.000.000 |
| Business Surplus Fund | 15% | Rp15.000.000 |

## 26.4 Kontrol Sistem

- Setiap fund dalam split harus memiliki budget cukup.
- Restricted fund tidak boleh menanggung biaya yang tidak eligible.
- Cost sharing rule harus approved sebelum dipakai.
- Split allocation harus terlihat di laporan masing-masing fund.

---

# 27. Workflow Bridging Fund & Inter-Fund Settlement

## 27.1 Tujuan

Mengelola penggunaan dana internal sementara untuk membayar biaya yang nantinya akan diganti oleh grant atau fund tertentu.

## 27.2 Alur Utama

```text
Bridging Need Identified
  -> Eligible Future Fund Selected
  -> Internal Fund Selected
  -> Bridging Approval
  -> Expense Paid from Internal Fund
  -> Receivable from Target Fund Recorded
  -> Target Fund Received
  -> Settlement Proposed
  -> Finance Approval
  -> Inter-Fund Settlement Posted
  -> Bridging Closed
```

## 27.3 Kontrol Sistem

- Bridging harus memiliki target fund yang jelas.
- Biaya bridging harus eligible terhadap target fund.
- Settlement tidak boleh dilakukan tanpa dana target diterima.
- Laporan harus membedakan cash source dan final funding source.

---

# 28. Workflow Bank Reconciliation

## 28.1 Tujuan

Mencocokkan transaksi bank dengan catatan ERP.

## 28.2 Alur Utama

```text
Bank Statement Imported
  -> Transactions Matched
  -> Unmatched Items Reviewed
  -> Missing Entries Created
  -> Difference Investigated
  -> Finance Review
  -> Reconciliation Approved
  -> Period Closed
```

## 28.3 Kontrol Sistem

- Unmatched transaction harus diberi status dan PIC.
- Bank charge, interest, dan forex difference harus dicatat sesuai fund/cost center jika relevan.
- Rekonsiliasi bulanan harus selesai sebelum financial period closed.

---

# 29. Workflow Financial Period Closing

## 29.1 Tujuan

Menutup periode akuntansi bulanan/kuartalan/tahunan.

## 29.2 Alur Utama

```text
Cut-off Date Reached
  -> Pending Transactions Reviewed
  -> Bank Reconciliation Completed
  -> Advance Aging Reviewed
  -> Accruals Posted
  -> Prepayments Reviewed
  -> Budget vs Actual Reviewed
  -> Finance Manager Approval
  -> Period Locked
  -> Management Reports Issued
```

## 29.3 Kontrol Sistem

- Period tidak boleh closed jika bank reconciliation belum selesai.
- Pending liquidation harus dilaporkan.
- Transaksi setelah period lock membutuhkan reopening approval.
- Donor report period harus mengikuti cut-off yang disepakati.

---

# 30. Workflow Donor Report

## 30.1 Tujuan

Menghasilkan laporan donor dari data transaksi, activity, evidence, dan indicator.

## 30.2 Alur Utama

```text
Reporting Period Open
  -> Transactions Pulled
  -> Budget vs Actual Generated
  -> Supporting Documents Checked
  -> Variance Analysis Added
  -> Program Narrative Added
  -> MEAL Indicator Added
  -> Finance Review
  -> Program Review
  -> Grant Manager Review
  -> Management Approval
  -> Submitted to Donor
  -> Donor Feedback / Revision
  -> Archived
```

## 30.3 Kontrol Sistem

- Angka donor report harus drill-down ke transaksi.
- Transaksi tanpa evidence wajib diberi flag.
- Variance melewati threshold wajib explanation.
- Laporan final harus dikunci setelah submitted.
- Feedback donor harus dicatat sebagai follow-up.

---

# 31. Workflow Campaign Public Report

## 31.1 Tujuan

Melaporkan penggunaan dana campaign kepada publik, donor individu, atau corporate donor.

## 31.2 Alur Utama

```text
Campaign Reporting Period
  -> Donation Summary Generated
  -> Fundraising Cost Calculated
  -> Net Fund Available Calculated
  -> Program Utilization Pulled
  -> Beneficiary / Impact Data Added
  -> Evidence Selected
  -> Fundraising Review
  -> Finance Review
  -> Management Approval
  -> Public Report Published
  -> Campaign Archive Updated
```

## 31.3 Kontrol Sistem

- Public report tidak boleh menampilkan data pribadi beneficiary tanpa persetujuan atau anonimisasi.
- Fundraising cost harus dipisahkan dari program utilization.
- Sisa dana campaign harus dijelaskan: digunakan lanjut, dialihkan, atau dikembalikan sesuai policy.

---

# 32. Workflow Business Unit Report

## 32.1 Tujuan

Menyusun laporan unit usaha dan kontribusinya terhadap misi sosial.

## 32.2 Alur Utama

```text
Reporting Period Close
  -> Revenue Pulled
  -> COGS Pulled
  -> Operating Expense Pulled
  -> Receivable / Payable Reviewed
  -> Inventory Reviewed
  -> Net Surplus Calculated
  -> Surplus Allocation Reviewed
  -> Finance Review
  -> Business Unit Manager Review
  -> Management Approval
  -> Report Published Internally
```

## 32.3 Kontrol Sistem

- Unit usaha harus memiliki P&L terpisah.
- Surplus belum boleh dialokasikan jika transaksi periode belum closed.
- Pajak/kewajiban legal harus diperhitungkan sebelum surplus allocation.

---

# 33. Workflow MEAL Indicator Tracking

## 33.1 Tujuan

Mengelola target, capaian, evidence, dan laporan dampak program.

## 33.2 Alur Utama

```text
Indicator Framework Setup
  -> Baseline / Target Entered
  -> Activity Linked to Indicator
  -> Achievement Data Collected
  -> Evidence Uploaded
  -> MEAL Verification
  -> Program Review
  -> Indicator Report Updated
  -> Donor / Campaign / Impact Report Generated
```

## 33.3 Kontrol Sistem

- Indicator harus terkait project, grant, campaign, atau program.
- Achievement harus memiliki periode dan evidence.
- Data beneficiary sensitif harus memiliki kontrol akses.
- Koreksi data indicator harus memiliki audit trail.

---

# 34. Workflow Beneficiary Management

## 34.1 Tujuan

Mengelola data beneficiary atau participant secara aman dan sesuai kebutuhan program.

## 34.2 Alur Utama

```text
Beneficiary Registration
  -> Consent Captured
  -> Eligibility Screening
  -> Program Enrollment
  -> Service / Benefit Recorded
  -> Follow-up / Case Update
  -> Outcome Measurement
  -> Data Review
  -> Case Closed / Archived
```

## 34.3 Kontrol Sistem

- Consent harus dicatat jika data pribadi dikumpulkan.
- Akses data beneficiary harus role-based.
- Data sensitif harus dibatasi dan dapat dianonimkan untuk reporting.
- Beneficiary tidak boleh diduplikasi tanpa deduplication check.

---

# 35. Workflow Feedback, Complaint, and Accountability

## 35.1 Tujuan

Mengelola mekanisme umpan balik, komplain, dan accountability kepada beneficiary, donor, publik, dan stakeholder.

## 35.2 Alur Utama

```text
Feedback / Complaint Received
  -> Case Logged
  -> Category and Severity Assigned
  -> Responsible Unit Assigned
  -> Investigation / Follow-up
  -> Resolution Proposed
  -> Management Review if High Risk
  -> Response Provided
  -> Case Closed
  -> Learning Captured
```

## 35.3 Kontrol Sistem

- Komplain sensitif harus memiliki akses terbatas.
- High-risk complaint harus dieskalasi otomatis.
- SLA penyelesaian harus dipantau.
- Data complaint dapat dianalisis untuk learning dan improvement.

---

# 36. Workflow Compliance Exception

## 36.1 Tujuan

Mengelola transaksi atau activity yang melanggar atau berpotensi melanggar budget, donor rule, policy, atau periode fund.

## 36.2 Alur Utama

```text
Exception Detected
  -> Exception Type Classified
  -> Transaction Put On Hold
  -> Justification Required
  -> Finance / Compliance Review
  -> Grant / Fund Manager Review
  -> Management Decision
  -> Approved Exception / Rejected / Reclassified
  -> Audit Trail Updated
```

## 36.3 Jenis Exception

- Budget exceeded
- Expense outside grant period
- Missing mandatory document
- Ineligible cost
- Procurement threshold not met
- Vendor not approved
- Activity not approved
- Fund restriction mismatch
- Exchange rate variance
- Late liquidation

## 36.4 Kontrol Sistem

- Exception tidak boleh diproses diam-diam.
- Semua exception wajib memiliki alasan dan approval.
- Exception yang ditolak harus dikoreksi atau dialihkan ke fund lain jika allowed.
- Exception report harus tersedia untuk audit dan management.

---

# 37. Workflow Supporting Document Register

## 37.1 Tujuan

Mengelola seluruh dokumen pendukung transaksi dan laporan.

## 37.2 Alur Utama

```text
Document Required
  -> Document Uploaded
  -> Document Classified
  -> Linked to Transaction / Activity / Report
  -> Completeness Check
  -> Finance / Program Verification
  -> Archived
  -> Available for Audit Pack
```

## 37.3 Kontrol Sistem

- Sistem harus menentukan dokumen wajib berdasarkan transaction type, fund type, dan threshold.
- Dokumen tidak boleh hanya tersimpan sebagai file tanpa metadata.
- Dokumen harus dapat dicari berdasarkan fund, project, vendor, activity, transaction, dan report period.
- Dokumen sensitif harus memiliki permission khusus.

---

# 38. Workflow Audit Pack Preparation

## 38.1 Tujuan

Menyiapkan paket audit untuk donor, auditor eksternal, internal audit, atau board.

## 38.2 Alur Utama

```text
Audit Scope Defined
  -> Fund / Period / Project Selected
  -> Transaction List Generated
  -> Supporting Documents Pulled
  -> Missing Document Check
  -> Exception List Generated
  -> Finance Review
  -> Management Review
  -> Audit Pack Locked
  -> Shared with Auditor
  -> Findings Logged
  -> Corrective Action Tracked
```

## 38.3 Kontrol Sistem

- Audit pack harus mempertahankan versi final yang dikunci.
- Missing document harus otomatis ditandai.
- Auditor hanya boleh mengakses data sesuai scope.
- Findings dan corrective action harus dilacak sampai closed.

---

# 39. Workflow Grant / Fund Closeout

## 39.1 Tujuan

Menutup fund, grant, campaign, atau project setelah implementasi dan reporting selesai.

## 39.2 Alur Utama

```text
Closeout Initiated
  -> Financial Review
  -> Outstanding Advance Check
  -> Payable / Receivable Check
  -> Asset Review
  -> Inventory Review
  -> Evidence Completeness Check
  -> Final Report Prepared
  -> Remaining Balance Decision
  -> Management / Donor Approval
  -> Fund Closed
  -> Archive Completed
```

## 39.3 Closeout Checklist

| Area | Pertanyaan |
|---|---|
| Finance | Apakah semua transaksi sudah posted? |
| Advance | Apakah semua advance sudah liquidated? |
| Payable | Apakah masih ada invoice belum dibayar? |
| Receivable | Apakah masih ada dana donor belum diterima? |
| Asset | Apakah asset grant/campaign sudah dicatat dan diputuskan statusnya? |
| Inventory | Apakah barang sisa sudah diselesaikan? |
| Evidence | Apakah semua dokumen pendukung lengkap? |
| Report | Apakah final report sudah submitted? |
| Balance | Apakah saldo sisa akan dikembalikan, dialihkan, atau tetap disimpan? |
| Audit | Apakah audit/finding sudah diselesaikan? |

## 39.4 Kontrol Sistem

- Fund tidak bisa closed jika masih ada outstanding transaction.
- Sisa saldo restricted fund harus mengikuti rule donor/campaign.
- Setelah closed, transaksi baru diblokir.
- Reopening closed fund harus memerlukan approval khusus.

---

# 40. Workflow Dashboard & Monitoring

## 40.1 Tujuan

Menyediakan monitoring real-time untuk management, finance, program, fundraising, business unit, dan compliance.

## 40.2 Alur Data

```text
Transactions Posted
  -> Fund / Project / Activity Dimensions Updated
  -> Budget Actual Recalculated
  -> Commitments Updated
  -> Exceptions Flagged
  -> Dashboard Refreshed
  -> Alerts Sent
```

## 40.3 Dashboard Utama

| Dashboard | Pengguna | Isi |
|---|---|---|
| Fund Dashboard | Finance/Management | Income, expense, balance, restriction, utilization |
| Grant Dashboard | Grant Manager | Budget vs actual, burn rate, report due, compliance risk |
| Campaign Dashboard | Fundraising | Donation collected, donor count, utilization, public report |
| Business Unit Dashboard | Business Unit Manager | Revenue, cost, margin, receivable, surplus |
| Project Dashboard | Project Manager | Workplan, activity, expense, output, pending approval |
| Finance Dashboard | Finance | Payables, advances, bank, budget exception, period close |
| Compliance Dashboard | Management/Audit | Missing evidence, procurement exception, overdue liquidation |
| MEAL Dashboard | MEAL/Program | Target vs achievement, beneficiary, evidence, impact |

---

# 41. Workflow Notification & Reminder

## 41.1 Tujuan

Mengirim notifikasi otomatis untuk approval, deadline, exception, dan reporting.

## 41.2 Trigger Utama

| Trigger | Penerima |
|---|---|
| Request submitted | Approver terkait |
| Budget exception | Finance Manager, Project Manager |
| Advance due soon | Staff, Supervisor, Finance |
| Advance overdue | Staff, Supervisor, Finance Manager |
| Donor report due | Grant Manager, Finance, Program |
| Campaign report due | Fundraising Manager, Finance |
| Missing evidence | Requester, Finance Officer |
| Procurement threshold triggered | Procurement Officer |
| Grant nearing end date | Grant Manager, Project Manager, Finance |
| Fund balance low | Finance Manager, Management |

---

# 42. Approval Matrix Ringkas

## 42.1 Berdasarkan Nilai Transaksi

| Nilai | Approval Minimum |
|---:|---|
| Kecil | Supervisor / Project Manager |
| Menengah | Project Manager + Finance |
| Besar | Finance Manager + Operations/Procurement Manager |
| Sangat besar | Executive Director / Board |

## 42.2 Berdasarkan Jenis Fund

| Fund Type | Approval Utama | Kontrol Khusus |
|---|---|---|
| Grant Fund | Project Manager, Finance, Grant Manager | Donor rule, budget line, grant period |
| Campaign Fund | Campaign Manager, Program, Finance | Public accountability, restricted purpose |
| Unrestricted Fund | Department Head, Finance, Management | Annual budget, cash flow |
| Business Surplus Fund | Business Unit Manager, Finance, Management | P&L, tax, surplus policy |
| Reserve Fund | Executive Director, Board | Reserve policy, strategic approval |
| Bridging Fund | Finance Manager, Executive Director | Recoverability, settlement plan |

---

# 43. ERPNext/Frappe Implementation Notes

## 43.1 Standard ERPNext Component

| Proses | ERPNext Component |
|---|---|
| Accounting | GL Entry, Journal Entry, Payment Entry, Accounts |
| Procurement | Material Request/Purchase Request, RFQ, Supplier Quotation, Purchase Order, Purchase Invoice |
| Project | Project, Task, Timesheet |
| Asset | Asset |
| Inventory | Item, Warehouse, Stock Entry, Delivery Note |
| Sales Unit Usaha | Customer, Sales Order, Sales Invoice, Payment Entry |
| Approval | Workflow, Workflow State, Role Permission |
| Reporting | Query Report, Script Report, Dashboard |

## 43.2 Custom DocType yang Disarankan

- Funding Source
- Fund
- Fund Restriction
- Fund Budget
- Fund Allocation
- Fund Transfer
- Grant
- Grant Budget Line
- Grant Budget Revision
- Campaign
- Donation Receipt
- Donor Acknowledgment
- Business Unit Surplus Allocation
- Cost Sharing Rule
- Bridging Fund Settlement
- Activity Plan
- Field Activity Report
- Cash Advance
- Liquidation
- Procurement Threshold Rule
- Bid Analysis
- Supporting Document Register
- Indicator
- Indicator Achievement
- Beneficiary
- Complaint / Feedback Case
- Donor Report
- Campaign Public Report
- Audit Pack
- Closeout Checklist

## 43.3 Accounting Dimensions

Dimensi minimum:

- Fund
- Project
- Cost Center

Dimensi tambahan:

- Grant
- Campaign
- Business Unit
- Activity
- Budget Line
- Location
- Donor
- Funding Source

## 43.4 Conditional Fields

Agar user experience tidak terlalu berat, field harus muncul berdasarkan konteks:

| Kondisi | Field Tambahan |
|---|---|
| Fund Type = Grant | Grant, Donor Budget Line, Reporting Period |
| Fund Type = Campaign | Campaign, Public Report Category |
| Fund Type = Business Unit | Business Unit, Product/Service, Revenue Stream |
| Fund Type = Unrestricted | Allocation Purpose, Department |
| Expense Type = Procurement | Vendor, Quotation, Bid Analysis |
| Expense Type = Advance | Staff, Liquidation Due Date |

---

# 44. Prioritas Workflow untuk MVP

Untuk MVP, workflow yang paling penting adalah:

1. Funding Source Management
2. Fund Creation & Fund Setup
3. Grant Lifecycle sederhana
4. Fundraising Campaign sederhana
5. Donation Receipt
6. Unit Usaha P&L sederhana
7. Project Setup
8. Activity Planning
9. Budget Allocation
10. Expense Request
11. Cash Advance
12. Liquidation
13. Purchase Request to Payment
14. Fund Utilization Report
15. Donor Report sederhana
16. Campaign Report sederhana
17. Business Unit Report sederhana
18. Closeout Checklist sederhana

---

# 45. Ringkasan End-to-End Flow

```text
Funding Source
  -> Fund
      -> Budget / Allocation
          -> Project
              -> Activity
                  -> Request
                      -> Approval
                          -> Procurement / Advance / Expense / Payment
                              -> Evidence
                                  -> Accounting Posting
                                      -> Budget Actual Update
                                          -> Dashboard
                                              -> Report
                                                  -> Audit / Closeout
```

Untuk fundraising:

```text
Campaign
  -> Donation Receipt
      -> Campaign Fund
          -> Program Utilization
              -> Evidence
                  -> Public Report
                      -> Campaign Closure
```

Untuk unit usaha:

```text
Business Unit
  -> Sales
      -> Revenue
          -> Cost
              -> Surplus
                  -> Surplus Allocation
                      -> Program / Reserve / Reinvestment Fund
                          -> Report
```

Untuk grant:

```text
Donor
  -> Grant
      -> Grant Fund
          -> Grant Budget
              -> Project / Activity
                  -> Expense / Procurement / Advance
                      -> Evidence
                          -> Donor Report
                              -> Grant Closeout
```

---

# 46. Penutup

Workflow dalam Fund-centric ERP harus memastikan bahwa setiap rupiah dapat ditelusuri dari sumber dana sampai dampak program. Sistem tidak hanya mencatat transaksi, tetapi juga mengontrol penggunaan dana, memastikan compliance, mengumpulkan evidence, dan menghasilkan laporan yang siap diaudit.

Dengan pendekatan ini, organisasi dapat mengelola berbagai sumber pendanaan seperti grant, donasi publik, fundraising campaign, pendapatan unit usaha, dana unrestricted, reserve, co-funding, dan bridging fund dalam satu sistem yang terpadu.
