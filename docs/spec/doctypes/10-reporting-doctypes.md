# Reporting — DocType Field Specifications

**Module:** Fundara > Reporting

---

## DocType: Reporting Period

**Module:** Fundara > Reporting
**Parent (if child table):** —
**Is Submittable:** No
**Has Workflow:** No
**Naming Series:** —

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | period_name | Period Name | Data | | Yes | e.g. "Q1 2025", "Annual 2024–2025" |
| 2 | frequency | Frequency | Select | Monthly\nQuarterly\nSemi-Annual\nAnnual\nCustom | Yes | |
| 3 | period_start | Period Start | Date | | Yes | |
| 4 | period_end | Period End | Date | | Yes | |
| 5 | due_date | Report Due Date | Date | | No | Deadline for submitting reports in this period |
| 6 | responsible_person | Responsible Person | Link | User | No | Default report owner for this period |
| 7 | fiscal_year | Fiscal Year | Link | Fiscal Year | No | |
| 8 | status | Status | Select | Open\nClosed | No | Closed periods prevent new report entries |
| 9 | notes | Notes | Small Text | | No | |

**Business Rules:**
1. period_end must be on or after period_start.
2. Periods of the same frequency must not overlap.
3. Closing a period prevents new Report records from being linked to it; existing draft reports may still be finalised.

---

## DocType: Report Template

**Module:** Fundara > Reporting
**Parent (if child table):** —
**Is Submittable:** No
**Has Workflow:** No
**Naming Series:** RPT-.#####

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | naming_series | Naming Series | Select | RPT-.##### | Yes | |
| 2 | template_name | Template Name | Data | | Yes | e.g. "Donor Financial Report – Standard" |
| 3 | report_type | Report Type | Select | Donor Financial Report\nDonor Narrative Report\nCampaign Report\nFund Utilization Report\nBoard Report\nManagement Report\nPublic Impact Report\nProject Progress Report\nAdvance Aging Report\nAudit Pack\nOther | Yes | |
| 4 | applicable_fund_type | Applicable Fund Type | Select | \nRestricted\nUnrestricted\nEndowment\nCampaign | No | Leave blank for all fund types |
| 5 | applicable_donor | Applicable Donor | Link | Donor | No | Specific donor template if required |
| 6 | applicable_campaign | Applicable Campaign | Link | Campaign | No | |
| 7 | sections | Template Sections | Table | Report Template Section | No | Ordered list of report sections |
| 8 | required_data_sources | Required Data Sources | Small Text | | No | Describe which contexts/DocTypes provide data |
| 9 | output_format | Output Format | Select | PDF\nExcel\nBoth | No | |
| 10 | print_format | Print Format | Link | Print Format | No | Frappe print format for PDF export |
| 11 | is_active | Is Active | Check | | Yes | Default 1 |
| 12 | notes | Notes | Small Text | | No | |

**Business Rules:**
1. A deactivated template cannot be selected when creating a new Report.
2. Existing Reports linked to a deactivated template remain unaffected.
3. Report Templates should be kept minimal in the MVP phase to reduce maintenance burden.

---

## DocType: Report Template Section

**Module:** Fundara > Reporting
**Parent (if child table):** Report Template
**Is Submittable:** No
**Has Workflow:** No
**Naming Series:** —

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | section_order | Order | Int | | Yes | Display sequence |
| 2 | section_name | Section Name | Data | | Yes | e.g. "Financial Summary", "Indicator Achievement" |
| 3 | section_type | Section Type | Select | Financial\nNarrative\nIndicator\nEvidence\nCustom | Yes | |
| 4 | is_mandatory | Is Mandatory | Check | | No | If mandatory, report cannot be approved with section empty |
| 5 | instructions | Instructions | Small Text | | No | Guidance for the person filling this section |

---

## DocType: Report

