-- (b) fines as of today: loan 1 = 16 days x K2 = 32; loan 3 stops at return (12); loan 4 = 0
SELECT loan_id, fn_fine, stored FROM (
  SELECT loan_id, fn_loan_fine(loan_id, CURRENT_DATE) AS fn_fine, fine_amount AS stored
  FROM loans) t ORDER BY loan_id;
DO $$ BEGIN PERFORM fn_loan_fine(999, CURRENT_DATE);
EXCEPTION WHEN OTHERS THEN RAISE NOTICE 'Rejected: %', SQLERRM; END $$;

-- (e) overdue view BEFORE returning loan 1
SELECT * FROM v_overdue_loans ORDER BY loan_id;

-- (c) rejections
DO $$ BEGIN CALL pr_return_loan(999, CURRENT_DATE);
EXCEPTION WHEN OTHERS THEN RAISE NOTICE 'Rejected: %', SQLERRM; END $$;
DO $$ BEGIN CALL pr_return_loan(3, CURRENT_DATE);               -- already returned
EXCEPTION WHEN OTHERS THEN RAISE NOTICE 'Rejected: %', SQLERRM; END $$;
DO $$ BEGIN CALL pr_return_loan(1, CURRENT_DATE - 100);         -- before borrowed_on
EXCEPTION WHEN OTHERS THEN RAISE NOTICE 'Rejected: %', SQLERRM; END $$;

-- (g) snapshot twice: same row, replaced
CALL pr_refresh_overdue(CURRENT_DATE);
CALL pr_refresh_overdue(CURRENT_DATE);
SELECT * FROM overdue_summary;

-- (c)+(d) valid return: date and fine saved together, one audit row
CALL pr_return_loan(1, CURRENT_DATE);
SELECT loan_id, returned_on, fine_amount FROM loans WHERE loan_id = 1;   -- fine 32
UPDATE loans SET returned_on = returned_on WHERE loan_id = 3;            -- unchanged: no audit
SELECT * FROM loan_audit ORDER BY audit_id;                              -- 4 rows (3 seed + 1)

-- (f) EXPLAIN again now that the tables contain data
ANALYZE loans;
SET enable_seqscan = off;   -- tiny table: force the planner to show the index

EXPLAIN
SELECT loan_id, borrower_name, due_on
FROM loans
WHERE book_id = 1
  AND returned_on IS NULL;

RESET enable_seqscan;
