-- Add created_at columns to finance schema tables where missing

-- Add created_at to finance.category
ALTER TABLE finance.category ADD COLUMN IF NOT EXISTS created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

-- Add created_at to finance.statement
ALTER TABLE finance.statement ADD COLUMN IF NOT EXISTS created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

-- Add created_at to finance.transaction
ALTER TABLE finance.transaction ADD COLUMN IF NOT EXISTS created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

-- finance.credit_card already has a created_at column.
