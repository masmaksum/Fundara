# Organization Context — DocType Specifications

**Module:** Fundara > Organization
**Context File:** fundara-domain-contexts/01-organization-context.md
**Last Updated:** 2026-06-18

---

## Table of Contents

1. [Organization](#1-organization) — MVP
2. [Office](#2-office) — MVP
3. [Department](#3-department) — MVP
4. [Cost Center (Extension)](#4-cost-center-extension) — MVP
5. [Delegation of Authority](#5-delegation-of-authority) — MVP
6. [Delegation of Authority Item](#6-delegation-of-authority-item) — MVP (child)
7. [Organization Contact Item](#7-organization-contact-item) — MVP (child)
8. [Approval Matrix](#8-approval-matrix) — Post-MVP
9. [Office Permission Rule](#9-office-permission-rule) — Post-MVP

> **Note on ERPNext built-ins:** ERPNext v16 already ships `User`, `Role`, `Department`, `Cost Center`, and `Branch` DocTypes. Where a built-in covers the need, Fundara extends it via `Custom Field` rather than creating a new DocType. The "Extension" label below indicates this pattern.

---

## 1. Organization

**Module:** Fundara > Organization
**Parent (if child table):** —
**Is Submittable:** No
**Has Workflow:** No
**Naming Series:** ORG-.YYYY.-.####

Represents the primary entity using Fundara — an NGO, foundation, social enterprise, or mission-driven organization. Maps conceptually to ERPNext's `Company`, but carries NGO-specific identity fields. This is a separate DocType rather than extending Company to keep mission-context data clean from accounting config.

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | naming_series | Series | Select | ORG-.YYYY.-.#### | Yes | |
| 2 | organization_name | Organization Name | Data | | Yes | Public/operating name |
| 3 | legal_name | Legal Name | Data | | No | As registered with authorities |
| 4 | organization_type | Organization Type | Select | NGO\nYayasan\nKomunitas\nSocial Enterprise\nLembaga Filantropi\nFaith-based Organization\nKoperasi Sosial\nProgram CSR | Yes | |
| 5 | registration_number | Registration Number | Data | | No | Legal registration / akta number |
| 6 | legal_status | Legal Status | Data | | No | e.g., Badan Hukum, Berbadan Hukum Yayasan |
| 7 | sb1 | — | Section Break | | No | Location & Currency |
| 8 | country | Country | Link | Country | Yes | |
| 9 | base_currency | Base Currency | Link | Currency | Yes | Default currency for financial reporting |
| 10 | default_language | Default Language | Data | | No | e.g., id, en |
| 11 | fiscal_year_start_month | Fiscal Year Start Month | Select | January\nFebruary\nMarch\nApril\nMay\nJune\nJuly\nAugust\nSeptember\nOctober\nNovember\nDecember | Yes | |
| 12 | sb2 | — | Section Break | | No | Contact & Online |
| 13 | website | Website | Data | | No | |
| 14 | email | Email | Data | | No | Primary contact email |
| 15 | phone | Phone | Data | | No | |
| 16 | address | Address | Small Text | | No | |
| 17 | sb3 | — | Section Break | | No | Mission & Identity |
| 18 | mission_statement | Mission Statement | Long Text | | No | |
| 19 | vision_statement | Vision Statement | Long Text | | No | |
| 20 | sb4 | — | Section Break | | No | Tax & Compliance |
| 21 | tax_profile | Tax Profile | Small Text | | No | Tax exemption status, NPWP, etc. |
| 22 | sb5 | — | Section Break | | No | Status |
| 23 | is_active | Is Active | Check | | No | Default 1 |
| 24 | logo | Logo | Attach Image | | No | |
| 25 | notes | Notes | Long Text | | No | Internal notes |

**Business Rules:**
1. Only one Organization should be in Active status at a time per Frappe site (single-tenant assumption for MVP).
2. `base_currency` must match the currency used in the linked ERPNext Company.
3. `organization_type` drives default reporting labels and is used in report headers.
4. If `legal_name` is blank, `organization_name` is used in all formal documents.

---

## 2. Office

**Module:** Fundara > Organization
**Parent (if child table):** —
**Is Submittable:** No
**Has Workflow:** No
**Naming Series:** OFF-.YYYY.-.####

Represents an operational location of the organization — head office, regional office, field office, warehouse, project site, or business unit location.

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | naming_series | Series | Select | OFF-.YYYY.-.#### | Yes | |
| 2 | office_name | Office Name | Data | | Yes | |
| 3 | office_code | Office Code | Data | | Yes | Short code, e.g., HO, RO-JB, FO-KPG |
| 4 | organization | Organization | Link | Organization | Yes | Parent organization |
| 5 | office_type | Office Type | Select | Head Office\nRegional Office\nField Office\nWarehouse\nProject Site\nBusiness Unit Location | Yes | |
| 6 | sb1 | — | Section Break | | No | Location |
| 7 | address_line_1 | Address Line 1 | Data | | No | |
| 8 | address_line_2 | Address Line 2 | Data | | No | |
| 9 | city | City | Data | | No | |
| 10 | province | Province / State | Data | | No | |
| 11 | country | Country | Link | Country | Yes | |
| 12 | postal_code | Postal Code | Data | | No | |
| 13 | sb2 | — | Section Break | | No | Management |
| 14 | manager | Manager | Link | User | No | Office manager / PIC |
| 15 | parent_office | Parent Office | Link | Office | No | For hierarchical office structures |
| 16 | linked_cost_center | Linked Cost Center | Link | Cost Center | No | ERPNext Cost Center for this office |
| 17 | sb3 | — | Section Break | | No | Status |
| 18 | is_active | Is Active | Check | | No | Default 1 |
| 19 | opening_date | Opening Date | Date | | No | |
| 20 | closing_date | Closing Date | Date | | No | Populated when office is decommissioned |
| 21 | notes | Notes | Small Text | | No | |

**Business Rules:**
1. `office_code` must be unique across all offices in the organization.
2. Exactly one office must have `office_type = Head Office`.
3. When an office is deactivated (`is_active = 0`), existing documents linked to it remain valid; the office is locked from new document creation.
4. `closing_date` must not precede `opening_date` if both are set.

---

## 3. Department

**Module:** Fundara > Organization
**Parent (if child table):** —
**Is Submittable:** No
**Has Workflow:** No
**Naming Series:** DEPT-.YYYY.-.####

Represents an internal work unit. ERPNext ships a built-in `Department` DocType; Fundara extends it with NGO-specific fields via Custom Fields. This spec describes the complete field set including Fundara additions.

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | naming_series | Series | Select | DEPT-.YYYY.-.#### | Yes | Fundara custom field on ERPNext Department |
| 2 | department_name | Department Name | Data | | Yes | Built-in ERPNext field |
| 3 | department_code | Department Code | Data | | Yes | Short code, e.g., FIN, PROG, HR |
| 4 | organization | Organization | Link | Organization | Yes | Parent organization |
| 5 | parent_department | Parent Department | Link | Department | No | For nested unit structures |
| 6 | sb1 | — | Section Break | | No | Management |
| 7 | department_head | Department Head | Link | User | No | Person responsible for this unit |
| 8 | sb2 | — | Section Break | | No | Cost Tracking |
| 9 | linked_cost_center | Linked Cost Center | Link | Cost Center | No | ERPNext Cost Center for this department |
| 10 | sb3 | — | Section Break | | No | Status |
| 11 | is_active | Is Active | Check | | No | Default 1 |
| 12 | notes | Notes | Small Text | | No | |

**Business Rules:**
1. `department_code` must be unique within the organization.
2. A department may have a `parent_department`, but circular references are not permitted.
3. `linked_cost_center` should not be the same cost center assigned to a different department (cost center ownership should be 1-to-1 at the department level unless explicitly shared).
4. Deactivating a department does not delete historical records; it prevents new assignments.

---

## 4. Cost Center (Extension)

**Module:** Fundara > Organization
**Parent (if child table):** —
**Is Submittable:** No
**Has Workflow:** No
**Naming Series:** — (ERPNext built-in, uses Company-based naming)

ERPNext's built-in `Cost Center` DocType is used directly. Fundara adds the following Custom Fields to link cost centers to the organization context.

> These are Custom Fields on the existing ERPNext `Cost Center` DocType — not a new DocType.

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | (built-in) | Cost Center Name | Data | | Yes | ERPNext native |
| 2 | (built-in) | Cost Center Number | Data | | No | ERPNext native |
| 3 | (built-in) | Parent Cost Center | Link | Cost Center | No | ERPNext native |
| 4 | (built-in) | Company | Link | Company | Yes | ERPNext native |
| 5 | fundara_office | Office | Link | Office | No | Custom Field — which office owns this CC |
| 6 | fundara_department | Department | Link | Department | No | Custom Field — which department owns this CC |
| 7 | fundara_cc_type | Cost Center Type | Select | Organizational\nProgram\nProject\nBusiness Unit\nShared | No | Custom Field — classification |
| 8 | fundara_notes | Notes | Small Text | | No | Custom Field |

**Business Rules:**
1. A Cost Center is never a substitute for a Fund or Project in Fundara's model — it represents organizational structure only.
2. `fundara_cc_type = Program` or `Project` cost centers must still be linked to a Fund in the Fund Stewardship Context.
3. The parent-child hierarchy of Cost Centers must mirror the organization hierarchy to maintain consistent roll-up reporting.

---

## 5. Delegation of Authority

**Module:** Fundara > Organization
**Parent (if child table):** —
**Is Submittable:** Yes
**Has Workflow:** Yes
**Naming Series:** DOA-.YYYY.-.####

Defines approval rules: who can approve what, up to what monetary threshold, for which document types, funds, projects, or departments. This is the central approval governance record.

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | naming_series | Series | Select | DOA-.YYYY.-.#### | Yes | |
| 2 | authority_name | Authority Name | Data | | Yes | Human-readable label, e.g., "Finance Officer — Operational Expense" |
| 3 | organization | Organization | Link | Organization | Yes | |
| 4 | sb1 | — | Section Break | | No | Approval Principal |
| 5 | approver_role | Approver Role | Link | Role | Yes | Role that holds this authority |
| 6 | approval_level | Approval Level | Int | | Yes | 1 = lowest, higher = more senior |
| 7 | sb2 | — | Section Break | | No | Document Scope |
| 8 | applicable_document_types | Applicable Document Types | Table | Delegation of Authority Item | Yes | Child table listing document types |
| 9 | sb3 | — | Section Break | | No | Amount Threshold |
| 10 | currency | Currency | Link | Currency | Yes | |
| 11 | minimum_amount | Minimum Amount | Currency | | No | 0 if no lower bound |
| 12 | maximum_amount | Maximum Amount | Currency | Yes | Upper limit of approval authority |
| 13 | sb4 | — | Section Break | | No | Organizational Scope |
| 14 | applicable_department | Applicable Department | Link | Department | No | Blank = all departments |
| 15 | applicable_office | Applicable Office | Link | Office | No | Blank = all offices |
| 16 | sb5 | — | Section Break | | No | Validity |
| 17 | valid_from | Valid From | Date | | Yes | |
| 18 | valid_to | Valid To | Date | | No | Blank = open-ended |
| 19 | is_active | Is Active | Check | | No | Controlled by submit/cancel workflow |
| 20 | sb6 | — | Section Break | | No | Notes |
| 21 | notes | Notes | Long Text | | No | Rationale, board resolution reference, etc. |

**Business Rules:**
1. `approver_role` must be a role that exists and is assigned to at least one active user.
2. `maximum_amount` must be greater than `minimum_amount` when both are set.
3. Two active `Delegation of Authority` records for the same `approver_role` and overlapping `applicable_document_types` must have non-overlapping amount ranges.
4. Changes to a submitted record must go through amendment; original record is preserved in audit trail.
5. `valid_to` must not be earlier than `valid_from`.
6. When `valid_to` passes, the rule becomes inactive automatically (scheduled job).

---

## 6. Delegation of Authority Item

**Module:** Fundara > Organization
**Parent (if child table):** Delegation of Authority
**Is Submittable:** No
**Has Workflow:** No
**Naming Series:** —

Child table row specifying a document type covered by a Delegation of Authority rule.

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | document_type | Document Type | Select | Purchase Request\nPayment Request\nPayment Voucher\nGrant Agreement\nDonation\nJournal Entry\nBudget Revision\nExpense Claim\nProcurement Order | Yes | Extend list as new DocTypes are built |
| 2 | remarks | Remarks | Small Text | | No | Specific conditions or exceptions for this doc type |

**Business Rules:**
1. A single Delegation of Authority should not list the same `document_type` more than once.

---

## 7. Organization Contact Item

**Module:** Fundara > Organization
**Parent (if child table):** Organization
**Is Submittable:** No
**Has Workflow:** No
**Naming Series:** —

Child table for storing multiple contact persons associated with the organization (board members, legal representatives, auditors, etc.).

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | contact_name | Contact Name | Data | | Yes | |
| 2 | contact_role | Contact Role | Select | Board Chair\nBoard Member\nExecutive Director\nLegal Representative\nExternal Auditor\nBanker\nOther | Yes | |
| 3 | email | Email | Data | | No | |
| 4 | phone | Phone | Data | | No | |
| 5 | linked_user | Linked User | Link | User | No | If this contact is also a system user |
| 6 | is_primary | Is Primary Contact | Check | | No | |
| 7 | notes | Notes | Small Text | | No | |

**Business Rules:**
1. Only one row per Organization Contact Item table should have `is_primary = 1`.

---

## 8. Approval Matrix

> **Status: Post-MVP**

**Module:** Fundara > Organization
**Parent (if child table):** —
**Is Submittable:** Yes
**Has Workflow:** Yes
**Naming Series:** APM-.YYYY.-.####

A more structured matrix that defines multi-level approval chains per document type, linking Delegation of Authority rules into sequential or parallel approval steps.

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | naming_series | Series | Select | APM-.YYYY.-.#### | Yes | |
| 2 | matrix_name | Matrix Name | Data | | Yes | |
| 3 | organization | Organization | Link | Organization | Yes | |
| 4 | document_type | Document Type | Select | Purchase Request\nPayment Request\nPayment Voucher\nGrant Agreement\nExpense Claim | Yes | |
| 5 | approval_steps | Approval Steps | Table | Approval Matrix Step | Yes | Ordered list of approval levels |
| 6 | valid_from | Valid From | Date | | Yes | |
| 7 | valid_to | Valid To | Date | | No | |
| 8 | notes | Notes | Long Text | | No | |

**Business Rules:**
1. Steps in `approval_steps` must have unique, sequential `step_order` values.
2. Only one active Approval Matrix per `document_type` at any time.

---

## 9. Office Permission Rule

> **Status: Post-MVP**

**Module:** Fundara > Organization
**Parent (if child table):** —
**Is Submittable:** No
**Has Workflow:** No
**Naming Series:** OPR-.YYYY.-.####

Defines data visibility rules: which roles can see documents belonging to which offices or departments. Complements ERPNext's Role Permission Manager with org-structure-aware filtering.

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | naming_series | Series | Select | OPR-.YYYY.-.#### | Yes | |
| 2 | rule_name | Rule Name | Data | | Yes | |
| 3 | organization | Organization | Link | Organization | Yes | |
| 4 | role | Role | Link | Role | Yes | |
| 5 | permission_type | Permission Type | Select | Own Office Only\nOwn Department Only\nOwn Office + Sub-offices\nAll Offices | Yes | |
| 6 | applicable_document | Applicable Document Type | Data | | No | ERPNext DocType name; blank = all |
| 7 | is_active | Is Active | Check | | No | Default 1 |
| 8 | notes | Notes | Small Text | | No | |

**Business Rules:**
1. More restrictive rules take precedence when multiple rules match a user's role.
2. Users with System Manager role bypass all Office Permission Rules.

---

## Summary — Organization Context DocTypes

| # | DocType | Type | MVP? | Submittable |
|---|---|---|---|---|
| 1 | Organization | Main | Yes | No |
| 2 | Office | Main | Yes | No |
| 3 | Department | Main (extends built-in) | Yes | No |
| 4 | Cost Center Extension | Custom Fields on built-in | Yes | No |
| 5 | Delegation of Authority | Main | Yes | Yes |
| 6 | Delegation of Authority Item | Child | Yes | No |
| 7 | Organization Contact Item | Child | Yes | No |
| 8 | Approval Matrix | Main | Post-MVP | Yes |
| 9 | Office Permission Rule | Main | Post-MVP | No |
