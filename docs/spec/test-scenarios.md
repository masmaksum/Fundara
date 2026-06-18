# MVP Test Scenarios

**Format:** Given-When-Then with edge case / negative test.
**Domain context references:** `03-fund-stewardship-context.md`, `06-financial-accountability-context.md`
**Decision references:** D-02 (budget formula), D-04 (multi-currency)
**ERPNext version:** v16

Test codes follow the pattern: `TC-[area prefix][sequence number]`
- `FM` = Fund Management
- `CA` = Cash Advance
- `PR` = Procurement
- `BG` = Budget
- `RP` = Reporting

---

## Fund Management

---

### [TC-FM-01] Create Restricted Grant Fund with USD Currency

**Given:**
- A Funding Source record exists for "USAID Health Program" with type = Donor
- The Currency Exchange master has a USD/IDR rate for today (e.g., 1 USD = 15,800 IDR)
- The user has the role Finance Manager

**When:**
The Finance Manager creates a Fund with:
- Fund Name: "USAID Health 2025"
- Fund Type: Grant Fund
- Restriction Type: Restricted
- Currency: USD
- Start Date: 2025-01-01
- End Date: 2025-12-31
- Funding Source: USAID Health Program
- Opening Balance: 100,000 USD
- Status: Draft → submitted for activation

**Then:**
- Fund record is saved with all fields populated
- Fund Status transitions from Draft to Active after approval
- Opening balance of USD 100,000 is recorded; IDR equivalent (USD 100,000 × 15,800 = IDR 1,580,000,000) is stored in `opening_balance_idr`
- Fund Balance panel shows: "Balance (USD): 100,000.00 | Balance (IDR): Rp 1,580,000,000"
- Fund appears in the active fund list and is available for selection on transactions

**Edge case / negative test:**
- If Currency Exchange has no rate for USD today, submission is blocked: "No exchange rate found for USD. Please set the rate in Currency Exchange master before creating this fund."
- If Restriction Type is left blank, submission is blocked: "Restriction Type is required."
- If End Date is earlier than Start Date, validation fails: "Fund End Date must be after Start Date."

---

### [TC-FM-02] Fund Transfer Between Two Funds with Restriction Check

**Given:**
- Unrestricted Fund C (IDR, balance: IDR 50,000,000, status: Active) exists
- Grant Fund A (USD, restricted to "Health Program activities only", status: Active) exists
- The Finance Manager has a legitimate reason: "Co-funding contribution for health workshop"

**When:**
The Finance Manager creates a Fund Transfer:
- Source Fund: Unrestricted Fund C
- Target Fund: Grant Fund A
- Amount: IDR 5,000,000
- Reason: "Co-funding contribution for health workshop"

**Then:**
- System checks that the transfer reason is consistent with Grant Fund A's restriction rules
- Transfer is posted as a Journal Entry:
  - Dr Unrestricted Fund C (Fund Transfer Out) 5,000,000
  - Cr Grant Fund A (Fund Transfer In) 5,000,000
- Unrestricted Fund C balance decreases by IDR 5,000,000
- Grant Fund A balance increases by IDR 5,000,000 (and in USD: 5,000,000 / exchange_rate)
- A Fund Transfer record is created with status = Completed

**Edge case / negative test:**
- If a transfer is attempted FROM a restricted Grant Fund TO another unrelated fund, the system blocks it: "Restricted fund [name] cannot transfer funds out without donor approval. This transfer violates fund restriction rules."
- If Source Fund balance is insufficient (attempted transfer > available balance), block: "Insufficient balance in [Source Fund]. Available: IDR [X], Requested: IDR [Y]."
- If Source Fund status is not Active (e.g., Suspended), block: "Fund [name] is not active and cannot process transfers."

---

### [TC-FM-03] Fund Balance Calculation After Multiple Transactions

**Given:**
- Grant Fund A (USD) has:
  - Opening balance: USD 50,000
  - Two paid expenses recorded: USD 2,000 and USD 3,500
  - One approved-but-not-yet-paid Cash Advance: USD 1,000 (status = Approved)
  - One pending Purchase Invoice: USD 800 (status = Submitted, not yet paid)

**When:**
The Finance Officer opens the Fund Balance panel for Grant Fund A

**Then:**
Per D-02, available balance = Approved Budget − Actual (paid only):
- Opening balance: USD 50,000
- Actual paid expenses: USD 5,500 (= 2,000 + 3,500)
- Available balance shown: USD 44,500
- "Pending Payment" info panel shows: USD 1,000 (Approved advance not yet paid) + USD 800 (Invoice not yet paid) = USD 1,800 in queue
- The USD 1,800 pending amount does NOT reduce the displayed available balance
- IDR equivalent of USD 44,500 is shown at the latest exchange rate

**Edge case / negative test:**
- If an expense is reversed (journal reversal posted), the reversal should restore the balance. After reversal of the USD 2,000 expense, balance should show USD 46,500.
- If no exchange rate is available for the current date, the IDR equivalent falls back to the last known rate with a footnote: "IDR equivalent uses rate from [last rate date]."

---

### [TC-FM-04] Attempt to Overspend a Fund (Block at Payment)

**Given:**
- Grant Fund A (USD) has an approved budget of USD 10,000 for budget line "Personnel"
- Actual paid to date: USD 9,800 (USD 200 remaining)
- A Cash Advance of USD 500 has been Approved (not yet Paid)

**When:**
Finance Officer attempts to post payment for the USD 500 Cash Advance

**Then:**
- Payment is **blocked** with message: "Payment blocked: Grant Fund A — Budget Line 'Personnel' would be exceeded by USD 300. Available: USD 200, Required: USD 500. Please revise the allocation or request a budget revision before proceeding."
- No GL entry is created
- The Cash Advance remains in status = Approved