**Module:** Fundara > Reporting
**Parent (if child table):** —
**Is Submittable:** Yes
**Has Workflow:** Yes
**Naming Series:** RPT-.YYYY.-.#####

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | naming_series | Naming Series | Select | RPT-.YYYY.-.##### | Yes | |
| 2 | report_title | Report Title | Data | | Yes | e.g. "Donor Financial Report – Fund XYZ – Q1 2025" |
| 3 | report_type | Report Type | Select | Donor Financial Report\nDonor Narrative Report\nCampaign Report\nFund Utilization Report\nBoard Report\nManagement Report\nPublic Impact Report\nProject Progress Report\nAdvance Aging Report\nAudit Pack\nOther | Yes | |
| 4 | report_template | Report Template | Link | Report Template | No | |
| 5 | reporting_period | Reporting Period | Link | Reporting Period | Yes | |
| 6 | fund | Fund | Link | Fund | No | Required for Donor/Fund reports |
| 7 | project | Project | Link | Project | No | Required for Project/Programme reports |
| 8 | donor | Donor | Link | Donor | No | Required for Donor reports |
| 9 | campaign | Campaign | Link | Campaign | No | Required for Campaign reports |
| 10 | generated_by | Generated By | Link | User | Yes | Auto-set |
| 11 | generated_date | Generated Date | Date | | Yes | Auto-set to today |
| 12 | period_start | Period Start | Date | | Yes | Convenience repeat of reporting period start |
| 13 | period_end | Period End | Date | | Yes | |
| 14 | status | Status | Select | Draft\nGenerated\nReviewed\nApproved\nSubmitted\nArchived | No | Controlled by workflow |
| 15 | report_lines | Report Lines | Table | Report Line | No | Financial detail lines |
| 16 | impact_section | Impact Achievement Summary | Long Text | | No | Narrative or reference to Indicator Achievements |
| 17 | narrative_sections | Narrative Sections | Table | Report Narrative Section | No | Free-text narrative blocks per template section |
| 18 | supporting_document_register | Supporting Document Register | Link | Supporting Document Register | No | |
| 19 | missing_evidence_flag | Missing Evidence | Check | | No | Set by system if SDR shows missing items |
| 20 | approved_by | Approved By | Link | User | No | |
| 21 | approval_date | Approval Date | Date | | No | |
| 22 | submitted_to | Submitted To | Data | | No | Name of donor, board, authority |
| 23 | submission_date | Submission Date | Date | | No | |
| 24 | revision_of | Revision Of | Link | Report | No | Set if this is a revised version of a submitted report |
| 25 | revision_reason | Revision Reason | Small Text | | No | Required if revision_of is set |
| 26 | notes | Internal Notes | Small Text | | No | |
| 27 | attachments | Attachments | Attach | | No | Exported PDF, donor submission files |

**Business Rules:**
1. Donor Financial Report must have fund or project set.
2. Campaign Report must have campaign set.
3. A Report may not be submitted (status → Submitted) if:
   a. The mandatory review cycle is not complete (Report Review records not all Approved), or
   b. missing_evidence_flag = 1 unless an explicit override with justification is recorded.
4. A Submitted report is read-only; corrections require creating a new Report with revision_of pointing to the submitted report.
5. revision_reason is mandatory if revision_of is set.
6. Archiving a Report preserves it permanently; archived reports cannot be deleted.

---

## DocType: Report Line

