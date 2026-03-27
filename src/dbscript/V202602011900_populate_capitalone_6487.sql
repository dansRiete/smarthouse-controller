-- Script to populate Capital One card 6487 transactions
-- Data source: 2026-02-01_transaction_download(1).csv

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
    VALUES ('Oleksii Kuzko', 'Capital One', '6487', 5000.00, 26.99, 15, 25)
    ON CONFLICT DO NOTHING;

    SELECT id INTO v_card_id FROM finance.credit_card WHERE last_four = '6487';

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
    INSERT INTO finance.transaction (card_id, category_id, transaction_date, post_date, amount, description) VALUES
    (v_card_id, v_cat_groceries_id, '2025-12-20', '2025-12-22', -14.20, 'PUBLIX #1554'),
    (v_card_id, v_cat_health_id, '2025-12-17', '2025-12-18', -50.00, 'AFC URGENT CARE-HALLAN'),
    (v_card_id, v_cat_payment_id, '2025-11-01', '2025-11-01', 29.99, 'CAPITAL ONE ONLINE PYMT'),
    (v_card_id, v_cat_subscription_id, '2025-10-17', '2025-10-18', -29.99, 'EXPERIAN* CREDIT REPO'),
    (v_card_id, v_cat_payment_id, '2025-09-18', '2025-09-18', 3.99, 'CAPITAL ONE ONLINE PYMT'),
    (v_card_id, v_cat_subscription_id, '2025-09-12', '2025-09-13', -3.99, 'Nintendo CD1466716415'),
    (v_card_id, v_cat_payment_id, '2025-08-29', '2025-08-29', 19.71, 'CAPITAL ONE ONLINE PYMT'),
    (v_card_id, v_cat_dining_id, '2025-08-18', '2025-08-19', -15.72, 'SPO*ASIANWOK&GRILLC152'),
    (v_card_id, v_cat_subscription_id, '2025-08-12', '2025-08-13', -3.99, 'Nintendo CD1450327532'),
    (v_card_id, v_cat_payment_id, '2025-07-24', '2025-07-24', 3.99, 'CAPITAL ONE ONLINE PYMT'),
    (v_card_id, v_cat_subscription_id, '2025-07-12', '2025-07-14', -3.99, 'Nintendo CD1433030946'),
    (v_card_id, v_cat_payment_id, '2025-06-26', '2025-06-26', 19.36, 'CAPITAL ONE ONLINE PYMT'),
    (v_card_id, v_cat_transport_id, '2025-06-24', '2025-06-25', -3.35, 'COH PRKING PAY BY PHON'),
    (v_card_id, v_cat_subscription_id, '2025-06-19', '2025-06-20', -4.70, 'Nintendo CA1420048867'),
    (v_card_id, v_cat_subscription_id, '2025-06-18', '2025-06-19', -11.31, 'GOOGLE *SiriusXM Music'),
    (v_card_id, v_cat_payment_id, '2025-04-21', '2025-04-21', 29.99, 'CAPITAL ONE ONLINE PYMT'),
    (v_card_id, v_cat_subscription_id, '2025-04-17', '2025-04-18', -29.99, 'EXPERIAN* CREDIT REPO'),
    (v_card_id, v_cat_payment_id, '2025-04-01', '2025-04-01', 14.98, 'CAPITAL ONE ONLINE PYMT'),
    (v_card_id, v_cat_entertainment_id, '2025-03-19', '2025-03-20', -4.99, 'APPLE.COM/BILL'),
    (v_card_id, v_cat_entertainment_id, '2025-03-17', '2025-03-18', -9.99, 'APPLE.COM/BILL'),
    (v_card_id, v_cat_payment_id, '2025-03-07', '2025-03-07', 34.99, 'CAPITAL ONE ONLINE PYMT'),
    (v_card_id, v_cat_subscription_id, '2025-02-23', '2025-02-24', -34.99, 'Nintendo CA1361927437'),
    (v_card_id, v_cat_payment_id, '2025-02-20', '2025-02-20', 156.84, 'CAPITAL ONE ONLINE PYMT'),
    (v_card_id, v_cat_shopping_id, '2025-02-18', '2025-02-19', -121.86, 'BANYAN 954-491-6355'),
    (v_card_id, v_cat_subscription_id, '2025-02-19', '2025-02-19', -5.99, 'STEAMGAMES.COM 4259522'),
    (v_card_id, v_cat_subscription_id, '2025-02-16', '2025-02-17', -3.99, 'Nintendo CA1358299270'),
    (v_card_id, v_cat_dining_id, '2025-02-10', '2025-02-11', -7.00, 'Nyx*NAYAX VENDING 34'),
    (v_card_id, v_cat_subscription_id, '2025-02-05', '2025-02-06', -9.00, 'Flightradar24 AB'),
    (v_card_id, v_cat_subscription_id, '2025-02-04', '2025-02-05', -9.00, 'Flightradar24 AB'),
    (v_card_id, v_cat_payment_id, '2025-01-22', '2025-01-22', 14.26, 'CAPITAL ONE ONLINE PYMT'),
    (v_card_id, v_cat_payment_id, '2025-01-15', '2025-01-15', 100.00, 'CAPITAL ONE ONLINE PYMT'),
    (v_card_id, v_cat_payment_id, '2025-01-15', '2025-01-15', 190.00, 'CAPITAL ONE ONLINE PYMT'),
    (v_card_id, v_cat_dining_id, '2025-01-11', '2025-01-13', -178.27, 'HOLLYWOOD BREWERY'),
    (v_card_id, v_cat_dining_id, '2025-01-08', '2025-01-10', -19.85, 'YUL URNB CRV 73'),
    (v_card_id, v_cat_shopping_id, '2025-01-08', '2025-01-09', -6.38, '3725-MNTR MAISON DE LA'),
    (v_card_id, v_cat_dining_id, '2025-01-08', '2025-01-09', -2.27, 'COCA COLA MONTREAL QC'),
    (v_card_id, v_cat_dining_id, '2025-01-08', '2025-01-09', -26.48, 'AIR CANADA ON BOARD CA'),
    (v_card_id, v_cat_travel_id, '2025-01-07', '2025-01-09', -14.77, 'HILTON MONTREAL AIRPOR'),
    (v_card_id, v_cat_travel_id, '2025-01-07', '2025-01-09', -21.79, 'HILTON MONTREAL AIRPOR'),
    (v_card_id, v_cat_payment_id, '2025-01-08', '2025-01-08', 250.66, 'CAPITAL ONE ONLINE PYMT'),
    (v_card_id, v_cat_dining_id, '2025-01-07', '2025-01-08', -0.94, 'Inamore Imb B Malpens'),
    (v_card_id, v_cat_dining_id, '2025-01-07', '2025-01-08', -5.53, 'Comptoir Libanais Mal'),
    (v_card_id, v_cat_travel_id, '2025-01-07', '2025-01-08', -15.66, 'GALAXY SERVICE S.R.L.'),
    (v_card_id, v_cat_shopping_id, '2025-01-07', '2025-01-08', -1.88, 'ACQU.DISTRIB.AUTOMATI'),
    (v_card_id, v_cat_shopping_id, '2025-01-07', '2025-01-08', -10.44, 'DUFRITAL 119 MXP T1'),
    (v_card_id, v_cat_travel_id, '2025-01-06', '2025-01-07', -15.66, 'GALAXY SERVICE S.R.L.'),
    (v_card_id, v_cat_travel_id, '2025-01-05', '2025-01-06', -110.72, 'Hotel at Booking.com');

    -- Monthly Statements (Estimated based on 15th of month)
    INSERT INTO finance.statement (card_id, statement_date, due_date, statement_balance, minimum_payment, paid_amount, is_fully_paid) VALUES
    (v_card_id, '2025-01-15', '2025-02-09', 540.66, 25.00, 540.66, TRUE),
    (v_card_id, '2025-02-15', '2025-03-12', 156.84, 25.00, 156.84, TRUE),
    (v_card_id, '2025-03-15', '2025-04-09', 34.99, 25.00, 34.99, TRUE),
    (v_card_id, '2025-04-15', '2025-05-10', 44.97, 25.00, 44.97, TRUE),
    (v_card_id, '2025-05-15', '2025-06-09', 0.00, 0.00, 0.00, TRUE),
    (v_card_id, '2025-06-15', '2025-07-10', 19.36, 25.00, 19.36, TRUE),
    (v_card_id, '2025-07-15', '2025-08-09', 3.99, 25.00, 3.99, TRUE),
    (v_card_id, '2025-08-15', '2025-09-09', 19.71, 25.00, 19.71, TRUE),
    (v_card_id, '2025-09-15', '2025-10-10', 3.99, 25.00, 3.99, TRUE),
    (v_card_id, '2025-10-15', '2025-11-09', 29.99, 25.00, 29.99, TRUE),
    (v_card_id, '2025-11-15', '2025-12-10', 0.00, 0.00, 0.00, TRUE),
    (v_card_id, '2025-12-15', '2026-01-09', 64.20, 25.00, 0.00, FALSE)
    ON CONFLICT (card_id, statement_date) DO NOTHING;

END $$;
