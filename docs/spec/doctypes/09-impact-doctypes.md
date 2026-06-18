# Impact & Learning — DocType Field Specifications

**Module:** Fundara > Impact & Learning

---

## DocType: Impact Framework

**Module:** Fundara > Impact & Learning
**Parent (if child table):** —
**Is Submittable:** No
**Has Workflow:** Yes
**Naming Series:** IMP-.YYYY.-.#####

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | naming_series | Naming Series | Select | IMP-.YYYY.-.##### | Yes | |
| 2 | framework_name | Framework Name | Data | | Yes | e.g. "Education Programme Theory of Change 2025" |
| 3 | scope | Scope | Select | Organisation\nProgramme\nProject | Yes | |
| 4 | programme | Programme | Link | Programme | No | Required if scope = Programme |
| 5 | project | Project | Link | Project | No | Required if scope = Project |
| 6 | period_start | Period Start | Date | | Yes | |
| 7 | period_end | Period End | Date | | Yes | |
| 8 | theory_of_change_summary | Theory of Change Summary | Long Text | | No | Narrative explanation of the causal chain |
| 9 | strategic_objective | Strategic Objective | Small Text | | No | High-level goal this framework serves |
| 10 | owner | Owner | Link | User | Yes | Responsible MEAL officer or programme manager |
| 11 | status | Status | Select | Draft\nActive\nArchived | No | |
| 12 | approved_by | Approved By | Link | User | No | |
| 13 | approval_date | Approval Date | Date | | No | |
| 14 | framework_document | Framework Document | Attach | | No | Full ToC document |
| 15 | notes | Notes | Small Text | | No | |

**Business Rules:**
1. A Project or Programme may have only one Active Impact Framework at a time.
2. Once Archived, the framework is read-only; a new version must be created.
3. Outcomes and Indicators must be linked to an Active Impact Framework.
4. period_end must be on or after period_start.

---

## DocType: Outcome

**Module:** Fundara > Impact & Learning
**Parent (if child table):** —
**Is Submittable:** No
**Has Workflow:** No
**Naming Series:** OUT-.#####

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | naming_series | Naming Series | Select | OUT-.##### | Yes | |
| 2 | outcome_statement | Outcome Statement | Data | | Yes | e.g. "Increased access to quality education for marginalised children" |
| 3 | impact_framework | Impact Framework | Link | Impact Framework | Yes | |
| 4 | outcome_level | Outcome Level | Select | Immediate\nIntermediate\nFinal Impact | Yes | Position in the results chain |
| 5 | target_group | Target Group | Data | | No | Who benefits from this outcome |
| 6 | parent_outcome | Parent Outcome | Link | Outcome | No | For nested outcome hierarchies |
| 7 | description | Description | Long Text | | No | More detail on what change is expected |
| 8 | period_start | Period Start | Date | | No | |
| 9 | period_end | Period End | Date | | No | |
| 10 | owner | Owner | Link | User | No | |
| 11 | is_active | Is Active | Check | | Yes | Default 1 |
| 12 | notes | Notes | Small Text | | No | |

**Business Rules:**
1. Outcome must belong to an Active Impact Framework.
2. If parent_outcome is set, the parent must belong to the same Impact Framework.
3. An Outcome linked to published Indicator Achievement records cannot be deleted.

---

## DocType: Indicator