**Module:** Fundara > Reporting
**Parent (if child table):** Report
**Is Submittable:** No
**Has Workflow:** No
**Naming Series:** —

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | line_type | Line Type | Select | Budget\nActual Expense\nAdvance\nCommitment\nIndicator Achievement\nOther | Yes | |
| 2 | line_description | Description | Data | | Yes | |
| 3 | budget_line | Budget Line | Link | Budget Line Item | No | Linked budget line if financial |
| 4 | activity | Activity | Link | Activity | No | |
| 5 | indicator | Indicator | Link | Indicator | No | For impact lines |
| 6 | indicator_achievement | Indicator Achievement | Link | Indicator Achievement | No | |
| 7 | transaction_type | Transaction Type | Data | | No | DocType of the source transaction |
| 8 | transaction_reference | Transaction Reference | Data | | No | Name of the source transaction |
| 9 | budget_amount | Budget Amount | Currency | | No | |
| 10 | line_currency | Currency | Link | Currency | No | |
| 11 | actual_amount | Actual Amount | Currency | | No | |
| 12 | variance_amount | Variance | Currency | | No | Computed: budget - actual |
| 13 | variance_percent | Variance % | Percent | | No | |
| 14 | evidence_status | Evidence Status | Select | Complete\nMissing\nPending | No | |
| 15 | evidence_reference | Evidence Reference | Link | Evidence | No | |
| 16 | notes | Notes | Small Text | | No | |

**Business Rules:**
1. Financial lines (Actual Expense, Advance, Commitment) must have transaction_reference traceable to a real Fundara transaction.
2. Indicator Achievement lines must link to a Verified Indicator Achievement record.
3. variance_amount = budget_amount − actual_amount; recomputed on save when both values are present.
4. Evidence status must be Complete for report approval; Missing lines trigger missing_evidence_flag on the parent Report.

---

## DocType: Report Narrative Section

**Module:** Fundara > Reporting
**Parent (if child table):** Report
**Is Submittable:** No
**Has Workflow:** No
**Naming Series:** —

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | section_name | Section Name | Data | | Yes | Must match a template section name |
| 2 | section_type | Section Type | Select | Financial\nNarrative\nIndicator\nEvidence\nCustom | Yes | |
| 3 | content | Content | Long Text | | No | Written by staff; may be required depending on template |
| 4 | is_complete | Is Complete | Check | | No | Staff marks complete before review |

---

## DocType: Report Review

**Module:** Fundara > Reporting
**Parent (if child table):** —
**Is Submittable:** No
**Has Workflow:** No
**Naming Series:** RRV-.YYYY.-.#####

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | naming_series | Naming Series | Select | RRV-.YYYY.-.##### | Yes | |
| 2 | report | Report | Link | Report | Yes | |
| 3 | reviewer | Reviewer | Link | User | Yes | |
| 4 | review_role | Review Role | Select | Finance Review\nProgramme Review\nMEAL Review\nManagement Approval\nBoard Approval | Yes | |
| 5 | review_date | Review Date | Date | | Yes | Auto-set to today |
| 6 | decision | Decision | Select | Approved\nNeeds Revision\nRejected | Yes | |
| 7 | comments | Comments | Long Text | | No | Required if decision = Needs Revision or Rejected |
| 8 | revision_requested | Revision Requested | Check | | No | Auto-set if decision = Needs Revision |

**Business Rules:**
1. Multiple Report Reviews may exist for a single report (one per review role).
2. All mandatory review roles defined by the report template must have an Approved review before the report moves to Approved status.
3. A Needs Revision decision resets the report status to Draft (or Generated) and notifies the report owner.
4. comments is mandatory when decision is Needs Revision or Rejected.

---

## DocType: Report Submission

**Module:** Fundara > Reporting
**Parent (if child table):** —
**Is Submittable:** No
**Has Workflow:** No
**Naming Series:** RSB-.YYYY.-.#####

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | naming_series | Naming Series | Select | RSB-.YYYY.-.##### | Yes | |
| 2 | report | Report | Link | Report | Yes | Must be in Approved status |
| 3 | submitted_to | Submitted To | Data | | Yes | Name of recipient (donor, board, authority) |
| 4 | recipient_email | Recipient Email | Data | | No | |
| 5 | submission_date | Submission Date | Date | | Yes | |
| 6 | submission_method | Submission Method | Select | Email\nPortal Upload\nPhysical Delivery\nCourier\nOther | Yes | |
| 7 | submitted_by | Submitted By | Link | User | Yes | Auto-set |
| 8 | acknowledgment_received | Acknowledgment Received | Check | | No | |
| 9 | acknowledgment_date | Acknowledgment Date | Date | | No | |
| 10 | acknowledgment_document | Acknowledgment Document | Attach | | No | |
| 11 | tracking_reference | Tracking Reference | Data | | No | Portal reference number or courier tracking |
| 12 | notes | Notes | Small Text | | No | |

