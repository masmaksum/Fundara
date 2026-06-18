# Definition of Done — Fundara Development Project

**Project:** Fundara — Fund-centric ERP for Mission-driven Organizations  
**Platform:** ERPNext v16 / Frappe Framework  
**Document owner:** Project Manager  
**Last updated:** 2026-06-18

This document defines the criteria that must be satisfied at three levels before work is declared complete. No story, sprint, or MVP release may be closed while any unchecked criterion remains open.

---

## Level 1: Story DoD (per user story / DocType)

A developer marks a story as **Done** only after all items below are checked. The Tech Lead verifies the checklist before moving the card to the Done column.

### Implementation

- [ ] DocType exists in Frappe with all fields from the agreed spec (field names, types, options, and labels match the design document)
- [ ] Naming series is configured (e.g., `FUND-.YYYY.-.#####`)
- [ ] Workflow is configured in Frappe Workflow (if the DocType has lifecycle states — e.g., Draft → Active → Closed)
- [ ] Workflow states map to the status values defined in `workflow.md`
- [ ] Permissions are set per the permission matrix (roles from `workflow.md` section 3 mapped to read/write/create/delete/submit/cancel as designed)
- [ ] Conditional fields are implemented as specified (e.g., Grant-specific fields appear only when Fund Type = Grant Fund; per `workflow.md` section 43.4)

### Business Logic

- [ ] Server-side validation enforces all mandatory business rules (e.g., Fund End Date must be after Start Date; Restriction Type is required on Fund; per TC-FM-01)
- [ ] GL posting hook is implemented and produces the correct double-entry journal for transaction DocTypes (debit/credit accounts, account currency, fund dimension, project dimension)
- [ ] Budget formula (D-02) is implemented correctly: `Available Budget = Approved Budget − Actual (paid only)`. Approved-but-unpaid advances and purchase orders do NOT reduce the available budget; they appear only in the Pending Payment panel
- [ ] Multi-currency fields are populated correctly: `transaction_currency`, `exchange_rate`, `amount_in_base_currency` (IDR), `amount_in_fund_currency` (per D-04)
- [ ] Fund restriction checks are enforced (ineligible cost categories blocked per fund restriction rules)

### Quality

- [ ] Unit test written and passing (covers the happy path and at least one negative/edge case from the test scenarios in `docs/spec/test-scenarios.md` for the relevant area)
- [ ] No Python traceback appears in the Frappe error log during normal use of the DocType
- [ ] No browser console errors appear during normal use of the form
- [ ] Reviewed and approved by Tech Lead (code review completed; merge approved)
- [ ] Reviewed by Finance Domain Expert if the story involves: GL entries, journal entry rules, ISAK 35 mapping, budget calculations, or any item in `docs/accounting/`
- [ ] Reviewed by Program Domain Expert if the story involves: activity approval workflow, procurement thresholds, advance and liquidation rules, or MEAL integration

### Documentation

- [ ] Any new DECISIONS.md entry required by implementation choices has been drafted and approved by TL
- [ ] Inline docstrings added for non-obvious server scripts and Python methods

---

## Level 2: Sprint DoD (per sprint)

A sprint is **closed** only after all items below are checked. The PM verifies this checklist in the sprint closing session before declaring the sprint complete.

### Stories

- [ ] All sprint stories pass Level 1 DoD (no card is in Done without the full Level 1 checklist signed off)
- [ ] All stories that were In Progress at sprint end but not completed have been triaged: either carried to the next sprint backlog or reverted to the backlog with a clear reason

### Testing

- [ ] BDD test scenarios from `docs/spec/test-scenarios.md` that cover sprint features have been executed and are passing
- [ ] Negative and edge case tests (as specified in each test scenario) have been executed
- [ ] Regression: all test scenarios that were passing in the previous sprint are still passing (no previously-green test has been broken)
- [ ] If any test scenario was skipped, a skip reason has been documented in the sprint report

### Environment

- [ ] Staging environment has been updated with the sprint's changes
- [ ] Staging is running ERPNext v16 and the latest Fundara app code from the sprint branch
- [ ] Staging has the demo dataset loaded and all sprint features can be demonstrated live

