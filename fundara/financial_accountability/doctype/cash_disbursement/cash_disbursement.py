import frappe
from frappe import _
from frappe.model.document import Document


class CashDisbursement(Document):
	def validate(self):
		self._validate_amount()
		self._compute_amount_base()

	def before_submit(self):
		self._check_budget_availability()

	def on_submit(self):
		self._post_journal_entry()

	def on_cancel(self):
		self._cancel_journal_entry()

	# ------------------------------------------------------------------

	def _validate_amount(self):
		if not self.amount or self.amount <= 0:
			frappe.throw(_("Amount must be greater than zero."))
		if not self.exchange_rate or self.exchange_rate <= 0:
			frappe.throw(_("Exchange Rate must be greater than zero."))

	def _compute_amount_base(self):
		self.amount_base = (self.amount or 0) * (self.exchange_rate or 1)

	def _check_budget_availability(self):
		if not self.budget_line:
			return
		status = get_budget_status(self.fund, self.budget_line)
		available = status.get("available", 0)
		amount_base = self.amount_base or self._compute_amount_base() or 0
		if available < amount_base:
			frappe.throw(
				_("Insufficient budget. Available: {0} IDR, Required: {1} IDR (D-02).").format(
					frappe.format(available, {"fieldtype": "Currency"}),
					frappe.format(amount_base, {"fieldtype": "Currency"}),
				)
			)

	def _post_journal_entry(self):
		if self.journal_entry:
			return

		company = frappe.db.get_single_value("Global Defaults", "default_company")
		je = frappe.get_doc({
			"doctype": "Journal Entry",
			"voucher_type": "Journal Entry",
			"posting_date": self.posting_date,
			"company": company,
			"user_remark": f"Cash Disbursement {self.name} — {self.payee}",
			"accounts": [
				{
					"account": self.expense_account,
					"debit_in_account_currency": self.amount,
					"credit_in_account_currency": 0,
					"exchange_rate": self.exchange_rate or 1,
					"account_currency": self.currency,
					"fund": self.fund,
					"project": self.project,
					"activity": self.activity,
					"cost_center": self.cost_center,
					"reference_type": "Cash Disbursement",
					"reference_name": self.name,
					# budget_line dimension linked after Accounting Dimension config
				},
				{
					"account": self.bank_account,
					"debit_in_account_currency": 0,
					"credit_in_account_currency": self.amount,
					"exchange_rate": self.exchange_rate or 1,
					"account_currency": self.currency,
					"fund": self.fund,
					"reference_type": "Cash Disbursement",
					"reference_name": self.name,
				},
			],
		})
		je.insert(ignore_permissions=True)
		try:
			je.submit()
		except Exception as e:
			frappe.log_error(message=str(e), title=f"Cash Disbursement JE submit failed: {self.name}")
			frappe.throw(_("Failed to post Journal Entry for Cash Disbursement {0}: {1}").format(self.name, str(e)))

		self.db_set("journal_entry", je.name)

	def _cancel_journal_entry(self):
		if not self.journal_entry:
			return
		je = frappe.get_doc("Journal Entry", self.journal_entry)
		if je.docstatus == 1:
			try:
				je.cancel()
			except Exception as e:
				frappe.log_error(message=str(e), title=f"Cash Disbursement JE cancel failed: {self.name}")
				frappe.throw(_("Failed to cancel Journal Entry {0}: {1}").format(self.journal_entry, str(e)))


@frappe.whitelist()
def get_budget_status(fund, budget_line):
	frappe.has_permission("Cash Disbursement", throw=True)

	if not fund or not budget_line:
		return {"status": "green", "available": 0}

	approved = frappe.db.get_value("Fund Budget Line", budget_line, "approved_amount") or 0
	revised = frappe.db.get_value("Fund Budget Line", budget_line, "revised_amount")
	effective_budget = revised if revised is not None else approved

	# D-02: actual = sum of submitted Cash Disbursements + Purchase Invoices against this budget_line
	actual_cd = frappe.db.sql(
		"""
		SELECT COALESCE(SUM(amount_base), 0)
		FROM `tabCash Disbursement`
		WHERE budget_line = %s AND docstatus = 1
		""",
		(budget_line,),
	)[0][0]

	available = effective_budget - actual_cd

	if available > effective_budget * 0.2:
		status = "green"
	elif available > 0:
		status = "yellow"
	else:
		status = "red"

	return {"status": status, "available": float(available)}
