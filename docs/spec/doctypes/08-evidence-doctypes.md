# Evidence & Compliance — DocType Field Specifications

**Module:** Fundara > Evidence & Compliance

---

## DocType: Evidence Type

**Module:** Fundara > Evidence & Compliance
**Parent (if child table):** —
**Is Submittable:** No
**Has Workflow:** No
**Naming Series:** —

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | evidence_type_name | Evidence Type Name | Data | | Yes | e.g. "Invoice", "Attendance List", "Photo Documentation" |
| 2 | description | Description | Small Text | | No | |
| 3 | allowed_file_types | Allowed File Types | Small Text | | No | Comma-separated extensions, e.g. "pdf,jpg,png" |
| 4 | default_retention_years | Default Retention Period (Years) | Int | | No | |
| 5 | sensitive_data | Contains Sensitive/Personal Data | Check | | No | If checked, restricts visibility by role |
| 6 | required_metadata | Required Metadata Notes | Small Text | | No | Describes what metadata must accompany upload |
| 7 | is_active | Is Active | Check | | Yes | Default 1 |

**Business Rules:**
1. Evidence Type records are reference data; changes affect all linked Evidence Requirement rules.
2. If sensitive_data = 1, access to Evidence records of this type must be restricted to authorised roles only.
3. Deactivating an Evidence Type does not delete historical Evidence records linked to it.

---

## DocType: Evidence Requirement

**Module:** Fundara > Evidence & Compliance
**Parent (if child table):** —
**Is Submittable:** No
**Has Workflow:** No
**Naming Series:** EVR-.#####

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | naming_series | Naming Series | Select | EVR-.##### | Yes | |
| 2 | requirement_name | Requirement Name | Data | | Yes | Short name for this rule |
| 3 | applies_to_document_type | Applies to Document Type | Select | Purchase Request\nPurchase Order (Fundara)\nGoods Receipt / Service Acceptance Note\nActivity\nExpense Claim\nCash Advance\nJournal Entry\nOther | Yes | |
| 4 | applies_to_fund_type | Applies to Fund Type | Select | \nRestricted\nUnrestricted\nEndowment\nCampaign | No | Leave blank for all fund types |
| 5 | applies_to_fund | Applies to Fund | Link | Fund | No | Leave blank for all funds |
| 6 | applies_to_activity_type | Applies to Activity Type | Data | | No | e.g. "Training", "Distribution" |
| 7 | amount_threshold | Amount Threshold | Currency | | No | Rule triggers when transaction amount >= this value |
| 8 | threshold_currency | Threshold Currency | Link | Currency | No | |
| 9 | required_evidence_type | Required Evidence Type | Link | Evidence Type | Yes | |
| 10 | is_mandatory | Is Mandatory | Check | | Yes | If mandatory, missing evidence can block approval |
| 11 | blocking_severity | Blocking Severity | Select | Info\nWarning\nBlocking\nException Allowed | Yes | Controls system behaviour when evidence is missing |
| 12 | description | Rule Description | Small Text | | No | |
| 13 | is_active | Is Active | Check | | Yes | Default 1 |

**Business Rules:**
1. Rules are evaluated at document submission time; the system collects all matching active rules for the document type, fund type, activity type, and amount.
2. A Blocking severity rule will prevent document approval until the required evidence is uploaded and verified.
3. An Exception Allowed severity will block but provide the option to create a Compliance Exception.
4. Multiple rules may apply to a single document; all mandatory rules must be satisfied.

---

## DocType: Evidence

**Module:** Fundara > Evidence & Compliance
**Parent (if child table):** —
**Is Submittable:** No
**Has Workflow:** Yes
**Naming Series:** EVD-.YYYY.-.#####

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | naming_series | Naming Series | Select | EVD-.YYYY.-.##### | Yes | |
| 2 | evidence_type | Evidence Type | Link | Evidence Type | Yes | |
| 3 | linked_document_type | Linked Document Type | Select | Purchase Request\nPurchase Order (Fundara)\nGoods Receipt / Service Acceptance Note\nActivity\nExpense Claim\nCash Advance\nJournal Entry\nReport\nOther | Yes | The DocType of the parent document |
| 4 | linked_document | Linked Document | Dynamic Link | linked_document_type | Yes | FK to the actual document |
| 5 | title | Evidence Title | Data | | Yes | Descriptive title |
| 6 | description | Description | Small Text | | No | |
| 7 | file_attachment | File Attachment | Attach | | Yes | The evidence file |
| 8 | uploaded_by | Uploaded By | Link | User | Yes | Auto-set to current user |
| 9 | upload_date | Upload Date | Date | | Yes | Auto-set to today |
| 10 | document_date | Document Date | Date | | No | Date shown on the evidence document itself |
| 11 | verification_status | Verification Status | Select | Pending\nVerified\nRejected | No | Default Pending |
| 12 | verified_by | Verified By | Link | User | No | |
| 13 | verification_date | Verification Date | Date | | No | |
| 14 | rejection_reason | Rejection Reason | Small Text | | No | Required if verification_status = Rejected |
| 15 | confidentiality_level | Confidentiality Level | Select | Public\nInternal\nConfidential\nRestricted | No | Default Internal |
| 16 | retention_years | Retention Period (Years) | Int | | No | Defaults from Evidence Type; can be overridden |
| 17 | retention_due_date | Retention Due Date | Date | | No | Computed: upload_date + retention_years |
| 18 | included_in_audit_pack | Included in Audit Pack | Check | | No | Set when added to an Audit Pack |
| 19 | audit_pack | Audit Pack Reference | Link | Audit Pack | No | |
| 20 | notes | Internal Notes | Small Text | | No | |