**Edge case / negative test:**
- If a Budget Revision is approved that increases the Personnel budget line by USD 500, the payment can then proceed without modification to the advance.
- If the Finance Manager manually overrides the block (requires special permission "Budget Override Approver"), the payment proceeds but a Budget Exception record is automatically created with the override reason and approver identity.
- A warning (not a hard block) is shown at advance approval time to alert Finance that available budget is low: "Note: Approving this advance would bring pending payments to USD 500 against a remaining budget of USD 200."

---

### [TC-FM-05] Close a Fund with Outstanding Advances (Block)

**Given:**
- Grant Fund A (USD) is in Closing status
- There are 2 outstanding Cash Advances linked to Grant Fund A:
  - Advance #001: status = Pending Liquidation, amount = USD 300
  - Advance #002: status = Overdue, amount = USD 150

**When:**
Finance Manager attempts to move Grant Fund A to Closed status

**Then:**
- Status change is **blocked** with message: "Fund cannot be closed. Outstanding advances exist: [Advance #001 — USD 300 — Pending Liquidation], [Advance #002 — USD 150 — Overdue]. All advances must be Closed before the fund can be closed."
- Fund Closure Checklist displays the 2 outstanding advances as blocking items
- Fund remains in Closing status

**Edge case / negative test:**
- If both advances are liquidated and closed, the fund closure proceeds and status changes to Closed.
- If there are also unreconciled bank transactions tagged to the fund, a warning is shown (non-blocking for closure): "2 bank transactions tagged to this fund remain unreconciled. Reconcile before final audit submission."

---

### [TC-FM-06] Fund Balance Display in Both Transaction Currency and IDR

**Given:**
- EUR Grant Fund B exists with:
  - Multiple EUR-denominated income and expense entries
  - Exchange rate history: various EUR/IDR rates over the past 6 months
  - Current period-end rate: 1 EUR = 17,200 IDR

**When:**
Finance Manager opens the Fund Balance panel for EUR Grant Fund B

**Then:**
- Panel shows two balance lines:
  - "Balance (EUR): €28,450.00" — calculated from sum of GL `debit_in_account_currency` − `credit_in_account_currency` where `account_currency = EUR`
  - "Balance (IDR): Rp 489,340,000" — sum of actual IDR amounts posted to GL (historical cost, not revalued)
- A separate "Revalued Balance (IDR)" field shows the restated value at current rate: EUR 28,450 × 17,200 = IDR 489,340,000 (if rates happened to be the same; shown separately if different)
- Fund Utilization Report can be generated in either EUR or IDR

**Edge case / negative test:**
- If no EUR/IDR rate is set for the current date, the revalued balance shows "Rate not available — using last known rate from [date]" in a yellow warning banner.

---

### [TC-FM-07] Create Bridging Fund and Settle After Grant Cashes

**Given:**
- Reserve Fund D (IDR, balance: IDR 80,000,000) exists as a Bridging Fund
- Grant Fund A (USD) is Active but has not yet received its first disbursement
- A project activity needs to be paid now (IDR 15,000,000) before the grant arrives

**When:**
Step 1: Finance Officer posts IDR 15,000,000 expense against Reserve Fund D (marked as "recoverable from Grant Fund A")
Step 2: Grant Fund A receives USD 10,000 disbursement (exchange rate: 15,800 IDR/USD)
Step 3: Finance Manager creates a Bridging Fund Settlement: settles IDR 15,000,000 from Grant Fund A back to Reserve Fund D

**Then:**
- After Step 1: Reserve Fund D balance = IDR 65,000,000; Grant Fund A balance unchanged
- After Step 2: Grant Fund A balance = USD 10,000 / IDR 158,000,000
- After Step 3 settlement:
  - Reserve Fund D is reimbursed IDR 15,000,000; balance returns to IDR 80,000,000
  - Grant Fund A balance reduces by IDR 15,000,000 (= USD 948.10 at 15,800 rate)
  - A Bridging Fund Settlement record is created with status = Settled
  - GL entry for settlement: Dr Reserve Fund D (transfer in) 15,000,000 / Cr Grant Fund A (transfer out) 15,000,000

**Edge case / negative test:**
- If the expense is deemed ineligible by the grant donor after the fact, the settlement is blocked: "Bridging Fund Settlement can only include eligible expenses. [Expense item] is marked as ineligible for Grant Fund A."
- If Grant Fund A's balance is insufficient to settle (USD equivalent < IDR 15,000,000 / exchange rate), block: "Grant Fund A has insufficient balance to settle IDR 15,000,000."

---

### [TC-FM-08] Budget Revision Requiring Donor Approval

**Given:**
- Grant Fund A (USD) has an approved Budget Revision history showing original allocation:
  - Personnel: USD 30,000
  - Training: USD 10,000
  - Travel: USD 8,000
- Grant Fund A's Fund Restriction requires "donor approval for budget line changes exceeding 10% of line amount"
- Finance Manager wants to increase Travel from USD 8,000 to USD 10,000 (a 25% increase, flagged as requiring donor approval)

**When:**
Finance Manager creates a Budget Revision:
- Budget Line: Travel
- Original Amount: USD 8,000
- Revised Amount: USD 10,000
- Reason: "Increased field visit requirements due to extended project scope"

**Then:**
- System detects the 25% increase exceeds the 10% donor approval threshold
- Budget Revision is saved in "Pending Donor Approval" status
- The revision does NOT take effect yet; the old budget (USD 8,000) remains active
- A task/notification is created for Finance Manager to obtain and record donor approval
- Once the Finance Manager attaches the donor approval email/letter and marks the revision as "Donor Approved", the revision activates and the new budget of USD 10,000 takes effect
- Budget Revision history records: v1 (original), v2 (pending), v2 (activated with donor approval reference)

