-- Script to populate Capital One card 8819 transactions from January 2026
-- Data source: 2026-02-01_transaction_download(3).csv

DO $$
DECLARE
    v_card_id INTEGER;
    v_cat_groceries_id INTEGER;
    v_cat_dining_id INTEGER;
    v_cat_utilities_id INTEGER;
    v_cat_transport_id INTEGER;
    v_cat_entertainment_id INTEGER;
    v_cat_shopping_id INTEGER;
    v_cat_health_id INTEGER;
    v_cat_travel_id INTEGER;
    v_cat_subscription_id INTEGER;
    v_cat_payment_id INTEGER;
BEGIN
    -- Ensure Capital One card exists
    SELECT id INTO v_card_id FROM finance.credit_card WHERE last_four = '8819';

    -- Get category IDs
    SELECT id INTO v_cat_groceries_id FROM finance.category WHERE name = 'Groceries';
    SELECT id INTO v_cat_dining_id FROM finance.category WHERE name = 'Dining Out';
    SELECT id INTO v_cat_utilities_id FROM finance.category WHERE name = 'Utilities';
    SELECT id INTO v_cat_transport_id FROM finance.category WHERE name = 'Transportation';
    SELECT id INTO v_cat_entertainment_id FROM finance.category WHERE name = 'Entertainment';
    SELECT id INTO v_cat_shopping_id FROM finance.category WHERE name = 'Shopping';
    SELECT id INTO v_cat_health_id FROM finance.category WHERE name = 'Health';
    SELECT id INTO v_cat_travel_id FROM finance.category WHERE name = 'Travel';
    SELECT id INTO v_cat_subscription_id FROM finance.category WHERE name = 'Subscription';
    SELECT id INTO v_cat_payment_id FROM finance.category WHERE name = 'Payment';

    -- Insert Transactions from CSV
    -- Mapping:
    -- BROWARD COUNTY SCHOOL -> Shopping
    -- NETFLIX.COM -> Subscription
    -- WAL-MART -> Groceries
    -- PUBLIX -> Groceries
    -- EUROPA GOURMET -> Groceries
    -- Europcar.com -> Travel
    -- FARMER'S MILK -> Dining Out
    -- CAPITAL ONE ONLINE PYMT -> Payment
    -- NIC*-DEP MIZELL-JOHNSO -> Shopping
    -- CITY OF HOLLYWOOD -> Utilities
    -- AIRPORT CONCESSIONS NW -> Dining Out
    -- THE MUSEUM OF FLIGHT M -> Entertainment
    -- PIKE&PINE -> Shopping
    -- ALASKA AIR -> Dining Out (per CSV categorization)
    -- BULLWHEEL REST CRYSTAL -> Dining Out

    INSERT INTO finance.transaction (card_id, category_id, transaction_date, post_date, amount, description) VALUES
    (v_card_id, v_cat_shopping_id, '2026-01-30', '2026-01-31', -22.49, 'BROWARD COUNTY SCHOOL'),
    (v_card_id, v_cat_subscription_id, '2026-01-30', '2026-01-31', -28.28, 'NETFLIX.COM'),
    (v_card_id, v_cat_groceries_id, '2026-01-29', '2026-01-30', -84.67, 'WAL-MART #4563'),
    (v_card_id, v_cat_groceries_id, '2026-01-28', '2026-01-29', -30.69, 'PUBLIX #1554'),
    (v_card_id, v_cat_groceries_id, '2026-01-27', '2026-01-28', -30.92, 'EUROPA GOURMET'),
    (v_card_id, v_cat_travel_id, '2026-01-23', '2026-01-26', -233.87, 'Europcar.com/us USD pr'),
    (v_card_id, v_cat_dining_id, '2026-01-24', '2026-01-24', -6.95, 'TST* FARMER''S MILK'),
    (v_card_id, v_cat_groceries_id, '2026-01-23', '2026-01-24', -33.72, 'PUBLIX #1554'),
    (v_card_id, v_cat_groceries_id, '2026-01-21', '2026-01-22', -44.68, 'EUROPA GOURMET'),
    (v_card_id, v_cat_groceries_id, '2026-01-20', '2026-01-21', -45.35, 'PUBLIX #1554'),
    (v_card_id, v_cat_shopping_id, '2026-01-20', '2026-01-21', -22.49, 'BROWARD COUNTY SCHOOL'),
    (v_card_id, v_cat_groceries_id, '2026-01-19', '2026-01-20', -222.57, 'WAL-MART #4563'),
    (v_card_id, v_cat_groceries_id, '2026-01-17', '2026-01-19', -44.90, 'PUBLIX #1554'),
    (v_card_id, v_cat_dining_id, '2026-01-17', '2026-01-17', -7.07, 'TST* FARMER''S MILK'),
    (v_card_id, v_cat_groceries_id, '2026-01-16', '2026-01-17', -66.17, 'PUBLIX #1554'),
    (v_card_id, v_cat_payment_id, '2026-01-15', '2026-01-15', 505.40, 'CAPITAL ONE ONLINE PYMT'),
    (v_card_id, v_cat_groceries_id, '2026-01-14', '2026-01-15', -19.79, 'PUBLIX #1554'),
    (v_card_id, v_cat_shopping_id, '2026-01-11', '2026-01-12', -6.00, 'NIC*-DEP MIZELL-JOHNSO'),
    (v_card_id, v_cat_dining_id, '2026-01-10', '2026-01-10', -7.93, 'TST* FARMER''S MILK'),
    (v_card_id, v_cat_groceries_id, '2026-01-09', '2026-01-10', -3.99, 'PUBLIX #1554'),
    (v_card_id, v_cat_groceries_id, '2026-01-08', '2026-01-09', -56.28, 'EUROPA GOURMET'),
    (v_card_id, v_cat_groceries_id, '2026-01-08', '2026-01-09', -182.25, 'WAL-MART #1996'),
    (v_card_id, v_cat_groceries_id, '2026-01-06', '2026-01-07', -30.11, 'PUBLIX #1554'),
    (v_card_id, v_cat_payment_id, '2026-01-04', '2026-01-05', 253.00, 'CAPITAL ONE ONLINE PYMT'),
    (v_card_id, v_cat_payment_id, '2026-01-04', '2026-01-05', 200.00, 'CAPITAL ONE ONLINE PYMT'),
    (v_card_id, v_cat_utilities_id, '2026-01-04', '2026-01-05', -200.54, 'CITY OF HOLLYWOOD'),
    (v_card_id, v_cat_dining_id, '2026-01-03', '2026-01-05', -92.67, 'AIRPORT CONCESSIONS NW'),
    (v_card_id, v_cat_entertainment_id, '2026-01-03', '2026-01-05', -20.00, 'THE MUSEUM OF FLIGHT M'),
    (v_card_id, v_cat_entertainment_id, '2026-01-03', '2026-01-05', -79.00, 'THE MUSEUM OF FLIGHT M'),
    (v_card_id, v_cat_shopping_id, '2026-01-03', '2026-01-05', -31.88, 'PIKE&PINE ST2275'),
    (v_card_id, v_cat_dining_id, '2026-01-04', '2026-01-05', -17.25, 'ALASKA AIR* QC52WGQA8'),
    (v_card_id, v_cat_dining_id, '2026-01-02', '2026-01-05', -14.29, 'BULLWHEEL REST CRYSTAL');

    -- Update/Insert Statement for January 15, 2026
    -- From V202602011800, we had a statement for 2025-12-15.
    -- The next one is likely 2026-01-15.
    -- Based on the CSV, we have a payment of 505.40 on Jan 15.
    
    INSERT INTO finance.statement (card_id, statement_date, due_date, statement_balance, minimum_payment, paid_amount, is_fully_paid)
    VALUES (v_card_id, '2026-01-15', '2026-02-09', 505.40, 25.00, 505.40, TRUE)
    ON CONFLICT (card_id, statement_date) 
    DO UPDATE SET 
        statement_balance = EXCLUDED.statement_balance,
        paid_amount = EXCLUDED.paid_amount,
        is_fully_paid = EXCLUDED.is_fully_paid;

END $$;
