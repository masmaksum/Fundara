# Sprint Plan — Petruk (Backend Developer)

**Role:** Backend Developer  
**Akun:** petruk  
**GitHub:** @petruk-droid  
**Dokumen ini:** rencana kerja Petruk per sprint, diekstrak dari complexity.md (Dev 1 track) dan dependency-map.md.  
**Last updated:** 2026-06-20

---

## Prinsip Penyusunan

1. **Baca sebelum coding** — D-01, D-02, dan dependency-map.md wajib dibaca sebelum Sprint 1 dimulai.
2. **Urutan layer tidak bisa dibalik** — DocType di Layer N tidak bisa dibangun sebelum Layer N-1 selesai.
3. **GL posting pertama ada di Sprint 5** — jangan sentuh ERPNext accounting engine sebelum Chart of Accounts dan Fund sudah stabil.
4. **D-02 adalah invariant** — setiap DocType yang menyentuh budget atau advance harus enforce: `Available = Approved − Actual (paid only)`.
5. **Tidak ada Co-Authored-By di commit** — kebijakan audit trail proyek.

---

## Bacaan Wajib (Sebelum Sprint 1)

| Dokumen | Lokasi | Mengapa Wajib |
|---|---|---|
| D-01 dan D-02 | `DECISIONS.md` | Menentukan arsitektur Grant dan formula budget — salah baca = salah implementasi |
| Dependency Map | `docs/pm/dependency-map.md` | Build order Layer 0–5; jangan skip layer |
| Local Setup | `docs/dev/local-setup.md` | Setup bench lokal dari nol |
| Dev Workflow | `docs/dev/dev-workflow.md` | Cara buat DocType, server script, GL hook, unit test, PR |
| Frappe Cookbook | `docs/dev/frappe-cookbook.md` | Resep copy-paste: `get_doc`, `make_gl_entries`, `frappe.db.sql` parameterized |
| Git Branching | `docs/dev/git-branching.md` | Format commit, branch convention, PR template |
| Journal Entry Rules | `docs/accounting/journal-entries.md` | 28 aturan GL posting (JE-01 s/d JE-27) — wajib sebelum Sprint 5 |
| RBAC Permissions | `docs/spec/permissions.md` | Matriks 13 role × 30+ DocType — wajib sebelum Sprint 1 |

---

## Sprint 0 — Minggu 0 (Persiapan, Sebelum Sprint 1)

**Tujuan:** Environment lokal siap. Semua bacaan wajib selesai.

### Tugas

**0-A. Setup bench lokal**

Ikuti `docs/dev/local-setup.md` dari awal sampai akhir. Target: bench jalan dalam 60 menit.

```bash
bench init --frappe-branch version-16 fundara-bench
cd fundara-bench
bench get-app --branch version-16 erpnext
bench get-app fundara https://github.com/masmaksum/Fundara
bench new-site fundara-petruk.local --install-app erpnext --install-app fundara
bench --site fundara-petruk.local set-config developer_mode 1
bench start
```

**0-B. Baca dokumen wajib**

Urutan baca yang direkomendasikan:
1. `DECISIONS.md` — D-01 dan D-02 dulu
2. `docs/pm/dependency-map.md`
3. `docs/accounting/journal-entries.md`
4. `docs/dev/dev-workflow.md` + `frappe-cookbook.md`
5. `docs/spec/permissions.md`

**0-C. Setup VS Code**

Dari `docs/dev/local-setup.md` section IDE:
- Extension: Pylance, Python, ESLint
- `extraPaths` di settings.json untuk Frappe virtualenv

**Exit criteria Sprint 0:** `bench start` jalan, bisa login, baca semua doc wajib, bisa buat DocType kosong dan export JSON-nya.

---

## Sprint 1 (Minggu 1–2) — Layer 0 + Layer 1 Foundation

**Tujuan:** ERPNext terkonfigurasi. Organization dan Funding masters selesai. Basis untuk semua sprint berikutnya.

### Tugas

**1-A. ERPNext Layer 0 — Configure Only, Bukan Custom Dev**

Referensi: `docs/pm/dependency-map.md` section Layer 0

