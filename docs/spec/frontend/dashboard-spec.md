# Fundara Dashboard Specification

**Version:** 1.0  
**Last Updated:** 2026-06-19  
**Audience:** Frontend Developer  
**Platform:** ERPNext v16 / Frappe Framework  

---

## How to Read This Document

Each role section specifies the exact components of that role's Frappe Dashboard page. All dashboards are implemented as named Dashboard documents in ERPNext (path: `/app/dashboard`). Role-specific dashboards are set as the **default homepage** via `System Settings > Default Home Page` or via a role-specific `Desktop` configuration.

Frappe dashboard components referenced here:

- **Number Card** — A single metric widget backed by a query or script. Configured in `Number Card` DocType.
- **Chart** — A chart widget backed by a named `Dashboard Chart`. Configured in `Dashboard Chart` DocType.
- **Shortcut** — A quick-link tile on the Frappe Desk that opens a DocType list or form.
- **Alert Banner** — Implemented as a server-rendered `frappe.msgprint` or a custom HTML widget injected via `dashboard_chart.js` hooks.

Color thresholds on Number Cards are implemented using the `color` field on the `Number Card` DocType and/or conditional coloring via a custom script in `numbercard.js`.

---

## Shared Dashboard Components

These widgets appear on more than one role's dashboard with identical configuration. Implement them once as named reusable `Number Card` or `Dashboard Chart` records.

### Shared Number Cards

| Card Name (reuse key) | Source DocType | Filter | Format | Appears on |
|---|---|---|---|---|
| `ncard-my-pending-advances` | Cash Advance | `requester == session.user`, `workflow_state in ["Approved", "Pending Liquidation"]` | Count | Field Staff, Project Manager |
| `ncard-my-overdue-advances` | Cash Advance | `requester == session.user`, `workflow_state == "Overdue"` | Count | Field Staff, Project Manager |
| `ncard-total-overdue-advances` | Cash Advance | `workflow_state == "Overdue"` | Count | Finance Officer, Finance Manager |
| `ncard-pending-liquidations` | Cash Advance | `workflow_state == "Pending Liquidation"` | Count | Finance Officer, Finance Manager |
| `ncard-pending-my-approval` | (multi-doctype script) | Documents in workflow states requiring current user's role to act | Count | Project Manager, Finance Officer, Finance Manager, Grant Manager |
| `ncard-active-grants` | Grant | `workflow_state == "Active"` | Count | Grant Manager, Executive Director |
| `ncard-active-campaigns` | Fundraising Campaign | `workflow_state == "Active"` | Count | Fundraising Officer, Executive Director |

### Shared Charts

| Chart Name (reuse key) | Type | Description | Appears on |
|---|---|---|---|
| `chart-budget-vs-actual-by-fund` | Bar | Budget vs Actual grouped by Fund | Finance Manager, Executive Director |
| `chart-advance-aging` | Bar (stacked) | Advance aging buckets: 0–7 days, 8–30 days, >30 days | Finance Officer, Finance Manager |
| `chart-grant-burn-rate` | Line | Monthly burn rate vs expected burn rate for all active grants | Grant Manager, Executive Director |
| `chart-campaign-donation-trend` | Line | Daily/weekly donation collection trend for active campaigns | Fundraising Officer, Executive Director |

---

## Dashboard: Field Staff / Program Officer

**Default landing page after login:** Activity list, filtered to `assigned_to == session.user`

> This dashboard is intentionally minimal. Field Staff should immediately see their task queue and outstanding obligations without navigating through financial data they cannot access.

### Number Cards (top row)

| Card Label | Source DocType | Filter | Format | Color Threshold |
|---|---|---|---|---|
| My Open Activities | Activity | `assigned_to == session.user`, `status in ["Approved", "In Progress"]` | Count | Orange if > 5 |
| My Pending Advances | Cash Advance | `requester == session.user`, `workflow_state in ["Approved", "Pending Liquidation"]` | Count | Red if > 0 |
| My Overdue Advances | Cash Advance | `requester == session.user`, `workflow_state == "Overdue"` | Count | Red if > 0 (always red when non-zero; triggers block on new advances) |
| Reports Due This Week | Field Report | `assigned_to == session.user`, `due_date <= today+7`, `workflow_state != "Closed"` | Count | Orange if > 0 |

