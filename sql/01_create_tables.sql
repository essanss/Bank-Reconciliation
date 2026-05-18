-- Bank Reconciliation Automation - MySQL schema
-- Purpose: compare bank statement transactions with ERP transactions and identify matched, unmatched, duplicate, and timing-difference items.

DROP DATABASE IF EXISTS finance_recon;
CREATE DATABASE finance_recon;
USE finance_recon;

CREATE TABLE bank_statement (
    bank_txn_id VARCHAR(20) PRIMARY KEY,
    transaction_date DATE NOT NULL,
    description VARCHAR(255),
    reference_no VARCHAR(60),
    debit DECIMAL(14,2) DEFAULT 0,
    credit DECIMAL(14,2) DEFAULT 0,
    bank_account VARCHAR(50),
    source_file VARCHAR(100),
    net_amount DECIMAL(14,2) GENERATED ALWAYS AS (credit - debit) STORED
);

CREATE TABLE erp_transactions (
    erp_txn_id VARCHAR(20) PRIMARY KEY,
    transaction_date DATE NOT NULL,
    document_type VARCHAR(80),
    customer_vendor VARCHAR(100),
    invoice_no VARCHAR(60),
    reference_no VARCHAR(60),
    debit DECIMAL(14,2) DEFAULT 0,
    credit DECIMAL(14,2) DEFAULT 0,
    status VARCHAR(30),
    net_amount DECIMAL(14,2) GENERATED ALWAYS AS (credit - debit) STORED
);

CREATE TABLE reconciliation_results (
    recon_id INT AUTO_INCREMENT PRIMARY KEY,
    bank_txn_id VARCHAR(20),
    erp_txn_id VARCHAR(20),
    reference_no VARCHAR(60),
    bank_amount DECIMAL(14,2),
    erp_amount DECIMAL(14,2),
    amount_difference DECIMAL(14,2),
    date_difference_days INT,
    match_status VARCHAR(50),
    exception_reason VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);