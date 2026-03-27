-- Script to populate statement for account ending in 3401 (Card ID 1)
-- Period: May 8 - June 7, 2025
-- Based on the provided transaction list

DO $$
DECLARE
    v_card_id INTEGER;
    v_cat_payment_id INTEGER;
    v_cat_shopping_id INTEGER;
BEGIN
    -- Ensure the credit card exists
    INSERT INTO finance.credit_card (name, bank_name, last_four, credit_limit, interest_rate_apr, statement_day_of_month, grace_period_days)
    VALUES ('Oleksii Kuzko', 'Unknown Bank', '3401', 5000.00, 19.99, 7, 25)
    ON CONFLICT DO NOTHING;

    SELECT id INTO v_card_id FROM finance.credit_card WHERE last_four = '3401';

    -- Get category IDs
    SELECT id INTO v_cat_payment_id FROM finance.category WHERE name = 'Payment';
    SELECT id INTO v_cat_shopping_id FROM finance.category WHERE name = 'Shopping';

    -- Payments and Other Credits
    -- 05/15 05/15 PAYMENT - THANK YOU 1067 3401 -214.93
    -- 05/15 05/16 BA ELECTRONIC PAYMENT 2951 3401 -110.00
    -- 05/15 05/16 BA ELECTRONIC PAYMENT 2969 3401 -600.00
    -- 05/18 05/19 IKEA SUNRISE SUNRISE FL 4023 3401 -48.12 (Refund?)
    INSERT INTO finance.transaction (card_id, category_id, transaction_date, post_date, amount, description) VALUES
    (v_card_id, v_cat_payment_id, '2025-05-15', '2025-05-15', 214.93, 'PAYMENT - THANK YOU'),
    (v_card_id, v_cat_payment_id, '2025-05-15', '2025-05-16', 110.00, 'BA ELECTRONIC PAYMENT'),
    (v_card_id, v_cat_payment_id, '2025-05-15', '2025-05-16', 600.00, 'BA ELECTRONIC PAYMENT'),
    (v_card_id, v_cat_shopping_id, '2025-05-18', '2025-05-19', 48.12, 'IKEA SUNRISE SUNRISE FL');

    -- Statement Summary
    -- Total Payments/Credits: $973.05
    -- Based on previous statement (July), the starting balance for July was $48.12.
    -- This means the ending balance for June (this one) must have been $48.12.
    -- If there were no purchases in this period (none provided), then:
    -- Previous Balance + Purchases - Payments = New Balance
    -- Prev Balance + 0 - 973.05 = 48.12
    -- Prev Balance = 1021.17
    
    INSERT INTO finance.statement (card_id, statement_date, due_date, statement_balance, minimum_payment, paid_amount, is_fully_paid)
    VALUES (v_card_id, '2025-06-07', '2025-07-02', 48.12, 0.00, 973.05, FALSE)
    ON CONFLICT (card_id, statement_date) DO UPDATE 
    SET statement_balance = EXCLUDED.statement_balance,
        paid_amount = EXCLUDED.paid_amount,
        is_fully_paid = EXCLUDED.is_fully_paid;

END $$;
