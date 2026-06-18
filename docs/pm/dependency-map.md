# Fundara — Feature Dependency Map

**Audience:** Project Manager
**Purpose:** Sprint sequencing guide — which DocTypes and features must be built before others can function
**Last Updated:** 2026-06-18

---

## Why This Map Matters

In ERPNext custom app development, build order is not optional — it is a hard technical constraint:

- A DocType with a **Link field** to another DocType will throw errors if the linked DocType does not yet exist in the system.
- A **workflow** cannot be configured until its target DocType exists.
- **GL posting** (debit/credit journal entries) cannot work until the Chart of Accounts is set up correctly.
- **Budget checking** at transaction time requires the Budget DocType to already exist and contain approved records.
- **Fund-tagged transactions** cannot be saved until the Fund master record exists.

This map organizes all Fundara DocTypes into build layers. A developer must not start a layer until all DocTypes in the previous layer are completed and deployed.

---

## Layer 0 — ERPNext Infrastructure (Pre-existing, Configure Only)

These DocTypes are **shipped by ERPNext v16**. No custom development is needed. The team only needs to configure them correctly before Fundara development begins.

| Component | Action Required | Why It Matters |
|---|---|---|
| Company | Configure one Company; set base currency (IDR) | All GL entries, Cost Centers, and Bank Accounts belong to a Company |
| Chart of Accounts | Set up a nonprofit CoA (or import the Fundara template) | All Cash Receipt, Disbursement, and Journal Entry GL postings require valid accounts |
| Fiscal Year | Create the current Fiscal Year | Budget DocType requires a linked Fiscal Year |
| Currency | Enable IDR, USD, EUR (and any grant currencies in use) | Fund master and all transactions carry a currency field |
| Cost Center | Create the organizational Cost Center hierarchy | Project, Activity, Fund Allocation, and all transactions link to Cost Centers |
| Bank Account | Configure at least one Bank Account | Cash Disbursement and Bank Reconciliation link to Bank Account |
| Location | Create at least one Location record | Activity and Fixed Asset require a Location |
| ERPNext User / Role | Create the 7 MVP roles (Finance Manager, Finance Officer, Program Manager, Project Officer, Executive Viewer, Auditor Viewer, System Manager) | Workflows and permission rules depend on these roles |

**Sprint position:** Complete all Layer 0 configuration in **Sprint 1** before any custom DocType development starts.

---

## Layer 1 — Foundation Masters (No Fundara Dependencies)

These are **new custom DocTypes** that Fundara creates, but they only link to ERPNext built-ins (User, Department, Cost Center, Currency, Country, Organization — the last one also being in this layer) or have no external links at all. They can all be built in parallel.

### Organization Context

| DocType | External Links | Notes |
|---|---|---|
| Organization | Country, Currency (ERPNext built-ins), User | The root master; must exist before Office and Department |
| Office | Organization, Country, Cost Center, User | Requires Organization |
| Department | Organization, Department (self-link for hierarchy), Cost Center, User | Requires Organization |
| Cost Center Extension | Custom Fields on ERPNext Cost Center | No new DocType; add Custom Fields to ERPNext built-in |
| Delegation of Authority | Organization, Role, Currency, Department, Office | Requires Organization, Office, Department |

### Funding Context — Pure Masters

| DocType | External Links | Notes |
|---|---|---|
| Funding Source | Organization, Country, User, Department | Requires Organization — links to Donor, Campaign, Business Unit (which are also in this layer, so build them together) |
| Donor | Organization, Country, User | No Fundara dependencies |
| Institutional Donor Profile | Donor | Requires Donor |
| Business Unit | Organization, User, Office, Department, Cost Center | Requires Organization, Office |
| Revenue Stream | Business Unit, Organization, Account (ERPNext) | Requires Business Unit |

### Financial Accountability — Pure Config Masters

| DocType | External Links | Notes |
|---|---|---|
| Accounting Standard Profile | Country, Currency (ERPNext built-ins) | No Fundara dependencies |
| Net Asset Class | Accounting Standard Profile, Account (ERPNext) | Requires Accounting Standard Profile |

### Mission Delivery — Pure Masters

| DocType | External Links | Notes |
|---|---|---|
| Program | User | No Fundara dependencies; links to User only |
| Activity Type | — | No external links at all; pure reference data |

