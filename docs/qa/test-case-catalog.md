# Test Case Catalog — Fundara Manual QA

**Version:** 1.0  
**Date:** 2026-06-19  
**Target:** ERPNext v16 / Frappe Framework  
**Audience:** QA engineers executing manual test runs

> **Catatan penting:** Test case ini melengkapi 34 skenario BDD di `docs/spec/test-scenarios.md` — jangan duplikasi. Semua skenario di file tersebut (TC-FM, TC-CA, TC-PR, TC-BG, TC-RP) sudah mencakup happy path, edge case, dan negative test untuk alur utama Fund Management, Cash Advance, Procurement, Budget, dan Reporting. Katalog ini mengisi celah yang belum dicakup: RBAC, workflow role-mismatch, UI/UX validation, notifikasi, print format, multi-currency edge case, dan performance dasar.

---

## Coverage Complement Map

Tabel berikut menunjukkan bagaimana katalog ini melengkapi skenario BDD yang sudah ada.

| Area | Covered by existing TC | Extended by this catalog |
|---|---|---|
| Fund Management — happy path | TC-FM-01 to TC-FM-08 | TC-ORG-*, TC-UI-05, TC-PERM-01 |
| Cash Advance — full lifecycle | TC-CA-01 to TC-CA-10 | TC-WF-01 to TC-WF-04, TC-PERM-03, TC-NT-01 to TC-NT-03 |
| Procurement | TC-PR-01 to TC-PR-06 | TC-WF-05, TC-UI-03 |
| Budget | TC-BG-01 to TC-BG-06 | TC-PERM-04, TC-WF-06 |
| Reporting | TC-RP-01 to TC-RP-04 | TC-PF-03, TC-PF-04, TC-MC-* |
| Donor & Funding | — | TC-DN-01 to TC-DN-04 |
| Grant Management | — | TC-GR-01 to TC-GR-06, TC-NT-04 |
| RBAC / Permissions | — | TC-PERM-01 to TC-PERM-06 |
| Workflow wrong-role / cancel | — | TC-WF-01 to TC-WF-08 |
| UI / field visibility | — | TC-UI-01 to TC-UI-08 |
| Notifications | — | TC-NT-01 to TC-NT-04 |
| Print format | — | TC-PF-01 to TC-PF-04 |
| Multi-currency edge cases | TC-FM-06, TC-CA-08 | TC-MC-01 to TC-MC-04 |
| Organization setup | — | TC-ORG-01 to TC-ORG-04 |
| Performance | — | TC-PERF-01 to TC-PERF-02 |

---

## Role Reference

The following roles are referenced throughout this catalog. They are the Frappe Roles defined in the Fundara RBAC matrix.

| Role Label Used Here | Frappe Role Name |
|---|---|
| Field Staff | Field Staff |
| Finance Officer | Finance Officer |
| Finance Manager | Finance Manager |
| Project Manager | Project Manager |
| Grant Manager | Donor Relationship Manager |
| Executive Director | Executive Director |
| Fundraising Officer | Fundraising Officer |
| Procurement Officer | Procurement Officer |
| System Admin | System Manager |

---

## TC-PERM — Permission / RBAC Tests

---

### [TC-PERM-01] Finance Officer Cannot Create a Fund

**Given:**
- User "Sari" has only the role Finance Officer (not Finance Manager)
- The Fund Stewardship module is enabled

**When:**
Sari navigates to Fund list and clicks "New"

**Then:**
- The "New" button is either absent, or clicking it shows a permission error: "You do not have permission to create a Fund. Role required: Finance Manager."
- No Fund record is created
- Sari can read existing Fund records (read permission is granted to Finance Officer)

**Negative/edge case:**
- If Sari opens the Fund form via a direct URL (bypassing the list), the server-side `has_permission` check must still block the save: submission returns HTTP 403.

---

### [TC-PERM-02] Field Staff Cannot See the Fund List

**Given:**
- User "Budi" has only the role Field Staff
- Fund records exist in the system

**When:**
Budi navigates to the Fund list view (Fundara > Fund Stewardship > Fund)

**Then:**
- The Fund list view either shows zero records (row-level permission filter hides all) OR the menu item "Fund" is not visible to Field Staff at all
- Budi cannot open any individual Fund record
- No fund names, balances, or restriction details are visible to Budi

**Negative/edge case:**
- If Budi accesses a Fund record via a direct URL, the system returns "Not permitted" and does not show any field values.

---

### [TC-PERM-03] Field Staff Can Only See Their Own Cash Advances

**Given:**
- User "Andi" (Field Staff) has three Cash Advances: ADV-001 (his), ADV-002 (his), ADV-003 (belongs to "Rina", another Field Staff)
- All three advances are in various statuses

**When:**
Andi opens the Cash Advance list view

**Then:**
- List shows only ADV-001 and ADV-002 (records where `requester = Andi`)
- ADV-003 does not appear in the list
- Andi cannot open ADV-003 via direct URL — system returns "Not permitted"

**Negative/edge case:**
- Finance Officer "Dewi" opens the same list — she sees all three advances (Finance Officer has cross-staff read access).
- Finance Manager opens the list — sees all three advances.

---

### [TC-PERM-04] Project Manager Can Approve Activity Budgets but Not Fund Allocations

**Given:**
- User "Rini" has the role Project Manager
- A Fund Budget (budget_type = Activity) exists in "Submitted" state
- A Fund Allocation record also exists in "Submitted" state

**When:**
Step 1: Rini attempts to approve the Fund Budget (Activity type)
Step 2: Rini attempts to approve the Fund Allocation

**Then:**
- Step 1: Approval succeeds — Project Manager is in the allowed roles for budget approval at activity level (per Workflow 4 and Procurement Threshold Rule, Tier 1-2)
- Step 2: Approval is blocked — "You do not have permission to approve Fund Allocations. Role required: Finance Manager."
- Fund Allocation remains in "Submitted" state

**Negative/edge case:**
- If the budget is budget_type = Grant or Organizational, Project Manager is also blocked from approving — only Finance Manager or higher can approve those types.

---

### [TC-PERM-05] Grant Manager Can View All Grants but Cannot Approve Cash Advances

**Given:**
- User "Tono" has the role Donor Relationship Manager (Grant Manager)
- Several Grant records exist at various stages (Pipeline, Awarded, Active)
- A Cash Advance exists in "Under Review" state

**When:**
Step 1: Tono opens the Grant list view
Step 2: Tono attempts to click "Approve" on the Cash Advance in "Under Review"

