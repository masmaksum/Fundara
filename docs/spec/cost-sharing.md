# Cost Sharing and Split-Fund Specification

**Scope:** Implementation detail for allocating a single expense across multiple funds in Fundara MVP.
**Domain context reference:** `fundara-domain-contexts/03-fund-stewardship-context.md`, `fundara-domain-contexts/06-financial-accountability-context.md`
**Decision reference:** `DECISIONS.md` D-02 (budget impact only on payment), D-04 (multi-currency aware)

---

## 1. Cost Sharing Definition

**Cost sharing** is the practice of distributing the cost of a single expenditure item across two or more funds, where each fund bears a defined portion of the total cost. The total of all fund portions must equal 100% of the expense.

### 1.1 When Cost Sharing Applies

Cost sharing is applicable when:

- A staff member works across multiple programs or projects simultaneously (staff time allocation)
- A vehicle, office space, or equipment is used by multiple projects in the same period
- Overhead or administrative costs are charged to multiple grant funds according to a predetermined allocation rate
- A training event or workshop benefits participants from multiple programs
- Co-funded activities where two or more donors each cover a share of the same deliverable

### 1.2 What Cost Sharing Is Not

Cost sharing does not apply to:

- Expenses clearly belonging to one fund only (no split needed)
- Inter-fund transfers (fund transfer has its own DocType and workflow)
- Bridging fund settlements (separate mechanism; see `03-fund-stewardship-context.md` Section 4.6)
- Reimbursements to staff who paid out of pocket (use Reimbursement Request)

### 1.3 Terminology

| Term | Definition |
|---|---|
| Split expense | The parent transaction representing the full cost |
| Fund split line | One row in the cost allocation child table, representing one fund's share |
| Allocation method | The rule used to determine each fund's portion (percentage, fixed amount, or activity-based) |
| Indirect cost rate | A pre-agreed percentage applied to direct costs to recover overhead |

---

## 2. Allocation Methods

Fundara supports three allocation methods for split-fund expenses. The method is selected at the transaction level and applies to all split lines within that transaction.

### 2.1 Percentage Split

Each fund is assigned a percentage of the total expense amount. Percentages must sum to exactly 100%.

**Use when:** The split ratio is policy-defined (e.g., staff allocation policy: 60% to Grant A, 30% to Campaign B, 10% to Unrestricted).

**Example:** Program Manager salary IDR 10,000,000:
- Grant Fund A: 60% → IDR 6,000,000
- Campaign Fund B: 30% → IDR 3,000,000
- Unrestricted Fund C: 10% → IDR 1,000,000

### 2.2 Fixed Amount Split

Each fund is assigned a fixed absolute amount. The sum of all fixed amounts must equal the total transaction amount.

**Use when:** Each fund has a specific agreed contribution amount (e.g., a co-funded workshop where Donor X covers travel costs at a fixed USD 500, and Donor Y covers the remainder).

**Example:** Workshop cost IDR 15,000,000:
- Grant Fund D: IDR 9,000,000 (fixed)
- Grant Fund E: IDR 6,000,000 (fixed)

### 2.3 Activity-Based Split

The system calculates the split ratio from activity records: the proportion of planned hours, participant count, or activity days attributable to each fund.

**Use when:** Timesheets, attendance records, or activity logs document how a shared resource was actually used.

**MVP limitation:** In MVP, activity-based split is entered manually as a percentage after the Finance Officer refers to timesheet data. Automated calculation from timesheet records is a post-MVP feature.

---

## 3. Journal Entry Rules

### 3.1 General Principle

A split expense produces **one debit per expense account per fund** and a **single credit to the payment account**. The GL entries are fund-dimension-tagged individually per line so that each fund's utilization is tracked independently.

Every split line must carry:
- The fund dimension (`custom_fund`)
- The budget line (`custom_budget_line`)
- The project and activity (where applicable)
- The expense account

### 3.2 Three-Way Split — Full Example

**Scenario:** Program Manager monthly salary of IDR 10,000,000 is allocated across three funds:
- Grant Fund A (USAID): 60% = IDR 6,000,000
- Campaign Fund B (Peduli Anak): 30% = IDR 3,000,000
- Unrestricted Fund C: 10% = IDR 1,000,000

**Journal Entry produced on payment:**