### Grant Context — Pure Masters

| DocType | External Links | Notes |
|---|---|---|
| Donor | (see Funding Context above) | Minimum fields needed before Grant can be created |

### Evidence Context — Pure Masters

| DocType | External Links | Notes |
|---|---|---|
| Evidence Type | — | No external links; pure reference data |

**Sprint position:** Layer 1 can begin in **Sprint 1 (parallel with Layer 0 configuration)** or in **Sprint 2**. Multiple developers can work on different Layer 1 DocTypes simultaneously.

---

## Layer 2 — Core Fund Layer (Depends on Layer 1)

These DocTypes form the central fund management system. They depend on Layer 1 masters being available before they can be built and used.

### Fund Stewardship Context

| DocType | Key Dependencies (Fundara) | Notes |
|---|---|---|
| Fund Type | — | Simple master; seed with 8 MVP types as fixture data |
| Fund | Funding Source (L1), Fund Type (L2 — build Fund Type first), Grant (L3 — see note), User (L0 ERPNext), Currency (L0) | The most important DocType in the system. The `grant` field is optional at creation and only mandatory when `fund_type = Grant Fund` |
| Fund Restriction | Fund | Requires Fund |

### Grant Context

| DocType | Key Dependencies (Fundara) | Notes |
|---|---|---|
| Grant | Donor (L1), Program (L1), Department (L1), Currency (L0), User (L0) | Can exist before Fund is created (by design — D-01 decision) |
| Grant Agreement | Grant | Requires Grant |
| Grant Budget Line | Grant, Grant Agreement | Requires both Grant and Grant Agreement |
| Grant Budget Line Mapping | Grant Budget Line, Fund Budget Line (L3) | The Fund Budget Line mapping can be filled in after L3 is built |
| Grant Reporting Schedule | Grant, Grant Agreement | Requires Grant Agreement |

> **Note on Grant ↔ Fund circular dependency:** Grant is built in Layer 2 because it can exist independently (Pipeline stage precedes Fund creation — this is Decision D-01). The Fund's `grant` field links to Grant but is optional. In practice: build Grant DocType first, then Fund DocType. The `grant` field in Fund will resolve correctly once both exist.

### Financial Accountability — Budget DocTypes

| DocType | Key Dependencies (Fundara) | Notes |
|---|---|---|
| Fund Budget Line | — | Child table of Fund Budget; can be defined early |
| Fund Budget | Fund (L2), Project (L3 — see note), Activity (L3), Cost Center (L0), Fiscal Year (L0), Currency (L0) | Budget requires Fund. The Project/Activity fields are optional (budget can be at fund level without a project). Build Fund Budget after Fund is available |

> **Note:** Fund Budget is placed here because a basic organizational-level budget can exist with only a Fund link. Project-level and Activity-level budgets require Layer 3.

**Sprint position:** Layer 2 begins in **Sprint 3**. Fund Type and Grant should be built before Fund master, as Fund links to both.

---

## Layer 3 — Operational Layer (Depends on Layer 2)

These DocTypes represent the operational structure — projects, activities, and allocations. They depend on Fund and Grant existing.

### Mission Delivery Context

| DocType | Key Dependencies (Fundara) | Notes |
|---|---|---|
| Project | Program (L1), Fund (L2 via Project Fund Allocation child table), Cost Center (L0), User (L0) | Requires Program and Fund |
| Project Fund Allocation | Fund (L2), Project (L3) | Child table of Project |
| Activity | Project (L3), Fund (L2), Fund Budget Line (L2), Activity Type (L1), Cost Center (L0), User (L0) | Requires Project and Fund Budget Line |

### Fund Stewardship Context — Allocation Layer

| DocType | Key Dependencies (Fundara) | Notes |
|---|---|---|
| Fund Allocation | Fund (L2), Program (L1), Project (L3), Activity (L3), Fund Budget Line (L2) | Requires Fund; can allocate to Program without Project if needed |
| Fund Allocation Item | Fund Allocation (L3), Fund Budget Line (L2), Grant Budget Line (L2) | Child table |
| Fund Transfer | Fund (L2) | Requires two Fund records |
| Bridging Fund Settlement | Fund (L2) | Requires Fund records |
| Fund Balance Snapshot | Fund (L2) | Requires Fund; best built alongside Fund Transfer |

