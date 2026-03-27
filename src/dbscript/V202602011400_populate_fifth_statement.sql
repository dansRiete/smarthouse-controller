-- Script to populate statement for NEW account ending in 9573
-- Period: December 18, 2025 - January 17, 2026

DO $$
DECLARE
    v_card_id INTEGER;
    v_cat_payment_id INTEGER;
    v_cat_transport_id INTEGER;
    v_cat_entertainment_id INTEGER;
    v_cat_dining_id INTEGER;
BEGIN
    -- Ensure the NEW credit card exists (account ending in 9573)
    INSERT INTO finance.credit_card (name, bank_name, last_four, credit_limit, interest_rate_apr, statement_day_of_month, grace_period_days)
    VALUES ('Oleksii Kuzko', 'Unknown Bank', '9573', 5000.00, 19.99, 17, 25)
    ON CONFLICT DO NOTHING;

    SELECT id INTO v_card_id FROM finance.credit_card WHERE last_four = '9573';

    -- Get category IDs
    SELECT id INTO v_cat_payment_id FROM finance.category WHERE name = 'Payment';
    SELECT id INTO v_cat_transport_id FROM finance.category WHERE name = 'Transportation';
    SELECT id INTO v_cat_entertainment_id FROM finance.category WHERE name = 'Entertainment';
    SELECT id INTO v_cat_dining_id FROM finance.category WHERE name = 'Dining Out';

    -- Payments and Other Credits
    INSERT INTO finance.transaction (card_id, category_id, transaction_date, post_date, amount, description) VALUES
    (v_card_id, v_cat_payment_id, '2026-01-04', '2026-01-05', 38.00, 'PAYMENT - THANK YOU');

    -- Purchases and Adjustments
    INSERT INTO finance.transaction (card_id, category_id, transaction_date, post_date, amount, description) VALUES
    (v_card_id, v_cat_transport_id, '2025-12-27', '2025-12-29', -111.98, 'UBER *TRIP HELP.UBER.COMCA'),
    (v_card_id, v_cat_entertainment_id, '2025-12-30', '2025-12-31', -131.76, 'WHITE PASS CO, INC NACHES WA'),
    (v_card_id, v_cat_transport_id, '2026-01-04', '2026-01-05', -29.20, 'UBER *TRIP HELP.UBER.COMCA');

    -- Statement Summary
    -- Total Purchases: $272.94
    -- Total Payments: $38.00
    -- Statement Balance: $272.94 - $38.00 = $234.94
    INSERT INTO finance.statement (card_id, statement_date, due_date, statement_balance, minimum_payment, paid_amount, is_fully_paid)
    VALUES (v_card_id, '2026-01-17', '2026-02-11', 234.94, 25.00, 0, FALSE);

END $$;
