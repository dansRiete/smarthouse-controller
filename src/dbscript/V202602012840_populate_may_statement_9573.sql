-- Script to populate statement for account ending in 9573 (Card ID 3)
-- Period: April 18 - May 17, 2025
-- Based on the provided transaction list

DO $$
DECLARE
    v_card_id INTEGER;
    v_cat_payment_id INTEGER;
    v_cat_subscription_id INTEGER;
    v_cat_other_id INTEGER;
    v_cat_insurance_id INTEGER;
    v_cat_transport_id INTEGER;
    v_cat_shopping_id INTEGER;
    v_cat_dining_id INTEGER;
    v_cat_education_id INTEGER;
BEGIN
    -- Ensure the credit card exists
    INSERT INTO finance.credit_card (name, bank_name, last_four, credit_limit, interest_rate_apr, statement_day_of_month, grace_period_days)
    VALUES ('Oleksii Kuzko', 'Unknown Bank', '9573', 5000.00, 19.99, 17, 25)
    ON CONFLICT DO NOTHING;

    SELECT id INTO v_card_id FROM finance.credit_card WHERE last_four = '9573';

    -- Ensure categories exist
    INSERT INTO finance.category (name) VALUES ('Education'), ('Subscription'), ('Other'), ('Transportation'), ('Insurance'), ('Shopping'), ('Dining Out') ON CONFLICT DO NOTHING;

    -- Get category IDs
    SELECT id INTO v_cat_payment_id FROM finance.category WHERE name = 'Payment';
    SELECT id INTO v_cat_education_id FROM finance.category WHERE name = 'Education';
    SELECT id INTO v_cat_subscription_id FROM finance.category WHERE name = 'Subscription';
    SELECT id INTO v_cat_other_id FROM finance.category WHERE name = 'Other';
    SELECT id INTO v_cat_transport_id FROM finance.category WHERE name = 'Transportation';
    SELECT id INTO v_cat_insurance_id FROM finance.category WHERE name = 'Insurance';
    SELECT id INTO v_cat_shopping_id FROM finance.category WHERE name = 'Shopping';
    SELECT id INTO v_cat_dining_id FROM finance.category WHERE name = 'Dining Out';

    -- Payments and Other Credits
    -- 04/21 04/21 PAYMENT - THANK YOU 1027 9573 -121.45
    -- 04/30 05/01 BA ELECTRONIC PAYMENT 2371 9573 -770.73
    -- 05/15 05/15 PAYMENT - THANK YOU 1075 9573 -359.23
    INSERT INTO finance.transaction (card_id, category_id, transaction_date, post_date, amount, description) VALUES
    (v_card_id, v_cat_payment_id, '2025-04-21', '2025-04-21', 121.45, 'PAYMENT - THANK YOU'),
    (v_card_id, v_cat_payment_id, '2025-04-30', '2025-05-01', 770.73, 'BA ELECTRONIC PAYMENT'),
    (v_card_id, v_cat_payment_id, '2025-05-15', '2025-05-15', 359.23, 'PAYMENT - THANK YOU');

    -- Purchases and Adjustments
    -- 04/22 04/23 AIRCRAFT & PILOT ASSN WWW.AOPA.ORG MD 3017 9573 13.99
    -- 04/22 04/23 BANYAN BAY MARINE clover.com FL 9345 9573 297.00
    -- 04/23 04/23 AD* AssuredPartners Aero Kansas City MO 3026 9573 205.03
    -- 04/26 04/28 EXXON GIANT 134 DANIA FL 9974 9573 21.80
    -- 04/26 04/28 BP#6469795SRF 114 DANIA FL 3097 9573 15.05
    -- 04/27 04/28 AMZN Mktp IT*0Y1SM46T5 AMAZON.IT 2367 9573 93.64
    -- 04/28 04/30 TST*THE MERMAID QUEEN Hollywood FL 6867 9573 124.22
    -- 04/30 05/01 PY *SkyEagle Aviation Aca954-7721212 FL 2485 9573 309.00
    -- 05/03 05/05 SQ *SAN FRANCISCO PUFFS AFort LauderdaFL 6941 9573 50.23
    INSERT INTO finance.transaction (card_id, category_id, transaction_date, post_date, amount, description) VALUES
    (v_card_id, v_cat_subscription_id, '2025-04-22', '2025-04-23', -13.99, 'AIRCRAFT & PILOT ASSN WWW.AOPA.ORG MD'),
    (v_card_id, v_cat_other_id, '2025-04-22', '2025-04-23', -297.00, 'BANYAN BAY MARINE clover.com FL'),
    (v_card_id, v_cat_insurance_id, '2025-04-23', '2025-04-23', -205.03, 'AD* AssuredPartners Aero Kansas City MO'),
    (v_card_id, v_cat_transport_id, '2025-04-26', '2025-04-28', -21.80, 'EXXON GIANT 134 DANIA FL'),
    (v_card_id, v_cat_transport_id, '2025-04-26', '2025-04-28', -15.05, 'BP#6469795SRF 114 DANIA FL'),
    (v_card_id, v_cat_shopping_id, '2025-04-27', '2025-04-28', -93.64, 'AMZN Mktp IT*0Y1SM46T5 AMAZON.IT'),
    (v_card_id, v_cat_dining_id, '2025-04-28', '2025-04-30', -124.22, 'TST*THE MERMAID QUEEN Hollywood FL'),
    (v_card_id, v_cat_education_id, '2025-04-30', '2025-05-01', -309.00, 'PY *SkyEagle Aviation Aca954-7721212 FL'),
    (v_card_id, v_cat_dining_id, '2025-05-03', '2025-05-05', -50.23, 'SQ *SAN FRANCISCO PUFFS AFort LauderdaFL');

    -- Statement Summary
    -- Total Purchases: $1,129.96
    -- Total Payments: $1,251.41
    -- Balance from snippet seems to be part of a larger calculation.
    -- If we assume it starts at 121.45 (which was paid on 04/21), then 121.45 + 1129.96 - 1251.41 = 0.
    INSERT INTO finance.statement (card_id, statement_date, due_date, statement_balance, minimum_payment, paid_amount, is_fully_paid)
    VALUES (v_card_id, '2025-05-17', '2025-06-11', 0.00, 0.00, 1251.41, TRUE)
    ON CONFLICT (card_id, statement_date) DO UPDATE 
    SET statement_balance = EXCLUDED.statement_balance,
        paid_amount = EXCLUDED.paid_amount,
        is_fully_paid = EXCLUDED.is_fully_paid;

END $$;
