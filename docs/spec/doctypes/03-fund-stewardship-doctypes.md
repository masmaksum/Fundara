# DocType Specifications — Fund Stewardship Context

**Context:** Fundara > Fund Stewardship
**ERPNext Version:** v16
**Related Decisions:** D-02 (budget formula = Approved − Actual paid only), D-04 (multi-currency in MVP)
**Domain Source:** `fundara-domain-contexts/03-fund-stewardship-context.md`

---

## DocType: Fund

**Module:** Fundara > Fund Stewardship
**Parent (if child table):** —
**Is Submittable:** Yes
**Has Workflow:** Yes (Draft → Active → Suspended → Closing → Closed)
**Naming Series:** FUND-.YYYY.-.####

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | naming_series | Series | Select | FUND-.YYYY.-.#### | Yes | |
| 2 | fund_name | Fund Name | Data | | Yes | Human-readable name |
| 3 | fund_code | Fund Code | Data | | Yes | Short unique identifier, used in reports |
| 4 | fund_type | Fund Type | Link | Fund Type | Yes | Controls behaviour and UI conditionals |
| 5 | | | Section Break | | | **Restriction & Purpose** |
| 6 | restriction_type | Restriction Type | Select | Restricted\nTemporarily Restricted\nUnrestricted\nBoard-designated | Yes | Per canonical list in domain context §4.3 |
| 7 | purpose | Purpose | Small Text | | No | Narrative description of intended use |
| 8 | | | Section Break | | | **Source & Ownership** |
| 9 | funding_source | Funding Source | Link | Funding Source | Yes | Links to Funding Context |
| 10 | grant | Grant | Link | Grant | No | Mandatory when fund_type = Grant Fund (D-01) |
| 11 | fund_owner | Fund Owner | Link | User | Yes | Responsible person |
| 12 | approval_authority | Approval Authority | Link | User | No | Person who can approve allocations/transfers |
| 13 | | | Section Break | | | **Period** |
| 14 | start_date | Start Date | Date | | Yes | |
| 15 | end_date | End Date | Date | | No | Blank = open-ended fund |
| 16 | | | Section Break | | | **Currency & Opening Balance (D-04)** |
| 17 | currency | Currency | Link | Currency | Yes | Fund's operating currency (e.g. USD, IDR) |
| 18 | exchange_rate_on_creation | Exchange Rate on Creation | Float | | No | Rate vs base currency (IDR) at fund creation |
| 19 | opening_balance | Opening Balance | Currency | | No | In fund currency |
| 20 | opening_balance_base | Opening Balance (Base IDR) | Currency | | No | Auto-computed: opening_balance × exchange_rate_on_creation |
| 21 | base_currency | Base Currency | Link | Currency | No | Read-only, pulled from ERPNext Company settings (IDR) |
| 22 | | | Section Break | | | **Status** |
| 23 | status | Status | Select | Draft\nActive\nSuspended\nClosing\nClosed | Yes | Controlled by workflow |
| 24 | | | Section Break | | | **Restriction Rules** |
| 25 | allowed_cost_categories | Allowed Cost Categories | Small Text | | No | Narrative or comma-separated cost category codes |
| 26 | disallowed_cost_categories | Disallowed Cost Categories | Small Text | | No | |
| 27 | allowed_programs | Allowed Programs | Small Text | | No | Program codes permitted to draw from this fund |
| 28 | allowed_projects | Allowed Projects | Small Text | | No | Project codes permitted; leave blank = all |
| 29 | procurement_requirement | Procurement Requirement | Small Text | | No | Special procurement rules for this fund |
| 30 | reporting_requirement | Reporting Requirement | Small Text | | No | e.g., quarterly narrative + financial |
| 31 | exception_rule | Exception Rule | Small Text | | No | Documented override conditions |
| 32 | | | Section Break | | | **Notes** |
| 33 | notes | Notes | Long Text | | No | Internal notes |
| 34 | is_bridging_fund | Is Bridging Fund | Check | | No | Flag for bridging/talangan funds |
| 35 | recoverable_from_fund | Recoverable From Fund | Link | Fund | No | Applicable when is_bridging_fund = 1 |

