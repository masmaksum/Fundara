# Notification Templates

**Version:** 1.0
**Last Updated:** 2026-06-19
**Target:** ERPNext v16 / Frappe Notification DocType + Server Script
**Audience:** Frontend Developer

---

## How to Read This Document

### Channels

| Channel | Frappe Implementation | Notes |
|---|---|---|
| **In-app** | Frappe Notification bell (via `frappe.publish_realtime` + Notification Log) | Tersimpan di database, bisa dibaca ulang |
| **Email** | Frappe `Notification` DocType dengan `Event = Custom` + Server Script trigger | Dikirim via Email Account yang dikonfigurasi |
| **Both** | Kombinasi keduanya | Gunakan untuk peristiwa kritis |

### Variable Notation

`{{variable}}` = nilai dinamis dari dokumen sumber.

### Notification ID Convention

`NOTIF-[NN]` — urutan penomoran berdasarkan area proses.

### Recipients

Role-based recipients dikirim ke **semua user aktif dengan role tersebut** kecuali disebutkan "specific user field" (misalnya `requester`, `project_manager`).

---

## NOTIF-01: Cash Advance Diajukan

**Trigger:** Workflow transition — Cash Advance: `Draft → Submitted`
**DocType:** Cash Advance
**Condition:** Selalu
**Recipients:** Project Manager (linked to `cash_advance.project`), Finance Officer
**Channel:** Both

**Subject (email):**
```
[Fundara] Uang Muka Baru Perlu Ditinjau — {{cash_advance_name}} oleh {{requester_name}}
```

**Body:**
```
Yth. {{recipient_name}},

Terdapat pengajuan Uang Muka baru yang memerlukan tinjauan Anda.

Detail Pengajuan:
- Nomor       : {{cash_advance_name}}
- Pemohon     : {{requester_name}} ({{requester_department}})
- Keperluan   : {{purpose}}
- Kegiatan    : {{activity}}
- Fund        : {{fund_name}}
- Budget Line : {{budget_line}}
- Jumlah      : {{currency}} {{amount_requested}}
- Tanggal ajuan: {{submission_date}}

Silakan tinjau dan ambil tindakan yang diperlukan melalui tautan berikut:
{{doc_link}}

Terima kasih,
Sistem Fundara
```

**In-app message (maks 100 karakter):**
```
Uang Muka baru: {{cash_advance_name}} — {{currency}} {{amount_requested}} oleh {{requester_name}}
```

---

## NOTIF-02: Cash Advance Disetujui

**Trigger:** Workflow transition — Cash Advance: `Under Review → Approved`
**DocType:** Cash Advance
**Condition:** Selalu
**Recipients:** `cash_advance.owner` (pemohon / requester)
**Channel:** Both

**Subject (email):**
```
[Fundara] Uang Muka Anda Disetujui — {{cash_advance_name}}
```

**Body:**
```
Yth. {{requester_name}},

Pengajuan Uang Muka Anda telah DISETUJUI.

Detail:
- Nomor       : {{cash_advance_name}}
- Keperluan   : {{purpose}}
- Jumlah      : {{currency}} {{amount_requested}}
- Disetujui oleh: {{approver_name}} pada {{approval_date}}

Langkah selanjutnya:
Pembayaran akan diproses oleh Finance Officer. Anda akan menerima notifikasi 
konfirmasi setelah dana dicairkan.

Batas waktu pertanggungjawaban: {{liquidation_due_date}}

Lihat dokumen: {{doc_link}}

Terima kasih,
Sistem Fundara
```

**In-app message:**
```
Uang Muka {{cash_advance_name}} DISETUJUI — menunggu pencairan dana.
```

---

## NOTIF-03: Cash Advance Dibayar (Pencairan)

**Trigger:** Workflow transition — Cash Advance: `Approved → Paid`
**DocType:** Cash Advance
**Condition:** Selalu
**Recipients:** `cash_advance.owner` (pemohon)
**Channel:** Both

**Subject (email):**
```
[Fundara] Dana Uang Muka Dicairkan — {{cash_advance_name}} — Harap Pertanggungjawabkan sebelum {{liquidation_due_date}}
```

