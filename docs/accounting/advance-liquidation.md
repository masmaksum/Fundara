# Advance & Liquidation

## 1. Ringkasan

Modul uang muka adalah fitur penting Fundara karena banyak organisasi misi sosial menjalankan kegiatan lapangan melalui advance kepada staff, relawan, atau tim project.

Risiko umum advance:

- outstanding terlalu lama;
- bukti tidak lengkap;
- tidak terkait activity;
- tidak jelas fund dan budget line;
- donor report tertunda;
- staff masih memegang dana organisasi.

## 2. Entitas

```text
Advance Request
Advance Payment
Additional Advance Payment
Liquidation
Refund
Reimbursement
Advance Aging
Advance Settlement
```

## 3. Advance Request

Data utama:

- requester;
- fund;
- project;
- activity;
- budget line;
- purpose;
- amount requested;
- amount approved;
- expected activity date;
- liquidation due date;
- approval status.

## 4. Workflow Advance

```text
Request
→ Budget Check
→ Supervisor Approval
→ Finance Approval
→ Payment
→ Pending Liquidation
→ Liquidation Submitted
→ Finance Review
→ Closed / Refund / Additional Payment / Reimbursement
```

## 5. Liquidation

Liquidation mencatat realisasi penggunaan advance.

Data:

- cash advance;
- expense lines;
- actual amount;
- receipts/evidence;
- refund amount;
- reimbursement amount;
- reviewer;
- finance approval.

Jika actual lebih kecil dari advance:

```text
Refund Required
```

Jika actual lebih besar dari advance dan disetujui:

```text
Additional Payment / Reimbursement Required
```

## 6. Advance Aging

Kategori aging:

```text
0-7 hari
8-14 hari
15-30 hari
>30 hari
Overdue
```

Dashboard harus menunjukkan:

- outstanding advance by staff;
- outstanding advance by project;
- outstanding advance by donor/fund;
- overdue advance;
- advance tanpa activity;
- advance tanpa liquidation.

## 7. Business Rules

1. Advance harus memiliki fund.
2. Advance untuk project harus memiliki project dan activity.
3. Advance harus memiliki due date liquidation.
4. Advance overdue harus muncul dalam dashboard finance.
5. Liquidation tidak boleh ditutup tanpa bukti minimum.
6. Liquidation harus memperbarui actual expense.
7. Refund harus tercatat sebagai penerimaan kas/bank.
8. Additional payment harus melalui approval.
9. Advance yang sudah closed tidak boleh diubah tanpa correction flow.

## 8. MVP

MVP Advance:

- advance request;
- payment;
- liquidation;
- refund/reimbursement calculation;
- evidence upload;
- advance aging;
- budget check;
- dashboard outstanding advance.