**Business Rules:**
1. A Verified evidence record cannot be deleted; deletion must go through an audit-trailed void process.
2. If the Evidence Type has sensitive_data = 1, visibility is restricted to users with the Evidence - Sensitive role.
3. An evidence record included in an Audit Pack (included_in_audit_pack = 1) cannot be deleted without breaking the audit pack — system must block deletion and require exception.
4. rejection_reason is mandatory when verification_status is set to Rejected.
5. retention_due_date = upload_date + retention_years; system should alert before expiry.
6. One document may have multiple Evidence records of different types.

---

## DocType: Compliance Rule

**Module:** Fundara > Evidence & Compliance
**Parent (if child table):** —
**Is Submittable:** No
**Has Workflow:** No
**Naming Series:** CRL-.#####

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | naming_series | Naming Series | Select | CRL-.##### | Yes | |
| 2 | rule_name | Rule Name | Data | | Yes | |
| 3 | rule_type | Rule Type | Select | Fund Eligibility\nDonor Procurement Rule\nCampaign Restriction\nBudget Variance\nDocument Completeness\nApproval Threshold\nPeriod Eligibility\nVendor Eligibility\nOther | Yes | |
| 4 | description | Description | Long Text | | No | Full description of the rule and its rationale |
| 5 | applies_to | Applies To | Select | Fund\nDonor\nCampaign\nOrganisation | Yes | Scope of the rule |
| 6 | fund | Fund | Link | Fund | No | If applies_to = Fund |
| 7 | donor | Donor | Link | Donor | No | If applies_to = Donor |
| 8 | campaign | Campaign | Link | Campaign | No | If applies_to = Campaign |
| 9 | condition_expression | Condition | Small Text | | No | Human-readable condition description |
| 10 | action | Action When Triggered | Small Text | | No | Human-readable action description |
| 11 | severity | Severity | Select | Info\nWarning\nBlocking\nException Allowed | Yes | |
| 12 | check_trigger | Check Trigger | Select | On Submission\nOn Approval\nManual\nScheduled | Yes | When the rule is evaluated |
| 13 | is_active | Is Active | Check | | Yes | Default 1 |
| 14 | reference_document | Reference Document | Data | | No | External policy reference, e.g. donor guideline section |
| 15 | notes | Notes | Small Text | | No | |

**Business Rules:**
1. Compliance Rules are configurable per fund, donor, campaign, or organisation; they must not be hardcoded.
2. Active rules with severity Blocking prevent document approval until the condition is resolved.
3. Active rules with severity Exception Allowed allow proceeding via a Compliance Exception.
4. Deactivating a rule does not retroactively clear past Compliance Check failures.

---

## DocType: Compliance Check

**Module:** Fundara > Evidence & Compliance
**Parent (if child table):** —
**Is Submittable:** No
**Has Workflow:** No
**Naming Series:** CCK-.YYYY.-.#####

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | naming_series | Naming Series | Select | CCK-.YYYY.-.##### | Yes | |
| 2 | linked_document_type | Linked Document Type | Select | Purchase Request\nPurchase Order (Fundara)\nGoods Receipt / Service Acceptance Note\nActivity\nExpense Claim\nCash Advance\nJournal Entry\nOther | Yes | |
| 3 | linked_document | Linked Document | Dynamic Link | linked_document_type | Yes | |
| 4 | compliance_rule | Compliance Rule | Link | Compliance Rule | Yes | |
| 5 | check_result | Check Result | Select | Passed\nWarning\nFailed\nException Approved | Yes | |
| 6 | checked_by | Checked By | Link | User | Yes | Auto-set to current user or system |
| 7 | checked_at | Checked At | Datetime | | Yes | Auto-set |
| 8 | notes | Notes / Details | Small Text | | No | Explanation of the result |
| 9 | exception_reference | Exception Reference | Link | Compliance Exception | No | Set if check_result = Exception Approved |

