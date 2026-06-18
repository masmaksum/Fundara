# Fundara MVP — Feature Complexity Estimate

**Audience:** Project Manager
**Purpose:** T-shirt sizing for MVP sprint planning (~6-month timeline, 10 sprints of 2 weeks each)
**Last Updated:** 2026-06-18

---

## Sizing Guide

| Size | Days | What This Means in ERPNext Development |
|---|---|---|
| **S** | 1–3 days | Simple CRUD. No business logic, no GL posting, no workflow. Pure master data or configuration. |
| **M** | 4–7 days | Workflow + validation rules, moderate business logic, possibly one computed field. No GL posting. |
| **L** | 8–14 days | GL posting integration, multi-DocType interaction, complex validation logic, or multi-step workflow. |
| **XL** | 15+ days | Cross-context integration, multi-currency handling, complex algorithms, or reporting that aggregates across multiple DocTypes. |

**Assumptions:**
- One developer = one feature group at a time.
- Sizes include: DocType creation, field configuration, server-side validation scripts, workflow setup, unit testing, and demo data.
- Sizes do NOT include: UI polish, localization (Bahasa Indonesia labels), documentation, deployment.
- Multi-currency (Decision D-04) affects every transaction DocType — this adds 1–2 days to any DocType that carries currency + exchange rate + base currency equivalent fields.

---

## Feature Groups — Complexity Estimates

---

### FG-01: Organization Setup

**T-shirt size: M (5 days)**

**What is included:**
- Organization DocType
- Office DocType
- Department DocType (extending ERPNext built-in via Custom Fields)
- Cost Center Extension (Custom Fields on ERPNext Cost Center)
- Delegation of Authority + child table

**What makes it this size:**
- Mostly master data with no GL posting or workflow.
- Delegation of Authority has a multi-step approval workflow and date-based validation (valid_from/valid_to) — this adds a day.
- Custom Fields on ERPNext built-ins (Department, Cost Center) require care to avoid breaking ERPNext core behavior.
- Role setup (7 MVP roles) and workspace configuration adds half a day.

**Key dependencies:** ERPNext Company and Cost Center must be configured first (Layer 0).

**Recommended sprint:** Sprint 1

---

### FG-02: Funding Source & Donor Masters

**T-shirt size: M (5 days)**

**What is included:**
- Funding Source DocType
- Donor DocType
- Institutional Donor Profile DocType
- Donor Contact Item (child table)
- Business Unit DocType
- Revenue Stream DocType

**What makes it this size:**
- Six DocTypes, but all are pure masters — no GL posting, no complex workflow.
- Funding Source has conditional logic (linked_donor/linked_campaign/linked_business_unit depends on source_type) — this requires a small client-side script.
- Donor has a status lifecycle (Prospect → Active → Lapsed → Blacklisted) that affects validation on linked documents.
- No multi-currency complexity at this layer.

**Key dependencies:** Organization (FG-01) must exist.

**Recommended sprint:** Sprint 1 (parallel with FG-01)

---

### FG-03: Fund Master & Fund Type

**T-shirt size: L (10 days)**

**What is included:**
- Fund Type DocType (with fixture data for 8 MVP types)
- Fund DocType with full lifecycle workflow (Draft → Active → Suspended → Closing → Closed)
- Fund Restriction DocType with approval workflow
- Multi-currency fields on Fund (D-04): currency, exchange_rate_on_creation, opening_balance, opening_balance_base

**What makes it this size:**
- Fund is the central DocType in the entire system. Getting it wrong cascades everywhere.
- The `grant` field is conditionally mandatory (only when fund_type = Grant Fund) — requires server-side validation.
- Restriction type change on an Active fund requires approval workflow + audit log entry — this is non-trivial.
- Fund lifecycle workflow has 5 states, each with business rule checks.
- Multi-currency: base currency equivalents must auto-compute on save.
- Fund Restriction has its own submit/approval workflow with "only one active restriction per fund" rule.
- Fixture data for Fund Types must be seeded correctly (8 types with correct defaults).

**Key dependencies:** Funding Source (FG-02) must exist. Grant DocType (FG-05) is optionally linked — Fund can be built before Grant, but the `grant` field should be in place from the start.

