# Sprint Plan — Semar (Front End Developer)

**Role:** Front End Developer  
**Akun:** semar | GitHub: @pakde-semar  
**Dokumen ini:** rencana kerja Semar per sprint — client script per FG dan frontend track FE-01 s/d FE-06. Estimasi backend DocType ada di `complexity.md` (dikerjakan Petruk).  
**Last updated:** 2026-06-20

---

## Prinsip Penyusunan

1. **Sprint 1 = baca, bukan code** — Semar tidak mulai coding sebelum semua spec frontend dibaca dan environment lokal berjalan.
2. **Client script mengikuti backend** — setiap FG dikerjakan Semar segera setelah Petruk selesai DocType-nya. Jangan mendahului.
3. **FE-01, FE-02, FE-06 tersebar** — dikerjakan bersamaan dengan sprint aktif, bukan sprint terpisah.
4. **FE-04 dan FE-05 SKIP** — diputuskan post-MVP per D-07 Opsi C.

---

## Peta Tugas Frontend vs Prioritas

| Item | Estimasi | Sprint | Status |
|---|---|---|---|
| Local environment setup | — | Pre-Sprint | Wajib sebelum Sprint 1 |
| Baca semua spec frontend | — | Sprint 1 | Wajib sebelum coding |
| FE-02: Validation messages (Bahasa Indonesia) | ~5 hari | Tersebar Sprint 2–7 | MVP |
| Client Script FG-03: Fund | ~1.5 hari | Sprint 2 | MVP |
| FE-01: Status colors & `get_indicator` | ~5 hari | Tersebar Sprint 3–8 | MVP |
| Client Script FG-04: Project & Activity | ~2.0 hari | Sprint 3–4 | MVP |
| Client Script FG-05: Grant | ~1.5 hari | Sprint 3–5 | MVP |
| Client Script FG-06: Budget | ~1.0 hari | Sprint 3–4 | MVP |
| Client Script FG-07: Cash Receipt & Disbursement | ~1.0 hari | Sprint 5 | MVP |
| Client Script FG-08: Campaign & Donation | ~1.5 hari | Sprint 5 | MVP |
| FE-03: 21 Notification templates + scheduled jobs | ~8 hari | Sprint 5–8 | MVP |
| Client Script FG-09: Advance & Liquidation | ~2.5 hari | Sprint 6–7 | MVP |
| Client Script FG-10: Evidence | ~0.5 hari | Sprint 5–6 | MVP |
| Client Script Sprint 6–7 lainnya | ~2.5 hari | Sprint 6–7 | MVP |
| FE-06: Bahasa Indonesia labels & UI copy | ~3 hari | Tersebar Sprint 1–9 | MVP |
| UAT Milestone 1 (fasilitasi bersama PM) | 3 hari | Sprint 5 exit | MVP |
| UAT Milestone 2 (fasilitasi bersama PM) | 3 hari | Sprint 10 exit | MVP |
| **FE-04: 7 Print format Jinja2** | ~14 hari | **SKIP — post-MVP** | v0.2 |
| **FE-05: 7 Role-specific dashboards** | ~14 hari | **SKIP — post-MVP** | v0.2 |

---

## Pre-Sprint — Sebelum Sprint 1 Dimulai

**Tujuan:** Environment lokal berjalan di mesin Semar.

### Tugas

**P-A. Local environment setup**

Ikuti `docs/dev/local-setup.md` sepenuhnya. Versi yang wajib dipakai (dari `docs/infra/environment-spec.md`):

```
Python 3.12.x
Node.js 18.x LTS + npm + Yarn 1.22.x
MariaDB 10.11.x (charset utf8mb4)
Redis 7.x
wkhtmltopdf 0.12.6 patched Qt  ← VERSI INI SPESIFIK, versi lain merusak PDF
```

Jika pakai macOS: gunakan pyenv + nvm. Jika pakai Ubuntu: ikuti section Ubuntu di `local-setup.md`.

**P-B. Clone dan install**

```bash
bench init --frappe-branch version-16 fundara-bench
cd fundara-bench
bench get-app --branch version-16 erpnext
bench get-app fundara https://github.com/masmaksum/Fundara
bench new-site fundara-dev.local --install-app erpnext --install-app fundara
bench --site fundara-dev.local set-config developer_mode 1
```

**P-C. VS Code extensions**

Dari `local-setup.md` section IDE:
- Python (Pylance)
- Frappe Framework Intellisense
- ESLint
- Set `python.pythonPath` ke `fundara-bench/env/bin/python`

**Verifikasi:**

