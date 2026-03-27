-- Script to populate fourth statement for account ending in 3401
-- Period: September 8, 2025 - October 7, 2025

DO $$
DECLARE
    v_card_id INTEGER;
    v_cat_payment_id INTEGER;
    v_cat_groceries_id INTEGER;
    v_cat_dining_id INTEGER;
    v_cat_transport_id INTEGER;
    v_cat_travel_id INTEGER;
    v_cat_shopping_id INTEGER;
    v_cat_entertainment_id INTEGER;
    v_cat_subscription_id INTEGER;
    v_cat_health_id INTEGER;
    v_cat_utilities_id INTEGER;
BEGIN
    -- Ensure the credit card exists
    INSERT INTO finance.credit_card (name, bank_name, last_four, credit_limit, interest_rate_apr, statement_day_of_month, grace_period_days)
    VALUES ('Oleksii Kuzko', 'Unknown Bank', '3401', 5000.00, 19.99, 7, 25)
    ON CONFLICT DO NOTHING;

    SELECT id INTO v_card_id FROM finance.credit_card WHERE last_four = '3401';

    -- Get category IDs
    SELECT id INTO v_cat_payment_id FROM finance.category WHERE name = 'Payment';
    SELECT id INTO v_cat_groceries_id FROM finance.category WHERE name = 'Groceries';
    SELECT id INTO v_cat_dining_id FROM finance.category WHERE name = 'Dining Out';
    SELECT id INTO v_cat_transport_id FROM finance.category WHERE name = 'Transportation';
    SELECT id INTO v_cat_travel_id FROM finance.category WHERE name = 'Travel';
    SELECT id INTO v_cat_shopping_id FROM finance.category WHERE name = 'Shopping';
    SELECT id INTO v_cat_entertainment_id FROM finance.category WHERE name = 'Entertainment';
    SELECT id INTO v_cat_subscription_id FROM finance.category WHERE name = 'Subscription';
    SELECT id INTO v_cat_health_id FROM finance.category WHERE name = 'Health';
    SELECT id INTO v_cat_utilities_id FROM finance.category WHERE name = 'Utilities';

    -- Payments and Other Credits
    INSERT INTO finance.transaction (card_id, category_id, transaction_date, post_date, amount, description) VALUES
    (v_card_id, v_cat_payment_id, '2025-09-30', '2025-09-30', 352.32, 'PAYMENT - THANK YOU'),
    (v_card_id, v_cat_payment_id, '2025-10-07', '2025-10-07', 31.44, 'PAYMENT - THANK YOU');

    -- Purchases and Adjustments
    INSERT INTO finance.transaction (card_id, category_id, transaction_date, post_date, amount, description) VALUES
    (v_card_id, v_cat_health_id, '2025-09-06', '2025-09-08', -75.00, 'NEWSTAR DENTAL FORT LAUDERDAFL'),
    (v_card_id, v_cat_health_id, '2025-09-06', '2025-09-08', -19.00, 'NEWSTAR DENTAL FORT LAUDERDAFL'),
    (v_card_id, v_cat_health_id, '2025-09-11', '2025-09-12', -215.00, 'NEWSTAR DENTAL FORT LAUDERDAFL'),
    (v_card_id, v_cat_health_id, '2025-09-11', '2025-09-12', -20.00, 'NEWSTAR DENTAL FORT LAUDERDAFL'),
    (v_card_id, v_cat_shopping_id, '2025-09-18', '2025-09-19', -14.97, 'eBay O*20-13580-44168 800-4563229 CA'),
    (v_card_id, v_cat_transport_id, '2025-09-27', '2025-09-29', -8.35, 'COH PRKING PAY BY PHONE www.parkmobilFL'),
    (v_card_id, v_cat_dining_id, '2025-10-03', '2025-10-04', -31.44, 'TST* FRITZ & FRANZ BIERHACORAL GABLES FL'),
    (v_card_id, v_cat_travel_id, '2025-10-05', '2025-10-07', -431.60, 'ALASKA AIR 0272119359112SEATTLE WA'),
    (v_card_id, v_cat_travel_id, '2025-10-05', '2025-10-07', -431.60, 'ALASKA AIR 0272119359113SEATTLE WA'),
    (v_card_id, v_cat_travel_id, '2025-10-05', '2025-10-07', -431.60, 'ALASKA AIR 0272119359114SEATTLE WA');

    -- Statement Summary
    -- Total Purchases: $1,678.56
    -- Total Payments: $383.76
    -- Calculated Balance: $1,678.56 - $383.76 = $1,294.80
    INSERT INTO finance.statement (card_id, statement_date, due_date, statement_balance, minimum_payment, paid_amount, is_fully_paid)
    VALUES (v_card_id, '2025-10-07', '2025-11-01', 1294.80, 25.00, 0, FALSE);

END $$;
