-- Create flat transactions table with all details denormalized (spendings only)
CREATE TABLE transactions_flat
(
    id                   SERIAL PRIMARY KEY,
    card_name            VARCHAR(100),
    card_last_four       VARCHAR(4),
    category_name        TEXT,
    subcategory          TEXT,
    transaction_date     DATE           NOT NULL,
    amount               NUMERIC(15, 2) NOT NULL,
    description          TEXT,
    created_at           TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE transactions_flat OWNER TO smarthouse;

/*-- Populate the flat table with spending transactions only (no payments)
INSERT INTO transactions_flat (card_name, card_last_four, category_name, subcategory, transaction_date, amount, description)
VALUES
    -- Card 3 (9573) - February Statement
    ('Oleksii Kuzko', '9573', 'Dining Out', 'Dining Out', '2025-02-08', 32.97, 'SQ *CAMPO MEAT Hallandale BeFL'),
    ('Oleksii Kuzko', '9573', 'Groceries', 'Groceries', '2025-02-08', 105.68, 'NET COST MARKET HOLLYWOOD FL'),
    ('Oleksii Kuzko', '9573', 'Entertainment', 'Entertainment', '2025-02-08', 29.96, 'DAVE & BUSTERS #8 PWC HOLLYWOOD FL'),

    -- Card 6 (1437) - Discover IT Card January-February 2026 Statement
    ('Oksana Kuzko', '1437', 'Entertainment', 'Entertainment', '2026-01-10', 19.99, 'ROBLOX 1.888.858.2569 8888582569 CA'),
    ('Oksana Kuzko', '1437', 'Utilities', 'Utilities', '2026-01-10', 87.28, 'ATT*BILL PAYMENT 800-288-2020 TX GVFB8R97EPAYE02'),
    ('Oksana Kuzko', '1437', 'Subscription', 'Subscription', '2026-01-12', 11.99, 'JOTTACLOUD 34328257 21042900 NOR'),
    ('Oksana Kuzko', '1437', 'Insurance', 'Insurance', '2026-01-13', 247.15, 'GEICO *AUTO 800-841-3000 DC 6211589459000887845891'),
    ('Oksana Kuzko', '1437', 'Subscription', 'Subscription', '2026-01-16', 11.99, 'ADOBE SAN JOSE CA'),
    ('Oksana Kuzko', '1437', 'Utilities', 'Utilities', '2026-01-17', 108.63, 'GOOGLE FI 4STPMJ GOOGLE.COM CA'),
    ('Oksana Kuzko', '1437', 'Groceries', 'Groceries', '2026-01-19', 10.49, 'NET COST MARKET HOLLYWOOD FL GOOGLE PAY ENDING IN 5097'),
    ('Oksana Kuzko', '1437', 'Groceries', 'Groceries', '2026-01-19', 27.27, 'NET COST MARKET HOLLYWOOD FL GOOGLE PAY ENDING IN 5097'),
    ('Oksana Kuzko', '1437', 'Entertainment', 'Entertainment', '2026-01-21', 17.49, 'PLAYSTATIONNETWORK SAN MATEO CA'),
    ('Oksana Kuzko', '1437', 'Subscription', 'Subscription', '2026-01-22', 3.99, '1PASSWORD 8668127277 CAN'),
    ('Oksana Kuzko', '1437', 'Subscription', 'Subscription', '2026-02-02', 1.49, 'GOOGLE *FLIGHTRADAR24 G.CO/HELPPAY#CA P1IKC4QXM'),

    -- Card 7 (8819) - Capital One December 2025 - January 2026
    ('Oleksii Kuzko', '8819', 'Travel', 'Travel', '2025-12-27', 8.00, 'WIFIONBOARD ALASKACHICAGOIL'),
    ('Oleksii Kuzko', '8819', 'Travel', 'Travel', '2025-12-27', 17.50, 'RESIDENCE INN WENATCHEWENATCHEEWA'),
    ('Oleksii Kuzko', '8819', 'Subscription', 'Subscription', '2025-12-27', 3.99, 'PY *SERGIOSMIAMIFL'),
    ('Oleksii Kuzko', '8819', 'Travel', 'Travel', '2025-12-29', 34.50, 'ALASKA AIR IN FLIGHTSEATACWA'),
    ('Oleksii Kuzko', '8819', 'Shopping', 'Shopping', '2025-12-29', 2.00, 'CTLP*CHARACTERS UNLIMIBOULDERCITYNV'),
    ('Oleksii Kuzko', '8819', 'Dining Out', 'Dining Out', '2025-12-29', 15.17, 'STARBUCKS #71537NORTH BENDWA'),
    ('Oleksii Kuzko', '8819', 'Dining Out', 'Dining Out', '2025-12-29', 52.03, 'LUKE''S LOBSTER - PIKESEATTLEWA'),
    ('Oleksii Kuzko', '8819', 'Dining Out', 'Dining Out', '2025-12-29', 22.09, 'JACK''S FISH SPOTSEATTLEWA'),
    ('Oleksii Kuzko', '8819', 'Dining Out', 'Dining Out', '2026-01-02', 14.29, 'BULLWHEEL REST CRYSTALENUMCLAWWA'),
    ('Oleksii Kuzko', '8819', 'Dining Out', 'Dining Out', '2026-01-03', 31.88, 'PIKE&PINE ST2275SEATTLEWA'),
    ('Oleksii Kuzko', '8819', 'Entertainment', 'Entertainment', '2026-01-03', 79.00, 'THE MUSEUM OF FLIGHT MTUKWILAWA'),
    ('Oleksii Kuzko', '8819', 'Entertainment', 'Entertainment', '2026-01-03', 20.00, 'THE MUSEUM OF FLIGHT MTUKWILAWA'),
    ('Oleksii Kuzko', '8819', 'Dining Out', 'Dining Out', '2026-01-03', 92.67, 'AIRPORT CONCESSIONS NWSEATTLEWA'),
    ('Oleksii Kuzko', '8819', 'Travel', 'Travel', '2026-01-04', 17.25, 'ALASKA AIR* QC52WGQA8SEATTLEWA'),
    ('Oleksii Kuzko', '8819', 'Utilities', 'Utilities', '2026-01-04', 200.54, 'CITY OF HOLLYWOOD9549213938FL'),
    ('Oleksii Kuzko', '8819', 'Groceries', 'Groceries', '2026-01-06', 30.11, 'PUBLIX #1554HOLLYWOODFL'),
    ('Oleksii Kuzko', '8819', 'Groceries', 'Groceries', '2026-01-08', 182.25, 'WAL-MART #1996HALLANDALEFL'),
    ('Oleksii Kuzko', '8819', 'Groceries', 'Groceries', '2026-01-08', 56.28, 'EUROPA GOURMETHOLLYWOODFL'),
    ('Oleksii Kuzko', '8819', 'Groceries', 'Groceries', '2026-01-09', 3.99, 'PUBLIX #1554HOLLYWOODFL'),
    ('Oleksii Kuzko', '8819', 'Groceries', 'Groceries', '2026-01-10', 7.93, 'TST* FARMER''S MILKHOLLYWOODFL'),
    ('Oleksii Kuzko', '8819', 'Other', 'Other', '2026-01-11', 6.00, 'NIC*-DEP MIZELL-JOHNSODANIAFL'),
    ('Oleksii Kuzko', '8819', 'Groceries', 'Groceries', '2026-01-14', 19.79, 'PUBLIX #1554HOLLYWOODFL'),
    ('Oleksii Kuzko', '8819', 'Groceries', 'Groceries', '2026-01-16', 66.17, 'PUBLIX #1554HOLLYWOODFL'),
    ('Oleksii Kuzko', '8819', 'Groceries', 'Groceries', '2026-01-17', 7.07, 'TST* FARMER''S MILKHOLLYWOODFL'),
    ('Oleksii Kuzko', '8819', 'Groceries', 'Groceries', '2026-01-17', 44.90, 'PUBLIX #1554HOLLYWOODFL'),
    ('Oleksii Kuzko', '8819', 'Groceries', 'Groceries', '2026-01-19', 222.57, 'WAL-MART #4563DANIAFL'),
    ('Oleksii Kuzko', '8819', 'Education', 'Education', '2026-01-20', 22.49, 'BROWARD COUNTY SCHOOLSUNRISEFL'),
    ('Oleksii Kuzko', '8819', 'Groceries', 'Groceries', '2026-01-20', 45.35, 'PUBLIX #1554HOLLYWOODFL'),
    ('Oleksii Kuzko', '8819', 'Groceries', 'Groceries', '2026-01-21', 44.68, 'EUROPA GOURMETHOLLYWOODFL'),
    ('Oleksii Kuzko', '8819', 'Groceries', 'Groceries', '2026-01-23', 33.72, 'PUBLIX #1554HOLLYWOODFL'),
    ('Oleksii Kuzko', '8819', 'Travel', 'Travel', '2026-01-23', 233.87, 'Europcar.com/us USD prVoisins-Le-BrFRA'),
    ('Oleksii Kuzko', '8819', 'Groceries', 'Groceries', '2026-01-24', 7.07, 'TST* FARMER''S MILKHOLLYWOODFL'),
    ('Oleksii Kuzko', '8819', 'Groceries', 'Groceries', '2026-01-27', 30.92, 'EUROPA GOURMETHOLLYWOODFL'),

    -- Card 8 (6487) - Capital One December 2025 - January 2026
    ('Oleksii Kuzko', '6487', 'Groceries', 'Groceries', '2025-12-20', 14.20, 'PUBLIX #1554HOLLYWOODFL'),

    -- Card 30 (5975) - Amazon Card January-February 2026
    ('Oksana Kuzko', '5975', 'Shopping', 'Shopping', '2026-01-21', 50.00, 'AMAZON RETAIL SEATTLE WA - Amazon Physical Gift Card - Mi CeJqdTfbFbju'),
    ('Oksana Kuzko', '5975', 'Home', 'Housing', '2026-01-28', 36.37, 'AMAZON MARKETPLACE SEATTLE WA - Fenmzee Grey Bedside Table Lam vqRvbNouanZr'),
    ('Oksana Kuzko', '5975', 'Health', 'Health', '2026-02-02', 94.02, 'AMAZON MARKETPLACE SEATTLE WA - ARM & HAMMER Advance White Bak / Oral-B iO Series 5 Ultimate Wh TQYDyuzJkfnU'),
    ('Oksana Kuzko', '5975', 'Shopping', 'Shopping', '2026-02-03', 17.27, 'AMAZON MARKETPLACE SEATTLE WA - Adam''s Polishes Tar 9oz - Heav IHOhmpmAvber'),
    ('Oksana Kuzko', '5975', 'Health', 'Health', '2026-02-04', 11.62, 'AMAZON MARKETPLACE SEATTLE WA - Boka Fluoride Free Toothpaste VCiyCQWUZbbC'),
    ('Oksana Kuzko', '5975', 'Electronics', 'Electronics', '2026-02-13', 203.29, 'AMAZON MARKETPLACE SEATTLE WA - GOLDENMATE 1000VA/800W Lithium shqCHnXYdSdv'),
    ('Oksana Kuzko', '5975', 'Electronics', 'Electronics', '2026-02-17', 256.75, 'AMAZON RETAIL SEATTLE WA - CyberPower CP1500PFCLCD PFC Si CURngPtjtvAb');
*/
-- Create indexes for better query performance
CREATE INDEX idx_transactions_flat_transaction_date ON transactions_flat(transaction_date);
CREATE INDEX idx_transactions_flat_card_last_four ON transactions_flat(card_last_four);
CREATE INDEX idx_transactions_flat_category_name ON transactions_flat(category_name);
CREATE INDEX idx_transactions_flat_subcategory ON transactions_flat(subcategory);
