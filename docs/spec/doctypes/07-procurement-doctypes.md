# Procurement & Operations — DocType Field Specifications

**Module:** Fundara > Procurement

---

## DocType: Procurement Threshold Rule

**Module:** Fundara > Procurement
**Parent (if child table):** —
**Is Submittable:** No
**Has Workflow:** No
**Naming Series:** —

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | rule_name | Rule Name | Data | | Yes | e.g. "Single Source < 5 Jt", "Minimum 3 Quotation" |
| 2 | fund_type | Fund Type | Select | Restricted\nUnrestricted\nEndowment\nCampaign | No | Leave blank to apply to all fund types |
| 3 | applicable_fund | Applicable Fund | Link | Fund | No | Leave blank for organisation-wide rule |
| 4 | amount_from | Amount From (IDR) | Currency | | No | Lower bound of threshold range |
| 5 | currency_from | Currency (From) | Link | Currency | No | Companion currency field for amount_from |
| 6 | amount_to | Amount To (IDR) | Currency | | No | Upper bound; blank = unlimited |
| 7 | currency_to | Currency (To) | Link | Currency | No | Companion currency field for amount_to |
| 8 | procurement_method | Procurement Method | Select | Direct Purchase\nSingle Quotation\nMinimum 2 Quotations\nMinimum 3 Quotations\nTender | Yes | |
| 9 | min_quotation_count | Minimum Quotation Count | Int | | No | Derived from method; stored explicitly for validation |
| 10 | bid_analysis_required | Bid Analysis Required | Check | | No | Auto-set when quotation count > 1 |
| 11 | committee_approval_required | Committee Approval Required | Check | | No | |
| 12 | notes | Notes | Small Text | | No | |
| 13 | is_active | Is Active | Check | | Yes | Default 1 |

**Business Rules:**
1. Amount ranges must not overlap for the same fund type.
2. If bid_analysis_required is set, a Bid Analysis must exist before a Purchase Order can be submitted.
3. Deactivated rules are ignored at runtime but preserved for historical reference.

---

## DocType: Purchase Request

**Module:** Fundara > Procurement
**Parent (if child table):** —
**Is Submittable:** Yes
**Has Workflow:** Yes
**Naming Series:** PR-.YYYY.-.#####

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | naming_series | Naming Series | Select | PR-.YYYY.-.##### | Yes | |
| 2 | title | Request Title | Data | | Yes | Short description of what is needed |
| 3 | requester | Requester | Link | User | Yes | Person submitting the request |
| 4 | request_date | Request Date | Date | | Yes | Default today |
| 5 | required_by | Required By | Date | | Yes | Deadline for procurement |
| 6 | request_type | Request Type | Select | Goods\nServices\nWorks | Yes | |
| 7 | purpose | Purpose | Small Text | | Yes | Why this purchase is needed |
| 8 | fund | Fund | Link | Fund | Yes | Fund bearing the cost |
| 9 | project | Project | Link | Project | Yes | ERPNext Project linked to Fundara Project |
| 10 | activity | Activity | Link | Activity | No | Sub-activity generating this request |
| 11 | cost_center | Cost Center | Link | Cost Center | Yes | Auto-populated from fund/project |
| 12 | budget_line | Budget Line | Link | Budget Line Item | Yes | Specific budget line to consume |
| 13 | estimated_amount | Estimated Amount | Currency | | Yes | |
| 14 | currency | Currency | Link | Currency | Yes | |
| 15 | procurement_method | Procurement Method | Select | Direct Purchase\nSingle Quotation\nMinimum 2 Quotations\nMinimum 3 Quotations\nTender | No | Auto-suggested by Procurement Threshold Rule |
| 16 | threshold_rule | Threshold Rule | Link | Procurement Threshold Rule | No | Rule applied |
| 17 | items | Items | Table | Purchase Request Item | Yes | Line items |
| 18 | status | Status | Select | Draft\nSubmitted\nBudget Checked\nApproved\nProcurement Processing\nClosed\nRejected | No | Controlled by workflow |
| 19 | budget_check_result | Budget Check Result | Select | Passed\nFailed\nWarning | No | Set by budget check server script |
| 20 | budget_check_notes | Budget Check Notes | Small Text | | No | |
| 21 | approved_by | Approved By | Link | User | No | Set on approval |
| 22 | approval_date | Approval Date | Date | | No | |
| 23 | rejection_reason | Rejection Reason | Small Text | | No | Required if status = Rejected |
| 24 | linked_purchase_order | Linked Purchase Order | Link | Purchase Order | No | Populated when PO is created from this PR |
| 25 | notes | Notes | Small Text | | No | |
| 26 | attachments | Attachments | Attach | | No | Supporting documents |