```
[ ] Company: satu company, base currency IDR
[ ] Chart of Accounts: import template nonprofit Fundara
[ ] Fiscal Year: tahun berjalan
[ ] Currency: IDR (default), USD, EUR
[ ] Cost Center: hirarki organisasi (HQ, kantor cabang, departemen)
[ ] Bank Account: minimal satu akun bank
[ ] Location: minimal satu lokasi
[ ] ERPNext Roles: 7 role MVP (Finance Manager, Finance Officer, Program Manager,
    Project Officer, Executive Viewer, Auditor Viewer, System Manager)
```

**1-B. FG-01: Organization Setup (5 hari)**

DocType yang dibuat:
- Organization
- Office
- Department (Custom Fields di ERPNext built-in)
- Cost Center Extension (Custom Fields, bukan DocType baru)
- Delegation of Authority + child table

Hal yang perlu diperhatikan:
- Custom Fields di ERPNext built-in jangan sampai break core behavior
- Delegation of Authority punya workflow approval + validasi `valid_from`/`valid_to`
- Role setup (7 MVP roles) dan workspace config: +0.5 hari

**1-C. FG-02: Funding Source & Donor Masters (5 hari) — paralel jika memungkinkan**

DocType yang dibuat:
- Funding Source
- Donor + Institutional Donor Profile
- Donor Contact Item (child table)
- Business Unit
- Revenue Stream

Hal yang perlu diperhatikan:
- Donor punya status lifecycle (Prospect → Active → Lapsed → Blacklisted) yang mempengaruhi validasi di dokumen downstream
- Funding Source punya conditional logic per `source_type` — flagging untuk Semar (client script)

**Exit criteria Sprint 1:** Organization bisa dibuat. Funding Source dan Donor bisa dibuat. 7 role terdaftar. Cost Center bisa dipakai di transaksi.

---

## Sprint 2 (Minggu 3–4) — Fund Core

**Tujuan:** Fund DocType selesai dan stabil. Ini titik paling kritis — semua Sprint 3–9 bergantung padanya.

### Tugas

**2-A. FG-03: Fund Master & Fund Type (10 hari)**

DocType yang dibuat:
- Fund Type (dengan fixture data 8 tipe MVP)
- Fund (lifecycle 5 state: Draft → Active → Suspended → Closing → Closed)
- Fund Restriction + workflow approval

Hal yang perlu diperhatikan:
- Field `grant` conditionally mandatory — hanya jika `fund_type = Grant Fund` (D-01)
- Restriction type change pada Fund Active butuh approval workflow + audit log
- Multi-currency: `opening_balance_base = opening_balance × exchange_rate` auto-compute on save
- Fund Restriction: hanya satu restriction aktif per Fund (server-side check)
- Fixture data Fund Type harus di-seed dengan benar sebelum site bisa dipakai

**2-B. Config masters tambahan (2 hari)**

- Accounting Standard Profile
- Net Asset Class
- Program DocType (simple, no dependencies)
- Activity Type (fixture data, no dependencies)

**2-C. Demo data awal**

Buat satu Funding Source dan satu Fund (status Active) untuk validasi sprint selanjutnya.

**Exit criteria Sprint 2:** Fund bisa dibuat dari Funding Source dan transisi ke Active. Fund Restriction bisa di-attach dengan approval.

---

## Sprint 3–4 (Minggu 5–8) — Project, Budget & Activity

**Tujuan:** Struktur project dan budget selesai. Activity bisa masuk status Approved (syarat untuk Cash Advance di Sprint 6).

### Tugas

**Sprint 3:**

**3-A. FG-04: Program, Project & Activity (10 hari)**

DocType yang dibuat:
- Project + Project Fund Allocation child table (workflow 6 state)
- Activity (workflow 7 state: Planned → Approved → In Progress → Completed → Reported → Verified → Closed)

Hal yang perlu diperhatikan:
- Activity tidak bisa di-close jika ada open Cash Advance (cross-DocType check — akan di-wire di Sprint 6)
- Project tidak bisa di-close jika ada Activity non-terminal atau open advances
- Project Fund Allocation: `total_budget` auto-sum dari child rows
- Multi-currency pada Project Fund Allocation

**3-B. FG-06: Budget Layer (10 hari)**

DocType yang dibuat:
- Fund Budget + Fund Budget Line child table (workflow 8 state)
- Budget Revision + Budget Revision Line child table
- Fund Allocation (workflow 6 state)

