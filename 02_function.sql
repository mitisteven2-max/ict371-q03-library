-- ICT371 Q3 (b): fn_loan_fine  (K2 per day after the due date)
CREATE OR REPLACE FUNCTION fn_loan_fine(p_loan_id INTEGER, p_as_of DATE)
RETURNS NUMERIC
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_due      DATE;
    v_returned DATE;
    v_end      DATE;
BEGIN
    IF p_as_of IS NULL THEN
        RAISE EXCEPTION 'p_as_of is required';
    END IF;

    SELECT due_on, returned_on INTO v_due, v_returned
    FROM loans WHERE loan_id = p_loan_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Unknown loan_id: %', p_loan_id;
    END IF;

    -- Fines stop at the return date: use the earlier of the two dates
    v_end := LEAST(p_as_of, COALESCE(v_returned, p_as_of));

    -- Returned on the due date (or earlier) => 0 overdue days => no fine
    RETURN 2.00 * GREATEST(v_end - v_due, 0);
END;
$$;
