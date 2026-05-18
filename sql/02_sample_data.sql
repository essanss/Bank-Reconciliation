-- Optional manual insert sample data. You can also import CSV files from /data.
USE finance_recon;

INSERT INTO bank_statement (bank_txn_id, transaction_date, description, reference_no, debit, credit, bank_account, source_file) VALUES
('B001','2026-05-01','NEFT RECEIPT INV1001 ACME LTD','INV1001',0,125000,'HDFC-001','bank_statement_may.csv'),
('B002','2026-05-02','VENDOR PAYMENT INFOSYS BILL 789','PAY789',85000,0,'HDFC-001','bank_statement_may.csv'),
('B003','2026-05-03','CUSTOMER RECEIPT INV1002 BETA PVT','INV1002',0,76000,'HDFC-001','bank_statement_may.csv'),
('B004','2026-05-04','BANK CHARGES MAY','BANKCHG',650,0,'HDFC-001','bank_statement_may.csv'),
('B005','2026-05-05','RTGS RECEIPT INV1003 DELTA','INV1003',0,98000,'HDFC-001','bank_statement_may.csv'),
('B006','2026-05-06','NEFT RECEIPT INV1003 DELTA DUPLICATE','INV1003',0,98000,'HDFC-001','bank_statement_may.csv'),
('B007','2026-05-07','PAYMENT TO TCS INV AP556','AP556',45000,0,'HDFC-001','bank_statement_may.csv'),
('B008','2026-05-08','UPI CUSTOMER RECEIPT UNKNOWN','UPI889',0,15000,'HDFC-001','bank_statement_may.csv'),
('B009','2026-05-09','SALARY PAYMENT MAY','PAYROLL',120000,0,'HDFC-001','bank_statement_may.csv'),
('B010','2026-05-11','NEFT RECEIPT INV1004 OMEGA','INV1004',0,32000,'HDFC-001','bank_statement_may.csv'),
('B011','2026-05-12','VENDOR PAYMENT WIPRO BILL AP557','AP557',62000,0,'HDFC-001','bank_statement_may.csv'),
('B012','2026-05-13','REVERSAL BANK ERROR','REV001',0,650,'HDFC-001','bank_statement_may.csv'),
('B013','2026-05-14','CUSTOMER RECEIPT INV1005 GAMMA','INV1005',0,110000,'HDFC-001','bank_statement_may.csv'),
('B014','2026-05-14','CUSTOMER RECEIPT INV1005 GAMMA DUP','INV1005',0,110000,'HDFC-001','bank_statement_may.csv'),
('B015','2026-05-15','CARD SETTLEMENT INV1006','INV1006',0,54000,'HDFC-001','bank_statement_may.csv');

INSERT INTO erp_transactions (erp_txn_id, transaction_date, document_type, customer_vendor, invoice_no, reference_no, debit, credit, status) VALUES
('E001','2026-05-01','Customer Receipt','ACME LTD','INV1001','INV1001',0,125000,'Posted'),
('E002','2026-05-02','Vendor Payment','INFOSYS','AP789','PAY789',85000,0,'Posted'),
('E003','2026-05-03','Customer Receipt','BETA PVT','INV1002','INV1002',0,76000,'Posted'),
('E004','2026-05-05','Customer Receipt','DELTA','INV1003','INV1003',0,98000,'Posted'),
('E005','2026-05-07','Vendor Payment','TCS','AP556','AP556',45000,0,'Posted'),
('E006','2026-05-09','Payroll Payment','Employees','MAYPAY','PAYROLL',120000,0,'Posted'),
('E007','2026-05-10','Customer Receipt','OMEGA','INV1004','INV1004',0,32000,'Posted'),
('E008','2026-05-12','Vendor Payment','WIPRO','AP557','AP557',62000,0,'Posted'),
('E009','2026-05-14','Customer Receipt','GAMMA','INV1005','INV1005',0,110000,'Posted'),
('E010','2026-05-15','Customer Receipt','LAMBDA','INV1006','INV1006',0,54000,'Posted'),
('E011','2026-05-16','Vendor Payment','ZOHO','AP558','AP558',25000,0,'Posted'),
('E012','2026-05-17','Customer Receipt','NOVA','INV1007','INV1007',0,70000,'Posted');