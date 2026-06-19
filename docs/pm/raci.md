# RACI Matrix — Fundara Development Project

**Project:** Fundara — Fund-centric ERP for Mission-driven Organizations  
**Platform:** ERPNext v16 / Frappe Framework  
**Document owner:** Project Manager  
**Last updated:** 2026-06-18

---

## Role Legend

| Code | Role | Description |
|------|------|-------------|
| **PO** | Product Owner | Sets priorities, approves features, represents NGO end-users |
| **PM** | Project Manager | Leads delivery, manages sprints, removes blockers |
| **TL** | Tech Lead | Architecture decisions, code review, ERPNext/Frappe expertise |
| **DEV** | Developer(s) | Implementation of DocTypes, scripts, and configuration |
| **QA** | QA Engineer | Test scenario execution, regression testing, bug reporting |
| **FE** | Domain Expert: Finance | Accounting rules, ISAK 35, GL logic, journal entries |
| **PE** | Domain Expert: Program | Activity, procurement, advance, MEAL workflows |
| **UX** | UX Designer | Form layout, dashboards, conditional fields, user experience |
| **DO** | DevOps / SysAdmin | Server provisioning, backup operations, monitoring, upgrade execution, site management. In a small team, this role is filled by TL. |

---

## RACI Key

| Symbol | Meaning |
|--------|---------|
| **R** | **Responsible** — does the work |
| **A** | **Accountable** — final decision authority, one person per row |
| **C** | **Consulted** — provides input before the activity completes |
| **I** | **Informed** — notified when the activity completes |

---

## Phase 1: Planning

| Activity | PO | PM | TL | DEV | QA | FE | PE | UX |
|----------|----|----|-----|-----|----|----|----|----|
| Define sprint scope | C | **A/R** | C | I | I | I | I | I |
| Prioritize backlog | **A** | R | C | I | I | C | C | C |
| Resolve scope disputes | **A** | R | C | I | I | C | C | I |
| Make architecture decisions | I | I | **A/R** | C | I | C | I | I |
| Approve new DECISIONS.md entries | C | I | **A/R** | C | I | C | C | I |

**Notes:**
- Sprint scope is set by PM in consultation with TL (effort) and PO (priority). Final call is PM's.
- Backlog priority is PO's final authority; PM executes.
- Architecture decisions belong to TL; PM facilitates, DEV implements. DECISIONS.md entries require TL sign-off.
- Domain experts (FE, PE) are consulted on architecture decisions that touch accounting or workflow rules.

---

## Phase 2: Design

| Activity | PO | PM | TL | DEV | QA | FE | PE | UX |
|----------|----|----|-----|-----|----|----|----|----|
| Review DocType field spec | C | I | **A** | R | I | C | C | R |
| Review journal entry rules | I | I | C | I | I | **A/R** | I | I |
| Review workflow configuration | C | I | **A** | R | C | C | C | I |
| Review permission matrix | I | C | **A** | R | I | I | I | I |
| Design form UX / conditional fields | C | I | C | I | I | C | C | **A/R** |

**Notes:**
- DocType field spec is co-produced by UX (layout) and DEV (technical), reviewed and approved by TL. Domain experts consulted for field correctness.
- Journal entry rules are owned entirely by Finance Domain Expert (FE). TL ensures ERPNext implementation is consistent with that spec.
- UX Designer owns all form and dashboard design; TL ensures Frappe framework constraints are respected.
- Permission matrix decisions rest with TL against the workflow.md role definitions.

---

## Phase 3: Development

| Activity | PO | PM | TL | DEV | QA | FE | PE | UX |
|----------|----|----|-----|-----|----|----|----|----|
| Implement DocType | I | I | C | **A/R** | I | I | I | I |
| Write server scripts / GL hooks | I | I | **A** | R | I | C | I | I |
| Configure Frappe Workflow | I | I | **A** | R | I | I | C | I |
| Configure permissions | I | I | **A** | R | I | I | I | I |
| Write unit tests | I | I | C | **A/R** | C | I | I | I |
| Code review | I | I | **A/R** | C | I | I | I | I |
| Implement print format templates (Jinja2) | I | I | C | R | I | I | I | **A/R** |
| Implement notification templates + scheduled jobs | I | I | C | R | I | I | C | **A** |
| Implement role dashboards (7 role-specific) | I | I | C | R | I | I | I | **A/R** |
| Implement status colors + `get_indicator` hooks | I | I | **A** | R | I | I | I | C |