**Business Rules:**
1. Report must be in Approved status before a Submission record can be created.
2. Submission date cannot be in the future.
3. acknowledgment_date must be on or after submission_date.
4. A Submission record is permanent; it cannot be deleted.
5. A report may have multiple submissions (e.g. initial submission + re-submission after revision).

---

## DocType: Fund Utilization Report

**Module:** Fundara > Reporting
**Parent (if child table):** —
**Is Submittable:** Yes
**Has Workflow:** Yes
**Naming Series:** FUR-.YYYY.-.#####

> MVP Core: Primary financial accountability report showing budget vs actual by fund.

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | naming_series | Naming Series | Select | FUR-.YYYY.-.##### | Yes | |
| 2 | report_title | Report Title | Data | | Yes | Auto-generated from fund + period |
| 3 | fund | Fund | Link | Fund | Yes | |
| 4 | reporting_period | Reporting Period | Link | Reporting Period | Yes | |
| 5 | period_start | Period Start | Date | | Yes | |
| 6 | period_end | Period End | Date | | Yes | |
| 7 | generated_by | Generated By | Link | User | Yes | |
| 8 | generated_date | Generated Date | Date | | Yes | |
| 9 | total_budget | Total Budget | Currency | | No | Sum of all approved budget lines for this fund |
| 10 | fund_currency | Fund Currency | Link | Currency | Yes | |
| 11 | total_committed | Total Committed | Currency | | No | Sum of open Purchase Orders |
| 12 | total_actual | Total Actual Expense | Currency | | No | Sum of posted expense transactions |
| 13 | total_advance_outstanding | Total Advance Outstanding | Currency | | No | |
| 14 | available_balance | Available Balance | Currency | | No | budget − committed − actual |
| 15 | utilization_percent | Utilization % | Percent | | No | actual / budget × 100 |
| 16 | budget_lines | Budget vs Actual by Line | Table | FUR Budget Line | No | Detail per budget line |
| 17 | status | Status | Select | Draft\nGenerated\nApproved\nSubmitted\nArchived | No | |
| 18 | approved_by | Approved By | Link | User | No | |
| 19 | notes | Notes | Small Text | | No | |

**Business Rules:**
1. All currency amounts use the fund's base currency; multi-currency transactions are converted at the recorded exchange rate.
2. available_balance = total_budget − total_committed − total_actual − total_advance_outstanding.
3. utilization_percent = total_actual / total_budget × 100; recomputed on save.
4. Budget line detail must be traceable to the Budget Line Item and underlying transactions.
5. A submitted Fund Utilization Report cannot be modified; a new report with revision reference must be created.

---

## DocType: FUR Budget Line

**Module:** Fundara > Reporting
**Parent (if child table):** Fund Utilization Report
**Is Submittable:** No
**Has Workflow:** No
**Naming Series:** —

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | budget_line | Budget Line | Link | Budget Line Item | Yes | |
| 2 | budget_line_name | Budget Line Name | Data | | No | Auto-filled |
| 3 | project | Project | Link | Project | No | |
| 4 | cost_center | Cost Center | Link | Cost Center | No | |
| 5 | approved_budget | Approved Budget | Currency | | No | |
| 6 | line_currency | Currency | Link | Currency | No | |
| 7 | committed_amount | Committed | Currency | | No | Open PO value |
| 8 | actual_amount | Actual Expense | Currency | | No | Posted expenses |
| 9 | advance_outstanding | Advance Outstanding | Currency | | No | |
| 10 | available_balance | Available Balance | Currency | | No | Computed |
| 11 | utilization_percent | Utilization % | Percent | | No | Computed |
| 12 | variance_notes | Variance Notes | Small Text | | No | Explanation if variance > threshold |

