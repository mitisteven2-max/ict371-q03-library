-- ICT371 Q3 (a): six loans (dates relative to today so the data stays meaningful)
INSERT INTO loans (book_id, borrower_name, borrowed_on, due_on) VALUES
    (1, 'Chanda Mwila',      CURRENT_DATE - 30, CURRENT_DATE - 16),  -- 1 open, overdue
    (2, 'Mutinta Hamusonde', CURRENT_DATE -  3, CURRENT_DATE + 11),  -- 2 open, on time
    (3, 'Bwalya Tembo',      CURRENT_DATE - 40, CURRENT_DATE - 26),  -- 3 returned late
    (1, 'Namukolo Sakala',   CURRENT_DATE - 25, CURRENT_DATE - 11),  -- 4 returned ON due date
    (2, 'Kelvin Zulu',       CURRENT_DATE - 15, CURRENT_DATE -  1),  -- 5 open, overdue
    (3, 'Lubuto Phiri',      CURRENT_DATE - 10, CURRENT_DATE +  4);  -- 6 returned early

-- Returns go through the procedure so the fine is stored with the date
CALL pr_return_loan(3, CURRENT_DATE - 20);   -- 6 days late  => K12
CALL pr_return_loan(4, CURRENT_DATE - 11);   -- on due date  => K0
CALL pr_return_loan(6, CURRENT_DATE -  5);   -- early        => K0
