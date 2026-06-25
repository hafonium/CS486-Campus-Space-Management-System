# SQL INSERT Syntax Guide

## Structure and Formatting
- Format inserts clearly, grouping records for the same table together.
- Use explicit column names for all `INSERT` statements. This prevents execution failures if the schema has evolved with new columns.
  ```sql
  -- RECOMMENDED
  INSERT INTO Users (UserId, FirstName, LastName, Email) 
  VALUES (1, 'Alice', 'Smith', 'alice@example.com');
  ```
- Use multi-row `VALUES` clauses where appropriate to keep the script concise.
  ```sql
  INSERT INTO Users (UserId, FirstName, LastName, Email) VALUES 
  (1, 'Alice', 'Smith', 'alice@example.com'),
  (2, 'Bob', 'Jones', 'bob@example.com');
  ```

## Handling Foreign Keys (Insertion Order)
- The execution sequence is critical. 
- You must `INSERT` into independent tables (Lookup tables, primary entities) *before* you `INSERT` into dependent tables (Junction tables, children).
- If `TableB` has a foreign key referencing `TableA`, `TableA` rows must be inserted first.

## Data Type Formatting
- **Strings:** Always use single quotes (`'text'`).
- **Dates:** Use standardized formats like `YYYY-MM-DD` or `YYYY-MM-DD HH:MM:SS` (e.g., `'2024-05-15 14:30:00'`).
- **Booleans/Bits:** Use `1` for true and `0` for false, or literal `TRUE`/`FALSE` if the dialect supports it.
- **Nulls:** Explicitly use the `NULL` keyword (unquoted) for empty values.

## Documenting the SQL
- Precede blocks of inserts with standard SQL comments (`--`) explaining what the block is doing.
- Use comments to label rows that are specifically testing "Exceptional Cases" versus "Normal Operations".

## Handling Triggers during Data Seeding
- When performing bulk data preparation and using `SET IDENTITY_INSERT ON`, active triggers (specifically `INSTEAD OF INSERT` triggers) will often conflict with explicit ID assignments and crash the batch.
- **Rule:** If the DDL indicates a table has an `INSTEAD OF INSERT` trigger, you MUST wrap that table's insert block with commands to temporarily disable and re-enable the trigger.
- **Syntax Pattern:**
  ```sql
  DISABLE TRIGGER [schema].[trigger_name] ON [schema].[TableName];
  GO
  SET IDENTITY_INSERT [schema].[TableName] ON;
  GO
  
  -- Insert statements here
  
  SET IDENTITY_INSERT [schema].[TableName] OFF;
  GO
  ENABLE TRIGGER [schema].[trigger_name] ON [schema].[TableName];
  GO