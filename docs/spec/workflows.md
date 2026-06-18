# Fundara Workflow Configurations

**Version:** 1.0  
**Last Updated:** 2026-06-18  
**Source:** workflow.md (sections 17, 20, 7, 8, 6, 42), fundara-domain-contexts 03, 06, 07  
**Target:** ERPNext v16 / Frappe Framework Workflow JSON-compatible configuration

---

## How to Read This Document

Each section provides a Frappe Workflow-compatible configuration for one DocType workflow. The format mirrors the fields in ERPNext's **Workflow** DocType:

- **States** map to `Workflow State` child records.
- **Transitions** map to `Workflow Transition` child records.
- **Doc Status** values: `0` = Saved (not submitted), `1` = Submitted, `2` = Cancelled.
- **Style** maps to Bootstrap button/badge classes: `default`, `primary`, `success`, `warning`, `danger`, `info`.
- **Allow Edit**: Whether the document can be edited while in this state (outside of workflow transitions).
- **Condition**: A Python expression evaluated against `doc` at transition time.

---

## Approval Thresholds

These thresholds apply across all financial workflows (Cash Advance, Purchase Request, Purchase Order, Fund Allocation, Budget Revision). Amounts are in IDR equivalent; for foreign currency transactions, convert using the rate on the transaction date.

### By Transaction Amount

| Tier | Amount Range (IDR) | Minimum Approvers Required |
|---|---|---|
| Tier 1 — Small | ≤ 5,000,000 | Supervisor or Project Manager |
| Tier 2 — Medium | 5,000,001 – 50,000,000 | Project Manager + Finance Officer |
| Tier 3 — Large | 50,000,001 – 200,000,000 | Finance Manager + Department/Procurement Head |
| Tier 4 — Very Large | 200,000,001 – 500,000,000 | Finance Manager + Management/Executive |
| Tier 5 — Strategic | > 500,000,000 | Executive Director + Board (if applicable) |

> **Implementation note:** These tiers are configurable in a custom DocType called `Procurement Threshold Rule`. Workflows reference the tier symbolically; the actual IDR values can be changed without redeploying workflow JSON.

### By Fund Type (Additional Controls)

| Fund Type | Additional Approval Required |
|---|---|
| Grant Fund | Donor Relationship Manager must review for compliance with donor rules before Finance approval |
| Campaign Fund | Fundraising Officer must confirm fund is available within campaign scope |
| Reserve Fund | Executive Director approval required regardless of amount |
| Bridging Fund | Finance Manager + Executive Director required; settlement plan must exist |
| Board-designated Fund | Executive Director approval required; Board notification sent |

### Budget Revision Thresholds

| Change Magnitude | Approval Level |
|---|---|
| ≤ 10% of line item, no change to total | Project Manager + Finance Officer |
| > 10% of line item or total budget unchanged | Finance Manager |
| Change in total budget or new budget line added | Finance Manager + Program/Grant Manager |
| Donor-funded grant budget revision | Donor Relationship Manager + Management approval; donor notification may be required |

---

## Workflow 1: Cash Advance

**DocType:** Cash Advance  
**Is Active:** Yes  
**Send Email Alerts:** Yes  
**Override Status:** Yes (workflow state overrides document status display)

### States

| State | Doc Status | Style | Allow Edit | Description |
|---|---|---|---|---|
| Draft | 0 (Saved) | default | Yes | Requester is composing the advance request |
| Submitted | 0 | primary | No | Request sent to supervisor/project manager for review |
| Under Review | 0 | info | No | Finance Officer is reviewing for budget and eligibility |
| Approved | 0 | success | No | Advance approved; pending payment disbursement |
| Paid | 1 | success | No | Cash disbursed to requester; liquidation clock starts |
| Pending Liquidation | 1 | warning | No | Awaiting accountability submission from requester |
| Overdue | 1 | danger | No | Liquidation due date has passed without submission |
| Liquidated | 1 | info | No | Accountability submitted; Finance is reviewing |
| Closed | 1 | success | No | Advance fully settled (refund/reimbursement resolved) |
| Rejected | 2 | danger | No | Request denied; requester notified |
| Cancelled | 2 | danger | No | Advance cancelled before payment |

### Transitions

