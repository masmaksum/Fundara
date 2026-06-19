# Fundara MVP — Test Plan

**Project:** Fundara — Fund-centric ERP for Mission-driven Organizations
**Platform:** ERPNext v16 / Frappe Framework
**Document owner:** QA Lead
**Last updated:** 2026-06-19
**Version:** 1.0

**Audience:** QA Engineer, Tech Lead, Project Manager

This document is the master testing strategy for the Fundara MVP. It defines WHAT is tested, WHEN, by WHO, and what the acceptance criteria are before any release gate is passed.

---

## 1. Scope dan Tujuan

### 1.1 In Scope

This test plan covers the following:

| Area | Detail |
|---|---|
| Fundara custom app | 10 bounded contexts (Fund Stewardship, Grant Management, Cash Advance & Liquidation, Procurement, Budget Layer, Financial Accountability, Reporting, Evidence & Compliance, Organization Setup, Impact & Learning) |
| ERPNext v16 integration | GL posting hooks (`on_submit` / `on_cancel`), Frappe Workflow engine, Frappe permission engine |
| Multi-currency calculations | Decision D-04: `amount_in_base_currency = amount × exchange_rate` on every transaction DocType; currency-aware fund balance display; historical-rate reporting |
| D-02 budget formula compliance | Available Budget = Approved Budget − Actual (paid only). Approved-but-unpaid advances and purchase orders must NOT reduce available budget |
| ISAK 35 accounting output | Laporan Aktivitas restricted/unrestricted column split, Pelepasan Pembatasan entries, beban classification |
| Role-based access control | 13 roles (7 MVP roles + 6 extended): read/write/submit/cancel/delete permissions per DocType per role |

### 1.2 Out of Scope

The following are explicitly NOT covered by this test plan:

- **ERPNext core functionality** — Accounts Payable, Payroll, CRM, and other standard ERPNext modules are tested by upstream Frappe CI. Fundara tests only our customisations and extensions.
- **Frappe framework internals** — Web server, background workers, socket.io, and Frappe's own test suite are out of scope.
- **Infrastructure and network testing** — Load balancing, DNS, TLS certificate renewal, and firewall rules are covered by the infra team's runbook.
- **Payment gateway integration** — Not in MVP scope; deferred to post-MVP.
- **UI localization completeness** — Full Bahasa Indonesia label coverage is a Medium-severity QA item tracked separately, not a release blocker.

---

## 2. Jenis Testing

| Jenis | Tool | Who | When |
|---|---|---|---|
| Unit test | `frappe.tests.utils.FrappeTestCase` (Python) | Developer | Setiap PR sebelum merge ke `develop` |
| Integration test | `FrappeTestCase` + fixtures | Developer | Sebelum merge ke `develop` |
| End-to-end (E2E) | Manual, dipandu `docs/qa/test-case-catalog.md` | QA Engineer | Sprint genap (setiap 2 sprint) di staging |
| UAT | Manual, dipandu `docs/qa/uat-script.md` | Staf NGO pilot + PM | Sebelum setiap milestone release |
| Performance test | `wrk` / `locust` (basic) | Tech Lead | Sebelum staging deploy di Sprint 9 dan Sprint 10 |
| Regression | Regression checklist (bagian dari sprint QA report) | QA Engineer | Setiap sprint (per sprint QA cycle) |
| Security | OWASP Top 10 checklist + Frappe permission audit | Security reviewer | Sebelum go-live (Sprint 10) |
| Accessibility | Manual keyboard navigation + screen reader spot-check | QA / FE Developer | Post-MVP (tidak memblokir go-live) |

---

## 3. Strategi per Layer

### 3.1 Unit Testing

**Target coverage:** 80% lines untuk setiap DocType yang memiliki server-side business logic.

**Wajib ditest dengan unit test:**
- Semua method `validate()` dan `before_submit()` — field validations, mandatory checks, cross-field rules
- Semua `on_submit()` dan `on_cancel()` hook — GL posting, budget updates, status transitions
- Custom method yang mengandung kalkulasi (contoh: `calculate_fund_balance()`, `compute_amount_in_base_currency()`, `get_aging_category()`)
- Scheduled job handlers (contoh: `mark_overdue_advances()`)

**Tidak perlu unit test:**
- DocType master data murni tanpa business logic (contoh: `Organization`, `Department`, `Funding Source` basic fields)
- Frappe-native field validations (required, data type) — sudah dicover oleh Frappe framework

