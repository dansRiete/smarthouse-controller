-- Script to populate statement for account ending in 9573
-- Period: November 18 - December 17, 2025

DO $$
DECLARE
    v_card_id INTEGER;
    v_cat_shopping_id INTEGER;
BEGIN
    -- Ensure the credit card exists (account ending in 9573)
    -- Using common parameters for this card as seen in previous scripts
    INSERT INTO finance.credit_card (name, bank_name, last_four, credit_limit, interest_rate_apr, statement_day_of_month, grace_period_days)
    VALUES ('Oleksii Kuzko', 'Unknown Bank', '9573', 5000.00, 19.99, 17, 25)
    ON CONFLICT DO NOTHING;

    SELECT id INTO v_card_id FROM finance.credit_card WHERE last_four = '9573';

    -- Get category IDs
    SELECT id INTO v_cat_shopping_id FROM finance.category WHERE name = 'Shopping';

    -- Purchases and Adjustments
    INSERT INTO finance.transaction (card_id, category_id, transaction_date, post_date, amount, description) VALUES
    (v_card_id, v_cat_shopping_id, '2025-11-28', '2025-12-01', -37.43, 'THE HOME DEPOT #6310 HOLLYWOOD FL');

    -- Statement Summary
    -- Total Purchases: $37.43
    -- Total Payments: $0.00
    -- Statement Balance: $37.43
    INSERT INTO finance.statement (card_id, statement_date, due_date, statement_balance, minimum_payment, paid_amount, is_fully_paid)
    VALUES (v_card_id, '2025-12-17', '2026-01-11', 37.43, 25.00, 0, FALSE);

END $$;
