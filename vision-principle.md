# Fundara Vision & Principles

**Product:** Fundara  
**Category:** Mission Impact Platform  
**Tagline:** Helping mission-driven organizations turn trusted funds into measurable impact.  
**Audience:** NGOs, foundations, community organizations, social enterprises, philanthropic institutions, faith-based organizations, and other mission-driven teams.

---

## 1. Purpose of This Document

This document defines the vision and operating principles of **Fundara** as an open-source Mission Impact Platform.

It explains what Fundara wants to become, why it exists, what kind of change it wants to create, and what principles should guide product design, architecture, implementation, governance, and community contribution.

This document should be treated as a foundation for:

- product strategy;
- domain modeling;
- roadmap planning;
- technical architecture;
- open-source governance;
- contributor alignment;
- implementation decisions;
- community communication.

Fundara may technically behave like an ERP-backed system, but its public identity is not merely “ERP for NGOs.” Fundara is positioned as a **Mission Impact Platform**: a system that helps mission-driven organizations connect funding, operations, accountability, and impact in one transparent workflow.

---

## 2. Vision Statement

### 2.1 English Vision

> **To become the open-source mission impact infrastructure that helps organizations turn trusted resources into transparent action and measurable social impact.**

### 2.2 Indonesian Vision

> **Menjadi infrastruktur open-source untuk dampak misi sosial yang membantu organisasi mengubah sumber daya amanah menjadi aksi yang transparan dan dampak sosial yang terukur.**

---

## 3. Expanded Vision

Mission-driven organizations are trusted with funds, programs, people, evidence, public expectations, and social responsibility. Yet many of them still manage critical operations through disconnected spreadsheets, manual approvals, scattered documents, isolated accounting systems, and reporting processes that require repeated reconstruction.

Fundara envisions a different future.

A future where every trusted fund can be traced from its source to its intended purpose, from approved budget to field activity, from transaction to supporting evidence, and from operational work to measurable impact.

A future where small and medium-sized NGOs can access the same level of operational clarity, accountability, and reporting quality that large organizations often build through expensive proprietary systems.

A future where donors, boards, finance teams, program managers, field staff, and communities can work with shared information, not fragmented records.

A future where accountability is not treated as a burden added at the end of a project, but as a natural part of daily operations.

A future where open-source infrastructure helps strengthen the social sector by making transparent, auditable, and mission-aligned management tools accessible to more organizations.

Fundara exists to support that future.

---

## 4. Vision Narrative

Fundara believes that social impact depends not only on good intentions, but also on trustworthy systems.

Organizations that serve communities often operate under difficult constraints: limited staff, complex donor requirements, unpredictable funding cycles, field-level realities, and high expectations for transparency. They must manage grants, donations, fundraising campaigns, unit usaha or social enterprise income, internal funds, procurement, cash advances, project budgets, operational requests, evidence, indicators, and reports.

When these processes are fragmented, organizations lose time, visibility, and trust. Finance teams chase receipts. Program teams maintain parallel trackers. Management lacks real-time insight. Donor reporting becomes a recurring manual burden. Evidence is collected too late. Impact becomes difficult to connect with the resources used to create it.

Fundara aims to change this by connecting the full chain:

```text
Funding Source
→ Fund
→ Program / Project
→ Activity
→ Budget
→ Request
→ Procurement / Expense / Advance
→ Payment / Liquidation
→ Evidence
→ Report
→ Impact
```

This is the essence of Fundara’s vision:

> **From trusted funds to measurable impact, every step should be traceable, accountable, and useful.**

---

## 5. What Fundara Wants to Make Possible

Fundara wants to make the following outcomes possible for mission-driven organizations.

### 5.1 Fund Transparency

Organizations can clearly see:

- where each fund comes from;
- whether the fund is restricted, unrestricted, board-designated, or internally allocated;
- what purpose the fund is intended for;
- how much has been budgeted, committed, spent, and remains available;
- which projects, activities, and expenses are linked to the fund.

### 5.2 Program Accountability

Program teams can plan, request, implement, and report activities without losing the connection between fieldwork, budget, evidence, and impact.

Each activity should be connected to:

- project objectives;
- fund source;
- budget line;
- responsible person;
- location;
- planned and actual cost;
- supporting evidence;
- output or outcome indicators.

