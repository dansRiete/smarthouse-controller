-- Script to populate second statement for account ending in 3401
-- Period: November 8, 2025 - December 7, 2025

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
    (v_card_id, v_cat_payment_id, '2025-11-14', '2025-11-14', 353.49, 'PAYMENT - THANK YOU'),
    (v_card_id, v_cat_payment_id, '2025-11-24', '2025-11-24', 267.00, 'CASH REWARDS STATEMENT CREDIT'),
    (v_card_id, v_cat_payment_id, '2025-11-27', '2025-11-28', 386.31, 'PAYMENT - THANK YOU');

    -- Purchases and Adjustments
    INSERT INTO finance.transaction (card_id, category_id, transaction_date, post_date, amount, description) VALUES
    (v_card_id, v_cat_groceries_id, '2025-11-07', '2025-11-08', -93.24, 'TOTAL WINE & MORE 9 FT LAUDERDALEFL'),
    (v_card_id, v_cat_subscription_id, '2025-11-07', '2025-11-10', -10.00, 'JetBrains Americas INC 165-05772345 CA'),
    (v_card_id, v_cat_transport_id, '2025-11-08', '2025-11-10', -9.35, 'COH PRKING PAY BY PHONE 954-921-3266 FL'),
    (v_card_id, v_cat_transport_id, '2025-11-08', '2025-11-10', -4.85, 'COH PRKING PAY BY PHONE 954-921-3266 FL'),
    (v_card_id, v_cat_groceries_id, '2025-11-09', '2025-11-10', -43.96, 'NET COST MARKET HOLLYWOOD FL'),
    (v_card_id, v_cat_transport_id, '2025-11-15', '2025-11-17', -1.13, 'BLINK CHARGING CO 888-9982546 FL'),
    (v_card_id, v_cat_shopping_id, '2025-11-16', '2025-11-17', -97.50, 'GROUP ROSSIGNOL USA INC 435-2523344 UT'),
    (v_card_id, v_cat_groceries_id, '2025-11-16', '2025-11-17', -29.46, 'PUBLIX #1554 HOLLYWOOD FL'),
    (v_card_id, v_cat_transport_id, '2025-11-18', '2025-11-19', -2.35, 'COH PRKING PAY BY PHONE 954-921-3266 FL'),
    (v_card_id, v_cat_transport_id, '2025-11-18', '2025-11-20', -7.00, 'NAYAX WASH HUNT VALLEY MD'),
    (v_card_id, v_cat_shopping_id, '2025-11-20', '2025-11-20', -42.98, 'SP LONE PINE GEAR EX LONEPINEGEARXUT'),
    (v_card_id, v_cat_shopping_id, '2025-11-20', '2025-11-21', -115.56, 'SP ENGELBERT STRAUSS US.STRAUSS.COCA'),
    (v_card_id, v_cat_shopping_id, '2025-11-20', '2025-11-21', -5.34, 'MARSHALLS #1455 FORT LAUDERDAFL'),
    (v_card_id, v_cat_shopping_id, '2025-11-20', '2025-11-22', -5.35, 'FIVE BELOW 6055 FT. LAUDERDALFL'),
    (v_card_id, v_cat_entertainment_id, '2025-11-21', '2025-11-22', -21.85, 'WERUNFOUNDATION.ORG SYDNEY'),
    (v_card_id, v_cat_shopping_id, '2025-11-21', '2025-11-22', -157.29, 'BACKCOUNTRY.COM 800-409-4502 UT'),
    (v_card_id, v_cat_groceries_id, '2025-11-22', '2025-11-24', -15.23, 'PUBLIX #1554 HOLLYWOOD FL'),
    (v_card_id, v_cat_groceries_id, '2025-11-22', '2025-11-24', -42.92, 'NET COST MARKET HOLLYWOOD FL'),
    (v_card_id, v_cat_transport_id, '2025-11-22', '2025-11-24', -2.15, 'COH PRKING PAY BY PHONE 954-921-3266 FL'),
    (v_card_id, v_cat_transport_id, '2025-11-22', '2025-11-24', -9.35, 'COH PRKING PAY BY PHONE 954-921-3266 FL'),
    (v_card_id, v_cat_transport_id, '2025-11-22', '2025-11-24', -4.85, 'COH PRKING PAY BY PHONE 954-921-3266 FL'),
    (v_card_id, v_cat_groceries_id, '2025-11-22', '2025-11-24', -93.00, 'TOTAL WINE & MORE 9 FT LAUDERDALEFL'),
    (v_card_id, v_cat_groceries_id, '2025-11-27', '2025-11-28', -18.01, 'NET COST MARKET HOLLYWOOD FL'),
    (v_card_id, v_cat_shopping_id, '2025-11-27', '2025-11-28', -162.43, 'SMITH OPTIC 888-206-2995 NJ'),
    (v_card_id, v_cat_groceries_id, '2025-11-28', '2025-11-29', -145.87, 'NET COST MARKET HOLLYWOOD FL'),
    (v_card_id, v_cat_shopping_id, '2025-11-28', '2025-12-01', -149.80, 'PETER GLENN #5 FT LAUDERDALEFL'),
    (v_card_id, v_cat_groceries_id, '2025-11-29', '2025-12-01', -22.98, 'SQ *CAMPO MEAT Hallandale BeFL'),
    (v_card_id, v_cat_shopping_id, '2025-11-29', '2025-12-01', -50.00, 'BEST BUY 00005587 AVENTURA FL'),
    (v_card_id, v_cat_groceries_id, '2025-11-29', '2025-12-01', -6.76, 'PUBLIX #402 HALLANDALE FL'),
    (v_card_id, v_cat_health_id, '2025-12-01', '2025-12-02', -445.60, 'NEWSTAR DENTAL FORT LAUDERDAFL'),
    (v_card_id, v_cat_utilities_id, '2025-12-05', '2025-12-06', -48.93, 'GOOGLE *Google Fi 855-836-3987 CA');

    -- Statement Summary
    -- Total Purchases: $1,865.09
    -- Total Payments: $1,006.80
    -- Statement Balance: $1,865.09 - $1,006.80 = $858.29 (Assuming 0 starting balance, but usually it's the ending balance of previous period)
    -- Actually, the statement balance is usually just the sum of transactions in that period plus previous balance.
    -- If we treat each script as independent and populating one statement's activity:
    INSERT INTO finance.statement (card_id, statement_date, due_date, statement_balance, minimum_payment, paid_amount, is_fully_paid)
    VALUES (v_card_id, '2025-12-07', '2026-01-01', 858.29, 25.00, 0, FALSE);

END $$;
