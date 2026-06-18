# Funding Context — DocType Specifications

**Module:** Fundara > Funding
**Context File:** fundara-domain-contexts/02-funding-context.md
**Last Updated:** 2026-06-18

---

## Table of Contents

1. [Funding Source](#1-funding-source) — MVP
2. [Donor](#2-donor) — MVP
3. [Institutional Donor Profile](#3-institutional-donor-profile) — MVP
4. [Donor Contact Item](#4-donor-contact-item) — MVP (child)
5. [Fundraising Campaign](#5-fundraising-campaign) — MVP
6. [Campaign Channel Item](#6-campaign-channel-item) — MVP (child)
7. [Donation](#7-donation) — MVP
8. [Business Unit](#8-business-unit) — MVP
9. [Revenue Stream](#9-revenue-stream) — MVP
10. [Surplus Allocation Policy](#10-surplus-allocation-policy) — Post-MVP
11. [Donor Acknowledgment](#11-donor-acknowledgment) — Post-MVP

> **Key Design Principle:** Funding Source is the origin of money; Fund (defined in Fund Stewardship Context) is the management bucket. These must never be conflated.

---

## 1. Funding Source

**Module:** Fundara > Funding
**Parent (if child table):** —
**Is Submittable:** No
**Has Workflow:** No
**Naming Series:** FS-.YYYY.-.####

The umbrella record representing any origin of funds — institutional donors, individual donors, public fundraising campaigns, business units, government contracts, or internal reserves. Specific sub-types (Donor, Fundraising Campaign, Business Unit) link back to a Funding Source record.

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | naming_series | Series | Select | FS-.YYYY.-.#### | Yes | |
| 2 | source_name | Source Name | Data | | Yes | Display name for this funding source |
| 3 | source_code | Source Code | Data | | Yes | Short unique code, e.g., USAID-2024, ZIS-JKT |
| 4 | source_type | Source Type | Select | Institutional Donor\nIndividual Donor\nCorporate Donor\nPublic Fundraising\nFundraising Campaign\nSocial Enterprise Revenue\nService Revenue\nMembership Fee\nGovernment Contract\nInternal Reserve\nInvestment Income\nZakat / Infaq / Wakaf | Yes | Determines which linked sub-record applies |
| 5 | organization | Organization | Link | Organization | Yes | Owning organization |
| 6 | sb1 | — | Section Break | | No | Contact & Ownership |
| 7 | country | Country | Link | Country | No | Country of the funding source |
| 8 | relationship_owner | Relationship Owner | Link | User | No | Internal staff responsible for this source |
| 9 | responsible_department | Responsible Department | Link | Department | No | |
| 10 | sb2 | — | Section Break | | No | Fund Character |
| 11 | default_restriction_type | Default Restriction Type | Select | Restricted\nUnrestricted\nDesignated | Yes | Default applied to funds created from this source |
| 12 | reporting_expectation | Reporting Expectation | Select | None\nBasic Receipt\nNarrative Report\nFull Financial Report\nAudit Required | Yes | |
| 13 | risk_profile | Risk Profile | Select | Low\nMedium\nHigh | No | Internal assessment of compliance risk |
| 14 | sb3 | — | Section Break | | No | Links to Sub-records |
| 15 | linked_donor | Linked Donor | Link | Donor | No | Populated if source_type is a donor type |
| 16 | linked_campaign | Linked Campaign | Link | Fundraising Campaign | No | Populated if source_type = Fundraising Campaign |
| 17 | linked_business_unit | Linked Business Unit | Link | Business Unit | No | Populated if source_type is revenue-generating |
| 18 | sb4 | — | Section Break | | No | Status |
| 19 | is_active | Is Active | Check | | No | Default 1 |
| 20 | activation_date | Activation Date | Date | | No | |
| 21 | deactivation_date | Deactivation Date | Date | | No | |
| 22 | notes | Notes | Long Text | | No | |

**Business Rules:**
1. `source_code` must be unique across all Funding Sources in the organization.
2. A Funding Source may generate more than one Fund (handled in Fund Stewardship Context).
3. Exactly one of `linked_donor`, `linked_campaign`, `linked_business_unit` should be populated based on `source_type`; leave all blank for Internal Reserve or Investment Income types.
4. `default_restriction_type` is a default only — the actual Fund can override it at creation time.
5. Deactivating a Funding Source prevents creation of new Funds from it but does not affect existing Funds.

---

## 2. Donor

**Module:** Fundara > Funding
**Parent (if child table):** —
**Is Submittable:** No
**Has Workflow:** No
**Naming Series:** DNR-.YYYY.-.####

Represents an entity or person that gives funds or resources to support the organization's mission. Donors of institutional type should also have an `Institutional Donor Profile` child or linked record.

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | naming_series | Series | Select | DNR-.YYYY.-.#### | Yes | |
| 2 | donor_name | Donor Name | Data | | Yes | |
| 3 | donor_type | Donor Type | Select | Individual\nInstitutional\nCorporate\nPhilanthropic Foundation\nMultilateral Agency\nGovernment\nCommunity | Yes | |
| 4 | organization | Organization | Link | Organization | Yes | Owning organization |
| 5 | sb1 | — | Section Break | | No | Contact |
| 6 | contact_person | Contact Person | Data | | No | Primary contact name for institutional/corporate donors |
| 7 | email | Email | Data | | No | |
| 8 | phone | Phone | Data | | No | |
| 9 | country | Country | Link | Country | No | |
| 10 | preferred_language | Preferred Language | Data | | No | e.g., id, en |
| 11 | donor_contacts | Contacts | Table | Donor Contact Item | No | Additional contacts |
| 12 | sb2 | — | Section Break | | No | Preferences |
| 13 | reporting_preference | Reporting Preference | Select | Email\nPost\nPortal\nNo Preference | No | How they receive reports |
| 14 | acknowledgment_preference | Acknowledgment Preference | Select | Email\nLetter\nCall\nCertificate\nNone | No | |
| 15 | sb3 | — | Section Break | | No | Relationship |
| 16 | relationship_owner | Relationship Owner | Link | User | No | Staff managing this donor relationship |
| 17 | linked_funding_source | Linked Funding Source | Link | Funding Source | No | Back-link to Funding Source record |
| 18 | sb4 | — | Section Break | | No | Institutional Profile |
| 19 | institutional_profile | Institutional Profile | Link | Institutional Donor Profile | No | Only for Institutional / Multilateral / Government types |
| 20 | sb5 | — | Section Break | | No | Status |
| 21 | donor_status | Donor Status | Select | Prospect\nActive\nLapsed\nFormer\nBlacklisted | Yes | |
| 22 | is_anonymous_allowed | Allow Anonymous Donations | Check | | No | If donor permits anonymous recording of donations |
| 23 | notes | Notes | Long Text | | No | |

**Business Rules:**
1. `donor_type = Individual` must not have `institutional_profile` populated.
2. `donor_type` in `[Institutional, Multilateral Agency, Government, Philanthropic Foundation]` should have an `institutional_profile` linked.
3. A donor with `donor_status = Blacklisted` cannot be selected on a new Donation or Fundraising Campaign.
4. Donor records are never deleted — they are lapsed or archived to preserve donation history.
5. `relationship_owner` must be an active system user.

---

## 3. Institutional Donor Profile

**Module:** Fundara > Funding
**Parent (if child table):** —
**Is Submittable:** No
**Has Workflow:** No
**Naming Series:** IDP-.YYYY.-.####

Stores formal compliance, reporting, and operational requirements specific to institutional, government, multilateral, or philanthropic foundation donors. Linked from the `Donor` record.

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | naming_series | Series | Select | IDP-.YYYY.-.#### | Yes | |
| 2 | donor_legal_name | Donor Legal Name | Data | | Yes | Official registered name |
| 3 | donor_short_name | Donor Short Name | Data | | No | Abbreviation used internally |
| 4 | linked_donor | Donor | Link | Donor | Yes | Parent donor record |
| 5 | sb1 | — | Section Break | | No | Compliance Requirements |
| 6 | compliance_requirements | Compliance Requirements | Long Text | | No | Summary of donor compliance rules |
| 7 | audit_requirement | Audit Requirement | Select | None\nInternal Audit\nExternal Audit\nDonor-Commissioned Audit | No | |
| 8 | procurement_preference | Procurement Preference | Select | No Restriction\nDonor Procurement Rules\nLocal Procurement Priority\nCompetitive Bidding Required | No | |
| 9 | branding_requirement | Branding Requirement | Small Text | | No | Visibility / logo placement rules |
| 10 | sb2 | — | Section Break | | No | Reporting Format |
| 11 | financial_reporting_format | Financial Reporting Format | Select | Standard Fundara\nDonor Template\nIFRS\nLocal GAAP\nCustom | No | |
| 12 | narrative_reporting_format | Narrative Reporting Format | Select | Standard Fundara\nDonor Template\nCustom | No | |
| 13 | reporting_frequency | Reporting Frequency | Select | Monthly\nQuarterly\nSemi-annual\nAnnual\nMilestone-based | No | |
| 14 | sb3 | — | Section Break | | No | Currency & Financial |
| 15 | allowed_currency | Allowed Currency | Table MultiSelect | Currency | No | Currencies acceptable for grant disbursement |
| 16 | sb4 | — | Section Break | | No | Notes |
| 17 | special_conditions | Special Conditions | Long Text | | No | Any donor-specific operational conditions |
| 18 | attachments | Attachments | Attach | | No | Donor compliance document uploads |

**Business Rules:**
1. `linked_donor` must point to a Donor with `donor_type` in `[Institutional, Government, Multilateral Agency, Philanthropic Foundation]`.
2. One Institutional Donor Profile per Donor record.
3. `allowed_currency` restricts which currencies can be used when creating grants or funds from this donor.

---

## 4. Donor Contact Item

**Module:** Fundara > Funding
**Parent (if child table):** Donor
**Is Submittable:** No
**Has Workflow:** No
**Naming Series:** —

Child table for multiple contact persons at a donor organization.

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | contact_name | Contact Name | Data | | Yes | |
| 2 | title | Title | Data | | No | e.g., Dr., Prof., Ms. |
| 3 | position | Position | Data | | No | Job title at donor org |
| 4 | contact_type | Contact Type | Select | Primary\nFinance\nProgrammatic\nLegal\nCommunications\nOther | Yes | |
| 5 | email | Email | Data | | No | |
| 6 | phone | Phone | Data | | No | |
| 7 | is_primary | Is Primary | Check | | No | |
| 8 | notes | Notes | Small Text | | No | |

**Business Rules:**
1. Only one row per Donor Contact Item table should have `is_primary = 1`.

---

## 5. Fundraising Campaign

**Module:** Fundara > Funding
**Parent (if child table):** —
**Is Submittable:** Yes
**Has Workflow:** Yes
**Naming Series:** CAMP-.YYYY.-.####

Represents a targeted effort to collect funds from the public or a specific segment. A campaign has a purpose, target, timeline, and status lifecycle. Campaigns are distinct from Projects — a campaign raises money; a project spends it.

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | naming_series | Series | Select | CAMP-.YYYY.-.#### | Yes | |
| 2 | campaign_name | Campaign Name | Data | | Yes | |
| 3 | campaign_code | Campaign Code | Data | | Yes | Unique short code, e.g., BANJIR-2026 |
| 4 | organization | Organization | Link | Organization | Yes | |
| 5 | sb1 | — | Section Break | | No | Purpose |
| 6 | purpose | Purpose | Small Text | | Yes | Brief description of what this campaign funds |
| 7 | restricted_purpose | Restricted Purpose | Small Text | | No | Specific restriction communicated to donors |
| 8 | restriction_type | Restriction Type | Select | Restricted\nUnrestricted\nDesignated | Yes | |
| 9 | sb2 | — | Section Break | | No | Target & Timeline |
| 10 | currency | Currency | Link | Currency | Yes | |
| 11 | target_amount | Target Amount | Currency | | Yes | |
| 12 | start_date | Start Date | Date | | Yes | |
| 13 | end_date | End Date | Date | | Yes | |
| 14 | sb3 | — | Section Break | | No | Management |
| 15 | campaign_manager | Campaign Manager | Link | User | Yes | |
| 16 | responsible_department | Responsible Department | Link | Department | No | Usually Fundraising or Communications |
| 17 | sb4 | — | Section Break | | No | Channels |
| 18 | campaign_channels | Campaign Channels | Table | Campaign Channel Item | No | List of channels used |
| 19 | sb5 | — | Section Break | | No | Reporting & Transparency |
| 20 | public_reporting_required | Public Reporting Required | Check | | No | Whether a public report must be published |
| 21 | public_reporting_commitment | Public Reporting Commitment | Small Text | | No | What will be reported and when |
| 22 | sb6 | — | Section Break | | No | Status |
| 23 | status | Status | Select | Draft\nUnder Review\nApproved\nActive\nPaused\nCompleted\nReporting\nClosed\nCancelled | Yes | Controlled by workflow |
| 24 | linked_funding_source | Linked Funding Source | Link | Funding Source | No | Auto-created or manually linked |
| 25 | sb7 | — | Section Break | | No | Financials |
| 26 | total_donations_received | Total Donations Received | Currency | | No | Read-only, computed from linked Donations |
| 27 | total_donors | Total Donors | Int | | No | Read-only count |
| 28 | achievement_percent | Achievement % | Percent | | No | Read-only: total_donations_received / target_amount |
| 29 | sb8 | — | Section Break | | No | Notes |
| 30 | notes | Notes | Long Text | | No | |

**Business Rules:**
1. `campaign_code` must be unique across all campaigns in the organization.
2. `end_date` must be after `start_date`.
3. A campaign with `status = Cancelled` cannot receive new Donation entries.
4. Once `status = Closed`, the record is locked and can only be amended.
5. `restriction_type = Restricted` campaigns must have `restricted_purpose` populated.
6. `total_donations_received`, `total_donors`, and `achievement_percent` are computed (not editable).
7. Transitioning to `status = Active` requires `status = Approved` first (workflow enforced).
8. A campaign is distinct from a Project — it governs the fundraising side only.

---

## 6. Campaign Channel Item

**Module:** Fundara > Funding
**Parent (if child table):** Fundraising Campaign
**Is Submittable:** No
**Has Workflow:** No
**Naming Series:** —

Child table listing the distribution channels used by a campaign.

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | channel | Channel | Select | Online Platform\nSocial Media\nEmail\nDirect Mail\nEvent\nSMS\nWhatsApp\nPeer-to-Peer\nDoor-to-Door\nCorporate Partnership\nOther | Yes | |
| 2 | channel_detail | Channel Detail | Data | | No | e.g., platform name, event name |
| 3 | channel_target_amount | Channel Target Amount | Currency | | No | |
| 4 | is_primary_channel | Is Primary Channel | Check | | No | |
| 5 | notes | Notes | Small Text | | No | |

**Business Rules:**
1. Only one row should have `is_primary_channel = 1`.

---

## 7. Donation

**Module:** Fundara > Funding
**Parent (if child table):** —
**Is Submittable:** Yes
**Has Workflow:** Yes
**Naming Series:** DON-.YYYY.-.####

Records a single donation received from a donor (individual, corporate, or public). Donations may be linked to a Campaign. Each submitted Donation triggers or updates a Fund in the Fund Stewardship Context.

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | naming_series | Series | Select | DON-.YYYY.-.#### | Yes | |
| 2 | donation_number | Donation Number | Data | | No | Read-only, set from naming_series |
| 3 | organization | Organization | Link | Organization | Yes | |
| 4 | sb1 | — | Section Break | | No | Donor |
| 5 | is_anonymous | Anonymous Donation | Check | | No | If checked, donor identity hidden from public reports |
| 6 | donor | Donor | Link | Donor | No | Mandatory unless is_anonymous = 1 |
| 7 | donor_display_name | Donor Display Name | Data | | No | Override name for anonymous ("Hamba Allah", "Donatur Baik") |
| 8 | sb2 | — | Section Break | | No | Campaign |
| 9 | fundraising_campaign | Fundraising Campaign | Link | Fundraising Campaign | No | Leave blank if not campaign-linked |
| 10 | funding_source | Funding Source | Link | Funding Source | No | Auto-derived from campaign or donor |
| 11 | sb3 | — | Section Break | | No | Amount |
| 12 | currency | Currency | Link | Currency | Yes | |
| 13 | amount | Amount | Currency | | Yes | |
| 14 | exchange_rate | Exchange Rate | Float | | No | Required if currency != base currency |
| 15 | amount_in_base_currency | Amount in Base Currency | Currency | | No | Read-only computed field |
| 16 | sb4 | — | Section Break | | No | Payment |
| 17 | date_received | Date Received | Date | | Yes | |
| 18 | payment_channel | Payment Channel | Select | Bank Transfer\nCash\nCredit Card\nDigital Wallet\nCheque\nZakat Platform\nOnline Platform\nOther | Yes | |
| 19 | payment_reference | Payment Reference | Data | | No | Bank ref, transaction ID, cheque number |
| 20 | sb5 | — | Section Break | | No | Restriction |
| 21 | restriction_type | Restriction Type | Select | Restricted\nUnrestricted\nDesignated | Yes | |
| 22 | restriction_purpose | Restriction Purpose | Small Text | | No | Mandatory if restriction_type = Restricted |
| 23 | sb6 | — | Section Break | | No | Receipt & Acknowledgment |
| 24 | receipt_number | Receipt Number | Data | | No | Official receipt number |
| 25 | receipt_issued | Receipt Issued | Check | | No | |
| 26 | receipt_date | Receipt Date | Date | | No | |
| 27 | acknowledgment_status | Acknowledgment Status | Select | Pending\nSent\nConfirmed\nNot Required | Yes | |
| 28 | acknowledgment_date | Acknowledgment Date | Date | | No | |
| 29 | sb7 | — | Section Break | | No | Notes |
| 30 | notes | Notes | Long Text | | No | |

**Business Rules:**
1. If `is_anonymous = 0`, then `donor` is mandatory.
2. If `is_anonymous = 1`, `donor` must be left blank; `donor_display_name` is used instead.
3. `restriction_type = Restricted` requires `restriction_purpose` to be filled.
4. `amount` must be greater than 0.
5. If `currency` differs from organization's `base_currency`, `exchange_rate` is mandatory.
6. Submitting a Donation should trigger creation or update of a Fund in Fund Stewardship Context (via hook or workflow).
7. Cancelled Donations must not affect Fund balances (reversal required).
8. `acknowledgment_status` must be tracked and should not remain `Pending` beyond a configurable SLA.
9. If `fundraising_campaign` is set, the campaign must be in `Active` or `Paused` status (not Cancelled or Closed).

---

## 8. Business Unit

**Module:** Fundara > Funding
**Parent (if child table):** —
**Is Submittable:** No
**Has Workflow:** No
**Naming Series:** BU-.YYYY.-.####

Represents a revenue-generating unit or social enterprise arm of the organization (training center, café sosial, consulting unit, product line, publishing, etc.).

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | naming_series | Series | Select | BU-.YYYY.-.#### | Yes | |
| 2 | business_unit_name | Business Unit Name | Data | | Yes | |
| 3 | business_unit_code | Business Unit Code | Data | | Yes | Unique short code, e.g., TC-YOG, CAFE-JKT |
| 4 | organization | Organization | Link | Organization | Yes | |
| 5 | sb1 | — | Section Break | | No | Operations |
| 6 | revenue_model | Revenue Model | Select | Training / Education\nFood & Beverage\nConsulting / Professional Services\nProduct Sales\nEvent Management\nMembership\nRental\nPublication\nOther | Yes | |
| 7 | manager | Manager | Link | User | No | Person responsible for this business unit |
| 8 | office | Office | Link | Office | No | Physical location / office |
| 9 | linked_cost_center | Linked Cost Center | Link | Cost Center | No | ERPNext Cost Center for revenue tracking |
| 10 | linked_department | Linked Department | Link | Department | No | |
| 11 | sb2 | — | Section Break | | No | Financial |
| 12 | currency | Currency | Link | Currency | Yes | Operating currency |
| 13 | tax_profile | Tax Profile | Small Text | | No | Tax treatment for revenue from this unit |
| 14 | sb3 | — | Section Break | | No | Surplus Policy |
| 15 | surplus_allocation_policy | Surplus Allocation Policy | Link | Surplus Allocation Policy | No | Post-MVP: how surplus is distributed to funds |
| 16 | surplus_allocation_description | Surplus Allocation Description | Small Text | | No | Brief narrative for MVP use |
| 17 | sb4 | — | Section Break | | No | Funding Source |
| 18 | linked_funding_source | Linked Funding Source | Link | Funding Source | No | The Funding Source representing this BU's revenue |
| 19 | sb5 | — | Section Break | | No | Status |
| 20 | is_active | Is Active | Check | | No | Default 1 |
| 21 | opening_date | Opening Date | Date | | No | |
| 22 | closing_date | Closing Date | Date | | No | |
| 23 | notes | Notes | Long Text | | No | |

**Business Rules:**
1. `business_unit_code` must be unique across all Business Units in the organization.
2. Business Unit revenue must be tracked separately from donation income — they must use distinct accounts/cost centers.
3. Surplus from a Business Unit may only be allocated to a Fund after revenue and directly attributable costs for the period have been confirmed.
4. A deactivated Business Unit cannot have new Revenue Stream entries recorded against it.

---

## 9. Revenue Stream

**Module:** Fundara > Funding
**Parent (if child table):** —
**Is Submittable:** No
**Has Workflow:** No
**Naming Series:** RS-.YYYY.-.####

Defines a category of income generated by a Business Unit. Used for classifying revenue lines and supporting disaggregated financial reporting.

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | naming_series | Series | Select | RS-.YYYY.-.#### | Yes | |
| 2 | stream_name | Stream Name | Data | | Yes | e.g., Training Fee, Consulting Fee, Product Sales |
| 3 | stream_code | Stream Code | Data | | Yes | Unique code, e.g., TRN-FEE, CNSLT, PROD-SALE |
| 4 | business_unit | Business Unit | Link | Business Unit | Yes | Parent business unit |
| 5 | organization | Organization | Link | Organization | Yes | |
| 6 | sb1 | — | Section Break | | No | Classification |
| 7 | stream_type | Stream Type | Select | Training Fee\nConsulting Fee\nProduct Sales\nEvent Ticket\nMembership Fee\nRental Income\nPublication Sales\nService Fee\nOther | Yes | |
| 8 | income_account | Income Account | Link | Account | No | ERPNext GL account for this revenue stream |
| 9 | sb2 | — | Section Break | | No | Status |
| 10 | is_active | Is Active | Check | | No | Default 1 |
| 11 | notes | Notes | Small Text | | No | |

**Business Rules:**
1. `stream_code` must be unique within a Business Unit.
2. `income_account` must be an Income-type account in ERPNext Chart of Accounts.
3. A Revenue Stream cannot be deleted if it has transactions recorded against it — deactivate instead.

---

## 10. Surplus Allocation Policy

> **Status: Post-MVP**

**Module:** Fundara > Funding
**Parent (if child table):** —
**Is Submittable:** Yes
**Has Workflow:** No
**Naming Series:** SAP-.YYYY.-.####

Defines how surplus generated by a Business Unit is distributed across funds (operational reserve, mission fund, specific program, etc.).

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | naming_series | Series | Select | SAP-.YYYY.-.#### | Yes | |
| 2 | policy_name | Policy Name | Data | | Yes | |
| 3 | business_unit | Business Unit | Link | Business Unit | Yes | |
| 4 | organization | Organization | Link | Organization | Yes | |
| 5 | policy_description | Policy Description | Small Text | | No | |
| 6 | allocation_basis | Allocation Basis | Select | Fixed Percentage\nBoard Decision\nFormula | Yes | |
| 7 | allocation_items | Allocation Items | Table | Surplus Allocation Item | Yes | Where surplus goes and in what proportion |
| 8 | valid_from | Valid From | Date | | Yes | |
| 9 | valid_to | Valid To | Date | | No | |
| 10 | notes | Notes | Long Text | | No | |

**Business Rules:**
1. Percentage allocations in `allocation_items` must sum to 100%.
2. Only one active Surplus Allocation Policy per Business Unit at any time.
3. Surplus allocation can only occur after books for the period are confirmed.

---

## 11. Donor Acknowledgment

> **Status: Post-MVP**

**Module:** Fundara > Funding
**Parent (if child table):** —
**Is Submittable:** Yes
**Has Workflow:** No
**Naming Series:** DACK-.YYYY.-.####

Tracks formal acknowledgment communications sent to donors (thank-you letters, certificates, impact updates). Linked to one or more Donations.

| # | Field Name | Label | Fieldtype | Options / Link To | Mandatory | Notes |
|---|---|---|---|---|---|---|
| 1 | naming_series | Series | Select | DACK-.YYYY.-.#### | Yes | |
| 2 | donor | Donor | Link | Donor | Yes | |
| 3 | organization | Organization | Link | Organization | Yes | |
| 4 | acknowledgment_type | Acknowledgment Type | Select | Thank You Letter\nReceipt\nCertificate\nImpact Report\nCall Log\nOther | Yes | |
| 5 | linked_donation | Linked Donation | Link | Donation | No | Specific donation this acknowledges |
| 6 | acknowledgment_date | Acknowledgment Date | Date | | Yes | |
| 7 | sent_by | Sent By | Link | User | No | Staff who sent the acknowledgment |
| 8 | channel | Channel | Select | Email\nPost\nCall\nWhatsApp\nIn-person\nPortal | Yes | |
| 9 | status | Status | Select | Draft\nSent\nDelivered\nFailed | Yes | |
| 10 | attachment | Attachment | Attach | | No | Copy of the acknowledgment document |
| 11 | notes | Notes | Small Text | | No | |

**Business Rules:**
1. A Donation with `acknowledgment_status = Confirmed` should have at least one linked Donor Acknowledgment record.
2. `acknowledgment_date` must not precede the linked Donation's `date_received`.

---

## Summary — Funding Context DocTypes

| # | DocType | Type | MVP? | Submittable |
|---|---|---|---|---|
| 1 | Funding Source | Main | Yes | No |
| 2 | Donor | Main | Yes | No |
| 3 | Institutional Donor Profile | Main | Yes | No |
| 4 | Donor Contact Item | Child of Donor | Yes | No |
| 5 | Fundraising Campaign | Main | Yes | Yes |
| 6 | Campaign Channel Item | Child of Fundraising Campaign | Yes | No |
| 7 | Donation | Main | Yes | Yes |
| 8 | Business Unit | Main | Yes | No |
| 9 | Revenue Stream | Main | Yes | No |
| 10 | Surplus Allocation Policy | Main | Post-MVP | Yes |
| 11 | Donor Acknowledgment | Main | Post-MVP | Yes |
