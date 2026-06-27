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

## Dynamic Identity Handling (No Hardcoded IDs)
- Never use `SET IDENTITY_INSERT ON` or attempt to force explicit IDs into auto-incrementing columns. This bypasses realistic testing and breaks `INSTEAD OF` triggers.
- **Rule:** When inserting data that has dependent child records, declare T-SQL variables at the top of your batch. After inserting the parent record, capture its generated ID using `SCOPE_IDENTITY()` and pass that variable to the child inserts.
- **Syntax Pattern:**
  ```sql
  DECLARE @AssignedUserId INT;
  DECLARE @TargetSpaceCode VARCHAR(50) = 'AUD-101';

  -- 1. Insert Parent
  INSERT INTO [schema].[USER] (full_name, email, role) 
  VALUES ('Jane Doe', 'jane@test.com', 'student');
  
  -- 2. Capture Auto-Generated ID
  SET @AssignedUserId = SCOPE_IDENTITY();
  
  -- 3. Insert Child using the captured ID
  INSERT INTO [schema].[BOOKING] (requester_id, space_code, status) 
  VALUES (@AssignedUserId, @TargetSpaceCode, 'pending');