```
[ ] bench start berjalan tanpa error
[ ] http://fundara-dev.local:8000 bisa diakses
[ ] Fundara app terinstall
[ ] Developer mode aktif
```

---

## Sprint 1 (Minggu 1–2) — Baca Spec, Tidak Ada Coding

**Tujuan:** Semar memahami seluruh frontend spec sebelum mulai mengimplementasi apapun.

### Tugas

**1-A. Baca docs/dev/ (urutan wajib)**

```
1. docs/dev/local-setup.md          — setup (sudah dilakukan di pre-sprint)
2. docs/dev/dev-workflow.md         — lifecycle fitur dari story ke staging
3. docs/dev/frappe-cookbook.md      — resep client script siap pakai
4. docs/dev/git-branching.md        — konvensi branch dan commit
```

Konvensi commit Fundara:
```
[domain]: deskripsi singkat
Contoh: fe: tambah client script fund balance indicator
```
**TIDAK ada Co-Authored-By** — kebijakan audit trail proyek.

**1-B. Baca docs/spec/frontend/ (semua file)**

```
form-layout.md         — 1.496 baris, layout 21 DocType MVP. BACA SEMUA.
status-colors.md       — indicator color rules 14 DocType
validation-messages.md — 65+ rule validasi Bahasa Indonesia
notifications.md       — 21 template notifikasi, 5 scheduled job
print-formats.md       — SKIP baca detail (post-MVP), cukup overview
dashboard-spec.md      — SKIP baca detail (post-MVP), cukup overview
```

**1-C. Baca docs/spec/workflows.md dan docs/spec/permissions.md**

Semar perlu tahu state mana yang lock field apa, dan role mana yang bisa lihat apa, sebelum menulis client script.

**1-D. FE-06 batch pertama — label Sprint 1**

Mulai inventarisasi label Bahasa Indonesia untuk FG-01 dan FG-02 (Organization, Funding Source, Donor). Catat string yang perlu dikonfirmasi ke domain expert keuangan.

**Exit criteria Sprint 1:** Semar bisa menjawab: "Field apa yang lock saat Cash Advance status = Approved?" dan "Apa warna indicator Fund saat status Suspended?" tanpa buka spec.

---

## Sprint 2 (Minggu 3–4) — Client Script FG-03 + FE-02 Batch 1

**Tujuan:** Semar mulai coding. Fund DocType punya client script yang berfungsi.

### Tugas

**2-A. Client Script FG-03: Fund (~1.5 hari)**

Koordinasi dengan Petruk: kerjakan setelah `Fund` dan `Fund Allocation` DocType selesai di backend.

Fund — 5 `form.on()` handler:
1. Validasi currency saat `fund_type` berubah
2. Live balance update
3. Warning jika restriction_type berubah saat Fund Active
4. Conditional `grant` field mandatory (hanya jika `fund_type == "Grant Fund"`)
5. Lock semua field saat status `Closing` atau `Closed`

Fund — 2 custom button:
- "Lihat Alokasi"
- "Ajukan Pembatasan"

Fund Allocation — 4 handler + 1 button:
- Live available-balance indicator via `frappe.call`
- Lock saat status Approved
- Restriction warning jika fund restricted
- Recompute total dari items
- Button: (sesuai spec)

Referensi pattern: `docs/dev/frappe-cookbook.md` section "Client Script".

**2-B. FE-02: Validation messages batch 1 (~0.5 hari)**

Dari `docs/spec/frontend/validation-messages.md`:
- VA-FUND-01 s/d VA-FUND-xx (semua rule untuk Fund DocType)
- Bahasa Indonesia, gunakan `frappe.throw()` untuk error, `frappe.msgprint()` untuk warning

**2-C. FE-06: Label batch 2 — FG-03**

Verifikasi semua label Bahasa Indonesia di Fund form sesuai `form-layout.md`.

**Exit criteria Sprint 2:** Fund DocType di local Semar punya semua client script berfungsi dan bisa demo live balance update.

---

## Sprint 3–4 (Minggu 5–8) — Client Script FG-04, FG-05, FG-06 + FE-01 Mulai

**Tujuan:** Project, Activity, Grant, dan Budget punya client script. Status colors mulai diimplementasi.

### Tugas

**3-A. Client Script FG-04: Project & Activity (~2.0 hari)**

Project — 3 handler + 3 button:
- Fund allocation total auto-compute dari child table
- Close-blocking check via `frappe.call` sebelum state transition
- Lock budget saat status Completed
- Button: "Lihat Advance", "Tambah Fund Alokasi", "Tutup Proyek" (konfirmasi dialog)

