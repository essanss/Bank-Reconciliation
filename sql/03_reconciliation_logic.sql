USE finance_recon;

-- 1) Clear previous results for repeatable execution
TRUNCATE TABLE reconciliation_results;

-- 2) Exact match: same reference number and same net amount
INSERT INTO reconciliation_results
(bank_txn_id, erp_txn_id, reference_no, bank_amount, erp_amount, amount_difference, date_difference_days, match_status, exception_reason)
SELECT
    b.bank_txn_id,
    e.erp_txn_id,
    b.reference_no,
    b.net_amount AS bank_amount,
    e.net_amount AS erp_amount,
    b.net_amount - e.net_amount AS amount_difference,
    DATEDIFF(b.transaction_date, e.transaction_date) AS date_difference_days,
    CASE
        WHEN ABS(DATEDIFF(b.transaction_date, e.transaction_date)) <= 1 THEN 'MATCHED'
        ELSE 'MATCHED_WITH_TIMING_DIFFERENCE'
    END AS match_status,
    CASE
        WHEN ABS(DATEDIFF(b.transaction_date, e.transaction_date)) <= 1 THEN 'Reference and amount matched'
        ELSE 'Reference and amount matched, but posting date differs'
    END AS exception_reason
FROM bank_statement b
JOIN erp_transactions e
    ON b.reference_no = e.reference_no
   AND b.net_amount = e.net_amount;

-- 3) Bank entries not found in ERP
INSERT INTO reconciliation_results
(bank_txn_id, erp_txn_id, reference_no, bank_amount, erp_amount, amount_difference, date_difference_days, match_status, exception_reason)
SELECT
    b.bank_txn_id,
    NULL,
    b.reference_no,
    b.net_amount,
    NULL,
    NULL,
    NULL,
    'BANK_NOT_IN_ERP',
    'Transaction exists in bank statement but not posted in ERP'
FROM bank_statement b
LEFT JOIN reconciliation_results r ON b.bank_txn_id = r.bank_txn_id
WHERE r.bank_txn_id IS NULL;

-- 4) ERP entries not found in bank
INSERT INTO reconciliation_results
(bank_txn_id, erp_txn_id, reference_no, bank_amount, erp_amount, amount_difference, date_difference_days, match_status, exception_reason)
SELECT
    NULL,
    e.erp_txn_id,
    e.reference_no,
    NULL,
    e.net_amount,
    NULL,
    NULL,
    'ERP_NOT_IN_BANK',
    'Transaction posted in ERP but not found in bank statement'
FROM erp_transactions e
LEFT JOIN reconciliation_results r ON e.erp_txn_id = r.erp_txn_id
WHERE r.erp_txn_id IS NULL;

-- 5) Duplicate bank transactions by reference and amount
CREATE OR REPLACE VIEW vw_duplicate_bank_transactions AS
SELECT
    reference_no,
    net_amount,
    COUNT(*) AS duplicate_count,
    GROUP_CONCAT(bank_txn_id ORDER BY transaction_date) AS bank_transaction_ids
FROM bank_statement
GROUP BY reference_no, net_amount
HAVING COUNT(*) > 1;

-- 6) Duplicate ERP transactions by reference and amount
CREATE OR REPLACE VIEW vw_duplicate_erp_transactions AS
SELECT
    reference_no,
    net_amount,
    COUNT(*) AS duplicate_count,
    GROUP_CONCAT(erp_txn_id ORDER BY transaction_date) AS erp_transaction_ids
FROM erp_transactions
GROUP BY reference_no, net_amount
HAVING COUNT(*) > 1;

-- 7) Final exception report for finance review
CREATE OR REPLACE VIEW vw_bank_reconciliation_exception_report AS
SELECT
    recon_id,
    COALESCE(bank_txn_id, '-') AS bank_txn_id,
    COALESCE(erp_txn_id, '-') AS erp_txn_id,
    reference_no,
    bank_amount,
    erp_amount,
    amount_difference,
    date_difference_days,
    match_status,
    exception_reason,
    created_at
FROM reconciliation_results
WHERE match_status <> 'MATCHED'
ORDER BY match_status, reference_no;

-- 8) Management summary
CREATE OR REPLACE VIEW vw_reconciliation_summary AS
SELECT
    match_status,
    COUNT(*) AS transaction_count,
    SUM(COALESCE(bank_amount, 0)) AS total_bank_amount,
    SUM(COALESCE(erp_amount, 0)) AS total_erp_amount
FROM reconciliation_results
GROUP BY match_status;

SELECT * FROM vw_reconciliation_summary;
SELECT * FROM vw_bank_reconciliation_exception_report;
SELECT * FROM vw_duplicate_bank_transactions;