**Module:** Fundara > Impact & Learning
**Parent (if child table):** —
**Is Submittable:** No
**Has Workflow:** No
**Naming Series:** IND-.#####

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | naming_series | Naming Series | Select | IND-.##### | Yes | |
| 2 | indicator_name | Indicator Name | Data | | Yes | Clear, measurable statement |
| 3 | indicator_code | Indicator Code | Data | | No | Short code for reference, e.g. "EDU-01" |
| 4 | impact_framework | Impact Framework | Link | Impact Framework | Yes | |
| 5 | outcome | Outcome | Link | Outcome | No | If indicator measures a specific outcome |
| 6 | indicator_type | Indicator Type | Select | Output\nOutcome\nImpact\nProcess\nFinancial Efficiency | Yes | |
| 7 | unit_of_measure | Unit of Measure | Data | | Yes | e.g. "Number of people", "Percentage", "Schools" |
| 8 | baseline_value | Baseline Value | Float | | No | Starting point before intervention |
| 9 | baseline_date | Baseline Date | Date | | No | |
| 10 | baseline_source | Baseline Source | Small Text | | No | How baseline was established |
| 11 | collection_frequency | Collection Frequency | Select | Monthly\nQuarterly\nSemi-Annual\nAnnual\nCustom\nPer Activity | Yes | |
| 12 | data_source | Data Source | Small Text | | Yes | Where data comes from |
| 13 | data_collection_method | Data Collection Method | Small Text | | No | Survey, register, administrative records, etc. |
| 14 | disaggregation_required | Disaggregation Required | Check | | No | If checked, achievement must include disaggregation |
| 15 | disaggregation_categories | Disaggregation Categories | Small Text | | No | e.g. "Gender, Age Group, Location" |
| 16 | responsible_person | Responsible Person | Link | User | No | |
| 17 | is_active | Is Active | Check | | Yes | Default 1 |
| 18 | notes | Notes | Small Text | | No | |

**Business Rules:**
1. unit_of_measure is mandatory; without it achievement values are meaningless.
2. An Indicator must belong to an Active Impact Framework.
3. If disaggregation_required = 1, the Indicator Achievement must include disaggregation data before verification.
4. Indicator Targets (in the Indicator Target DocType) are separate from Indicator Achievements.

---

## DocType: Indicator Target

**Module:** Fundara > Impact & Learning
**Parent (if child table):** —
**Is Submittable:** No
**Has Workflow:** No
**Naming Series:** INT-.YYYY.-.#####

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | naming_series | Naming Series | Select | INT-.YYYY.-.##### | Yes | |
| 2 | indicator | Indicator | Link | Indicator | Yes | |
| 3 | project | Project | Link | Project | No | |
| 4 | programme | Programme | Link | Programme | No | |
| 5 | reporting_period | Reporting Period | Link | Reporting Period | No | |
| 6 | period_label | Period Label | Data | | No | e.g. "Q1 2025", "Year 1" |
| 7 | period_start | Period Start | Date | | Yes | |
| 8 | period_end | Period End | Date | | Yes | |
| 9 | target_value | Target Value | Float | | Yes | |
| 10 | target_notes | Target Notes | Small Text | | No | |
| 11 | set_by | Set By | Link | User | No | |
| 12 | set_date | Set Date | Date | | No | |

**Business Rules:**
1. One Indicator Target per Indicator per period; duplicates should be prevented by validation.
2. period_end must be on or after period_start.
3. Target value must be > 0.
4. Target may be set at programme or project level; if both exist, project-level takes precedence for project reporting.

---

## DocType: Indicator Achievement

**Module:** Fundara > Impact & Learning
**Parent (if child table):** —
**Is Submittable:** Yes
**Has Workflow:** Yes
**Naming Series:** ACH-.YYYY.-.#####

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | naming_series | Naming Series | Select | ACH-.YYYY.-.##### | Yes | |
| 2 | indicator | Indicator | Link | Indicator | Yes | |
| 3 | project | Project | Link | Project | No | Required if indicator scope = Project |
| 4 | activity | Activity | Link | Activity | No | Required if collection_frequency = Per Activity |
| 5 | reporting_period | Reporting Period | Link | Reporting Period | No | |
| 6 | period_label | Period Label | Data | | No | e.g. "Q1 2025" |
| 7 | period_start | Period Start | Date | | Yes | |
| 8 | period_end | Period End | Date | | Yes | |
| 9 | actual_value | Actual Value | Float | | Yes | |
| 10 | target_value | Target (for reference) | Float | | No | Pulled from Indicator Target; read-only |
| 11 | achievement_percent | Achievement % | Percent | | No | Computed: (actual / target) × 100 |
| 12 | disaggregation | Disaggregation Data | Table | Achievement Disaggregation | No | Required if indicator.disaggregation_required = 1 |
| 13 | evidence | Evidence | Link | Evidence | No | Supporting evidence record |
| 14 | additional_evidence | Additional Evidence | Table | Achievement Evidence Link | No | Multiple evidence links |
| 15 | submitted_by | Submitted By | Link | User | Yes | Auto-set |
| 16 | submitted_date | Submitted Date | Date | | Yes | |
| 17 | verification_status | Verification Status | Select | Pending\nVerified\nRejected | No | |
| 18 | verified_by | Verified By | Link | User | No | MEAL officer |
| 19 | verification_date | Verification Date | Date | | No | |
| 20 | verification_notes | Verification Notes | Small Text | | No | |
| 21 | rejection_reason | Rejection Reason | Small Text | | No | Required if verification_status = Rejected |
| 22 | include_in_report | Include in Report | Check | | No | Only verified achievements should be flagged |
| 23 | narrative | Narrative / Qualitative Notes | Long Text | | No | Qualitative context for the achievement |

