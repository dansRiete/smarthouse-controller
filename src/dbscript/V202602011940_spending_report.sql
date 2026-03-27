-- SQL Query to generate a report of spending grouped by month and category
-- Only considers spending (negative amounts) and returns absolute values for readability

SELECT
    TO_CHAR(t.transaction_date, 'YYYY-MM') AS month,
    SUM(CASE WHEN c.name = 'Groceries' THEN ABS(t.amount) ELSE 0 END) AS Groceries,
    SUM(CASE WHEN c.name = 'Dining Out' THEN ABS(t.amount) ELSE 0 END) AS Dining_Out,
    SUM(CASE WHEN c.name = 'Transportation' THEN ABS(t.amount) ELSE 0 END) AS Transportation,
    SUM(CASE WHEN c.name = 'Travel' THEN ABS(t.amount) ELSE 0 END) AS Travel,
    SUM(CASE WHEN c.name = 'Shopping' THEN ABS(t.amount) ELSE 0 END) AS Shopping,
    SUM(CASE WHEN c.name = 'Utilities' THEN ABS(t.amount) ELSE 0 END) AS Utilities,
    SUM(CASE WHEN c.name = 'Subscription' THEN ABS(t.amount) ELSE 0 END) AS Subscriptions,
    SUM(CASE WHEN c.name = 'Health' THEN ABS(t.amount) ELSE 0 END) AS Health,
    SUM(CASE WHEN c.name = 'Entertainment' THEN ABS(t.amount) ELSE 0 END) AS Entertainment,
    SUM(ABS(t.amount)) AS total_monthly_spending
FROM
    finance.transaction t
JOIN
    finance.category c ON t.category_id = c.id
WHERE
    t.amount < 0 AND t.card_id = 1
GROUP BY
    TO_CHAR(t.transaction_date, 'YYYY-MM')
ORDER BY
    month DESC;

-- Optional: Vertical report style
-- This provides a list of spending per category per month for Card ID 1

SELECT
    TO_CHAR(t.transaction_date, 'YYYY-MM') AS month,
    c.name AS category,
    SUM(ABS(t.amount)) AS total_spent
FROM
    finance.transaction t
        JOIN
    finance.category c ON t.category_id = c.id
WHERE
    t.amount < 0
GROUP BY
    TO_CHAR(t.transaction_date, 'YYYY-MM')
         , c.name
ORDER BY
    category,
    month DESC;
