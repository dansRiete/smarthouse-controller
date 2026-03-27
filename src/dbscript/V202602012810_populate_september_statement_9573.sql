-- Script to populate statement for account ending in 9573 (Card ID 3)
-- Period: August 18 - September 17, 2025
-- Based on the provided transaction list

DO $$
DECLARE
    v_card_id INTEGER;
    v_cat_shopping_id INTEGER;
BEGIN
    -- Ensure the credit card exists
    INSERT INTO finance.credit_card (name, bank_name, last_four, credit_limit, interest_rate_apr, statement_day_of_month, grace_period_days)
    VALUES ('Oleksii Kuzko', 'Unknown Bank', '9573', 5000.00, 19.99, 17, 25)
    ON CONFLICT DO NOTHING;

    SELECT id INTO v_card_id FROM finance.credit_card WHERE last_four = '9573';

    -- Get category IDs
    SELECT id INTO v_cat_shopping_id FROM finance.category WHERE name = 'Shopping';

    -- Purchases and Adjustments
    -- 09/14 09/15 BESTBUYCOM807086872460 888BESTBUY MN 0765 9573 588.49
    INSERT INTO finance.transaction (card_id, category_id, transaction_date, post_date, amount, description) VALUES
    (v_card_id, v_cat_shopping_id, '2025-09-14', '2025-09-15', -588.49, 'BESTBUYCOM807086872460 888BESTBUY MN');

    -- Statement Summary
    -- Total Purchases: $588.49
    -- Total Payments: $0.00
    -- Statement Balance: $588.49
    INSERT INTO finance.statement (card_id, statement_date, due_date, statement_balance, minimum_payment, paid_amount, is_fully_paid)
    VALUES (v_card_id, '2025-09-17', '2025-10-12', 588.49, 25.00, 0, FALSE)
    ON CONFLICT (card_id, statement_date) DO UPDATE 
    SET statement_balance = EXCLUDED.statement_balance,
        paid_amount = EXCLUDED.paid_amount,
        is_fully_paid = EXCLUDED.is_fully_paid;

END $$;