### Sprint Review

- [ ] Sprint demo has been conducted (see Sprint Review Agenda Template below)
- [ ] Demo was attended by PO and at least one domain expert relevant to the sprint's features
- [ ] Feedback from the demo has been captured in writing (meeting notes or issue comments)
- [ ] All feedback items have been triaged: accepted (added to backlog), deferred (documented), or rejected (reason recorded)

### Quality Gate

- [ ] Known bugs introduced during the sprint are documented in the backlog with severity assigned (Critical / High / Medium / Low)
- [ ] No Critical or High severity bugs are left without an assigned owner and a target sprint
- [ ] Tech Lead has confirmed no unreviewed code was merged to main during the sprint

---

## Level 3: MVP DoD (for go-live)

MVP is **ready for go-live** only after all items below are checked. The PM and PO review this checklist together. Go-live approval requires sign-off from both PO and Finance Domain Expert.

### Functional Completeness

- [ ] All 15 MVP Definition of Done items from `roadmap.md` section 3.5 are demonstrable:
  1. Create a Funding Source
  2. Create a Fund with restriction type
  3. Allocate a fund to project/activity
  4. Create a Budget Line
  5. Record a cash/bank receipt
  6. Record a cash/bank disbursement
  7. Run advance and liquidation end-to-end
  8. Attach evidence to a transaction
  9. Generate Fund Utilization Report
  10. Generate Budget vs Actual report
  11. Generate Advance Aging report
  12. Show transactions with incomplete evidence
  13. System runs stably on Ubuntu Server 24.04.4
  14. Installation documentation exists
  15. Demo dataset exists
- [ ] All workflow lifecycles (Fund, Activity, Cash Advance, Liquidation) run from Draft to their final terminal state without errors

### Test Coverage

- [ ] All 34 test scenarios in `docs/spec/test-scenarios.md` have been executed and are passing:
  - TC-FM-01 through TC-FM-08 (Fund Management — 8 scenarios)
  - TC-CA-01 through TC-CA-10 (Cash Advance — 10 scenarios)
  - TC-PR-01 through TC-PR-06 (Procurement — 6 scenarios)
  - TC-BG-01 through TC-BG-06 (Budget — 6 scenarios)
  - TC-RP-01 through TC-RP-04 (Reporting — 4 scenarios)
- [ ] No test scenario is marked as skipped without a documented, PO-accepted reason
- [ ] All negative/edge case tests within each scenario have been executed

### Accounting Correctness (verified by Finance Domain Expert)

- [ ] ISAK 35 Laporan Aktivitas generates correctly with the restricted/unrestricted column split (per TC-RP-03): income separated by fund restriction, Pelepasan Pembatasan recorded, beban classified correctly
- [ ] Fund Utilization Report shows correct income, transfer, and expense figures across all three MVP fund types: Grant Fund (USD), Campaign Fund (IDR), Unrestricted Fund (IDR) — per TC-RP-02
- [ ] Multi-currency: a USD Grant Fund balance displays correctly in both USD and IDR at the historical exchange rate; IDR equivalent uses last known rate with footnote when no current rate is available (per TC-FM-01, TC-FM-06, D-04)
- [ ] D-02 compliance verified end-to-end: a Cash Advance in Approved status does NOT reduce the available budget; budget reduces only when status = Paid; the Pending Payment panel shows the approved-but-unpaid amount as a warning (per TC-CA-01, TC-BG-03)
- [ ] GL entries balance: for every transaction DocType, total debits equal total credits in the GL Entry
- [ ] Cash/Bank Receipt and Disbursement produce correct double-entry (Dr Bank / Cr Pendapatan for receipt; Dr Beban / Cr Bank for disbursement)

### Security and Permissions

- [ ] Permission matrix verified: each of the 7 MVP roles (System Manager, Finance Manager, Finance Officer, Program Manager, Project Officer, Executive Viewer, Auditor Viewer) has been tested to confirm correct read/write/submit/cancel access on each relevant DocType
- [ ] Fund and project-level visibility restrictions are working (users see only the funds and projects they are permitted to access)
- [ ] Audit trail is active: every status change, approval action, and GL posting leaves a timestamped log entry in the document's comment/timeline

