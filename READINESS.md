# Development Readiness

## Status: Siap untuk Coding — 97%

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

### Setelah Pelengkapan Dokumen — Sesi 1

Hasil: **85% siap. Semua Tier 1 blocker backend sudah tertutup.**

### Setelah Pelengkapan Dokumen Frontend — Sesi 2

Hasil: **93% siap. Frontend spec lengkap ditambahkan.**

Gap yang ditutup:
1. Form layout & `depends_on` rules — tidak ada → Siap
2. Dashboard spec per role — tidak ada → Siap
3. Status color coding — tidak ada → Siap
4. Client-side validation messages — tidak ada → Siap
5. Print format specifications — tidak ada → Siap
6. Notification templates — tidak ada → Siap

### Setelah Pelengkapan Dokumen Developer Process — Sesi 3

Hasil: **97% siap. Dokumen pre-development dan development process lengkap ditambahkan.**

Gap yang ditutup:
1. Local development environment setup — tidak ada → Siap (`docs/dev/local-setup.md`)
2. Feature development lifecycle (spec → code → test → staging) — tidak ada → Siap (`docs/dev/dev-workflow.md`)
3. Frappe patterns & recipes for Fundara developer — tidak ada → Siap (`docs/dev/frappe-cookbook.md`)
4. Git branching strategy & PR process — tidak ada → Siap (`docs/dev/git-branching.md`)

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

**Dokumen PM (sesi 1):**

| File | Isi |
|---|---|
| `docs/pm/dependency-map.md` | 5-layer build order ~55 DocType + critical path |
| `docs/pm/complexity.md` | T-shirt sizing per feature group, 145 dev-days, breakdown 10 sprint |
| `docs/pm/risk-register.md` | 27 risiko (Technical/Domain/Scope/Delivery/Quality) |
| `docs/pm/raci.md` | Matriks 25 aktivitas × 8 role + decision authority |
| `docs/pm/definition-of-done.md` | DoD 3 level (Story/Sprint/MVP) + agenda sprint review |

**Dokumen Frontend (sesi 2):**

| File | Isi |
|---|---|
| `docs/spec/frontend/form-layout.md` | Layout, `depends_on`, `read_only`, `fetch_from` untuk 21 DocType MVP |
| `docs/spec/frontend/dashboard-spec.md` | Dashboard 7 role: number cards, charts, list views, alert banners |
| `docs/spec/frontend/status-colors.md` | Warna indicator semua status, list view row highlight rules |
| `docs/spec/frontend/validation-messages.md` | 60+ validation rule (Error/Warning) + D-02 UI messages |
| `docs/spec/frontend/print-formats.md` | 7 print format: layout, field mapping, tanda tangan, watermark |
| `docs/spec/frontend/notifications.md` | 21 notifikasi: subject, body Bahasa Indonesia, in-app message |

**Dokumen Developer Process (sesi 3):**

| File | Isi |
|---|---|
| `docs/dev/local-setup.md` | Setup dev environment di Ubuntu/macOS/WSL2: bench, ERPNext, Fundara, IDE, troubleshooting |
| `docs/dev/dev-workflow.md` | Lifecycle implementasi fitur: story → DocType → server script → test → PR → staging (contoh: Cash Advance) |
| `docs/dev/frappe-cookbook.md` | Resep Frappe siap pakai: console, controller, GL posting, client script, API, scheduler, fixtures, debugging |
| `docs/dev/git-branching.md` | Branching strategy, commit convention, PR template, release process, version tagging |

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
| Form layout & depends_on rules | Siap |
| Dashboard spec per role | Siap |
| Status color coding | Siap |
| Client-side validation messages | Siap |
| Print format specifications | Siap |
| Notification templates | Siap |
| PM: dependency map & complexity | Siap |
| PM: risk register & RACI & DoD | Siap |
| Dev: local environment setup guide | Siap |
| Dev: feature development lifecycle | Siap |
| Dev: Frappe patterns & cookbook | Siap |
| Dev: git branching & PR process | Siap |
| Deployment automation script | Belum — dibutuhkan sebelum staging/UAT |
| Demo data fixtures (JSON aktual) | Belum — dibutuhkan di sprint QA pertama |
| API contracts integrasi eksternal | Belum — post-MVP (payment gateway, KoboToolbox, bank API) |
| Formal ER diagram dengan constraint | Belum — bisa di-generate dari kode setelah DocType dibuat |
| Multi-tenancy strategy (D-06) | DEFERRED — diputuskan sebelum v1.0 release |