**Body:**
```
Yth. {{requester_name}},

Dana Uang Muka Anda telah DICAIRKAN.

Detail Pembayaran:
- Nomor       : {{cash_advance_name}}
- Jumlah      : {{currency}} {{amount_paid}}
- Metode      : {{payment_method}}
- Referensi   : {{payment_reference}}
- Tanggal bayar: {{payment_date}}

⚠ PENTING — Batas Pertanggungjawaban:
Anda wajib menyerahkan pertanggungjawaban (kuitansi dan laporan pengeluaran) 
selambat-lambatnya: {{liquidation_due_date}}

Keterlambatan pertanggungjawaban akan mengakibatkan:
1. Status advance berubah menjadi Overdue
2. Pemblokiran pengajuan uang muka baru

Lihat dokumen: {{doc_link}}

Terima kasih,
Sistem Fundara
```

**In-app message:**
```
Dana {{cash_advance_name}} ({{currency}} {{amount_paid}}) dicairkan. Pertanggungjawabkan sebelum {{liquidation_due_date}}.
```

---

## NOTIF-04: Cash Advance Overdue (Harian)

**Trigger:** Scheduled job harian — `fundara.scheduled.advance_overdue_check`
**DocType:** Cash Advance
**Condition:** `workflow_state = 'Overdue'` DAN `closed_date IS NULL`
**Recipients:** `cash_advance.owner` (pemohon), Project Manager terkait, Finance Manager
**Channel:** Both
**Frekuensi:** Dikirim setiap hari sampai advance diliquidasi atau ditutup

**Subject (email):**
```
[OVERDUE — Hari ke-{{days_overdue}}] Uang Muka Belum Dipertanggungjawabkan — {{cash_advance_name}}
```

**Body:**
```
Yth. {{recipient_name}},

PENGINGAT OVERDUE — Hari ke-{{days_overdue}}

Uang Muka berikut belum dipertanggungjawabkan melebihi batas yang ditetapkan:

- Nomor          : {{cash_advance_name}}
- Pemohon        : {{requester_name}}
- Jumlah         : {{currency}} {{amount_paid}}
- Batas tenggat  : {{liquidation_due_date}}
- Keterlambatan  : {{days_overdue}} hari

Status saat ini: Pemohon DIBLOKIR dari pengajuan uang muka baru sampai 
advance ini diselesaikan.

Tindakan yang diperlukan:
→ {{requester_name}}: Segera serahkan kuitansi dan laporan pengeluaran.
→ Finance Officer: Hubungi pemohon jika diperlukan tindak lanjut.

Lihat dokumen: {{doc_link}}

Untuk mematikan notifikasi ini, selesaikan pertanggungjawaban melalui sistem.

Sistem Fundara
```

**In-app message:**
```
⛔ OVERDUE Hari ke-{{days_overdue}}: {{cash_advance_name}} ({{requester_name}}) belum dipertanggungjawabkan.
```

---

## NOTIF-05: Pertanggungjawaban Uang Muka Diajukan

**Trigger:** Workflow transition — Cash Advance: `Pending Liquidation / Overdue → Liquidated`
**DocType:** Cash Advance
**Condition:** `liquidation_submitted = 1`
**Recipients:** Finance Officer, Finance Manager (jika late)
**Channel:** In-app (+ Email jika late / overdue)

**Subject (email — hanya jika overdue):**
```
[Fundara] Pertanggungjawaban Terlambat Diterima — {{cash_advance_name}} — Harap Ditinjau
```

**Body (email — jika overdue):**
```
Yth. {{recipient_name}},

Pertanggungjawaban untuk Uang Muka {{cash_advance_name}} telah diterima, 
namun TERLAMBAT {{days_overdue}} hari dari batas yang ditetapkan.

Detail:
- Pemohon          : {{requester_name}}
- Jumlah advance   : {{currency}} {{advance_amount}}
- Total pengeluaran: {{currency}} {{actual_expense}}
- Selisih          : {{currency}} {{difference}} ({{refund_or_reimbursement}})

Harap tinjau dan verifikasi dokumen pendukung:
{{doc_link}}

Sistem Fundara
```