**Business Rules:**
1. `grant` field is mandatory when `fund_type` = "Grant Fund" (D-01 constraint — validate via server-side script).
2. `end_date` must be after `start_date` when both are set.
3. A Fund in status "Closed" must reject any new allocation, transfer, or transaction linkage.
4. `restriction_type` change after status = "Active" requires approval workflow and generates audit log entry.
5. `opening_balance_base` = `opening_balance` × `exchange_rate_on_creation`; recompute on save when either changes.
6. `recoverable_from_fund` must not reference itself.

---

## DocType: Fund Type

**Module:** Fundara > Fund Stewardship
**Parent (if child table):** —
**Is Submittable:** No
**Has Workflow:** No
**Naming Series:** —

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | fund_type_name | Fund Type Name | Data | | Yes | Unique; becomes DocType name value |
| 2 | description | Description | Small Text | | No | |
| 3 | default_restriction_type | Default Restriction Type | Select | Restricted\nTemporarily Restricted\nUnrestricted\nBoard-designated | No | Pre-fills Fund creation |
| 4 | requires_grant | Requires Grant | Check | | No | If Yes, Fund must link to a Grant DocType record |
| 5 | requires_donor | Requires Donor | Check | | No | If Yes, Funding Source must have a Donor |
| 6 | has_end_date | Has End Date | Check | | No | If Yes, end_date is mandatory on Fund |
| 7 | is_active | Is Active | Check | | No | Controls availability in dropdowns |
| 8 | notes | Notes | Small Text | | No | |

**Business Rules:**
1. The eight MVP fund types (Grant Fund, Campaign Fund, Unrestricted Fund, Business Surplus Fund, Reserve Fund, Co-funding Fund, Bridging Fund, Board-designated Fund) must be seeded as fixture data.
2. Endowment Fund is defined but flagged inactive for MVP.
3. `fund_type_name` is the key used in conditional logic throughout the system — do not rename after go-live.

---

## DocType: Fund Restriction

**Module:** Fundara > Fund Stewardship
**Parent (if child table):** —
**Is Submittable:** Yes
**Has Workflow:** Yes (changes to restriction require approval)
**Naming Series:** FRESTR-.YYYY.-.####

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | naming_series | Series | Select | FRESTR-.YYYY.-.#### | Yes | |
| 2 | fund | Fund | Link | Fund | Yes | |
| 3 | restriction_type | Restriction Type | Select | Restricted\nTemporarily Restricted\nUnrestricted\nBoard-designated | Yes | |
| 4 | effective_date | Effective Date | Date | | Yes | When this restriction record becomes effective |
| 5 | | | Section Break | | | **Allowed Usage** |
| 6 | allowed_cost_categories | Allowed Cost Categories | Long Text | | No | Comma-separated or free text |
| 7 | disallowed_cost_categories | Disallowed Cost Categories | Long Text | | No | |
| 8 | allowed_programs | Allowed Programs | Long Text | | No | |
| 9 | allowed_projects | Allowed Projects | Long Text | | No | |
| 10 | allowed_locations | Allowed Locations | Long Text | | No | Geographic or organisational location restriction |
| 11 | allowed_period_start | Allowed Period Start | Date | | No | Expenditure must fall in this window |
| 12 | allowed_period_end | Allowed Period End | Date | | No | |
| 13 | | | Section Break | | | **Requirements** |
| 14 | procurement_requirement | Procurement Requirement | Long Text | | No | |
| 15 | reporting_requirement | Reporting Requirement | Long Text | | No | |
| 16 | exception_rule | Exception Rule | Long Text | | No | |
| 17 | | | Section Break | | | **Approval & Audit** |
| 18 | approved_by | Approved By | Link | User | No | Required on Submit |
| 19 | approval_date | Approval Date | Date | | No | |
| 20 | change_reason | Change Reason | Small Text | | No | Mandatory when amending an existing restriction |
| 21 | amendment_reference | Amendment Reference | Data | | No | Reference doc or minute number |
| 22 | | | Section Break | | | **Notes** |
| 23 | notes | Notes | Long Text | | No | |

**Business Rules:**
1. Only one Fund Restriction record per Fund should be in "Submitted" status at a time; creating a new one automatically supersedes the previous.
2. `approved_by` and `approval_date` are mandatory before submission.
3. All historical Fund Restriction records are retained for audit trail — never delete, only amend by creating a new record.
4. `change_reason` is mandatory when the fund already has a prior submitted restriction.

---

## DocType: Fund Allocation

