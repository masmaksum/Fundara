# Fundara — Frontend Form Layout Specification

**Version:** 1.0  
**Date:** 2026-06-19  
**Target:** Frappe v16 / ERPNext v16  
**Audience:** Frontend developers writing Frappe client scripts and configuring DocType form layouts

---

## Document Scope

This document specifies the form layout, field visibility rules, auto-population logic, and client-side behaviours for every MVP DocType in Fundara. It is the canonical reference for the frontend layer. Business rules and server-side validation are defined in the DocType specification files under `docs/spec/doctypes/`.

---

## Global Rules (apply to all forms)

### Post-Submit Lock
All fields on **all submittable DocTypes** become read-only when `doc.docstatus == 1` (Submitted) or `doc.docstatus == 2` (Cancelled). Exceptions are documented per DocType. Amendments are the only path to editing submitted documents.

```
read_only: eval:doc.docstatus == 1
```

### Currency / Exchange Rate Pattern
- `exchange_rate` is read-only when the document's `currency` equals the company base currency (IDR).
- `amount_base` / `amount_in_base_currency` / any `*_base` computed field is always read-only.

```
exchange_rate read_only: eval:doc.currency == frappe.defaults.get_default('currency')
*_base         read_only: 1 (always)
```

### D-02 Pending Payment Warning Pattern
Any form that shows `pending_payment_flag == 1` must display a yellow info alert in the form header area via client script. The exact text varies by DocType (see Cash Advance below for the canonical D-02 banner).

---

## Priority 1 — Core DocTypes

---

## DocType: Fund

**Module:** Fundara > Fund Stewardship  
**Naming Series:** FUND-.YYYY.-.####  
**Submittable:** Yes | **Workflow:** Yes

### Layout Overview
Two-column header for name/code/type. Five vertical sections handle restriction, source, period, currency, and restriction rules. The `grant` field and campaign-related fields slide in/out based on `fund_type`. The Bridging Fund section appears only when `is_bridging_fund` is checked.

### Sections and Fields

#### Section: Header (no section label — top of form)
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| naming_series | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |
| fund_name | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |
| fund_code | 2 of 2 | — | eval:doc.docstatus==1 | — | — | |
| fund_type | 1 of 2 | — | eval:doc.docstatus==1 | — | — | Triggers conditional field visibility |

#### Section: Restriction & Purpose
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| restriction_type | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |
| purpose | 2 of 2 | — | eval:doc.docstatus==1 | — | — | |

#### Section: Source & Ownership
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| funding_source | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |
| grant | 1 of 2 | eval:doc.fund_type=="Grant Fund" | eval:doc.docstatus==1 | eval:doc.fund_type=="Grant Fund" | — | Mandatory only for Grant Fund (D-01) |
| fund_owner | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |
| approval_authority | 2 of 2 | — | eval:doc.docstatus==1 | — | — | |

#### Section: Period
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| start_date | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |
| end_date | 2 of 2 | — | eval:doc.docstatus==1 | — | eval:doc.fund_type=="Grant Fund"?doc.grant_end_date:'' | Optional unless Fund Type has_end_date flag |

#### Section: Currency & Opening Balance
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| currency | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |
| exchange_rate_on_creation | 2 of 2 | — | eval:doc.currency==frappe.defaults.get_default('currency')\|\|doc.docstatus==1 | — | — | Read-only when IDR |
| opening_balance | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |
| opening_balance_base | 2 of 2 | — | 1 | — | — | Always read-only; computed |
| base_currency | 1 of 2 | — | 1 | — | — | Always read-only; from ERPNext Company |

#### Section: Status
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| status | 1 of 1 | — | eval:doc.docstatus==1 | — | — | Controlled by workflow |

#### Section: Restriction Rules
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| allowed_cost_categories | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |
| disallowed_cost_categories | 2 of 2 | — | eval:doc.docstatus==1 | — | — | |
| allowed_programs | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |
| allowed_projects | 2 of 2 | — | eval:doc.docstatus==1 | — | — | |
| procurement_requirement | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |
| reporting_requirement | 2 of 2 | — | eval:doc.docstatus==1 | — | — | |
| exception_rule | 1 of 1 | — | eval:doc.docstatus==1 | — | — | |

#### Section: Bridging Fund
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| is_bridging_fund | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |
| recoverable_from_fund | 2 of 2 | eval:doc.is_bridging_fund==1 | eval:doc.docstatus==1 | eval:doc.is_bridging_fund==1 | — | Hidden unless bridging fund |

#### Section: Notes
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| notes | 1 of 1 | — | eval:doc.docstatus==1 | — | — | |

### Client Script Behavior
- On `fund_type` change: refresh dependent fields (`grant`, `end_date`). If changing away from "Grant Fund", clear the `grant` field.
- On `opening_balance` or `exchange_rate_on_creation` change: recompute `opening_balance_base = opening_balance × exchange_rate_on_creation`. Display result immediately.
- On `currency` change: if `currency == base_currency`, set `exchange_rate_on_creation = 1` and make it read-only; otherwise unlock.
- `base_currency` is populated from `frappe.defaults.get_default('currency')` on form load and is always read-only.
- When `status == "Active"` and user tries to change `restriction_type`: show warning dialog — "Perubahan restriction type pada fund aktif memerlukan approval. Proses ini akan membuat audit log."

### Form Button Customizations
- **"Lihat Alokasi"** — always visible when `status` is Active or later — opens a filtered list of Fund Allocations for this fund.
- **"Lihat Balance Snapshot"** — always visible when `docstatus == 1` — opens the latest Fund Balance Snapshot for this fund.

---

## DocType: Cash Advance

**Module:** Fundara > Financial Accountability  
**Naming Series:** ADV-.YYYY.-.####  
**Submittable:** Yes | **Workflow:** Yes

### Layout Overview
The form opens with requester identification and the fund/activity linkage block. The D-02 constraint surfaces as a prominent HTML banner when `status == "Approved"` and `pending_payment_flag == 1`. Approval signature fields are grouped at the bottom, read-only unless the user holds the correct role.

### Sections and Fields

#### Section: [D-02 Info Banner — rendered via HTML field or client script]
> **Implementation:** Insert an HTML field or use `frm.dashboard.add_comment()` / `frm.set_intro()` in client script. Show only when `doc.status == "Approved"` and `doc.pending_payment_flag == 1`.
>
> Banner text: **"Advance ini belum dibayar. Budget belum berkurang. Pastikan pembayaran diproses untuk mencatat pengurangan budget."**  
> Style: yellow/warning background (`alert alert-warning`).

#### Section: Requester
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| naming_series | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |
| advance_number | 2 of 2 | — | 1 | — | — | Auto from naming_series, always read-only |
| requester | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |
| requester_department | 2 of 2 | — | 1 | — | requester.department | Auto-populated from requester; always read-only |

#### Section: Activity & Fund
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| fund | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |
| project | 2 of 2 | — | eval:doc.docstatus==1 | — | — | |
| activity | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |
| budget_line | 2 of 2 | — | eval:doc.docstatus==1 | — | — | |
| cost_center | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |

#### Section: Currency & Amounts
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| currency | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |
| exchange_rate | 2 of 2 | — | eval:doc.currency==frappe.defaults.get_default('currency')\|\|doc.docstatus==1 | — | — | |
| requested_amount | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |
| approved_amount | 2 of 2 | — | eval:doc.docstatus==1 | — | — | Set by Finance during approval |
| paid_amount | 1 of 2 | — | 1 | — | — | Always read-only; set by system on payment |

#### Section: D-02 Budget Control
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| pending_payment_flag | 1 of 1 | eval:doc.status=="Approved" | 1 | — | — | Always read-only; system-managed; show only when Approved |

#### Section: Purpose & Schedule
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| purpose | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |
| expected_activity_date | 2 of 2 | — | eval:doc.docstatus==1 | — | — | |
| posting_date | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |
| liquidation_due_date | 2 of 2 | — | eval:doc.docstatus==1 | — | — | Mandatory; must be future date at submission |

