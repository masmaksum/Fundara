import frappe
from frappe import _
from frappe.model.document import Document


class BudgetRevision(Document):
	def before_insert(self):
		self._set_revision_number()

	def validate(self):
		self._validate_budget_editable()
		self._validate_revised_amounts()
		self._compute_change_amounts()

	def on_submit(self):
		self._apply_revision_to_budget()

	def _set_revision_number(self):
		last = frappe.db.get_value(
			"Budget Revision",
			{"budget": self.budget, "docstatus": 1},
			"revision_number",
			order_by="revision_number desc",
		)
		self.revision_number = (last or 0) + 1

	def _validate_budget_editable(self):
		if not self.budget:
			return
		budget_status = frappe.db.get_value("Fund Budget", self.budget, "status")
		if budget_status not in ("Approved", "Active", "Revised"):
			frappe.throw(
				_("Budget Revision can only be created for a Budget in Approved, Active, or Revised status.")
			)

	def _validate_revised_amounts(self):
		for row in (self.revision_lines or []):
			if row.revised_amount is None or row.revised_amount < 0:
				frappe.throw(_("Revised Amount must be >= 0 on row {0}.").format(row.idx))

	def _compute_change_amounts(self):
		for row in (self.revision_lines or []):
			if row.budget_line and not row.original_amount:
				row.original_amount = frappe.db.get_value(
					"Fund Budget Line", row.budget_line, "approved_amount"
				)
			row.change_amount = (row.revised_amount or 0) - (row.original_amount or 0)

	def _apply_revision_to_budget(self):
		for row in (self.revision_lines or []):
			if row.budget_line:
				frappe.db.set_value(
					"Fund Budget Line", row.budget_line, "revised_amount", row.revised_amount
				)
		frappe.db.set_value("Fund Budget", self.budget, "status", "Revised")