### Quality Gates

- [ ] No Critical or High severity bugs are open at the time of go-live approval
- [ ] Medium severity bugs have been reviewed by PO; any left open have a documented accept-and-monitor decision

### Performance

- [ ] Fund Utilization Report generates in under 10 seconds for a dataset of 1,000 transactions (tested on the staging server; result documented)
- [ ] Budget vs Actual dashboard loads without timeout for a fund with 500+ budget lines and transactions

### Deployment and Operations

- [ ] System runs stably on Ubuntu Server 24.04.4 (the target platform per D-03 / roadmap.md section 11)
- [ ] Installation guide has been followed from scratch on a clean server and produces a working system
- [ ] Backup and restore has been tested successfully at least once on staging
- [ ] No database services (MySQL, Redis) are exposed to public network interfaces
- [ ] SSL is configured on the staging/production server

### Training and Readiness

- [ ] User training materials have been prepared for the 7 MVP roles (at minimum: a quick-start guide covering the Fund-to-Accountability loop)
- [ ] At least one training session has been conducted with representative end-users (Finance Officer role, Project Officer role)
- [ ] Training feedback has been reviewed; critical usability issues have been fixed or scheduled

### Go-live Approval

- [ ] Go-live formally approved in writing by: **Product Owner** and **Finance Domain Expert**
- [ ] Post-launch monitoring plan is in place (who monitors what, escalation path for critical errors)

---

## Sprint Review Agenda Template

**Duration:** 60 minutes  
**Cadence:** End of every sprint  
**Facilitator:** Project Manager  
**Required attendees:** PO, PM, TL, DEV (all), QA  
**Invited attendees:** FE, PE (domain experts relevant to the sprint's content)  
**Venue:** In-person or video call; staging environment must be accessible on screen

---

| Time | Duration | Segment | Owner | Purpose |
|------|----------|---------|-------|---------|
| 0:00 | 5 min | Opening & logistics | PM | State sprint goal, confirm staging is accessible, note who is present |
| 0:05 | 5 min | Sprint metrics | PM | Velocity: stories planned vs. completed; carry-over count; bug count opened vs. closed |
| 0:10 | 25 min | Live demo | DEV / QA | Demo each completed story against acceptance criteria on staging. PO and domain experts observe and ask questions. No slides — live system only. |
| 0:35 | 10 min | Feedback capture | PM | Open discussion: what works, what does not, what is missing. PM records all feedback items in real time (shared screen or backlog tool). |
| 0:45 | 5 min | Feedback triage | PO + PM | For each feedback item: accept (add to backlog with priority), defer (park for later), or reject (record reason). PO has final call. |
| 0:50 | 5 min | Next sprint preview | PM | PM presents the top candidates for the next sprint backlog. PO confirms or adjusts priorities. TL flags any architectural pre-work needed. |
| 0:55 | 5 min | Blockers and actions | PM | Record any open blockers, assign owners and due dates. Confirm Definition of Done Level 2 checklist is complete for this sprint. |
| 1:00 | — | Close | PM | Sprint officially closed. PM updates sprint board and sends brief written summary to all stakeholders within 24 hours. |

---

### Demo Guidelines for Developers

- Demo only stories that fully pass the Level 1 DoD checklist. Do not demo work-in-progress.
- Follow the Given-When-Then format from the test scenario when demonstrating a feature (state the precondition, perform the action, show the expected outcome).
- For accounting-heavy stories, show the GL Entry that was created alongside the form — Finance Domain Expert will check it.
- For budget stories, show the Budget vs Actual dashboard before and after the transaction to demonstrate D-02 compliance.
- If a demo fails live, do not continue past the failure — mark it as carry-over, note the bug, and move on.

### Post-Review Actions (PM completes within 24 hours)

1. Update backlog with all triaged feedback items.
2. Close the sprint in the project management tool.
3. Send sprint summary email/message to PO and domain experts: stories completed, carry-overs, key decisions made, next sprint goal.
4. Update `docs/pm/` or sprint notes file with any new decisions made during the review.