**In-app message:**
```
Pertanggungjawaban {{cash_advance_name}} diterima dari {{requester_name}} — harap tinjau.
```

---

## NOTIF-06: Pertanggungjawaban Disetujui

**Trigger:** Workflow transition — Cash Advance: `Liquidated → Closed`
**DocType:** Cash Advance
**Condition:** Selalu
**Recipients:** `cash_advance.owner` (pemohon)
**Channel:** Both

**Subject (email):**
```
[Fundara] Pertanggungjawaban Uang Muka Disetujui — {{cash_advance_name}}
```

**Body:**
```
Yth. {{requester_name}},

Pertanggungjawaban Uang Muka Anda telah DISETUJUI dan advance dinyatakan SELESAI.

Detail:
- Nomor advance    : {{cash_advance_name}}
- Jumlah advance   : {{currency}} {{advance_amount}}
- Total disetujui  : {{currency}} {{approved_expense}}
- Selisih          : {{currency}} {{difference}}

{{#if refund_amount}}
⚠ Refund yang harus dikembalikan: {{currency}} {{refund_amount}}
Batas waktu pengembalian: {{refund_deadline}}
{{/if}}

{{#if reimbursement_amount}}
✓ Penggantian kelebihan: {{currency}} {{reimbursement_amount}} akan diproses oleh Finance.
{{/if}}

Pemblokiran pengajuan advance baru (jika ada) telah dicabut.

Lihat dokumen: {{doc_link}}

Terima kasih,
Sistem Fundara
```

**In-app message:**
```
Pertanggungjawaban {{cash_advance_name}} DISETUJUI dan advance ditutup.
```

---

## NOTIF-07: Pertanggungjawaban Dikembalikan untuk Revisi

**Trigger:** Workflow transition — Cash Advance: `Liquidated → Pending Liquidation` (Return for Revision)
**DocType:** Cash Advance
**Condition:** Selalu
**Recipients:** `cash_advance.owner` (pemohon)
**Channel:** Both

**Subject (email):**
```
[Fundara] Pertanggungjawaban Dikembalikan — {{cash_advance_name}} — Perlu Revisi
```

**Body:**
```
Yth. {{requester_name}},

Pertanggungjawaban Uang Muka Anda DIKEMBALIKAN untuk revisi oleh Finance Officer.

Detail:
- Nomor     : {{cash_advance_name}}
- Dikembalikan oleh: {{reviewer_name}} pada {{return_date}}

Catatan dari Finance:
"{{finance_notes}}"

Tindakan yang diperlukan:
Silakan perbaiki dokumen pertanggungjawaban sesuai catatan di atas dan ajukan kembali.

{{doc_link}}

Sistem Fundara
```

**In-app message:**
```
Pertanggungjawaban {{cash_advance_name}} dikembalikan: "{{finance_notes_short}}"
```

---

## NOTIF-08: Cash Advance Ditolak

**Trigger:** Workflow transition — Cash Advance: `Submitted / Under Review → Rejected`
**DocType:** Cash Advance
**Condition:** Selalu
**Recipients:** `cash_advance.owner` (pemohon)
**Channel:** Both

**Subject (email):**
```
[Fundara] Pengajuan Uang Muka Ditolak — {{cash_advance_name}}
```

**Body:**
```
Yth. {{requester_name}},

Pengajuan Uang Muka Anda DITOLAK.

Detail:
- Nomor          : {{cash_advance_name}}
- Keperluan      : {{purpose}}
- Jumlah         : {{currency}} {{amount_requested}}
- Ditolak oleh   : {{rejector_name}} pada {{rejection_date}}

Alasan Penolakan:
"{{rejection_reason}}"

Catatan: Pengajuan yang ditolak tidak dapat diajukan ulang. Buat pengajuan baru 
jika kebutuhan masih relevan.

{{doc_link}}

Sistem Fundara
```

**In-app message:**
```
Uang Muka {{cash_advance_name}} DITOLAK: "{{rejection_reason_short}}"
```

---

## NOTIF-09: Purchase Request Disetujui

