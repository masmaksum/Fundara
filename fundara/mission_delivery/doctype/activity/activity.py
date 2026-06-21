import frappe
from frappe import _
from frappe.model.document import Document


class Activity(Document):
	def validate(self):
		self._validate_project_active()
		self._auto_populate_program()

	def _validate_project_active(self):
		if not self.project:
			return
		project_status = frappe.db.get_value("Project", self.project, "status")
		if project_status not in ("Active",):
			frappe.throw(
				_("Activity must belong to a Project with status Active. Project '{0}' is currently '{1}'.").format(
					self.project, project_status
				)
			)

	def _auto_populate_program(self):
		if self.project and not self.program:
			self.program = frappe.db.get_value("Project", self.project, "program")
