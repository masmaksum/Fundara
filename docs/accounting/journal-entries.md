# Fundara Journal Entry Rules Catalog

**Version:** 1.0  
**Date:** 2026-06-18  
**Standards:** ISAK 35 (primary), FASB ASC 958 (conceptual reference)  
**ERPNext Target:** v16  
**Base Currency:** IDR  
**Transaction Currencies:** IDR, USD, EUR (and others as configured)

---

## Purpose

This catalog defines every accounting transaction in Fundara with its Dr/Cr posting rules.
It is the authoritative reference for ERPNext developers implementing accounting hooks,
custom DocTypes, and GL posting logic.

**Governing decisions:**

- **D-02:** Budget reduces on actual payment only — no commitment layer reduces budget.
  `Available Budget = Approved Budget − Actual (paid transactions)`
- **D-04:** Multi-currency from day one. Every GL entry stores: `currency`,
  `exchange_rate`, `amount` (transaction currency), `amount_in_base_currency` (IDR).
- **D-05:** This file (`docs/accounting/`) is the canonical source for
  implementation details. `06-financial-accountability-context.md` is canonical
  for domain logic and lifecycle rules.

**ERPNext mechanics used:**

- `Journal Entry` — general purpose GL posting
- `Payment Entry` — cash/bank in and out (also used for advances)
- `Purchase Invoice` — expense recognition before payment
- `Sales Invoice` — business unit revenue recognition
- `Asset` + `Asset Depreciation Schedule` — fixed asset and depreciation
- `Accounting Dimension` — Fund, Project, Activity, Budget Line, Cost Center
  are dimensions on every GL entry line, **not** separate accounts in the CoA

---

## Net Asset Class Reference

| Fundara Term | Indonesian Label | FASB Equivalent | Account Group |
|---|---|---|---|
| Unrestricted | Aset Neto Tanpa Pembatasan | Net Assets Without Donor Restrictions | 3-1xxx |
| Temporarily Restricted | Aset Neto Dengan Pembatasan Temporer | Net Assets With Donor Restrictions (time/purpose) | 3-2xxx |
| Permanently Restricted | Aset Neto Dengan Pembatasan Permanen | Net Assets With Donor Restrictions (perpetual) | 3-3xxx |
| Board-Designated | Aset Neto Ditetapkan Pengurus | Board-Designated (subset of Unrestricted) | 3-4xxx |

> **Implementation note:** In ERPNext, "Temporarily Restricted" and "Permanently
> Restricted" are sub-accounts under the Aset Neto Dengan Pembatasan parent. The
> fund_restriction field on each Fund master drives which net asset sub-account
> receives postings.

---

## Chart of Accounts Structure

The minimum account tree for ISAK 35 compliance follows. Account codes use a
4-digit prefix; organisations may extend with additional sub-accounts.

### 1xxx — Aset (Assets)

| Code | Account Name | Normal Balance | ISAK 35 Report Line |
|---|---|---|---|
| 1-1100 | Kas Kecil | Debit | Laporan Posisi Keuangan — Kas dan Setara Kas |
| 1-1110 | Bank Operasional | Debit | Laporan Posisi Keuangan — Kas dan Setara Kas |
| 1-1120 | Bank Dana Terikat | Debit | Laporan Posisi Keuangan — Kas dan Setara Kas (disclosed separately in CALK) |
| 1-1130 | Deposito | Debit | Laporan Posisi Keuangan — Investasi Jangka Pendek |
| 1-1200 | Piutang Donor | Debit | Laporan Posisi Keuangan — Piutang |
| 1-1210 | Piutang Unit Usaha | Debit | Laporan Posisi Keuangan — Piutang |
| 1-1220 | Piutang Karyawan | Debit | Laporan Posisi Keuangan — Piutang |
| 1-1300 | Uang Muka Kegiatan | Debit | Laporan Posisi Keuangan — Uang Muka |
| 1-1310 | Uang Muka Perjalanan | Debit | Laporan Posisi Keuangan — Uang Muka |
| 1-1320 | Uang Muka Operasional | Debit | Laporan Posisi Keuangan — Uang Muka |
| 1-1400 | Persediaan | Debit | Laporan Posisi Keuangan — Persediaan |
| 1-2100 | Peralatan Kantor | Debit | Laporan Posisi Keuangan — Aset Tetap (gross) |
| 1-2110 | Kendaraan | Debit | Laporan Posisi Keuangan — Aset Tetap (gross) |
| 1-2120 | Bangunan | Debit | Laporan Posisi Keuangan — Aset Tetap (gross) |
| 1-2190 | Akumulasi Penyusutan | Credit | Laporan Posisi Keuangan — Aset Tetap (contra, netted) |
| 1-2200 | Aset Tidak Berwujud | Debit | Laporan Posisi Keuangan — Aset Lainnya |
| 1-2900 | Aset Lainnya | Debit | Laporan Posisi Keuangan — Aset Lainnya |
| 1-2910 | Selisih Kurs Belum Terealisasi — Aset | Debit | Laporan Posisi Keuangan — Aset Lainnya |

### 2xxx — Liabilitas (Liabilities)

| Code | Account Name | Normal Balance | ISAK 35 Report Line |
|---|---|---|---|
| 2-1100 | Utang Usaha | Credit | Laporan Posisi Keuangan — Liabilitas Jangka Pendek |
| 2-1200 | Utang Pajak | Credit | Laporan Posisi Keuangan — Liabilitas Jangka Pendek |
| 2-1300 | Utang Gaji | Credit | Laporan Posisi Keuangan — Liabilitas Jangka Pendek |
| 2-1400 | Dana Diterima di Muka | Credit | Laporan Posisi Keuangan — Liabilitas Jangka Pendek (deferred grant revenue) |
| 2-1500 | Utang Bridging Fund | Credit | Laporan Posisi Keuangan — Liabilitas Jangka Pendek (inter-fund payable) |
| 2-1600 | Selisih Kurs Belum Terealisasi — Liabilitas | Credit | Laporan Posisi Keuangan — Liabilitas Jangka Pendek |
| 2-9000 | Liabilitas Lainnya | Credit | Laporan Posisi Keuangan — Liabilitas Lainnya |

### 3xxx — Aset Neto (Net Assets)

| Code | Account Name | Normal Balance | ISAK 35 Report Line |
|---|---|---|---|
| 3-1000 | Aset Neto Tanpa Pembatasan | Credit | Laporan Posisi Keuangan — Aset Neto Tanpa Pembatasan |
| 3-2000 | Aset Neto Dengan Pembatasan Temporer | Credit | Laporan Posisi Keuangan — Aset Neto Dengan Pembatasan |
| 3-3000 | Aset Neto Dengan Pembatasan Permanen | Credit | Laporan Posisi Keuangan — Aset Neto Dengan Pembatasan |
| 3-4000 | Aset Neto Ditetapkan Pengurus | Credit | Laporan Posisi Keuangan — Aset Neto Tanpa Pembatasan (board-designated subset) |
| 3-9000 | Saldo Laba/Rugi Ditahan | Credit | Laporan Perubahan Aset Neto — Kumulatif |

### 4xxx — Pendapatan (Revenue / Support)

| Code | Account Name | Normal Balance | ISAK 35 Report Line |
|---|---|---|---|
| 4-1100 | Pendapatan Grant — Tanpa Pembatasan | Credit | Laporan Aktivitas — Pendapatan Tanpa Pembatasan |
| 4-1200 | Pendapatan Grant — Dengan Pembatasan Temporer | Credit | Laporan Aktivitas — Pendapatan Dengan Pembatasan |
| 4-1300 | Pendapatan Grant — Dengan Pembatasan Permanen | Credit | Laporan Aktivitas — Pendapatan Dengan Pembatasan |
| 4-2100 | Pendapatan Donasi — Tanpa Pembatasan | Credit | Laporan Aktivitas — Pendapatan Tanpa Pembatasan |
| 4-2200 | Pendapatan Donasi — Dengan Pembatasan | Credit | Laporan Aktivitas — Pendapatan Dengan Pembatasan |
| 4-3100 | Pendapatan Fundraising Campaign | Credit | Laporan Aktivitas — Pendapatan Tanpa Pembatasan (default) |
| 4-4100 | Pendapatan Unit Usaha | Credit | Laporan Aktivitas — Pendapatan Unit Usaha |
| 4-5100 | Pendapatan Jasa | Credit | Laporan Aktivitas — Pendapatan Lainnya |
| 4-6100 | Pelepasan Pembatasan Dana — Temporer | Credit | Laporan Aktivitas — Pelepasan Pembatasan |
| 4-6200 | Pelepasan Pembatasan Dana — Permanen | Credit | Laporan Aktivitas — Pelepasan Pembatasan |
| 4-7100 | Pendapatan Bunga Bank | Credit | Laporan Aktivitas — Pendapatan Lainnya |
| 4-7200 | Pendapatan Selisih Kurs Terealisasi | Credit | Laporan Aktivitas — Pendapatan Lainnya |
| 4-7300 | Pendapatan Selisih Kurs Belum Terealisasi | Credit | Laporan Aktivitas — Pendapatan Lainnya |
| 4-8100 | Keuntungan Pelepasan Aset | Credit | Laporan Aktivitas — Pendapatan Lainnya |
| 4-9000 | Pendapatan Lainnya | Credit | Laporan Aktivitas — Pendapatan Lainnya |

