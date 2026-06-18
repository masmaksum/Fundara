# Financial Accountability — DocType Field Specifications

**Module:** Fundara > Financial Accountability
**Source Context:** `fundara-domain-contexts/06-financial-accountability-context.md`
**Key Decision:** D-02 — Available Budget = Approved Budget − Actual (paid only). Cash Advance in status Approved-but-not-Paid does NOT reduce budget. `pending_payment_flag` field provides dashboard warning only.
**Key Decision:** D-04 — Multi-currency is in MVP. Every transaction DocType carries `currency`, `exchange_rate`, and base-currency equivalent where relevant.

---

## DocType: Accounting Standard Profile

**Module:** Fundara > Financial Accountability
**Parent (if child table):** —
**Is Submittable:** No
**Has Workflow:** No
**Naming Series:** —

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | profile_name | Profile Name | Data | | Yes | e.g. "Indonesia - ISAK 35" |
| 2 | country | Country | Link | Country | No | |
| 3 | reporting_framework | Reporting Framework | Select | ISAK 35\nFASB ASC 958\nCustom | Yes | |
| 4 | — | — | Section Break | | | Defaults |
| 5 | default_net_asset_class | Default Net Asset Classification | Select | With Donor Restrictions\nWithout Donor Restrictions\nBoard-Designated | No | |
| 6 | default_currency | Default Currency | Link | Currency | No | |
| 7 | fiscal_year_rule | Fiscal Year Rule | Select | January-December\nApril-March\nJuly-June\nOctober-September\nCustom | No | |
| 8 | — | — | Section Break | | | Report Templates |
| 9 | default_report_templates | Default Report Templates | Small Text | | No | Comma-separated list of template names |
| 10 | — | — | Section Break | | | Status |
| 11 | is_active | Is Active | Check | | No | Default 1 |
| 12 | notes | Notes | Long Text | | No | |

**Business Rules:**
1. Only one Accounting Standard Profile should be active per Company at any time.
2. `reporting_framework` determines which financial report templates the system generates by default.

---

## DocType: Net Asset Class

**Module:** Fundara > Financial Accountability
**Parent (if child table):** —
**Is Submittable:** No
**Has Workflow:** No
**Naming Series:** —

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | class_name | Class Name | Data | | Yes | e.g. "Aset Neto Dengan Pembatasan" |
| 2 | class_code | Class Code | Data | | No | Short code for reporting |
| 3 | classification_type | Classification Type | Select | With Donor Restrictions\nWithout Donor Restrictions\nBoard-Designated | Yes | |
| 4 | accounting_standard_profile | Accounting Standard Profile | Link | Accounting Standard Profile | No | |
| 5 | mapped_account | Mapped Account | Link | Account | No | GL account for this class |
| 6 | description | Description | Small Text | | No | |
| 7 | is_active | Is Active | Check | | No | Default 1 |

**Business Rules:**
1. `class_name` must be unique.
2. `classification_type` must align with the linked `accounting_standard_profile.reporting_framework`.

---

## DocType: Fund Budget Line

**Module:** Fundara > Financial Accountability
**Parent (if child table):** Fund Budget
**Is Submittable:** No
**Has Workflow:** No
**Naming Series:** —

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | budget_line_name | Budget Line Name | Data | | Yes | e.g. "Personnel", "Training", "Travel" |
| 2 | budget_code | Budget Code | Data | | No | Donor-facing code |
| 3 | parent_budget_line | Parent Budget Line | Link | Fund Budget Line | No | For hierarchical budget lines |
| 4 | — | — | Section Break | | | Amount |
| 5 | approved_amount | Approved Amount | Currency | | Yes | |
| 6 | revised_amount | Revised Amount | Currency | | No | Populated after Budget Revision |
| 7 | actual_amount | Actual Amount | Currency | | No | System-computed; paid transactions only (D-02) |
| 8 | — | — | Section Break | | | Mapping |
| 9 | allowed_accounts | Allowed Accounts | Small Text | | No | Comma-separated GL account codes |
| 10 | donor_report_category | Donor Report Category | Data | | No | Label used in donor reports |
| 11 | fund_restriction | Fund Restriction | Select | Unrestricted\nTemporarily Restricted\nPermanently Restricted | No | |
| 12 | is_active | Is Active | Check | | No | Default 1 |
| 13 | notes | Notes | Small Text | | No | |

**Business Rules:**
1. `approved_amount` must be > 0.
2. `actual_amount` is system-maintained — it increments only when a Cash Advance reaches status Paid, or a disbursement/invoice is posted (D-02).
3. Available budget for this line = (`revised_amount` if set, else `approved_amount`) − `actual_amount`.

---

## DocType: Fund Budget

**Module:** Fundara > Financial Accountability
**Parent (if child table):** —
**Is Submittable:** Yes
**Has Workflow:** Yes
**Naming Series:** BDG-.YYYY.-.####

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | naming_series | Series | Select | BDG-.YYYY.-.#### | Yes | |
| 2 | budget_name | Budget Name | Data | | Yes | |
| 3 | budget_type | Budget Type | Select | Organizational\nProgram\nProject\nGrant\nCampaign\nBusiness Unit\nActivity | Yes | |
| 4 | — | — | Section Break | | | Fund & Dimensions |
| 5 | fund | Fund | Link | Fund | Yes | |
| 6 | project | Project | Link | Project | No | Required if budget_type = Project or Activity |
| 7 | activity | Activity | Link | Activity | No | Required if budget_type = Activity |
| 8 | cost_center | Cost Center | Link | Cost Center | No | |
| 9 | — | — | Section Break | | | Period |
| 10 | fiscal_year | Fiscal Year | Link | Fiscal Year | Yes | |
| 11 | start_date | Start Date | Date | | Yes | |
| 12 | end_date | End Date | Date | | Yes | |
| 13 | posting_date | Posting Date | Date | | No | Date of budget approval |
| 14 | — | — | Section Break | | | Currency & Totals |
| 15 | currency | Currency | Link | Currency | Yes | |
| 16 | exchange_rate | Exchange Rate | Float | | No | Default 1.0 |
| 17 | total_approved_amount | Total Approved Amount | Currency | | No | Sum of budget lines; read-only |
| 18 | total_actual_amount | Total Actual Amount | Currency | | No | System-computed (paid only, D-02); read-only |
| 19 | total_available_amount | Total Available Amount | Currency | | No | Computed: total_approved_amount − total_actual_amount |
| 20 | — | — | Section Break | | | Budget Lines |
| 21 | budget_lines | Budget Lines | Table | Fund Budget Line | Yes | |
| 22 | — | — | Section Break | | | Approval |
| 23 | status | Status | Select | Draft\nSubmitted\nReview by Program\nReview by Finance\nApproved\nActive\nRevised\nClosed | Yes | Default: Draft |
| 24 | approved_by | Approved By | Link | User | No | |
| 25 | approved_on | Approved On | Date | | No | |
| 26 | — | — | Section Break | | | Notes |
| 27 | notes | Notes | Long Text | | No | |