### Charts

| Chart Title | Type | X-axis | Y-axis / Series | Filter | Date Range |
|---|---|---|---|---|---|
| My Activity Status | Donut | — | Count by workflow_state | `assigned_to == session.user` | All active |
| My Advance History | Bar | Month | Count of advances by state (Closed / Overdue) | `requester == session.user` | Last 6 months |

### List Views (quick access)

| List Name | DocType | Filters | Columns Shown |
|---|---|---|---|
| My Activities | Activity | `assigned_to == session.user`, `status != "Closed"` | Activity Name, Project, Status, Start Date, Due Date |
| My Advances | Cash Advance | `requester == session.user` | Name, Amount, Status, Liquidation Due Date |
| My Pending Reports | Field Report | `assigned_to == session.user`, `workflow_state != "Closed"` | Report Name, Activity, Due Date, Status |

### Quick Action Buttons

| Button Label | Action | Condition to Show |
|---|---|---|
| New Advance Request | Open Cash Advance form (new) | Always visible |
| Submit Liquidation | Open Advance Liquidation form linked to oldest Pending Liquidation advance | Visible only if `ncard-my-pending-advances > 0` |
| Upload Field Report | Open Field Report form (new) | Always visible |

### Alert Banners

| Condition | Message | Severity |
|---|---|---|
| `workflow_state == "Overdue"` on any advance for session.user | "You have an overdue advance. New advance requests are blocked until this is settled." | danger |
| Field Report due within 3 days | "A field report is due in [N] days: [Report Name]." | warning |
| Activity due date passed and status still "In Progress" | "Activity [Name] is past its due date. Please update the status or contact your Project Manager." | warning |

---

## Dashboard: Project Manager

**Default landing page after login:** Project list, filtered to `project_manager == session.user`

> Project Managers are the primary workflow approvers for activities and advances within their project scope. Their dashboard surfaces approval queues alongside budget visibility.

### Number Cards (top row)

| Card Label | Source DocType | Filter | Format | Color Threshold |
|---|---|---|---|---|
| Active Projects | Project | `project_manager == session.user`, `status == "Active"` | Count | — |
| Pending Approvals | (multi-doc script) | Cash Advances and Activities in states awaiting Project Manager action, scoped to session.user's projects | Count | Orange if > 0, Red if > 5 |
| Budget Utilization (%) | (script card) | Average of `(actual_amount / allocated_budget) * 100` across session.user's active projects | Percentage | Orange if > 75%, Red if > 90% |
| My Overdue Advances | Cash Advance | `workflow_state == "Overdue"`, project in session.user's projects | Count | Red if > 0 |

### Charts

| Chart Title | Type | X-axis | Y-axis / Series | Filter | Date Range |
|---|---|---|---|---|---|
| Budget vs Actual by Activity | Bar (grouped) | Activity Name | Allocated Budget / Actual Spent | Projects owned by session.user | Current fiscal year |
| Activity Progress | Bar (stacked) | Week | Count of activities by state (Approved / In Progress / Completed) | Projects owned by session.user | Current quarter |
| Advance Aging (My Projects) | Bar | Aging bucket (0–7 / 8–30 / >30 days) | Count of advances | Projects owned by session.user | All open |

### List Views (quick access)

| List Name | DocType | Filters | Columns Shown |
|---|---|---|---|
| Pending Advance Approvals | Cash Advance | `workflow_state == "Submitted"`, project in session.user's projects | Requester, Amount, Fund, Activity, Submitted Date |
| Pending Activity Approvals | Activity | `workflow_state == "Submitted"`, project in session.user's projects | Activity Name, Project, Estimated Budget, PIC, Submitted Date |
| My Project Activities | Activity | project in session.user's projects, `status != "Closed"` | Activity, Status, Start Date, Due Date, PIC |
| Overdue Advances | Cash Advance | `workflow_state == "Overdue"`, project in session.user's projects | Requester, Amount, Liquidation Due Date, Days Overdue |

### Quick Action Buttons

| Button Label | Action | Condition to Show |
|---|---|---|
| Approve Pending Items | Navigate to filtered list of documents awaiting PM approval | Visible if pending approvals > 0 |
| View My Projects | Open Project list filtered to session.user | Always visible |
| New Activity | Open Activity form (new), pre-filled with user's projects in dropdown | Always visible |

