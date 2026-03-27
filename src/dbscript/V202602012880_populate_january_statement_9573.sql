-- Script to populate statement for account ending in 9573 (Card ID 3)
-- Period: December 18, 2024 - January 17, 2025
-- Based on the provided transaction list

DO $$
DECLARE
    v_card_id INTEGER;
    v_cat_payment_id INTEGER;
    v_cat_other_id INTEGER;
    v_cat_transport_id INTEGER;
    v_cat_entertainment_id INTEGER;
BEGIN
    -- Ensure the credit card exists
    INSERT INTO finance.credit_card (name, bank_name, last_four, credit_limit, interest_rate_apr, statement_day_of_month, grace_period_days)
    VALUES ('Oleksii Kuzko', 'Unknown Bank', '9573', 5000.00, 19.99, 17, 25)
    ON CONFLICT DO NOTHING;

    SELECT id INTO v_card_id FROM finance.credit_card WHERE last_four = '9573';

    -- Ensure categories exist
    INSERT INTO finance.category (name) VALUES ('Other'), ('Transportation'), ('Entertainment') ON CONFLICT DO NOTHING;

    -- Get category IDs
    SELECT id INTO v_cat_payment_id FROM finance.category WHERE name = 'Payment';
    SELECT id INTO v_cat_other_id FROM finance.category WHERE name = 'Other';
    SELECT id INTO v_cat_transport_id FROM finance.category WHERE name = 'Transportation';
    SELECT id INTO v_cat_entertainment_id FROM finance.category WHERE name = 'Entertainment';

    -- Payments and Other Credits
    -- 01/08 01/10 BA ELECTRONIC PAYMENT 4903 9573 -491.28
    -- 01/10 01/10 PAYMENT - THANK YOU 0969 9573 -35.00
    -- 01/11 01/11 PAYMENT - THANK YOU 0981 9573 -22.47
    INSERT INTO finance.transaction (card_id, category_id, transaction_date, post_date, amount, description) VALUES
    (v_card_id, v_cat_payment_id, '2025-01-08', '2025-01-10', 491.28, 'BA ELECTRONIC PAYMENT'),
    (v_card_id, v_cat_payment_id, '2025-01-10', '2025-01-10', 35.00, 'PAYMENT - THANK YOU'),
    (v_card_id, v_cat_payment_id, '2025-01-11', '2025-01-11', 22.47, 'PAYMENT - THANK YOU');

    -- Purchases and Adjustments
    -- 12/22 12/23 BANYAN BAY MARINE clover.com FL 5718 9573 297.00
    -- 12/25 12/26 UBER *TRIP HELP.UBER.COMCA 5131 9573 45.77
    -- 12/26 12/26 YYZ Sweet Maple Mississauga ON 30.48 CAD 8058 9573 21.25
    -- 12/26 12/26 UBER *TRIP HELP.UBER.COMCA 3979 9573 8.24
    -- 12/27 12/28 Nintendo CA1326950212 800-2553700 WA 2049 9573 5.29
    -- 12/31 01/02 Nintendo CA1331005071 800-2553700 WA 6021 9573 9.99
    -- 01/03 01/04 Nintendo CA1333726961 800-2553700 WA 5097 9573 3.99
    -- 01/05 01/06 Nintendo CD1335610524 800-2553700 WA 6077 9573 3.99
    -- 01/08 01/09 UBER *TRIP HELP.UBER.COMCA 4738 9573 47.89
    -- 01/08 01/09 UBER *TRIP HELP.UBER.COMCA 7312 9573 9.58
    INSERT INTO finance.transaction (card_id, category_id, transaction_date, post_date, amount, description) VALUES
    (v_card_id, v_cat_other_id, '2024-12-22', '2024-12-23', -297.00, 'BANYAN BAY MARINE clover.com FL'),
    (v_card_id, v_cat_transport_id, '2024-12-25', '2024-12-26', -45.77, 'UBER *TRIP HELP.UBER.COMCA'),
    (v_card_id, v_cat_other_id, '2024-12-26', '2024-12-26', -21.25, 'YYZ Sweet Maple Mississauga ON'),
    (v_card_id, v_cat_transport_id, '2024-12-26', '2024-12-26', -8.24, 'UBER *TRIP HELP.UBER.COMCA'),
    (v_card_id, v_cat_entertainment_id, '2024-12-27', '2024-12-28', -5.29, 'Nintendo CA1326950212 800-2553700 WA'),
    (v_card_id, v_cat_entertainment_id, '2024-12-31', '2025-01-02', -9.99, 'Nintendo CA1331005071 800-2553700 WA'),
    (v_card_id, v_cat_entertainment_id, '2025-01-03', '2025-01-04', -3.99, 'Nintendo CA1333726961 800-2553700 WA'),
    (v_card_id, v_cat_entertainment_id, '2025-01-05', '2025-01-06', -3.99, 'Nintendo CD1335610524 800-2553700 WA'),
    (v_card_id, v_cat_transport_id, '2025-01-08', '2025-01-09', -47.89, 'UBER *TRIP HELP.UBER.COMCA'),
    (v_card_id, v_cat_transport_id, '2025-01-08', '2025-01-09', -9.58, 'UBER *TRIP HELP.UBER.COMCA');

    -- Statement Summary
    -- Total Purchases: $452.99
    -- Total Payments: $548.75
    -- Balance: 95.76 + 452.99 - 548.75 = 0
    -- So previous balance was likely 95.76.
    INSERT INTO finance.statement (card_id, statement_date, due_date, statement_balance, minimum_payment, paid_amount, is_fully_paid)
    VALUES (v_card_id, '2025-01-17', '2025-02-11', 0.00, 0.00, 548.75, TRUE)
    ON CONFLICT (card_id, statement_date) DO UPDATE 
    SET statement_balance = EXCLUDED.statement_balance,
        paid_amount = EXCLUDED.paid_amount,
        is_fully_paid = EXCLUDED.is_fully_paid;

END $$;