### Evidence & Compliance Context — Operational Rules

| DocType | Key Dependencies (Fundara) | Notes |
|---|---|---|
| Evidence Requirement | Evidence Type (L1), Fund (L2) | Requires Evidence Type |
| Evidence | Evidence Type (L1) | The actual evidence record; linked dynamically to any document type |

**Sprint position:** Layer 3 begins in **Sprint 4–5**. Project and Activity must be built before transactions can be tagged with project/activity dimensions.

---

## Layer 4 — Transaction Layer (Depends on Layer 3)

These are the primary financial transaction DocTypes. They require Fund, Project, Activity, and Budget to already exist and have approved records.

### Financial Accountability — Transactions

| DocType | Key Dependencies (Fundara) | Notes |
|---|---|---|
| Cash Receipt | Fund (L2), Project (L3), Donor (L1), Fundraising Campaign (see below), Net Asset Class (L1), Account (L0 ERPNext) | Core inflow transaction; auto-creates Journal Entry |
| Cash Disbursement | Fund (L2), Project (L3), Activity (L3), Fund Budget Line (L2), Account (L0 ERPNext) | Core outflow transaction; requires budget check |
| General Journal Line | Fund (L2), Project (L3), Activity (L3), Fund Budget Line (L2), Net Asset Class (L1) | Child table |
| General Journal | Fund (L2), Project (L3), Cost Center (L0) | Manual adjustment journal |
| Cash Advance | Fund (L2), Project (L3), Activity (L3), Fund Budget Line (L2), User (L0) | Requires Activity to be in Approved or In Progress status |
| Advance Liquidation Line | Fund Budget Line (L2), Account (L0 ERPNext) | Child table |
| Advance Liquidation | Cash Advance (L4), Fund (L2), Project (L3), Activity (L3) | Requires a Paid Cash Advance to exist |
| Additional Advance Payment | Cash Advance (L4) | Requires a Cash Advance in Pending Liquidation status |
| Reimbursement Request | Fund (L2), Project (L3), Activity (L3), Fund Budget Line (L2), Account (L0 ERPNext) | Similar to Cash Advance but for out-of-pocket expenses |

### Financial Accountability — Asset & Reconciliation

| DocType | Key Dependencies (Fundara) | Notes |
|---|---|---|
| Fixed Asset | Fund (L2), Project (L3), Donor (L1), Fund Budget Line (L2), Location (L0), User (L0), Account (L0) | Requires fund and location; auto-generates Depreciation Schedule |
| Depreciation Schedule Line | — | Child table of Depreciation Schedule |
| Depreciation Schedule | Fixed Asset (L4), Fund (L2), Project (L3), Account (L0) | Auto-created when Fixed Asset is submitted |
| Bank Statement Line | — | Child table of Bank Statement Import |
| Bank Statement Import | Bank Account (L0 ERPNext), Fund (L2), Currency (L0) | Requires bank account and fund |
| Bank Reconciliation | Bank Account (L0), Fund (L2), Bank Statement Import (L4) | Requires imported bank statement |

### Financial Accountability — Setup Helpers

| DocType | Key Dependencies (Fundara) | Notes |
|---|---|---|
| Opening Balance Line | Account (L0), Fund (L2), Donor (L1), Net Asset Class (L1), Project (L3) | Child table |
| Opening Balance Assistant | Fiscal Year (L0), Currency (L0) | Must be done before any transactions are posted; auto-creates Journal Entry |
| Budget Revision Line | Fund Budget Line (L2) | Child table |
| Budget Revision | Fund Budget (L2), Fund (L2), Project (L3), Cost Center (L0) | Requires an Active/Approved Fund Budget |

### Funding Context — Campaign Transactions

| DocType | Key Dependencies (Fundara) | Notes |
|---|---|---|
| Fundraising Campaign | Organization (L1), Department (L1), Funding Source (L1), Currency (L0) | Can be built in Layer 1/2 but is shown here because Cash Receipt links to it |
| Donation | Donor (L1), Fundraising Campaign (see above), Funding Source (L1), Currency (L0) | Submitting a Donation should trigger Fund update |

### Fund Stewardship Context — Closure

