-- Script to populate statement for account ending in 9573 (Card ID 3)
-- Period: June 18 - July 17, 2025
-- Based on the provided transaction list

DO $$
DECLARE
    v_card_id INTEGER;
    v_cat_payment_id INTEGER;
    v_cat_subscription_id INTEGER;
BEGIN
    -- Ensure the credit card exists
    INSERT INTO finance.credit_card (name, bank_name, last_four, credit_limit, interest_rate_apr, statement_day_of_month, grace_period_days)
    VALUES ('Oleksii Kuzko', 'Unknown Bank', '9573', 5000.00, 19.99, 17, 25)
    ON CONFLICT DO NOTHING;

    SELECT id INTO v_card_id FROM finance.credit_card WHERE last_four = '9573';

    -- Get category IDs
    SELECT id INTO v_cat_payment_id FROM finance.category WHERE name = 'Payment';
    SELECT id INTO v_cat_subscription_id FROM finance.category WHERE name = 'Subscription';

    -- Ensure category exists
    INSERT INTO finance.category (name) VALUES ('Subscription') ON CONFLICT DO NOTHING;
    SELECT id INTO v_cat_subscription_id FROM finance.category WHERE name = 'Subscription';

    -- Payments and Other Credits
    -- 06/26 06/26 PAYMENT - THANK YOU 1112 9573 -13.99
    INSERT INTO finance.transaction (card_id, category_id, transaction_date, post_date, amount, description) VALUES
    (v_card_id, v_cat_payment_id, '2025-06-26', '2025-06-26', 13.99, 'PAYMENT - THANK YOU');

    -- Purchases and Adjustments
    -- 06/20 06/20 AIRCRAFT & PILOT ASSN WWW.AOPA.ORG MD 1859 9573 13.99
    INSERT INTO finance.transaction (card_id, category_id, transaction_date, post_date, amount, description) VALUES
    (v_card_id, v_cat_subscription_id, '2025-06-20', '2025-06-20', -13.99, 'AIRCRAFT & PILOT ASSN WWW.AOPA.ORG MD');

    -- Statement Summary
    -- Total Purchases: $13.99
    -- Total Payments: $13.99
    -- Statement Balance: $0.00
    INSERT INTO finance.statement (card_id, statement_date, due_date, statement_balance, minimum_payment, paid_amount, is_fully_paid)
    VALUES (v_card_id, '2025-07-17', '2025-08-11', 0.00, 0.00, 13.99, TRUE)
    ON CONFLICT (card_id, statement_date) DO UPDATE 
    SET statement_balance = EXCLUDED.statement_balance,
        paid_amount = EXCLUDED.paid_amount,
        is_fully_paid = EXCLUDED.is_fully_paid;

END $$;
