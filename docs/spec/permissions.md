# Fundara Permission Matrix

**Version:** 1.0  
**Last Updated:** 2026-06-18  
**Source:** workflow.md (sections 3, 42), fundara-domain-contexts 03, 06, 07

---

## Role Definitions

| # | Role | Core Responsibility |
|---|---|---|
| 1 | System Admin | Full system access; configuration, user management, workflow setup |
| 2 | Finance Manager | Approves large transactions, budget exceptions, financial reports, period closing |
| 3 | Finance Officer | Records transactions, reviews advances, reconciles bank, posts entries |
| 4 | Program Manager | Oversees programs, approves project-level decisions, reviews reporting |
| 5 | Project Manager | Manages a specific project; approves activities, advances, and expenditure within project |
| 6 | Field Staff / Program Officer | Executes activities, submits advance requests, uploads evidence |
| 7 | Procurement Officer | Manages RFQ, quotations, bid analysis, purchase orders, vendor compliance |
| 8 | Audit / Internal Control | Read-only across all financial records; flags exceptions, reviews compliance |
| 9 | Management / Executive | Strategic approval for high-value transactions, reserve fund, board-designated funds |
| 10 | Donor Relationship Manager | Manages grant and donor records, reporting schedules, donor reports |
| 11 | Fundraising Officer | Manages campaigns, donations, acknowledgments, campaign reports |
| 12 | HR Manager | Manages staff profiles, payroll allocation, leave; no financial approval authority |
| 13 | Read-only Viewer | Read access to non-sensitive dashboards and approved reports only |

---

## Permission Notation

| Symbol | Meaning |
|---|---|
| **C** | Create a new record |
| **R** | Read / view existing records |
| **W** | Write / edit an existing record |
| **S** | Submit (transition to submitted state, triggers workflow) |
| **A** | Amend (create amendment after submission) |
| **D** | Delete a record |
| **—** | No access |

---

## Permission Matrix

> Column order: Sys Admin | Finance Mgr | Finance Off | Prog Mgr | Project Mgr | Field Staff | Procurement | Audit | Mgmt | Donor Rel | Fundraising | HR | Viewer

### Organization Context

| DocType | Sys Admin | Finance Mgr | Finance Off | Prog Mgr | Project Mgr | Field Staff | Procurement | Audit | Mgmt | Donor Rel | Fundraising | HR | Viewer |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Organization Profile | CRWSAD | R | R | R | R | R | R | R | RW | R | R | R | R |
| Department | CRWSAD | RW | R | R | R | — | R | R | RW | — | — | RW | — |
| Staff Profile | CRWSAD | RW | R | R | R | R (own) | R | R | RW | R | R | CRWSAD | — |
| Organization Location | CRWSAD | RW | R | RW | R | R | R | R | RW | — | — | R | — |
| Fiscal Year | CRWSAD | RWS | R | R | — | — | — | R | R | — | — | — | — |

### Funding Context

| DocType | Sys Admin | Finance Mgr | Finance Off | Prog Mgr | Project Mgr | Field Staff | Procurement | Audit | Mgmt | Donor Rel | Fundraising | HR | Viewer |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Funding Source | CRWSAD | CRWS | RW | R | R | — | — | R | RWS | CRWS | RWS | — | R |
| Donor | CRWSAD | RW | R | R | R | — | — | R | RW | CRWSA | RW | — | — |
| Fundraising Campaign | CRWSAD | RWS | R | RW | R | — | — | R | RWS | RW | CRWS | — | R |
| Donation | CRWSAD | RWSA | CRWS | R | — | — | — | R | R | RW | CRWS | — | — |
| Business Unit | CRWSAD | CRWSA | R | R | — | — | — | R | CRWSA | — | — | — | R |

### Fund Stewardship Context

| DocType | Sys Admin | Finance Mgr | Finance Off | Prog Mgr | Project Mgr | Field Staff | Procurement | Audit | Mgmt | Donor Rel | Fundraising | HR | Viewer |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Fund | CRWSAD | CRWSA | R | R | R | — | — | R | RS | R | R | — | R |
| Fund Allocation | CRWSAD | CRWSA | RWS | RW | R | — | — | R | RS | R | — | — | R |
| Fund Transfer | CRWSAD | CRWSA | RWS | — | — | — | — | R | RS | — | — | — | — |
| Bridging Fund Settlement | CRWSAD | CRWSA | RWS | — | — | — | — | R | RS | — | — | — | — |

### Grant Context