### 5.3 Financial Control Without Losing Mission Focus

Finance should not be separated from mission delivery.

Fundara should help organizations ensure that expenses are:

- linked to the correct fund;
- eligible under fund restrictions;
- within approved budget;
- approved through the right workflow;
- supported by complete documentation;
- reflected in reports without manual reconstruction.

### 5.4 Audit Readiness by Default

Fundara should help organizations become audit-ready as part of normal operations.

This means every important transaction should carry:

- source fund;
- project and activity context;
- budget reference;
- approval history;
- supporting documents;
- posting or payment status;
- reporting classification.

Audit readiness should not depend on a last-minute document hunt.

### 5.5 Better Reporting for Donors, Boards, Communities, and Management

Fundara should support multiple types of reporting:

- donor financial reports;
- grant utilization reports;
- fundraising campaign reports;
- unrestricted fund reports;
- business unit surplus reports;
- management dashboards;
- impact reports;
- supporting document registers;
- audit packs.

Reports should be generated from structured operational data, not rebuilt manually from scattered spreadsheets.

### 5.6 Open Infrastructure for the Social Sector

Fundara should become open infrastructure that can be adapted by local communities, implementers, NGOs, and developers.

It should not force every organization into one rigid workflow. Instead, it should provide a strong domain foundation that can be configured, localized, extended, and integrated.

---

## 6. Product Identity

### 6.1 Name

**Fundara**

The name suggests fund, flow, trust, and stewardship. It is intentionally less technical than “ERP” and more accessible to mission-driven organizations.

### 6.2 Category

**Mission Impact Platform**

Fundara is not presented primarily as an ERP, accounting package, donor database, or M&E tool. It is a platform that connects all of those operational concerns around the mission.

### 6.3 Tagline

> **Helping mission-driven organizations turn trusted funds into measurable impact.**

Indonesian version:

> **Membantu organisasi misi sosial mengubah dana amanah menjadi dampak yang terukur.**

### 6.4 Core Promise

Fundara helps organizations connect:

```text
Trusted Funds → Accountable Operations → Evidence → Measurable Impact
```

### 6.5 Technical Interpretation

Under the hood, Fundara can be implemented as a fund-centric ERP-like platform built on ERPNext/Frappe.

However, in communication with users, the emphasis should be on mission, accountability, transparency, and impact—not on enterprise software terminology.

---

## 7. Vision Boundaries

Fundara should be ambitious, but not vague. It should have clear boundaries.

### 7.1 Fundara Is

Fundara is:

- a Mission Impact Platform;
- an open-source operational backbone for mission-driven organizations;
- a fund-centric system for managing resources entrusted to organizations;
- a bridge between finance, program, operations, evidence, and impact;
- a configurable platform for grants, donations, fundraising, social enterprise income, and internal funds;
- a tool for improving transparency, accountability, and reporting.

### 7.2 Fundara Is Not

Fundara is not:

- only an accounting system;
- only a donor CRM;
- only a project management tool;
- only an M&E platform;
- only a grant reporting tool;
- only a document repository;
- a rigid one-size-fits-all NGO template;
- a proprietary black-box system;
- a replacement for organizational governance, policies, and human accountability.

Fundara supports good governance, but it does not replace the need for good governance.

---

# 8. Core Principles

The following principles guide Fundara’s product, domain, architecture, and community decisions.

---

## Principle 1: Mission First, Software Second

Fundara exists to strengthen mission-driven work, not to impose software complexity.

Every feature should be judged by whether it helps organizations manage their mission more clearly, transparently, and effectively.

### Implications

- Avoid building features only because traditional ERP systems have them.
- Prioritize workflows that connect funding, fieldwork, accountability, and impact.
- Use language that program, finance, operations, management, and field teams can understand.
- Design around mission outcomes, not only accounting structures.

### Design Question

> Does this feature help an organization deliver, account for, or learn from its mission work?

---

## Principle 2: Fund-First Design

Fundara starts from the reality that mission-driven organizations manage entrusted funds with different restrictions, purposes, reporting requirements, and accountability expectations.

The fund is not merely an accounting label. It is a governance object.

### Implications

Every major transaction should know:

- which fund it uses;
- where the fund came from;
- whether the fund is restricted or unrestricted;
- what project or activity it supports;
- which budget line it affects;
- what reporting obligation it contributes to.

### Design Question

> Can this transaction be traced back to the fund and its intended purpose?

---

## Principle 3: From Funding to Impact

Fundara should connect the full journey from funding source to measurable impact.

The platform should not stop at recording income and expenses. It should help organizations understand how resources become activities, outputs, outcomes, and impact.

### Implications

Fundara should connect:

```text
Funding Source
→ Fund
→ Budget
→ Project
→ Activity
→ Expense
→ Evidence
→ Output / Outcome
→ Report
```

This allows organizations to answer questions such as:

- Which funds supported this activity?
- What did we spend?
- What evidence supports it?
- What output was produced?
- What impact indicator did it contribute to?

### Design Question

> Can we connect the money spent with the work done and the result achieved?

---

## Principle 4: Accountability by Design

Accountability should be embedded into daily workflows, not added manually at the end.

Fundara should help organizations build accountability into requests, approvals, procurement, spending, liquidation, reporting, and evidence management.

### Implications

- Approval trails should be captured automatically.
- Supporting documents should be required when relevant.
- Budget checks should happen before spending, not only after posting.
- Exceptions should be visible and explainable.
- Reports should be traceable back to source transactions.

### Design Question

> If this item appears in a report, can we explain, approve, and evidence it?

---

## Principle 5: Transparency Without Overexposure

Fundara should promote transparency while respecting confidentiality, safeguarding, privacy, and data protection.

Not all data should be visible to everyone. Transparency must be balanced with appropriate access control.

### Implications

- Use role-based permissions.
- Separate public accountability data from sensitive internal records.
- Protect beneficiary, donor, staff, financial, and case-related data.
- Avoid exposing sensitive field data unnecessarily.
- Support anonymized or aggregated reporting where needed.

### Design Question

> Who needs to see this information, and what level of detail is safe and appropriate?

---

## Principle 6: Evidence Should Travel With the Work

Evidence should not be collected only at reporting or audit time. It should be linked to the work as it happens.

### Implications

Evidence can include:

- receipts;
- invoices;
- attendance lists;
- photos;
- contracts;
- delivery notes;
- bid comparisons;
- field reports;
- beneficiary records;
- monitoring forms;
- approval memos.

Each evidence item should be connected to the relevant activity, transaction, project, fund, or report.

### Design Question

> If someone asks “where is the proof?”, can the system answer quickly?

---

## Principle 7: Reporting Should Be Generated, Not Reconstructed

Organizations should not need to rebuild reports from scratch every month, quarter, or grant cycle.

Reports should be generated from structured data captured during normal operations.

### Implications

- Reporting requirements should influence data model design.
- Donor report categories should be mapped early.
- Campaign reports should be linked to donation and expense records.
- Business unit reports should be linked to income, cost, and surplus allocation.
- Impact reports should connect activities, outputs, and indicators.

### Design Question

> Are we capturing the data needed to generate this report later?

---

## Principle 8: Configurable Before Customizable

Mission-driven organizations are diverse. Fundara should support variation through configuration wherever possible before requiring custom code.

### Implications

Configuration should support differences in:

- fund types;
- donor rules;
- campaign restrictions;
- approval workflows;
- procurement thresholds;
- budget structures;
- reporting formats;
- currencies;
- localization;
- organizational structure.

Custom code should be reserved for genuinely unique requirements.

### Design Question

> Can this variation be handled through configuration instead of custom development?

---

## Principle 9: Field-Friendly by Default

Fundara should work for people closest to the mission, not only for head office staff.

Field staff, program officers, volunteers, and local implementers should be able to interact with the system without needing deep accounting or ERP knowledge.

### Implications

- Use simple language in field-facing forms.
- Minimize unnecessary fields.
- Provide contextual defaults.
- Support mobile-friendly workflows where possible.
- Separate accounting complexity from program input forms.
- Design for low-bandwidth and intermittent connectivity as a future direction.

### Design Question

> Can a field or program user complete this workflow without feeling like they are using an accounting system?

---

## Principle 10: Finance and Program Must Stay Connected

Finance and program work should not live in separate worlds.

Fundara should help both teams use the same underlying information while giving each role the interface and language they need.

