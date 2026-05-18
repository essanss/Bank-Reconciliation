# Excel Review Template Guide

After running `python/bank_reconciliation.py`, open `outputs/bank_reconciliation_report.xlsx`.

Recommended Excel sheets:

1. Summary
   - KPI counts for matched, unmatched, duplicates, and timing differences.

2. Matched
   - Transactions matched between bank and ERP.

3. Bank_Not_In_ERP
   - Items appearing in bank statement but missing in ERP.
   - Common reasons: bank charges, direct customer deposits, unposted receipts, bank errors.

4. ERP_Not_In_Bank
   - Items posted in ERP but not yet appearing in bank.
   - Common reasons: payment not cleared, receipt pending in bank, posting error.

5. Duplicates
   - Same reference number and amount appearing more than once in bank data.

Useful Excel formulas:

```excel
=COUNTIF(Summary[metric],"Bank not in ERP")
=SUMIFS(Bank_Not_In_ERP[net_amount],Bank_Not_In_ERP[match_status],"BANK_NOT_IN_ERP")
=IF([@date_difference_days]>1,"Timing Difference","Normal")
```