import frappe
from frappe import _
from frappe.model.document import Document

# FE-01: status colors — spec docs/spec/frontend/status-colors.md
_BUDGET_INDICATORS = {
    "Draft": "grey",
    "Submitted": "blue",
    "Review by Program": "orange",
    "Review by Finance": "orange",
    "Approved": "green",
    "Active": "blue",
    "Revised": "yellow",
    "Closed": "darkgrey",
}


def get_indicator(doc, all_data=False):
    color = _BUDGET_INDICATORS.get(doc.status, "grey")
    return [doc.status, color, f"status,=,{doc.status}"]


class FundBudget(Document):
	def validate(self):
		self._validate_dates()
		self._validate_budget_lines()
		self._compute_totals()

	def before_submit(self):
		if self.status not in ("Approved", "Active"):
			frappe.throw(_("Budget must be in Approved or Active status before submission."))

	def _validate_dates(self):
		if self.end_date and self.start_date and self.end_date < self.start_date:
			frappe.throw(_("End Date cannot be earlier than Start Date."))

	def _validate_budget_lines(self):
		for row in (self.budget_lines or []):
			if not row.approved_amount or row.approved_amount <= 0:
				frappe.throw(
					_("Approved Amount must be greater than zero on Budget Line row {0}.").format(row.idx)
				)

	def _compute_totals(self):
		total_approved = sum(row.approved_amount or 0 for row in (self.budget_lines or []))
		total_actual = sum(row.actual_amount or 0 for row in (self.budget_lines or []))
		self.total_approved_amount = total_approved
		self.total_actual_amount = total_actual
		self.total_available_amount = total_approved - total_actual