### Alert Banners

| Condition | Message | Severity |
|---|---|---|
| Any advance in session.user's projects is Overdue | "[N] advance(s) are overdue in your projects. Approve the liquidation or escalate to Finance." | danger |
| Budget utilization > 90% on any project | "Project [Name] has used [X]% of its budget. Review activity planning." | warning |
| Any activity has passed due date without Completed status | "Activity [Name] in project [Project] is past its scheduled end date." | warning |
| Pending approvals > 5 | "You have [N] items waiting for your approval." | info |

---

## Dashboard: Finance Officer

**Default landing page after login:** Cash Advance list, filtered to `workflow_state in ["Submitted", "Under Review", "Liquidated"]`

> Finance Officers are transaction processors. Their dashboard is a work queue — surfacing documents that need review, payment, or reconciliation action today.

### Number Cards (top row)

| Card Label | Source DocType | Filter | Format | Color Threshold |
|---|---|---|---|---|
| Advances Awaiting Review | Cash Advance | `workflow_state in ["Submitted", "Under Review"]` | Count | Orange if > 3 |
| Total Overdue Advances | Cash Advance | `workflow_state == "Overdue"` | Count | Red if > 0 |
| Liquidations Pending Review | Advance Liquidation | `workflow_state in ["Submitted", "Under Finance Review"]` | Count | Orange if > 3 |
| Purchase Requests to Process | Purchase Request | `workflow_state in ["Submitted", "Under Review"]` | Count | Orange if > 2 |
| Missing Evidence (Open Transactions) | (script card) | Count of Cash Advances or Liquidations with `evidence_complete == 0` and workflow_state not in ["Draft", "Rejected", "Cancelled"] | Count | Red if > 0 |

### Charts

| Chart Title | Type | X-axis | Y-axis / Series | Filter | Date Range |
|---|---|---|---|---|---|
| Advance Aging | Bar (stacked) | Aging bucket | Count (0–7 days / 8–30 days / >30 days) | `workflow_state in ["Pending Liquidation", "Overdue"]` | All open |
| Transaction Volume | Line | Day | Count of advances posted / liquidations closed | All | Last 30 days |
| Budget Exceptions | Bar | Fund Name | Count of transactions flagged as Budget Exception | All | Current fiscal year |

### List Views (quick access)

| List Name | DocType | Filters | Columns Shown |
|---|---|---|---|
| Advance Review Queue | Cash Advance | `workflow_state in ["Submitted", "Under Review"]` | Requester, Amount, Fund, Activity, Submitted Date |
| Liquidation Review Queue | Advance Liquidation | `workflow_state in ["Submitted", "Under Finance Review"]` | Staff, Advance Name, Actual Amount, Difference, Evidence Status |
| Overdue Advances | Cash Advance | `workflow_state == "Overdue"` | Requester, Amount, Due Date, Days Overdue, Project Manager |
| Missing Evidence | Cash Advance, Advance Liquidation | `evidence_complete == 0`, `workflow_state not in ["Draft", "Rejected", "Cancelled"]` | Transaction, Staff, Amount, Missing Document Type |
| PR Review Queue | Purchase Request | `workflow_state in ["Submitted", "Under Review"]` | Requester, Fund, Estimated Amount, Procurement Method |

### Quick Action Buttons

| Button Label | Action | Condition to Show |
|---|---|---|
| Process Next Advance | Open oldest Advance in "Under Review" state | Visible if advance review queue > 0 |
| Review Next Liquidation | Open oldest Liquidation in "Under Finance Review" | Visible if liquidation queue > 0 |
| Flag Missing Evidence | Open filtered list of transactions with missing evidence | Visible if missing evidence count > 0 |

### Alert Banners

| Condition | Message | Severity |
|---|---|---|
| Any advance overdue > 30 days | "[N] advance(s) have been overdue for more than 30 days. Escalate to Finance Manager." | danger |
| Missing evidence count > 0 | "[N] transaction(s) have incomplete evidence. These must be resolved before period closing." | warning |
| Budget exception exists | "[N] transaction(s) are flagged as Budget Exception. Review required before approval." | warning |

---

## Dashboard: Finance Manager

**Default landing page after login:** Fund Utilization Report or Finance Dashboard (custom)