**Trigger:** Workflow transition — Purchase Request: `Under Review → Approved`
**DocType:** Purchase Request
**Condition:** Selalu
**Recipients:** Procurement Officer
**Channel:** Both

**Subject (email):**
```
[Fundara] Purchase Request Disetujui — {{pr_name}} — Siap Dibuatkan PO
```

**Body:**
```
Yth. Tim Pengadaan,

Purchase Request berikut telah DISETUJUI dan siap untuk dibuatkan Purchase Order.

Detail:
- Nomor PR        : {{pr_name}}
- Diajukan oleh   : {{requester_name}}
- Item / Layanan  : {{item_description}}
- Estimasi jumlah : {{currency}} {{estimated_amount}}
- Fund            : {{fund_name}}
- Budget Line     : {{budget_line}}
- Vendor yang diusulkan: {{proposed_vendor}}
- Disetujui oleh  : {{approver_name}} pada {{approval_date}}

Tindakan selanjutnya:
Buat Purchase Order berdasarkan PR ini. Jika diperlukan RFQ atau bid analysis, 
lakukan sesuai Procurement Threshold Rule.

{{doc_link}}

Tim Fundara
```

**In-app message:**
```
PR {{pr_name}} DISETUJUI — buat Purchase Order sekarang.
```

---

## NOTIF-10: Grant Nearing End Date (30 Hari)

**Trigger:** Scheduled job harian — `fundara.scheduled.grant_end_date_reminder`
**DocType:** Grant
**Condition:** `end_date = today + 30 days` DAN `status = 'Active' OR 'Extended'`
**Recipients:** Grant Manager (linked to grant), Project Manager (linked project), Finance Manager
**Channel:** Both
**Frekuensi:** Satu kali pada H-30

**Subject (email):**
```
[Fundara] Pengingat: Grant {{grant_name}} Berakhir dalam 30 Hari ({{end_date}})
```

**Body:**
```
Yth. {{recipient_name}},

Grant {{grant_name}} akan berakhir dalam 30 hari.

Detail:
- Grant         : {{grant_name}}
- Donor         : {{donor_name}}
- Tanggal berakhir: {{end_date}}
- Sisa anggaran : {{currency}} {{remaining_budget}}
- Advance outstanding: {{outstanding_advance_count}} advance ({{currency}} {{outstanding_advance_total}})
- Laporan tertunda: {{pending_report_count}}

Tindakan yang Disarankan (Checklist Penutupan):
□ Pastikan semua advance diliquidasi sebelum tanggal berakhir
□ Pastikan semua invoice vendor sudah dibayar
□ Siapkan laporan akhir kepada donor
□ Periksa saldo sisa — apakah perlu dikembalikan ke donor?
□ Mulai closeout checklist

{{doc_link}}

Sistem Fundara
```

**In-app message:**
```
Grant {{grant_name}} berakhir dalam 30 hari ({{end_date}}). Siapkan closeout.
```

---

## NOTIF-11: Grant Reporting Schedule Jatuh Tempo dalam 14 Hari

**Trigger:** Scheduled job harian — `fundara.scheduled.grant_reporting_reminder`
**DocType:** Grant Reporting Schedule
**Condition:** `due_date = today + 14 days` DAN `status != 'Submitted'`
**Recipients:** Grant Manager
**Channel:** Both

**Subject (email):**
```
[Fundara] Pengingat Laporan: {{report_period}} untuk {{grant_name}} Jatuh Tempo {{due_date}}
```

**Body:**
```
Yth. {{grant_manager_name}},

Jadwal laporan berikut jatuh tempo dalam 14 hari:

- Grant       : {{grant_name}}
- Donor       : {{donor_name}}
- Periode laporan: {{report_period}}
- Jenis laporan  : {{report_type}}
- Jatuh tempo    : {{due_date}}
- Status saat ini: {{report_status}}

Tindakan yang diperlukan:
Siapkan dan kirimkan laporan kepada donor sebelum {{due_date}}.

{{doc_link}}

Sistem Fundara
```

**In-app message:**
```
Laporan {{report_period}} untuk {{grant_name}} jatuh tempo {{due_date}} — 14 hari lagi.
```

---

## NOTIF-12: Grant Reporting Schedule Overdue

