# SQL Query & Optimization Guidelines (T-SQL)

Reference for writing correct, performant T-SQL queries inside triggers, stored procedures, and validation logic during Step 5 implementation.

---

## 1. Core Query Structure & Operators

### Clause Order

Queries follow this strict clause ordering: `SELECT` → `FROM` → `WHERE` → `GROUP BY` → `HAVING` → `ORDER BY`.

### Operators

| Category | Operators / Keywords |
| :--- | :--- |
| Logical | `AND`, `OR`, `NOT` |
| Comparison | `=`, `<>`, `>`, `<`, `>=`, `<=` |
| Null | `IS NULL`, `IS NOT NULL` |
| Set membership | `IN`, `NOT IN` |
| Existence | `EXISTS`, `NOT EXISTS` |
| Pattern matching | `LIKE` (wildcard: `%` = zero or more characters) |

**Note:** Use `=` instead of `==` and `<>` instead of `!=` for portable T-SQL.

---

## 2. Date & Time Functions

Relevant for booking overlap detection, maintenance timelines, and audit timestamps in triggers:

| Function | Description |
| :--- | :--- |
| `YEAR(date)` | Extracts year from a datetime value |
| `MONTH(date)` | Extracts month from a datetime value |
| `DAY(date)` | Extracts day from a datetime value |
| `DATEPART(part, date)` | Extracts any date part (year, month, day, hour, etc.) |
| `DATEDIFF(part, start, end)` | Difference between two datetimes (day, month, year, hour, minute) |
| `GETDATE()` | Returns current server datetime |

### Example: Overlap Detection

```sql
-- Check if two time ranges overlap:
-- Range A (start_a, end_a) overlaps Range B (start_b, end_b) when:
-- start_a < end_b AND end_a > start_b
WHERE @start_a < end_b AND @end_a > start_b
```

**SARGable pattern:** Avoid wrapping date columns in functions. Write:
```sql
-- BAD:  WHERE YEAR(booking_date) = 2026
-- GOOD: WHERE booking_date >= '2026-01-01' AND booking_date < '2027-01-01'
```

---

## 3. Joins

### Explicit Join Types

| Join Type | Behaviour |
| :--- | :--- |
| `INNER JOIN` | Returns rows where the join condition matches in both tables |
| `LEFT JOIN` | Returns all rows from the left table, plus matched rows from the right (NULLs where no match) |
| `RIGHT JOIN` | Returns all rows from the right table, plus matched rows from the left (NULLs where no match) |

### Cartesian Product Warning

Omitting the join condition produces a Cartesian product: every row from the left table paired with every row from the right table. **Always specify an `ON` clause for every `JOIN` in triggers and procedures.**

---

## 4. Grouping & Aggregation

### Aggregate Functions

`MIN`, `MAX`, `SUM`, `COUNT`, `AVG`

### Counting Variants

| Expression | Behaviour |
| :--- | :--- |
| `COUNT(column)` | Counts non-null values in the column |
| `COUNT(*)` | Counts all rows |
| `COUNT(DISTINCT column)` | Counts distinct non-null values |

### GROUP BY Strict Rule

Any column in the `SELECT` or `HAVING` clause that is not inside an aggregate function **must** appear in the `GROUP BY` clause.

### Handling Nulls in Aggregation

Use `ISNULL(count(...), 0)` to replace null aggregation results with zero.

---

## 5. Set Operations

| Operation | Behaviour |
| :--- | :--- |
| `UNION` | Combines two result sets, removes duplicates |
| `UNION ALL` | Combines two result sets, keeps duplicates (faster) |
| `EXCEPT` | Returns rows from set 1 not present in set 2, removes duplicates |
| `INTERSECT` | Returns rows present in both sets, removes duplicates |

**Optimization rule:** Use `UNION ALL` by default unless duplicate removal is explicitly required. `UNION` performs a costly hidden sort and deduplication.

---

## 6. Subqueries

- **Placement:** Subqueries can appear in `SELECT`, `FROM`, or `WHERE` clauses.
- **Correlated subquery:** A subquery referencing at least one column from the outer query. Use with care — it executes once per outer row.
- **Prefer `EXISTS` over `IN`:** When checking for existence of records, `EXISTS` short-circuits on first match. `IN` evaluates the entire subquery first.

```sql
-- Prefer:
IF EXISTS (SELECT 1 FROM BOOKING WHERE space_code = @code AND booking_status = 'approved')
  THROW 50000, 'Space already booked', 1;

-- Over:
IF @code IN (SELECT space_code FROM BOOKING WHERE booking_status = 'approved')
  THROW 50000, 'Space already booked', 1;
```

---

## 7. Advanced Query Structures

### Common Table Expressions (CTEs)

Use CTEs to simplify nested subqueries and improve readability:

```sql
WITH ApprovedBookings AS (
    SELECT space_code, requested_start_time, requested_end_time
    FROM BOOKING
    WHERE booking_status = 'approved'
)
SELECT * FROM ApprovedBookings
WHERE requested_start_time >= @today;
```

### Window Functions

Solve "Top N per Group" problems without complex correlated subqueries:

```sql
SELECT * FROM (
    SELECT *, ROW_NUMBER() OVER(PARTITION BY space_code ORDER BY requested_start_time DESC) AS rn
    FROM BOOKING
) ranked
WHERE rn <= 3;
```

### COALESCE for Multiple Fallbacks

Use `COALESCE` when checking multiple columns in order until a non-null value is found:

```sql
-- Returns the first non-null value among col1, col2, 'default'
SELECT COALESCE(col1, col2, 'default') AS resolved_value FROM TABLE;
```

---

## 8. Query Optimization Rules (Anti-Slowdown)

### Avoid `SELECT *` in Production

Always list columns explicitly. `SELECT *` reads unnecessary data, breaks covering indexes, and silently breaks when columns are added/dropped.

### Write SARGable WHERE Clauses

Do not wrap columns in functions inside `WHERE` — it prevents index usage:

```sql
-- BAD:  WHERE YEAR(birthdate) = 2000
-- GOOD: WHERE birthdate >= '2000-01-01' AND birthdate < '2001-01-01'
-- BAD:  WHERE UPPER(name) = 'SMITH'
-- GOOD: WHERE name = 'SMITH'
```

### Avoid Leading Wildcards in LIKE

```sql
-- BAD:  WHERE name LIKE '%Smith'  -- full table scan
-- GOOD: WHERE name LIKE 'Smith%'  -- uses index
```

### Prefer EXISTS over IN

`EXISTS` short-circuits on first match; `IN` evaluates the entire subquery first. Always default to `EXISTS` for existence checks in triggers and validation logic.

### Use UNION ALL by Default

`UNION` sorts and deduplicates. `UNION ALL` does not. Use `UNION ALL` unless you explicitly need deduplication.

### Avoid Cursors and WHILE Loops

SQL is optimized for set-based operations. Do not use `CURSOR` or `WHILE` loops to process rows one-by-one. Rewrite as a set-based `INSERT`, `UPDATE`, or `MERGE` statement.
