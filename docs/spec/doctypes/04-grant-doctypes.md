# DocType Specifications — Grant Context

**Context:** Fundara > Grant
**ERPNext Version:** v16
**Related Decisions:** D-01 (Grant is a standalone bounded context — Opsi A), D-04 (multi-currency in MVP)
**Domain Source:** `fundara-domain-contexts/04-grant-context.md`

---

## Architecture Note (D-01)

Per DECISIONS.md D-01, Grant is a **bounded context mandiri (Opsi A)**. Grant has its own DocTypes: Grant, Grant Agreement, Grant Budget Line, and Grant Reporting Schedule. These are separate from Fund Stewardship DocTypes.

The linkage between contexts is:
- `Fund.grant` → Link to **Grant** (set when `fund_type` = "Grant Fund")
- Financial transactions are linked to both a Fund and a Grant Budget Line (via the Grant)

Grant DocTypes do NOT absorb Fund balance logic. Fund Stewardship DocTypes own balance and allocation logic.

---

## DocType: Grant

**Module:** Fundara > Grant
**Parent (if child table):** —
**Is Submittable:** Yes
**Has Workflow:** Yes (Pipeline → Submitted → Awarded → Agreement Review → Active → Extended → Suspended → Closing → Closed; terminal: Rejected, Cancelled)
**Naming Series:** GRANT-.YYYY.-.####

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | naming_series | Series | Select | GRANT-.YYYY.-.#### | Yes | |
| 2 | grant_name | Grant Name | Data | | Yes | |
| 3 | grant_code | Grant Code | Data | | No | Short identifier; may be assigned by donor |
| 4 | | | Section Break | | | **Donor & Classification** |
| 5 | donor | Donor | Link | Donor | Yes | Institutional donor providing the grant |
| 6 | grant_type | Grant Type | Select | Bilateral\nMultilateral\nFoundation\nGovernment\nCorporate | Yes | |
| 7 | program_area | Program Area | Link | Program | No | Primary program this grant supports |
| 8 | implementing_unit | Implementing Unit | Link | Department | No | Lead department or unit |
| 9 | grant_manager | Grant Manager | Link | User | Yes | Internal person responsible for grant management |
| 10 | | | Section Break | | | **Amount & Currency (D-04)** |
| 11 | currency | Currency | Link | Currency | Yes | Grant's denominated currency (e.g. USD) |
| 12 | total_amount | Total Amount | Currency | | Yes | Total grant value in grant currency |
| 13 | exchange_rate_on_creation | Exchange Rate on Creation | Float | | No | Rate vs IDR at grant record creation |
| 14 | total_amount_base | Total Amount (Base IDR) | Currency | | No | total_amount × exchange_rate_on_creation |
| 15 | base_currency | Base Currency | Link | Currency | No | Read-only; from ERPNext Company settings |
| 16 | | | Section Break | | | **Period** |
| 17 | start_date | Start Date | Date | | Yes | Grant implementation start |
| 18 | end_date | End Date | Date | | Yes | Grant implementation end |
| 19 | grant_period_months | Grant Period (Months) | Int | | No | Auto-calculated from start/end dates |
| 20 | | | Section Break | | | **Lifecycle Status** |
| 21 | status | Status | Select | Pipeline\nSubmitted\nAwarded\nAgreement Review\nActive\nExtended\nSuspended\nClosing\nClosed\nRejected\nCancelled | Yes | Controlled by workflow |
| 22 | | | Section Break | | | **Fund Link** |
| 23 | fund | Fund | Link | Fund | No | Linked Grant Fund in Fund Stewardship (set when status = Active or later) |
| 24 | | | Section Break | | | **Notes** |
| 25 | notes | Notes | Long Text | | No | |

**Business Rules:**
1. A Grant record can exist before a Fund exists (Pipeline and Submitted stages precede Fund creation — this is the primary reason for D-01 Opsi A).
2. `end_date` must be after `start_date`.
3. `grant_period_months` is auto-calculated: round-up of months between `start_date` and `end_date`.
4. `fund` linkage is set when the Grant Fund is created in Fund Stewardship; enforced by server script — the Fund record sets `Fund.grant = this grant`.
5. A Grant in status "Active" must have at least one approved Grant Agreement.
6. Status "Rejected" and "Cancelled" are terminal — no further workflow transitions allowed from these states.
7. Status "Extended" updates `end_date` to the new extended date; prior `end_date` is recorded in Grant Agreement amendment history.
8. `total_amount_base` = `total_amount` × `exchange_rate_on_creation`; recompute on save when either changes.