### 5xxx — Beban (Expenses)

| Code | Account Name | Normal Balance | ISAK 35 Report Line |
|---|---|---|---|
| 5-1100 | Beban Program | Debit | Laporan Aktivitas — Beban Program |
| 5-1200 | Beban Kegiatan | Debit | Laporan Aktivitas — Beban Program |
| 5-1300 | Beban Perjalanan | Debit | Laporan Aktivitas — Beban Program |
| 5-1400 | Beban Pengadaan | Debit | Laporan Aktivitas — Beban Program |
| 5-1500 | Beban Sub-Grant | Debit | Laporan Aktivitas — Beban Program |
| 5-2100 | Beban Personalia | Debit | Laporan Aktivitas — Beban Program / G&A (by cost center) |
| 5-3100 | Beban Fundraising | Debit | Laporan Aktivitas — Beban Fundraising |
| 5-4100 | Beban Administrasi dan Umum | Debit | Laporan Aktivitas — Beban Administrasi dan Umum |
| 5-4200 | Beban Sewa | Debit | Laporan Aktivitas — Beban Administrasi dan Umum |
| 5-4300 | Beban Utilitas | Debit | Laporan Aktivitas — Beban Administrasi dan Umum |
| 5-4400 | Beban Jasa Profesional | Debit | Laporan Aktivitas — Beban Administrasi dan Umum |
| 5-4500 | Beban Pajak | Debit | Laporan Aktivitas — Beban Administrasi dan Umum |
| 5-5100 | Beban Unit Usaha | Debit | Laporan Aktivitas — Beban Unit Usaha |
| 5-6100 | Beban Penyusutan | Debit | Laporan Aktivitas — Beban Program / G&A (by asset fund) |
| 5-6200 | Beban Selisih Kurs Terealisasi | Debit | Laporan Aktivitas — Beban Lainnya |
| 5-6300 | Beban Selisih Kurs Belum Terealisasi | Debit | Laporan Aktivitas — Beban Lainnya |
| 5-7100 | Rugi Pelepasan Aset | Debit | Laporan Aktivitas — Beban Lainnya |
| 5-8100 | Beban Penghapusan Piutang / Uang Muka | Debit | Laporan Aktivitas — Beban Administrasi dan Umum |
| 5-9100 | Beban Pelepasan Pembatasan | Debit | Laporan Aktivitas — Pelepasan Pembatasan |

---

## Dimension Rules (All Journal Entries)

Every GL entry line **must** carry the following Accounting Dimensions where applicable:

| Dimension | Required On | Optional On |
|---|---|---|
| `fund` | All expense, income, advance, liquidation entries | Opening balance entries |
| `project` | Project-linked expenses, advances, liquidations | — |
| `activity` | Activity-linked expenses, advances | — |
| `budget_line` | All expense entries | Income entries |
| `cost_center` | All expense entries | Income entries |
| `donor` | Grant income, donor-funded expenses | — |
| `campaign` | Campaign income lines | — |

> If a transaction has no fund, the system must **block posting** and require the
> user to assign one. This enforces Business Rule §10.1 of the Financial
> Accountability Context.

---

## Journal Entry Rules

---

## JE-01: Donation Received — Unrestricted

**Trigger:** Cash Receipt / Bank Receipt submitted with source_type = "Donation"
and fund_restriction = "Unrestricted"  
**ERPNext DocType:** `Payment Entry` (receive type) or custom `Cash Receipt`
posting a `Journal Entry`  
**Condition:** fund.restriction_class = "Unrestricted"  
**Fund Dimension:** fund linked to the Cr line (income) and Dr line (bank/cash)

| # | Account | Debit (Dr) | Credit (Cr) | Notes |
|---|---|---|---|---|
| 1 | Bank Operasional (1-1110) | Dr [amount] | — | Bank account receiving the donation |
| 2 | Pendapatan Donasi — Tanpa Pembatasan (4-2100) | — | Cr [amount] | Revenue recognized immediately |

**Multi-currency variant:** If donation is in USD/EUR, row 1 records
`amount_in_base_currency` (IDR equivalent at today's exchange rate) and the
`currency` + `exchange_rate` fields on the Payment Entry. ERPNext auto-creates
the exchange gain/loss entry if the rate differs from a prior AR entry (not
applicable here since this is a direct receipt).

**Edge cases:**
- If donor sends a cheque not yet cleared, use `Piutang Donor (1-1200)` as Dr
  instead of Bank, then create JE-08 (payment receipt) when cheque clears.
- If the donation is subsequently designated restricted by the board (not donor),
  post a board-designation reclassification journal (see JE-18 Opening Balance /
  manual adjustment pattern).
- Zero-amount donations (in-kind) are recorded via a separate in-kind donation
  journal at fair value — Dr Asset/Expense, Cr Pendapatan Donasi.

---

## JE-02: Donation Received — Restricted (Temporarily or Permanently)

**Trigger:** Cash Receipt / Bank Receipt submitted with source_type = "Donation"
and fund_restriction = "Temporarily Restricted" or "Permanently Restricted"  
**ERPNext DocType:** `Payment Entry` (receive type) or custom `Cash Receipt`  
**Condition:** fund.restriction_class ∈ {"Temporarily Restricted",
"Permanently Restricted"}  
**Fund Dimension:** fund linked on both GL lines

| # | Account | Debit (Dr) | Credit (Cr) | Notes |
|---|---|---|---|---|
| 1 | Bank Dana Terikat (1-1120) | Dr [amount] | — | Restricted funds held in segregated bank account (best practice) |
| 2 | Pendapatan Donasi — Dengan Pembatasan (4-2200) | — | Cr [amount] | Net asset increases in restricted class |

**Multi-currency variant:** Same as JE-01. Exchange rate at receipt date is
recorded. Unrealized gain/loss is recognized at period-end (JE-17).

**Edge cases:**
- If the restriction is purpose-based (e.g., "for program X only"), record the
  fund's purpose in the Fund master; no separate account is needed.
- If restriction is time-based (usable after a future date), same posting — the
  restriction release happens in JE-16 when the condition is met.
- Permanently restricted donations (e.g., endowment principal) credit
  `Aset Neto Dengan Pembatasan Permanen (3-3000)` directly as a net asset entry
  rather than a revenue entry, if the organisation's accounting policy treats
  endowments as direct equity contributions. Confirm with auditor.

---

## JE-03: Grant Received — Deferred Revenue Treatment

**Trigger:** Cash Receipt / Bank Receipt with source_type = "Grant" and the
grant agreement requires expense-before-recognition (cost-reimbursable grant)  
**ERPNext DocType:** `Payment Entry` (receive type) or custom `Bank Receipt`  
**Condition:** grant.recognition_method = "Cost Reimbursable" (grant advance
received before expenses are incurred)  
**Fund Dimension:** fund (Grant Fund) on both lines

| # | Account | Debit (Dr) | Credit (Cr) | Notes |
|---|---|---|---|---|
| 1 | Bank Dana Terikat (1-1120) | Dr [amount] | — | Grant cash received |
| 2 | Dana Diterima di Muka (2-1400) | — | Cr [amount] | Liability until expenses are incurred |

When expenses are incurred and conditions are met, release deferred revenue
via JE-16 (Restriction Release / Revenue Recognition):

| # | Account | Debit (Dr) | Credit (Cr) | Notes |
|---|---|---|---|---|
| 1 | Dana Diterima di Muka (2-1400) | Dr [amount] | — | Deferred liability reduced |
| 2 | Pendapatan Grant — Dengan Pembatasan Temporer (4-1200) | — | Cr [amount] | Revenue recognized as conditions met |

**Multi-currency variant (foreign currency grant — USD/EUR):**

| # | Account | Debit (Dr) | Credit (Cr) | Notes |
|---|---|---|---|---|
| 1 | Bank Dana Terikat (1-1120) | Dr [IDR equiv.] | — | Exchange rate = rate on receipt date |
| 2 | Dana Diterima di Muka (2-1400) | — | Cr [IDR equiv.] | Liability recorded at IDR equivalent |

The `Dana Diterima di Muka` balance is a monetary liability denominated in the
grant currency. At period-end, revalue it (JE-17) — any exchange difference posts
to selisih kurs accounts.

**Edge cases:**
- If grant is unconditional (no conditions attached, money freely available),
  recognize revenue immediately: Dr Bank, Cr Pendapatan Grant (no deferred
  liability). Confirm per grant agreement language.
- Partial grant drawdowns: each drawdown creates a separate JE-03 entry. The
  `Dana Diterima di Muka` balance accumulates until expenses are recognized.
- If the grant is recognized by milestone: recognize revenue when milestone is
  certified (not when cash arrives).

---

## JE-04: Grant Received — Direct Revenue Recognition

**Trigger:** Cash Receipt with source_type = "Grant" and
grant.recognition_method = "Unconditional" or "Output-based (conditions
substantially met at receipt)"  
**ERPNext DocType:** `Payment Entry` (receive type)  
**Condition:** grant.recognition_method = "Unconditional"  
**Fund Dimension:** fund on both lines

