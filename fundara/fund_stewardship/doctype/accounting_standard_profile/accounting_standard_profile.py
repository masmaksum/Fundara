import frappe
from frappe import _
from frappe.model.document import Document


class AccountingStandardProfile(Document):
	def validate(self):
		self._validate_single_active_per_company()

	def _validate_single_active_per_company(self):
		if not self.is_active:
			return
		existing = frappe.db.get_value(
			"Accounting Standard Profile",
			{"company": self.company, "is_active": 1, "name": ("!=", self.name)},
			"name",
		)
		if existing:
			frappe.msgprint(
				_("Company {0} already has an active Accounting Standard Profile: {1}. "
				  "Consider deactivating it first.").format(self.company, existing),
				alert=True,
			)