**Recommended sprint:** Sprint 2

---

### FG-04: Program, Project & Activity

**T-shirt size: L (10 days)**

**What is included:**
- Program DocType
- Project DocType with lifecycle workflow (Concept → Approved → Active → On Hold → Completed → Closed)
- Project Fund Allocation child table (multi-fund support)
- Activity Type DocType (fixture data)
- Activity DocType with 7-state lifecycle workflow (Planned → Approved → In Progress → Completed → Reported → Verified → Closed)

**What makes it this size:**
- Activity has 7 workflow states, each with validation rules:
  - Cannot create a Cash Advance unless Activity is in Approved or In Progress
  - Activity cannot close if it has open advances
- Project cannot close if it has Activities in non-terminal states or open Cash Advances.
- Project Fund Allocation child table requires logic to compute total_budget from child rows.
- Activity links to Fund Budget Line — that DocType must exist at the same time (see FG-06).
- Multi-currency: Project carries a base currency; Project Fund Allocation carries currency + exchange rate.

**Key dependencies:** Program requires no Fundara dependencies. Project requires Program and Fund (FG-03). Activity requires Project and Fund Budget Line (FG-06 — build in the same sprint).

**Recommended sprint:** Sprint 3–4 (build alongside FG-06 Budget Layer)

---

### FG-05: Grant Management

**T-shirt size: XL (18 days)**

**What is included:**
- Grant DocType with 11-state lifecycle workflow (Pipeline → Submitted → Awarded → Agreement Review → Active → Extended → Suspended → Closing → Closed, + Rejected and Cancelled terminals)
- Grant Agreement DocType with amendment history
- Grant Budget Line DocType with multi-currency amounts and internal budget line mapping
- Grant Budget Line Mapping child table
- Grant Reporting Schedule DocType with auto-status transitions (Upcoming → Due Soon → Overdue)
- Grant Closeout Checklist + child table
- Integration with Fund: Fund.grant back-link, validation that Grant Fund matches grant's status

**What makes it this size:**
- The most complex bounded context in the MVP after Financial Accountability.
- 11-state lifecycle with terminal states (Rejected, Cancelled cannot transition further).
- Grant Agreement has amendment history — superseding a prior agreement requires workflow.
- Grant Reporting Schedule requires a scheduled background job to auto-transition Upcoming → Due Soon → Overdue based on due_date relative to today. Scheduled jobs in Frappe require testing on a running instance.
- Grant Budget Line has its own balance computation (amount_current = amount_revised if set, else amount_approved) plus utilization tracking.
- Closeout checklist has conditional mandatory fields (donor_acknowledgement_received is mandatory only for institutional grants — requires check against Grant.grant_type).
- Cross-context integration: closing a Grant must validate that the corresponding Fund is in Closing/Closed status.
- Multi-currency on every amount field: Grant currency (e.g., USD), base currency (IDR), exchange rates.

**Key dependencies:** Donor (FG-02) must exist. Fund (FG-03) must exist for the Grant Fund back-link. This is a bounded context that can be developed semi-independently after Sprint 2 (D-01 decision).

**Recommended sprint:** Sprint 3–5 (run in parallel with FG-04 and FG-06 on a separate developer track)

---

### FG-06: Budget Layer (Fund Budget, Budget Revision)

**T-shirt size: L (10 days)**

**What is included:**
- Fund Budget Line DocType (child table)
- Fund Budget DocType with multi-stage workflow (Draft → Submitted → Review by Program → Review by Finance → Approved → Active → Revised → Closed)
- Budget Revision Line child table
- Budget Revision DocType with workflow
- Fund Allocation DocType with 6-state lifecycle workflow
- Fund Allocation Item child table

**What makes it this size:**
- Fund Budget has an 8-state workflow — the most states of any non-transaction DocType.
- Budget cannot be directly edited after it is Approved/Active; a Budget Revision must be created instead. This requires server-side protection on the Fund Budget fields.
- Budget Revision updates `revised_amount` on Fund Budget Lines on approval — this is a cross-document write operation.
- Fund Allocation requires checking Fund's available_balance before approval.
- Decision D-02 (Available = Approved − Actual paid only): `total_actual_amount` on Fund Budget must only increment when Cash Advance is Paid or Purchase Invoice is posted — this is a deferred hook that depends on Layer 4 transactions being built.
- Multi-currency on all amount fields.

