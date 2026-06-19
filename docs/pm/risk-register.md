# Fundara — Risk Register

**Project:** Fundara — Fund-Centric ERP for NGOs (ERPNext v16 / Frappe Framework)
**Document Owner:** Project Manager
**Last Updated:** 2026-06-18
**Status:** Active

---

## Summary

### Risk Count by Priority

| Priority | Count |
|---|---|
| Critical (High Likelihood + High Impact) | 6 |
| High (High + Medium or Medium + High) | 13 |
| Medium | 8 |
| Low | 5 |
| **Total** | **32** |

---

### Top 5 Risks for Weekly PM Monitoring

| Rank | ID | Risk | Priority | Early Warning Indicators |
|---|---|---|---|---|
| 1 | RISK-TECH-01 | ERPNext Accounting Dimension limits break multi-fund architecture | Critical | Developer reports Accounting Dimension count hitting platform ceiling; fund-per-transaction linkage requires workarounds; Journal Entry test failures referencing dimension overflow |
| 2 | RISK-DOMAIN-01 | Grant Context (04) implementation stalls because key design decisions remain under-specified | Critical | Grant DocType PRs not merged after 2+ sprints; developer questions on Grant-to-Fund FK design recurring; Grant Budget Line ↔ Internal Budget Line mapping undecided in sprint planning |
| 3 | RISK-SCOPE-01 | Multi-currency implementation (D-04) expands scope beyond what "MVP" can absorb | Critical | Exchange-rate edge cases generating >15% of sprint backlog items; FX gain/loss journal spec requires new review cycles; multi-currency blocking sign-off on Financial Accountability Context |
| 4 | RISK-QUAL-01 | Opening Balance migration from Excel leaves fund/restriction balances unreconciled | Critical | Opening Balance Assistant producing unbalanced trial balances in UAT; fund restriction class totals do not match legacy records; UAT sign-off blocked per-fund rather than per-org |
| 5 | RISK-DOMAIN-02 | ISAK 35 report compliance not validated by a qualified Indonesian auditor before release | Critical | No auditor sign-off scheduled; Laporan Aktivitas or Laporan Perubahan Aset Neto output not reviewed by external party; net asset classification mapping disputed by pilot user |

---

## Risk Detail Cards

---

### RISK-TECH-01

| Field | Content |
|---|---|
| **ID** | RISK-TECH-01 |
| **Risk** | ERPNext v16 Accounting Dimension limits (default 4 active dimensions) constrain the multi-dimension model required by Fundara, where every GL line must carry Fund, Project, Activity, Budget Line, and Donor/Campaign simultaneously |
| **Category** | Technical |
| **Likelihood** | High |
| **Impact** | High |
| **Priority** | Critical |
| **Mitigation** | Benchmark Accounting Dimension count in ERPNext v16 before Sprint 1; prototype a GL entry carrying all 5 dimensions and verify no performance degradation; if limit is hit, decide during architecture review whether to use Custom Fields on GL Entry (Frappe-supported pattern) or collapse Donor/Campaign into a single dimension with a composite key |
| **Owner** | Tech Lead |
| **Status** | Open |

---

### RISK-TECH-02

| Field | Content |
|---|---|
| **ID** | RISK-TECH-02 |
| **Risk** | ERPNext v16 Budget module does not natively support the "Available = Approved − Actual (paid only)" formula decided in D-02, requiring a custom budget availability engine that may introduce calculation errors or performance issues at scale |
| **Category** | Technical |
| **Likelihood** | High |
| **Impact** | High |
| **Priority** | Critical |
| **Mitigation** | Build and isolate a custom Budget Availability Check DocType as specified in `06-financial-accountability-context.md`; write BDD test scenarios (already templated in `docs/spec/test-scenarios.md`) covering concurrent approvals from the same budget; add a "Pending Payment" dashboard warning as documented in D-02 to compensate for the absent commitment layer |
| **Owner** | Tech Lead |
| **Status** | Open |

---

### RISK-TECH-03

| Field | Content |
|---|---|
| **ID** | RISK-TECH-03 |
| **Risk** | Multi-currency posting algorithm (D-04) is complex — every transaction must store both transaction-currency and base-currency (IDR) amounts, with periodic unrealized FX gain/loss journals — increasing the probability of silent rounding or FX balance errors that only surface during donor audit |
| **Category** | Technical |
| **Likelihood** | Medium |
| **Impact** | High |
| **Priority** | High |
| **Mitigation** | Follow the algorithm specified in `docs/spec/multicurrency.md`; add an automated reconciliation check that compares Fund Balance in transaction currency vs. Fund Balance converted at period-end rate; include FX edge-case scenarios in QA regression suite; assign a finance domain expert to review the unrealized gain/loss journal before go-live |
| **Owner** | Tech Lead |
| **Status** | Open |

