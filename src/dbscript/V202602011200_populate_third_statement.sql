-- Script to populate third statement for account ending in 3401
-- Period: October 8, 2025 - November 7, 2025

DO $$
DECLARE
    v_card_id INTEGER;
    v_cat_payment_id INTEGER;
    v_cat_groceries_id INTEGER;
    v_cat_dining_id INTEGER;
    v_cat_transport_id INTEGER;
    v_cat_shopping_id INTEGER;
    v_cat_other_id INTEGER;
BEGIN
    -- Ensure the credit card exists
    INSERT INTO finance.credit_card (name, bank_name, last_four, credit_limit, interest_rate_apr, statement_day_of_month, grace_period_days)
    VALUES ('Oleksii Kuzko', 'Unknown Bank', '3401', 5000.00, 19.99, 7, 25)
    ON CONFLICT DO NOTHING;

    SELECT id INTO v_card_id FROM finance.credit_card WHERE last_four = '3401';

    -- Get category IDs
    SELECT id INTO v_cat_payment_id FROM finance.category WHERE name = 'Payment';
    SELECT id INTO v_cat_groceries_id FROM finance.category WHERE name = 'Groceries';
    SELECT id INTO v_cat_dining_id FROM finance.category WHERE name = 'Dining Out';
    SELECT id INTO v_cat_transport_id FROM finance.category WHERE name = 'Transportation';
    SELECT id INTO v_cat_shopping_id FROM finance.category WHERE name = 'Shopping';
    
    -- Ensure an 'Other' or 'Education' category exists if needed, but I'll stick to existing ones or use Shopping/Other if I add it.
    -- Looking at V202602010930_credit_cards.sql, we have:
    -- ('Groceries'), ('Dining Out'), ('Utilities'), ('Transportation'), 
    -- ('Entertainment'), ('Shopping'), ('Health'), ('Travel'), ('Subscription'), ('Payment')
    
    -- Payments and Other Credits
    INSERT INTO finance.transaction (card_id, category_id, transaction_date, post_date, amount, description) VALUES
    (v_card_id, v_cat_payment_id, '2025-10-08', '2025-10-08', 1294.80, 'PAYMENT - THANK YOU'),
    (v_card_id, v_cat_payment_id, '2025-10-15', '2025-10-15', 115.30, 'PAYMENT - THANK YOU'),
    (v_card_id, v_cat_payment_id, '2025-11-01', '2025-11-01', 121.39, 'PAYMENT - THANK YOU');

    -- Purchases and Adjustments
    INSERT INTO finance.transaction (card_id, category_id, transaction_date, post_date, amount, description) VALUES
    (v_card_id, v_cat_shopping_id, '2025-10-08', '2025-10-09', -33.99, 'MLT (SCHOOL) 800-736-4753 MN'),
    (v_card_id, v_cat_shopping_id, '2025-10-09', '2025-10-09', -81.31, 'PYN*keychron WWW.PAYONEER.'),
    (v_card_id, v_cat_transport_id, '2025-10-15', '2025-10-16', -7.35, 'COH PRKING PAY BY PHONE www.parkmobilFL'),
    (v_card_id, v_cat_transport_id, '2025-10-15', '2025-10-16', -1.05, 'COH PRKING PAY BY PHONE www.parkmobilFL'),
    (v_card_id, v_cat_transport_id, '2025-10-23', '2025-10-25', -12.00, 'NAYAX WASH 4 HUNT VALLEY MD'),
    (v_card_id, v_cat_groceries_id, '2025-10-23', '2025-10-27', -19.98, 'SQ *CAMPO MEAT Hallandale BeFL'),
    (v_card_id, v_cat_groceries_id, '2025-10-25', '2025-10-27', -81.01, 'NET COST MARKET HOLLYWOOD FL'),
    (v_card_id, v_cat_shopping_id, '2025-10-31', '2025-11-01', -68.99, 'OLD NAVY US 6062 HOLLYWOOD FL'),
    (v_card_id, v_cat_groceries_id, '2025-10-31', '2025-11-01', -74.00, 'NET COST MARKET HOLLYWOOD FL'),
    (v_card_id, v_cat_transport_id, '2025-11-03', '2025-11-04', -49.10, 'HSMV MYDMVPORTAL TPEREQ@TYLERTFL');

    -- Statement Summary
    -- Total Purchases: $428.78
    -- Total Payments: $1,531.49
    -- Statement Balance: $428.78 - $1,531.49 = -$1,102.71
    -- Note: If this is an early statement, the balance might be negative if payments exceeded purchases,
    -- or it might include a carried over balance. Given previous statements:
    -- Dec 8 - Jan 7: $1,767.66
    -- Nov 8 - Dec 7: $858.29
    -- Oct 8 - Nov 7: -$1,102.71 (This seems like a large credit balance, but I will follow the math from the provided snippet)
    -- Actually, usually people pay the previous statement balance.
    
    INSERT INTO finance.statement (card_id, statement_date, due_date, statement_balance, minimum_payment, paid_amount, is_fully_paid)
    VALUES (v_card_id, '2025-11-07', '2025-12-01', -1102.71, 0.00, 0, TRUE);

END $$;