#### Section: Status & Aging
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| status | 1 of 2 | — | eval:doc.docstatus==1 | — | — | Workflow-controlled |
| aging_category | 2 of 2 | eval:doc.status=="Paid"\|\|doc.status=="Pending Liquidation"\|\|doc.status=="Overdue" | 1 | — | — | System-computed |
| days_outstanding | 1 of 2 | eval:doc.status=="Paid"\|\|doc.status=="Pending Liquidation"\|\|doc.status=="Overdue" | 1 | — | — | System-computed |

#### Section: Approval
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| supervisor_approved_by | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |
| supervisor_approved_on | 2 of 2 | — | eval:doc.docstatus==1 | — | — | |
| finance_approved_by | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |
| finance_approved_on | 2 of 2 | — | eval:doc.docstatus==1 | — | — | |
| rejected_reason | 1 of 1 | eval:doc.status=="Rejected"\|\|doc.status=="Cancelled" | eval:doc.docstatus==1 | eval:doc.status=="Rejected"\|\|doc.status=="Cancelled" | — | |

#### Section: Payment Reference
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| payment_reference | 1 of 2 | eval:doc.status=="Paid"\|\|doc.status=="Pending Liquidation"\|\|doc.status=="Liquidated"\|\|doc.status=="Closed" | eval:doc.docstatus==1 | — | — | |
| payment_date | 2 of 2 | eval:doc.status=="Paid"\|\|doc.status=="Pending Liquidation"\|\|doc.status=="Liquidated"\|\|doc.status=="Closed" | 1 | — | — | Read-only; set by system |
| payment_journal_entry | 1 of 1 | eval:doc.payment_journal_entry | 1 | — | — | Auto-created; always read-only |

#### Section: Notes
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| remarks | 1 of 1 | — | eval:doc.docstatus==1 | — | — | |

### Client Script Behavior
- **D-02 Banner:** On form load and on every `status` change: if `doc.status == "Approved"` and `doc.pending_payment_flag == 1`, call `frm.set_intro('Advance ini belum dibayar. Budget belum berkurang. Pastikan pembayaran diproses untuk mencatat pengurangan budget.', 'yellow')`. Clear the intro when status moves past Approved.
- On `requester` change: fetch `requester_department` from the User's linked Department.
- On `activity` change: fetch `fund`, `project`, and `budget_line` from the linked Activity. Show a dialog if Activity status is not Approved or In Progress — "Activity belum disetujui. Advance tidak bisa diajukan."
- On `currency` change: if currency equals base currency, set `exchange_rate = 1` and lock it.
- Show a read-only balance indicator near `budget_line` showing: Available Budget = (Approved − Paid) for that line (fetched via server call on budget_line selection).

### Form Button Customizations
- **"Liquidasi Advance"** — visible when `status == "Pending Liquidation"` or `status == "Overdue"` — creates a new Advance Liquidation document pre-filled with this advance's data.
- **"Tambah Advance"** — visible when `status == "Pending Liquidation"` or `status == "Overdue"` — creates a new Additional Advance Payment linked to this advance.

---

## DocType: Advance Liquidation

**Module:** Fundara > Financial Accountability  
**Naming Series:** LIQ-.YYYY.-.####  
**Submittable:** Yes | **Workflow:** Yes

### Layout Overview
Linked Cash Advance sits at the top and auto-fills dimension fields. The expense lines table is the main working area. A computed settlement summary panel shows refund or reimbursement amounts. Refund detail fields appear only when `settlement_type == "Refund Required"`.

### Sections and Fields

#### Section: Advance Reference
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| naming_series | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |
| cash_advance | 1 of 2 | — | eval:doc.docstatus==1 | — | — | Selecting this triggers auto-fill of dimensions |

#### Section: Dimensions (read-only — from Cash Advance)
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| fund | 1 of 2 | — | 1 | — | cash_advance.fund | Always read-only |
| project | 2 of 2 | — | 1 | — | cash_advance.project | Always read-only |
| activity | 1 of 2 | — | 1 | — | cash_advance.activity | Always read-only |
| cost_center | 2 of 2 | — | eval:doc.docstatus==1 | — | — | Editable if needed |
| posting_date | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |

#### Section: Currency & Amounts
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| currency | 1 of 2 | — | eval:doc.docstatus==1 | — | cash_advance.currency | |
| exchange_rate | 2 of 2 | — | eval:doc.currency==frappe.defaults.get_default('currency')\|\|doc.docstatus==1 | — | cash_advance.exchange_rate | |
| advance_paid_amount | 1 of 2 | — | 1 | — | cash_advance.paid_amount | Always read-only |
| total_actual_expense | 2 of 2 | — | 1 | — | — | System-computed from expense_lines |

#### Section: Expense Lines
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| expense_lines | 1 of 1 | — | eval:doc.docstatus==1 | — | — | Child table; at least 1 row required |

#### Section: Settlement Summary
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| refund_amount | 1 of 2 | eval:doc.settlement_type=="Refund Required"\|\|doc.settlement_type=="No Difference" | 1 | — | — | System-computed |
| reimbursement_amount | 2 of 2 | eval:doc.settlement_type=="Reimbursement Required"\|\|doc.settlement_type=="No Difference" | 1 | — | — | System-computed |
| settlement_type | 1 of 1 | — | 1 | — | — | System-computed |

#### Section: Refund Details
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| refund_receipt_reference | 1 of 2 | eval:doc.settlement_type=="Refund Required" | eval:doc.docstatus==1 | eval:doc.settlement_type=="Refund Required" | — | Mandatory only when refund required |
| refund_date | 2 of 2 | eval:doc.settlement_type=="Refund Required" | eval:doc.docstatus==1 | eval:doc.settlement_type=="Refund Required" | — | |

#### Section: Review
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| review_status | 1 of 2 | — | eval:doc.docstatus==1 | — | — | Workflow-controlled |
| finance_reviewed_by | 1 of 2 | eval:doc.review_status!="Draft"&&doc.review_status!="Submitted" | eval:doc.docstatus==1 | — | — | |
| finance_reviewed_on | 2 of 2 | eval:doc.review_status!="Draft"&&doc.review_status!="Submitted" | eval:doc.docstatus==1 | — | — | |

#### Section: Evidence
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| evidence_completeness | 1 of 2 | eval:doc.review_status=="Under Review by Finance"\|\|doc.review_status=="Approved" | eval:doc.docstatus==1 | — | — | Set by Finance reviewer |
| remarks | 1 of 1 | — | eval:doc.docstatus==1 | — | — | |

### Client Script Behavior
- On `cash_advance` selection: auto-fetch `fund`, `project`, `activity`, `currency`, `exchange_rate`, `advance_paid_amount`. Lock these fields. Check that `cash_advance.status` is "Pending Liquidation" or "Overdue"; show error if not.
- On any change to `expense_lines`: recompute `total_actual_expense`, then compute `settlement_type` and `refund_amount`/`reimbursement_amount`:
  - If `total_actual_expense == advance_paid_amount` → `settlement_type = "No Difference"`
  - If `total_actual_expense < advance_paid_amount` → `settlement_type = "Refund Required"`, `refund_amount = advance_paid_amount - total_actual_expense`
  - If `total_actual_expense > advance_paid_amount` → `settlement_type = "Reimbursement Required"`, `reimbursement_amount = total_actual_expense - advance_paid_amount`
- Show a color-coded summary bar below the expense lines table: green for No Difference, orange for Refund Required, blue for Reimbursement Required.

### Form Button Customizations
- **"Lihat Cash Advance"** — always visible — navigates to the linked Cash Advance document.

---

## DocType: Grant

**Module:** Fundara > Grant  
**Naming Series:** GRANT-.YYYY.-.####  
**Submittable:** Yes | **Workflow:** Yes

### Layout Overview
Two-column header. Donor and classification follow. Amount and currency in a dedicated section with the base-currency equivalent always visible but read-only. Period section auto-calculates `grant_period_months`. A Fund link section appears after the grant reaches Active status.

### Sections and Fields

#### Section: Header
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| naming_series | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |
| grant_name | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |
| grant_code | 2 of 2 | — | eval:doc.docstatus==1 | — | — | |

#### Section: Donor & Classification
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| donor | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |
| grant_type | 2 of 2 | — | eval:doc.docstatus==1 | — | — | |
| program_area | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |
| implementing_unit | 2 of 2 | — | eval:doc.docstatus==1 | — | — | |
| grant_manager | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |

