-- Script to populate statement for account ending in 9573 (Card ID 3)
-- Period: September 18 - October 17, 2025
-- Based on the provided transaction list

DO $$
DECLARE
    v_card_id INTEGER;
    v_cat_payment_id INTEGER;
    v_cat_shopping_id INTEGER;
BEGIN
    -- Ensure the credit card exists (account ending in 9573)
    INSERT INTO finance.credit_card (name, bank_name, last_four, credit_limit, interest_rate_apr, statement_day_of_month, grace_period_days)
    VALUES ('Oleksii Kuzko', 'Unknown Bank', '9573', 5000.00, 19.99, 17, 25)
    ON CONFLICT DO NOTHING;

    SELECT id INTO v_card_id FROM finance.credit_card WHERE last_four = '9573';

    -- Get category IDs
    SELECT id INTO v_cat_payment_id FROM finance.category WHERE name = 'Payment';
    SELECT id INTO v_cat_shopping_id FROM finance.category WHERE name = 'Shopping';

    -- Payments and Other Credits
    -- 09/30 09/30 PAYMENT - THANK YOU 1165 9573 -588.49
    -- 10/15 10/15 PAYMENT - THANK YOU 1206 9573 -103.67
    INSERT INTO finance.transaction (card_id, category_id, transaction_date, post_date, amount, description) VALUES
    (v_card_id, v_cat_payment_id, '2025-09-30', '2025-09-30', 588.49, 'PAYMENT - THANK YOU 1165'),
    (v_card_id, v_cat_payment_id, '2025-10-15', '2025-10-15', 103.67, 'PAYMENT - THANK YOU 1206');

    -- Purchases and Adjustments
    -- 10/08 10/09 TOTAL WINE & MORE 9 FT LAUDERDALEFL 6046 9573 103.67
    INSERT INTO finance.transaction (card_id, category_id, transaction_date, post_date, amount, description) VALUES
    (v_card_id, v_cat_shopping_id, '2025-10-08', '2025-10-09', -103.67, 'TOTAL WINE & MORE 9 FT LAUDERDALE FL');

    -- Statement Summary
    -- Total Purchases: $103.67
    -- Total Payments: $692.16
    -- Statement Date: 2025-10-17
    -- Statement Balance: $0.00 (Assuming it was fully paid or covered by payments)
    -- Previous balance seems to have been $588.49 based on the first payment.
    -- Prev Balance + Purchases - Payments = New Balance
    -- 588.49 + 103.67 - 692.16 = 0.00
    
    INSERT INTO finance.statement (card_id, statement_date, due_date, statement_balance, minimum_payment, paid_amount, is_fully_paid)
    VALUES (v_card_id, '2025-10-17', '2025-11-11', 0.00, 0.00, 692.16, TRUE)
    ON CONFLICT (card_id, statement_date) DO UPDATE 
    SET statement_balance = EXCLUDED.statement_balance,
        paid_amount = EXCLUDED.paid_amount,
        is_fully_paid = EXCLUDED.is_fully_paid;

END $$;
