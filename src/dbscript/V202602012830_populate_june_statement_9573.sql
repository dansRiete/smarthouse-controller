-- Script to populate statement for account ending in 9573 (Card ID 3)
-- Period: May 18 - June 17, 2025
-- Based on the provided transaction list

DO $$
DECLARE
    v_card_id INTEGER;
    v_cat_payment_id INTEGER;
    v_cat_education_id INTEGER;
    v_cat_subscription_id INTEGER;
    v_cat_other_id INTEGER;
    v_cat_transport_id INTEGER;
BEGIN
    -- Ensure the credit card exists
    INSERT INTO finance.credit_card (name, bank_name, last_four, credit_limit, interest_rate_apr, statement_day_of_month, grace_period_days)
    VALUES ('Oleksii Kuzko', 'Unknown Bank', '9573', 5000.00, 19.99, 17, 25)
    ON CONFLICT DO NOTHING;

    SELECT id INTO v_card_id FROM finance.credit_card WHERE last_four = '9573';

    -- Ensure categories exist
    INSERT INTO finance.category (name) VALUES ('Education'), ('Subscription'), ('Other'), ('Transportation') ON CONFLICT DO NOTHING;

    -- Get category IDs
    SELECT id INTO v_cat_payment_id FROM finance.category WHERE name = 'Payment';
    SELECT id INTO v_cat_education_id FROM finance.category WHERE name = 'Education';
    SELECT id INTO v_cat_subscription_id FROM finance.category WHERE name = 'Subscription';
    SELECT id INTO v_cat_other_id FROM finance.category WHERE name = 'Other';
    SELECT id INTO v_cat_transport_id FROM finance.category WHERE name = 'Transportation';

    -- Payments and Other Credits
    -- 06/01 06/02 BA ELECTRONIC PAYMENT 0293 9573 -100.00
    -- 06/02 06/02 PAYMENT - THANK YOU 1084 9573 -1,437.49
    -- 06/02 06/03 BA ELECTRONIC PAYMENT 1612 9573 -580.00
    -- 06/04 06/04 PAYMENT - THANK YOU 1098 9573 -90.00
    INSERT INTO finance.transaction (card_id, category_id, transaction_date, post_date, amount, description) VALUES
    (v_card_id, v_cat_payment_id, '2025-06-01', '2025-06-02', 100.00, 'BA ELECTRONIC PAYMENT'),
    (v_card_id, v_cat_payment_id, '2025-06-02', '2025-06-02', 1437.49, 'PAYMENT - THANK YOU'),
    (v_card_id, v_cat_payment_id, '2025-06-02', '2025-06-03', 580.00, 'BA ELECTRONIC PAYMENT'),
    (v_card_id, v_cat_payment_id, '2025-06-04', '2025-06-04', 90.00, 'PAYMENT - THANK YOU');

    -- Purchases and Adjustments
    -- 05/18 05/19 PY *SkyEagle Aviation Aca954-7721212 FL 3153 9573 1,030.00
    -- 05/20 05/21 PY *SkyEagle Aviation Aca954-7721212 FL 6447 9573 360.50
    -- 05/21 05/21 AIRCRAFT & PILOT ASSN WWW.AOPA.ORG MD 8982 9573 13.99
    -- 05/22 05/23 BANYAN BAY MARINE clover.com FL 8246 9573 297.00
    -- 05/24 05/26 NIC*-DEP MIZELL-JOHNSON DANIA FL 6677 9573 13.00
    -- 05/ PSI EXAMS 800-367-1565 KS 3686 9573 175.00 (Wait, typo in snippet 05/25 05/26)
    -- 05/25 05/26 PY *SkyEagle Aviation Aca954-7721212 FL 8100 9573 309.00
    -- 05/25 05/26 Nyx*NAYAX VENDING 34 HUNT VALLEY MD 0606 9573 9.00
    INSERT INTO finance.transaction (card_id, category_id, transaction_date, post_date, amount, description) VALUES
    (v_card_id, v_cat_education_id, '2025-05-18', '2025-05-19', -1030.00, 'PY *SkyEagle Aviation Aca954-7721212 FL'),
    (v_card_id, v_cat_education_id, '2025-05-20', '2025-05-21', -360.50, 'PY *SkyEagle Aviation Aca954-7721212 FL'),
    (v_card_id, v_cat_subscription_id, '2025-05-21', '2025-05-21', -13.99, 'AIRCRAFT & PILOT ASSN WWW.AOPA.ORG MD'),
    (v_card_id, v_cat_other_id, '2025-05-22', '2025-05-23', -297.00, 'BANYAN BAY MARINE clover.com FL'),
    (v_card_id, v_cat_other_id, '2025-05-24', '2025-05-26', -13.00, 'NIC*-DEP MIZELL-JOHNSON DANIA FL'),
    (v_card_id, v_cat_education_id, '2025-05-25', '2025-05-26', -175.00, 'PSI EXAMS 800-367-1565 KS'),
    (v_card_id, v_cat_education_id, '2025-05-25', '2025-05-26', -309.00, 'PY *SkyEagle Aviation Aca954-7721212 FL'),
    (v_card_id, v_cat_transport_id, '2025-05-25', '2025-05-26', -9.00, 'Nyx*NAYAX VENDING 34 HUNT VALLEY MD');

    -- Statement Summary
    -- Total Purchases: $2,207.49
    -- Total Payments: $2,207.49
    -- Statement Balance: $0.00
    INSERT INTO finance.statement (card_id, statement_date, due_date, statement_balance, minimum_payment, paid_amount, is_fully_paid)
    VALUES (v_card_id, '2025-06-17', '2025-07-12', 0.00, 0.00, 2207.49, TRUE)
    ON CONFLICT (card_id, statement_date) DO UPDATE 
    SET statement_balance = EXCLUDED.statement_balance,
        paid_amount = EXCLUDED.paid_amount,
        is_fully_paid = EXCLUDED.is_fully_paid;

END $$;
