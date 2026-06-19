# Client-side Validation Messages

**Version:** 1.0
**Last Updated:** 2026-06-19
**Target:** ERPNext v16 / Frappe Framework — Client Script + Server Script
**Audience:** Frontend Developer

---

## How to Read This Document

### Message Types

| Type | Frappe Implementation | User Behavior |
|---|---|---|
| **Error / Hard Block** | `frappe.throw(message)` or `frappe.validated = false` in `validate` hook | Form cannot be saved or submitted. User must fix the issue. |
| **Warning** | `frappe.msgprint({ message, indicator: 'orange', title: 'Perhatian' })` | User sees the message and can choose to proceed or cancel. |
| **Info Banner** | `frappe.show_alert({ message, indicator: 'blue' })` or inline HTML in form | Informational only — no action blocked. Displayed persistently on the form. |

### Variable Notation

`{variable}` in message text means the value is dynamically interpolated at runtime.

### Rule ID Convention

`VA-[AREA]-[NUMBER]` where areas:
- `FUND` = Fund
- `ADV` = Cash Advance
- `LIQ` = Advance Liquidation
- `PR` = Purchase Request
- `PO` = Purchase Order
- `FT` = Fund Transfer
- `GR` = Grant
- `BR` = Budget Revision

---

## DocType: Fund

| Rule ID | Trigger | Type | Message (Bahasa Indonesia) | Action Required |
|---|---|---|---|---|
| VA-FUND-01 | Before Submit | Error | "Fund tidak dapat diaktifkan tanpa Funding Source. Pilih Funding Source terlebih dahulu." | Set `funding_source` |
| VA-FUND-02 | Before Submit | Error | "Restriction Type wajib diisi sebelum Fund dapat diaktifkan." | Set `restriction_type` |
| VA-FUND-03 | On Save / Validate | Error | "Tanggal berakhir Fund harus setelah tanggal mulai. Periksa kembali periode Fund." | Fix `end_date` > `start_date` |
| VA-FUND-04 | Before Submit (Grant Fund) | Error | "Grant Fund harus memiliki referensi Grant yang aktif. Hubungkan dokumen Grant terlebih dahulu." | Set `grant` |
| VA-FUND-05 | Before Submit | Error | "Fund dengan currency selain IDR harus memiliki nilai tukar terkini di Currency Exchange master. Tidak ditemukan kurs {currency} untuk hari ini." | Add exchange rate for today |
| VA-FUND-06 | On Save | Warning | "Tidak ada Budget yang ditetapkan untuk Fund ini. Fund akan aktif namun transaksi tidak dapat dikontrol per budget line. Lanjutkan?" | Acknowledge or add budget |
| VA-FUND-07 | Before Closing | Error | "Fund tidak dapat ditutup. Terdapat {count} advance outstanding: {advance_list}. Selesaikan semua advance sebelum menutup Fund." | Resolve outstanding advances |
| VA-FUND-08 | Before Closing | Error | "Fund tidak dapat ditutup. Terdapat {count} purchase invoice yang belum dibayar: {invoice_list}." | Settle all pending invoices |
| VA-FUND-09 | Before Closing | Warning | "Terdapat {count} transaksi bank yang belum direkonsiliasi untuk Fund ini. Rekonsiliasi sebelum pengajuan audit." | Acknowledge or reconcile |
| VA-FUND-10 | On Status Change to Active | Error | "Fund tidak dapat diaktifkan di luar periode yang ditentukan. Tanggal hari ini ({today}) berada di luar periode {start_date} – {end_date}." | Adjust period or wait |

---

## DocType: Cash Advance

### Validasi Saat Pengisian Form

