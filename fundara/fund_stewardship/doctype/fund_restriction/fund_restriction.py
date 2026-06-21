import frappe
from frappe import _
from frappe.model.document import Document


class FundRestriction(Document):
	def validate(self):
		self._validate_allowed_period()
		self._validate_change_reason_required()
		self._validate_approval_fields()

	def before_submit(self):
		if not self.approved_by:
			frappe.throw(_("Approved By is required before submission."))
		if not self.approval_date:
			frappe.throw(_("Approval Date is required before submission."))

	def on_submit(self):
		self._supersede_previous_restriction()

	def _validate_allowed_period(self):
		if (self.allowed_period_start and self.allowed_period_end
				and self.allowed_period_end < self.allowed_period_start):
			frappe.throw(_("Allowed Period End cannot be earlier than Allowed Period Start."))

	def _validate_change_reason_required(self):
		prior = frappe.db.get_value(
			"Fund Restriction",
			{"fund": self.fund, "docstatus": 1, "name": ("!=", self.name)},
			"name",
		)
		if prior and not self.change_reason:
			frappe.throw(
				_("Change Reason is mandatory when the Fund already has a prior approved restriction.")
			)

	def _validate_approval_fields(self):
		if self.approval_date and self.approval_date < self.effective_date:
			frappe.msgprint(
				_("Approval Date is earlier than Effective Date — please verify."),
				alert=True,
			)

	def _supersede_previous_restriction(self):
		"""Cancel any previously submitted restriction for the same Fund."""
		previous = frappe.get_all(
			"Fund Restriction",
			filters={"fund": self.fund, "docstatus": 1, "name": ("!=", self.name)},
			pluck="name",
		)
		for name in previous:
			doc = frappe.get_doc("Fund Restriction", name)
			doc.cancel()