**Business Rules:**
1. Fund, project, cost_center, and budget_line are mandatory before submission.
2. On submission, system checks budget availability against budget_line; sets budget_check_result.
3. If budget_check_result = Failed and workflow severity is Blocking, submission is halted.
4. procurement_method is auto-suggested from Procurement Threshold Rule matching estimated_amount and fund type; user may override with justification.
5. A Purchase Order may only be created from an Approved Purchase Request.
6. Closing the Purchase Request is only allowed when the linked Purchase Order is submitted or if the request is cancelled.

---

## DocType: Purchase Request Item

**Module:** Fundara > Procurement
**Parent (if child table):** Purchase Request
**Is Submittable:** No
**Has Workflow:** No
**Naming Series:** —

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | item_description | Item / Service Description | Data | | Yes | |
| 2 | item | Item (ERPNext) | Link | Item | No | Link to ERPNext Item catalogue if available |
| 3 | qty | Quantity | Float | | Yes | |
| 4 | uom | Unit of Measure | Link | UOM | Yes | |
| 5 | estimated_unit_price | Estimated Unit Price | Currency | | No | |
| 6 | currency | Currency | Link | Currency | No | |
| 7 | estimated_amount | Estimated Amount | Currency | | No | Auto-computed: qty × unit_price |
| 8 | item_currency | Item Currency | Link | Currency | No | |
| 9 | specifications | Specifications / Remarks | Small Text | | No | |
| 10 | asset_flag | Mark as Asset | Check | | No | If checked, triggers Asset creation on receipt |

**Business Rules:**
1. estimated_amount = qty × estimated_unit_price; recomputed on save.
2. If asset_flag is set, the receiving workflow will prompt to create an Asset record.

---

## DocType: Vendor Registration

**Module:** Fundara > Procurement
**Parent (if child table):** —
**Is Submittable:** No
**Has Workflow:** Yes
**Naming Series:** VND-.YYYY.-.#####

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | naming_series | Naming Series | Select | VND-.YYYY.-.##### | Yes | |
| 2 | vendor_name | Vendor Name | Data | | Yes | |
| 3 | supplier | Supplier (ERPNext) | Link | Supplier | No | Linked ERPNext Supplier record |
| 4 | vendor_type | Vendor Type | Select | Individual\nCompany\nCooperative\nNGO/Foundation\nGovernment Entity | Yes | |
| 5 | business_category | Business Category | Data | | No | e.g. "IT Services", "Construction", "Catering" |
| 6 | tax_number | Tax Number (NPWP) | Data | | No | |
| 7 | registration_number | Business Registration No. | Data | | No | NIB or SIUP |
| 8 | address | Address | Small Text | | No | |
| 9 | city | City | Data | | No | |
| 10 | country | Country | Link | Country | No | |
| 11 | contact_person | Contact Person | Data | | No | |
| 12 | phone | Phone | Data | | No | |
| 13 | email | Email | Data | | No | |
| 14 | bank_name | Bank Name | Data | | No | |
| 15 | bank_account_number | Bank Account Number | Data | | No | |
| 16 | bank_account_name | Bank Account Name | Data | | No | |
| 17 | due_diligence_status | Due Diligence Status | Select | Not Started\nIn Progress\nPassed\nFailed\nWaived | No | |
| 18 | due_diligence_date | Due Diligence Date | Date | | No | |
| 19 | due_diligence_notes | Due Diligence Notes | Small Text | | No | |
| 20 | due_diligence_document | Due Diligence Document | Attach | | No | |
| 21 | conflict_of_interest | Conflict of Interest Declared | Check | | No | |
| 22 | coi_declaration_document | COI Declaration Document | Attach | | No | Required if conflict_of_interest = 1 |
| 23 | blacklist_check | Blacklist Check Done | Check | | No | |
| 24 | blacklist_check_date | Blacklist Check Date | Date | | No | |
| 25 | is_active | Is Active | Check | | Yes | Default 1 |
| 26 | deactivation_reason | Deactivation Reason | Small Text | | No | |
| 27 | notes | Notes | Small Text | | No | |