**Module:** Fundara > Fund Stewardship
**Parent (if child table):** —
**Is Submittable:** Yes
**Has Workflow:** Yes (Draft → Submitted → Approved → Active → Revised → Closed)
**Naming Series:** FALLOC-.YYYY.-.####

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | naming_series | Series | Select | FALLOC-.YYYY.-.#### | Yes | |
| 2 | fund | Fund | Link | Fund | Yes | Source fund being allocated |
| 3 | | | Section Break | | | **Allocation Target** |
| 4 | allocated_to_type | Allocated To Type | Select | Program\nProject\nActivity\nCost Center | Yes | Controls which reference field is shown |
| 5 | program | Program | Link | Program | No | Mandatory when allocated_to_type = Program |
| 6 | project | Project | Link | Project | No | Mandatory when allocated_to_type = Project |
| 7 | activity | Activity | Link | Activity | No | Mandatory when allocated_to_type = Activity |
| 8 | cost_center | Cost Center | Link | Cost Center | No | Mandatory when allocated_to_type = Cost Center |
| 9 | budget_line | Budget Line | Link | Budget Line | No | Internal budget line this allocation supports |
| 10 | | | Section Break | | | **Amount & Currency (D-04)** |
| 11 | currency | Currency | Link | Currency | Yes | Must match fund currency |
| 12 | allocated_amount | Allocated Amount | Currency | | Yes | In fund currency |
| 13 | exchange_rate | Exchange Rate | Float | | Yes | At time of allocation; default from Fund |
| 14 | allocated_amount_base | Allocated Amount (Base IDR) | Currency | | No | Auto: allocated_amount × exchange_rate |
| 15 | | | Section Break | | | **Period** |
| 16 | allocation_period_start | Allocation Period Start | Date | | Yes | |
| 17 | allocation_period_end | Allocation Period End | Date | | No | |
| 18 | | | Section Break | | | **Status & Approval** |
| 19 | status | Status | Select | Draft\nSubmitted\nApproved\nActive\nRevised\nClosed | Yes | |
| 20 | approved_by | Approved By | Link | User | No | |
| 21 | approval_date | Approval Date | Date | | No | |
| 22 | revision_note | Revision Note | Small Text | | No | Required when status moves to Revised |
| 23 | | | Section Break | | | **Utilisation Summary (D-02)** |
| 24 | total_paid | Total Paid | Currency | | No | Read-only; computed from linked payment transactions |
| 25 | total_pending_payment | Total Pending Payment | Currency | | No | Read-only; approved but not yet paid — informational only, does NOT reduce available balance (D-02) |
| 26 | available_balance | Available Balance | Currency | | No | allocated_amount − total_paid |
| 27 | | | Section Break | | | **Notes** |
| 28 | notes | Long Text | Long Text | | No | |

**Business Rules:**
1. `allocated_amount` must not exceed the Fund's `available_balance` at time of approval, unless an authorised override is recorded.
2. `currency` must match the linked Fund's `currency`.
3. `available_balance` = `allocated_amount` − `total_paid`. `total_pending_payment` is shown for information only and does not reduce the balance (D-02).
4. A Fund in status "Closed" or "Suspended" cannot receive a new Allocation in "Approved" or "Active" status.
5. Revising an Active allocation requires `revision_note` and re-approval workflow.
6. When `allocated_to_type` changes, previously set reference fields (program, project, activity, cost_center) must be cleared.

---

## DocType: Fund Allocation Item

**Module:** Fundara > Fund Stewardship
**Parent (if child table):** Fund Allocation
**Is Submittable:** No
**Has Workflow:** No
**Naming Series:** —

> This child table is used when a single Fund Allocation needs to distribute across multiple budget lines or sub-periods.

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | budget_line | Budget Line | Link | Budget Line | No | Internal budget line |
| 2 | grant_budget_line | Grant Budget Line | Link | Grant Budget Line | No | Donor budget line, if applicable |
| 3 | description | Description | Data | | No | |
| 4 | period_start | Period Start | Date | | No | |
| 5 | period_end | Period End | Date | | No | |
| 6 | currency | Currency | Link | Currency | Yes | Inherited from parent |
| 7 | amount | Amount | Currency | | Yes | |
| 8 | amount_base | Amount (Base IDR) | Currency | | No | amount × parent exchange_rate |
| 9 | notes | Notes | Small Text | | No | |