**Key dependencies:** Fund (FG-03) must exist. Project and Activity (FG-04) are needed for project-level budgets but not for org-level budgets. Build FG-06 in the same sprint as FG-04.

**Recommended sprint:** Sprint 3–4

---

### FG-07: Cash Receipt & Cash Disbursement

**T-shirt size: L (10 days)**

**What is included:**
- Cash Receipt DocType with GL posting (Dr Bank / Cr Income)
- Cash Disbursement DocType with GL posting (Dr Expense / Cr Bank)
- Budget availability check on Cash Disbursement before approval (D-02 formula)
- Auto Journal Entry creation on Submit for both DocTypes
- Multi-currency: amount in transaction currency, exchange rate, amount in base currency (IDR)
- Fund/project/activity/budget line tagging on all transactions

**What makes it this size:**
- These are the first DocTypes that touch ERPNext's GL engine — this is where accounting correctness must be validated carefully.
- Auto-creation of Journal Entry on Submit requires Frappe `on_submit` hook. The Journal Entry must carry the correct accounts, amounts, and dimensions.
- Budget check on Cash Disbursement requires querying Fund Budget and Fund Budget Lines — this is a cross-DocType query at transaction time.
- Cash Disbursement has a reconciliation_status field that is updated by the Bank Reconciliation process (a future integration point).
- Multi-currency: if cash_bank_account is in USD and base currency is IDR, the system must compute both correctly.
- Evidence status field: Cash Disbursement has `evidence_status` that the Evidence context will update — design the field now, wire the logic later.

**Key dependencies:** Fund (FG-03), Project/Activity (FG-04), Fund Budget (FG-06), Chart of Accounts (Layer 0) must all exist. Cash Receipt also links to Donor and Fundraising Campaign (FG-02, FG-08).

**Recommended sprint:** Sprint 5

---

### FG-08: Fundraising Campaign & Donation

**T-shirt size: M (7 days)**

**What is included:**
- Fundraising Campaign DocType with 9-state lifecycle workflow
- Campaign Channel Item child table
- Donation DocType with workflow and GL hook (submit triggers Fund update)
- Business rules: anonymous donation handling, restriction enforcement, campaign-linked vs. standalone donations

**What makes it this size:**
- Fundraising Campaign has a complex 9-state lifecycle (Draft → Under Review → Approved → Active → Paused → Completed → Reporting → Closed → Cancelled) but with moderate business logic.
- Donation submit must trigger Fund balance update or Fund creation in Fund Stewardship — this cross-context hook adds complexity.
- Anonymous donation logic (if is_anonymous = 1, donor field must be blank, display name used instead) requires careful validation.
- Multi-currency: Donation carries currency + exchange rate.
- Cash Receipt (FG-07) links to Fundraising Campaign — these two should be built in the same sprint.

**Key dependencies:** Funding Source, Donor (FG-02), Fund (FG-03) must exist.

**Recommended sprint:** Sprint 5 (parallel with FG-07 on a second developer)

---

### FG-09: Advance & Liquidation Workflow

**T-shirt size: XL (16 days)**

**What is included:**
- Cash Advance DocType with 11-state lifecycle workflow (Draft → Submitted → Under Review → Approved → Paid → Pending Liquidation → Overdue → Liquidated → Closed, + Rejected and Cancelled)
- D-02 budget control: only `paid_amount` reduces budget; `pending_payment_flag` is a dashboard warning only
- Auto-computation of aging_category and days_outstanding from payment_date
- Auto-transition to Overdue status when liquidation_due_date passes (scheduled job)
- Advance Liquidation DocType with expense line child table
- Settlement logic: compute refund_amount vs reimbursement_amount; trigger Cash Advance status → Liquidated
- Additional Advance Payment DocType
- Reimbursement Request DocType
- GL posting on Cash Advance payment and on Liquidation approval
- Multi-currency on all DocTypes in this group

