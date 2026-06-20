# Development Readiness

## Status: Siap untuk Coding — 100%

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

### Setelah Pelengkapan Dokumen QA — Sesi 4

Hasil: **99% siap. Semua dokumen QA selesai.**

Gap yang ditutup:
1. Test plan (strategi testing keseluruhan) — tidak ada → Siap (`docs/qa/test-plan.md`)
2. Test case catalog (50 kasus beyond 34 BDD yang sudah ada) — tidak ada → Siap (`docs/qa/test-case-catalog.md`)
3. Demo data specification (NGO fiktif YPN, 8 user, 5 fund, transaksi multi-state) — tidak ada → Siap (`docs/qa/demo-data.md`)
4. UAT script (dalam Bahasa Indonesia untuk staf NGO, 7 skenario per role) — tidak ada → Siap (`docs/qa/uat-script.md`)
5. Bug severity matrix (Critical/High/Medium/Low + SLA + contoh Fundara + lifecycle) — tidak ada → Siap (`docs/qa/bug-severity-matrix.md`)
6. Regression checklist (Happy path per area, bisa selesai 2–3 jam per sprint) — tidak ada → Siap (`docs/qa/regression-checklist.md`)

### Setelah Pelengkapan Dokumen Security — Sesi 5

Hasil: **100% siap. Semua dokumen security selesai. Seluruh area dokumentasi MVP tertutup.**

Gap yang ditutup:
1. Security requirements — tidak ada → Siap (`docs/security/security-requirements.md`)
2. Threat model (STRIDE, 16 ancaman, risk matrix) — tidak ada → Siap (`docs/security/threat-model.md`)
3. Pentest scope (ruang lingkup, test accounts, rules of engagement) — tidak ada → Siap (`docs/security/pentest-scope.md`)
4. OWASP Top 10 checklist (untuk Frappe/ERPNext custom app) — tidak ada → Siap (`docs/security/owasp-checklist.md`)
5. Data privacy spec (UU PDP No. 27/2022, retensi, anonymization, consent) — tidak ada → Siap (`docs/security/data-privacy.md`)
6. Incident response plan (5 fase, notifikasi UU PDP, tabletop exercise) — tidak ada → Siap (`docs/security/incident-response.md`)

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

**Dokumen QA (sesi 4):**

| File | Isi |
|---|---|
| `docs/qa/test-plan.md` | Master testing strategy: 8 jenis test, prioritas per feature group, metrik kualitas, sprint QA report template |
| `docs/qa/test-case-catalog.md` | 50 test case (TC-PERM, TC-WF, TC-UI, TC-GR, TC-DN, TC-ORG, TC-NT, TC-PF, TC-MC, TC-PERF) — melengkapi 34 BDD yang sudah ada |
| `docs/qa/demo-data.md` | Spec dataset demo: Yayasan Peduli Nusantara, 8 user, 5 fund, 2 grant, transaksi multi-state, checklist verifikasi |
| `docs/qa/uat-script.md` | Skrip UAT Bahasa Indonesia: 7 skenario per role staf NGO, formulir feedback, kriteria Pass/Fail |
| `docs/qa/bug-severity-matrix.md` | Critical/High/Medium/Low: definisi, contoh Fundara, SLA, lifecycle bug, metrik |
| `docs/qa/regression-checklist.md` | Checklist happy path setiap sprint (2–3 jam), section wajib D-02 dan D-04, report template |

**Dokumen Security (sesi 5):**

| File | Isi |
|---|---|
| `docs/security/security-requirements.md` | SR-AUTH, SR-AUTHZ, SR-ENC, SR-LOG, SR-DEV, SR-DEP — checklist go-live wajib |
| `docs/security/threat-model.md` | STRIDE: 9 aset, 11 aktor, 9 attack surface, 16 ancaman, risk matrix |
| `docs/security/pentest-scope.md` | In/out scope, 7 area uji, test accounts per role, rules of engagement, format laporan |
| `docs/security/owasp-checklist.md` | OWASP Top 10 (2021): relevansi Frappe, checklist implementasi, status tracking |
| `docs/security/data-privacy.md` | UU PDP No. 27/2022: inventaris PII, retensi 10 area, prosedur anonymisasi, consent management |
| `docs/security/incident-response.md` | 5 fase respons, containment commands, notifikasi UU PDP, tabletop exercise guide |

**Dokumen Audit & Compliance (sesi 6):**

| File | Isi |
|---|---|
| `docs/security/iso27001-audit.md` | Gap analysis ISO/IEC 27001:2022 — 93 kontrol Annex A + 10 klausul utama, scorecard kepatuhan, 17 gap prioritas (7 Critical), roadmap 18 dokumen tambahan, rekomendasi strategis |

**Dokumen PM — Revisi Estimasi & Keputusan Frontend (sesi 7 — 20 Juni 2026):**

| File | Perubahan |
|---|---|
| `docs/pm/complexity.md` | Tambah kolom Client JS ke summary table (~14 hari overhead dari `form-layout.md`). Setiap FG-03 s/d FG-10 kini punya breakdown eksplisit client script (handler, custom button, `frappe.call`). Section baru "Client Script Track". Revised total: ~172 dev-days (Opsi C) + 20 QA = ~192 hari. FE-04 + FE-05 masuk Post-MVP table. |
| `DECISIONS.md` | Tambah D-07 (OPEN) — keputusan scope frontend FE-04 (7 print format, ~14 hari) dan FE-05 (7 role dashboard, ~14 hari). Rekomendasi Opsi C: keduanya ke v0.2. Deadline: sebelum Sprint 4. |
| `docs/pm/d07-decision-brief.html` | Dokumen presentasi interaktif untuk Product Owner — cost meter visual per opsi, tiga alasan rekomendasi, tombol keputusan dengan ringkasan konsekuensi. |

