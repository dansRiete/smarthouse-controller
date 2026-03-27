-- Script to populate statement for account ending in 9573 (Card ID 3)
-- Period: March 18 - April 17, 2025
-- Based on the provided transaction list

DO $$
DECLARE
    v_card_id INTEGER;
    v_cat_payment_id INTEGER;
    v_cat_other_id INTEGER;
    v_cat_dining_id INTEGER;
    v_cat_transport_id INTEGER;
    v_cat_subscription_id INTEGER;
BEGIN
    -- Ensure the credit card exists
    INSERT INTO finance.credit_card (name, bank_name, last_four, credit_limit, interest_rate_apr, statement_day_of_month, grace_period_days)
    VALUES ('Oleksii Kuzko', 'Unknown Bank', '9573', 5000.00, 19.99, 17, 25)
    ON CONFLICT DO NOTHING;

    SELECT id INTO v_card_id FROM finance.credit_card WHERE last_four = '9573';

    -- Ensure categories exist
    INSERT INTO finance.category (name) VALUES ('Other'), ('Dining Out'), ('Transportation'), ('Subscription') ON CONFLICT DO NOTHING;

    -- Get category IDs
    SELECT id INTO v_cat_payment_id FROM finance.category WHERE name = 'Payment';
    SELECT id INTO v_cat_other_id FROM finance.category WHERE name = 'Other';
    SELECT id INTO v_cat_dining_id FROM finance.category WHERE name = 'Dining Out';
    SELECT id INTO v_cat_transport_id FROM finance.category WHERE name = 'Transportation';
    SELECT id INTO v_cat_subscription_id FROM finance.category WHERE name = 'Subscription';

    -- Payments and Other Credits
    -- 04/01 04/01 PAYMENT - THANK YOU 0993 9573 -668.27
    -- 04/03 04/03 PAYMENT - THANK YOU 1005 9573 -11.04
    INSERT INTO finance.transaction (card_id, category_id, transaction_date, post_date, amount, description) VALUES
    (v_card_id, v_cat_payment_id, '2025-04-01', '2025-04-01', 668.27, 'PAYMENT - THANK YOU'),
    (v_card_id, v_cat_payment_id, '2025-04-03', '2025-04-03', 11.04, 'PAYMENT - THANK YOU');

    -- Purchases and Adjustments
    -- 03/22 03/24 BANYAN BAY MARINE clover.com FL 4057 9573 297.00
    -- 03/30 04/01 HOLLYWOOD BREWERY HOLLYWOOD FL 8098 9573 60.00
    -- 04/01 04/02 Nyx*NAYAX VENDING 34 HUNT VALLEY MD 3817 9573 7.00
    -- 04/09 04/09 SXM SIRIUSXM.COM/ACCT SIRIUSXM.COM NY 8713 9573 11.31
    -- 04/08 04/10 HOLLYWOOD BREWERY HOLLYWOOD FL 4257 9573 110.14
    INSERT INTO finance.transaction (card_id, category_id, transaction_date, post_date, amount, description) VALUES
    (v_card_id, v_cat_other_id, '2025-03-22', '2025-03-24', -297.00, 'BANYAN BAY MARINE clover.com FL'),
    (v_card_id, v_cat_dining_id, '2025-03-30', '2025-04-01', -60.00, 'HOLLYWOOD BREWERY HOLLYWOOD FL'),
    (v_card_id, v_cat_transport_id, '2025-04-01', '2025-04-02', -7.00, 'Nyx*NAYAX VENDING 34 HUNT VALLEY MD'),
    (v_card_id, v_cat_subscription_id, '2025-04-09', '2025-04-09', -11.31, 'SXM SIRIUSXM.COM/ACCT SIRIUSXM.COM NY'),
    (v_card_id, v_cat_dining_id, '2025-04-08', '2025-04-10', -110.14, 'HOLLYWOOD BREWERY HOLLYWOOD FL');

    -- Statement Summary
    -- Total Purchases: $485.45
    -- Total Payments: $679.31
    -- Balance: 193.86 + 485.45 - 679.31 = 0
    -- So previous balance was likely 193.86.
    INSERT INTO finance.statement (card_id, statement_date, due_date, statement_balance, minimum_payment, paid_amount, is_fully_paid)
    VALUES (v_card_id, '2025-04-17', '2025-05-12', 0.00, 0.00, 679.31, TRUE)
    ON CONFLICT (card_id, statement_date) DO UPDATE 
    SET statement_balance = EXCLUDED.statement_balance,
        paid_amount = EXCLUDED.paid_amount,
        is_fully_paid = EXCLUDED.is_fully_paid;

END $$;