**Business Rules:**
1. Compliance Check records are created automatically when a rule is evaluated; they should not be manually created or edited.
2. A single document may have multiple Compliance Check records (one per rule).
3. All Compliance Check records for a document must show Passed or Exception Approved before final approval proceeds.
4. Compliance Checks are immutable after creation; a new check is created on re-evaluation.

---

## DocType: Compliance Exception

**Module:** Fundara > Evidence & Compliance
**Parent (if child table):** —
**Is Submittable:** Yes
**Has Workflow:** Yes
**Naming Series:** EXC-.YYYY.-.#####

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | naming_series | Naming Series | Select | EXC-.YYYY.-.##### | Yes | |
| 2 | linked_document_type | Linked Document Type | Select | Purchase Request\nPurchase Order (Fundara)\nGoods Receipt / Service Acceptance Note\nActivity\nExpense Claim\nCash Advance\nJournal Entry\nOther | Yes | |
| 3 | linked_document | Linked Document | Dynamic Link | linked_document_type | Yes | |
| 4 | failed_compliance_rule | Failed Compliance Rule | Link | Compliance Rule | Yes | |
| 5 | compliance_check | Compliance Check | Link | Compliance Check | No | The check that failed |
| 6 | justification | Justification | Long Text | | Yes | Explanation of why the exception should be granted |
| 7 | requested_by | Requested By | Link | User | Yes | Auto-set to current user |
| 8 | request_date | Request Date | Date | | Yes | Auto-set to today |
| 9 | supporting_document | Supporting Memo / Document | Attach | | No | Approval memo or relevant supporting file |
| 10 | risk_level | Risk Level | Select | Low\nMedium\nHigh | Yes | Assessed risk of granting the exception |
| 11 | status | Status | Select | Draft\nSubmitted\nApproved\nRejected | No | |
| 12 | approved_by | Approved By | Link | User | No | |
| 13 | approval_date | Approval Date | Date | | No | |
| 14 | rejection_reason | Rejection Reason | Small Text | | No | Required if status = Rejected |
| 15 | conditions | Conditions / Mitigations | Small Text | | No | Any conditions attached to the approved exception |
| 16 | expiry_date | Exception Expiry Date | Date | | No | If the exception is time-limited |

**Business Rules:**
1. Only Compliance Rules with severity = Exception Allowed may have an exception submitted.
2. A Blocking severity rule requires the rule itself to be resolved; an exception cannot override it.
3. Exception must have justification and be approved by an authorised role (defined by Delegation of Authority).
4. High risk_level exceptions require additional approval level.
5. Approved exception automatically updates the linked Compliance Check to Exception Approved.
6. Exception records are permanent and cannot be deleted.

---

## DocType: Supporting Document Register

**Module:** Fundara > Evidence & Compliance
**Parent (if child table):** —
**Is Submittable:** No
**Has Workflow:** No
**Naming Series:** SDR-.YYYY.-.#####

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | naming_series | Naming Series | Select | SDR-.YYYY.-.##### | Yes | |
| 2 | register_title | Register Title | Data | | Yes | e.g. "Donor Report Q2 2025 – Supporting Documents" |
| 3 | report | Report | Link | Report | No | Linked report if generated from Reporting context |
| 4 | fund | Fund | Link | Fund | No | Scope |
| 5 | project | Project | Link | Project | No | |
| 6 | period_start | Period Start | Date | | Yes | |
| 7 | period_end | Period End | Date | | Yes | |
| 8 | generated_by | Generated By | Link | User | Yes | |
| 9 | generated_date | Generated Date | Date | | Yes | |
| 10 | document_lines | Document Lines | Table | Supporting Document Line | Yes | One row per transaction/evidence pair |
| 11 | total_transactions | Total Transactions | Int | | No | Computed |
| 12 | complete_count | Complete | Int | | No | Computed |
| 13 | missing_count | Missing | Int | | No | Computed |
| 14 | status | Register Status | Select | Draft\nReviewed\nFinalised | No | |
| 15 | reviewed_by | Reviewed By | Link | User | No | |
| 16 | review_date | Review Date | Date | | No | |
| 17 | notes | Notes | Small Text | | No | |

**Business Rules:**
1. The document lines are populated by a server script that collects transactions within the period and checks Evidence completeness against Evidence Requirements.
2. A Finalised register must not be modified; create a new revision instead.
3. missing_count > 0 should trigger a warning before the linked report is submitted.

---

## DocType: Supporting Document Line

