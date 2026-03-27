-- Script to populate statement for account ending in 3401 (Card ID 1)
-- Period: June 8 - July 7, 2025
-- Based on the provided transaction list

DO $$
DECLARE
    v_card_id INTEGER;
    v_cat_payment_id INTEGER;
    v_cat_transport_id INTEGER;
    v_cat_education_id INTEGER;
    v_cat_shopping_id INTEGER;
    v_cat_insurance_id INTEGER;
BEGIN
    -- Ensure the credit card exists
    INSERT INTO finance.credit_card (name, bank_name, last_four, credit_limit, interest_rate_apr, statement_day_of_month, grace_period_days)
    VALUES ('Oleksii Kuzko', 'Unknown Bank', '3401', 5000.00, 19.99, 7, 25)
    ON CONFLICT DO NOTHING;

    SELECT id INTO v_card_id FROM finance.credit_card WHERE last_four = '3401';

    -- Get category IDs
    SELECT id INTO v_cat_payment_id FROM finance.category WHERE name = 'Payment';
    SELECT id INTO v_cat_transport_id FROM finance.category WHERE name = 'Transportation';
    SELECT id INTO v_cat_education_id FROM finance.category WHERE name = 'Education';
    SELECT id INTO v_cat_shopping_id FROM finance.category WHERE name = 'Shopping';
    SELECT id INTO v_cat_insurance_id FROM finance.category WHERE name = 'Insurance';

    -- Ensure categories exist (optional, but good for robustness if we use new ones)
    INSERT INTO finance.category (name) VALUES ('Education'), ('Insurance') ON CONFLICT DO NOTHING;
    SELECT id INTO v_cat_education_id FROM finance.category WHERE name = 'Education';
    SELECT id INTO v_cat_insurance_id FROM finance.category WHERE name = 'Insurance';

    -- Payments and Other Credits
    -- 06/12 06/13 PAYMENT - THANK YOU 1104 3401 -466.88
    -- 06/23 06/24 SSA*SKI SAFE SEA SAFE 800-225-6560 NY 5167 3401 -31.31
    -- 07/05 07/05 PAYMENT - THANK YOU 1121 3401 -6,177.79
    INSERT INTO finance.transaction (card_id, category_id, transaction_date, post_date, amount, description) VALUES
    (v_card_id, v_cat_payment_id, '2025-06-12', '2025-06-13', 466.88, 'PAYMENT - THANK YOU'),
    (v_card_id, v_cat_insurance_id, '2025-06-23', '2025-06-24', 31.31, 'SSA*SKI SAFE SEA SAFE 800-225-6560 NY'),
    (v_card_id, v_cat_payment_id, '2025-07-05', '2025-07-05', 6177.79, 'PAYMENT - THANK YOU');

    -- Purchases and Adjustments
    -- 06/07 06/09 PY *SkyEagle Aviation Aca954-7721212 FL 5369 3401 515.00
    -- 06/18 06/19 MPA PARKING PAY BY PHONE 305-373-6789 FL 3957 3401 9.10
    -- 07/04 07/05 CITY FURNITURE #27 HOLLYWOOD FL 8464 3401 6,200.00
    INSERT INTO finance.transaction (card_id, category_id, transaction_date, post_date, amount, description) VALUES
    (v_card_id, v_cat_education_id, '2025-06-07', '2025-06-09', -515.00, 'PY *SkyEagle Aviation Aca954-7721212 FL'),
    (v_card_id, v_cat_transport_id, '2025-06-18', '2025-06-19', -9.10, 'MPA PARKING PAY BY PHONE 305-373-6789 FL'),
    (v_card_id, v_cat_shopping_id, '2025-07-04', '2025-07-05', -6200.00, 'CITY FURNITURE #27 HOLLYWOOD FL');

    -- Statement Summary
    -- Total Purchases: $6,724.10
    -- Total Payments/Credits: $6,675.98
    -- Statement Balance: $6,724.10 - $6,675.98 = $48.12
    INSERT INTO finance.statement (card_id, statement_date, due_date, statement_balance, minimum_payment, paid_amount, is_fully_paid)
    VALUES (v_card_id, '2025-07-07', '2025-08-02', 48.12, 0.00, 6675.98, FALSE)
    ON CONFLICT (card_id, statement_date) DO UPDATE 
    SET statement_balance = EXCLUDED.statement_balance,
        paid_amount = EXCLUDED.paid_amount,
        is_fully_paid = EXCLUDED.is_fully_paid;

END $$;