**Trigger:** Scheduled job harian — `fundara.scheduled.grant_reporting_reminder`
**DocType:** Grant Reporting Schedule
**Condition:** `due_date < today` DAN `status != 'Submitted'`
**Recipients:** Grant Manager, Finance Manager
**Channel:** Both
**Frekuensi:** Harian sampai laporan diajukan

**Subject (email):**
```
[OVERDUE] Laporan {{report_period}} untuk {{grant_name}} Terlambat {{days_overdue}} Hari
```

**Body:**
```
Yth. {{recipient_name}},

LAPORAN DONOR TERLAMBAT — Perlu Tindakan Segera

Detail:
- Grant          : {{grant_name}}
- Donor          : {{donor_name}}
- Periode laporan: {{report_period}}
- Jatuh tempo    : {{due_date}}
- Keterlambatan  : {{days_overdue}} hari
- Status         : Belum diajukan

Keterlambatan laporan dapat mempengaruhi hubungan dengan donor dan 
penerimaan dana berikutnya.

{{doc_link}}

Sistem Fundara
```

**In-app message:**
```
⛔ Laporan {{grant_name}} ({{report_period}}) OVERDUE {{days_overdue}} hari — segera kirim!
```

---

## NOTIF-13: Saldo Fund Di Bawah 10%

**Trigger:** Server Script — `after_insert` dan `on_update` pada GL Entry; atau Scheduled job harian `fundara.scheduled.fund_balance_check`
**DocType:** Fund
**Condition:** `(available_balance / total_approved_budget) < 0.10` DAN `status = 'Active'`
**Recipients:** Fund Owner (field `fund.fund_manager`), Finance Manager
**Channel:** Both
**Frekuensi:** Satu kali per hari selama kondisi berlaku (jangan spam per transaksi)

**Subject (email):**
```
[Fundara] Peringatan: Saldo Fund {{fund_name}} Di Bawah 10% — Perlu Perhatian
```

**Body:**
```
Yth. {{recipient_name}},

Saldo Fund berikut telah berada di bawah 10% dari anggaran yang disetujui:

Detail Fund:
- Nama Fund      : {{fund_name}}
- Jenis Fund     : {{fund_type}}
- Anggaran total : {{currency}} {{total_budget}}
- Realisasi      : {{currency}} {{total_actual}}
- Saldo tersedia : {{currency}} {{available_balance}} ({{percent_remaining}}%)

Pending Payment (belum mengurangi saldo — D-02):
{{pending_payment_summary}}

Tindakan yang Disarankan:
□ Tinjau anggaran tersisa dan pending payment
□ Ajukan revisi anggaran jika diperlukan
□ Koordinasikan dengan Grant Manager / Fundraising untuk top-up jika perlu
□ Tunda pengeluaran non-prioritas

{{doc_link}}

Sistem Fundara
```

**In-app message:**
```
⚠ Saldo {{fund_name}} tersisa {{percent_remaining}}% ({{currency}} {{available_balance}}) — perhatian diperlukan.
```

---

## NOTIF-14: Target Campaign Tercapai 100%

**Trigger:** Server Script — `on_update` pada Donation Receipt, ketika `campaign.total_donations_received >= campaign.target_amount`
**DocType:** Fundraising Campaign
**Condition:** `total_donations_received >= target_amount` DAN `status = 'Active'`
**Recipients:** Fundraising Manager, Management (Executive Director role)
**Channel:** Both
**Frekuensi:** Satu kali — tidak berulang jika sudah terkirim (`notif_target_reached_sent = 1`)

**Subject (email):**
```
[Fundara] 🎉 Target Campaign Tercapai! — {{campaign_name}}
```

**Body:**
```
Yth. {{recipient_name}},

Target Campaign {{campaign_name}} telah TERCAPAI!

Ringkasan:
- Nama Campaign  : {{campaign_name}}
- Target         : {{currency}} {{target_amount}}
- Total terkumpul: {{currency}} {{total_donations_received}}
- Jumlah donatur : {{donor_count}}
- Pencapaian     : {{percent_achieved}}%
- Periode        : {{start_date}} – {{end_date}}

Tindakan Selanjutnya:
Jika campaign masih aktif, pertimbangkan apakah perlu melanjutkan penggalangan 
atau menutup penerimaan donasi lebih awal.

{{doc_link}}

Sistem Fundara
```

