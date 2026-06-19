# Fundara Status Color Coding

**Version:** 1.0  
**Last Updated:** 2026-06-19  
**Audience:** Frontend Developer  
**Platform:** ERPNext v16 / Frappe Framework  

---

## How to Read This Document

Frappe renders workflow state indicators as colored dot-and-label badges in list views and form headers. These are configured via the `indicator_color` field on `Workflow State` records and/or via a custom `get_indicator` hook in the DocType controller.

### Frappe Indicator Color Reference

| Color Keyword | Bootstrap / CSS Class | Typical Semantic Meaning |
|---|---|---|
| `grey` | `.indicator.grey` | Draft, not yet submitted, no action needed |
| `blue` | `.indicator.blue` | Active processing, submitted, in progress |
| `orange` | `.indicator.orange` | Pending external action, waiting for someone else |
| `yellow` | `.indicator.yellow` | Warning, approaching a limit or deadline |
| `green` | `.indicator.green` | Completed, approved, paid, closed successfully |
| `red` | `.indicator.red` | Overdue, rejected, cancelled, compliance failure |
| `purple` | `.indicator.purple` | Special or exceptional state, board-level |
| `darkgrey` | `.indicator.darkgrey` | Archived, historically closed, no further action |

### Implementation Method

Each DocType can define its indicator color in two ways:

1. **Frappe Workflow State color** — set the `style` field on each `Workflow State` record. Frappe maps styles to indicators: `default` → grey, `primary` → blue, `success` → green, `warning` → orange/yellow, `danger` → red, `info` → blue.

2. **`get_indicator` controller hook** — override in Python for fine-grained control:

```python
@staticmethod
def get_indicator(doc, user):
    if doc.workflow_state == "Overdue":
        return [_("Overdue"), "red", "workflow_state,=,Overdue"]
    if doc.workflow_state == "Paid":
        return [_("Paid"), "green", "workflow_state,=,Paid"]
    # fallback
    return None
```

Use method 2 for DocTypes where the same workflow_state should show differently depending on additional field values (e.g., a "Closed" grant that was rejected vs. one that completed cleanly).

---

## Global Color Rules

These rules are applied consistently across all DocTypes. When in doubt, follow these rules before consulting the per-DocType table.

**Red always means:**
- The document is overdue (deadline has passed without required action)
- The document was rejected by an approver
- The document was cancelled after previously having financial impact
- A compliance or budget exception is blocking progress
- A fund has a negative balance

**Green always means:**
- The document has been fully approved and is financially active (Active, Approved for spending)
- The document has been successfully completed and all financial obligations settled (Paid, Closed, Completed)
- A campaign has reached or exceeded its target

**Orange always means:**
- The document is in a transitional state awaiting an external party's action (Pending Liquidation, Pending Payment, Reporting)
- A document is approaching a deadline but has not yet breached it (nearing end date, budget utilization > 75%)

**Blue always means:**
- The document is under active internal review or processing (Under Review, Liquidated pending final review)
- The document has been submitted and is in the approval queue (Submitted state)
- The document is in active implementation (In Progress)

**Yellow means:**
- The document has been extended or revised — still valid but changed from the original (Extended grant, Revised allocation)
- A campaign is paused — still alive but not collecting
- Partially completed (Partially Received on a PO)

**Purple means:**
- Reserved for board-level or strategic states that require executive or board attention (board-designated fund activation, reserve fund drawdown approval pending)

**Darkgrey means:**
- The document is archived, historically closed, or read-only with no further workflow action possible

---

## How Overdue Items Are Surfaced

Overdue status is computed by a **daily scheduled job** (`fundara.scheduled.*_overdue_check`) that runs at midnight and transitions qualifying documents. Once transitioned, the system:

1. Sets `workflow_state = "Overdue"` on the document
2. Sets `indicator_color = "red"` via the `get_indicator` hook
3. Sets a flag field (e.g., `overdue_flag = 1`) for efficient list view filtering
4. Sends an urgent notification to the responsible staff, their supervisor, and the Finance Manager
5. In the case of Cash Advance: blocks the requester from submitting new advance requests

In list views, overdue rows are highlighted with a red row background (see List View Highlight Rules section below). In forms, the workflow state badge renders in red with the label "Overdue."

---

## DocType: Fund

