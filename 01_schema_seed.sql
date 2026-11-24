-- ICT371 Q3 (a): tables, constraints, books
DROP TABLE IF EXISTS overdue_summary, loan_audit, loans, books CASCADE;

CREATE TABLE books (
    book_id  SERIAL PRIMARY KEY,
    title    VARCHAR(150) NOT NULL
);

CREATE TABLE loans (
    loan_id        SERIAL PRIMARY KEY,
    book_id        INTEGER       NOT NULL REFERENCES books(book_id),
    borrower_name  VARCHAR(100)  NOT NULL,
    borrowed_on    DATE          NOT NULL,
    due_on         DATE          NOT NULL,
    returned_on    DATE,
    fine_amount    NUMERIC(10,2) NOT NULL DEFAULT 0 CHECK (fine_amount >= 0),
    CONSTRAINT ck_due_on_or_after_borrowed
        CHECK (due_on >= borrowed_on),
    CONSTRAINT ck_returned_not_before_borrowed
        CHECK (returned_on IS NULL OR returned_on >= borrowed_on)
);

CREATE TABLE loan_audit (
    audit_id          SERIAL PRIMARY KEY,
    loan_id           INTEGER   NOT NULL REFERENCES loans(loan_id),
    old_returned_on   DATE,
    new_returned_on   DATE,
    changed_at        TIMESTAMP NOT NULL DEFAULT now()
);

CREATE TABLE overdue_summary (
    snapshot_date  DATE PRIMARY KEY,
    overdue_count  INTEGER       NOT NULL CHECK (overdue_count >= 0),
    total_fine     NUMERIC(12,2) NOT NULL CHECK (total_fine >= 0)
);

INSERT INTO books (title) VALUES
    ('Things Fall Apart'),
    ('Introduction to Algorithms'),
    ('A Brief History of Zambia');
-- Loans are loaded in 08_load_data.sql (returns go through pr_return_loan)