**Then:**
- Step 1: Tono can see all Grant records and open each one in read mode — Grant Manager has full read access to all Grants
- Step 2: The "Approve" action button is not visible to Tono, OR clicking it returns: "You do not have permission to approve Cash Advances. Role required: Finance Officer or Finance Manager."
- Cash Advance remains in "Under Review" state

**Negative/edge case:**
- Tono can transition a Grant from "Awarded" to "Agreement Review" (that action is in his allowed roles per Workflow 5). This must not be affected by the Cash Advance permission restriction.

---

### [TC-PERM-06] Executive Director Can View All Dashboards but Cannot Edit Transaction Records

**Given:**
- User "Pak Hendra" has the role Executive Director
- A posted Cash Disbursement record exists (docstatus = 1)
- The Fund Balance dashboard is visible

**When:**
Step 1: Pak Hendra opens the Fund Balance dashboard
Step 2: Pak Hendra opens a posted Cash Disbursement record and attempts to edit a field

**Then:**
- Step 1: Dashboard renders completely with all fund data — Executive Director has read access to all financial dashboards
- Step 2: All fields on the posted Cash Disbursement are read-only. The "Edit" button is either absent or clicking it shows: "Submitted documents cannot be edited. Cancel and amend to make changes."
- No edit is saved

**Negative/edge case:**
- If Pak Hendra attempts to cancel the Cash Disbursement (a Finance Manager action), the cancel button is absent or returns "Permission denied."

---

## TC-WF — Workflow-Specific Tests (Wrong Role, Cancel, State Mismatch)

---

### [TC-WF-01] Cash Advance Submitted by a Role That Is Not Allowed — Blocked

**Given:**
- User "Deni" has only the role Procurement Officer
- A Cash Advance has been drafted with fund, activity, and amount filled in

**When:**
Deni attempts to click "Submit for Review" to transition the advance from Draft to Submitted

**Then:**
- The "Submit for Review" action is not visible to Deni, OR clicking it returns: "You do not have permission to submit this Cash Advance. Allowed roles: Field Staff, Finance Officer, Project Manager."
- Advance remains in Draft state

**Negative/edge case:**
- If Deni is later given the Field Staff role in addition to Procurement Officer, the submit action becomes available.

---

### [TC-WF-02] Finance Officer Tries to Approve a Cash Advance That Is Still in "Submitted" (Not Yet "Under Review") — Blocked

**Given:**
- Cash Advance ADV-020 is in state "Submitted" (not yet moved to "Under Review")
- User "Dewi" has role Finance Officer

**When:**
Dewi attempts to use the "Approve" action on ADV-020

**Then:**
- The "Approve" action button is not available on the form when state = "Submitted" — the workflow only exposes "Begin Review" and "Reject" at this state
- Dewi must first click "Begin Review" to move the advance to "Under Review", then "Approve" becomes available
- If Dewi tries to force the state change via API, the workflow engine returns an error: "Transition 'Approve' is not valid from state 'Submitted'."

**Negative/edge case:**
- If the advance is correctly in "Under Review" state, Dewi can approve (for amounts ≤ IDR 50,000,000 per approval threshold table).

---

### [TC-WF-03] Finance Manager Tries to Cancel a Cash Advance That Is in "Paid" Status — Blocked

**Given:**
- Cash Advance ADV-030 has status = Paid (GL entries have been posted, `payment_journal_entry` is set)
- Finance Manager "Bu Lia" attempts to cancel the advance

**When:**
Bu Lia clicks "Cancel" on ADV-030

**Then:**
- Cancellation is blocked: "Cash Advance cannot be cancelled after payment has been made. To reverse this advance, the requester must submit a Liquidation with zero expenses and return the full amount."
- ADV-030 remains in "Paid" state
- No GL reversal entry is created

**Negative/edge case:**
- If ADV-030 is in "Approved" state (not yet paid), cancellation is allowed — the advance moves to "Cancelled" with no GL entries to reverse.
- If the advance is in "Pending Liquidation" or "Overdue", cancellation is also blocked — the liquidation process must be followed.

---

### [TC-WF-04] Reject a Cash Advance at "Under Review" — Resulting Status Is "Rejected", Not "Draft"

**Given:**
- Cash Advance ADV-040 is in state "Under Review"
- Finance Officer "Dewi" rejects it with reason: "Activity does not match the fund restriction — health fund only."

**When:**
Dewi clicks "Reject" and enters the rejection reason

**Then:**
- Advance status transitions to "Rejected" (not back to "Draft")
- `rejected_reason` field is populated with the entered text
- Requester receives a notification: "Your Cash Advance ADV-040 has been rejected. Reason: Activity does not match the fund restriction — health fund only."
- The advance is read-only in Rejected state — no further actions are available except viewing

**Negative/edge case:**
- A Rejected advance cannot be resubmitted — the requester must create a new advance. The "Submit for Review" button is absent on a Rejected record.
- Finance Manager can also reject at this stage; the behavior is identical.

---

### [TC-WF-05] Finance Officer Approves a Cash Advance That Exceeds Their Approval Threshold

**Given:**
- Cash Advance ADV-050: amount = IDR 75,000,000 (Tier 3 — requires Finance Manager approval)
- User "Dewi" has role Finance Officer (approval limit ≤ IDR 50,000,000)
- ADV-050 is in state "Under Review"

**When:**
Dewi attempts to click "Approve" on ADV-050

**Then:**
- The "Approve" action is blocked with message: "This advance (IDR 75,000,000) exceeds your approval limit (IDR 50,000,000). Finance Manager approval is required for amounts above IDR 50,000,000."
- ADV-050 remains in "Under Review" state
- Finance Manager "Bu Lia" sees the advance and can approve it

**Negative/edge case:**
- If the advance amount is IDR 50,000,000 exactly (at the boundary), Finance Officer can approve — the threshold is "≤ 50 M" for Finance Officer.
- If the advance is in USD, the system converts using today's exchange rate to determine IDR equivalent for threshold comparison.

---

### [TC-WF-06] Purchase Request Rejected at PO Stage — PR Status Behavior

**Given:**
- Purchase Request PR-2025-040 has status = "Ordered" (a Purchase Order has been created from it)
- The Purchase Order PO-2025-040 is subsequently cancelled by Finance Manager

**When:**
Finance Manager cancels PO-2025-040 (transitions PO to "Cancelled")