---

## DocType: Grant Agreement

**Module:** Fundara > Grant
**Parent (if child table):** —
**Is Submittable:** Yes
**Has Workflow:** Yes (Draft → Under Review → Approved → Superseded)
**Naming Series:** GRAGR-.YYYY.-.####

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | naming_series | Series | Select | GRAGR-.YYYY.-.#### | Yes | |
| 2 | grant | Grant | Link | Grant | Yes | Parent grant this agreement belongs to |
| 3 | agreement_number | Agreement Number | Data | | Yes | Donor-assigned agreement/contract number |
| 4 | | | Section Break | | | **Dates** |
| 5 | signing_date | Signing Date | Date | | No | Date both parties signed |
| 6 | effective_date | Effective Date | Date | | Yes | Agreement comes into force |
| 7 | end_date | End Date | Date | | Yes | Agreement expiry |
| 8 | | | Section Break | | | **Contracted Amount (D-04)** |
| 9 | currency | Currency | Link | Currency | Yes | Must match Grant.currency |
| 10 | total_amount_contracted | Total Amount Contracted | Currency | | Yes | In grant currency |
| 11 | exchange_rate | Exchange Rate | Float | | Yes | At signing date |
| 12 | total_amount_contracted_base | Total Amount Contracted (Base IDR) | Currency | | No | total_amount_contracted × exchange_rate |
| 13 | | | Section Break | | | **Eligible / Ineligible Costs** |
| 14 | eligible_cost_categories | Eligible Cost Categories | Long Text | | No | Free text or structured list of allowed cost categories |
| 15 | ineligible_cost_categories | Ineligible Cost Categories | Long Text | | No | |
| 16 | indirect_cost_rate | Indirect Cost Rate | Percent | | No | Overhead/indirect rate agreed with donor |
| 17 | | | Section Break | | | **Rules & Requirements** |
| 18 | procurement_rules | Procurement Rules | Long Text | | No | Donor's procurement compliance requirements |
| 19 | audit_requirement | Audit Requirement | Small Text | | No | e.g., "External audit required if total > USD 500,000" |
| 20 | branding_requirement | Branding Requirement | Small Text | | No | Donor visibility requirements |
| 21 | | | Section Break | | | **Amendment History** |
| 22 | is_amendment | Is Amendment | Check | | No | True if this agreement supersedes a prior one |
| 23 | supersedes_agreement | Supersedes Agreement | Link | Grant Agreement | No | Prior agreement this one replaces |
| 24 | amendment_reason | Amendment Reason | Small Text | | No | Required when is_amendment = 1 |
| 25 | amendment_date | Amendment Date | Date | | No | |
| 26 | | | Section Break | | | **Document** |
| 27 | agreement_document | Agreement Document | Attach | | No | Scanned signed agreement |
| 28 | | | Section Break | | | **Approval** |
| 29 | approved_by | Approved By | Link | User | No | Internal authorised approver |
| 30 | approval_date | Approval Date | Date | | No | |
| 31 | | | Section Break | | | **Notes** |
| 32 | notes | Notes | Long Text | | No | |

**Business Rules:**
1. Only one Grant Agreement per Grant should be in "Approved" status at a time; approving a new one automatically moves the previous to "Superseded".
2. `currency` must match `Grant.currency`.
3. `is_amendment = 1` requires `supersedes_agreement` and `amendment_reason`.
4. A Grant cannot transition to "Active" in its lifecycle until at least one Grant Agreement is in "Approved" status.
5. `end_date` must be after `effective_date`.
6. `total_amount_contracted_base` = `total_amount_contracted` × `exchange_rate`; recompute on save.
7. `agreement_document` attachment is strongly recommended (validation warning, not hard block) before approval.

---

## DocType: Grant Budget Line

**Module:** Fundara > Grant
**Parent (if child table):** —
**Is Submittable:** Yes
**Has Workflow:** No (approval managed via parent Grant Agreement workflow)
**Naming Series:** GRBUDL-.YYYY.-.####

