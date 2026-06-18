# Mission Delivery — DocType Field Specifications

**Module:** Fundara > Mission Delivery
**Source Context:** `fundara-domain-contexts/05-mission-delivery-context.md`

---

## DocType: Program

**Module:** Fundara > Mission Delivery
**Parent (if child table):** —
**Is Submittable:** No
**Has Workflow:** No
**Naming Series:** PROG-.YYYY.-.####

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | naming_series | Series | Select | PROG-.YYYY.-.#### | Yes | |
| 2 | program_name | Program Name | Data | | Yes | |
| 3 | program_code | Program Code | Data | | No | Short code, e.g. EDU, HLTH |
| 4 | — | — | Section Break | | | Basic Info |
| 5 | strategic_objective | Strategic Objective | Small Text | | No | |
| 6 | program_manager | Program Manager | Link | User | No | |
| 7 | — | — | Column Break | | | |
| 8 | start_date | Start Date | Date | | No | |
| 9 | end_date | End Date | Date | | No | |
| 10 | — | — | Section Break | | | Target & Status |
| 11 | target_population | Target Population | Small Text | | No | Description of beneficiary group |
| 12 | is_active | Is Active | Check | | No | Default 1 |
| 13 | description | Description | Long Text | | No | |

**Business Rules:**
1. `program_code` must be unique if provided.
2. A Program cannot be deactivated (`is_active = 0`) if it has any Project in status Active or On Hold.

---

## DocType: Project Fund Allocation

**Module:** Fundara > Mission Delivery
**Parent (if child table):** Project
**Is Submittable:** No
**Has Workflow:** No
**Naming Series:** —

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | fund | Fund | Link | Fund | Yes | |
| 2 | currency | Currency | Link | Currency | Yes | Pulled from Fund |
| 3 | allocated_amount | Allocated Amount | Currency | | Yes | |
| 4 | exchange_rate | Exchange Rate | Float | | No | Default 1.0 |
| 5 | notes | Notes | Small Text | | No | |

**Business Rules:**
1. `allocated_amount` must be > 0.
2. `currency` must match the currency of the linked Fund.

---

## DocType: Project

**Module:** Fundara > Mission Delivery
**Parent (if child table):** —
**Is Submittable:** No
**Has Workflow:** Yes
**Naming Series:** PROJ-.YYYY.-.####

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | naming_series | Series | Select | PROJ-.YYYY.-.#### | Yes | |
| 2 | project_name | Project Name | Data | | Yes | |
| 3 | project_code | Project Code | Data | | No | |
| 4 | program | Program | Link | Program | Yes | |
| 5 | — | — | Section Break | | | Management |
| 6 | project_manager | Project Manager | Link | User | Yes | |
| 7 | cost_center | Cost Center | Link | Cost Center | No | ERPNext Cost Center |
| 8 | — | — | Column Break | | | |
| 9 | status | Status | Select | Concept\nApproved\nActive\nOn Hold\nCompleted\nClosed | Yes | Default: Concept |
| 10 | — | — | Section Break | | | Period & Location |
| 11 | start_date | Start Date | Date | | Yes | |
| 12 | end_date | End Date | Date | | Yes | |
| 13 | location | Location | Link | Location | No | |
| 14 | — | — | Column Break | | | |
| 15 | target_beneficiaries | Target Beneficiaries | Int | | No | |
| 16 | — | — | Section Break | | | Budget |
| 17 | currency | Currency | Link | Currency | Yes | Primary/base currency of project |
| 18 | total_budget | Total Budget | Currency | | No | Sum of all fund allocations |
| 19 | fund_allocations | Fund Allocations | Table | Project Fund Allocation | No | Multi-fund support |
| 20 | — | — | Section Break | | | Details |
| 21 | objective | Objective | Long Text | | No | |
| 22 | expected_results | Expected Results | Long Text | | No | |
| 23 | notes | Notes | Long Text | | No | |

**Business Rules:**
1. `end_date` must be >= `start_date`.
2. A Project cannot transition to Closed if it has Activity records in status other than Completed, Reported, Verified, or Closed.
3. A Project cannot transition to Closed if there are open Cash Advance records linked to it.
4. `total_budget` is a computed/summary field — the system may maintain it from `fund_allocations`.
5. Status transitions follow the workflow: Concept → Approved → Active → On Hold → Completed → Closed.