Hal yang perlu diperhatikan:
- Fund Budget tidak bisa di-edit langsung setelah Approved/Active — harus via Budget Revision
- Budget Revision update `revised_amount` di Fund Budget Lines saat approval (cross-document write)
- D-02: `total_actual_amount` di Fund Budget hanya increment saat Cash Advance Paid atau Purchase Invoice posted — hook ini di-wire sepenuhnya di Sprint 5–6
- Fund Allocation: cek `available_balance` Fund sebelum approval

**Sprint 4:**

**4-A. FG-13: Opening Balance Assistant (5 hari)**

DocType yang dibuat:
- Opening Balance Assistant
- Opening Balance Line child table

Hal yang perlu diperhatikan:
- Balancing check: `total_debit == total_credit` sebelum submit
- Satu Opening Balance Assistant per fiscal year (duplicate check server-side)
- GL posting on submit: Journal Entry dengan `journal_type = Opening Balance`
- Multi-currency per line

**Exit criteria Sprint 3–4:** Project bisa dibuat dan linked ke Fund. Budget Line bisa di-approve. Activity bisa masuk status Approved. Opening Balance bisa di-submit dengan GL Entry terbentuk.

---

## Sprint 5 (Minggu 9–10) — GL Posting Pertama

**Tujuan:** Transaksi kas pertama terbentuk GL Entry yang benar. Ini milestone kritis — ERPNext accounting engine pertama kali disentuh.

**Wajib baca sebelum Sprint 5:** `docs/accounting/journal-entries.md` — 28 aturan GL posting.

### Tugas

**5-A. FG-07: Cash Receipt & Cash Disbursement (10 hari)**

DocType yang dibuat:
- Cash Receipt (GL: Dr Bank / Cr Pendapatan)
- Cash Disbursement (GL: Dr Beban / Cr Bank)

Hal yang perlu diperhatikan:
- Ini DocType pertama yang menyentuh ERPNext GL engine — validasi akurasi GL Entry dengan teliti
- `on_submit` hook wajib membuat Journal Entry di ERPNext dengan akun, amount, dan fund dimension yang benar
- Budget check pada Cash Disbursement: query Fund Budget Line saat submit (D-02)
- Multi-currency: jika bank account dalam USD, hitung `amount` dan `amount_base` (IDR) dengan benar
- Field `evidence_status` dibuat sekarang — logic-nya di-wire di Sprint 6 (FG-10)
- `reconciliation_status` dibuat sekarang — di-wire di Sprint 8 (FG-12)

**5-B. FG-14: General Journal (5 hari)**

DocType yang dibuat:
- General Journal + General Journal Line child table

Hal yang perlu diperhatikan:
- Multi-line, multi-akun — pattern serupa Cash Receipt/Disbursement tapi lebih fleksibel
- `total_debit == total_credit` check sebelum posting
- Fund dimension mandatory pada journal line yang menyentuh fund-restricted accounts
- Posted journals tidak bisa di-edit — reversal via Correction journal

**Exit criteria Sprint 5:** Cash bisa diterima ke fund dengan GL Entry terbentuk. Cash bisa dikeluarkan dari fund dengan budget check dan GL Entry. General Journal bisa di-post. *First working end-to-end demo bisa dilakukan di akhir Sprint 5.*

---

## Sprint 6–7 (Minggu 11–14) — Advance & Liquidation

**Tujuan:** Workflow advance-to-liquidation selesai end-to-end. Ini feature group paling kompleks di seluruh MVP.

### Tugas

**6-A. FG-09: Cash Advance & Advance Liquidation (16 hari — spans Sprint 6 dan 7)**

DocType yang dibuat:
- Cash Advance (workflow 11 state: Draft → Submitted → Under Review → Approved → Paid → Pending Liquidation → Overdue → Liquidated → Closed, + Rejected dan Cancelled)
- Advance Liquidation + Expense Line child table
- Additional Advance Payment
- Reimbursement Request

Hal yang perlu diperhatikan (ordered by complexity):

1. **D-02 enforcement** — `Cash Advance.paid_amount` trigger update ke `Fund Budget Line.actual_amount`. Harus diuji agar tidak double-count saat Additional Advance Payment:
   ```python
   # Benar:
   Available = Approved Budget − Actual (paid_amount only)
   # Salah: jangan hitung advance_amount yang belum dibayar
   ```