| Status (workflow_state) | Indicator Color | Label Shown in List | Notes |
|---|---|---|---|
| Draft | grey | Draft | Fund is being configured; cannot accept transactions |
| Submitted | blue | Pending Approval | Submitted for Finance Manager review |
| Approved | blue | Approved | Approved but not yet activated by Finance Officer |
| Active | green | Active | Fund is live; transactions can be posted against it |
| Closing | yellow | Closing | Closeout process initiated; new commitments blocked |
| Closed | darkgrey | Closed | Fund fully closed; no new transactions allowed |
| Suspended | red | Suspended | Fund suspended; transactions blocked |
| Rejected | red | Rejected | Fund activation rejected |

**Additional field indicators:**

| Condition | Indicator on Fund record | Color |
|---|---|---|
| `end_date <= today + 30` and `status == "Active"` | "Expiring Soon" badge | yellow |
| `end_date < today` and `status == "Active"` | "Expired" badge | red |
| Fund balance < 0 | "Negative Balance" badge | red |
| `restriction_type == "Restricted"` | "Restricted" tag | purple |
| `restriction_type == "Board-designated"` | "Board-designated" tag | purple |

---

## DocType: Cash Advance

| Status (workflow_state) | Indicator Color | Label Shown in List | Notes |
|---|---|---|---|
| Draft | grey | Draft | Requester is composing; not yet submitted |
| Submitted | blue | Pending Review | Awaiting Project Manager / Finance Officer action |
| Under Review | blue | Under Review | Finance Officer is reviewing |
| Approved | green | Approved | Approved; pending cash disbursement |
| Paid | green | Paid | Cash disbursed; liquidation countdown started |
| Pending Liquidation | orange | Pending Liquidation | Awaiting accountability from requester |
| Overdue | red | Overdue | Liquidation due date passed; requester blocked |
| Liquidated | blue | Liquidated — Under Review | Evidence submitted; Finance is reviewing |
| Closed | darkgrey | Closed | Advance fully settled (refund/reimbursement done) |
| Rejected | red | Rejected | Request denied |
| Cancelled | red | Cancelled | Cancelled before or after payment |

**Computed badges on the form (not workflow_state — derived from fields):**

| Condition | Badge Label | Color |
|---|---|---|
| `liquidation_due_date <= today + 3` and state == "Pending Liquidation" | "Due Soon" | yellow |
| `evidence_complete == 0` and state == "Liquidated" | "Missing Evidence" | red |
| `net_difference > 0` (actual < advance) | "Refund Required: [Amount]" | orange |
| `net_difference < 0` (actual > advance) | "Reimbursement Required: [Amount]" | orange |

---

## DocType: Advance Liquidation

| Status (workflow_state) | Indicator Color | Label Shown in List | Notes |
|---|---|---|---|
| Draft | grey | Draft | Staff is filling in expense details |
| Submitted | blue | Pending Review | Submitted to Finance for completeness check |
| Under Finance Review | blue | Under Review | Finance Officer reviewing evidence and amounts |
| Returned for Revision | orange | Returned | Finance has returned for correction; requester must revise |
| Approved | green | Approved | Approved; expense posting pending |
| Refund Required | orange | Refund Required | Actual < Advance; staff must return excess cash |
| Reimbursement Required | orange | Reimbursement Required | Actual > Advance; Finance must reimburse shortfall |
| Posted | green | Posted | Expense posted to GL; advance receivable reversed |
| Closed | darkgrey | Closed | All financial obligations settled |
| Rejected | red | Rejected | Liquidation rejected; advance remains outstanding |

---

## DocType: Grant

| Status (workflow_state) | Indicator Color | Label Shown in List | Notes |
|---|---|---|---|
| Pipeline | grey | Pipeline | Grant opportunity; proposal in progress |
| Submitted | blue | Submitted to Donor | Proposal submitted; awaiting donor decision |
| Awarded | green | Awarded | Donor notified of award; agreement not yet signed |
| Agreement Review | blue | Agreement Review | Contract under legal/finance review |
| Active | green | Active | Agreement signed; implementation underway |
| Extended | yellow | Extended | Grant period extended by donor amendment |
| Suspended | red | Suspended | Grant suspended; new transactions blocked |
| Closing | yellow | Closing | Closeout checklist active; final reporting in progress |
| Closed | darkgrey | Closed | Grant fully closed; all obligations settled |
| Rejected | red | Rejected | Proposal rejected or award revoked |
| Cancelled | red | Cancelled | Cancelled by organization |

