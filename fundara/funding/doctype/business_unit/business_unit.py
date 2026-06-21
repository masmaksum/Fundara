import frappe
from frappe import _
from frappe.model.document import Document


class BusinessUnit(Document):
	def validate(self):
		self._validate_closing_date()

	def _validate_closing_date(self):
		if self.closing_date and self.opening_date and self.closing_date < self.opening_date:
			frappe.throw(_("Closing Date cannot be earlier than Opening Date."))