**What makes it this size:**
- The advance lifecycle is the most complex workflow in the MVP: 11 states, two terminal states, two separate approval actors (supervisor and finance).
- The Overdue auto-transition requires a scheduled background job (Frappe `scheduler_events` hook). This must be tested on a running instance with time manipulation.
- Advance Liquidation must handle three settlement scenarios: no difference, refund required, or reimbursement required — each has different GL posting logic.
- The budget hook (D-02): `Cash Advance.paid_amount` must trigger update to `Fund Budget Line.actual_amount`. This is a cross-DocType write that must be carefully tested to avoid double-counting when Additional Advance Payments are made.
- Cancellation after Paid state requires a reversal process — cannot simply cancel.
- Advance Liquidation inherits dimensions from Cash Advance (fund, project, activity) as read-only fields.

**Key dependencies:** Fund (FG-03), Project/Activity (FG-04), Fund Budget (FG-06), Cash Disbursement GL setup (FG-07) must all exist. Activity must be in Approved or In Progress status.

**Recommended sprint:** Sprint 6–7 (the most complex feature group in the MVP — allocate two sprints or two developers)

---

### FG-10: Evidence & Compliance

**T-shirt size: M (6 days)**

**What is included:**
- Evidence Type DocType (fixture data: Invoice, Receipt, Payment Proof, Attendance List, Activity Report, Photo, Approval Memo, Quotation, Delivery Note)
- Evidence Requirement DocType with blocking severity logic
- Evidence DocType with verification workflow
- Integration: Evidence links dynamically to any transaction DocType via Dynamic Link field
- Evidence completeness status on Cash Disbursement and Cash Advance (already has `evidence_status` field — wire the logic here)

**What makes it this size:**
- Evidence Type and Evidence Requirement are simple masters.
- Evidence Requirement evaluation at document submission time requires a generic hook that fires on multiple document types — this is a reusable validation script, not a per-DocType change.
- The blocking severity logic (Info / Warning / Blocking / Exception Allowed) requires different system behavior per severity level — moderate complexity.
- Dynamic Link field on Evidence (linked_document_type + linked_document) allows linking to any DocType — Frappe handles this natively but testing against multiple DocTypes takes time.
- Evidence verification workflow is simple (Pending → Verified → Rejected) but the constraint that Verified evidence cannot be deleted adds a server-side guard.

**Key dependencies:** Evidence Type (L1 — can be built in Sprint 1). Evidence Requirement and Evidence need transaction DocTypes (FG-07, FG-09) to exist for meaningful testing, but the DocTypes themselves can be built earlier.

**Recommended sprint:** Sprint 5–6 (start Evidence Type in Sprint 1; wire compliance hooks after transactions are built)

---

### FG-11: Fixed Asset & Depreciation

**T-shirt size: L (12 days)**

**What is included:**
- Fixed Asset DocType with fund/donor tagging
- Depreciation Schedule auto-generation on Fixed Asset submit
- Depreciation Schedule Line child table
- Monthly depreciation posting (Dr Depreciation Expense / Cr Accumulated Depreciation) via scheduled job
- Donor reporting treatment vs. accounting depreciation (some donors expense assets at acquisition)

**What makes it this size:**
- Fixed Asset auto-generates a Depreciation Schedule on submit — this is a Frappe `on_submit` hook that creates a separate DocType.
- Monthly depreciation requires a scheduled job that posts Journal Entries for all Pending schedule lines in the current accounting period.
- The `donor_reporting_treatment` field (Capitalize and Depreciate vs. Expense at Acquisition) adds a conditional reporting layer — the asset is capitalized in GL but shown as expensed in donor reports.
- Multi-currency: acquisition cost in transaction currency + base currency equivalent.
- ERPNext v16 has a built-in Asset module — Fundara extends it with fund tagging rather than replacing it. This means careful custom field design to avoid conflicts.

**Key dependencies:** Fund (FG-03), Project (FG-04), Donor (FG-02), Chart of Accounts (Layer 0), Location (Layer 0) must exist.

**Recommended sprint:** Sprint 7 (after transaction layer is stable; this is lower priority than advance workflow for MVP)

---

### FG-12: Bank Reconciliation

**T-shirt size: L (10 days)**

**What is included:**
- Bank Statement Import DocType with CSV/XLSX parsing
- Bank Statement Line child table with matching_status logic
- Bank Reconciliation DocType with balance computation
- Auto-matching logic (match by transaction date + reference number + amount)
- Manual matching UI

