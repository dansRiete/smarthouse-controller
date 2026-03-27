-- Script to populate statement for account ending in 9573 (Card ID 3)
-- Period: February 18 - March 17, 2025
-- Based on the provided transaction list

DO $$
DECLARE
    v_card_id INTEGER;
    v_cat_transport_id INTEGER;
    v_cat_other_id INTEGER;
    v_cat_subscription_id INTEGER;
BEGIN
    -- Ensure the credit card exists
    INSERT INTO finance.credit_card (name, bank_name, last_four, credit_limit, interest_rate_apr, statement_day_of_month, grace_period_days)
    VALUES ('Oleksii Kuzko', 'Unknown Bank', '9573', 5000.00, 19.99, 17, 25)
    ON CONFLICT DO NOTHING;

    SELECT id INTO v_card_id FROM finance.credit_card WHERE last_four = '9573';

    -- Ensure categories exist
    INSERT INTO finance.category (name) VALUES ('Transportation'), ('Other'), ('Subscription') ON CONFLICT DO NOTHING;

    -- Get category IDs
    SELECT id INTO v_cat_transport_id FROM finance.category WHERE name = 'Transportation';
    SELECT id INTO v_cat_other_id FROM finance.category WHERE name = 'Other';
    SELECT id INTO v_cat_subscription_id FROM finance.category WHERE name = 'Subscription';

    -- Purchases and Adjustments
    -- 02/21 02/22 Nyx*NAYAX VENDING 34 HUNT VALLEY MD 6629 9573 7.00
    -- 02/22 02/24 BANYAN BAY MARINE clover.com FL 1184 9573 297.00
    -- 03/09 03/10 SXM SIRIUSXM.COM/ACCT SIRIUSXM.COM NY 7592 9573 11.31
    INSERT INTO finance.transaction (card_id, category_id, transaction_date, post_date, amount, description) VALUES
    (v_card_id, v_cat_transport_id, '2025-02-21', '2025-02-22', -7.00, 'Nyx*NAYAX VENDING 34 HUNT VALLEY MD'),
    (v_card_id, v_cat_other_id, '2025-02-22', '2025-02-24', -297.00, 'BANYAN BAY MARINE clover.com FL'),
    (v_card_id, v_cat_subscription_id, '2025-03-09', '2025-03-10', -11.31, 'SXM SIRIUSXM.COM/ACCT SIRIUSXM.COM NY');

    -- Statement Summary
    -- Total Purchases: $315.31
    -- Total Payments: $0.00
    -- Statement Balance: $193.86 (calculated backwards from April statement)
    -- Purchases 315.31. If it was fully paid before, balance would be 315.31.
    -- But April statement suggested a starting balance of 193.86.
    -- 121.45 (payment on 04/21) + 770.73 (payment on 04/30) = 892.18.
    -- Wait, April statement payments: 668.27 + 11.04 = 679.31.
    -- If 679.31 was paid in April, and purchases were 485.45, then 679.31 - 485.45 = 193.86 was the previous balance.
    INSERT INTO finance.statement (card_id, statement_date, due_date, statement_balance, minimum_payment, paid_amount, is_fully_paid)
    VALUES (v_card_id, '2025-03-17', '2025-04-11', 193.86, 25.00, 0, FALSE)
    ON CONFLICT (card_id, statement_date) DO UPDATE 
    SET statement_balance = EXCLUDED.statement_balance,
        paid_amount = EXCLUDED.paid_amount,
        is_fully_paid = EXCLUDED.is_fully_paid;

END $$;
