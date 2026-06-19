# Frappe Developer Cookbook — Fundara

Referensi cepat pola-pola Frappe v16 yang dipakai berulang dalam pengembangan Fundara. Ini bukan tutorial — ini recipe book. Setiap resep adalah snippet siap-pakai dengan penjelasan singkat.

**Konteks wajib sebelum pakai cookbook ini:**
- Baca `DECISIONS.md` — terutama D-02 (budget hanya berkurang saat Paid) dan D-04 (multi-currency wajib)
- Baca `docs/spec/doctypes/` untuk field spec DocType yang sedang dikerjakan
- Baca `docs/accounting/journal-entries.md` sebelum menulis GL posting

---

## 1. Frappe Console Recipes

Buka console dengan: `bench --site fundara.local console`

### Get a document

```python
doc = frappe.get_doc("Cash Advance", "ADV-2026-0001")
print(doc.status, doc.amount, doc.fund)
```

### Create a document programmatically

```python
doc = frappe.new_doc("Fund")
doc.fund_name = "Test Grant Fund"
doc.fund_type = "Grant Fund"
doc.insert()
frappe.db.commit()
```

> `insert()` saves the doc and assigns the `name` field. Call `frappe.db.commit()` explicitly in console — in production code it is handled automatically at request end.

### Query the database

```python
results = frappe.db.get_all(
    "Cash Advance",
    filters={"status": "Approved", "fund": "FUND-2026-0001"},
    fields=["name", "amount", "staff_name"],
    order_by="creation desc",
    limit=10
)
```

### Get a single field value

```python
balance = frappe.db.get_value("Fund", "FUND-2026-0001", "available_balance")

# Get multiple fields at once — returns a dict
vals = frappe.db.get_value(
    "Fund", "FUND-2026-0001",
    ["available_balance", "currency", "status"],
    as_dict=True
)
```

### Update a field without loading the whole document

```python
frappe.db.set_value("Cash Advance", "ADV-2026-0001", "status", "Paid")
frappe.db.commit()
```

> Prefer `set_value` for single-field updates in background tasks. It bypasses `validate` hooks — only use when you explicitly want that.

### Check if a document exists

```python
if frappe.db.exists("Cash Advance", "ADV-2026-0001"):
    doc = frappe.get_doc("Cash Advance", "ADV-2026-0001")

# With filters
if frappe.db.exists("Cash Advance", {"fund": "FUND-2026-0001", "status": "Approved"}):
    print("There is an open approved advance on this fund")
```

### Get child table rows

```python
doc = frappe.get_doc("Fund Budget", "BUDG-2026-0001")
for line in doc.budget_lines:  # child table field name
    print(line.budget_line_name, line.approved_amount)

# Or query the child table directly
lines = frappe.db.get_all(
    "Fund Budget Line",
    filters={"parent": "BUDG-2026-0001", "parenttype": "Fund Budget"},
    fields=["name", "budget_line_name", "approved_amount", "actual_amount"]
)
```

### Create child table rows programmatically

```python
doc = frappe.get_doc("Fund Budget", "BUDG-2026-0001")
doc.append("budget_lines", {
    "budget_line_name": "Program Staff",
    "approved_amount": 50000000,
    "currency": "IDR",
})
doc.save()
frappe.db.commit()
```

> `append(fieldname, row_dict)` adds a row to a child table. `fieldname` is the field name on the parent DocType, not the child DocType name.

### Delete a test document

```python
frappe.delete_doc("Fund", "FUND-TEST-0001", force=True)
frappe.db.commit()
```

> `force=True` deletes even if there are linked documents. Use only in dev/testing — in production, let Frappe enforce link integrity.

### Reload a document from DB

```python
doc = frappe.get_doc("Cash Advance", "ADV-2026-0001")
# ... some other process updates the DB ...
doc.reload()  # refreshes doc fields from DB
print(doc.status)
```

### Run a raw SQL query (use sparingly)

```python
results = frappe.db.sql("""
    SELECT name, amount FROM `tabCash Advance`
    WHERE fund = %s AND status = 'Paid'
""", ("FUND-2026-0001",), as_dict=True)
```

> Use `frappe.db.get_all()` first. Drop to raw SQL only for complex JOINs or aggregations that `get_all` cannot express. Always use parameterized queries — never f-strings with user input.

