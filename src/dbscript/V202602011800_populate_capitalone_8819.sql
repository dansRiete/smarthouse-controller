-- Script to populate Capital One card 8819 transactions
-- Data source: 2026-02-01_transaction_download.csv

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
    VALUES ('Oleksii Kuzko', 'Capital One', '8819', 10000.00, 26.99, 15, 25)
    ON CONFLICT DO NOTHING;

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
    -- Dining -> Dining Out
    -- Lodging -> Travel
    -- Internet -> Subscription
    -- Payment/Credit -> Payment
    -- Merchandise -> Shopping or Groceries (if PUBLIX, EUROPA, WAL-MART, COSTCO, SAFEWAY, etc)
    -- Other / Other Services -> Shopping
    -- Utilities -> Utilities
    -- Health Care -> Health
    -- Gas/Automotive -> Transportation
    -- Entertainment -> Entertainment

    INSERT INTO finance.transaction (card_id, category_id, transaction_date, post_date, amount, description) VALUES
    (v_card_id, v_cat_dining_id, '2025-12-29', '2025-12-31', -22.09, 'JACK''S FISH SPOT'),
    (v_card_id, v_cat_dining_id, '2025-12-29', '2025-12-31', -52.03, 'LUKE''S LOBSTER - PIKE'),
    (v_card_id, v_cat_dining_id, '2025-12-29', '2025-12-31', -15.17, 'STARBUCKS #71537'),
    (v_card_id, v_cat_dining_id, '2025-12-29', '2025-12-30', -2.00, 'CTLP*CHARACTERS UNLIMI'),
    (v_card_id, v_cat_dining_id, '2025-12-29', '2025-12-30', -34.50, 'ALASKA AIR IN FLIGHT'),
    (v_card_id, v_cat_dining_id, '2025-12-27', '2025-12-29', -3.99, 'PY *SERGIOS'),
    (v_card_id, v_cat_travel_id, '2025-12-27', '2025-12-29', -17.50, 'RESIDENCE INN WENATCHE'),
    (v_card_id, v_cat_subscription_id, '2025-12-27', '2025-12-29', -8.00, 'WIFIONBOARD ALASKA'),
    (v_card_id, v_cat_payment_id, '2025-12-23', '2025-12-23', 570.00, 'CAPITAL ONE ONLINE PYMT'),
    (v_card_id, v_cat_groceries_id, '2025-12-22', '2025-12-23', -2.76, 'EUROPA GOURMET'),
    (v_card_id, v_cat_groceries_id, '2025-12-22', '2025-12-23', -63.95, 'EUROPA GOURMET'),
    (v_card_id, v_cat_groceries_id, '2025-12-22', '2025-12-23', -36.54, 'WILD FORK FOODS - AVEN'),
    (v_card_id, v_cat_groceries_id, '2025-12-22', '2025-12-23', -73.42, 'PUBLIX #1554'),
    (v_card_id, v_cat_shopping_id, '2025-12-19', '2025-12-20', -22.49, 'BROWARD COUNTY SCHOOL'),
    (v_card_id, v_cat_shopping_id, '2025-12-18', '2025-12-19', -126.91, 'WM SUPERCENTER #4563'),
    (v_card_id, v_cat_groceries_id, '2025-12-17', '2025-12-18', -109.82, 'PUBLIX #1554'),
    (v_card_id, v_cat_shopping_id, '2025-12-15', '2025-12-16', -47.71, 'WAL-MART #1996'),
    (v_card_id, v_cat_groceries_id, '2025-12-13', '2025-12-15', -30.09, 'PUBLIX #1554'),
    (v_card_id, v_cat_groceries_id, '2025-12-13', '2025-12-15', -38.73, 'EUROPA GOURMET'),
    (v_card_id, v_cat_groceries_id, '2025-12-13', '2025-12-15', -32.97, 'SQ *CAMPO MEAT'),
    (v_card_id, v_cat_dining_id, '2025-12-12', '2025-12-13', -15.73, 'TST*FARMERS MILK'),
    (v_card_id, v_cat_groceries_id, '2025-12-12', '2025-12-13', -25.48, 'PUBLIX #1554'),
    (v_card_id, v_cat_shopping_id, '2025-12-09', '2025-12-10', -158.82, 'WM SUPERCENTER #4563'),
    (v_card_id, v_cat_shopping_id, '2025-12-08', '2025-12-09', -22.49, 'BROWARD COUNTY SCHOOL'),
    (v_card_id, v_cat_groceries_id, '2025-12-07', '2025-12-08', -65.00, 'WWW COSTCO COM'),
    (v_card_id, v_cat_shopping_id, '2025-12-06', '2025-12-08', -6.00, 'NIC*-DEP MIZELL-JOHNSO'),
    (v_card_id, v_cat_groceries_id, '2025-12-05', '2025-12-06', -66.49, 'PUBLIX #1554'),
    (v_card_id, v_cat_shopping_id, '2025-12-05', '2025-12-06', -105.90, 'CITY OF HOLLYWOOD FL'),
    (v_card_id, v_cat_utilities_id, '2025-12-05', '2025-12-06', -209.38, 'CITY OF HOLLYWOOD'),
    (v_card_id, v_cat_health_id, '2025-12-02', '2025-12-03', -6.18, 'CVS/PHARMACY #10078'),
    (v_card_id, v_cat_shopping_id, '2025-12-02', '2025-12-03', -53.70, 'WM SUPERCENTER #4563'),
    (v_card_id, v_cat_groceries_id, '2025-11-28', '2025-11-29', -47.32, 'WHOLEFDS FFH#10715'),
    (v_card_id, v_cat_groceries_id, '2025-11-28', '2025-11-29', -77.51, 'TOTAL WINE & MORE 9'),
    (v_card_id, v_cat_payment_id, '2025-11-27', '2025-11-28', 569.69, 'CAPITAL ONE ONLINE PYMT'),
    (v_card_id, v_cat_groceries_id, '2025-11-26', '2025-11-28', -23.13, 'PUBLIX #1554'),
    (v_card_id, v_cat_shopping_id, '2025-11-26', '2025-11-28', -59.88, 'WAL-MART #4563'),
    (v_card_id, v_cat_groceries_id, '2025-11-25', '2025-11-26', -23.28, 'EUROPA GOURMET'),
    (v_card_id, v_cat_groceries_id, '2025-11-25', '2025-11-26', -53.54, 'PUBLIX #1554'),
    (v_card_id, v_cat_payment_id, '2025-11-24', '2025-11-24', 305.67, 'CREDIT-CASH BACK REWARD'),
    (v_card_id, v_cat_shopping_id, '2025-11-23', '2025-11-24', -6.00, 'NIC*-DEP MIZELL-JOHNSO'),
    (v_card_id, v_cat_shopping_id, '2025-11-21', '2025-11-22', -210.59, 'WAL-MART #4563'),
    (v_card_id, v_cat_dining_id, '2025-11-18', '2025-11-19', -112.86, 'TST*LEMONICA'),
    (v_card_id, v_cat_shopping_id, '2025-11-19', '2025-11-19', -159.08, 'Columbia 459'),
    (v_card_id, v_cat_groceries_id, '2025-11-15', '2025-11-17', -38.54, 'WILD FORK FOODS - AVEN'),
    (v_card_id, v_cat_groceries_id, '2025-11-15', '2025-11-17', -84.32, 'EUROPA GOURMET'),
    (v_card_id, v_cat_groceries_id, '2025-11-14', '2025-11-15', -20.86, 'PUBLIX #1554'),
    (v_card_id, v_cat_shopping_id, '2025-11-15', '2025-11-15', -143.80, 'Sesderma US'),
    (v_card_id, v_cat_payment_id, '2025-11-14', '2025-11-14', 946.94, 'CAPITAL ONE ONLINE PYMT'),
    (v_card_id, v_cat_shopping_id, '2025-11-13', '2025-11-14', -22.49, 'BROWARD COUNTY SCHOOL'),
    (v_card_id, v_cat_shopping_id, '2025-11-11', '2025-11-12', -152.95, 'WM SUPERCENTER #4563'),
    (v_card_id, v_cat_groceries_id, '2025-11-11', '2025-11-12', -19.98, 'SQ *CAMPO MEAT'),
    (v_card_id, v_cat_shopping_id, '2025-11-10', '2025-11-11', -11.90, 'USPS PO 1139980305'),
    (v_card_id, v_cat_groceries_id, '2025-11-10', '2025-11-11', -37.95, 'PUBLIX #1554'),
    (v_card_id, v_cat_shopping_id, '2025-11-10', '2025-11-11', -27.22, 'FEDEX OFFIC16700016766'),
    (v_card_id, v_cat_groceries_id, '2025-11-07', '2025-11-08', -8.26, 'PUBLIX #1554'),
    (v_card_id, v_cat_groceries_id, '2025-11-07', '2025-11-08', -39.99, 'EUROPA GOURMET'),
    (v_card_id, v_cat_dining_id, '2025-11-07', '2025-11-08', -16.34, 'TST*FARMERS MILK'),
    (v_card_id, v_cat_health_id, '2025-11-06', '2025-11-07', -40.00, 'CVS/PHARMACY #10078'),
    (v_card_id, v_cat_groceries_id, '2025-11-06', '2025-11-07', -18.51, 'PUBLIX #402'),
    (v_card_id, v_cat_health_id, '2025-11-06', '2025-11-07', -150.00, 'SQ *THE NEW YORK EAR,'),
    (v_card_id, v_cat_groceries_id, '2025-11-05', '2025-11-06', -78.08, 'PUBLIX #1554'),
    (v_card_id, v_cat_utilities_id, '2025-11-05', '2025-11-06', -304.27, 'CITY OF HOLLYWOOD'),
    (v_card_id, v_cat_shopping_id, '2025-11-05', '2025-11-06', -22.49, 'BROWARD COUNTY SCHOOL'),
    (v_card_id, v_cat_shopping_id, '2025-11-04', '2025-11-05', -19.00, 'SCHOLASTIC BOOK FAIRS'),
    (v_card_id, v_cat_payment_id, '2025-11-01', '2025-11-01', 854.63, 'CAPITAL ONE ONLINE PYMT'),
    (v_card_id, v_cat_transport_id, '2025-10-27', '2025-10-28', -3.00, 'HCA FL Aventura Hospit'),
    (v_card_id, v_cat_health_id, '2025-10-27', '2025-10-28', -9.58, 'CVS/PHARMACY #10078'),
    (v_card_id, v_cat_groceries_id, '2025-10-27', '2025-10-28', -10.40, 'PUBLIX #1554'),
    (v_card_id, v_cat_groceries_id, '2025-10-27', '2025-10-28', -22.86, 'EUROPA GOURMET'),
    (v_card_id, v_cat_shopping_id, '2025-10-27', '2025-10-28', -92.59, 'WM SUPERCENTER #1996'),
    (v_card_id, v_cat_groceries_id, '2025-10-27', '2025-10-28', -20.80, 'KC MARKET HALLANDALE'),
    (v_card_id, v_cat_shopping_id, '2025-10-25', '2025-10-27', -43.40, 'MARSHALLS #0541'),
    (v_card_id, v_cat_shopping_id, '2025-10-25', '2025-10-27', -109.63, 'OLD NAVY US 6062'),
    (v_card_id, v_cat_groceries_id, '2025-10-24', '2025-10-25', -90.92, 'PUBLIX #1554'),
    (v_card_id, v_cat_shopping_id, '2025-10-24', '2025-10-25', -22.49, 'BROWARD COUNTY SCHOOL'),
    (v_card_id, v_cat_dining_id, '2025-10-24', '2025-10-25', -15.73, 'TST*FARMERS MILK'),
    (v_card_id, v_cat_groceries_id, '2025-10-21', '2025-10-22', -31.77, 'PUBLIX #1554'),
    (v_card_id, v_cat_health_id, '2025-10-19', '2025-10-20', -28.01, 'CVS/PHARMACY #10078'),
    (v_card_id, v_cat_groceries_id, '2025-10-19', '2025-10-20', -47.47, 'WINN-DIXIE   #0306'),
    (v_card_id, v_cat_health_id, '2025-10-19', '2025-10-20', -50.00, 'AFC URGENT CARE-HALLAN'),
    (v_card_id, v_cat_groceries_id, '2025-10-18', '2025-10-20', -44.23, 'PUBLIX #1554'),
    (v_card_id, v_cat_dining_id, '2025-10-18', '2025-10-18', -7.50, 'TST* MIRAZUR'),
    (v_card_id, v_cat_shopping_id, '2025-10-17', '2025-10-18', -106.96, 'WAL-MART #4563'),
    (v_card_id, v_cat_payment_id, '2025-10-17', '2025-10-17', 137.58, 'CAPITAL ONE ONLINE PYMT'),
    (v_card_id, v_cat_dining_id, '2025-10-15', '2025-10-17', -97.29, 'HOLLYWOOD BREWERY'),
    (v_card_id, v_cat_payment_id, '2025-10-15', '2025-10-15', 397.35, 'CAPITAL ONE ONLINE PYMT'),
    (v_card_id, v_cat_groceries_id, '2025-10-14', '2025-10-15', -137.58, 'PUBLIX #1554'),
    (v_card_id, v_cat_shopping_id, '2025-10-13', '2025-10-14', -16.59, 'DOLLAR TREE'),
    (v_card_id, v_cat_groceries_id, '2025-10-11', '2025-10-13', -15.23, 'PUBLIX #1554'),
    (v_card_id, v_cat_dining_id, '2025-10-09', '2025-10-10', -10.00, 'TST*VERSAILLES RESTAUR'),
    (v_card_id, v_cat_dining_id, '2025-10-09', '2025-10-10', -85.41, 'TST*VERSAILLES RESTAUR'),
    (v_card_id, v_cat_groceries_id, '2025-10-08', '2025-10-09', -40.46, 'PUBLIX #1554'),
    (v_card_id, v_cat_groceries_id, '2025-10-08', '2025-10-09', -52.05, 'EUROPA GOURMET'),
    (v_card_id, v_cat_shopping_id, '2025-10-06', '2025-10-07', -116.89, 'WM SUPERCENTER #4563'),
    (v_card_id, v_cat_groceries_id, '2025-10-04', '2025-10-06', -27.16, 'PUBLIX #1693'),
    (v_card_id, v_cat_groceries_id, '2025-10-03', '2025-10-04', -24.42, 'EUROPA GOURMET'),
    (v_card_id, v_cat_groceries_id, '2025-10-03', '2025-10-04', -9.14, 'PUBLIX #1554'),
    (v_card_id, v_cat_payment_id, '2025-10-03', '2025-10-03', 53.97, 'CAPITAL ONE ONLINE PYMT'),
    (v_card_id, v_cat_shopping_id, '2025-10-01', '2025-10-02', -53.97, 'ZAHRAH USA'),
    (v_card_id, v_cat_payment_id, '2025-09-29', '2025-09-29', 74.27, 'CAPITAL ONE ONLINE PYMT'),
    (v_card_id, v_cat_utilities_id, '2025-09-25', '2025-09-26', -74.27, 'CITY OF HOLLYWOOD'),
    (v_card_id, v_cat_payment_id, '2025-09-23', '2025-09-23', 9.99, 'CAPITAL ONE ONLINE PYMT'),
    (v_card_id, v_cat_groceries_id, '2025-09-21', '2025-09-22', -9.99, 'SQ *CAMPO MEAT'),
    (v_card_id, v_cat_payment_id, '2025-09-05', '2025-09-05', 6.97, 'CAPITAL ONE ONLINE PYMT'),
    (v_card_id, v_cat_shopping_id, '2025-09-01', '2025-09-02', -6.97, 'WM SUPERCENTER #4563'),
    (v_card_id, v_cat_payment_id, '2025-08-12', '2025-08-12', 17.75, 'CAPITAL ONE ONLINE PYMT'),
    (v_card_id, v_cat_shopping_id, '2025-08-10', '2025-08-11', -17.75, 'WAL-MART #1996'),
    (v_card_id, v_cat_payment_id, '2025-07-24', '2025-07-24', 83.98, 'CAPITAL ONE ONLINE PYMT'),
    (v_card_id, v_cat_groceries_id, '2025-07-20', '2025-07-21', -84.00, 'PUBLIX #1693'),
    (v_card_id, v_cat_payment_id, '2025-07-09', '2025-07-09', 373.00, 'CAPITAL ONE ONLINE PYMT'),
    (v_card_id, v_cat_payment_id, '2025-07-09', '2025-07-09', 80.00, 'CAPITAL ONE ONLINE PYMT'),
    (v_card_id, v_cat_shopping_id, '2025-07-04', '2025-07-05', -452.98, 'CITY FURNITURE #27'),
    (v_card_id, v_cat_payment_id, '2025-06-30', '2025-06-30', 53.20, 'CAPITAL ONE ONLINE PYMT'),
    (v_card_id, v_cat_payment_id, '2025-06-28', '2025-06-28', 174.50, 'CAPITAL ONE ONLINE PYMT'),
    (v_card_id, v_cat_shopping_id, '2025-06-28', '2025-06-28', -53.20, 'MERCARI*888-325-2168'),
    (v_card_id, v_cat_payment_id, '2025-06-26', '2025-06-26', 588.00, 'CAPITAL ONE ONLINE PYMT'),
    (v_card_id, v_cat_dining_id, '2025-06-25', '2025-06-26', -7.00, 'Nyx*NAYAX VENDING 34'),
    (v_card_id, v_cat_entertainment_id, '2025-06-24', '2025-06-25', -4.99, 'APPLE.COM/BILL'),
    (v_card_id, v_cat_dining_id, '2025-06-22', '2025-06-24', -397.43, 'TAVERNA OPA HOLLYWOOD'),
    (v_card_id, v_cat_dining_id, '2025-06-21', '2025-06-23', -7.00, 'Nyx*NAYAX VENDING 34'),
    (v_card_id, v_cat_dining_id, '2025-06-20', '2025-06-21', -20.00, 'TST*VERSAILLES RESTAUR'),
    (v_card_id, v_cat_dining_id, '2025-06-18', '2025-06-19', -118.40, 'CAFE AT THE SUMMIT'),
    (v_card_id, v_cat_transport_id, '2025-06-18', '2025-06-19', -186.80, 'ParkWhiz, Inc.'),
    (v_card_id, v_cat_entertainment_id, '2025-06-17', '2025-06-18', -6.99, 'APPLE.COM/BILL'),
    (v_card_id, v_cat_shopping_id, '2025-06-14', '2025-06-16', -13.89, 'THE HOME DEPOT #6310'),
    (v_card_id, v_cat_payment_id, '2025-06-01', '2025-06-02', 11.98, 'CAPITAL ONE ONLINE PYMT'),
    (v_card_id, v_cat_entertainment_id, '2025-05-24', '2025-05-26', -4.99, 'APPLE.COM/BILL'),
    (v_card_id, v_cat_entertainment_id, '2025-05-17', '2025-05-19', -6.99, 'APPLE.COM/BILL'),
    (v_card_id, v_cat_payment_id, '2025-04-30', '2025-04-30', 4.99, 'CAPITAL ONE ONLINE PYMT'),
    (v_card_id, v_cat_entertainment_id, '2025-04-24', '2025-04-25', -4.99, 'APPLE.COM/BILL'),
    (v_card_id, v_cat_payment_id, '2025-04-23', '2025-04-23', 4.01, 'CAPITAL ONE ONLINE PYMT'),
    (v_card_id, v_cat_payment_id, '2025-04-21', '2025-04-21', 254.51, 'CAPITAL ONE ONLINE PYMT'),
    (v_card_id, v_cat_transport_id, '2025-04-19', '2025-04-21', -4.01, 'SHELL OIL57543704019'),
    (v_card_id, v_cat_entertainment_id, '2025-04-17', '2025-04-18', -254.51, 'AQUATICA ORLANDO'),
    (v_card_id, v_cat_payment_id, '2025-04-02', '2025-04-02', 4.80, 'CAPITAL ONE ONLINE PYMT'),
    (v_card_id, v_cat_payment_id, '2025-04-01', '2025-04-01', 390.00, 'CAPITAL ONE ONLINE PYMT'),
    (v_card_id, v_cat_groceries_id, '2025-03-31', '2025-04-01', -43.62, 'PUBLIX #1693'),
    (v_card_id, v_cat_payment_id, '2025-04-01', '2025-04-01', 43.62, 'CAPITAL ONE ONLINE PYMT'),
    (v_card_id, v_cat_entertainment_id, '2025-03-21', '2025-03-22', -124.99, 'APPLE.COM/BILL'),
    (v_card_id, v_cat_payment_id, '2025-03-17', '2025-03-17', 130.92, 'CAPITAL ONE ONLINE PYMT'),
    (v_card_id, v_cat_groceries_id, '2025-03-16', '2025-03-17', -81.48, 'TOTAL WINE AND MORE'),
    (v_card_id, v_cat_groceries_id, '2025-03-16', '2025-03-17', -49.44, 'PUBLIX #1693'),
    (v_card_id, v_cat_dining_id, '2025-03-08', '2025-03-10', -7.00, 'Nyx*NAYAX VENDING 34'),
    (v_card_id, v_cat_payment_id, '2025-03-08', '2025-03-08', 180.00, 'CAPITAL ONE ONLINE PYMT'),
    (v_card_id, v_cat_shopping_id, '2025-03-05', '2025-03-06', -27.80, 'JOMASHOP INC.'),
    (v_card_id, v_cat_groceries_id, '2025-03-02', '2025-03-03', -93.16, 'PUBLIX #1693'),
    (v_card_id, v_cat_shopping_id, '2025-03-02', '2025-03-03', -59.00, 'INTUIT *TURBOTAX'),
    (v_card_id, v_cat_dining_id, '2025-02-28', '2025-03-03', -91.30, 'HOLLYWOOD BREWERY'),
    (v_card_id, v_cat_groceries_id, '2025-02-28', '2025-03-03', -137.32, 'TOTAL WINE AND MORE'),
    (v_card_id, v_cat_shopping_id, '2025-03-01', '2025-03-03', -34.23, 'eBay O*22-12758-82733');

    -- Insert some statement summaries based on payment dates
    -- Statement day is 15th of the month
    INSERT INTO finance.statement (card_id, statement_date, due_date, statement_balance, minimum_payment, paid_amount, is_fully_paid) VALUES
    (v_card_id, '2025-04-15', '2025-05-10', 254.51, 25.00, 254.51, TRUE),
    (v_card_id, '2025-05-15', '2025-06-10', 11.98, 11.98, 11.98, TRUE),
    (v_card_id, '2025-06-15', '2025-07-10', 815.70, 25.00, 815.70, TRUE),
    (v_card_id, '2025-07-15', '2025-08-10', 84.00, 25.00, 83.98, FALSE),
    (v_card_id, '2025-08-15', '2025-09-10', 17.75, 17.75, 17.75, TRUE),
    (v_card_id, '2025-09-15', '2025-10-10', 6.97, 6.97, 6.97, TRUE),
    (v_card_id, '2025-10-15', '2025-11-10', 931.32, 25.00, 931.32, TRUE),
    (v_card_id, '2025-11-15', '2025-12-10', 1516.63, 35.00, 1516.63, TRUE),
    (v_card_id, '2025-12-15', '2026-01-10', 1100.00, 25.00, 570.00, FALSE)
    ON CONFLICT DO NOTHING;

END $$;