**Framework:** `frappe.tests.utils.FrappeTestCase`

**Lokasi file:** `fundara/[domain]/doctype/[doctype_name]/test_[doctype_name].py`

**CI trigger:** GitHub Actions menjalankan seluruh unit test suite otomatis pada setiap PR yang dibuat ke branch `develop`. PR tidak bisa di-merge jika ada test yang gagal.

**Contoh test file minimal (Cash Advance):**
```python
# fundara/cash_advance/doctype/cash_advance/test_cash_advance.py
from frappe.tests.utils import FrappeTestCase

class TestCashAdvance(FrappeTestCase):
    def test_approved_advance_does_not_reduce_budget(self):
        # TC-BG-03 / D-02 compliance
        ...

    def test_payment_blocked_when_fund_balance_insufficient(self):
        # TC-CA-07
        ...

    def test_overdue_transition_skips_closed_advances(self):
        # TC-CA-06 edge case
        ...
```

### 3.2 Integration Testing

Integration test memverifikasi alur lintas DocType yang tidak bisa ditest dengan unit test terisolasi. Semua integration test berada di layer yang sama (`FrappeTestCase` dengan fixtures), tetapi mengoperasikan multiple DocType dalam urutan yang realistis.

**Alur yang wajib di-cover oleh integration test:**

| Alur | Referensi Scenario |
|---|---|
| Cash Advance full lifecycle: Draft → Paid → Liquidated → Closed (semua GL entries harus balance) | TC-CA-01 |
| D-02 assertion: fund balance tidak berkurang saat Approved, berkurang saat Paid | TC-CA-01, TC-BG-03 |
| Multi-currency: `amount_in_base_currency = amount × exchange_rate` selalu benar di setiap status transition | TC-CA-08, TC-FM-01 |
| Fund allocation: alokasi tidak melebihi fund balance; block saat melebihi | TC-FM-04, TC-CA-07 |
| Grant closeout: semua Grant Budget Line harus lunas atau di-close sebelum Grant bisa ditutup | TC-FM-05 |
| Budget revision activation: `revised_amount` ter-update di Fund Budget Line, available balance terhitung ulang | TC-BG-04 |
| Procurement chain: Purchase Request → Purchase Order → Goods Receipt → Invoice → Payment (budget hanya berkurang saat Payment) | TC-PR-01, TC-BG-02 |

**Fixtures:** Integration test menggunakan fixtures yang di-seed via `frappe.tests.utils.make_test_records()` atau custom fixture loader di `fundara/tests/fixtures/`.

### 3.3 End-to-End Testing (E2E)

E2E test dilakukan secara manual oleh QA Engineer, bukan automated browser test (post-MVP).

**Jadwal:** Setiap sprint genap (Sprint 2, 4, 6, 8, 10). Sprint ganjil fokus ke developer testing dan unit/integration test.

**Environment:** Selalu di staging (bukan local developer machine). Staging harus sudah di-update dengan kode sprint terbaru sebelum E2E dimulai.

**Data:** Demo data fixtures di-load ulang ke staging sebelum setiap E2E cycle. Dokumen fixture ada di `docs/qa/demo-data.md`.

**Panduan:** QA menggunakan `docs/qa/test-case-catalog.md` sebagai checklist. Setiap test case mencatat: status (Pass / Fail / Blocked), bug reference jika ada, screenshot jika Fail.

**Dokumentasi hasil:** QA mengisi Sprint QA Report (template di Lampiran A) dan meng-upload screenshot ke issue tracker.

### 3.4 User Acceptance Testing (UAT)

UAT dilakukan oleh staf NGO pilot — bukan developer, bukan QA internal.

**Kapan:**
- Milestone 1 (Sprint 5 exit): setelah demo dataset pertama siap, sebelum Sprint 6
- Milestone 2 (Sprint 10 exit): sebelum go-live decision

**Script:** `docs/qa/uat-script.md` — ditulis dalam Bahasa Indonesia, menggunakan bahasa non-teknis, dipandu oleh PM.

**Durasi:** 2–3 hari intensif per milestone. UAT dilakukan di staging.