**Then:**
- Per Workflow 3 auto-action: linked Purchase Request PR-2025-040 status is updated — the system must NOT leave PR in "Ordered" state after PO cancellation
- Expected behavior: PR transitions back to "Approved" (PO is gone, but PR is still valid and can be re-converted to a new PO)
- A notification is sent to the Procurement Officer: "Purchase Order PO-2025-040 has been cancelled. Purchase Request PR-2025-040 has been returned to Approved status."

**Negative/edge case:**
- If the PR itself needs to be cancelled (not just the PO), Finance Manager must explicitly cancel the PR — the PO cancellation alone does not auto-cancel the PR.

---

### [TC-WF-07] Grant Workflow: Advance from "Awarded" to "Active" Without Grant Agreement — Blocked

**Given:**
- Grant GR-2025-001 is in state "Awarded"
- The `grant_agreement` field is empty (no Grant Agreement document attached)
- Donor Relationship Manager "Tono" attempts to move the grant directly to "Active"

**When:**
Tono clicks "Activate Grant" (transition: Agreement Review → Active)

**Then:**
- The "Activate Grant" action is not available from "Awarded" state — the workflow requires passing through "Agreement Review" first
- If Tono tries to skip to "Active" via the workflow button "Begin Agreement Review" then "Activate Grant" without setting `agreement_signed = 1`, the condition `doc.agreement_signed == 1 and doc.grant_fund and doc.grant_budget_approved == 1` evaluates to False
- System blocks with: "Cannot activate grant: Grant Agreement must be signed, a linked Grant Fund must exist, and grant budget must be approved before activation."
- Grant remains in "Agreement Review" state

**Negative/edge case:**
- If `grant_agreement` is attached and `agreement_signed = 1` but `grant_fund` is missing, the transition is still blocked — all three conditions must be true simultaneously.

---

### [TC-WF-08] Fund Allocation Submitted Without Finance Manager Approval — Blocked

**Given:**
- Fund Allocation FALLOC-2025-010 is in state "Submitted"
- User "Rini" has role Project Manager
- Rini attempts to click "Approve Allocation"

**Then:**
- "Approve Allocation" action is not available to Project Manager — the workflow transition "Submitted → Approved" requires Finance Manager role
- Rini sees only: "Return for Revision" (if allowed) — no "Approve" button
- FALLOC-2025-010 remains in "Submitted" state

**Negative/edge case:**
- After Finance Manager approves and the allocation reaches "Approved" state, Rini (Project Manager) cannot revert it — only Finance Manager can activate, revise, or close an allocation.

---

## TC-UI — UI/UX Validation Tests

---

### [TC-UI-01] Cash Advance Form: `grant` Field Only Appears When Fund Type Is "Grant Fund"

**Given:**
- A new Cash Advance form is open
- The `fund` field is currently blank

**When:**
Step 1: User selects a Fund with fund_type = "Unrestricted Fund"
Step 2: User changes the Fund selection to one with fund_type = "Grant Fund"

**Then:**
- After Step 1: The `grant` field (or Grant Budget Line selector) is hidden — it is not visible in the form
- After Step 2: The `grant` field becomes visible below the fund section, labeled "Grant" with a required indicator (*)
- Switching back to a non-Grant fund hides the field again and clears any previously entered value

**Negative/edge case:**
- If a user attempts to save a Cash Advance linked to a Grant Fund without filling in the `grant` field, a validation error appears: "Grant field is required when fund type is Grant Fund (D-01)."

---

### [TC-UI-02] Donation Form: `donor_name` Field Only Shows When `is_anonymous = 0`

**Given:**
- A new Donation form is open
- The `is_anonymous` checkbox is checked (value = 1)

**When:**
User unchecks the `is_anonymous` checkbox (value changes to 0)

**Then:**
- The `donor_name` (and linked Donor record field) become visible in the form
- When `is_anonymous` is re-checked, the `donor_name` field is hidden again and its value is cleared
- In the Donation list view, records with `is_anonymous = 1` show "Anonim" in the donor column, not null or the actual name

**Negative/edge case:**
- If the form is saved with `is_anonymous = 0` but no `donor_name` entered, validation blocks: "Donor name is required for non-anonymous donations."

---

### [TC-UI-03] After Submit (docstatus = 1): All Fields Are Read-Only

**Given:**
- Cash Advance ADV-060 has been submitted and is now in "Paid" state (docstatus = 1)

**When:**
Finance Officer opens ADV-060 and attempts to click on the `purpose` field to edit it

**Then:**
- All form fields are read-only — clicking on any field does not open an inline editor
- No "Edit" button is visible in the toolbar (or if visible, clicking it shows: "Submitted documents cannot be edited directly.")
- The workflow action buttons (the next valid transitions) are the only interactive elements
- This applies to all submittable DocTypes: Cash Advance, Fund Allocation, Fund Budget, General Journal, etc.

**Negative/edge case:**
- Frappe's native `allow_edit` on workflow states controls per-state editability. Confirm that states with `Allow Edit = No` (which is all states except Draft per the workflow config) enforce read-only correctly.

---

### [TC-UI-04] D-02 Warning Banner Appears When `pending_payment_flag = 1`

**Given:**
- Cash Advance ADV-070 has status = Approved and `pending_payment_flag = 1` (set automatically when approved, per D-02)

**When:**
Finance Officer opens ADV-070

**Then:**
- A yellow warning banner appears at the top of the form: "Uang muka ini sudah disetujui dan menunggu pembayaran. Dana belum berkurang dari budget hingga pembayaran dilakukan." (or equivalent in the system language)
- The banner is styled as `warning` (yellow/amber), not `danger` (red)
- Once Finance Officer marks the advance as Paid (status → Paid), the banner disappears — `pending_payment_flag` is set to 0

**Negative/edge case:**
- On the Fund dashboard's "Pending Payment" panel, the advance also appears in the list. Verify the panel total matches the sum of all advances with `pending_payment_flag = 1`.

---

### [TC-UI-05] Fund Balance Display Updates After a Payment Is Recorded

**Given:**
- Grant Fund A (USD) shows available balance: USD 44,500 in the Fund Balance panel
- Cash Advance ADV-080 (USD 200, Fund = Grant Fund A) is approved

**When:**
Finance Officer posts payment for ADV-080 (status transitions from Approved to Paid)

**Then:**
- The Fund Balance panel on the Grant Fund A record refreshes automatically (or on page reload)
- New available balance: USD 44,300 (= 44,500 − 200)
- The "Pending Payment" warning count decreases by 1 (ADV-080 is removed from pending list)
- The change is reflected immediately after the payment is saved — no overnight batch required

