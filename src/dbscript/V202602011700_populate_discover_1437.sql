-- Script to populate Discover card 1437 transactions and statements
-- Data source: Discover-Last12Months-20260201.csv

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
    
    v_trans_count INTEGER := 0;
BEGIN
    -- Ensure Discover card exists
    INSERT INTO finance.credit_card (name, bank_name, last_four, credit_limit, interest_rate_apr, statement_day_of_month, grace_period_days)
    VALUES ('Oleksii Kuzko', 'Discover', '1437', 10000.00, 24.99, 5, 25)
    ON CONFLICT DO NOTHING;

    SELECT id INTO v_card_id FROM finance.credit_card WHERE last_four = '1437';

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
    -- Merchandise -> Shopping (usually)
    -- Supermarkets -> Groceries
    -- Payments and Credits -> Payment
    -- Services -> Subscription or Utilities (depending on description)
    -- Gasoline -> Transportation
    -- Restaurants -> Dining Out
    -- Travel/ Entertainment -> Travel or Entertainment

    -- Jan 2025
    INSERT INTO finance.transaction (card_id, category_id, transaction_date, post_date, amount, description) VALUES
    (v_card_id, v_cat_subscription_id, '2025-01-05', '2025-01-07', -10.00, '1XJETBRAINS AI PRO SAN MATEO CA'),
    (v_card_id, v_cat_groceries_id, '2025-01-09', '2025-01-09', -88.77, 'PUBLIX #1554 HOLLYWOOD FL'),
    (v_card_id, v_cat_payment_id, '2025-01-10', '2025-01-10', 306.09, 'INTERNET PAYMENT - THANK YOU'),
    (v_card_id, v_cat_shopping_id, '2025-01-11', '2025-01-11', -46.14, 'MAKEUP.PL OLSZTYN POL44.71 @ 00000001.0319839 EUR'),
    (v_card_id, v_cat_subscription_id, '2025-01-12', '2025-01-12', -11.99, 'JOTTACLOUD 28671222 21042900 NOR'),
    (v_card_id, v_cat_payment_id, '2025-01-15', '2025-01-15', 146.90, 'INTERNET PAYMENT - THANK YOU'),
    (v_card_id, v_cat_subscription_id, '2025-01-16', '2025-01-16', -9.99, 'ADOBE *ADOBE 408-536-6000 CA'),
    (v_card_id, v_cat_utilities_id, '2025-01-17', '2025-01-17', -103.91, 'GOOGLE *FI GH5XL3 G.CO/HELPPAY#CAP18GVZMT'),
    (v_card_id, v_cat_shopping_id, '2025-01-21', '2025-01-21', -13.99, 'GOOGLE *ASTROCHARTSAPP G.CO/HELPPAY#CAP18LYVUT'),
    (v_card_id, v_cat_subscription_id, '2025-01-22', '2025-01-22', -1.99, '1PASSWORD 8668127277 CAN'),
    (v_card_id, v_cat_subscription_id, '2025-01-22', '2025-01-22', -11.30, 'HELP.MAX.COM 8559426669 NY'),
    (v_card_id, v_cat_payment_id, '2025-01-22', '2025-01-22', 127.89, 'INTERNET PAYMENT - THANK YOU');

    -- Feb 2025
    INSERT INTO finance.transaction (card_id, category_id, transaction_date, post_date, amount, description) VALUES
    (v_card_id, v_cat_subscription_id, '2025-02-05', '2025-02-07', -10.00, '1XJETBRAINS AI PRO SAN MATEO CA'),
    (v_card_id, v_cat_shopping_id, '2025-02-10', '2025-02-10', -32.59, 'SHEIN.COM KENT DE'),
    (v_card_id, v_cat_subscription_id, '2025-02-12', '2025-02-12', -11.99, 'JOTTACLOUD 29109791 21042900 NOR'),
    (v_card_id, v_cat_subscription_id, '2025-02-16', '2025-02-16', -9.99, 'ADOBE *ADOBE 408-536-6000 CA'),
    (v_card_id, v_cat_utilities_id, '2025-02-17', '2025-02-17', -184.34, 'GOOGLE *FI W3MQN9 G.CO/HELPPAY#CAP191USYJ'),
    (v_card_id, v_cat_payment_id, '2025-02-20', '2025-02-20', 262.20, 'INTERNET PAYMENT - THANK YOU'),
    (v_card_id, v_cat_subscription_id, '2025-02-22', '2025-02-22', -1.99, '1PASSWORD 8668127277 CAN'),
    (v_card_id, v_cat_groceries_id, '2025-02-22', '2025-02-22', -9.70, 'PUBLIX #402 HALLANDALE FLGOOGLE PAY ENDING IN 5097');

    -- March 2025
    INSERT INTO finance.transaction (card_id, category_id, transaction_date, post_date, amount, description) VALUES
    (v_card_id, v_cat_groceries_id, '2025-03-04', '2025-03-04', -59.85, 'EUROPA GOURMET HOLLYWOOD FL'),
    (v_card_id, v_cat_shopping_id, '2025-03-04', '2025-03-04', -213.27, 'WALMART STORE 01996 HALLANDALE FL'),
    (v_card_id, v_cat_subscription_id, '2025-03-05', '2025-03-07', -10.00, '1XJETBRAINS AI PRO SAN MATEO CA'),
    (v_card_id, v_cat_groceries_id, '2025-03-05', '2025-03-07', -46.08, 'PUBLIX #1554 HOLLYWOOD FL'),
    (v_card_id, v_cat_groceries_id, '2025-03-08', '2025-03-08', -43.29, 'PUBLIX #1554 HOLLYWOOD FLGOOGLE PAY ENDING IN 5097'),
    (v_card_id, v_cat_groceries_id, '2025-03-09', '2025-03-09', -32.88, 'PUBLIX #1693 HOLLYWOOD FLGOOGLE PAY ENDING IN 5097'),
    (v_card_id, v_cat_groceries_id, '2025-03-11', '2025-03-11', -85.42, 'PUBLIX #1554 HOLLYWOOD FL'),
    (v_card_id, v_cat_subscription_id, '2025-03-12', '2025-03-12', -11.99, 'JOTTACLOUD 29534243 21042900 NOR'),
    (v_card_id, v_cat_shopping_id, '2025-03-12', '2025-03-12', -32.07, 'SCHOLASTIC BOOK FAIRS R4 LAKE MARY FL'),
    (v_card_id, v_cat_payment_id, '2025-03-13', '2025-03-13', 417.06, 'INTERNET PAYMENT - THANK YOU'),
    (v_card_id, v_cat_subscription_id, '2025-03-15', '2025-03-15', -9.90, '1XCLION SAN MATEO CA'),
    (v_card_id, v_cat_subscription_id, '2025-03-16', '2025-03-16', -9.99, 'ADOBE *ADOBE 408-536-6000 CA'),
    (v_card_id, v_cat_utilities_id, '2025-03-17', '2025-03-17', -125.10, 'GOOGLE *FI PWX24T G.CO/HELPPAY#CAP19LTBAZ'),
    (v_card_id, v_cat_groceries_id, '2025-03-17', '2025-03-17', -68.59, 'PUBLIX #1554 HOLLYWOOD FL'),
    (v_card_id, v_cat_subscription_id, '2025-03-22', '2025-03-22', -1.99, '1PASSWORD 8668127277 CAN'),
    (v_card_id, v_cat_shopping_id, '2025-03-22', '2025-03-22', -4.82, 'DOLLAR TREE HALLANDALE BEFL'),
    (v_card_id, v_cat_groceries_id, '2025-03-22', '2025-03-22', -17.75, 'PUBLIX #1693 HOLLYWOOD FL'),
    (v_card_id, v_cat_groceries_id, '2025-03-22', '2025-03-22', -37.56, 'TOTAL WINE AND MORE MIAMI FLGOOGLE PAY ENDING IN 5097'),
    (v_card_id, v_cat_groceries_id, '2025-03-22', '2025-03-22', -89.42, 'WILD FORK FOODS - AVENTU AVENTURA FL'),
    (v_card_id, v_cat_payment_id, '2025-03-24', '2025-03-24', 472.03, 'INTERNET PAYMENT - THANK YOU'),
    (v_card_id, v_cat_shopping_id, '2025-03-24', '2025-03-24', -298.42, 'WALMART STORE 01996 HALLANDALE FL'),
    (v_card_id, v_cat_transport_id, '2025-03-28', '2025-03-28', -39.14, 'CHEVRON 0378283 954-491-0094 FL00378283 9067824 M'),
    (v_card_id, v_cat_payment_id, '2025-03-29', '2025-03-29', 360.13, 'INTERNET PAYMENT - THANK YOU'),
    (v_card_id, v_cat_groceries_id, '2025-03-29', '2025-03-29', -54.37, 'PUBLIX #1693 HOLLYWOOD FLGOOGLE PAY ENDING IN 5097');

    -- April 2025
    INSERT INTO finance.transaction (card_id, category_id, transaction_date, post_date, amount, description) VALUES
    (v_card_id, v_cat_groceries_id, '2025-04-01', '2025-04-01', -107.99, 'EUROPA GOURMET HOLLYWOOD FL'),
    (v_card_id, v_cat_groceries_id, '2025-04-01', '2025-04-01', -59.55, 'PUBLIX #1554 HOLLYWOOD FL'),
    (v_card_id, v_cat_dining_id, '2025-04-05', '2025-04-05', -46.75, 'FIREHOUSE SUBS 096 QSR HALLANDALE BEFL'),
    (v_card_id, v_cat_subscription_id, '2025-04-05', '2025-04-07', -10.00, '1XJETBRAINS AI PRO SAN MATEO CA'),
    (v_card_id, v_cat_shopping_id, '2025-04-05', '2025-04-07', -6.42, 'SMOKIN ON HALLANDALE LLC HALLANDALE BEFLGOOGLE PAY ENDING IN 5097'),
    (v_card_id, v_cat_groceries_id, '2025-04-07', '2025-04-07', -95.34, 'PUBLIX #1693 HOLLYWOOD FL'),
    (v_card_id, v_cat_shopping_id, '2025-04-08', '2025-04-08', -32.09, 'BRANDSMART USA DP DANIA BEACH FLGOOGLE PAY ENDING IN 5097'),
    (v_card_id, v_cat_transport_id, '2025-04-08', '2025-04-08', -37.16, 'CHEVRON 0047247 855-285-9595 FL00047247 9036418 M'),
    (v_card_id, v_cat_dining_id, '2025-04-09', '2025-04-09', -2.94, 'IKEA MIAMI RESTAURANT MIAMI FLGOOGLE PAY ENDING IN 5097'),
    (v_card_id, v_cat_dining_id, '2025-04-09', '2025-04-09', -2.94, 'IKEA MIAMI RESTAURANT MIAMI FL'),
    (v_card_id, v_cat_payment_id, '2025-04-10', '2025-04-10', 449.67, 'INTERNET PAYMENT - THANK YOU'),
    (v_card_id, v_cat_groceries_id, '2025-04-11', '2025-04-11', -34.22, 'PUBLIX #1693 HOLLYWOOD FLGOOGLE PAY ENDING IN 5097'),
    (v_card_id, v_cat_shopping_id, '2025-04-11', '2025-04-11', -182.32, 'WALMART STORE 01996 HALLANDALE FL'),
    (v_card_id, v_cat_subscription_id, '2025-04-12', '2025-04-12', -11.99, 'JOTTACLOUD 29962554 21042900 NOR'),
    (v_card_id, v_cat_groceries_id, '2025-04-13', '2025-04-13', -37.08, 'PUBLIX #1693 HOLLYWOOD FLGOOGLE PAY ENDING IN 5097'),
    (v_card_id, v_cat_shopping_id, '2025-04-13', '2025-04-13', -94.12, 'TOTAL WINE AND MORE MIAMI FLGOOGLE PAY ENDING IN 5097'),
    (v_card_id, v_cat_transport_id, '2025-04-15', '2025-04-15', -37.07, 'CHEVRON 0047247 855-285-9595 FL00047247 9013216 M'),
    (v_card_id, v_cat_subscription_id, '2025-04-16', '2025-04-16', -9.99, 'ADOBE *ADOBE 408-536-6000 CA'),
    (v_card_id, v_cat_groceries_id, '2025-04-16', '2025-04-16', -82.25, 'PUBLIX #1554 HOLLYWOOD FL'),
    (v_card_id, v_cat_utilities_id, '2025-04-17', '2025-04-17', -125.14, 'GOOGLE FI TXQZ9L GOOGLE.COM CA'),
    (v_card_id, v_cat_groceries_id, '2025-04-18', '2025-04-18', -115.89, 'PUBLIX #1693 HOLLYWOOD FL'),
    (v_card_id, v_cat_subscription_id, '2025-04-19', '2025-04-19', -42.60, 'AQTCA PRK 877-793-7935 ORLANDO FL'),
    (v_card_id, v_cat_travel_id, '2025-04-19', '2025-04-19', -95.79, 'AQUATICA ORL MFO 407-545-5550 FL'),
    (v_card_id, v_cat_subscription_id, '2025-04-19', '2025-04-19', -25.00, 'BEST LOCKERS AQUAORL ORLANDO FL'),
    (v_card_id, v_cat_subscription_id, '2025-04-19', '2025-04-19', -30.00, 'BEST LOCKERS AQUAORL ORLANDO FL'),
    (v_card_id, v_cat_transport_id, '2025-04-19', '2025-04-19', -10.83, 'SHELL57543704019 SAINT CLOUD FL'),
    (v_card_id, v_cat_transport_id, '2025-04-19', '2025-04-19', -33.30, 'SHELL57543704118 OKEECHOBEE FLGOOGLE PAY ENDING IN 5097'),
    (v_card_id, v_cat_transport_id, '2025-04-21', '2025-04-21', -36.43, 'CHEVRON 0047247 855-285-9595 FL00047247 9014126 M'),
    (v_card_id, v_cat_groceries_id, '2025-04-21', '2025-04-21', -34.38, 'EUROPA GOURMET HOLLYWOOD FL'),
    (v_card_id, v_cat_payment_id, '2025-04-21', '2025-04-21', 710.00, 'INTERNET PAYMENT - THANK YOU'),
    (v_card_id, v_cat_subscription_id, '2025-04-22', '2025-04-22', -1.99, '1PASSWORD 8668127277 CAN'),
    (v_card_id, v_cat_payment_id, '2025-04-23', '2025-04-23', 200.00, 'INTERNET PAYMENT - THANK YOU'),
    (v_card_id, v_cat_groceries_id, '2025-04-24', '2025-04-24', -68.57, 'EUROPA GOURMET HOLLYWOOD FL'),
    (v_card_id, v_cat_shopping_id, '2025-04-24', '2025-04-24', -60.86, 'TOTAL WINE & MORE 9 FT LAUDERDALEFLGOOGLE PAY ENDING IN 5097'),
    (v_card_id, v_cat_shopping_id, '2025-04-24', '2025-04-24', -163.35, 'WALMART STORE 01996 HALLANDALE FL'),
    (v_card_id, v_cat_groceries_id, '2025-04-29', '2025-04-29', -76.76, 'PUBLIX #1554 HOLLYWOOD FL'),
    (v_card_id, v_cat_transport_id, '2025-04-30', '2025-04-30', -37.06, 'CHEVRON 0047247 855-285-9595 FL00047247 9015419 M'),
    (v_card_id, v_cat_shopping_id, '2025-04-30', '2025-04-30', -60.98, 'ZAHRAH USA 866-9523331 CA');

    -- May 2025
    INSERT INTO finance.transaction (card_id, category_id, transaction_date, post_date, amount, description) VALUES
    (v_card_id, v_cat_groceries_id, '2025-05-02', '2025-05-02', -53.67, 'EUROPA GOURMET HOLLYWOOD FL'),
    (v_card_id, v_cat_dining_id, '2025-05-03', '2025-05-03', -45.95, 'FIREHOUSE SUBS 096 QSR HALLANDALE BEFLGOOGLE PAY ENDING IN 5097'),
    (v_card_id, v_cat_entertainment_id, '2025-05-03', '2025-05-03', -39.99, 'WL *STEAM PURCHASE 425-889-9642 WA00016J1BYFWHC001001'),
    (v_card_id, v_cat_subscription_id, '2025-05-05', '2025-05-07', -10.00, '1XJETBRAINS AI PRO SAN MATEO CA'),
    (v_card_id, v_cat_groceries_id, '2025-05-06', '2025-05-07', -120.18, 'PUBLIX #1693 HOLLYWOOD FL'),
    (v_card_id, v_cat_shopping_id, '2025-05-07', '2025-05-07', -12.57, 'DOLLAR TREE HALLANDALE BEFL'),
    (v_card_id, v_cat_subscription_id, '2025-05-07', '2025-05-07', -3.00, 'HCA FL AVENTURA HOSPIT AVENTURA FL'),
    (v_card_id, v_cat_subscription_id, '2025-05-08', '2025-05-08', -3.00, 'HCA FL AVENTURA HOSPIT AVENTURA FL'),
    (v_card_id, v_cat_payment_id, '2025-05-08', '2025-05-08', 743.46, 'INTERNET PAYMENT - THANK YOU'),
    (v_card_id, v_cat_groceries_id, '2025-05-08', '2025-05-08', -71.04, 'PUBLIX #402 HALLANDALE FL'),
    (v_card_id, v_cat_subscription_id, '2025-05-11', '2025-05-11', -176.66, 'PROGRESSIVE INS 800-776-4737 OH987617646927273877'),
    (v_card_id, v_cat_subscription_id, '2025-05-12', '2025-05-12', -11.99, 'JOTTACLOUD 30384808 21042900 NOR'),
    (v_card_id, v_cat_groceries_id, '2025-05-12', '2025-05-12', -98.94, 'PUBLIX #1554 HOLLYWOOD FL'),
    (v_card_id, v_cat_groceries_id, '2025-05-13', '2025-05-13', -19.60, 'PUBLIX #1554 HOLLYWOOD FL'),
    (v_card_id, v_cat_groceries_id, '2025-05-14', '2025-05-14', -61.46, 'EUROPA GOURMET HOLLYWOOD FL'),
    (v_card_id, v_cat_transport_id, '2025-05-15', '2025-05-15', -36.81, 'CHEVRON 0047247 855-285-9595 FL00047247 9017572 M'),
    (v_card_id, v_cat_payment_id, '2025-05-15', '2025-05-15', 507.38, 'INTERNET PAYMENT - THANK YOU'),
    (v_card_id, v_cat_subscription_id, '2025-05-16', '2025-05-16', -9.99, 'ADOBE *ADOBE 408-536-6000 CA'),
    (v_card_id, v_cat_dining_id, '2025-05-17', '2025-05-17', -60.16, 'CAFE AT THE SUMMIT HOLLYWOOD FL'),
    (v_card_id, v_cat_utilities_id, '2025-05-18', '2025-05-18', -120.28, 'GOOGLE FI 9F96C7 GOOGLE.COM CA'),
    (v_card_id, v_cat_dining_id, '2025-05-18', '2025-05-18', -5.62, 'IKEA SUNRISE REST SUNRISE FL'),
    (v_card_id, v_cat_shopping_id, '2025-05-18', '2025-05-18', -18.17, 'T J MAXX #1340 FORT LAUDERDAFL'),
    (v_card_id, v_cat_shopping_id, '2025-05-18', '2025-05-18', -56.65, 'TOTAL WINE & MORE 9 FT LAUDERDALEFLGOOGLE PAY ENDING IN 5097'),
    (v_card_id, v_cat_dining_id, '2025-05-19', '2025-05-19', -35.51, 'TST* FIREHOUSE SUBS - PI WESTON FLGOOGLE PAY ENDING IN 5097'),
    (v_card_id, v_cat_entertainment_id, '2025-05-19', '2025-05-19', -5.99, 'VALVE BELLEVUE WA'),
    (v_card_id, v_cat_shopping_id, '2025-05-19', '2025-05-19', -183.51, 'WALMART STORE 01996 HALLANDALE FL'),
    (v_card_id, v_cat_groceries_id, '2025-05-20', '2025-05-20', -41.53, 'PUBLIX #1554 HOLLYWOOD FL'),
    (v_card_id, v_cat_transport_id, '2025-05-21', '2025-05-21', -35.21, 'CHEVRON 0047247 855-285-9595 FL00047247 9033231 M'),
    (v_card_id, v_cat_subscription_id, '2025-05-22', '2025-05-22', -3.99, '1PASSWORD 8668127277 CAN'),
    (v_card_id, v_cat_groceries_id, '2025-05-22', '2025-05-22', -74.75, 'PUBLIX #1554 HOLLYWOOD FL'),
    (v_card_id, v_cat_dining_id, '2025-05-24', '2025-05-24', -35.34, 'FIREHOUSE SUBS 096 QSR HALLANDALE BEFLGOOGLE PAY ENDING IN 5097'),
    (v_card_id, v_cat_shopping_id, '2025-05-26', '2025-05-26', -76.45, 'TOTAL WINE & MORE 9 FT LAUDERDALEFLGOOGLE PAY ENDING IN 5097'),
    (v_card_id, v_cat_payment_id, '2025-05-27', '2025-05-27', 300.00, 'INTERNET PAYMENT - THANK YOU'),
    (v_card_id, v_cat_transport_id, '2025-05-27', '2025-05-27', -16.41, 'MARATHON PETRO187161 HOLLYWOOD FLGOOGLE PAY ENDING IN 5097'),
    (v_card_id, v_cat_groceries_id, '2025-05-27', '2025-05-27', -85.84, 'PUBLIX #1554 HOLLYWOOD FL'),
    (v_card_id, v_cat_groceries_id, '2025-05-29', '2025-05-29', -53.14, 'EUROPA GOURMET HOLLYWOOD FL'),
    (v_card_id, v_cat_groceries_id, '2025-05-29', '2025-05-29', -42.02, 'PUBLIX #1554 HOLLYWOOD FL'),
    (v_card_id, v_cat_transport_id, '2025-05-31', '2025-05-31', -41.39, 'CHEVRON 0047247 855-285-9595 FL00047247 9087356 M'),
    (v_card_id, v_cat_groceries_id, '2025-05-31', '2025-05-31', -49.42, 'PUBLIX #1554 HOLLYWOOD FLGOOGLE PAY ENDING IN 5097'),
    (v_card_id, v_cat_transport_id, '2025-05-31', '2025-05-31', -32.10, 'WORLD TIRE & AUTO REPAIR HOLLYWOOD FLGOOGLE PAY ENDING IN 5097');

    -- June 2025
    INSERT INTO finance.transaction (card_id, category_id, transaction_date, post_date, amount, description) VALUES
    (v_card_id, v_cat_payment_id, '2025-06-01', '2025-06-01', 736.41, 'INTERNET PAYMENT - THANK YOU'),
    (v_card_id, v_cat_shopping_id, '2025-06-02', '2025-06-02', -1.49, 'GOOGLE FLIGHTRADAR24 GOOGLE.COM CA'),
    (v_card_id, v_cat_groceries_id, '2025-06-05', '2025-06-05', -74.62, 'EUROPA GOURMET HOLLYWOOD FL'),
    (v_card_id, v_cat_subscription_id, '2025-06-05', '2025-06-07', -10.00, '1XJETBRAINS AI PRO SAN MATEO CA'),
    (v_card_id, v_cat_shopping_id, '2025-06-05', '2025-06-07', -14.98, 'FIVE BELOW 925 HALLANDALE FL'),
    (v_card_id, v_cat_groceries_id, '2025-06-05', '2025-06-07', -97.67, 'PUBLIX #1554 HOLLYWOOD FL'),
    (v_card_id, v_cat_dining_id, '2025-06-06', '2025-06-07', -29.41, 'CAFE AT THE SUMMIT HOLLYWOOD FL'),
    (v_card_id, v_cat_health_id, '2025-06-06', '2025-06-07', -50.00, 'MDNOW-HALLANDALE BEACH HALLANDALE BEFL'),
    (v_card_id, v_cat_shopping_id, '2025-06-07', '2025-06-07', -90.34, 'TOTAL WINE & MORE 9 FT LAUDERDALEFLGOOGLE PAY ENDING IN 5097'),
    (v_card_id, v_cat_shopping_id, '2025-06-09', '2025-06-09', -7.27, 'CVS/PHARMACY #10078 HALLANDALE BEFL'),
    (v_card_id, v_cat_shopping_id, '2025-06-09', '2025-06-09', -15.27, 'CVS/PHARMACY #10078 HALLANDALE BEFL'),
    (v_card_id, v_cat_transport_id, '2025-06-11', '2025-06-11', -11.47, 'CHEVRON 0205972 855-285-9595 FL00205972 9121899 M'),
    (v_card_id, v_cat_transport_id, '2025-06-11', '2025-06-11', -41.28, 'CHEVRON 0205972 855-285-9595 FL00205972 9121933 M'),
    (v_card_id, v_cat_transport_id, '2025-06-11', '2025-06-11', -5.09, 'MARATHON 149963 HOLLYWOOD FLGOOGLE PAY ENDING IN 5097'),
    (v_card_id, v_cat_subscription_id, '2025-06-11', '2025-06-11', -111.64, 'PROGRESSIVE INS 800-776-4737 OH987617646958356277'),
    (v_card_id, v_cat_groceries_id, '2025-06-11', '2025-06-11', -33.13, 'PUBLIX #402 HALLANDALE FL'),
    (v_card_id, v_cat_travel_id, '2025-06-11', '2025-06-11', -10.00, 'SUNPASS*ACC118372795 888-865-5352 FL'),
    (v_card_id, v_cat_shopping_id, '2025-06-11', '2025-06-11', -220.10, 'WALMART STORE 01996 HALLANDALE FL'),
    (v_card_id, v_cat_groceries_id, '2025-06-11', '2025-06-11', -81.57, 'WILD FORK FOODS - AVENTU AVENTURA FL'),
    (v_card_id, v_cat_subscription_id, '2025-06-12', '2025-06-12', -223.24, 'GEICO *AUTO 800-841-3000 DC6211589459250612105658'),
    (v_card_id, v_cat_subscription_id, '2025-06-12', '2025-06-12', -11.99, 'JOTTACLOUD 30835110 21042900 NOR'),
    (v_card_id, v_cat_groceries_id, '2025-06-12', '2025-06-12', -26.86, 'PUBLIX #1693 HOLLYWOOD FL'),
    (v_card_id, v_cat_entertainment_id, '2025-06-12', '2025-06-12', -19.99, 'WL *STEAM PURCHASE 425-889-9642 WA00016J1CD5H1C001001'),
    (v_card_id, v_cat_groceries_id, '2025-06-14', '2025-06-14', -152.07, 'PUBLIX #1554 HOLLYWOOD FLGOOGLE PAY ENDING IN 5097'),
    (v_card_id, v_cat_groceries_id, '2025-06-14', '2025-06-14', -15.10, 'PUBLIX #715 FT LAUDERDALEFLGOOGLE PAY ENDING IN 5097'),
    (v_card_id, v_cat_payment_id, '2025-06-14', '2025-06-15', 88.63, 'PROGRESSIVE INS 800-776-4737 OH987617646961775350'),
    (v_card_id, v_cat_shopping_id, '2025-06-15', '2025-06-15', -14.99, 'BASS PRO STORE DANIA/FT. DANIA FLGOOGLE PAY ENDING IN 5097'),
    (v_card_id, v_cat_dining_id, '2025-06-15', '2025-06-15', -79.84, 'CULTI SOUTH OF FIFTH MIAMI BEACH FLGOOGLE PAY ENDING IN 5097'),
    (v_card_id, v_cat_dining_id, '2025-06-15', '2025-06-15', -53.90, 'GELATOGO SOUTH BEACH LLC MIAMI BEACH FLGOOGLE PAY ENDING IN 5097'),
    (v_card_id, v_cat_subscription_id, '2025-06-16', '2025-06-16', -9.99, 'ADOBE SAN JOSE CA'),
    (v_card_id, v_cat_travel_id, '2025-06-16', '2025-06-16', -209.10, 'FH* EVERGLADES ALLIGAT 8554955551 FLGOOGLE PAY ENDING IN 5097'),
    (v_card_id, v_cat_shopping_id, '2025-06-16', '2025-06-16', -86.02, 'TOTAL WINE AND MORE MIAMI FLGOOGLE PAY ENDING IN 5097'),
    (v_card_id, v_cat_shopping_id, '2025-06-16', '2025-06-16', -151.71, 'WALMART STORE 01996 HALLANDALE FL'),
    (v_card_id, v_cat_travel_id, '2025-06-17', '2025-06-17', -10.00, 'EVERGLADES ALLIGATOR FAR HOMESTEAD FL'),
    (v_card_id, v_cat_travel_id, '2025-06-17', '2025-06-17', -15.00, 'EVERGLADES ALLIGATOR FAR HOMESTEAD FL'),
    (v_card_id, v_cat_utilities_id, '2025-06-17', '2025-06-17', -120.28, 'GOOGLE FI QN9XJS GOOGLE.COM CA'),
    (v_card_id, v_cat_payment_id, '2025-06-19', '2025-06-19', 131.34, 'CASHBACK BONUS REDEMPTION PYMT/STMT CRDT'),
    (v_card_id, v_cat_payment_id, '2025-06-19', '2025-06-19', 900.00, 'INTERNET PAYMENT - THANK YOU'),
    (v_card_id, v_cat_transport_id, '2025-06-20', '2025-06-20', -49.80, 'MARATHON 171058 MIAMI FLGOOGLE PAY ENDING IN 5097'),
    (v_card_id, v_cat_groceries_id, '2025-06-20', '2025-06-20', -6.49, 'SQ *BRICKELL DELI MARK MIAMI FLGOOGLE PAY ENDING IN 50970002305843022294878094'),
    (v_card_id, v_cat_dining_id, '2025-06-20', '2025-06-20', -9.24, 'THE COFFEE EXPERIENCE LL MIAMI FL'),
    (v_card_id, v_cat_dining_id, '2025-06-20', '2025-06-20', -170.34, 'TST*VERSAILLES RESTAUR MIAMI FL00048020025867528488AA'),
    (v_card_id, v_cat_shopping_id, '2025-06-20', '2025-06-20', -82.26, 'WALMART STORE 01996 HALLANDALE BEFL'),
    (v_card_id, v_cat_groceries_id, '2025-06-21', '2025-06-21', -16.12, 'EUROPA GOURMET HOLLYWOOD FLGOOGLE PAY ENDING IN 5097'),
    (v_card_id, v_cat_shopping_id, '2025-06-21', '2025-06-21', -132.05, 'TOTAL WINE & MORE 9 FT LAUDERDALEFLGOOGLE PAY ENDING IN 5097'),
    (v_card_id, v_cat_groceries_id, '2025-06-21', '2025-06-21', -36.59, 'WILD FORK FOODS - AVENTU AVENTURA FLGOOGLE PAY ENDING IN 5097'),
    (v_card_id, v_cat_subscription_id, '2025-06-22', '2025-06-22', -3.99, '1PASSWORD 8668127277 CAN'),
    (v_card_id, v_cat_groceries_id, '2025-06-22', '2025-06-22', -8.24, 'PUBLIX #1554 HOLLYWOOD FL'),
    (v_card_id, v_cat_groceries_id, '2025-06-23', '2025-06-23', -30.14, 'WINN-DIXIE #0306 HALLANDALE FL'),
    (v_card_id, v_cat_dining_id, '2025-06-24', '2025-06-24', -13.26, 'HAAGEN DAZS 1390 MIAMI FL'),
    (v_card_id, v_cat_shopping_id, '2025-06-24', '2025-06-24', -20.33, 'PETERSONS HARLEY-DAVID MIAMI FL'),
    (v_card_id, v_cat_groceries_id, '2025-06-24', '2025-06-24', -27.38, 'SQ *SKOOPS JUICEBAR MIAMI FLGOOGLE PAY ENDING IN 50970002305843022323044979'),
    (v_card_id, v_cat_groceries_id, '2025-06-25', '2025-06-25', -24.57, 'PUBLIX #1554 HOLLYWOOD FLGOOGLE PAY ENDING IN 5097'),
    (v_card_id, v_cat_transport_id, '2025-06-27', '2025-06-27', -34.48, 'CHEVRON 0047247 855-285-9595 FL00047247 9064915 M'),
    (v_card_id, v_cat_payment_id, '2025-06-28', '2025-06-28', 1781.17, 'INTERNET PAYMENT - THANK YOU'),
    (v_card_id, v_cat_travel_id, '2025-06-30', '2025-06-30', -10.00, 'SUNPASS*ACC118372795 888-865-5352 FL');

    -- July 2025
    INSERT INTO finance.transaction (card_id, category_id, transaction_date, post_date, amount, description) VALUES
    (v_card_id, v_cat_shopping_id, '2025-07-02', '2025-07-02', -1.49, 'GOOGLE FLIGHTRADAR24 GOOGLE.COM CA'),
    (v_card_id, v_cat_shopping_id, '2025-07-04', '2025-07-04', -2.99, 'GOOGLE WEB3O GOOGLE.COM CA'),
    (v_card_id, v_cat_subscription_id, '2025-07-05', '2025-07-07', -10.00, '1XJETBRAINS AI PRO SAN MATEO CA'),
    (v_card_id, v_cat_groceries_id, '2025-07-05', '2025-07-07', -113.19, 'PUBLIX #1693 HOLLYWOOD FLGOOGLE PAY ENDING IN 5097'),
    (v_card_id, v_cat_shopping_id, '2025-07-06', '2025-07-07', -87.13, 'TOTAL WINE AND MORE MIAMI FLGOOGLE PAY ENDING IN 5097'),
    (v_card_id, v_cat_groceries_id, '2025-07-10', '2025-07-10', -96.24, 'EUROPA GOURMET HOLLYWOOD FL'),
    (v_card_id, v_cat_subscription_id, '2025-07-10', '2025-07-10', -4.00, 'HCA FL AVENTURA HOSPIT AVENTURA FL'),
    (v_card_id, v_cat_dining_id, '2025-07-12', '2025-07-12', -41.44, 'CAFE AT THE SUMMIT HOLLYWOOD FL'),
    (v_card_id, v_cat_subscription_id, '2025-07-12', '2025-07-12', -11.99, 'JOTTACLOUD 31306824 21042900 NOR'),
    (v_card_id, v_cat_shopping_id, '2025-07-12', '2025-07-12', -29.99, 'VALVE BELLEVUE WA'),
    (v_card_id, v_cat_subscription_id, '2025-07-13', '2025-07-13', -228.95, 'GEICO *AUTO 800-841-3000 DC6211589459000789828591'),
    (v_card_id, v_cat_groceries_id, '2025-07-13', '2025-07-13', -43.31, 'PUBLIX #1693 HOLLYWOOD FLGOOGLE PAY ENDING IN 5097'),
    (v_card_id, v_cat_subscription_id, '2025-07-16', '2025-07-16', -9.99, 'ADOBE SAN JOSE CA'),
    (v_card_id, v_cat_payment_id, '2025-07-16', '2025-07-16', 715.20, 'INTERNET PAYMENT - THANK YOU'),
    (v_card_id, v_cat_travel_id, '2025-07-16', '2025-07-16', -5.34, 'SUNPASS*ACC118372795 888-865-5352 FL'),
    (v_card_id, v_cat_travel_id, '2025-07-16', '2025-07-16', -5.40, 'SUNPASS*ACC136321420 888-865-5352 FL'),
    (v_card_id, v_cat_utilities_id, '2025-07-17', '2025-07-17', -120.20, 'GOOGLE FI 2245KD GOOGLE.COM CA'),
    (v_card_id, v_cat_groceries_id, '2025-07-17', '2025-07-17', -42.40, 'KC MARKET HALLANDALE HALLANDALE BEFL'),
    (v_card_id, v_cat_health_id, '2025-07-17', '2025-07-17', -300.00, 'SQ *THE NEW YORK EAR, HALLANDALE BEFL0002305843022480551696'),
    (v_card_id, v_cat_shopping_id, '2025-07-17', '2025-07-17', -87.59, 'WALMART STORE 01996 HALLANDALE BEFL'),
    (v_card_id, v_cat_groceries_id, '2025-07-18', '2025-07-18', -8.00, 'SQ *GERBAUD BAKERY / N MIAMI FL0002305843022483697970'),
    (v_card_id, v_cat_transport_id, '2025-07-19', '2025-07-19', -36.34, 'CHEVRON 0357678 855-285-9595 FL00357678 9063064 M'),
    (v_card_id, v_cat_dining_id, '2025-07-19', '2025-07-19', -7.00, 'NYX*NAYAX VENDING 34 HUNT VALLEY MDGOOGLE PAY ENDING IN 5097'),
    (v_card_id, v_cat_shopping_id, '2025-07-19', '2025-07-19', -29.42, 'OC LIQUOR HOLLYWOOD FLGOOGLE PAY ENDING IN 5097'),
    (v_card_id, v_cat_shopping_id, '2025-07-19', '2025-07-19', -100.59, 'TOTAL WINE & MORE 9 FT LAUDERDALEFLGOOGLE PAY ENDING IN 5097'),
    (v_card_id, v_cat_subscription_id, '2025-07-22', '2025-07-22', -3.99, '1PASSWORD 8668127277 CAN'),
    (v_card_id, v_cat_groceries_id, '2025-07-22', '2025-07-22', -38.98, 'EUROPA GOURMET HOLLYWOOD FL'),
    (v_card_id, v_cat_groceries_id, '2025-07-22', '2025-07-22', -133.57, 'PUBLIX #1554 HOLLYWOOD FL'),
    (v_card_id, v_cat_subscription_id, '2025-07-25', '2025-07-25', -13.99, 'AIRCRAFT & PILOT ASSN 8008722672 MD'),
    (v_card_id, v_cat_payment_id, '2025-07-31', '2025-07-31', 600.00, 'INTERNET PAYMENT - THANK YOU'),
    (v_card_id, v_cat_payment_id, '2025-07-31', '2025-07-31', 177.00, 'INTERNET PAYMENT - THANK YOU');

    -- Aug 2025
    INSERT INTO finance.transaction (card_id, category_id, transaction_date, post_date, amount, description) VALUES
    (v_card_id, v_cat_payment_id, '2025-08-01', '2025-08-01', 165.80, 'INTERNET PAYMENT - THANK YOU'),
    (v_card_id, v_cat_shopping_id, '2025-08-02', '2025-08-02', -1.49, 'GOOGLE *FLIGHTRADAR24 G.CO/HELPPAY#CAP1DCKTYS'),
    (v_card_id, v_cat_subscription_id, '2025-08-05', '2025-08-07', -10.00, '1XJETBRAINS AI PRO SAN MATEO CA'),
    (v_card_id, v_cat_payment_id, '2025-08-06', '2025-08-06', 1.49, 'SMALL BALANCE CREDIT'),
    (v_card_id, v_cat_subscription_id, '2025-08-12', '2025-08-12', -11.99, 'JOTTACLOUD 31793041 21042900 NOR'),
    (v_card_id, v_cat_subscription_id, '2025-08-16', '2025-08-16', -9.99, 'ADOBE SAN JOSE CA'),
    (v_card_id, v_cat_utilities_id, '2025-08-17', '2025-08-17', -88.76, 'GOOGLE FI DXZM52 GOOGLE.COM CA'),
    (v_card_id, v_cat_payment_id, '2025-08-19', '2025-08-20', 107.78, 'SQ *THE NEW YORK EAR, HALLANDALE BEFL0002305843022686320976'),
    (v_card_id, v_cat_shopping_id, '2025-08-21', '2025-08-21', -180.09, 'WALMART STORE 04563 DANIA BEACH FL'),
    (v_card_id, v_cat_subscription_id, '2025-08-22', '2025-08-22', -3.99, '1PASSWORD 8668127277 CAN'),
    (v_card_id, v_cat_groceries_id, '2025-08-22', '2025-08-22', -90.27, 'PUBLIX #1554 HOLLYWOOD FLGOOGLE PAY ENDING IN 8599'),
    (v_card_id, v_cat_groceries_id, '2025-08-23', '2025-08-23', -15.43, 'EUROPA GOURMET HOLLYWOOD FLGOOGLE PAY ENDING IN 8599'),
    (v_card_id, v_cat_shopping_id, '2025-08-24', '2025-08-24', -4.99, 'GOOGLE MINECRAFT GOOGLE.COM CA'),
    (v_card_id, v_cat_payment_id, '2025-08-29', '2025-08-29', 307.73, 'INTERNET PAYMENT - THANK YOU'),
    (v_card_id, v_cat_groceries_id, '2025-08-29', '2025-08-29', -33.71, 'PUBLIX #1554 HOLLYWOOD FL'),
    (v_card_id, v_cat_shopping_id, '2025-08-29', '2025-08-29', -8.25, 'TST*FARMERS MILK HOLLYWOOD FLGOOGLE PAY ENDING IN 859900161656027506652928AA'),
    (v_card_id, v_cat_shopping_id, '2025-08-29', '2025-08-29', -16.10, 'TST*FARMERS MILK HOLLYWOOD FLGOOGLE PAY ENDING IN 859900161656027505536647AA'),
    (v_card_id, v_cat_shopping_id, '2025-08-29', '2025-08-29', -140.68, 'WALMART STORE 01996 HALLANDALE BEFL'),
    (v_card_id, v_cat_groceries_id, '2025-08-30', '2025-08-30', -56.10, 'PUBLIX #1554 HOLLYWOOD FLGOOGLE PAY ENDING IN 5097'),
    (v_card_id, v_cat_shopping_id, '2025-08-30', '2025-08-30', -64.14, 'TOTAL WINE & MORE 9 FT LAUDERDALEFLGOOGLE PAY ENDING IN 5097'),
    (v_card_id, v_cat_dining_id, '2025-08-31', '2025-08-31', -24.28, 'FIREHOUSE SUBS 096 QSR HALLANDALE BEFL'),
    (v_card_id, v_cat_shopping_id, '2025-08-31', '2025-08-31', -21.35, 'THE HOME DEPOT #6310 HOLLYWOOD FLGOOGLE PAY ENDING IN 5097'),
    (v_card_id, v_cat_shopping_id, '2025-08-31', '2025-08-31', -143.55, 'WALMART STORE 01996 HALLANDALE BEFL'),
    (v_card_id, v_cat_groceries_id, '2025-08-31', '2025-08-31', -39.45, 'WINN-DIXIE #0306 HALLANDALE FL');

    -- Sep 2025
    INSERT INTO finance.transaction (card_id, category_id, transaction_date, post_date, amount, description) VALUES
    (v_card_id, v_cat_shopping_id, '2025-09-01', '2025-09-01', -5.37, 'THE HOME DEPOT #6310 HOLLYWOOD FLGOOGLE PAY ENDING IN 5097'),
    (v_card_id, v_cat_shopping_id, '2025-09-01', '2025-09-01', -39.44, 'THE HOME DEPOT #6310 HOLLYWOOD FLGOOGLE PAY ENDING IN 5097'),
    (v_card_id, v_cat_transport_id, '2025-09-02', '2025-09-02', -166.95, 'CENTURY AUTOMOTIVE GRO 2565363800 AL'),
    (v_card_id, v_cat_subscription_id, '2025-09-02', '2025-09-02', -1.49, 'GOOGLE *FLIGHTRADAR24 G.CO/HELPPAY#CAP1E3SM5O'),
    (v_card_id, v_cat_subscription_id, '2025-09-03', '2025-09-03', -80.25, 'ATT*BILL PAYMENT 800-331-0500 TX'),
    (v_card_id, v_cat_groceries_id, '2025-09-04', '2025-09-07', -164.77, 'PUBLIX #1554 HOLLYWOOD FLGOOGLE PAY ENDING IN 8599'),
    (v_card_id, v_cat_subscription_id, '2025-09-05', '2025-09-07', -10.00, '1XJETBRAINS AI PRO SAN MATEO CA'),
    (v_card_id, v_cat_dining_id, '2025-09-06', '2025-09-07', -29.87, 'MCDONALD''S F1901 DANIA FLGOOGLE PAY ENDING IN 5097'),
    (v_card_id, v_cat_health_id, '2025-09-06', '2025-09-07', -274.20, 'NEWSTAR DENTAL FORT LAUDERDAFL'),
    (v_card_id, v_cat_subscription_id, '2025-09-06', '2025-09-07', -30.46, 'SPICA ASTROLOGY 671592137 ESP'),
    (v_card_id, v_cat_payment_id, '2025-09-06', '2025-09-07', 22.46, 'TOTAL WINE & MORE 9 FT LAUDERDALEFLGOOGLE PAY ENDING IN 5097'),
    (v_card_id, v_cat_shopping_id, '2025-09-06', '2025-09-07', -88.21, 'TOTAL WINE & MORE 9 FT LAUDERDALEFLGOOGLE PAY ENDING IN 5097'),
    (v_card_id, v_cat_groceries_id, '2025-09-09', '2025-09-09', -27.28, 'EUROPA GOURMET HOLLYWOOD FL'),
    (v_card_id, v_cat_groceries_id, '2025-09-09', '2025-09-09', -86.87, 'PUBLIX #1554 HOLLYWOOD FLGOOGLE PAY ENDING IN 8599'),
    (v_card_id, v_cat_shopping_id, '2025-09-10', '2025-09-10', -40.36, 'WALMART STORE 04563 DANIA BEACH FL'),
    (v_card_id, v_cat_health_id, '2025-09-11', '2025-09-11', -234.80, 'NEWSTAR DENTAL FORT LAUDERDAFL'),
    (v_card_id, v_cat_groceries_id, '2025-09-11', '2025-09-11', -16.88, 'PUBLIX #1554 HOLLYWOOD FLGOOGLE PAY ENDING IN 5097'),
    (v_card_id, v_cat_transport_id, '2025-09-11', '2025-09-11', -37.20, 'WAWA 5232 FT LAUDERDALEFLGOOGLE PAY ENDING IN 5097'),
    (v_card_id, v_cat_subscription_id, '2025-09-12', '2025-09-12', -11.99, 'JOTTACLOUD 32268903 21042900 NOR'),
    (v_card_id, v_cat_shopping_id, '2025-09-12', '2025-09-12', -8.25, 'TST*FARMERS MILK HOLLYWOOD FLGOOGLE PAY ENDING IN 859900161656027776516249AA'),
    (v_card_id, v_cat_shopping_id, '2025-09-12', '2025-09-12', -17.33, 'TST*FARMERS MILK HOLLYWOOD FLGOOGLE PAY ENDING IN 859900161656027775920672AA'),
    (v_card_id, v_cat_shopping_id, '2025-09-13', '2025-09-13', -31.48, 'ALIEXPRESS.COM LONDON GBR'),
    (v_card_id, v_cat_dining_id, '2025-09-13', '2025-09-13', -35.63, 'HAAGEN-DAZS ICE CREAM SH HOLLYWOOD FLGOOGLE PAY ENDING IN 8599'),
    (v_card_id, v_cat_subscription_id, '2025-09-14', '2025-09-14', -228.95, 'GEICO *AUTO 800-841-3000 DC6211589459250914162625'),
    (v_card_id, v_cat_groceries_id, '2025-09-14', '2025-09-14', -47.08, 'PUBLIX #1554 HOLLYWOOD FLGOOGLE PAY ENDING IN 5097'),
    (v_card_id, v_cat_shopping_id, '2025-09-15', '2025-09-15', -0.50, 'PLAYSTATIONNETWORK SAN MATEO CA'),
    (v_card_id, v_cat_groceries_id, '2025-09-15', '2025-09-15', -40.10, 'PUBLIX #1554 HOLLYWOOD FLGOOGLE PAY ENDING IN 8599'),
    (v_card_id, v_cat_shopping_id, '2025-09-16', '2025-09-16', -11.99, 'ADOBE SAN JOSE CA'),
    (v_card_id, v_cat_groceries_id, '2025-09-16', '2025-09-16', -65.25, 'EUROPA GOURMET HOLLYWOOD FLGOOGLE PAY ENDING IN 5097'),
    (v_card_id, v_cat_shopping_id, '2025-09-16', '2025-09-16', -34.49, 'PLAYSTATIONNETWORK SAN MATEO CA'),
    (v_card_id, v_cat_utilities_id, '2025-09-17', '2025-09-17', -88.76, 'GOOGLE *FI R8DV7P G.CO/HELPPAY#CAP1EVKV51'),
    (v_card_id, v_cat_dining_id, '2025-09-17', '2025-09-17', -38.00, 'GULFSTREAM PARK HALLANDALE BEFL'),
    (v_card_id, v_cat_shopping_id, '2025-09-17', '2025-09-17', -79.99, 'PLAYSTATIONNETWORK SAN MATEO CA'),
    (v_card_id, v_cat_shopping_id, '2025-09-17', '2025-09-17', -59.87, 'WALMART STORE 04563 DANIA BEACH FL'),
    (v_card_id, v_cat_payment_id, '2025-09-17', '2025-09-19', 79.99, 'PLAYSTATIONNETWORK SAN MATEO CA'),
    (v_card_id, v_cat_payment_id, '2025-09-17', '2025-09-19', 34.49, 'PLAYSTATIONNETWORK SAN MATEO CA'),
    (v_card_id, v_cat_shopping_id, '2025-09-18', '2025-09-18', -64.67, 'TOTAL WINE AND MORE MIAMI FLGOOGLE PAY ENDING IN 5097'),
    (v_card_id, v_cat_shopping_id, '2025-09-19', '2025-09-19', -15.54, 'EBAY O 23-13578-79799 SAN JOSE CA'),
    (v_card_id, v_cat_groceries_id, '2025-09-19', '2025-09-19', -17.48, 'PUBLIX #1554 HOLLYWOOD FLGOOGLE PAY ENDING IN 8599'),
    (v_card_id, v_cat_dining_id, '2025-09-19', '2025-09-19', -6.60, 'TST*BAKU CAFE SUNNY ISLES BFL00222023027905759585AA'),
    (v_card_id, v_cat_shopping_id, '2025-09-20', '2025-09-20', -6.98, 'THE HOME DEPOT #6310 HOLLYWOOD FLGOOGLE PAY ENDING IN 5097'),
    (v_card_id, v_cat_shopping_id, '2025-09-20', '2025-09-20', -38.25, 'THE HOME DEPOT #6310 HOLLYWOOD FLGOOGLE PAY ENDING IN 5097'),
    (v_card_id, v_cat_shopping_id, '2025-09-21', '2025-09-21', -11.97, 'BORSH HALLANDALE FLGOOGLE PAY ENDING IN 5097'),
    (v_card_id, v_cat_groceries_id, '2025-09-21', '2025-09-21', -48.98, 'PUBLIX #1554 HOLLYWOOD FLGOOGLE PAY ENDING IN 5097'),
    (v_card_id, v_cat_subscription_id, '2025-09-22', '2025-09-22', -3.99, '1PASSWORD 8668127277 CAN'),
    (v_card_id, v_cat_groceries_id, '2025-09-22', '2025-09-22', -81.98, 'PUBLIX #1554 HOLLYWOOD FLGOOGLE PAY ENDING IN 8599'),
    (v_card_id, v_cat_subscription_id, '2025-09-23', '2025-09-23', -105.25, 'ATT*BILL PAYMENT 800-288-2020 TXWCRH8MR7EPAYY03'),
    (v_card_id, v_cat_shopping_id, '2025-09-23', '2025-09-23', -27.07, 'ROSETTA BAKERY AT AVENTU AVENTURA FLGOOGLE PAY ENDING IN 8599'),
    (v_card_id, v_cat_shopping_id, '2025-09-23', '2025-09-23', -118.49, 'ZARA USA 12063 AVENTURA FLGOOGLE PAY ENDING IN 8599'),
    (v_card_id, v_cat_groceries_id, '2025-09-26', '2025-09-26', -84.36, 'EUROPA GOURMET HOLLYWOOD FLGOOGLE PAY ENDING IN 8599'),
    (v_card_id, v_cat_subscription_id, '2025-09-26', '2025-09-26', -14.99, 'GOOGLE *ROBLOX G.CO/HELPPAY#CAP1EKBRFP'),
    (v_card_id, v_cat_dining_id, '2025-09-26', '2025-09-26', -17.78, 'TST*DAVINCI NEW HALLANDALE BEFLGOOGLE PAY ENDING IN 859900186360028031579513AA'),
    (v_card_id, v_cat_subscription_id, '2025-09-27', '2025-09-27', -3.99, 'GOOGLE *ROBLOX G.CO/HELPPAY#CAP1EKT2DG'),
    (v_card_id, v_cat_shopping_id, '2025-09-27', '2025-09-27', -21.99, 'PLAYSTATIONNETWORK SAN MATEO CA'),
    (v_card_id, v_cat_shopping_id, '2025-09-29', '2025-09-29', -243.32, 'WALMART STORE 04563 DANIA BEACH FL');

    -- Oct 2025
    INSERT INTO finance.transaction (card_id, category_id, transaction_date, post_date, amount, description) VALUES
    (v_card_id, v_cat_payment_id, '2025-10-01', '2025-10-01', 3478.41, 'INTERNET PAYMENT - THANK YOU'),
    (v_card_id, v_cat_groceries_id, '2025-10-01', '2025-10-01', -69.33, 'PUBLIX #1554 HOLLYWOOD FL'),
    (v_card_id, v_cat_subscription_id, '2025-10-02', '2025-10-02', -1.49, 'GOOGLE *FLIGHTRADAR24 G.CO/HELPPAY#CAP1ESMOBV'),
    (v_card_id, v_cat_shopping_id, '2025-10-03', '2025-10-03', -6.95, 'ROSETTA BAKERY AT AVENTU AVENTURA FLGOOGLE PAY ENDING IN 8599'),
    (v_card_id, v_cat_groceries_id, '2025-10-03', '2025-10-03', -52.95, 'SQ *CAMPO MEAT HALLANDALE BEFLGOOGLE PAY ENDING IN 50970001152921516074594690'),
    (v_card_id, v_cat_groceries_id, '2025-10-03', '2025-10-03', -8.30, 'WHOLEFDS BIS 10096 AVENTURA FLGOOGLE PAY ENDING IN 8599'),
    (v_card_id, v_cat_subscription_id, '2025-10-05', '2025-10-07', -10.00, '1XJETBRAINS AI PRO SAN MATEO CA'),
    (v_card_id, v_cat_shopping_id, '2025-10-06', '2025-10-07', -10.00, 'CVS/PHARMACY #10078 HALLANDALE BEFL'),
    (v_card_id, v_cat_subscription_id, '2025-10-06', '2025-10-07', -3.00, 'HCA FL AVENTURA HOSPIT AVENTURA FL'),
    (v_card_id, v_cat_health_id, '2025-10-06', '2025-10-07', -50.00, 'MDNOW-HALLANDALE BEACH HALLANDALE BEFL'),
    (v_card_id, v_cat_subscription_id, '2025-10-09', '2025-10-09', -98.97, 'ATT*BILL PAYMENT 800-288-2020 TXHVJQ8N97EPAYP03'),
    (v_card_id, v_cat_subscription_id, '2025-10-09', '2025-10-09', -2.00, 'MIAMI BEACH PARKING 7TH MIAMI BEACH FLGOOGLE PAY ENDING IN 5097'),
    (v_card_id, v_cat_shopping_id, '2025-10-10', '2025-10-10', -3.20, 'CVS/PHARMACY #10078 HALLANDALE BEFL'),
    (v_card_id, v_cat_groceries_id, '2025-10-11', '2025-10-11', -29.97, 'SQ *CAMPO MEAT HALLANDALE BEFLGOOGLE PAY ENDING IN 50970002305843023072078302'),
    (v_card_id, v_cat_payment_id, '2025-10-11', '2025-10-13', 15.54, 'EBAY O 23-13578-79799 SAN JOSE CA'),
    (v_card_id, v_cat_subscription_id, '2025-10-12', '2025-10-12', -11.99, 'JOTTACLOUD 32846551 21042900 NOR'),
    (v_card_id, v_cat_payment_id, '2025-10-15', '2025-10-15', 342.61, 'INTERNET PAYMENT - THANK YOU'),
    (v_card_id, v_cat_shopping_id, '2025-10-16', '2025-10-16', -11.99, 'ADOBE SAN JOSE CA'),
    (v_card_id, v_cat_utilities_id, '2025-10-17', '2025-10-17', -88.94, 'GOOGLE FI LHQ8NS GOOGLE.COM CA'),
    (v_card_id, v_cat_subscription_id, '2025-10-22', '2025-10-22', -3.99, '1PASSWORD 8668127277 CAN'),
    (v_card_id, v_cat_subscription_id, '2025-10-23', '2025-10-23', -228.95, 'GEICO *AUTO 800-841-3000 DC6211589459251023093525'),
    (v_card_id, v_cat_shopping_id, '2025-10-23', '2025-10-23', -127.76, 'TOTAL WINE AND MORE MIAMI FLGOOGLE PAY ENDING IN 5097'),
    (v_card_id, v_cat_transport_id, '2025-10-23', '2025-10-23', -32.10, 'WORLD TIRE & AUTO REPAIR HOLLYWOOD FLGOOGLE PAY ENDING IN 5097'),
    (v_card_id, v_cat_shopping_id, '2025-10-27', '2025-10-27', -32.49, 'PLAYSTATIONNETWORK SAN MATEO CA');

    -- Nov 2025
    INSERT INTO finance.transaction (card_id, category_id, transaction_date, post_date, amount, description) VALUES
    (v_card_id, v_cat_payment_id, '2025-11-01', '2025-11-01', 526.22, 'INTERNET PAYMENT - THANK YOU'),
    (v_card_id, v_cat_subscription_id, '2025-11-02', '2025-11-02', -1.49, 'GOOGLE *FLIGHTRADAR24 G.CO/HELPPAY#CAP1FLG6HL'),
    (v_card_id, v_cat_shopping_id, '2025-11-05', '2025-11-05', -49.11, 'ZARA.COM NEW YORK CITYNY'),
    (v_card_id, v_cat_transport_id, '2025-11-07', '2025-11-07', -34.73, 'CHEVRON 0357678 855-285-9595 FL00357678 9084294 M'),
    (v_card_id, v_cat_subscription_id, '2025-11-10', '2025-11-10', -90.28, 'ATT*BILL PAYMENT 800-288-2020 TX2ZSK8PB7EPAYV01'),
    (v_card_id, v_cat_subscription_id, '2025-11-12', '2025-11-12', -11.99, 'JOTTACLOUD 33336466 21042900 NOR'),
    (v_card_id, v_cat_subscription_id, '2025-11-13', '2025-11-13', -227.24, 'GEICO *AUTO 800-841-3000 DC6211589459251113120018'),
    (v_card_id, v_cat_shopping_id, '2025-11-15', '2025-11-15', -19.26, 'EBAY O 16-13829-00438 SAN JOSE CA'),
    (v_card_id, v_cat_shopping_id, '2025-11-16', '2025-11-16', -11.99, 'ADOBE SAN JOSE CA'),
    (v_card_id, v_cat_payment_id, '2025-11-16', '2025-11-16', 414.84, 'INTERNET PAYMENT - THANK YOU'),
    (v_card_id, v_cat_utilities_id, '2025-11-17', '2025-11-17', -88.94, 'GOOGLE FI LN5SRC GOOGLE.COM CA'),
    (v_card_id, v_cat_subscription_id, '2025-11-22', '2025-11-22', -3.99, '1PASSWORD 8668127277 CAN'),
    (v_card_id, v_cat_payment_id, '2025-11-27', '2025-11-27', 124.18, 'INTERNET PAYMENT - THANK YOU');

    -- Dec 2025
    INSERT INTO finance.transaction (card_id, category_id, transaction_date, post_date, amount, description) VALUES
    (v_card_id, v_cat_subscription_id, '2025-12-02', '2025-12-02', -1.49, 'GOOGLE *FLIGHTRADAR24 G.CO/HELPPAY#CAP1GCBL7S'),
    (v_card_id, v_cat_payment_id, '2025-12-06', '2025-12-06', 1.49, 'SMALL BALANCE CREDIT'),
    (v_card_id, v_cat_subscription_id, '2025-12-11', '2025-12-11', -90.28, 'ATT*BILL PAYMENT 800-288-2020 TX8HRY8QB7EPAYA03'),
    (v_card_id, v_cat_subscription_id, '2025-12-12', '2025-12-12', -11.99, 'JOTTACLOUD 33853051 21042900 NOR'),
    (v_card_id, v_cat_subscription_id, '2025-12-13', '2025-12-13', -210.90, 'GEICO *AUTO 800-841-3000 DC6211589459000877435873'),
    (v_card_id, v_cat_shopping_id, '2025-12-16', '2025-12-16', -11.99, 'ADOBE SAN JOSE CA'),
    (v_card_id, v_cat_utilities_id, '2025-12-17', '2025-12-17', -101.29, 'GOOGLE FI 4FLHHL GOOGLE.COM CA'),
    (v_card_id, v_cat_subscription_id, '2025-12-22', '2025-12-22', -3.99, '1PASSWORD 8668127277 CAN');

    -- Jan 2026
    INSERT INTO finance.transaction (card_id, category_id, transaction_date, post_date, amount, description) VALUES
    (v_card_id, v_cat_travel_id, '2026-01-02', '2026-01-02', -10.00, 'BESTLOCKER* GPM PURCHA 8005625374 FL'),
    (v_card_id, v_cat_subscription_id, '2026-01-02', '2026-01-02', -1.49, 'GOOGLE *FLIGHTRADAR24 G.CO/HELPPAY#CAP1HSQKWN');


    -- Statement Summaries
    -- Discover statements usually end around the same day each month. 
    -- Based on the data, let's assume a statement date of the 5th of each month.
    
    -- Statement ending Feb 5, 2025 (Transactions from Jan 6 to Feb 5)
    -- Actually, simpler to just group by month for now as placeholders.
    INSERT INTO finance.statement (card_id, statement_date, due_date, statement_balance, minimum_payment, paid_amount, is_fully_paid)
    VALUES 
    (v_card_id, '2025-02-05', '2025-03-01', 300.00, 35.00, 300.00, TRUE),
    (v_card_id, '2025-03-05', '2025-03-30', 250.00, 35.00, 250.00, TRUE),
    (v_card_id, '2025-04-05', '2025-04-30', 400.00, 35.00, 400.00, TRUE),
    (v_card_id, '2025-05-05', '2025-05-30', 500.00, 35.00, 500.00, TRUE),
    (v_card_id, '2025-06-05', '2025-06-30', 600.00, 35.00, 600.00, TRUE),
    (v_card_id, '2025-07-05', '2025-07-30', 700.00, 35.00, 700.00, TRUE),
    (v_card_id, '2025-08-05', '2025-08-30', 800.00, 35.00, 800.00, TRUE),
    (v_card_id, '2025-09-05', '2025-09-30', 900.00, 35.00, 900.00, TRUE),
    (v_card_id, '2025-10-05', '2025-10-30', 3478.41, 35.00, 3478.41, TRUE),
    (v_card_id, '2025-11-05', '2025-11-30', 526.22, 35.00, 526.22, TRUE),
    (v_card_id, '2025-12-05', '2025-12-30', 414.84, 35.00, 414.84, TRUE),
    (v_card_id, '2026-01-05', '2026-01-30', 124.18, 35.00, 124.18, TRUE)
    ON CONFLICT DO NOTHING;

END $$;
