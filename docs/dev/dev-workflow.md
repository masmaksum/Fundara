# Developer Workflow — Implementing a Feature in Fundara

**Audience:** Developers working on Fundara  
**Platform:** ERPNext v16 / Frappe Framework  
**Document owner:** Tech Lead  
**Last updated:** 2026-06-19

This guide walks through the complete lifecycle of implementing one feature — from picking up the story card to the feature being live on staging. It uses **Cash Advance** as the worked example throughout because it touches every layer of the stack: DocType definition, workflow states, server-side validation, GL posting, client-side JavaScript, unit tests, and patches.

---

## 1. Before You Start a Story

### 1.1 Read the story card first

Every story card contains:

- **User story** — who wants what and why ("As a Finance Officer, I want to approve a cash advance request...")
- **Acceptance criteria** — the specific conditions that must be true for the story to be Done
- **Linked spec** — the document in `docs/spec/` that the implementation must follow
- **Dependencies** — other stories or DocTypes that must exist first
- **Layer** — which dependency layer this DocType sits in (from `docs/pm/dependency-map.md`)

Do not start coding until you can answer these three questions from the card:
1. What does this feature do for the user?
2. Which spec document defines the exact fields, rules, and workflow states?
3. What DocTypes must already exist before this one will work?

### 1.2 Which documents to read, in order

For any new story, read in this sequence — do not skip steps:

| Order | Document | Time | What you learn |
|---|---|---|---|
| 1 | `DECISIONS.md` | 15 min | The 6 architectural decisions that constrain every implementation choice. Read this first, every time. |
| 2 | `fundara-domain-contexts/[XX]-[context].md` | 30 min | The business domain: what the organisation does, why this feature exists, business rules in plain language. |
| 3 | `docs/spec/doctypes/[XX]-[context]-doctypes.md` | 30 min | Every field, its type, its validation rules, and its naming series. This is the authoritative source. |
| 4 | `docs/spec/workflows.md` | 20 min | State machine: all states, allowed transitions, and which roles can trigger each transition. |
| 5 | `docs/accounting/journal-entries.md` | 20 min | GL posting rules for this transaction type. Mandatory if the DocType posts to the ledger. |
| 6 | `docs/spec/test-scenarios.md` | 20 min | The BDD test scenarios for this domain — these are the acceptance criteria in Given/When/Then form. |
| 7 | `docs/spec/permissions.md` | 10 min | RBAC matrix: which roles read, write, submit, and cancel this DocType. |

**For Cash Advance specifically:**

- Domain context: `fundara-domain-contexts/06-financial-accountability-context.md`
- DocType spec: `docs/spec/doctypes/06-financial-accountability-doctypes.md` — search for `## DocType: Cash Advance`
- Workflow spec: `docs/spec/workflows.md` — `## Workflow 1: Cash Advance`
- GL rules: `docs/accounting/journal-entries.md` — `## JE-06`, `## JE-07`, `## JE-08`
- Test scenarios: `docs/spec/test-scenarios.md` — `TC-CA-01` through `TC-CA-10`

The most important decision to internalise before touching Cash Advance is **D-02**:

> Available Budget = Approved Budget − Actual (paid only).
>
> An advance in status Approved does NOT reduce the available budget. Budget only decreases when the advance reaches status Paid. The `pending_payment_flag` field is a dashboard warning, not a budget deduction.

Every validation, every GL posting, and every test you write must respect D-02. Getting this wrong is the most common mistake on this codebase.

### 1.3 Checking dependencies before you start

Cash Advance is a Layer 4 DocType. Before you can implement it, these must all exist and be working in your local site:

| Required DocType | Layer | How to verify |
|---|---|---|
| Fund | 2 | Open DocType List, search "Fund", confirm records exist |
| Project | 3 | Search "Project", confirm at least one Active record |
| Activity | 3 | Search "Activity", confirm at least one Approved record |
| Fund Budget Line | 2 | Search "Fund Budget Line", confirm records linked to an active budget |
| User | 0 (ERPNext) | Always present |
| Journal Entry | 0 (ERPNext) | Always present |

Quick dependency check via bench:

```bash
bench --site fundara.local execute frappe.client.get_list \
  --args '["Fund", {"filters": [["status", "=", "Active"]], "limit": 1}]'
```

If any required DocType returns no records, stop. You need test fixture data before you can meaningfully develop or test Cash Advance. Either create the records manually in the Frappe UI, or run the fixture loader:

```bash
bench --site fundara.local migrate
bench --site fundara.local execute frappe.core.doctype.data_import.data_import.import_doc \
  --args '["fundara/fixtures/"]'
```

If a required DocType does not even exist as a schema (you get a "DocType not found" error), the dependency story is not done. Do not proceed — raise the blocker with the Tech Lead.

### 1.4 Setting up your local site for the story

After reading the spec and confirming dependencies are met, get your local environment ready:

```bash
# Pull latest code from the shared branch
git pull origin main

# Apply any new migrations from teammates
bench --site fundara.local migrate

# Clear cache — stale cache causes mysterious JS and permission bugs
bench --site fundara.local clear-cache

# Verify developer mode is on — required for DocType editing via the UI
bench --site fundara.local set-config developer_mode 1

# Start the dev server
bench start
```

Verify the site opens at `http://fundara.local:8000`. Log in as Administrator.

### 1.5 Branch naming convention

Create your branch from the latest `main`:

```bash
git checkout main
git pull origin main
git checkout -b feature/financial-accountability-cash-advance
```

Branch name format: `feature/[domain-context]-[doctype-or-feature-name]`

Examples:
- `feature/financial-accountability-cash-advance`
- `feature/fund-stewardship-fund-transfer`
- `fix/cash-advance-overdue-trigger`
- `docs/journal-entry-multicurrency`

The domain context prefix is the module folder name under `fundara/`. Use it consistently — it makes `git log --oneline` readable and helps reviewers understand scope at a glance.

---

## 2. Implementing a DocType

### 2.1 Open Frappe Desk and create the DocType

1. Navigate to `http://fundara.local:8000`
2. Log in as Administrator (developer mode must be on)
3. Go to the search bar at the top, type **DocType List**, press Enter
4. Click **New**

### 2.2 Fill in the DocType header

For Cash Advance:

| Field | Value |
|---|---|
| Name | `Cash Advance` |
| Module | `Fundara > Financial Accountability` — the module dropdown must show "Financial Accountability" |
| Is Submittable | Yes — check this box; the DocType has a lifecycle from Draft to Closed |
| Naming Series | `ADV-.YYYY.-.####` — enter this in the Naming Series field in the DocType settings |
| Search Fields | `requester, fund, project, status` — enter comma-separated field names |