---

### RISK-TECH-04

| Field | Content |
|---|---|
| **ID** | RISK-TECH-04 |
| **Risk** | The "simple input → proper accounting" principle (single-entry UI that generates double-entry GL behind the scenes) requires a reliable auto-posting layer; if posting rules in `docs/accounting/journal-entries.md` diverge from domain context rules, silent GL errors will corrupt donor reports without an obvious user-facing error |
| **Category** | Technical |
| **Likelihood** | Medium |
| **Impact** | High |
| **Priority** | High |
| **Mitigation** | Treat D-05 (domain context = source of truth for logic, `docs/accounting/` = source of truth for GL detail) as a formal rule; add a CI check or document review gate that flags any lifecycle-status change in domain context files without a corresponding update to `docs/accounting/`; include GL balance assertions in all BDD test scenarios that touch cash/bank transactions |
| **Owner** | Tech Lead |
| **Status** | Open |

---

### RISK-TECH-05

| Field | Content |
|---|---|
| **ID** | RISK-TECH-05 |
| **Risk** | Multi-tenancy strategy (D-06) is DEFERRED, meaning deployment architecture for hosting multiple NGO organisations is undecided; if "one site per org" (Opsi A) is adopted close to v1.0, deployment automation and update pipeline will need to be built under time pressure |
| **Category** | Technical |
| **Likelihood** | Medium |
| **Impact** | Medium |
| **Priority** | Medium |
| **Mitigation** | Set a hard decision deadline for D-06 at the start of the sprint before v1.0 feature freeze; begin parallel work on deployment scripting even before the decision so that Opsi A infra is partially ready; document the assumption in the v1.0 release plan so no one is surprised |
| **Owner** | PM + Tech Lead |
| **Status** | Open |

---

### RISK-TECH-06

| Field | Content |
|---|---|
| **ID** | RISK-TECH-06 |
| **Risk** | The Compliance Rule engine (Evidence & Compliance Context) is designed to be fully configurable per fund, donor, and activity type, but implementing a generic rule engine on Frappe without hardcoding is non-trivial and may result in a rule engine that is too rigid for varied NGO donor requirements |
| **Category** | Technical |
| **Likelihood** | Medium |
| **Impact** | Medium |
| **Priority** | Medium |
| **Mitigation** | Define the minimum viable rule-condition schema (condition type, applies-to document, severity, action) in `docs/spec/doctypes/08-evidence-doctypes.md` before development; build two or three real donor rule profiles during UAT to validate configurability; defer "blocking" severity rules to post-MVP if they prove too complex in sprint 1 |
| **Owner** | Tech Lead |
| **Status** | Open |

---

### RISK-DOMAIN-01

| Field | Content |
|---|---|
| **ID** | RISK-DOMAIN-01 |
| **Risk** | Grant Context (04-grant-context.md) is the only domain context with explicitly unresolved sub-questions: the Internal Budget Line ↔ Donor Budget Line mapping approach and budget revision flow are not yet decided, which will block implementation of donor financial reports and grant closeout |
| **Category** | Domain/Requirements |
| **Likelihood** | High |
| **Impact** | High |
| **Priority** | Critical |
| **Mitigation** | Schedule a focused 90-minute decision session with Grant Manager / Finance domain expert before Sprint 2; add DECISION items for the two open questions to `DECISIONS.md` with a deadline; temporarily scope out Grant Budget Revision and focus Sprint 2 on Grant master, Grant Agreement, and Grant Reporting Schedule only |
| **Owner** | PM + Domain Expert (Grant Manager) |
| **Status** | Open |

---

### RISK-DOMAIN-02

| Field | Content |
|---|---|
| **ID** | RISK-DOMAIN-02 |
| **Risk** | ISAK 35 financial statement compliance (Laporan Posisi Keuangan, Laporan Aktivitas, Laporan Perubahan Aset Neto, Laporan Arus Kas) has not been reviewed by a qualified Indonesian auditor or accounting firm, making it possible that report structure or net asset classification does not meet external audit expectations |
| **Category** | Domain/Requirements |
| **Likelihood** | High |
| **Impact** | High |
| **Priority** | Critical |
| **Mitigation** | Engage a registered public accountant (Akuntan Publik) familiar with NGO/yayasan reporting before UAT; provide the ISAK 35 report template output and net asset mapping table from `06-financial-accountability-context.md` for review; treat auditor feedback as a hard requirement for v1.0 go-live |
| **Owner** | PM + Finance Domain Expert |
| **Status** | Open |

---