**Business Rules:**
1. Indicator Achievement must be linked to either a Project or an Activity.
2. If indicator.disaggregation_required = 1, disaggregation table must have at least one row before submission.
3. achievement_percent = (actual_value / target_value) × 100; computed on save if target_value > 0.
4. Only Verified achievements may be included in donor reports and impact reports (include_in_report = 1 requires verification_status = Verified).
5. A Verified achievement record is immutable; corrections require creating a new achievement record for the same period and marking the old one as superseded.

---

## DocType: Achievement Disaggregation

**Module:** Fundara > Impact & Learning
**Parent (if child table):** Indicator Achievement
**Is Submittable:** No
**Has Workflow:** No
**Naming Series:** —

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | category | Disaggregation Category | Data | | Yes | e.g. "Gender", "Age Group" |
| 2 | sub_category | Sub-Category | Data | | Yes | e.g. "Female", "Under 18" |
| 3 | value | Value | Float | | Yes | Count or measure for this sub-group |
| 4 | notes | Notes | Small Text | | No | |

**Business Rules:**
1. Sum of sub-category values should equal or not exceed the parent Indicator Achievement actual_value (system warns if mismatch).
2. Only collect disaggregation categories that are strictly necessary and safe for the target population (privacy by design).

---

## DocType: Achievement Evidence Link

**Module:** Fundara > Impact & Learning
**Parent (if child table):** Indicator Achievement
**Is Submittable:** No
**Has Workflow:** No
**Naming Series:** —

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | evidence | Evidence | Link | Evidence | Yes | |
| 2 | evidence_type | Evidence Type | Link | Evidence Type | No | Auto-filled from Evidence record |
| 3 | description | Description | Small Text | | No | |

---

## DocType: Activity Output

**Module:** Fundara > Impact & Learning
**Parent (if child table):** —
**Is Submittable:** Yes
**Has Workflow:** No
**Naming Series:** OPT-.YYYY.-.#####

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | naming_series | Naming Series | Select | OPT-.YYYY.-.##### | Yes | |
| 2 | output_name | Output Name | Data | | Yes | e.g. "100 teachers trained on child-centred learning" |
| 3 | activity | Activity | Link | Activity | Yes | |
| 4 | project | Project | Link | Project | Yes | Auto-filled from Activity |
| 5 | output_type | Output Type | Select | Training\nDistribution\nAdvocacy\nResearch\nService Delivery\nInfrastructure\nCapacity Building\nOther | Yes | |
| 6 | indicator | Linked Indicator | Link | Indicator | No | Optional link to a formal indicator |
| 7 | unit | Unit | Data | | Yes | e.g. "Persons", "Kits", "Villages" |
| 8 | target_qty | Target Quantity | Float | | Yes | |
| 9 | actual_qty | Actual Quantity | Float | | No | Recorded on completion |
| 10 | beneficiary_group | Beneficiary Group | Link | Beneficiary Group | No | |
| 11 | completion_date | Completion Date | Date | | No | |
| 12 | evidence | Evidence | Link | Evidence | No | Primary supporting evidence |
| 13 | cost_charged | Cost Charged to Activity | Currency | | No | Pulled from Financial Accountability context |
| 14 | output_currency | Currency | Link | Currency | No | |
| 15 | cost_per_output | Cost Per Output | Currency | | No | Computed: cost_charged / actual_qty |
| 16 | cpo_currency | CPO Currency | Link | Currency | No | |
| 17 | narrative | Narrative Notes | Small Text | | No | |
| 18 | verification_status | Verification Status | Select | Pending\nVerified\nRejected | No | |
| 19 | verified_by | Verified By | Link | User | No | |

