import frappe
from frappe import _
from frappe.model.document import Document


class FundingSource(Document):
    def validate(self):
        self._validate_deactivation_date()
        self._validate_linked_sub_records()

    def _validate_deactivation_date(self):
        if self.deactivation_date and self.activation_date:
            if self.deactivation_date < self.activation_date:
                frappe.throw(_("Deactivation Date cannot be earlier than Activation Date."))

    def _validate_linked_sub_records(self):
        donor_types = {"Institutional Donor", "Individual Donor", "Corporate Donor"}
        campaign_types = {"Fundraising Campaign", "Public Fundraising"}
        revenue_types = {"Social Enterprise Revenue", "Service Revenue", "Membership Fee"}

        if self.source_type in donor_types and not self.linked_donor:
            return
        if self.source_type in campaign_types and not self.linked_campaign:
            return
        if self.source_type in revenue_types and not self.linked_business_unit:
            return