**Notes:**
- DEV is solely responsible for DocType implementation; TL is consulted to confirm adherence to architecture decisions.
- GL hooks require Finance Domain Expert consultation to ensure correct debit/credit mapping before merge.
- Frappe Workflow configuration requires Program Domain Expert consultation to verify state transitions match approved workflow diagrams.
- Code review is accountable to TL; DEV peers may participate but TL has final merge authority.
- Frontend implementation (print formats, dashboards, notifications, status colors) is co-owned by UX (spec accountability) and DEV (technical execution). UX reviews and approves the implemented output against the frontend spec before sprint close.

---

## Phase 4: Testing

| Activity | PO | PM | TL | DEV | QA | FE | PE | UX |
|----------|----|----|-----|-----|----|----|----|----|
| Execute BDD test scenarios | I | I | I | I | **A/R** | I | I | I |
| UAT facilitation (running the session) | C | **A/R** | R | I | I | R | R | I |
| UAT findings triage + go/no-go | **A** | R | C | I | R | C | C | I |
| Verify accounting correctness | I | I | C | I | I | **A/R** | I | I |
| Approve sprint output | **A** | R | C | I | C | C | C | I |
| Report bugs | I | R | I | I | **A/R** | C | C | I |

**Notes:**
- QA owns BDD test scenario execution against docs/spec/test-scenarios.md.
- UAT: PM is the mandatory Facilitator (active running role — reads instructions, records observations, does NOT help participants). TL is a mandatory silent Observer (must be physically present; not Informed = occasionally notified, but present throughout). QA enters all findings to issue tracker within H+1 afternoon. PO makes the go/no-go decision at H+2. See `docs/qa/uat-script.md` for full protocol.
- Accounting correctness verification (GL entries, ISAK 35 mapping, D-02 budget formula) is exclusively the Finance Domain Expert's responsibility.
- Sprint output approval requires PO's sign-off; PM coordinates the demo and triage.
- Bugs are reported and tracked by QA; PM prioritizes them for the backlog.

---

## Phase 5: Delivery

| Activity | PO | PM | TL | DEV | QA | FE | PE | UX |
|----------|----|----|-----|-----|----|----|----|----|
| Setup staging environment | I | C | **A** | R | I | I | I | I |
| Data migration | I | C | **A** | R | I | C | I | I |
| User training | C | **A** | I | I | C | R | R | R |
| Go-live approval | **A** | R | C | I | C | C | C | I |
| Post-launch monitoring | I | **A** | R | R | R | I | I | I |
| Monthly backup restore drill (sign drill log) | I | C | **A/R** | I | I | I | I | I |
| Execute production upgrade (runbook Scenario A/B/C) | I | C | **A/R** | R | I | I | I | I |
| Approve upgrade change window | C | C | **A** | I | I | I | I | I |
| Finance Expert sign-off on staging upgrade test | I | C | C | I | I | **A/R** | I | I |
| Site decommission (irreversible — bench drop-site) | **A** | C | **R** | I | I | I | I | I |

**Notes:**
- Staging environment setup and data migration are technical activities owned by TL (architecture) and executed by DEV.
- User training is led by domain experts who understand the NGO context (FE for finance flows, PE for program flows, UX for navigating the interface). PM owns the training plan and schedule.
- Go-live approval is the PO's final authority, executed only after PM confirms all Level 3 MVP DoD criteria are met.
- Post-launch monitoring is TL/DEV (system health) and QA (regression), coordinated by PM.
- Monthly backup restore drill: TL (as DevOps) executes and signs the drill log per `docs/infra/backup-recovery.md` Section 7. This is a recurring monthly commitment after go-live.
- Production upgrade: TL owns the execution of the upgrade runbook per `docs/infra/upgrade-runbook.md`. Finance Domain Expert must sign off on staging upgrade test results before Scenario B/C production execution.
- Site decommission is irreversible (`bench drop-site` cannot be undone) — PO must authorize in writing before execution. TL executes; confirmation of data export must precede the drop command.