---

## DocType: Activity Type

**Module:** Fundara > Mission Delivery
**Parent (if child table):** —
**Is Submittable:** No
**Has Workflow:** No
**Naming Series:** —

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | activity_type_name | Activity Type Name | Data | | Yes | e.g. Training, Distribution, Survey |
| 2 | requires_field_report | Requires Field Report | Check | | No | Default 0 |
| 3 | evidence_requirements | Evidence Requirements | Small Text | | No | Describe minimum evidence |
| 4 | description | Description | Small Text | | No | |
| 5 | is_active | Is Active | Check | | No | Default 1 |

**Business Rules:**
1. If `requires_field_report = 1`, a completed Activity of this type must have at least one linked Field Report before it can be moved to Verified or Closed.

---

## DocType: Activity

**Module:** Fundara > Mission Delivery
**Parent (if child table):** —
**Is Submittable:** Yes
**Has Workflow:** Yes
**Naming Series:** ACT-.YYYY.-.####

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | naming_series | Series | Select | ACT-.YYYY.-.#### | Yes | |
| 2 | activity_name | Activity Name | Data | | Yes | |
| 3 | activity_code | Activity Code | Data | | No | |
| 4 | activity_type | Activity Type | Link | Activity Type | Yes | |
| 5 | — | — | Section Break | | | Project & Fund |
| 6 | project | Project | Link | Project | Yes | |
| 7 | program | Program | Link | Program | No | Read-only; pulled from Project |
| 8 | fund | Fund | Link | Fund | Yes | Which fund covers this activity |
| 9 | budget_line | Budget Line | Link | Fund Budget Line | Yes | |
| 10 | cost_center | Cost Center | Link | Cost Center | No | |
| 11 | — | — | Section Break | | | Responsibility |
| 12 | responsible_person | Responsible Person | Link | User | Yes | |
| 13 | status | Status | Select | Planned\nApproved\nIn Progress\nCompleted\nReported\nVerified\nClosed | Yes | Default: Planned |
| 14 | — | — | Section Break | | | Schedule |
| 15 | planned_date | Planned Date | Date | | Yes | |
| 16 | actual_date | Actual Date | Date | | No | Filled after execution |
| 17 | posting_date | Posting Date | Date | | No | Date for financial reference |
| 18 | — | — | Column Break | | | |
| 19 | location | Location | Link | Location | No | |
| 20 | — | — | Section Break | | | Budget & Cost |
| 21 | currency | Currency | Link | Currency | Yes | |
| 22 | exchange_rate | Exchange Rate | Float | | No | Default 1.0 |
| 23 | planned_cost | Planned Cost | Currency | | No | |
| 24 | actual_cost | Actual Cost | Currency | | No | System-computed from linked transactions |
| 25 | — | — | Section Break | | | Output |
| 26 | target_output | Target Output | Small Text | | No | |
| 27 | actual_output | Actual Output | Small Text | | No | Filled after completion |
| 28 | — | — | Section Break | | | Notes |
| 29 | description | Description | Long Text | | No | |
| 30 | notes | Notes | Long Text | | No | |

**Business Rules:**
1. Activity must belong to a Project with status Active.
2. Activity must have a `responsible_person`.
3. Activity may only request funds (generate Cash Advance) when status = Approved or In Progress.
4. If linked `activity_type.requires_field_report = 1`, Activity cannot move to Verified until a Field Report is linked.
5. `actual_cost` is computed from posted transactions (disbursements, liquidated advances) linked to this Activity.
6. `program` is auto-populated from `project.program` and is read-only.

---

## DocType: Workplan Activity

**Module:** Fundara > Mission Delivery
**Parent (if child table):** Workplan
**Is Submittable:** No
**Has Workflow:** No
**Naming Series:** —

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | activity | Activity | Link | Activity | Yes | |
| 2 | planned_date | Planned Date | Date | | No | |
| 3 | responsible_person | Responsible Person | Link | User | No | |
| 4 | planned_cost | Planned Cost | Currency | | No | |
| 5 | notes | Notes | Small Text | | No | |