**Why is_submittable matters:** Submittable DocTypes have `docstatus` (0 = Saved, 1 = Submitted, 2 = Cancelled). This controls whether Frappe allows editing (only docstatus = 0 can be edited). Set it wrong and you cannot implement a workflow.

### 2.3 Add fields one by one from the spec

Open `docs/spec/doctypes/06-financial-accountability-doctypes.md` and find `## DocType: Cash Advance`. Work through the field table row by row in the Frappe field editor.

For each field:

1. Click **Add Row** in the Fields table
2. Set **Field Type** first — this determines what other options appear
3. Set **Field Name** (snake_case, as per spec)
4. Set **Label** (human-readable, as per spec)
5. Set **Options** for Link fields (the target DocType name, e.g., `Fund`)
6. Check **Mandatory** if the spec marks the field as mandatory
7. For currency fields, also set the **Options** field to the companion currency field name (e.g., for `requested_amount`, set Options = `currency`)

Key fields for Cash Advance and their non-obvious settings:

| Field | Type | Options / Notes |
|---|---|---|
| `fund` | Link | Options: `Fund`. Set `in_list_view: 1` so it appears in list view. |
| `project` | Link | Options: `Project` |
| `activity` | Link | Options: `Activity` |
| `budget_line` | Link | Options: `Fund Budget Line` |
| `currency` | Link | Options: `Currency`. Mark mandatory. |
| `exchange_rate` | Float | Default value: `1.0` |
| `requested_amount` | Currency | Options: `currency` (links to the currency field for display formatting) |
| `approved_amount` | Currency | Options: `currency` |
| `paid_amount` | Currency | Options: `currency` |
| `pending_payment_flag` | Check | Default: 0. This is a dashboard flag, not a budget field. |
| `status` | Select | Options: one per line — `Draft`, `Submitted`, `Under Review`, `Approved`, `Paid`, `Pending Liquidation`, `Overdue`, `Liquidated`, `Closed`, `Rejected`, `Cancelled` |
| `payment_journal_entry` | Link | Options: `Journal Entry`. Mark read-only. |
| `requester_department` | Link | Options: `Department`. Set `fetch_from: requester.department` to auto-populate from the requester's User profile. |

Section Breaks are not real fields — they are layout dividers. Add them as `Section Break` type rows with a label to match the spec table structure.

### 2.4 Common mistakes to avoid

**Forgetting `in_list_view` on key fields.** Without this, the DocType list view shows only the document name. Set `in_list_view: 1` on `requester`, `fund`, `project`, `status`, and `posting_date`.

**Wrong Link target name.** If you type `Fund Budget` instead of `Fund Budget Line`, the field silently fails to validate on save. Always copy the exact DocType name from the DocType List.

**Forgetting `fetch_from` on auto-populated fields.** The `requester_department` field should populate automatically from the requester's department. Without `fetch_from: requester.department`, a developer has to write JavaScript to do this manually. Set it in the field definition.

**Not setting `search_fields` on the DocType.** Without this, the DocType search (the magnifying glass in list view) only searches by name/ID. Add `requester, fund, project, status` to the DocType's Search Fields setting.

**Omitting `amended_from` on submittable DocTypes.** Frappe requires a `Link` field named `amended_from` pointing to the same DocType on all submittable DocTypes. Without it, the Amendment button does not work. Add it at the bottom of the field list.

### 2.5 Save and verify the JSON file is created

After saving the DocType in the UI, Frappe (in developer mode) automatically writes the definition to disk:

```
fundara/financial_accountability/doctype/cash_advance/
├── cash_advance.json       ← the DocType definition
├── cash_advance.py         ← Python controller (initially empty)
├── cash_advance.js         ← Client-side script (initially empty)
└── test_cash_advance.py    ← Test file (initially empty)
```

Verify:

```bash
ls /home/[user]/fundara-bench/apps/fundara/fundara/financial_accountability/doctype/cash_advance/
```

If the directory does not exist, the Module setting is wrong — the DocType was saved under a different module. Check the Module field in the DocType header.

### 2.6 Commit the DocType definition

```bash
git add fundara/financial_accountability/doctype/cash_advance/
git commit -m "financial-accountability: add Cash Advance DocType definition"
```

Commit the JSON at this point, before writing any logic. This gives the reviewer a clean diff showing only the schema, separate from the business logic.

---

## 3. Implementing Server-side Logic

The Python controller lives at:

```
fundara/financial_accountability/doctype/cash_advance/cash_advance.py
```

### 3.1 Controller structure