**Edge case / negative test:**
- If the revision reduces a budget line below the actual amount already spent, block: "Budget revision rejected: Cannot reduce Personnel budget below the actual amount already paid (USD 28,500). New value must be ≥ USD 28,500."
- If the revision is within the 10% threshold (e.g., USD 8,000 → USD 8,500), no donor approval is required and the revision activates immediately after Finance Manager approval.

---

## Cash Advance

---

### [TC-CA-01] Full Happy Path: Request → Approve → Pay → Liquidate → Close

**Given:**
- Grant Fund A (USD, active) has budget line "Travel" with USD 5,000 available
- Project Officer "Budi" is a registered user with role Project Officer
- Finance Officer and Finance Manager have appropriate roles

**When:**
Full workflow is executed:
1. Budi creates Cash Advance: Fund = Grant Fund A, Budget Line = Travel, Amount = USD 200, Purpose = "Field visit Surabaya", Due Date = 14 days from today → saves as Draft, submits to Submitted
2. Supervisor reviews, changes status to Under Review
3. Finance Officer approves → status = Approved
4. Finance Officer processes payment → status = Paid (GL Entry posted: Dr Uang Muka / Cr Bank)
5. Budi submits Liquidation with receipts: actual spend = USD 185, attaches hotel receipt and transport receipt → status = Liquidated
6. Finance Officer reviews liquidation, approves → status = Closed; refund of USD 15 is requested
7. Budi refunds USD 15 → Cash Advance fully closed

**Then:**
- Status transitions follow: Draft → Submitted → Under Review → Approved → Paid → Pending Liquidation → Liquidated → Closed
- GL entries:
  - At payment: Dr Uang Muka — Budi [Fund: Grant Fund A] (USD 200 / IDR equivalent) / Cr Bank
  - At liquidation approval: Dr Beban Perjalanan [Fund: Grant Fund A] (USD 185) / Cr Uang Muka — Budi (USD 185)
  - At refund: Dr Bank (USD 15) / Cr Uang Muka — Budi (USD 15)
- Budget Line "Travel" actual increases by USD 185 (not USD 200 — per D-02, only the actual expense, not the advance amount)
- Advance Aging report shows zero outstanding for Budi after closure
- Fund balance for Grant Fund A decreases by USD 185

**Edge case / negative test:**
- At no stage should the advance appear in the Budget as reducing available budget until the Payment step (Paid status). Prior to Paid, it appears in the Pending Payment panel only.

---

### [TC-CA-02] Partial Liquidation (Less Than Advance Amount)

**Given:**
- Cash Advance #002: Paid, Amount = IDR 5,000,000, Fund = Unrestricted Fund C
- Staff submits Liquidation with actual expenses = IDR 3,200,000 (receipts attached)
- Remaining IDR 1,800,000 not yet returned

**When:**
Finance Officer reviews the Liquidation and approves it with the partial amount

**Then:**
- Liquidation is approved for IDR 3,200,000
- System records: actual_expense = 3,200,000, advance_amount = 5,000,000, difference = 1,800,000
- Advance status moves to Liquidated (not Closed — a refund is outstanding)
- A refund receivable of IDR 1,800,000 is created and tracked in Advance Aging
- GL at liquidation: Dr Beban [Fund C] 3,200,000 + Dr Refund Receivable 1,800,000 / Cr Uang Muka 5,000,000
- Advance status moves to Closed only after the IDR 1,800,000 refund is received

**Edge case / negative test:**
- If Finance attempts to close the advance without recording the refund receipt, block: "Advance cannot be closed while a refund of IDR 1,800,000 is outstanding."

---

### [TC-CA-03] Liquidation Exceeds Advance Amount

**Given:**
- Cash Advance #003: Paid, Amount = IDR 3,000,000, Fund = Campaign Fund B
- Staff submits Liquidation with actual expenses = IDR 3,750,000 (receipts attached for full amount)

**When:**
Finance Officer reviews the Liquidation

**Then:**
- System calculates: actual_expense = 3,750,000, advance_amount = 3,000,000, excess = 750,000
- Finance Officer is prompted: "Actual expenses exceed advance amount by IDR 750,000. Approve full reimbursement of IDR 750,000 to staff?"
- If approved: GL at liquidation: Dr Beban [Fund B] 3,750,000 / Cr Uang Muka 3,000,000 + Cr Utang Reimbursement 750,000
- A Reimbursement Payment of IDR 750,000 is created and queued for payment
- Advance status = Closed (the excess is handled via Reimbursement, not a new advance)
- Budget Line "Campaign Events" decreases by IDR 3,750,000 (the actual amount, not the advance amount)

**Edge case / negative test:**
- If the excess expense causes Campaign Fund B's budget line to be exceeded, a budget override warning appears before approving the reimbursement.
- If some receipts are rejected as ineligible, only the eligible amount is approved for reimbursement; the ineligible portion is borne by the staff member.

---

### [TC-CA-04] Advance with Ineligible Expense During Liquidation

**Given:**
- Cash Advance #004: Paid, Amount = IDR 2,500,000, Fund = Grant Fund A (restricted to Health Program activities)
- Staff submits Liquidation with:
  - Health workshop registration fee: IDR 1,800,000 (eligible)
  - Team dinner at restaurant: IDR 700,000 (ineligible per Grant Fund A restriction — "no entertainment expenses")

**When:**
Finance Officer reviews the liquidation detail

**Then:**
- System highlights the restaurant expense as ineligible based on Grant Fund A's restriction rules
- Finance Officer marks the IDR 700,000 as ineligible
- Eligible expense approved: IDR 1,800,000 charged to Grant Fund A
- The IDR 700,000 ineligible amount: Finance Officer must select one of:
  a. Staff refunds IDR 700,000 (treated as over-advance)
  b. IDR 700,000 is charged to Unrestricted Fund (if board policy allows)
