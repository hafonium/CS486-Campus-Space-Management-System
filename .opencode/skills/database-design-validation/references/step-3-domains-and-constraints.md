# Step 3 — Domains and Constraints

## Enum/Domain value verification

For every enumerated domain or set of allowed values in the schema:
1. List every value in the schema's definition. (In DBML, look in `Enum` blocks; in SQL DDL, look in `CHECK` constraints or `DOMAIN` definitions; in ER diagrams, look in the data dictionary.)
2. Find the corresponding value list in the BR (Section 5 candidate attributes) or ERD data dictionary.
3. Compare value-by-value, character-by-character. Underscores, casing, spelling — everything must match exactly.
4. If a schema value does not appear in the BR/ERD source, record a finding.
5. If a BR/ERD value is missing from the schema, record a finding.

Additionally, check the logical design's own prose for references to enum values (e.g., Section 4 Procedural Enforcement may reference a value like `disabled`). If the prose references a value by name and the schema uses a different name, that is an internal inconsistency.

## Data type verification

Confirm each schema column type is a valid refinement of the ERD attribute type. (See the Data Type Equivalence table in SKILL.md for valid refinements.) Only flag when the schema uses a fundamentally different domain (e.g., ERD `int` mapped to schema `varchar`, or ERD `datetime` mapped to schema `integer`).

## Default value verification

For every schema column with a default value declaration:
1. Confirm the default value matches the business process's initial lifecycle state as defined in the requirements (e.g., a status column might default to `'active'` for a new account, `'pending'` for a new request, or `'draft'` for an unsubmitted record).
2. Confirm the default literal is a valid value according to the column's domain constraint.
3. If a default is documented in the logical design prose but missing from the schema, record a finding.

## NOT NULL cross-check

For every schema column:
1. Check the logical design's NOT NULL constraints summary table.
2. The table and the schema constraint must agree: if the table says NOT NULL, the column must have a NOT NULL constraint. If the table does not mention a column, the column must not be NOT NULL.
3. If they disagree, record a finding against the schema (the summary table documents intent; the schema is what executes).

Additionally, verify that NOT NULL settings match the business requirements:
- Every PK column: implicitly NOT NULL (no annotation needed in most schema formats for PKs).
- FK columns where ERD cardinality is mandatory on the child side: NOT NULL.
- Business-critical data columns (name, email, time fields): NOT NULL.

## CHECK constraint verification

For every business integrity CHECK documented in the logical design:
1. Determine whether it is expressible as a single-column constraint or if it requires multi-column/conditional logic.
2. If it is a single-column CHECK: confirm a corresponding constraint exists in the schema.
3. If it is a multi-column or conditional CHECK: confirm it is clearly documented in the logical design's prose with the exact predicate (that will be implemented as a CHECK constraint, trigger, or application logic).
4. If a documented CHECK has no representation in the schema (or in the Procedural Enforcement section for complex checks), record a finding.