---

## Phase 6: Security Governance & Compliance

Fase ini mencakup deliverable **governance dan keamanan** yang diidentifikasi melalui gap analysis ISO 27001:2022 (lihat `docs/security/iso27001-audit.md`). Deliverable ini bukan fitur software — melainkan dokumen kebijakan, prosedur, dan proses yang menjadi prasyarat go-live dan sertifikasi keamanan.

**Catatan peran:** Untuk tim kecil (2 developer), PM memimpin semua dokumen governance; TL memimpin semua dokumen teknis-governance. QA berperan sebagai pelaksana audit internal. Kolom FE/PE/UX tidak relevan untuk fase ini dan dihilangkan.

---

### 6.1 Dokumen Governance Kritis (sebelum go-live)

| Deliverable | PO | PM | TL | DEV | QA | Target |
|---|---|---|---|---|---|---|
| Information Security Policy | **A** | R | C | I | I | Sprint 1 |
| ISMS Scope Document | C | **A/R** | C | I | I | Sprint 1 |
| Risk Treatment Plan (RTP) | C | R | **A/R** | I | I | Sprint 1 |
| Information Security Objectives | **A** | R | C | I | I | Sprint 1 |
| Offboarding Checklist (developer/DevOps) | C | **A/R** | C | I | I | Sprint 1 |
| NDA Template (developer & DevOps) | **A** | R | C | I | I | Sprint 1 |

**Notes:**
- Information Security Policy adalah dokumen tertinggi dalam hierarki keamanan — harus disetujui PO (pimpinan) secara formal, bukan hanya direview teknis.
- RTP memetakan 27 risiko dari `risk-register.md` dan 16 ancaman dari `threat-model.md` ke kontrol ISO 27001, PIC, dan timeline. Accountable ke TL karena konten teknis; PM yang koordinasi.
- NDA harus ditandatangani semua developer dan DevOps yang punya akses ke production **sebelum** staging environment diaktifkan.
- Offboarding checklist mencakup: revoke GitHub access, disable akun Frappe, revoke API key, transfer credentials ke vault baru, notifikasi ke PM.

---

### 6.2 Dokumen Governance High Priority (Sprint 2–3)

| Deliverable | PO | PM | TL | DEV | QA | Target |
|---|---|---|---|---|---|---|
| Internal Audit ISMS Checklist | **A** | R | C | I | R | Sprint 2 |
| Management Review Template | **A** | R | C | I | I | Sprint 2 |
| Information Classification Policy | C | R | **A** | I | I | Sprint 2 |
| Acceptable Use Policy (AUP) | **A** | R | C | I | I | Sprint 2 |
| Asset Register (data & infrastructure) | I | R | **A/R** | C | I | Sprint 2 |
| Security Awareness Guide (user PDF) | C | R | C | I | **A** | Sprint 3 |
| Contact with Authorities List | C | **A/R** | I | I | I | Sprint 3 |
| Remote Working Security Policy | C | **A/R** | C | I | I | Sprint 3 |
| License & IP Rights Policy | **A** | R | C | I | I | Sprint 3 |

**Notes:**
- Internal Audit Checklist dibuat PM, dieksekusi QA sebagai auditor internal. QA adalah satu-satunya peran yang cukup netral untuk menjalankan audit internal tanpa conflict of interest.
- Asset Register mencakup: data donor/benefisiari/keuangan, backup, credentials, server, API keys — dengan owner dan sensitivity classification per row.
- Security Awareness Guide adalah dokumen satu halaman (PDF) untuk staf NGO, bukan untuk developer. QA yang paling memahami failure mode pengguna, sehingga cocok sebagai accountable untuk konten-nya.
- AUP harus muncul saat onboarding pengguna baru (ditampilkan saat login pertama atau sesi training).

---