| # | Account | Debit (Dr) | Credit (Cr) | Notes |
|---|---|---|---|---|
| 1 | Bank Dana Terikat (1-1120) | Dr [amount] | — | |
| 2 | Pendapatan Grant — Dengan Pembatasan Temporer (4-1200) | — | Cr [amount] | Restricted class because grant has programmatic conditions |

> Use `Pendapatan Grant — Tanpa Pembatasan (4-1100)` if the grant is
> unrestricted (rare for institutional grants).

**Multi-currency variant:** As per JE-03 multi-currency rules. ERPNext
Payment Entry stores transaction currency (e.g., USD 50,000) and IDR equivalent.

**Edge cases:**
- Same as JE-03 unconditional case. If donor later places conditions post-receipt,
  reclassify from unrestricted to restricted via adjustment journal.

---

## JE-05: Business Unit Revenue Recorded

**Trigger:** Sales Invoice submitted for business unit services/products sold  
**ERPNext DocType:** `Sales Invoice`  
**Condition:** source_type = "Business Unit Revenue"  
**Fund Dimension:** business_unit fund on both lines

| # | Account | Debit (Dr) | Credit (Cr) | Notes |
|---|---|---|---|---|
| 1 | Piutang Unit Usaha (1-1210) | Dr [amount] | — | AR created on invoice submission |
| 2 | Pendapatan Unit Usaha (4-4100) | — | Cr [amount] | Revenue recognized on accrual basis |

When payment is received:

| # | Account | Debit (Dr) | Credit (Cr) | Notes |
|---|---|---|---|---|
| 1 | Bank Operasional (1-1110) | Dr [amount] | — | Cash received |
| 2 | Piutang Unit Usaha (1-1210) | — | Cr [amount] | AR cleared |

**Multi-currency variant:** If the service is billed in USD, Sales Invoice
records USD amount + exchange rate. Exchange difference between invoice date
rate and payment date rate posts to Pendapatan/Beban Selisih Kurs Terealisasi.

**Edge cases:**
- If the business unit surplus is transferred to the main unrestricted fund,
  use an internal fund transfer journal (JE-10).
- Services rendered but not yet invoiced: accrue with Dr Piutang Unit Usaha /
  Cr Pendapatan Unit Usaha at period end; reverse next period.

---

## JE-06: Cash Advance Paid to Staff

**Trigger:** Cash Advance status transitions to "Paid" — Finance releases the
advance payment  
**ERPNext DocType:** `Payment Entry` (pay type) linked to `Employee Advance`
or custom `Cash Advance`  
**Condition:** cash_advance.status = "Paid"  
**Fund Dimension:** fund, project, activity, budget_line on the Dr (advance) line

| # | Account | Debit (Dr) | Credit (Cr) | Notes |
|---|---|---|---|---|
| 1 | Uang Muka Kegiatan (1-1300) | Dr [amount] | — | Advance asset recorded; fund/project/activity/budget_line dimensions required |
| 2 | Bank Operasional (1-1110) | — | Cr [amount] | Cash paid out to staff |

**Multi-currency variant:** If advance is paid in USD (e.g., staff traveling
internationally), Dr Uang Muka Kegiatan at IDR equivalent. Exchange rate is
locked at payment date. At liquidation, differences become realized FX gain/loss.

**Budget impact (D-02):** Budget `actual` increases when this payment is made.
`Available Budget = Approved Budget − Actual` decreases by this amount.

**Edge cases:**
- Advance paid in cash (petty cash): Cr Kas Kecil (1-1100) instead of bank.
- Multiple advance payments for the same advance request (Additional Advance
  Payment): each payment creates a separate JE-06 entry, all pointing to the
  same Cash Advance document. The Uang Muka balance accumulates.
- Advance rejected before payment: no journal entry. Status stays "Rejected."
- Advance cancelled after payment: reverse JE-06 via a reversal journal entry
  and record cash receipt when money is returned.

---

## JE-07: Cash Advance Liquidated — Full Liquidation (Exact Match)

**Trigger:** Liquidation approved by Finance; actual expenses = advance amount  
**ERPNext DocType:** Custom `Liquidation` DocType, posting a `Journal Entry`  
**Condition:** liquidation.actual_amount = cash_advance.paid_amount  
**Fund Dimension:** fund, project, activity, budget_line on each expense line

| # | Account | Debit (Dr) | Credit (Cr) | Notes |
|---|---|---|---|---|
| 1 | Beban [relevant expense account] (5-xxxx) | Dr [actual amount] | — | One line per expense category; e.g., Beban Perjalanan, Beban Kegiatan |
| 2 | Uang Muka Kegiatan (1-1300) | — | Cr [actual amount] | Advance cleared |

**Multi-currency variant:** If advance was paid in USD and expenses are in IDR,
the Dr expense lines use IDR amounts. The Cr Uang Muka line uses the IDR
equivalent originally recorded at payment date. Any difference is a realized
FX gain/loss:

| # | Account | Debit (Dr) | Credit (Cr) | Notes |
|---|---|---|---|---|
| 1 | Beban [expense account] | Dr [actual IDR] | — | |
| 2 | Uang Muka Kegiatan (1-1300) | — | Cr [original IDR equiv.] | Original advance amount |
| 3 | Beban Selisih Kurs Terealisasi (5-6200) | Dr [FX loss] | — | If actual IDR > original equivalent |
| 3a | Pendapatan Selisih Kurs Terealisasi (4-7200) | — | Cr [FX gain] | If actual IDR < original equivalent |

**Edge cases:**
- Multiple expense categories in one liquidation: add one Dr line per expense
  account (all within the same journal entry).
- If the advance covered multiple activities: split the Dr lines by activity
  dimension; the Cr Uang Muka is a single line.

---

## JE-08: Cash Advance Liquidated — Partial Use (Refund Required)

**Trigger:** Liquidation approved; actual expenses < advance paid. Staff refunds
the surplus cash.  
**ERPNext DocType:** Custom `Liquidation` + `Payment Entry` (receive) for the
refund  
**Condition:** liquidation.actual_amount < cash_advance.paid_amount  
**Fund Dimension:** As per JE-07

**Step 1 — Expense recognition and advance clearing:**

| # | Account | Debit (Dr) | Credit (Cr) | Notes |
|---|---|---|---|---|
| 1 | Beban [expense account] (5-xxxx) | Dr [actual amount] | — | Only what was actually spent |
| 2 | Uang Muka Kegiatan (1-1300) | — | Cr [actual amount] | Partial advance cleared |

**Step 2 — Refund received from staff:**

| # | Account | Debit (Dr) | Credit (Cr) | Notes |
|---|---|---|---|---|
| 1 | Bank Operasional (1-1110) or Kas Kecil | Dr [refund amount] | — | Cash returned by staff |
| 2 | Uang Muka Kegiatan (1-1300) | — | Cr [refund amount] | Remaining advance balance closed |

After both steps, Uang Muka Kegiatan balance for this advance = 0.

**Budget impact (D-02):** Budget actual is reduced by the refund amount at the
fund/budget_line level. Only the net expense (actual_amount) consumes budget.
Implement via a negative budget actual adjustment when refund is posted.

**Edge cases:**
- Refund received in installments: create multiple Step 2 entries until
  Uang Muka balance = 0.