| Rule ID | Trigger | Type | Message (Bahasa Indonesia) | Action Required |
|---|---|---|---|---|
| VA-ADV-01 | Before Submit | Error | "Jumlah uang muka harus lebih dari 0." | Set `amount_requested > 0` |
| VA-ADV-02 | Before Submit | Error | "Fund wajib dipilih sebelum uang muka dapat diajukan." | Set `fund` |
| VA-ADV-03 | Before Submit | Error | "Kegiatan (Activity) wajib diisi. Uang muka harus dikaitkan dengan kegiatan yang disetujui." | Set `activity` |
| VA-ADV-04 | Before Submit | Error | "Budget Line wajib dipilih untuk Fund jenis {fund_type}." | Set `budget_line` |
| VA-ADV-05 | Before Submit | Error | "Fund {fund_name} tidak dalam status Aktif. Pilih Fund yang aktif atau hubungi Finance." | Change fund |
| VA-ADV-06 | Before Submit | Error | "Tanggal penggunaan melewati periode Fund {fund_name} ({fund_end_date}). Pengeluaran di luar periode grant adalah Compliance Exception." | Adjust date or change fund |
| VA-ADV-07 | On Approve (server) | Warning | "Saldo tersedia Fund {fund_name}: {currency} {available_balance}. Uang muka ini akan membebankan {percent_of_balance}% dari saldo. Lanjutkan persetujuan?" | Acknowledge or reject |
| VA-ADV-08 | Before Approve | Error | "Pemohon {requester_name} memiliki {overdue_count} uang muka yang sudah melewati batas pertanggungjawaban. Selesaikan uang muka yang overdue sebelum menyetujui yang baru." | Resolve overdue advances |

### Validasi Saat Pembayaran (D-02 — Paid Status)

| Rule ID | Trigger | Type | Message (Bahasa Indonesia) | Action Required |
|---|---|---|---|---|
| VA-ADV-09 | Before Mark as Paid | Error | "Pembayaran diblokir: Fund {fund_name} — Budget Line '{budget_line}' akan melebihi anggaran sebesar {currency} {over_amount}. Tersedia: {currency} {available}, Dibutuhkan: {currency} {required}. Ajukan revisi anggaran sebelum melanjutkan." | Request budget revision |
| VA-ADV-10 | Before Mark as Paid | Error | "Pembayaran diblokir: Saldo Fund {fund_name} tidak mencukupi. Tersedia: {currency} {available}, Dibutuhkan: {currency} {required}." | Fund top-up or reduce amount |
| VA-ADV-11 | Before Mark as Paid | Error | "Referensi pembayaran wajib diisi sebelum uang muka dapat ditandai sebagai Dibayar." | Set `payment_reference` |
| VA-ADV-12 | Before Mark as Paid | Error | "Uang muka yang sudah Dibayar tidak dapat dibatalkan. Untuk membalik uang muka ini, ajukan Pertanggungjawaban dengan pengeluaran = 0 dan kembalikan seluruh jumlah sebagai refund." | Submit liquidation with 0 expense |

### Validasi D-02 — Peringatan Pending Payment

| Rule ID | Trigger | Type | Message (Bahasa Indonesia) | Action Required |
|---|---|---|---|---|
| VA-ADV-13 | On Approve | Info Banner | "Perhatian D-02: {currency} {pending_total} dari uang muka dan pesanan yang sudah disetujui sedang menunggu pembayaran dari Budget Line '{budget_line}' (saldo tersedia: {currency} {available}). Saldo aktual mungkin lebih rendah setelah pembayaran dilakukan." | No action required — informational |
| VA-ADV-14 | On Budget Dashboard View | Info Banner | "Terdapat {pending_count} transaksi senilai {currency} {pending_total} yang sudah disetujui namun belum dibayar. Angka ini tidak termasuk dalam kolom Realisasi. Lihat panel Pending Payment untuk detailnya." | No action required |
| VA-ADV-15 | Saat Finance melihat antrean pembayaran | Warning | "{currency} {pending_total} dalam uang muka telah disetujui dan menunggu pembayaran dari Budget Line ini (tersedia: {currency} {available}). Membayar semua akan melebihi anggaran sebesar {currency} {over_amount}." | Pay in order of priority |

---

## DocType: Advance Liquidation (Pertanggungjawaban Uang Muka)