> Grant Budget Line represents the **donor's budget categorisation** as defined in the Grant Agreement. This is distinct from the internal Budget Line used in Mission Delivery / Financial Accountability contexts. Both must coexist and can be cross-mapped.

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | naming_series | Series | Select | GRBUDL-.YYYY.-.#### | Yes | |
| 2 | grant | Grant | Link | Grant | Yes | Parent grant |
| 3 | grant_agreement | Grant Agreement | Link | Grant Agreement | No | Agreement this budget line comes from; optional for multi-agreement grants |
| 4 | | | Section Break | | | **Line Identity** |
| 5 | budget_line_code | Budget Line Code | Data | | Yes | Donor's own code (e.g., "B1", "Personnel-01") |
| 6 | budget_line_name | Budget Line Name | Data | | Yes | Donor's label exactly as in agreement |
| 7 | description | Description | Small Text | | No | |
| 8 | | | Section Break | | | **Amounts (D-04)** |
| 9 | currency | Currency | Link | Currency | Yes | Must match Grant.currency |
| 10 | amount_approved | Amount Approved | Currency | | Yes | Original approved amount in grant currency |
| 11 | amount_revised | Amount Revised | Currency | | No | Latest revised amount after formal amendment; blank = no revision |
| 12 | amount_current | Amount Current | Currency | | No | Read-only: amount_revised if set, else amount_approved |
| 13 | exchange_rate | Exchange Rate | Float | | Yes | Rate at grant agreement signing |
| 14 | amount_approved_base | Amount Approved (Base IDR) | Currency | | No | amount_approved × exchange_rate |
| 15 | amount_current_base | Amount Current (Base IDR) | Currency | | No | amount_current × exchange_rate |
| 16 | | | Section Break | | | **Allowed Cost Types** |
| 17 | allowed_cost_types | Allowed Cost Types | Long Text | | No | What types of expenditure are covered by this line |
| 18 | restriction_note | Restriction / Note | Small Text | | No | Per-line donor restriction or note |
| 19 | | | Section Break | | | **Internal Mapping** |
| 20 | internal_budget_lines | Internal Budget Line Mapping | Table | Grant Budget Line Mapping | No | Cross-reference to internal budget lines |
| 21 | | | Section Break | | | **Utilisation (D-02)** |
| 22 | total_paid | Total Paid | Currency | | No | Read-only; sum of paid transactions charged to this line |
| 23 | total_pending_payment | Total Pending Payment | Currency | | No | Read-only; informational — approved but not yet paid (D-02: does not reduce available) |
| 24 | available_balance | Available Balance | Currency | | No | amount_current − total_paid |
| 25 | | | Section Break | | | **Notes** |
| 26 | notes | Notes | Long Text | | No | |

**Business Rules:**
1. `budget_line_code` must be unique within a Grant (two lines on the same grant cannot share a code).
2. `currency` must match `Grant.currency`.
3. `amount_revised` requires a corresponding Grant Agreement amendment and must not be set without documentation of donor approval (enforced by requiring `grant_agreement` linkage on save when `amount_revised` is set).
4. `amount_current` = `amount_revised` if set, otherwise `amount_approved`. Computed on save, read-only.
5. `available_balance` = `amount_current` − `total_paid`. Per D-02, `total_pending_payment` does not reduce this balance.
6. Budget revision exceeding a donor-defined threshold (stored in `Grant Agreement.amendment_reason` notes) must trigger a workflow approval notification.
7. Every transaction charged to a Grant Fund must reference at least one Grant Budget Line from that grant (validated in the Financial Accountability context).

---

## DocType: Grant Budget Line Mapping

**Module:** Fundara > Grant
**Parent (if child table):** Grant Budget Line
**Is Submittable:** No
**Has Workflow:** No
**Naming Series:** —

> Cross-reference table mapping a donor Grant Budget Line to one or more internal Budget Lines. Supports many-to-many relationship (one donor line may map to multiple internal lines, and vice versa).

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | internal_budget_line | Internal Budget Line | Link | Budget Line | Yes | Internal budget classification |
| 2 | mapping_note | Mapping Note | Small Text | | No | Explanation of the mapping relationship |
| 3 | allocation_percentage | Allocation % | Percent | | No | What percentage of this internal line is covered by the donor line; leave blank if full |