| DocType | Sys Admin | Finance Mgr | Finance Off | Prog Mgr | Project Mgr | Field Staff | Procurement | Audit | Mgmt | Donor Rel | Fundraising | HR | Viewer |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Grant | CRWSAD | RWSA | RW | RW | R | — | — | R | RS | CRWSA | — | — | R |
| Grant Agreement | CRWSAD | RWSA | R | RW | R | — | — | R | RS | CRWSA | — | — | — |
| Grant Budget Line | CRWSAD | CRWSA | CRWS | RW | R | — | — | R | R | CRWS | — | — | — |
| Grant Reporting Schedule | CRWSAD | CRWS | RW | CRWS | R | — | — | R | R | CRWSA | — | — | R |

### Mission Delivery Context

| DocType | Sys Admin | Finance Mgr | Finance Off | Prog Mgr | Project Mgr | Field Staff | Procurement | Audit | Mgmt | Donor Rel | Fundraising | HR | Viewer |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Program | CRWSAD | RW | R | CRWSA | R | R | — | R | RWS | R | R | — | R |
| Project | CRWSAD | RWS | R | CRWSA | RWS | R | R | R | RS | R | — | — | R |
| Activity | CRWSAD | RW | R | CRWS | CRWS | CRW | R | R | R | — | — | — | R |
| Activity Budget | CRWSAD | CRWSA | CRWS | CRWS | RWS | R | — | R | R | — | — | — | R |
| Beneficiary | CRWSAD | — | — | RW | RW | CRW | — | R | — | — | — | — | — |

### Financial Accountability Context

| DocType | Sys Admin | Finance Mgr | Finance Off | Prog Mgr | Project Mgr | Field Staff | Procurement | Audit | Mgmt | Donor Rel | Fundraising | HR | Viewer |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Transaction (Journal Entry / GL Entry) | CRWSAD | RWSA | CRWS | — | — | — | — | R | R | — | — | — | — |
| Cash Advance | CRWSAD | RWSA | CRWS | R | RS | CRS | — | R | R | — | — | — | — |
| Advance Liquidation | CRWSAD | RWSA | CRWS | R | RWS | CRWS | — | R | R | — | — | — | — |
| Budget | CRWSAD | CRWSA | CRWS | CRWS | R | — | — | R | RS | R | R | — | R |
| Budget Revision | CRWSAD | CRWSA | CRWS | CRWS | CRS | — | — | R | RS | — | — | — | — |
| Bank Reconciliation Statement | CRWSAD | RWSA | CRWS | — | — | — | — | R | R | — | — | — | — |

### Procurement Context

| DocType | Sys Admin | Finance Mgr | Finance Off | Prog Mgr | Project Mgr | Field Staff | Procurement | Audit | Mgmt | Donor Rel | Fundraising | HR | Viewer |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Purchase Request | CRWSAD | RWS | RWS | RS | CRWS | CRS | CRWS | R | RS | — | — | — | — |
| Purchase Order | CRWSAD | RWSA | RWS | R | R | — | CRWSA | R | RS | — | — | — | — |
| Vendor | CRWSAD | RWS | R | R | R | — | CRWSA | R | R | — | — | — | — |

### Evidence & Compliance Context

| DocType | Sys Admin | Finance Mgr | Finance Off | Prog Mgr | Project Mgr | Field Staff | Procurement | Audit | Mgmt | Donor Rel | Fundraising | HR | Viewer |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Evidence Document | CRWSAD | RW | RW | RW | RW | CRW | RW | CRWS | R | R | R | — | — |
| Compliance Checklist | CRWSAD | CRWSA | CRW | RW | R | — | RW | CRWS | R | R | — | — | — |

### Reporting Context

| DocType | Sys Admin | Finance Mgr | Finance Off | Prog Mgr | Project Mgr | Field Staff | Procurement | Audit | Mgmt | Donor Rel | Fundraising | HR | Viewer |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Donor Report | CRWSAD | RWSA | CRW | RW | R | — | — | R | RS | CRWSA | — | — | — |
| Fund Utilization Report | CRWSAD | CRWSA | CRW | R | R | — | — | R | RS | R | — | — | R |
| Campaign Report | CRWSAD | RWS | CRW | RW | — | — | — | R | RS | RW | CRWSA | — | R |

---

## Conditional Permissions

These rules override the base permission matrix. They are implemented as server-side permission queries (`has_permission` hooks) or Frappe permission conditions in the DocType controller.

### Project Manager — Scoped to Own Project