**What makes it this size:**
- CSV/XLSX parsing with error handling (duplicate detection, format validation) requires significant backend work.
- Auto-matching logic (Exact Match / Probable Match / Partial Match) is an algorithm — the edge cases (partial amounts, missing reference numbers, bank narration variations) take time to handle correctly.
- Bank Reconciliation balance formula: `adjusted_bank_balance = closing_balance_per_bank + outstanding_deposits − outstanding_payments`. The reconciliation difference must reach 0.00 before the period can be closed.
- Reconciled transactions cannot be modified without a reversal entry — this requires server-side guards on Cash Disbursement and Cash Receipt.
- `reconciliation_status` on Cash Disbursement (built in FG-07) must be updated by this process — cross-DocType write.

**Key dependencies:** Bank Account (Layer 0), Fund (FG-03), Cash Receipt and Cash Disbursement (FG-07) must exist and have posted transactions.

**Recommended sprint:** Sprint 8 (after transactions are stable and there is enough data to test matching)

---

### FG-13: Opening Balance Assistant

**T-shirt size: M (5 days)**

**What is included:**
- Opening Balance Assistant DocType
- Opening Balance Line child table
- Validation: total_debit must equal total_credit before submission
- Auto Journal Entry creation on Submit (journal_type = Opening Balance)
- One Opening Balance Assistant per fiscal year constraint

**What makes it this size:**
- Mostly data entry with a balancing check — moderate complexity.
- The "only one per fiscal year" constraint requires a server-side duplicate check.
- Multi-currency: each line can carry its own currency and exchange rate.
- The Opening Balance Assistant must be run before any transactions are posted — it is a setup step, not an ongoing transaction.
- GL posting is auto-generated on Submit: this uses the same Journal Entry creation pattern as Cash Receipt/Disbursement.

**Key dependencies:** Fund (FG-03), Net Asset Class (FG-01/L1), Project (FG-04), Chart of Accounts (Layer 0).

**Recommended sprint:** Sprint 4 (must be done before the first production use; can be done in parallel with FG-07)

---

### FG-14: General Journal

**T-shirt size: M (5 days)**

**What is included:**
- General Journal DocType with multi-line journal entry
- General Journal Line child table with fund/project/activity/budget_line dimensions
- Debit = Credit balance check before posting
- Auto-creation of ERPNext Journal Entry on posting
- Journal types: Adjustment, Accrual, Allocation, Correction, Depreciation, Opening Balance, Fund Transfer, Restriction Release, Other

**What makes it this size:**
- Similar pattern to Cash Receipt/Disbursement but with more flexibility (multi-line, multiple accounts).
- Balance check (total_debit == total_credit) is a standard accounting control — well-understood.
- Fund Transfer and Bridging Fund Settlement both auto-create a General Journal — these are already specified in FG-03/Fund Stewardship; the General Journal DocType must exist before those auto-creation hooks can fire.
- Fund dimension is mandatory on journal lines that touch fund-restricted accounts — requires account-type checking.
- Posted journals cannot be edited — reversal via new Correction journal is the only path.

**Key dependencies:** Fund (FG-03), Project/Activity (FG-04), Fund Budget Line (FG-06), Chart of Accounts (Layer 0).

**Recommended sprint:** Sprint 5 (same sprint as Cash Receipt/Disbursement — shares GL posting pattern)

---

### FG-15: Basic Reporting & Dashboard

**T-shirt size: XL (16 days)**

**What is included:**
- Fund Utilization Report (Script Report: fund balance vs. received vs. spent, filterable by fund/period/project)
- Budget vs Actual Report (Script Report: approved budget vs. actual paid, by budget line)
- Project Expense Report (Script Report: all expenses by project/activity)
- Advance Aging Report (Script Report: open advances by staff/fund/project, aging buckets)
- Evidence Completeness Report (Script Report: transactions with missing evidence)
- Cash/Bank Transaction Report (Script Report: all cash/bank movements by fund/period)
- Data Health Check DocType
- Basic Dashboard (Frappe Dashboard with 6–8 number cards and charts)