**Business Rules:**
1. actual_qty must be entered before the Output can be verified.
2. cost_per_output = cost_charged / actual_qty; computed when both values are present and actual_qty > 0.
3. Linked Indicator Achievement may reference this Output as supporting context.
4. Target and actual quantities must use the same unit.

---

## DocType: Beneficiary Group

**Module:** Fundara > Impact & Learning
**Parent (if child table):** —
**Is Submittable:** No
**Has Workflow:** No
**Naming Series:** —

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | group_name | Group Name | Data | | Yes | e.g. "Women-headed Households", "Primary School Teachers" |
| 2 | description | Description | Small Text | | No | |
| 3 | demographic_profile | Demographic Profile | Small Text | | No | Age range, gender, geography, etc. |
| 4 | location | Location / Coverage Area | Data | | No | |
| 5 | estimated_size | Estimated Group Size | Int | | No | Total eligible population in this group |
| 6 | is_active | Is Active | Check | | Yes | Default 1 |
| 7 | notes | Notes | Small Text | | No | |

**Business Rules:**
1. Beneficiary Group records are reference data shared across projects and activities.
2. No personal identifying information should be stored at this level; this is an aggregate/group record only.

---

## DocType: Feedback / Complaint

**Module:** Fundara > Impact & Learning
**Parent (if child table):** —
**Is Submittable:** Yes
**Has Workflow:** Yes
**Naming Series:** FBK-.YYYY.-.#####

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | naming_series | Naming Series | Select | FBK-.YYYY.-.##### | Yes | |
| 2 | feedback_date | Feedback Date | Date | | Yes | Date received |
| 3 | source_type | Source Type | Select | Beneficiary\nCommunity Member\nDonor\nPartner\nStaff\nAnonymous | Yes | |
| 4 | source_name | Source Name | Data | | No | Leave blank if anonymous; handle with care |
| 5 | project | Project | Link | Project | No | |
| 6 | activity | Activity | Link | Activity | No | |
| 7 | category | Category | Select | Programme Quality\nSafeguarding\nFinancial Concern\nStaff Conduct\nLogistics\nComplaint\nSuggestion\nAppreciation\nOther | Yes | |
| 8 | severity | Severity | Select | Low\nMedium\nHigh\nCritical | Yes | Critical triggers escalation |
| 9 | description | Description | Long Text | | Yes | Full description of the feedback or complaint |
| 10 | received_by | Received By | Link | User | Yes | |
| 11 | assigned_to | Assigned To | Link | User | No | Responsible for response |
| 12 | response_status | Response Status | Select | Open\nIn Progress\nResolved\nClosed\nEscalated | No | |
| 13 | resolution | Resolution / Response | Long Text | | No | Required before closing |
| 14 | resolution_date | Resolution Date | Date | | No | |
| 15 | escalated_to | Escalated To | Link | User | No | Required if response_status = Escalated |
| 16 | escalation_date | Escalation Date | Date | | No | |
| 17 | learning_captured | Learning Captured | Check | | No | If checked, a Learning Note should be linked |
| 18 | learning_note | Learning Note | Link | Learning Note | No | |
| 19 | confidential | Confidential | Check | | No | Restricts visibility |
| 20 | attachments | Attachments | Attach | | No | |

**Business Rules:**
1. Severity = Critical must trigger an automatic escalation alert to the designated safeguarding or management role.
2. resolution is mandatory before response_status can be set to Resolved or Closed.
3. Safeguarding-category complaints must follow the organisational safeguarding policy and may require external reporting; confidential = 1 by default for Safeguarding category.
4. Source_name handling must comply with privacy policy; anonymous feedback must not be traceable to individuals.
5. A Closed Feedback record cannot be reopened without creating a new record.

---

## DocType: Learning Note

