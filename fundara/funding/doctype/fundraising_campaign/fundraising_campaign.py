import frappe
from frappe import _
from frappe.model.document import Document


class FundraisingCampaign(Document):
	def validate(self):
		self._validate_dates()
		self._validate_restricted_purpose()

	def before_submit(self):
		if self.status not in ("Approved", "Active"):
			frappe.throw(
				_("Campaign must be in 'Approved' or 'Active' status before submitting.")
			)

	def _validate_dates(self):
		if self.end_date and self.start_date and self.end_date < self.start_date:
			frappe.throw(_("End Date must be after Start Date."))

	def _validate_restricted_purpose(self):
		if self.restriction_type == "Restricted" and not self.restricted_purpose:
			frappe.throw(_("Restricted Purpose is required when Restriction Type is 'Restricted'."))
