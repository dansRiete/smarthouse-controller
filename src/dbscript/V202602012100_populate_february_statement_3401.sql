-- Script to populate statement for account ending in 3401
-- Period: January 8, 2026 - February 7, 2026

DO $$
DECLARE
    v_card_id INTEGER;
    v_cat_payment_id INTEGER;
    v_cat_groceries_id INTEGER;
    v_cat_dining_id INTEGER;
    v_cat_transport_id INTEGER;
    v_cat_health_id INTEGER;
    v_cat_subscription_id INTEGER;
    v_cat_fees_id INTEGER;
BEGIN
    -- Ensure the credit card exists
    SELECT id INTO v_card_id FROM finance.credit_card WHERE last_four = '3401';

    -- Get category IDs
    SELECT id INTO v_cat_payment_id FROM finance.category WHERE name = 'Payment';
    SELECT id INTO v_cat_groceries_id FROM finance.category WHERE name = 'Groceries';
    SELECT id INTO v_cat_dining_id FROM finance.category WHERE name = 'Dining Out';
    SELECT id INTO v_cat_transport_id FROM finance.category WHERE name = 'Transportation';
    SELECT id INTO v_cat_health_id FROM finance.category WHERE name = 'Health';
    SELECT id INTO v_cat_subscription_id FROM finance.category WHERE name = 'Subscription';
    
    -- Add Fees & Interest category if it doesn't exist
    INSERT INTO finance.category (name) VALUES ('Fees & Interest') ON CONFLICT DO NOTHING;
    SELECT id INTO v_cat_fees_id FROM finance.category WHERE name = 'Fees & Interest';

    -- Payments and Other Credits
    INSERT INTO finance.transaction (card_id, category_id, transaction_date, post_date, amount, description) VALUES
    (v_card_id, v_cat_payment_id, '2026-01-23', '2026-01-23', 1800.00, 'PAYMENT - THANK YOU');

    -- Purchases and Adjustments
    INSERT INTO finance.transaction (card_id, category_id, transaction_date, post_date, amount, description) VALUES
    (v_card_id, v_cat_subscription_id, '2026-01-07', '2026-01-09', -10.00, 'JetBrains Americas INC 165-05772345 CA'),
    (v_card_id, v_cat_groceries_id, '2026-01-16', '2026-01-17', -106.69, 'WILD FORK FOODS - AVENTURAVENTURA FL'),
    (v_card_id, v_cat_groceries_id, '2026-01-16', '2026-01-17', -76.96, 'TOTAL WINE AND MORE MIAMI FL'),
    (v_card_id, v_cat_health_id, '2026-01-19', '2026-01-20', -59.60, 'NEWSTAR DENTAL FORT LAUDERDAFL'),
    (v_card_id, v_cat_transport_id, '2026-01-27', '2026-01-28', -3.95, 'COH PRKING PAY BY PHONE 954-921-3266 FL'),
    (v_card_id, v_cat_dining_id, '2026-01-27', '2026-01-29', -70.75, 'HOLLYWOOD BREWERY HOLLYWOOD FL'),
    (v_card_id, v_cat_groceries_id, '2026-01-30', '2026-01-31', -95.14, 'TOTAL WINE & MORE 9 FT LAUDERDALEFL'),
    (v_card_id, v_cat_groceries_id, '2026-01-31', '2026-02-02', -10.44, 'COSTCO WHSE #0091 DAVIE FL'),
    (v_card_id, v_cat_groceries_id, '2026-01-31', '2026-02-02', -286.76, 'COSTCO WHSE #0091 DAVIE FL'),
    (v_card_id, v_cat_groceries_id, '2026-01-31', '2026-02-02', -19.56, 'PUBLIX #1554 HOLLYWOOD FL'),
    (v_card_id, v_cat_transport_id, '2026-02-01', '2026-02-02', -3.15, 'COH PRKING PAY BY PHONE 954-921-3266 FL');

    -- Interest Charged
    INSERT INTO finance.transaction (card_id, category_id, transaction_date, post_date, amount, description) VALUES
    (v_card_id, v_cat_fees_id, '2026-02-07', '2026-02-07', -24.68, 'INTEREST CHARGED ON PURCHASES');

    -- Statement Summary
    -- Previous Balance (from Jan 7 statement): $1,767.66
    -- Payments: -$1,800.00
    -- Purchases: +$743.00
    -- Interest: +$24.68
    -- New Balance: 1767.66 - 1800.00 + 743.00 + 24.68 = $735.34
    INSERT INTO finance.statement (card_id, statement_date, due_date, statement_balance, minimum_payment, interest_charged)
    VALUES (v_card_id, '2026-02-07', '2026-03-04', 735.34, 25.00, 24.68);

END $$;