---

## 2. DocType Controller Patterns

File: `fundara/financial_accountability/doctype/cash_advance/cash_advance.py`

### Standard hooks

```python
import frappe
from frappe.model.document import Document


class CashAdvance(Document):

    def autoname(self):
        # Only override if naming_series is not sufficient
        # Usually not needed — set naming_series in DocType JSON instead
        pass

    def validate(self):
        self.validate_fund_balance()
        self.validate_period()
        self.validate_activity_status()

    def before_save(self):
        self.set_computed_fields()
        # Recalculate amount_base in case exchange_rate changed
        self.amount_base = (self.amount or 0) * (self.exchange_rate or 1)

    def on_submit(self):
        # D-02: do NOT post GL or deduct budget here — only on Paid
        pass

    def on_cancel(self):
        if self.status == "Paid":
            frappe.throw(
                "Advance yang sudah Paid tidak bisa dibatalkan langsung. Buat Amendment.",
                title="Tidak Bisa Dibatalkan"
            )
        self.reverse_gl_entries()

    def validate_fund_balance(self):
        """D-02: only a warning here — actual check at payment time."""
        available = frappe.db.get_value("Fund", self.fund, "available_balance")
        pending = frappe.db.get_value("Fund", self.fund, "total_pending_payment") or 0
        effective_available = (available or 0) - pending
        if self.amount > effective_available:
            frappe.msgprint(
                f"Perhatian: ada antrean pembayaran pending sebesar "
                f"{frappe.format_value(pending, {'fieldtype': 'Currency'})}. "
                f"Saldo efektif tersedia: {frappe.format_value(effective_available, {'fieldtype': 'Currency'})}.",
                indicator="orange",
                title="Peringatan Saldo"
            )

    @frappe.whitelist()
    def mark_as_paid(self):
        """Called from client via frm.call('mark_as_paid').
        D-02: this is where budget reduction happens."""
        frappe.has_permission(self.doctype, "write", self, throw=True)
        if self.status != "Approved":
            frappe.throw("Hanya advance dengan status Approved yang bisa dibayar.")
        self.status = "Paid"
        self.pending_payment_flag = 0
        self.payment_date = frappe.utils.today()
        self.save()
        self.post_gl_entries()         # GL debit: advance receivable, credit: bank
        self.update_fund_budget()      # D-02: reduce budget here
```

### Permission check inside a method

```python
def approve(self):
    # Check that the current user has Submit permission on this DocType
    frappe.has_permission(self.doctype, "submit", self, throw=True)

    # Check a specific role
    if "Finance Manager" not in frappe.get_roles():
        frappe.throw("Hanya Finance Manager yang bisa menyetujui advance ini.")

    # Check ownership
    if self.owner != frappe.session.user and "System Manager" not in frappe.get_roles():
        frappe.throw("Kamu hanya bisa menyetujui advance yang kamu buat sendiri.")
```

### Send email from a controller

```python
def notify_staff_on_approval(self):
    staff_email = frappe.db.get_value("User", self.staff_name, "email")
    if not staff_email:
        return

    frappe.sendmail(
        recipients=[staff_email],
        subject=f"Cash Advance {self.name} Disetujui",
        template="cash_advance_approved",   # template in fundara/templates/emails/
        args={
            "doc": self,
            "advance_link": frappe.utils.get_url_to_form(self.doctype, self.name),
        },
        now=False,  # False = queued via background worker
    )
```

> Email templates live in `fundara/templates/emails/[template_name].html` and `.txt`. Always use `now=False` to avoid blocking the request.

### Create a related document from a controller

```python
def create_liquidation_stub(self):
    """Auto-create a blank Advance Liquidation when advance status becomes Paid."""
    if frappe.db.exists("Advance Liquidation", {"cash_advance": self.name}):
        return  # already exists, do not duplicate

    liq = frappe.new_doc("Advance Liquidation")
    liq.cash_advance = self.name
    liq.staff_name = self.staff_name
    liq.fund = self.fund
    liq.project = self.project
    liq.cost_center = self.cost_center
    liq.advance_amount = self.amount
    liq.currency = self.currency
    liq.exchange_rate = self.exchange_rate
    liq.liquidation_due_date = frappe.utils.add_days(self.payment_date, 14)
    liq.insert(ignore_permissions=True)
    # Do not commit here — let the calling transaction commit
```