**Business Rules:**
1. `end_date` must be >= `start_date`.
2. Budget can only be set to Active after submission and approval workflow completes.
3. `total_approved_amount`, `total_actual_amount`, and `total_available_amount` are system-computed from child `budget_lines`.
4. Once Approved/Active, budget lines cannot be changed directly — a Budget Revision must be created.
5. `total_actual_amount` reflects only paid transactions per D-02.

---

## DocType: Budget Revision Line

**Module:** Fundara > Financial Accountability
**Parent (if child table):** Budget Revision
**Is Submittable:** No
**Has Workflow:** No
**Naming Series:** —

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | budget_line | Budget Line | Link | Fund Budget Line | Yes | Line being revised |
| 2 | original_amount | Original Amount | Currency | | No | Read-only; pulled from linked budget line |
| 3 | revised_amount | Revised Amount | Currency | | Yes | New approved amount |
| 4 | change_amount | Change Amount | Currency | | No | Computed: revised_amount − original_amount; read-only |
| 5 | justification | Justification | Small Text | | Yes | Reason for revision |

**Business Rules:**
1. `revised_amount` must be >= 0.
2. `change_amount` is system-computed.

---

## DocType: Budget Revision

**Module:** Fundara > Financial Accountability
**Parent (if child table):** —
**Is Submittable:** Yes
**Has Workflow:** Yes
**Naming Series:** BDGR-.YYYY.-.####

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | naming_series | Series | Select | BDGR-.YYYY.-.#### | Yes | |
| 2 | budget | Budget | Link | Fund Budget | Yes | Parent budget being revised |
| 3 | revision_number | Revision Number | Int | | No | Auto-incremented per budget |
| 4 | — | — | Section Break | | | Fund & Period |
| 5 | fund | Fund | Link | Fund | No | Read-only; from parent budget |
| 6 | project | Project | Link | Project | No | Read-only; from parent budget |
| 7 | cost_center | Cost Center | Link | Cost Center | No | |
| 8 | posting_date | Posting Date | Date | | Yes | Date of revision |
| 9 | — | — | Section Break | | | Currency |
| 10 | currency | Currency | Link | Currency | Yes | |
| 11 | exchange_rate | Exchange Rate | Float | | No | Default 1.0 |
| 12 | — | — | Section Break | | | Revision Lines |
| 13 | revision_lines | Revision Lines | Table | Budget Revision Line | Yes | |
| 14 | — | — | Section Break | | | Approval |
| 15 | status | Status | Select | Draft\nSubmitted\nApproved\nRejected | Yes | Default: Draft |
| 16 | reason | Reason | Long Text | | Yes | Overall justification for revision |
| 17 | approved_by | Approved By | Link | User | No | |
| 18 | approved_on | Approved On | Date | | No | |

**Business Rules:**
1. A Budget Revision can only be created for a budget in status Active or Approved.
2. On approval, the system updates the `revised_amount` on each affected `Fund Budget Line`.
3. Revision history is preserved — existing approved Budget Revision records must not be modified.
4. `revision_number` auto-increments per parent `budget`.

---

## DocType: Cash Receipt

**Module:** Fundara > Financial Accountability
**Parent (if child table):** —
**Is Submittable:** Yes
**Has Workflow:** Yes
**Naming Series:** CRCP-.YYYY.-.####

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | naming_series | Series | Select | CRCP-.YYYY.-.#### | Yes | |
| 2 | receipt_date | Receipt Date | Date | | Yes | |
| 3 | posting_date | Posting Date | Date | | Yes | Accounting posting date |
| 4 | — | — | Section Break | | | Account & Fund |
| 5 | cash_bank_account | Cash / Bank Account | Link | Account | Yes | GL cash or bank account |
| 6 | fund | Fund | Link | Fund | Yes | |
| 7 | project | Project | Link | Project | No | |
| 8 | cost_center | Cost Center | Link | Cost Center | No | |
| 9 | — | — | Section Break | | | Source |
| 10 | source_type | Source Type | Select | Donor\nCampaign\nBusiness Unit\nGrant\nUnrestricted\nOther | Yes | |
| 11 | donor | Donor | Link | Donor | No | Required if source_type = Donor or Grant |
| 12 | campaign | Campaign | Link | Campaign | No | Required if source_type = Campaign |
| 13 | — | — | Section Break | | | Amount |
| 14 | currency | Currency | Link | Currency | Yes | |
| 15 | exchange_rate | Exchange Rate | Float | | Yes | Default 1.0 |
| 16 | amount | Amount | Currency | | Yes | Amount in transaction currency |
| 17 | amount_in_base_currency | Amount in Base Currency | Currency | | No | System-computed: amount × exchange_rate |
| 18 | — | — | Section Break | | | Category & Reference |
| 19 | receipt_category | Receipt Category | Select | General Donation\nRestricted Donation\nGrant Receipt\nCampaign Income\nBusiness Unit Income\nOther | Yes | |
| 20 | net_asset_class | Net Asset Class | Link | Net Asset Class | No | |
| 21 | reference_number | Reference Number | Data | | No | Bank transfer ref, cheque no., etc. |
| 22 | — | — | Section Break | | | Posting |
| 23 | income_account | Income Account | Link | Account | Yes | Credit account for double-entry |
| 24 | posting_status | Posting Status | Select | Draft\nPosted\nCancelled | No | System-managed |
| 25 | journal_entry | Journal Entry | Link | Journal Entry | No | Auto-created on Submit |
| 26 | — | — | Section Break | | | Evidence |
| 27 | attachment | Attachment | Attach | | No | |
| 28 | remarks | Remarks | Small Text | | No | |

**Business Rules:**
1. On Submit, system auto-creates a Journal Entry: Dr `cash_bank_account` / Cr `income_account`.
2. `amount_in_base_currency` is system-computed as `amount × exchange_rate`.
3. `journal_entry` is populated by the system after auto-posting.
4. Posted receipts cannot be amended without a cancellation and reversal entry.
5. If `source_type = Donor` or `Grant`, `donor` field is mandatory.

---

## DocType: Cash Disbursement

