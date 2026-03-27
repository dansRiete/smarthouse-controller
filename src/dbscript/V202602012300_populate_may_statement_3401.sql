-- Script to populate statement for account ending in 3401 (Card ID 1)
-- Period: April 8 - May 7, 2025
-- Based on the provided transaction list

DO $$
DECLARE
    v_card_id INTEGER;
    v_cat_payment_id INTEGER;
    v_cat_shopping_id INTEGER;
    v_cat_insurance_id INTEGER;
    v_cat_transport_id INTEGER;
    v_cat_subscription_id INTEGER;
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

    -- Ensure categories exist
    INSERT INTO finance.category (name) VALUES ('Insurance'), ('Subscription') ON CONFLICT DO NOTHING;
    SELECT id INTO v_cat_insurance_id FROM finance.category WHERE name = 'Insurance';
    SELECT id INTO v_cat_subscription_id FROM finance.category WHERE name = 'Subscription';

    -- Payments and Other Credits
    -- 04/30 04/30 PAYMENT - THANK YOU 1058 3401 -700.00
    -- 04/30 05/01 BA ELECTRONIC PAYMENT 2389 3401 -190.00
    -- 04/30 05/01 BA ELECTRONIC PAYMENT 2397 3401 -600.00
    INSERT INTO finance.transaction (card_id, category_id, transaction_date, post_date, amount, description) VALUES
    (v_card_id, v_cat_payment_id, '2025-04-30', '2025-04-30', 700.00, 'PAYMENT - THANK YOU'),
    (v_card_id, v_cat_payment_id, '2025-04-30', '2025-05-01', 190.00, 'BA ELECTRONIC PAYMENT'),
    (v_card_id, v_cat_payment_id, '2025-04-30', '2025-05-01', 600.00, 'BA ELECTRONIC PAYMENT');

    -- Purchases and Adjustments
    -- 04/09 04/10 IKEA MIAMI MIAMI FL 9708 3401 659.30
    -- 04/11 04/12 PROGRESSIVE INS 800-776-4737 OH 7389 3401 171.71
    -- 04/20 04/21 SUNPASS*ACC118372795 888-865-5352 FL 7423 3401 10.00
    -- 04/20 04/21 SUNPASS*ACC118372795 888-865-5352 FL 7235 3401 10.00
    -- 04/20 04/21 SUNPASS*ACC118372795 888-865-5352 FL 8671 3401 10.00
    -- 04/21 04/21 SUNPASS*ACC118372795 888-865-5352 FL 5160 3401 10.00
    -- 05/02 05/03 GOOGLE *Flightradar24 855-836-3987 CA 5571 3401 1.49
    INSERT INTO finance.transaction (card_id, category_id, transaction_date, post_date, amount, description) VALUES
    (v_card_id, v_cat_shopping_id, '2025-04-09', '2025-04-10', -659.30, 'IKEA MIAMI MIAMI FL'),
    (v_card_id, v_cat_insurance_id, '2025-04-11', '2025-04-12', -171.71, 'PROGRESSIVE INS 800-776-4737 OH'),
    (v_card_id, v_cat_transport_id, '2025-04-20', '2025-04-21', -10.00, 'SUNPASS*ACC118372795 888-865-5352 FL'),
    (v_card_id, v_cat_transport_id, '2025-04-20', '2025-04-21', -10.00, 'SUNPASS*ACC118372795 888-865-5352 FL'),
    (v_card_id, v_cat_transport_id, '2025-04-20', '2025-04-21', -10.00, 'SUNPASS*ACC118372795 888-865-5352 FL'),
    (v_card_id, v_cat_transport_id, '2025-04-21', '2025-04-21', -10.00, 'SUNPASS*ACC118372795 888-865-5352 FL'),
    (v_card_id, v_cat_subscription_id, '2025-05-02', '2025-05-03', -1.49, 'GOOGLE *Flightradar24 855-836-3987 CA');

    -- Statement Summary
    -- Total Purchases: $872.50
    -- Total Payments: $1,490.00
    -- Ending Balance for May (Starting Balance for June) was calculated as $1,021.17 in the previous step.
    -- Prev Balance + Purchases - Payments = New Balance
    -- Prev Balance + 872.50 - 1490.00 = 1021.17
    -- Prev Balance = 1021.17 + 1490.00 - 872.50 = 1638.67
    
    INSERT INTO finance.statement (card_id, statement_date, due_date, statement_balance, minimum_payment, paid_amount, is_fully_paid)
    VALUES (v_card_id, '2025-05-07', '2025-06-02', 1021.17, 0.00, 1490.00, TRUE)
    ON CONFLICT (card_id, statement_date) DO UPDATE 
    SET statement_balance = EXCLUDED.statement_balance,
        paid_amount = EXCLUDED.paid_amount,
        is_fully_paid = EXCLUDED.is_fully_paid;

END $$;