### Use frappe.enqueue for background tasks

```python
def on_submit(self):
    # Heavy computation or bulk notification — do not block the request
    frappe.enqueue(
        "fundara.financial_accountability.doctype.cash_advance.cash_advance.send_payment_notifications",
        cash_advance=self.name,
        queue="long",       # "default" | "long" | "short"
        timeout=300,
        is_async=True,
    )

# The enqueued function must be importable at module level
def send_payment_notifications(cash_advance):
    doc = frappe.get_doc("Cash Advance", cash_advance)
    # ... send emails, update dashboards, etc.
```

---

## 3. GL Posting Pattern

Always read `docs/accounting/journal-entries.md` before writing a GL posting function. The account names, debit/credit sides, and Fundara accounting dimensions are specified there per transaction type.

```python
from erpnext.accounts.general_ledger import make_gl_entries


def post_gl_entries(self):
    """Post GL entries for Cash Advance payment (status: Approved → Paid).
    D-02: this is the moment budget is reduced — see docs/accounting/journal-entries.md."""
    gl_entries = []

    # Debit: Cash Advance Receivable (asset increases)
    gl_entries.append(self.get_gl_dict({
        "account": self.advance_account,      # e.g. "1300 - Uang Muka Staf"
        "debit": self.amount_base,
        "debit_in_account_currency": self.amount,
        "against": self.staff_name,
        "against_voucher_type": self.doctype,
        "against_voucher": self.name,
        "remarks": f"Cash Advance {self.name} — {self.purpose}",
        # Fundara accounting dimensions (required on all GL entries)
        "fund": self.fund,
        "project": self.project,
        "cost_center": self.cost_center,
    }, self.currency))

    # Credit: Bank/Cash (asset decreases)
    gl_entries.append(self.get_gl_dict({
        "account": self.payment_account,      # e.g. "1100 - Kas/Bank"
        "credit": self.amount_base,
        "credit_in_account_currency": self.amount,
        "against": self.staff_name,
        "remarks": f"Cash Advance {self.name} — pembayaran",
        "fund": self.fund,
        "project": self.project,
        "cost_center": self.cost_center,
    }, self.currency))

    make_gl_entries(gl_entries)


def reverse_gl_entries(self):
    """Reverse all GL entries for this voucher. Called on on_cancel."""
    from erpnext.accounts.general_ledger import make_reverse_gl_entries
    make_reverse_gl_entries(voucher_type=self.doctype, voucher_no=self.name)
```

### Verify GL entries posted correctly (console)

```python
frappe.db.get_all(
    "GL Entry",
    filters={"voucher_no": "ADV-2026-0001", "is_cancelled": 0},
    fields=["account", "debit", "credit", "fund", "project", "cost_center"]
)
```

---

## 4. Client Script Patterns

File: `fundara/financial_accountability/doctype/cash_advance/cash_advance.js`

### Form refresh and custom buttons

```javascript
frappe.ui.form.on('Cash Advance', {
    refresh(frm) {
        // D-02 info banner — show pending payment warning
        if (frm.doc.status === 'Approved' && frm.doc.pending_payment_flag) {
            frm.set_intro(
                __('Advance ini belum dibayar. Budget belum berkurang. Proses pembayaran untuk mencatat pengurangan budget.'),
                'orange'
            );
        }

        // Custom action button — only on saved, submitted docs
        if (frm.doc.status === 'Approved' && !frm.doc.__islocal && frm.doc.docstatus === 1) {
            frm.add_custom_button(__('Bayar'), () => {
                frappe.confirm(
                    __('Konfirmasi pembayaran Cash Advance {0}?', [frm.doc.name]),
                    () => {
                        frm.call('mark_as_paid').then(() => {
                            frm.refresh();
                            frappe.show_alert({
                                message: __('Pembayaran berhasil dicatat'),
                                indicator: 'green'
                            });
                        });
                    }
                );
            }, __('Tindakan'));
        }
    },

    // Filter fund to Active, submitted funds only
    setup(frm) {
        frm.set_query('fund', () => ({
            filters: { status: 'Active', docstatus: 1 }
        }));

        // Filter activity to Approved or In Progress, linked to same project
        frm.set_query('activity', () => ({
            filters: {
                project: frm.doc.project || '',
                status: ['in', ['Approved', 'In Progress']],
            }
        }));
    },

    // Auto-populate fields when fund is selected
    fund(frm) {
        if (frm.doc.fund) {
            frappe.db.get_value(
                'Fund',
                frm.doc.fund,
                ['currency', 'available_balance', 'cost_center'],
                (r) => {
                    frm.set_value('currency', r.currency);
                    frm.set_value('cost_center', r.cost_center);
                    frm.get_field('fund').set_description(
                        __('Saldo tersedia: {0}', [
                            format_currency(r.available_balance, r.currency)
                        ])
                    );
                }
            );
        }
    },

    // Recompute base amount whenever amount or exchange_rate changes
    amount(frm) { update_base_amount(frm); },
    exchange_rate(frm) { update_base_amount(frm); },
});

function update_base_amount(frm) {
    frm.set_value('amount_base', (frm.doc.amount || 0) * (frm.doc.exchange_rate || 1));
}
```