> Finance Managers are decision-makers and exception handlers. Their dashboard shows organizational financial health, pending high-value approvals, and exception flags.

### Number Cards (top row)

| Card Label | Source DocType | Filter | Format | Color Threshold |
|---|---|---|---|---|
| High-Value Approvals Pending | (multi-doc script) | Cash Advances > 50M IDR and Purchase Orders > 100M IDR awaiting Finance Manager | Count | Red if > 0 |
| Total Overdue Advances | Cash Advance | `workflow_state == "Overdue"` | Count | Red if > 0 |
| Active Funds (All) | Fund | `status == "Active"` | Count | — |
| Budget Exception Flags | (script card) | Transactions currently in "Budget Exception" state across all DocTypes | Count | Red if > 0 |
| Funds Nearing Expiry (<30 days) | Fund | `end_date <= today+30`, `status == "Active"` | Count | Orange if > 0 |

### Charts

| Chart Title | Type | X-axis | Y-axis / Series | Filter | Date Range |
|---|---|---|---|---|---|
| Budget vs Actual by Fund | Bar (grouped) | Fund Name | Allocated Budget / Actual Spent / Committed | All active funds | Current fiscal year |
| Advance Aging (All) | Bar (stacked) | Aging bucket | Count of all advances | All open | All open |
| Cash Flow Trend | Line | Month | Cash In / Cash Out / Net | All funds | Last 12 months |
| Budget Exception Trend | Bar | Month | Count of exceptions flagged | All | Current fiscal year |

### List Views (quick access)

| List Name | DocType | Filters | Columns Shown |
|---|---|---|---|
| High-Value Pending Approvals | Cash Advance + Purchase Order | Amount above Finance Manager threshold, workflow awaiting FM | Type, Name, Amount, Fund, Requester, Submitted Date |
| All Overdue Advances | Cash Advance | `workflow_state == "Overdue"` | Requester, Project, Amount, Due Date, Days Overdue |
| Budget Exceptions | (all transaction types) | `workflow_state == "Budget Exception"` | DocType, Name, Fund, Amount Over Budget, PIC |
| Funds Nearing Expiry | Fund | `end_date <= today+30`, `status == "Active"` | Fund Name, Type, End Date, Remaining Balance |

### Quick Action Buttons

| Button Label | Action | Condition to Show |
|---|---|---|
| Approve Pending High-Value | Navigate to filtered high-value approval queue | Visible if high-value pending > 0 |
| Run Budget vs Actual Report | Open Fund Utilization Report | Always visible |
| Review Period Closing | Navigate to Period Closing checklist | Always visible |

### Alert Banners

| Condition | Message | Severity |
|---|---|---|
| Any fund has negative balance | "Fund [Name] has a negative balance of [Amount]. Immediate review required." | danger |
| Budget exception count > 0 | "[N] budget exception(s) require your decision." | danger |
| Advance overdue > 30 days exists | "[N] advance(s) are overdue for more than 30 days." | warning |
| Fund nearing expiry within 7 days | "Fund [Name] expires in [N] days. Ensure all transactions are posted." | warning |
| Period closing overdue | "The accounting period has not been closed. Bank reconciliation may be pending." | warning |

---

## Dashboard: Grant Manager (Donor Relationship Manager)

**Default landing page after login:** Grant list, filtered to `grant_manager == session.user`

> The Grant Manager's dashboard is compliance-first. It must surface upcoming donor report deadlines, grant health, and compliance risks before the Grant Manager sees anything else.

### Number Cards (top row)

| Card Label | Source DocType | Filter | Format | Color Threshold |
|---|---|---|---|---|
| Active Grants | Grant | `grant_manager == session.user`, `workflow_state == "Active"` | Count | — |
| Donor Reports Due This Month | Grant Reporting Schedule | `grant_manager == session.user`, `due_date <= end_of_month`, `status != "Submitted"` | Count | Red if > 0 |
| Grants Nearing End Date (<30 days) | Grant | `grant_manager == session.user`, `end_date <= today+30`, `workflow_state in ["Active", "Extended"]` | Count | Red if > 0 |
| Compliance Exceptions (Open) | Compliance Checklist | linked to session.user's grants, `status != "Resolved"` | Count | Red if > 0 |

### Charts