**In-app message:**
```
🎉 Target Campaign {{campaign_name}} TERCAPAI! {{currency}} {{total_donations_received}} terkumpul dari {{donor_count}} donatur.
```

---

## NOTIF-15: Revisi Anggaran Memerlukan Persetujuan Donor

**Trigger:** Server Script — `on_update` pada Budget Revision, ketika threshold donor terlampaui
**DocType:** Budget Revision (Grant Budget Line)
**Condition:** Perubahan > `donor_approval_threshold` persen DAN `fund.fund_type = 'Grant Fund'`
**Recipients:** Grant Manager
**Channel:** Both

**Subject (email):**
```
[Fundara] Revisi Anggaran Memerlukan Persetujuan Donor — {{budget_revision_name}}
```

**Body:**
```
Yth. {{grant_manager_name}},

Revisi anggaran berikut memerlukan persetujuan dari donor sebelum dapat diaktifkan:

Detail Revisi:
- Nomor revisi    : {{budget_revision_name}}
- Grant           : {{grant_name}}
- Donor           : {{donor_name}}
- Budget Line     : {{budget_line}}
- Anggaran lama   : {{currency}} {{old_amount}}
- Anggaran baru   : {{currency}} {{new_amount}}
- Perubahan       : {{currency}} {{change_amount}} ({{change_percent}}%)
- Threshold donor : {{donor_threshold}}%
- Alasan revisi   : "{{revision_reason}}"

Status: Revisi dalam status MENUNGGU PERSETUJUAN DONOR.
Anggaran lama ({{currency}} {{old_amount}}) tetap berlaku sampai persetujuan diterima.

Tindakan yang Diperlukan:
1. Hubungi donor untuk mendapatkan persetujuan
2. Lampirkan bukti persetujuan (email/surat resmi) ke dokumen revisi
3. Tandai revisi sebagai "Donor Approved" untuk mengaktifkan anggaran baru

{{doc_link}}

Sistem Fundara
```

**In-app message:**
```
Revisi anggaran {{budget_revision_name}} perlu persetujuan donor ({{change_percent}}% perubahan).
```

---

## NOTIF-16: Fund Allocation Disetujui — Notifikasi ke Project Manager

**Trigger:** Workflow transition — Fund Allocation: `Approved → Active`
**DocType:** Fund Allocation
**Condition:** Selalu
**Recipients:** Project Manager (dari `fund_allocation.allocated_to_project`)
**Channel:** Both

**Subject (email):**
```
[Fundara] Dana Telah Dialokasikan ke Proyek Anda — {{project_name}}
```

**Body:**
```
Yth. {{project_manager_name}},

Dana telah resmi dialokasikan ke proyek yang Anda kelola.

Detail Alokasi:
- Nomor alokasi  : {{allocation_name}}
- Fund           : {{fund_name}}
- Proyek         : {{project_name}}
- Jumlah         : {{currency}} {{allocated_amount}}
- Periode        : {{start_date}} – {{end_date}}
- Disetujui oleh : {{approver_name}}

Anggaran per budget line telah diaktifkan di sistem. Anda sekarang dapat 
memproses permintaan pengeluaran terhadap alokasi ini.

{{doc_link}}

Tim Fundara
```

**In-app message:**
```
Dana {{currency}} {{allocated_amount}} dari {{fund_name}} dialokasikan ke {{project_name}}.
```

---

## NOTIF-17: Grant Diaktifkan

**Trigger:** Workflow transition — Grant: `Agreement Review → Active`
**DocType:** Grant
**Condition:** Selalu
**Recipients:** Project Manager (linked), Finance Manager
**Channel:** Both

**Subject (email):**
```
[Fundara] Grant Diaktifkan — {{grant_name}} — Implementasi Dapat Dimulai
```

