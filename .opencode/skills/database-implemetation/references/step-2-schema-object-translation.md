# Step 2 — Schema Object Translation

Translate every structural element from the logical design into T-SQL DDL without weakening or omitting any constraint.

## Tables and columns

For every `Table` block in the DBML (or equivalent logical design notation):

1. **Table name:** Preserve exactly. Do not rename, pluralize, or alter casing.
2. **Columns:** Every column listed must appear in the `CREATE TABLE` statement.
3. **Column order:** Follow the logical design column order unless dependency requires otherwise (e.g., FK columns grouped after their referenced PK columns).

## Identifier escaping (reserved keyword protection)

Before emitting any DDL, cross-reference every table name and column name against the [T-SQL reserved keyword list](https://learn.microsoft.com/en-us/sql/t-sql/language-elements/reserved-keywords-transact-sql). Any identifier matching a reserved keyword must be escaped with square brackets `[ ]` in ALL statements:

- `CREATE TABLE dbo.[USER]` (not `dbo.USER`)
- `REFERENCES dbo.[USER] ([user_id])` in FK constraints
- All future `SELECT`, `INSERT`, `UPDATE`, `DELETE` queries referencing the table

Common T-SQL reserved keywords that frequently collide with domain entity/attribute names: `USER`, `STATUS`, `STATE`, `ORDER`, `GROUP`, `INDEX`, `KEY`, `TABLE`, `VIEW`, `FUNCTION`, `SCHEMA`, `ROLE`, `ROLES`, `LOGIN`, `PASSWORD`, `SESSION`, `SYSTEM`, `ADMIN`.

Column names typically do not need escaping unless they match keywords such as `FROM`, `WHERE`, `SELECT`, `INSERT`, `UPDATE`, `DELETE`, `ORDER`, `BY`, `GROUP`, `HAVING`, `ON`, `OR`, `AND`, `NOT`, `LIKE`, `BETWEEN`, `IN`, `EXISTS`. If in doubt, escape the identifier: `[ ]` wrapping is safe even when not strictly required.

## Data type mapping

| Logical Design Type | T-SQL Type | Notes |
| :--- | :--- | :--- |
| `integer` | `INT` | If auto-increment, add `IDENTITY(1,1)` |
| `varchar(N)` | `VARCHAR(N)` | Keep length exactly as specified |
| `text` | `VARCHAR(MAX)` or `TEXT` | Prefer `VARCHAR(MAX)` for modern T-SQL |
| `datetime` | `DATETIME` or `DATETIME2` | `DATETIME2` preferred for precision |
| `boolean` | `BIT` | Not used in current skill, but map if encountered |

**Do not widen types** (e.g., `varchar(50)` → `varchar(255)`) unless the validated logical design was updated to require it.

## Primary keys

For every PK declaration:

1. **Single-column PK:** `CONSTRAINT pk_<table> PRIMARY KEY (<column>)`
2. **Composite PK:** `CONSTRAINT pk_<table> PRIMARY KEY (<col1>, <col2>)`
3. **Naming convention:** Use `pk_<table_lowercase>` consistently.
4. **Auto-increment surrogate:** Add `IDENTITY(1,1)` on the column definition when the logical design shows `[increment]`.

## Foreign keys

For every `Ref:` declaration in the DBML:

1. **FK column:** Must be present in the child table with the correct data type matching the parent PK type.
2. **FK constraint:** `CONSTRAINT fk_<child>_<role> FOREIGN KEY (<column>) REFERENCES <parent>(<pk_column>)`
3. **Naming convention:** Use `fk_<child>_<role>` — the role should match the FK column's semantic role (e.g., `fk_booking_requester`, not `fk_booking_user_id`).
4. **Delete behaviour:**
   - DBML `[delete: cascade]` → `ON DELETE CASCADE`
   - DBML `[delete: restrict]` or no modifier → `ON DELETE NO ACTION` (T-SQL default)
5. **Update behaviour:** Unless specified, omit `ON UPDATE`. The default `NO ACTION` is sufficient.

## Nullability

For every column:

1. DBML `[not null]` → T-SQL `NOT NULL`
2. No `[not null]` annotation → T-SQL `NULL` (explicit or implicit)

## Default values

For every DBML `[default: '<value>']`:

1. Emit the default as a **column-level constraint** directly on the column definition:
   ```sql
   [<column>] <type> CONSTRAINT df_<table>_<column> DEFAULT '<value>'
   ```
   **Do NOT use `DEFAULT '<value>' FOR [<column>]`** — that syntax is only valid with `ALTER TABLE`, not inside `CREATE TABLE`.
2. The default literal must be a valid value according to the column's domain CHECK constraint.

## Unique constraints

For every DBML `[unique]` annotation or `Indexes { (cols) [unique] }` block:

1. Single-column: `CONSTRAINT uq_<table>_<column> UNIQUE (<column>)`
2. Composite: `CONSTRAINT uq_<table>_<cols> UNIQUE (<col1>, <col2>)`
3. **Naming convention:** `uq_<table>_<purpose>` — match the name from the DBML if provided.

## CHECK constraints

For every documented CHECK constraint in the logical design Section 3:

1. Emit `CONSTRAINT <name> CHECK (<predicate>)` exactly as documented.
2. Preserve the constraint name exactly (e.g., `chk_booking_status_domain`).
3. Do not alter the predicate logic. If the predicate was `CHECK ([status] IN ('a','b','c'))`, do not add or remove values.

## Do-not-weaken rule

Before finishing this step, verify:
- No NOT NULL became NULL.
- No UNIQUE was dropped.
- No CHECK was omitted.
- No FK was weakened (e.g., ON DELETE CASCADE where RESTRICT was specified).
- If any constraint cannot be implemented as-is in T-SQL, document the reason and propose an equivalent alternative before writing DDL.