### RISK-DOMAIN-03

| Field | Content |
|---|---|
| **ID** | RISK-DOMAIN-03 |
| **Risk** | Domain context documents are written in Indonesian, which is appropriate for the target market, but may create bottlenecks if any team members (developers, QA, or integration partners) are not fully fluent, leading to misinterpretation of business rules in domain-rich areas like fund restriction types and compliance exception workflows |
| **Category** | Domain/Requirements |
| **Likelihood** | Medium |
| **Impact** | Medium |
| **Priority** | Medium |
| **Mitigation** | Identify any non-Indonesian-fluent team members at project kick-off; for those individuals, produce English-language summaries of the four most complex domains (Fund Stewardship, Financial Accountability, Grant, Evidence & Compliance) using the domain context files as source; establish a translation review gate for any BDD test scenario written in English that references Indonesian domain terms |
| **Owner** | PM |
| **Status** | Open |

---

### RISK-DOMAIN-04

| Field | Content |
|---|---|
| **ID** | RISK-DOMAIN-04 |
| **Risk** | Beneficiary and participant data in Impact & Learning Context may be sensitive (children, women, disaster-affected communities); without a privacy and data safeguarding policy defined before development, the system may be built without the access controls, consent tracking, and retention rules required by NGO safeguarding standards |
| **Category** | Domain/Requirements |
| **Likelihood** | Medium |
| **Impact** | High |
| **Priority** | High |
| **Mitigation** | Define a minimal data safeguarding policy (consent status field, privacy level field, access role restriction) as documented in `09-impact-learning-context.md` before building Beneficiary Profile; consult with at least one safeguarding-aware NGO practitioner; defer individual beneficiary tracking to post-MVP if policy is not finalised in time |
| **Owner** | PM + Domain Expert (MEAL Officer) |
| **Status** | Open |

---

### RISK-DOMAIN-05

| Field | Content |
|---|---|
| **ID** | RISK-DOMAIN-05 |
| **Risk** | The distinction between Fund Restriction types (Restricted, Temporarily Restricted, Unrestricted, Board-designated) maps to net asset classification in ISAK 35 and FASB ASC 958, but the exact mapping logic has not been reviewed by a domain expert who works with both standards, risking a misclassification that would require a data migration to fix |
| **Category** | Domain/Requirements |
| **Likelihood** | Medium |
| **Impact** | High |
| **Priority** | High |
| **Mitigation** | Create a one-page mapping table showing Fund Restriction Type → Net Asset Class → ISAK 35 report line → FASB equivalent; have this reviewed and signed off by the Finance domain expert before Fund DocType is built; treat this mapping as immutable once approved, requiring a formal change request to revise |
| **Owner** | Finance Domain Expert |
| **Status** | Open |

---

### RISK-SCOPE-01

| Field | Content |
|---|---|
| **ID** | RISK-SCOPE-01 |
| **Risk** | Multi-currency (D-04) was decided to be in MVP, but the full implementation — exchange rate management, unrealized FX gain/loss, dual-currency donor reports — may consume 30–40% of the Financial Accountability sprint capacity, compressing other MVP items like Data Health Check and Opening Balance Assistant |
| **Category** | Scope |
| **Likelihood** | High |
| **Impact** | High |
| **Priority** | Critical |
| **Mitigation** | In sprint planning, explicitly time-box multi-currency work; identify a "minimum viable multi-currency" subset (Fund can store non-IDR currency; transactions record exchange rate; no automated gain/loss journal at MVP — run manually) and negotiate this with stakeholders as acceptable for v0.1; schedule full unrealized gain/loss automation for v0.5 |
| **Owner** | PM |
| **Status** | Open |

---

### RISK-SCOPE-02

| Field | Content |
|---|---|
| **ID** | RISK-SCOPE-02 |
| **Risk** | The Financial Accountability Context alone lists 25+ custom DocTypes and 15 subdomains (Cash & Bank, Advance & Liquidation, Fixed Assets, Bank Reconciliation, Data Health Check, etc.), making it the largest single context in scope and a significant risk for underestimation in sprint planning |
| **Category** | Scope |
| **Likelihood** | High |
| **Impact** | Medium |
| **Priority** | High |
| **Mitigation** | Break Financial Accountability Context into at least 3 sprint epics: (1) Core transaction entry, budget, and advance; (2) Fixed assets and bank reconciliation; (3) Reporting, opening balance, and data health check; assign story points to each DocType individually rather than at the context level; use the 34 BDD scenarios in `docs/spec/test-scenarios.md` as a scope fence |
| **Owner** | PM + Tech Lead |
| **Status** | Open |

---

### RISK-SCOPE-03