```python
import frappe
from frappe import _
from frappe.model.document import Document


class CashAdvance(Document):
    """Cash Advance — staff request for operational funds.

    Key constraint (D-02): budget is reduced only when status transitions
    to Paid, not when the advance is merely Approved.
    """

    def validate(self):
        """Called on every Save. Run all field-level and business-rule checks here."""
        self._validate_activity_status()
        self._validate_fund_active()
        self._validate_liquidation_due_date()
        self._validate_approved_amount_within_budget()

    def before_submit(self):
        """Called just before docstatus changes to 1 (Submit button clicked).
        Use for final checks that should block submission, not just warn.
        """
        if not self.fund:
            frappe.throw(_("Fund is mandatory before submitting a Cash Advance."))
        if not self.activity:
            frappe.throw(_("Activity is mandatory before submitting a Cash Advance."))

    def on_submit(self):
        """Called after docstatus = 1 is committed.
        Do not post GL entries here for Cash Advance — GL is posted only at
        the Paid status transition, not at Submit. See mark_as_paid().
        """
        pass

    def before_cancel(self):
        """Called before cancellation. Block if already Paid."""
        if self.status == "Paid":
            frappe.throw(
                _("Cannot cancel a Cash Advance that has already been Paid. "
                  "Use a reversal process.")
            )

    def on_cancel(self):
        """Called after cancellation. Reverse any GL entries if they exist."""
        if self.payment_journal_entry:
            self._reverse_payment_journal_entry()

    # -------------------------------------------------------------------------
    # Private validation methods
    # -------------------------------------------------------------------------

    def _validate_activity_status(self):
        """Business Rule 1: Activity must be Approved or In Progress."""
        if not self.activity:
            return
        activity_status = frappe.db.get_value("Activity", self.activity, "status")
        if activity_status not in ("Approved", "In Progress"):
            frappe.throw(
                _("Activity {0} must be in status Approved or In Progress. "
                  "Current status: {1}").format(self.activity, activity_status)
            )

    def _validate_fund_active(self):
        """Fund must be Active to accept new advances."""
        if not self.fund:
            return
        fund_status = frappe.db.get_value("Fund", self.fund, "status")
        if fund_status != "Active":
            frappe.throw(
                _("Fund {0} is not Active (current status: {1}). "
                  "Cannot create advance against an inactive fund.").format(
                    self.fund, fund_status
                )
            )

    def _validate_liquidation_due_date(self):
        """Liquidation due date must be in the future at submission time."""
        if self.liquidation_due_date and self.liquidation_due_date <= frappe.utils.today():
            frappe.throw(
                _("Liquidation Due Date must be a future date.")
            )

    def _validate_approved_amount_within_budget(self):
        """D-02: approved_amount must not exceed the budget line's available balance.

        Available balance = approved budget line amount minus PAID transactions only.
        Approved-but-not-yet-paid advances do NOT reduce available balance.
        """
        if not self.approved_amount or not self.budget_line:
            return

        available = self._get_budget_line_available_balance()
        if self.approved_amount > available:
            frappe.throw(
                _("Approved amount {0} exceeds available budget of {1} "
                  "on budget line {2}. (D-02: only paid transactions reduce "
                  "available budget.)").format(
                    frappe.format_value(self.approved_amount, {"fieldtype": "Currency"}),
                    frappe.format_value(available, {"fieldtype": "Currency"}),
                    self.budget_line,
                )
            )

    def _get_budget_line_available_balance(self):
        """Return available balance for the linked budget line.

        D-02 formula: available = approved_amount − sum(paid_amount)
        where paid_amount is the sum of all Cash Advances against this
        budget line that have reached status = Paid.
        """
        approved = frappe.db.get_value(
            "Fund Budget Line", self.budget_line, "approved_amount"
        ) or 0

        paid_total = frappe.db.sql(
            """
            SELECT COALESCE(SUM(paid_amount), 0)
            FROM `tabCash Advance`
            WHERE budget_line = %s
              AND status IN ('Paid', 'Pending Liquidation', 'Overdue',
                             'Liquidated', 'Closed')
              AND name != %s
              AND docstatus = 1
            """,
            (self.budget_line, self.name or ""),
        )[0][0]

        return approved - paid_total

    # -------------------------------------------------------------------------
    # Public methods (called by workflow transitions or the UI)
    # -------------------------------------------------------------------------

    @frappe.whitelist()
    def mark_as_paid(self, payment_reference, payment_date=None):
        """Transition the advance to Paid and post the GL entry.

        Called by the "Mark as Paid" button on the form (client script calls
        frappe.call('fundara.financial_accountability.doctype
                     .cash_advance.cash_advance.mark_as_paid')).

        GL entry posted: Dr Uang Muka Kegiatan / Cr Bank Operasional (JE-06).
        Budget impact: paid_amount is set here, which reduces available budget (D-02).
        """
        if self.status != "Approved":
            frappe.throw(_("Advance must be in status Approved to be marked as Paid."))
        if not payment_reference:
            frappe.throw(_("Payment Reference is required to mark an advance as Paid."))

        self.payment_reference = payment_reference
        self.payment_date = payment_date or frappe.utils.today()
        self.paid_amount = self.approved_amount
        self.pending_payment_flag = 0
        self.status = "Paid"

        # Post GL entry — JE-06: Dr Uang Muka / Cr Bank
        je = self._post_payment_gl_entry()
        self.payment_journal_entry = je.name

        self.save()
        frappe.msgprint(
            _("Advance marked as Paid. Journal Entry {0} created.").format(je.name)
        )

    def _post_payment_gl_entry(self):
        """Post JE-06: Dr Uang Muka Kegiatan / Cr Bank Operasional.

        See docs/accounting/journal-entries.md ## JE-06 for the full rule,
        multi-currency variant, and edge cases.
        """
        from erpnext.accounts.general_ledger import make_gl_entries

        advance_account = frappe.db.get_single_value(
            "Fundara Settings", "advance_receivable_account"
        ) or "Uang Muka Kegiatan - FA"

        bank_account = frappe.db.get_single_value(
            "Fundara Settings", "default_bank_account"
        ) or "Bank Operasional - FA"

        gl_entries = [
            # Debit: Advance Receivable (asset increases when we give cash out)
            self.get_gl_dict({
                "account": advance_account,
                "debit": self.paid_amount * self.exchange_rate,
                "debit_in_account_currency": self.paid_amount,
                "against": self.fund,
                "cost_center": self.cost_center,
                # Custom dimensions — fund, project, activity flow through to GL
                "fund": self.fund,
                "project": self.project,
                "activity": self.activity,
                "remarks": "Cash Advance payment: {0}".format(self.name),
            }),
            # Credit: Bank (cash goes out)
            self.get_gl_dict({
                "account": bank_account,
                "credit": self.paid_amount * self.exchange_rate,
                "credit_in_account_currency": self.paid_amount,
                "against": self.requester,
                "cost_center": self.cost_center,
            }),
        ]

        make_gl_entries(gl_entries)

        # Return the created Journal Entry so the caller can link it
        return frappe.get_last_doc("Journal Entry")

    def _reverse_payment_journal_entry(self):
        """Reverse JE-06 on cancellation.
        Called from on_cancel() only when a payment JE exists.
        """
        if not self.payment_journal_entry:
            return
        je = frappe.get_doc("Journal Entry", self.payment_journal_entry)
        if je.docstatus == 1:
            je.cancel()
```

### 3.2 frappe.throw() vs frappe.msgprint()

Use the right one for the right situation:

| Method | When to use | Effect |
|---|---|---|
| `frappe.throw(message)` | Hard block — the operation must not proceed | Raises an exception, rolls back the save/submit, shows a red error dialog |
| `frappe.msgprint(message)` | Informational or soft warning — operation proceeds | Shows a notification, does not stop the save |

**For Cash Advance, always use `frappe.throw()`** for:
- Activity not in valid status
- Fund not Active
- Approved amount exceeds budget (D-02 violation)
- Trying to mark as Paid when not Approved
- Missing mandatory fields at submission

Use `frappe.msgprint()` only for confirmations after an action succeeds (e.g., "Journal Entry JE-2026-0042 created.").