**Additional computed badges:**

| Condition | Badge Label | Color |
|---|---|---|
| `end_date <= today + 30` and state in ["Active", "Extended"] | "Ending Soon" | yellow |
| `end_date <= today + 7` and state in ["Active", "Extended"] | "Ending in [N] Days" | red |
| `closeout_checklist_started == 0` and state == "Closing" | "Checklist Not Started" | red |
| Overdue donor report linked to this grant | "Report Overdue" | red |

---

## DocType: Grant Reporting Schedule

| Status | Indicator Color | Label Shown in List | Notes |
|---|---|---|---|
| Upcoming | grey | Upcoming | Report period has not opened yet |
| Due | orange | Due | Report period is open; submission expected |
| Overdue | red | Overdue | Due date passed without submission |
| In Preparation | blue | In Preparation | Finance/Program is drafting the report |
| Submitted | green | Submitted | Report submitted to donor |
| Accepted | green | Accepted | Donor acknowledged and accepted report |
| Revision Required | orange | Revision Required | Donor requested revision |
| Closed | darkgrey | Closed | Report cycle fully complete |

**Computed badge — Days Remaining:**

| Condition | Badge | Color |
|---|---|---|
| `due_date <= today + 14` and status in ["Upcoming", "Due"] | "[N] days to deadline" | yellow |
| `due_date <= today + 7` and status in ["Upcoming", "Due"] | "[N] days to deadline" | orange |
| `due_date <= today + 3` and status in ["Upcoming", "Due"] | "[N] days to deadline — Urgent" | red |

---

## DocType: Purchase Request

| Status (workflow_state) | Indicator Color | Label Shown in List | Notes |
|---|---|---|---|
| Draft | grey | Draft | Requester composing |
| Submitted | blue | Pending Approval | Awaiting manager review |
| Under Review | blue | Under Review | Budget and compliance check in progress |
| Budget Exception | red | Budget Exception | Budget insufficient; exception approval needed |
| Approved | green | Approved | PR approved; procurement can proceed |
| Ordered | blue | PO Created | Purchase Order has been created |
| Partially Received | yellow | Partially Received | Some goods/services received; delivery ongoing |
| Completed | darkgrey | Completed | Fully received and invoice settled |
| Cancelled | red | Cancelled | PR cancelled |

---

## DocType: Purchase Order (Fundara)

This refers to the custom Fundara Purchase Order, which may wrap or extend ERPNext's native Purchase Order.

| Status (workflow_state) | Indicator Color | Label Shown in List | Notes |
|---|---|---|---|
| Draft | grey | Draft | Procurement Officer drafting |
| Submitted | blue | Pending Approval | Submitted for Finance review |
| Approved | green | Approved | Approved; ready to issue to vendor |
| Ordered | blue | Ordered — Awaiting Delivery | Issued to vendor; delivery pending |
| Partially Received | yellow | Partially Received | Delivery in progress |
| Completed | green | Completed | Full delivery; invoice matched and paid |
| Cancelled | red | Cancelled | PO cancelled |

**Additional badges:**

| Condition | Badge | Color |
|---|---|---|
| `vendor_approved == 0` | "Vendor Not Approved" | red |
| `bid_analysis` missing and threshold requires it | "Bid Analysis Required" | orange |
| Delivery date passed and status == "Ordered" | "Delivery Overdue" | red |

---

## DocType: Fund Allocation

| Status (workflow_state) | Indicator Color | Label Shown in List | Notes |
|---|---|---|---|
| Draft | grey | Draft | Finance/Program composing |
| Submitted | blue | Pending Review | Submitted for Finance Manager review |
| Approved | blue | Approved — Not Yet Active | Approved but not yet activated |
| Active | green | Active | Budget committed to target project/activity |
| Revised | yellow | Revised | Allocation amended; previous version archived |
| Closed | darkgrey | Closed | Allocation period ended or fund closed |

---

## DocType: Fundraising Campaign