| Rule ID | Trigger | Type | Message (Bahasa Indonesia) | Action Required |
|---|---|---|---|---|
| VA-LIQ-01 | Before Submit | Error | "Total pengeluaran yang dipertanggungjawabkan tidak boleh negatif." | Fix `total_expense` |
| VA-LIQ-02 | Before Submit | Error | "Minimal satu baris pengeluaran harus diisi sebelum pertanggungjawaban dapat diajukan." | Add expense line |
| VA-LIQ-03 | Before Submit | Warning | "Tidak ada bukti (kuitansi/invoice) yang dilampirkan. Finance akan memerlukan bukti untuk menyetujui pertanggungjawaban ini. Lanjutkan pengajuan?" | Acknowledge or attach evidence |
| VA-LIQ-04 | Before Approve (server) | Error | "Item '{expense_description}' (Rp {amount}) tidak eligible berdasarkan aturan Fund {fund_name}: '{restriction_rule}'. Reklasifikasi atau tolak item ini sebelum menyetujui." | Reclassify or reject expense item |
| VA-LIQ-05 | Before Approve | Warning | "Total pengeluaran (Rp {actual_amount}) melebihi jumlah uang muka (Rp {advance_amount}) sebesar Rp {excess_amount}. Setujui penggantian (reimbursement) sebesar Rp {excess_amount} kepada staf?" | Approve or reject reimbursement |
| VA-LIQ-06 | Before Approve | Info | "Total pengeluaran (Rp {actual_amount}) kurang dari jumlah uang muka (Rp {advance_amount}). Staf harus mengembalikan Rp {refund_amount} ke kas organisasi." | No action — auto-creates refund record |
| VA-LIQ-07 | Before Close Advance | Error | "Uang muka tidak dapat ditutup karena refund sebesar Rp {refund_amount} belum diterima." | Record refund receipt first |
| VA-LIQ-08 | Before Approve | Error | "Diajukan terlambat: Batas pertanggungjawaban adalah {due_date}. Pertanggungjawaban ini diajukan {days_late} hari setelah batas. Finance Manager harus menyetujui pengecualian ini." | Requires Finance Manager approval |
| VA-LIQ-09 | Before Approve (Excess against budget) | Warning | "Penggantian kelebihan pengeluaran sebesar Rp {excess_amount} akan melebihi anggaran Budget Line '{budget_line}' Fund {fund_name}. Diperlukan pengecualian anggaran sebelum pembayaran penggantian." | Request budget exception |
| VA-LIQ-10 | Before Approve | Error | "Tidak semua item ineligible telah diklasifikasikan. Tandai setiap item sebagai 'Eligible' atau 'Tidak Eligible' dan tentukan penanganannya sebelum menyetujui." | Classify all expense items |

---

## DocType: Purchase Request (Permintaan Pembelian)

| Rule ID | Trigger | Type | Message (Bahasa Indonesia) | Action Required |
|---|---|---|---|---|
| VA-PR-01 | Before Submit | Error | "Fund wajib dipilih sebelum Permintaan Pembelian dapat diajukan." | Set `fund` |
| VA-PR-02 | Before Submit | Error | "Budget Line wajib diisi untuk Fund jenis {fund_type}." | Set `budget_line` |
| VA-PR-03 | Before Submit | Error | "Estimasi jumlah harus lebih dari 0." | Set `estimated_amount > 0` |
| VA-PR-04 | Before Submit | Error | "Vendor '{vendor_name}' belum terdaftar sebagai supplier yang disetujui. Daftarkan vendor terlebih dahulu atau pilih supplier yang sudah terdaftar." | Register vendor or change vendor |
| VA-PR-05 | Before Submit | Warning | "Tidak ada vendor yang dipilih. Vendor harus ditentukan sebelum Purchase Order dapat dibuat. Lanjutkan pengajuan?" | Acknowledge (PR can proceed without vendor) |
| VA-PR-06 | On Approve (server) | Error | "Kategori item '{item_category}' tidak eligible untuk Fund {fund_name}. Aturan fund menyatakan: '{restriction_rule}'. Ganti fund atau ajukan pengecualian dari donor." | Change fund or get donor exception |
| VA-PR-07 | On Budget Check | Warning | "Anggaran Budget Line '{budget_line}' Fund {fund_name}: disetujui {currency} {budget}, sisa {currency} {available}. Permintaan ini sebesar {currency} {requested}. Jika dibayar, akan menyerap {percent}% dari sisa anggaran." | Acknowledge or revise amount |
| VA-PR-08 | On Budget Check | Error | "Anggaran tidak mencukupi: Budget Line '{budget_line}' Fund {fund_name} memiliki sisa {currency} {available}, sementara permintaan ini sebesar {currency} {requested}. Ajukan revisi anggaran sebelum melanjutkan." | Request budget revision first |
| VA-PR-09 | Before Submit | Error | "Fund {fund_name} sedang dalam status {fund_status}. Tidak dapat membuat permintaan pembelian terhadap fund yang tidak aktif." | Use active fund |
| VA-PR-10 | Before Submit | Error | "Tanggal kebutuhan melebihi periode Fund {fund_name} ({fund_end_date}). Pengeluaran di luar periode grant adalah Compliance Exception." | Adjust date |