- **Project Manager can Write Activity** only if `frappe.session.user` is listed as `project_manager` on the parent Project document. Project Managers cannot edit Activities belonging to other projects.
- **Project Manager can Submit Cash Advance** only if the advance is linked to a Project where they are the assigned `project_manager`.
- **Project Manager can Submit Purchase Request** only if the PR references a Project they own.
- **Project Manager can Submit Budget Revision** only if the revision concerns a Project/Activity budget under their project — and only up to the Finance Manager approval threshold (see Approval Thresholds below).

### Field Staff — Own Records Only

- **Field Staff can Create/Read/Write Cash Advance** only for advances where `requester == frappe.session.user`.
- **Field Staff can Create/Write Advance Liquidation** only for liquidations tied to their own advances.
- **Field Staff can Create/Write Activity** only for activities where they are listed as PIC or team member.
- **Field Staff can Create/Write Evidence Document** only for evidence attached to their own activities or advances.

### Finance Officer — Amount Thresholds

- **Finance Officer can Submit Cash Advance** only if `amount_requested <= 50,000,000 IDR`. Advances above this threshold must be escalated to Finance Manager for final approval.
- **Finance Officer can Submit Purchase Request approval** only if `estimated_amount <= 100,000,000 IDR`.
- **Finance Officer cannot Amend a submitted Transaction** after period lock — amendments require Finance Manager approval.

### Procurement Officer — Vendor and PO Scope

- **Procurement Officer can Create/Write Vendor** records but cannot Approve (Submit) a Vendor to Active status — Vendor approval requires Finance Manager.
- **Procurement Officer can Create Purchase Order** only after a linked Purchase Request has status `Approved`.
- **Procurement Officer cannot Submit Purchase Order** above 200,000,000 IDR without Finance Manager co-approval.

### Donor Relationship Manager — Grant Scope

- **Donor Relationship Manager can Write Grant** only for grants where they are listed as `grant_manager`.
- **Donor Relationship Manager can Submit Donor Report** only for reports linked to grants they manage.
- **Donor Relationship Manager cannot Submit Fund Allocation** — Fund Allocation submission requires Finance Officer or Finance Manager.

### Fundraising Officer — Campaign Scope

- **Fundraising Officer can Write Fundraising Campaign** and **Donation** only for campaigns they created or are assigned to as campaign officer.
- **Fundraising Officer cannot Submit Campaign Report** without Finance Officer review (enforced via Workflow condition: `doc.finance_reviewed == 1`).

### Audit / Internal Control — Read-Only with Exception Flags

- **Audit role has no Create, Write, Submit, or Delete** on any DocType (zero write permissions). Audit access is read-only and covers all financial, fund, grant, procurement, and evidence records regardless of other filters.
- **Audit can Create Compliance Checklist** as an exception to flag findings for corrective action.
- Audit users can see all records including those normally filtered by project/fund scope.

### Management / Executive — High-Value Approvals Only

- **Management can Submit Fund** (approve Fund activation) — this is the final approval step in the Fund Creation workflow.
- **Management can Submit Fund Transfer** — inter-fund transfer above 500,000,000 IDR requires Management approval in addition to Finance Manager.
- **Management / Executive approval is required** for any transaction or budget revision above 500,000,000 IDR (see Approval Thresholds).

### Beneficiary — Data Sensitivity

- **Beneficiary records are restricted** to Project Manager and Field Staff of the owning project only. Finance Manager, Audit, and System Admin can access all records for reporting and audit purposes.
- Sensitive fields (name, ID number, health data) are masked for all roles except System Admin, Project Manager, and Audit when accessed outside the context of the owning project.

### Read-only Viewer — Public Dashboard Only

- **Viewer can Read** only DocTypes explicitly marked as `is_public_report = 1`: Fund Utilization Report, Campaign Report, and approved Donor Reports.
- Viewer has no access to Transaction, Cash Advance, Advance Liquidation, Beneficiary, Vendor, or any Grant detail records.

---

## Notes on ERPNext/Frappe Implementation

1. **Role Permission Manager**: Base permissions are configured in ERPNext Role Permission Manager per DocType per Role.
2. **User Permission**: Scope restrictions (e.g., Project Manager sees only own project's records) are implemented as User Permissions linking the user to allowed Project documents.
3. **has_permission hook**: Conditional rules (amount thresholds, requester == session.user) are implemented in the DocType controller's `has_permission` method or as a server script.
4. **Workflow Condition**: Rules enforced at workflow transition (e.g., `doc.finance_reviewed == 1`) are set as conditions on Frappe Workflow transitions.
5. **Field-level permission**: Sensitive field masking is implemented using Frappe's field-level permission or a `before_load` controller hook.