| DocType | Key Dependencies (Fundara) | Notes |
|---|---|---|
| Fund Closure Checklist | Fund (L2), User (L0) | Requires outstanding advances and transactions to be resolved (data dependency, not just DocType dependency) |
| Fund Closure Checklist Item | — | Child table |
| Grant Closeout Checklist | Grant (L2), User (L0) | Requires outstanding grant items to be resolved |
| Grant Closeout Checklist Item | — | Child table |

**Sprint position:** Layer 4 begins in **Sprint 5–7**. The advance workflow (Cash Advance → Liquidation) is the most complex transaction flow and should be built as a unit.

---

## Layer 5 — Reporting Layer (Depends on Layer 4)

These DocTypes and scripts aggregate data from Layer 4 transactions. They cannot produce meaningful output until transactions exist.

### Reporting Context

| DocType | Key Dependencies (Fundara) | Notes |
|---|---|---|
| Reporting Period | Fiscal Year (L0) | Simple master; can be built early but only useful once transactions exist |
| Report Template | Donor (L1), Fundraising Campaign (L4) | Reference data; can be set up before reports are run |

### Financial Accountability — Analytics

| DocType | Key Dependencies (Fundara) | Notes |
|---|---|---|
| Data Health Check | Fund (L2), Project (L3), Fiscal Year (L0) | Reads all transaction types; build last |
| Import Batch | Currency (L0) | Can be built in Layer 4 as a utility; used across transaction types |

### ERPNext Script Reports (not DocTypes — no separate storage)

| Report | Reads From |
|---|---|
| Fund Utilization Report | Fund (L2), Cash Receipt/Disbursement (L4), Fund Balance Snapshot (L3) |
| Budget vs Actual Report | Fund Budget (L2), Cash Advance (L4), Cash Disbursement (L4) |
| Project Expense Report | Project (L3), Cash Disbursement (L4), Cash Advance (L4) |
| Advance Aging Report | Cash Advance (L4), Advance Liquidation (L4) |
| Evidence Completeness Report | Evidence (L3), Evidence Requirement (L3), all transaction DocTypes (L4) |
| Cash/Bank Transaction Report | Cash Receipt (L4), Cash Disbursement (L4), Bank Statement Import (L4) |
| Basic Dashboard | All of the above |

**Sprint position:** Layer 5 begins in **Sprint 7–9**. Reports are built after the transactions they read are stable.

---

## Critical Path

The minimum sequence of features that must be complete to unlock the first working end-to-end user flow:

**"Create a Fund → Allocate to Project → Record an Expense → See the Balance"**

```
Step 1: Configure ERPNext (Layer 0)
  ├── Chart of Accounts
  ├── Fiscal Year
  ├── Currency (IDR minimum)
  ├── Cost Center
  └── Bank Account

Step 2: Build Organization Masters (Layer 1)
  ├── Organization
  ├── Department
  └── (User roles already in ERPNext)

Step 3: Build Funding Source & Donor (Layer 1)
  └── Funding Source (minimum: create one record for first test)

Step 4: Build Fund Master (Layer 2)
  ├── Fund Type (seed fixture data: 8 types)
  └── Fund (create an Active fund linked to Funding Source)

Step 5: Build Program → Project → Activity (Layer 3)
  ├── Program
  ├── Project (linked to Fund via Project Fund Allocation)
  └── Activity Type + Activity (linked to Project and Fund)

Step 6: Build Fund Budget (Layer 2+3)
  ├── Fund Budget Line (define cost categories)
  ├── Fund Budget (linked to Fund and Project; status → Active)
  └── Fund Allocation (link Fund to Project with approved amount)

Step 7: Build Cash Disbursement (Layer 4)
  └── Cash Disbursement (linked to Fund, Project, Activity, Budget Line)
      → Auto-creates Journal Entry in ERPNext GL

Step 8: Build Fund Balance Snapshot (Layer 3) and Fund Utilization Report (Layer 5)
  └── Fund Utilization Report (reads Cash Disbursement against Fund Budget)
```

**Minimum DocTypes on the critical path:** Organization, Funding Source, Fund Type, Fund, Program, Project, Activity Type, Activity, Fund Budget Line, Fund Budget, Fund Allocation, Cash Disbursement, Fund Balance Snapshot, and the Fund Utilization Report script.