**Roles yang wajib terlibat dalam UAT:**
- Finance Officer (menjalankan skenario Cash Advance, Laporan, Rekonsiliasi)
- Project Officer (menjalankan skenario Purchase Request, Activity)
- Finance Manager (menjalankan skenario Budget Revision, Approval, Fund Close)

**Sign-off:** UAT dinyatakan selesai setelah PM dan satu representative user NGO pilot menandatangani UAT sign-off form.

---

## 4. Prioritas Testing per Feature Group

Prioritas didasarkan pada dua dimensi:
1. **Criticality** — apakah feature group ini menyentuh D-02, D-04, ISAK 35, atau alur utama fund accountability
2. **Complexity** — ukuran dari `docs/pm/complexity.md`

| Feature Group | Complexity | Test Priority | Keterangan |
|---|---|---|---|
| FG-09: Cash Advance & Liquidation | XL (16 days) | **Critical** | D-02 compliance, 11-state lifecycle, GL posting pada setiap terminal. Skenario TC-CA-01 s/d TC-CA-10 harus 100% pass sebelum release. |
| FG-05: Grant Management | XL (18 days) | **Critical** | Donor reporting, Grant Budget Line tracking, closeout validation. Bug di sini berdampak langsung ke laporan donor. |
| FG-15: Reporting & Dashboard | XL (16 days) | **Critical** | ISAK 35 Laporan Aktivitas, Fund Utilization, Budget vs Actual. Output salah = laporan keuangan salah. |
| FG-03: Fund Master & Fund Type | L (10 days) | **High** | Sentral system. Fund balance calculation dan restriction rules menjadi fondasi semua feature lain. |
| FG-06: Budget Layer | L (10 days) | **High** | D-02 formula diimplementasi di sini. Budget Revision chain harus ditest penuh. |
| FG-07: Cash Receipt & Disbursement | L (10 days) | **High** | GL posting pertama. Double-entry correctness wajib diverifikasi oleh Finance Domain Expert. |
| FG-12: Bank Reconciliation | L (10 days) | **High** | Reconciliation period close adalah control point penting. Auto-matching algorithm memiliki banyak edge case. |
| FG-04: Program, Project & Activity | L (10 days) | **Medium** | Workflow kompleks tapi tidak menyentuh GL. Happy path cukup untuk sprint QA. |
| FG-11: Fixed Asset & Depreciation | L (12 days) | **Medium** | Scheduled depreciation job harus ditest dengan time manipulation. |
| FG-01: Organization Setup | M (5 days) | **Medium** | Master data. Testing cukup happy path + permission matrix. |
| FG-02: Funding Source & Donor | M (5 days) | **Medium** | Master data dengan status lifecycle. Negative test pada status transition. |
| FG-08: Campaign & Donation | M (7 days) | **Medium** | Donation GL hook ke Fund harus ditest. Anonymous donation edge case. |
| FG-13: Opening Balance Assistant | M (5 days) | **Medium** | Balancing check (debit = credit) adalah satu-satunya critical rule. |
| FG-14: General Journal | M (5 days) | **Medium** | Fund Restriction Release journal wajib ditest untuk ISAK 35. |
| FG-10: Evidence & Compliance | M (6 days) | **Low** | Post-MVP feature. Wiring compliance hooks ditest bersama FG-07/FG-09. |

---

## 5. Cakupan Test Scenario (34 BDD Scenarios)

Semua 34 test scenario dari `docs/spec/test-scenarios.md` harus dieksekusi sebelum MVP go-live. Berikut pemetaan ke sprint QA cycle:

| Kode | Judul Singkat | Sprint E2E Target | Priority |
|---|---|---|---|
| TC-FM-01 | Create Restricted Grant Fund with USD | Sprint 4 | High |
| TC-FM-02 | Fund Transfer Between Two Funds | Sprint 4 | High |
| TC-FM-03 | Fund Balance Calculation After Multiple Tx | Sprint 4 | Critical |
| TC-FM-04 | Attempt to Overspend a Fund | Sprint 4 | Critical |
| TC-FM-05 | Close a Fund with Outstanding Advances | Sprint 6 | High |
| TC-FM-06 | Fund Balance Display in Transaction Currency and IDR | Sprint 4 | High |
| TC-FM-07 | Bridging Fund Settlement | Sprint 8 | Medium |
| TC-FM-08 | Budget Revision Requiring Donor Approval | Sprint 8 | High |
| TC-CA-01 | Full Happy Path Advance Lifecycle | Sprint 6 | Critical |
| TC-CA-02 | Partial Liquidation | Sprint 6 | Critical |
| TC-CA-03 | Liquidation Exceeds Advance Amount | Sprint 6 | High |
| TC-CA-04 | Ineligible Expense During Liquidation | Sprint 6 | High |
| TC-CA-05 | Advance Rejected During Under Review | Sprint 6 | Medium |
| TC-CA-06 | Advance Becomes Overdue (Auto-trigger) | Sprint 6 | High |
| TC-CA-07 | Advance Paid but Fund Insufficient (Blocked) | Sprint 6 | Critical |
| TC-CA-08 | Multi-currency Advance Against USD Fund | Sprint 6 | High |
| TC-CA-09 | Two Advances Approved Before Either Paid | Sprint 6 | Critical |
| TC-CA-10 | Advance Cancellation After Payment (Blocked) | Sprint 6 | High |
| TC-PR-01 | Purchase Request Converted to Purchase Order | Sprint 6 | High |
| TC-PR-02 | Restricted Fund — Ineligible Item Blocked | Sprint 6 | High |
| TC-PR-03 | Vendor Not Registered — PR Submission Blocked | Sprint 6 | Medium |
| TC-PR-04 | Goods Received Partially — PO Remains Open | Sprint 8 | Medium |
| TC-PR-05 | Invoice Amount Differs from PO (Threshold Check) | Sprint 8 | High |
| TC-PR-06 | Emergency Procurement Without PR | Sprint 8 | Medium |
| TC-BG-01 | Budget vs Actual Dashboard Shows Correct Balance | Sprint 6 | Critical |
| TC-BG-02 | Expense Posted Today Reduces Budget (D-02) | Sprint 6 | Critical |
| TC-BG-03 | Approved-Not-Paid Advance in Pending Panel Only | Sprint 6 | Critical |
| TC-BG-04 | Budget Revision Changes Approved Amount | Sprint 6 | High |
| TC-BG-05 | Budget Line Hard Block at Payment | Sprint 6 | Critical |
| TC-BG-06 | Multi-fund Expense Split 60/40 | Sprint 8 | High |
| TC-RP-01 | Donor Report in USD for USD Grant Fund | Sprint 10 | Critical |
| TC-RP-02 | Fund Utilization Report All Funds | Sprint 10 | Critical |
| TC-RP-03 | ISAK 35 Laporan Aktivitas with Restriction Split | Sprint 10 | Critical |
| TC-RP-04 | Campaign Public Report After Reporting Status | Sprint 10 | High |

---

## 6. Lingkungan Testing

| Lingkungan | URL | Data | Digunakan untuk |
|---|---|---|---|
| Local (developer) | `http://fundara.local:8000` | Test fixtures di-seed ulang tiap test run | Unit test, integration test |
| Staging | `https://staging.fundara.[org]` | Demo data + di-reset tiap sprint E2E cycle | E2E test, regression test, UAT, performance test |
| Production | TBD | Data riil | Post go-live monitoring saja — tidak ada testing di production |

**Staging setup requirements:**
- ERPNext v16 (versi yang sama dengan target produksi)
- Fundara app ter-install dari branch `develop` (atau release branch)
- Demo dataset dari `docs/qa/demo-data.md` ter-load
- Background workers aktif (untuk scheduled job testing: advance overdue, depreciation)
- Currency Exchange master ter-populate dengan rate hari ini

---

## 7. Definisi Done untuk Testing

Story dianggap selesai dari sisi QA jika semua kriteria berikut terpenuhi:

- [ ] Unit test pass (coverage ≥80% untuk DocType dengan business logic)
- [ ] Integration test pass untuk alur utama yang relevan
- [ ] Tidak ada Critical atau High bug yang open dan unassigned
- [ ] E2E test scenario terkait telah dieksekusi manual oleh QA di staging (sprint genap)
- [ ] Regression checklist dijalankan: tidak ada test yang sebelumnya hijau menjadi merah
- [ ] GL entry balance diverifikasi oleh Finance Domain Expert (untuk story yang melibatkan GL posting)

---

## 8. Metrik Kualitas