| Field | Content |
|---|---|
| **ID** | RISK-SCOPE-03 |
| **Risk** | Deferred decision D-06 (multi-tenancy) may return as a scope demand mid-project if an early NGO pilot customer requests SaaS hosting, forcing an architectural rework while other MVP work is still in flight |
| **Category** | Scope |
| **Likelihood** | Medium |
| **Impact** | High |
| **Priority** | High |
| **Mitigation** | Communicate to all pilot customers and stakeholders that v1.0 is a single-tenant deployment; set D-06 decision deadline at 8 weeks before v1.0 release; if a SaaS pilot is requested early, scope it as a post-v1.0 spike with separate funding and timeline |
| **Owner** | PM |
| **Status** | Open |

---

### RISK-SCOPE-04

| Field | Content |
|---|---|
| **ID** | RISK-SCOPE-04 |
| **Risk** | The "post-MVP" items explicitly excluded from scope (advanced donor CRM, payment gateway integration, offline mobile app, full e-procurement portal, OCR, automated fraud detection, AI impact analysis) may be requested by pilot users during UAT, creating pressure to include them in v1.0 |
| **Category** | Scope |
| **Likelihood** | High |
| **Impact** | Medium |
| **Priority** | High |
| **Mitigation** | Publish a clear "MVP vs. Post-MVP Feature List" document derived from the "Belum perlu" sections of each domain context file; include it in pilot user onboarding materials; establish a formal change-request process requiring sponsor approval for any post-MVP item to be pulled into v1.0 |
| **Owner** | PM |
| **Status** | Open |

---

### RISK-SCOPE-05

| Field | Content |
|---|---|
| **ID** | RISK-SCOPE-05 |
| **Risk** | The dual-language requirement (Indonesian and English UI) across all labels, status values, workflow states, and standard report templates is a cross-cutting concern that, if not planned as a first-class sprint task from Sprint 1, will accumulate untranslated strings that are expensive to retrofit near release |
| **Category** | Scope |
| **Likelihood** | Medium |
| **Impact** | Medium |
| **Priority** | Medium |
| **Mitigation** | Create a translation checklist as a definition-of-done item for every new DocType and report; allocate a dedicated 0.5-day review per sprint for string completeness; use Frappe's built-in translation framework from day one rather than treating i18n as a post-build task |
| **Owner** | Tech Lead + PM |
| **Status** | Open |

---

### RISK-DELIV-01

| Field | Content |
|---|---|
| **ID** | RISK-DELIV-01 |
| **Risk** | Domain expert availability (Grant Manager, Finance Manager, MEAL Officer) is the primary single point of failure for requirements clarification; if these individuals are unavailable during sprint reviews or decision sessions, implementation decisions will be made by developers without domain authority |
| **Category** | Delivery |
| **Likelihood** | High |
| **Impact** | High |
| **Priority** | Critical |
| **Mitigation** | Formalise domain expert availability commitments (minimum 4 hours/week per expert) before Sprint 1; identify a deputy for each expert who can answer domain questions in their absence; hold decision sessions at the start of sprints, not the end, so blockers surface early; document every domain decision in `DECISIONS.md` so oral context is not lost |
| **Owner** | PM |
| **Status** | Open |

---

### RISK-DELIV-02

| Field | Content |
|---|---|
| **ID** | RISK-DELIV-02 |
| **Risk** | The project has 10 bounded contexts with heavy cross-context dependencies (Fund Stewardship → Financial Accountability → Reporting is the critical path); if the Fund and Financial Accountability contexts slip, Reporting, Grant, and Evidence contexts cannot be properly tested or demonstrated to stakeholders |
| **Category** | Delivery |
| **Likelihood** | Medium |
| **Impact** | High |
| **Priority** | High |
| **Mitigation** | Define a dependency graph for the 10 contexts and sequence sprint epics accordingly: Organization → Funding → Fund Stewardship → Grant → Mission Delivery → Financial Accountability → Procurement → Evidence → Reporting → Impact; treat Fund Stewardship and Financial Accountability as must-complete before any downstream context is marked "done" in the sprint plan |
| **Owner** | PM + Tech Lead |
| **Status** | Open |

---

### RISK-DELIV-03

| Field | Content |
|---|---|
| **ID** | RISK-DELIV-03 |
| **Risk** | The deployment automation script and demo data fixtures are explicitly flagged as not yet ready in READINESS.md; without these, UAT setup will be manual and slow, compressing the testing window available before the release deadline |
| **Category** | Delivery |
| **Likelihood** | High |
| **Impact** | Medium |
| **Priority** | High |
| **Mitigation** | Assign deployment scripting as a parallel workstream starting no later than Sprint 2; build demo data fixtures (JSON) incrementally — one context per sprint — rather than waiting until all contexts are complete; make "UAT environment can be reset and re-seeded in under 30 minutes" a release gate criterion |
| **Owner** | Tech Lead |
| **Status** | Open |

