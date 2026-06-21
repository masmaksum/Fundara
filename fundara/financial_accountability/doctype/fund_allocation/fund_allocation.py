import frappe
from frappe import _
from frappe.model.document import Document


class FundAllocation(Document):
	def validate(self):
		self._validate_amount()
		self._refresh_fund_balance()

	def before_submit(self):
		self._refresh_fund_balance()
		if self.fund_available_balance < self.amount:
			frappe.throw(
				_("Insufficient fund balance. Available: {0}, Requested: {1} (D-02).").format(
					frappe.format(self.fund_available_balance, {"fieldtype": "Currency"}),
					frappe.format(self.amount, {"fieldtype": "Currency"}),
				)
			)

	def _validate_amount(self):
		if not self.amount or self.amount <= 0:
			frappe.throw(_("Allocation Amount must be greater than zero."))

	def _refresh_fund_balance(self):
		if not self.fund:
			return
		opening = frappe.db.get_value("Fund", self.fund, "opening_balance_base") or 0
		allocated = frappe.db.sql(
			"""
			SELECT COALESCE(SUM(amount), 0)
			FROM `tabFund Allocation`
			WHERE fund = %s AND docstatus = 1 AND name != %s
			""",
			(self.fund, self.name or ""),
		)[0][0]
		self.fund_available_balance = opening - allocated
		self.fund_restriction_ok = 1