Activity — 4 handler + 2 button:
- Auto-fetch project + fund dari selection
- Date overlap validation
- Close-blocking jika ada advance terbuka
- Lock saat non-editable state
- Button: "Buat Advance" (enabled hanya saat Approved/In Progress), "Tandai Selesai"

**3-B. Client Script FG-05: Grant (~1.5 hari)**

Grant — 4 handler + 3 button:
- Status-locked field read-only enforcement
- Multi-currency conversion display preview
- Sidebar link ke Fund/Agreement
- Conditional mandatory fields per `grant_type`
- Button: "Ajukan ke Donor", "Buka Perjanjian Grant", "Tutup Grant" (validasi Closeout Checklist via `frappe.call`)

Grant Budget Line:
- Live utilization percentage, visual warning merah saat > 80%

**3-C. Client Script FG-06: Budget (~1.0 hari)**

Fund Budget:
- Lock semua field saat status Approved/Active
- Button "Revisi Budget" (hanya muncul saat Active, buka dialog + buat Budget Revision)

Budget Revision:
- Auto-sum `revised_total` dari revision lines setiap child table berubah

**3-D. FE-01: Status colors batch 1 (~1.5 hari)**

Dari `docs/spec/frontend/status-colors.md`:

Sprint 3–4 scope: FG-03, FG-04, FG-06 (Fund, Project, Activity, Fund Budget)
- `get_indicator` Python hook per DocType di `fundara/hooks.py`
- Listview highlight CSS untuk DocType yang ada di spec

Contoh pattern (dari frappe-cookbook.md):
```python
# hooks.py
doc_events = {
    "Fund": {
        "get_indicator": "fundara.fund.doctype.fund.fund.get_indicator"
    }
}
```

**3-E. FE-02: Validation messages batch 2 (~1.0 hari)**

VA rules untuk FG-04 (Project, Activity) dan FG-06 (Fund Budget).

**Exit criteria Sprint 3–4:** Project bisa di-close dengan blocking check. Grant punya closeout validation. Status colors Fund dan Project tampil di listview.

---

## Sprint 5 (Minggu 9–10) — Client Script FG-07, FG-08, FG-10 + FE-03 Mulai

**Tujuan:** Transaksi kas punya client script. Notifikasi batch pertama live.

### Tugas

**5-A. Client Script FG-07: Cash Receipt & Disbursement (~1.0 hari)**

Cash Disbursement:
- Budget availability badge via `frappe.call('fundara.api.get_budget_status')` — hijau/kuning/merah
- Auto-fetch fund/project/activity dari Cost Center selection
- Conditional field visibility berdasarkan `disbursement_type`

Cash Receipt:
- Fetch currency + exchange_rate dari linked Campaign atau Fund
- Conditional field visibility (campaign-linked vs standalone)

**5-B. Client Script FG-08: Campaign & Donation (~1.5 hari)**

Fundraising Campaign:
- Dynamic progress bar (`total_received / goal_amount`) sebagai custom HTML di form header
- Button: "Aktifkan Campaign", "Tutup Campaign" (konfirmasi dialog)

Donation — 5 handler + 1 button:
- Anonymous mode: clear `donor` field + warning "Donasi anonim: nama donor tidak akan disimpan"
- Auto-fetch fund dari Campaign
- Blacklist check via `frappe.call` sebelum submit
- `amount_base` auto-compute dari `currency × exchange_rate`
- Lock saat Approved
- Button: "Buat Kuitansi"

**5-C. Client Script FG-10: Evidence (~0.5 hari)**

- Dynamic Link auto-populate `linked_document_name` dari `linked_document_type`
- Visual severity indicator (ikon merah/kuning/biru berdasarkan `blocking_severity`) via `frm.set_intro()`

**5-D. FE-03: Notifikasi — batch 1 (~3 hari)**

Dari `docs/spec/frontend/notifications.md`:

Sprint 5 scope: NOTIF-01 s/d NOTIF-10 (notifikasi Cash Advance, Fund Allocation, Project)
- Buat Frappe Notification DocType per template
- Subject + body Bahasa Indonesia dengan variabel `{{}}`
- In-app message ≤ 100 karakter
- Channel: In-app / Email / Both sesuai spec
- Tambahkan `scheduler_events` di `hooks.py` untuk scheduled notifications

SMTP harus sudah dikonfigurasi Gareng di staging sebelum FE-03 bisa ditest.

**5-E. FE-02: Validation messages batch 3 (~1.0 hari)**

VA rules untuk FG-07 dan FG-08.

**5-F. FE-01: Status colors batch 2 (~1.0 hari)**

FG-07, FG-08, FG-10 (Cash Receipt, Cash Disbursement, Campaign, Donation, Evidence).