---

## DocType: Purchase Order (Surat Pesanan)

| Rule ID | Trigger | Type | Message (Bahasa Indonesia) | Action Required |
|---|---|---|---|---|
| VA-PO-01 | Before Submit | Error | "Vendor wajib dipilih sebelum Purchase Order dapat diajukan." | Set `supplier` |
| VA-PO-02 | Before Submit | Error | "Purchase Request referensi wajib dicantumkan. Gunakan Permintaan Pembelian yang sudah disetujui." | Set `purchase_request` |
| VA-PO-03 | Before Submit | Error | "Total jumlah Purchase Order harus lebih dari 0." | Add line items |
| VA-PO-04 | Before Submit | Error | "Vendor '{vendor_name}' belum disetujui (status: {vendor_status}). Purchase Order tidak dapat dibuat untuk vendor yang belum terverifikasi." | Verify vendor first |
| VA-PO-05 | Before Submit | Error | "Pembelian senilai {currency} {amount} memerlukan Analisis Penawaran (Bid Analysis) sesuai Procurement Threshold Rule tier {tier}. Lengkapi bid analysis sebelum mengajukan PO." | Attach bid analysis |
| VA-PO-06 | Before Submit | Warning | "Belum ada justifikasi single-source. Jika pembelian ini dilakukan tanpa kompetisi penawaran, lampirkan Single Source Justification." | Attach justification |
| VA-PO-07 | Before Approve | Warning | "Jumlah Purchase Order ({currency} {po_amount}) berbeda {percent}% dari estimasi Purchase Request ({currency} {pr_amount}). Melebihi threshold {threshold}% — notifikasi dikirim ke Finance Manager. PO tidak diblokir." | Finance Manager notified |
| VA-PO-08 | Before Approve | Error | "Jumlah Purchase Invoice ({currency} {invoice_amount}) melebihi jumlah Purchase Order ({currency} {po_amount}) sebesar {percent}% ({currency} {variance}). Melebihi threshold {threshold}% — diperlukan persetujuan Finance Manager sebelum invoice dapat diposting." | Finance Manager must approve |
| VA-PO-09 | Before Mark as Completed | Error | "PO tidak dapat ditandai Selesai jika goods receipt atau service acceptance belum dikonfirmasi." | Record goods receipt |
| VA-PO-10 | Before Mark as Completed | Error | "Invoice dari vendor belum dicocokkan (invoice matching belum selesai). Selesaikan invoice matching sebelum menutup PO." | Complete invoice matching |

---

## DocType: Fund Transfer (Transfer Dana)

