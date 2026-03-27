-- Script to populate historical statements for Amazon card ID 30
-- Periods: January 2025 - October 2025
-- Categorizing based on descriptions

DO $$
DECLARE
    v_card_id INTEGER := 30;
    v_cat_payment_id INTEGER;
    v_cat_shopping_id INTEGER;
    v_cat_entertainment_id INTEGER;
    v_cat_subscription_id INTEGER;
    v_cat_electronics_id INTEGER;
    v_cat_home_id INTEGER;
    v_cat_food_id INTEGER;
    v_cat_education_id INTEGER;
    v_cat_transportation_id INTEGER;
    v_cat_health_id INTEGER;
    v_cat_other_id INTEGER;
BEGIN
    -- Ensure categories exist
    INSERT INTO finance.category (name) VALUES 
    ('Entertainment'), ('Subscription'), ('Shopping'), ('Electronics'), ('Home'), ('Food'), ('Education'), ('Transportation'), ('Health'), ('Other')
    ON CONFLICT (name) DO NOTHING;

    -- Get category IDs
    SELECT id INTO v_cat_payment_id FROM finance.category WHERE name = 'Payment';
    SELECT id INTO v_cat_shopping_id FROM finance.category WHERE name = 'Shopping';
    SELECT id INTO v_cat_entertainment_id FROM finance.category WHERE name = 'Entertainment';
    SELECT id INTO v_cat_subscription_id FROM finance.category WHERE name = 'Subscription';
    SELECT id INTO v_cat_electronics_id FROM finance.category WHERE name = 'Electronics';
    SELECT id INTO v_cat_home_id FROM finance.category WHERE name = 'Home';
    SELECT id INTO v_cat_food_id FROM finance.category WHERE name = 'Food';
    SELECT id INTO v_cat_education_id FROM finance.category WHERE name = 'Education';
    SELECT id INTO v_cat_transportation_id FROM finance.category WHERE name = 'Transportation';
    SELECT id INTO v_cat_health_id FROM finance.category WHERE name = 'Health';
    SELECT id INTO v_cat_other_id FROM finance.category WHERE name = 'Other';

    ---------------------------------------------------------------------------
    -- OCTOBER 2025 STATEMENT (Closing approx Oct 23)
    ---------------------------------------------------------------------------
    -- Payments
    INSERT INTO finance.transaction (card_id, category_id, transaction_date, post_date, amount, description) VALUES
    (v_card_id, v_cat_payment_id, '2025-09-24', '2025-09-24', 994.03, 'ONLINE PYMT-THANK YOU ATLANTA'),
    (v_card_id, v_cat_payment_id, '2025-09-30', '2025-09-30', 420.00, 'ONLINE PYMT-THANK YOU ATLANTA'),
    (v_card_id, v_cat_payment_id, '2025-10-15', '2025-10-15', 54.28, 'ONLINE PYMT-THANK YOU ATLANTA');

    -- Other Credits
    INSERT INTO finance.transaction (card_id, category_id, transaction_date, post_date, amount, description) VALUES
    (v_card_id, v_cat_electronics_id, '2025-09-19', '2025-09-19', 519.75, 'CREDIT: AMAZON MARKETPLACE (BTF-LIGHTING)'),
    (v_card_id, v_cat_electronics_id, '2025-09-19', '2025-09-19', 122.15, 'CREDIT: AMAZON MARKETPLACE'),
    (v_card_id, v_cat_electronics_id, '2025-10-19', '2025-10-19', 33.16, 'CREDIT: AMAZON MARKETPLACE'),
    (v_card_id, v_cat_electronics_id, '2025-10-19', '2025-10-19', 49.21, 'CREDIT: AMAZON MARKETPLACE');

    -- Purchases
    INSERT INTO finance.transaction (card_id, category_id, transaction_date, post_date, amount, description) VALUES
    (v_card_id, v_cat_electronics_id, '2025-09-21', '2025-09-21', -7.69, 'AMAZON MARKETPLACE: SONOFF Zigbee Smart Plug'),
    (v_card_id, v_cat_electronics_id, '2025-09-26', '2025-09-26', -32.09, 'AMAZON MARKETPLACE: Mouse Pad, Large Gaming Mouse'),
    (v_card_id, v_cat_electronics_id, '2025-10-01', '2025-10-01', -657.80, 'AMAZON MARKETPLACE: SONOFF Zigbee Smart Light Swit'),
    (v_card_id, v_cat_electronics_id, '2025-10-01', '2025-10-01', -8.04, 'AMAZON MARKETPLACE: DC 5.5mm x 2.1mm to USB C Powe'),
    (v_card_id, v_cat_electronics_id, '2025-10-02', '2025-10-02', -28.86, 'AMAZON MARKETPLACE: Addtam Surge Protector Outlet'),
    (v_card_id, v_cat_electronics_id, '2025-10-06', '2025-10-06', -26.74, 'AMAZON MARKETPLACE: Zigbee Smart Switch no Neutral'),
    (v_card_id, v_cat_electronics_id, '2025-10-06', '2025-10-06', -32.09, 'AMAZON MARKETPLACE: SONOFF Zigbee Smart Light Swit'),
    (v_card_id, v_cat_home_id, '2025-10-12', '2025-10-12', -78.08, 'AMAZON MARKETPLACE: Mosquito Repellent Coils'),
    (v_card_id, v_cat_health_id, '2025-10-12', '2025-10-12', -26.74, 'AMAZON MARKETPLACE: Inspire Black Nitrile Gloves'),
    (v_card_id, v_cat_entertainment_id, '2025-10-12', '2025-10-12', -2.01, 'AMAZON MARKETPLACE: GIFTINBOX Army Costume for Kid'),
    (v_card_id, v_cat_home_id, '2025-10-15', '2025-10-15', -15.13, 'AMAZON RETAIL: Mind Reader Mesh Trash Can'),
    (v_card_id, v_cat_subscription_id, '2025-10-16', '2025-10-16', -15.13, 'AMAZON PRIME CONS');

    -- Oct Statement: Balance calculation
    -- Credits: 994.03 + 420.00 + 54.28 + 519.75 + 122.15 + 33.16 + 49.21 = 2192.58
    -- Debits: 7.69 + 32.09 + 657.80 + 8.04 + 28.86 + 26.74 + 32.09 + 78.08 + 26.74 + 2.01 + 15.13 + 15.13 = 930.40
    -- Balance change: -1262.18
    INSERT INTO finance.statement (card_id, statement_date, due_date, statement_balance, minimum_payment, paid_amount, is_fully_paid)
    VALUES (v_card_id, '2025-10-23', '2025-11-17', 0.00, 0.00, 1468.31, TRUE)
    ON CONFLICT (card_id, statement_date) DO NOTHING;

    ---------------------------------------------------------------------------
    -- SEPTEMBER 2025 STATEMENT
    ---------------------------------------------------------------------------
    -- Payments
    INSERT INTO finance.transaction (card_id, category_id, transaction_date, post_date, amount, description) VALUES
    (v_card_id, v_cat_payment_id, '2025-08-29', '2025-08-29', 702.65, 'ONLINE PYMT-THANK YOU ATLANTA');

    -- Purchases
    INSERT INTO finance.transaction (card_id, category_id, transaction_date, post_date, amount, description) VALUES
    (v_card_id, v_cat_home_id, '2025-08-22', '2025-08-22', -695.46, 'AMAZON RETAIL: T-Fal Ultraglide Steam Iron'),
    (v_card_id, v_cat_electronics_id, '2025-08-23', '2025-08-23', -54.91, 'AMAZON MARKETPLACE: Zulkit 5Pcs Project Boxes ABS'),
    (v_card_id, v_cat_electronics_id, '2025-08-26', '2025-08-26', -9.62, 'AMAZON RETAIL: TP-Link WiFi 7 BE9300 PCIe WiFi'),
    (v_card_id, v_cat_transportation_id, '2025-08-27', '2025-08-27', -54.48, 'AMAZON MARKETPLACE: BMW 61612447932 Front Wiper Bl'),
    (v_card_id, v_cat_electronics_id, '2025-08-29', '2025-08-29', -56.70, 'AMAZON MARKETPLACE: Muzata 6Pack LED Channels'),
    (v_card_id, v_cat_electronics_id, '2025-08-29', '2025-08-29', -35.29, 'AMAZON MARKETPLACE: BTF-LIGHTING FCOB USB Powered'),
    (v_card_id, v_cat_home_id, '2025-08-30', '2025-08-30', -85.59, 'AMAZON MARKETPLACE: BAYKA Floating Shelves'),
    (v_card_id, v_cat_entertainment_id, '2025-08-30', '2025-08-30', -16.78, 'AMAZON RETAIL: CAP Barbell High Density Exerc'),
    (v_card_id, v_cat_entertainment_id, '2025-08-31', '2025-08-31', -29.95, 'AMAZON MARKETPLACE: Sportneer Adjustable Weighted'),
    (v_card_id, v_cat_home_id, '2025-08-31', '2025-08-31', -22.16, 'AMAZON MARKETPLACE: FANHAO Upgraded Garden Hose No'),
    (v_card_id, v_cat_home_id, '2025-09-02', '2025-09-02', -18.18, 'AMAZON MARKETPLACE: Ddrihlees Mosquito Repeller'),
    (v_card_id, v_cat_electronics_id, '2025-09-04', '2025-09-04', -7.48, 'AMAZON MARKETPLACE: BTF-LIGHTING FCOB USB Powered'),
    (v_card_id, v_cat_electronics_id, '2025-09-04', '2025-09-04', -33.16, 'AMAZON MARKETPLACE: BTF-LIGHTING 10-Pack 1.64ft'),
    (v_card_id, v_cat_education_id, '2025-09-05', '2025-09-05', -4.27, 'AMAZON MARKETPLACE: Mr. Pen- Ruler, Rulers 12 inch'),
    (v_card_id, v_cat_home_id, '2025-09-05', '2025-09-05', -16.04, 'AMAZON MARKETPLACE: Collapsible Bucket'),
    (v_card_id, v_cat_electronics_id, '2025-09-05', '2025-09-05', -9.62, 'AMAZON MARKETPLACE: Zulkit Junction Box ABS Plasti'),
    (v_card_id, v_cat_subscription_id, '2025-09-05', '2025-09-05', -15.13, 'AMAZON PRIME CONS'),
    (v_card_id, v_cat_electronics_id, '2025-09-08', '2025-09-08', -27.81, 'AMAZON MARKETPLACE: Muzata 6Pack LED Channel'),
    (v_card_id, v_cat_electronics_id, '2025-09-09', '2025-09-09', -7.48, 'AMAZON MARKETPLACE: BTF-LIGHTING FCOB USB Powered'),
    (v_card_id, v_cat_electronics_id, '2025-09-12', '2025-09-12', -11.12, 'AMAZON MARKETPLACE: 18 Gauge Wire 2 Conductor'),
    (v_card_id, v_cat_electronics_id, '2025-09-12', '2025-09-12', -14.97, 'AMAZON MARKETPLACE: OCR 600pcs Cable Clips'),
    (v_card_id, v_cat_electronics_id, '2025-09-12', '2025-09-12', -65.24, 'AMAZON MARKETPLACE: MTDZKJG 5V 6A Power Supply'),
    (v_card_id, v_cat_electronics_id, '2025-09-13', '2025-09-13', -49.21, 'AMAZON MARKETPLACE: BTF-LIGHTING Tuya Zigbee / SONOFF'),
    (v_card_id, v_cat_electronics_id, '2025-09-16', '2025-09-16', -41.72, 'AMAZON MARKETPLACE: SONOFF Zigbee Smart Plug'),
    (v_card_id, v_cat_electronics_id, '2025-09-18', '2025-09-18', -8.55, 'AMAZON MARKETPLACE: BTF-LIGHTING FCOB USB Powered');

    INSERT INTO finance.statement (card_id, statement_date, due_date, statement_balance, minimum_payment, paid_amount, is_fully_paid)
    VALUES (v_card_id, '2025-09-23', '2025-10-17', 587.46, 25.00, 702.65, FALSE)
    ON CONFLICT (card_id, statement_date) DO NOTHING;

    ---------------------------------------------------------------------------
    -- AUGUST 2025 STATEMENT
    ---------------------------------------------------------------------------
    -- Payments
    INSERT INTO finance.transaction (card_id, category_id, transaction_date, post_date, amount, description) VALUES
    (v_card_id, v_cat_payment_id, '2025-07-31', '2025-07-31', 2041.84, 'ONLINE PYMT-THANK YOU ATLANTA');

    -- Other Credits
    INSERT INTO finance.transaction (card_id, category_id, transaction_date, post_date, amount, description) VALUES
    (v_card_id, v_cat_home_id, '2025-08-14', '2025-08-14', 42.26, 'CREDIT: AMAZON MARKETPLACE (MASTERY MART)'),
    (v_card_id, v_cat_home_id, '2025-08-14', '2025-08-14', 18.29, 'CREDIT: AMAZON MARKETPLACE (KASEDA)');

    -- Purchases
    INSERT INTO finance.transaction (card_id, category_id, transaction_date, post_date, amount, description) VALUES
    (v_card_id, v_cat_home_id, '2025-08-06', '2025-08-06', -128.08, 'AMAZON MARKETPLACE: CINOTON 50W LED Flood Light'),
    (v_card_id, v_cat_home_id, '2025-08-06', '2025-08-06', -25.19, 'AMAZON MARKETPLACE: Hakka Barbecue / VEVOR Vacuum'),
    (v_card_id, v_cat_home_id, '2025-08-07', '2025-08-07', -23.97, 'AMAZON MARKETPLACE: Goutime Shish / Fireplace Shovel'),
    (v_card_id, v_cat_home_id, '2025-08-08', '2025-08-08', -8.51, 'AMAZON MARKETPLACE: Amazon Basics MR16 LED Light B'),
    (v_card_id, v_cat_home_id, '2025-08-08', '2025-08-08', -16.03, 'AMAZON MARKETPLACE: KASEDA Stainless Steel Adjusta'),
    (v_card_id, v_cat_electronics_id, '2025-08-08', '2025-08-08', -15.24, 'AMAZON MARKETPLACE: Electrical Replacement Plugs'),
    (v_card_id, v_cat_home_id, '2025-08-08', '2025-08-08', -17.79, 'AMAZON MARKETPLACE: MIK Solutions LED Lights Brass'),
    (v_card_id, v_cat_electronics_id, '2025-08-08', '2025-08-08', -18.29, 'AMAZON MARKETPLACE: 22 Gauge 2 Conductor Electrical'),
    (v_card_id, v_cat_electronics_id, '2025-08-10', '2025-08-10', -14.85, 'AMAZON MARKETPLACE: 3 Prong Light Socket Outlet'),
    (v_card_id, v_cat_home_id, '2025-08-12', '2025-08-12', -53.49, 'AMAZON MARKETPLACE: MASTERY MART 5.5W Dimmable'),
    (v_card_id, v_cat_electronics_id, '2025-08-14', '2025-08-14', -39.21, 'AMAZON MARKETPLACE: Teyleten Robot ESP32-C3'),
    (v_card_id, v_cat_home_id, '2025-08-14', '2025-08-14', -35.24, 'AMAZON RETAIL: KRUPS Electric Kettle'),
    (v_card_id, v_cat_home_id, '2025-08-17', '2025-08-17', -128.39, 'AMAZON MARKETPLACE: Amazon Basics MR16 / Whirlpool'),
    (v_card_id, v_cat_home_id, '2025-08-18', '2025-08-18', -29.95, 'AMAZON MARKETPLACE: WishDirect Pots / Aluvor Stopper'),
    (v_card_id, v_cat_home_id, '2025-08-18', '2025-08-18', -14.97, 'AMAZON MARKETPLACE: FITUEYES Iron Base TV Stand'),
    (v_card_id, v_cat_electronics_id, '2025-08-20', '2025-08-20', -20.00, 'AMAZON MARKETPLACE: 328ft Wire Rope Crimping Tool'),
    (v_card_id, v_cat_electronics_id, '2025-08-21', '2025-08-21', -15.00, 'AMAZON MARKETPLACE: XIITIA 5V 4 Channel Relay');

    INSERT INTO finance.statement (card_id, statement_date, due_date, statement_balance, minimum_payment, paid_amount, is_fully_paid)
    VALUES (v_card_id, '2025-08-23', '2025-09-17', 503.70, 25.00, 2041.84, FALSE)
    ON CONFLICT (card_id, statement_date) DO NOTHING;

    ---------------------------------------------------------------------------
    -- JULY 2025 STATEMENT
    ---------------------------------------------------------------------------
    -- Payments
    INSERT INTO finance.transaction (card_id, category_id, transaction_date, post_date, amount, description) VALUES
    (v_card_id, v_cat_payment_id, '2025-06-28', '2025-06-28', 175.65, 'ONLINE PYMT-THANK YOU ATLANTA'),
    (v_card_id, v_cat_payment_id, '2025-07-08', '2025-07-08', 1000.00, 'ONLINE PYMT-THANK YOU ATLANTA');

    -- Other Credits
    INSERT INTO finance.transaction (card_id, category_id, transaction_date, post_date, amount, description) VALUES
    (v_card_id, v_cat_home_id, '2025-07-06', '2025-07-06', 32.09, 'CREDIT: AMAZON MARKETPLACE (Roamoris)'),
    (v_card_id, v_cat_other_id, '2025-07-08', '2025-07-08', 343.00, 'REWARDS REDEMPTION'),
    (v_card_id, v_cat_shopping_id, '2025-07-17', '2025-07-17', 33.99, 'CREDIT: AMAZON MARKETPLACE (VITUOFLY)');

    -- Purchases
    INSERT INTO finance.transaction (card_id, category_id, transaction_date, post_date, amount, description) VALUES
    (v_card_id, v_cat_shopping_id, '2025-06-28', '2025-06-28', -15.13, 'AMAZON MARKETPLACE: VITUOFLY Boys Sneakers'),
    (v_card_id, v_cat_subscription_id, '2025-06-29', '2025-06-29', -6.87, 'AMAZON PRIME CONS'),
    (v_card_id, v_cat_entertainment_id, '2025-07-01', '2025-07-01', -39.58, 'AMAZON MARKETPLACE: UNO / Poker Chips'),
    (v_card_id, v_cat_home_id, '2025-07-02', '2025-07-02', -31.02, 'AMAZON MARKETPLACE: Roamoris small pump'),
    (v_card_id, v_cat_home_id, '2025-07-02', '2025-07-02', -32.09, 'AMAZON MARKETPLACE: Roamoris Small Pump'),
    (v_card_id, v_cat_health_id, '2025-07-02', '2025-07-02', -51.36, 'AMAZON MARKETPLACE: Coco & Eve Shampoo'),
    (v_card_id, v_cat_education_id, '2025-07-03', '2025-07-03', -8.55, 'AMAZON RETAIL: Pilot Log Book'),
    (v_card_id, v_cat_electronics_id, '2025-07-06', '2025-07-06', -2672.86, 'AMAZON RETAIL: Sony 77 Inch OLED 4K TV'),
    (v_card_id, v_cat_shopping_id, '2025-07-14', '2025-07-14', -76.78, 'AMAZON MARKETPLACE: Asge Backpack / VITUOFLY Sneakers'),
    (v_card_id, v_cat_electronics_id, '2025-07-15', '2025-07-15', -481.49, 'AMAZON RETAIL: TP-Link Archer BE24000 Router'),
    (v_card_id, v_cat_shopping_id, '2025-07-16', '2025-07-16', -35.19, 'AMAZON MARKETPLACE: VITUOFLY Boys Sneakers');

    INSERT INTO finance.statement (card_id, statement_date, due_date, statement_balance, minimum_payment, paid_amount, is_fully_paid)
    VALUES (v_card_id, '2025-07-23', '2025-08-17', 1974.45, 50.00, 1175.65, FALSE)
    ON CONFLICT (card_id, statement_date) DO NOTHING;

    ---------------------------------------------------------------------------
    -- JUNE 2025 STATEMENT
    ---------------------------------------------------------------------------
    -- Payments
    INSERT INTO finance.transaction (card_id, category_id, transaction_date, post_date, amount, description) VALUES
    (v_card_id, v_cat_payment_id, '2025-05-27', '2025-05-27', 63.64, 'ONLINE PYMT-THANK YOU ATLANTA'),
    (v_card_id, v_cat_payment_id, '2025-06-02', '2025-06-02', 227.13, 'ONLINE PYMT-THANK YOU ATLANTA');

    -- Purchases
    INSERT INTO finance.transaction (card_id, category_id, transaction_date, post_date, amount, description) VALUES
    (v_card_id, v_cat_education_id, '2025-05-28', '2025-05-28', -29.23, 'AMAZON RETAIL: FAR/AIM 2025'),
    (v_card_id, v_cat_education_id, '2025-05-28', '2025-05-28', -16.56, 'AMAZON MARKETPLACE: Book Glue / Zebra Pen'),
    (v_card_id, v_cat_electronics_id, '2025-05-28', '2025-05-28', -8.55, 'AMAZON MARKETPLACE: WAYLLSHINE Red LED'),
    (v_card_id, v_cat_subscription_id, '2025-05-28', '2025-05-28', -15.13, 'AMAZON PRIME CONS'),
    (v_card_id, v_cat_entertainment_id, '2025-05-31', '2025-05-31', -18.09, 'AMAZON MARKETPLACE: Responsive Yoyo'),
    (v_card_id, v_cat_home_id, '2025-05-31', '2025-05-31', -39.57, 'AMAZON MARKETPLACE: Damp Dusting Sponge / Fleece Blanket'),
    (v_card_id, v_cat_electronics_id, '2025-06-12', '2025-06-12', -5.85, 'AMAZON RETAIL: Energizer 2032 Batteries'),
    (v_card_id, v_cat_home_id, '2025-06-12', '2025-06-12', -14.97, 'AMAZON MARKETPLACE: Cocous Natural Coconut Charcoa'),
    (v_card_id, v_cat_transportation_id, '2025-06-12', '2025-06-12', -13.68, 'AMAZON MARKETPLACE: Premium Shammy Cloth for Car'),
    (v_card_id, v_cat_health_id, '2025-06-17', '2025-06-17', -132.67, 'AMAZON RETAIL: BACtrack S80 Breathalyzer'),
    (v_card_id, v_cat_health_id, '2025-06-17', '2025-06-17', -8.48, 'AMAZON RETAIL: Neosporin Original');

    INSERT INTO finance.statement (card_id, statement_date, due_date, statement_balance, minimum_payment, paid_amount, is_fully_paid)
    VALUES (v_card_id, '2025-06-23', '2025-07-17', 52.01, 25.00, 290.77, FALSE)
    ON CONFLICT (card_id, statement_date) DO NOTHING;

    ---------------------------------------------------------------------------
    -- MAY 2025 STATEMENT
    ---------------------------------------------------------------------------
    -- Payments
    INSERT INTO finance.transaction (card_id, category_id, transaction_date, post_date, amount, description) VALUES
    (v_card_id, v_cat_payment_id, '2025-04-21', '2025-04-21', 83.00, 'ONLINE PYMT-THANK YOU ATLANTA');

    -- Other Credits
    INSERT INTO finance.transaction (card_id, category_id, transaction_date, post_date, amount, description) VALUES
    (v_card_id, v_cat_transportation_id, '2025-04-24', '2025-04-24', 32.05, 'CREDIT: AMAZON MARKETPLACE (ExoForma)');

    -- Purchases
    INSERT INTO finance.transaction (card_id, category_id, transaction_date, post_date, amount, description) VALUES
    (v_card_id, v_cat_transportation_id, '2025-04-24', '2025-04-24', -5.26, 'AMAZON MARKETPLACE: ExoForma Mega Car Drying Towel'),
    (v_card_id, v_cat_health_id, '2025-04-24', '2025-04-24', -5.34, 'AMAZON MARKETPLACE: Cotton Wool Balls'),
    (v_card_id, v_cat_electronics_id, '2025-04-25', '2025-04-25', -34.54, 'AMAZON MARKETPLACE: EZYUMM 3 Pack Ethernet Coupler'),
    (v_card_id, v_cat_entertainment_id, '2025-05-11', '2025-05-11', -24.34, 'AMAZON MARKETPLACE: Mini Lottoyday / Finger Skateboard'),
    (v_card_id, v_cat_electronics_id, '2025-05-11', '2025-05-11', -2.01, 'AMAZON MARKETPLACE: Sabrent USB 3.2 Type-C'),
    (v_card_id, v_cat_subscription_id, '2025-05-17', '2025-05-17', -6.94, 'AMAZON PRIME CONS'),
    (v_card_id, v_cat_home_id, '2025-05-17', '2025-05-17', -37.44, 'AMAZON MARKETPLACE: Hookah Tips / NIVEA Kids');

    INSERT INTO finance.statement (card_id, statement_date, due_date, statement_balance, minimum_payment, paid_amount, is_fully_paid)
    VALUES (v_card_id, '2025-05-23', '2025-06-17', 0.00, 0.00, 83.00, TRUE)
    ON CONFLICT (card_id, statement_date) DO NOTHING;

    ---------------------------------------------------------------------------
    -- APRIL 2025 STATEMENT
    ---------------------------------------------------------------------------
    -- Payments
    INSERT INTO finance.transaction (card_id, category_id, transaction_date, post_date, amount, description) VALUES
    (v_card_id, v_cat_payment_id, '2025-04-01', '2025-04-01', 141.70, 'ONLINE PYMT-THANK YOU ATLANTA'),
    (v_card_id, v_cat_payment_id, '2025-04-08', '2025-04-08', 50.00, 'ONLINE PYMT-THANK YOU ATLANTA'),
    (v_card_id, v_cat_payment_id, '2025-04-08', '2025-04-08', 162.81, 'ONLINE PYMT-THANK YOU ATLANTA');

    -- Purchases
    INSERT INTO finance.transaction (card_id, category_id, transaction_date, post_date, amount, description) VALUES
    (v_card_id, v_cat_electronics_id, '2025-04-01', '2025-04-01', -37.09, 'AMAZON MARKETPLACE: DisplayPort 1.4 / Metal Stapler'),
    (v_card_id, v_cat_transportation_id, '2025-04-01', '2025-04-01', -92.66, 'AMAZON MARKETPLACE: Wheel Bearing Grease / Anti Seize'),
    (v_card_id, v_cat_electronics_id, '2025-04-03', '2025-04-03', -47.60, 'AMAZON MARKETPLACE: Magnetic Socket / Dispense All'),
    (v_card_id, v_cat_transportation_id, '2025-04-03', '2025-04-03', -35.46, 'AMAZON MARKETPLACE: NGK Spark Plug LFR6A'),
    (v_card_id, v_cat_transportation_id, '2025-04-12', '2025-04-12', -19.25, 'AMAZON MARKETPLACE: RAM Mounts Twist-Lock'),
    (v_card_id, v_cat_health_id, '2025-04-18', '2025-04-18', -57.73, 'AMAZON MARKETPLACE: Gillette PRO / Socket Adapter'),
    (v_card_id, v_cat_entertainment_id, '2025-04-18', '2025-04-18', -83.21, 'AMAZON MARKETPLACE: Mini Finger Toy / ExoForma Kit / Flight Suppl');

    INSERT INTO finance.statement (card_id, statement_date, due_date, statement_balance, minimum_payment, paid_amount, is_fully_paid)
    VALUES (v_card_id, '2025-04-23', '2025-05-17', 18.49, 25.00, 354.51, FALSE)
    ON CONFLICT (card_id, statement_date) DO NOTHING;

    ---------------------------------------------------------------------------
    -- MARCH 2025 STATEMENT
    ---------------------------------------------------------------------------
    -- Payments
    INSERT INTO finance.transaction (card_id, category_id, transaction_date, post_date, amount, description) VALUES
    (v_card_id, v_cat_payment_id, '2025-02-25', '2025-02-25', 501.36, 'ONLINE PYMT-THANK YOU ATLANTA');

    -- Purchases
    INSERT INTO finance.transaction (card_id, category_id, transaction_date, post_date, amount, description) VALUES
    (v_card_id, v_cat_shopping_id, '2025-02-18', '2025-02-18', -175.44, 'AMAZON RETAIL: New Balance Shoes / Apple Pencil Pro'),
    (v_card_id, v_cat_entertainment_id, '2025-02-18', '2025-02-18', -184.11, 'AMAZON MARKETPLACE: MS Flight Simulator / iPad Folio'),
    (v_card_id, v_cat_home_id, '2025-02-18', '2025-02-18', -34.69, 'AMAZON MARKETPLACE: Refrigerator Water Filter'),
    (v_card_id, v_cat_health_id, '2025-02-18', '2025-02-18', -15.13, 'AMAZON MARKETPLACE: Nivea Kids / Gillette Fusion'),
    (v_card_id, v_cat_subscription_id, '2025-02-19', '2025-02-19', -73.82, 'AMAZON PRIME CONS'),
    (v_card_id, v_cat_electronics_id, '2025-02-21', '2025-02-21', -10.69, 'AMAZON MARKETPLACE: GoPro Mic Adapter / FAR AIM Tabs'),
    (v_card_id, v_cat_shopping_id, '2025-02-27', '2025-02-27', -6.84, 'AMAZON MARKETPLACE: WRAPAHOLIC Reversible Birthday'),
    (v_card_id, v_cat_shopping_id, '2025-03-13', '2025-03-13', -18.18, 'AMAZON MARKETPLACE: Clear Sheet Protectors'),
    (v_card_id, v_cat_shopping_id, '2025-03-13', '2025-03-13', -28.88, 'AMAZON RETAIL: Funny Lucky Dude Boys Shirt'),
    (v_card_id, v_cat_electronics_id, '2025-03-14', '2025-03-14', -30.91, 'AMAZON MARKETPLACE: MutecPower USB / HDMI Cable'),
    (v_card_id, v_cat_home_id, '2025-03-16', '2025-03-16', -48.34, 'AMAZON MARKETPLACE: SENSARTE Frying Pan'),
    (v_card_id, v_cat_education_id, '2025-03-17', '2025-03-17', -8.55, 'AMAZON RETAIL: Pilot Log Book');

    INSERT INTO finance.statement (card_id, statement_date, due_date, statement_balance, minimum_payment, paid_amount, is_fully_paid)
    VALUES (v_card_id, '2025-03-23', '2025-04-17', 134.22, 25.00, 501.36, FALSE)
    ON CONFLICT (card_id, statement_date) DO NOTHING;

    ---------------------------------------------------------------------------
    -- FEBRUARY 2025 STATEMENT
    ---------------------------------------------------------------------------
    -- Payments
    INSERT INTO finance.transaction (card_id, category_id, transaction_date, post_date, amount, description) VALUES
    (v_card_id, v_cat_payment_id, '2025-01-27', '2025-01-27', 175.74, 'ONLINE PYMT-THANK YOU ATLANTA');

    -- Purchases
    INSERT INTO finance.transaction (card_id, category_id, transaction_date, post_date, amount, description) VALUES
    (v_card_id, v_cat_electronics_id, '2025-01-23', '2025-01-23', -169.43, 'AMAZON MARKETPLACE: RJ45 Crimping Tool / Heat Shrink'),
    (v_card_id, v_cat_health_id, '2025-01-25', '2025-01-25', -17.27, 'AMAZON RETAIL: Neutrogena Healthy Lengths Mascara'),
    (v_card_id, v_cat_electronics_id, '2025-01-25', '2025-01-25', -10.66, 'AMAZON MARKETPLACE: Dutevolns Cat 6 Ethernet'),
    (v_card_id, v_cat_electronics_id, '2025-01-25', '2025-01-25', -114.48, 'AMAZON MARKETPLACE: Energizer 9V Batteries');

    INSERT INTO finance.statement (card_id, statement_date, due_date, statement_balance, minimum_payment, paid_amount, is_fully_paid)
    VALUES (v_card_id, '2025-02-23', '2025-03-17', 136.10, 25.00, 175.74, FALSE)
    ON CONFLICT (card_id, statement_date) DO NOTHING;

END $$;