| # | Account | Debit (IDR) | Credit (IDR) | Fund | Budget Line |
|---|---|---|---|---|---|
| 1 | Beban Personalia | 6,000,000 | — | Grant Fund A | Personnel |
| 2 | Beban Personalia | 3,000,000 | — | Campaign Fund B | Staff Cost |
| 3 | Beban Personalia | 1,000,000 | — | Unrestricted Fund C | General Admin |
| 4 | Bank (IDR) | — | 10,000,000 | — | — |

**Total:** Debits = IDR 10,000,000, Credits = IDR 10,000,000. Journal is balanced.

The single credit to Bank is not fund-tagged (the bank account itself is not fund-specific). The three expense debit lines are individually fund-tagged.

### 3.3 Multi-currency Three-Way Split

**Scenario:** A shared consultant fee of USD 1,500 is split: 70% to USD Grant Fund A, 30% to USD Grant Fund B. Exchange rate: 15,800 IDR/USD.

| # | Account | Debit IDR | Credit IDR | Debit USD | Credit USD | Fund |
|---|---|---|---|---|---|---|
| 1 | Beban Konsultan | 16,590,000 | — | 1,050.00 | — | Grant Fund A |
| 2 | Beban Konsultan | 7,110,000 | — | 450.00 | — | Grant Fund B |
| 3 | Bank (USD) | — | 23,700,000 | — | 1,500.00 | — |

Total debit IDR = 16,590,000 + 7,110,000 = 23,700,000. Balanced.

Each fund's USD balance decreases by its respective USD share. Donor reports for each grant show the USD amounts independently.

### 3.4 Split Across Different Currencies (Mixed)

**Scenario:** An expense of IDR 8,000,000 is split: 50% to USD Grant Fund (USD fund) and 50% to IDR Unrestricted Fund. Exchange rate: 16,000 IDR/USD.

| # | Account | Debit IDR | Credit IDR | Fund | Note |
|---|---|---|---|---|---|
| 1 | Beban Program | 4,000,000 | — | USD Grant Fund | IDR expense against USD fund; USD equiv. = 250.00 |
| 2 | Beban Program | 4,000,000 | — | Unrestricted Fund | IDR fund |
| 3 | Bank (IDR) | — | 8,000,000 | — | |

The USD Grant Fund's USD balance decreases by 250.00 USD (= 4,000,000 / 16,000).

---

## 4. UI/UX Specification

### 4.1 Entry Point

Cost sharing is entered on the following transaction forms:

- Cash Disbursement / Bank Disbursement
- Purchase Invoice
- Journal Entry (manual)
- Cash Advance Liquidation (when actual expense needs split)

### 4.2 Toggle to Enable Split

On the transaction form, there is a **"Split across multiple funds"** toggle (checkbox). When unchecked (default), the form shows a single Fund field. When checked, the single Fund field is hidden and the **Fund Split** child table appears.

### 4.3 Fund Split Child Table

The child table is named `Fund Cost Allocation` and contains the following columns:

| Column | Type | Required | Notes |
|---|---|---|---|
| `fund` | Link → Fund | Yes | Must be an Active fund |
| `budget_line` | Link → Budget Line | Yes | Must be valid for selected fund |
| `project` | Link → Project | No | Required if fund has project-restricted allocation |
| `activity` | Link → Activity | No | Optional; links expense to specific activity |
| `allocation_method` | Select | Yes | Options: Percentage / Fixed Amount |
| `percentage` | Float | If method = % | Must be between 0.01 and 100 |
| `amount` | Currency | If method = Fixed | Must be > 0 |
| `calculated_amount` | Currency | Read-only | System-calculated: `total × percentage / 100` (for %) or entered amount (for fixed) |
| `currency` | Link → Currency | Read-only | Inherited from the parent transaction currency |
| `exchange_rate` | Float | Read-only | Inherited from parent transaction |

### 4.4 Validation Behavior During Entry

As the user fills in the child table:

1. After each row is entered, the system shows a running total of allocated percentage (for % method) or allocated amount (for fixed method).
2. A visual progress bar shows: "Allocated: 70% | Remaining: 30%".
3. The **Submit** button is disabled if the total does not equal 100% (for %) or total amount (for fixed).

### 4.5 Budget Availability Check at Entry Time

When a fund is selected in a split line, the system immediately shows (inline, below the row):

```
Grant Fund A — Available Budget (Personnel): IDR 45,200,000
This split line will use: IDR 6,000,000
After this expense: IDR 39,200,000 remaining
```

If the split amount exceeds the available budget for that fund's budget line, a **warning** is displayed (not a hard block at entry time — per D-02, the hard block is at payment). The warning reads:

> "Warning: Allocated amount for [Fund Name] exceeds available budget for [Budget Line] by IDR [X]. This will be blocked at payment if not resolved."

### 4.6 Summary Bar

Below the child table, a non-editable summary row shows:

```
Total transaction amount:   IDR 10,000,000
Total allocated:            IDR 10,000,000   ✓ Balanced
Unallocated:                IDR 0
```

---

## 5. Budget Impact (D-02 Compliance)

Per Decision D-02: budget is reduced only when payment is made ("Actual = transaksi yang sudah menghasilkan payment").

### 5.1 Budget Reduction Timeline for Split Expenses

| Stage | Effect on budget |
|---|---|
| Split expense saved as Draft | No effect |
| Split expense Submitted (approved) | No effect on budget; appears in "Pending Payment" info panel per fund |
| Payment posted | Each fund's budget line reduces by its allocated amount |

### 5.2 Budget Reduction Mechanics

When a split payment is posted, the system iterates through each `Fund Cost Allocation` row and updates:

```
Fund A — Budget Line "Personnel":
  budget_line.actual_amount += 6,000,000
  fund_a.actual_paid += 6,000,000
  fund_a.available_balance = fund_a.approved_budget - fund_a.actual_paid

Fund B — Budget Line "Staff Cost":
  budget_line.actual_amount += 3,000,000
  ...

Fund C — Budget Line "General Admin":
  budget_line.actual_amount += 1,000,000
  ...
```

### 5.3 Pending Payment Panel

Before payment, each fund's dashboard shows the split expense in its "Pending Payment" panel:

```
Fund A — Pending Payments:
  [Program Manager Salary — Sep 2025]   IDR 6,000,000   [Pay by: 30 Sep 2025]
```

This is informational; it does not reduce the available budget number until payment clears.

### 5.4 Hard Block at Payment

When a payment is processed, the system performs a final budget check per fund per split line. If any fund's split amount would cause `actual_paid > approved_budget` for the relevant budget line, the payment is **blocked** with a clear message:

> "Payment blocked: Grant Fund A — Budget Line 'Personnel' would be exceeded by IDR 800,000. Available: IDR 5,200,000, Required: IDR 6,000,000. Please revise the allocation or request a budget revision."

---

## 6. Indirect Cost Allocation

### 6.1 Definition

Indirect costs (also called overhead, administrative costs, or support costs) are organizational expenses that cannot be directly attributed to a single program or grant but benefit multiple activities. Examples: office rent, utilities, finance staff salaries, IT infrastructure.

Many institutional donors (USAID, EU, UNICEF) require NGOs to include an indirect cost rate (also called overhead rate or ICR) in grant budgets and to apply it systematically.

### 6.2 Indirect Cost Rate Setup

The Finance Manager defines one or more **Indirect Cost Rate** records:

| Field | Type | Notes |
|---|---|---|
| `rate_name` | Data | e.g., "Organizational Overhead Rate FY2025" |
| `rate_percentage` | Float | e.g., 15 (meaning 15% of direct costs) |
| `base` | Select | Options: Total Direct Costs / Personnel Costs Only / Programmatic Costs Only |
| `applicable_funds` | Table | Link to Fund(s) this rate applies to |
| `effective_from` | Date | |
| `effective_to` | Date | |
| `donor_approved` | Checkbox | Whether the donor has formally agreed to this rate |
| `approval_reference` | Data | Grant agreement clause or memo reference |

### 6.3 Applying Indirect Cost Allocation

Indirect costs can be applied in two ways:

**Method A — Periodic allocation journal (recommended for MVP)**

At the end of each month, Finance runs an **Indirect Cost Allocation** job. The system:

1. Sums the total direct costs posted to each grant fund during the month.
2. Calculates the indirect cost amount: `indirect_cost = total_direct × rate_percentage / 100`.
3. Posts a Journal Entry:

```
Example: Grant Fund A had direct costs of IDR 50,000,000 in September.
Indirect cost rate: 15% of direct costs.
Indirect cost charge: IDR 7,500,000.

Journal Entry:
Dr  Beban Administrasi dan Umum [Fund: Grant Fund A, Budget Line: Indirect Cost]   7,500,000
    Cr  Pendapatan Alokasi Overhead [Unrestricted Fund / Operating Fund]            7,500,000
```

The credit recovers overhead costs to the Operating/Unrestricted Fund that originally paid for rent, utilities, and admin staff.

**Method B — Add indirect cost line to each split expense (for smaller organizations)**

On each split expense, the user manually adds an extra row in the Fund Split table for "Indirect Cost":