### Child table row operations

```javascript
// Add a row to a child table
frm.add_child('expense_lines', {
    description: 'Transport',
    amount: 150000,
    account: '5100 - Biaya Transport',
});
frm.refresh_field('expense_lines');

// Iterate over child rows
(frm.doc.expense_lines || []).forEach(row => {
    console.log(row.description, row.amount);
});

// Sum a child table field
const total = (frm.doc.expense_lines || [])
    .reduce((sum, row) => sum + (row.amount || 0), 0);
frm.set_value('total_expense', total);

// Remove a row by index
frm.doc.expense_lines.splice(rowIndex, 1);
frm.refresh_field('expense_lines');
```

### Form dialog (frappe.prompt)

```javascript
// Single field
frappe.prompt(
    { label: 'Alasan penolakan', fieldtype: 'Small Text', reqd: 1 },
    (values) => {
        frm.call('reject', { reason: values.value }).then(() => frm.refresh());
    },
    __('Tolak Advance'),
    __('Simpan')
);

// Multiple fields
frappe.prompt(
    [
        { label: 'Tanggal Bayar', fieldname: 'payment_date', fieldtype: 'Date', reqd: 1 },
        { label: 'Referensi', fieldname: 'reference_no', fieldtype: 'Data' },
    ],
    (values) => {
        frm.call('process_payment', {
            payment_date: values.payment_date,
            reference_no: values.reference_no,
        }).then(() => frm.refresh());
    },
    __('Proses Pembayaran'),
    __('Bayar')
);
```

### Confirmation dialog (frappe.confirm)

```javascript
frappe.confirm(
    __('Yakin ingin membatalkan advance ini? Tindakan ini tidak bisa diurungkan.'),
    () => {
        // User clicked Yes
        frm.call('cancel_advance').then(() => frm.refresh());
    },
    () => {
        // User clicked No — optional
        frappe.show_alert({ message: __('Pembatalan dibatalkan'), indicator: 'blue' });
    }
);
```

### Progress indicator for long operations

```javascript
frappe.call({
    method: 'fundara.api.generate_grant_report',
    args: { grant: frm.doc.name },
    freeze: true,                         // grays out the page
    freeze_message: __('Membuat laporan grant, harap tunggu...'),
    callback(r) {
        if (r.message) {
            frappe.show_alert({ message: __('Laporan berhasil dibuat'), indicator: 'green' });
            frm.refresh();
        }
    }
});
```

---

## 5. Whitelisted API Methods

File: `fundara/api.py` — callable from browser via `frappe.call()` or from external systems via HTTP.

