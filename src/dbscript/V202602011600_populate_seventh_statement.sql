-- Script to populate statement for account ending in 9573
-- Period: October 18 - November 17, 2025

DO $$
DECLARE
    v_card_id INTEGER;
    v_cat_payment_id INTEGER;
    v_cat_shopping_id INTEGER;
    v_cat_dining_id INTEGER;
BEGIN
    -- Ensure the credit card exists (account ending in 9573)
    INSERT INTO finance.credit_card (name, bank_name, last_four, credit_limit, interest_rate_apr, statement_day_of_month, grace_period_days)
    VALUES ('Oleksii Kuzko', 'Unknown Bank', '9573', 5000.00, 19.99, 17, 25)
    ON CONFLICT DO NOTHING;

    SELECT id INTO v_card_id FROM finance.credit_card WHERE last_four = '9573';

    -- Get category IDs
    SELECT id INTO v_cat_payment_id FROM finance.category WHERE name = 'Payment';
    SELECT id INTO v_cat_shopping_id FROM finance.category WHERE name = 'Shopping';
    SELECT id INTO v_cat_dining_id FROM finance.category WHERE name = 'Dining Out';

    -- Payments and Other Credits
    INSERT INTO finance.transaction (card_id, category_id, transaction_date, post_date, amount, description) VALUES
    (v_card_id, v_cat_payment_id, '2025-11-14', '2025-11-14', 107.68, 'PAYMENT - THANK YOU 1234');

    -- Purchases and Adjustments
    INSERT INTO finance.transaction (card_id, category_id, transaction_date, post_date, amount, description) VALUES
    (v_card_id, v_cat_shopping_id, '2025-11-04', '2025-11-06', -4.55, 'THE HOME DEPOT #6310 HOLLYWOOD FL'),
    (v_card_id, v_cat_dining_id, '2025-11-08', '2025-11-10', -103.13, 'HOLLYWOOD BREWERY HOLLYWOOD FL');

    -- Statement Summary
    -- Total Purchases: $107.68
    -- Total Payments: $107.68
    -- Statement Balance: $107.68 - $107.68 = $0.00
    INSERT INTO finance.statement (card_id, statement_date, due_date, statement_balance, minimum_payment, paid_amount, is_fully_paid)
    VALUES (v_card_id, '2025-11-17', '2025-12-12', 0.00, 0.00, 107.68, TRUE);

END $$;