| Fund | Budget Line | Amount | Notes |
|---|---|---|---|
| Grant Fund A | Personnel | 6,000,000 | Direct cost |
| Grant Fund A | Indirect Cost | 900,000 | 15% indirect rate on personnel |
| Unrestricted Fund | — | (900,000) | Recovered overhead |

This method is simpler but requires Finance to calculate manually. MVP supports both methods; Method A is recommended for grants with formal donor-approved ICR.

### 6.4 Indirect Cost GL Entry (Method A — Canonical)

```
At month-end allocation:

Dr  Beban Administrasi dan Umum     [Fund: Grant Fund A]    7,500,000
    Cr  Alokasi Overhead — Diterima [Fund: Operating Fund]  7,500,000
```

The Grant Fund's approved budget for "Indirect Cost" decreases by IDR 7,500,000. The Operating Fund is reimbursed for that amount.

### 6.5 Indirect Cost in Donor Report

The donor report must show indirect cost as a separate line item in the budget vs. actual table, matching the grant budget structure agreed with the donor.

---

## 7. Validation Rules

The following validations are enforced by Fundara. "Hard block" means the system refuses to proceed. "Warning" means the system alerts but allows continuation to the next stage.

### 7.1 Split Percentage / Amount Must Equal 100% / Total

| Condition | Behavior |
|---|---|
| Sum of percentages ≠ 100% | Hard block: "Total allocation percentage must equal 100%. Current total: [X]%." |
| Sum of fixed amounts ≠ transaction total | Hard block: "Total allocated amount must equal IDR [transaction_amount]. Current total: IDR [X]." |

### 7.2 Fund Must Be Active

| Condition | Behavior |
|---|---|
| A split line references a fund with status ≠ Active | Hard block: "[Fund Name] is not active (current status: [status]). Expenses cannot be posted to an inactive fund." |
| A split line references a fund whose period has ended | Hard block: "[Fund Name] period ended on [date]. This transaction date is outside the fund period." |

### 7.3 Budget Line Must Be Valid for Fund

| Condition | Behavior |
|---|---|
| Budget line is not part of the fund's budget | Hard block: "Budget Line '[name]' is not defined for [Fund Name]." |
| Budget line allows: disallowed cost category for restricted fund | Hard block: "[Fund Name] restriction rules do not allow '[cost category]' expenses." |

### 7.4 Fund Balance and Budget Availability

| Condition | Stage | Behavior |
|---|---|---|
| Split amount > available budget for fund/budget line | Entry (Submit) | Warning: "Amount exceeds available budget. Proceed?" |
| Split amount > available budget for fund/budget line | Payment | Hard block: "Payment blocked — budget exceeded." |
| Split amount > available fund balance | Payment | Hard block: "Payment blocked — insufficient fund balance." |

### 7.5 Restricted Fund Restriction Compliance

| Condition | Behavior |
|---|---|
| Restricted fund split line includes a disallowed expense account | Hard block: "Account '[account]' is not eligible for [Fund Name] per fund restriction rules." |
| Restricted fund split line includes an expense outside the allowed project | Warning: "This expense is outside the projects allowed by [Fund Name] restriction rules. Confirm if this is intentional." |

### 7.6 Minimum Split Line Count

| Condition | Behavior |
|---|---|
| "Split across multiple funds" is enabled but only 1 fund line is entered | Warning: "Split mode is enabled but only one fund is allocated. Either add another fund or disable split mode and use the single Fund field." |

---

## 8. Reporting

### 8.1 Donor Report — Cost Sharing Breakdown

The **Donor Fund Utilization Report** can include a cost sharing detail section. For each expense that involves cost sharing, the report shows:

```
Training Workshop — 15 Sep 2025        IDR 15,000,000    USD 949.37
  ↳ Grant Fund A (60%):                 IDR  9,000,000    USD 569.62
  ↳ Campaign Fund B (30%):              IDR  4,500,000    USD 284.81
  ↳ Unrestricted Fund C (10%):          IDR  1,500,000    USD  94.94
```

The breakdown is optional and can be collapsed in the standard report view. It is expanded in the full audit-supporting schedule.

### 8.2 Fund Utilization Report — Split Expense Attribution

The **Fund Utilization Report** filtered to a single fund (e.g., Grant Fund A) shows only that fund's share of any split expense:

```
Personnel — Sep 2025
  [Program Manager Salary]   60% share   IDR 6,000,000
```

The report does not show the total transaction amount unless specifically requested. This ensures each fund sees only its own attributed costs.