**Module:** Fundara > Financial Accountability
**Parent (if child table):** —
**Is Submittable:** Yes
**Has Workflow:** Yes
**Naming Series:** CDSB-.YYYY.-.####

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | naming_series | Series | Select | CDSB-.YYYY.-.#### | Yes | |
| 2 | disbursement_date | Disbursement Date | Date | | Yes | |
| 3 | posting_date | Posting Date | Date | | Yes | Accounting posting date |
| 4 | — | — | Section Break | | | Account & Fund |
| 5 | cash_bank_account | Cash / Bank Account | Link | Account | Yes | GL cash or bank account |
| 6 | fund | Fund | Link | Fund | Yes | |
| 7 | project | Project | Link | Project | No | |
| 8 | activity | Activity | Link | Activity | No | |
| 9 | budget_line | Budget Line | Link | Fund Budget Line | Yes | |
| 10 | cost_center | Cost Center | Link | Cost Center | No | |
| 11 | — | — | Section Break | | | Payee |
| 12 | payee_type | Payee Type | Select | Supplier\nEmployee\nOther | Yes | |
| 13 | payee_name | Payee Name | Data | | Yes | |
| 14 | payee | Payee | Dynamic Link | payee_type | No | Link to Supplier or Employee |
| 15 | — | — | Section Break | | | Amount |
| 16 | currency | Currency | Link | Currency | Yes | |
| 17 | exchange_rate | Exchange Rate | Float | | Yes | Default 1.0 |
| 18 | amount | Amount | Currency | | Yes | Amount in transaction currency |
| 19 | amount_in_base_currency | Amount in Base Currency | Currency | | No | System-computed: amount × exchange_rate |
| 20 | — | — | Section Break | | | Expense Account |
| 21 | expense_account | Expense / Asset Account | Link | Account | Yes | Dr account for double-entry |
| 22 | disbursement_type | Disbursement Type | Select | Expense\nAsset Purchase\nAdvance Payment\nOther | Yes | |
| 23 | — | — | Section Break | | | Posting |
| 24 | posting_status | Posting Status | Select | Draft\nPosted\nCancelled | No | System-managed |
| 25 | journal_entry | Journal Entry | Link | Journal Entry | No | Auto-created on Submit |
| 26 | reconciliation_status | Reconciliation Status | Select | Unreconciled\nMatched\nReconciled | No | Default: Unreconciled |
| 27 | — | — | Section Break | | | Evidence & Approval |
| 28 | approval_status | Approval Status | Select | Draft\nSubmitted\nApproved\nRejected | No | |
| 29 | approved_by | Approved By | Link | User | No | |
| 30 | attachment | Attachment | Attach | | No | Receipt / invoice |
| 31 | evidence_status | Evidence Status | Select | Incomplete\nComplete | No | |
| 32 | remarks | Remarks | Small Text | | No | |

**Business Rules:**
1. On Submit, system auto-creates a Journal Entry: Dr `expense_account` / Cr `cash_bank_account`.
2. Budget availability for the linked `budget_line` must be checked before approval (Available = Approved − Actual paid per D-02).
3. `reconciliation_status` is updated by the Bank Reconciliation process.
4. If `fund` is a donor-restricted fund, `project` and `budget_line` are mandatory.
5. `amount_in_base_currency` is system-computed as `amount × exchange_rate`.

---

## DocType: General Journal Line

**Module:** Fundara > Financial Accountability
**Parent (if child table):** General Journal
**Is Submittable:** No
**Has Workflow:** No
**Naming Series:** —

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | account | Account | Link | Account | Yes | GL account |
| 2 | debit_amount | Debit | Currency | | No | In transaction currency |
| 3 | credit_amount | Credit | Currency | | No | In transaction currency |
| 4 | fund | Fund | Link | Fund | No | Dimension — required if account touches fund balances |
| 5 | project | Project | Link | Project | No | Dimension |
| 6 | activity | Activity | Link | Activity | No | Dimension |
| 7 | budget_line | Budget Line | Link | Fund Budget Line | No | Dimension |
| 8 | cost_center | Cost Center | Link | Cost Center | No | Dimension |
| 9 | net_asset_class | Net Asset Class | Link | Net Asset Class | No | |
| 10 | reference_type | Reference Type | Data | | No | e.g. "Cash Advance", "Depreciation" |
| 11 | reference_name | Reference Name | Data | | No | Name of the linked document |
| 12 | remarks | Remarks | Small Text | | No | |

**Business Rules:**
1. Each line must have either `debit_amount > 0` or `credit_amount > 0`, but not both.
2. If the account belongs to a fund-balance-affecting account type, `fund` is mandatory.

---

## DocType: General Journal

**Module:** Fundara > Financial Accountability
**Parent (if child table):** —
**Is Submittable:** Yes
**Has Workflow:** Yes
**Naming Series:** JV-.YYYY.-.####

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | naming_series | Series | Select | JV-.YYYY.-.#### | Yes | |
| 2 | journal_type | Journal Type | Select | Adjustment\nAccrual\nAllocation\nCorrection\nDepreciation\nOpening Balance\nFund Transfer\nRestriction Release\nOther | Yes | |
| 3 | posting_date | Posting Date | Date | | Yes | |
| 4 | — | — | Section Break | | | Dimensions |
| 5 | fund | Fund | Link | Fund | No | Primary fund dimension; line-level fund overrides |
| 6 | project | Project | Link | Project | No | |
| 7 | cost_center | Cost Center | Link | Cost Center | No | |
| 8 | — | — | Section Break | | | Currency |
| 9 | currency | Currency | Link | Currency | Yes | Transaction currency |
| 10 | exchange_rate | Exchange Rate | Float | | Yes | Default 1.0 |
| 11 | — | — | Section Break | | | Journal Lines |
| 12 | journal_lines | Journal Lines | Table | General Journal Line | Yes | |
| 13 | total_debit | Total Debit | Currency | | No | System-computed; read-only |
| 14 | total_credit | Total Credit | Currency | | No | System-computed; read-only |
| 15 | — | — | Section Break | | | Reason & Approval |
| 16 | adjustment_reason | Adjustment Reason | Small Text | | Yes | Mandatory for all journal types |
| 17 | status | Status | Select | Draft\nSubmitted\nApproved\nPosted\nCancelled | Yes | Default: Draft |
| 18 | approved_by | Approved By | Link | User | No | |
| 19 | approved_on | Approved On | Date | | No | |
| 20 | linked_journal_entry | ERPNext Journal Entry | Link | Journal Entry | No | Auto-created on posting |
| 21 | — | — | Section Break | | | Notes |
| 22 | remarks | Remarks | Long Text | | No | |

**Business Rules:**
1. Journal must balance: `total_debit == total_credit` before it can be submitted/posted.
2. `adjustment_reason` is mandatory for all journal types.
3. Journal lines that touch fund-restricted accounts must carry a `fund` dimension.
4. Posted journals cannot be edited — only reversed via a new Correction journal.
5. `linked_journal_entry` is system-populated on posting to ERPNext GL.

---

## DocType: Cash Advance