| From State | To State | Action Label | Allowed Roles | Condition |
|---|---|---|---|---|
| Draft | Submitted | Submit for Review | Field Staff, Finance Officer, Project Manager | `doc.amount_requested > 0 and doc.fund and doc.activity` |
| Submitted | Under Review | Begin Review | Finance Officer, Finance Manager | — |
| Submitted | Rejected | Reject | Project Manager, Finance Officer, Finance Manager | — |
| Submitted | Draft | Return for Revision | Project Manager, Finance Officer, Finance Manager | — |
| Under Review | Approved | Approve | Finance Officer (≤ 50 M IDR), Finance Manager (> 50 M IDR) | `doc.budget_available == 1` |
| Under Review | Rejected | Reject | Finance Officer, Finance Manager | — |
| Under Review | Draft | Return for Revision | Finance Officer, Finance Manager | — |
| Approved | Paid | Mark as Paid | Finance Officer, Finance Manager | `doc.payment_reference` |
| Approved | Cancelled | Cancel | Finance Manager | — |
| Paid | Pending Liquidation | Set Pending Liquidation | System (auto on payment) | — |
| Pending Liquidation | Liquidated | Submit Liquidation | Field Staff, Finance Officer | `doc.liquidation_submitted == 1` |
| Pending Liquidation | Overdue | Mark Overdue | System (scheduled job) | `doc.liquidation_due_date < today` |
| Overdue | Liquidated | Submit Liquidation (Late) | Field Staff, Finance Officer | `doc.liquidation_submitted == 1` |
| Liquidated | Closed | Close Advance | Finance Officer, Finance Manager | `doc.refund_settled == 1 or doc.reimbursement_settled == 1 or doc.net_difference == 0` |
| Liquidated | Pending Liquidation | Return for Revision | Finance Officer, Finance Manager | — |

### Auto-actions (Server Script Triggers)

| Trigger | Action |
|---|---|
| On transition to Submitted | Send notification to Project Manager and Finance Officer |
| On transition to Approved | Send notification to requester; set `pending_payment_flag = 1` |
| On transition to Paid | Set `pending_payment_flag = 0`; set `liquidation_due_date` based on org policy; debit Advance account, credit Bank/Cash |
| On transition to Pending Liquidation | Set `aging_start_date = today`; send reminder to requester |
| On transition to Overdue | Send urgent notification to requester, Project Manager, and Finance Manager; set `overdue_flag = 1`; block new advance requests for requester |
| On transition to Liquidated | Post actual expense entries; reverse advance receivable; calculate refund or reimbursement due |
| On transition to Closed | Update fund balance (actual); clear advance from aging report; unblock requester for new advances if no other overdue |
| On transition to Rejected | Send notification to requester with rejection reason |
| On transition to Cancelled | Reverse any payment entry if disbursed; restore budget commitment |
| Daily scheduled job | Check all `Pending Liquidation` advances; transition to Overdue if `liquidation_due_date < today` |

---

## Workflow 2: Purchase Request

**DocType:** Purchase Request  
**Is Active:** Yes  
**Send Email Alerts:** Yes  
**Override Status:** Yes

### States

| State | Doc Status | Style | Allow Edit | Description |
|---|---|---|---|---|
| Draft | 0 | default | Yes | Requester composing purchase request |
| Submitted | 0 | primary | No | Awaiting manager review and budget check |
| Under Review | 0 | info | No | Budget check and compliance review in progress |
| Approved | 0 | success | No | PR approved; procurement can proceed |
| Ordered | 1 | info | No | Purchase Order has been created from this PR |
| Completed | 1 | success | No | Goods/service received and invoice settled |
| Cancelled | 2 | danger | No | PR cancelled |

### Transitions

| From State | To State | Action Label | Allowed Roles | Condition |
|---|---|---|---|---|
| Draft | Submitted | Submit for Approval | Field Staff, Project Manager, Finance Officer, Procurement Officer | `doc.fund and doc.budget_line and doc.estimated_amount > 0` |
| Submitted | Under Review | Begin Review | Finance Officer, Finance Manager, Project Manager | — |
| Submitted | Draft | Return for Revision | Project Manager, Finance Officer, Finance Manager | — |
| Submitted | Cancelled | Cancel | Finance Manager, System Admin | — |
| Under Review | Approved | Approve | Project Manager (Tier 1–2), Finance Manager (Tier 3–4), Management (Tier 5) | `doc.budget_available == 1 and doc.fund_restriction_ok == 1` |
| Under Review | Draft | Return for Revision | Finance Officer, Finance Manager, Project Manager | — |
| Under Review | Cancelled | Cancel | Finance Manager | — |
| Approved | Ordered | Create PO | Procurement Officer | `doc.purchase_order` |
| Ordered | Completed | Mark Completed | Procurement Officer, Finance Officer | `doc.goods_received == 1 and doc.invoice_paid == 1` |
| Ordered | Cancelled | Cancel Order | Finance Manager, Procurement Officer | — |

