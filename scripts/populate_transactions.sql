-- Fix the sequence to start after existing records
SELECT setval('transaction_id_seq', (SELECT COALESCE(MAX(id), 0) FROM transaction));

-- Card 3 (9573) - February Statement
INSERT INTO transaction (card_id, category_id, transaction_date, post_date, amount, description, is_pending, subcategory)
VALUES
    (3, 10, '2025-02-02', '2025-02-02', -272.37, 'PAYMENT - THANK YOU', false, 'Payment'),
    (3, 2, '2025-02-08', '2025-02-09', 32.97, 'SQ *CAMPO MEAT Hallandale BeFL', false, 'Dining Out'),
    (3, 1, '2025-02-08', '2025-02-09', 105.68, 'NET COST MARKET HOLLYWOOD FL', false, 'Groceries'),
    (3, 5, '2025-02-08', '2025-02-10', 29.96, 'DAVE & BUSTERS #8 PWC HOLLYWOOD FL', false, 'Entertainment');

-- Card 6 (1437) - Discover IT Card January-February 2026 Statement
INSERT INTO transaction (card_id, category_id, transaction_date, post_date, amount, description, is_pending, subcategory)
VALUES
    (6, 10, '2026-01-15', '2026-01-15', -35.00, 'INTERNET PAYMENT - THANK YOU', false, 'Payment'),
    (6, 10, '2026-01-23', '2026-01-23', -407.00, 'INTERNET PAYMENT - THANK YOU', false, 'Payment'),
    (6, 10, '2026-02-02', '2026-02-02', -150.00, 'INTERNET PAYMENT - THANK YOU', false, 'Payment'),
    (6, 10, '2026-02-02', '2026-02-02', -5.46, '1% Cashback Bonus REDEEMED THIS PERIOD', false, 'Payment'),
    (6, 5, '2026-01-10', '2026-01-10', 19.99, 'ROBLOX 1.888.858.2569 8888582569 CA', false, 'Entertainment'),
    (6, 3, '2026-01-10', '2026-01-10', 87.28, 'ATT*BILL PAYMENT 800-288-2020 TX GVFB8R97EPAYE02', false, 'Utilities'),
    (6, 9, '2026-01-12', '2026-01-12', 11.99, 'JOTTACLOUD 34328257 21042900 NOR', false, 'Subscription'),
    (6, 12, '2026-01-13', '2026-01-13', 247.15, 'GEICO *AUTO 800-841-3000 DC 6211589459000887845891', false, 'Insurance'),
    (6, 9, '2026-01-16', '2026-01-16', 11.99, 'ADOBE SAN JOSE CA', false, 'Subscription'),
    (6, 3, '2026-01-17', '2026-01-17', 108.63, 'GOOGLE FI 4STPMJ GOOGLE.COM CA', false, 'Utilities'),
    (6, 1, '2026-01-19', '2026-01-19', 10.49, 'NET COST MARKET HOLLYWOOD FL GOOGLE PAY ENDING IN 5097', false, 'Groceries'),
    (6, 1, '2026-01-19', '2026-01-19', 27.27, 'NET COST MARKET HOLLYWOOD FL GOOGLE PAY ENDING IN 5097', false, 'Groceries'),
    (6, 5, '2026-01-21', '2026-01-21', 17.49, 'PLAYSTATIONNETWORK SAN MATEO CA', false, 'Entertainment'),
    (6, 9, '2026-01-22', '2026-01-22', 3.99, '1PASSWORD 8668127277 CAN', false, 'Subscription'),
    (6, 9, '2026-02-02', '2026-02-02', 1.49, 'GOOGLE *FLIGHTRADAR24 G.CO/HELPPAY#CA P1IKC4QXM', false, 'Subscription');