**Module:** Fundara > Financial Accountability
**Parent (if child table):** —
**Is Submittable:** Yes
**Has Workflow:** Yes
**Naming Series:** ADV-.YYYY.-.####

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | naming_series | Series | Select | ADV-.YYYY.-.#### | Yes | |
| 2 | advance_number | Advance Number | Data | | No | Auto from naming_series |
| 3 | — | — | Section Break | | | Requester |
| 4 | requester | Requester | Link | User | Yes | Staff requesting the advance |
| 5 | requester_department | Department | Link | Department | No | Auto-populated from requester |
| 6 | — | — | Section Break | | | Activity & Fund |
| 7 | fund | Fund | Link | Fund | Yes | |
| 8 | project | Project | Link | Project | Yes | |
| 9 | activity | Activity | Link | Activity | Yes | Advance must be tied to an Activity |
| 10 | budget_line | Budget Line | Link | Fund Budget Line | Yes | |
| 11 | cost_center | Cost Center | Link | Cost Center | No | |
| 12 | — | — | Section Break | | | Currency & Amounts |
| 13 | currency | Currency | Link | Currency | Yes | |
| 14 | exchange_rate | Exchange Rate | Float | | Yes | Default 1.0 |
| 15 | requested_amount | Requested Amount | Currency | | Yes | Amount requested by staff |
| 16 | approved_amount | Approved Amount | Currency | | No | Set during Finance approval |
| 17 | paid_amount | Paid Amount | Currency | | No | Actual amount disbursed (D-02: this reduces budget) |
| 18 | — | — | Section Break | | | D-02 Budget Control |
| 19 | pending_payment_flag | Pending Payment (Dashboard Warning) | Check | | No | Set to 1 when status=Approved but not yet Paid. Does NOT reduce budget. Dashboard warning only. |
| 20 | — | — | Section Break | | | Purpose & Schedule |
| 21 | purpose | Purpose | Small Text | | Yes | Description of what advance is for |
| 22 | expected_activity_date | Expected Activity Date | Date | | No | |
| 23 | posting_date | Posting Date | Date | | Yes | |
| 24 | liquidation_due_date | Liquidation Due Date | Date | | Yes | Deadline for submitting liquidation |
| 25 | — | — | Section Break | | | Status & Aging |
| 26 | status | Status | Select | Draft\nSubmitted\nUnder Review\nApproved\nPaid\nPending Liquidation\nOverdue\nLiquidated\nClosed\nRejected\nCancelled | Yes | Default: Draft |
| 27 | aging_category | Aging Category | Select | 0-7 Days\n8-14 Days\n15-30 Days\n>30 Days\nOverdue | No | System-computed based on days since Paid |
| 28 | days_outstanding | Days Outstanding | Int | | No | System-computed; days since Paid |
| 29 | — | — | Section Break | | | Approval |
| 30 | supervisor_approved_by | Supervisor Approved By | Link | User | No | |
| 31 | supervisor_approved_on | Supervisor Approved On | Date | | No | |
| 32 | finance_approved_by | Finance Approved By | Link | User | No | |
| 33 | finance_approved_on | Finance Approved On | Date | | No | |
| 34 | rejected_reason | Rejected / Cancelled Reason | Small Text | | No | |
| 35 | — | — | Section Break | | | Payment Reference |
| 36 | payment_reference | Payment Reference | Data | | No | Bank transfer ref or payment voucher |
| 37 | payment_date | Payment Date | Date | | No | Date when disbursement was made |
| 38 | payment_journal_entry | Payment Journal Entry | Link | Journal Entry | No | Auto-created when status→Paid |
| 39 | — | — | Section Break | | | Notes |
| 40 | remarks | Remarks | Long Text | | No | |

**Business Rules:**
1. `activity` must be in status Approved or In Progress before an advance can be submitted.
2. `approved_amount` is set during Finance approval and cannot exceed the available budget of the linked `budget_line`.
3. **D-02:** Only `paid_amount` (recorded when status transitions to Paid) reduces budget. `approved_amount` alone does NOT reduce budget.
4. `pending_payment_flag` = 1 when status = Approved and payment has not yet been made. This is a dashboard warning flag only and has no budget impact.
5. When status transitions to Paid, system sets `paid_amount`, records `payment_date`, creates `payment_journal_entry`, and sets `pending_payment_flag` = 0.
6. `liquidation_due_date` is mandatory and must be a future date at time of submission.
7. Status transitions to Overdue automatically if `liquidation_due_date` has passed and status is still Pending Liquidation.
8. `aging_category` and `days_outstanding` are system-computed from `payment_date`.
9. Cancellation is only allowed before status = Paid. After Paid, a reversal process is required.
10. Status lifecycle: Draft → Submitted → Under Review → Approved → Paid → Pending Liquidation → Overdue → Liquidated → Closed / (Rejected or Cancelled from appropriate states).

---

## DocType: Additional Advance Payment

**Module:** Fundara > Financial Accountability
**Parent (if child table):** —
**Is Submittable:** Yes
**Has Workflow:** Yes
**Naming Series:** AADV-.YYYY.-.####

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | naming_series | Series | Select | AADV-.YYYY.-.#### | Yes | |
| 2 | cash_advance | Cash Advance | Link | Cash Advance | Yes | Parent advance being topped up |
| 3 | — | — | Section Break | | | Dimensions |
| 4 | fund | Fund | Link | Fund | No | Read-only; from parent Cash Advance |
| 5 | project | Project | Link | Project | No | Read-only; from parent Cash Advance |
| 6 | activity | Activity | Link | Activity | No | Read-only; from parent Cash Advance |
| 7 | budget_line | Budget Line | Link | Fund Budget Line | No | Read-only; from parent Cash Advance |
| 8 | cost_center | Cost Center | Link | Cost Center | No | |
| 9 | posting_date | Posting Date | Date | | Yes | |
| 10 | — | — | Section Break | | | Amount |
| 11 | currency | Currency | Link | Currency | Yes | |
| 12 | exchange_rate | Exchange Rate | Float | | Yes | Default 1.0 |
| 13 | additional_amount | Additional Amount | Currency | | Yes | Top-up amount |
| 14 | reason | Reason | Small Text | | Yes | Why additional amount is needed |
| 15 | — | — | Section Break | | | Approval |
| 16 | status | Status | Select | Draft\nSubmitted\nApproved\nPaid\nRejected\nCancelled | Yes | Default: Draft |
| 17 | approved_by | Approved By | Link | User | No | |
| 18 | approved_on | Approved On | Date | | No | |
| 19 | payment_date | Payment Date | Date | | No | |
| 20 | payment_journal_entry | Payment Journal Entry | Link | Journal Entry | No | |