### 6.3 Dokumen Governance Medium Priority (Sprint 3–4)

| Deliverable | PO | PM | TL | DEV | QA | Target |
|---|---|---|---|---|---|---|
| Supplier Security Register | C | R | **A** | I | I | Sprint 4 |
| Business Continuity Plan | **A** | R | **A/R** | C | I | Sprint 4 |

**Notes:**
- BCP bersifat co-owned antara PM (proses bisnis) dan TL (aspek teknis/infrastruktur). Keduanya Accountable untuk bagian masing-masing; PO sebagai final approver.
- Supplier Security Register mencakup: ERPNext upstream, hosting provider, library kritis, payment gateway (jika ada). TL paling tahu risk landscape teknis.

---

### 6.4 Aktivitas Keamanan Berkelanjutan

| Aktivitas | PO | PM | TL | DEV | QA | Frekuensi |
|---|---|---|---|---|---|---|
| Quarterly access rights review | C | **A** | R | I | I | Per kuartal |
| Penetration testing (eksternal) | **A** | R | C | I | R | Sebelum go-live & tahunan |
| pip audit + npm audit | I | I | **A** | R | I | Bulanan / saat upgrade |
| CVE patching (Critical: 7 hari) | I | C | **A/R** | R | I | On-demand |
| ISMS management review | **A** | R | C | I | I | Per kuartal |
| Internal audit ISMS | **A** | R | I | I | **R** | Tahunan |
| Incident response drill / tabletop | C | **A** | R | C | R | Tahunan |
| Update DECISIONS.md untuk security decisions | I | I | **A/R** | C | I | Per keputusan |

**Notes:**
- Quarterly access rights review memastikan akun mantan developer/staf sudah dinonaktifkan dan permission setiap user masih sesuai perannya.
- Penetration testing dilakukan oleh pihak eksternal per `docs/security/pentest-scope.md`. QA berperan sebagai liaison dan mendokumentasikan temuan.
- CVE patching: TL memutuskan patch schedule; DEV mengeksekusi. Untuk Critical CVE, SLA 7 hari tidak bisa dinegosiasikan (per SR-DEP).

---

## Decision Authority

For decisions that arise during the project, the following table defines who has **final say** and who must be consulted.

| Decision Type | Final Authority | Must Consult | Must Inform |
|---------------|-----------------|--------------|-------------|
| Add or change a story in the current sprint | PM | PO, TL | DEV, QA |
| Remove a story from the current sprint | PM | PO | DEV, QA |
| Scope change affecting MVP boundary | **PO** | PM, TL | FE, PE |
| Architecture change (new pattern, library, or ERPNext API usage) | **TL** | PM, DEV | PO |
| New DECISIONS.md entry (design decision) | **TL** | FE or PE (if domain-relevant) | PM, PO, DEV |
| Override an existing DECISIONS.md decision | **TL + PO jointly** | PM, FE, PE | DEV, QA |
| Budget or timeline change | **PO** | PM | TL, FE, PE |
| Domain rule clarification (accounting, ISAK 35) | **FE** | TL | PM, DEV, QA |
| Domain rule clarification (program, procurement, MEAL) | **PE** | TL | PM, DEV, QA |
| Merge to main branch | **TL** | DEV | PM, QA |
| Go-live decision | **PO** | PM, TL, FE | All |
| Deprioritize or defer a bug | **PM** | PO (for high severity) | QA, DEV |
| Approve Information Security Policy | **PO** | PM, TL | All |
| Approve Risk Treatment Plan | **TL + PO jointly** | PM | All |
| Accept security risk (risk treatment = accept) | **PO** | TL, PM | DEV, QA |
| Authorize penetration test (target, scope, timing) | **PO** | PM, TL | All |
| Declare security incident (escalation level) | **TL** | PM | PO, All |
| Approve go-live despite open Medium security gap | **PO** | TL, PM | All |

**Key principle:** No design decision that contradicts an existing DECISIONS.md entry may be implemented without a formal update to that document, signed off by TL. The PM is responsible for surfacing contested decisions as blockers in the sprint board, not resolving them unilaterally.