**What makes it this size:**
- Six Script Reports, each reading from multiple DocTypes. Each report needs filter configuration, query optimization, and drill-down behavior.
- Fund Utilization Report is the most complex: it must aggregate Cash Receipts, Cash Disbursements, Cash Advances (paid only — D-02), General Journals, and Fund Transfers against Fund Allocations. Multi-currency conversion to base currency (IDR) must be consistent.
- Advance Aging Report requires the aging_category calculation (0–7 days, 8–14 days, 15–30 days, >30 days, Overdue) computed from payment_date.
- Evidence Completeness Report must join Evidence Requirement rules against all transaction DocTypes to find which transactions are missing mandatory evidence — a multi-DocType JOIN operation.
- Data Health Check runs 8 diagnostic checks across all transaction types — this is a read-only scan that must produce actionable links to problem documents.
- Dashboard requires Frappe Dashboard configuration (number cards, charts, refresh logic).
- Export to XLSX/PDF is a basic requirement for each report.

**Key dependencies:** All transaction DocTypes (FG-07 through FG-14) must be built and have test data. Specifically: Fund Budget (FG-06), Cash Receipt/Disbursement (FG-07), Cash Advance/Liquidation (FG-09), Evidence (FG-10).

**Recommended sprint:** Sprint 8–9 (reports are built last; partial reports can be built earlier for testing)

---

## Summary Table

| ID | Feature Group | Size | Est. Days | Sprint | Parallelizable With |
|---|---|---|---|---|---|
| FG-01 | Organization Setup | M | 5 | 1 | FG-02 |
| FG-02 | Funding Source & Donor | M | 5 | 1 | FG-01 |
| FG-03 | Fund Master & Fund Type | L | 10 | 2 | FG-05 (separate dev) |
| FG-04 | Program, Project & Activity | L | 10 | 3–4 | FG-05, FG-06 |
| FG-05 | Grant Management | XL | 18 | 3–5 | FG-04, FG-06 |
| FG-06 | Budget Layer | L | 10 | 3–4 | FG-04, FG-05 |
| FG-07 | Cash Receipt & Disbursement | L | 10 | 5 | FG-08, FG-14 |
| FG-08 | Campaign & Donation | M | 7 | 5 | FG-07, FG-14 |
| FG-09 | Advance & Liquidation | XL | 16 | 6–7 | FG-10, FG-11 |
| FG-10 | Evidence & Compliance | M | 6 | 5–6 | FG-07, FG-09 |
| FG-11 | Fixed Asset & Depreciation | L | 12 | 7 | FG-12 |
| FG-12 | Bank Reconciliation | L | 10 | 8 | FG-15 (partial) |
| FG-13 | Opening Balance Assistant | M | 5 | 4 | FG-06 |
| FG-14 | General Journal | M | 5 | 5 | FG-07, FG-08 |
| FG-15 | Basic Reporting & Dashboard | XL | 16 | 8–9 | FG-12 |
| | **TOTAL** | | **145 days** | | |

> **145 developer-days** across 10 sprints (2 weeks each) = approximately **14.5 dev-days per sprint** with 1 developer. With 2 developers on parallel tracks, this is achievable in ~73 dev-days = 7–8 sprints, within a 6-month timeline.

---

## Recommended Sprint Breakdown

### Sprint 1 (Weeks 1–2) — Foundation
**Goal:** All Layer 0 configuration complete. Organization and Funding masters built.

| Work Item | Who | Days |
|---|---|---|
| ERPNext Layer 0 configuration: CoA, Fiscal Year, Currency, Cost Center, Bank Account, Roles | Dev 1 | 3 |
| FG-01: Organization Setup (Organization, Office, Department, Cost Center Extension, Delegation of Authority) | Dev 1 | 5 |
| FG-02: Funding Source & Donor Masters | Dev 2 | 5 |
| Evidence Type (Layer 1 master — simple, start now) | Dev 2 | 1 |

**Sprint 1 Exit Criteria:** Organization exists. Funding Source and Donor can be created. Roles are assigned.

---

### Sprint 2 (Weeks 3–4) — Fund Core
**Goal:** The central Fund DocType is complete and deployable.