**Business Rules:**
1. A vendor with due_diligence_status = Failed may not be selected on a Quotation or Purchase Order unless a Compliance Exception is approved.
2. If conflict_of_interest = 1, coi_declaration_document must be attached.
3. Deactivating a vendor (is_active = 0) requires deactivation_reason.
4. Due diligence must be repeated at the interval defined in organisation policy; system should warn if due_diligence_date is stale.

---

## DocType: Quotation (Fundara)

**Module:** Fundara > Procurement
**Parent (if child table):** —
**Is Submittable:** Yes
**Has Workflow:** No
**Naming Series:** QTN-.YYYY.-.#####

> Note: Supplements ERPNext's native Supplier Quotation. Use this DocType when the native form is insufficient for fund-linked tracking.

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | naming_series | Naming Series | Select | QTN-.YYYY.-.##### | Yes | |
| 2 | purchase_request | Purchase Request | Link | Purchase Request | Yes | |
| 3 | vendor | Vendor | Link | Vendor Registration | Yes | |
| 4 | quotation_date | Quotation Date | Date | | Yes | |
| 5 | validity_date | Valid Until | Date | | Yes | |
| 6 | currency | Currency | Link | Currency | Yes | |
| 7 | total_amount | Total Quoted Amount | Currency | | Yes | |
| 8 | quotation_currency | Quotation Currency | Link | Currency | Yes | Companion for total_amount |
| 9 | quotation_document | Quotation Document | Attach | | Yes | Scanned or digital quotation from vendor |
| 10 | items | Items | Table | Quotation Item (Fundara) | No | Line-by-line breakdown |
| 11 | notes | Evaluation Notes | Small Text | | No | Internal notes during evaluation |
| 12 | evaluation_status | Evaluation Status | Select | Pending\nSelected\nNot Selected\nDisqualified | No | Set during Bid Analysis |
| 13 | disqualification_reason | Disqualification Reason | Small Text | | No | Required if evaluation_status = Disqualified |

**Business Rules:**
1. Quotation date must be on or before validity_date.
2. evaluation_status is updated when a Bid Analysis is finalised.
3. A quotation linked to a Purchase Request with procurement_method requiring minimum 3 quotations must not be the only quotation when PO is created.

---

## DocType: Quotation Item (Fundara)

**Module:** Fundara > Procurement
**Parent (if child table):** Quotation (Fundara)
**Is Submittable:** No
**Has Workflow:** No
**Naming Series:** —

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | item_description | Item / Service Description | Data | | Yes | |
| 2 | qty | Quantity | Float | | Yes | |
| 3 | uom | Unit of Measure | Link | UOM | Yes | |
| 4 | unit_price | Unit Price | Currency | | Yes | |
| 5 | item_currency | Currency | Link | Currency | Yes | |
| 6 | amount | Amount | Currency | | No | Auto-computed: qty × unit_price |
| 7 | line_currency | Line Currency | Link | Currency | No | |
| 8 | notes | Notes | Small Text | | No | |

**Business Rules:**
1. amount = qty × unit_price; recomputed on save.

---

## DocType: Bid Analysis

**Module:** Fundara > Procurement
**Parent (if child table):** —
**Is Submittable:** Yes
**Has Workflow:** Yes
**Naming Series:** BID-.YYYY.-.#####

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | naming_series | Naming Series | Select | BID-.YYYY.-.##### | Yes | |
| 2 | purchase_request | Purchase Request | Link | Purchase Request | Yes | |
| 3 | fund | Fund | Link | Fund | Yes | Carried from Purchase Request |
| 4 | project | Project | Link | Project | Yes | |
| 5 | cost_center | Cost Center | Link | Cost Center | Yes | |
| 6 | analysis_date | Analysis Date | Date | | Yes | |
| 7 | quotations | Quotations Compared | Table | Bid Analysis Quotation | Yes | Minimum 2 rows when bid_analysis_required |
| 8 | selected_vendor | Selected Vendor | Link | Vendor Registration | Yes | |
| 9 | selected_quotation | Selected Quotation | Link | Quotation (Fundara) | Yes | |
| 10 | selected_amount | Selected Amount | Currency | | Yes | |
| 11 | selected_currency | Selected Currency | Link | Currency | Yes | |
| 12 | selection_criteria | Selection Criteria | Select | Lowest Price\nBest Value\nTechnical Score\nSole Source Justification | Yes | |
| 13 | selection_reason | Selection Reason / Justification | Long Text | | Yes | |
| 14 | committee_members | Committee Members | Table | Bid Committee Member | No | Required if threshold rule mandates committee |
| 15 | committee_approval_date | Committee Approval Date | Date | | No | |
| 16 | status | Status | Select | Draft\nSubmitted\nApproved\nRejected | No | |
| 17 | approved_by | Approved By | Link | User | No | |
| 18 | approval_date | Approval Date | Date | | No | |
| 19 | rejection_reason | Rejection Reason | Small Text | | No | |
| 20 | supporting_document | Supporting Document | Attach | | No | Bid committee minutes, comparison sheet |