---

## DocType: Campaign Report

**Module:** Fundara > Reporting
**Parent (if child table):** —
**Is Submittable:** Yes
**Has Workflow:** Yes
**Naming Series:** CAR-.YYYY.-.#####

> MVP Core: Accountability report for public campaigns showing collection vs disbursement.

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | naming_series | Naming Series | Select | CAR-.YYYY.-.##### | Yes | |
| 2 | campaign | Campaign | Link | Campaign | Yes | |
| 3 | report_title | Report Title | Data | | Yes | |
| 4 | reporting_period | Reporting Period | Link | Reporting Period | Yes | |
| 5 | period_start | Period Start | Date | | Yes | |
| 6 | period_end | Period End | Date | | Yes | |
| 7 | generated_by | Generated By | Link | User | Yes | |
| 8 | generated_date | Generated Date | Date | | Yes | |
| 9 | total_collected | Total Collected | Currency | | No | Sum of campaign donations received |
| 10 | campaign_currency | Currency | Link | Currency | Yes | |
| 11 | platform_fees | Platform / Payment Fees | Currency | | No | |
| 12 | net_collected | Net Collected | Currency | | No | total_collected − platform_fees |
| 13 | total_disbursed | Total Disbursed | Currency | | No | Expenses charged to campaign fund |
| 14 | remaining_balance | Remaining Balance | Currency | | No | net_collected − total_disbursed |
| 15 | disbursement_lines | Disbursement Lines | Table | Campaign Disbursement Line | No | Per programme area or activity |
| 16 | beneficiaries_reached | Beneficiaries Reached | Int | | No | Aggregate count |
| 17 | key_outputs | Key Outputs Summary | Small Text | | No | |
| 18 | narrative | Narrative Summary | Long Text | | No | Public-facing summary |
| 19 | status | Status | Select | Draft\nGenerated\nApproved\nSubmitted\nArchived | No | |
| 20 | approved_by | Approved By | Link | User | No | |
| 21 | public_report | Is Public Report | Check | | No | If checked, formatted for public transparency |
| 22 | notes | Notes | Small Text | | No | |

**Business Rules:**
1. Campaign must be linked to a Campaign Fund.
2. remaining_balance = net_collected − total_disbursed; must not be negative without explanation.
3. If public_report = 1, only non-sensitive information is included in the export.
4. Submitted Campaign Reports should be archived in the organisation's public transparency register.

---

## DocType: Campaign Disbursement Line

**Module:** Fundara > Reporting
**Parent (if child table):** Campaign Report
**Is Submittable:** No
**Has Workflow:** No
**Naming Series:** —

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | programme_area | Programme Area / Activity | Data | | Yes | |
| 2 | activity | Activity | Link | Activity | No | |
| 3 | amount_disbursed | Amount Disbursed | Currency | | Yes | |
| 4 | line_currency | Currency | Link | Currency | Yes | |
| 5 | description | Description | Small Text | | No | |
| 6 | beneficiaries_reached | Beneficiaries Reached | Int | | No | |

---

## DocType: Advance Aging Report

**Module:** Fundara > Reporting
**Parent (if child table):** —
**Is Submittable:** No
**Has Workflow:** No
**Naming Series:** AAR-.YYYY.-.#####

> MVP Core: Tracks outstanding cash advances to identify overdue liquidations.

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | naming_series | Naming Series | Select | AAR-.YYYY.-.##### | Yes | |
| 2 | report_title | Report Title | Data | | Yes | Auto-generated |
| 3 | as_of_date | As of Date | Date | | Yes | Snapshot date |
| 4 | generated_by | Generated By | Link | User | Yes | |
| 5 | generated_date | Generated Date | Date | | Yes | |
| 6 | fund | Fund | Link | Fund | No | Filter by fund; blank = all funds |
| 7 | project | Project | Link | Project | No | Filter by project |
| 8 | advance_lines | Advance Lines | Table | Advance Aging Line | Yes | One row per outstanding advance |
| 9 | total_outstanding | Total Outstanding | Currency | | No | Sum of all outstanding amounts |
| 10 | report_currency | Currency | Link | Currency | Yes | |
| 11 | overdue_count | Overdue Count | Int | | No | Advances past due date |
| 12 | notes | Notes | Small Text | | No | |