- Refund not received by due date: escalate to overdue; the Uang Muka balance
  remains open and appears on advance aging report.

---

## JE-09: Cash Advance Liquidated — Excess Spending (Reimbursement Required)

**Trigger:** Liquidation approved; actual expenses > advance paid. Organisation
owes staff a reimbursement.  
**ERPNext DocType:** Custom `Liquidation` + `Payment Entry` (pay) for
reimbursement  
**Condition:** liquidation.actual_amount > cash_advance.paid_amount  
**Fund Dimension:** As per JE-07

**Step 1 — Full expense recognition, advance fully cleared:**

| # | Account | Debit (Dr) | Credit (Cr) | Notes |
|---|---|---|---|---|
| 1 | Beban [expense account] (5-xxxx) | Dr [actual amount] | — | Total actual spent (including excess) |
| 2 | Uang Muka Kegiatan (1-1300) | — | Cr [advance paid amount] | Original advance cleared |
| 3 | Utang Usaha (2-1100) or Piutang Karyawan (credit) | — | Cr [excess amount] | Payable to staff for excess spending |

**Step 2 — Reimbursement paid to staff:**

| # | Account | Debit (Dr) | Credit (Cr) | Notes |
|---|---|---|---|---|
| 1 | Utang Usaha (2-1100) | Dr [excess amount] | — | Liability cleared |
| 2 | Bank Operasional (1-1110) | — | Cr [excess amount] | Cash paid to staff |

**Budget impact (D-02):** The full actual expense amount (including excess)
reduces available budget. The additional payment in Step 2 does not create a
second budget deduction — only the expense in Step 1 does.

**Edge cases:**
- If excess amount is not approved by Finance, the rejected portion is treated
  as per JE-10 (partial rejection).
- Reimbursement requires a separate approval workflow before Step 2 is posted.

---

## JE-10: Cash Advance — Partial Rejection During Liquidation

**Trigger:** Finance reviews liquidation and rejects some expense lines as
non-compliant (e.g., no receipt, out-of-policy, incorrect fund)  
**ERPNext DocType:** Custom `Liquidation` with rejection lines  
**Condition:** Some liquidation expense lines are marked "Rejected"  
**Fund Dimension:** fund, project, activity, budget_line on approved lines only

**Step 1 — Post only approved expenses; treat rejected amount as staff debt:**

| # | Account | Debit (Dr) | Credit (Cr) | Notes |
|---|---|---|---|---|
| 1 | Beban [expense account] | Dr [approved amount] | — | Only approved expense lines |
| 2 | Piutang Karyawan (1-1220) | Dr [rejected amount] | — | Rejected amount becomes receivable from staff |
| 3 | Uang Muka Kegiatan (1-1300) | — | Cr [total advance paid] | Advance fully cleared |

**Step 2 — Staff refunds the rejected amount:**

| # | Account | Debit (Dr) | Credit (Cr) | Notes |
|---|---|---|---|---|
| 1 | Bank Operasional (1-1110) | Dr [rejected amount] | — | Cash returned |
| 2 | Piutang Karyawan (1-1220) | — | Cr [rejected amount] | Receivable cleared |

**Budget impact (D-02):** Only the approved expense amount reduces budget.
The rejected amount that becomes Piutang Karyawan does not count as program
expense. When the staff refund is received, it does not affect budget.

**Edge cases:**
- If staff disputes the rejection, the Piutang Karyawan balance remains open
  until resolved. Flag on advance aging report.
- If rejected amount is written off (uncollectible), post:
  Dr Beban Penghapusan (5-8100) / Cr Piutang Karyawan (1-1220).

---

## JE-11: Purchase Invoice Posted — Goods or Services

**Trigger:** Purchase Invoice submitted and approved  
**ERPNext DocType:** `Purchase Invoice`  
**Condition:** Item type = Service or Non-asset goods  
**Fund Dimension:** fund, project, activity, budget_line, cost_center on each
expense line

| # | Account | Debit (Dr) | Credit (Cr) | Notes |
|---|---|---|---|---|
| 1 | Beban [expense account] (5-xxxx) | Dr [net amount] | — | One line per expense account/budget_line |
| 2 | Utang Usaha (2-1100) | — | Cr [total invoice amount] | Payable to vendor |

If tax is applicable (e.g., VAT / PPN):

| # | Account | Debit (Dr) | Credit (Cr) | Notes |
|---|---|---|---|---|
| 1 | Beban [expense account] | Dr [net amount] | — | |
| 2 | PPN Masukan / Input Tax (or include in expense if non-recoverable) | Dr [tax amount] | — | If VAT is a cost to the org |
| 3 | Utang Usaha (2-1100) | — | Cr [gross amount incl. tax] | |

**Budget impact (D-02):** Budget actual increases when the Purchase Invoice is
**submitted** (posted), per D-02 which states "Purchase Invoice (posted) reduces
budget." Note: payment does not create an additional budget reduction.

**Multi-currency variant:** If vendor invoice is in USD, the Utang Usaha is
recorded in IDR equivalent at invoice date rate. If the exchange rate at payment
differs, an exchange gain/loss is recognized at payment (JE-12).

**Edge cases:**
- Goods received but invoice not yet received (GRN without invoice): use an
  accrual journal Dr Beban / Cr Utang Usaha at estimated amount; reverse when
  actual invoice arrives.
- Invoice for multiple funds/projects: split Dr lines by fund dimension; each
  line carries its own fund, project, budget_line.

---

## JE-12: Purchase Invoice Posted — Fixed Asset Acquisition via Invoice

**Trigger:** Purchase Invoice submitted where item_type = "Fixed Asset"  
**ERPNext DocType:** `Purchase Invoice` with is_fixed_asset = True  
**Condition:** Item maps to a fixed asset category  
**Fund Dimension:** fund, project on the asset Dr line; donor dimension if
donor-funded

| # | Account | Debit (Dr) | Credit (Cr) | Notes |
|---|---|---|---|---|
| 1 | [Asset Account] e.g., Peralatan Kantor (1-2100) | Dr [asset cost] | — | Asset capitalized; fund/donor dimensions required |
| 2 | Utang Usaha (2-1100) | — | Cr [asset cost] | Payable to vendor |

After submission, ERPNext automatically creates a Fixed Asset record and links
it to the Invoice. The depreciation schedule is generated separately (see JE-20).

**Multi-currency variant:** Asset is capitalized at IDR equivalent on invoice
date. The IDR cost is the depreciable base going forward — subsequent exchange
rate changes do not adjust the asset cost.

**Edge cases:**
- Direct payment without invoice (cash purchase): use Cash Disbursement posting
  Dr Asset / Cr Bank directly (JE-13b below).
- Partial payment with retention: Dr Asset full amount / Cr Utang Usaha (payable)
  and note retention terms in the invoice.
- Asset purchased for multiple projects: capitalize the full asset under the
  primary fund; note the shared use in asset comments. Depreciation is then
  allocated by cost center (JE-20).

---

## JE-13: Payment to Vendor

**Trigger:** Payment Entry submitted against a Purchase Invoice  
**ERPNext DocType:** `Payment Entry` (pay type) linked to `Purchase Invoice`  
**Condition:** payment_entry.payment_type = "Pay"  
**Fund Dimension:** Inherited from the linked Purchase Invoice

| # | Account | Debit (Dr) | Credit (Cr) | Notes |
|---|---|---|---|---|
| 1 | Utang Usaha (2-1100) | Dr [payment amount] | — | Payable cleared |
| 2 | Bank Operasional (1-1110) | — | Cr [payment amount] | Cash paid out |

**Multi-currency variant:** If the invoice was in USD and payment is in USD at
a different rate:

| # | Account | Debit (Dr) | Credit (Cr) | Notes |
|---|---|---|---|---|
| 1 | Utang Usaha (2-1100) | Dr [original IDR equiv.] | — | At invoice-date rate |
| 2 | Bank Operasional (1-1110) | — | Cr [payment IDR equiv.] | At payment-date rate |
| 3 | Beban Selisih Kurs Terealisasi (5-6200) | Dr [FX loss] | — | If payment rate > invoice rate |
| 3a | Pendapatan Selisih Kurs Terealisasi (4-7200) | — | Cr [FX gain] | If payment rate < invoice rate |

ERPNext Payment Entry handles this automatically when multi-currency is enabled.

**Budget impact (D-02):** Budget is NOT reduced again at payment. It was already
reduced when the Purchase Invoice was posted (JE-11).