**Business Rules:**
1. Sum of `amount` across all child rows must equal parent `allocated_amount`.
2. `currency` must match parent Fund Allocation's `currency`.

---

## DocType: Fund Transfer

**Module:** Fundara > Fund Stewardship
**Parent (if child table):** —
**Is Submittable:** Yes
**Has Workflow:** Yes (Draft → Submitted → Approved → Posted → Cancelled)
**Naming Series:** FTRANS-.YYYY.-.####

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | naming_series | Series | Select | FTRANS-.YYYY.-.#### | Yes | |
| 2 | transfer_date | Transfer Date | Date | | Yes | |
| 3 | | | Section Break | | | **Source & Target** |
| 4 | source_fund | Source Fund | Link | Fund | Yes | Fund money is moving from |
| 5 | target_fund | Target Fund | Link | Fund | Yes | Fund money is moving to |
| 6 | | | Section Break | | | **Amount & Currency (D-04)** |
| 7 | currency | Currency | Link | Currency | Yes | Must match source_fund currency |
| 8 | amount | Amount | Currency | | Yes | In source fund currency |
| 9 | exchange_rate | Exchange Rate | Float | | Yes | Rate at transfer date |
| 10 | amount_base | Amount (Base IDR) | Currency | | No | amount × exchange_rate |
| 11 | target_currency | Target Fund Currency | Link | Currency | No | Read-only; pulled from target_fund.currency |
| 12 | target_exchange_rate | Target Exchange Rate | Float | | No | Rate for target fund currency, if different from source |
| 13 | amount_in_target_currency | Amount in Target Currency | Currency | | No | Computed when currencies differ |
| 14 | | | Section Break | | | **Reason & Approval** |
| 15 | reason | Reason | Small Text | | Yes | |
| 16 | restriction_check_passed | Restriction Check Passed | Check | | No | Confirms reviewer validated restriction rules |
| 17 | approval_reference | Approval Reference | Data | | No | Minute number, board decision ref, etc. |
| 18 | approved_by | Approved By | Link | User | No | Required before status = Approved |
| 19 | approval_date | Approval Date | Date | | No | |
| 20 | | | Section Break | | | **Journal Entry Link** |
| 21 | journal_entry | Journal Entry | Link | Journal Entry | No | Auto-created on Post; read-only |
| 22 | | | Section Break | | | **Notes** |
| 23 | notes | Notes | Long Text | | No | |

**Business Rules:**
1. `source_fund` and `target_fund` must not be the same document.
2. `amount` must not exceed `source_fund.available_balance` at time of approval.
3. Transfer from a Restricted fund requires `restriction_check_passed` = 1 and a documented `approval_reference`.
4. Both funds must be in "Active" status to allow a transfer.
5. On Submit (Post), a Journal Entry is auto-created to move the amount between the funds' corresponding accounts and update Fund Balance snapshots.
6. A Posted transfer cannot be edited — create a reversal transfer if correction is needed.

---

## DocType: Bridging Fund Settlement

