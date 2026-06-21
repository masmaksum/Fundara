import frappe
from frappe import _
from frappe.model.document import Document


class Fund(Document):
	def validate(self):
		self._validate_grant_required()
		self._validate_dates()
		self._validate_bridging_fund()
		self._validate_end_date_required()
		self._compute_opening_balance_base()
		self._set_base_currency()

	def before_submit(self):
		if self.status not in ("Active",):
			frappe.throw(_("Fund must be set to 'Active' before submission."))

	def _validate_grant_required(self):
		fund_type = frappe.db.get_value("Fund Type", self.fund_type, "requires_grant")
		if fund_type and not self.grant:
			frappe.throw(
				_("Grant is mandatory for Fund Type '{0}' (D-01).").format(self.fund_type)
			)

	def _validate_dates(self):
		if self.end_date and self.start_date and self.end_date < self.start_date:
			frappe.throw(_("End Date cannot be earlier than Start Date."))

	def _validate_end_date_required(self):
		if not self.fund_type:
			return
		has_end_date = frappe.db.get_value("Fund Type", self.fund_type, "has_end_date")
		if has_end_date and not self.end_date:
			frappe.throw(
				_("End Date is mandatory for Fund Type '{0}'.").format(self.fund_type)
			)

	def _validate_bridging_fund(self):
		if self.recoverable_from_fund and self.recoverable_from_fund == self.name:
			frappe.throw(_("A Fund cannot be set as recoverable from itself."))

	def _compute_opening_balance_base(self):
		if self.opening_balance is not None:
			rate = self.exchange_rate_on_creation or 1
			self.opening_balance_base = self.opening_balance * rate

	def _set_base_currency(self):
		base = frappe.db.get_single_value("Global Defaults", "default_currency") or "IDR"
		self.base_currency = base