**5-G. UAT Milestone 1 (Sprint 5 exit)**

Fasilitasi bersama PM (Bagong). Semar hadir seluruh sesi UAT:
- Tangani bug UI yang muncul saat sesi
- Catat feedback UX dari staf NGO pilot
- Post-UAT: update bug ke backlog Sprint 6

**Exit criteria Sprint 5:** Semua transaksi kas punya client script berfungsi. 10 notifikasi pertama live di staging. UAT Milestone 1 selesai.

---

## Sprint 6–7 (Minggu 11–14) — Client Script FG-09 + FE-03 Selesai

**Tujuan:** Cash Advance — client script terumit selesai. Semua notifikasi live.

### Tugas

**6-A. Client Script FG-09: Advance & Liquidation (~2.5 hari)**

**Ini adalah client script terumit di seluruh MVP.**

Cash Advance:
1. D-02 budget banner "Budget Tersedia: Rp X" via `frappe.call('fundara.api.get_available_budget')` — server call setiap kali `fund` atau `activity` berubah, bukan computed field statik
2. Color-coded live bar via `frm.set_intro()`:
   - Hijau: utilization < 70%
   - Kuning: 70–90%
   - Merah: > 90%
3. 11 workflow state: lock/unlock behavior berbeda per state per field. Gunakan `frm.set_df_property('fieldname', 'read_only', true/false)` per state transition
4. `pending_payment_flag` warning banner
5. Button "Bayar Advance" + "Batalkan Pembayaran" — masing-masing dengan konfirmasi dialog dan server validation

Advance Liquidation:
- Auto-compute `refund_amount` vs `reimbursement_amount` dari `total_expense_amount` vs `advance_amount` setiap child table berubah
- Color-coded settlement summary bar di form footer:
  - "Lebih: Rp X — perlu dikembalikan" (hijau)
  - "Kurang: Rp X — perlu reimbursement" (merah)

**6-B. Client Script Sprint 6–7 lainnya (~2.5 hari)**

- Fund Transfer: same-fund check + restricted warning
- Purchase Request: budget badge + threshold indicator
- Purchase Order: vendor check + total auto-compute
- Field Report: `verified_by ≠ submitted_by` validation
- Workplan: sesuai spec

**6-C. FE-03: Notifikasi — batch 2 selesai (~3 hari)**

Sprint 6–7 scope: NOTIF-11 s/d NOTIF-21
- Termasuk NOTIF-14 dengan duplicate-prevention flag logic (field `notif_sent_flag` di DocType)
- 5 scheduled job di `hooks.py`:

```python
scheduler_events = {
    "daily": [
        "fundara.notifications.check_overdue_advances",
        "fundara.notifications.check_grant_deadlines",
        ...
    ]
}
```

**6-D. FE-02: Validation messages batch 4 — FG-09 (~1.0 hari)**

D-02 section khusus: VA-ADV-13, VA-ADV-14, VA-ADV-15
- VA-ADV-13: banner saat status = Approved tapi belum Paid
- VA-ADV-14: warning jika liquidation_due_date < hari ini
- VA-ADV-15: error jika mencoba submit liquidation saat advance belum Paid

**6-E. FE-01: Status colors batch 3 (~1.5 hari)**

FG-09 (Cash Advance 11 state), FG-05 (Grant 11 state). Ini yang paling banyak state.

**Exit criteria Sprint 6–7:** Cash Advance D-02 banner berfungsi live. Semua 21 notifikasi terdaftar di Frappe. Status colors lengkap untuk semua DocType MVP.

---

## Sprint 8 (Minggu 15–16) — FE-01 Selesai + FE-03 Tuning

**Tujuan:** Semua status colors selesai. Notifikasi diverifikasi di staging.

### Tugas

**8-A. FE-01: Status colors batch 4 — selesai (~1.0 hari)**

FG-12 (Bank Reconciliation), FG-15 (Data Health Check), sisa DocType yang belum done.

**8-B. FE-03: Verifikasi notifikasi di staging**

- Test kirim tiap notifikasi manual
- Verifikasi in-app message ≤ 100 karakter
- Verifikasi dedup logic NOTIF-14
- Verifikasi scheduled job berjalan via `bench scheduler logs`

**8-C. FE-02: Validation messages batch 5 — FG-12, FG-15 (~0.5 hari)**

**Exit criteria Sprint 8:** Semua 13 DocType punya status color. Semua 21 notifikasi terverifikasi di staging.

---

## Sprint 9 (Minggu 17–18) — FE-06 Final + Support Reporting

**Tujuan:** Semua label Bahasa Indonesia final. Support Petruk untuk FG-15 reports.

