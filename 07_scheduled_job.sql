-- ICT371 Q3 (g): pr_refresh_overdue + pg_cron
-- A loan counts when it is unreturned as of p_as_of and already past its due date.
CREATE OR REPLACE PROCEDURE pr_refresh_overdue(p_as_of DATE)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_as_of IS NULL THEN
        RAISE EXCEPTION 'p_as_of is required';
    END IF;

    INSERT INTO overdue_summary (snapshot_date, overdue_count, total_fine)
    SELECT p_as_of,
           COUNT(*),
           COALESCE(SUM(fn_loan_fine(loan_id, p_as_of)), 0)
    FROM loans
    WHERE (returned_on IS NULL OR returned_on > p_as_of)   -- still out on that date
      AND borrowed_on <= p_as_of
      AND due_on < p_as_of
    ON CONFLICT (snapshot_date) DO UPDATE
    SET overdue_count = EXCLUDED.overdue_count,
        total_fine    = EXCLUDED.total_fine;
END;
$$;

CREATE EXTENSION IF NOT EXISTS pg_cron;

-- Daily at 00:10 for today
SELECT cron.schedule(
    'q03_overdue_daily',
    '10 0 * * *',
    $$CALL pr_refresh_overdue(CURRENT_DATE)$$
);

-- Inspect:
-- SELECT jobid, jobname, schedule, command FROM cron.job;
-- SELECT * FROM cron.job_run_details ORDER BY start_time DESC LIMIT 5;