**Business Rules:**
1. Must be linked to an Approved Purchase Request.
2. Number of quotations in the child table must meet the minimum required by the Procurement Threshold Rule.
3. selected_vendor must correspond to selected_quotation.
4. Approved Bid Analysis is a prerequisite for Purchase Order creation when bid_analysis_required = 1.
5. Only one active Bid Analysis per Purchase Request.

---

## DocType: Bid Analysis Quotation

**Module:** Fundara > Procurement
**Parent (if child table):** Bid Analysis
**Is Submittable:** No
**Has Workflow:** No
**Naming Series:** —

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | quotation | Quotation | Link | Quotation (Fundara) | Yes | |
| 2 | vendor | Vendor | Link | Vendor Registration | Yes | Auto-filled from quotation |
| 3 | quoted_amount | Quoted Amount | Currency | | Yes | |
| 4 | quote_currency | Currency | Link | Currency | Yes | |
| 5 | technical_score | Technical Score | Float | | No | 0–100 if evaluation includes technical |
| 6 | remarks | Remarks | Small Text | | No | |
| 7 | is_selected | Selected | Check | | No | Only one row may be selected |

---

## DocType: Bid Committee Member

**Module:** Fundara > Procurement
**Parent (if child table):** Bid Analysis
**Is Submittable:** No
**Has Workflow:** No
**Naming Series:** —

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | member | Member | Link | User | Yes | |
| 2 | role_in_committee | Role in Committee | Data | | No | e.g. "Chair", "Member", "Observer" |
| 3 | signed | Signed | Check | | No | Physical or digital sign-off captured |

---

## DocType: Purchase Order (Fundara)

**Module:** Fundara > Procurement
**Parent (if child table):** —
**Is Submittable:** Yes
**Has Workflow:** Yes
**Naming Series:** PO-.YYYY.-.#####

> Note: Extends ERPNext's native Purchase Order concept with fund, project, activity, and bid traceability.

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | naming_series | Naming Series | Select | PO-.YYYY.-.##### | Yes | |
| 2 | purchase_request | Purchase Request | Link | Purchase Request | Yes | Source PR |
| 3 | bid_analysis | Bid Analysis | Link | Bid Analysis | No | Required if bid_analysis_required on the threshold rule |
| 4 | vendor | Vendor | Link | Vendor Registration | Yes | |
| 5 | erpnext_purchase_order | ERPNext Purchase Order | Link | Purchase Order | No | Mirror in ERPNext native PO |
| 6 | fund | Fund | Link | Fund | Yes | |
| 7 | project | Project | Link | Project | Yes | |
| 8 | activity | Activity | Link | Activity | No | |
| 9 | cost_center | Cost Center | Link | Cost Center | Yes | |
| 10 | budget_line | Budget Line | Link | Budget Line Item | Yes | |
| 11 | order_date | Order Date | Date | | Yes | |
| 12 | delivery_date | Expected Delivery Date | Date | | Yes | |
| 13 | currency | Currency | Link | Currency | Yes | |
| 14 | total_amount | Total Order Amount | Currency | | Yes | |
| 15 | order_currency | Order Currency | Link | Currency | Yes | |
| 16 | items | Order Items | Table | Purchase Order Item (Fundara) | Yes | |
| 17 | payment_terms | Payment Terms | Small Text | | No | |
| 18 | delivery_address | Delivery Address | Small Text | | No | |
| 19 | status | Status | Select | Draft\nSubmitted\nApproved\nGoods/Service Received\nInvoiced\nPaid\nCancelled | No | |
| 20 | commitment_created | Commitment Created | Check | | No | Set by server script when PO is submitted |
| 21 | commitment_entry | Commitment Journal Entry | Link | Journal Entry | No | |
| 22 | approved_by | Approved By | Link | User | No | |
| 23 | approval_date | Approval Date | Date | | No | |
| 24 | cancellation_reason | Cancellation Reason | Small Text | | No | |
| 25 | attachments | Attachments | Attach | | No | Signed PO document, contract |

