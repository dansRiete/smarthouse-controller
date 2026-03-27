-- Script to populate first statement for account ending in 3401
-- Period: December 8, 2025 - January 7, 2026 (Inferred year 2025/2026)

DO $$
DECLARE
    v_card_id INTEGER;
    v_cat_payment_id INTEGER;
    v_cat_groceries_id INTEGER;
    v_cat_dining_id INTEGER;
    v_cat_transport_id INTEGER;
    v_cat_travel_id INTEGER;
    v_cat_shopping_id INTEGER;
    v_cat_entertainment_id INTEGER;
    v_cat_subscription_id INTEGER;
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
    SELECT id INTO v_cat_travel_id FROM finance.category WHERE name = 'Travel';
    SELECT id INTO v_cat_shopping_id FROM finance.category WHERE name = 'Shopping';
    SELECT id INTO v_cat_entertainment_id FROM finance.category WHERE name = 'Entertainment';
    SELECT id INTO v_cat_subscription_id FROM finance.category WHERE name = 'Subscription';

    -- Payments and Other Credits
    INSERT INTO finance.transaction (card_id, category_id, transaction_date, post_date, amount, description) VALUES
    (v_card_id, v_cat_payment_id, '2025-12-13', '2025-12-15', 148.30, 'BACKCOUNTRY.COM COTTONWOOD HEUT'),
    (v_card_id, v_cat_payment_id, '2025-12-23', '2025-12-24', 1050.38, 'PAYMENT - THANK YOU'),
    (v_card_id, v_cat_payment_id, '2026-01-04', '2026-01-05', 650.00, 'PAYMENT - THANK YOU');

    -- Purchases and Adjustments
    INSERT INTO finance.transaction (card_id, category_id, transaction_date, post_date, amount, description) VALUES
    (v_card_id, v_cat_groceries_id, '2025-12-07', '2025-12-08', -7.48, 'COSTCO WHSE #0091 DAVIE FL'),
    (v_card_id, v_cat_groceries_id, '2025-12-07', '2025-12-08', -343.26, 'COSTCO WHSE #0091 DAVIE FL'),
    (v_card_id, v_cat_transport_id, '2025-12-07', '2025-12-08', -9.00, 'NAYAX WASH HUNT VALLEY MD'),
    (v_card_id, v_cat_subscription_id, '2025-12-07', '2025-12-09', -10.00, 'JetBrains Americas INC 165-05772345 CA'),
    (v_card_id, v_cat_subscription_id, '2025-12-11', '2025-12-12', -9.99, 'FLUENTLY, INC. GETFLUENTLY.ACA'),
    (v_card_id, v_cat_shopping_id, '2025-12-12', '2025-12-13', -15.00, 'LS WONDERLAND GIFT SH WONDERLAND1.CFL'),
    (v_card_id, v_cat_groceries_id, '2025-12-13', '2025-12-15', -47.04, 'TOTAL WINE & MORE 9 FT LAUDERDALEFL'),
    (v_card_id, v_cat_groceries_id, '2025-12-14', '2025-12-15', -10.49, 'NET COST MARKET HOLLYWOOD FL'),
    (v_card_id, v_cat_groceries_id, '2025-12-14', '2025-12-15', -16.76, 'NET COST MARKET HOLLYWOOD FL'),
    (v_card_id, v_cat_transport_id, '2025-12-16', '2025-12-17', -2.35, 'COH PRKING PAY BY PHONE 954-921-3266 FL'),
    (v_card_id, v_cat_transport_id, '2025-12-16', '2025-12-17', -7.35, 'COH PRKING PAY BY PHONE 954-921-3266 FL'),
    (v_card_id, v_cat_dining_id, '2025-12-16', '2025-12-18', -94.60, 'TST*LEMONICA Hollywood FL'),
    (v_card_id, v_cat_entertainment_id, '2025-12-19', '2025-12-20', -10.00, 'SQ *CRYSTAL MOUNTAIN gosq.com WA'),
    (v_card_id, v_cat_travel_id, '2025-12-20', '2025-12-22', -846.58, 'TURO INC.* TRIP DEC 27 TURO.COM CA'),
    (v_card_id, v_cat_transport_id, '2025-12-21', '2025-12-22', -8.91, 'PARKING PAY PHONE 305-373-6789 FL'),
    (v_card_id, v_cat_transport_id, '2025-12-25', '2025-12-26', -2.51, 'MB-PARKING PARKMOBILE www.parkmobilFL'),
    (v_card_id, v_cat_transport_id, '2025-12-25', '2025-12-26', -1.48, 'MB-PARKING PARKMOBILE www.parkmobilFL'),
    (v_card_id, v_cat_dining_id, '2025-12-25', '2025-12-27', -90.12, 'HOLLYWOOD BREWERY HOLLYWOOD FL'),
    (v_card_id, v_cat_travel_id, '2025-12-26', '2025-12-29', -35.00, 'ALASKA AIR SEATTLE WA'),
    (v_card_id, v_cat_entertainment_id, '2025-12-27', '2025-12-29', -34.50, 'SQ *PRAYER OUT REACH SERVLeavenworth WA'),
    (v_card_id, v_cat_dining_id, '2025-12-27', '2025-12-29', -65.26, 'APPLEBEES 2110015 TUKWILA WA'),
    (v_card_id, v_cat_transport_id, '2025-12-28', '2025-12-29', -4.30, 'CITY OF LEAVENWORTH 509-5485275 WA'),
    (v_card_id, v_cat_travel_id, '2025-12-28', '2025-12-29', -90.00, 'RESIDENCE INN WENATCHE WENATCHEE WA'),
    (v_card_id, v_cat_transport_id, '2025-12-28', '2025-12-30', -6.30, 'CITY OF LEAVENWORTH 509-5485275 WA'),
    (v_card_id, v_cat_groceries_id, '2025-12-28', '2025-12-30', -74.25, 'SAFEWAY #1589 LEAVENWORTH WA'),
    (v_card_id, v_cat_dining_id, '2025-12-29', '2025-12-30', -126.51, 'TST*KRISTALLS RESTAURAN 509-548-5267 WA'),
    (v_card_id, v_cat_shopping_id, '2025-12-29', '2025-12-30', -190.64, 'WAL-MART #3794 FEDERAL WAY WA'),
    (v_card_id, v_cat_groceries_id, '2025-12-29', '2025-12-30', -13.21, 'TOTAL WINE AND MORE FEDERAL WAY WA'),
    (v_card_id, v_cat_groceries_id, '2025-12-29', '2025-12-30', -115.20, 'EURO FOOD AND DELI FEDER FEDERAL WAY WA'),
    (v_card_id, v_cat_transport_id, '2025-12-29', '2025-12-31', -83.48, 'SHELL OIL 57445613102 NORTH BEND WA'),
    (v_card_id, v_cat_travel_id, '2025-12-29', '2025-12-31', -584.68, 'RESIDENCE INN WENATCHE WENATCHEE WA'),
    (v_card_id, v_cat_travel_id, '2025-12-29', '2025-12-31', -21.00, 'RESIDENCE INN WENATCHE WENATCHEE WA'),
    (v_card_id, v_cat_dining_id, '2025-12-30', '2025-12-31', -64.56, 'WHITE PASS CO RESTAURANT NACHES WA'),
    (v_card_id, v_cat_entertainment_id, '2026-01-02', '2026-01-05', -56.45, 'CRYSTAL MTN BOOTPACK ENUMCLAW WA'),
    (v_card_id, v_cat_entertainment_id, '2026-01-02', '2026-01-05', -149.18, 'CRYSTAL MTN SKI RENTAL ENUMCLAW WA'),
    (v_card_id, v_cat_entertainment_id, '2026-01-02', '2026-01-05', -38.92, 'CRYSTAL MTN SKI RENTAL ENUMCLAW WA'),
    (v_card_id, v_cat_travel_id, '2026-01-02', '2026-01-05', -35.00, 'ALASKA AIR SEATTLE WA'),
    (v_card_id, v_cat_transport_id, '2026-01-03', '2026-01-05', -92.94, '76 - DBA SEATAC BP SEATAC WA'),
    (v_card_id, v_cat_dining_id, '2026-01-03', '2026-01-05', -66.89, 'APPLEBEES 2110015 TUKWILA WA'),
    (v_card_id, v_cat_shopping_id, '2026-01-04', '2026-01-05', -40.87, 'TENDER LOVING EMPIRE 150-37290841 WA'),
    (v_card_id, v_cat_groceries_id, '2026-01-04', '2026-01-05', -55.13, 'PUBLIX #1693 HOLLYWOOD FL'),
    (v_card_id, v_cat_transport_id, '2026-01-04', '2026-01-06', -39.15, '7-ELEVEN 30002 HOLLYWOOD FL');

    -- Statement Summary
    -- Statement Balance: Purchases ($3,616.34) - Payments ($1,848.68) = $1,767.66
    -- Assuming a starting balance of 0 for the first statement.
    INSERT INTO finance.statement (card_id, statement_date, due_date, statement_balance, minimum_payment, paid_amount, is_fully_paid)
    VALUES (v_card_id, '2026-01-07', '2026-02-01', 1767.66, 35.00, 0, FALSE);

END $$;