---

## Sisa 3% — Tidak Memblokir MVP

Gap yang tersisa tidak akan menghentikan developer atau frontend dev di sprint pertama:

- **Deployment script** — concern DevOps, bisa dikerjakan paralel saat sprint 1-2
- **Demo data fixtures** — concern QA, dibutuhkan saat sprint testing pertama (sprint 4-5)
- **External API contracts** — semua integrasi eksternal ada di post-MVP scope
- **ER diagram formal** — DocType specs sudah cukup sebagai substitusi; bisa di-generate otomatis dari schema ERPNext setelah DocType dibuat

---

## Dokumen yang Belum Ada — Perlu Dibuat

Tiga area berikut belum memiliki dokumen sama sekali. Perlu dibuat sebelum staging/UAT dan sebelum go-live.

### QA (Quality Assurance)

| Dokumen | Isi yang Dibutuhkan | Prioritas |
|---|---|---|
| Test plan | Strategi testing keseluruhan: unit, integration, UAT, regression | Sebelum sprint QA pertama |
| Test case catalog | Test case lengkap per fitur di luar 34 skenario BDD yang sudah ada | Sebelum sprint QA pertama |
| Demo data fixtures | Dataset JSON realistis untuk setiap bounded context | Sprint 4–5 |
| UAT script | Skrip sesi UAT untuk end-user (staf NGO), bukan developer | Sebelum UAT |
| Bug severity matrix | Definisi Critical/High/Medium/Low + SLA fix per level | Awal proyek |
| Regression checklist | Daftar fitur yang harus ditest ulang setiap sprint | Sprint 2 |

### Security / Pentest

| Dokumen | Isi yang Dibutuhkan | Prioritas |
|---|---|---|
| Security requirements | Daftar kebutuhan keamanan: autentikasi, enkripsi data, session management, audit log | Sebelum coding dimulai |
| Threat model | Identifikasi aset sensitif (data donor, data benefisiari, data keuangan), attack surface, dan mitigasi | Sebelum coding dimulai |
| Pentest scope | Ruang lingkup penetration testing: endpoint, role, data sensitivity, exclusion | Sebelum staging |
| OWASP checklist | Checklist OWASP Top 10 yang relevan untuk Frappe/ERPNext custom app | Sebelum go-live |
| Data privacy spec | Perlakuan data PII: donor, benefisiari, staf — termasuk masking, retention, deletion policy | Sebelum go-live |
| Incident response plan | Langkah-langkah jika terjadi breach atau kebocoran data | Sebelum go-live |

### Infrastruktur

| Dokumen | Isi yang Dibutuhkan | Prioritas |
|---|---|---|
| Deployment script | Shell script atau Ansible playbook untuk setup Ubuntu 24.04 + Frappe bench + Fundara | Sprint 1–2 |
| Environment spec | Spesifikasi server dev, staging, production (CPU, RAM, disk, OS) | Sprint 1 |
| Backup & recovery plan | Jadwal backup, lokasi, prosedur restore, RTO/RPO target | Sebelum staging |
| Monitoring spec | Metric yang dipantau, alert threshold, tool (Grafana/Prometheus/Netdata) | Sebelum staging |
| Upgrade runbook | Prosedur upgrade ERPNext versi minor/major tanpa downtime | Sebelum go-live |
| Multi-site setup guide | Cara setup per-org site di Frappe bench (D-06 prerequisite) | Sebelum v1.0 |

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