**Edge cases:**
- Partial payment: Dr Utang Usaha [partial amount] / Cr Bank [partial amount].
  The remaining payable stays open.
- Advance payment to vendor (prepayment): use Dr Uang Muka Operasional (1-1320)
  / Cr Bank — do not debit Utang Usaha until the vendor invoice arrives.
- Payment against multiple invoices: ERPNext Payment Entry supports multi-invoice
  allocation.

---

## JE-13b: Direct Cash/Bank Disbursement (Without Purchase Invoice)

**Trigger:** Cash Disbursement or Bank Disbursement submitted directly (no prior
invoice)  
**ERPNext DocType:** Custom `Bank Disbursement` or `Journal Entry`  
**Condition:** Simple expense paid directly without procurement flow  
**Fund Dimension:** fund, project, activity, budget_line required

For a program expense:

| # | Account | Debit (Dr) | Credit (Cr) | Notes |
|---|---|---|---|---|
| 1 | Beban Program (5-1100) | Dr [amount] | — | Or other relevant expense account |
| 2 | Bank Operasional (1-1110) | — | Cr [amount] | |

For a fixed asset purchase paid directly:

| # | Account | Debit (Dr) | Credit (Cr) | Notes |
|---|---|---|---|---|
| 1 | Peralatan Kantor (1-2100) | Dr [amount] | — | Asset capitalized |
| 2 | Bank Operasional (1-1110) | — | Cr [amount] | |

**Budget impact (D-02):** Budget actual increases at the time of this payment
(since there is no prior invoice step).

---

## JE-14: Internal Fund Transfer (Source Fund → Target Fund)

**Trigger:** Finance creates a Fund Transfer journal to move resources between
two internal funds (e.g., from Unrestricted General Fund to a Campaign Fund, or
from Bridging Fund to a Grant Fund)  
**ERPNext DocType:** Custom `Fund Transfer Entry` or `Journal Entry` with
journal_type = "Fund Transfer"  
**Condition:** Both funds exist and are active; transfer is approved  
**Fund Dimension:** source fund on Cr line; target fund on Dr line

| # | Account | Debit (Dr) | Credit (Cr) | Notes |
|---|---|---|---|---|
| 1 | Aset Neto [target fund class] (3-xxxx) | Dr [amount] | — | Net asset of target fund increases (Dr reduces restriction balance) — *see note below* |
| 2 | Aset Neto [source fund class] (3-xxxx) | — | Cr [amount] | Net asset of source fund decreases |

> **Note on account selection:** An internal fund transfer does not change total
> net assets — it reclassifies them. The debit and credit are both to Aset Neto
> accounts. The fund dimension on each line ensures the fund ledger reflects the
> movement. In ERPNext, use two lines on a Journal Entry — each line carries a
> different fund dimension.

**Alternative approach (via clearing account):** Some implementations prefer a
clearing (inter-fund) account:

| # | Account | Debit (Dr) | Credit (Cr) | Notes |
|---|---|---|---|---|
| 1 | Inter-Fund Transfer Receivable (asset) | Dr [amount] | — | On source fund side |
| 2 | Bank Operasional (if cash actually moves) | — | Cr [amount] | Source fund pays out |
| 3 | Bank Operasional (if cash received) | Dr [amount] | — | Target fund receives |
| 4 | Inter-Fund Transfer Payable (liability) | — | Cr [amount] | Target fund side |

Use the net asset approach for accounting reclassification where no cash moves.
Use the clearing account approach when cash physically moves between bank
accounts.

**Edge cases:**
- Transfer from restricted fund to unrestricted: only allowed if restriction
  conditions are fully met — otherwise record as Restriction Release (JE-16).
- Transfer requires approval from Finance Director and, if restricted funds are
  involved, from Program Director.

---

## JE-15: Bridging Fund — Expense Paid by Bridging Fund

**Trigger:** An expense for Fund B is paid from the Bridging Fund (e.g., Fund B
has not received its grant cash yet)  
**ERPNext DocType:** Custom `Bank Disbursement` with bridging_fund flag, or
`Journal Entry`  
**Condition:** payment.fund = Bridging Fund; expense.intended_fund = Fund B  
**Fund Dimension:** Bridging Fund on the Cr (bank/cash) line; Fund B on the
Dr (expense) line

| # | Account | Debit (Dr) | Credit (Cr) | Notes |
|---|---|---|---|---|
| 1 | Beban [expense account] (5-xxxx) | Dr [amount] | — | Fund dimension = Fund B (the intended fund) |
| 2 | Utang Bridging Fund (2-1500) | — | Cr [amount] | Liability: Fund B owes Bridging Fund |

Simultaneously, on the Bridging Fund ledger, record the cash outflow:

| # | Account | Debit (Dr) | Credit (Cr) | Notes |
|---|---|---|---|---|
| 1 | Piutang antar-Fund (1-xxxx) or Utang Bridging Fund (2-1500) | Dr [amount] | — | Bridging Fund's receivable from Fund B |
| 2 | Bank Operasional (1-1110) | — | Cr [amount] | Cash out from Bridging Fund's bank |

> **Implementation note for ERPNext:** Use two GL entry lines with different
> fund dimensions on the same Journal Entry to achieve the cross-fund posting.
> One line: fund = Bridging Fund; another line: fund = Fund B.

**Multi-currency variant:** If the expense is in USD and the Bridging Fund
account is in IDR, record at the exchange rate on the payment date. The
Utang Bridging Fund is in IDR.

**Edge cases:**
- Multiple expenses paid from Bridging Fund for the same target fund: each
  payment creates its own JE-15. The Utang Bridging Fund liability accumulates.
- Bridging Fund should never have a negative balance — implement a balance check
  before allowing this payment.

---

## JE-16: Bridging Fund Settlement — Target Fund Reimburses Bridging Fund

**Trigger:** Fund B receives its grant cash and reimburses the Bridging Fund  
**ERPNext DocType:** `Payment Entry` or `Journal Entry` with
journal_type = "Bridging Fund Settlement"  
**Condition:** Fund B has sufficient balance; Utang Bridging Fund balance > 0  
**Fund Dimension:** Fund B on Cr (bank) line; Bridging Fund on Dr line

| # | Account | Debit (Dr) | Credit (Cr) | Notes |
|---|---|---|---|---|
| 1 | Utang Bridging Fund (2-1500) | Dr [amount] | — | Fund B's liability cleared; fund dimension = Fund B |
| 2 | Bank Dana Terikat (1-1120) | — | Cr [amount] | Fund B's bank account decreases |

Bridging Fund receives the cash:

| # | Account | Debit (Dr) | Credit (Cr) | Notes |
|---|---|---|---|---|
| 1 | Bank Operasional (1-1110) | Dr [amount] | — | Bridging Fund's bank account increases |
| 2 | Piutang antar-Fund | — | Cr [amount] | Bridging Fund's receivable cleared |

**Edge cases:**
- Partial reimbursement: settle proportionally; Utang Bridging Fund balance
  remains for the unpaid portion.
- Exchange rate difference at settlement vs. at original payment: recognize
  FX gain/loss on the Bridging Fund's books.

---

## JE-17: Restriction Release — Temporarily Restricted to Unrestricted

**Trigger:** Program confirms that the restricted purpose has been fulfilled
(activity completed, time period elapsed, or reporting milestone achieved);
Finance posts the release  
**ERPNext DocType:** Custom `Restriction Release Entry` or `Journal Entry` with
journal_type = "Restriction Release"  
**Condition:** fund.restriction_class = "Temporarily Restricted" and release
conditions are certified  
**Fund Dimension:** The restricted fund on both lines

| # | Account | Debit (Dr) | Credit (Cr) | Notes |
|---|---|---|---|---|
| 1 | Beban Pelepasan Pembatasan (5-9100) | Dr [amount] | — | Reduces restricted net assets; fund dimension = restricted fund |
| 2 | Pendapatan Donasi / Grant — Tanpa Pembatasan (4-2100 or 4-1100) | — | Cr [amount] | Recognized in unrestricted class |

Alternatively, using net asset accounts directly (for the fund reclassification):

| # | Account | Debit (Dr) | Credit (Cr) | Notes |
|---|---|---|---|---|
| 1 | Aset Neto Dengan Pembatasan Temporer (3-2000) | Dr [amount] | — | Restricted net assets reduced |
| 2 | Aset Neto Tanpa Pembatasan (3-1000) | — | Cr [amount] | Unrestricted net assets increased |