**Business Rules:**
1. Additional Advance Payment can only be created for a Cash Advance in status Pending Liquidation or Overdue.
2. `additional_amount` must be within available budget of the linked `budget_line` (D-02: availability = approved − paid).
3. On status → Paid, `paid_amount` on parent Cash Advance is incremented and budget is reduced accordingly.
4. All dimension fields (`fund`, `project`, `activity`, `budget_line`) are read-only and inherited from parent Cash Advance.

---

## DocType: Advance Liquidation Line

**Module:** Fundara > Financial Accountability
**Parent (if child table):** Advance Liquidation
**Is Submittable:** No
**Has Workflow:** No
**Naming Series:** —

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | expense_description | Expense Description | Data | | Yes | What was spent on |
| 2 | expense_date | Expense Date | Date | | Yes | |
| 3 | account | Expense Account | Link | Account | Yes | GL account for this expense |
| 4 | budget_line | Budget Line | Link | Fund Budget Line | No | May differ from advance budget line |
| 5 | amount | Amount | Currency | | Yes | |
| 6 | receipt_reference | Receipt Reference | Data | | No | Receipt or invoice number |
| 7 | attachment | Attachment | Attach | | No | Receipt file |

---

## DocType: Advance Liquidation

**Module:** Fundara > Financial Accountability
**Parent (if child table):** —
**Is Submittable:** Yes
**Has Workflow:** Yes
**Naming Series:** LIQ-.YYYY.-.####

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | naming_series | Series | Select | LIQ-.YYYY.-.#### | Yes | |
| 2 | cash_advance | Cash Advance | Link | Cash Advance | Yes | Advance being liquidated |
| 3 | — | — | Section Break | | | Dimensions (read-only from advance) |
| 4 | fund | Fund | Link | Fund | No | Read-only; from Cash Advance |
| 5 | project | Project | Link | Project | No | Read-only; from Cash Advance |
| 6 | activity | Activity | Link | Activity | No | Read-only; from Cash Advance |
| 7 | cost_center | Cost Center | Link | Cost Center | No | |
| 8 | posting_date | Posting Date | Date | | Yes | |
| 9 | — | — | Section Break | | | Currency & Amounts |
| 10 | currency | Currency | Link | Currency | Yes | |
| 11 | exchange_rate | Exchange Rate | Float | | Yes | Default 1.0 |
| 12 | advance_paid_amount | Advance Paid Amount | Currency | | No | Read-only; from Cash Advance.paid_amount |
| 13 | total_actual_expense | Total Actual Expense | Currency | | No | System-computed: sum of expense_lines |
| 14 | — | — | Section Break | | | Expense Lines |
| 15 | expense_lines | Expense Lines | Table | Advance Liquidation Line | Yes | |
| 16 | — | — | Section Break | | | Settlement |
| 17 | refund_amount | Refund Amount | Currency | | No | Computed: advance_paid_amount − total_actual_expense (if positive) |
| 18 | reimbursement_amount | Reimbursement Amount | Currency | | No | Computed: total_actual_expense − advance_paid_amount (if positive) |
| 19 | settlement_type | Settlement Type | Select | No Difference\nRefund Required\nReimbursement Required | No | System-computed |
| 20 | — | — | Section Break | | | Refund Details |
| 21 | refund_receipt_reference | Refund Receipt Reference | Data | | No | Required if settlement_type = Refund Required |
| 22 | refund_date | Refund Date | Date | | No | |
| 23 | — | — | Section Break | | | Review |
| 24 | review_status | Review Status | Select | Draft\nSubmitted\nUnder Review by Finance\nApproved\nRejected | Yes | Default: Draft |
| 25 | finance_reviewed_by | Finance Reviewed By | Link | User | No | |
| 26 | finance_reviewed_on | Finance Reviewed On | Date | | No | |
| 27 | — | — | Section Break | | | Evidence |
| 28 | evidence_completeness | Evidence Completeness | Select | Incomplete\nComplete | No | Assessed by Finance reviewer |
| 29 | remarks | Remarks | Long Text | | No | |

**Business Rules:**
1. Liquidation cannot be created unless the linked `cash_advance.status` is Pending Liquidation or Overdue.
2. `expense_lines` must contain at least one line.
3. Finance cannot approve without setting `evidence_completeness = Complete`.
4. On Finance approval, system sets `cash_advance.status = Liquidated`.
5. `refund_amount` and `reimbursement_amount` are system-computed.
6. If `settlement_type = Refund Required`, `refund_receipt_reference` and `refund_date` are mandatory before closing the advance.
7. On full settlement (including refund if required), Cash Advance status transitions to Closed.
8. Dimension fields (`fund`, `project`, `activity`) are read-only, inherited from Cash Advance.

---

## DocType: Reimbursement Request

**Module:** Fundara > Financial Accountability
**Parent (if child table):** —
**Is Submittable:** Yes
**Has Workflow:** Yes
**Naming Series:** REIM-.YYYY.-.####

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | naming_series | Series | Select | REIM-.YYYY.-.#### | Yes | |
| 2 | requester | Requester | Link | User | Yes | Staff who paid out of pocket |
| 3 | — | — | Section Break | | | Activity & Fund |
| 4 | fund | Fund | Link | Fund | Yes | |
| 5 | project | Project | Link | Project | No | |
| 6 | activity | Activity | Link | Activity | No | |
| 7 | budget_line | Budget Line | Link | Fund Budget Line | Yes | |
| 8 | cost_center | Cost Center | Link | Cost Center | No | |
| 9 | posting_date | Posting Date | Date | | Yes | |
| 10 | — | — | Section Break | | | Amount |
| 11 | currency | Currency | Link | Currency | Yes | |
| 12 | exchange_rate | Exchange Rate | Float | | Yes | Default 1.0 |
| 13 | amount_claimed | Amount Claimed | Currency | | Yes | |
| 14 | amount_approved | Amount Approved | Currency | | No | Set during approval |
| 15 | — | — | Section Break | | | Details |
| 16 | expense_date | Expense Date | Date | | Yes | Date expense was incurred |
| 17 | expense_description | Expense Description | Small Text | | Yes | |
| 18 | expense_account | Expense Account | Link | Account | Yes | |
| 19 | attachment | Attachment | Attach | | Yes | Receipt / proof of payment |
| 20 | — | — | Section Break | | | Status |
| 21 | status | Status | Select | Draft\nSubmitted\nApproved\nPaid\nRejected\nCancelled | Yes | Default: Draft |
| 22 | approved_by | Approved By | Link | User | No | |
| 23 | approved_on | Approved On | Date | | No | |
| 24 | payment_date | Payment Date | Date | | No | |
| 25 | remarks | Remarks | Small Text | | No | |

