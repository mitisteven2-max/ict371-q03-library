-- ICT371 Q3 (f): partial index on unreturned loans, by book
CREATE INDEX IF NOT EXISTS idx_loans_book_unreturned
    ON loans (book_id)
    WHERE returned_on IS NULL;

ANALYZE loans;
SET enable_seqscan = off;   -- tiny table: force the planner to show the index

EXPLAIN
SELECT loan_id, borrower_name, due_on
FROM loans
WHERE book_id = 1
  AND returned_on IS NULL;

RESET enable_seqscan;
