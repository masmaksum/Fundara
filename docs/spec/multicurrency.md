# Multi-currency Specification

**Scope:** Implementation detail and accounting rules for multi-currency support in Fundara MVP.
**Domain context reference:** `fundara-domain-contexts/06-financial-accountability-context.md`
**Decision reference:** `DECISIONS.md` D-04 — Multi-currency masuk MVP (Opsi B)

---

## 1. Exchange Rate Management

### 1.1 Storage

Exchange rates are stored in ERPNext's built-in **Currency Exchange** master (`erpnext.setup.doctype.currency_exchange`). Each record stores:

| Field | Type | Description |
|---|---|---|
| `from_currency` | Link → Currency | Source currency (e.g. USD) |
| `to_currency` | Link → Currency | Target currency (IDR as base) |
| `exchange_rate` | Float | Rate: 1 unit of `from_currency` = N IDR |
| `date` | Date | Effective date of the rate |
| `for_buying` | Checkbox | Applicable to buying transactions |
| `for_selling` | Checkbox | Applicable to selling transactions |

Fundara configures ERPNext with **IDR as the Company base currency**. All GL postings are stored in IDR. The Currency Exchange master serves as the authoritative lookup table.

### 1.2 MVP Currencies

The three currencies supported from day one are:

| Currency | ISO Code | Role |
|---|---|---|
| Indonesian Rupiah | IDR | Base currency (all GL in IDR) |
| US Dollar | USD | Primary grant currency |
| Euro | EUR | Secondary grant currency |

Additional currencies may be added via the Currency master; no code changes are required.

### 1.3 Who Sets Exchange Rates

**Manual rate setting** is the MVP approach (D-04 decision: no automated exchange rate API in MVP).

Responsibility matrix:

| Scenario | Who enters the rate | When |
|---|---|---|
| New month begins | Finance Officer | Beginning of each month, or before first transaction of the month |
| Large grant disbursement | Finance Manager | On the date the disbursement is received |
| Period-end revaluation | Finance Manager | Last working day of each accounting period |
| Spot transaction differs materially | Finance Officer | At time of transaction (overrides monthly rate) |

Finance Officers may override the system-suggested rate on any individual transaction by entering a rate directly in the transaction form. The system records both the rate source (monthly rate vs. transaction-specific rate) in a custom field `exchange_rate_source`.

### 1.4 When Exchange Rates Are Required

An exchange rate must be present before a transaction can be submitted whenever the transaction currency differs from IDR. The system looks up the rate in this priority order:

1. Rate entered directly on the transaction (transaction-specific override)
2. Latest Currency Exchange record with `date ≤ transaction_date` for that currency pair
3. If no rate found: submission is blocked with message "No exchange rate found for [currency] on [date]. Please set the rate in Currency Exchange master."

---

## 2. Transaction Recording

### 2.1 Required Fields on Every Foreign-currency Transaction

Every transaction in Fundara that involves a non-IDR currency must store the following four values. These are non-nullable once the document is submitted.

| Field name | ERPNext standard field? | Description |
|---|---|---|
| `transaction_currency` | Yes (`currency`) | The currency of the transaction (e.g. USD) |
| `exchange_rate` | Yes | Rate at time of transaction: 1 USD = N IDR |
| `transaction_amount` | Yes (varies by doctype) | Amount in transaction currency |
| `base_amount_idr` | Yes (`base_*` fields in ERPNext) | Amount in IDR = transaction_amount × exchange_rate |

ERPNext natively stores dual amounts for Payment Entry, Journal Entry, Purchase Invoice, and Sales Invoice. Fundara custom DocTypes (Cash Advance, Liquidation, Fund Transfer) must explicitly add these four fields in their schema.

### 2.2 GL Entry Rule

All GL entries are posted in IDR only. The `base_amount_idr` value is what lands in the General Ledger (`GL Entry.debit` / `GL Entry.credit`).

The transaction currency and rate are stored on the source document and on `GL Entry.account_currency` and `GL Entry.debit_in_account_currency` / `GL Entry.credit_in_account_currency` for drill-down and currency-specific reporting.

### 2.3 Fund Dimension Tagging

Every GL entry must carry the fund dimension tag. When a USD grant fund is involved, the GL entry carries:

- `account_currency = USD`
- `debit_in_account_currency = [USD amount]`
- `debit = [IDR equivalent]`
- `custom_fund = [Fund ID]`

This enables the system to reconstruct the USD balance of any fund by summing `debit_in_account_currency` and `credit_in_account_currency` where `account_currency = USD`.

---

## 3. Fund Balance in Multi-currency

### 3.1 Balance Display Policy

A USD Grant Fund maintains balances in **both USD and IDR simultaneously**:

| Balance view | When used | How calculated |
|---|---|---|
| **USD balance** (transaction currency) | Day-to-day fund management, donor reporting | Sum of `debit_in_account_currency` − `credit_in_account_currency` across all GL entries tagged to this fund where `account_currency = USD` |
| **IDR equivalent** (base currency) | Internal financial statements, ISAK 35 reports, organization-wide aggregation | Sum of `GL Entry.debit` − `GL Entry.credit` across all GL entries tagged to this fund |

The Fund Balance dashboard panel must display both values side by side:

```
Fund: USAID Health Project 2025
Balance (USD): 42,350.00 USD
Balance (IDR): Rp 671,285,000 (at blended rate of Rp 15,850/USD)
```

The IDR equivalent shown is the **historical cost** (sum of actual IDR postings), not a revalued figure. Revaluation is a separate period-end process (see Section 5).

### 3.2 Fund Balance Formula (Multi-currency)

```
Fund Balance (USD) = Opening Balance (USD)
                   + Income Received (USD)
                   + Transfer In (USD)
                   − Transfer Out (USD)
                   − Actual Expenses (USD)
                   − Advance Paid (USD)

Fund Balance (IDR) = Sum of all GL debits (IDR) tagged to fund
                   − Sum of all GL credits (IDR) tagged to fund
```

Per D-02: "Actual" = transactions with payment posted. Approved-but-not-paid advances do not reduce the fund balance; they appear in the "Pending Payment" info panel.

### 3.3 Multi-currency Allocation

When a Fund Allocation is created for a USD Grant Fund, the allocation amount is entered in USD. The system stores:

- `allocation_amount_usd = [entered amount]`
- `allocation_amount_idr = allocation_amount_usd × exchange_rate_at_allocation_date`
- `allocation_exchange_rate = [rate used]`
- `allocation_date = [date]`

Budget utilization checks for restricted grant funds use the USD allocation to compare against USD expenditures.

---

## 4. Donor Reporting Currency

### 4.1 Report Currency Selection

When generating a Donor Fund Utilization Report, the user selects the **reporting currency**:

- **Grant currency** (e.g. USD): all amounts are shown in USD. Transaction amounts come from `GL Entry.debit_in_account_currency`.
- **Base currency** (IDR): all amounts are shown in IDR. Transaction amounts come from `GL Entry.debit`.

The report header must display the selected currency prominently.

### 4.2 Currency Conversion in Reports

When reporting in grant currency (USD) and a transaction was originally in IDR (e.g., an IDR expense charged to a USD fund), the system converts the IDR amount back to USD using the **exchange rate recorded on that transaction**.

Formula: `Reported USD amount = IDR amount / exchange_rate_at_transaction`

This means the donor report is internally consistent with the rates used at the time of each transaction, rather than applying a single period-end rate to all transactions.

### 4.3 Budget vs. Actual Report (Donor)

The donor budget vs. actual report uses the **grant currency** throughout:

| Column | Source |
|---|---|
| Budget Line | Grant Budget Line (in USD) |
| Approved Budget | `grant_budget_line.approved_amount_usd` |
| Actual Spent | Sum of GL entries in USD for this fund + budget line |
| Available | Approved − Actual |
| % Utilized | Actual / Approved × 100% |

Variance notes (difference between actual and budget) must be provided in narrative form by Finance; Fundara provides the numbers, not the narrative.

---

## 5. Unrealized Exchange Gain/Loss

### 5.1 Purpose

At the end of each accounting period, open foreign-currency balances (fund balances, outstanding payables/receivables in foreign currency) must be restated at the current exchange rate. The difference between the book value (historical rate) and the restated value is recorded as an **Unrealized Exchange Gain or Loss**.

This is a non-cash accounting adjustment required for accurate period-end financial statements.

### 5.2 Accounts