**Negative/edge case:**
- If the payment for ADV-080 is subsequently cancelled (reversed), the balance must restore to USD 44,500. Test the reversal path.

---

### [TC-UI-06] Error Message Displayed in Bahasa Indonesia When Mandatory Field Is Missing

**Given:**
- The system language is set to Indonesian (Bahasa Indonesia) for the test user
- A Cash Advance form has `purpose` (mandatory field) left blank

**When:**
User clicks "Save" or attempts to submit the form

**Then:**
- A validation error appears in Bahasa Indonesia: "Field 'Tujuan' wajib diisi." (not the raw English ERPNext default: "purpose is mandatory")
- The error message uses the field's Indonesian label, not the internal field name
- The mandatory field is highlighted in red with the error message displayed inline

**Negative/edge case:**
- Verify that ALL mandatory fields on the Cash Advance form produce Indonesian-language error messages, not mixed English/Indonesian messages.
- If any field shows an English error despite the language setting, this is a localization bug.

---

### [TC-UI-07] Exchange Rate Field Appears When Transaction Currency Is Not Base Currency (IDR)

**Given:**
- A Cash Disbursement form is open
- The user selects Currency = IDR (the base currency)

**When:**
User changes the currency selection to USD

**Then:**
- The `exchange_rate` field becomes visible and editable immediately after USD is selected
- The field is pre-populated with the latest USD/IDR rate from the ERPNext Currency Exchange master
- `amount_in_base_currency` is automatically computed as `amount × exchange_rate` and shown as a read-only field
- If the user changes the currency back to IDR, the `exchange_rate` field is hidden (or set to 1.0 and read-only)

**Negative/edge case:**
- If no exchange rate exists for USD on today's date, the field appears but shows 0 or blank with a warning: "No exchange rate found for USD today. Please enter the rate manually or update Currency Exchange master."

---

### [TC-UI-08] Fund Type Field Triggers Grant-Related Fields to Appear/Disappear

**Given:**
- A new Fund form is open
- `fund_type` is blank

**When:**
Step 1: User selects fund_type = "Grant Fund"
Step 2: User changes fund_type = "Campaign Fund"
Step 3: User changes fund_type = "Unrestricted Fund"

**Then:**
- After Step 1: The `grant` field becomes visible and mandatory (asterisk shown). Restriction-related fields for grant reporting (`reporting_requirement`) are highlighted. The `is_bridging_fund` checkbox is hidden.
- After Step 2: The `grant` field is hidden and cleared. Campaign-specific fields (if any) appear.
- After Step 3: All grant-related and campaign-specific fields are hidden. Only common fields remain.
- The form does not require a page reload — field visibility changes are dynamic (Frappe `depends_on` JS evaluation)

**Negative/edge case:**
- If user has entered a `grant` value and then switches to a non-Grant fund_type, the system must clear the `grant` field value and show a confirmation: "Changing Fund Type will clear the Grant link. Proceed?"

---

## TC-DN — Donor & Funding Source Tests

---

### [TC-DN-01] Create Individual Donor with Masked PII — Donation Receipt Hides Name

**Given:**
- A new Donor record is created: donor_type = Individual, is_anonymous = 1
- A Donation of IDR 500,000 is linked to this anonymous Donor

**When:**
Finance Officer generates the Donation Receipt PDF for this donation

**Then:**
- The Donation Receipt does not display the donor's name or any PII
- The donor field on the receipt shows: "Anonim" (not the internal donor record name, not null, not blank)
- The receipt shows: donation amount, date, purpose/campaign, receipt number — all other fields as normal
- The generated PDF is printable and the "Anonim" text is clear and legible

**Negative/edge case:**
- If a second user queries the Donation list and filters by donor, the anonymous donor's legal name is not exposed in the list view — the name column shows "Anonim" even to Finance Officers (PII masking is enforced at the data layer, not just the print layer).

---

### [TC-DN-02] Create Institutional Donor — Institutional Donor Profile Is Created

**Given:**
- No Donor record exists for "Yayasan Peduli Anak"

**When:**
Finance Officer creates a new Donor record: donor_type = Institution, donor_name = "Yayasan Peduli Anak", contact details filled in

**Then:**
- Donor record is saved successfully
- An Institutional Donor Profile child record (or linked profile) is created automatically, capturing: institution name, registration number field, contact person, address
- The Donor appears in the Donor list and can be linked to Donations, Funding Sources, and Cash Receipt records
- No error about missing individual-type fields (individual-specific fields like date_of_birth are hidden for institutional donors)

**Negative/edge case:**
- If donor_type = Institution but no institution name is provided, validation blocks: "Institution name is required for institutional donors."

---

### [TC-DN-03] Fundraising Campaign Cannot Be Closed Before end_date

**Given:**
- Fundraising Campaign "Donasi Buku 2025" has:
  - status = Active
  - end_date = 2025-12-31
  - Today = 2025-10-15 (before end date)

**When:**
Fundraising Officer attempts to transition the campaign to "Completed" (End Collection Period)

**Then:**
- The "End Collection Period" action is blocked: "Campaign end date has not been reached. The campaign can only be completed on or after 2025-12-31."
- Campaign remains in "Active" state
- Fundraising Officer cannot force-close the campaign before end_date without Management override

**Negative/edge case:**
- If Management needs to close early (e.g., target reached), a special "Cancel Active Campaign" transition is available to the Management role only, with a `cancellation_approval` reference required (per Workflow 6).

---

### [TC-DN-04] Donation Linked to Anonymous Donor — Receipt Shows "Anonim"

**Given:**
- A Donor record exists with is_anonymous = 1, internal name = "DONOR-0042"
- A Donation record is linked to DONOR-0042, amount = IDR 1,000,000

**When:**
Finance Officer prints the Donation Receipt for this donation

**Then:**
- The printed receipt displays "Donatur: Anonim" (not "Donatur: DONOR-0042" and not blank)
- The receipt number, amount, date, campaign name, and authorized signature area are all present and correct
- The receipt is legally compliant — the missing donor name is replaced by the explicit label "Anonim", not an empty space
- When this receipt is exported to PDF, the "Anonim" text is embedded in the PDF (not a rendering artifact)

**Negative/edge case:**
- If the donation is linked to a non-anonymous donor, the receipt correctly shows the donor's full name — confirm the is_anonymous flag correctly controls the output in both directions.

---

## TC-GR — Grant Management Tests

---

### [TC-GR-01] Grant Cannot Be Awarded Before Grant Agreement Is Signed