-- Card 7 (8819) - Capital One December 2025 - January 2026
INSERT INTO transaction (card_id, category_id, transaction_date, post_date, amount, description, is_pending, subcategory)
VALUES
    (7, 10, '2026-01-04', '2026-01-05', -200.00, 'CAPITAL ONE ONLINE PYMT', false, 'Payment'),
    (7, 10, '2026-01-04', '2026-01-05', -253.00, 'CAPITAL ONE ONLINE PYMT', false, 'Payment'),
    (7, 10, '2026-01-15', '2026-01-15', -505.40, 'CAPITAL ONE ONLINE PYMT', false, 'Payment'),
    (7, 8, '2025-12-27', '2025-12-29', 8.00, 'WIFIONBOARD ALASKACHICAGOIL', false, 'Travel'),
    (7, 8, '2025-12-27', '2025-12-29', 17.50, 'RESIDENCE INN WENATCHEWENATCHEEWA', false, 'Travel'),
    (7, 9, '2025-12-27', '2025-12-29', 3.99, 'PY *SERGIOSMIAMIFL', false, 'Subscription'),
    (7, 8, '2025-12-29', '2025-12-30', 34.50, 'ALASKA AIR IN FLIGHTSEATACWA', false, 'Travel'),
    (7, 6, '2025-12-29', '2025-12-30', 2.00, 'CTLP*CHARACTERS UNLIMIBOULDERCITYNV', false, 'Shopping'),
    (7, 2, '2025-12-29', '2025-12-31', 15.17, 'STARBUCKS #71537NORTH BENDWA', false, 'Dining Out'),
    (7, 2, '2025-12-29', '2025-12-31', 52.03, 'LUKE''S LOBSTER - PIKESEATTLEWA', false, 'Dining Out'),
    (7, 2, '2025-12-29', '2025-12-31', 22.09, 'JACK''S FISH SPOTSEATTLEWA', false, 'Dining Out'),
    (7, 2, '2026-01-02', '2026-01-05', 14.29, 'BULLWHEEL REST CRYSTALENUMCLAWWA', false, 'Dining Out'),
    (7, 2, '2026-01-03', '2026-01-05', 31.88, 'PIKE&PINE ST2275SEATTLEWA', false, 'Dining Out'),
    (7, 5, '2026-01-03', '2026-01-05', 79.00, 'THE MUSEUM OF FLIGHT MTUKWILAWA', false, 'Entertainment'),
    (7, 5, '2026-01-03', '2026-01-05', 20.00, 'THE MUSEUM OF FLIGHT MTUKWILAWA', false, 'Entertainment'),
    (7, 2, '2026-01-03', '2026-01-05', 92.67, 'AIRPORT CONCESSIONS NWSEATTLEWA', false, 'Dining Out'),
    (7, 8, '2026-01-04', '2026-01-05', 17.25, 'ALASKA AIR* QC52WGQA8SEATTLEWA', false, 'Travel'),
    (7, 3, '2026-01-04', '2026-01-05', 200.54, 'CITY OF HOLLYWOOD9549213938FL', false, 'Utilities'),
    (7, 1, '2026-01-06', '2026-01-07', 30.11, 'PUBLIX #1554HOLLYWOODFL', false, 'Groceries'),
    (7, 1, '2026-01-08', '2026-01-09', 182.25, 'WAL-MART #1996HALLANDALEFL', false, 'Groceries'),
    (7, 1, '2026-01-08', '2026-01-09', 56.28, 'EUROPA GOURMETHOLLYWOODFL', false, 'Groceries'),
    (7, 1, '2026-01-09', '2026-01-10', 3.99, 'PUBLIX #1554HOLLYWOODFL', false, 'Groceries'),
    (7, 1, '2026-01-10', '2026-01-10', 7.93, 'TST* FARMER''S MILKHOLLYWOODFL', false, 'Groceries'),
    (7, 24, '2026-01-11', '2026-01-12', 6.00, 'NIC*-DEP MIZELL-JOHNSODANIAFL', false, 'Other'),
    (7, 1, '2026-01-14', '2026-01-15', 19.79, 'PUBLIX #1554HOLLYWOODFL', false, 'Groceries'),
    (7, 1, '2026-01-16', '2026-01-17', 66.17, 'PUBLIX #1554HOLLYWOODFL', false, 'Groceries'),
    (7, 1, '2026-01-17', '2026-01-17', 7.07, 'TST* FARMER''S MILKHOLLYWOODFL', false, 'Groceries'),
    (7, 1, '2026-01-17', '2026-01-19', 44.90, 'PUBLIX #1554HOLLYWOODFL', false, 'Groceries'),
    (7, 1, '2026-01-19', '2026-01-20', 222.57, 'WAL-MART #4563DANIAFL', false, 'Groceries'),
    (7, 11, '2026-01-20', '2026-01-21', 22.49, 'BROWARD COUNTY SCHOOLSUNRISEFL', false, 'Education'),
    (7, 1, '2026-01-20', '2026-01-21', 45.35, 'PUBLIX #1554HOLLYWOODFL', false, 'Groceries'),
    (7, 1, '2026-01-21', '2026-01-22', 44.68, 'EUROPA GOURMETHOLLYWOODFL', false, 'Groceries'),
    (7, 1, '2026-01-23', '2026-01-24', 33.72, 'PUBLIX #1554HOLLYWOODFL', false, 'Groceries'),
    (7, 8, '2026-01-23', '2026-01-26', 233.87, 'Europcar.com/us USD prVoisins-Le-BrFRA', false, 'Travel'),
    (7, 1, '2026-01-24', '2026-01-24', 7.07, 'TST* FARMER''S MILKHOLLYWOODFL', false, 'Groceries'),
    (7, 1, '2026-01-27', '2026-01-28', 30.92, 'EUROPA GOURMETHOLLYWOODFL', false, 'Groceries');