| Account | Type | Normal Balance |
|---|---|---|
| Selisih Kurs yang Belum Direalisasi — Laba (Unrealized Exchange Gain) | Other Income | Credit |
| Selisih Kurs yang Belum Direalisasi — Rugi (Unrealized Exchange Loss) | Other Expense | Debit |

These accounts must be present in the nonprofit CoA template. They are tagged to the "Aset Neto Tanpa Pembatasan" (Without Donor Restriction) net asset class, unless the originating fund is a restricted grant, in which case the gain/loss is tagged to the same fund's restriction class.

### 5.3 Revaluation Algorithm

The period-end revaluation process runs as follows:

**Step 1 — Identify open foreign-currency positions.**

Query all GL entries where:
- `account_currency ≠ IDR`
- `posting_date ≤ period_end_date`
- The fund or account has an open balance in foreign currency

Group by `(fund, account, account_currency)` to get the open balance in each foreign currency.

**Step 2 — Calculate book value in IDR.**

For each group: `book_value_idr = sum(GL Entry.debit) − sum(GL Entry.credit)` (this is the historical-rate IDR balance).

**Step 3 — Calculate restated value in IDR.**

Fetch the period-end exchange rate for each foreign currency: `restated_value_idr = open_balance_foreign × period_end_rate`.

**Step 4 — Calculate difference.**

`difference_idr = restated_value_idr − book_value_idr`

- If `difference_idr > 0`: Unrealized Gain (the IDR value of the balance increased)
- If `difference_idr < 0`: Unrealized Loss (the IDR value of the balance decreased)

**Step 5 — Post Journal Entry.**

For each (fund, account, currency) group that has a non-zero difference:

```
Scenario: USD balance has gained value (Unrealized Gain)

Dr  [Foreign Currency Asset / Bank Account in USD]   difference_idr   [Fund dimension]
    Cr  Selisih Kurs yang Belum Direalisasi — Laba   difference_idr   [Fund dimension]

Scenario: USD balance has lost value (Unrealized Loss)

Dr  Selisih Kurs yang Belum Direalisasi — Rugi       difference_idr   [Fund dimension]
    Cr  [Foreign Currency Asset / Bank Account in USD]  difference_idr  [Fund dimension]
```

**Step 6 — Tag and archive.**

The Journal Entry must be tagged:
- `journal_type = "Exchange Rate Revaluation"`
- `period = [accounting period]`
- `is_revaluation = 1`

**Step 7 — Reversal at period start.**

The revaluation Journal Entry is automatically reversed on the **first day of the following period** (standard accounting treatment for unrealized gains/losses). This ensures the adjustment does not double-count when the position is eventually settled.

### 5.4 Who Runs Revaluation

The Finance Manager runs the period-end revaluation process via a custom **Exchange Rate Revaluation** tool in Fundara. The tool presents a preview of all positions and calculated differences before posting. The Finance Manager reviews and confirms before the journal entries are created.

---

## 6. Realized Exchange Gain/Loss

### 6.1 When It Occurs

A realized exchange gain or loss occurs when a foreign-currency transaction is **settled** — that is, when actual cash movement happens at a rate different from the rate used when the transaction was originally booked.

Common scenarios in Fundara:

| Scenario | Booking event | Settlement event |
|---|---|---|
| Grant disbursement received in bank | Grant income posted at booking rate | Bank statement shows IDR receipt at actual bank rate |
| Foreign-currency invoice paid | Invoice posted at booking rate | Payment made at actual payment date rate |
| Cash advance paid in IDR to liquidate USD advance | Advance posted at advance rate | IDR payment represents a different effective rate |

### 6.2 Accounts

| Account | Type | Normal Balance |
|---|---|---|
| Selisih Kurs yang Telah Direalisasi — Laba (Realized Exchange Gain) | Other Income | Credit |
| Selisih Kurs yang Telah Direalisasi — Rugi (Realized Exchange Loss) | Other Expense | Debit |

### 6.3 Algorithm

At the time of payment or settlement:

1. Retrieve the **booking rate** (rate on the original transaction, stored in `exchange_rate` on the source document).
2. Retrieve the **settlement rate** (rate on the payment date, from Currency Exchange master or transaction-specific override).
3. Calculate: `realized_difference_idr = settled_amount_foreign × (settlement_rate − booking_rate)`
4. Post a Journal Entry line for the realized difference:

```
If settlement_rate > booking_rate (gain — IDR weakened, foreign currency worth more):

Dr  Bank / Cash (IDR)                                 [actual IDR received]
    Cr  [Receivable / Advance / Income account]       [original booked IDR amount]
    Cr  Selisih Kurs yang Telah Direalisasi — Laba    [difference]

If settlement_rate < booking_rate (loss — IDR strengthened):

Dr  Bank / Cash (IDR)                                 [actual IDR received]
Dr  Selisih Kurs yang Telah Direalisasi — Rugi        [difference]
    Cr  [Receivable / Advance / Income account]       [original booked IDR amount]
```

ERPNext's Payment Entry doctype handles this automatically for standard transactions (Payment Entry has `exchange_gain_loss_account` field). For Fundara custom DocTypes (Cash Advance payment, Fund Transfer), the realized gain/loss calculation must be implemented explicitly in server-side Python.

---

## 7. ERPNext Implementation

### 7.1 System Settings to Enable

| Setting | Location | Required value |
|---|---|---|
| Company base currency | Company master → Default Currency | IDR |
| Multi-currency accounting | Accounts Settings → Allow Multi-Currency | Enabled |
| Exchange rate revaluation account | Company master | Selisih Kurs yang Belum Direalisasi — Rugi/Laba |
| Realized gain/loss account | Company master | Selisih Kurs yang Telah Direalisasi — Rugi/Laba |
| Allow stale exchange rates | Accounts Settings → Allow Stale Exchange Rates | No (force Finance to set current rate) |
| Stale days | Accounts Settings | 7 days (warn if rate is older than 7 days) |

### 7.2 DocTypes with Multi-currency Fields

The following ERPNext standard DocTypes already support multi-currency and must be configured correctly:

| DocType | Key multi-currency fields | Fundara action |
|---|---|---|
| Journal Entry | `multi_currency`, `accounts[].account_currency`, `accounts[].exchange_rate`, `accounts[].debit_in_account_currency` | Add Fund Accounting Dimension; ensure fund is tagged on each row |
| Payment Entry | `payment_type`, `paid_amount`, `received_amount`, `source_exchange_rate`, `target_exchange_rate`, `exchange_gain_loss_account` | Map to Cash Advance payment; link to fund |
| Purchase Invoice | `currency`, `conversion_rate`, `base_grand_total` | Link to fund via Accounting Dimension |

The following Fundara custom DocTypes require explicit multi-currency field additions:

| Custom DocType | Fields to add |
|---|---|
| Cash Advance | `currency`, `exchange_rate`, `amount_in_fund_currency`, `base_amount_idr`, `exchange_rate_source` |
| Liquidation | `currency`, `exchange_rate`, `actual_amount_in_currency`, `base_actual_idr` |
| Fund Transfer | `source_fund_currency`, `target_fund_currency`, `source_amount`, `target_amount`, `source_exchange_rate`, `target_exchange_rate`, `transfer_rate` |
| Fund Balance Snapshot | `currency`, `balance_in_fund_currency`, `balance_idr`, `snapshot_exchange_rate`, `snapshot_date` |

### 7.3 Accounting Dimension for Fund

The Fund must be registered as an **Accounting Dimension** in ERPNext (`Setup → Accounting → Accounting Dimensions`). This ensures every GL Entry automatically carries a `fund` field and the field appears on all transaction forms (Journal Entry, Payment Entry, Purchase Invoice).

### 7.4 Currency Exchange Master Population

Finance must populate the Currency Exchange master at minimum:
- Monthly: on or before the 1st of each month, set USD/IDR and EUR/IDR rates
- On-demand: whenever a large transaction occurs at a materially different rate
- Period-end: on the last day of each accounting period for revaluation

---

## 8. Edge Cases

### 8.1 IDR Expense Charged to USD Grant Fund

**Scenario:** Staff pays IDR 15,750,000 for a training event. The training is funded by a USD grant. The grant exchange rate for that month is 1 USD = 15,750 IDR.

**Which rate to use:** The **transaction-date exchange rate** from the Currency Exchange master (or transaction-specific override). The system converts the IDR expense back to USD for reporting:

```
IDR expense:      15,750,000 IDR
Exchange rate:    15,750 IDR/USD
USD equivalent:   1,000.00 USD

GL Entry:
Dr  Beban Program (IDR) [Fund: USD Grant]    15,750,000   (also: 1,000 in account_currency USD)
    Cr  Bank (IDR)                           15,750,000
```