| Status (workflow_state) | Indicator Color | Label Shown in List | Notes |
|---|---|---|---|
| Draft | grey | Draft | Campaign proposal being composed |
| Under Review | blue | Under Review | Finance and Program reviewing |
| Approved | green | Approved — Not Yet Live | Campaign approved; not yet launched |
| Active | green | Active | Campaign live; donations being collected |
| Paused | yellow | Paused | Temporarily suspended |
| Completed | blue | Collection Ended | Donation period closed; reporting pending |
| Reporting | blue | Reporting | Campaign report being prepared |
| Closed | darkgrey | Closed | Report submitted; fund settled |
| Cancelled | red | Cancelled | Campaign cancelled |

**Additional computed badges:**

| Condition | Badge | Color |
|---|---|---|
| `collected_amount >= target_amount` | "Target Reached" | green |
| `(collected_amount / target_amount) < 0.5` and `end_date <= today + 14` | "Below Target — [X]% Reached" | orange |
| `end_date <= today + 7` and state == "Active" | "Ending in [N] Days" | yellow |
| `workflow_state == "Completed"` and no Campaign Report created within 7 days | "Report Not Started" | orange |

---

## DocType: Project

| Status | Indicator Color | Label Shown in List | Notes |
|---|---|---|---|
| Draft | grey | Draft | Project charter being prepared |
| Submitted | blue | Pending Approval | Submitted for Management review |
| Approved | blue | Approved | Approved; not yet started |
| Active | green | Active | Project implementation underway |
| On Hold | yellow | On Hold | Project paused pending decision |
| Completed | green | Completed | All activities completed and reported |
| Closed | darkgrey | Closed | Project formally closed; documents archived |
| Cancelled | red | Cancelled | Project cancelled |

**Additional computed badges:**

| Condition | Badge | Color |
|---|---|---|
| Budget utilization > 90% and status == "Active" | "Budget >90% Used" | red |
| Budget utilization > 75% and status == "Active" | "Budget >75% Used" | yellow |
| `end_date < today` and status == "Active" | "End Date Passed" | red |
| Any linked advance with `workflow_state == "Overdue"` | "Outstanding Advances" | orange |

---

## DocType: Activity

| Status | Indicator Color | Label Shown in List | Notes |
|---|---|---|---|
| Draft | grey | Draft | Activity being planned |
| Submitted | blue | Pending Approval | Awaiting Project Manager approval |
| Approved | green | Approved | Approved; ready for implementation |
| In Progress | blue | In Progress | Activity being executed in the field |
| Pending Evidence | orange | Pending Evidence | Evidence/report not yet uploaded |
| Completed | green | Completed | Activity done; evidence uploaded and reviewed |
| Closed | darkgrey | Closed | Activity formally closed; costs settled |
| Rejected | red | Rejected | Activity rejected by Project Manager |
| Cancelled | red | Cancelled | Activity cancelled |

---

## DocType: Field Report

| Status | Indicator Color | Label Shown in List | Notes |
|---|---|---|---|
| Draft | grey | Draft | Staff is composing |
| Submitted | blue | Submitted | Submitted to Project Manager |
| Under Review | blue | Under Review | Project Manager reviewing |
| Returned | orange | Returned for Revision | Needs correction from submitter |
| Approved | green | Approved | Report approved and archived |
| Overdue | red | Overdue | Report due date passed without submission |

---

## DocType: Donor Report

| Status | Indicator Color | Label Shown in List | Notes |
|---|---|---|---|
| Draft | grey | Draft | Finance/Program composing |
| Under Finance Review | blue | Finance Review | Finance reviewing transactions and evidence |
| Under Program Review | blue | Program Review | Program team adding narrative and indicators |
| Under Grant Manager Review | blue | Grant Manager Review | Grant Manager reviewing for donor compliance |
| Pending Management Approval | orange | Pending Approval | Awaiting Management sign-off |
| Approved | green | Approved — Ready to Submit | Approved internally; not yet sent to donor |
| Submitted to Donor | green | Submitted | Report sent to donor |
| Revision Requested | orange | Revision Requested | Donor requested changes |
| Accepted | green | Accepted | Donor accepted the report |
| Overdue | red | Overdue | Report not submitted by due date in Grant Reporting Schedule |
| Archived | darkgrey | Archived | Accepted and archived |

---

## DocType: Fund Utilization Report

| Status | Indicator Color | Label Shown in List | Notes |
|---|---|---|---|
| Draft | grey | Draft | Being prepared |
| Under Review | blue | Under Review | Finance Manager reviewing |
| Approved | green | Approved | Report approved for distribution |
| Published | green | Published | Shared with management or board |
| Archived | darkgrey | Archived | Stored for audit reference |