**Given:**
- Grant GR-2025-010 is in state "Awarded"
- Donor Relationship Manager "Tono" begins the "Agreement Review" transition
- The `agreement_signed` field is 0 (False) — agreement has not been signed yet

**When:**
Tono attempts to click "Activate Grant" to move from "Agreement Review" to "Active"

**Then:**
- Transition is blocked — the condition `doc.agreement_signed == 1 and doc.grant_fund and doc.grant_budget_approved == 1` evaluates to False
- System shows: "Grant cannot be activated: the grant agreement must be signed before activation. Please upload the signed agreement and set 'Agreement Signed' to Yes."
- Grant remains in "Agreement Review" state

**Negative/edge case:**
- If the agreement is uploaded but `agreement_signed` checkbox is not checked, the transition is still blocked — the checkbox must be explicitly confirmed by the responsible user.

---

### [TC-GR-02] Grant Budget Line Total Cannot Exceed Grant Agreement Amount

**Given:**
- Grant Agreement for GR-2025-015 specifies total award = USD 50,000
- Finance Manager creates Grant Budget Lines:
  - Personnel: USD 25,000
  - Travel: USD 15,000
  - Equipment: USD 12,000
  - Training: USD 5,000
  - Total: USD 57,000 (exceeds USD 50,000 by USD 7,000)

**When:**
Finance Manager attempts to save or submit the Grant Budget

**Then:**
- Save is blocked with validation error: "Total Grant Budget Lines (USD 57,000) exceed the Grant Agreement amount (USD 50,000) by USD 7,000. Revise budget lines before saving."
- No budget record is created
- Finance Manager must reduce the budget lines to ≤ USD 50,000 total

**Negative/edge case:**
- If the Grant Agreement amount is later amended to USD 60,000 (donor approval), the existing budget (USD 57,000) is now within limit — the validation passes on the next save.

---

### [TC-GR-03] Grant Reporting Schedule Auto-Generated When Grant Status = Active

**Given:**
- Grant GR-2025-020 transitions from "Agreement Review" to "Active"
- The Grant Agreement specifies: quarterly narrative + financial reports (4 per year)
- Grant period: 2025-01-01 to 2025-12-31

**When:**
Finance Manager activates the grant (trigger: on_transition_to_Active server script)

**Then:**
- System automatically creates a Grant Reporting Schedule linked to GR-2025-020
- Schedule contains 4 report due dates: March 31, June 30, September 30, December 31
- Each schedule entry has: report type (Quarterly), due date, status = Pending, linked grant
- Donor Relationship Manager "Tono" receives a notification: "Grant GR-2025-020 is now Active. 4 reporting deadlines have been scheduled. First report due: 2025-03-31."
- The reporting schedule is visible in the Grant record under a "Reporting" tab

**Negative/edge case:**
- If the grant is subsequently extended (to 2026-06-30), the Reporting Schedule must be updated to add 2 more entries (March 2026, June 2026). The extension trigger must auto-append, not replace.

---

### [TC-GR-04] Grant Closeout Blocked If There Are Open Cash Advances Against the Grant

**Given:**
- Grant GR-2025-025 is in "Closing" state
- The closeout condition requires `doc.outstanding_advances == 0`
- There are 2 Cash Advances linked to Grant Fund (linked to GR-2025-025) that are in "Pending Liquidation" state:
  - ADV-100: IDR 3,000,000
  - ADV-101: IDR 1,500,000

**When:**
Finance Manager attempts to click "Close Grant" to transition from "Closing" to "Closed"

**Then:**
- Transition is blocked: "Grant cannot be closed. 2 outstanding cash advances must be resolved before closure: [ADV-100 — IDR 3,000,000 — Pending Liquidation], [ADV-101 — IDR 1,500,000 — Pending Liquidation]."
- Grant remains in "Closing" state
- The Closeout Checklist displays ADV-100 and ADV-101 as blocking items

**Negative/edge case:**
- Once both advances are liquidated and closed (status = Closed), `outstanding_advances` evaluates to 0 and the Close Grant transition becomes available.
- If there are also outstanding Purchase Invoices (outstanding_payables > 0), the transition is also blocked by that condition independently.

---

### [TC-GR-05] Grant with Multiple Budget Lines — Expense Allocation Per Line Tracked Separately

**Given:**
- Grant GR-2025-030 (Active) has the following budget lines:
  - Personnel: USD 20,000 (actual: USD 8,000)
  - Travel: USD 5,000 (actual: USD 1,500)
  - Training: USD 3,000 (actual: USD 0)
- A Cash Advance of USD 1,000 is paid against budget line "Training"

**When:**
Finance Manager opens the Grant Budget vs Actual view for GR-2025-030

**Then:**
- Budget line "Training" actual increases to USD 1,000 after the advance is paid
- Budget lines "Personnel" and "Travel" are unchanged
- Each line's available balance is computed independently: Personnel = USD 12,000, Travel = USD 3,500, Training = USD 2,000
- The Donor Report shows each line separately — expenses cannot be rolled up to a single "grant total" without the per-line breakdown also being visible

**Negative/edge case:**
- If an expense is submitted against Grant Fund GR-2025-030 without specifying a budget line, the system blocks: "Budget line is required for transactions against a restricted Grant Fund."

---

### [TC-GR-06] Grant Expiry Alert Sent to Grant Manager Before end_date

**Given:**
- Grant GR-2025-035 has end_date = 2025-12-31
- Today = 2025-12-01 (30 days before end date)
- The daily scheduled job `fundara.scheduled.grant_end_date_reminder` runs

**When:**
The scheduled job executes at end-of-day

**Then:**
- System detects GR-2025-035 end_date is within 30 days
- An in-app notification AND email is sent to Donor Relationship Manager "Tono": "Grant GR-2025-035 'USAID Health Program' is expiring on 2025-12-31 — 30 days remaining. Initiate closeout process if implementation is complete."
- Notification includes a direct link to the Grant record
- A second reminder is sent at 60 days before end_date (captured in Workflow 5 auto-actions)

**Negative/edge case:**
- If the grant is already in "Closing" or "Closed" state, no reminder is sent — the scheduled job skips grants not in Active or Extended state.
- If the grant has been extended (`end_date` updated to 2026-03-31), the reminder resets to 30 days before the new end date.

---

## TC-ORG — Organization Setup Tests

---

### [TC-ORG-01] Delegation of Authority: Delegate Can Approve Up to Specified Limit, Blocked Above It

