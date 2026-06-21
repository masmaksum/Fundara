import frappe
from frappe import _
from frappe.model.document import Document


class Organization(Document):
	def validate(self):
		self._validate_single_active()
		self._validate_base_currency_matches_company()

	def _validate_single_active(self):
		if not self.is_active:
			return
		existing = frappe.db.get_value(
			"Organization",
			{"is_active": 1, "name": ("!=", self.name or "")},
			"name",
		)
		if existing:
			frappe.throw(
				_("Only one Organization can be active at a time. Currently active: {0}").format(existing)
			)

	def _validate_base_currency_matches_company(self):
		if not self.base_currency:
			return
		company_currency = frappe.db.get_single_value("Global Defaults", "default_currency")
		if company_currency and company_currency != self.base_currency:
			frappe.msgprint(
				_("Warning: Base Currency ({0}) differs from Company default currency ({1}).").format(
					self.base_currency, company_currency
				),
				alert=True,
			)