**Module:** Fundara > Evidence & Compliance
**Parent (if child table):** Supporting Document Register
**Is Submittable:** No
**Has Workflow:** No
**Naming Series:** —

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | transaction_type | Transaction Type | Data | | Yes | DocType of the transaction |
| 2 | transaction_reference | Transaction Reference | Data | | Yes | Name/ID of the transaction |
| 3 | transaction_date | Transaction Date | Date | | No | |
| 4 | transaction_amount | Transaction Amount | Currency | | No | |
| 5 | txn_currency | Currency | Link | Currency | No | |
| 6 | required_evidence_type | Required Evidence Type | Link | Evidence Type | Yes | |
| 7 | evidence_reference | Evidence Reference | Link | Evidence | No | Linked Evidence record if uploaded |
| 8 | evidence_status | Evidence Status | Select | Complete\nMissing\nRejected\nPending Verification | Yes | |
| 9 | is_missing | Is Missing | Check | | No | Quick filter flag |
| 10 | remarks | Remarks | Small Text | | No | |

---

## DocType: Audit Pack

**Module:** Fundara > Evidence & Compliance
**Parent (if child table):** —
**Is Submittable:** No
**Has Workflow:** Yes
**Naming Series:** AUD-.YYYY.-.#####

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | naming_series | Naming Series | Select | AUD-.YYYY.-.##### | Yes | |
| 2 | pack_title | Pack Title | Data | | Yes | e.g. "Annual Audit Pack FY2025 – Fund XYZ" |
| 3 | fund | Fund | Link | Fund | No | |
| 4 | project | Project | Link | Project | No | |
| 5 | period_start | Period Start | Date | | Yes | |
| 6 | period_end | Period End | Date | | Yes | |
| 7 | generated_by | Generated By | Link | User | Yes | |
| 8 | generated_date | Generated Date | Date | | Yes | |
| 9 | supporting_document_register | Supporting Document Register | Link | Supporting Document Register | No | |
| 10 | included_transactions | Included Transactions | Table | Audit Pack Transaction | No | |
| 11 | included_evidence | Included Evidence | Table | Audit Pack Evidence | No | |
| 12 | missing_documents_summary | Missing Documents Summary | Small Text | | No | |
| 13 | status | Status | Select | Draft\nReviewed\nApproved\nArchived | No | |
| 14 | reviewed_by | Reviewed By | Link | User | No | |
| 15 | review_date | Review Date | Date | | No | |
| 16 | approved_by | Approved By | Link | User | No | |
| 17 | approval_date | Approval Date | Date | | No | |
| 18 | archive_location | Archive Location | Data | | No | Physical or digital archive reference |
| 19 | notes | Notes | Small Text | | No | |

**Business Rules:**
1. Evidence records added to an Audit Pack cannot be deleted (system enforces this via the included_in_audit_pack flag on Evidence).
2. A pack in Archived status is read-only.
3. Missing documents must be resolved or noted before the pack is approved.
4. Only one Approved Audit Pack per fund/project/period combination.

---

## DocType: Audit Pack Transaction

**Module:** Fundara > Evidence & Compliance
**Parent (if child table):** Audit Pack
**Is Submittable:** No
**Has Workflow:** No
**Naming Series:** —

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | transaction_type | Transaction Type | Data | | Yes | |
| 2 | transaction_reference | Transaction Reference | Data | | Yes | |
| 3 | transaction_date | Transaction Date | Date | | No | |
| 4 | amount | Amount | Currency | | No | |
| 5 | txn_currency | Currency | Link | Currency | No | |
| 6 | evidence_complete | Evidence Complete | Check | | No | |
| 7 | remarks | Remarks | Small Text | | No | |

---

## DocType: Audit Pack Evidence

**Module:** Fundara > Evidence & Compliance
**Parent (if child table):** Audit Pack
**Is Submittable:** No
**Has Workflow:** No
**Naming Series:** —

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | evidence | Evidence | Link | Evidence | Yes | |
| 2 | evidence_type | Evidence Type | Link | Evidence Type | No | Auto-filled |
| 3 | verification_status | Verification Status | Data | | No | Pulled from Evidence record |
| 4 | remarks | Remarks | Small Text | | No | |

---

## DocType: Document Retention Rule — (Post-MVP)

**Module:** Fundara > Evidence & Compliance
**Parent (if child table):** —
**Is Submittable:** No
**Has Workflow:** No
**Naming Series:** —

> Post-MVP: Advanced retention policy management per donor, fund, or legal regulation.

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | rule_name | Rule Name | Data | | Yes | |
| 2 | applies_to | Applies To | Select | Evidence Type\nFund\nDonor | Yes | |
| 3 | evidence_type | Evidence Type | Link | Evidence Type | No | If applies_to = Evidence Type |
| 4 | fund | Fund | Link | Fund | No | If applies_to = Fund |
| 5 | donor | Donor | Link | Donor | No | If applies_to = Donor |
| 6 | retention_years | Retention Period (Years) | Int | | Yes | |
| 7 | legal_basis | Legal Basis | Small Text | | No | Reference to law or donor requirement |
| 8 | is_active | Is Active | Check | | Yes | |