| Chart Title | Type | X-axis | Y-axis / Series | Filter | Date Range |
|---|---|---|---|---|---|
| Grant Burn Rate | Line | Month | Actual Spend / Expected Burn Rate | Grants owned by session.user | Grant period (full) |
| Budget vs Actual by Grant | Bar (grouped) | Grant Name | Approved Budget / Committed / Actual | Grants owned by session.user | Current fiscal year |
| Reporting Schedule | Gantt-style bar or timeline | Grant Name | Report due dates plotted on timeline | Grants owned by session.user | Next 6 months |
| Grant Status Overview | Donut | — | Count by workflow_state | Grants owned by session.user | All active |

> Note on Reporting Schedule chart: Frappe does not natively support a Gantt chart in dashboards. Implement this as a custom HTML widget or a simplified bar chart where X-axis is "Month" and each bar is colored by whether the report is on-time (green), due soon (orange), or overdue (red).

### List Views (quick access)

| List Name | DocType | Filters | Columns Shown |
|---|---|---|---|
| Upcoming Donor Reports | Grant Reporting Schedule | `due_date <= today+30`, `status != "Submitted"`, grants owned by session.user | Grant, Report Period, Due Date, Status, Assigned To |
| Overdue Donor Reports | Grant Reporting Schedule | `due_date < today`, `status != "Submitted"`, grants owned by session.user | Grant, Report Period, Due Date, Days Overdue |
| Active Grants | Grant | `workflow_state in ["Active", "Extended"]`, `grant_manager == session.user` | Grant Name, Donor, Start Date, End Date, Budget, Burn Rate |
| Open Compliance Issues | Compliance Checklist | linked to session.user's grants, `status != "Resolved"` | Grant, Issue Type, Flagged By, Date |

### Quick Action Buttons

| Button Label | Action | Condition to Show |
|---|---|---|
| Prepare Donor Report | Open Donor Report form (new), pre-linked to oldest overdue schedule | Visible if overdue reports > 0 |
| Review Compliance Issues | Open Compliance Checklist list filtered to session.user's grants | Visible if exceptions > 0 |
| Initiate Grant Closeout | Open Grant form for grants with end_date < today+30 | Visible if grants nearing end > 0 |
| View All Grants | Open Grant list filtered to session.user | Always visible |

### Alert Banners

| Condition | Message | Severity |
|---|---|---|
| Donor report overdue | "Donor report for [Grant Name] — [Period] — is overdue. Submit immediately to avoid compliance breach." | danger |
| Grant end date within 7 days | "Grant [Name] ends in [N] days. All outstanding advances and purchases must be settled." | danger |
| Grant end date within 30 days | "Grant [Name] ends in [N] days. Initiate closeout checklist." | warning |
| Compliance exception unresolved > 14 days | "Compliance issue on [Grant Name] has been open for [N] days." | warning |
| Missing evidence on active grant transactions | "[N] transaction(s) under grant [Name] are missing required evidence." | warning |

---

## Dashboard: Fundraising Officer

**Default landing page after login:** Fundraising Campaign list, filtered to `campaign_officer == session.user OR created_by == session.user`

> Fundraising Officers track live campaign performance — donation volume, donor count, and utilization — with a clear view of what still needs reporting or closing.

### Number Cards (top row)

| Card Label | Source DocType | Filter | Format | Color Threshold |
|---|---|---|---|---|
| Active Campaigns | Fundraising Campaign | `workflow_state == "Active"`, linked to session.user | Count | — |
| Total Donations This Month | Donation | `campaign` in session.user's active campaigns, `date >= start_of_month` | Currency (IDR) | Green if > 0 |
| Donor Count (Active Campaigns) | Donation | unique donors across session.user's active campaigns | Count | — |
| Campaigns Needing Report | Fundraising Campaign | `workflow_state == "Completed"`, `campaign_officer == session.user` | Count | Orange if > 0 |

### Charts

| Chart Title | Type | X-axis | Y-axis / Series | Filter | Date Range |
|---|---|---|---|---|---|
| Campaign Donation Trend | Line | Day | Donation Amount | Active campaigns owned by session.user | Last 30 days |
| Target vs Collected | Bar (grouped) | Campaign Name | Target Amount / Collected Amount | All campaigns by session.user | Campaign period |
| Fundraising Cost Ratio | Bar | Campaign Name | Fundraising Cost % of Gross Donations | Completed campaigns | Last 12 months |
| Donor Channel Breakdown | Donut | — | Donation Amount by Channel | Active campaigns | Campaign period |