- GL at liquidation approval: Dr Beban Program [Fund A] 1,800,000 + Dr Unrestricted/Refund Receivable 700,000 / Cr Uang Muka 2,500,000

**Edge case / negative test:**
- If Finance Officer attempts to approve the full IDR 2,500,000 including the ineligible item against Grant Fund A, the system blocks it: "Restaurant expenses are ineligible under Grant Fund A restriction rules. Reclassify or reject before approving."

---

### [TC-CA-05] Advance Rejected During Under Review

**Given:**
- Cash Advance #005: status = Under Review
- Finance Officer determines the purpose ("Team building trip") is not aligned with any active project budget

**When:**
Finance Officer rejects the advance with reason: "No budget allocation found for team building activities in FY2025."

**Then:**
- Advance status changes to Rejected
- Rejection reason is recorded in the advance document
- Requester receives a notification with the rejection reason
- No GL entries are created
- No budget impact occurs
- The advance remains visible in the requester's history with status = Rejected

**Edge case / negative test:**
- A Rejected advance cannot be resubmitted. The requester must create a new advance if the activity is legitimate.
- A Rejected advance cannot be moved to Paid, Approved, or any other status except Cancelled (if the requester withdraws it).

---

### [TC-CA-06] Advance Becomes Overdue (Auto-trigger After Due Date)

**Given:**
- Cash Advance #006: status = Pending Liquidation
- Due date for liquidation = 2025-09-15
- Today = 2025-09-16 (one day past due)
- No liquidation has been submitted

**When:**
The end-of-day scheduled job runs

**Then:**
- Advance #006 status automatically changes from Pending Liquidation to Overdue
- An alert appears on the Finance Officer's dashboard: "1 advance is now overdue: [Advance #006 — IDR 2,000,000 — Requester: Andi]"
- An email/system notification is sent to the requester and their supervisor
- Advance appears in red on the Advance Aging Report
- The advance is now listed in the "Overdue" section of the Data Health Check dashboard

**Edge case / negative test:**
- Overdue status does not block the requester from submitting liquidation — they can still submit even in Overdue status, which moves the advance to Liquidated for Finance review.
- If the advance was already moved to a final status (Closed/Cancelled/Rejected) before the scheduled job ran, the job skips that advance.

---

### [TC-CA-07] Advance Paid but Fund Had Insufficient Balance (Blocked)

**Given:**
- Grant Fund A (USD) has an available fund balance of USD 150
- Cash Advance #007: Approved, Amount = USD 500, Fund = Grant Fund A

**When:**
Finance Officer attempts to process the payment for Cash Advance #007

**Then:**
- Payment is blocked: "Payment blocked: Grant Fund A has insufficient balance. Available: USD 150, Required: USD 500."
- No GL entry is created
- Advance remains in status = Approved
- Finance Officer must either:
  a. Wait for a fund top-up (new disbursement or fund transfer)
  b. Reduce the advance amount (requires a revision workflow)
  c. Cancel the advance and resubmit with a lower amount

**Edge case / negative test:**
- If the USD 150 balance is itself a result of other pending-but-not-yet-paid items, the Finance Officer is shown the Pending Payment panel to understand why the balance is low.

---

### [TC-CA-08] Multi-currency Advance: IDR Advance Against USD Grant Fund

**Given:**
- Grant Fund A (USD, balance: USD 5,000) is active
- Staff Rina needs IDR 3,162,000 for field expenses (health activity)
- Exchange rate today: 1 USD = 15,810 IDR
- Advance is requested in IDR (Rina will receive IDR from the bank)

**When:**
Finance Officer creates and pays an advance: Fund = Grant Fund A, Currency = IDR, Amount = IDR 3,162,000

**Then:**
- System calculates USD equivalent: 3,162,000 / 15,810 = USD 200.00
- Advance is recorded as: transaction_currency = IDR, transaction_amount = 3,162,000, exchange_rate = 15,810, base_amount_idr = 3,162,000, amount_in_fund_currency = USD 200.00
- GL entry: Dr Uang Muka — Rina [Fund: Grant Fund A, account_currency: USD] 3,162,000 IDR (200 USD) / Cr Bank (IDR) 3,162,000
- Grant Fund A USD balance decreases by USD 200.00
- Pending Payment panel for Grant Fund A shows: "Uang Muka — Rina: USD 200.00 (IDR 3,162,000)"

**Edge case / negative test:**
- At liquidation, Rina submits receipts in IDR. If the exchange rate has changed between advance payment and liquidation, the realized exchange difference is calculated and posted: Dr/Cr Selisih Kurs Direalisasi for the difference.
- If the IDR advance amount entered does not divide evenly to a round USD number, the system does not round — it accepts the fractional USD equivalent.

---

### [TC-CA-09] Two Advances Approved from Same Fund Before Either Is Paid

**Given:**
- Grant Fund A (USD) has available budget for Travel: USD 1,000
- Advance #008: Approved, USD 600, Fund = Grant Fund A, Budget Line = Travel
- Advance #009: Approved, USD 500, Fund = Grant Fund A, Budget Line = Travel

**When:**
Finance Officer reviews the payment queue and sees both advances pending

**Then:**
- Per D-02: neither advance has reduced the budget yet (they are Approved, not Paid)
- Available budget still shows USD 1,000 (no reduction yet)
- A **"Pending Payment" warning** is displayed: "USD 1,100 in advances are approved and awaiting payment against this budget line (available: USD 1,000). Paying both would exceed the budget by USD 100."
- Finance Officer can pay either advance first; when the first advance (USD 600) is paid, budget actual increases by USD 600, leaving USD 400 available
- When Finance Officer attempts to pay the second advance (USD 500), the payment is **blocked**: "Payment blocked — budget line Travel would be exceeded by USD 100. Available: USD 400, Required: USD 500."

