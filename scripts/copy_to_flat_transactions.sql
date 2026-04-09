-- Copy spending transactions from the normalized transaction table to the flat table
-- Excludes payments (negative amounts) and joins with credit_card and category tables

INSERT INTO transactions_flat (id, card_name, card_last_four, category_name, subcategory, transaction_date, amount, description, created_at)
SELECT
    t.id,
    cc.name AS card_name,
    cc.last_four AS card_last_four,
    c.name AS category_name,
    t.subcategory,
    t.transaction_date,
    t.amount,
    t.description,
    t.created_at
FROM transaction t
LEFT JOIN credit_card cc ON t.card_id = cc.id
LEFT JOIN category c ON t.category_id = c.id
  AND t.ignore = false  -- Exclude ignored transactions
ORDER BY t.transaction_date, t.id;