### List Views (quick access)

| List Name | DocType | Filters | Columns Shown |
|---|---|---|---|
| Active Campaigns | Fundraising Campaign | `workflow_state == "Active"`, session.user | Campaign Name, Target, Collected, Donors, End Date, % Reached |
| Recent Donations | Donation | campaign in session.user's campaigns, last 30 days | Donor, Channel, Amount, Campaign, Date |
| Campaigns Awaiting Report | Fundraising Campaign | `workflow_state == "Completed"`, session.user | Campaign Name, Collection End Date, Gross Donations, Net Fund |
| Acknowledgments Pending | Donation | `acknowledgment_sent == 0`, campaign in session.user's campaigns | Donor, Amount, Channel, Date |

### Quick Action Buttons

| Button Label | Action | Condition to Show |
|---|---|---|
| Record Donation | Open Donation form (new) | Always visible |
| Send Pending Acknowledgments | Open Donation list filtered to `acknowledgment_sent == 0` | Visible if pending acknowledgments > 0 |
| Start Campaign Report | Open Campaign Report form for oldest Completed campaign | Visible if campaigns needing report > 0 |
| New Campaign | Open Fundraising Campaign form (new) | Always visible |

### Alert Banners

| Condition | Message | Severity |
|---|---|---|
| Campaign end date within 7 days | "Campaign [Name] ends in [N] days. Verify donation totals and prepare for reporting." | warning |
| Campaign completed but report not started within 7 days | "Campaign [Name] has ended [N] days ago. Please initiate the campaign report." | warning |
| Acknowledgment backlog > 10 donors | "[N] donors have not received an acknowledgment. Send acknowledgments today." | info |
| Campaign below 50% of target with less than 14 days remaining | "Campaign [Name] is at [X]% of target with [N] days left. Consider escalation." | warning |

---

## Dashboard: Executive Director / Management

**Default landing page after login:** Executive Dashboard (custom Frappe Dashboard named `fundara-executive-dashboard`)

> This is the organization-wide strategic view. The Executive Director sees no individual transaction queues. Every widget answers a strategic question: Is the organization financially healthy? Are funds flowing to mission? Where are the risks?

### Number Cards (top row — Row 1: Fund Health)

| Card Label | Source DocType | Filter | Format | Color Threshold |
|---|---|---|---|---|
| Total Restricted Funds Balance | Fund | `restriction_type == "Restricted"`, `status == "Active"` | Currency (IDR) | — |
| Total Unrestricted Funds Balance | Fund | `restriction_type == "Unrestricted"`, `status == "Active"` | Currency (IDR) | Red if < org minimum operating reserve |
| Active Grants | Grant | `workflow_state in ["Active", "Extended"]` | Count | — |
| Active Campaigns | Fundraising Campaign | `workflow_state == "Active"` | Count | — |

### Number Cards (Row 2: Risk Indicators)

| Card Label | Source DocType | Filter | Format | Color Threshold |
|---|---|---|---|---|
| Overdue Advances (All) | Cash Advance | `workflow_state == "Overdue"` | Count | Red if > 0 |
| Overdue Donor Reports | Grant Reporting Schedule | `due_date < today`, `status != "Submitted"` | Count | Red if > 0 |
| Budget Exception Flags | (all) | `workflow_state == "Budget Exception"` | Count | Red if > 0 |
| Funds Expiring < 30 days | Fund | `end_date <= today+30`, `status == "Active"` | Count | Orange if > 0 |

### Charts

| Chart Title | Type | X-axis | Y-axis / Series | Filter | Date Range |
|---|---|---|---|---|---|
| Fund Balances Overview | Bar (horizontal) | Fund Name | Available Balance | All active funds | Current |
| Budget vs Actual by Fund | Bar (grouped) | Fund Name | Budget / Committed / Actual | All active funds | Current fiscal year |
| Cash Flow Trend | Line | Month | Cash In / Cash Out / Net | Org-wide | Last 12 months |
| Grant Burn Rate (All) | Line | Month | Actual Spend vs Expected Burn | All active grants | Grant periods |
| Campaign Performance | Bar (grouped) | Campaign Name | Target / Collected / Utilized | All campaigns | Last 12 months |
| Restricted vs Unrestricted Over Time | Area | Month | Restricted Balance / Unrestricted Balance | All funds | Last 12 months |