| Work Item | Who | Days |
|---|---|---|
| FG-03: Fund Type fixture data + Fund DocType + Fund Restriction | Dev 1 | 10 |
| Accounting Standard Profile + Net Asset Class (Layer 1, needed before Cash Receipt) | Dev 2 | 2 |
| Program DocType + Activity Type DocType (simple Layer 1 masters) | Dev 2 | 2 |
| Demo data: create one Funding Source, one Fund | Dev 1 | 1 |

**Sprint 2 Exit Criteria:** A Fund can be created from a Funding Source and transitioned to Active status. Fund Restriction can be attached with approval.

---

### Sprint 3–4 (Weeks 5–8) — Project, Budget & Grant Track A
**Goal:** Project and budget structure complete. Grant bounded context underway on separate track.

| Work Item | Who | Days |
|---|---|---|
| FG-04: Program, Project, Activity (full workflows) | Dev 1 | 10 |
| FG-06: Fund Budget + Budget Revision + Fund Allocation | Dev 1 | 10 |
| FG-13: Opening Balance Assistant | Dev 1 | 5 |
| FG-05: Grant Management — Grant + Grant Agreement + Grant Budget Line | Dev 2 | 18 (spans into Sprint 5) |

**Sprint 3–4 Exit Criteria:** A Project can be created, linked to a Fund. Budget lines can be approved. An Activity can be created in Approved status. Grant can be created with an Agreement.

---

### Sprint 5 (Weeks 9–10) — Transactions Layer A
**Goal:** Core inflow and outflow transactions posting to GL. Evidence framework wired.

| Work Item | Who | Days |
|---|---|---|
| FG-07: Cash Receipt + Cash Disbursement (GL posting) | Dev 1 | 10 |
| FG-14: General Journal | Dev 1 | 5 |
| FG-08: Fundraising Campaign + Donation | Dev 2 | 7 |
| FG-10: Evidence Requirement + Evidence (with compliance hooks on FG-07 transactions) | Dev 2 | 6 |
| FG-05: Grant Management — Grant Reporting Schedule + Closeout Checklist (continuation) | Dev 2 | — (from Sprint 4) |

**Sprint 5 Exit Criteria:** Cash can be received into a fund (with GL entry). Cash can be disbursed from a fund against a budget line (with budget check and GL entry). Evidence can be attached to a transaction. A donation can be recorded.

> **First working end-to-end demo is possible at the end of Sprint 5.**

---

### Sprint 6–7 (Weeks 11–14) — Advance & Liquidation
**Goal:** The advance-to-liquidation workflow is complete end-to-end. Fixed assets begun.

| Work Item | Who | Days |
|---|---|---|
| FG-09: Cash Advance + Advance Liquidation + Additional Advance + Reimbursement Request | Dev 1 | 16 (spans both sprints) |
| FG-11: Fixed Asset + Depreciation Schedule | Dev 2 | 12 |
| Fund Transfer + Bridging Fund Settlement + Fund Balance Snapshot + Fund Closure Checklist | Dev 2 | 8 |

**Sprint 6–7 Exit Criteria:** Staff can request an advance, get it approved and paid, submit a liquidation with receipts, and the advance closes. Fixed assets can be registered with auto-depreciation schedule. Fund transfers work between funds.

---

### Sprint 8 (Weeks 15–16) — Reconciliation & Data Health
**Goal:** Bank reconciliation live. Data health checks running.

| Work Item | Who | Days |
|---|---|---|
| FG-12: Bank Statement Import + Bank Reconciliation | Dev 1 | 10 |
| Data Health Check DocType (FG-15 partial) | Dev 1 | 3 |
| Import Batch utility DocType | Dev 2 | 3 |
| Opening Balance polishing and testing | Dev 2 | 2 |

**Sprint 8 Exit Criteria:** A bank statement CSV can be imported, auto-matched against transactions, and a reconciliation period can be closed.

---

### Sprint 9 (Weeks 17–18) — Reports & Dashboard
**Goal:** All MVP reports functional and exportable.

| Work Item | Who | Days |
|---|---|---|
| FG-15: Fund Utilization Report + Budget vs Actual Report | Dev 1 | 6 |
| FG-15: Project Expense Report + Advance Aging Report | Dev 1 | 4 |
| FG-15: Evidence Completeness Report + Cash/Bank Transaction Report | Dev 2 | 4 |
| FG-15: Basic Dashboard (8 number cards + 4 charts) | Dev 2 | 6 |