> **ISAK 35 presentation note:** In the Laporan Aktivitas, restriction releases
> appear as a separate line item: "Pelepasan Pembatasan Dana" — deducted from
> restricted column and added to unrestricted column. The accounting entry should
> support this two-column presentation. Fundara recommends using the income
> statement approach (first variant above) so that the Laporan Aktivitas
> automatically presents this correctly.

**Edge cases:**
- Release of grant deferred revenue (Dana Diterima di Muka): if the grant was
  originally recorded as deferred (JE-03), the release is:
  Dr Dana Diterima di Muka (2-1400) / Cr Pendapatan Grant — Dengan Pembatasan
  Temporer (4-1200) — recognizing the revenue, not just reclassifying net assets.
- Partial release: if only a portion of the restriction is lifted, post only that
  portion.
- Permanently restricted funds: restrictions are **never** released — no JE-17
  for permanently restricted. If the original classification was wrong, correct
  via a prior-period adjustment.

---

## JE-18: Multi-Currency Revaluation — Unrealized Gain/Loss at Period End

**Trigger:** Period-end close process — revalue all foreign-currency monetary
balances (bank accounts, receivables, payables in non-IDR currency) to the
closing rate  
**ERPNext DocType:** `Journal Entry` created by ERPNext's Exchange Rate
Revaluation tool or a custom period-end script  
**Condition:** Triggered at month-end or year-end; only for accounts with
open balances in non-IDR currencies  
**Fund Dimension:** Same fund dimension as the original monetary balance

For an unrealized gain (IDR appreciated / foreign currency weakened):

| # | Account | Debit (Dr) | Credit (Cr) | Notes |
|---|---|---|---|---|
| 1 | Bank Dana Terikat (1-1120) or Utang Usaha (2-1100) | Dr or Cr [revaluation diff.] | — | Adjust the carrying amount |
| 2 | Pendapatan Selisih Kurs Belum Terealisasi (4-7300) | — | Cr [gain amount] | For asset appreciation |

For an unrealized loss (IDR depreciated / foreign currency strengthened):

| # | Account | Debit (Dr) | Credit (Cr) | Notes |
|---|---|---|---|---|
| 1 | Beban Selisih Kurs Belum Terealisasi (5-6300) | Dr [loss amount] | — | |
| 2 | Bank Dana Terikat (1-1120) or Utang Usaha | — | Cr [revaluation diff.] | Reduce carrying amount |

For `Dana Diterima di Muka` (monetary liability in foreign currency):

| # | Account | Debit (Dr) | Credit (Cr) | Notes |
|---|---|---|---|---|
| 1 | Dana Diterima di Muka (2-1400) | Dr [gain — liability decreased] | — | If IDR weakened (liability worth more in IDR) |
| 2 | Beban Selisih Kurs Belum Terealisasi (5-6300) | Dr [loss] | — | |
| 3 | Pendapatan Selisih Kurs Belum Terealisasi (4-7300) | — | Cr [gain] | |

**ERPNext implementation:** Use `Exchange Rate Revaluation` tool in ERPNext v16.
This generates a Journal Entry automatically. Fundara must ensure fund dimensions
are propagated to the generated entries.

**Reversal at next period start:** ERPNext can optionally auto-reverse the
unrealized entry at the start of the next period; when the actual transaction
settles, the realized gain/loss is recorded (via JE-07 or JE-13).

**Edge cases:**
- Revaluation of `Uang Muka` in foreign currency: treat Uang Muka as a monetary
  asset; revalue to closing rate.
- Do not revalue non-monetary items (prepaid expenses, advance payments for
  goods not yet received when already fixed in terms).

---

## JE-19: Opening Balance Entry

**Trigger:** Opening Balance Assistant completed and validated; Finance posts the
opening balance journal  
**ERPNext DocType:** `Journal Entry` with journal_type = "Opening Entry"; or
ERPNext Opening Balance import  
**Condition:** Fiscal year is new; validated per the Opening Balance Assistant  
**Fund Dimension:** Each balance line carries the appropriate fund dimension

The opening balance entry is a single large Journal Entry with Dr lines for all
assets and Cr lines for all liabilities and net assets. It must balance.

Example structure:

| # | Account | Debit (Dr) | Credit (Cr) | Notes |
|---|---|---|---|---|
| 1 | Kas Kecil (1-1100) | Dr [opening balance] | — | Per physical cash count |
| 2 | Bank Operasional (1-1110) | Dr [opening balance] | — | Per bank statement; per fund dimension |
| 3 | Bank Dana Terikat (1-1120) | Dr [opening balance] | — | Restricted fund bank balance |
| 4 | Piutang Donor (1-1200) | Dr [opening balance] | — | Outstanding donor receivables |
| 5 | Uang Muka Kegiatan (1-1300) | Dr [opening balance] | — | Outstanding advance per staff |
| 6 | Peralatan Kantor (1-2100) | Dr [gross book value] | — | Per asset register |
| 7 | Akumulasi Penyusutan (1-2190) | — | Cr [accumulated depreciation] | |
| 8 | Utang Usaha (2-1100) | — | Cr [opening balance] | Outstanding vendor payables |
| 9 | Dana Diterima di Muka (2-1400) | — | Cr [outstanding deferred grants] | Per fund |
| 10 | Aset Neto Tanpa Pembatasan (3-1000) | — | Cr [calculated] | = Total assets − liabilities − restricted net assets |
| 11 | Aset Neto Dengan Pembatasan Temporer (3-2000) | — | Cr [per fund] | Per restricted fund balance |
| 12 | Aset Neto Dengan Pembatasan Permanen (3-3000) | — | Cr [per fund] | Per permanently restricted fund |

**Validation before posting:**
- Total Dr = Total Cr (standard double-entry check)
- Sum of fund balances = total of relevant asset/liability accounts
- Net asset accounts cross-check: Total Aset − Total Liabilitas = Total Aset Neto

**Edge cases:**
- If migrating from a prior system mid-year: the opening entry captures balances
  as of the migration date; prior-period income/expense is netted into Aset Neto.
- Outstanding advances must be listed with staff name, fund, activity, due date
  in supporting schedule (CALK disclosure).
- After posting, lock the opening balance period; it cannot be modified without
  a separate correction journal.

---

## JE-20: Monthly Depreciation Posting

**Trigger:** Finance runs monthly depreciation for all active depreciable assets  
**ERPNext DocType:** `Asset` → `Asset Depreciation Schedule` → `Journal Entry`
(auto-generated by ERPNext Asset module)  
**Condition:** Asset status = "Submitted" (active); depreciation_schedule has a
pending entry for this month  
**Fund Dimension:** fund, project, donor from the Asset's funding source record;
cost_center from asset location

| # | Account | Debit (Dr) | Credit (Cr) | Notes |
|---|---|---|---|---|
| 1 | Beban Penyusutan (5-6100) | Dr [monthly depreciation amount] | — | Expense posted to the fund that funded the asset |
| 2 | Akumulasi Penyusutan (1-2190) | — | Cr [monthly depreciation amount] | Contra-asset reduces net book value |

**Formula:**
```
Monthly Depreciation = (Cost − Residual Value) ÷ Useful Life in Months
```

For straight-line method. ERPNext Asset module supports this natively.

**Multi-currency note:** The asset is capitalized in IDR (at cost on acquisition
date). Depreciation is always in IDR regardless of the original purchase currency.

**Donor reporting note:** If the donor's grant agreement treats asset purchase
as full expense at acquisition (common with some bilateral donors), set
`donor_reporting_treatment = "Full Expense at Acquisition"` on the Asset. In
this case, no depreciation is reported to that donor; the full cost was already
reported in the period of purchase. The accounting depreciation still posts to
the GL as shown above.

**Edge cases:**
- Partial month (asset acquired mid-month): apply the depreciation policy
  (`start_of_next_month` or `pro_rata`). Configure per Asset Category.
- Asset disposed before end of depreciation schedule: post final depreciation
  up to disposal date (JE-21 handles the disposal gain/loss).
- If two funds share an asset (e.g., multi-donor project), split the depreciation
  Dr line by fund dimension proportionally. Use separate GL lines in the same JE.
- Double-posting guard: ERPNext prevents posting a depreciation schedule entry
  twice. Fundara must also validate this in the depreciation run script.

---

## JE-21: Fixed Asset Disposal

**Trigger:** Asset disposed of (sold, scrapped, donated, grant closeout disposal)  
**ERPNext DocType:** `Asset` → `Asset Disposal` (ERPNext built-in) or `Journal
Entry` with journal_type = "Asset Disposal"  
**Condition:** Asset status transitions to "Disposed"  
**Fund Dimension:** fund from the Asset's funding source

