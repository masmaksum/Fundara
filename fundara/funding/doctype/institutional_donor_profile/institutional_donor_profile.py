import frappe
from frappe import _
from frappe.model.document import Document

ALLOWED_DONOR_TYPES = {"Institutional", "Government", "Multilateral Agency", "Philanthropic Foundation"}


class InstitutionalDonorProfile(Document):
    def validate(self):
        self._validate_donor_type()

    def _validate_donor_type(self):
        if not self.linked_donor:
            return
        donor_type = frappe.db.get_value("Donor", self.linked_donor, "donor_type")
        if donor_type and donor_type not in ALLOWED_DONOR_TYPES:
            frappe.throw(
                _("Institutional Donor Profile can only be linked to donors of type: {0}.").format(
                    ", ".join(ALLOWED_DONOR_TYPES)
                )
            )