### Auto-actions (Server Script Triggers)

| Trigger | Action |
|---|---|
| On transition to Submitted | Send notification to Project Manager and Finance Officer; run budget availability check |
| On transition to Under Review | Determine procurement method based on `estimated_amount` and `Procurement Threshold Rule`; set `procurement_method` field |
| On transition to Approved | Create Commitment record reducing available budget; send notification to Procurement Officer |
| On transition to Ordered | Link Purchase Order; update Commitment to reference PO |
| On transition to Completed | Clear commitment; update fund balance with actual expense; notify requester |
| On transition to Cancelled | Reverse commitment if any; restore available budget |

---

## Workflow 3: Purchase Order

**DocType:** Purchase Order  
**Is Active:** Yes  
**Send Email Alerts:** Yes  
**Override Status:** Yes

### States

| State | Doc Status | Style | Allow Edit | Description |
|---|---|---|---|---|
| Draft | 0 | default | Yes | Procurement Officer drafting the PO |
| Submitted | 0 | primary | No | PO submitted for internal approval |
| Approved | 0 | success | No | PO approved; can be sent to vendor |
| Ordered | 1 | info | No | PO issued to vendor; awaiting delivery |
| Partially Received | 1 | warning | No | Some goods/services received; delivery ongoing |
| Completed | 1 | success | No | Full delivery confirmed; invoice matched |
| Cancelled | 2 | danger | No | PO cancelled |

### Transitions

| From State | To State | Action Label | Allowed Roles | Condition |
|---|---|---|---|---|
| Draft | Submitted | Submit for Approval | Procurement Officer | `doc.vendor and doc.purchase_request and doc.total_amount > 0` |
| Submitted | Approved | Approve | Finance Officer (≤ 100 M IDR), Finance Manager (> 100 M IDR), Management (> 200 M IDR) | `doc.vendor_approved == 1 and (doc.bid_analysis or doc.single_source_justification)` |
| Submitted | Draft | Return for Revision | Finance Officer, Finance Manager | — |
| Submitted | Cancelled | Cancel | Finance Manager | — |
| Approved | Ordered | Issue to Vendor | Procurement Officer | `doc.vendor_confirmation_date` |
| Ordered | Partially Received | Record Partial Receipt | Procurement Officer, Finance Officer | `doc.goods_receipt_partial == 1` |
| Ordered | Completed | Confirm Full Receipt | Procurement Officer, Finance Officer | `doc.goods_received == 1 and doc.invoice_matched == 1` |
| Partially Received | Completed | Confirm Completion | Procurement Officer, Finance Officer | `doc.goods_received == 1 and doc.invoice_matched == 1` |
| Ordered | Cancelled | Cancel Order | Finance Manager, Procurement Officer | — |
| Partially Received | Cancelled | Cancel Remaining | Finance Manager | — |

### Auto-actions (Server Script Triggers)

| Trigger | Action |
|---|---|
| On transition to Submitted | Validate vendor status (`vendor_approved == 1`); check if bid analysis required; notify Finance |
| On transition to Approved | Update Commitment; send PO document notification to Procurement Officer |
| On transition to Ordered | Lock PO for editing; send notification to vendor contact (if email configured); update Purchase Request status to Ordered |
| On transition to Partially Received | Update delivery percentage; alert Procurement Officer if overdue |
| On transition to Completed | Post Purchase Invoice as actual expense; reduce budget commitment; update fund balance; archive supporting documents; update Purchase Request to Completed |
| On transition to Cancelled | Reverse commitment; notify Finance Manager; update linked Purchase Request |

---

## Workflow 4: Fund Allocation

