-- Script to populate statement for Amazon card ID 30
-- Period: November - December 2025
-- Categorizing based on descriptions

DO $$
DECLARE
    v_card_id INTEGER := 30;
    v_cat_payment_id INTEGER;
    v_cat_shopping_id INTEGER;
    v_cat_entertainment_id INTEGER;
    v_cat_subscription_id INTEGER;
BEGIN
    -- Ensure categories exist
    INSERT INTO finance.category (name) VALUES ('Entertainment'), ('Subscription'), ('Shopping') ON CONFLICT (name) DO NOTHING;

    -- Get category IDs
    SELECT id INTO v_cat_payment_id FROM finance.category WHERE name = 'Payment';
    SELECT id INTO v_cat_shopping_id FROM finance.category WHERE name = 'Shopping';
    SELECT id INTO v_cat_entertainment_id FROM finance.category WHERE name = 'Entertainment';
    SELECT id INTO v_cat_subscription_id FROM finance.category WHERE name = 'Subscription';

    -- Payments
    -- 11/27 ONLINE PYMT-THANK YOU ATLANTA $241.79
    INSERT INTO finance.transaction (card_id, category_id, transaction_date, post_date, amount, description) VALUES
    (v_card_id, v_cat_payment_id, '2025-11-27', '2025-11-27', 241.79, 'ONLINE PYMT-THANK YOU ATLANTA');

    -- Purchases
    -- 11/25 PlayStation DualSense Wireless Controller $188.13
    INSERT INTO finance.transaction (card_id, category_id, transaction_date, post_date, amount, description) VALUES
    (v_card_id, v_cat_entertainment_id, '2025-11-25', '2025-11-25', -188.13, 'AMAZON RETAIL: PlayStation DualSense Wireless');

    -- 11/25 PS5 Controller Charging Station $58.84
    INSERT INTO finance.transaction (card_id, category_id, transaction_date, post_date, amount, description) VALUES
    (v_card_id, v_cat_entertainment_id, '2025-11-25', '2025-11-25', -58.84, 'AMAZON MARKETPLACE: PS5 Controller Charging Station');

    -- 11/25 AMAZON PRIME CONS $17.75
    INSERT INTO finance.transaction (card_id, category_id, transaction_date, post_date, amount, description) VALUES
    (v_card_id, v_cat_subscription_id, '2025-11-25', '2025-11-25', -17.75, 'AMAZON PRIME CONS');

    -- 12/07 Extension Selfie $15.13
    INSERT INTO finance.transaction (card_id, category_id, transaction_date, post_date, amount, description) VALUES
    (v_card_id, v_cat_shopping_id, '2025-12-07', '2025-12-07', -15.13, 'AMAZON MARKETPLACE: Trehapuva 28" Extension Selfie');

    -- 12/08 OMOTON / SPIDERCASE / Debrox $18.18
    INSERT INTO finance.transaction (card_id, category_id, transaction_date, post_date, amount, description) VALUES
    (v_card_id, v_cat_shopping_id, '2025-12-08', '2025-12-08', -18.18, 'AMAZON MARKETPLACE: OMOTON/SPIDERCASE/Debrox');

    -- 12/12 SONGMICS 15 Inches Cube Storage $39.74
    INSERT INTO finance.transaction (card_id, category_id, transaction_date, post_date, amount, description) VALUES
    (v_card_id, v_cat_shopping_id, '2025-12-12', '2025-12-12', -39.74, 'AMAZON RETAIL: SONGMICS 15 Inches Cube Storage');

    -- 12/12 Additional amount listed in details $38.49
    -- Categorized as Shopping as well
    INSERT INTO finance.transaction (card_id, category_id, transaction_date, post_date, amount, description) VALUES
    (v_card_id, v_cat_shopping_id, '2025-12-12', '2025-12-12', -38.49, 'AMAZON RETAIL: Additional Item/Adjustment');

    -- Statement Summary
    -- Total Purchases: 188.13 + 58.84 + 17.75 + 15.13 + 18.18 + 39.74 + 38.49 = 376.26
    -- Total Payments: 241.79
    -- Statement Balance: Assuming starting balance was 0, new balance 376.26 - 241.79 = 134.47
    
    INSERT INTO finance.statement (card_id, statement_date, due_date, statement_balance, minimum_payment, paid_amount, is_fully_paid)
    VALUES (v_card_id, '2025-12-23', '2026-01-17', 134.47, 25.00, 241.79, FALSE)
    ON CONFLICT (card_id, statement_date) DO UPDATE 
    SET statement_balance = EXCLUDED.statement_balance,
        paid_amount = EXCLUDED.paid_amount,
        is_fully_paid = EXCLUDED.is_fully_paid;

END $$;