**Module:** Fundara > Impact & Learning
**Parent (if child table):** —
**Is Submittable:** No
**Has Workflow:** No
**Naming Series:** LRN-.YYYY.-.#####

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | naming_series | Naming Series | Select | LRN-.YYYY.-.##### | Yes | |
| 2 | title | Learning Note Title | Data | | Yes | |
| 3 | project | Project | Link | Project | No | |
| 4 | activity | Activity | Link | Activity | No | |
| 5 | learning_date | Learning Date | Date | | Yes | When this learning was documented |
| 6 | documented_by | Documented By | Link | User | Yes | |
| 7 | what_worked | What Worked | Long Text | | No | Positive findings |
| 8 | what_did_not_work | What Did Not Work | Long Text | | No | Challenges and failures |
| 9 | root_cause | Root Cause Analysis | Small Text | | No | |
| 10 | recommendation | Recommendation | Long Text | | No | Suggested changes for future implementation |
| 11 | tags | Tags | Small Text | | No | Comma-separated thematic tags |
| 12 | shared_with | Shared With | Small Text | | No | Audience / teams this has been shared with |
| 13 | apply_to_future | Apply to Future Planning | Check | | No | Flag for workplan review |
| 14 | linked_feedback | Linked Feedback | Link | Feedback / Complaint | No | If this arose from a feedback case |
| 15 | status | Status | Select | Draft\nFinalised\nArchived | No | |
| 16 | attachments | Attachments | Attach | | No | Workshop notes, report |

**Business Rules:**
1. At least one of what_worked, what_did_not_work, or recommendation must be filled before the note can be finalised.
2. An Archived Learning Note is read-only.
3. Learning Notes tagged for future planning (apply_to_future = 1) should surface in workplan review processes.
4. Learning Notes linked to Safeguarding Feedback must inherit the confidentiality handling of the parent Feedback record.

---

## DocType: Beneficiary Profile — (Post-MVP)

**Module:** Fundara > Impact & Learning
**Parent (if child table):** —
**Is Submittable:** No
**Has Workflow:** No
**Naming Series:** BNF-.YYYY.-.#####

> Post-MVP: Individual beneficiary records. Only implement when there is a clear programmatic need, explicit consent framework, and data minimisation policy in place.

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | naming_series | Naming Series | Select | BNF-.YYYY.-.##### | Yes | |
| 2 | beneficiary_code | Beneficiary Code | Data | | Yes | System-generated or field ID; no full name required |
| 3 | beneficiary_group | Beneficiary Group | Link | Beneficiary Group | Yes | |
| 4 | gender | Gender | Select | Female\nMale\nNon-binary\nPrefer not to say | No | |
| 5 | age_group | Age Group | Select | Under 5\n5–17\n18–35\n36–59\n60 and above | No | |
| 6 | location | Location | Data | | No | Village, district level only — not full address |
| 7 | consent_status | Consent Status | Select | Consented\nNot Consented\nWithdrawn | Yes | |
| 8 | consent_date | Consent Date | Date | | No | |
| 9 | services_received | Services Received | Small Text | | No | Summary only |
| 10 | privacy_level | Privacy Level | Select | Standard\nHighly Sensitive | Yes | Highly Sensitive restricts access further |
| 11 | project | Project | Link | Project | No | |
| 12 | notes | Notes | Small Text | | No | |

**Business Rules:**
1. No full name, national ID, or contact information should be stored in this DocType without explicit legal and ethical justification.
2. consent_status = Not Consented or Withdrawn prevents data use in reports.
3. privacy_level = Highly Sensitive restricts read access to authorised caseworkers only.
4. Data minimisation: only collect fields that are strictly necessary for programme delivery and reporting.

---

## DocType: Disaggregation Category — (Post-MVP)

**Module:** Fundara > Impact & Learning
**Parent (if child table):** —
**Is Submittable:** No
**Has Workflow:** No
**Naming Series:** —

> Post-MVP: Formalises disaggregation taxonomies for consistent cross-project reporting.

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | category_name | Category Name | Data | | Yes | e.g. "Gender" |
| 2 | sub_categories | Sub-Categories | Table | Disaggregation Sub-Category | Yes | e.g. "Female", "Male", "Non-binary" |
| 3 | is_active | Is Active | Check | | Yes | |
| 4 | notes | Notes | Small Text | | No | |

---

## DocType: Disaggregation Sub-Category — (Post-MVP)

**Module:** Fundara > Impact & Learning
**Parent (if child table):** Disaggregation Category
**Is Submittable:** No
**Has Workflow:** No
**Naming Series:** —

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | sub_category_name | Sub-Category Name | Data | | Yes | |
| 2 | description | Description | Small Text | | No | |