#### Section: Amount & Currency
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| currency | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |
| total_amount | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |
| exchange_rate_on_creation | 2 of 2 | — | eval:doc.currency==frappe.defaults.get_default('currency')\|\|doc.docstatus==1 | — | — | |
| total_amount_base | 2 of 2 | — | 1 | — | — | Always read-only; computed |
| base_currency | 1 of 2 | — | 1 | — | — | Always read-only |

#### Section: Period
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| start_date | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |
| end_date | 2 of 2 | — | eval:doc.docstatus==1 | — | — | |
| grant_period_months | 1 of 2 | — | 1 | — | — | Auto-calculated; always read-only |

#### Section: Lifecycle Status
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| status | 1 of 1 | — | eval:doc.docstatus==1 | — | — | Workflow-controlled |

#### Section: Fund Link
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| fund | 1 of 1 | eval:doc.status=="Active"\|\|doc.status=="Extended"\|\|doc.status=="Suspended"\|\|doc.status=="Closing"\|\|doc.status=="Closed" | 1 | — | — | Read-only; populated when Grant Fund created |

#### Section: Notes
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| notes | 1 of 1 | — | eval:doc.docstatus==1 | — | — | |

### Client Script Behavior
- On `start_date` or `end_date` change: compute `grant_period_months` = Math.ceil(date difference in months). Display immediately.
- On `total_amount` or `exchange_rate_on_creation` change: recompute `total_amount_base`.
- On `currency` change: if currency equals base currency, set `exchange_rate_on_creation = 1` and lock; otherwise unlock.
- When `status == "Rejected"` or `"Cancelled"`: add a red intro banner — "Grant ini sudah ditolak/dibatalkan. Tidak ada perubahan yang dapat dilakukan."
- Show quick-access links in the form sidebar to: Grant Agreements, Grant Budget Lines, Grant Reporting Schedules linked to this grant.

### Form Button Customizations
- **"Buat Grant Agreement"** — visible when `status` is in ["Awarded", "Agreement Review", "Active"] — creates a new Grant Agreement linked to this grant.
- **"Lihat Budget Lines"** — visible when `docstatus == 1` — opens filtered list of Grant Budget Lines.
- **"Initiate Closeout"** — visible when `status == "Closing"` — creates a Grant Closeout Checklist.

---

## DocType: Project

**Module:** Fundara > Mission Delivery  
**Naming Series:** PROJ-.YYYY.-.####  
**Submittable:** No | **Workflow:** Yes

### Layout Overview
Header with name, code, and program. Two-column management section. Period and budget sections. Fund allocations as a child table. Details (objective, expected results) at the bottom.

### Sections and Fields

#### Section: Header
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| naming_series | 1 of 2 | — | — | — | — | |
| project_name | 1 of 2 | — | — | — | — | |
| project_code | 2 of 2 | — | — | — | — | |
| program | 1 of 2 | — | — | — | — | |

#### Section: Management
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| project_manager | 1 of 2 | — | — | — | — | |
| cost_center | 2 of 2 | — | — | — | — | |
| status | 1 of 2 | — | — | — | — | Workflow-controlled |

#### Section: Period & Location
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| start_date | 1 of 2 | — | — | — | — | |
| end_date | 2 of 2 | — | — | — | — | |
| location | 1 of 2 | — | — | — | — | |
| target_beneficiaries | 2 of 2 | — | — | — | — | |

#### Section: Budget
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| currency | 1 of 2 | — | — | — | — | |
| total_budget | 2 of 2 | — | 1 | — | — | Computed from fund_allocations; read-only |
| fund_allocations | 1 of 1 | — | — | — | — | Child table: Project Fund Allocation |

#### Section: Details
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| objective | 1 of 1 | — | — | — | — | |
| expected_results | 1 of 1 | — | — | — | — | |
| notes | 1 of 1 | — | — | — | — | |

### Client Script Behavior
- On `fund_allocations` table change: recompute `total_budget` as sum of all `allocated_amount` rows.
- On `status` change to "Completed" or "Closed": check (via server call) for open Activities and open Cash Advances. Show a warning dialog listing blockers if any exist.
- Show a project summary panel at the top of the form (custom HTML field or dashboard chart) with: Total Budget, Total Spent, % Complete.

### Form Button Customizations
- **"Buat Activity"** — visible when `status == "Active"` — creates a new Activity pre-filled with this project.
- **"Lihat Workplan"** — always visible — opens filtered list of Workplans for this project.
- **"Lihat Cash Advances"** — always visible — opens filtered list of Cash Advances linked to this project.

---

## DocType: Activity

**Module:** Fundara > Mission Delivery  
**Naming Series:** ACT-.YYYY.-.####  
**Submittable:** Yes | **Workflow:** Yes

### Layout Overview
Activity identity at top. Project/fund linkage section below. Responsibility and status in the same row. Schedule and budget sections side-by-side. Output tracking at the bottom.

### Sections and Fields

#### Section: Header
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| naming_series | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |
| activity_name | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |
| activity_code | 2 of 2 | — | eval:doc.docstatus==1 | — | — | |
| activity_type | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |

#### Section: Project & Fund
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| project | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |
| program | 2 of 2 | — | 1 | — | project.program | Always read-only; auto-filled |
| fund | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |
| budget_line | 2 of 2 | — | eval:doc.docstatus==1 | — | — | |
| cost_center | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |

#### Section: Responsibility & Status
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| responsible_person | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |
| status | 2 of 2 | — | eval:doc.docstatus==1 | — | — | Workflow-controlled |

#### Section: Schedule
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| planned_date | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |
| actual_date | 2 of 2 | eval:doc.status=="Completed"\|\|doc.status=="Reported"\|\|doc.status=="Verified"\|\|doc.status=="Closed" | eval:doc.docstatus==1 | — | — | |
| posting_date | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |
| location | 2 of 2 | — | eval:doc.docstatus==1 | — | — | |

#### Section: Budget & Cost
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| currency | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |
| exchange_rate | 2 of 2 | — | eval:doc.currency==frappe.defaults.get_default('currency')\|\|doc.docstatus==1 | — | — | |
| planned_cost | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |
| actual_cost | 2 of 2 | — | 1 | — | — | System-computed; always read-only |

#### Section: Output
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| target_output | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |
| actual_output | 2 of 2 | eval:doc.status=="Completed"\|\|doc.status=="Reported"\|\|doc.status=="Verified"\|\|doc.status=="Closed" | eval:doc.docstatus==1 | — | — | |

#### Section: Notes
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| description | 1 of 1 | — | eval:doc.docstatus==1 | — | — | |
| notes | 1 of 1 | — | eval:doc.docstatus==1 | — | — | |

### Client Script Behavior
- On `project` change: fetch `program` from `project.program` and lock it.
- On `activity_type` change: if `activity_type.requires_field_report == 1`, show info banner: "Jenis activity ini memerlukan Field Report sebelum dapat diverifikasi."
- On `status` transition to "Verified": if linked `activity_type.requires_field_report == 1`, check (via server call) for at least one verified Field Report. Block if none.
- On `currency` change: handle exchange_rate lock/unlock.

### Form Button Customizations
- **"Ajukan Cash Advance"** — visible when `status` is "Approved" or "In Progress" — creates new Cash Advance pre-filled with this activity's fund, project, and budget_line.
- **"Buat Field Report"** — visible when `status` is "In Progress", "Completed", or "Reported" — creates new Field Report linked to this activity.

---

## DocType: Purchase Request

**Module:** Fundara > Procurement  
**Naming Series:** PR-.YYYY.-.#####  
**Submittable:** Yes | **Workflow:** Yes

### Layout Overview
Title and requester at top. Fund/project/budget linkage. Estimated amount with auto-suggested procurement method based on threshold rule. Items child table. Budget check result displayed as a colored indicator. Approval fields at the bottom.

### Sections and Fields

#### Section: Header
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| naming_series | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |
| title | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |
| requester | 2 of 2 | — | eval:doc.docstatus==1 | — | — | |
| request_date | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |
| required_by | 2 of 2 | — | eval:doc.docstatus==1 | — | — | |
| request_type | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |
| purpose | 1 of 1 | — | eval:doc.docstatus==1 | — | — | |