This is approximately **14 DocTypes + 1 report script** before the first working demo is possible. All other DocTypes are parallel tracks that do not block this flow.

---

## Parallel Development Tracks

Once the critical path reaches Layer 3, these tracks can proceed in parallel with different developers:

| Track | Assigned To | Depends On |
|---|---|---|
| **Track A — Advance & Liquidation** | Developer 1 | Layer 3 complete (Project, Activity, Budget) |
| **Track B — Cash Receipt & Bank Reconciliation** | Developer 2 | Layer 2 complete (Fund); Layer 0 (Bank Account) |
| **Track C — Grant Management** | Developer 3 | Layer 1 complete (Donor); can run parallel from Sprint 3 |
| **Track D — Evidence & Compliance** | Developer 4 | Layer 1 (Evidence Type); scales up when transactions exist |
| **Track E — Reports & Dashboard** | Developer 2 or 5 | Layer 4 transactions must be stable |

---

## Summary Table — Layer Assignment

| DocType | Layer | Context |
|---|---|---|
| Organization | 1 | Organization |
| Office | 1 | Organization |
| Department | 1 | Organization |
| Delegation of Authority | 1 | Organization |
| Funding Source | 1 | Funding |
| Donor | 1 | Funding |
| Institutional Donor Profile | 1 | Funding |
| Business Unit | 1 | Funding |
| Revenue Stream | 1 | Funding |
| Program | 1 | Mission Delivery |
| Activity Type | 1 | Mission Delivery |
| Evidence Type | 1 | Evidence |
| Accounting Standard Profile | 1 | Financial Accountability |
| Net Asset Class | 1 | Financial Accountability |
| Fund Type | 2 | Fund Stewardship |
| Fund | 2 | Fund Stewardship |
| Fund Restriction | 2 | Fund Stewardship |
| Grant | 2 | Grant |
| Grant Agreement | 2 | Grant |
| Grant Budget Line | 2 | Grant |
| Grant Budget Line Mapping | 2 | Grant |
| Grant Reporting Schedule | 2 | Grant |
| Fund Budget Line | 2 | Financial Accountability |
| Fund Budget | 2 | Financial Accountability |
| Project | 3 | Mission Delivery |
| Project Fund Allocation | 3 | Mission Delivery |
| Activity | 3 | Mission Delivery |
| Fund Allocation | 3 | Fund Stewardship |
| Fund Allocation Item | 3 | Fund Stewardship |
| Fund Transfer | 3 | Fund Stewardship |
| Bridging Fund Settlement | 3 | Fund Stewardship |
| Fund Balance Snapshot | 3 | Fund Stewardship |
| Evidence Requirement | 3 | Evidence |
| Evidence | 3 | Evidence |
| Fundraising Campaign | 3–4 | Funding |
| Donation | 4 | Funding |
| Cash Receipt | 4 | Financial Accountability |
| Cash Disbursement | 4 | Financial Accountability |
| General Journal | 4 | Financial Accountability |
| Cash Advance | 4 | Financial Accountability |
| Advance Liquidation | 4 | Financial Accountability |
| Additional Advance Payment | 4 | Financial Accountability |
| Reimbursement Request | 4 | Financial Accountability |
| Fixed Asset | 4 | Financial Accountability |
| Depreciation Schedule | 4 | Financial Accountability |
| Bank Statement Import | 4 | Financial Accountability |
| Bank Reconciliation | 4 | Financial Accountability |
| Opening Balance Assistant | 4 | Financial Accountability |
| Budget Revision | 4 | Financial Accountability |
| Fund Closure Checklist | 4 | Fund Stewardship |
| Grant Closeout Checklist | 4 | Grant |
| Import Batch | 4–5 | Financial Accountability |
| Reporting Period | 5 | Reporting |
| Report Template | 5 | Reporting |
| Data Health Check | 5 | Financial Accountability |
| Fund Utilization Report (script) | 5 | Reporting |
| Budget vs Actual Report (script) | 5 | Reporting |
| Project Expense Report (script) | 5 | Reporting |
| Advance Aging Report (script) | 5 | Reporting |
| Evidence Completeness Report (script) | 5 | Reporting |
| Basic Dashboard | 5 | Reporting |