2. **Overdue auto-transition** — scheduled job via `hooks.py scheduler_events`:
   ```python
   scheduler_events = {
       "daily": ["fundara.tasks.mark_overdue_advances"]
   }
   ```
   Harus ditest di instance yang berjalan dengan manipulasi tanggal.

3. **Settlement logic** — Advance Liquidation hitung:
   - `refund_amount = advance_amount − total_expense` (jika advance > expense)
   - `reimbursement_amount = total_expense − advance_amount` (jika expense > advance)
   Masing-masing punya GL posting berbeda.

4. **Cancellation setelah Paid** — tidak bisa cancel langsung, perlu reversal process.

5. **Advance Liquidation inherit dimensions** — `fund`, `project`, `activity` dari Cash Advance sebagai read-only.

**6-B. FG-10: Evidence & Compliance — wire logic (2 hari)**

Wire `evidence_status` di Cash Disbursement (FG-07) berdasarkan Evidence Requirement rules. DocType Evidence sendiri dibuat oleh Dev 2 (koordinasi dengan Semar).

**Exit criteria Sprint 6–7:** Staff bisa ajukan advance, dapat approval dan pembayaran, submit liquidasi dengan bukti, advance closed. D-02: budget baru berkurang saat Paid, bukan saat Approved.

---

## Sprint 8 (Minggu 15–16) — Bank Reconciliation

**Tujuan:** Bank statement bisa diimpor dan direkonsiliasi.

### Tugas

**8-A. FG-12: Bank Statement Import & Bank Reconciliation (10 hari)**

DocType yang dibuat:
- Bank Statement Import + Bank Statement Line child table
- Bank Reconciliation

Hal yang perlu diperhatikan:
- CSV/XLSX parsing: error handling untuk duplikat, format invalid, missing reference number
- Auto-matching: Exact Match / Probable Match / Partial Match — edge cases butuh waktu
- Formula: `adjusted_bank_balance = closing_balance_per_bank + outstanding_deposits − outstanding_payments`
- Rekonsiliasi period bisa di-close hanya jika difference = 0.00
- Reconciled transactions tidak bisa di-modifikasi tanpa reversal entry — guard di Cash Disbursement dan Cash Receipt
- Update `reconciliation_status` di Cash Disbursement (cross-DocType write)

**Exit criteria Sprint 8:** Bank statement CSV bisa diimpor, auto-matched, dan reconciliation period bisa di-close.

---

## Sprint 9 (Minggu 17–18) — Reports

**Tujuan:** Semua 6 laporan MVP functional dan bisa ekspor XLSX/PDF.

### Tugas

**9-A. FG-15: Fund Utilization Report (4 hari)**

Script Report yang aggregate: Cash Receipt, Cash Disbursement, Cash Advance (paid only — D-02), General Journal, Fund Transfer. Multi-currency ke IDR harus konsisten.

**9-B. FG-15: Budget vs Actual Report (2 hari)**

Approved budget vs actual paid, per budget line.

**9-C. FG-15: Advance Aging Report (3 hari)**

Open advances per staff/fund/project, aging buckets: 0–7 hari, 8–14 hari, 15–30 hari, >30 hari, Overdue. Compute dari `payment_date`.

**9-D. FG-15: Project Expense Report + Cash/Bank Transaction Report (3 hari)**

Paralel dengan laporan di atas.

**9-E. FG-15: Evidence Completeness Report (4 hari)**

JOIN Evidence Requirement rules terhadap semua transaction DocType — query multi-DocType, cukup kompleks.

**Exit criteria Sprint 9:** Semua 6 laporan berjalan dan bisa ekspor. Dashboard dasar menampilkan fund balance, budget vs actual, advance aging.

---

## Sprint 10 (Minggu 19–20) — Hardening & Go-live

**Tujuan:** MVP stable, security clean, demo dataset ready.

### Tugas

**10-A. Bug fixes dari Sprint 9 testing (5 hari)**

**10-B. Demo dataset (3 hari)**

Berdasarkan `docs/qa/demo-data.md` — YPN (Yayasan Peduli Nusantara):
- 1 company, 2 grant aktif (USAID USD, EU EUR), 5 fund
- 6 cash advance dalam state berbeda (termasuk satu Approved-belum-Paid untuk demo D-02)