**Given:**
- Finance Manager "Bu Lia" has delegated approval authority to Finance Officer "Dewi" for amounts up to IDR 30,000,000, effective today, valid_to = 2025-12-31
- A Delegation of Authority record exists with these parameters

**When:**
Step 1: Dewi attempts to approve a Cash Advance of IDR 25,000,000 (within delegate limit)
Step 2: Dewi attempts to approve a Cash Advance of IDR 35,000,000 (exceeds delegate limit)

**Then:**
- Step 1: Approval succeeds — Dewi is acting within her delegated authority. The record is stamped with: "Approved by: Dewi (Delegated from: Bu Lia)"
- Step 2: Approval is blocked: "This transaction (IDR 35,000,000) exceeds your delegated approval limit (IDR 30,000,000). This transaction requires the original approver (Bu Lia) or a higher authority."
- The advance in Step 2 remains in "Under Review" state

**Negative/edge case:**
- If the delegation specifies a fund restriction (e.g., "delegate authority only for Unrestricted Fund transactions"), approvals for Grant Fund transactions must be blocked even if within the IDR limit.

---

### [TC-ORG-02] Delegation Expired — Blocked Even If Role Is Correct

**Given:**
- Finance Officer "Dewi" has a Delegation of Authority record with valid_to = 2025-09-30
- Today = 2025-10-01 (one day after expiry)
- A Cash Advance of IDR 20,000,000 is in "Under Review" state

**When:**
Dewi attempts to approve the Cash Advance using her delegated authority

**Then:**
- Approval is blocked: "Your delegation of authority from Bu Lia expired on 2025-09-30. You no longer have delegated approval rights. Contact Finance Manager to renew or approve directly."
- The advance remains in "Under Review" state
- Dewi's own Finance Officer approval limit (≤ IDR 50,000,000) still applies — this test case should clarify: does the delegation extend or replace native role authority? If delegation is additive, Dewi can still approve up to her own Finance Officer limit without the delegation.

**Negative/edge case:**
- An expired delegation cannot be used. The system must check `valid_to` on every approval action, not just at delegation creation time.

---

### [TC-ORG-03] Department with Cost Center: Transactions Auto-Populate cost_center from Department

**Given:**
- Department "Program Health" has a linked Cost Center "CC-PROG-HEALTH"
- User "Andi" belongs to Department "Program Health"
- Andi creates a new Cash Advance

**When:**
Andi opens a new Cash Advance form — the `requester` field auto-fills with Andi's user