**Business Rules:**
1. `attachment` (receipt/invoice) is mandatory.
2. `amount_approved` cannot exceed `amount_claimed`.
3. Budget availability must be checked against `budget_line` before approval.
4. On status → Paid, system posts expense journal: Dr `expense_account` / Cr Bank/Cash account.

---

## DocType: Fixed Asset

**Module:** Fundara > Financial Accountability
**Parent (if child table):** —
**Is Submittable:** Yes
**Has Workflow:** Yes
**Naming Series:** FA-.YYYY.-.####

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | naming_series | Series | Select | FA-.YYYY.-.#### | Yes | |
| 2 | asset_name | Asset Name | Data | | Yes | |
| 3 | asset_code | Asset Code | Data | | No | Internal asset tag |
| 4 | asset_category | Asset Category | Link | Asset Category | Yes | ERPNext Asset Category |
| 5 | — | — | Section Break | | | Acquisition |
| 6 | acquisition_date | Acquisition Date | Date | | Yes | |
| 7 | posting_date | Posting Date | Date | | Yes | |
| 8 | currency | Currency | Link | Currency | Yes | |
| 9 | exchange_rate | Exchange Rate | Float | | Yes | Default 1.0 |
| 10 | acquisition_cost | Acquisition Cost | Currency | | Yes | |
| 11 | acquisition_cost_base | Acquisition Cost (Base Currency) | Currency | | No | System-computed |
| 12 | purchase_invoice | Purchase Invoice | Link | Purchase Invoice | No | Source purchase document |
| 13 | — | — | Section Break | | | Funding Source |
| 14 | fund | Fund | Link | Fund | Yes | Donor principle: asset must know which fund purchased it |
| 15 | donor | Donor | Link | Donor | No | |
| 16 | project | Project | Link | Project | No | |
| 17 | budget_line | Budget Line | Link | Fund Budget Line | No | |
| 18 | cost_center | Cost Center | Link | Cost Center | No | |
| 19 | — | — | Section Break | | | Location & Custodian |
| 20 | location | Location | Link | Location | Yes | |
| 21 | custodian | Custodian | Link | User | Yes | Person responsible for the asset |
| 22 | — | — | Section Break | | | Depreciation |
| 23 | useful_life_months | Useful Life (Months) | Int | | Yes | |
| 24 | depreciation_method | Depreciation Method | Select | Straight Line\nDouble Declining Balance\nUnits of Production | Yes | |
| 25 | residual_value | Residual Value | Currency | | No | Default 0 |
| 26 | depreciation_start_date | Depreciation Start Date | Date | | Yes | |
| 27 | donor_reporting_treatment | Donor Reporting Treatment | Select | Capitalize and Depreciate\nExpense at Acquisition | No | Some donors expense assets directly |
| 28 | — | — | Section Break | | | Book Value |
| 29 | accumulated_depreciation | Accumulated Depreciation | Currency | | No | System-maintained |
| 30 | current_book_value | Current Book Value | Currency | | No | System-computed: acquisition_cost − accumulated_depreciation |
| 31 | — | — | Section Break | | | Status |
| 32 | asset_status | Asset Status | Select | Active\nUnder Repair\nDisposed\nTransferred | Yes | Default: Active |
| 33 | disposal_date | Disposal Date | Date | | No | |
| 34 | disposal_reason | Disposal Reason | Small Text | | No | |
| 35 | — | — | Section Break | | | Evidence |
| 36 | acquisition_evidence | Acquisition Evidence | Attach | | No | Receipt, invoice, or procurement record |
| 37 | asset_image | Asset Image | Attach Image | | No | |
| 38 | notes | Notes | Long Text | | No | |

**Business Rules:**
1. `fund`, `location`, and `custodian` are mandatory — all assets must have a known funding source, location, and responsible person.
2. `depreciation_start_date` must be >= `acquisition_date`.
3. On Submit, system generates a Depreciation Schedule based on `useful_life_months`, `depreciation_method`, and `residual_value`.
4. `current_book_value` is system-maintained: `acquisition_cost − accumulated_depreciation`.
5. If `donor_reporting_treatment = Expense at Acquisition`, the asset is expensed in the donor report at acquisition but still capitalized in the general ledger.
6. Disposed assets must have `disposal_date` set.

---

## DocType: Depreciation Schedule Line

**Module:** Fundara > Financial Accountability
**Parent (if child table):** Depreciation Schedule
**Is Submittable:** No
**Has Workflow:** No
**Naming Series:** —

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | depreciation_month | Depreciation Month | Date | | Yes | First day of the month |
| 2 | depreciation_amount | Depreciation Amount | Currency | | Yes | |
| 3 | accumulated_depreciation | Accumulated Depreciation | Currency | | Yes | Running total after this period |
| 4 | book_value | Book Value | Currency | | Yes | After depreciation |
| 5 | posting_status | Posting Status | Select | Pending\nPosted\nSkipped | Yes | Default: Pending |
| 6 | journal_entry | Journal Entry | Link | Journal Entry | No | Auto-created when posted |
| 7 | posted_on | Posted On | Date | | No | |

---

## DocType: Depreciation Schedule

**Module:** Fundara > Financial Accountability
**Parent (if child table):** —
**Is Submittable:** No
**Has Workflow:** No
**Naming Series:** DS-.YYYY.-.####

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | naming_series | Series | Select | DS-.YYYY.-.#### | Yes | |
| 2 | fixed_asset | Fixed Asset | Link | Fixed Asset | Yes | |
| 3 | fund | Fund | Link | Fund | No | Read-only; from Fixed Asset |
| 4 | project | Project | Link | Project | No | Read-only; from Fixed Asset |
| 5 | cost_center | Cost Center | Link | Cost Center | No | |
| 6 | posting_date | Posting Date | Date | | No | |
| 7 | currency | Currency | Link | Currency | Yes | |
| 8 | exchange_rate | Exchange Rate | Float | | No | Default 1.0 |
| 9 | depreciation_account | Depreciation Expense Account | Link | Account | Yes | Dr account |
| 10 | accumulated_depreciation_account | Accumulated Depreciation Account | Link | Account | Yes | Cr account |
| 11 | schedule_lines | Schedule Lines | Table | Depreciation Schedule Line | Yes | |
| 12 | total_depreciation | Total Depreciation | Currency | | No | System-computed: sum of depreciation_amount |
| 13 | notes | Notes | Small Text | | No | |

**Business Rules:**
1. Auto-generated when a Fixed Asset is submitted.
2. Monthly depreciation run posts each `Pending` schedule line for the current accounting period.
3. Depreciation journal: Dr `depreciation_account` / Cr `accumulated_depreciation_account`.
4. Skipped lines require a reason and Finance approval.

---

## DocType: Bank Statement Line