The fund's USD balance decreases by USD 1,000.00. Donor report shows this expense as USD 1,000.00.

**Risk:** If the actual IDR payment and the exchange rate used differ (e.g., the organization paid IDR 15,800,000 but used a rate of 15,750), there will be a rounding difference. Finance must reconcile and book a small realized exchange difference if material.

### 8.2 Cash Advance in IDR Against a USD Grant Fund

**Scenario:** Field Officer requests IDR 5,000,000 advance to pay for field activities funded by a USD grant.

**Rule:** The advance is booked in IDR (the currency the staff will receive). It is simultaneously recorded in USD for fund balance purposes.

```
At advance payment (rate: 15,800 IDR/USD):

Dr  Uang Muka — [Staff Name] (IDR) [Fund: USD Grant]   5,000,000   (also: 316.46 USD)
    Cr  Bank (IDR)                                      5,000,000

Fund balance decreases by 316.46 USD (= 5,000,000 / 15,800).
```

At liquidation, the Finance Officer reconciles actual receipts (in IDR). If the actual expense was IDR 4,850,000:

```
Dr  Beban Program (IDR) [Fund: USD Grant]   4,850,000
Dr  Kas — Refund Receivable (IDR)             150,000
    Cr  Uang Muka — [Staff Name] (IDR)      5,000,000

Exchange difference: If exchange rate changed between advance date and liquidation date, post a small realized exchange gain/loss line.
```

**Note:** The fund's USD balance is ultimately reduced by the actual IDR expense divided by the transaction-date rate, not the advance rate. This difference is the realized exchange gain/loss on the advance.

### 8.3 Advance Paid in IDR, Fund in USD — Rate Moved Between Approval and Payment

**Scenario:** Advance approved when rate = 15,800 IDR/USD. Payment made 3 days later when rate = 16,000 IDR/USD. Advance amount = USD 1,000 (approved in USD terms) = IDR 15,800,000 (booked at approval rate).

**Rule:** The payment uses the rate on the **payment date** (16,000). The IDR actually paid is `1,000 × 16,000 = 16,000,000`. The difference of IDR 200,000 is a realized exchange loss (it costs more IDR to pay the USD amount).

```
Dr  Uang Muka (IDR) [Fund: USD Grant]          16,000,000
    Cr  Bank (IDR)                             16,000,000
Dr  Selisih Kurs yang Telah Direalisasi — Rugi    200,000
    Cr  Uang Muka (IDR)                          200,000   [correction to restate at booking rate]
```

In practice: ERPNext Payment Entry handles this via `exchange_gain_loss_account`. Finance must ensure this account is configured in the Company master.

### 8.4 Fund Transfer Between USD Fund and IDR Fund

**Scenario:** Unrestricted Fund (IDR) provides a bridging loan to a USD Grant Fund project before the grant disbursement arrives.

**Rule:** The transfer must record:
- Amount leaving IDR fund: in IDR
- Amount entering USD fund: in USD (converted at transfer-date rate)
- Any rate difference at settlement is posted as realized exchange gain/loss when the USD grant repays the IDR bridging fund

The Fund Transfer DocType must store both `source_amount_idr` and `target_amount_usd` along with the exchange rate used.

### 8.5 Two Advances from the Same USD Fund, Different Rates

**Scenario:** Advance A booked at 15,750 IDR/USD, Advance B booked at 16,100 IDR/USD. Both from the same fund. Liquidated in the same period.

**Rule:** Each advance retains its own `exchange_rate`. Liquidation uses the rate on the **liquidation date** for any remaining balance. Realized gain/loss is calculated per advance independently.

### 8.6 Grant Received in Parts (Multiple Disbursements at Different Rates)

**Scenario:** USD 100,000 grant. First disbursement: USD 60,000 received when rate = 15,800. Second disbursement: USD 40,000 received when rate = 16,200.

**Rule:** Each disbursement is recorded as a separate Receipt with its own exchange rate. The fund's IDR balance is the sum of actual IDR received. For donor reporting, the fund balance in USD is the sum of USD received (USD 100,000), regardless of the IDR equivalent.

The blended average rate shown in the Fund Balance dashboard is informational only and not used for any accounting calculation.