| Rule ID | Trigger | Type | Message (Bahasa Indonesia) | Action Required |
|---|---|---|---|---|
| VA-FT-01 | Before Submit | Error | "Fund sumber dan Fund tujuan tidak boleh sama." | Select different source/destination |
| VA-FT-02 | Before Submit | Error | "Saldo Fund sumber tidak mencukupi. Tersedia: {currency} {available}, Diminta: {currency} {requested}." | Reduce transfer amount |
| VA-FT-03 | Before Submit | Error | "Fund {source_fund_name} tidak dalam status Aktif ({current_status}). Transfer tidak dapat diproses." | Use active fund |
| VA-FT-04 | Before Submit | Error | "Transfer DARI Fund terbatas (restricted) '{source_fund_name}' ke fund yang tidak terkait diblokir. Aturan fund terbatas tidak mengizinkan transfer keluar tanpa persetujuan donor. Lampirkan bukti persetujuan donor." | Attach donor approval document |
| VA-FT-05 | Before Submit | Warning | "Transfer ke Fund terbatas '{target_fund_name}' akan menggabungkan dana dari sumber yang berbeda. Pastikan peruntukan transfer ini sesuai dengan tujuan Fund tujuan: '{fund_purpose}'." | Acknowledge |
| VA-FT-06 | Before Submit | Error | "Jumlah transfer harus lebih dari 0." | Set `amount > 0` |
| VA-FT-07 | Before Submit | Error | "Alasan transfer wajib diisi untuk Fund jenis Reserve Fund atau Bridging Fund." | Set `transfer_reason` |

---

## DocType: Grant

| Rule ID | Trigger | Type | Message (Bahasa Indonesia) | Action Required |
|---|---|---|---|---|
| VA-GR-01 | Before transition to Active | Error | "Grant tidak dapat diaktifkan tanpa Perjanjian Hibah (Grant Agreement) yang sudah ditandatangani. Unggah dokumen perjanjian dan tandai sebagai 'Ditandatangani'." | Upload and mark agreement as signed |
| VA-GR-02 | Before transition to Active | Error | "Grant tidak dapat diaktifkan tanpa Grant Fund yang terkait. Buat Grant Fund terlebih dahulu." | Create Grant Fund |
| VA-GR-03 | Before transition to Active | Error | "Grant tidak dapat diaktifkan tanpa anggaran yang disetujui. Masukkan Grant Budget Lines sebelum aktivasi." | Set `grant_budget_approved = 1` |
| VA-GR-04 | Before transition to Active | Error | "Grant Reporting Schedule belum dikonfigurasi. Tetapkan jadwal pelaporan sebelum grant dapat diaktifkan." | Configure reporting schedule |
| VA-GR-05 | Before transition to Closing | Error | "Grant tidak dapat memasuki proses penutupan jika masih ada {count} advance outstanding." | Resolve all advances |
| VA-GR-06 | Before transition to Closed | Error | "Grant tidak dapat ditutup. Checklist penutupan belum lengkap: {incomplete_items}." | Complete closeout checklist |
| VA-GR-07 | Before transition to Closed | Error | "Laporan akhir (Final Report) belum diajukan. Grant tidak dapat ditutup tanpa laporan akhir kepada donor." | Submit final report |
| VA-GR-08 | 30 hari sebelum `end_date` | Info Banner | "Grant {grant_name} akan berakhir dalam {days_remaining} hari ({end_date}). Periksa jadwal pelaporan dan rencana penutupan." | No action — reminder |
| VA-GR-09 | Before transition to Active | Warning | "Tanggal mulai grant sudah lewat ({start_date}). Grant akan diaktifkan dengan tanggal efektif mundur. Semua transaksi sejak {start_date} akan dianggap dalam periode grant." | Acknowledge |

---

## DocType: Budget Revision (Revisi Anggaran)