**Governance Documents — Critical (sesi 7 lanjutan):**

| File | Isi |
|---|---|
| `docs/security/is-policy.md` | Kebijakan Keamanan Informasi formal (ISP-001 v1.0) — 12 area kebijakan, tujuan terukur, peran & tanggung jawab, pelanggaran, pengecualian, jadwal review tahunan, blok tanda tangan Pimpinan. Menutup gap CRITICAL #1 ISO 27001 (Klausul 5.2, A.5.1). |
| `docs/security/isms-scope.md` | Ruang Lingkup ISMS formal (ISP-002 v1.0) — pernyataan scope, 13 aset dalam lingkup, 7 pengecualian dengan justifikasi, antarmuka eksternal, siklus PDCA, pihak berkepentingan, konteks organisasi. Menutup gap CRITICAL #2 ISO 27001 (Klausul 4.3). |
| `docs/security/offboarding-checklist.md` | Offboarding Checklist formal (ISP-003 v1.0) — inventarisasi akses D-2, pencabutan akses 11 kategori sistem dalam 24 jam (GitHub, Frappe dev/staging/prod, SSH keys, API keys, database, GPG backup, monitoring, vault, komunikasi), verifikasi D+7, rekam jejak audit. Menutup gap CRITICAL #3 ISO 27001 (A.6.5). |
| `docs/security/nda-template.md` | Template NDA (ISP-004 v1.0) — Template A: NDA formal 11 pasal untuk Developer/Contributor/DevOps (definisi informasi rahasia, tabel lingkup akses per sistem, UU PDP Pasal 20+40+67, sanksi KUHPerdata + UU ITE, jangka waktu 5 tahun); Template B: klausul kerahasiaan singkat untuk staf NGO, siap diintegrasikan ke kontrak kerja. Menutup gap CRITICAL #4 ISO 27001 (A.6.6). |
| `docs/security/information-classification.md` | Kebijakan Klasifikasi Informasi (ISP-005 v1.0) — skema 4 tingkat L4 Terbatas / L3 Rahasia / L2 Internal / L1 Publik; tabel 20+ komponen Fundara; pemetaan dari skema sensitivitas lama (Kritis/Sangat Tinggi/Tinggi); aturan penanganan per tingkat (storage, transmisi, akses, cetak, pemusnahan); decision tree klasifikasi data baru; panduan pelabelan dokumen. Menutup gap CRITICAL #5 ISO 27001 (A.5.12). |

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
| QA: test plan | Siap |
| QA: test case catalog (50 kasus) | Siap |
| QA: demo data specification | Siap |
| QA: UAT script (Bahasa Indonesia) | Siap |
| QA: bug severity matrix | Siap |
| QA: regression checklist | Siap |
| Security: security requirements | Siap |
| Security: threat model (STRIDE) | Siap |
| Security: pentest scope | Siap |
| Security: OWASP Top 10 checklist | Siap |
| Security: data privacy spec (UU PDP) | Siap |
| Security: incident response plan | Siap |
| Security: ISO 27001:2022 compliance audit | Siap |
| Deployment automation script | Siap (docs/infra/deploy.sh) |
| Demo data fixtures (JSON aktual) | Belum — spec sudah ada di docs/qa/demo-data.md, developer perlu buat JSON-nya |
| API contracts integrasi eksternal | Belum — post-MVP (payment gateway, KoboToolbox, bank API) |
| Formal ER diagram dengan constraint | Belum — bisa di-generate dari kode setelah DocType dibuat |
| Multi-tenancy strategy (D-06) | DEFERRED — diputuskan sebelum v1.0 release |
| PM: client script overhead per FG (~14 hari) | Siap — tercatat di `docs/pm/complexity.md` § Client Script Track |
| PM: keputusan D-07 frontend MVP scope | OPEN — presentasi disiapkan (`docs/pm/d07-decision-brief.html`), menunggu keputusan PO sebelum Sprint 4 |
| Governance: IS Policy formal (ISP-001) | Siap — `docs/security/is-policy.md`. **Menunggu tanda tangan Pimpinan (PO) untuk berlaku efektif.** |
| Governance: ISMS Scope Document (ISP-002) | Siap — `docs/security/isms-scope.md`. **Menunggu tanda tangan Pimpinan (PO) untuk berlaku efektif.** |
| Governance: Offboarding Checklist (ISP-003) | Siap — `docs/security/offboarding-checklist.md`. Dapat langsung digunakan saat ada offboarding. |
| Governance: NDA Template (ISP-004) | Siap — `docs/security/nda-template.md`. Template A untuk developer/DevOps; Template B untuk staf NGO. |
| Governance: Information Classification Policy (ISP-005) | Siap — `docs/security/information-classification.md`. Skema L4/L3/L2/L1 dengan aturan handling per tingkat. |

---

## Semua Area Tercakup — Siap 100%

Seluruh area dokumentasi yang dibutuhkan untuk memulai development sudah tersedia. Tiga item berikut bukan blocker — akan diselesaikan di fase yang tepat:

- **Demo data fixtures (JSON aktual)** — spec ada di `docs/qa/demo-data.md`. Developer implement saat sprint QA pertama (sprint 4–5).
- **External API contracts** — semua integrasi eksternal (payment gateway, KoboToolbox, bank API) ada di post-MVP scope.
- **ER diagram formal** — bisa di-generate otomatis dari schema ERPNext setelah DocType dibuat. DocType specs sudah cukup sebagai substitusi.

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
