import frappe
from frappe import _
from frappe.model.document import Document


class Office(Document):
	def validate(self):
		self._validate_head_office_unique()
		self._validate_closing_date()
		self._validate_no_self_parent()

	def _validate_head_office_unique(self):
		if self.office_type != "Head Office":
			return
		existing = frappe.db.get_value(
			"Office",
			{
				"office_type": "Head Office",
				"organization": self.organization,
				"name": ("!=", self.name or ""),
				"is_active": 1,
			},
			"name",
		)
		if existing:
			frappe.throw(
				_("Organization {0} already has an active Head Office: {1}").format(
					self.organization, existing
				)
			)

	def _validate_closing_date(self):
		if self.closing_date and self.opening_date and self.closing_date < self.opening_date:
			frappe.throw(_("Closing Date cannot be earlier than Opening Date."))

	def _validate_no_self_parent(self):
		if self.parent_office and self.parent_office == self.name:
			frappe.throw(_("An Office cannot be its own Parent Office."))
