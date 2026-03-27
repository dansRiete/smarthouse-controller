-- Script to populate statement for account ending in 9573 (Card ID 3)
-- Period: January 18 - February 17, 2025
-- Based on the provided transaction list

DO $$
DECLARE
    v_card_id INTEGER;
    v_cat_payment_id INTEGER;
    v_cat_subscription_id INTEGER;
    v_cat_other_id INTEGER;
    v_cat_entertainment_id INTEGER;
BEGIN
    -- Ensure the credit card exists
    INSERT INTO finance.credit_card (name, bank_name, last_four, credit_limit, interest_rate_apr, statement_day_of_month, grace_period_days)
    VALUES ('Oleksii Kuzko', 'Unknown Bank', '9573', 5000.00, 19.99, 17, 25)
    ON CONFLICT DO NOTHING;

    SELECT id INTO v_card_id FROM finance.credit_card WHERE last_four = '9573';

    -- Ensure categories exist
    INSERT INTO finance.category (name) VALUES ('Subscription'), ('Other'), ('Entertainment') ON CONFLICT DO NOTHING;

    -- Get category IDs
    SELECT id INTO v_cat_payment_id FROM finance.category WHERE name = 'Payment';
    SELECT id INTO v_cat_subscription_id FROM finance.category WHERE name = 'Subscription';
    SELECT id INTO v_cat_other_id FROM finance.category WHERE name = 'Other';
    SELECT id INTO v_cat_entertainment_id FROM finance.category WHERE name = 'Entertainment';

    -- Payments and Other Credits
    -- 02/01 02/03 BA ELECTRONIC PAYMENT 8920 9573 -615.99
    INSERT INTO finance.transaction (card_id, category_id, transaction_date, post_date, amount, description) VALUES
    (v_card_id, v_cat_payment_id, '2025-02-01', '2025-02-03', 615.99, 'BA ELECTRONIC PAYMENT');

    -- Purchases and Adjustments
    -- 01/18 01/20 Amazon Prime*ZG2UM3UB2 Amzn.com/billWA 7200 9573 2.01
    -- 01/22 01/23 BANYAN BAY MARINE clover.com FL 5169 9573 297.00
    -- 01/23 01/24 BANYAN BAY MARINE clover.com FL 6442 9573 297.00
    -- 01/25 01/27 Nintendo CD1346145765 800-2553700 WA 2063 9573 7.99
    -- 01/26 01/27 WL *STEAM PURCHASE 425-889-9642 WA 3253 9573 11.99
    INSERT INTO finance.transaction (card_id, category_id, transaction_date, post_date, amount, description) VALUES
    (v_card_id, v_cat_subscription_id, '2025-01-18', '2025-01-20', -2.01, 'Amazon Prime*ZG2UM3UB2 Amzn.com/billWA'),
    (v_card_id, v_cat_other_id, '2025-01-22', '2025-01-23', -297.00, 'BANYAN BAY MARINE clover.com FL'),
    (v_card_id, v_cat_other_id, '2025-01-23', '2025-01-24', -297.00, 'BANYAN BAY MARINE clover.com FL'),
    (v_card_id, v_cat_entertainment_id, '2025-01-25', '2025-01-27', -7.99, 'Nintendo CD1346145765 800-2553700 WA'),
    (v_card_id, v_cat_entertainment_id, '2025-01-26', '2025-01-27', -11.99, 'WL *STEAM PURCHASE 425-889-9642 WA');

    -- Statement Summary
    -- Total Purchases: $615.99
    -- Total Payments: $615.99
    -- Statement Balance: $0.00
    INSERT INTO finance.statement (card_id, statement_date, due_date, statement_balance, minimum_payment, paid_amount, is_fully_paid)
    VALUES (v_card_id, '2025-02-17', '2025-03-14', 0.00, 0.00, 615.99, TRUE)
    ON CONFLICT (card_id, statement_date) DO UPDATE 
    SET statement_balance = EXCLUDED.statement_balance,
        paid_amount = EXCLUDED.paid_amount,
        is_fully_paid = EXCLUDED.is_fully_paid;

END $$;