### Tugas

**9-A. FE-06: Bahasa Indonesia labels — final sweep (~1.5 hari)**

Review semua form labels, button text, dialog messages, dan banner text di seluruh 15 FG. Konfirmasi terminologi ke domain expert keuangan (FE role) dan program (PE role).

Checklist per DocType:
```
[ ] Semua field label Bahasa Indonesia sesuai form-layout.md
[ ] Button text sesuai spec
[ ] Error/warning message sesuai validation-messages.md
[ ] In-app notification sesuai notifications.md
```

**9-B. Support Petruk: FG-15 report UI**

Petruk mengerjakan Script Reports — Semar support untuk:
- Filter UI layout di setiap report
- Column header label Bahasa Indonesia
- Chart type configuration di Basic Dashboard

**Exit criteria Sprint 9:** Seluruh UI copy Bahasa Indonesia final. Tidak ada label Inggris yang tersisa di form MVP.

---

## Sprint 10 (Minggu 19–20) — Hardening + UAT Milestone 2

**Tujuan:** Semua client script diverifikasi di staging. UAT final. Go-live ready.

### Tugas

**10-A. Regression UI checklist**

Dari `docs/qa/regression-checklist.md`:
- Verifikasi `depends_on` (grant field, donor_name field) di semua form yang relevan
- Verifikasi D-02 banner tampil di Cash Advance saat status Approved
- Verifikasi post-submit lock (`docstatus == 1`) di semua submit-able DocType
- Verifikasi fund_type trigger di Fund form

**10-B. Fix bug UI dari Sprint 9**

**10-C. UAT Milestone 2 (Sprint 10 exit)**

Fasilitasi bersama PM. Semar standby seluruh sesi:
- Observasi UX dari staf NGO
- Tangani bug UI yang muncul
- Post-UAT: prioritaskan fix berdasarkan severity matrix

**Exit criteria Sprint 10:** Seluruh regression checklist UI hijau. UAT Milestone 2 selesai. Go/no-go decision bisa diambil.

---

## Yang Dilewati Sekarang (Post-MVP per D-07 Opsi C)

| Item | Alasan Skip | Target |
|---|---|---|
| FE-04: 7 Print format Jinja2 (~14 hari) | Tidak memblokir UAT; staf bisa pakai cetak standar Frappe sementara | v0.2 |
| FE-05: 7 Role-specific dashboards (~14 hari) | Dashboard detail butuh data historis; lebih baik post go-live. Gap estimasi 8 hari vs FG-15 | v0.2 |

Catatan: FG-15 Basic Dashboard (8 number cards, 4 charts) tetap masuk MVP — dikerjakan Petruk di Sprint 9. Yang skip adalah 7 role-specific dashboard dari `dashboard-spec.md`.

---

## Ringkasan Timeline Semar

```
Pre-Sprint      → Local setup + bench + Fundara running
Sprint 1        → Baca semua spec, tidak ada coding, FE-06 batch 1
Sprint 2        → Client script FG-03 (Fund), FE-02 batch 1
Sprint 3–4      → Client script FG-04/05/06, FE-01 batch 1, FE-02 batch 2
Sprint 5        → Client script FG-07/08/10, FE-03 batch 1, UAT Milestone 1
Sprint 6–7      → Client script FG-09 (TERUMIT), FE-03 selesai, FE-01 batch 3
Sprint 8        → FE-01 selesai, FE-03 verifikasi staging
Sprint 9        → FE-06 final sweep, support FG-15 report UI
Sprint 10       → Regression checklist UI, bug fix, UAT Milestone 2
```

**Total estimasi Semar:** ~27 hari (13 hari FE-01/02/03/06 + 14 hari client script) — tersebar 10 sprint paralel dengan backend Petruk.

---

## Dokumen Referensi Utama Semar

| Dokumen | Kapan Dibaca |
|---|---|
| `docs/dev/local-setup.md` | Pre-Sprint |
| `docs/dev/dev-workflow.md` | Sprint 1 |
| `docs/dev/frappe-cookbook.md` | Sprint 1, lalu rujukan saat coding |
| `docs/dev/git-branching.md` | Sprint 1 |
| `docs/spec/frontend/form-layout.md` | Sprint 1 (wajib semua 1.496 baris) |
| `docs/spec/frontend/status-colors.md` | Sprint 1 |
| `docs/spec/frontend/validation-messages.md` | Sprint 1 |
| `docs/spec/frontend/notifications.md` | Sprint 1 |
| `docs/spec/workflows.md` | Sprint 1 — perlu paham state machine |
| `docs/spec/permissions.md` | Sprint 1 — perlu paham role visibility |