#### Section: Fund & Budget
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| fund | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |
| project | 2 of 2 | — | eval:doc.docstatus==1 | — | — | |
| activity | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |
| cost_center | 2 of 2 | — | eval:doc.docstatus==1 | — | — | Auto from fund/project |
| budget_line | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |

#### Section: Procurement Details
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| estimated_amount | 1 of 2 | — | eval:doc.docstatus==1 | — | — | Triggers threshold rule lookup |
| currency | 2 of 2 | — | eval:doc.docstatus==1 | — | — | |
| procurement_method | 1 of 2 | — | eval:doc.docstatus==1 | — | — | Auto-suggested; user may override |
| threshold_rule | 2 of 2 | — | 1 | — | — | Auto-populated; read-only |

#### Section: Items
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| items | 1 of 1 | — | eval:doc.docstatus==1 | — | — | Child table |

#### Section: Budget Check
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| budget_check_result | 1 of 2 | eval:doc.budget_check_result | 1 | — | — | System-set; color-coded |
| budget_check_notes | 2 of 2 | eval:doc.budget_check_result | 1 | — | — | |

#### Section: Status & Approval
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| status | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |
| approved_by | 1 of 2 | eval:doc.status=="Approved"\|\|doc.status=="Procurement Processing"\|\|doc.status=="Closed" | eval:doc.docstatus==1 | — | — | |
| approval_date | 2 of 2 | eval:doc.status=="Approved"\|\|doc.status=="Procurement Processing"\|\|doc.status=="Closed" | eval:doc.docstatus==1 | — | — | |
| rejection_reason | 1 of 1 | eval:doc.status=="Rejected" | eval:doc.docstatus==1 | eval:doc.status=="Rejected" | — | |
| linked_purchase_order | 1 of 1 | eval:doc.linked_purchase_order | 1 | — | — | Always read-only when set |

#### Section: Notes
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| notes | 1 of 1 | — | eval:doc.docstatus==1 | — | — | |
| attachments | 1 of 1 | — | eval:doc.docstatus==1 | — | — | |

### Client Script Behavior
- On `estimated_amount` change: call server method to find matching Procurement Threshold Rule based on amount and `fund.fund_type`. Auto-populate `procurement_method` and `threshold_rule`. Show tooltip: "Metode pengadaan disarankan berdasarkan aturan threshold. Anda dapat mengubah jika ada justifikasi."
- On `budget_check_result` change: render a colored badge — green for Passed, red for Failed, yellow for Warning.
- `budget_check_result == "Failed"` should show a red alert banner: "Anggaran tidak mencukupi. Silakan revisi jumlah atau hubungi Finance."
- On `fund` change: fetch `cost_center` from fund.

### Form Button Customizations
- **"Buat Purchase Order"** — visible when `status == "Approved"` — creates a new Purchase Order (Fundara) linked to this PR.

---

## DocType: Fund Allocation

**Module:** Fundara > Fund Stewardship  
**Naming Series:** FALLOC-.YYYY.-.####  
**Submittable:** Yes | **Workflow:** Yes

### Layout Overview
Fund at top. Allocation target section with conditional reference fields based on `allocated_to_type`. Amount section with base equivalent. Period. Status and approval. Utilisation summary (D-02) always read-only at the bottom.

### Sections and Fields

#### Section: Header
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| naming_series | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |
| fund | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |

#### Section: Allocation Target
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| allocated_to_type | 1 of 2 | — | eval:doc.docstatus==1 | — | — | Drives conditional visibility below |
| program | 1 of 2 | eval:doc.allocated_to_type=="Program" | eval:doc.docstatus==1 | eval:doc.allocated_to_type=="Program" | — | |
| project | 1 of 2 | eval:doc.allocated_to_type=="Project" | eval:doc.docstatus==1 | eval:doc.allocated_to_type=="Project" | — | |
| activity | 1 of 2 | eval:doc.allocated_to_type=="Activity" | eval:doc.docstatus==1 | eval:doc.allocated_to_type=="Activity" | — | |
| cost_center | 1 of 2 | eval:doc.allocated_to_type=="Cost Center" | eval:doc.docstatus==1 | eval:doc.allocated_to_type=="Cost Center" | — | |
| budget_line | 2 of 2 | — | eval:doc.docstatus==1 | — | — | |

#### Section: Amount & Currency
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| currency | 1 of 2 | — | eval:doc.docstatus==1 | — | fund.currency | Auto from fund |
| allocated_amount | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |
| exchange_rate | 2 of 2 | — | eval:doc.currency==frappe.defaults.get_default('currency')\|\|doc.docstatus==1 | — | fund.exchange_rate_on_creation | |
| allocated_amount_base | 2 of 2 | — | 1 | — | — | Always read-only; computed |

#### Section: Period
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| allocation_period_start | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |
| allocation_period_end | 2 of 2 | — | eval:doc.docstatus==1 | — | — | |

#### Section: Status & Approval
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| status | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |
| approved_by | 1 of 2 | eval:doc.status=="Approved"\|\|doc.status=="Active"\|\|doc.status=="Revised"\|\|doc.status=="Closed" | eval:doc.docstatus==1 | — | — | |
| approval_date | 2 of 2 | eval:doc.status=="Approved"\|\|doc.status=="Active"\|\|doc.status=="Revised"\|\|doc.status=="Closed" | eval:doc.docstatus==1 | — | — | |
| revision_note | 1 of 1 | eval:doc.status=="Revised" | eval:doc.docstatus==1 | eval:doc.status=="Revised" | — | Mandatory when Revised |

#### Section: Utilisation Summary (D-02)
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| total_paid | 1 of 2 | — | 1 | — | — | Always read-only; D-02: only paid amounts |
| total_pending_payment | 2 of 2 | — | 1 | — | — | Read-only; informational only — does NOT reduce balance |
| available_balance | 1 of 2 | — | 1 | — | — | Always read-only: allocated − paid |

#### Section: Notes
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| notes | 1 of 1 | — | eval:doc.docstatus==1 | — | — | |

### Client Script Behavior
- On `allocated_to_type` change: clear the previously set reference field (program/project/activity/cost_center) before displaying the new one.
- On `fund` change: fetch `currency` and `exchange_rate` from fund; validate that the chosen fund is Active.
- On `allocated_amount` or `exchange_rate` change: recompute `allocated_amount_base`.
- Display a live "Fund Available Balance" indicator near the `allocated_amount` field (fetched from server on fund selection). Show a warning if `allocated_amount` would exceed the fund's available balance.
- `total_pending_payment` should show with a grey label and a tooltip: "Ini hanya informasi — tidak mengurangi saldo yang tersedia (D-02)."

### Form Button Customizations
- **"Revisi Alokasi"** — visible when `status == "Active"` — prompts for `revision_note` and triggers re-approval workflow.

---

## DocType: Fundraising Campaign

**Module:** Fundara > Funding  
**Naming Series:** CAMP-.YYYY.-.####  
**Submittable:** Yes | **Workflow:** Yes

### Layout Overview
Name, code, and organisation at top. Purpose section with conditional `restricted_purpose`. Target and timeline. Management. Campaign channels child table. Reporting/transparency. Status and computed financial summary (read-only).

### Sections and Fields

#### Section: Header
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| naming_series | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |
| campaign_name | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |
| campaign_code | 2 of 2 | — | eval:doc.docstatus==1 | — | — | |
| organization | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |

#### Section: Purpose
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| purpose | 1 of 1 | — | eval:doc.docstatus==1 | — | — | |
| restriction_type | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |
| restricted_purpose | 2 of 2 | eval:doc.restriction_type=="Restricted" | eval:doc.docstatus==1 | eval:doc.restriction_type=="Restricted" | — | Mandatory and visible only when Restricted |

#### Section: Target & Timeline
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| currency | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |
| target_amount | 2 of 2 | — | eval:doc.docstatus==1 | — | — | |
| start_date | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |
| end_date | 2 of 2 | — | eval:doc.docstatus==1 | — | — | |

#### Section: Management
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| campaign_manager | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |
| responsible_department | 2 of 2 | — | eval:doc.docstatus==1 | — | — | |