**Module:** Fundara > Fund Stewardship
**Parent (if child table):** —
**Is Submittable:** Yes
**Has Workflow:** Yes (Draft → Submitted → Approved → Settled → Closed)
**Naming Series:** BSETTLE-.YYYY.-.####

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | naming_series | Series | Select | BSETTLE-.YYYY.-.#### | Yes | |
| 2 | | | Section Break | | | **Funds** |
| 3 | original_fund | Original (Bridging) Fund | Link | Fund | Yes | Fund that initially paid the expense |
| 4 | recoverable_fund | Recoverable Fund | Link | Fund | Yes | Fund that will reimburse the original fund |
| 5 | | | Section Break | | | **Linked Transaction** |
| 6 | transaction_doctype | Transaction DocType | Data | | No | e.g. "Payment Entry", "Journal Entry" |
| 7 | transaction_reference | Transaction Reference | Data | | No | Name of the originating transaction |
| 8 | expense_description | Expense Description | Small Text | | No | What was paid for |
| 9 | expense_date | Expense Date | Date | | No | Date the original expense was incurred |
| 10 | | | Section Break | | | **Amounts & Currency (D-04)** |
| 11 | currency | Currency | Link | Currency | Yes | Currency of the eligible amount |
| 12 | eligible_amount | Eligible Amount | Currency | | Yes | Amount confirmed eligible for recovery |
| 13 | exchange_rate | Exchange Rate | Float | | Yes | At settlement date |
| 14 | eligible_amount_base | Eligible Amount (Base IDR) | Currency | | No | eligible_amount × exchange_rate |
| 15 | settlement_amount | Settlement Amount | Currency | | No | Actual amount transferred to bridging fund (may differ from eligible) |
| 16 | settlement_date | Settlement Date | Date | | No | Date reimbursement is made |
| 17 | | | Section Break | | | **Eligibility Review** |
| 18 | eligibility_confirmed | Eligibility Confirmed | Check | | No | Reviewer confirms cost is eligible under recoverable_fund rules |
| 19 | eligibility_note | Eligibility Note | Small Text | | No | Justification |
| 20 | | | Section Break | | | **Approval** |
| 21 | approved_by | Approved By | Link | User | No | |
| 22 | approval_date | Approval Date | Date | | No | |
| 23 | journal_entry | Journal Entry | Link | Journal Entry | No | Settlement journal entry; auto-created on Settle |
| 24 | | | Section Break | | | **Status** |
| 25 | status | Status | Select | Draft\nSubmitted\nApproved\nSettled\nClosed | Yes | |
| 26 | | | Section Break | | | **Notes** |
| 27 | notes | Notes | Long Text | | No | |

**Business Rules:**
1. `original_fund.is_bridging_fund` must be 1 (i.e., the originating fund must be flagged as a bridging fund).
2. `eligible_amount` must not exceed the original transaction amount.
3. `settlement_amount` must not exceed `recoverable_fund.available_balance` at settlement time.
4. `eligibility_confirmed` must be checked before approval.
5. A Settlement Journal Entry is created on transition to "Settled", debiting the recoverable fund and crediting the bridging fund's corresponding accounts.
6. Once "Closed", no further edits are permitted.

---

## DocType: Fund Balance Snapshot

**Module:** Fundara > Fund Stewardship
**Parent (if child table):** —
**Is Submittable:** No
**Has Workflow:** No
**Naming Series:** FBAL-.YYYY.-.####

> This DocType captures a point-in-time balance for a fund. It is generated automatically (e.g., end of month) or manually triggered. It does NOT replace real-time balance computations but provides auditable snapshots.

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | naming_series | Series | Select | FBAL-.YYYY.-.#### | Yes | |
| 2 | fund | Fund | Link | Fund | Yes | |
| 3 | snapshot_date | Snapshot Date | Date | | Yes | Effective date of this snapshot |
| 4 | | | Section Break | | | **Currency (D-04)** |
| 5 | currency | Currency | Link | Currency | Yes | Fund's currency |
| 6 | exchange_rate | Exchange Rate | Float | | Yes | Rate on snapshot date |
| 7 | | | Section Break | | | **Income & Inflows** |
| 8 | opening_balance | Opening Balance | Currency | | No | Balance at start of period |
| 9 | total_income | Total Income | Currency | | No | Cumulative income received into fund |
| 10 | transfer_in | Transfer In | Currency | | No | Cumulative Fund Transfers received |
| 11 | | | Section Break | | | **Outflows** |
| 12 | transfer_out | Transfer Out | Currency | | No | Cumulative Fund Transfers sent out |
| 13 | total_paid | Total Paid | Currency | | Yes | Cumulative actual paid transactions (D-02: this is the only deduction to available balance) |
| 14 | | | Section Break | | | **Pending Payments (Informational — D-02)** |
| 15 | total_pending_payment | Total Pending Payment | Currency | | No | Approved but not yet paid; shown for awareness only — does NOT reduce available_balance |
| 16 | | | Section Break | | | **Balances** |
| 17 | allocated_amount | Total Allocated Amount | Currency | | No | Sum of Active Fund Allocations |
| 18 | available_balance | Available Balance | Currency | | Yes | opening_balance + total_income + transfer_in − transfer_out − total_paid |
| 19 | forecast_balance | Forecast Balance | Currency | | No | available_balance − total_pending_payment (for planning purposes only) |
| 20 | | | Section Break | | | **Base Currency Equivalents (D-04)** |
| 21 | available_balance_base | Available Balance (Base IDR) | Currency | | No | available_balance × exchange_rate |
| 22 | total_paid_base | Total Paid (Base IDR) | Currency | | No | total_paid × exchange_rate |
| 23 | | | Section Break | | | **Notes** |
| 24 | notes | Notes | Long Text | | No | |