**Business Rules:**
1. Cannot be submitted without an Approved Purchase Request.
2. If the Procurement Threshold Rule requires a Bid Analysis, bid_analysis must be set and in Approved status.
3. On submission, a commitment journal entry is created against the fund and budget line.
4. Vendor must have due_diligence_status = Passed (or Waived with exception).
5. total_amount must not exceed the budget_line remaining balance without a variance exception.
6. Only one active Purchase Order per Purchase Request (unless partial procurement is enabled).

---

## DocType: Purchase Order Item (Fundara)

**Module:** Fundara > Procurement
**Parent (if child table):** Purchase Order (Fundara)
**Is Submittable:** No
**Has Workflow:** No
**Naming Series:** —

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | item_description | Item / Service Description | Data | | Yes | |
| 2 | item | Item (ERPNext) | Link | Item | No | |
| 3 | qty | Quantity | Float | | Yes | |
| 4 | uom | Unit of Measure | Link | UOM | Yes | |
| 5 | unit_price | Unit Price | Currency | | Yes | |
| 6 | item_currency | Currency | Link | Currency | Yes | |
| 7 | amount | Amount | Currency | | No | Auto-computed |
| 8 | line_currency | Line Currency | Link | Currency | No | |
| 9 | asset_flag | Mark as Asset | Check | | No | |
| 10 | specifications | Specifications | Small Text | | No | |

**Business Rules:**
1. amount = qty × unit_price; recomputed on save.
2. Sum of item amounts must equal Purchase Order total_amount.

---

## DocType: Goods Receipt / Service Acceptance Note

**Module:** Fundara > Procurement
**Parent (if child table):** —
**Is Submittable:** Yes
**Has Workflow:** Yes
**Naming Series:** GRN-.YYYY.-.#####

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | naming_series | Naming Series | Select | GRN-.YYYY.-.##### | Yes | |
| 2 | receipt_type | Receipt Type | Select | Goods\nServices | Yes | |
| 3 | purchase_order | Purchase Order | Link | Purchase Order (Fundara) | Yes | |
| 4 | vendor | Vendor | Link | Vendor Registration | Yes | Auto-filled from PO |
| 5 | fund | Fund | Link | Fund | Yes | Carried from PO |
| 6 | project | Project | Link | Project | Yes | |
| 7 | cost_center | Cost Center | Link | Cost Center | Yes | |
| 8 | receipt_date | Receipt / Acceptance Date | Date | | Yes | |
| 9 | received_by | Received / Accepted By | Link | User | Yes | |
| 10 | items | Items Received | Table | GRN Item | Yes | |
| 11 | service_description | Service Completion Description | Small Text | | No | Required if receipt_type = Services |
| 12 | acceptance_note | Acceptance Notes | Small Text | | No | |
| 13 | erpnext_purchase_receipt | ERPNext Purchase Receipt | Link | Purchase Receipt | No | Mirror in ERPNext native PR |
| 14 | status | Status | Select | Draft\nSubmitted\nVerified\nRejected | No | |
| 15 | verified_by | Verified By | Link | User | No | |
| 16 | verification_date | Verification Date | Date | | No | |
| 17 | rejection_reason | Rejection Reason | Small Text | | No | |
| 18 | delivery_note | Delivery Note / DO Number | Data | | No | |
| 19 | attachments | Attachments | Attach | | No | Delivery note, service completion memo |

**Business Rules:**
1. Can only be created from a Submitted/Approved Purchase Order.
2. Quantities received must not exceed quantities ordered without a documented exception.
3. For Services receipt type, service_description is mandatory.
4. On verification, goods items with asset_flag will prompt Asset creation.
5. A Purchase Invoice may only be processed after a Verified receipt exists.

---

## DocType: GRN Item

