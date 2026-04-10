-- Create a flat table for spending reports
CREATE SCHEMA IF NOT EXISTS finance;

CREATE TABLE IF NOT EXISTS finance.spending_report (
    id SERIAL PRIMARY KEY,
    card_number VARCHAR(4),
    card_name TEXT,
    transaction_date DATE NOT NULL,
    amount DECIMAL(15, 2) NOT NULL,
    description TEXT,
    category TEXT,
    subcategory TEXT,
    filename TEXT,
    original_amount DECIMAL(15, 2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    modified_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Trigger to update modified_at
CREATE OR REPLACE FUNCTION update_modified_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.modified_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_spending_report_modtime
    BEFORE UPDATE ON finance.spending_report
    FOR EACH ROW
    EXECUTE PROCEDURE update_modified_at_column();