**DocType:** Fund Allocation  
**Is Active:** Yes  
**Send Email Alerts:** Yes  
**Override Status:** Yes

### States

| State | Doc Status | Style | Allow Edit | Description |
|---|---|---|---|---|
| Draft | 0 | default | Yes | Finance or Program composing the allocation |
| Submitted | 0 | primary | No | Submitted for Finance review |
| Approved | 0 | success | No | Allocation approved; not yet activated |
| Active | 1 | success | No | Allocation active; budget committed to target |
| Revised | 1 | warning | No | Allocation has been amended; previous version archived |
| Closed | 2 | default | No | Allocation period ended or fund closed |

### Transitions

| From State | To State | Action Label | Allowed Roles | Condition |
|---|---|---|---|---|
| Draft | Submitted | Submit for Review | Finance Officer, Program Manager, Project Manager | `doc.fund and doc.allocated_to_reference and doc.amount > 0` |
| Submitted | Approved | Approve Allocation | Finance Manager | `doc.fund_available_balance >= doc.amount and doc.fund_restriction_ok == 1` |
| Submitted | Draft | Return for Revision | Finance Officer, Finance Manager | — |
| Approved | Active | Activate | Finance Officer, Finance Manager | — |
| Active | Revised | Revise Allocation | Finance Manager | `doc.revision_justification` |
| Active | Closed | Close Allocation | Finance Manager | `doc.outstanding_commitments == 0` |
| Revised | Active | Activate Revision | Finance Manager | — |
| Revised | Closed | Close Allocation | Finance Manager | — |

### Auto-actions (Server Script Triggers)

| Trigger | Action |
|---|---|
| On transition to Submitted | Check fund availability; flag if `amount > fund.available_balance`; notify Finance Manager |
| On transition to Approved | Reserve amount from Fund (reduce `available_balance`; increase `allocated_amount`) |
| On transition to Active | Create budget lines in target Project/Activity; send notification to Project Manager |
| On transition to Revised | Archive current version with timestamp; create new version record; notify Finance Manager |
| On transition to Closed | Release any uncommitted reserved amounts back to fund; update Fund Balance snapshot |

---

## Workflow 5: Grant

**DocType:** Grant  
**Is Active:** Yes  
**Send Email Alerts:** Yes  
**Override Status:** Yes

### States

| State | Doc Status | Style | Allow Edit | Description |
|---|---|---|---|---|
| Pipeline | 0 | default | Yes | Grant opportunity identified; proposal in progress |
| Submitted | 0 | primary | No | Proposal submitted to donor; awaiting decision |
| Awarded | 0 | success | No | Donor notified award; agreement not yet signed |
| Agreement Review | 0 | info | No | Grant agreement under legal/finance/management review |
| Active | 1 | success | No | Agreement signed; Grant Fund activated; implementation underway |
| Extended | 1 | warning | No | Grant period extended by donor amendment |
| Suspended | 1 | danger | No | Grant suspended by donor or management |
| Closing | 1 | warning | No | Grant closing process initiated; closeout checklist active |
| Closed | 2 | default | No | Grant fully closed; all obligations settled and reported |
| Rejected | 2 | danger | No | Donor rejected proposal or award was revoked |
| Cancelled | 2 | danger | No | Grant cancelled by organization before award |

### Transitions

