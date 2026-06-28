# SQL Syntax Quick Reference (Microsoft SQL Server / T-SQL)

Concise reference for database, table, constraint, and DML operations. Use during Step 5 implementation to verify correct syntax and dependency ordering.

---

## 1. Core Syntax: Database Operations

- **Create Database**: `CREATE DATABASE [database name];`
- **Remove Database**: `DROP DATABASE [database name];`
- **Select Database**: `USE [database name];`
- **Case Sensitivity**: SQL keywords are case-insensitive (`CREATE DATABASE` equals `create database`).

---

## 2. Core Syntax: Table Operations & Constraints

### Table Creation

```sql
CREATE TABLE [table name]
(
    [attribute 1] [data type 1] [constraint 1]...,
    [attribute 2] [data type 2] [constraint 1]...,
    PRIMARY KEY ([list of attributes]),
    UNIQUE ([list of attributes]),
    FOREIGN KEY ([list of attributes]) REFERENCES [other table] ([list of attributes in primary key])
);
```

### Constraint Syntax Shortcuts

PK, UNIQUE, and FK constraints can be defined directly next to the column when they involve only that single column:

```sql
column_name INT PRIMARY KEY,
column_name INT UNIQUE,
column_name INT REFERENCES other_table(pk_column)
```

### Constraint Rules

- **PRIMARY KEY (PK):** A table should have exactly one PK (single-column or composite). PK columns are implicitly `NOT NULL` and values cannot be duplicated.
- **NOT NULL:** Forces a column to reject null values. All columns are nullable by default.
- **CHECK:** Ensures inserted values meet a condition or set of conditions (e.g., `CHECK (gender IN ('F', 'M', 'O'))`).
- **DEFAULT:** Provides a fallback value when a new record has no value specified for that column.
- **FOREIGN KEY (FK):**
  - Must reference the primary key of another table.
  - Must have the exact same number of columns, data types, and column order as the referenced primary key.
  - Inserted values must be `NULL` or match an existing value in the referenced table.

### Modifying and Dropping Tables

- **Add column:** `ALTER TABLE [table-name] ADD [attribute-name] [data type] [constraint]...`
- **Drop column:** `ALTER TABLE [table-name] DROP COLUMN [attribute]`
- **Add constraint:** `ALTER TABLE [table-name] ADD CONSTRAINT ...`
- **Drop constraint:** `ALTER TABLE [table-name] DROP CONSTRAINT ...`
- **Drop table:** `DROP TABLE [table name];`

**Critical note:** You cannot drop a table that is referenced by a foreign key from another table. Drop the referencing constraint or table first.

---

## 3. Handling Complex Relationships

### Composite Primary Keys

- A PK composed of two or more columns that together uniquely identify a row.
- **Referencing a composite PK:** The FK must include all columns in the exact same order with matching data types.
- Example: junction/fact table FK must be composite when referencing a composite PK.

### Self-Referencing Tables

- A column in a table can reference the PK of the *same* table (e.g., `Employee` table with `ManagerID` referencing `EmpID`).

### Circular Relationships (Table A references B, Table B references A)

- **Creation order:**
  1. Create table A without its FK constraint.
  2. Create table B with its FK constraint referencing table A.
  3. Use `ALTER TABLE` to add the FK constraint to table A.
- **Data insertion order:**
  1. Insert into table A with `NULL` for its FK.
  2. Insert all data into table B.
  3. `UPDATE` table A's FK column with the correct references.

---

## 4. Data Manipulation (DML) Execution Rules

### Syntax

- **INSERT:** `INSERT INTO [table name] (column1, ...) VALUES (value1, ...);`
- **UPDATE:** `UPDATE [table_name] SET [column1] = [value1] WHERE [condition];`
- **DELETE:** `DELETE FROM [table name] WHERE [conditions];`

### Critical Data Insertion Order

1. **Standard Foreign Keys:** Insert into the referenced (parent) table first — the FK requires those values to exist.
2. **Self-Referencing Tables:** Insert the record with a `NULL` value for the FK column first, then `UPDATE` to set the correct reference.
3. **Circular Relationships:**
   - Insert into table A with `NULL` for its FK.
   - Insert all data into table B.
   - `UPDATE` table A's FK column with the correct references.

---

## 5. T-SQL Specifics (Microsoft SQL Server)

- **Auto-increment:** Use `IDENTITY(1,1)` on `INT` columns. Replaces MySQL `AUTO_INCREMENT`.
- **No ENUM type:** Use `VARCHAR` with `CHECK (... IN (...))` constraints instead.
- **Batch separator:** Use `GO` between independent statement blocks (SSMS convention, not a T-SQL keyword).
- **Re-runnable scripts:** Use `IF OBJECT_ID('dbo.<name>', 'U') IS NOT NULL DROP TABLE dbo.<name>;` before `CREATE TABLE`.
- **Delete behaviour:** `ON DELETE CASCADE`, `ON DELETE SET NULL`, `ON DELETE SET DEFAULT`, or omit for `NO ACTION`.
- **Schema prefix:** Use `dbo.` consistently for all object names where applicable.
- **Reserved keyword escaping:** Wrap identifiers that match T-SQL reserved keywords in square brackets `[ ]` (e.g., `dbo.[USER]`, `[STATUS]`). Apply in `CREATE TABLE`, `REFERENCES`, and all DML statements. Always use `[ ]` for the `USER` table name.
- **Constraint naming:** Use consistent prefixes: `pk_` (primary key), `fk_` (foreign key), `uq_` (unique), `chk_` (check), `df_` (default).
- **Null handling:** Use `ISNULL(expr, replacement)` for single-column fallback; use `COALESCE(col1, col2, 'default')` when checking multiple columns in order until a non-null value is found.
- **Trigger/procedure body:** Always include `SET NOCOUNT ON;` at the top of trigger and stored procedure bodies. For validation failures, use `;THROW 50000, 'message', 1;` with leading semicolon (SQL Server 2012+). Do not use `RAISERROR` — it lacks the automatic batch-termination behaviour of `THROW` and is harder to use correctly inside `BEGIN...END` blocks.
- **THROW semicolon rule:** The statement immediately before `THROW` must be terminated with a semicolon. Inside `BEGIN...END` blocks, write `;THROW` (leading semicolon) to avoid the parser misinterpreting `BEGIN` as `BEGIN DIALOG CONVERSATION` (Service Broker). Example: `BEGIN ;THROW 50000, 'msg', 1; END`
- **Comparison operators:** Use `=` (not `==`) and `<>` (not `!=`) for portable T-SQL. This applies equally to CHECK predicates and trigger conditions.

## 6. DML Validation & Error Handling Patterns

### Trigger Validation Template

```sql
CREATE TRIGGER trg_<table>_<purpose>
ON <table>
INSTEAD OF INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1 FROM inserted
        WHERE <validation_condition>
    )
    BEGIN
        ;THROW 50000, '<error message>', 1;
    END;

    -- Forward valid operations
    -- INSERT: INSERT INTO <table> SELECT * FROM inserted;
    -- UPDATE: UPDATE t SET ... FROM <table> t INNER JOIN inserted i ON t.pk = i.pk;
END;
```

### Data Insertion Order (Full Reference)

1. **Standard Foreign Keys:** Insert into parent table first, then child table.
2. **Self-Referencing Tables:** Insert row with `NULL` FK first, then `UPDATE` FK to the correct value once the referenced row exists.
3. **Circular Relationships:** Insert into table A with `NULL` FK → insert into table B → `UPDATE` table A FK with correct value.
4. **Junction Tables:** Insert parent rows first (both sides), then insert junction rows last.