---

## DocType: Workplan

**Module:** Fundara > Mission Delivery
**Parent (if child table):** —
**Is Submittable:** Yes
**Has Workflow:** Yes
**Naming Series:** WP-.YYYY.-.####

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | naming_series | Series | Select | WP-.YYYY.-.#### | Yes | |
| 2 | workplan_name | Workplan Name | Data | | Yes | |
| 3 | project | Project | Link | Project | Yes | |
| 4 | fund | Fund | Link | Fund | No | Primary fund for this workplan |
| 5 | cost_center | Cost Center | Link | Cost Center | No | |
| 6 | — | — | Section Break | | | Period |
| 7 | period_type | Period Type | Select | Monthly\nQuarterly\nAnnual\nCustom | Yes | |
| 8 | period_label | Period Label | Data | | No | e.g. "Q1 2025", "January 2025" |
| 9 | start_date | Start Date | Date | | Yes | |
| 10 | end_date | End Date | Date | | Yes | |
| 11 | — | — | Section Break | | | Activities |
| 12 | activities | Activities | Table | Workplan Activity | No | |
| 13 | — | — | Section Break | | | Budget & Approval |
| 14 | currency | Currency | Link | Currency | Yes | |
| 15 | exchange_rate | Exchange Rate | Float | | No | Default 1.0 |
| 16 | posting_date | Posting Date | Date | | No | |
| 17 | planned_budget | Planned Budget | Currency | | No | Total planned across activities |
| 18 | approval_status | Approval Status | Select | Draft\nSubmitted\nApproved\nRejected | No | Managed by workflow |
| 19 | approved_by | Approved By | Link | User | No | |
| 20 | approval_date | Approval Date | Date | | No | |
| 21 | — | — | Section Break | | | Notes |
| 22 | expected_outputs | Expected Outputs | Long Text | | No | |
| 23 | notes | Notes | Long Text | | No | |

**Business Rules:**
1. `end_date` must be >= `start_date`.
2. All Activities listed in the workplan must belong to the same `project`.
3. A Workplan can only be approved if the linked Project is in status Active.

---

## DocType: Deliverable

**Module:** Fundara > Mission Delivery
**Parent (if child table):** —
**Is Submittable:** Yes
**Has Workflow:** Yes
**Naming Series:** DLV-.YYYY.-.####

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | naming_series | Series | Select | DLV-.YYYY.-.#### | Yes | |
| 2 | deliverable_name | Deliverable Name | Data | | Yes | |
| 3 | project | Project | Link | Project | Yes | |
| 4 | activity | Activity | Link | Activity | No | Optional link to specific activity |
| 5 | fund | Fund | Link | Fund | No | |
| 6 | cost_center | Cost Center | Link | Cost Center | No | |
| 7 | — | — | Section Break | | | Responsibility & Schedule |
| 8 | responsible_person | Responsible Person | Link | User | Yes | |
| 9 | due_date | Due Date | Date | | Yes | |
| 10 | completion_date | Completion Date | Date | | No | |
| 11 | — | — | Column Break | | | |
| 12 | completion_status | Completion Status | Select | Pending\nIn Progress\nSubmitted for Review\nApproved\nCompleted\nOverdue | Yes | Default: Pending |
| 13 | — | — | Section Break | | | Evidence |
| 14 | evidence_required | Evidence Required | Small Text | | No | Description of what must be submitted |
| 15 | attachment | Attachment | Attach | | No | Primary deliverable file |
| 16 | — | — | Section Break | | | Notes |
| 17 | currency | Currency | Link | Currency | No | For cost tracking if applicable |
| 18 | exchange_rate | Exchange Rate | Float | | No | Default 1.0 |
| 19 | posting_date | Posting Date | Date | | No | |
| 20 | description | Description | Long Text | | No | |
| 21 | notes | Notes | Long Text | | No | |

**Business Rules:**
1. `completion_date` must be set when `completion_status` is changed to Completed.
2. A Deliverable cannot be marked Completed without an `attachment` if `evidence_required` is non-empty.
3. Completion status becomes Overdue automatically if `due_date` has passed and status is still Pending or In Progress.

---

