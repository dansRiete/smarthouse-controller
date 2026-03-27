-- Script to populate statement for account ending in 3401 (Card ID 1)
-- Period: February 8 - March 7, 2025
-- Based on the provided transaction list

DO $$
DECLARE
    v_card_id INTEGER;
    v_cat_payment_id INTEGER;
    v_cat_shopping_id INTEGER;
    v_cat_insurance_id INTEGER;
    v_cat_transport_id INTEGER;
    v_cat_subscription_id INTEGER;
    v_cat_education_id INTEGER;
    v_cat_health_id INTEGER;
    v_cat_food_id INTEGER;
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
    SELECT id INTO v_cat_education_id FROM finance.category WHERE name = 'Education';
    SELECT id INTO v_cat_health_id FROM finance.category WHERE name = 'Health';
    SELECT id INTO v_cat_food_id FROM finance.category WHERE name = 'Food';

    -- Ensure categories exist
    INSERT INTO finance.category (name) VALUES ('Health'), ('Food') ON CONFLICT DO NOTHING;
    SELECT id INTO v_cat_health_id FROM finance.category WHERE name = 'Health';
    SELECT id INTO v_cat_food_id FROM finance.category WHERE name = 'Food';

    -- Payments and Other Credits
    -- 02/07 02/10 CVS/PHARMACY #10078 HALLANDALE BEFL 9409 3401 -10.69 (Refund?)
    -- 02/24 02/25 BA ELECTRONIC PAYMENT 5499 3401 -1,000.00
    -- 02/26 02/27 eBay O*26-12683-10375 800-4563229 CA 8030 3401 -706.19 (Refund?)
    -- 03/03 03/04 BA ELECTRONIC PAYMENT 0580 3401 -500.00
    INSERT INTO finance.transaction (card_id, category_id, transaction_date, post_date, amount, description) VALUES
    (v_card_id, v_cat_health_id, '2025-02-07', '2025-02-10', 10.69, 'CVS/PHARMACY #10078 HALLANDALE BEFL'),
    (v_card_id, v_cat_payment_id, '2025-02-24', '2025-02-25', 1000.00, 'BA ELECTRONIC PAYMENT'),
    (v_card_id, v_cat_shopping_id, '2025-02-26', '2025-02-27', 706.19, 'eBay O*26-12683-10375 800-4563229 CA'),
    (v_card_id, v_cat_payment_id, '2025-03-03', '2025-03-04', 500.00, 'BA ELECTRONIC PAYMENT');

    -- Purchases and Adjustments
    -- 02/07 02/08 CVS/PHARMACY #10078 HALLANDALE BEFL 9442 3401 8.55
    -- 02/07 02/08 WINN-DIXIE #0306 HALLANDALE FL 9368 3401 49.00
    -- 02/10 02/11 WAL-MART #1996 HALLANDALE FL 1801 3401 163.88
    -- 02/11 02/11 PROGRESSIVE INS 800-776-4737 OH 9080 3401 210.92
    -- 02/12 02/13 eBay O*26-12683-10375 800-4563229 CA 7030 3401 706.19
    -- 02/13 02/14 EUROPA GOURMET HOLLYWOOD FL 9832 3401 109.50
    -- 02/13 02/14 PUBLIX #1554 HOLLYWOOD FL 1239 3401 123.62
    -- 02/14 02/15 CHEVRON 0047247 HALLANDALE FL 3167 3401 28.96
    -- 02/16 02/17 PUBLIX #1554 HOLLYWOOD FL 0937 3401 22.08
    -- 02/18 02/18 Bose Corporation 800-3792073 MA 6038 3401 1,389.93
    -- 02/18 02/19 PUBLIX #402 HALLANDALE FL 6406 3401 78.56
    -- 02/19 02/20 CHUCK E CHEESE 435 MIAMI FL 9220 3401 50.00
    -- 02/19 02/20 SPORTY'S CATALOGS 513-735-9000 OH 6167 3401 121.33
    -- 02/20 02/21 PUBLIX #1554 HOLLYWOOD FL 2845 3401 82.54
    -- 02/19 02/22 APPAREO SYSTEMS LLC 7013562200 ND 0171 3401 66.36
    -- 02/21 02/22 CHEVRON 0047247 855-285-9595 FL 0162 3401 23.99
    -- 02/21 02/22 EUROPA GOURMET HOLLYWOOD FL 3056 3401 19.88
    -- 02/22 02/24 BANYAN 954-491-6355 FT LAUDERDALEFL 0706 3401 26.70
    -- 02/24 02/25 CHUCK E CHEESE 435 MIAMI FL 2777 3401 166.67
    -- 02/25 02/25 MLT (SCHOOL) 800-736-4753 MN 6990 3401 33.99
    -- 02/25 02/26 PUBLIX #1554 HOLLYWOOD FL 6871 3401 51.71
    -- 02/27 02/28 SPORTY'S CATALOGS 513-735-9000 OH 8583 3401 299.00
    -- 02/28 03/01 CHEVRON 0047247 855-285-9595 FL 5396 3401 35.99
    -- 03/02 03/03 GOOGLE *Flightradar24 g.co/helppay#CA 1963 3401 1.49
    INSERT INTO finance.transaction (card_id, category_id, transaction_date, post_date, amount, description) VALUES
    (v_card_id, v_cat_health_id, '2025-02-07', '2025-02-08', -8.55, 'CVS/PHARMACY #10078 HALLANDALE BEFL'),
    (v_card_id, v_cat_food_id, '2025-02-07', '2025-02-08', -49.00, 'WINN-DIXIE #0306 HALLANDALE FL'),
    (v_card_id, v_cat_shopping_id, '2025-02-10', '2025-02-11', -163.88, 'WAL-MART #1996 HALLANDALE FL'),
    (v_card_id, v_cat_insurance_id, '2025-02-11', '2025-02-11', -210.92, 'PROGRESSIVE INS 800-776-4737 OH'),
    (v_card_id, v_cat_shopping_id, '2025-02-12', '2025-02-13', -706.19, 'eBay O*26-12683-10375 800-4563229 CA'),
    (v_card_id, v_cat_food_id, '2025-02-13', '2025-02-14', -109.50, 'EUROPA GOURMET HOLLYWOOD FL'),
    (v_card_id, v_cat_food_id, '2025-02-13', '2025-02-14', -123.62, 'PUBLIX #1554 HOLLYWOOD FL'),
    (v_card_id, v_cat_transport_id, '2025-02-14', '2025-02-15', -28.96, 'CHEVRON 0047247 HALLANDALE FL'),
    (v_card_id, v_cat_food_id, '2025-02-16', '2025-02-17', -22.08, 'PUBLIX #1554 HOLLYWOOD FL'),
    (v_card_id, v_cat_shopping_id, '2025-02-18', '2025-02-18', -1389.93, 'Bose Corporation 800-3792073 MA'),
    (v_card_id, v_cat_food_id, '2025-02-18', '2025-02-19', -78.56, 'PUBLIX #402 HALLANDALE FL'),
    (v_card_id, v_cat_food_id, '2025-02-19', '2025-02-20', -50.00, 'CHUCK E CHEESE 435 MIAMI FL'),
    (v_card_id, v_cat_shopping_id, '2025-02-19', '2025-02-20', -121.33, 'SPORTY''S CATALOGS 513-735-9000 OH'),
    (v_card_id, v_cat_food_id, '2025-02-20', '2025-02-21', -82.54, 'PUBLIX #1554 HOLLYWOOD FL'),
    (v_card_id, v_cat_transport_id, '2025-02-19', '2025-02-22', -66.36, 'APPAREO SYSTEMS LLC 7013562200 ND'),
    (v_card_id, v_cat_transport_id, '2025-02-21', '2025-02-22', -23.99, 'CHEVRON 0047247 855-285-9595 FL'),
    (v_card_id, v_cat_food_id, '2025-02-21', '2025-02-22', -19.88, 'EUROPA GOURMET HOLLYWOOD FL'),
    (v_card_id, v_cat_food_id, '2025-02-22', '2025-02-24', -26.70, 'BANYAN 954-491-6355 FT LAUDERDALEFL'),
    (v_card_id, v_cat_food_id, '2025-02-24', '2025-02-25', -166.67, 'CHUCK E CHEESE 435 MIAMI FL'),
    (v_card_id, v_cat_education_id, '2025-02-25', '2025-02-25', -33.99, 'MLT (SCHOOL) 800-736-4753 MN'),
    (v_card_id, v_cat_food_id, '2025-02-25', '2025-02-26', -51.71, 'PUBLIX #1554 HOLLYWOOD FL'),
    (v_card_id, v_cat_shopping_id, '2025-02-27', '2025-02-28', -299.00, 'SPORTY''S CATALOGS 513-735-9000 OH'),
    (v_card_id, v_cat_transport_id, '2025-02-28', '2025-03-01', -35.99, 'CHEVRON 0047247 855-285-9595 FL'),
    (v_card_id, v_cat_subscription_id, '2025-03-02', '2025-03-03', -1.49, 'GOOGLE *Flightradar24 g.co/helppay#CA');

    -- Statement Summary
    -- Total Purchases: $3,870.84
    -- Total Payments/Credits: $2,216.88
    -- Ending Balance for March (Starting Balance for April) was $1,638.67.
    
    INSERT INTO finance.statement (card_id, statement_date, due_date, statement_balance, minimum_payment, paid_amount, is_fully_paid)
    VALUES (v_card_id, '2025-03-07', '2025-04-02', 1638.67, 0.00, 2216.88, TRUE)
    ON CONFLICT (card_id, statement_date) DO UPDATE 
    SET statement_balance = EXCLUDED.statement_balance,
        paid_amount = EXCLUDED.paid_amount,
        is_fully_paid = EXCLUDED.is_fully_paid;

END $$;