### 3.3 The D-02 budget check — what to check and when

The check in `_validate_approved_amount_within_budget()` runs on every save. This is intentional. It must query only **paid** transactions, not approved-but-pending ones. The SQL in `_get_budget_line_available_balance()` explicitly filters `status IN ('Paid', 'Pending Liquidation', 'Overdue', 'Liquidated', 'Closed')`. It does NOT include `'Approved'`.

If someone argues that "surely Approved advances should also reduce the available balance so we don't over-commit," point them to `DECISIONS.md D-02`. The decision is final. Approved-but-unpaid advances show up in the `pending_payment_flag` dashboard panel as a warning; they do not deduct from budget.

---

## 4. Implementing Client-side Logic (JavaScript)

File: `fundara/financial_accountability/doctype/cash_advance/cash_advance.js`

### 4.1 Form controller structure

```javascript
frappe.ui.form.on('Cash Advance', {

    refresh(frm) {
        // Runs every time the form loads or is refreshed (after save, submit, etc.)
        // Use this to: add custom buttons, set intro messages, show/hide sections.
        setup_action_buttons(frm);
        show_d02_banner(frm);
        display_fund_balance(frm);
    },

    fund(frm) {
        // Runs when the fund field value changes.
        // Use this to: filter related fields, fetch fund metadata.
        if (frm.doc.fund) {
            filter_project_by_fund(frm);
            fetch_and_display_fund_balance(frm);
        }
    },

    project(frm) {
        // Runs when the project field value changes.
        if (frm.doc.project) {
            filter_activity_by_project(frm);
        }
    },

    requested_amount(frm) {
        // Runs when the requested amount changes.
        // Pre-populate approved_amount to match (Finance can adjust during review).
        if (frm.doc.requested_amount && !frm.doc.approved_amount) {
            frm.set_value('approved_amount', frm.doc.requested_amount);
        }
    },

    requester(frm) {
        // Auto-populate department from requester's User record.
        if (frm.doc.requester) {
            frappe.db.get_value('User', frm.doc.requester, 'department', (r) => {
                if (r && r.department) {
                    frm.set_value('requester_department', r.department);
                }
            });
        }
    }
});
```

### 4.2 The D-02 banner

When an advance is in status `Approved` (disbursement authorised but not yet paid), show a prominent informational banner so Finance Officers know the payment is pending. This is the UI expression of the `pending_payment_flag`.

```javascript
function show_d02_banner(frm) {
    frm.set_intro('');  // Clear any previous intro

    if (frm.doc.status === 'Approved' && frm.doc.pending_payment_flag) {
        frm.set_intro(
            __('This advance is approved and awaiting payment disbursement. ' +
               'Available budget is NOT yet reduced — it will decrease only after ' +
               'payment is processed (D-02 policy). Use "Mark as Paid" below ' +
               'once the cash has been transferred.'),
            'blue'
        );
    } else if (frm.doc.status === 'Overdue') {
        frm.set_intro(
            __('This advance is OVERDUE. Liquidation due date has passed. ' +
               'The requester has been notified. Finance Manager review required.'),
            'red'
        );
    } else if (frm.doc.status === 'Pending Liquidation') {
        const days = frappe.datetime.get_diff(
            frm.doc.liquidation_due_date,
            frappe.datetime.get_today()
        );
        if (days <= 3 && days >= 0) {
            frm.set_intro(
                __('Liquidation is due in {0} day(s). Remind the requester to ' +
                   'submit their accountability report.').replace('{0}', days),
                'orange'
            );
        }
    }
}
```

### 4.3 The "Mark as Paid" custom action button

The workflow transition from `Approved` to `Paid` requires a payment reference to be recorded. Rather than relying on the workflow button alone, add a custom button that opens a dialog to capture the reference before calling the server method:

```javascript
function setup_action_buttons(frm) {
    // Show "Mark as Paid" only when the form is Approved and the user
    // has the Finance Officer or Finance Manager role.
    if (frm.doc.status === 'Approved' && frm.doc.docstatus === 0) {
        const allowed_roles = ['Finance Officer', 'Finance Manager', 'System Manager'];
        const user_roles = frappe.user_roles;
        const can_pay = allowed_roles.some(r => user_roles.includes(r));

        if (can_pay) {
            frm.add_custom_button(__('Mark as Paid'), () => {
                mark_as_paid_dialog(frm);
            }, __('Actions'));
        }
    }
}

function mark_as_paid_dialog(frm) {
    const d = new frappe.ui.Dialog({
        title: __('Mark Advance as Paid'),
        fields: [
            {
                label: __('Payment Reference'),
                fieldname: 'payment_reference',
                fieldtype: 'Data',
                reqd: 1,
                description: __('Bank transfer reference number or payment voucher ID')
            },
            {
                label: __('Payment Date'),
                fieldname: 'payment_date',
                fieldtype: 'Date',
                reqd: 1,
                default: frappe.datetime.get_today()
            }
        ],
        primary_action_label: __('Confirm Payment'),
        primary_action(values) {
            frappe.call({
                method: 'fundara.financial_accountability.doctype' +
                        '.cash_advance.cash_advance.mark_as_paid',
                args: {
                    doc: frm.doc.name,
                    payment_reference: values.payment_reference,
                    payment_date: values.payment_date
                },
                callback(r) {
                    if (!r.exc) {
                        frm.reload_doc();
                        frappe.show_alert({
                            message: __('Advance marked as Paid.'),
                            indicator: 'green'
                        });
                    }
                }
            });
            d.hide();
        }
    });
    d.show();
}
```

### 4.4 Fetching and displaying fund balance

Finance Officers need to see the fund's available balance on the form before approving an amount. Fetch it via a server call and display it in a read-only field or as highlighted text:

```javascript
function fetch_and_display_fund_balance(frm) {
    if (!frm.doc.fund) return;

    frappe.call({
        method: 'fundara.financial_accountability.doctype' +
                '.cash_advance.cash_advance.get_fund_available_balance',
        args: { fund: frm.doc.fund },
        callback(r) {
            if (r.message !== undefined) {
                // Display in a read-only field or via set_df_property
                frm.set_df_property(
                    'fund',
                    'description',
                    __('Available balance: {0}').replace(
                        '{0}',
                        format_currency(r.message, frm.doc.currency)
                    )
                );
            }
        }
    });
}

function display_fund_balance(frm) {
    if (frm.doc.fund) {
        fetch_and_display_fund_balance(frm);
    }
}
```

