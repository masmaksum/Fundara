import frappe
from frappe import _
from frappe.model.document import Document


class Donation(Document):
	def validate(self):
		self._validate_donor_required()
		self._validate_amount()
		self._validate_restriction_purpose()
		self._validate_exchange_rate()
		self._compute_base_currency_amount()
		self._validate_campaign_status()

	def _validate_donor_required(self):
		if not self.is_anonymous and not self.donor:
			frappe.throw(_("Donor is required for non-anonymous donations."))
		if self.is_anonymous and self.donor:
			frappe.throw(_("Donor must be blank for anonymous donations."))

	def _validate_amount(self):
		if self.amount is not None and self.amount <= 0:
			frappe.throw(_("Donation Amount must be greater than zero."))

	def _validate_restriction_purpose(self):
		if self.restriction_type == "Restricted" and not self.restriction_purpose:
			frappe.throw(_("Restriction Purpose is required when Restriction Type is 'Restricted'."))

	def _validate_exchange_rate(self):
		if not self.currency:
			return
		org_currency = frappe.db.get_value("Organization", self.organization, "base_currency")
		if org_currency and self.currency != org_currency and not self.exchange_rate:
			frappe.throw(
				_("Exchange Rate is required when Donation Currency ({0}) differs from base currency ({1}).").format(
					self.currency, org_currency
				)
			)

	def _compute_base_currency_amount(self):
		if self.amount:
			rate = self.exchange_rate or 1
			self.amount_in_base_currency = self.amount * rate

	def _validate_campaign_status(self):
		if not self.fundraising_campaign:
			return
		campaign_status = frappe.db.get_value(
			"Fundraising Campaign", self.fundraising_campaign, "status"
		)
		if campaign_status in ("Cancelled", "Closed"):
			frappe.throw(
				_("Cannot link donation to a campaign with status '{0}'.").format(campaign_status)
			)