### Implications

- Program activities should link to budgets and funds.
- Finance transactions should link to program context.
- Budget vs actual reports should be useful to both finance and program teams.
- Liquidation and evidence workflows should connect operational reality with accounting requirements.

### Design Question

> Does this workflow help finance and program teams understand the same reality from different perspectives?

---

## Principle 11: Open Source as Stewardship

Fundara is open-source because mission infrastructure should be accessible, inspectable, adaptable, and community-owned.

Open source is not only a licensing choice. It is part of Fundara’s accountability model.

### Implications

- The codebase should be open for inspection and contribution.
- Documentation should be clear enough for implementers and communities.
- The project should welcome localization and sector-specific extensions.
- Governance should encourage trust, transparency, and long-term maintainability.
- Avoid vendor lock-in.

### Design Question

> Does this decision strengthen community ownership and long-term trust?

---

## Principle 12: Interoperability and Data Portability

Fundara should not trap organizations inside one closed system.

Mission-driven organizations often use many tools: accounting software, spreadsheets, KoboToolbox, ODK, Google Workspace, Microsoft 365, payment gateways, banking tools, BI dashboards, and donor templates.

Fundara should be designed to integrate, export, import, and exchange data responsibly.

### Implications

- Provide APIs where possible.
- Support structured imports and exports.
- Avoid proprietary-only data formats.
- Design stable identifiers for domain objects.
- Make reporting data accessible for BI tools.

### Design Question

> Can organizations move, integrate, and reuse their data without unnecessary friction?

---

## Principle 13: Localizable by Design

Mission-driven organizations operate in different legal, cultural, financial, and donor environments.

Fundara should support localization from the beginning.

### Implications

Localization may include:

- language;
- currency;
- chart of accounts templates;
- tax treatment;
- donor report templates;
- procurement thresholds;
- approval practices;
- local NGO regulations;
- naming conventions;
- date and number formats.

### Design Question

> Can this model adapt to local practice without breaking the core architecture?

---

## Principle 14: Audit Trail Is a Product Feature

Audit trail should not be treated as a technical afterthought.

For mission-driven organizations, trust depends on being able to explain decisions, approvals, spending, evidence, and changes over time.

### Implications

Fundara should preserve:

- status history;
- approval history;
- document versions;
- budget revisions;
- fund allocation changes;
- transaction references;
- report generation history;
- user actions where appropriate.

### Design Question

> Can we reconstruct what happened, when it happened, who approved it, and why?

---

## Principle 15: Simplicity Is a Form of Inclusion

Many organizations that need Fundara most may not have large finance teams, IT departments, or implementation budgets.

Simplicity is not a nice-to-have. It is essential for accessibility.

### Implications

- Start with essential workflows.
- Avoid over-modeling early.
- Provide clear defaults.
- Use progressive complexity: simple by default, advanced when needed.
- Build documentation for non-technical users as well as implementers.

### Design Question

> Can a small organization adopt the core value of Fundara without a heavy implementation burden?

---

## Principle 16: Modularity Over Monolith Thinking

Although Fundara may be built on ERPNext/Frappe, the product should be conceptually modular.

Organizations should be able to adopt capabilities progressively.

### Implications

Possible modules include:

- Fund Management;
- Grant Management;
- Donation and Campaign Management;
- Business Unit / Social Enterprise Management;
- Project and Activity Management;
- Procurement;
- Cash Advance and Liquidation;
- Finance and Budget Control;
- Evidence and Compliance;
- Impact Reporting;
- Audit Pack;
- Integration Layer.

### Design Question

> Can this capability work as part of a broader platform while remaining understandable and maintainable on its own?

---

## Principle 17: The System Should Support Good Judgment, Not Replace It

Fundara should help organizations make better decisions, but it should not pretend that every governance question can be automated.

### Implications

- Allow exception workflows with documented justification.
- Make risks visible rather than silently blocking every edge case.
- Provide decision context to approvers.
- Support policy-based controls while allowing accountable overrides where appropriate.

### Design Question

> Does the system support responsible decision-making instead of hiding complexity or forcing unrealistic rigidity?

---

## Principle 18: Build for Trust

The ultimate product of Fundara is not only software. It is trust.

