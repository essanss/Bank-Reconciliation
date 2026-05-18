"""
Bank Reconciliation Automation
Tools: Python + Pandas + CSV/Excel-compatible outputs

What this script does:
1. Reads bank statement and ERP transaction files
2. Standardizes amount signs and reference numbers
3. Matches bank vs ERP transactions by reference number and amount
4. Detects unmatched bank entries, unmatched ERP entries, duplicate bank entries, and timing differences
5. Exports exception report, summary report, and reconciled transaction list
"""

from pathlib import Path
import pandas as pd
import numpy as np

BASE_DIR = Path(__file__).resolve().parents[1]
DATA_DIR = BASE_DIR / "data"
OUTPUT_DIR = BASE_DIR / "outputs"
OUTPUT_DIR.mkdir(exist_ok=True)

DATE_TOLERANCE_DAYS = 1


def load_data():
    bank = pd.read_csv(DATA_DIR / "bank_statement.csv", parse_dates=["transaction_date"])
    erp = pd.read_csv(DATA_DIR / "erp_transactions.csv", parse_dates=["transaction_date"])
    return bank, erp


def prepare_data(bank: pd.DataFrame, erp: pd.DataFrame):
    bank = bank.copy()
    erp = erp.copy()

    bank["reference_no"] = bank["reference_no"].astype(str).str.upper().str.strip()
    erp["reference_no"] = erp["reference_no"].astype(str).str.upper().str.strip()

    bank["debit"] = bank["debit"].fillna(0).astype(float)
    bank["credit"] = bank["credit"].fillna(0).astype(float)
    erp["debit"] = erp["debit"].fillna(0).astype(float)
    erp["credit"] = erp["credit"].fillna(0).astype(float)

    # Positive amount = receipt/inflow, negative amount = payment/outflow
    bank["net_amount"] = bank["credit"] - bank["debit"]
    erp["net_amount"] = erp["credit"] - erp["debit"]

    return bank, erp


def reconcile(bank: pd.DataFrame, erp: pd.DataFrame):
    matched = bank.merge(
        erp,
        on=["reference_no", "net_amount"],
        how="inner",
        suffixes=("_bank", "_erp")
    )

    matched["date_difference_days"] = (
        matched["transaction_date_bank"] - matched["transaction_date_erp"]
    ).dt.days.abs()

    matched["match_status"] = np.where(
        matched["date_difference_days"] <= DATE_TOLERANCE_DAYS,
        "MATCHED",
        "MATCHED_WITH_TIMING_DIFFERENCE"
    )

    matched_report = matched[[
        "bank_txn_id", "erp_txn_id", "reference_no", "net_amount",
        "transaction_date_bank", "transaction_date_erp", "date_difference_days", "match_status"
    ]]

    matched_bank_ids = set(matched_report["bank_txn_id"])
    matched_erp_ids = set(matched_report["erp_txn_id"])

    unmatched_bank = bank[~bank["bank_txn_id"].isin(matched_bank_ids)].copy()
    unmatched_bank["match_status"] = "BANK_NOT_IN_ERP"
    unmatched_bank["exception_reason"] = "Bank transaction not found in ERP"

    unmatched_erp = erp[~erp["erp_txn_id"].isin(matched_erp_ids)].copy()
    unmatched_erp["match_status"] = "ERP_NOT_IN_BANK"
    unmatched_erp["exception_reason"] = "ERP transaction not found in bank statement"

    duplicate_bank = bank.groupby(["reference_no", "net_amount"], as_index=False).agg(
        duplicate_count=("bank_txn_id", "count"),
        bank_transaction_ids=("bank_txn_id", lambda x: ", ".join(x)),
        total_amount=("net_amount", "sum")
    )
    duplicate_bank = duplicate_bank[duplicate_bank["duplicate_count"] > 1]

    summary = pd.DataFrame({
        "metric": [
            "Bank transactions",
            "ERP transactions",
            "Matched transactions",
            "Timing differences",
            "Bank not in ERP",
            "ERP not in bank",
            "Duplicate bank groups",
        ],
        "count": [
            len(bank),
            len(erp),
            (matched_report["match_status"] == "MATCHED").sum(),
            (matched_report["match_status"] == "MATCHED_WITH_TIMING_DIFFERENCE").sum(),
            len(unmatched_bank),
            len(unmatched_erp),
            len(duplicate_bank),
        ]
    })

    return matched_report, unmatched_bank, unmatched_erp, duplicate_bank, summary


def export_reports(matched_report, unmatched_bank, unmatched_erp, duplicate_bank, summary):
    matched_report.to_csv(OUTPUT_DIR / "matched_transactions.csv", index=False)
    unmatched_bank.to_csv(OUTPUT_DIR / "unmatched_bank_transactions.csv", index=False)
    unmatched_erp.to_csv(OUTPUT_DIR / "unmatched_erp_transactions.csv", index=False)
    duplicate_bank.to_csv(OUTPUT_DIR / "duplicate_bank_transactions.csv", index=False)
    summary.to_csv(OUTPUT_DIR / "reconciliation_summary.csv", index=False)

    with pd.ExcelWriter(OUTPUT_DIR / "bank_reconciliation_report.xlsx", engine="openpyxl") as writer:
        summary.to_excel(writer, sheet_name="Summary", index=False)
        matched_report.to_excel(writer, sheet_name="Matched", index=False)
        unmatched_bank.to_excel(writer, sheet_name="Bank_Not_In_ERP", index=False)
        unmatched_erp.to_excel(writer, sheet_name="ERP_Not_In_Bank", index=False)
        duplicate_bank.to_excel(writer, sheet_name="Duplicates", index=False)

    print("Reports generated in:", OUTPUT_DIR)


def main():
    bank, erp = load_data()
    bank, erp = prepare_data(bank, erp)
    matched_report, unmatched_bank, unmatched_erp, duplicate_bank, summary = reconcile(bank, erp)
    export_reports(matched_report, unmatched_bank, unmatched_erp, duplicate_bank, summary)

    print("\nReconciliation Summary")
    print(summary.to_string(index=False))


if __name__ == "__main__":
    main()