Add the server-side method to `cash_advance.py` as a whitelisted standalone function:

```python
@frappe.whitelist()
def get_fund_available_balance(fund):
    """Return the available balance for a Fund.
    Called from the client script when the fund field changes.
    D-02: only paid transactions count against the balance.
    """
    doc = frappe.get_doc("Fund", fund)
    # Assumes Fund has a get_available_balance() method
    # that queries paid Cash Advances and Disbursements
    return doc.get_available_balance()
```

### 4.5 Filtering Link fields

Link fields without filters show every record of that DocType in the dropdown. Always filter them to relevant records:

```javascript
// In the refresh handler, or in a separate setup function called from refresh:

function setup_link_filters(frm) {
    // Only show Active funds in the Fund dropdown
    frm.set_query('fund', () => ({
        filters: { status: 'Active' }
    }));

    // Only show projects linked to the selected fund
    frm.set_query('project', () => ({
        filters: { fund: frm.doc.fund }
    }));

    // Only show activities that are Approved or In Progress
    frm.set_query('activity', () => ({
        filters: {
            project: frm.doc.project,
            status: ['in', ['Approved', 'In Progress']]
        }
    }));

    // Only show budget lines for the selected fund
    frm.set_query('budget_line', () => ({
        filters: { fund: frm.doc.fund }
    }));
}
```

Call `setup_link_filters(frm)` inside the `refresh` handler.

### 4.6 Dynamic field visibility beyond JSON `depends_on`

The DocType JSON supports `depends_on` for simple hide/show rules (e.g., `eval:doc.status=='Approved'`). For more complex conditions, override in JavaScript:

```javascript
function toggle_payment_fields(frm) {
    // Show payment fields only when status is Approved or beyond
    const show_payment = ['Approved', 'Paid', 'Pending Liquidation',
                          'Overdue', 'Liquidated', 'Closed'].includes(frm.doc.status);
    frm.toggle_display('payment_reference', show_payment);
    frm.toggle_display('payment_date', show_payment);
    frm.toggle_display('payment_journal_entry', show_payment);

    // The approved_amount field is only editable during Under Review
    frm.toggle_enable('approved_amount', frm.doc.status === 'Under Review');
}
```

Call `toggle_payment_fields(frm)` inside the `refresh` handler.

---

## 5. Implementing the Frappe Workflow

### 5.1 Create the workflow via Frappe UI

1. Go to `http://fundara.local:8000`
2. Navigate to **Setup > Workflow > New** (or search "Workflow" in the top bar)
3. Fill in the header:

| Field | Value |
|---|---|
| Workflow Name | `Cash Advance` |
| Document Type | `Cash Advance` |
| Is Active | Yes |
| Override Status | Yes |
| Send Email Alerts | Yes |

4. Add **Workflow States** — one row per state from `docs/spec/workflows.md ## Workflow 1: Cash Advance`:

| State | Doc Status | Style |
|---|---|---|
| Draft | 0 | default |
| Submitted | 0 | primary |
| Under Review | 0 | info |
| Approved | 0 | success |
| Paid | 1 | success |
| Pending Liquidation | 1 | warning |
| Overdue | 1 | danger |
| Liquidated | 1 | info |
| Closed | 1 | success |
| Rejected | 2 | danger |
| Cancelled | 2 | danger |

5. Add **Workflow Transitions** — copy from the spec table exactly, including the `Condition` column. Frappe evaluates conditions as Python expressions against the document:

| From State | To State | Action Label | Allowed Roles | Condition |
|---|---|---|---|---|
| Draft | Submitted | Submit for Review | Field Staff, Finance Officer, Project Manager | `doc.requested_amount > 0 and doc.fund and doc.activity` |
| Submitted | Under Review | Begin Review | Finance Officer, Finance Manager | — |
| Submitted | Rejected | Reject | Project Manager, Finance Officer, Finance Manager | — |
| Submitted | Draft | Return for Revision | Project Manager, Finance Officer, Finance Manager | — |
| Under Review | Approved | Approve | Finance Officer, Finance Manager | `doc.budget_available == 1` |
| Under Review | Rejected | Reject | Finance Officer, Finance Manager | — |
| Under Review | Draft | Return for Revision | Finance Officer, Finance Manager | — |
| Approved | Paid | Mark as Paid | Finance Officer, Finance Manager | `doc.payment_reference` |
| Approved | Cancelled | Cancel | Finance Manager | — |

> **Note on approval thresholds:** The spec states Finance Officer approves advances up to 50 million IDR, Finance Manager for amounts above that. Implement this as a server-side check in `validate()` or `before_submit()` — Frappe workflow conditions cannot call Python functions directly, so do not try to embed the threshold logic in the workflow condition string.

6. Save the workflow. Frappe validates it and activates it on the Cash Advance DocType.

### 5.2 Export the workflow as a fixture

Workflows must be committed to version control so they can be deployed to staging and production:

```bash
bench --site fundara.local export-doc Workflow "Cash Advance"
```

This creates:

```
fundara/fixtures/Workflow/Cash Advance.json
```

Verify the file exists:

```bash
ls fundara/fixtures/Workflow/
```

Ensure `hooks.py` includes the Workflow fixture type so it loads automatically on `bench migrate`:

```python
# fundara/hooks.py
fixtures = [
    {"dt": "Workflow", "filters": [["module", "=", "Fundara"]]},
    {"dt": "Workflow Action Master"},
    {"dt": "Workflow State"},
]
```

### 5.3 Testing the workflow manually

Log in as different users and test each state transition:

1. **As a Project Officer (Field Staff role):** Create a new Cash Advance, fill in all mandatory fields, click "Submit for Review" — verify status changes to Submitted.
2. **As a Finance Officer:** Open the submitted advance, click "Begin Review" — verify status changes to Under Review.
3. **As a Finance Officer:** With a valid budget, click "Approve" — verify status changes to Approved and the D-02 banner appears on the form.
4. **As a Finance Officer:** Click "Mark as Paid" with a payment reference — verify status changes to Paid and the Journal Entry is created.
5. **Negative test — as a Project Officer:** Try to click "Approve" directly from Submitted — verify the button does not appear (role restriction works).
6. **Negative test:** Try to approve when available budget is 0 — verify the transition is blocked by the `budget_available` condition.

### 5.4 Checking that forbidden transitions are blocked

Frappe enforces transition rules automatically — if a transition is not defined for a given state, the button does not appear. But there is a subtlety: Frappe workflow buttons appear based on the user's roles AND the current document state. If a button appears that should not, check:

1. The "Allowed Roles" column in the workflow definition — is the role listed?
2. The "From State" column — does it match the current state?
3. Developer mode quirk: System Manager can override all workflow restrictions. Always test with a non-admin user.

---

## 6. Writing Tests

### 6.1 Test file location and structure

```
fundara/financial_accountability/doctype/cash_advance/test_cash_advance.py
```

```python
import frappe
import unittest
from frappe.tests.utils import FrappeTestCase


class TestCashAdvance(FrappeTestCase):
    """Unit tests for Cash Advance — covers D-02 budget logic and core lifecycle.

    Test scenarios sourced from docs/spec/test-scenarios.md TC-CA-01 through
    TC-CA-10. Each test method maps to one scenario or one business rule.
    """

    def setUp(self):
        """Create the minimum test fixtures needed for every test.

        Creates: Fund, Project, Activity, Fund Budget Line.
        All records are created with flags that let tearDown clean them up.
        """
        self.test_fund = frappe.get_doc({
            "doctype": "Fund",
            "fund_name": "_Test Fund for Cash Advance",
            "fund_code": "_TFCA",
            "fund_type": "Unrestricted Fund",
            "restriction_type": "Unrestricted",
            "funding_source": frappe.db.get_value(
                "Funding Source", {"fund_source_name": ["like", "_Test%"]}, "name"
            ),
            "fund_owner": frappe.session.user,
            "start_date": "2026-01-01",
            "currency": "IDR",
            "status": "Active",
        }).insert(ignore_permissions=True)

        self.test_budget_line = frappe.get_doc({
            "doctype": "Fund Budget Line",
            "fund": self.test_fund.name,
            "budget_line_name": "_Test Travel Budget",
            "approved_amount": 10_000_000,
            "currency": "IDR",
        }).insert(ignore_permissions=True)

        # Project and Activity creation abbreviated for clarity —
        # use frappe.get_doc({...}).insert() as above

    def tearDown(self):
        """Delete all test records created in setUp to keep the test DB clean."""
        frappe.db.delete("Cash Advance",
                         {"purpose": ["like", "_Test%"]})
        frappe.db.delete("Fund Budget Line",
                         {"budget_line_name": "_Test Travel Budget"})
        frappe.db.delete("Fund",
                         {"fund_code": "_TFCA"})
        frappe.db.commit()

    # -------------------------------------------------------------------------
    # TC-CA-01 / D-02 core tests
    # -------------------------------------------------------------------------

    def test_budget_reduces_only_on_paid_not_on_approved(self):
        """D-02: available budget must not decrease when advance is Approved.

        Maps to TC-CA-01 edge case and docs/pm/definition-of-done.md
        Business Logic item: Budget formula (D-02).
        """
        # Create an advance and put it in Approved state
        advance = frappe.get_doc({
            "doctype": "Cash Advance",
            "requester": frappe.session.user,
            "fund": self.test_fund.name,
            "budget_line": self.test_budget_line.name,
            "currency": "IDR",
            "exchange_rate": 1.0,
            "requested_amount": 3_000_000,
            "approved_amount": 3_000_000,
            "purpose": "_Test advance for D-02 check",
            "posting_date": frappe.utils.today(),
            "liquidation_due_date": frappe.utils.add_days(frappe.utils.today(), 14),
            "status": "Approved",
            "pending_payment_flag": 1,
        }).insert(ignore_permissions=True)

        # Available balance must still be the full 10,000,000
        available = advance._get_budget_line_available_balance()
        self.assertEqual(
            available, 10_000_000,
            "Available balance should remain 10,000,000 when advance is Approved "
            "(D-02: only Paid transactions reduce the budget)."
        )

        # Simulate paying the advance
        advance.db_set("status", "Paid")
        advance.db_set("paid_amount", 3_000_000)

        # Now available balance must drop
        available_after_payment = advance._get_budget_line_available_balance()
        self.assertEqual(
            available_after_payment, 7_000_000,
            "Available balance should be 7,000,000 after payment of 3,000,000."
        )

    def test_cannot_exceed_fund_budget_on_approval(self):
        """Hard block when approved_amount would exceed available balance."""
        advance = frappe.get_doc({
            "doctype": "Cash Advance",
            "requester": frappe.session.user,
            "fund": self.test_fund.name,
            "budget_line": self.test_budget_line.name,
            "currency": "IDR",
            "exchange_rate": 1.0,
            "requested_amount": 12_000_000,  # exceeds 10M budget
            "approved_amount": 12_000_000,
            "purpose": "_Test over-budget advance",
            "posting_date": frappe.utils.today(),
            "liquidation_due_date": frappe.utils.add_days(frappe.utils.today(), 14),
            "status": "Under Review",
        })

        with self.assertRaises(frappe.exceptions.ValidationError) as ctx:
            advance.insert(ignore_permissions=True)

        self.assertIn("exceeds available budget", str(ctx.exception))

    def test_pending_payment_flag_cleared_on_paid(self):
        """pending_payment_flag must be 0 after Mark as Paid is processed."""
        advance = frappe.get_doc({
            "doctype": "Cash Advance",
            "requester": frappe.session.user,
            "fund": self.test_fund.name,
            "budget_line": self.test_budget_line.name,
            "currency": "IDR",
            "exchange_rate": 1.0,
            "requested_amount": 2_000_000,
            "approved_amount": 2_000_000,
            "purpose": "_Test flag cleared on paid",
            "posting_date": frappe.utils.today(),
            "liquidation_due_date": frappe.utils.add_days(frappe.utils.today(), 14),
            "status": "Approved",
            "pending_payment_flag": 1,
        }).insert(ignore_permissions=True)

        # Simulate the mark_as_paid action
        advance.mark_as_paid(
            payment_reference="TRF-TEST-001",
            payment_date=frappe.utils.today()
        )
        advance.reload()

        self.assertEqual(advance.pending_payment_flag, 0,
                         "pending_payment_flag must be 0 after payment.")
        self.assertEqual(advance.status, "Paid")

    def test_activity_must_be_approved_before_advance(self):
        """Business Rule 1: Activity in Draft status must block advance creation."""
        # This test requires a Draft Activity fixture — create inline
        # Abbreviated; full implementation follows the same pattern as setUp
        pass  # Implement with a Draft activity and assert ValidationError

    def test_cannot_cancel_after_paid(self):
        """Cancellation of a Paid advance must throw an error."""
        advance = frappe.get_doc({
            "doctype": "Cash Advance",
            "requester": frappe.session.user,
            "fund": self.test_fund.name,
            "budget_line": self.test_budget_line.name,
            "currency": "IDR",
            "exchange_rate": 1.0,
            "requested_amount": 1_000_000,
            "approved_amount": 1_000_000,
            "paid_amount": 1_000_000,
            "purpose": "_Test cannot cancel paid",
            "posting_date": frappe.utils.today(),
            "liquidation_due_date": frappe.utils.add_days(frappe.utils.today(), 14),
            "status": "Paid",
            "docstatus": 1,
        }).insert(ignore_permissions=True)

        with self.assertRaises(frappe.exceptions.ValidationError):
            advance.cancel()
```