**Case A — Disposed at net book value (no gain/loss):**

| # | Account | Debit (Dr) | Credit (Cr) | Notes |
|---|---|---|---|---|
| 1 | Akumulasi Penyusutan (1-2190) | Dr [accumulated depreciation] | — | Remove contra-asset |
| 2 | [Asset account e.g., Peralatan] (1-2100) | — | Cr [original cost] | Remove asset at cost |

**Case B — Sold at a gain (sale proceeds > net book value):**

| # | Account | Debit (Dr) | Credit (Cr) | Notes |
|---|---|---|---|---|
| 1 | Bank Operasional (1-1110) | Dr [sale proceeds] | — | Cash received |
| 2 | Akumulasi Penyusutan (1-2190) | Dr [accumulated depreciation] | — | Remove contra-asset |
| 3 | [Asset account] (1-2100) | — | Cr [original cost] | Remove asset at cost |
| 4 | Keuntungan Pelepasan Aset (4-8100) | — | Cr [gain = proceeds − NBV] | |

**Case C — Disposed at a loss (sale proceeds < net book value or scrapped):**

| # | Account | Debit (Dr) | Credit (Cr) | Notes |
|---|---|---|---|---|
| 1 | Bank Operasional (1-1110) | Dr [proceeds, if any] | — | Zero if scrapped |
| 2 | Akumulasi Penyusutan (1-2190) | Dr [accumulated depreciation] | — | |
| 3 | Rugi Pelepasan Aset (5-7100) | Dr [loss = NBV − proceeds] | — | |
| 4 | [Asset account] (1-2100) | — | Cr [original cost] | |

**Edge cases:**
- Grant-funded asset disposed at grant closeout: donor may require proceeds to
  be returned to the donor or used to acquire a replacement. Record according
  to grant agreement terms.
- Asset donated to another organization: proceeds = 0; post as Case C with full
  loss = NBV. Note the in-kind donation value in CALK.
- Transfer to another fund (asset reclassification between funds): no disposal
  — update the Fund dimension on the Asset record and post an internal fund
  reclassification journal.

---

## JE-22: Bank Reconciliation Adjustment

**Trigger:** During bank reconciliation, Finance identifies a bank charge, bank
interest, or error that was not previously recorded in Fundara  
**ERPNext DocType:** `Journal Entry` created during bank reconciliation process  
**Condition:** Bank statement line is unmatched because no Fundara transaction
exists  
**Fund Dimension:** Operational fund or the fund associated with the bank account

**Case A — Bank fee / charge recorded:**

| # | Account | Debit (Dr) | Credit (Cr) | Notes |
|---|---|---|---|---|
| 1 | Beban Administrasi dan Umum (5-4100) | Dr [bank fee] | — | Or a dedicated "Bank Charges" sub-account |
| 2 | Bank Operasional (1-1110) | — | Cr [bank fee] | |

**Case B — Bank interest income recorded:**

| # | Account | Debit (Dr) | Credit (Cr) | Notes |
|---|---|---|---|---|
| 1 | Bank Operasional (1-1110) | Dr [interest amount] | — | |
| 2 | Pendapatan Bunga Bank (4-7100) | — | Cr [interest amount] | |

**Case C — Duplicate transaction correction (transaction was double-posted):**

| # | Account | Debit (Dr) | Credit (Cr) | Notes |
|---|---|---|---|---|
| 1 | [Expense account] (5-xxxx) | — | Cr [duplicate amount] | Reversal of duplicate |
| 2 | Bank Operasional (1-1110) | Dr [duplicate amount] | — | Add back to bank |

**Edge cases:**
- Reconciliation adjustments must carry an explanation in the journal's
  `user_remark` field.
- After reconciliation is closed, adjustments require Finance Director approval
  and create an audit trail flag.
- Foreign currency bank accounts: bank statements show local (foreign) currency
  balances. Reconcile in the foreign currency first, then the IDR equivalent
  follows from the exchange rate.

---

## JE-23: Multi-Currency Revaluation — Full Cycle Summary

This is a companion to JE-18. It summarizes the full realized + unrealized FX
cycle for developer reference.

**Unrealized (period-end) — JE-18:**
- Revalue open monetary balances to closing rate.
- Post to Pendapatan/Beban Selisih Kurs Belum Terealisasi.
- Optionally auto-reverse at start of next period.

**Realized (at settlement) — embedded in JE-07, JE-09, JE-12, JE-13:**
- When a foreign-currency transaction is settled (advance liquidated, invoice
  paid, grant received and used), the difference between the original IDR
  equivalent and the settlement IDR equivalent is the realized FX gain/loss.
- Post to Pendapatan/Beban Selisih Kurs Terealisasi (4-7200 / 5-6200).

**ERPNext handling:** ERPNext v16 Payment Entry automatically computes and posts
the exchange rate difference. For Journal Entries with foreign currency lines,
the developer must ensure the `exchange_rate` field is populated on each GL line
and the `difference_account` (set to the FX gain/loss account) is configured.

---

## JE-24: Period Closing Journal

**Trigger:** Finance closes the accounting period (monthly or annual)  
**ERPNext DocType:** ERPNext Period Closing Voucher, supplemented by a custom
`Journal Entry` for ISAK 35-specific entries  
**Condition:** All reconciliation, revaluation, and depreciation entries are
posted; period is locked  
**Fund Dimension:** Not applicable (aggregate entry)

ERPNext handles closing via the `Period Closing Voucher` which:
1. Prevents further posting to the closed period
2. Transfers net income/loss to the retained earnings account

In Fundara, the ISAK 35 equivalent is:

| # | Account | Debit (Dr) | Credit (Cr) | Notes |
|---|---|---|---|---|
| 1 | Pendapatan [all income accounts] | Dr [total income] | — | Close income accounts to zero |
| 2 | Beban [all expense accounts] | — | Cr [total expenses] | Close expense accounts to zero |
| 3 | Saldo Laba/Rugi Ditahan (3-9000) | Dr or Cr [net] | — | Net surplus/deficit to retained net assets |

> In ERPNext, this is handled automatically by Period Closing Voucher. Fundara
> should map the closing account to `Saldo Laba/Rugi Ditahan (3-9000)`.

**ISAK 35-specific year-end allocation:**
After closing, if the organisation's policy is to allocate the net surplus by
fund type:

| # | Account | Debit (Dr) | Credit (Cr) | Notes |
|---|---|---|---|---|
| 1 | Saldo Laba/Rugi Ditahan (3-9000) | Dr [restricted surplus] | — | Reclassify to proper net asset class |
| 2 | Aset Neto Dengan Pembatasan Temporer (3-2000) | — | Cr [restricted surplus] | |

**Edge cases:**
- If the period has material unreconciled bank items, the system must show a
  warning before allowing close (but not block, per Business Rule §10.20 if
  approval is given).
- Annual close additionally requires depreciation is fully posted and all
  advances with overdue status are reviewed.

---

## JE-25: Cost Sharing — One Expense Split Across Multiple Funds

**Trigger:** An expense (e.g., shared staff salary, shared rent) is split
proportionally across multiple funds  
**ERPNext DocType:** `Journal Entry` with journal_type = "Allocation" or
`Purchase Invoice` with split expense lines  
**Condition:** Expense involves multiple funds per the cost-sharing policy  
**Fund Dimension:** Each Dr line carries a different fund dimension

| # | Account | Debit (Dr) | Credit (Cr) | Notes |
|---|---|---|---|---|
| 1 | Beban [expense account] (5-xxxx) | Dr [Fund A share] | — | Fund dimension = Fund A; budget_line = Fund A's line |
| 2 | Beban [expense account] (5-xxxx) | Dr [Fund B share] | — | Fund dimension = Fund B; budget_line = Fund B's line |
| 3 | Beban [expense account] (5-xxxx) | Dr [Fund C share] | — | Fund dimension = Fund C; budget_line = Fund C's line |
| 4 | Utang Usaha (2-1100) or Bank | — | Cr [total amount] | Single payable/cash line |

The allocation ratio must be documented in a `Cost Sharing Policy` linked to
the Journal Entry. ERPNext Accounting Dimension allows multiple lines with
different dimensions in a single Journal Entry.

**Budget impact (D-02):** Each fund's budget is reduced by its share. Budget
check must be performed for each fund separately before posting.

**Multi-currency variant:** If the source document is in USD, each Dr line
carries the IDR equivalent of its proportional share.

**Edge cases:**
- Retroactive allocation (expense was initially posted to one fund, then split):
  create a correction journal — reverse the original posting and re-post with
  split.