**Sprint 9 Exit Criteria:** All 6 MVP reports run and export to XLSX. Dashboard displays fund balances, budget vs. actual, and advance aging.

---

### Sprint 10 (Weeks 19–20) — Hardening & Demo Dataset
**Goal:** MVP is stable, documented, and demo-ready.

| Work Item | Who | Days |
|---|---|---|
| Bug fixes from Sprint 9 testing | Dev 1 + Dev 2 | 5 |
| Demo dataset: 1 org, 2 funds (1 grant, 1 unrestricted), 1 project, 3 activities, 5 transactions, 1 advance cycle, sample reports | Dev 1 | 3 |
| Installation documentation baseline | Dev 2 | 3 |
| Role permission matrix review | Dev 1 | 2 |
| MVP Definition of Done checklist review | Both | 2 |

**Sprint 10 Exit Criteria:** All 15 MVP Definition of Done items verified. Demo dataset loads cleanly. Installation guide tested on Ubuntu 24.04.4.

---

## Notes on Parallelization

### Where Two Developers Can Work Simultaneously

| Sprint | Developer 1 Track | Developer 2 Track | Risk of Conflict |
|---|---|---|---|
| Sprint 1 | Organization + ERPNext config | Funding Source + Donor | Low — no shared DocTypes |
| Sprint 2 | Fund Master | Config masters + simple Layer 1 | Low |
| Sprint 3–4 | Project + Budget + Activity | Grant bounded context | Low — Grant and Budget have separate fields |
| Sprint 5 | Cash Receipt/Disbursement + Journal | Campaign/Donation + Evidence | Medium — both Dev 1 and Dev 2 will add hooks to transaction DocTypes; coordinate on FG-07 submit hook |
| Sprint 6–7 | Advance + Liquidation | Fixed Asset + Fund Transfer | Low — separate DocType families |
| Sprint 8 | Bank Reconciliation | Import Batch + Opening Balance | Low |
| Sprint 9 | 3 reports | 3 reports + Dashboard | Low — reports read data, do not write |

### Hard Sequencing Rules (Cannot Parallelize)

1. **FG-03 (Fund) must precede FG-04 (Project)** — Activity links to Fund.
2. **FG-06 (Budget) must precede FG-07 (Cash Disbursement)** — Disbursement checks budget at submit time.
3. **FG-07 (Cash Disbursement) must precede FG-09 (Cash Advance Liquidation)** — same GL posting pattern; Liquidation references expense accounts established in FG-07.
4. **FG-04 (Activity) must precede FG-09 (Cash Advance)** — Cash Advance requires Activity to be in Approved/In Progress.
5. **FG-07 and FG-09 must precede FG-15 (Reports)** — Reports have no data to show until transactions exist.

### Critical Risk: Multi-Currency (D-04)

Every transaction DocType carries `currency`, `exchange_rate`, and `amount_in_base_currency`. This is a cross-cutting concern. Before Sprint 5, the team should:

1. Agree on a reusable utility function for `amount_in_base_currency = amount × exchange_rate` computation.
2. Decide how exchange rates are sourced (manual entry per transaction, or pulled from ERPNext Currency Exchange master).
3. Test multi-currency on Fund (FG-03) before applying the pattern to transactions.

If multi-currency is not tested early, fixing it later will require changes to every transaction DocType simultaneously.

---

## Post-MVP Feature Groups (Not In This Estimate)

The following feature groups are in the roadmap but are explicitly out of MVP scope:

| Feature Group | Target Version | Rough Estimate |
|---|---|---|
| Grant Donor Reporting Package | v0.2 | XL (20+ days) |
| Advanced Procurement Rules + Bid Analysis | v0.4 | XL (20+ days) |
| ISAK 35 Report Templates | v0.5 | XL (25+ days) |
| Impact Framework + Indicators | v0.6 | L (14 days) |
| Report Package + Audit Pack | v0.7 | L (12 days) |
| Integration / Import/Export | v0.8 | XL (20+ days) |
| Security Hardening + Deployment | v0.9 | M–L (10–14 days) |
