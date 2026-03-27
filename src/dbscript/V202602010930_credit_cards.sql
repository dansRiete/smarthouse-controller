-- Schema for Credit Card Spending and Management

CREATE SCHEMA IF NOT EXISTS finance;

-- Categories for spending analysis
CREATE TABLE finance.category (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT
);

-- Credit Card definitions
CREATE TABLE finance.credit_card (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    bank_name VARCHAR(100),
    last_four VARCHAR(4) UNIQUE,
    credit_limit DECIMAL(15, 2),
    interest_rate_apr DECIMAL(5, 2), -- Annual Percentage Rate
    statement_day_of_month INTEGER CHECK (statement_day_of_month BETWEEN 1 AND 31),
    grace_period_days INTEGER, -- Days between statement date and due date
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Individual Transactions (Spending and Payments)
CREATE TABLE finance.transaction (
    id SERIAL PRIMARY KEY,
    card_id INTEGER REFERENCES finance.credit_card(id),
    category_id INTEGER REFERENCES finance.category(id),
    transaction_date DATE NOT NULL,
    post_date DATE,
    amount DECIMAL(15, 2) NOT NULL, -- Negative for spending, positive for payments/refunds
    description TEXT,
    is_pending BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Monthly Statements
-- This table helps track statement balances and due dates to calculate interest if not paid
CREATE TABLE finance.statement (
    id SERIAL PRIMARY KEY,
    card_id INTEGER REFERENCES finance.credit_card(id),
    statement_date DATE NOT NULL,
    due_date DATE NOT NULL,
    statement_balance DECIMAL(15, 2) NOT NULL,
    minimum_payment DECIMAL(15, 2),
    paid_amount DECIMAL(15, 2) DEFAULT 0,
    is_fully_paid BOOLEAN DEFAULT FALSE,
    interest_charged DECIMAL(15, 2) DEFAULT 0,
    UNIQUE(card_id, statement_date)
);

-- Initial Data for Categories
INSERT INTO finance.category (name) VALUES 
('Groceries'), ('Dining Out'), ('Utilities'), ('Transportation'), 
('Entertainment'), ('Shopping'), ('Health'), ('Travel'), ('Subscription'), ('Payment');

-- Example Query for Spending Analysis by Category
-- SELECT c.name, SUM(ABS(t.amount)) 
-- FROM finance.transaction t 
-- JOIN finance.category c ON t.category_id = c.id 
-- WHERE t.amount < 0 AND t.transaction_date BETWEEN '2026-01-01' AND '2026-01-31'
-- GROUP BY c.name;
