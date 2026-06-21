import frappe
from frappe import _
from frappe.model.document import Document

INSTITUTIONAL_TYPES = {"Institutional", "Multilateral Agency", "Government", "Philanthropic Foundation"}


class Donor(Document):
    def validate(self):
        self._validate_individual_no_profile()
        self._validate_institutional_profile_type()

    def _validate_individual_no_profile(self):
        if self.donor_type == "Individual" and self.institutional_profile:
            frappe.throw(_("Individual donors cannot have an Institutional Profile."))

    def _validate_institutional_profile_type(self):
        if self.donor_type in INSTITUTIONAL_TYPES and not self.institutional_profile:
            frappe.msgprint(
                _("Institutional donor '{0}' has no Institutional Donor Profile linked.").format(
                    self.donor_name
                ),
                alert=True,
            )