#### Section: Channels
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| campaign_channels | 1 of 1 | — | eval:doc.docstatus==1 | — | — | Child table |

#### Section: Reporting & Transparency
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| public_reporting_required | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |
| public_reporting_commitment | 2 of 2 | eval:doc.public_reporting_required==1 | eval:doc.docstatus==1 | eval:doc.public_reporting_required==1 | — | |

#### Section: Status
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| status | 1 of 2 | — | eval:doc.docstatus==1 | — | — | Workflow-controlled |
| linked_funding_source | 2 of 2 | — | 1 | — | — | Auto-created; read-only |

#### Section: Financial Summary (read-only)
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| total_donations_received | 1 of 2 | — | 1 | — | — | Computed from linked Donations |
| total_donors | 2 of 2 | — | 1 | — | — | Computed count |
| achievement_percent | 1 of 2 | — | 1 | — | — | Computed: received / target |

#### Section: Notes
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| notes | 1 of 1 | — | eval:doc.docstatus==1 | — | — | |

### Client Script Behavior
- On `restriction_type` change: if changed away from "Restricted", clear `restricted_purpose`.
- Show a progress bar indicator near `achievement_percent` (green when ≥ 100%, orange when ≥ 50%, red when < 50%). Rendered via `frm.dashboard`.
- On `status == "Cancelled"` or `"Closed"`: show intro banner "Kampanye ini sudah ditutup/dibatalkan. Donasi baru tidak dapat ditambahkan."

### Form Button Customizations
- **"Lihat Donasi"** — always visible when saved — opens filtered Donation list for this campaign.
- **"Buat Laporan Publik"** — visible when `status` is "Completed" or "Reporting" and `public_reporting_required == 1` — initiates public campaign report.

---

## DocType: Donation

**Module:** Fundara > Funding  
**Naming Series:** DON-.YYYY.-.####  
**Submittable:** Yes | **Workflow:** Yes

### Layout Overview
A short two-column header. Donor section with `is_anonymous` toggle controlling donor field visibility. Campaign linkage. Amount with exchange rate. Payment details. Restriction. Receipt and acknowledgment tracking.

### Sections and Fields

#### Section: Header
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| naming_series | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |
| donation_number | 2 of 2 | — | 1 | — | — | Auto; always read-only |
| organization | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |

#### Section: Donor
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| is_anonymous | 1 of 2 | — | eval:doc.docstatus==1 | — | — | Toggle controls donor field |
| donor | 1 of 2 | eval:!doc.is_anonymous | eval:doc.docstatus==1 | eval:!doc.is_anonymous | — | Hidden and cleared when anonymous |
| donor_display_name | 2 of 2 | eval:doc.is_anonymous | eval:doc.docstatus==1 | — | — | e.g. "Hamba Allah" — visible only when anonymous |

#### Section: Campaign
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| fundraising_campaign | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |
| funding_source | 2 of 2 | — | 1 | — | fundraising_campaign.linked_funding_source | Auto-derived; read-only |

#### Section: Amount
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| currency | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |
| amount | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |
| exchange_rate | 2 of 2 | — | eval:doc.currency==frappe.defaults.get_default('currency')\|\|doc.docstatus==1 | eval:doc.currency!=frappe.defaults.get_default('currency') | — | Mandatory when currency ≠ IDR |
| amount_in_base_currency | 2 of 2 | — | 1 | — | — | Always read-only; computed |

#### Section: Payment
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| date_received | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |
| payment_channel | 2 of 2 | — | eval:doc.docstatus==1 | — | — | |
| payment_reference | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |

#### Section: Restriction
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| restriction_type | 1 of 2 | — | eval:doc.docstatus==1 | — | fundraising_campaign.restriction_type | Auto-derived from campaign |
| restriction_purpose | 2 of 2 | eval:doc.restriction_type=="Restricted" | eval:doc.docstatus==1 | eval:doc.restriction_type=="Restricted" | fundraising_campaign.restricted_purpose | |

#### Section: Receipt & Acknowledgment
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| receipt_number | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |
| receipt_issued | 2 of 2 | — | eval:doc.docstatus==1 | — | — | |
| receipt_date | 1 of 2 | eval:doc.receipt_issued==1 | eval:doc.docstatus==1 | eval:doc.receipt_issued==1 | — | |
| acknowledgment_status | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |
| acknowledgment_date | 2 of 2 | eval:doc.acknowledgment_status=="Sent"\|\|doc.acknowledgment_status=="Confirmed" | eval:doc.docstatus==1 | — | — | |

#### Section: Notes
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| notes | 1 of 1 | — | eval:doc.docstatus==1 | — | — | |

### Client Script Behavior
- On `is_anonymous` toggle to `1`: clear `donor` field and make it invisible. Show `donor_display_name`.
- On `is_anonymous` toggle to `0`: hide `donor_display_name`; make `donor` visible and mandatory.
- On `fundraising_campaign` selection: fetch `restriction_type` and `restricted_purpose` from campaign. Validate campaign is in "Active" or "Paused" status; show error if Cancelled or Closed.
- On `currency` change: handle exchange_rate lock. Recompute `amount_in_base_currency` on `amount` or `exchange_rate` change.
- On `donor` selection: check `donor.donor_status != "Blacklisted"`; show error if blacklisted.

### Form Button Customizations
- **"Kirim Acknowledgment"** — visible when `docstatus == 1` and `acknowledgment_status == "Pending"` — sets `acknowledgment_status = "Sent"` and `acknowledgment_date = today`.

---

## Priority 2 — Important DocTypes

---

## DocType: Grant Agreement

**Module:** Fundara > Grant  
**Naming Series:** GRAGR-.YYYY.-.####  
**Submittable:** Yes | **Workflow:** Yes

### Layout Overview
Linked grant at top. Dates section. Contracted amount with currency (must match Grant). Eligible/ineligible cost categories. Rules and requirements. Amendment section visible only when `is_amendment == 1`. Document attachment. Approval block.

### Sections and Fields

#### Section: Header
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| naming_series | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |
| grant | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |
| agreement_number | 2 of 2 | — | eval:doc.docstatus==1 | — | — | |

#### Section: Dates
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| signing_date | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |
| effective_date | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |
| end_date | 2 of 2 | — | eval:doc.docstatus==1 | — | — | |

#### Section: Contracted Amount
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| currency | 1 of 2 | — | eval:doc.docstatus==1 | — | grant.currency | Auto from Grant; should match |
| total_amount_contracted | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |
| exchange_rate | 2 of 2 | — | eval:doc.currency==frappe.defaults.get_default('currency')\|\|doc.docstatus==1 | — | — | |
| total_amount_contracted_base | 2 of 2 | — | 1 | — | — | Always read-only |

#### Section: Eligible / Ineligible Costs
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| eligible_cost_categories | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |
| ineligible_cost_categories | 2 of 2 | — | eval:doc.docstatus==1 | — | — | |
| indirect_cost_rate | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |

#### Section: Rules & Requirements
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| procurement_rules | 1 of 1 | — | eval:doc.docstatus==1 | — | — | |
| audit_requirement | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |
| branding_requirement | 2 of 2 | — | eval:doc.docstatus==1 | — | — | |

#### Section: Amendment
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| is_amendment | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |
| supersedes_agreement | 1 of 2 | eval:doc.is_amendment==1 | eval:doc.docstatus==1 | eval:doc.is_amendment==1 | — | |
| amendment_reason | 2 of 2 | eval:doc.is_amendment==1 | eval:doc.docstatus==1 | eval:doc.is_amendment==1 | — | |
| amendment_date | 1 of 2 | eval:doc.is_amendment==1 | eval:doc.docstatus==1 | — | — | |

#### Section: Document
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| agreement_document | 1 of 1 | — | eval:doc.docstatus==1 | — | — | Strongly recommended; warning if missing |

#### Section: Approval
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| approved_by | 1 of 2 | eval:doc.status=="Approved" | eval:doc.docstatus==1 | — | — | |
| approval_date | 2 of 2 | eval:doc.status=="Approved" | eval:doc.docstatus==1 | — | — | |
| notes | 1 of 1 | — | eval:doc.docstatus==1 | — | — | |