---

---

## List View Highlight Rules

These rules apply row-level background highlighting in Frappe list views. Implement via `frappe.listview_settings['DocType'].add_indicator` or the `get_indicator` method plus CSS class injection.

### General Row Highlight Rules (All DocTypes)

| Condition | Row Background | CSS Class to Apply |
|---|---|---|
| `workflow_state == "Overdue"` | Light red | `list-row-danger` |
| `workflow_state == "Rejected"` | Light red (muted) | `list-row-danger` (0.5 opacity) |
| `workflow_state == "Cancelled"` | Light grey | `list-row-muted` |
| Any compliance exception flag active | Light orange | `list-row-warning` |

### Cash Advance List View

| Condition | Row Highlight | Rationale |
|---|---|---|
| `workflow_state == "Overdue"` | Red row | Overdue advance — requires immediate attention |
| `workflow_state == "Pending Liquidation"` and `liquidation_due_date <= today + 3` | Orange row | Due within 3 days |
| `workflow_state == "Pending Liquidation"` and `liquidation_due_date > today + 3` | No highlight | Within normal window |
| `evidence_complete == 0` and `workflow_state == "Liquidated"` | Orange row | Evidence still missing after submission |
| `workflow_state == "Closed"` | Light grey | Completed — no action needed |

### Grant Reporting Schedule List View

| Condition | Row Highlight | Rationale |
|---|---|---|
| `status == "Overdue"` | Red row | Report overdue |
| `due_date <= today + 7` and `status in ["Upcoming", "Due"]` | Orange row | Critical deadline approaching |
| `due_date <= today + 14` and `status in ["Upcoming", "Due"]` | Yellow row | Upcoming deadline — start preparation |
| `status == "Accepted"` | Light grey | Completed cycle |

### Grant List View

| Condition | Row Highlight | Rationale |
|---|---|---|
| `workflow_state == "Suspended"` | Red row | Active risk |
| `end_date <= today + 7` and `workflow_state in ["Active", "Extended"]` | Red row | Ending imminently |
| `end_date <= today + 30` and `workflow_state in ["Active", "Extended"]` | Orange row | Nearing end date |
| `workflow_state == "Closing"` | Orange row | Closeout in progress — action required |
| `workflow_state == "Closed"` | Light grey | Archived |

### Fundraising Campaign List View

| Condition | Row Highlight | Rationale |
|---|---|---|
| `workflow_state == "Cancelled"` | Red row | Cancelled |
| `workflow_state == "Completed"` and no report created within 7 days | Orange row | Report not started |
| `collected_amount / target_amount < 0.5` and `end_date <= today + 14` | Orange row | Below target approaching deadline |
| `collected_amount >= target_amount` | Light green row | Target reached |

### Purchase Request List View

| Condition | Row Highlight | Rationale |
|---|---|---|
| `workflow_state == "Budget Exception"` | Red row | Blocked — requires exception approval |
| `workflow_state == "Cancelled"` | Light grey | No action needed |
| `workflow_state == "Completed"` | Light grey | Archived |

### Fund List View

| Condition | Row Highlight | Rationale |
|---|---|---|
| Fund balance < 0 | Red row | Negative balance — critical |
| `end_date <= today + 7` and `status == "Active"` | Red row | Expiring imminently |
| `end_date <= today + 30` and `status == "Active"` | Orange row | Nearing expiry |
| `status == "Closed"` | Light grey | No further action |

---

## Implementation Checklist

When implementing status colors for a new DocType, verify the following:

- [ ] Workflow State records have the correct `style` set (`default`, `primary`, `success`, `warning`, `danger`, `info`)
- [ ] `get_indicator` hook is defined in the DocType controller for any state that needs to differ from the workflow style default
- [ ] `listview_settings` JS file for the DocType includes `add_indicator` rules for computed badges
- [ ] List view row highlight rules are added via `get_list_indicator` or CSS class injection in the list view JS
- [ ] Overdue computed badges are driven by the scheduled job, not only by client-side date comparison
- [ ] All "Overdue" states render as `red`; all "Closed/Archived" states render as `darkgrey`
- [ ] Color rules are consistent with the Global Color Rules table at the top of this document — no DocType uses green for a pending/incomplete state or red for a neutral state