**Module:** Fundara > Procurement
**Parent (if child table):** Goods Receipt / Service Acceptance Note
**Is Submittable:** No
**Has Workflow:** No
**Naming Series:** —

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | purchase_order_item | PO Item Reference | Data | | No | Row reference from PO items |
| 2 | item_description | Item / Service Description | Data | | Yes | Auto-filled from PO item |
| 3 | item | Item (ERPNext) | Link | Item | No | |
| 4 | ordered_qty | Ordered Quantity | Float | | No | Read-only; from PO |
| 5 | received_qty | Received Quantity | Float | | Yes | |
| 6 | uom | Unit of Measure | Link | UOM | Yes | |
| 7 | asset_flag | Is Asset | Check | | No | Carried from PO item |
| 8 | condition | Condition | Select | Good\nDamaged\nPartial | No | |
| 9 | remarks | Remarks | Small Text | | No | |

**Business Rules:**
1. received_qty must be > 0.
2. received_qty > ordered_qty triggers a warning requiring supervisor override.

---

## DocType: Travel Request

**Module:** Fundara > Procurement
**Parent (if child table):** —
**Is Submittable:** Yes
**Has Workflow:** Yes
**Naming Series:** TVL-.YYYY.-.#####

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | naming_series | Naming Series | Select | TVL-.YYYY.-.##### | Yes | |
| 2 | traveler | Traveler | Link | User | Yes | |
| 3 | department | Department | Link | Department | No | |
| 4 | fund | Fund | Link | Fund | Yes | |
| 5 | project | Project | Link | Project | Yes | |
| 6 | activity | Activity | Link | Activity | No | |
| 7 | cost_center | Cost Center | Link | Cost Center | Yes | |
| 8 | budget_line | Budget Line | Link | Budget Line Item | No | |
| 9 | travel_purpose | Travel Purpose | Small Text | | Yes | |
| 10 | destination | Destination | Data | | Yes | |
| 11 | departure_date | Departure Date | Date | | Yes | |
| 12 | return_date | Return Date | Date | | Yes | |
| 13 | mode_of_transport | Mode of Transport | Select | Flight\nTrain\nBus\nPrivate Vehicle\nOrganisation Vehicle\nOther | No | |
| 14 | estimated_cost | Estimated Total Cost | Currency | | No | |
| 15 | travel_currency | Currency | Link | Currency | No | |
| 16 | cost_breakdown | Cost Breakdown | Table | Travel Cost Item | No | |
| 17 | advance_required | Advance Required | Check | | No | |
| 18 | advance_amount | Advance Amount | Currency | | No | |
| 19 | advance_currency | Advance Currency | Link | Currency | No | |
| 20 | status | Status | Select | Draft\nSubmitted\nApproved\nRejected\nCompleted | No | |
| 21 | approved_by | Approved By | Link | User | No | |
| 22 | approval_date | Approval Date | Date | | No | |
| 23 | rejection_reason | Rejection Reason | Small Text | | No | |
| 24 | linked_expense_claim | Linked Expense Claim | Link | Expense Claim | No | Post-travel |
| 25 | notes | Notes | Small Text | | No | |

**Business Rules:**
1. return_date must be on or after departure_date.
2. If advance_required = 1, advance_amount must be provided and will create a Cash Advance request.
3. Fund and project must be active during the travel period.
4. Post-travel, an Expense Claim must be submitted and linked; until then status stays Completed-Pending Liquidation.

---

## DocType: Travel Cost Item

**Module:** Fundara > Procurement
**Parent (if child table):** Travel Request
**Is Submittable:** No
**Has Workflow:** No
**Naming Series:** —

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | cost_category | Cost Category | Select | Transportation\nAccommodation\nMeals\nVisa/Document\nOther | Yes | |
| 2 | description | Description | Data | | No | |
| 3 | estimated_amount | Estimated Amount | Currency | | Yes | |
| 4 | item_currency | Currency | Link | Currency | Yes | |

---

## DocType: Vehicle Request

