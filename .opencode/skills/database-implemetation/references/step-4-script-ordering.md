# Step 4 — Script Ordering

Order all DDL statements so the script can be executed from top to bottom without dependency errors.

## Dependency tree

Build the dependency order by following these rules:

### 1. Parent tables before child tables

Tables that are referenced by foreign keys must be created before the tables that reference them.

```
USER                     ← created first (referenced by BOOKING, MAINTENANCE_RECORD)
SPACE                    ← created first (referenced by BOOKING, MAINTENANCE_RECORD, SPACE_FACILITY)
FACILITY                 ← created first (referenced by SPACE_FACILITY)
BOOKING                  ← created after USER and SPACE
MAINTENANCE_RECORD       ← created after USER and SPACE
SPACE_FACILITY           ← created after SPACE and FACILITY
```

### 2. Constraints after tables

All `ALTER TABLE ... ADD CONSTRAINT` statements for FKs, CHECKs, and UNIQUEs must appear after the base `CREATE TABLE` statements.

**Recommended approach:** Define all inline constraints (PRIMARY KEY, UNIQUE, CHECK, DEFAULT) within the `CREATE TABLE` statement. Use `ALTER TABLE` only for FOREIGN KEY constraints to keep the script modular and avoid forward-reference errors.

### 3. Indexes after tables

`CREATE INDEX` and `CREATE UNIQUE INDEX` statements appear after the target table exists.

### 4. Triggers after referenced tables

`CREATE TRIGGER` statements must appear after all tables referenced inside the trigger body exist.

## Recommended script structure

```
-- 1. Independent parent tables (no FKs to other tables)
CREATE TABLE USER (...);
CREATE TABLE SPACE (...);
CREATE TABLE FACILITY (...);

-- 2. Dependent child tables
CREATE TABLE BOOKING (...);
CREATE TABLE MAINTENANCE_RECORD (...);

-- 3. Junction tables (pure associative)
CREATE TABLE SPACE_FACILITY (...);

-- 4. Foreign key constraints (ALTER TABLE)
ALTER TABLE BOOKING ADD CONSTRAINT fk_booking_requester ...;
ALTER TABLE BOOKING ADD CONSTRAINT fk_booking_space ...;
-- ... etc.

-- 5. Indexes (if any beyond PK/UNIQUE inline)
-- CREATE INDEX idx_... ON ...;

-- 6. Triggers and procedural objects (if in scope)
-- CREATE TRIGGER trg_... ON ...;
```

## DROP/CREATE pattern

If the script must be re-runnable:

1. Precede each `CREATE TABLE` with `IF OBJECT_ID('dbo.<table>', 'U') IS NOT NULL DROP TABLE dbo.<table>;`
2. Drop order: child tables first, then parent tables (reverse of create order).
3. For triggers: `IF OBJECT_ID('dbo.<trigger>', 'TR') IS NOT NULL DROP TRIGGER dbo.<trigger>;`
4. If the task does not require re-runnability, omit DROP statements and produce a clean creation script.

## Batch separation

- Use `GO` statements between logical blocks (after each table create, after each group of ALTER TABLE statements).
- `GO` is a batch separator in SQL Server Management Studio and `sqlcmd`. It is not a T-SQL keyword.
- Do not place `GO` inside `CREATE TABLE`, `CREATE TRIGGER`, or `ALTER TABLE` statements.

## Verification checklist

Before declaring the ordering complete:
- [ ] Can the script run top-to-bottom without errors on a fresh database?
- [ ] Does every FK reference a table that appears earlier in the script?
- [ ] Do all triggers reference tables that exist?
- [ ] Are DROP statements in reverse-dependency order (if included)?
