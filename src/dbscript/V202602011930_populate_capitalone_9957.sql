-- Script to populate Capital One card 9957 (and 0225) transactions
-- Data source: 2026-02-01_transaction_download(4).csv

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
    INSERT INTO finance.credit_card (name, bank_name, last_four, credit_limit, interest_rate_apr, statement_day_of_month, grace_period_days)
    VALUES ('Oleksii Kuzko', 'Capital One', '9957', 10000.00, 26.99, 15, 25)
    ON CONFLICT DO NOTHING;

    SELECT id INTO v_card_id FROM finance.credit_card WHERE last_four = '9957';

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
    -- Note: Card 0225 transactions are included as they belong to the same account statement.

    -- 2026
    INSERT INTO finance.transaction (card_id, category_id, transaction_date, post_date, amount, description) VALUES
    (v_card_id, v_cat_payment_id, '2026-01-04', '2026-01-05', 70.00, 'CAPITAL ONE ONLINE PYMT');

    -- 2025
    INSERT INTO finance.transaction (card_id, category_id, transaction_date, post_date, amount, description) VALUES
    (v_card_id, v_cat_travel_id, '2025-12-15', '2025-12-15', -168.52, 'AIRBNB * HMYBM5RAMY'),
    (v_card_id, v_cat_travel_id, '2025-12-11', '2025-12-12', -12.00, 'AIRBNB * HMYBM5RAMY'),
    (v_card_id, v_cat_health_id, '2025-12-02', '2025-12-03', -780.20, 'NEWSTAR DENTAL'),
    (v_card_id, v_cat_payment_id, '2025-11-27', '2025-11-28', 57.00, 'CAPITAL ONE ONLINE PYMT'),
    (v_card_id, v_cat_travel_id, '2025-11-25', '2025-11-25', -42.13, 'AIRBNB * HMYBM5RAMY'),
    (v_card_id, v_cat_payment_id, '2025-11-01', '2025-11-01', 520.00, 'CAPITAL ONE ONLINE PYMT'),
    (v_card_id, v_cat_payment_id, '2025-09-29', '2025-09-29', 63.00, 'CAPITAL ONE ONLINE PYMT'),
    (v_card_id, v_cat_travel_id, '2025-09-14', '2025-09-15', -523.80, 'AIRBNB * HMNS5CZWZR'),
    (v_card_id, v_cat_travel_id, '2025-09-09', '2025-09-10', -1078.41, 'AIRBNB * HMNS5CZWZR'),
    (v_card_id, v_cat_payment_id, '2025-08-29', '2025-08-29', 50.00, 'CAPITAL ONE ONLINE PYMT'),
    (v_card_id, v_cat_payment_id, '2025-08-29', '2025-08-29', 378.00, 'CAPITAL ONE ONLINE PYMT'),
    (v_card_id, v_cat_groceries_id, '2025-08-27', '2025-08-28', -44.04, 'PUBLIX #1554'),
    (v_card_id, v_cat_entertainment_id, '2025-08-25', '2025-08-26', -88.00, 'EVENTCARTEL.COM'),
    (v_card_id, v_cat_groceries_id, '2025-08-23', '2025-08-25', -29.49, 'Borsh'),
    (v_card_id, v_cat_groceries_id, '2025-08-22', '2025-08-23', -173.62, 'PUBLIX #1554'),
    (v_card_id, v_cat_shopping_id, '2025-08-21', '2025-08-23', -20.80, 'THE HOME DEPOT #6310'),
    (v_card_id, v_cat_payment_id, '2025-08-18', '2025-08-21', 47.51, 'PURCHASE ADJUSTMENT'),
    (v_card_id, v_cat_payment_id, '2025-08-17', '2025-08-21', 69.50, 'PURCHASE ADJUSTMENT'),
    (v_card_id, v_cat_payment_id, '2025-08-18', '2025-08-20', 347.00, 'PURCHASE ADJUSTMENT'),
    (v_card_id, v_cat_payment_id, '2025-08-18', '2025-08-20', 247.00, 'PURCHASE ADJUSTMENT'),
    (v_card_id, v_cat_shopping_id, '2025-08-17', '2025-08-20', -69.50, 'JCPENNEY 2071'),
    (v_card_id, v_cat_shopping_id, '2025-08-17', '2025-08-19', -40.01, 'ZARA USA 12063'),
    (v_card_id, v_cat_dining_id, '2025-08-18', '2025-08-19', -35.17, 'SPO*ASIANWOK&GRILLC152'),
    (v_card_id, v_cat_shopping_id, '2025-08-18', '2025-08-19', -47.51, 'WAL-MART #4303'),
    (v_card_id, v_cat_shopping_id, '2025-08-18', '2025-08-19', -247.00, 'XTRA WIRELESS LLC'),
    (v_card_id, v_cat_shopping_id, '2025-08-18', '2025-08-19', -347.00, 'XTRA WIRELESS LLC'),
    (v_card_id, v_cat_payment_id, '2025-08-17', '2025-08-18', 29.25, 'PURCHASE ADJUSTMENT'),
    (v_card_id, v_cat_payment_id, '2025-08-17', '2025-08-18', 106.12, 'PURCHASE ADJUSTMENT'),
    (v_card_id, v_cat_transport_id, '2025-08-17', '2025-08-18', -29.25, 'DC TRANSIT SERVICE CEN'),
    (v_card_id, v_cat_groceries_id, '2025-08-17', '2025-08-18', -44.55, 'EUROPA GOURMET'),
    (v_card_id, v_cat_shopping_id, '2025-08-17', '2025-08-18', -23.94, 'GAP US 6312'),
    (v_card_id, v_cat_shopping_id, '2025-08-17', '2025-08-18', -106.12, 'TARGET        00010389'),
    (v_card_id, v_cat_shopping_id, '2025-08-17', '2025-08-18', -105.24, 'JCPENNEY 2071'),
    (v_card_id, v_cat_shopping_id, '2025-08-17', '2025-08-18', -243.93, 'JCPENNEY 2071'),
    (v_card_id, v_cat_groceries_id, '2025-08-14', '2025-08-15', -142.74, 'TOTAL WINE AND MORE'),
    (v_card_id, v_cat_groceries_id, '2025-08-14', '2025-08-15', -55.52, 'WINN-DIXIE   #0306'),
    (v_card_id, v_cat_shopping_id, '2025-08-14', '2025-08-15', -36.36, 'JOMASHOP INC.'),
    (v_card_id, v_cat_groceries_id, '2025-08-14', '2025-08-15', -51.48, 'WILD FORK FOODS - AVEN'),
    (v_card_id, v_cat_groceries_id, '2025-08-14', '2025-08-15', -239.55, 'WAL-MART #1996'),
    (v_card_id, v_cat_groceries_id, '2025-08-13', '2025-08-14', -39.37, 'PUBLIX #1554'),
    (v_card_id, v_cat_utilities_id, '2025-08-13', '2025-08-14', -228.95, 'GEICO  *AUTO'),
    (v_card_id, v_cat_groceries_id, '2025-08-12', '2025-08-13', -94.66, 'PUBLIX #1554'),
    (v_card_id, v_cat_subscription_id, '2025-08-13', '2025-08-13', -4.95, 'STEAMGAMES.COM 4259522'),
    (v_card_id, v_cat_transport_id, '2025-08-11', '2025-08-13', -1.42, 'CHARGEPOINT INC'),
    (v_card_id, v_cat_dining_id, '2025-08-11', '2025-08-12', -7.49, 'IKEA SUNRISE REST'),
    (v_card_id, v_cat_shopping_id, '2025-08-11', '2025-08-12', -642.57, 'IKEA SUNRISE'),
    (v_card_id, v_cat_dining_id, '2025-08-10', '2025-08-11', -38.88, 'CAFE AT THE SUMMIT'),
    (v_card_id, v_cat_groceries_id, '2025-08-09', '2025-08-11', -63.22, 'PUBLIX #1693'),
    (v_card_id, v_cat_groceries_id, '2025-08-09', '2025-08-11', -25.21, 'EUROPA GOURMET'),
    (v_card_id, v_cat_payment_id, '2025-08-07', '2025-08-09', 15.81, 'PUBLIX #1554'),
    (v_card_id, v_cat_groceries_id, '2025-08-08', '2025-08-09', -37.30, 'PUBLIX #1693'),
    (v_card_id, v_cat_shopping_id, '2025-08-07', '2025-08-09', -57.53, 'THE HOME DEPOT #6310'),
    (v_card_id, v_cat_groceries_id, '2025-08-07', '2025-08-08', -40.16, 'PUBLIX #1554'),
    (v_card_id, v_cat_groceries_id, '2025-08-05', '2025-08-06', -16.94, 'PUBLIX #1693'),
    (v_card_id, v_cat_groceries_id, '2025-08-04', '2025-08-05', -64.32, 'PUBLIX #1554'),
    (v_card_id, v_cat_groceries_id, '2025-08-04', '2025-08-05', -282.16, 'WAL-MART #1996'),
    (v_card_id, v_cat_groceries_id, '2025-08-03', '2025-08-04', -46.08, 'PUBLIX #1554'),
    (v_card_id, v_cat_shopping_id, '2025-08-03', '2025-08-04', -187.31, 'LOWES #01681*'),
    (v_card_id, v_cat_dining_id, '2025-08-02', '2025-08-04', -41.95, 'FIREHOUSE SUBS 096 QSR'),
    (v_card_id, v_cat_groceries_id, '2025-08-01', '2025-08-02', -122.44, 'TOTAL WINE AND MORE'),
    (v_card_id, v_cat_payment_id, '2025-07-31', '2025-07-31', 25.00, 'CAPITAL ONE ONLINE PYMT'),
    (v_card_id, v_cat_groceries_id, '2025-07-30', '2025-07-31', -63.94, 'PUBLIX #1693'),
    (v_card_id, v_cat_shopping_id, '2025-07-29', '2025-07-31', -588.49, 'THE WEBSTAURANT STORE'),
    (v_card_id, v_cat_dining_id, '2025-07-28', '2025-07-30', -96.62, 'HOLLYWOOD BREWERY'),
    (v_card_id, v_cat_groceries_id, '2025-07-25', '2025-07-26', -75.61, 'WM SUPERCENTER #1996'),
    (v_card_id, v_cat_travel_id, '2025-07-09', '2025-07-10', -309.00, 'PY *SKYEAGLE AVIATION'),
    (v_card_id, v_cat_payment_id, '2025-07-09', '2025-07-09', 537.00, 'CAPITAL ONE MOBILE PYMT'),
    (v_card_id, v_cat_groceries_id, '2025-07-08', '2025-07-09', -199.61, 'WM SUPERCENTER #1996'),
    (v_card_id, v_cat_dining_id, '2025-07-04', '2025-07-05', -71.89, 'TST*BANCHEROS HALLANDA'),
    (v_card_id, v_cat_shopping_id, '2025-07-04', '2025-07-05', -18.18, 'BRANDSMART USA DP'),
    (v_card_id, v_cat_travel_id, '2025-07-02', '2025-07-03', -618.00, 'PY *SKYEAGLE AVIATION'),
    (v_card_id, v_cat_groceries_id, '2025-07-01', '2025-07-02', -77.71, 'PUBLIX #402'),
    (v_card_id, v_cat_shopping_id, '2025-07-01', '2025-07-01', -150.00, 'SQ *TENANTEVALUATION'),
    (v_card_id, v_cat_groceries_id, '2025-06-26', '2025-06-27', -19.41, 'PUBLIX #1554');

    -- Monthly Statements (Estimated based on 15th of month)
    INSERT INTO finance.statement (card_id, statement_date, due_date, statement_balance, minimum_payment, paid_amount, is_fully_paid) VALUES
    (v_card_id, '2025-07-15', '2025-08-09', 1215.14, 30.00, 1215.14, TRUE),
    (v_card_id, '2025-08-15', '2025-09-09', 3000.00, 75.00, 3000.00, TRUE), -- High usage in Aug
    (v_card_id, '2025-09-15', '2025-10-10', 1602.21, 40.00, 63.00, FALSE),
    (v_card_id, '2025-10-15', '2025-11-09', 1539.21, 40.00, 520.00, FALSE),
    (v_card_id, '2025-11-15', '2025-12-10', 1019.21, 25.00, 57.00, FALSE),
    (v_card_id, '2025-12-15', '2026-01-09', 1922.86, 48.00, 70.00, FALSE)
    ON CONFLICT (card_id, statement_date) DO NOTHING;

END $$;