**Module:** Fundara > Procurement
**Parent (if child table):** —
**Is Submittable:** Yes
**Has Workflow:** Yes
**Naming Series:** VEH-.YYYY.-.#####

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | naming_series | Naming Series | Select | VEH-.YYYY.-.##### | Yes | |
| 2 | requester | Requester | Link | User | Yes | |
| 3 | fund | Fund | Link | Fund | No | |
| 4 | project | Project | Link | Project | No | |
| 5 | activity | Activity | Link | Activity | No | |
| 6 | cost_center | Cost Center | Link | Cost Center | No | |
| 7 | purpose | Purpose | Small Text | | Yes | |
| 8 | destination | Destination | Data | | Yes | |
| 9 | request_date | Request Date | Date | | Yes | |
| 10 | departure_datetime | Departure Date & Time | Datetime | | Yes | |
| 11 | return_datetime | Expected Return Date & Time | Datetime | | No | |
| 12 | number_of_passengers | Number of Passengers | Int | | No | |
| 13 | vehicle | Vehicle | Data | | No | Vehicle plate / name; Link to Vehicle DocType if available |
| 14 | driver | Driver | Link | User | No | |
| 15 | status | Status | Select | Draft\nSubmitted\nApproved\nRejected\nCompleted | No | |
| 16 | approved_by | Approved By | Link | User | No | |
| 17 | approval_date | Approval Date | Date | | No | |
| 18 | rejection_reason | Rejection Reason | Small Text | | No | |
| 19 | notes | Notes | Small Text | | No | |

**Business Rules:**
1. return_datetime must be after departure_datetime.
2. Vehicle and driver assignment can be done at approval time.
3. Actual mileage or fuel cost may be recorded as a separate operational expense.

---

## DocType: Asset (Fundara Extension) — (Post-MVP)

**Module:** Fundara > Procurement
**Parent (if child table):** —
**Is Submittable:** No
**Has Workflow:** No
**Naming Series:** AST-.YYYY.-.#####

> Post-MVP: ERPNext's native Asset module handles depreciation and maintenance. This extension adds fund-traceability fields.

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | naming_series | Naming Series | Select | AST-.YYYY.-.##### | Yes | |
| 2 | erpnext_asset | ERPNext Asset | Link | Asset | Yes | Link to native Asset record |
| 3 | fund | Fund | Link | Fund | Yes | Fund that financed the purchase |
| 4 | project | Project | Link | Project | No | |
| 5 | cost_center | Cost Center | Link | Cost Center | Yes | |
| 6 | purchase_order | Purchase Order | Link | Purchase Order (Fundara) | No | Source PO |
| 7 | grn | Goods Receipt | Link | Goods Receipt / Service Acceptance Note | No | |
| 8 | asset_code | Asset Code | Data | | No | Organisation's internal asset tag |
| 9 | assigned_to | Assigned To | Link | User | No | Custodian |
| 10 | location | Location | Data | | No | Physical location |
| 11 | donor_reporting_required | Donor Reporting Required | Check | | No | Flag if asset must appear in donor report |
| 12 | disposal_date | Disposal Date | Date | | No | |
| 13 | disposal_notes | Disposal Notes | Small Text | | No | |
| 14 | status | Status | Select | Active\nTransferred\nDisposed\nLost | No | |

**Business Rules:**
1. Requires an ERPNext Asset record to exist first.
2. Fund and cost_center must match the financing fund.
3. Disposal must be approved and noted; donor may need to be informed.

---

## DocType: Logistics Request — (Post-MVP)

**Module:** Fundara > Procurement
**Parent (if child table):** —
**Is Submittable:** Yes
**Has Workflow:** Yes
**Naming Series:** LOG-.YYYY.-.#####

> Post-MVP: Covers distribution logistics not handled by Travel or Vehicle Request. Relevant for humanitarian/relief programmes.

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | naming_series | Naming Series | Select | LOG-.YYYY.-.##### | Yes | |
| 2 | request_title | Request Title | Data | | Yes | |
| 3 | requester | Requester | Link | User | Yes | |
| 4 | fund | Fund | Link | Fund | Yes | |
| 5 | project | Project | Link | Project | Yes | |
| 6 | activity | Activity | Link | Activity | No | |
| 7 | cost_center | Cost Center | Link | Cost Center | Yes | |
| 8 | logistics_type | Logistics Type | Select | Distribution\nStorage\nTransportation\nOther | Yes | |
| 9 | description | Description | Long Text | | Yes | |
| 10 | required_date | Required Date | Date | | Yes | |
| 11 | destination | Destination | Data | | No | |
| 12 | status | Status | Select | Draft\nSubmitted\nApproved\nIn Progress\nCompleted\nCancelled | No | |
| 13 | notes | Notes | Small Text | | No | |