**Business Rules:**
1. `available_balance` = `opening_balance` + `total_income` + `transfer_in` − `transfer_out` − `total_paid`. Per D-02, committed/pending amounts do NOT reduce this figure.
2. `total_pending_payment` is displayed as a warning indicator on the Fund dashboard — it does not affect `available_balance`.
3. `forecast_balance` = `available_balance` − `total_pending_payment` and is labelled clearly as an estimate.
4. One snapshot per fund per period. Duplicate snapshots for the same fund and date should be rejected.
5. Snapshots are read-only after creation; corrections require a new snapshot with an explanatory note.

---

## DocType: Fund Closure Checklist

**Module:** Fundara > Fund Stewardship
**Parent (if child table):** —
**Is Submittable:** Yes
**Has Workflow:** Yes (all items must be checked before Fund can transition to Closed)
**Naming Series:** FCLOSE-.YYYY.-.####

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | naming_series | Series | Select | FCLOSE-.YYYY.-.#### | Yes | |
| 2 | fund | Fund | Link | Fund | Yes | Fund being closed |
| 3 | closure_date | Target Closure Date | Date | | Yes | |
| 4 | initiated_by | Initiated By | Link | User | Yes | |
| 5 | | | Section Break | | | **Checklist Items** |
| 6 | outstanding_commitments_cleared | Outstanding Commitments Cleared | Check | | No | All approved but unpaid transactions resolved |
| 7 | unliquidated_advances_cleared | Unliquidated Advances Cleared | Check | | No | No open cash advances |
| 8 | missing_evidence_resolved | Missing Evidence Resolved | Check | | No | All receipts/supporting docs uploaded |
| 9 | remaining_balance_resolved | Remaining Balance Resolved | Check | | No | Surplus returned, transferred, or documented |
| 10 | final_fund_report_generated | Final Fund Report Generated | Check | | No | |
| 11 | final_fund_report_link | Final Fund Report | Attach | | No | |
| 12 | audit_completed | Audit Completed (if required) | Check | | No | |
| 13 | donor_acknowledgement_received | Donor Acknowledgement Received | Check | | No | For Grant Funds |
| 14 | | | Section Break | | | **Exceptions & Approval** |
| 15 | exceptions_noted | Exceptions Noted | Long Text | | No | Document any unresolved items with justification |
| 16 | approved_by | Approved By | Link | User | No | Finance manager or authorised approver |
| 17 | approval_date | Approval Date | Date | | No | |
| 18 | | | Section Break | | | **Notes** |
| 19 | notes | Notes | Long Text | | No | |

**Business Rules:**
1. All mandatory checklist items (`outstanding_commitments_cleared`, `unliquidated_advances_cleared`, `missing_evidence_resolved`, `remaining_balance_resolved`, `final_fund_report_generated`) must be checked before submission is allowed.
2. On Submit, the linked Fund's `status` transitions to "Closed" automatically.
3. A Closed Fund cannot be re-opened without a new fund closure checklist being cancelled and an explicit management override.
4. `exceptions_noted` is mandatory if any optional checklist item (e.g., `audit_completed`) is left unchecked.
5. One closure checklist per Fund — duplicate submissions must be rejected.

---

## DocType: Fund Closure Checklist Item

**Module:** Fundara > Fund Stewardship
**Parent (if child table):** Fund Closure Checklist
**Is Submittable:** No
**Has Workflow:** No
**Naming Series:** —

> Optional extension table for custom/ad-hoc closure checklist items beyond the standard fields.

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | item_description | Item Description | Data | | Yes | What must be completed |
| 2 | responsible_person | Responsible Person | Link | User | No | |
| 3 | due_date | Due Date | Date | | No | |
| 4 | completed | Completed | Check | | No | |
| 5 | completion_date | Completion Date | Date | | No | |
| 6 | evidence | Evidence | Attach | | No | Supporting document |
| 7 | notes | Notes | Small Text | | No | |

**Business Rules:**
1. All rows where `completed` = 0 block submission of the parent Fund Closure Checklist unless overridden with a documented exception in parent `exceptions_noted`.
