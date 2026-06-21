frappe.ui.form.on('Activity', {
	// ==========================================
	// SETUP
	// ==========================================
	setup(frm) {
		// Filter project hanya yang Active
		frm.set_query('project', () => ({
			filters: { status: 'Active' }
		}));
		// Filter fund berdasarkan project yang dipilih
		frm.set_query('fund', () => ({
			filters: { status: 'Active' }
		}));
	},

	// ==========================================
	// REFRESH — buttons, locks
	// ==========================================
	refresh(frm) {
		apply_activity_lock(frm);
		add_activity_buttons(frm);
	},

	// ==========================================
	// VALIDATE — FE-02 pesan Bahasa Indonesia
	// ==========================================
	validate(frm) {
		// actual_date tidak boleh sebelum planned_date
		if (frm.doc.actual_date && frm.doc.planned_date
				&& frm.doc.actual_date < frm.doc.planned_date) {
			frappe.msgprint({
				message: __('Tanggal realisasi ({0}) lebih awal dari tanggal rencana ({1}). '
					+ 'Periksa kembali tanggal activity.', [frm.doc.actual_date, frm.doc.planned_date]),
				indicator: 'orange',
				title: __('Perhatian — Tanggal Activity'),
			});
		}

		// actual_cost tidak boleh negatif
		if (frm.doc.actual_cost < 0) {
			frappe.throw(__('Biaya realisasi (Actual Cost) tidak boleh negatif.'));
		}
	},

	// ==========================================
	// HANDLER 1: project dipilih → auto-isi program + fund
	// ==========================================
	project(frm) {
		if (!frm.doc.project) return;
		frappe.db.get_value(
			'Project', frm.doc.project,
			['program', 'cost_center'],
			(r) => {
				if (!r) return;
				if (r.program && !frm.doc.program) {
					frm.set_value('program', r.program);
				}
				if (r.cost_center && !frm.doc.cost_center) {
					frm.set_value('cost_center', r.cost_center);
				}
			}
		);
	},

	// ==========================================
	// HANDLER 2: fund dipilih → auto-isi currency
	// ==========================================
	fund(frm) {
		if (!frm.doc.fund) return;
		frappe.db.get_value('Fund', frm.doc.fund, 'currency', (r) => {
			if (r && r.currency && !frm.doc.currency) {
				frm.set_value('currency', r.currency);
			}
		});
	},

	// ==========================================
	// HANDLER 3: currency → toggle exchange_rate (D-04)
	// ==========================================
	currency(frm) {
		toggle_activity_exchange_rate(frm);
	},

	// ==========================================
	// HANDLER 4: planned_date / actual_date → validasi overlap
	// (overlap check dengan activity lain di project yang sama)
	// ==========================================
	planned_date(frm) { check_date_overlap(frm); },
});

// ==========================================
// HELPER: lock saat status terminal
// ==========================================
function apply_activity_lock(frm) {
	const terminal = ['Verified', 'Closed'].includes(frm.doc.status);
	if (terminal) {
		frm.set_intro(
			__('Activity dalam status <strong>{0}</strong> — tidak dapat diedit.',
				[frm.doc.status]),
			'blue'
		);
	}
	const lockable = [
		'activity_name', 'activity_code', 'activity_type', 'project', 'program',
		'fund', 'budget_line', 'cost_center', 'responsible_person',
		'planned_date', 'planned_cost', 'target_output',
	];
	lockable.forEach(f => frm.set_df_property(f, 'read_only', terminal ? 1 : 0));
}

// ==========================================
// HELPER: exchange rate read_only jika IDR (D-04)
// ==========================================
function toggle_activity_exchange_rate(frm) {
	const base = frappe.defaults.get_default('currency') || 'IDR';
	const is_base = frm.doc.currency === base;
	frm.set_df_property('exchange_rate', 'read_only', is_base ? 1 : 0);
	frm.set_df_property('exchange_rate', 'reqd', is_base ? 0 : 1);
	if (is_base && frm.doc.exchange_rate !== 1) {
		frm.set_value('exchange_rate', 1);
	}
	frm.refresh_field('exchange_rate');
}

// ==========================================
// HELPER: cek overlap tanggal dengan activity lain di project
// ==========================================
function check_date_overlap(frm) {
	if (!frm.doc.project || !frm.doc.planned_date || frm.doc.__islocal) return;
	frappe.call({
		method: 'frappe.client.get_count',
		args: {
			doctype: 'Activity',
			filters: {
				project: frm.doc.project,
				planned_date: frm.doc.planned_date,
				name: ['!=', frm.doc.name || ''],
				status: ['not in', ['Closed', 'Verified']],
			},
		},
		callback(r) {
			if (r.message > 0) {
				frappe.show_alert({
					message: __('Terdapat {0} activity lain pada tanggal yang sama di proyek ini.',
						[r.message]),
					indicator: 'orange',
				}, 8);
			}
		},
	});
}

// ==========================================
// HELPER: custom buttons
// ==========================================
function add_activity_buttons(frm) {
	if (frm.doc.__islocal) return;

	// "Buat Advance" — buka Cash Advance baru terkait activity ini
	if (['Approved', 'In Progress'].includes(frm.doc.status)) {
		frm.add_custom_button(__('Buat Advance'), () => {
			frappe.new_doc('Cash Advance', {
				activity: frm.doc.name,
				project: frm.doc.project,
				fund: frm.doc.fund,
				budget_line: frm.doc.budget_line,
			});
		}, __('Activity'));
	}

	// "Tandai Selesai" — transisi ke Completed
	if (frm.doc.status === 'In Progress') {
		frm.add_custom_button(__('Tandai Selesai'), () => {
			frappe.confirm(
				__('Tandai activity <strong>{0}</strong> sebagai Selesai?', [frm.doc.activity_name]),
				() => {
					// Cek tidak ada advance terbuka
					frappe.call({
						method: 'frappe.client.get_count',
						args: {
							doctype: 'Cash Advance',
							filters: {
								activity: frm.doc.name,
								workflow_state: ['not in', ['Closed', 'Cancelled', 'Rejected']],
							},
						},
						callback(r) {
							if (r.message > 0) {
								frappe.msgprint({
									message: __(
										'Tidak dapat menyelesaikan activity: terdapat <strong>{0}</strong> '
										+ 'Cash Advance yang masih terbuka. Selesaikan semua advance '
										+ 'sebelum menandai activity sebagai selesai.', [r.message]
									),
									indicator: 'red',
									title: __('Activity Tidak Bisa Diselesaikan'),
								});
							} else {
								frm.set_value('status', 'Completed');
								frm.set_value('actual_date', frappe.datetime.get_today());
								frm.save();
							}
						},
					});
				}
			);
		}, __('Activity'));
	}
}