Trust between organizations and donors. Trust between finance and program teams. Trust between management and field teams. Trust between organizations and the communities they serve.

### Implications

Fundara should help build trust through:

- clear fund tracking;
- transparent workflows;
- complete evidence;
- reliable reports;
- consistent approvals;
- secure access;
- open-source governance;
- explainable data.

### Design Question

> Does this feature increase trust in how mission resources are managed?

---

# 9. Product Design Principles Summary

The principles can be summarized as follows:

| Principle | Short Meaning |
|---|---|
| Mission First | Build for mission delivery, not software complexity |
| Fund-First Design | Treat funds as governance objects, not just accounting tags |
| Funding to Impact | Connect resources to activities, evidence, and results |
| Accountability by Design | Embed accountability into daily workflows |
| Transparency With Protection | Share what is needed, protect what is sensitive |
| Evidence Travels With Work | Link proof to activities and transactions as they happen |
| Reporting Generated | Reports should come from structured operational data |
| Configurable Before Custom | Prefer settings and templates over custom code |
| Field-Friendly | Design for program and field users, not only finance users |
| Finance-Program Alignment | Keep financial and program realities connected |
| Open Source Stewardship | Build community-owned mission infrastructure |
| Interoperability | Make data portable and systems connectable |
| Localizable | Adapt to local rules, language, and practice |
| Audit Trail as Feature | Preserve explainability over time |
| Simplicity | Make adoption possible for smaller organizations |
| Modularity | Allow progressive adoption and extension |
| Support Judgment | Help people decide responsibly |
| Build Trust | Make trust the outcome of the system |

---

# 10. Engineering Principles

Fundara’s technical implementation should support the product principles above.

## 10.1 Domain-Driven Design

The system should be modeled around real mission-sector concepts such as Fund, Grant, Campaign, Project, Activity, Budget Line, Evidence, Indicator, and Report.

Avoid forcing NGO concepts into generic ERP categories when doing so would lose important meaning.

## 10.2 Strong Core, Flexible Edges

The core domain model should be stable and coherent, while allowing local extensions and sector-specific modules.

Core concepts should include:

- Organization;
- Funding Source;
- Fund;
- Project;
- Activity;
- Budget;
- Transaction;
- Evidence;
- Report;
- Indicator.

Extensions may include:

- donor-specific reporting;
- local tax handling;
- religious giving models;
- social enterprise modules;
- humanitarian response workflows;
- case management integrations.

## 10.3 Use ERPNext/Frappe Strengths Where Appropriate

Fundara can benefit from ERPNext/Frappe capabilities such as:

- DocTypes;
- workflows;
- role permissions;
- accounting;
- projects;
- buying;
- selling;
- stock;
- assets;
- dashboards;
- reports;
- REST APIs;
- custom apps.

The goal is not to rebuild ERPNext, but to create a mission-driven domain layer on top of it.

## 10.4 Avoid Over-Customization

Custom code should be used carefully.

Where possible, Fundara should rely on:

- configuration;
- custom fields;
- workflow definitions;
- standard DocType extensions;
- reusable templates;
- report builders;
- modular apps.

## 10.5 Testability and Auditability

Business rules that affect fund use, budget control, approval, reporting, and compliance should be testable and explainable.

Examples:

- budget availability checks;
- grant period checks;
- mandatory evidence rules;
- procurement threshold rules;
- fund restriction checks;
- reporting category mapping.

## 10.6 Data Quality as a First-Class Concern

Because reports depend on operational data, Fundara should encourage data completeness and consistency.

This includes:

- required fields where appropriate;
- validation rules;
- reference data governance;
- controlled vocabularies;
- status workflows;
- duplicate prevention;
- clear ownership of master data.

---

# 11. Community and Open-Source Principles

Fundara’s open-source community should reflect the mission it serves.

## 11.1 Community Before Vendor

The project should avoid becoming dependent on a single vendor or implementer. Vendors and consultants may contribute, but the long-term direction should serve the wider community.

## 11.2 Documentation Is Part of the Product

Documentation should serve multiple audiences:

- NGO leaders;
- finance teams;
- program teams;
- implementers;
- developers;
- donors and partners;
- open-source contributors.

## 11.3 Localization Contributions Are Valuable