---

### RISK-DELIV-04

| Field | Content |
|---|---|
| **ID** | RISK-DELIV-04 |
| **Risk** | External API integrations (payment gateway for donation receipts, KoboToolbox for MEAL data, bank API for reconciliation) are all post-MVP, but pilot NGO customers may have existing data in these systems and expect data to flow into Fundara at go-live |
| **Category** | Delivery |
| **Likelihood** | Medium |
| **Impact** | Medium |
| **Priority** | Medium |
| **Mitigation** | Confirm with each pilot NGO during onboarding whether they have active integrations with any of these systems; if yes, assess whether a manual CSV import path (already in MVP scope) is sufficient for go-live; document integration as a post-v1.0 item in the pilot agreement to manage expectations |
| **Owner** | PM |
| **Status** | Open |

---

### RISK-DELIV-05

| Field | Content |
|---|---|
| **ID** | RISK-DELIV-05 |
| **Risk** | ERPNext v16 is described in DECISIONS.md as having an ecosystem where "not all plugins have updated yet"; if Fundara depends on any Frappe/ERPNext community app (HR, Payroll, CRM) that has not been ported to v16, that dependency will block implementation or require a custom fork |
| **Category** | Delivery |
| **Likelihood** | Medium |
| **Impact** | Medium |
| **Priority** | Medium |
| **Mitigation** | Produce an explicit dependency manifest listing every Frappe/ERPNext module used by Fundara and verify each one is fully functional on v16 before Sprint 1; flag any module requiring a community fork as a separate risk item; prefer using ERPNext core modules over community apps wherever the core module is sufficient |
| **Owner** | Tech Lead |
| **Status** | Open |

---

### RISK-QUAL-01

| Field | Content |
|---|---|
| **ID** | RISK-QUAL-01 |
| **Risk** | Most target NGOs are currently operating from Excel; the Opening Balance Assistant must correctly import fund balances, restriction classes, donor balances, and per-fund net asset totals from legacy data — any error here will produce a permanently incorrect starting point that is difficult to correct post-go-live |
| **Category** | Quality |
| **Likelihood** | High |
| **Impact** | High |
| **Priority** | Critical |
| **Mitigation** | Build the Opening Balance Assistant as a wizard with validation rules (assets = liabilities + net assets; total net assets reconcile to sum of fund balances by restriction class); require two-person review (Finance Officer + Finance Manager) before confirming any opening balance import; test the assistant against at least two real legacy Excel datasets during UAT, not just synthetic test data |
| **Owner** | Tech Lead + Finance Domain Expert |
| **Status** | Open |

---

### RISK-QUAL-02

| Field | Content |
|---|---|
| **ID** | RISK-QUAL-02 |
| **Risk** | The 34 BDD test scenarios in `docs/spec/test-scenarios.md` cover happy paths and some edge cases, but the fund-restriction enforcement logic, multi-fund expense allocation, and bridging fund settlement involve complex state transitions that are not fully covered, leaving gaps that could manifest as compliance failures in real operations |
| **Category** | Quality |
| **Likelihood** | Medium |
| **Impact** | High |
| **Priority** | High |
| **Mitigation** | Expand BDD scenarios specifically for: (a) fund restriction violation detection; (b) concurrent budget requests from the same budget; (c) bridging fund settlement with partial eligibility; (d) grant closeout with outstanding advances; schedule a domain expert walkthrough of these scenarios before they are handed to QA |
| **Owner** | Tech Lead + QA |
| **Status** | Open |

---

### RISK-QUAL-03

| Field | Content |
|---|---|
| **ID** | RISK-QUAL-03 |
| **Risk** | The Delegation of Authority (DoA) and RBAC permission matrix covers 13 roles × 30+ DocTypes, but the intersection of role-based permissions with fund-level and project-level data segmentation (a Finance Officer at Field Office A should not see Fund data for Field Office B) is a complex row-level security problem that ERPNext's standard Role Permission Manager may not handle natively |
| **Category** | Quality |
| **Likelihood** | Medium |
| **Impact** | High |
| **Priority** | High |
| **Mitigation** | Prototype row-level data isolation using Frappe User Permission framework before Sprint 3; test with a realistic multi-office scenario (two field offices, shared donor) during development; if Frappe User Permission is insufficient, design a custom permission rule layer and include it in the scope of Sprint 3 explicitly |
| **Owner** | Tech Lead |
| **Status** | Open |

---

### RISK-QUAL-04

