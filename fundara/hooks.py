app_name = "fundara"
app_title = "Fundara"
app_publisher = "Fundara Team"
app_description = "Fund-centric ERP for Indonesian NGOs"
app_email = "bagong@combine.id"
app_license = "mit"

# Fundara Modules
# ---------------
# app_include_icons = "fundara/public/icons.svg"  # file belum dibuat

# Fixtures
fixtures = [
    {"dt": "Role", "filters": [["role_name", "in", [
        "Program Manager", "Project Officer", "Executive Viewer", "Auditor Viewer",
        "Finance Officer",
    ]]]},
    {"dt": "Custom Field", "filters": [["module", "=", "Organization"]]},
    {"dt": "Fund Type", "filters": []},
    {"dt": "Activity Type", "filters": [["activity_type", "in", [
        "Training", "Advocacy", "Service Delivery", "Research",
        "Community Engagement", "Coordination", "Monitoring and Evaluation",
    ]]]},
]

# Apps
# ------------------

# required_apps = []

# Each item in the list will be shown as an app in the apps page
# add_to_apps_screen = [
# 	{
# 		"name": "fundara",
# 		"logo": "/assets/fundara/logo.png",
# 		"title": "Fundara",
# 		"route": "/fundara",
# 		"has_permission": "fundara.api.permission.has_app_permission"
# 	}
# ]

# Includes in <head>
# ------------------

# include js, css files in header of desk.html
# app_include_css = "/assets/fundara/css/fundara.css"
# app_include_js = "/assets/fundara/js/fundara.js"

# include js, css files in header of web template
# web_include_css = "/assets/fundara/css/fundara.css"
# web_include_js = "/assets/fundara/js/fundara.js"

# include custom scss in every website theme (without file extension ".scss")
# website_theme_scss = "fundara/public/scss/website"

# include js, css files in header of web form
# webform_include_js = {"doctype": "public/js/doctype.js"}
# webform_include_css = {"doctype": "public/css/doctype.css"}

# include js in page
# page_js = {"page" : "public/js/file.js"}

# include js in doctype views
# doctype_js = {"doctype" : "public/js/doctype.js"}
# doctype_list_js = {"doctype" : "public/js/doctype_list.js"}
# doctype_tree_js = {"doctype" : "public/js/doctype_tree.js"}
# doctype_calendar_js = {"doctype" : "public/js/doctype_calendar.js"}

# Svg Icons
# ------------------
# include app icons in desk
# app_include_icons = "fundara/public/icons.svg"

# Home Pages
# ----------

# application home page (will override Website Settings)
# home_page = "login"

# website user home page (by Role)
# role_home_page = {
# 	"Role": "home_page"
# }

# Generators
# ----------

# automatically create page for each record of this doctype
# website_generators = ["Web Page"]

# automatically load and sync documents of this doctype from downstream apps
# importable_doctypes = [doctype_1]

# Jinja
# ----------

# add methods and filters to jinja environment
# jinja = {
# 	"methods": "fundara.utils.jinja_methods",
# 	"filters": "fundara.utils.jinja_filters"
# }

# Installation
# ------------

# before_install = "fundara.install.before_install"
# after_install = "fundara.install.after_install"

# Uninstallation
# ------------

# before_uninstall = "fundara.uninstall.before_uninstall"
# after_uninstall = "fundara.uninstall.after_uninstall"

# Integration Setup
# ------------------
# To set up dependencies/integrations with other apps
# Name of the app being installed is passed as an argument

# before_app_install = "fundara.utils.before_app_install"
# after_app_install = "fundara.utils.after_app_install"

# Integration Cleanup
# -------------------
# To clean up dependencies/integrations with other apps
# Name of the app being uninstalled is passed as an argument

# before_app_uninstall = "fundara.utils.before_app_uninstall"
# after_app_uninstall = "fundara.utils.after_app_uninstall"

# Build
# ------------------
# To hook into the build process

# after_build = "fundara.build.after_build"

# Desk Notifications
# ------------------
# See frappe.core.notifications.get_notification_config

# notification_config = "fundara.notifications.get_notification_config"

# Permissions
# -----------
# Permissions evaluated in scripted ways

# permission_query_conditions = {
# 	"Event": "frappe.desk.doctype.event.event.get_permission_query_conditions",
# }
#
# has_permission = {
# 	"Event": "frappe.desk.doctype.event.event.has_permission",
# }

# Document Events
# ---------------
# Hook on document methods and events

# doc_events = {
# 	"*": {
# 		"on_update": "method",
# 		"on_cancel": "method",
# 		"on_trash": "method"
# 	}
# }

# Scheduled Tasks
# ---------------

# scheduler_events = {
# 	"all": [
# 		"fundara.tasks.all"
# 	],
# 	"daily": [
# 		"fundara.tasks.daily"
# 	],
# 	"hourly": [
# 		"fundara.tasks.hourly"
# 	],
# 	"weekly": [
# 		"fundara.tasks.weekly"
# 	],
# 	"monthly": [
# 		"fundara.tasks.monthly"
# 	],
# }

# Testing
# -------

# before_tests = "fundara.install.before_tests"

# Extend DocType Class
# ------------------------------
#
# Specify custom mixins to extend the standard doctype controller.
# extend_doctype_class = {
# 	"Task": "fundara.custom.task.CustomTaskMixin"
# }

# Overriding Methods
# ------------------------------
#
# override_whitelisted_methods = {
# 	"frappe.desk.doctype.event.event.get_events": "fundara.event.get_events"
# }
#
# each overriding function accepts a `data` argument;
# generated from the base implementation of the doctype dashboard,
# along with any modifications made in other Frappe apps
# override_doctype_dashboards = {
# 	"Task": "fundara.task.get_dashboard_data"
# }

# exempt linked doctypes from being automatically cancelled
#
# auto_cancel_exempted_doctypes = ["Auto Repeat"]

# Ignore links to specified DocTypes when deleting documents
# -----------------------------------------------------------

# ignore_links_on_delete = ["Communication", "ToDo"]

# Request Events
# ----------------
# before_request = ["fundara.utils.before_request"]
# after_request = ["fundara.utils.after_request"]

# Job Events
# ----------
# before_job = ["fundara.utils.before_job"]
# after_job = ["fundara.utils.after_job"]

# User Data Protection
# --------------------

# user_data_fields = [
# 	{
# 		"doctype": "{doctype_1}",
# 		"filter_by": "{filter_by}",
# 		"redact_fields": ["{field_1}", "{field_2}"],
# 		"partial": 1,
# 	},
# 	{
# 		"doctype": "{doctype_2}",
# 		"filter_by": "{filter_by}",
# 		"partial": 1,
# 	},
# 	{
# 		"doctype": "{doctype_3}",
# 		"strict": False,
# 	},
# 	{
# 		"doctype": "{doctype_4}"
# 	}
# ]

# Authentication and authorization
# --------------------------------

# auth_hooks = [
# 	"fundara.auth.validate"
# ]

# Automatically update python controller files with type annotations for this app.
# export_python_type_annotations = True

# default_log_clearing_doctypes = {
# 	"Logging DocType Name": 30  # days to retain logs
# }

# Translation
# ------------
# List of apps whose translatable strings should be excluded from this app's translations.
# ignore_translatable_strings_from = []

