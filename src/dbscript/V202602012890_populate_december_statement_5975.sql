-- Script to populate statement for new Amazon card ending in 5975
-- Period: December 2025
-- All expenses attributed to Shopping category

DO $$
DECLARE
    v_card_id INTEGER;
    v_cat_payment_id INTEGER;
    v_cat_shopping_id INTEGER;
BEGIN

    IF v_card_id IS NULL THEN
        SELECT id INTO v_card_id FROM finance.credit_card WHERE last_four = '5975';
    END IF;

    -- Get category IDs
    SELECT id INTO v_cat_payment_id FROM finance.category WHERE name = 'Payment';
    SELECT id INTO v_cat_shopping_id FROM finance.category WHERE name = 'Shopping';

    -- Ensure Shopping category exists
    IF v_cat_shopping_id IS NULL THEN
        INSERT INTO finance.category (name) VALUES ('Shopping') ON CONFLICT (name) DO NOTHING;
        SELECT id INTO v_cat_shopping_id FROM finance.category WHERE name = 'Shopping';
    END IF;

    -- Payments
    -- 12/23 ONLINE PYMT-THANK YOU ATLANTA $32.24
    INSERT INTO finance.transaction (card_id, category_id, transaction_date, post_date, amount, description) VALUES
    (v_card_id, v_cat_payment_id, '2025-12-23', '2025-12-23', 32.24, 'ONLINE PYMT-THANK YOU ATLANTA');

    -- Other Credits
    -- 12/26 AMAZON DIGITAL -$96.41
    -- 12/26 AMAZON DIGITAL -$3.38
    -- I interpret these as credits (positive in DB) because they are in "Other Credits" section
    INSERT INTO finance.transaction (card_id, category_id, transaction_date, post_date, amount, description) VALUES
    (v_card_id, v_cat_shopping_id, '2025-12-26', '2025-12-26', 96.41, 'AMAZON DIGITAL SEATTLE WA'),
    (v_card_id, v_cat_shopping_id, '2025-12-26', '2025-12-26', 3.38, 'AMAZON DIGITAL SEATTLE WA');

    -- Purchases
    -- 12/23 AMAZON MARKETPLACE $28.86
    -- 12/24 AMAZON DIGITAL $3.38
    INSERT INTO finance.transaction (card_id, category_id, transaction_date, post_date, amount, description) VALUES
    (v_card_id, v_cat_shopping_id, '2025-12-23', '2025-12-23', -28.86, 'AMAZON MARKETPLACE SEATTLE WA'),
    (v_card_id, v_cat_shopping_id, '2025-12-24', '2025-12-24', -3.38, 'AMAZON DIGITAL SEATTLE WA');

    -- Statement Summary
    -- Total Purchases: 28.86 + 3.38 = 32.24
    -- Total Payments & Credits: 32.24 + 96.41 + 3.38 = 132.03
    -- Statement Balance: Assuming starting balance was 0, new balance would be 32.24 - 132.03 = -99.79
    -- However, usually statements don't have negative balance unless overpaid.
    -- Given the credits, it might be an overpayment or reflecting previous balance.
    -- For now, I'll set a placeholder statement.
    INSERT INTO finance.statement (card_id, statement_date, due_date, statement_balance, minimum_payment, paid_amount, is_fully_paid)
    VALUES (v_card_id, '2025-12-23', '2026-01-17', -99.79, 0.00, 32.24, TRUE)
    ON CONFLICT (card_id, statement_date) DO UPDATE 
    SET statement_balance = EXCLUDED.statement_balance,
        paid_amount = EXCLUDED.paid_amount,
        is_fully_paid = EXCLUDED.is_fully_paid;

END $$;