**Then:**
- The `requester_department` field auto-populates with "Program Health" (from Andi's user profile)
- The `cost_center` field auto-populates with "CC-PROG-HEALTH" (pulled from the department's linked cost center)
- Andi can override the `cost_center` value if needed (not locked)
- If Andi belongs to a department with no cost center configured, the `cost_center` field is blank and must be filled manually

**Negative/edge case:**
- If the `cost_center` field is left blank on submission for a restricted fund, validation blocks: "Cost center is required for transactions against a restricted Grant Fund."

---

### [TC-ORG-04] Two Offices Under Same Organization — Their Cost Centers Are Separate

**Given:**
- The organization has two offices: "Kantor Jakarta" and "Kantor Surabaya"
- Each office has its own Cost Center: "CC-JKT" and "CC-SBY"
- Both cost centers are under the same parent company in the ERPNext chart

**When:**
Finance Manager generates a Cost Center report or Fund Utilization Report filtered to one office

**Then:**
- Transactions tagged with "CC-JKT" appear only in the Jakarta report — they do not appear in the Surabaya report
- Transactions tagged with "CC-SBY" appear only in the Surabaya report
- An "All Offices" combined view shows transactions from both cost centers summed, with a breakdown column per cost center
- A Cash Advance created by a Jakarta-based staff member with auto-populated "CC-JKT" does not affect Surabaya's budget reporting

**Negative/edge case:**
- If a transaction is posted without a cost center (cost_center = blank), it appears in the "Unclassified" row of the cost center report and is flagged by the Data Health Check.

---

## TC-NT — Notification Tests

---

### [TC-NT-01] Cash Advance Submitted → Finance Officer Receives In-App Notification

**Given:**
- User "Budi" (Field Staff) creates Cash Advance ADV-120 and clicks "Submit for Review"
- Finance Officer "Dewi" is the designated reviewer for Budi's department

**When:**
The workflow transition from Draft to Submitted completes (server script: On transition to Submitted)

**Then:**
- Finance Officer "Dewi" receives an in-app notification (Frappe notification bell) within 30 seconds of submission
- Notification text: "Cash Advance ADV-120 submitted by Budi (IDR X,XXX,XXX). Review required. [Open ADV-120]"
- The notification includes a direct link to the advance record
- An email notification is also sent to Dewi's registered email address with the same content
- Budi does NOT receive a notification on submission (he is the submitter)

**Negative/edge case:**
- If Dewi's email is not configured in her user profile, the in-app notification still fires but the email notification fails gracefully (logged as a delivery failure, not a system error).

---

### [TC-NT-02] Cash Advance Approved → Field Staff Receives Notification

**Given:**
- Cash Advance ADV-121 submitted by "Budi" is in "Under Review" state
- Finance Officer "Dewi" approves it (status → Approved)

**When:**
The workflow transition from Under Review to Approved completes

**Then:**
- Budi receives an in-app notification: "Your Cash Advance ADV-121 (IDR X,XXX,XXX) has been approved. Payment will be processed soon."
- Budi's supervisor (Project Manager) also receives a notification: "Cash Advance ADV-121 for project [project_name] has been approved by Finance Officer."
- Finance Manager receives a notification if the advance amount is above Tier 2 (IDR 5,000,000)
- `pending_payment_flag` is set to 1 on ADV-121 automatically

**Negative/edge case:**
- If the advance is rejected instead of approved, Budi receives a rejection notification with the rejection reason included in the message body — not just a status change notification.

---

### [TC-NT-03] Cash Advance Overdue → Reminder Sent to Both Staff and Finance Officer

**Given:**
- Cash Advance ADV-130 (status = Pending Liquidation) has liquidation_due_date = 2025-09-15
- Today = 2025-09-16 (one day past due)
- Daily scheduled job runs

**When:**
The scheduled job `fundara.scheduled.advance_overdue_check` executes

**Then:**
- ADV-130 status automatically transitions to "Overdue"
- Requester "Andi" receives an urgent notification: "URGENT: Cash Advance ADV-130 (IDR X,XXX,XXX) is overdue. Liquidation was due on 2025-09-15. Submit your accountability report immediately."
- Finance Officer "Dewi" receives a notification: "Cash Advance ADV-130 for Andi is now overdue (due: 2025-09-15). Follow up required."
- The advance is highlighted in red on Dewi's dashboard and in the Advance Aging Report
- Andi is blocked from submitting new Cash Advance requests while ADV-130 is overdue

**Negative/edge case:**
- If ADV-130 was already moved to "Liquidated" or "Closed" status before the scheduled job ran, the job must skip it — do not retroactively mark a closed advance as overdue.

---

### [TC-NT-04] Grant Reporting Deadline Approaching → Grant Manager Notified N Days Before

**Given:**
- Grant GR-2025-050 has a Reporting Schedule with a quarterly report due on 2025-09-30
- Today = 2025-09-01 (29 days before deadline, within the 30-day alert window)
- Daily scheduled job `fundara.scheduled.grant_end_date_reminder` runs

**When:**
The scheduled job executes

**Then:**
- Donor Relationship Manager "Tono" receives an in-app notification: "Reminder: Quarterly donor report for Grant GR-2025-050 'USAID Health Program' is due on 2025-09-30 — 29 days remaining."
- Email notification is also sent to Tono
- The notification includes a link to the specific Reporting Schedule entry
- If the report due date passes without the report being submitted, a second notification is sent marked as overdue

**Negative/edge case:**
- If the reporting schedule entry is already marked as Submitted (report has been filed), no reminder is sent for that entry.
- Notifications should only fire once per approaching deadline per day — the scheduled job must not send duplicate notifications if run multiple times on the same day.

---

## TC-PF — Print Format Tests

---

### [TC-PF-01] Cash Advance Receipt: Shows Correct Amount, Fund Name, Purpose, Staff Name, Date

**Given:**
- Cash Advance ADV-140 has:
  - requester: "Budi Santoso"
  - fund: "USAID Health 2025"
  - purpose: "Field visit ke Puskesmas Surabaya"
  - paid_amount: USD 200.00
  - payment_date: 2025-09-10

**When:**
Finance Officer generates the Cash Advance Receipt print format for ADV-140

**Then:**
- Printed receipt contains:
  - Heading: "BUKTI UANG MUKA" (or equivalent)
  - Nama Staf: "Budi Santoso"
  - Dana: "USAID Health 2025"
  - Tujuan: "Field visit ke Puskesmas Surabaya"
  - Jumlah: "USD 200.00"
  - Tanggal Pembayaran: "10 September 2025"
  - Nomor Referensi: "ADV-140"
  - Signature area for Finance Officer and Recipient
- The receipt is formatted to A5 or A4 and printable without layout overflow
- PDF export produces a correctly formatted file

**Negative/edge case:**
- If `paid_amount` is blank (advance not yet paid), the receipt print format should either be blocked ("Receipt can only be printed for Paid advances") or show IDR 0.00 clearly marked as unpaid.

---

### [TC-PF-02] Donation Receipt: Anonymous Donor Shows "Anonim" Not Null

**Given:**
- A Donation record is linked to an anonymous donor (is_anonymous = 1)
- Donation amount: IDR 500,000, campaign: "Donasi Buku 2025", date: 2025-08-15

**When:**
Finance Officer generates the Donation Receipt print format

**Then:**
- The "Nama Donatur" field on the printed receipt shows: "Anonim"
- No null, empty space, or placeholder text like "N/A" or "undefined" appears
- All other receipt fields are correctly populated: amount, campaign, date, receipt number
- The PDF export renders "Anonim" correctly (not a rendering artifact or encoding issue)

**Negative/edge case:**
- For a non-anonymous donation, the same print format shows the actual donor name. Verify the template conditionally renders the correct value in both cases.

---

### [TC-PF-03] Fund Utilization Report Print Format: Shows Period, Fund Name, Income, Expense, Balance

**Given:**
- Grant Fund A (USD) has transactions for the period Jan–Sep 2025
- Finance Manager generates the Fund Utilization Report for this fund

**When:**
Finance Manager prints or exports the report

**Then:**
- Report header shows:
  - Organization name and logo
  - Report title: "Laporan Penggunaan Dana" (or "Fund Utilization Report")
  - Fund: "USAID Health 2025"
  - Period: "Januari 2025 — September 2025"
- Report body shows:
  - Opening Balance: USD X,XXX
  - Total Income (receipts): USD X,XXX
  - Total Expenses (paid): USD X,XXX
  - Closing Balance: USD X,XXX
  - Budget vs Actual table per budget line
- Footer shows: "Dicetak pada: [today's date]" and "Disiapkan oleh: [user name]"
- PDF export is correctly formatted with no table overflow

**Negative/edge case:**
- If the report is exported with Report Currency = IDR (not USD), all amounts are converted and the header clearly states: "Semua jumlah dalam IDR menggunakan kurs historis transaksi."

---

### [TC-PF-04] Donor Report in USD Fund: All Amounts Are in USD, Not IDR

**Given:**
- A Donor Report is generated for Grant Fund A (USD) for a donor who requires USD reporting
- Finance Manager selects: Fund = Grant Fund A, Currency = USD, Period = full year

**When:**
Finance Manager prints or exports the Donor Report

**Then:**
- Every monetary value in the report is denominated in USD
- The report currency label (e.g., column headers) shows "USD" not "IDR" or "Rp"
- The IDR equivalent of each line item is NOT shown in the main table (unless specifically requested as an additional column)
- Exchange rate footnote appears: "Exchange rates used are transaction-date rates per ERPNext Currency Exchange master."
- The total row adds up correctly in USD
- XLSX export preserves the USD formatting (not converted to IDR on export)

**Negative/edge case:**
- If any transaction in the period was entered in IDR and linked to the USD Grant Fund (cross-currency entry), the IDR amount is converted to USD using the transaction-date rate and shown in USD in the report. No IDR amounts appear in the main body.

---

## TC-MC — Multi-Currency Edge Cases

---

### [TC-MC-01] Exchange Rate Changes After Fund Opening: Historical Transactions Use Old Rate, New Ones Use New Rate

**Given:**
- Grant Fund A (USD) opened on 2025-01-01 with exchange rate: 1 USD = 15,800 IDR
- Transaction T1 posted on 2025-01-15: USD 1,000 expense (IDR equivalent: 15,800,000)
- Exchange rate updated on 2025-06-01: 1 USD = 16,200 IDR
- Transaction T2 posted on 2025-06-15: USD 1,000 expense (IDR equivalent: 16,200,000)

**When:**
Finance Manager views the Fund Utilization Report for Jan–Jun 2025 in IDR

**Then:**
- T1 is reported in IDR at 15,800,000 (the rate on the transaction date, not the current rate)
- T2 is reported in IDR at 16,200,000 (the rate on the transaction date)
- Total IDR expenses: 32,000,000 (not 32,400,000 — which would incorrectly revalue T1 at the new rate)
- The report footer notes: "All IDR amounts calculated at historical transaction-date exchange rates."

**Negative/edge case:**
- The "Revalued Balance" field on the Fund Balance panel shows the USD balance restated at the current rate (USD X × 16,200). This is clearly labeled as "Revalued" and is separate from the historical cost balance.

---

### [TC-MC-02] Cash Advance in USD from an IDR-Denominated Fund — Warning or Error

**Given:**
- Unrestricted Fund C is denominated in IDR
- Staff "Rina" attempts to create a Cash Advance: Fund = Unrestricted Fund C, Currency = USD, Amount = USD 200

**When:**
Finance Officer reviews the advance and attempts to approve it

**Then:**
- System detects a currency mismatch: the advance currency (USD) does not match the fund currency (IDR)
- A validation warning or error is shown: "Currency mismatch: Unrestricted Fund C is an IDR fund. Advances from this fund should be in IDR. To use USD, select a USD-denominated fund or create the advance in IDR with an exchange rate conversion."
- Expected outcome: either block the advance OR allow it with an explicit exchange rate entry and a conversion warning banner visible to Finance
- If allowed, the IDR equivalent is computed and the fund balance deduction is in IDR

**Negative/edge case:**
- A USD advance against a USD Grant Fund is normal and must not trigger this warning — verify the mismatch detection is fund-currency-specific.

---

### [TC-MC-03] Fund Balance Displayed in Transaction Currency AND in Base IDR Simultaneously

**Given:**
- Grant Fund A (USD) has an available balance of USD 28,450
- Current exchange rate: 1 USD = 16,500 IDR
- Finance Manager opens the Fund record

**When:**
Finance Manager views the Fund Balance panel on the Fund form

**Then:**
- Two balance lines are shown:
  - "Saldo (USD): 28,450.00" — the native fund currency balance
  - "Saldo (IDR): Rp 469,425,000" — USD 28,450 × 16,500 at today's rate
- A "Saldo Revaluasi (IDR)" or equivalent label clearly distinguishes the revalued IDR figure from the historical cost figure
- If the historical cost IDR total differs from the revalued total (because entries were posted at different rates), both are shown with a clear label explaining the difference
- Neither figure is labeled simply "Balance" without a currency qualifier

**Negative/edge case:**
- If today's exchange rate is not available (e.g., weekend and no rate set for today), the IDR balance shows the last available rate with a yellow warning: "Menggunakan kurs dari [last rate date]. Perbarui kurs untuk saldo IDR yang akurat."

---

### [TC-MC-04] Unrealized FX Gain/Loss Journal Entry Posted Correctly at Month-End

**Given:**
- Grant Fund A (USD) has a balance of USD 10,000 in the GL
- At 2025-09-30 (month-end): 1 USD = 16,300 IDR (balance: IDR 163,000,000 at revalued rate)
- At 2025-10-31 (previous month-end): 1 USD = 16,100 IDR (balance then: IDR 161,000,000)
- A month-end FX revaluation journal entry needs to be created

**When:**
Finance Manager runs the month-end FX revaluation process for September 2025

**Then:**
- System computes the unrealized FX difference: IDR 163,000,000 − IDR 161,000,000 = IDR 2,000,000 gain
- A General Journal entry is auto-created or proposed:
  - Dr: Grant Fund A (USD GL account) 2,000,000 IDR (unrealized gain side)
  - Cr: Selisih Kurs Belum Direalisasi (Unrealized FX Gain/Loss account) 2,000,000 IDR
- Journal Type = "Adjustment" or "Correction" with adjustment_reason: "Month-end FX revaluation — September 2025"
- The revaluation journal does not affect the USD balance — only the IDR equivalent is adjusted
- Finance Manager reviews and approves the journal before it is posted
- If exchange rate went the other way (loss), the debit/credit sides are reversed

**Negative/edge case:**
- If no month-end revaluation is run (Finance Manager skips it), the Data Health Check flags: "FX revaluation not performed for Grant Fund A in September 2025. Unrealized gain/loss may be understated."

---

## TC-PERF — Performance Tests (Basic)

---

### [TC-PERF-01] 50 Cash Advances Loaded in List View — Renders in Under 3 Seconds

**Given:**
- The database contains at least 50 Cash Advance records in various statuses (mixed: Draft, Approved, Paid, Closed)
- The test user has the Finance Officer role (can see all advances)
- No custom filters are applied (default list view)
- Test environment: standard development hardware or a staging server matching minimum production spec

**When:**
Finance Officer navigates to the Cash Advance list view (Fundara > Financial Accountability > Cash Advance)

**Then:**
- The list view renders fully (all 50 rows visible or paginated) within 3 seconds of the page load
- Page load time is measured from the browser's network request initiation to the last network response for the list data (DOMContentLoaded or equivalent)
- No spinner remains after 3 seconds
- List filtering (e.g., filter by status = "Paid") also renders within 3 seconds

**Negative/edge case:**
- If the list renders more than 50 records by default (e.g., page size = 100), the test should use a list of 100 records with a 5-second budget.
- Record pagination must be functional — navigating to page 2 of results must also render within 3 seconds.

---

### [TC-PERF-02] Fund Utilization Report with 1 Year of Data — Renders in Under 10 Seconds

**Given:**
- Grant Fund A has 12 months of transaction data (at least 200 individual journal entries)
- The Fund Utilization Report covers the full fiscal year (12-month period)
- Finance Manager runs the report with no filters beyond Fund name and period

**When:**
Finance Manager generates the Fund Utilization Report: Fund = Grant Fund A, Period = Jan–Dec 2025

**Then:**
- The report renders fully within 10 seconds from when the "Generate" button is clicked
- All budget lines, income, expenses, and balance totals are populated
- The report is exportable to PDF within an additional 5 seconds after render
- XLSX export is also available and completes within 5 seconds

**Negative/edge case:**
- If the report takes more than 10 seconds, the system should show a loading spinner — it must not appear to freeze or return a timeout error.
- If the period is extended to 2 years (e.g., for a multi-year grant), the performance budget extends to 20 seconds — still under a maximum acceptable threshold.
