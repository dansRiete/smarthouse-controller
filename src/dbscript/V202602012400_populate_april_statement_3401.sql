-- Script to populate statement for account ending in 3401 (Card ID 1)
-- Period: March 8 - April 7, 2025
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
    v_cat_entertainment_id INTEGER;
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
    SELECT id INTO v_cat_entertainment_id FROM finance.category WHERE name = 'Entertainment';

    -- Ensure categories exist
    INSERT INTO finance.category (name) VALUES ('Entertainment') ON CONFLICT DO NOTHING;
    SELECT id INTO v_cat_entertainment_id FROM finance.category WHERE name = 'Entertainment';

    -- Payments and Other Credits
    -- 03/14 03/15 BA ELECTRONIC PAYMENT 5891 3401 -200.00
    -- 03/17 03/18 BA ELECTRONIC PAYMENT 3407 3401 -1,100.00
    -- 04/01 04/02 BA ELECTRONIC PAYMENT 3332 3401 -515.93
    -- 04/04 04/04 PAYMENT - THANK YOU 1011 3401 -1.49
    INSERT INTO finance.transaction (card_id, category_id, transaction_date, post_date, amount, description) VALUES
    (v_card_id, v_cat_payment_id, '2025-03-14', '2025-03-15', 200.00, 'BA ELECTRONIC PAYMENT'),
    (v_card_id, v_cat_payment_id, '2025-03-17', '2025-03-18', 1100.00, 'BA ELECTRONIC PAYMENT'),
    (v_card_id, v_cat_payment_id, '2025-04-01', '2025-04-02', 515.93, 'BA ELECTRONIC PAYMENT'),
    (v_card_id, v_cat_payment_id, '2025-04-04', '2025-04-04', 1.49, 'PAYMENT - THANK YOU');

    -- Purchases and Adjustments
    -- 03/11 03/12 PROGRESSIVE INS 800-776-4737 OH 0585 3401 208.76
    -- 03/13 03/14 eBay O*26-12803-45735 800-4563229 CA 1094 3401 1,192.34
    -- 03/13 03/14 CHEVRON 0047247 855-285-9595 FL 2821 3401 33.14
    -- 03/20 03/21 HSMV MYDMVPORTAL TPEREQ@TYLERTFL 5214 3401 4.50
    -- 03/27 03/28 WL *Steam Purchase 425-9522985 WA 4378 3401 4.99
    -- 04/02 04/03 GOOGLE *Flightradar24 855-836-3987 CA 7793 3401 1.49
    -- 04/04 04/05 PY *SkyEagle Aviation Aca954-7721212 FL 0624 3401 66.95
    -- 04/05 04/07 BRANDSMART USA DP DANIA BEACH FL 5545 3401 1,475.48
    INSERT INTO finance.transaction (card_id, category_id, transaction_date, post_date, amount, description) VALUES
    (v_card_id, v_cat_insurance_id, '2025-03-11', '2025-03-12', -208.76, 'PROGRESSIVE INS 800-776-4737 OH'),
    (v_card_id, v_cat_shopping_id, '2025-03-13', '2025-03-14', -1192.34, 'eBay O*26-12803-45735 800-4563229 CA'),
    (v_card_id, v_cat_transport_id, '2025-03-13', '2025-03-14', -33.14, 'CHEVRON 0047247 855-285-9595 FL'),
    (v_card_id, v_cat_transport_id, '2025-03-20', '2025-03-21', -4.50, 'HSMV MYDMVPORTAL TPEREQ@TYLERTFL'),
    (v_card_id, v_cat_entertainment_id, '2025-03-27', '2025-03-28', -4.99, 'WL *Steam Purchase 425-9522985 WA'),
    (v_card_id, v_cat_subscription_id, '2025-04-02', '2025-04-03', -1.49, 'GOOGLE *Flightradar24 855-836-3987 CA'),
    (v_card_id, v_cat_education_id, '2025-04-04', '2025-04-05', -66.95, 'PY *SkyEagle Aviation Aca954-7721212 FL'),
    (v_card_id, v_cat_shopping_id, '2025-04-05', '2025-04-07', -1475.48, 'BRANDSMART USA DP DANIA BEACH FL');

    -- Statement Summary
    -- Total Purchases: $2,987.65
    -- Total Payments: $1,817.42
    -- Ending Balance for April (Starting Balance for May) was calculated as $1,638.67.
    
    INSERT INTO finance.statement (card_id, statement_date, due_date, statement_balance, minimum_payment, paid_amount, is_fully_paid)
    VALUES (v_card_id, '2025-04-07', '2025-05-02', 1638.67, 0.00, 1817.42, TRUE)
    ON CONFLICT (card_id, statement_date) DO UPDATE 
    SET statement_balance = EXCLUDED.statement_balance,
        paid_amount = EXCLUDED.paid_amount,
        is_fully_paid = EXCLUDED.is_fully_paid;

END $$;