| From State | To State | Action Label | Allowed Roles | Condition |
|---|---|---|---|---|
| Pipeline | Submitted | Mark as Submitted to Donor | Donor Relationship Manager | `doc.proposal_reference and doc.submission_date` |
| Pipeline | Cancelled | Cancel Pursuit | Program Manager, Donor Relationship Manager | — |
| Submitted | Awarded | Record Award | Donor Relationship Manager, Management | `doc.award_notice_reference` |
| Submitted | Rejected | Record Rejection | Donor Relationship Manager | — |
| Submitted | Cancelled | Cancel | Donor Relationship Manager | — |
| Awarded | Agreement Review | Begin Agreement Review | Donor Relationship Manager, Finance Manager, Management | `doc.grant_agreement` |
| Agreement Review | Active | Activate Grant | Finance Manager, Management | `doc.agreement_signed == 1 and doc.grant_fund and doc.grant_budget_approved == 1` |
| Agreement Review | Awarded | Return to Negotiation | Management, Donor Relationship Manager | — |
| Active | Extended | Extend Grant | Donor Relationship Manager, Finance Manager | `doc.extension_approval_reference and doc.new_end_date > doc.end_date` |
| Active | Suspended | Suspend Grant | Finance Manager, Management | `doc.suspension_reason` |
| Active | Closing | Initiate Closeout | Donor Relationship Manager, Finance Manager | `doc.closeout_checklist_started == 1` |
| Extended | Closing | Initiate Closeout | Donor Relationship Manager, Finance Manager | `doc.closeout_checklist_started == 1` |
| Extended | Suspended | Suspend Grant | Finance Manager, Management | `doc.suspension_reason` |
| Suspended | Active | Reinstate Grant | Finance Manager, Management | `doc.reinstatement_approval` |
| Suspended | Closing | Initiate Closeout | Management | — |
| Closing | Closed | Close Grant | Finance Manager, Management | `doc.final_report_submitted == 1 and doc.outstanding_advances == 0 and doc.outstanding_payables == 0 and doc.missing_evidence == 0` |
| Closing | Active | Reopen (Exception) | Management | `doc.closeout_reversal_reason` |

### Auto-actions (Server Script Triggers)

| Trigger | Action |
|---|---|
| On transition to Awarded | Notify Finance Manager and Management to begin agreement review preparation |
| On transition to Active | Create Grant Fund record (if not exists); activate Grant Budget Lines; set Grant Reporting Schedule; notify Project Manager and Finance Manager |
| On transition to Extended | Update `end_date`; extend Grant Fund period; update Reporting Schedule; notify Project Manager |
| On transition to Suspended | Block new transactions against Grant Fund; notify all linked Project Managers and Finance Manager |
| On transition to Closing | Activate Closeout Checklist; freeze new commitments; run outstanding advance check; notify Donor Relationship Manager |
| On transition to Closed | Set Grant Fund status to Closed; block all new transactions; archive all documents; send closure notification to Donor Relationship Manager |
| 30 days before `end_date` | Send reminder to Donor Relationship Manager, Project Manager, Finance Manager: "Grant nearing end date" |
| 60 days before `end_date` | Send reminder to Donor Relationship Manager: "Donor report due soon — check Reporting Schedule" |

---

## Workflow 6: Fundraising Campaign

**DocType:** Fundraising Campaign  
**Is Active:** Yes  
**Send Email Alerts:** Yes  
**Override Status:** Yes

### States

| State | Doc Status | Style | Allow Edit | Description |
|---|---|---|---|---|
| Draft | 0 | default | Yes | Fundraising Officer composing campaign proposal |
| Under Review | 0 | info | No | Finance and Program reviewing campaign purpose and budget |
| Approved | 0 | success | No | Campaign approved by Management; ready to launch |
| Active | 1 | success | No | Campaign launched; donation collection open |
| Paused | 1 | warning | No | Campaign temporarily suspended |
| Completed | 1 | info | No | Campaign collection period ended; awaiting reporting |
| Reporting | 1 | primary | No | Campaign report being prepared |
| Closed | 2 | default | No | Campaign fully closed; report submitted and fund settled |
| Cancelled | 2 | danger | No | Campaign cancelled before or during launch |

### Transitions

| From State | To State | Action Label | Allowed Roles | Condition |
|---|---|---|---|---|
| Draft | Under Review | Submit for Review | Fundraising Officer | `doc.campaign_purpose and doc.target_amount > 0 and doc.start_date and doc.end_date` |
| Draft | Cancelled | Cancel Draft | Fundraising Officer, Program Manager | — |
| Under Review | Approved | Approve Campaign | Management, Program Manager | `doc.finance_reviewed == 1 and doc.purpose_restriction_defined == 1` |
| Under Review | Draft | Return for Revision | Program Manager, Finance Manager, Management | — |
| Under Review | Cancelled | Cancel | Management | — |
| Approved | Active | Launch Campaign | Fundraising Officer | `doc.launch_date <= today and doc.campaign_fund` |
| Approved | Cancelled | Cancel Before Launch | Management | — |
| Active | Paused | Pause Campaign | Fundraising Officer, Program Manager, Management | `doc.pause_reason` |
| Active | Completed | End Collection Period | Fundraising Officer, Finance Officer | `doc.end_date <= today` |
| Active | Cancelled | Cancel Active Campaign | Management | `doc.cancellation_approval` |
| Paused | Active | Resume Campaign | Fundraising Officer, Management | — |
| Paused | Completed | End Campaign | Fundraising Officer, Management | — |
| Paused | Cancelled | Cancel | Management | `doc.cancellation_approval` |
| Completed | Reporting | Begin Reporting | Fundraising Officer, Finance Officer | `doc.final_donation_total_verified == 1` |
| Reporting | Closed | Close Campaign | Finance Manager, Management | `doc.campaign_report_submitted == 1 and doc.remaining_balance_decision_made == 1 and doc.finance_reviewed == 1` |
| Reporting | Completed | Return to Completion | Finance Officer | — |