**Business Rules:**
1. The same internal Budget Line should not appear twice in the same Grant Budget Line's mapping table.
2. `allocation_percentage` must be between 0 and 100 when set.

---

## DocType: Grant Reporting Schedule

**Module:** Fundara > Grant
**Parent (if child table):** —
**Is Submittable:** No
**Has Workflow:** No (status updated as reports are submitted)
**Naming Series:** GRSCHED-.YYYY.-.####

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | naming_series | Series | Select | GRSCHED-.YYYY.-.#### | Yes | |
| 2 | grant | Grant | Link | Grant | Yes | |
| 3 | grant_agreement | Grant Agreement | Link | Grant Agreement | No | Agreement that defines this reporting obligation |
| 4 | | | Section Break | | | **Report Details** |
| 5 | report_type | Report Type | Select | Financial\nNarrative\nCombined\nAudit\nOther | Yes | |
| 6 | report_period | Report Period | Select | Monthly\nQuarterly\nSemi-annual\nAnnual\nFinal\nAd-hoc | Yes | |
| 7 | reporting_period_start | Reporting Period Start | Date | | Yes | Start of the period this report covers |
| 8 | reporting_period_end | Reporting Period End | Date | | Yes | End of the period this report covers |
| 9 | due_date | Due Date | Date | | Yes | Deadline for submission to donor |
| 10 | | | Section Break | | | **Recipient** |
| 11 | recipient_name | Recipient Name | Data | | No | Donor contact person |
| 12 | recipient_email | Recipient Email | Data | | No | |
| 13 | | | Section Break | | | **Submission** |
| 14 | submitted_date | Submitted Date | Date | | No | Actual date report was submitted |
| 15 | submitted_by | Submitted By | Link | User | No | |
| 16 | submission_reference | Submission Reference | Data | | No | Email thread ID, portal reference, etc. |
| 17 | report_attachment | Report Attachment | Attach | | No | Final submitted report document |
| 18 | | | Section Break | | | **Status** |
| 19 | status | Status | Select | Upcoming\nDue Soon\nOverdue\nSubmitted\nAccepted\nRevision Requested\nCancelled | Yes | |
| 20 | donor_feedback | Donor Feedback | Small Text | | No | Donor's response or comments |
| 21 | | | Section Break | | | **Notes** |
| 22 | notes | Notes | Long Text | | No | |

**Business Rules:**
1. `reporting_period_end` must be after `reporting_period_start`.
2. `due_date` should be on or after `reporting_period_end`.
3. Status auto-transitions:
   - "Upcoming" → "Due Soon" when `due_date` − today ≤ 30 days (scheduled job)
   - "Due Soon" → "Overdue" when `due_date` < today and `status` ≠ "Submitted" or later
4. `submitted_date` and `report_attachment` are mandatory before status can be set to "Submitted".
5. Each Grant should have its reporting schedule seeded from the Grant Agreement when the agreement is approved (manual or via script).
6. A Grant cannot transition to "Closing" in its lifecycle if any reporting schedule row is "Overdue" — this must be resolved or explicitly waived with a documented exception.

---

## DocType: Grant Closeout Checklist

**Module:** Fundara > Grant
**Parent (if child table):** —
**Is Submittable:** Yes
**Has Workflow:** Yes (all items resolved before Grant can transition to Closed)
**Naming Series:** GRCLOSE-.YYYY.-.####

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | naming_series | Series | Select | GRCLOSE-.YYYY.-.#### | Yes | |
| 2 | grant | Grant | Link | Grant | Yes | |
| 3 | initiated_by | Initiated By | Link | User | Yes | |
| 4 | target_closure_date | Target Closure Date | Date | | Yes | |
| 5 | | | Section Break | | | **Closeout Items** |
| 6 | all_advances_liquidated | All Advances Liquidated | Check | | No | No outstanding cash advances charged to this grant |
| 7 | all_procurement_finalised | All Procurement Finalised | Check | | No | All POs closed or cancelled |
| 8 | assets_accounted_for | Assets Accounted For | Check | | No | All purchased assets recorded and disposition decided |
| 9 | final_report_submitted | Final Report Submitted | Check | | No | |
| 10 | final_report_attachment | Final Report | Attach | | No | |
| 11 | audit_completed | Audit Completed | Check | | No | If donor requires final audit |
| 12 | audit_report_attachment | Audit Report | Attach | | No | |
| 13 | surplus_funds_resolved | Surplus Funds Resolved | Check | | No | Remaining balance returned to donor or reallocated per agreement |
| 14 | surplus_resolution_note | Surplus Resolution Note | Small Text | | No | How surplus was handled |
| 15 | documentation_archived | Documentation Archived | Check | | No | All grant documents stored per retention policy |
| 16 | donor_acknowledgement_received | Donor Acknowledgement Received | Check | | No | Donor has confirmed grant closure acceptance |
| 17 | donor_acknowledgement_attachment | Donor Acknowledgement | Attach | | No | |
| 18 | | | Section Break | | | **Ad-hoc Items** |
| 19 | additional_items | Additional Closeout Items | Table | Grant Closeout Checklist Item | No | Custom checklist items specific to this grant |
| 20 | | | Section Break | | | **Exceptions & Approval** |
| 21 | exceptions_noted | Exceptions Noted | Long Text | | No | Required if any mandatory item remains unchecked |
| 22 | approved_by | Approved By | Link | User | No | |
| 23 | approval_date | Approval Date | Date | | No | |
| 24 | | | Section Break | | | **Notes** |
| 25 | notes | Notes | Long Text | | No | |

