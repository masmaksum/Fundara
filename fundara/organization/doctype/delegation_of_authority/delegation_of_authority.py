import frappe
from frappe import _
from frappe.model.document import Document


class DelegationofAuthority(Document):
	def validate(self):
		self._validate_amount_range()
		self._validate_dates()
		self._validate_document_types_unique()

	def on_submit(self):
		self.is_active = 1
		self.db_set("is_active", 1)

	def on_cancel(self):
		self.is_active = 0
		self.db_set("is_active", 0)

	def _validate_amount_range(self):
		if self.minimum_amount and self.maximum_amount:
			if self.maximum_amount <= self.minimum_amount:
				frappe.throw(_("Maximum Amount must be greater than Minimum Amount."))

	def _validate_dates(self):
		if self.valid_to and self.valid_from and self.valid_to < self.valid_from:
			frappe.throw(_("Valid To cannot be earlier than Valid From."))

	def _validate_document_types_unique(self):
		seen = set()
		for row in self.applicable_document_types:
			if row.document_type in seen:
				frappe.throw(
					_("Document Type '{0}' is listed more than once in Applicable Document Types.").format(
						row.document_type
					)
				)
			seen.add(row.document_type)
