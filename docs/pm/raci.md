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

**Notes:**
- DEV is solely responsible for DocType implementation; TL is consulted to confirm adherence to architecture decisions.
- GL hooks require Finance Domain Expert consultation to ensure correct debit/credit mapping before merge.
- Frappe Workflow configuration requires Program Domain Expert consultation to verify state transitions match approved workflow diagrams.
- Code review is accountable to TL; DEV peers may participate but TL has final merge authority.

---

## Phase 4: Testing

| Activity | PO | PM | TL | DEV | QA | FE | PE | UX |
|----------|----|----|-----|-----|----|----|----|----|
| Execute BDD test scenarios | I | I | I | I | **A/R** | I | I | I |
| UAT (user acceptance testing) | **A/R** | C | I | I | C | R | R | I |
| Verify accounting correctness | I | I | C | I | I | **A/R** | I | I |
| Approve sprint output | **A** | R | C | I | C | C | C | I |
| Report bugs | I | R | I | I | **A/R** | C | C | I |

**Notes:**
- QA owns BDD test scenario execution against docs/spec/test-scenarios.md.
- UAT involves PO and both domain experts (FE for accounting stories, PE for program/procurement stories) — PO has final sign-off.
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

**Notes:**
- Staging environment setup and data migration are technical activities owned by TL (architecture) and executed by DEV.
- User training is led by domain experts who understand the NGO context (FE for finance flows, PE for program flows, UX for navigating the interface). PM owns the training plan and schedule.
- Go-live approval is the PO's final authority, executed only after PM confirms all Level 3 MVP DoD criteria are met.
- Post-launch monitoring is TL/DEV (system health) and QA (regression), coordinated by PM.

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

**Key principle:** No design decision that contradicts an existing DECISIONS.md entry may be implemented without a formal update to that document, signed off by TL. The PM is responsible for surfacing contested decisions as blockers in the sprint board, not resolving them unilaterally.