### List Views (quick access)

| List Name | DocType | Filters | Columns Shown |
|---|---|---|---|
| Strategic Approvals Pending | (multi-doc script) | Transactions > 200M IDR awaiting Management/Executive action | DocType, Name, Amount, Fund, Submitted By, Date |
| Overdue Reports | Grant Reporting Schedule | `due_date < today`, `status != "Submitted"` | Grant, Period, Due Date, Days Overdue, Grant Manager |
| Funds Nearing Expiry | Fund | `end_date <= today+30`, `status == "Active"` | Fund Name, Type, End Date, Balance, Grant/Campaign Manager |
| Active Grants Summary | Grant | `workflow_state in ["Active", "Extended"]` | Grant Name, Donor, End Date, Budget, Actual Spent, Burn Rate |

### Quick Action Buttons

| Button Label | Action | Condition to Show |
|---|---|---|
| Approve Strategic Transactions | Navigate to high-value approval queue (> 200M IDR) | Visible if strategic pending > 0 |
| Run Fund Utilization Report | Open Fund Utilization Report for current fiscal year | Always visible |
| View Compliance Summary | Open Compliance Checklist aggregated view | Always visible |
| View Impact Summary | Open MEAL Dashboard / Impact Report | Always visible |

### Alert Banners

| Condition | Message | Severity |
|---|---|---|
| Unrestricted fund balance below policy minimum | "Unrestricted fund balance is [Amount], below the minimum operating reserve of [Policy Amount]. Board notification may be required." | danger |
| Any donor report overdue | "[N] donor report(s) are overdue. Compliance risk — review with Grant Manager immediately." | danger |
| Any advance overdue > 30 days | "[N] advance(s) have been overdue for more than 30 days. Finance Manager escalation required." | warning |
| Budget exception unresolved > 7 days | "[N] budget exception(s) have been open for more than 7 days." | warning |
| Grant nearing end date < 7 days | "Grant [Name] ends in [N] days. Confirm closeout checklist is active." | warning |
| Fund expiring < 7 days with remaining balance | "Fund [Name] has [Balance] remaining and expires in [N] days. Decision required on remaining funds." | warning |

---

## Implementation Notes

### Landing Page by Role

Configure default homepage in ERPNext under `Setup > System Settings > Role > Default Home Page`. Alternatively, use a `desk.js` hook or a `boot_session` server script to redirect users based on their primary role.

| Role | Default Homepage Setting |
|---|---|
| Field Staff | `/app/activity?assigned_to=%(user)s` |
| Project Manager | `/app/project?project_manager=%(user)s` |
| Finance Officer | `/app/cash-advance?workflow_state=Under Review` |
| Finance Manager | `/app/dashboard/fundara-finance-manager-dashboard` |
| Donor Relationship Manager | `/app/grant?grant_manager=%(user)s` |
| Fundraising Officer | `/app/fundraising-campaign?campaign_officer=%(user)s` |
| Executive Director | `/app/dashboard/fundara-executive-dashboard` |

### Number Card Refresh

Set `auto_refresh_time` on all Number Cards to `60` seconds for role dashboards used in live monitoring (Finance Officer, Finance Manager, Executive Director). For Field Staff and Project Manager dashboards, `300` seconds is sufficient.

### Multi-DocType Script Cards

Cards labeled "(multi-doc script)" require a custom server-side script in `Number Card` using the `script` field. The script queries multiple DocTypes and returns a combined count. Example pattern:

```python
count = 0
for doctype in ["Cash Advance", "Purchase Request", "Activity"]:
    count += frappe.db.count(doctype, {
        "workflow_state": ["in", ["Submitted", "Under Review"]],
        "project_manager": frappe.session.user
    })
return count
```

### Alert Banner Implementation

Alert banners are implemented by injecting a `frappe.show_alert()` or `frappe.msgprint()` call from a custom page script that runs on dashboard load. Alternatively, use a `Dashboard Chart` with type `Custom HTML` to render a styled banner. The condition logic runs as a server script called via `frappe.call` on page load.