**Business Rules:**
1. Core mandatory checklist items (`all_advances_liquidated`, `all_procurement_finalised`, `assets_accounted_for`, `final_report_submitted`, `surplus_funds_resolved`, `documentation_archived`) must all be checked before the checklist can be submitted.
2. On Submit, the linked Grant's `status` transitions to "Closed".
3. `donor_acknowledgement_received` is mandatory for grants from institutional donors (bilateral, multilateral, government types); validated by checking `Grant.grant_type`.
4. `exceptions_noted` is mandatory if any non-mandatory checklist item is unchecked on submission.
5. One Grant Closeout Checklist per Grant; duplicate submissions are rejected.
6. Closing a Grant also triggers validation in Fund Stewardship: the corresponding Grant Fund must be in "Closing" or "Closed" status.

---

## DocType: Grant Closeout Checklist Item

**Module:** Fundara > Grant
**Parent (if child table):** Grant Closeout Checklist
**Is Submittable:** No
**Has Workflow:** No
**Naming Series:** —

> Ad-hoc child table for grant-specific closure items beyond the standard checklist fields.

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | item_description | Item Description | Data | | Yes | |
| 2 | responsible_person | Responsible Person | Link | User | No | |
| 3 | due_date | Due Date | Date | | No | |
| 4 | completed | Completed | Check | | No | |
| 5 | completion_date | Completion Date | Date | | No | |
| 6 | evidence | Evidence | Attach | | No | |
| 7 | notes | Notes | Small Text | | No | |

**Business Rules:**
1. Any row with `completed` = 0 blocks submission of the parent Grant Closeout Checklist unless the unchecked item is documented in `exceptions_noted`.

---

## Donor

> **Note:** "Donor" is referenced as a Link target from Grant. The full Donor DocType specification belongs to the Funding Context (02-funding-context). It is listed here for cross-reference only.

The Grant context requires the following minimum fields on Donor to function:

- `donor_name` (Data, mandatory)
- `donor_type` (Select: Individual / Organisation / Government / Foundation / Corporate)
- `country` (Link to Country)
- `contact_email` (Data)

If the Funding Context DocType spec does not yet exist, a minimal Donor DocType should be created in module `Fundara > Funding` with the fields above, and expanded when the Funding Context is specified.

---

## Cross-Context Integration Summary

| Integration Point | Grant Side | Fund Stewardship Side |
|---|---|---|
| Grant Fund creation | `Grant.status` reaches Awarded/Active | `Fund` created with `fund_type` = "Grant Fund" and `fund.grant` → Grant |
| Budget line linkage | `Grant Budget Line` records | Financial transactions reference `grant_budget_line` field |
| Balance computation | `Grant Budget Line.available_balance` tracks donor budget utilisation | `Fund Balance Snapshot.available_balance` tracks fund cash position |
| Closeout coordination | `Grant Closeout Checklist.grant` | `Fund Closure Checklist.fund` — both must complete for full closeout |
| Currency | Grant denominated in `Grant.currency`; all amounts also in IDR base | Fund operates in `Fund.currency` with exchange rate on creation |