**Edge case / negative test:**
- The warning should be shown prominently at the Approved stage and on the pending payment queue, not just at payment time.
- If Finance Manager has approved a budget revision increasing Travel to USD 1,200 before the second payment, both advances can be paid in full.

---

### [TC-CA-10] Advance Cancellation After Payment (Blocked)

**Given:**
- Cash Advance #010: status = Paid (GL entries have been posted, cash has been disbursed)
- The requester or Finance Officer wants to cancel the advance

**When:**
User attempts to change status to Cancelled

**Then:**
- Cancellation is **blocked**: "Advance #010 cannot be cancelled after payment has been made. To reverse this advance, submit a Liquidation with zero expenses and return the full amount as a refund."
- The advance remains in status = Paid
- The correct resolution path is:
  1. Requester submits Liquidation with actual expenses = 0, refund = full advance amount
  2. Finance approves the liquidation
  3. Staff returns the full amount to bank
  4. Advance closes as fully refunded

**Edge case / negative test:**
- If the advance is in Draft or Submitted status (before payment), cancellation is allowed.
- If the advance is in Approved status (not yet Paid), cancellation is allowed and no GL reversal is needed.
- If the advance is in Pending Liquidation or Overdue status, it cannot be cancelled — it must go through the liquidation process.

---

## Procurement

---

### [TC-PR-01] Purchase Request Approved, Converted to Purchase Order

**Given:**
- Project Officer has role to create Purchase Requests
- Grant Fund A (USD) has budget line "Equipment" with USD 3,000 available
- Vendor "PT Maju Teknologi" is registered as an active supplier

**When:**
1. Project Officer creates Purchase Request: Item = "Laptop", Qty = 1, Estimated Cost = USD 1,200, Fund = Grant Fund A, Budget Line = Equipment
2. Supervisor reviews and approves
3. Finance Officer reviews budget → available USD 3,000, USD 1,200 required — passes
4. Purchase Request status = Approved
5. Finance Officer converts Purchase Request to Purchase Order for PT Maju Teknologi at USD 1,150 (negotiated price)

**Then:**
- Purchase Request status changes to Converted
- Purchase Order is created, linked to the Purchase Request
- Purchase Order carries: Fund = Grant Fund A, Budget Line = Equipment
- No budget reduction yet (per D-02: only paid invoices reduce budget)
- "Pending Payment" info panel for Grant Fund A shows USD 1,150 in committed orders

**Edge case / negative test:**
- If the Purchase Order amount (USD 1,150) differs from the Purchase Request estimate (USD 1,200) by more than a configurable threshold (default: 10%), a notification is sent to the Finance Manager, but the PO is not blocked.
- If the vendor (PT Maju Teknologi) is flagged with a compliance warning (e.g., missing due diligence documents), the PO creation shows a warning banner but is not blocked in MVP.

---

### [TC-PR-02] Purchase Order with Restricted Fund — Ineligible Item Blocked

**Given:**
- Grant Fund A (USD, restricted to Health Program activities) is active
- A Purchase Request has been created for "Office Chairs × 10" (estimated USD 800)
- Grant Fund A restriction rules define: "Capital equipment for non-health purposes is ineligible"

**When:**
Finance Officer attempts to approve the Purchase Request linked to Grant Fund A with budget line "Equipment"

**Then:**
- System checks the item category ("Furniture/Office Equipment") against Grant Fund A's allowed cost categories
- Approval is **blocked**: "Item category 'Office Furniture' is ineligible for Grant Fund A. Fund restriction allows only health program equipment purchases."
- Finance Officer must either:
  a. Change the fund to Unrestricted Fund (if office chairs are an unrestricted expense)
  b. Obtain a formal exception approval from the donor

**Edge case / negative test:**
- If the restriction rule has an exception clause ("Exception: small value purchases under USD 100 are allowed"), and the per-unit price is USD 80, the system allows it with an informational note.

---

### [TC-PR-03] Vendor Not Yet Registered — PR Submission Blocked

**Given:**
- A Program Officer wants to purchase training materials from "CV Buku Pintar" — a vendor not yet registered in the Supplier master

**When:**
Program Officer creates a Purchase Request and enters "CV Buku Pintar" as the proposed vendor, then submits it

**Then:**
- System detects "CV Buku Pintar" is not in the Supplier master
- PR submission is **blocked**: "Vendor 'CV Buku Pintar' is not registered as an approved supplier. Please register the vendor first or select an existing approved supplier."
- Program Officer must:
  a. Ask Finance to register CV Buku Pintar as a supplier, or
  b. Select an already-registered alternative supplier

**Edge case / negative test:**
- If the vendor field is left blank (no vendor entered), the PR can be submitted with a warning: "No vendor specified. A vendor must be selected before a Purchase Order can be created."
- A PR without a vendor can reach Approved status, but cannot be converted to a PO until a vendor is specified.

---

### [TC-PR-04] Goods Received Partially — PO Remains Open

**Given:**
- Purchase Order #PO-2025-018: 50 units of "Activity Kits" at IDR 200,000 each, total IDR 10,000,000, Fund = Campaign Fund B
- First shipment arrives: 30 units received and accepted

**When:**
Warehouse Staff records a Goods Receipt for 30 units against PO-2025-018

**Then:**
- Goods Receipt is posted for 30 units (IDR 6,000,000)
- Purchase Order status changes to "Partially Received" (not Closed)
- PO remains open for the remaining 20 units
- A Purchase Invoice can be created for IDR 6,000,000 (the 30-unit batch)
- Campaign Fund B's budget is reduced by IDR 6,000,000 only when the invoice is paid
- The pending quantity (20 units) remains visible in the PO