```python
import frappe


@frappe.whitelist()
def get_fund_balance(fund):
    """Returns fund balance info. Called from client dashboard and client scripts.

    Usage from JS:
        frappe.call('fundara.api.get_fund_balance', { fund: 'FUND-2026-0001' }, r => {
            console.log(r.message.available_balance);
        });
    """
    frappe.has_permission("Fund", throw=True)
    doc = frappe.get_doc("Fund", fund)
    return {
        "available_balance": doc.available_balance,
        "total_paid": doc.total_paid,
        "total_pending_payment": doc.total_pending_payment,
        "currency": doc.currency,
    }


@frappe.whitelist()
def get_open_advances_for_fund(fund):
    """Returns all Approved (unpaid) advances for a fund.
    Used for the D-02 pending payment warning on Fund dashboard."""
    frappe.has_permission("Cash Advance", throw=True)
    return frappe.db.get_all(
        "Cash Advance",
        filters={"fund": fund, "status": "Approved", "docstatus": 1},
        fields=["name", "staff_name", "amount", "currency", "creation"],
        order_by="creation asc",
    )


@frappe.whitelist(allow_guest=True)
def health():
    """Health check endpoint for uptime monitoring.
    Accessible without login: GET /api/method/fundara.api.health"""
    return {
        "status": "ok",
        "app": "fundara",
        "frappe": frappe.__version__,
        "site": frappe.local.site,
    }
```

### Call a whitelisted method from JavaScript

```javascript
// Simple call
frappe.call('fundara.api.get_fund_balance', { fund: frm.doc.fund })
    .then(r => {
        if (r.message) {
            console.log(r.message.available_balance);
        }
    });

// With error handling
frappe.call({
    method: 'fundara.api.get_open_advances_for_fund',
    args: { fund: frm.doc.fund },
    callback(r) {
        if (r.message && r.message.length > 0) {
            frappe.msgprint(`Ada ${r.message.length} advance yang belum dibayar di fund ini.`);
        }
    },
    error(r) {
        frappe.msgprint('Gagal mengambil data advance.', 'Error');
    }
});
```

---

## 6. Scheduled Jobs (hooks.py)

```python
# fundara/hooks.py

scheduler_events = {
    "daily": [
        # Mark Cash Advances as Overdue when liquidation_due_date has passed
        "fundara.tasks.daily.mark_overdue_advances",
        # Transition Grant Reporting Schedule: Upcoming → Due Soon → Overdue
        "fundara.tasks.daily.update_grant_reporting_schedule_status",
        # Optional: send daily digest to Finance Officer
        "fundara.tasks.daily.send_business_digest",
    ],
    "weekly": [
        "fundara.tasks.weekly.check_grant_reporting_deadlines",
        "fundara.tasks.weekly.send_advance_aging_summary",
    ],
    "monthly": [
        "fundara.tasks.monthly.post_depreciation_entries",
    ],
    "cron": {
        # Weekdays at 08:00 — morning reminder for open tasks
        "0 8 * * 1-5": [
            "fundara.tasks.morning.send_daily_reminders",
        ],
        # Every 6 hours — keep Fund available_balance in sync
        "0 */6 * * *": [
            "fundara.tasks.sync.recalculate_fund_balances",
        ],
    }
}
```

### Task function template

```python
# fundara/tasks/daily.py
import frappe


def mark_overdue_advances():
    """Auto-transition Cash Advance to Overdue when liquidation_due_date has passed.
    Called daily by scheduler. D-02 context: does not affect budget — only status."""
    today = frappe.utils.today()
    overdue_advances = frappe.db.get_all(
        "Cash Advance",
        filters={
            "status": "Pending Liquidation",
            "liquidation_due_date": ["<", today],
        },
        fields=["name"],
    )
    for row in overdue_advances:
        frappe.db.set_value("Cash Advance", row.name, "status", "Overdue")

    frappe.db.commit()
    frappe.logger().info(f"mark_overdue_advances: {len(overdue_advances)} advances marked Overdue")
```

---

## 7. Fixtures and Seed Data

Fixtures ship with the app and are imported automatically on `bench migrate` or `bench --site fundara.local install-app fundara`.

### Declare fixtures in hooks.py

```python
# fundara/hooks.py
fixtures = [
    # Export all records of a simple master
    {"dt": "Fund Type"},
    {"dt": "Evidence Type"},
    {"dt": "Activity Type"},

    # Export only Fundara workflows
    {"dt": "Workflow", "filters": [["module", "=", "Fundara"]]},
    {"dt": "Workflow State", "filters": [["workflow", "like", "Cash Advance%"]]},

    # Export custom fields added to ERPNext core DocTypes
    {
        "dt": "Custom Field",
        "filters": [["dt", "in", ["Journal Entry", "Cost Center", "Department"]]]
    },

    # Export property setters (UI customizations on core DocTypes)
    {"dt": "Property Setter"},
]
```