## DocType: Field Report Evidence

**Module:** Fundara > Mission Delivery
**Parent (if child table):** Field Report
**Is Submittable:** No
**Has Workflow:** No
**Naming Series:** —

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | evidence_type | Evidence Type | Select | Photo\nDocument\nVideo\nOther | Yes | |
| 2 | attachment | Attachment | Attach | | Yes | |
| 3 | description | Description | Small Text | | No | |

---

## DocType: Field Report

**Module:** Fundara > Mission Delivery
**Parent (if child table):** —
**Is Submittable:** Yes
**Has Workflow:** Yes
**Naming Series:** FR-.YYYY.-.####

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | naming_series | Series | Select | FR-.YYYY.-.#### | Yes | |
| 2 | field_report_number | Field Report Number | Data | | No | Auto from naming_series |
| 3 | activity | Activity | Link | Activity | Yes | |
| 4 | project | Project | Link | Project | No | Read-only; auto-populated from Activity |
| 5 | fund | Fund | Link | Fund | No | Read-only; auto-populated from Activity |
| 6 | cost_center | Cost Center | Link | Cost Center | No | |
| 7 | — | — | Section Break | | | Report Details |
| 8 | report_date | Report Date | Date | | Yes | Date of field activity |
| 9 | posting_date | Posting Date | Date | | No | |
| 10 | location | Location | Link | Location | No | |
| 11 | — | — | Column Break | | | |
| 12 | submitted_by | Submitted By | Link | User | Yes | |
| 13 | verification_status | Verification Status | Select | Draft\nSubmitted\nUnder Review\nVerified\nRejected | Yes | Default: Draft |
| 14 | verified_by | Verified By | Link | User | No | |
| 15 | verified_on | Verified On | Date | | No | |
| 16 | — | — | Section Break | | | Participants |
| 17 | participant_count | Participant Count | Int | | No | |
| 18 | participant_breakdown | Participant Breakdown | Small Text | | No | e.g. "Male: 10, Female: 15" |
| 19 | — | — | Section Break | | | Narrative |
| 20 | summary | Summary | Long Text | | Yes | |
| 21 | issues_encountered | Issues Encountered | Long Text | | No | |
| 22 | lessons_learned | Lessons Learned | Long Text | | No | |
| 23 | — | — | Section Break | | | Evidence |
| 24 | evidence_attachments | Evidence Attachments | Table | Field Report Evidence | No | |
| 25 | currency | Currency | Link | Currency | No | |
| 26 | exchange_rate | Exchange Rate | Float | | No | Default 1.0 |

**Business Rules:**
1. `project` and `fund` are auto-populated from the linked `activity` and are read-only.
2. Verification can only be done by a user other than `submitted_by`.
3. An Activity where `activity_type.requires_field_report = 1` cannot be marked Verified unless at least one Field Report with `verification_status = Verified` exists.

---

## DocType: Location

**Module:** Fundara > Mission Delivery
**Parent (if child table):** —
**Is Submittable:** No
**Has Workflow:** No
**Naming Series:** —

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | location_name | Location Name | Data | | Yes | |
| 2 | administrative_level | Administrative Level | Select | National\nProvince\nDistrict\nSub-district\nVillage\nSite | No | |
| 3 | — | — | Section Break | | | Administrative Area |
| 4 | country | Country | Link | Country | No | |
| 5 | province_state | Province / State | Data | | No | |
| 6 | district | District / Kabupaten / Kota | Data | | No | |
| 7 | sub_district | Sub-district / Kecamatan | Data | | No | |
| 8 | village | Village / Desa / Kelurahan | Data | | No | |
| 9 | — | — | Section Break | | | Coordinates & Risk |
| 10 | latitude | Latitude | Float | | No | |
| 11 | longitude | Longitude | Float | | No | |
| 12 | risk_profile | Risk Profile | Select | Low\nMedium\nHigh\nVery High | No | |
| 13 | is_active | Is Active | Check | | No | Default 1 |
| 14 | notes | Notes | Small Text | | No | |

**Business Rules:**
1. `location_name` must be unique.
2. If GPS coordinates are provided, `latitude` must be between -90 and 90, and `longitude` between -180 and 180.