**Edge case / negative test:**
- If the remaining 20 units are never delivered and the PO needs to be closed, Finance Manager can close the PO with a partial closure note. The undelivered portion is not invoiced.
- If the 30 received units do not match the expected specification (wrong model), a Goods Receipt exception is created and the items are placed in "Quality Hold" before the invoice can be processed.

---

### [TC-PR-05] Invoice Amount Differs from PO Amount (Threshold Check)

**Given:**
- Purchase Order #PO-2025-020: Services for "Baseline Survey", USD 5,000, Fund = Grant Fund A
- Supplier submits invoice for USD 5,420 (8.4% above PO amount)
- Organization threshold: "Invoice may exceed PO by up to 5% without additional approval; above 5% requires Finance Manager approval"

**When:**
Finance Officer creates a Purchase Invoice for USD 5,420 against PO-2025-020

**Then:**
- System detects invoice amount (USD 5,420) exceeds PO amount (USD 5,000) by 8.4%, which is above the 5% threshold
- Invoice is created but placed in "Pending Finance Manager Approval" status
- Finance Officer cannot post the invoice without Finance Manager sign-off
- Finance Manager is notified: "Invoice #INV-2025-055 for USD 5,420 exceeds PO amount (USD 5,000) by USD 420 (8.4%). Review and approve."
- If Finance Manager approves, the invoice is posted and payment can proceed

**Edge case / negative test:**
- If the invoice amount is LESS than the PO (e.g., USD 4,800, a 4% underrun), no additional approval is required — this is a saving and the PO can be partially closed.
- If the variance explanation provided is "Scope expansion — additional survey sites", and no PO amendment has been created, Finance Manager is reminded: "Consider amending the PO to formally record the scope change."

---

### [TC-PR-06] Emergency Procurement Without PR (Special Role Required)

**Given:**
- An urgent situation requires immediate purchase of medical supplies (IDR 8,500,000) for a field emergency
- There is no time to follow the standard PR → approval → PO → GR → invoice process
- Finance Manager has the role "Emergency Procurement Approver"

**When:**
Finance Manager creates a direct Purchase Invoice (bypassing PR/PO) and attaches:
- Emergency justification memo (signed by Program Director)
- Supplier quotation
- Goods receipt confirmation

**Then:**
- System allows the direct invoice because Finance Manager has "Emergency Procurement Approver" role
- A flag `is_emergency_procurement = 1` is set on the invoice
- Invoice is posted with emergency flag; an automatic **Exception Record** is created in the procurement audit trail
- The Exception Record is flagged for review at the next Finance Committee meeting
- Fund balance and budget are updated normally upon payment
- The exception appears in the Compliance Exception report

**Edge case / negative test:**
- If a Finance Officer (without the "Emergency Procurement Approver" role) attempts to create a direct invoice without a PR/PO reference, the system blocks it: "Purchase Invoice requires a linked Purchase Order or Purchase Request. For emergency purchases, an Emergency Procurement Approver must process this transaction."

---

## Budget

---

### [TC-BG-01] Budget vs Actual Dashboard Shows Correct Available Balance

**Given:**
- Grant Fund A has the following budget structure (fiscal year 2025):
  - Personnel: USD 30,000 approved
  - Travel: USD 8,000 approved
  - Equipment: USD 5,000 approved
- Paid actuals to date:
  - Personnel: USD 12,500
  - Travel: USD 2,300
  - Equipment: USD 0

**When:**
Finance Manager opens the Budget vs Actual Dashboard for Grant Fund A

**Then:**
Dashboard shows:

| Budget Line | Approved (USD) | Actual (USD) | Available (USD) | % Used |
|---|---|---|---|---|
| Personnel | 30,000 | 12,500 | 17,500 | 41.7% |
| Travel | 8,000 | 2,300 | 5,700 | 28.8% |
| Equipment | 5,000 | 0 | 5,000 | 0.0% |
| **Total** | **43,000** | **14,800** | **28,200** | **34.4%** |

- A "Pending Payment" sidebar shows: any approved-but-unpaid advances or invoices (e.g., "Travel — Advance #007: USD 400 pending")
- The pending amounts do not appear in the "Actual" column
- Chart showing budget vs actual vs elapsed time period is visible

**Edge case / negative test:**
- If a budget revision has been submitted but not yet approved, the dashboard shows the current approved budget (pre-revision), not the draft revised amount.

---

### [TC-BG-02] Expense Posted Today Reduces Available Budget Correctly (D-02)

**Given:**
- Unrestricted Fund C has budget line "General Admin" with IDR 20,000,000 approved; actual paid = IDR 5,000,000; available = IDR 15,000,000
- A Purchase Invoice for office supplies (IDR 3,500,000) is created, approved, and paid today

**When:**
The payment for the IDR 3,500,000 invoice is posted (Payment Entry submitted)

**Then:**
- GL entry is created: Dr Beban Administrasi (Fund C) 3,500,000 / Cr Bank 3,500,000
- Budget Line "General Admin" actual increases from IDR 5,000,000 to IDR 8,500,000
- Available budget decreases from IDR 15,000,000 to IDR 11,500,000
- Budget vs Actual dashboard refreshes to reflect: Available = IDR 11,500,000
- The change is immediate (no batch job required)

**Edge case / negative test:**
- If the Payment Entry is cancelled after posting, the budget reduction must be reversed: actual returns to IDR 5,000,000, available returns to IDR 15,000,000.

---

### [TC-BG-03] Approved-but-Not-Paid Advance Shows in Pending Payment, NOT in Budget Reduction

**Given:**
- Grant Fund A, budget line "Training": USD 10,000 approved, USD 0 actual paid
- Cash Advance #011: USD 1,500, status = Approved, Fund = Grant Fund A, Budget Line = Training

**When:**
Finance Officer views the Budget vs Actual Dashboard for Grant Fund A → Training line