**10-C. Security audit teknis (2 hari)**

```bash
# Grep seluruh custom app untuk ignore_permissions
grep -r "ignore_permissions" apps/fundara/ --include="*.py"
# Hasil wajib: 0 baris di production code

# Grep untuk SQL string concat
grep -r "frappe.db.sql" apps/fundara/ --include="*.py"
# Setiap hit wajib pakai parameter tuple, bukan f-string atau %s concat

# Grep untuk whitelist tanpa permission check
grep -r "@frappe.whitelist" apps/fundara/ --include="*.py"
# Setiap hit wajib ada frappe.has_permission() di bawahnya
```

**10-D. developer_mode off check**

```bash
bench --site [site] set-config developer_mode 0
```

**Exit criteria Sprint 10:** Semua DoD MVP terpenuhi. Demo dataset load bersih. Security audit bersih.

---

## Aturan Coding yang Wajib Diterapkan Sejak Sprint 1

| Aturan | Contoh Benar | Contoh Salah |
|---|---|---|
| SQL parameterized | `frappe.db.sql("SELECT * FROM tabFund WHERE name = %s", (name,))` | `frappe.db.sql(f"SELECT * FROM tabFund WHERE name = '{name}'")` |
| Whitelist + permission | `@frappe.whitelist()` diikuti `frappe.has_permission(...)` | `@frappe.whitelist()` tanpa permission check |
| Tidak ada ignore_permissions | — | `frappe.flags.ignore_permissions = True` |
| Commit format | `fund: tambah validasi restriction type` | `fix stuff` |
| Tidak ada Co-Authored-By | — | `Co-Authored-By: ...` |

---

## Hard Sequencing — Tidak Bisa Dibalik

```
Layer 0 (ERPNext config)
  └── Layer 1 (Organization, Donor, Fund Type, Program)   → Sprint 1
        └── FG-03 Fund Master                             → Sprint 2
              └── FG-04 Project + FG-06 Budget            → Sprint 3–4
                    └── FG-07 Cash Disbursement           → Sprint 5 ← GL engine pertama
                          └── FG-09 Cash Advance          → Sprint 6–7 ← paling kompleks
                                └── FG-12 Bank Rec        → Sprint 8
                                      └── FG-15 Reports   → Sprint 9
```

---

## Koordinasi dengan Semar (Frontend)

Semar mengerjakan Client Script segera setelah DocType backend selesai. Petruk wajib:

| Setelah selesai... | Notify Semar untuk... |
|---|---|
| FG-02 Funding Source | Client script conditional field per `source_type` |
| FG-03 Fund | 5 form handler + 2 custom button |
| FG-04 Project + Activity | Close-blocking check via `frappe.call` |
| FG-07 Cash Disbursement | Budget badge via `frappe.call('fundara.api.get_budget_status')` |
| FG-09 Cash Advance | D-02 banner + color bar + 2 custom button (paling berat) |

API method yang dibutuhkan Semar dari Petruk:
```python
@frappe.whitelist()
def get_available_budget(fund, activity):
    # returns: { available: float, utilization_pct: float }

@frappe.whitelist()
def get_budget_status(fund, budget_line):
    # returns: { status: "green"|"yellow"|"red", available: float }
```

Buat API ini **sebelum** Semar butuh — jangan tunggu Semar minta.

---

## Ringkasan Timeline

```
Minggu 0       → Sprint 0: Setup lokal + baca semua doc wajib
Minggu 1–2     → Sprint 1: Layer 0 ERPNext config + FG-01 Organization + FG-02 Donor
Minggu 3–4     → Sprint 2: FG-03 Fund Master (paling kritis)
Minggu 5–8     → Sprint 3–4: FG-04 Project + FG-06 Budget + FG-13 Opening Balance
Minggu 9–10    → Sprint 5: FG-07 Cash (GL pertama) + FG-14 Journal → DEMO
Minggu 11–14   → Sprint 6–7: FG-09 Advance & Liquidation (paling kompleks)
Minggu 15–16   → Sprint 8: FG-12 Bank Reconciliation
Minggu 17–18   → Sprint 9: FG-15 Reports
Minggu 19–20   → Sprint 10: Hardening + demo dataset + go-live
```
