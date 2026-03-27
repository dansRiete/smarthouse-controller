-- Script to add latest payment for Capital One card 6487
-- Data source: 2026-02-01_transaction_download(2).csv

DO $$
DECLARE
    v_card_id INTEGER;
    v_cat_payment_id INTEGER;
BEGIN
    -- Ensure Capital One card exists
    SELECT id INTO v_card_id FROM finance.credit_card WHERE last_four = '6487';

    -- Get category ID
    SELECT id INTO v_cat_payment_id FROM finance.category WHERE name = 'Payment';

    -- Insert the new transaction
    -- 2026-01-10,2026-01-10,6487,CAPITAL ONE MOBILE PYMT,Payment/Credit,,64.20
    INSERT INTO finance.transaction (card_id, category_id, transaction_date, post_date, amount, description)
    VALUES (v_card_id, v_cat_payment_id, '2026-01-10', '2026-01-10', 64.20, 'CAPITAL ONE MOBILE PYMT');

    -- Update the previous statement to reflect this payment
    -- The statement on 2025-12-15 had a balance of $64.20
    UPDATE finance.statement
    SET paid_amount = paid_amount + 64.20,
        is_fully_paid = TRUE
    WHERE card_id = v_card_id 
      AND statement_date = '2025-12-15';

END $$;