| Rule ID | Trigger | Type | Message (Bahasa Indonesia) | Action Required |
|---|---|---|---|---|
| VA-BR-01 | Before Submit | Error | "Revisi anggaran tidak dapat mengurangi Budget Line '{budget_line}' di bawah jumlah yang sudah direalisasikan. Minimum yang diperbolehkan: {currency} {min_allowed} (sudah terealisasi: {currency} {actual_paid})." | Increase revised amount |
| VA-BR-02 | Before Submit | Error | "Alasan revisi anggaran wajib diisi." | Set `revision_reason` |
| VA-BR-03 | On Save / Validate | Info Banner | "Perubahan ini ({percent}% dari budget line) melebihi threshold persetujuan donor ({donor_threshold}%). Revisi akan disimpan dalam status 'Menunggu Persetujuan Donor' dan tidak berlaku sampai persetujuan diterima. Anggaran lama ({currency} {old_amount}) tetap berlaku sementara." | No action — automatic routing |
| VA-BR-04 | Before Activate | Error | "Revisi anggaran ini memerlukan persetujuan donor karena perubahan melebihi {donor_threshold}%. Lampirkan bukti persetujuan donor sebelum revisi dapat diaktifkan." | Attach donor approval |
| VA-BR-05 | Before Activate | Error | "Revisi ini menambah total anggaran grant. Perubahan total anggaran memerlukan persetujuan Finance Manager dan Grant Manager." | Route to Finance + Grant Manager |
| VA-BR-06 | On Save | Warning | "Revisi ini menambahkan budget line baru '{new_budget_line}'. Budget line baru memerlukan persetujuan Finance Manager dan Grant Manager sesuai aturan yang berlaku." | Acknowledge |
| VA-BR-07 | Before Activate | Error | "Revisi anggaran tidak dapat diaktifkan karena versi sebelumnya masih dalam proses persetujuan. Tunggu hingga revisi sebelumnya selesai diproses." | Wait for prior revision |
| VA-BR-08 | Before Submit | Error | "Total anggaran setelah revisi melebihi nilai Grant Agreement ({currency} {grant_agreement_total}). Revisi tidak dapat dilakukan melebihi nilai kontrak tanpa amandemen resmi dari donor." | Amend grant agreement first |

---

## Pesan Khusus D-02 (D-02 Specific Messages)

Bagian ini mendefinisikan pesan yang spesifik untuk penerapan D-02 (Available Budget = Approved Budget − Actual Paid Only).

### Banner Informasi pada Form Cash Advance — Status Approved, Belum Paid

**Implementasi:** Inline HTML banner di bagian atas Cash Advance form, muncul otomatis via Client Script ketika `workflow_state === 'Approved'` dan `payment_reference` kosong.

```
Uang muka ini telah DISETUJUI dan menunggu pembayaran.
Jumlah: {currency} {amount_requested}
Fund: {fund_name} | Budget Line: {budget_line}

Anggaran BELUM berkurang sampai pembayaran dilakukan (sesuai kebijakan D-02).
Saldo anggaran saat ini: {currency} {available_budget}

[Lihat Antrean Pending Payment]   [Proses Pembayaran]
```

Style: Background biru muda (`#e8f4fd`), border kiri biru (`#2196F3`), 4px).

---

### Peringatan Saat Finance Melihat Budget dengan Pending Payment

**Implementasi:** Panel terpisah ("Pending Payment") di bawah tabel Budget vs Actual pada Fund form dan laporan anggaran. Muncul via Client Script jika ada advance dengan `workflow_state = 'Approved'` dan `payment_reference` kosong, atau invoice dengan status `Submitted`.

**Judul panel:** "⚠ Transaksi Pending — Belum Mengurangi Anggaran (D-02)"

```
Anggaran yang ditampilkan di atas hanya mencerminkan transaksi yang SUDAH DIBAYAR.
Berikut transaksi yang sudah disetujui namun belum dibayar — tidak termasuk dalam 
kolom Realisasi, namun akan mengurangi saldo jika dibayarkan:

| Jenis              | Nomor       | Untuk / Vendor | Budget Line | Jumlah          |
|--------------------|-------------|----------------|-------------|-----------------|
| Uang Muka Disetujui| CA-2025-011 | Budi Santoso   | Travel      | USD 1,500       |
| Purchase Order     | PO-2025-018 | PT Maju Tekno  | Equipment   | IDR 12.000.000  |

Total Pending: {currency} {total_pending}
Saldo setelah semua pending dibayar (estimasi): {currency} {estimated_remaining}
```

**Jika estimated_remaining negatif**, tambahkan baris merah:
```
⛔ PERINGATAN: Membayar semua transaksi pending akan melebihi anggaran sebesar 
{currency} {over_amount}. Tinjau antrean pembayaran sebelum memproses.
```