### Client Script Behavior
- On `grant` selection: fetch `currency` from grant and lock it (currency must match Grant.currency).
- Warn (non-blocking) if `agreement_document` is not attached when attempting to submit.
- On `total_amount_contracted` or `exchange_rate` change: recompute `total_amount_contracted_base`.

---

## DocType: Grant Budget Line

**Module:** Fundara > Grant  
**Naming Series:** GRBUDL-.YYYY.-.####  
**Submittable:** Yes

### Layout Overview
Grant and optional agreement at top. Line identity (code + name). Amount section with revision column and read-only `amount_current`. Allowed cost types and restriction notes. Internal mapping child table. Utilisation summary (D-02) at the bottom.

### Sections and Fields

#### Section: Header
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| naming_series | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |
| grant | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |
| grant_agreement | 2 of 2 | — | eval:doc.docstatus==1 | — | — | Optional |

#### Section: Line Identity
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| budget_line_code | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |
| budget_line_name | 2 of 2 | — | eval:doc.docstatus==1 | — | — | |
| description | 1 of 1 | — | eval:doc.docstatus==1 | — | — | |

#### Section: Amounts
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| currency | 1 of 2 | — | eval:doc.docstatus==1 | — | grant.currency | Auto from Grant |
| amount_approved | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |
| amount_revised | 2 of 2 | — | eval:doc.docstatus==1 | — | — | Requires grant_agreement when set |
| amount_current | 1 of 2 | — | 1 | — | — | Always read-only: revised if set, else approved |
| exchange_rate | 2 of 2 | — | eval:doc.currency==frappe.defaults.get_default('currency')\|\|doc.docstatus==1 | — | — | |
| amount_approved_base | 1 of 2 | — | 1 | — | — | |
| amount_current_base | 2 of 2 | — | 1 | — | — | |

#### Section: Restrictions
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| allowed_cost_types | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |
| restriction_note | 2 of 2 | — | eval:doc.docstatus==1 | — | — | |

#### Section: Internal Mapping
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| internal_budget_lines | 1 of 1 | — | eval:doc.docstatus==1 | — | — | Child table: Grant Budget Line Mapping |

#### Section: Utilisation (D-02)
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| total_paid | 1 of 2 | — | 1 | — | — | Always read-only |
| total_pending_payment | 2 of 2 | — | 1 | — | — | Informational only (D-02) |
| available_balance | 1 of 2 | — | 1 | — | — | amount_current − total_paid |

#### Section: Notes
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| notes | 1 of 1 | — | eval:doc.docstatus==1 | — | — | |

### Client Script Behavior
- On `grant` selection: fetch and lock `currency`.
- On `amount_revised` change: require `grant_agreement` to be set; show validation message if not.
- Recompute `amount_current` = `amount_revised || amount_approved`. Display immediately.
- Show `total_pending_payment` with tooltip: "Informasi saja — tidak mengurangi saldo yang tersedia (D-02)."

---

## DocType: Fund Transfer

**Module:** Fundara > Fund Stewardship  
**Naming Series:** FTRANS-.YYYY.-.####  
**Submittable:** Yes | **Workflow:** Yes

### Layout Overview
Transfer date at top. Source and target fund side-by-side. Amount and exchange rate. Cross-currency fields appear only when source and target currencies differ. Reason and restriction check. Approval. Journal entry link (read-only, auto-created).

### Sections and Fields

#### Section: Header
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| naming_series | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |
| transfer_date | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |

#### Section: Source & Target
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| source_fund | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |
| target_fund | 2 of 2 | — | eval:doc.docstatus==1 | — | — | |

#### Section: Amount & Currency
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| currency | 1 of 2 | — | eval:doc.docstatus==1 | — | source_fund.currency | Auto from source fund |
| amount | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |
| exchange_rate | 2 of 2 | — | eval:doc.currency==frappe.defaults.get_default('currency')\|\|doc.docstatus==1 | — | — | |
| amount_base | 2 of 2 | — | 1 | — | — | Always read-only |
| target_currency | 1 of 2 | eval:doc.target_fund | 1 | — | target_fund.currency | Read-only; shown for context |
| target_exchange_rate | 2 of 2 | eval:doc.target_currency && doc.target_currency != doc.currency | eval:doc.docstatus==1 | — | — | Shown only when currencies differ |
| amount_in_target_currency | 1 of 2 | eval:doc.target_currency && doc.target_currency != doc.currency | 1 | — | — | Computed when cross-currency |

#### Section: Reason & Approval
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| reason | 1 of 1 | — | eval:doc.docstatus==1 | — | — | |
| restriction_check_passed | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |
| approval_reference | 2 of 2 | eval:doc.restriction_check_passed==1 | eval:doc.docstatus==1 | eval:doc.restriction_check_passed==1 | — | |
| approved_by | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |
| approval_date | 2 of 2 | — | eval:doc.docstatus==1 | — | — | |

#### Section: Journal Entry
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| journal_entry | 1 of 1 | eval:doc.journal_entry | 1 | — | — | Auto-created on Post; always read-only |

#### Section: Notes
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| notes | 1 of 1 | — | eval:doc.docstatus==1 | — | — | |

### Client Script Behavior
- On `source_fund` or `target_fund` change: validate they are not the same document.
- On `source_fund` selection: fetch `currency`; show available balance of source fund.
- On `target_fund` selection: fetch `target_currency`; if different from source currency, show cross-currency fields.
- If `source_fund.restriction_type == "Restricted"`: show warning — "Transfer dari dana restricted memerlukan `restriction_check_passed` dan referensi persetujuan."

---

## DocType: Fund Budget

**Module:** Fundara > Financial Accountability  
**Naming Series:** BDG-.YYYY.-.####  
**Submittable:** Yes | **Workflow:** Yes

### Layout Overview
Budget name and type at top. Type-dependent dimension fields (project/activity appear only for relevant types). Period. Currency and totals (all read-only). Budget lines child table (editable until Approved, then locked). Approval block.

### Sections and Fields

#### Section: Header
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| naming_series | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |
| budget_name | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |
| budget_type | 2 of 2 | — | eval:doc.docstatus==1 | — | — | Controls conditional dimension fields |

#### Section: Fund & Dimensions
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| fund | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |
| project | 2 of 2 | eval:doc.budget_type=="Project"\|\|doc.budget_type=="Activity" | eval:doc.docstatus==1 | eval:doc.budget_type=="Project"\|\|doc.budget_type=="Activity" | — | |
| activity | 1 of 2 | eval:doc.budget_type=="Activity" | eval:doc.docstatus==1 | eval:doc.budget_type=="Activity" | — | |
| cost_center | 2 of 2 | — | eval:doc.docstatus==1 | — | — | |

#### Section: Period
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| fiscal_year | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |
| start_date | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |
| end_date | 2 of 2 | — | eval:doc.docstatus==1 | — | — | |
| posting_date | 1 of 2 | — | eval:doc.docstatus==1 | — | — | Date of budget approval |

#### Section: Currency & Totals
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| currency | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |
| exchange_rate | 2 of 2 | — | eval:doc.currency==frappe.defaults.get_default('currency')\|\|doc.docstatus==1 | — | — | |
| total_approved_amount | 1 of 2 | — | 1 | — | — | Computed from budget_lines |
| total_actual_amount | 2 of 2 | — | 1 | — | — | Paid only (D-02) |
| total_available_amount | 1 of 2 | — | 1 | — | — | approved − actual |

#### Section: Budget Lines
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| budget_lines | 1 of 1 | — | eval:doc.status=="Approved"\|\|doc.status=="Active"\|\|doc.docstatus==1 | — | — | Locked after Approved |

#### Section: Approval
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| status | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |
| approved_by | 1 of 2 | eval:doc.status=="Approved"\|\|doc.status=="Active" | eval:doc.docstatus==1 | — | — | |
| approved_on | 2 of 2 | eval:doc.status=="Approved"\|\|doc.status=="Active" | eval:doc.docstatus==1 | — | — | |
| notes | 1 of 1 | — | eval:doc.docstatus==1 | — | — | |

### Client Script Behavior
- On `budget_lines` change: recompute `total_approved_amount` as sum of `approved_amount` across all lines.
- Warn before submission if `total_approved_amount` exceeds the linked fund's available balance.
- When `status == "Approved"` or `"Active"`: lock the `budget_lines` table and show info: "Budget sudah disetujui. Untuk mengubah, buat Budget Revision."

