# Development Readiness

## Status: Siap untuk Coding — 85%

Dokumen ini mencatat hasil audit kesiapan dokumen Fundara sebelum development dimulai, dan apa yang sudah dilengkapi.

---

## Riwayat Audit

### Audit Pertama — sebelum sesi ini

Hasil: **55% siap.**

Temuan: dokumen visi, domain model konseptual, dan workflow sudah kuat. Tapi tidak ada spesifikasi implementasi yang cukup untuk developer mulai coding — tidak ada field DocType, tidak ada aturan posting akuntansi, tidak ada matriks permission.

Semua Tier 1 blocker ditemukan:

1. DocType field specification — tidak ada
2. Journal entry rules catalog — tidak ada
3. Permission matrix (RBAC) — tidak ada
4. Workflow engine configuration — tidak ada
5. Multi-currency posting algorithm — tidak ada
6. Cost-sharing GL formula — tidak ada

### Setelah Pelengkapan Dokumen

Hasil: **85% siap. Semua Tier 1 blocker sudah tertutup.**

---

## Dokumen yang Ditambahkan

| File | Isi |
|---|---|
| `docs/spec/doctypes/01-organization-doctypes.md` | Field spec DocType context Organization |
| `docs/spec/doctypes/02-funding-doctypes.md` | Field spec DocType context Funding |
| `docs/spec/doctypes/03-fund-stewardship-doctypes.md` | Field spec DocType context Fund Stewardship |
| `docs/spec/doctypes/04-grant-doctypes.md` | Field spec DocType context Grant |
| `docs/spec/doctypes/05-mission-delivery-doctypes.md` | Field spec DocType context Mission Delivery |
| `docs/spec/doctypes/06-financial-accountability-doctypes.md` | Field spec DocType context Financial Accountability |
| `docs/spec/doctypes/07-procurement-doctypes.md` | Field spec DocType context Procurement |
| `docs/spec/doctypes/08-evidence-doctypes.md` | Field spec DocType context Evidence & Compliance |
| `docs/spec/doctypes/09-impact-doctypes.md` | Field spec DocType context Impact & Learning |
| `docs/spec/doctypes/10-reporting-doctypes.md` | Field spec DocType context Reporting |
| `docs/accounting/journal-entries.md` | 28 aturan GL posting + struktur Chart of Accounts ISAK 35 |
| `docs/spec/permissions.md` | Matriks RBAC: 13 role × 30+ DocType |
| `docs/spec/workflows.md` | 6 konfigurasi Frappe Workflow + threshold approval |
| `docs/spec/multicurrency.md` | Algoritma multi-currency, unrealized/realized FX, edge cases |
| `docs/spec/cost-sharing.md` | Formula split-fund GL, indirect cost allocation |
| `docs/spec/test-scenarios.md` | 34 skenario BDD test (Given/When/Then) |

---

## Status per Area

| Area | Status |
|---|---|
| System overview & MVP scope | Siap |
| Domain model (10 bounded context) | Siap |
| DocType field specifications (80+ DocType) | Siap |
| ERPNext/Frappe implementation spec | Siap |
| Workflow & approval matrix | Siap |
| Accounting rules & journal entries | Siap |
| Permission model (RBAC) | Siap |
| Multi-currency algorithm | Siap |
| Cost-sharing & split-fund | Siap |
| Test scenarios (BDD) | Siap |
| Deployment automation script | Belum — dibutuhkan sebelum staging/UAT |
| Demo data fixtures (JSON aktual) | Belum — dibutuhkan di sprint QA pertama |
| API contracts integrasi eksternal | Belum — post-MVP (payment gateway, KoboToolbox, bank API) |
| Formal ER diagram dengan constraint | Belum — bisa di-generate dari kode setelah DocType dibuat |
| Multi-tenancy strategy (D-06) | DEFERRED — diputuskan sebelum v1.0 release |

---

## Sisa 15% — Tidak Memblokir MVP

Gap yang tersisa tidak akan menghentikan developer di sprint pertama:

- **Deployment script** — concern DevOps, bisa dikerjakan paralel
- **Demo data fixtures** — concern QA, dibutuhkan saat sprint testing pertama
- **External API contracts** — semua integrasi eksternal ada di post-MVP scope
- **ER diagram formal** — DocType specs sudah cukup sebagai substitusi; ER diagram bisa di-generate otomatis dari schema ERPNext setelah DocType dibuat

---

## Keputusan Arsitektur yang Sudah Dikunci

Lihat `DECISIONS.md` untuk detail. Ringkasan:

| ID | Keputusan |
|---|---|
| D-01 | Grant = bounded context mandiri (bukan sub-domain Fund) |
| D-02 | Available Budget = Approved Budget − Actual (paid only). Tidak ada commitment layer. |
| D-03 | ERPNext v16 |
| D-04 | Multi-currency masuk MVP (USD, EUR, IDR dari hari pertama) |
| D-05 | Domain context = logic bisnis. `docs/accounting/` = detail implementasi. |
| D-06 | Multi-tenancy DEFERRED — diputuskan sebelum v1.0 |