### 6.2 Running the tests

Run only Cash Advance tests:

```bash
bench --site fundara.local run-tests --app fundara --doctype "Cash Advance"
```

Run all Financial Accountability tests:

```bash
bench --site fundara.local run-tests --app fundara --module financial_accountability
```

Run the full Fundara test suite:

```bash
bench --site fundara.local run-tests --app fundara
```

A passing run looks like:

```
Ran 5 tests in 3.421s
OK
```

Any failure output includes the test name, the assertion that failed, and the full traceback. Fix failures before pushing — do not push with failing tests.

### 6.3 Mapping tests to BDD scenarios

Each test method should reference the scenario ID from `docs/spec/test-scenarios.md` in its docstring. This makes it clear which acceptance criteria the test covers:

```python
def test_budget_reduces_only_on_paid_not_on_approved(self):
    """D-02: available budget must not decrease when advance is Approved.
    Covers: TC-CA-01 edge case, TC-BG-03.
    """
```

When a reviewer asks "does this story have test coverage for TC-CA-07?", they can search the test file for `TC-CA-07` in the docstring.

---

## 7. Database Migrations (Patches)

Frappe handles schema migrations automatically via `bench migrate` — new fields, new DocTypes, and field type changes are applied without manual SQL. You need a patch only when you need to **transform existing data** — not just change schema.

### 7.1 When do you need a patch?

Examples that require a patch:

- Backfilling a new field: "Set `pending_payment_flag = 1` for all existing Cash Advances in status Approved."
- Data migration: "Copy values from the old `amount` field into the new split `requested_amount` and `approved_amount` fields."
- Seeding reference data: "Insert the 8 Fund Type records if they do not already exist."

Examples that do NOT require a patch (handled by `bench migrate` automatically):
- Adding a new field to a DocType
- Changing a field label
- Creating a new DocType

### 7.2 Creating a patch

1. Create the patch file under the appropriate version folder:

```bash
# Path convention: fundara/patches/v1_0/[verb]_[what]_[on_what].py
touch fundara/patches/v1_0/set_pending_payment_flag_on_approved_advances.py
```

2. Write the patch. It must be **idempotent** — running it twice produces the same result as running it once:

```python
# fundara/patches/v1_0/set_pending_payment_flag_on_approved_advances.py
"""
Backfill patch: set pending_payment_flag = 1 for all Cash Advances
that are currently in status Approved and have not yet been paid.

Idempotency: uses UPDATE WHERE condition that only matches rows
where the flag is still 0. Safe to run multiple times.

Related decision: D-02.
"""

import frappe


def execute():
    frappe.db.sql(
        """
        UPDATE `tabCash Advance`
        SET pending_payment_flag = 1
        WHERE status = 'Approved'
          AND (paid_amount IS NULL OR paid_amount = 0)
          AND pending_payment_flag = 0
          AND docstatus = 0
        """
    )
    frappe.db.commit()
```

3. Register the patch in `fundara/patches.txt`:

```
# patches.txt — one patch per line, in execution order
fundara.patches.v1_0.set_pending_payment_flag_on_approved_advances
```

4. Run and verify:

```bash
bench --site fundara.local migrate
```

Look for the patch name in the migrate output. A line like:

```
Executing fundara.patches.v1_0.set_pending_payment_flag_on_approved_advances
```

confirms it ran. If the line is absent, the patch may have already run (check `tabPatch Log` in the database).

### 7.3 How to write a safe, idempotent patch

- **Always filter on current state** — use `WHERE` conditions that match only the rows that actually need changing.
- **Use `frappe.db.sql()` for bulk updates** — `frappe.get_all()` + `frappe.get_doc()` in a loop is correct but slow on large datasets. Use raw SQL for patches that touch more than ~100 rows.
- **Always call `frappe.db.commit()`** at the end — patches run in a transaction; without commit, changes are rolled back.
- **Test on a copy first** — if the patch touches more than 500 rows or alters financial data, test on a backup of the staging database before running on staging.
- **Do not run destructive operations without a backup** — patches that delete data or alter amounts need a verified backup first. Document this in the patch file's docstring.

---

## 8. Before Pushing — Local Checklist

Run this checklist in order before every `git push`. Do not skip items.

```
[ ] bench --site fundara.local migrate
    → Output ends with "Bench: Migrating Done" and no Python tracebacks

[ ] bench --site fundara.local run-tests --app fundara
    → Output ends with "OK" — zero failures, zero errors

[ ] bench build --app fundara
    → No JavaScript compilation errors in the output

[ ] Manual smoke test in the browser:
    → Create a new Cash Advance as Project Officer → fill all fields → Submit for Review
    → Log in as Finance Officer → Begin Review → Approve
    → Mark as Paid with a test reference number
    → Verify the Journal Entry was created (check Journal Entry list)
    → Verify pending_payment_flag = 0 on the advance
    → Verify the fund balance field updated
    → Verify no console errors in the browser developer tools (F12)

[ ] git diff — no unintended files staged:
    → site_config.json must NOT be committed (contains passwords)
    → *.pyc, __pycache__/ must NOT be committed (add to .gitignore if needed)
    → No .env files, no local test data files

[ ] Commit messages follow the format:
    → [domain]: [short description]
    → Example: financial-accountability: add Cash Advance DocType and D-02 budget check
    → No "Co-Authored-By" lines (project audit trail policy — see CONTRIBUTING.md §9.2)
```

If any item fails, fix it before pushing. A broken test pushed to `main` blocks everyone.

---

## 9. Pull Request Process

### 9.1 Push your branch

```bash
git push -u origin feature/financial-accountability-cash-advance
```

### 9.2 Create the pull request

On GitHub, create the PR with:

**Title format:** `[domain]: short description`