**Body:**
```
Yth. {{recipient_name}},

Grant berikut telah resmi DIAKTIFKAN.

Detail:
- Nama Grant     : {{grant_name}}
- Donor          : {{donor_name}}
- Nilai Grant    : {{currency}} {{total_budget}}
- Periode        : {{start_date}} – {{end_date}}
- Grant Fund     : {{grant_fund_name}}
- Jadwal laporan : {{reporting_schedule_summary}}

Grant Fund telah dibuat dan anggaran grant telah diaktifkan. 
Transaksi dapat mulai dilakukan terhadap Grant Fund ini.

{{doc_link}}

Sistem Fundara
```

**In-app message:**
```
Grant {{grant_name}} AKTIF — implementasi dan pengeluaran dapat dimulai.
```

---

## NOTIF-18: Grant Ditangguhkan (Suspended)

**Trigger:** Workflow transition — Grant: `Active / Extended → Suspended`
**DocType:** Grant
**Condition:** Selalu
**Recipients:** Project Manager (semua yang terkait), Finance Manager, Finance Officer
**Channel:** Both

**Subject (email):**
```
[PENTING] Grant {{grant_name}} DITANGGUHKAN — Transaksi Baru Diblokir
```

**Body:**
```
Yth. {{recipient_name}},

Grant {{grant_name}} telah DITANGGUHKAN.

Detail:
- Grant          : {{grant_name}}
- Donor          : {{donor_name}}
- Alasan penangguhan: "{{suspension_reason}}"
- Ditangguhkan oleh : {{suspender_name}} pada {{suspension_date}}

Dampak Sistem:
- Semua transaksi baru terhadap Grant Fund {{grant_fund_name}} DIBLOKIR
- Transaksi yang sedang berjalan perlu ditinjau
- Advance yang belum dibayar perlu dikaji ulang

Hubungi Management untuk informasi lebih lanjut mengenai rencana tindak lanjut.

{{doc_link}}

Sistem Fundara
```

**In-app message:**
```
⛔ Grant {{grant_name}} DITANGGUHKAN — transaksi baru diblokir. Hubungi Management.
```

---

## NOTIF-19: Purchase Request — Budget Exception Terdeteksi

**Trigger:** Workflow transition — Purchase Request: `Draft → Submitted` (server-side budget check)
**DocType:** Purchase Request
**Condition:** `estimated_amount > available_budget` DAN budget check gagal
**Recipients:** Finance Manager, Project Manager
**Channel:** Both

**Subject (email):**
```
[Fundara] Budget Exception pada Purchase Request {{pr_name}} — Perlu Tindakan
```

**Body:**
```
Yth. {{recipient_name}},

Permintaan Pembelian berikut memicu Budget Exception karena anggaran tidak mencukupi:

Detail:
- Nomor PR        : {{pr_name}}
- Diajukan oleh   : {{requester_name}}
- Fund            : {{fund_name}}
- Budget Line     : {{budget_line}}
- Anggaran tersedia: {{currency}} {{available_budget}}
- Jumlah diminta  : {{currency}} {{estimated_amount}}
- Kekurangan      : {{currency}} {{shortfall}}

PR telah diajukan dan dapat ditinjau, namun TIDAK DAPAT DISETUJUI tanpa 
revisi anggaran atau perubahan fund.

Tindakan yang Diperlukan:
1. Tolak PR dan minta pemohon mengubah fund/jumlah, atau
2. Setujui revisi anggaran untuk Budget Line ini, atau
3. Gunakan prosedur Budget Override (hanya untuk Finance Manager)

{{doc_link}}

Sistem Fundara
```

**In-app message:**
```
Budget Exception: PR {{pr_name}} melebihi anggaran {{budget_line}} sebesar {{currency}} {{shortfall}}.
```

---

## NOTIF-20: Invoice Melebihi PO — Perlu Persetujuan Finance Manager

**Trigger:** Server Script — `validate` pada Purchase Invoice
**DocType:** Purchase Invoice
**Condition:** `(invoice_amount - po_amount) / po_amount > invoice_variance_threshold`
**Recipients:** Finance Manager
**Channel:** Both

**Subject (email):**
```
[Fundara] Invoice Melebihi PO — Persetujuan Diperlukan — {{invoice_name}}
```