-- Card 8 (6487) - Capital One December 2025 - January 2026
INSERT INTO transaction (card_id, category_id, transaction_date, post_date, amount, description, is_pending, subcategory)
VALUES
    (8, 10, '2026-01-10', '2026-01-10', -64.20, 'CAPITAL ONE MOBILE PYMT', false, 'Payment'),
    (8, 1, '2025-12-20', '2025-12-22', 14.20, 'PUBLIX #1554HOLLYWOODFL', false, 'Groceries');

-- Card 9 (9957) - Capital One January 2026
INSERT INTO transaction (card_id, category_id, transaction_date, post_date, amount, description, is_pending, subcategory)
VALUES
    (9, 10, '2026-01-04', '2026-01-05', -70.00, 'CAPITAL ONE ONLINE PYMT', false, 'Payment');

-- Card 30 (5975) - Amazon Card January-February 2026
INSERT INTO transaction (card_id, category_id, transaction_date, post_date, amount, description, is_pending, subcategory)
VALUES
    (30, 10, '2026-02-01', '2026-02-01', -115.23, 'ONLINE PYMT-THANK YOU ATLANTA GA', false, 'Payment'),
    (30, 10, '2026-02-16', '2026-02-16', -203.29, 'AMAZON MARKETPLACE SEATTLE WA - GOLDENMATE 1000VA/800W Lithium OpeLRyQXdOKm', false, 'Payment'),
    (30, 6, '2026-01-21', '2026-01-21', 50.00, 'AMAZON RETAIL SEATTLE WA - Amazon Physical Gift Card - Mi CeJqdTfbFbju', false, 'Shopping'),
    (30, 57, '2026-01-28', '2026-01-28', 36.37, 'AMAZON MARKETPLACE SEATTLE WA - Fenmzee Grey Bedside Table Lam vqRvbNouanZr', false, 'Housing'),
    (30, 7, '2026-02-02', '2026-02-02', 94.02, 'AMAZON MARKETPLACE SEATTLE WA - ARM & HAMMER Advance White Bak / Oral-B iO Series 5 Ultimate Wh TQYDyuzJkfnU', false, 'Health'),
    (30, 6, '2026-02-03', '2026-02-03', 17.27, 'AMAZON MARKETPLACE SEATTLE WA - Adam''s Polishes Tar 9oz - Heav IHOhmpmAvber', false, 'Shopping'),
    (30, 7, '2026-02-04', '2026-02-04', 11.62, 'AMAZON MARKETPLACE SEATTLE WA - Boka Fluoride Free Toothpaste VCiyCQWUZbbC', false, 'Health'),
    (30, 56, '2026-02-13', '2026-02-13', 203.29, 'AMAZON MARKETPLACE SEATTLE WA - GOLDENMATE 1000VA/800W Lithium shqCHnXYdSdv', false, 'Electronics'),
    (30, 56, '2026-02-17', '2026-02-17', 256.75, 'AMAZON RETAIL SEATTLE WA - CyberPower CP1500PFCLCD PFC Si CURngPtjtvAb', false, 'Electronics');