- Allocation ratios may change quarterly (e.g., as headcount changes). Each
  cost-sharing period should have its own allocation policy documented.
- Donor may not allow certain allocation methods. The `budget_line` dimension
  on each fund's share must map to an allowable budget line in that fund's
  grant budget.

---

## JE-26: Advance Overdue — Write-Off

**Trigger:** Cash Advance has been overdue for a policy-defined period (e.g.,
>90 days past liquidation due date) and Finance decides to write off or deduct
from payroll  
**ERPNext DocType:** `Journal Entry` with journal_type = "Write-Off"  
**Condition:** cash_advance.status = "Overdue" AND write-off is approved  
**Fund Dimension:** fund from the original advance

**Option A — Write-off as expense (uncollectible):**

| # | Account | Debit (Dr) | Credit (Cr) | Notes |
|---|---|---|---|---|
| 1 | Beban Penghapusan Piutang / Uang Muka (5-8100) | Dr [overdue advance amount] | — | Policy expense; fund dimension required |
| 2 | Uang Muka Kegiatan (1-1300) | — | Cr [overdue advance amount] | Advance balance closed |

**Option B — Deducted from payroll (recovered via HR):**

| # | Account | Debit (Dr) | Credit (Cr) | Notes |
|---|---|---|---|---|
| 1 | Utang Gaji (2-1300) | Dr [deduction amount] | — | Offset against payroll liability |
| 2 | Uang Muka Kegiatan (1-1300) | — | Cr [deduction amount] | Advance balance reduced |

**Option C — Write-off reversed when advance is subsequently liquidated:**
If the staff later submits the liquidation after the write-off:

| # | Account | Debit (Dr) | Credit (Cr) | Notes |
|---|---|---|---|---|
| 1 | Uang Muka Kegiatan (1-1300) | Dr [amount] | — | Reinstate the advance |
| 2 | Beban Penghapusan (5-8100) | — | Cr [amount] | Reverse the write-off |

Then apply JE-07 / JE-08 normally for the liquidation.

**Budget impact (D-02):** The write-off (Option A) is recorded as an actual
expense and reduces available budget. This is consistent with D-02 — the advance
payment already reduced budget at the time of payment (JE-06), so the write-off
does not double-reduce budget; it reclassifies the asset (Uang Muka) into an
expense.

**Edge cases:**
- Write-off requires Finance Director approval and HR coordination.
- The write-off does not forgive the staff's obligation — HR follows up
  separately. The accounting write-off and the legal obligation are independent.
- If Organisation has an allowance-for-doubtful-advances policy, create an
  allowance account (contra-asset under Uang Muka) and post periodically:
  Dr Beban Penyisihan Uang Muka / Cr Penyisihan Uang Muka (contra).

---

## JE-27: Cost of Goods Sold / Business Unit Inventory (If Applicable)

**Trigger:** Business unit sells goods from inventory  
**ERPNext DocType:** `Sales Invoice` with `Delivery Note`  
**Condition:** Business unit has inventory (Persediaan) on the balance sheet  
**Fund Dimension:** Business unit fund

| # | Account | Debit (Dr) | Credit (Cr) | Notes |
|---|---|---|---|---|
| 1 | Piutang Unit Usaha (1-1210) | Dr [sale price] | — | Revenue recognition (same as JE-05) |
| 2 | Pendapatan Unit Usaha (4-4100) | — | Cr [sale price] | |
| 3 | Beban Unit Usaha (5-5100) | Dr [cost of goods] | — | COGS posted simultaneously |
| 4 | Persediaan (1-1400) | — | Cr [cost of goods] | Inventory reduced |

---

## Summary Table — Budget Impact by Transaction

Per Decision D-02, the following table summarizes when the budget actual is
updated:

| JE # | Transaction | Budget Impact | Trigger Point |
|---|---|---|---|
| JE-01/02 | Donation received | None | Income, not expense |
| JE-03/04 | Grant received | None | Income, not expense |
| JE-06 | Cash Advance paid | Reduces available budget | When advance is paid (Payment Entry) |
| JE-07/08/09 | Advance liquidated | No additional reduction | Budget already reduced at JE-06 |
| JE-10 | Partial rejection — expense | Reduces budget by approved amount only | At liquidation approval |
| JE-11 | Purchase Invoice posted | Reduces available budget | When invoice is submitted/posted |
| JE-12 | Fixed Asset invoice | Reduces available budget | When invoice is submitted/posted |
| JE-13 | Payment to vendor | No additional reduction | Budget was reduced at JE-11 |
| JE-13b | Direct disbursement | Reduces available budget | At payment |
| JE-14 | Internal fund transfer | Per fund: reduces source, increases target | At transfer posting |
| JE-15 | Bridging fund expense | Reduces Fund B budget | At bridging payment |
| JE-20 | Depreciation | No budget impact | Depreciation is not budget-controlled |
| JE-25 | Cost sharing | Reduces each fund's budget by its share | At allocation posting |
| JE-26 | Advance write-off | No additional reduction (already reduced at JE-06) | Write-off posts as expense reclassification |

---

## Developer Implementation Notes

### 1. Accounting Dimension Enforcement

In ERPNext v16, configure `Accounting Dimension` for:
- `fund` — mandatory on all expense and income GL lines
- `project` — mandatory on project-linked expenses
- `activity` — mandatory on activity-linked expenses
- `budget_line` — mandatory on all expense lines
- `cost_center` — mandatory on all expense lines

Implement via `validate` hooks on `Journal Entry` and `Payment Entry` to check
that the required dimensions are populated before `submit`.

### 2. Fund Balance Update

Fund balance is a derived view: sum of all GL entries with a given `fund`
dimension. Do not store fund balance as a separate field — query from
`GL Entry` to ensure accuracy. Provide a fast cached view for dashboards, but
always recompute from GL for official reports.

### 3. Exchange Rate Storage

Every `GL Entry` must store:
```
currency (transaction currency)
exchange_rate (to IDR on transaction date)
debit / credit (in transaction currency)
debit_in_account_currency / credit_in_account_currency (ERPNext fields)
```

Use ERPNext's built-in `Currency Exchange` master for rate lookup. Allow manual
override per transaction (required for grant agreements that fix the exchange rate).

### 4. Budget Check (D-02 Implementation)

```
On Payment Entry (pay) submit:
  → check budget availability for fund + budget_line + project
  → available = approved_budget − sum(GL entries where is_payment=true)
  → block if available < 0 (or warn if override is allowed for Finance Director)

On Purchase Invoice submit:
  → same check (invoice posting reduces budget per D-02)

On Journal Entry submit (expense lines):
  → same check
```

The "Pending Payment" warning (approved but not yet paid advances/orders)
should appear as an informational dashboard widget, not as a budget deduction.

### 5. Net Asset Class Routing

The routing logic that determines which net asset account to post to is:
```
If fund.restriction_class == "Unrestricted":
    income → 4-2100 or 4-1100 (unrestricted revenue)
    net asset → 3-1000

If fund.restriction_class == "Temporarily Restricted":
    income → 4-2200 or 4-1200 (restricted revenue)
    net asset → 3-2000

If fund.restriction_class == "Permanently Restricted":
    income → 4-1300
    net asset → 3-3000

If fund.restriction_class == "Board Designated":
    income → 4-2100 (unrestricted, board designation is internal)
    net asset → 3-4000 (board-designated subset)
```

This routing is applied by Fundara's `Journal Allocation Rule` engine, not
manually by users.

### 6. Bridging Fund Inter-Fund Postings

ERPNext does not natively support inter-fund postings on a single Journal Entry
with different fund dimensions per line. Implement as:
- Two GL Entry lines on the same Journal Entry document
- Each line has a different `fund` Accounting Dimension value
- Validate that the two fund-dimension lines net to zero on the balance sheet
  (the inter-fund receivable/payable nets out at the entity level)

### 7. Restriction Release Automation Trigger

A `Restriction Release Entry` custom DocType should:
1. Reference the source restricted fund and the amount to release
2. Require approval from Program Director (conditions met) + Finance Director
3. On submit, auto-create the Journal Entry (JE-17 pattern)
4. Update the fund's `restriction_status` if fully released

### 8. Depreciation Integration

ERPNext Asset module auto-generates depreciation Journal Entries from the
Depreciation Schedule. Ensure:
- The `cost_center` field on the Asset is propagated to the JE
- The `fund` dimension from the Asset's funding source is propagated to the JE
- Double-posting is guarded by checking `Journal Entry` linked to each schedule
  line before the run

---

*End of Fundara Journal Entry Rules Catalog*
