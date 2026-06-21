# Step 2 — Keys and Relationships

## Primary key verification

For every table in the schema:
1. Confirm exactly one PK is declared. (In DBML, look for `[pk]` annotation; in SQL DDL, look for `PRIMARY KEY` constraint; in other formats, look for the equivalent declaration.)
2. Cross-check: the PK documented in the logical design's "Primary Keys & Candidate Keys" summary table must match the schema declaration. If they disagree, record a finding against the schema (the summary table documents intent; the schema is what gets implemented).

## FK placement verification

For every 1:N relationship in the ERD:
1. Identify the parent (1-side) and child (N-side).
2. Confirm the FK constraint exists in the child table and references the parent table's PK.
3. If an FK is found on the parent side instead of the child side, record a finding.

## FK nullability verification

For each FK column, its nullability must match the logical design's documented constraints. The documented nullability should align with the ERD relationship cardinality:

| ERD left-of-arrow symbol (from child's perspective) | Meaning | FK should be |
| :--- | :--- | :--- |
| `\|\|` (exactly one, mandatory) | Child must belong to parent | **NOT NULL** |
| `\|o` (zero or one, optional) | Child may or may not belong to parent | **nullable** |
| `}o` (zero or more, optional) | Child may or may not belong to parent | **nullable** |
| `}\|` (one or more, mandatory) | Child must belong to parent | **NOT NULL** |

**How to read:** In `DEPARTMENT ||--o{ EMPLOYEE`, the child is EMPLOYEE (right side). The symbol closest to EMPLOYEE is `o{`, which means zero or more. Reading the left symbol from EMPLOYEE's perspective: `||` means exactly one DEPARTMENT per EMPLOYEE. Therefore `department_id` must be NOT NULL.

Compare the documented nullability in the logical design's FK summary table against the schema constraint. If they disagree, record a finding.

## Candidate key verification

For every candidate key listed in the logical design's "Primary Keys & Candidate Keys" summary:
1. Confirm a unique constraint is declared in the schema for the same column(s). (In DBML, look for `[unique]` annotation or `UNIQUE` index; in SQL DDL, look for `UNIQUE` constraint; in other formats, look for the equivalent declaration.)
2. If a CK is documented but has no schema unique constraint, record a finding.

## Multi-role FK count verification

When the ERD shows one parent entity connected to the same child entity through N relationship lines (N > 1):
1. Count the relationship lines in the ERD (e.g., Employee→Task appears 3 times: creates, reviews, approves).
2. Confirm the child table has exactly N FK columns referencing that parent.
3. Confirm each FK has a distinct, role-specific column name.
4. Confirm each FK's nullability independently matches its own ERD relationship cardinality (they may differ — one may be mandatory, another optional).