---

### Pesan Saat Budget Menampilkan "Tersedia" Namun Ada Pending Payment Signifikan

**Konteks:** Saat Finance Officer membuka antrean pembayaran dan melihat saldo yang "tersedia" namun sebenarnya sudah terkomitmen oleh advance yang disetujui.

**Implementasi:** Toast notification / `frappe.show_alert` saat form Cash Advance dibuka dalam status Approved, bila total pending melebihi 50% saldo tersedia.

```javascript
// Client Script — Cash Advance form
frappe.show_alert({
    message: `Perhatian: Saldo tersedia Budget Line '${budget_line}' adalah 
              ${currency} ${available}, namun ${currency} ${total_pending} 
              sedang menunggu pembayaran (${percent_of_balance}% dari saldo). 
              Pastikan ada cukup dana sebelum memproses pembayaran ini.`,
    indicator: 'orange'
}, 10); // auto-dismiss setelah 10 detik
```

---

### Pesan Hard Block Saat Pembayaran Melebihi Budget (D-02 Enforcement)

Ini adalah pesan error utama D-02 — ditampilkan saat Finance mencoba memproses pembayaran advance yang akan melampaui anggaran.

**Implementasi:** `frappe.throw()` di Server Script (DocType Event: `before_save` pada Payment Entry atau pada transisi workflow ke 'Paid').

```
Pembayaran Diblokir

Fund: {fund_name}
Budget Line: {budget_line}
Anggaran yang Disetujui: {currency} {approved_budget}
Realisasi Saat Ini: {currency} {actual_paid}
Saldo Tersedia: {currency} {available}

Pembayaran ini ({currency} {payment_amount}) akan melebihi anggaran 
sebesar {currency} {over_amount}.

Tindakan yang tersedia:
1. Ajukan Revisi Anggaran untuk Budget Line ini
2. Kurangi jumlah pembayaran
3. Ganti Budget Line atau Fund
4. Minta otorisasi Budget Override (hanya Finance Manager)

Pembayaran dibatalkan. Tidak ada jurnal yang dibuat.
```

---

## Catatan Implementasi

### Client Script Pattern (Frappe v16)

```javascript
// Contoh implementasi VA-ADV-13 — Info Banner D-02
frappe.ui.form.on('Cash Advance', {
    after_save(frm) {
        if (frm.doc.workflow_state === 'Approved' && !frm.doc.payment_reference) {
            frm.dashboard.add_comment(
                `Uang muka ini sudah disetujui dan menunggu pembayaran. 
                 Anggaran belum berkurang sampai pembayaran dilakukan (D-02).`,
                'blue',
                true
            );
        }
    }
});
```

### Server Script Pattern (Frappe v16)

```python
# Contoh implementasi VA-ADV-09 — Hard Block pada payment
def validate_budget_on_payment(doc, method):
    if doc.workflow_state == "Paid" and not doc.flags.get("advance_paid_flag"):
        available = get_available_budget(doc.fund, doc.budget_line)
        if doc.amount_requested > available:
            over_amount = doc.amount_requested - available
            frappe.throw(
                f"Pembayaran Diblokir: Fund {doc.fund} — Budget Line "
                f"'{doc.budget_line}' akan melebihi anggaran sebesar "
                f"{doc.currency} {over_amount:,.2f}. "
                f"Tersedia: {doc.currency} {available:,.2f}, "
                f"Dibutuhkan: {doc.currency} {doc.amount_requested:,.2f}."
            )
```

### Urutan Prioritas Validasi

Ketika beberapa validasi berlaku bersamaan, tampilkan dalam urutan berikut:
1. Error yang memblokir (ditampilkan satu per satu dengan `frappe.throw`)
2. Warning yang memerlukan konfirmasi (ditampilkan setelah semua error selesai)
3. Info banner (ditampilkan permanen di form, tidak memblokir)

Jangan menumpuk beberapa `frappe.throw()` sekaligus — gunakan array dan `frappe.throw(messages.join('<br>'))` jika ada banyak error dalam satu validasi.