| Field | Content |
|---|---|
| **ID** | RISK-QUAL-04 |
| **Risk** | Donor report data traceability — the requirement that "every number in a donor report must be drill-down traceable to the transaction and evidence" — is one of the most architecturally demanding requirements in the Reporting Context; if this is not tested against real donor report formats (e.g., EU, USAID, or Indonesian government grant formats) before UAT, it may fail during the first live donor report cycle |
| **Category** | Quality |
| **Likelihood** | Medium |
| **Impact** | High |
| **Priority** | High |
| **Mitigation** | Collect at least two real donor report templates (formatted Excel or Word tables from actual grant agreements used by pilot NGOs) before Reporting Context development; use these as acceptance criteria for the Donor Financial Report DocType; verify that every line in the sample report can be traced to a transaction in Fundara |
| **Owner** | PM + Finance Domain Expert |
| **Status** | Open |

---

### RISK-QUAL-05

| Field | Content |
|---|---|
| **ID** | RISK-QUAL-05 |
| **Risk** | The Data Health Check feature (which scans for transactions without fund, advance overdue, journal not balanced, fund balance negative, etc.) is designed as an MVP feature but may be developed late in the release cycle, meaning that data quality issues accumulated during development and early UAT will not be detectable until just before release |
| **Category** | Quality |
| **Likelihood** | Medium |
| **Impact** | Medium |
| **Priority** | Medium |
| **Mitigation** | Build the Data Health Check module in the same sprint as the first complete transaction flow (not at the end of the project); treat a clean Data Health Check run as a sprint definition-of-done gate for Financial Accountability Context; seed the UAT environment with intentionally broken data to validate that the check catches all documented issue types |
| **Owner** | Tech Lead |
| **Status** | Open |

---

### RISK-QUAL-06

| Field | Content |
|---|---|
| **ID** | RISK-QUAL-06 |
| **Risk** | The Activity form for field staff is identified in Mission Delivery Context as a risk if it is "too heavy", but there is currently no UI/UX mockup or user test that validates the form design against actual field staff usage patterns, risking poor adoption among the primary data-entry users |
| **Category** | Quality |
| **Likelihood** | Medium |
| **Impact** | Medium |
| **Priority** | Medium |
| **Mitigation** | Conduct a 30-minute prototype test of the Activity form with at least 2 field staff representatives before the Mission Delivery sprint is marked done; capture the maximum number of fields a field staff user can complete in a single session without dropping off; enforce a "field staff form = maximum 12 fields on screen at once" design constraint |
| **Owner** | PM + UX (if available) |
| **Status** | Open |

---

### RISK-QUAL-07

| Field | Content |
|---|---|
| **ID** | RISK-QUAL-07 |
| **Risk** | Cost-sharing and split-fund GL formula (documented in `docs/spec/cost-sharing.md`) involves allocating shared costs (e.g., staff salaries) across multiple funds proportionally; this is a high-risk area for rounding errors and for producing incorrect fund balances if the allocation formula is not validated against real payroll data |
| **Category** | Quality |
| **Likelihood** | Low |
| **Impact** | High |
| **Priority** | High |
| **Mitigation** | Build automated rounding reconciliation into the cost-sharing journal so that the sum of allocated amounts always equals the total amount (any cent-level rounding difference is posted to a designated rounding account); test with a real salary allocation scenario across at least 3 funds before go-live |
| **Owner** | Tech Lead + Finance Domain Expert |
| **Status** | Open |

---

### RISK-QUAL-08

| Field | Content |
|---|---|
| **ID** | RISK-QUAL-08 |
| **Risk** | The Audit Trail requirement (every action on every DocType must be logged with user, timestamp, old value, and new value) is a cross-cutting technical requirement; if not implemented as a framework-level concern from Sprint 1, individual DocType developers may implement it inconsistently or skip it for custom server-side operations |
| **Category** | Quality |
| **Likelihood** | Low |
| **Impact** | Medium |
| **Priority** | Low |
| **Mitigation** | Leverage Frappe's built-in Document Version and Activity Log features as the baseline; define a custom audit trail standard for server-side scripts (e.g., bulk operations, scheduled jobs) where Frappe's automatic logging does not apply; include audit trail completeness in the definition-of-done for every DocType |
| **Owner** | Tech Lead |
| **Status** | Open |

---

### RISK-TECH-07