Local chart of accounts templates, donor report formats, translations, procurement rules, and workflow patterns should be treated as meaningful contributions.

## 11.4 Real-World Feedback Matters

Product decisions should be informed by real NGO workflows, not only software assumptions.

Field realities, finance constraints, donor expectations, and local compliance practices should shape the roadmap.

## 11.5 Respectful Governance

Fundara should maintain a contribution culture based on:

- clarity;
- transparency;
- respectful discussion;
- practical usefulness;
- maintainability;
- openness to local contexts.

---

# 12. Practical Decision Framework

When evaluating a new feature, module, or design change, contributors should ask:

1. Does it strengthen Fundara’s mission impact positioning?
2. Does it connect funding, operations, accountability, or impact more clearly?
3. Does it improve transparency without exposing sensitive data?
4. Does it reduce manual reconstruction of reports?
5. Does it help finance and program teams work from shared information?
6. Can it be configured instead of hard-coded?
7. Is it understandable for the intended users?
8. Is it maintainable as part of an open-source project?
9. Does it preserve auditability and explainability?
10. Does it help build trust?

If the answer to most of these questions is no, the feature may not belong in Fundara’s core.

---

# 13. Consequences for Roadmap

The vision and principles imply a phased roadmap.

## Phase 0: Foundation

Focus:

- product identity;
- mission and vision;
- domain model;
- repository structure;
- documentation;
- contribution guide;
- license;
- demo dataset.

## Phase 1: Fund and Project Finance Core

Focus:

- funding source;
- fund master;
- project;
- activity;
- budget line;
- budget allocation;
- expense request;
- cash advance;
- liquidation;
- fund utilization report.

## Phase 2: Grant and Donor Accountability

Focus:

- donor;
- grant;
- grant budget;
- grant period control;
- eligible cost rules;
- donor report schedule;
- supporting document register;
- budget revision;
- donor financial report.

## Phase 3: Fundraising and Campaign Fund

Focus:

- campaign;
- donation receipt;
- restricted and unrestricted donations;
- donor acknowledgment;
- fundraising cost;
- campaign utilization report;
- public accountability report.

## Phase 4: Social Enterprise and Unit Usaha

Focus:

- business unit;
- sales revenue;
- cost center;
- operating cost;
- business unit P&L;
- surplus calculation;
- surplus allocation to mission funds.

## Phase 5: Evidence, MEAL, and Impact

Focus:

- indicator framework;
- target vs actual;
- beneficiary reach;
- activity results;
- evidence repository;
- cost per output;
- impact report.

## Phase 6: Ecosystem and Scale

Focus:

- localization packs;
- donor templates;
- mobile and offline workflows;
- Kobo/ODK integration;
- BI integration;
- API ecosystem;
- community modules.

---

# 14. North Star Metrics

Fundara should define success through mission-aligned metrics, not only software adoption.

Potential North Star metrics:

- percentage of expenses traceable to a fund, project, activity, and evidence;
- reduction in time needed to prepare donor reports;
- percentage of active funds with real-time budget vs actual visibility;
- percentage of advances liquidated on time;
- number of organizations using Fundara for multi-source fund management;
- number of localized templates contributed by the community;
- number of reports generated from system data instead of manual spreadsheets;
- percentage of activities linked to output or outcome indicators.

A strong candidate North Star metric:

> **Percentage of mission spending that is fully traceable from funding source to activity, evidence, and impact indicator.**

Indonesian version:

> **Persentase belanja misi yang dapat ditelusuri secara lengkap dari sumber dana, aktivitas, bukti, hingga indikator dampak.**

---

# 15. Final Vision Summary

Fundara is built on the belief that mission-driven organizations deserve transparent, accountable, affordable, and adaptable infrastructure.

Its vision is not merely to digitize administration. Its vision is to help organizations steward trusted funds, coordinate mission operations, produce reliable reports, and demonstrate measurable impact.

Fundara should make it easier for organizations to answer:

- Where did this fund come from?
- What was it intended for?
- Who approved its use?
- Which project and activity used it?
- What evidence supports it?
- What result did it help create?
- Can we report it with confidence?

If Fundara can help organizations answer these questions clearly, it will fulfill its promise:

> **Helping mission-driven organizations turn trusted funds into measurable impact.**