**Module:** Fundara > Financial Accountability
**Parent (if child table):** Bank Statement Import
**Is Submittable:** No
**Has Workflow:** No
**Naming Series:** —

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | transaction_date | Transaction Date | Date | | Yes | Date on bank statement |
| 2 | value_date | Value Date | Date | | No | |
| 3 | description | Description | Data | | No | Narration from bank |
| 4 | reference_number | Reference Number | Data | | No | Bank reference / cheque no. |
| 5 | debit | Debit | Currency | | No | Amount withdrawn from account |
| 6 | credit | Credit | Currency | | No | Amount deposited to account |
| 7 | balance | Running Balance | Currency | | No | From bank statement |
| 8 | matching_status | Matching Status | Select | Unmatched\nMatched\nPartially Matched\nReconciled\nException\nDuplicate | Yes | Default: Unmatched |
| 9 | matched_document_type | Matched Document Type | Data | | No | e.g. "Cash Disbursement" |
| 10 | matched_document_name | Matched Document | Data | | No | Name of matched Fundara transaction |
| 11 | match_type | Match Type | Select | Exact Match\nProbable Match\nPartial Match\nManual Match\nSplit Match | No | |

---

## DocType: Bank Statement Import

**Module:** Fundara > Financial Accountability
**Parent (if child table):** —
**Is Submittable:** No
**Has Workflow:** No
**Naming Series:** BSI-.YYYY.-.####

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | naming_series | Series | Select | BSI-.YYYY.-.#### | Yes | |
| 2 | bank_account | Bank Account | Link | Bank Account | Yes | ERPNext Bank Account |
| 3 | fund | Fund | Link | Fund | No | Fund associated with this bank account |
| 4 | cost_center | Cost Center | Link | Cost Center | No | |
| 5 | — | — | Section Break | | | Period |
| 6 | statement_from_date | Statement From Date | Date | | Yes | |
| 7 | statement_to_date | Statement To Date | Date | | Yes | |
| 8 | posting_date | Posting Date | Date | | No | |
| 9 | — | — | Section Break | | | Import |
| 10 | currency | Currency | Link | Currency | Yes | |
| 11 | exchange_rate | Exchange Rate | Float | | No | Default 1.0 |
| 12 | uploaded_file | Uploaded File | Attach | | Yes | CSV or XLSX bank statement |
| 13 | import_status | Import Status | Select | Pending\nParsed\nValidated\nImported\nFailed | No | System-managed |
| 14 | total_lines | Total Lines | Int | | No | System-computed after parsing |
| 15 | error_count | Error Count | Int | | No | Lines with parsing errors |
| 16 | — | — | Section Break | | | Statement Lines |
| 17 | statement_lines | Statement Lines | Table | Bank Statement Line | No | Populated after import |
| 18 | — | — | Section Break | | | Log |
| 19 | import_log | Import Log | Long Text | | No | System-written import summary |

**Business Rules:**
1. `statement_to_date` must be >= `statement_from_date`.
2. Duplicate detection: lines with the same `transaction_date`, `reference_number`, and `debit`/`credit` amount are flagged as Duplicate.
3. Once Imported, statement lines cannot be deleted — exceptions must be flagged.

---

## DocType: Bank Reconciliation

**Module:** Fundara > Financial Accountability
**Parent (if child table):** —
**Is Submittable:** Yes
**Has Workflow:** Yes
**Naming Series:** BRE-.YYYY.-.####

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | naming_series | Series | Select | BRE-.YYYY.-.#### | Yes | |
| 2 | bank_account | Bank Account | Link | Bank Account | Yes | |
| 3 | fund | Fund | Link | Fund | No | |
| 4 | cost_center | Cost Center | Link | Cost Center | No | |
| 5 | — | — | Section Break | | | Period |
| 6 | reconciliation_period | Reconciliation Period | Data | | No | e.g. "May 2025" |
| 7 | from_date | From Date | Date | | Yes | |
| 8 | to_date | To Date | Date | | Yes | |
| 9 | posting_date | Posting Date | Date | | Yes | |
| 10 | — | — | Section Break | | | Currency |
| 11 | currency | Currency | Link | Currency | Yes | |
| 12 | exchange_rate | Exchange Rate | Float | | No | Default 1.0 |
| 13 | — | — | Section Break | | | Balances |
| 14 | opening_balance_per_bank | Opening Balance per Bank | Currency | | No | From bank statement |
| 15 | closing_balance_per_bank | Closing Balance per Bank | Currency | | No | From bank statement |
| 16 | balance_per_books | Balance per Books | Currency | | No | GL balance for the account |
| 17 | outstanding_deposits | Outstanding Deposits | Currency | | No | In books, not yet on bank statement |
| 18 | outstanding_payments | Outstanding Payments | Currency | | No | In books, not yet on bank statement |
| 19 | adjusted_bank_balance | Adjusted Bank Balance | Currency | | No | System-computed |
| 20 | difference | Difference | Currency | | No | adjusted_bank_balance − balance_per_books |
| 21 | — | — | Section Break | | | Status |
| 22 | status | Status | Select | Draft\nIn Progress\nReconciled\nException | Yes | Default: Draft |
| 23 | has_material_exception | Has Material Exception | Check | | No | Prevents closing if True without approval |
| 24 | exception_approval | Exception Approval | Link | User | No | Required if has_material_exception = 1 |
| 25 | — | — | Section Break | | | Source |
| 26 | bank_statement_import | Bank Statement Import | Link | Bank Statement Import | No | Linked import batch |
| 27 | — | — | Section Break | | | Notes |
| 28 | remarks | Remarks | Long Text | | No | |

**Business Rules:**
1. A reconciliation period cannot be closed if `has_material_exception = 1` without `exception_approval` being set.
2. `difference` must be 0.00 for status to be set to Reconciled.
3. Transactions already in a Reconciled period cannot be modified without a reversal entry.
4. `adjusted_bank_balance` = `closing_balance_per_bank` + `outstanding_deposits` − `outstanding_payments`.

---

## DocType: Opening Balance Line

**Module:** Fundara > Financial Accountability
**Parent (if child table):** Opening Balance Assistant
**Is Submittable:** No
**Has Workflow:** No
**Naming Series:** —

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | account | Account | Link | Account | Yes | |
| 2 | fund | Fund | Link | Fund | No | Dimension; required for restricted accounts |
| 3 | donor | Donor | Link | Donor | No | For donor-specific balance tracking |
| 4 | restriction_class | Net Asset Class | Link | Net Asset Class | No | |
| 5 | project | Project | Link | Project | No | If balance is project-specific |
| 6 | opening_debit | Opening Debit | Currency | | No | |
| 7 | opening_credit | Opening Credit | Currency | | No | |
| 8 | currency | Currency | Link | Currency | No | |
| 9 | exchange_rate | Exchange Rate | Float | | No | Default 1.0 |
| 10 | remarks | Remarks | Small Text | | No | |