| Metrik | Target | Frekuensi Pengukuran | Penanggung Jawab |
|---|---|---|---|
| Unit test pass rate | 100% | Setiap PR | CI (GitHub Actions) |
| Test coverage — DocType dengan logic | ≥80% lines | Setiap sprint | Developer + TL |
| Open Critical bugs saat sprint close | 0 | Setiap akhir sprint | QA |
| Open High bugs boleh carry over | ≤3 (dengan persetujuan PM dan TL) | Setiap akhir sprint | PM |
| Regression failure rate | 0% | Setiap sprint | QA |
| UAT pass rate | ≥90% skenario Pass | Setiap UAT session | PM |
| Performance: Fund Utilization Report | <10 detik untuk 1.000 transaksi | Sprint 9 + Sprint 10 | Tech Lead |
| Performance: Budget vs Actual dashboard | Tidak timeout untuk 500+ budget lines | Sprint 10 | Tech Lead |

---

## 9. Bug Lifecycle dan Reporting

Semua bug dicatat di issue tracker (GitHub Issues). Panduan lengkap ada di `docs/qa/bug-severity-matrix.md`.

**Bug tracker label convention:**
- `severity:critical` / `severity:high` / `severity:medium` / `severity:low`
- `type:regression` — bug yang pernah fix muncul kembali
- `type:blocking` — memblokir test scenario lain
- `domain:cash-advance` / `domain:fund` / `domain:reporting` / dll.

**Sprint QA standup:** 15 menit setiap Senin pagi. QA melaporkan:
1. Jumlah bug open per severity (Critical / High / Medium / Low)
2. Bug baru ditemukan minggu lalu
3. Bug yang SLA-nya mendekati batas
4. Blocker untuk E2E testing

---

## 10. Peran dan Tanggung Jawab

| Peran | Tanggung Jawab QA |
|---|---|
| Developer | Menulis unit test dan integration test. Memastikan test pass sebelum PR dibuat. Mengisi Level 1 DoD checklist. |
| QA Engineer | Menjalankan E2E test setiap sprint genap. Mengisi Sprint QA Report. Mencatat dan men-triage bug. Menjalankan regression checklist. |
| Tech Lead | Mereview code sebelum merge. Memverifikasi test coverage. Menjalankan performance test sebelum staging deploy. Sign-off pada Level 2 DoD quality gate. |
| Project Manager | Memverifikasi Level 2 DoD (Sprint DoD) saat sprint close. Memastikan UAT terjadwal dan sign-off UAT. Mengelola bug carry-over decision. |
| Finance Domain Expert | Memverifikasi GL entry correctness. Memverifikasi ISAK 35 output. Sign-off pada Level 3 DoD (MVP DoD) untuk accounting correctness section. |

---

## Lampiran A: Template Sprint QA Report

Diisi oleh QA Engineer setiap akhir sprint dan disampaikan di sprint review.

---

**Sprint:** [nomor sprint]
**Periode:** [tanggal mulai] — [tanggal selesai]
**QA Engineer:** [nama]
**Environment:** Staging `https://staging.fundara.[org]` — branch `[nama branch]`

---

### Ringkasan Eksekusi Test Case

| Domain | Jumlah TC | Pass | Fail | Blocked | Catatan |
|---|---|---|---|---|---|
| Fund Management | | | | | |
| Cash Advance | | | | | |
| Procurement | | | | | |
| Budget | | | | | |
| Reporting | | | | | |
| **Total** | | | | | |

### Bug Ditemukan Sprint Ini

| ID | Judul | Severity | Domain | Status | Assignee |
|---|---|---|---|---|---|
| | | | | | |

### Ringkasan Bug per Severity

| Severity | Ditemukan | Diselesaikan | Carry Over |
|---|---|---|---|
| Critical | | | |
| High | | | |
| Medium | | | |
| Low | | | |

### Regression Status

- Jumlah test case regression dijalankan: ___
- Pass: ___ / Fail: ___ / Blocked: ___
- Regression yang gagal (jika ada):

### Performance (sprint genap sebelum release)

- Fund Utilization Report (1.000 tx): ___ detik (target: <10 detik)
- Budget vs Actual dashboard (500+ lines): ___ (target: no timeout)

### Rekomendasi

- [ ] **Release** — Tidak ada blocker, sprint siap dilanjutkan
- [ ] **Hold** — Ada Critical/High bug yang harus diselesaikan dulu

**Alasan (jika Hold):** ___________________________________________

**Tanda tangan QA:** ___________________________ **Tanggal:** ___________
