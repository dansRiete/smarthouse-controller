-- Script to populate statement for account ending in 3401 (Card ID 1)
-- Period: January 8 - February 7, 2025
-- Based on the provided transaction list

DO $$
DECLARE
    v_card_id INTEGER;
    v_cat_payment_id INTEGER;
    v_cat_shopping_id INTEGER;
    v_cat_insurance_id INTEGER;
    v_cat_transport_id INTEGER;
    v_cat_subscription_id INTEGER;
    v_cat_food_id INTEGER;
    v_cat_entertainment_id INTEGER;
    v_cat_health_id INTEGER;
BEGIN
    -- Ensure the credit card exists
    INSERT INTO finance.credit_card (name, bank_name, last_four, credit_limit, interest_rate_apr, statement_day_of_month, grace_period_days)
    VALUES ('Oleksii Kuzko', 'Unknown Bank', '3401', 5000.00, 19.99, 7, 25)
    ON CONFLICT DO NOTHING;

    SELECT id INTO v_card_id FROM finance.credit_card WHERE last_four = '3401';

    -- Get category IDs
    SELECT id INTO v_cat_payment_id FROM finance.category WHERE name = 'Payment';
    SELECT id INTO v_cat_shopping_id FROM finance.category WHERE name = 'Shopping';
    SELECT id INTO v_cat_insurance_id FROM finance.category WHERE name = 'Insurance';
    SELECT id INTO v_cat_transport_id FROM finance.category WHERE name = 'Transportation';
    SELECT id INTO v_cat_subscription_id FROM finance.category WHERE name = 'Subscription';
    SELECT id INTO v_cat_food_id FROM finance.category WHERE name = 'Food';
    SELECT id INTO v_cat_entertainment_id FROM finance.category WHERE name = 'Entertainment';
    SELECT id INTO v_cat_health_id FROM finance.category WHERE name = 'Health';

    -- Ensure categories exist
    INSERT INTO finance.category (name) VALUES ('Food'), ('Entertainment'), ('Health') ON CONFLICT DO NOTHING;
    SELECT id INTO v_cat_food_id FROM finance.category WHERE name = 'Food';
    SELECT id INTO v_cat_entertainment_id FROM finance.category WHERE name = 'Entertainment';
    SELECT id INTO v_cat_health_id FROM finance.category WHERE name = 'Health';

    -- Payments and Other Credits
    -- 01/11 01/11 PAYMENT - THANK YOU 0973 3401 -210.92
    -- 01/14 01/14 ATM PAYMENT HALLANDALE FL 5094 3401 -7,500.00
    INSERT INTO finance.transaction (card_id, category_id, transaction_date, post_date, amount, description) VALUES
    (v_card_id, v_cat_payment_id, '2025-01-11', '2025-01-11', 210.92, 'PAYMENT - THANK YOU'),
    (v_card_id, v_cat_payment_id, '2025-01-14', '2025-01-14', 7500.00, 'ATM PAYMENT HALLANDALE FL');

    -- Purchases and Adjustments
    INSERT INTO finance.transaction (card_id, category_id, transaction_date, post_date, amount, description) VALUES
    (v_card_id, v_cat_insurance_id, '2025-01-11', '2025-01-11', -210.92, 'PROGRESSIVE INS 800-776-4737 OH'),
    (v_card_id, v_cat_shopping_id, '2025-01-11', '2025-01-13', -101.64, 'NEWEGG INC. 800-390-1119 CA'),
    (v_card_id, v_cat_food_id, '2025-01-14', '2025-01-15', -124.22, 'PUBLIX #1554 HOLLYWOOD FL'),
    (v_card_id, v_cat_transport_id, '2025-01-16', '2025-01-17', -36.96, 'CHEVRON 0047247 855-285-9595 FL'),
    (v_card_id, v_cat_food_id, '2025-01-16', '2025-01-17', -131.69, 'EUROPA GOURMET HOLLYWOOD FL'),
    (v_card_id, v_cat_shopping_id, '2025-01-17', '2025-01-18', -9.00, 'Nyx*NAYAX VENDING 34 HUNT VALLEY MD'),
    (v_card_id, v_cat_shopping_id, '2025-01-18', '2025-01-20', -6.41, 'AMAZON MKTPL*ZG4634KC2 Amzn.com/billWA'),
    (v_card_id, v_cat_shopping_id, '2025-01-18', '2025-01-20', -25.42, 'Amazon.com*Z52OW3WP0 Amzn.com/billWA'),
    (v_card_id, v_cat_food_id, '2025-01-18', '2025-01-20', -103.42, 'WILD FORK FOODS - AVENTURAVENTURA FL'),
    (v_card_id, v_cat_shopping_id, '2025-01-18', '2025-01-20', -172.57, 'WAL-MART #1996 HALLANDALE FL'),
    (v_card_id, v_cat_shopping_id, '2025-01-18', '2025-01-20', -112.43, 'TOTAL WINE AND MORE MIAMI FL'),
    (v_card_id, v_cat_food_id, '2025-01-19', '2025-01-21', -56.00, 'HOLLYWOOD BREWERY HOLLYWOOD FL'),
    (v_card_id, v_cat_food_id, '2025-01-19', '2025-01-21', -10.97, '3 SCOOPS HOLLYWOOD FL'),
    (v_card_id, v_cat_shopping_id, '2025-01-21', '2025-01-22', -140.00, 'ALIEN FLIGHT STUDENT PROG571-227-1089 VA'),
    (v_card_id, v_cat_transport_id, '2025-01-22', '2025-01-22', -10.00, 'SUNPASS*ACC118372795 888-865-5352 FL'),
    (v_card_id, v_cat_food_id, '2025-01-22', '2025-01-23', -57.45, 'PUBLIX #1554 HOLLYWOOD FL'),
    (v_card_id, v_cat_entertainment_id, '2025-01-27', '2025-01-28', -90.61, 'CTS*AIR.SHOW FT LAUD SQUADUP.COM FL'),
    (v_card_id, v_cat_food_id, '2025-01-27', '2025-01-28', -79.52, 'PUBLIX #1554 HOLLYWOOD FL'),
    (v_card_id, v_cat_shopping_id, '2025-01-28', '2025-01-29', -146.30, 'WAL-MART #1996 HALLANDALE FL'),
    (v_card_id, v_cat_food_id, '2025-01-29', '2025-01-30', -20.79, 'PUBLIX #1554 HOLLYWOOD FL'),
    (v_card_id, v_cat_entertainment_id, '2025-01-30', '2025-01-30', -29.99, 'WL *STEAM PURCHASE 425-889-9642 WA'),
    (v_card_id, v_cat_transport_id, '2025-01-30', '2025-01-31', -30.37, 'CHEVRON 0304796 855-285-9595 FL'),
    (v_card_id, v_cat_shopping_id, '2025-01-30', '2025-01-31', -24.00, 'IDEMIA TSA FTSP PEMBROKE PINEFL'),
    (v_card_id, v_cat_food_id, '2025-01-31', '2025-02-01', -106.02, 'EUROPA GOURMET HOLLYWOOD FL'),
    (v_card_id, v_cat_subscription_id, '2025-02-02', '2025-02-03', -1.49, 'GOOGLE *Flightradar24 855-836-3987 CA'),
    (v_card_id, v_cat_health_id, '2025-02-03', '2025-02-04', -3.00, 'HCA FL AVENTURA HOSPITAL AVENTURA FL'),
    (v_card_id, v_cat_health_id, '2025-02-03', '2025-02-04', -25.00, 'PEDIATRIC ASSOCIATES #34 AVENTURA FL'),
    (v_card_id, v_cat_shopping_id, '2025-02-03', '2025-02-04', -20.18, 'CVS/PHARMACY #10078 HALLANDALE BEFL'),
    (v_card_id, v_cat_food_id, '2025-02-04', '2025-02-05', -55.18, 'PUBLIX #402 HALLANDALE FL'),
    (v_card_id, v_cat_shopping_id, '2025-02-04', '2025-02-05', -7.98, 'CVS/PHARMACY #10078 HALLANDALE BEFL'),
    (v_card_id, v_cat_transport_id, '2025-02-06', '2025-02-07', -18.00, 'OSP*B0121 - Hollywood Cen703-3788299 FL');

    -- Statement Summary
    -- Total Purchases: $1,967.53
    -- Total Payments: $7,710.92
    -- Ending Balance for February (Starting Balance for March) was calculated as $1,638.67 in the previous step.
    -- Prev Balance + Purchases - Payments = New Balance
    -- Prev Balance + 1,967.53 - 7,710.92 = 1,638.67
    -- Prev Balance = 1,638.67 + 7,710.92 - 1,967.53 = 7,382.06
    
    INSERT INTO finance.statement (card_id, statement_date, due_date, statement_balance, minimum_payment, paid_amount, is_fully_paid)
    VALUES (v_card_id, '2025-02-07', '2025-03-02', 1638.67, 0.00, 7710.92, TRUE)
    ON CONFLICT (card_id, statement_date) DO UPDATE 
    SET statement_balance = EXCLUDED.statement_balance,
        paid_amount = EXCLUDED.paid_amount,
        is_fully_paid = EXCLUDED.is_fully_paid;

END $$;