**Business Rules:**
1. Each line must have either `opening_debit > 0` or `opening_credit > 0`, but not both.

---

## DocType: Opening Balance Assistant

**Module:** Fundara > Financial Accountability
**Parent (if child table):** —
**Is Submittable:** Yes
**Has Workflow:** No
**Naming Series:** OBA-.YYYY.-####

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | naming_series | Series | Select | OBA-.YYYY.-#### | Yes | |
| 2 | fiscal_year | Fiscal Year | Link | Fiscal Year | Yes | |
| 3 | as_of_date | As of Date | Date | | Yes | Opening balance date |
| 4 | posting_date | Posting Date | Date | | Yes | |
| 5 | — | — | Section Break | | | Currency |
| 6 | currency | Currency | Link | Currency | Yes | Base currency |
| 7 | exchange_rate | Exchange Rate | Float | | No | Default 1.0 |
| 8 | — | — | Section Break | | | Balances |
| 9 | balance_lines | Balance Lines | Table | Opening Balance Line | Yes | |
| 10 | total_debit | Total Debit | Currency | | No | System-computed; read-only |
| 11 | total_credit | Total Credit | Currency | | No | System-computed; read-only |
| 12 | — | — | Section Break | | | Validation |
| 13 | validation_status | Validation Status | Select | Pending\nBalanced\nOut of Balance\nPosted | No | System-managed |
| 14 | difference | Difference | Currency | | No | total_debit − total_credit; must be 0 to post |
| 15 | — | — | Section Break | | | Journal |
| 16 | opening_journal_entry | Opening Journal Entry | Link | Journal Entry | No | Auto-created on Submit |
| 17 | notes | Notes | Long Text | | No | |

**Business Rules:**
1. `total_debit` must equal `total_credit` (difference = 0) before submission.
2. `validation_status` is set to Balanced by the system when difference = 0, and Out of Balance otherwise.
3. On Submit, system creates an Opening Balance Journal Entry using `journal_type = Opening Balance`.
4. Only one Opening Balance Assistant per `fiscal_year` can be Posted.

---

## DocType: Import Batch

**Module:** Fundara > Financial Accountability
**Parent (if child table):** —
**Is Submittable:** No
**Has Workflow:** No
**Naming Series:** IMP-.YYYY.-.####

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | naming_series | Series | Select | IMP-.YYYY.-.#### | Yes | |
| 2 | import_type | Import Type | Select | Budget\nCash Receipt\nCash Disbursement\nGeneral Journal\nFixed Asset\nOpening Balance\nBank Statement\nOther | Yes | |
| 3 | — | — | Section Break | | | File |
| 4 | uploaded_file | Uploaded File | Attach | | Yes | CSV or XLSX |
| 5 | mapping_configuration | Mapping Configuration | Long Text | | No | JSON or description of column mapping |
| 6 | — | — | Section Break | | | Results |
| 7 | import_status | Import Status | Select | Pending\nValidating\nValidated\nImporting\nImported\nFailed\nPartially Imported | No | System-managed |
| 8 | total_rows | Total Rows | Int | | No | |
| 9 | valid_rows | Valid Rows | Int | | No | |
| 10 | error_count | Error Count | Int | | No | |
| 11 | created_records | Created Records | Int | | No | |
| 12 | — | — | Section Break | | | Log |
| 13 | validation_result | Validation Result | Long Text | | No | System-written |
| 14 | import_log | Import Log | Long Text | | No | System-written |
| 15 | — | — | Section Break | | | Date |
| 16 | posting_date | Posting Date | Date | | No | Applied to imported records |
| 17 | currency | Currency | Link | Currency | No | Applied to imported records if applicable |
| 18 | exchange_rate | Exchange Rate | Float | | No | Default 1.0 |

**Business Rules:**
1. Records are only created after `validation_status = Validated` and explicit user confirmation.
2. Failed import batches must be correctable and re-submittable.
3. Import log must record: timestamp, user, row count, error details, and created record names.

---

## DocType: Data Health Check

**Module:** Fundara > Financial Accountability
**Parent (if child table):** —
**Is Submittable:** No
**Has Workflow:** No
**Naming Series:** DHC-.YYYY.-.####

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | naming_series | Series | Select | DHC-.YYYY.-.#### | Yes | |
| 2 | check_date | Check Date | Date | | Yes | |
| 3 | posting_date | Posting Date | Date | | No | |
| 4 | — | — | Section Break | | | Scope |
| 5 | fund | Fund | Link | Fund | No | Scope to specific fund (blank = all) |
| 6 | project | Project | Link | Project | No | |
| 7 | fiscal_year | Fiscal Year | Link | Fiscal Year | No | |
| 8 | cost_center | Cost Center | Link | Cost Center | No | |
| 9 | — | — | Section Break | | | Check Configuration |
| 10 | check_transactions_without_fund | Check: Transactions Without Fund | Check | | No | Default 1 |
| 11 | check_transactions_without_budget_line | Check: Transactions Without Budget Line | Check | | No | Default 1 |
| 12 | check_expense_without_evidence | Check: Expense Without Evidence | Check | | No | Default 1 |
| 13 | check_overdue_advances | Check: Overdue Advances | Check | | No | Default 1 |
| 14 | check_unbalanced_journals | Check: Unbalanced Journals | Check | | No | Default 1 |
| 15 | check_negative_fund_balance | Check: Negative Fund Balance | Check | | No | Default 1 |
| 16 | check_assets_without_depreciation | Check: Assets Without Depreciation Schedule | Check | | No | Default 1 |
| 17 | check_unreconciled_bank_transactions | Check: Unreconciled Bank Transactions | Check | | No | Default 1 |
| 18 | check_donor_transactions_without_period | Check: Donor Transactions Without Reporting Period | Check | | No | Default 1 |
| 19 | — | — | Section Break | | | Results |
| 20 | run_status | Run Status | Select | Not Run\nRunning\nCompleted\nFailed | No | Default: Not Run |
| 21 | total_issues | Total Issues Found | Int | | No | System-computed |
| 22 | check_results | Check Results | Long Text | | No | System-written JSON or formatted report |
| 23 | — | — | Section Break | | | Currency |
| 24 | currency | Currency | Link | Currency | No | For monetary checks |
| 25 | exchange_rate | Exchange Rate | Float | | No | Default 1.0 |

**Business Rules:**
1. Data Health Check is read-only after running — create a new one for each run.
2. Results must link to the specific problem documents so users can navigate directly to fix issues.
3. Check must not alter any data — it is read-only diagnostic.