| Field | Content |
|---|---|
| **ID** | RISK-TECH-07 |
| **Risk** | Frappe Workflow engine configuration (6 workflows defined in `docs/spec/workflows.md`) covers only the main document lifecycles; the cross-context approval chains — where, for example, a Fund Allocation approval triggers an Activity budget check which triggers a Procurement threshold check — are not covered by standard Frappe Workflow and may require custom controller logic that is fragile to ERPNext upgrades |
| **Category** | Technical |
| **Likelihood** | Low |
| **Impact** | Medium |
| **Priority** | Low |
| **Mitigation** | Keep cross-context approval logic in isolated server-side event hooks (not in Frappe Workflow states) so that ERPNext upgrades do not silently break the chain; document each hook with a comment referencing the domain context business rule it implements; include upgrade testing of all hooks in the v1.0 release checklist |
| **Owner** | Tech Lead |
| **Status** | Open |

---

### RISK-DELIV-06

| Field | Content |
|---|---|
| **ID** | RISK-DELIV-06 |
| **Risk** | There is no formal project schedule or sprint plan in the current documentation, making it impossible for the PM to forecast delivery dates, identify the critical path, or communicate realistic milestones to NGO pilot customers and potential investors |
| **Category** | Delivery |
| **Likelihood** | High |
| **Impact** | Medium |
| **Priority** | High |
| **Mitigation** | Produce a sprint plan within the first week of development, using the 10 domain contexts as the basis for epic definition and the 80+ DocType specs as the basis for story sizing; establish a weekly PM status report cadence; communicate milestones to pilot customers as "target windows" rather than fixed dates until the team velocity is established after Sprint 2 |
| **Owner** | PM |
| **Status** | Open |

---

### RISK-SCOPE-06

| Field | Content |
|---|---|
| **ID** | RISK-SCOPE-06 |
| **Risk** | Organization Context permits multi-office, multi-program, multi-currency, and multi-level cost center hierarchies from day one; while this is a design principle, it significantly increases the permutation space for permission and data isolation testing, which could extend QA cycles beyond the allocated sprint time |
| **Category** | Scope |
| **Likelihood** | Low |
| **Impact** | Medium |
| **Priority** | Low |
| **Mitigation** | Define a "reference configuration" for UAT — two offices, three departments, two programs, two funds — and use this as the standard test harness; test more complex configurations (5 offices, 10 funds) in a dedicated regression sprint before v1.0 rather than in every sprint |
| **Owner** | PM + QA |
| **Status** | Open |

---

### RISK-INFRA-01

| Field | Content |
|---|---|
| **ID** | RISK-INFRA-01 |
| **Risk** | Disk space exhaustion causes production application outage — Frappe/ERPNext writes logs, backups, and file attachments continuously; a full disk crashes the application silently and is the most common cause of production NGO outage per `docs/infra/monitoring-spec.md` |
| **Category** | Infrastructure |
| **Likelihood** | High |
| **Impact** | High |
| **Priority** | Critical |
| **Mitigation** | Configure monitoring alerts at 75% (warning) and 88% (critical) disk usage per monitoring-spec.md §2.1; keep maximum 3 days of local backups (backup-recovery.md §2.4); configure logrotate for Frappe logs via `bench setup logrotate`; set monthly restore drill to force disk hygiene review; alert channel must page the DevOps/TL on-call |
| **Owner** | Tech Lead |
| **Status** | Open |
| **Early Warning** | Netdata disk alert fires at >75% usage; Frappe error log shows ENOSPC errors; backup cron job fails silently (check monitoring alert for backup job failure) |

---

### RISK-INFRA-02

| Field | Content |
|---|---|
| **ID** | RISK-INFRA-02 |
| **Risk** | GPG encryption passphrase for offsite backups is lost, rendering all encrypted remote backups permanently unrecoverable — loss of this single key equals loss of all backup history |
| **Category** | Infrastructure |
| **Likelihood** | Low |
| **Impact** | High |
| **Priority** | High |
| **Mitigation** | Store GPG passphrase in a secrets manager (Bitwarden Teams or equivalent) with at least two authorized key holders (TL + PM); never store only locally; test key retrieval from secrets manager quarterly; document key recovery procedure in the BCP; include key material audit in quarterly access review |
| **Owner** | Tech Lead + PM |
| **Status** | Open |
| **Early Warning** | Single key holder leaves organization; secrets manager account access is not verified in quarterly review; restore drill fails decryption step |

---

### RISK-INFRA-03