**Body:**
```
Yth. Finance Manager,

Invoice berikut melebihi jumlah Purchase Order dan memerlukan persetujuan Anda:

Detail:
- Nomor Invoice  : {{invoice_name}}
- Vendor         : {{supplier_name}}
- Nomor PO Referensi: {{po_name}}
- Jumlah PO      : {{currency}} {{po_amount}}
- Jumlah Invoice : {{currency}} {{invoice_amount}}
- Kelebihan      : {{currency}} {{variance}} ({{variance_percent}}%)
- Threshold yang berlaku: {{threshold}}%

Invoice dalam status MENUNGGU PERSETUJUAN dan tidak dapat diposting 
sebelum Anda menyetujuinya.

{{doc_link}}

Sistem Fundara
```

**In-app message:**
```
Invoice {{invoice_name}} melebihi PO {{po_name}} sebesar {{currency}} {{variance}} ({{variance_percent}}%).
```

---

## NOTIF-21: Campaign Hampir Berakhir (7 Hari)

**Trigger:** Scheduled job harian — `fundara.scheduled.campaign_end_date_reminder`
**DocType:** Fundraising Campaign
**Condition:** `end_date = today + 7 days` DAN `status = 'Active'`
**Recipients:** Fundraising Manager, Finance Officer
**Channel:** In-app

**In-app message:**
```
Campaign {{campaign_name}} berakhir dalam 7 hari ({{end_date}}). Total terkumpul: {{currency}} {{total_donations}}.
```

---

## Catatan Implementasi

### Frappe Notification DocType (untuk email otomatis sederhana)

Notifikasi sederhana yang hanya bergantung pada perubahan status dapat dikonfigurasi via **Frappe Notification DocType** (`Setup → Email → Notification`):

- **Event:** `Workflow State` — pilih state yang memicu
- **Channel:** Email
- **Condition:** Python expression (opsional)
- **Recipients:** Role atau field-based

### Server Script (untuk notifikasi kompleks)

Notifikasi yang memerlukan logika tambahan (threshold check, perhitungan, multi-recipient berdasarkan relasi) harus diimplementasikan menggunakan **Frappe Server Script** dengan trigger `DocType Event`:

```python
def send_notification(recipients, subject, message, doc_link):
    for recipient in recipients:
        frappe.publish_realtime(
            event='notification',
            message={
                'message': message,
                'subject': subject,
                'from_user': 'Administrator',
                'type': 'Alert'
            },
            user=recipient
        )
        frappe.sendmail(
            recipients=[recipient],
            subject=subject,
            message=message
        )
```

### Scheduled Jobs

Daftarkan semua cron jobs di `fundara/hooks.py`:

```python
scheduler_events = {
    "daily": [
        "fundara.scheduled.advance_overdue_check",          # NOTIF-04
        "fundara.scheduled.grant_end_date_reminder",        # NOTIF-10
        "fundara.scheduled.grant_reporting_reminder",       # NOTIF-11, NOTIF-12
        "fundara.scheduled.fund_balance_check",             # NOTIF-13
        "fundara.scheduled.campaign_end_date_reminder",     # NOTIF-21
    ]
}
```

### Mencegah Notifikasi Duplikat

Untuk notifikasi yang dikirim sekali (seperti NOTIF-14 campaign target tercapai), gunakan flag field pada DocType:

```python
if not doc.notif_target_reached_sent:
    send_notification(...)
    doc.notif_target_reached_sent = 1
    doc.save(ignore_permissions=True)
```

Untuk notifikasi harian (seperti NOTIF-04 overdue), cukup pastikan scheduled job hanya berjalan sekali sehari dan tidak meng-trigger di luar jadwal.

### Panjang Pesan In-App

Pesan in-app dibatasi 100 karakter termasuk spasi. Jika variabel bisa membuatnya melebihi 100 karakter, potong dengan `[:80]` dan tambahkan `...`.

### Konfigurasi Email Account

Semua email dikirim via `Default Outgoing Email Account` yang dikonfigurasi di ERPNext (`Setup → Email → Email Account`). Pastikan `default_send_email = 1` dan SMTP dikonfigurasi dengan benar sebelum deployment.