### Form Button Customizations
- **"Revisi Budget"** — visible when `status == "Active"` — creates a Budget Revision document linked to this budget.

---

## DocType: Purchase Order (Fundara)

**Module:** Fundara > Procurement  
**Naming Series:** PO-.YYYY.-.#####  
**Submittable:** Yes | **Workflow:** Yes

### Layout Overview
Source Purchase Request and Bid Analysis at top. Vendor. Fund/project/budget linkage. Order dates and currency. Items child table. Status and approval. Commitment journal entry link (read-only).

### Sections and Fields

#### Section: Header
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| naming_series | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |
| purchase_request | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |
| bid_analysis | 2 of 2 | — | eval:doc.docstatus==1 | — | — | Required when threshold rule mandates it |
| vendor | 1 of 2 | — | eval:doc.docstatus==1 | — | purchase_request.vendor | |
| erpnext_purchase_order | 2 of 2 | eval:doc.erpnext_purchase_order | 1 | — | — | Read-only when set |

#### Section: Fund & Budget
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| fund | 1 of 2 | — | eval:doc.docstatus==1 | — | purchase_request.fund | |
| project | 2 of 2 | — | eval:doc.docstatus==1 | — | purchase_request.project | |
| activity | 1 of 2 | — | eval:doc.docstatus==1 | — | purchase_request.activity | |
| cost_center | 2 of 2 | — | eval:doc.docstatus==1 | — | purchase_request.cost_center | |
| budget_line | 1 of 2 | — | eval:doc.docstatus==1 | — | purchase_request.budget_line | |

#### Section: Order Details
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| order_date | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |
| delivery_date | 2 of 2 | — | eval:doc.docstatus==1 | — | — | |
| currency | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |
| total_amount | 2 of 2 | — | eval:doc.docstatus==1 | — | — | |
| items | 1 of 1 | — | eval:doc.docstatus==1 | — | — | Child table |

#### Section: Additional Terms
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| payment_terms | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |
| delivery_address | 2 of 2 | — | eval:doc.docstatus==1 | — | — | |

#### Section: Status & Approval
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| status | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |
| approved_by | 1 of 2 | eval:doc.status=="Approved" | eval:doc.docstatus==1 | — | — | |
| approval_date | 2 of 2 | eval:doc.status=="Approved" | eval:doc.docstatus==1 | — | — | |
| cancellation_reason | 1 of 1 | eval:doc.status=="Cancelled" | eval:doc.docstatus==1 | eval:doc.status=="Cancelled" | — | |

#### Section: Commitment
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| commitment_created | 1 of 2 | — | 1 | — | — | System-set; always read-only |
| commitment_entry | 2 of 2 | eval:doc.commitment_entry | 1 | — | — | Auto-created; read-only |

#### Section: Documents
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| attachments | 1 of 1 | — | eval:doc.docstatus==1 | — | — | Signed PO, contract |

### Client Script Behavior
- On `purchase_request` selection: auto-fetch `fund`, `project`, `activity`, `cost_center`, `budget_line`, `currency` from PR.
- Validate vendor's `due_diligence_status` is "Passed" or "Waived"; show error if "Failed".
- On `items` change: recompute `total_amount` from sum of item amounts.

---

## DocType: Field Report

**Module:** Fundara > Mission Delivery  
**Naming Series:** FR-.YYYY.-.####  
**Submittable:** Yes | **Workflow:** Yes

### Layout Overview
Activity at top; project and fund auto-filled read-only. Report date and submitted by. Verification block visible after submission. Participants section. Narrative. Evidence attachments table.

### Sections and Fields

#### Section: Header
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| naming_series | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |
| field_report_number | 2 of 2 | — | 1 | — | — | Auto; always read-only |
| activity | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |
| project | 2 of 2 | — | 1 | — | activity.project | Always read-only |
| fund | 1 of 2 | — | 1 | — | activity.fund | Always read-only |
| cost_center | 2 of 2 | — | eval:doc.docstatus==1 | — | — | |

#### Section: Report Details
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| report_date | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |
| posting_date | 2 of 2 | — | eval:doc.docstatus==1 | — | — | |
| location | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |
| submitted_by | 2 of 2 | — | eval:doc.docstatus==1 | — | — | |
| verification_status | 1 of 2 | — | eval:doc.docstatus==1 | — | — | Workflow-controlled |

#### Section: Verification
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| verified_by | 1 of 2 | eval:doc.verification_status=="Verified"\|\|doc.verification_status=="Under Review" | eval:doc.docstatus==1 | — | — | Cannot be same user as submitted_by |
| verified_on | 2 of 2 | eval:doc.verification_status=="Verified" | eval:doc.docstatus==1 | — | — | |

#### Section: Participants
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| participant_count | 1 of 2 | — | eval:doc.docstatus==1 | — | — | |
| participant_breakdown | 2 of 2 | — | eval:doc.docstatus==1 | — | — | |

#### Section: Narrative
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| summary | 1 of 1 | — | eval:doc.docstatus==1 | — | — | |
| issues_encountered | 1 of 1 | — | eval:doc.docstatus==1 | — | — | |
| lessons_learned | 1 of 1 | — | eval:doc.docstatus==1 | — | — | |

#### Section: Evidence
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| evidence_attachments | 1 of 1 | — | eval:doc.docstatus==1 | — | — | Child table: Field Report Evidence |

### Client Script Behavior
- On `activity` selection: auto-fetch `project` and `fund` and lock them.
- On `verified_by` selection: validate it is not the same user as `submitted_by`. Show error if same.
- When `verification_status` changes to "Verified" and `verified_by` is the same as `submitted_by`: block and show error.

---

## DocType: Vendor Registration

**Module:** Fundara > Procurement  
**Naming Series:** VND-.YYYY.-.#####  
**Workflow:** Yes (no workflow submission but status-driven)

### Layout Overview
Vendor identity at top. Contact and address. Banking information. Due diligence section. Conflict of interest check. Status.

### Sections and Fields

#### Section: Header
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| naming_series | 1 of 2 | — | — | — | — | |
| vendor_name | 1 of 2 | — | — | — | — | |
| supplier | 2 of 2 | — | — | — | — | Link to ERPNext Supplier |
| vendor_type | 1 of 2 | — | — | — | — | |
| business_category | 2 of 2 | — | — | — | — | |

#### Section: Identity & Legal
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| tax_number | 1 of 2 | — | — | — | — | |
| registration_number | 2 of 2 | — | — | — | — | |

#### Section: Contact & Address
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| address | 1 of 1 | — | — | — | — | |
| city | 1 of 2 | — | — | — | — | |
| country | 2 of 2 | — | — | — | — | |
| contact_person | 1 of 2 | — | — | — | — | |
| phone | 1 of 2 | — | — | — | — | |
| email | 2 of 2 | — | — | — | — | |

#### Section: Banking
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| bank_name | 1 of 2 | — | — | — | — | |
| bank_account_number | 1 of 2 | — | — | — | — | |
| bank_account_name | 2 of 2 | — | — | — | — | |

#### Section: Due Diligence
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| due_diligence_status | 1 of 2 | — | — | — | — | |
| due_diligence_date | 2 of 2 | — | — | — | — | |
| due_diligence_notes | 1 of 1 | — | — | — | — | |
| due_diligence_document | 1 of 1 | — | — | — | — | |
| blacklist_check | 1 of 2 | — | — | — | — | |
| blacklist_check_date | 2 of 2 | eval:doc.blacklist_check==1 | — | — | — | |

#### Section: Conflict of Interest
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| conflict_of_interest | 1 of 2 | — | — | — | — | |
| coi_declaration_document | 2 of 2 | eval:doc.conflict_of_interest==1 | — | eval:doc.conflict_of_interest==1 | — | Mandatory when COI declared |

#### Section: Status
| Field | Column | depends_on | read_only | mandatory_depends_on | fetch_from | Notes |
|---|---|---|---|---|---|---|
| is_active | 1 of 2 | — | — | — | — | |
| deactivation_reason | 2 of 2 | eval:!doc.is_active | — | eval:!doc.is_active | — | Mandatory when deactivating |
| notes | 1 of 1 | — | — | — | — | |