### Export fixture data from a running site

```bash
# Export all records of a DocType declared in fixtures
bench --site fundara.local export-fixtures

# Export a specific document
bench --site fundara.local export-doc "Fund Type" "Grant Fund"
# File appears in: fundara/fixtures/fund_type/Grant Fund.json

# After exporting, files are in fundara/fixtures/
# Commit them to git — they travel with the app
```

### Import fixtures manually (debugging)

```bash
bench --site fundara.local import-doc fundara/fixtures/fund_type/Grant\ Fund.json
```

### Seed data via patch (one-time migration)

For seed data that cannot be expressed as a fixture (e.g., depends on site-specific config), use a patch:

```python
# fundara/patches/v0_1/seed_default_fund_types.py
import frappe


def execute():
    fund_types = [
        {"fund_type_name": "Grant Fund", "is_restricted": 1},
        {"fund_type_name": "Unrestricted Fund", "is_restricted": 0},
        {"fund_type_name": "Endowment Fund", "is_restricted": 1},
    ]
    for ft in fund_types:
        if not frappe.db.exists("Fund Type", ft["fund_type_name"]):
            frappe.get_doc({"doctype": "Fund Type", **ft}).insert()
    frappe.db.commit()
```

Add the patch path to `fundara/patches.txt`:

```
fundara.patches.v0_1.seed_default_fund_types
```

---

## 8. Debugging Recipes

### Inspect GL entries for a voucher

```python
frappe.db.get_all(
    "GL Entry",
    filters={"voucher_no": "ADV-2026-0001", "is_cancelled": 0},
    fields=["account", "debit", "credit", "fund", "project", "cost_center", "posting_date"]
)
```

### Inspect a workflow's current configuration

```python
frappe.get_doc("Workflow", "Cash Advance").as_dict()
```

### Check which patches have run

```python
frappe.db.get_all(
    "Patch Log",
    filters={"patch": ["like", "%fundara%"]},
    fields=["patch", "creation"],
    order_by="creation desc"
)
```

### Check a user's roles

```python
frappe.get_roles("wahyu@combine.id")
```

### Trace permission errors

```python
# Is this user allowed to submit this document?
frappe.has_permission("Cash Advance", "submit", "ADV-2026-0001", user="wahyu@combine.id")
```

### Find what's causing a budget discrepancy (D-02 audit)

```python
# All paid cash advances against a fund
frappe.db.sql("""
    SELECT name, staff_name, amount_base, payment_date
    FROM `tabCash Advance`
    WHERE fund = %s AND status IN ('Paid', 'Liquidated', 'Closed')
    ORDER BY payment_date
""", ("FUND-2026-0001",), as_dict=True)
```

### Reload cache and run migrations after JSON edits

```bash
# After editing a DocType JSON manually
bench --site fundara.local clear-cache
bench --site fundara.local migrate

# Watch logs in real time
bench logs --web       # web worker logs (request errors, tracebacks)
bench logs --worker    # background worker logs (scheduler, enqueue)

# Restart all workers
bench restart
```

### Force reload a DocType definition

```bash
bench --site fundara.local execute frappe.reload_doctype --args "['Cash Advance']"
```

---

## Quick Reference

| Butuh apa | Pakai ini |
|---|---|
| Fetch one doc | `frappe.get_doc(doctype, name)` |
| Fetch many docs | `frappe.db.get_all(doctype, filters, fields)` |
| Fetch one field | `frappe.db.get_value(doctype, name, field)` |
| Update one field | `frappe.db.set_value(doctype, name, field, value)` |
| Doc exists? | `frappe.db.exists(doctype, name_or_filters)` |
| Throw user error | `frappe.throw("Pesan", title="Judul")` |
| Non-blocking warning | `frappe.msgprint("Pesan", indicator="orange")` |
| Check permission | `frappe.has_permission(doctype, ptype, doc, throw=True)` |
| Run in background | `frappe.enqueue("module.function", arg=val)` |
| Reverse GL entries | `make_reverse_gl_entries(voucher_type=..., voucher_no=...)` |
| GL posting rules | `docs/accounting/journal-entries.md` |
| Field spec | `docs/spec/doctypes/` |
| Arch decisions | `DECISIONS.md` |
