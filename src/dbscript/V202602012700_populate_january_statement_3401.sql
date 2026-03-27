-- Script to populate statement for account ending in 3401 (Card ID 1)
-- Period: December 8, 2024 - January 7, 2025
-- Based on the provided transaction list

DO $$
DECLARE
    v_card_id INTEGER;
    v_cat_payment_id INTEGER;
    v_cat_subscription_id INTEGER;
    v_cat_insurance_id INTEGER;
    v_cat_shopping_id INTEGER;
    v_cat_other_id INTEGER;
BEGIN
    -- Ensure the credit card exists
    INSERT INTO finance.credit_card (name, bank_name, last_four, credit_limit, interest_rate_apr, statement_day_of_month, grace_period_days)
    VALUES ('Oleksii Kuzko', 'Unknown Bank', '3401', 5000.00, 19.99, 7, 25)
    ON CONFLICT DO NOTHING;

    SELECT id INTO v_card_id FROM finance.credit_card WHERE last_four = '3401';

    -- Ensure categories exist
    INSERT INTO finance.category (name) VALUES ('Subscription'), ('Insurance'), ('Shopping'), ('Other') ON CONFLICT DO NOTHING;

    -- Get category IDs
    SELECT id INTO v_cat_payment_id FROM finance.category WHERE name = 'Payment';
    SELECT id INTO v_cat_subscription_id FROM finance.category WHERE name = 'Subscription';
    SELECT id INTO v_cat_insurance_id FROM finance.category WHERE name = 'Insurance';
    SELECT id INTO v_cat_shopping_id FROM finance.category WHERE name = 'Shopping';
    SELECT id INTO v_cat_other_id FROM finance.category WHERE name = 'Other';

    -- Payments and Other Credits
    -- 12/11 12/13 BA ELECTRONIC PAYMENT 7436 3401 -210.92
    -- 12/16 12/16 PAYMENT - THANK YOU 0959 3401 -513.00
    -- 12/31 01/02 BA ELECTRONIC PAYMENT 0592 3401 -587.47
    INSERT INTO finance.transaction (card_id, category_id, transaction_date, post_date, amount, description) VALUES
    (v_card_id, v_cat_payment_id, '2024-12-11', '2024-12-13', 210.92, 'BA ELECTRONIC PAYMENT'),
    (v_card_id, v_cat_payment_id, '2024-12-16', '2024-12-16', 513.00, 'PAYMENT - THANK YOU'),
    (v_card_id, v_cat_payment_id, '2024-12-31', '2025-01-02', 587.47, 'BA ELECTRONIC PAYMENT');

    -- Purchases and Adjustments
    -- 12/09 12/10 GOOGLE *Google Fi 855-836-3987 CA 7983 3401 748.99
    -- 12/11 12/12 PROGRESSIVE INS 800-776-4737 OH 3788 3401 210.92
    -- 12/15 12/16 IKEA SUNRISE SUNRISE FL 2974 3401 245.19
    -- 12/25 12/26 Flightradar24 AB Stockholm 5029 3401 2.99
    -- 12/27 12/28 ALLO DNIPRO 4,199.00 UAH 6977 3401 100.30
    -- 01/02 01/03 GOOGLE *Flightradar24 855-836-3987 CA 8234 3401 1.49
    INSERT INTO finance.transaction (card_id, category_id, transaction_date, post_date, amount, description) VALUES
    (v_card_id, v_cat_subscription_id, '2024-12-09', '2024-12-10', -748.99, 'GOOGLE *Google Fi 855-836-3987 CA'),
    (v_card_id, v_cat_insurance_id, '2024-12-11', '2024-12-12', -210.92, 'PROGRESSIVE INS 800-776-4737 OH'),
    (v_card_id, v_cat_shopping_id, '2024-12-15', '2024-12-16', -245.19, 'IKEA SUNRISE SUNRISE FL'),
    (v_card_id, v_cat_subscription_id, '2024-12-25', '2024-12-26', -2.99, 'Flightradar24 AB Stockholm'),
    (v_card_id, v_cat_shopping_id, '2024-12-27', '2024-12-28', -100.30, 'ALLO DNIPRO (4,199.00 UAH)'),
    (v_card_id, v_cat_subscription_id, '2025-01-02', '2025-01-03', -1.49, 'GOOGLE *Flightradar24 855-836-3987 CA');

    -- Fees
    -- 12/27 12/28 FOREIGN TRANSACTION FEE 6977 3401 3.00
    INSERT INTO finance.transaction (card_id, category_id, transaction_date, post_date, amount, description) VALUES
    (v_card_id, v_cat_other_id, '2024-12-27', '2024-12-28', -3.00, 'FOREIGN TRANSACTION FEE');

    -- Statement Summary
    -- Prev Balance: $1,638.67 (Starting Balance for February statement)
    -- Purchases & Fees: $1,309.88 + $3.00 = $1,312.88
    -- Payments: $1,311.39
    -- Statement Balance = Prev Balance + Purchases/Fees - Payments
    -- Statement Balance = 1638.67 + 1312.88 - 1311.39 = 1640.16
    
    INSERT INTO finance.statement (card_id, statement_date, due_date, statement_balance, minimum_payment, paid_amount, is_fully_paid)
    VALUES (v_card_id, '2025-01-07', '2025-02-02', 1640.16, 0.00, 1311.39, TRUE)
    ON CONFLICT (card_id, statement_date) DO UPDATE 
    SET statement_balance = EXCLUDED.statement_balance,
        paid_amount = EXCLUDED.paid_amount,
        is_fully_paid = EXCLUDED.is_fully_paid;

END $$;