### Client Script Behavior
- If `due_diligence_status == "Failed"`: show a persistent red banner — "Vendor ini gagal due diligence dan tidak dapat digunakan dalam pengadaan tanpa pengecualian yang disetujui."
- On `is_active` toggle to 0: require `deactivation_reason` before saving.

---

## Priority 3 — Standard DocTypes (Simplified Spec)

---

## DocType: Donor

**Module:** Fundara > Funding

### Key Conditional Rules
| Rule | Condition |
|---|---|
| `institutional_profile` visible | eval:doc.donor_type=="Institutional"\|\|doc.donor_type=="Multilateral Agency"\|\|doc.donor_type=="Government"\|\|doc.donor_type=="Philanthropic Foundation" |
| `contact_person` label changes | Show "Primary Contact" for institutional, "Full Name" for individual |
| `donor_contacts` table | Always visible |

### Form Section Order
1. Header: `naming_series`, `donor_name`, `donor_type`, `organization`
2. Contact: `contact_person`, `email`, `phone`, `country`, `preferred_language`, `donor_contacts` table
3. Preferences: `reporting_preference`, `acknowledgment_preference`
4. Relationship: `relationship_owner`, `linked_funding_source`
5. Institutional Profile: `institutional_profile` (conditional)
6. Status: `donor_status`, `is_anonymous_allowed`, `notes`

### Client Script Behavior
- If `donor_status == "Blacklisted"`: show red banner — "Donor ini diblacklist dan tidak dapat menerima donasi baru."
- If `donor_type` changes away from institutional types: clear `institutional_profile`.

---

## DocType: Funding Source

**Module:** Fundara > Funding

### Key Conditional Rules
| Rule | Condition |
|---|---|
| `linked_donor` visible | eval:["Institutional Donor","Individual Donor","Corporate Donor"].includes(doc.source_type) |
| `linked_campaign` visible | eval:doc.source_type=="Fundraising Campaign" |
| `linked_business_unit` visible | eval:["Social Enterprise Revenue","Service Revenue","Membership Fee"].includes(doc.source_type) |
| `deactivation_date` visible | eval:!doc.is_active |

### Form Section Order
1. Header: `naming_series`, `source_name`, `source_code`, `source_type`, `organization`
2. Contact & Ownership: `country`, `relationship_owner`, `responsible_department`
3. Fund Character: `default_restriction_type`, `reporting_expectation`, `risk_profile`
4. Links to Sub-records: `linked_donor`, `linked_campaign`, `linked_business_unit` (all conditional)
5. Status: `is_active`, `activation_date`, `deactivation_date`, `notes`

---

## DocType: Program

**Module:** Fundara > Mission Delivery

### Form Section Order
1. Header: `naming_series`, `program_name`, `program_code`
2. Basic Info (two column): Left: `strategic_objective`, `program_manager`; Right: `start_date`, `end_date`
3. Target & Status: `target_population`, `is_active`, `description`

### Key Rules
- No conditional fields.
- `is_active = 0` triggers a server-side check for active Projects — warn the user.

---

## DocType: Workplan

**Module:** Fundara > Mission Delivery

### Key Conditional Rules
| Rule | Condition |
|---|---|
| `period_label` | Always visible; free text |
| `approved_by`, `approval_date` | eval:doc.approval_status=="Approved" |
| `exchange_rate` | eval:doc.currency!=frappe.defaults.get_default('currency') |

### Form Section Order
1. Header: `naming_series`, `workplan_name`, `project`, `fund`, `cost_center`
2. Period: `period_type`, `period_label`, `start_date`, `end_date`
3. Activities: `activities` child table
4. Budget & Approval: `currency`, `exchange_rate`, `posting_date`, `planned_budget`, `approval_status`, `approved_by`, `approval_date`
5. Notes: `expected_outputs`, `notes`

### Client Script Behavior
- On `activities` table change: recompute `planned_budget` as sum of `planned_cost` across all rows.

---

## DocType: Evidence

> Note: "Evidence" in the MVP is the `Field Report Evidence` child table within Field Report. If a standalone Evidence DocType is implemented, apply the following simplified spec.

### Form Section Order
1. Header: `evidence_type`, `attachment`
2. Details: `description`

### Key Rules
- `attachment` is always mandatory.
- No conditional fields required.

---

## Appendix A: Global Client Script Patterns

### Pattern 1 — Base Currency Recomputation
```javascript
// Use in any form with currency + exchange_rate + *_base fields
function recompute_base(frm, amount_field, rate_field, base_field) {
    let amount = frm.doc[amount_field] || 0;
    let rate = frm.doc[rate_field] || 1;
    frappe.model.set_value(frm.doctype, frm.docname, base_field, flt(amount * rate, 2));
}
```

### Pattern 2 — Exchange Rate Lock
```javascript
// Run on currency change
function handle_currency_change(frm, currency_field, rate_field) {
    let base_currency = frappe.defaults.get_default('currency');
    if (frm.doc[currency_field] === base_currency) {
        frm.set_value(rate_field, 1.0);
        frm.set_df_property(rate_field, 'read_only', 1);
    } else {
        frm.set_df_property(rate_field, 'read_only', 0);
    }
}
```

### Pattern 3 — D-02 Pending Payment Banner
```javascript
// Cash Advance and any form showing pending_payment_flag
frappe.ui.form.on('Cash Advance', {
    refresh: function(frm) {
        if (frm.doc.status === 'Approved' && frm.doc.pending_payment_flag) {
            frm.set_intro(
                __('Advance ini belum dibayar. Budget belum berkurang. Pastikan pembayaran diproses untuk mencatat pengurangan budget.'),
                'yellow'
            );
        } else {
            frm.set_intro('');
        }
    },
    status: function(frm) {
        // Re-evaluate intro on status change
        frm.trigger('refresh');
    }
});
```

### Pattern 4 — Post-Submit Global Lock
```javascript
// In setup() of any submittable DocType's client script
frappe.ui.form.on('DocType Name', {
    refresh: function(frm) {
        if (frm.doc.docstatus === 1) {
            frm.disable_form();
            // Exception: add Amendment button if needed
        }
    }
});
```

---

## Appendix B: Approval Matrix Reference

The following matrix (from `workflow.md` §42) informs which role-gates should be surfaced in approval fields on each form.

| Fund Type | Primary Approvers | Special Controls |
|---|---|---|
| Grant Fund | Project Manager → Finance → Grant Manager | Donor rule, budget line, grant period |
| Campaign Fund | Campaign Manager → Program → Finance | Public accountability, restricted purpose |
| Unrestricted Fund | Department Head → Finance → Management | Annual budget, cash flow |
| Business Surplus Fund | BU Manager → Finance → Management | P&L, tax, surplus policy |
| Reserve Fund | Executive Director → Board | Reserve policy, strategic approval |
| Bridging Fund | Finance Manager → Executive Director | Recoverability, settlement plan |

| Transaction Value | Minimum Approval |
|---|---|
| Small | Supervisor / Project Manager |
| Medium | Project Manager + Finance |
| Large | Finance Manager + Procurement Manager |
| Very Large | Executive Director / Board |

---

## Appendix C: depends_on Syntax Quick Reference

All `depends_on` values in Frappe use the `eval:` prefix. Common patterns used in this document:

| Pattern | Syntax |
|---|---|
| Field equals value | `eval:doc.field_name=="value"` |
| Field not equal | `eval:doc.field_name!="value"` |
| Boolean field is true | `eval:doc.field_name==1` |
| Boolean field is false | `eval:!doc.field_name` |
| Multiple OR conditions | `eval:doc.f=="a"\|\|doc.f=="b"` |
| Multiple AND conditions | `eval:doc.f=="a"&&doc.g=="b"` |
| Post-submit lock | `eval:doc.docstatus==1` |
| Base currency check | `eval:doc.currency==frappe.defaults.get_default('currency')` |
| Field has a value | `eval:doc.field_name` |

> **Note on `mandatory_depends_on`:** This property makes a field mandatory only when the condition is true. It does not show or hide the field — use `depends_on` for visibility and `mandatory_depends_on` separately for conditional mandatory logic.