### 8.3 Cost Sharing Summary Report

A dedicated **Cost Sharing Summary Report** is available under the Financial Accountability module. It shows:

| Column | Description |
|---|---|
| Transaction | Reference number and description |
| Total Amount | Full transaction amount |
| Number of Funds | How many funds the cost is split across |
| Fund Shares | Each fund and its amount/percentage |
| Status | Draft / Submitted / Paid |
| Period | Transaction month |

The report can be filtered by period, fund, budget line, and allocation method. It can be exported to XLSX.

### 8.4 Indirect Cost Allocation Report

A separate **Indirect Cost Allocation Report** shows:

- Month / period
- Grant fund
- Total direct costs in period
- Indirect cost rate applied
- Indirect cost charged
- Budget line consumed
- Journal entry reference

---

## 9. ERPNext Implementation

### 9.1 Accounting Dimension Approach

Fundara uses ERPNext's **Accounting Dimensions** feature to tag fund, project, activity, and budget line on each GL Entry row. This is the foundation that makes cost sharing work without creating separate accounts per fund in the Chart of Accounts.

Configuration:
- `Fund` registered as Accounting Dimension (mandatory on expense accounts)
- `Project` registered as Accounting Dimension (optional/mandatory per fund restriction)
- `Budget Line` registered as custom Accounting Dimension

### 9.2 Custom Child Table — `Fund Cost Allocation`

The `Fund Cost Allocation` child table is a new custom DocType linked to the parent expense transaction. It is added as a child table field on:

- `Cash Disbursement` (custom DocType)
- `Bank Disbursement` (custom DocType)
- `Journal Entry` (via custom field)
- `Purchase Invoice` (via custom field)
- `Liquidation` (custom DocType)

Schema for `Fund Cost Allocation`:

```python
{
    "doctype": "Fund Cost Allocation",
    "fields": [
        {"fieldname": "fund", "fieldtype": "Link", "options": "Fund", "reqd": 1},
        {"fieldname": "budget_line", "fieldtype": "Link", "options": "Budget Line", "reqd": 1},
        {"fieldname": "project", "fieldtype": "Link", "options": "Project"},
        {"fieldname": "activity", "fieldtype": "Link", "options": "Activity"},
        {"fieldname": "allocation_method", "fieldtype": "Select",
         "options": "Percentage\nFixed Amount", "reqd": 1},
        {"fieldname": "percentage", "fieldtype": "Float"},
        {"fieldname": "amount", "fieldtype": "Currency"},
        {"fieldname": "calculated_amount", "fieldtype": "Currency", "read_only": 1},
        {"fieldname": "currency", "fieldtype": "Link", "options": "Currency", "read_only": 1},
        {"fieldname": "exchange_rate", "fieldtype": "Float", "read_only": 1},
    ]
}
```

### 9.3 GL Entry Generation

When the parent transaction is paid/posted, a server-side Python controller (`on_submit`) iterates through the `Fund Cost Allocation` child table and generates one GL Entry debit row per split line:

```python
def generate_split_gl_entries(self):
    for row in self.fund_cost_allocation:
        make_gl_entry({
            "account": self.expense_account,
            "debit": row.calculated_amount,
            "debit_in_account_currency": row.calculated_amount_in_currency,
            "account_currency": row.currency,
            "exchange_rate": row.exchange_rate,
            "custom_fund": row.fund,
            "custom_budget_line": row.budget_line,
            "project": row.project,
            "cost_center": self.cost_center,
        })
    # Single credit to bank/cash (not fund-tagged)
    make_gl_entry({
        "account": self.bank_account,
        "credit": self.total_amount,
        "credit_in_account_currency": self.total_amount_in_currency,
    })
```

### 9.4 Budget Impact Hooks

After GL entries are posted, a server-side hook updates budget actuals per fund per budget line:

```python
def update_budget_actuals_on_split(self):
    for row in self.fund_cost_allocation:
        frappe.db.set_value("Budget Line Item", {
            "fund": row.fund,
            "budget_line": row.budget_line,
        }, "actual_amount",
            frappe.db.get_value(...) + row.calculated_amount
        )
```

### 9.5 Indirect Cost Allocation Job

The periodic indirect cost allocation is implemented as a Frappe scheduled job (`frappe.utils.scheduler`) that runs on the last day of each month. Finance can also trigger it manually from the Indirect Cost Allocation DocType. The job generates Journal Entries automatically and places them in Draft status for Finance Manager review before posting.
