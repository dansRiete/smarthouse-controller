-- Script to populate statement for account ending in 3401 (Card ID 1)
-- Period: August 8 - September 7, 2025
-- Based on the provided transaction list

DO $$
DECLARE
    v_card_id INTEGER;
    v_cat_payment_id INTEGER;
    v_cat_transport_id INTEGER;
    v_cat_subscription_id INTEGER;
    v_cat_shopping_id INTEGER;
BEGIN
    -- Ensure the credit card exists
    INSERT INTO finance.credit_card (name, bank_name, last_four, credit_limit, interest_rate_apr, statement_day_of_month, grace_period_days)
    VALUES ('Oleksii Kuzko', 'Unknown Bank', '3401', 5000.00, 19.99, 7, 25)
    ON CONFLICT DO NOTHING;

    SELECT id INTO v_card_id FROM finance.credit_card WHERE last_four = '3401';

    -- Get category IDs
    SELECT id INTO v_cat_payment_id FROM finance.category WHERE name = 'Payment';
    SELECT id INTO v_cat_transport_id FROM finance.category WHERE name = 'Transportation';
    SELECT id INTO v_cat_subscription_id FROM finance.category WHERE name = 'Subscription';
    SELECT id INTO v_cat_shopping_id FROM finance.category WHERE name = 'Shopping';

    -- Payments and Other Credits
    INSERT INTO finance.transaction (card_id, category_id, transaction_date, post_date, amount, description) VALUES
    (v_card_id, v_cat_payment_id, '2025-08-29', '2025-08-29', 33.64, 'PAYMENT - THANK YOU'),
    (v_card_id, v_cat_payment_id, '2025-09-05', '2025-09-05', 13.05, 'PAYMENT - THANK YOU');

    -- Purchases and Adjustments
    INSERT INTO finance.transaction (card_id, category_id, transaction_date, post_date, amount, description) VALUES
    (v_card_id, v_cat_transport_id, '2025-08-22', '2025-08-23', -27.00, 'HSMV MYDMVPORTAL TPEREQ@TYLERTFL'),
    (v_card_id, v_cat_subscription_id, '2025-08-23', '2025-08-26', -6.45, 'MEDIA APP 764520480 (5.49 EUR)'),
    (v_card_id, v_cat_transport_id, '2025-08-30', '2025-09-01', -8.35, 'COH PRKING PAY BY PHONE www.parkmobilFL'),
    (v_card_id, v_cat_transport_id, '2025-08-30', '2025-09-01', -2.75, 'COH PRKING PAY BY PHONE www.parkmobilFL'),
    (v_card_id, v_cat_transport_id, '2025-08-30', '2025-09-01', -1.95, 'COH PRKING PAY BY PHONE www.parkmobilFL');

    -- Fees
    INSERT INTO finance.transaction (card_id, category_id, transaction_date, post_date, amount, description) VALUES
    (v_card_id, v_cat_shopping_id, '2025-08-23', '2025-08-26', -0.19, 'FOREIGN TRANSACTION FEE');

    -- Statement Summary
    -- Total Purchases: $46.50
    -- Total Fees: $0.19
    -- Total Payments: $46.69
    -- Statement Balance: $46.50 + $0.19 - $46.69 = $0.00
    INSERT INTO finance.statement (card_id, statement_date, due_date, statement_balance, minimum_payment, paid_amount, is_fully_paid)
    VALUES (v_card_id, '2025-09-07', '2025-10-02', 0.00, 0.00, 46.69, TRUE)
    ON CONFLICT (card_id, statement_date) DO UPDATE 
    SET statement_balance = EXCLUDED.statement_balance,
        paid_amount = EXCLUDED.paid_amount,
        is_fully_paid = EXCLUDED.is_fully_paid;

END $$;