**Then:**
- Approved Budget: USD 10,000
- Actual Paid: USD 0
- Available Budget: **USD 10,000** (not USD 8,500)
- "Pending Payment" info panel (separate from budget table) shows: "Training — Advance #011: USD 1,500 — Status: Approved, Awaiting Payment"
- The dashboard note reads: "USD 1,500 in advances are approved and pending payment. Available budget may be lower once paid."

**Edge case / negative test:**
- This behavior is the explicit result of D-02 decision. Any test that shows the advance reducing the available budget (i.e., available = USD 8,500) is a regression bug.

---

### [TC-BG-04] Budget Revision Changes Approved Amount, Recalculates Available

**Given:**
- Grant Fund A, budget line "Training": USD 10,000 approved, USD 4,200 actual paid, available = USD 5,800
- Finance Manager creates a Budget Revision: Training → USD 12,000 (increase of USD 2,000)
- Revision is approved

**When:**
Budget Revision is activated (status = Approved → Active)

**Then:**
- Budget Line "Training" approved amount updates to USD 12,000
- Available budget recalculates: USD 12,000 − USD 4,200 = USD 7,800
- Budget Revision history shows: v1 (USD 10,000), v2 (USD 12,000, reason, approver, date)
- Dashboard immediately reflects the new values
- No GL entries are required for a budget revision (it is a plan change, not a transaction)

**Edge case / negative test:**
- If a budget revision is created that reduces "Training" below USD 4,200 (the actual already paid), the system blocks it: "Cannot reduce budget below amount already spent. Minimum allowed: USD 4,200."

---

### [TC-BG-05] Budget Line Over-allocation Warning, Hard Block at Payment

**Given:**
- Grant Fund A, budget line "Equipment": USD 5,000 approved, USD 4,800 actual paid
- Two Purchase Requests are approved (not yet resulting in payments):
  - PR-A: Equipment USD 300
  - PR-B: Equipment USD 400

**When:**
Step 1: PR-A is converted to PO, goods received, invoice created for USD 300, payment processed
Step 2: PR-B is converted to PO, goods received, invoice created for USD 400, payment attempted

**Then:**
- Step 1 payment: USD 300 payment processes successfully. Actual = USD 5,100. Available = −USD 100.
  - Wait — this would actually be blocked at Step 1. Correct: USD 4,800 + USD 300 = USD 5,100 > USD 5,000. So Step 1 payment is also blocked.
  - The system blocks Step 1 payment: "Payment blocked: Equipment budget would be exceeded by USD 100. Available: USD 200, Required: USD 300."
- The "Warning at allocation" (not hard block) means: when PR-A was approved, a warning was shown — "Note: approving this PR will bring committed spend to USD 5,100 against a budget of USD 5,000 once paid." But approval was not blocked.
- Hard block occurs at payment, exactly as per D-02.

**Edge case / negative test:**
- A Budget Revision approving USD 5,500 for Equipment allows both payments to proceed.

---

### [TC-BG-06] Multi-fund Budget: Expense Split 60/40 Reduces Both Fund Budgets Proportionally

**Given:**
- Grant Fund A (USD), budget line "Personnel": USD 20,000 approved, USD 8,000 actual
- Campaign Fund B (IDR), budget line "Staff Cost": IDR 50,000,000 approved, IDR 10,000,000 actual
- A staff salary payment of IDR 10,000,000 is split: 60% to Grant Fund A (IDR 6,000,000 = USD ~380 at 15,800), 40% to Campaign Fund B (IDR 4,000,000)
- Payment is processed

**Then:**
- Grant Fund A — Personnel actual increases by IDR 6,000,000 (USD 379.75 at 15,800 rate)
  - New actual: USD 8,000 + USD 379.75 = USD 8,379.75
  - New available: USD 20,000 − USD 8,379.75 = USD 11,620.25
- Campaign Fund B — Staff Cost actual increases by IDR 4,000,000
  - New actual: IDR 14,000,000
  - New available: IDR 36,000,000
- Budget vs Actual Dashboard for each fund independently reflects its reduced available budget
- Cost sharing breakdown is visible in the transaction detail

**Edge case / negative test:**
- If either fund's payment portion would breach its budget, the entire split payment is blocked (not partially processed): "Payment blocked: Grant Fund A Personnel budget would be exceeded. The entire split payment cannot be processed until the budget constraint is resolved."

---

## Reporting

---

### [TC-RP-01] Donor Report in USD for a USD Grant Fund

**Given:**
- Grant Fund A (USD) has transactions over the period Jan–Sep 2025:
  - Grant income received: USD 80,000 (in 2 disbursements at different rates)
  - Expenses paid: USD 35,420 across multiple budget lines
  - One IDR expense of IDR 3,162,000 charged to the fund (at 15,810 rate = USD 200)
- Finance Manager generates Donor Fund Utilization Report for period Jan–Sep 2025

**When:**
Finance Manager selects: Report Currency = USD, Fund = Grant Fund A, Period = Jan–Sep 2025

**Then:**
- All amounts in the report are denominated in USD
- Grant income shows: USD 80,000 (sum of `debit_in_account_currency` for income entries)
- Expenses show: USD 35,420 (including the IDR expense converted at its transaction-date rate: 3,162,000 / 15,810 = USD 200.00)
- Budget vs actual table:

| Budget Line | Budget (USD) | Actual (USD) | Available (USD) |
|---|---|---|---|
| Personnel | 30,000 | 18,200 | 11,800 |
| Travel | 8,000 | 5,320 | 2,680 |
| Equipment | 5,000 | 3,500 | 1,500 |
| Training | 12,000 | 8,400 | 3,600 |
| **Total** | **55,000** | **35,420** | **19,580** |

- Report can be exported to XLSX and PDF
- Every amount can be drill-drowned to the source transaction

