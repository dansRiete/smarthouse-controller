### Current Task: Credit Card Spending Database Migration and Flat Report Table

#### Context:
The objective is to consolidate credit card spending data from multiple sources (bank statements in PDF format and CSV exports) into a unified PostgreSQL database schema. Initially, a normalized schema was created in the `finance` schema. Subsequently, a "flat" table was requested to simplify reporting and analysis across all cards.

#### Database Schema:
1. **Normalized Schema (`finance` schema):**
   - `category`: Spending categories (Groceries, Dining Out, etc.).
   - `credit_card`: Metadata for each card (limit, APR, last four digits).
   - `transaction`: Individual charges and payments.
   - `statement`: Monthly statement summaries.

2. **Flat Report Table (`finance.spending_report`):**
   - Located in: `src/dbscript/new/V202602092245_create_flat_spending_table.sql`
   - Purpose: Provides a single, denormalized view of all transactions for easier reporting.
   - Columns: `id`, `card_number`, `card_name`, `transaction_date`, `amount`, `description`, `category`, `subcategory`, `filename`, `original_amount`, `created_at`, `modified_at`.

#### Data Population:
- Transactions are parsed from `/home/alexkzk/Documents/bank-statements-copy/` recursively.
- `card_name` is derived from the folder path.
- `filename` is the name of the source PDF/CSV file.
- `amount` follows the convention: **Negative** for spending, **Positive** for payments/credits.

#### Current Progress:
- [✓] Designed and implemented normalized schema.
- [✓] Populated data for multiple statements (BoA 3401, 9573; Discover 1437; Capital One 8819, 6487, 9957; Amazon 5975).
- [✓] Created spending reports and monthly average queries.
- [✓] Added `created_at` auditing columns to all finance tables.
- [✓] Created and populated the flat `finance.spending_report` table with initial data from identified files.

#### Next Steps:
- Continue parsing remaining or new statements into the flat table as they become available.
- Refine categorization logic based on merchant descriptions.