### Auto-actions (Server Script Triggers)

| Trigger | Action |
|---|---|
| On transition to Approved | Send notification to Fundraising Officer; create Campaign Fund record (if not exists) |
| On transition to Active | Open Campaign Fund for donation posting; notify Finance Officer; publish campaign status |
| On transition to Paused | Block new donation entries; notify Finance Officer and Program Manager |
| On transition to Completed | Lock donation entry; calculate gross donations, fundraising cost, net available fund; notify Fundraising Officer and Finance Officer to begin reporting |
| On transition to Reporting | Generate Campaign Utilization Summary; notify Finance Officer to review; set `finance_reviewed = 0` |
| On transition to Closed | Set Campaign Fund status to Closed; post remaining balance decision (return/retain/transfer); archive campaign documents; send notification to Management |
| On transition to Cancelled | Refund process triggered if donations received (manual review required); notify Finance Manager |
| Daily check on Active campaigns | Alert Fundraising Officer if `end_date < today + 7 days`: "Campaign ending soon" |

---

## Common Workflow Implementation Notes

### Frappe Workflow JSON Template

Each workflow above can be translated to a Frappe Workflow document with this structure:

```json
{
  "doctype": "Workflow",
  "name": "[Workflow Name]",
  "document_type": "[DocType]",
  "is_active": 1,
  "send_email_alert": 1,
  "workflow_state_field": "workflow_state",
  "states": [
    {
      "state": "Draft",
      "doc_status": "0",
      "style": "default",
      "allow_edit": "System Manager"
    }
  ],
  "transitions": [
    {
      "state": "Draft",
      "action": "Submit for Review",
      "next_state": "Submitted",
      "allowed": "Field Staff",
      "condition": "doc.amount > 0"
    }
  ]
}
```

### Workflow State Field

Add a `workflow_state` custom field (type: Data, read-only) to each DocType. This field stores the current Frappe Workflow state label and is separate from the native `docstatus` field.

### Status Field vs Workflow State

In Fundara, each DocType has two status-related fields:

| Field | Source | Purpose |
|---|---|---|
| `docstatus` | ERPNext native | 0 = Saved, 1 = Submitted, 2 = Cancelled |
| `workflow_state` | Frappe Workflow | Human-readable current state (e.g., "Pending Liquidation") |
| `status` (custom) | Server script | Derived display status for dashboards and list views |

### Email Notification Template

Use Frappe's `Notification` DocType to configure email alerts per workflow event. Each notification should include:

- Document type and number
- Current state
- Action taken (who approved/rejected)
- Link to the document in Fundara
- Next required action

### Server Script Hooks for Auto-actions

Implement auto-actions using Frappe Server Scripts with trigger type `"DocType Event"` set to `"on_update"`. Check `doc.workflow_state` to determine which state was just entered, and guard against re-running with a flag field (e.g., `advance_paid_flag`).

Example pattern:

```python
if doc.workflow_state == "Paid" and not doc.advance_paid_flag:
    # post payment entry
    # update fund balance
    doc.advance_paid_flag = 1
    doc.save()
```

### Scheduled Jobs for Overdue/Deadline Checks

Register cron jobs in `hooks.py` under `scheduler_events`:

```python
scheduler_events = {
    "daily": [
        "fundara.scheduled.advance_overdue_check",
        "fundara.scheduled.grant_end_date_reminder",
        "fundara.scheduled.campaign_end_date_reminder",
    ]
}
```

Each job queries the relevant DocType, checks date conditions, and calls `frappe.workflow.apply_workflow(doc, "Mark Overdue")` or sends a notification as appropriate.
