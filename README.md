# ICT371 Q3 - Library Returns and Overdue Fines

**Student:** Steven Miti (202405283)  
**DBMS:** PostgreSQL 13+ with the pg_cron extension

## How to run
Use a fresh database for this question (several questions share table names such as `students`):

```bash
createdb ict371_q03
psql -d ict371_q03 -f run_all.sql
```

Files run in order: schema, function, procedure, trigger, view, index, scheduled job, data load, tests.
The data load (`08_load_data.sql`) runs after the trigger/procedure exist, as the question requires.

| Part | File |
|------|------|
| (a) Tables + seed data | `01_schema_seed.sql`, `08_load_data.sql` |
| (b) Function | `02_function.sql` |
| (c) Procedure | `03_procedure.sql` |
| (d) Trigger | `04_trigger.sql` |
| (e) View | `05_view.sql` |
| (f) Index + EXPLAIN | `06_index.sql` |
| (g) Scheduled job | `07_scheduled_job.sql` |
| Demonstration queries | `09_tests.sql` |

## Index
`idx_loans_book_unreturned ON loans (book_id) WHERE returned_on IS NULL (partial index)`

The search is 'unreturned loans for one book'. A partial index stores only open loans, so it stays small as returned loans pile up, and it matches the query's book_id = ? AND returned_on IS NULL exactly.

## Design notes
- Returned loan: fine is calculated up to the earlier of p_as_of and returned_on.
- pr_refresh_overdue counts loans that were still out on the given date AND already past due (fine > 0 possible). Loans out but not yet due are not 'overdue'. If your lecturer wants every unreturned loan counted, remove the due_on < p_as_of line in 07_scheduled_job.sql.
- Seed dates are relative to CURRENT_DATE so the open loans stay overdue whenever you run it.

## Output
_Paste screenshots / output of `09_tests.sql` and the `EXPLAIN` plan here._