**Edge case / negative test:**
- If reporting currency = IDR is selected instead, all amounts convert to IDR using the historical transaction-date rates (not a single current rate). The report header clearly states: "All amounts in IDR at historical exchange rates."

---

### [TC-RP-02] Fund Utilization Report Shows Income, Expenses, and Available Balance Per Fund

**Given:**
- Three funds are active: Grant Fund A (USD), Campaign Fund B (IDR), Unrestricted Fund C (IDR)
- Transactions span the fiscal year to date

**When:**
Finance Manager opens the Fund Utilization Report for All Funds, current fiscal year

**Then:**
Report shows one row per fund:

| Fund | Type | Currency | Opening Balance | Income | Transfer In | Transfer Out | Expenses Paid | Available Balance |
|---|---|---|---|---|---|---|---|---|
| Grant Fund A | Grant | USD | 100,000 | 0 | 0 | 0 | 35,420 | 64,580 |
| Campaign Fund B | Campaign | IDR | 0 | 120,000,000 | 0 | 0 | 45,000,000 | 75,000,000 |
| Unrestricted Fund C | Unrestricted | IDR | 50,000,000 | 30,000,000 | 0 | 5,000,000 | 18,000,000 | 57,000,000 |

- Amounts for Grant Fund A are shown in USD (its native currency)
- An IDR equivalent column can be toggled on for organization-wide aggregation
- Clicking any number drills down to the underlying transactions

**Edge case / negative test:**
- Funds with status = Closed are excluded from the default view but can be included via a filter toggle "Include Closed Funds."
- If a fund has a negative balance (actual > opening + income), it is highlighted in red as a data quality issue.

---

### [TC-RP-03] ISAK 35 Laporan Aktivitas Generates Correctly with Restricted/Unrestricted Split

**Given:**
- The organization has completed the fiscal year with:
  - Restricted grant income (from Grant Fund A): USD 80,000 = IDR 1,264,000,000 (at blended rate)
  - Unrestricted donation income: IDR 150,000,000
  - Campaign restricted income (Campaign Fund B): IDR 120,000,000
  - Total expenses against restricted funds: IDR 560,420,000
  - Total expenses against unrestricted funds: IDR 63,000,000
  - Release from restriction (grant funds fully utilized and closed): IDR 560,420,000 moved from Restricted to Unrestricted

**When:**
Finance Manager generates the Laporan Aktivitas (Statement of Activities) for FY2025

**Then:**
Laporan Aktivitas shows the following structure:

```
LAPORAN AKTIVITAS
Periode 1 Januari 2025 — 31 Desember 2025

                                          Dengan          Tanpa
                                       Pembatasan     Pembatasan       Total
PERUBAHAN ASET NETO:
Pendapatan:
  Pendapatan Grant                    1,264,000,000           —    1,264,000,000
  Pendapatan Donasi Terbatas            120,000,000           —      120,000,000
  Pendapatan Donasi Tidak Terbatas              —    150,000,000      150,000,000
                                    ─────────────  ─────────────  ─────────────
Total Pendapatan                      1,384,000,000   150,000,000  1,534,000,000

Pelepasan Pembatasan Dana:
  Pelepasan dari pembatasan donor      (560,420,000)  560,420,000            —

Beban:
  Beban Program                                —    (560,420,000)   (560,420,000)
  Beban Administrasi dan Umum                  —     (63,000,000)    (63,000,000)
                                    ─────────────  ─────────────  ─────────────
Kenaikan Aset Neto                     823,580,000    86,420,000    910,000,000
Saldo Awal Aset Neto                            —             —              —
                                    ─────────────  ─────────────  ─────────────
Saldo Akhir Aset Neto                  823,580,000    86,420,000    910,000,000
```

- Report is available for export to XLSX and PDF
- Column split (With Restriction / Without Restriction) maps to Fund Restriction type
- "Pelepasan Pembatasan" entries come from Restriction Release Journal Entries

**Edge case / negative test:**
- If a Restriction Release Journal Entry has not been created for a fully utilized restricted fund, the Laporan Aktivitas will show an imbalance (restricted income not released). The Data Health Check flags this: "Fund [name] is fully spent but no Restriction Release has been recorded."

---

### [TC-RP-04] Campaign Public Report Generated After Campaign Status = Reporting

**Given:**
- Campaign Fund B "Peduli Bencana Sulteng" has status = Reporting
- Total donations received: IDR 250,000,000 from 1,847 donors
- Total fundraising cost: IDR 12,500,000
- Total program expenses: IDR 210,000,000
- Remaining balance: IDR 27,500,000 (to be used in next distribution phase)
- Campaign period: 1 July 2025 — 30 September 2025

**When:**
Finance Manager generates the Campaign Public Report for Campaign Fund B

**Then:**
- Report is generated in a donor-friendly format with:
  - Campaign summary: total raised, number of donors, period
  - Fundraising costs: IDR 12,500,000 (5% of total raised)
  - Net available for program: IDR 237,500,000
  - Program expenses by activity:
    - Emergency food distribution: IDR 90,000,000
    - Emergency shelter support: IDR 75,000,000
    - Medical assistance: IDR 45,000,000
  - Remaining balance: IDR 27,500,000 with note "Allocated for Phase 2 distribution"
  - Evidence summary: "325 receipts attached, 3 activity reports, 12 beneficiary lists"
- Report can be exported to PDF for public publication
- Campaign status can be updated to Reported after report is generated and published

**Edge case / negative test:**
- If Campaign status is not yet = Reporting (e.g., still = Active), the "Generate Public Report" button is disabled with tooltip: "Campaign must be in Reporting status to generate the public accountability report."
- If any expense attached to Campaign Fund B has incomplete evidence (no receipt or activity report), a warning appears: "3 transactions have incomplete evidence. Review before publishing the report."
