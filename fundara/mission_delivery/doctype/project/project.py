import frappe
from frappe import _
from frappe.model.document import Document

# FE-01: status colors — spec docs/spec/frontend/status-colors.md
_PROJECT_INDICATORS = {
    "Concept": "grey",
    "Approved": "blue",
    "Active": "blue",
    "On Hold": "orange",
    "Completed": "green",
    "Closed": "darkgrey",
}


def get_indicator(doc, all_data=False):
    color = _PROJECT_INDICATORS.get(doc.status, "grey")
    return [doc.status, color, f"status,=,{doc.status}"]


class Project(Document):
	def validate(self):
		self._validate_dates()
		self._validate_close_conditions()
		self._compute_total_budget()
		self._validate_fund_allocation_amounts()

	def _validate_dates(self):
		if self.end_date and self.start_date and self.end_date < self.start_date:
			frappe.throw(_("End Date cannot be earlier than Start Date."))

	def _validate_close_conditions(self):
		if self.status != "Closed":
			return
		if not self.is_new():
			open_activities = frappe.db.count(
				"Activity",
				filters={
					"project": self.name,
					"status": ("not in", ["Completed", "Reported", "Verified", "Closed"]),
				},
			)
			if open_activities:
				frappe.throw(
					_("Cannot close Project: {0} Activity record(s) are not in a terminal state.").format(
						open_activities
					)
				)

	def _compute_total_budget(self):
		total = sum(row.allocated_amount or 0 for row in (self.fund_allocations or []))
		self.total_budget = total

	def _validate_fund_allocation_amounts(self):
		for row in (self.fund_allocations or []):
			if not row.allocated_amount or row.allocated_amount <= 0:
				frappe.throw(
					_("Fund Allocation amount must be greater than zero (row {0}).").format(row.idx)
				)