**Business Rules:**
1. Only Cash Advances with status != Fully Liquidated appear in the lines.
2. Days outstanding is computed from the advance date to as_of_date.
3. An advance is Overdue if days outstanding > the organisation's standard liquidation period (configurable).
4. Report is a snapshot; it does not change historical records.

---

## DocType: Advance Aging Line

**Module:** Fundara > Reporting
**Parent (if child table):** Advance Aging Report
**Is Submittable:** No
**Has Workflow:** No
**Naming Series:** —

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | cash_advance | Cash Advance | Link | Cash Advance | Yes | |
| 2 | advance_holder | Advance Holder | Link | User | No | Auto-filled |
| 3 | advance_date | Advance Date | Date | | No | |
| 4 | due_date | Due Date | Date | | No | Expected liquidation date |
| 5 | fund | Fund | Link | Fund | No | |
| 6 | project | Project | Link | Project | No | |
| 7 | original_amount | Original Amount | Currency | | No | |
| 8 | line_currency | Currency | Link | Currency | No | |
| 9 | liquidated_amount | Liquidated Amount | Currency | | No | |
| 10 | outstanding_amount | Outstanding Amount | Currency | | No | original − liquidated |
| 11 | days_outstanding | Days Outstanding | Int | | No | As of report date |
| 12 | is_overdue | Is Overdue | Check | | No | |
| 13 | aging_bucket | Aging Bucket | Select | 0–30 Days\n31–60 Days\n61–90 Days\n91–180 Days\n180+ Days | No | |

---

## DocType: Dashboard Configuration — (Post-MVP)

**Module:** Fundara > Reporting
**Parent (if child table):** —
**Is Submittable:** No
**Has Workflow:** No
**Naming Series:** —

> Post-MVP: Formal DocType for configuring role-based dashboard widgets. In MVP, use Frappe's built-in Workspace and Dashboard configuration directly.

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | dashboard_name | Dashboard Name | Data | | Yes | e.g. "Executive Dashboard", "Finance Dashboard" |
| 2 | target_roles | Target Roles | Table | Dashboard Role | Yes | Roles that see this dashboard |
| 3 | widgets | Widgets | Table | Dashboard Widget | No | Ordered list of charts/numbers/shortcuts |
| 4 | is_default | Is Default for Role | Check | | No | If 1, auto-loaded for users with the target role |
| 5 | is_active | Is Active | Check | | Yes | Default 1 |

---

## DocType: Dashboard Role — (Post-MVP)

**Module:** Fundara > Reporting
**Parent (if child table):** Dashboard Configuration
**Is Submittable:** No
**Has Workflow:** No
**Naming Series:** —

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | role | Role | Link | Role | Yes | |

---

## DocType: Dashboard Widget — (Post-MVP)

**Module:** Fundara > Reporting
**Parent (if child table):** Dashboard Configuration
**Is Submittable:** No
**Has Workflow:** No
**Naming Series:** —

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | widget_order | Order | Int | | Yes | |
| 2 | widget_type | Widget Type | Select | Number Card\nChart\nShortcut\nReport Link | Yes | |
| 3 | widget_label | Label | Data | | Yes | |
| 4 | source_report | Source Report | Data | | No | Frappe Report name |
| 5 | source_doctype | Source DocType | Link | DocType | No | |
| 6 | filter_field | Filter Field | Data | | No | e.g. "fund", "project" |
| 7 | chart_type | Chart Type | Select | Bar\nLine\nPie\nDonut\nNumber | No | |
| 8 | is_visible | Is Visible | Check | | Yes | Default 1 |