| Field | Content |
|---|---|
| **ID** | RISK-INFRA-03 |
| **Risk** | SSL certificate expiry or Certbot auto-renewal failure makes the production site inaccessible to all users (browsers show hard security error, no workaround for end users) |
| **Category** | Infrastructure |
| **Likelihood** | Medium |
| **Impact** | High |
| **Priority** | High |
| **Mitigation** | Configure Certbot auto-renewal via systemd timer per environment-spec.md §3.6; configure monitoring alert at <30 days (warning) and <7 days (critical) remaining per monitoring-spec.md §2.2; test renewal with `certbot renew --dry-run` monthly; ensure port 80 remains open (required for Let's Encrypt ACME challenge) |
| **Owner** | Tech Lead |
| **Status** | Open |
| **Early Warning** | Uptime Kuma SSL monitor alerts <30 days; `certbot renew --dry-run` fails in scheduled test; monitoring alert for certificate expiry fires |

---

### RISK-INFRA-04

| Field | Content |
|---|---|
| **ID** | RISK-INFRA-04 |
| **Risk** | A major ERPNext version upgrade (v16 → v17+) breaks Fundara custom fields, server scripts, or workflow configurations — upgrade-runbook.md Scenario C identifies database mid-migration rollback as the highest-risk operation with 30–90 minute recovery time and possible partial migration state |
| **Category** | Infrastructure |
| **Likelihood** | Medium |
| **Impact** | High |
| **Priority** | High |
| **Mitigation** | Follow upgrade-runbook.md Scenario C protocol strictly: audit all `frappe.get_doc` and `frappe.db.get_value` calls against breaking changes; test on staging for minimum 2 weeks before production; require Finance Domain Expert sign-off on staging accounting correctness after upgrade; never upgrade production on a Friday; maintain a rollback snapshot (VM snapshot or db dump) taken immediately before production migration |
| **Owner** | Tech Lead |
| **Status** | Open |
| **Early Warning** | ERPNext v17 release announced; breaking changes in changelog affect Fundara DocTypes; staging upgrade test fails any of the 34 BDD scenarios; Finance Domain Expert reports GL discrepancy on staging post-upgrade |

---

### RISK-INFRA-05

| Field | Content |
|---|---|
| **ID** | RISK-INFRA-05 |
| **Risk** | In multi-site deployment (post-D-06), Redis cache is shared across all sites on the same bench; a Redis misconfiguration or Frappe bug could cause cross-site cache pollution, exposing one NGO's data to another organization's users |
| **Category** | Infrastructure |
| **Likelihood** | Low |
| **Impact** | High |
| **Priority** | High |
| **Mitigation** | Applies only after D-06 multi-site is enabled; monitor Redis namespace isolation in staging before enabling a second live site; include Redis cross-site test in pentest scope per docs/security/pentest-scope.md; consider separate Redis instance per org for high-sensitivity deployments (adds infrastructure cost); document as accepted risk if single-tenant deployment per server |
| **Owner** | Tech Lead |
| **Status** | Open — triggered only when D-06 is activated |
| **Early Warning** | Frappe logs show cache key collisions; user reports seeing another organization's data; Redis keyspace inspection shows unexpected cross-site keys |

---

## Risk Ownership Summary

| Owner | Risk IDs |
|---|---|
| Tech Lead | RISK-TECH-01, RISK-TECH-02, RISK-TECH-03, RISK-TECH-04, RISK-TECH-06, RISK-TECH-07, RISK-QUAL-03, RISK-QUAL-05, RISK-QUAL-07, RISK-QUAL-08, RISK-DELIV-03, RISK-DELIV-05, RISK-INFRA-01, RISK-INFRA-03, RISK-INFRA-04, RISK-INFRA-05 |
| PM | RISK-SCOPE-01, RISK-SCOPE-02, RISK-SCOPE-03, RISK-SCOPE-04, RISK-DELIV-04, RISK-DELIV-06, RISK-DOMAIN-03 |
| PM + Tech Lead | RISK-TECH-05, RISK-DELIV-02, RISK-SCOPE-05, RISK-INFRA-02 |
| PM + Domain Expert | RISK-DOMAIN-01, RISK-DOMAIN-02, RISK-QUAL-04 |
| Finance Domain Expert | RISK-DOMAIN-05 |
| Tech Lead + Finance Domain Expert | RISK-QUAL-01, RISK-QUAL-07 |
| Tech Lead + QA | RISK-QUAL-02 |
| PM + Domain Expert (MEAL) | RISK-DOMAIN-04 |
| PM + UX | RISK-QUAL-06 |
| PM + Finance Domain Expert | RISK-TECH-03 |
| Tech Lead + Domain Expert | RISK-DELIV-05 |
| PM + QA | RISK-SCOPE-06 |

---

## Change Log

| Date | Change | Changed By |
|---|---|---|
| 2026-06-18 | Initial version created from domain context audit, DECISIONS.md, and READINESS.md | PM |
| 2026-06-20 | Tambah 5 risiko infrastruktur baru (RISK-INFRA-01 s/d RISK-INFRA-05) berdasarkan audit dokumen infra vs PM gap analysis | PM |