Example: `financial-accountability: implement Cash Advance with D-02 budget logic`

Keep the title under 72 characters. The domain prefix matches the branch prefix.

**PR description template:**

```markdown
## What was implemented

Cash Advance DocType (Layer 4 — Financial Accountability). Covers the full
lifecycle from Draft through to Closed, including:
- DocType definition with all fields from
  docs/spec/doctypes/06-financial-accountability-doctypes.md
- D-02 budget check: approved_amount validated against paid-only transactions
- GL posting on Mark as Paid (JE-06: Dr Uang Muka / Cr Bank)
- Workflow with 11 states per docs/spec/workflows.md Workflow 1
- Client script: D-02 banner, Mark as Paid dialog, fund balance display
- Unit tests: TC-CA-01, TC-CA-07 (D-02 core cases)

## Spec documents followed

- docs/spec/doctypes/06-financial-accountability-doctypes.md — Cash Advance section
- docs/spec/workflows.md — Workflow 1: Cash Advance
- docs/accounting/journal-entries.md — JE-06
- DECISIONS.md — D-02

## How to test

1. Enable developer mode: `bench --site fundara.local set-config developer_mode 1`
2. Run migrate: `bench --site fundara.local migrate`
3. Clear cache: `bench --site fundara.local clear-cache`
4. Log in as Project Officer → create a new Cash Advance → fill fund, project,
   activity, budget_line, requested_amount, liquidation_due_date → Submit for Review
5. Log in as Finance Officer → Begin Review → Approve
6. As Finance Officer → click Mark as Paid → enter payment reference → confirm
7. Verify: Journal Entry created, pending_payment_flag = 0, status = Paid
8. Verify: Fund balance field shows reduced amount
9. Run tests: `bench --site fundara.local run-tests --app fundara --doctype "Cash Advance"`

## D-02 verification step

After step 5 (Approved but before step 6 Paid): navigate to the Fund record
and verify available_balance has NOT changed. It should change only after step 6.
```

### 9.3 Who reviews

| Reviewer | Required when |
|---|---|
| Tech Lead | Always — code review for all PRs before merge |
| Finance Domain Expert | When the story involves GL entries, journal entry rules, ISAK 35 mapping, budget calculations, or any item in `docs/accounting/` |
| Program Domain Expert | When the story involves activity approval workflow, procurement thresholds, advance and liquidation rules, or MEAL integration |

Cash Advance requires **both** Tech Lead and Finance Domain Expert review because it posts GL entries and implements D-02 budget logic.

### 9.4 What the Tech Lead checks

Per `CONTRIBUTING.md`:

- Field names follow the snake_case convention
- D-02 constraint is implemented correctly — no budget deduction on Approve
- GL entries are posted only in `on_submit()` or a dedicated method, not in `validate()`
- `frappe.throw()` is used for hard blocks, not `frappe.msgprint()`
- Tests cover the happy path and at least one negative case
- No `print()` statements left in production code
- No hardcoded account names — account names come from Fundara Settings or a configurable reference
- `amended_from` field exists on the submittable DocType

### 9.5 Addressing review comments

When a reviewer leaves a comment:

1. Do not resolve the comment yourself — that is the reviewer's job after they are satisfied.
2. Make the fix in the same branch (new commit, not amend — the PR history must stay readable).
3. Reply to the comment with a brief note: "Fixed in commit abc1234 — moved the budget check from on_submit to validate() as requested."
4. Re-request review from the reviewer after all comments are addressed.

### 9.6 Merge policy

**Squash merge** for feature branches before they merge to `main`. This keeps `main`'s history clean — one commit per feature. The squash commit message should be the PR title.

The Tech Lead performs the merge. Developers do not merge their own PRs.

---

## 10. After Merge — Staging Deployment

### 10.1 Who deploys to staging

The Tech Lead deploys to staging after merge. Developers do not push to staging directly. If a developer needs something on staging urgently, request it from the Tech Lead with the PR number.

### 10.2 Deployment command sequence

On the staging server:

```bash
# 1. Pull the latest main
cd ~/fundara-bench
git -C apps/fundara pull origin main

# 2. Apply database migrations
bench --site fundara.local migrate

# 3. Rebuild JavaScript assets
bench build --app fundara

# 4. Restart all services (web, worker, scheduler)
bench restart
```

Run these steps in order. Do not restart before migrating — old code running against a new schema causes errors. Do not skip `bench build` — stale JS bundles mean the browser sees old code.

### 10.3 Smoke test on staging before marking Done

After deployment, the Tech Lead or a designated developer runs a smoke test on the staging environment:

1. Open the staging site in a browser
2. Create a Cash Advance as Project Officer — verify the form loads, all fields are present, no console errors
3. Move through the workflow to Paid — verify GL entry is created
4. Check the Advance Aging report includes the new advance
5. Verify D-02: check fund balance before and after the Paid transition

If any step fails, the story is not Done — raise a bug, revert if necessary, and fix before closing the story.

### 10.4 Who signs off

Per `docs/pm/definition-of-done.md` Level 1, a story is Done only when:

1. The Level 1 DoD checklist is fully checked — all implementation, business logic, and quality items
2. The Tech Lead has reviewed and approved the code
3. If GL entries or accounting logic is involved (Cash Advance qualifies): the Finance Domain Expert has reviewed and confirmed the GL posting is correct
4. The smoke test on staging passes

The PM closes the story card only after receiving sign-off from both the Tech Lead and (for Cash Advance) the Finance Domain Expert. The story is not Done until staging is verified.

---

## Quick Reference

| Question | Where to look |
|---|---|
| What fields does Cash Advance have? | `docs/spec/doctypes/06-financial-accountability-doctypes.md` |
| What are the workflow states and transitions? | `docs/spec/workflows.md` — Workflow 1 |
| What GL entries does Cash Advance post? | `docs/accounting/journal-entries.md` — JE-06, JE-07, JE-08 |
| Which roles can approve? | `docs/spec/permissions.md` + `docs/spec/workflows.md` Transitions table |
| What tests must pass? | `docs/spec/test-scenarios.md` — TC-CA-01 through TC-CA-10 |
| What does D-02 mean? | `DECISIONS.md` — D-02 |
| What DocTypes must exist before Cash Advance? | `docs/pm/dependency-map.md` — Layer 4 prerequisites |
| What does Done mean for this story? | `docs/pm/definition-of-done.md` — Level 1 |
| ERPNext v16 API reference | https://frappeframework.com/docs/v16 |
