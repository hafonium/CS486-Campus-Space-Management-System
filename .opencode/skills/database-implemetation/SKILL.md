---
name: database-implementation
description: Implement a validated logical database design as executable SQL DDL and related schema objects.
---

# Database Implementation

## Purpose
This skill is a reusable Step 5 implementation framework in a 7-step database-design workflow.

It converts the validated logical database design into executable T-SQL DDL for Microsoft SQL Server.

The agent must implement the current logical database design only after Step 4 validation has been accepted. If Step 4 is not accepted, do not generate the final implementation for release.

The final output should be the implementation script itself, not a long explanation.

## When to use
Use this skill when:
- the user has completed requirements analysis, ERD design, logical design, and validation,
- the user asks to generate Microsoft SQL Server DDL or schema implementation,
- the task is specifically designated as database implementation or Step 5.

Do not use this skill when:
- the user only wants analysis, ERD design, logical design, or validation,
- the user asks for sample data only,
- the user asks for a review rather than implementation.

## Inputs
The agent should expect:
- the logical database design output,
- the validation output or validation findings,
- Microsoft SQL Server as the target DBMS.

## Workflow

### 1. Confirm implementation readiness
- Check whether Step 4 validation has been accepted.
- If Step 4 has not been accepted, stop short of final implementation and report that Step 5 is not ready.
- If Microsoft SQL Server is not the intended target, do not generate this implementation.

Before this step, read `references/step-1-implementation-readiness.md`.

### 2. Translate schema objects
- Implement tables, columns, data types, primary keys, foreign keys, nullability, defaults, unique constraints, and check constraints.
- Preserve the logical design faithfully.
- Do not drop business rules that can be implemented structurally.

Before this step, read `references/step-2-schema-object-translation.md` and `references/sql-syntax-quick-reference.md`.

### 3. Implement database-specific objects
- Convert enums, domains, lookup tables, indexes, and key constraints into the appropriate T-SQL form for Microsoft SQL Server.
- Implement triggers, procedures, or functions only when the design requires procedural enforcement.
- Keep implementation consistent with the validated design and Microsoft SQL Server.

Before this step, read `references/step-3-tsql-specific-objects.md` and `references/sql-query-and-optimization-guidelines.md`.

### 4. Order statements correctly
- Create prerequisite objects before dependent objects.
- Create tables before foreign keys that reference them.
- Create indexes, triggers, and procedural objects after the referenced tables exist.

Before this step, read `references/step-4-script-ordering.md`.

### 5. Check implementation quality
- Verify that every table and relationship from the logical design has been implemented.
- Verify that mandatory constraints were not weakened or omitted.
- Verify that procedural rules are either implemented or clearly marked as deferred when the task scope does not include them.

Before this step, read `references/step-5-implementation-quality-checks.md`.

## Output rules
- Produce T-SQL that can be run in Microsoft SQL Server.
- Keep the script focused on schema implementation.
- Do not add sample data unless the user asks for it.
- Do not add broad design explanations unless they are needed to clarify an implementation choice.
- If Step 4 has unresolved issues, do not produce a final implementation script; report that Step 5 must wait until validation is accepted.

## Deliverable structure
When producing Step 5, write the implementation into the requested output file (or the file named in the task context) using this general structure:

1. Optional header comment with Microsoft SQL Server and any assumptions.
2. Schema object definitions in dependency order.
3. Constraints, indexes, and procedural objects.
4. A short note only if some procedural rules are intentionally deferred.

## Reference Map

### `references/step-1-implementation-readiness.md`
Use this to gate implementation on Step 4 validation acceptance, confirm Microsoft SQL Server as the target DBMS, and lock scope to the validated logical design only.

### `references/step-2-schema-object-translation.md`
Use this to translate every DBML construct — tables, columns, data types, PKs, FKs, nullability, defaults, UNIQUE, and CHECK — into exact T-SQL DDL without weakening any constraint.

### `references/step-3-tsql-specific-objects.md`
Use this to handle T-SQL specifics: IDENTITY for auto-increment, CHECK constraints as enum replacement, trigger/procedure implementation for procedural rules, index creation, and delete-behaviour mapping.

### `references/step-4-script-ordering.md`
Use this to order DDL statements by dependency — parent tables before child tables, FKs after referenced tables exist, indexes and triggers last — with DROP/CREATE patterns for re-runnability.

### `references/step-5-implementation-quality-checks.md`
Use this to audit the generated script against the logical design for completeness, constraint preservation, procedural coverage, T-SQL syntax correctness, and anti-drift before release.

### `references/sql-syntax-quick-reference.md`
Use this as a quick lookup for SQL DDL/DML syntax during implementation: `CREATE TABLE`, constraints (PK/FK/CHECK/DEFAULT/NOT NULL), `ALTER TABLE`, `DROP`, composite keys, self-referencing FKs, circular relationships, data insertion order, T-SQL specifics (IDENTITY, GO, re-runnable patterns, COALESCE, SET NOCOUNT ON), and trigger validation templates.

### `references/sql-query-and-optimization-guidelines.md`
Use this when writing queries inside triggers, stored procedures, or validation logic: clause ordering, operators, date/time functions, join types, grouping/aggregation, set operations, subqueries, CTEs, window functions, COALESCE, and optimization rules (SARGable conditions, EXISTS over IN, UNION ALL, avoid SELECT *, avoid cursors).

---

## Review checklist
Before finishing, verify:
- **Completeness:** All validated tables are fully implemented without placeholders.
- **Structural Integrity:** All validated keys and constraints are physically present.
- **Logical Alignment:** Foreign keys and nullability match the logical design exactly.
- **Global Syntax Audit (T-SQL Pass):** Run a simulated top-to-bottom compilation scan of the entire generated script. Verify that:
  1. Every single code line complies with strict Microsoft SQL Server (T-SQL) DDL syntax.
  2. There are zero trailing commas `,` before closing parentheses `)` in all table blocks.
  3. Every single `;THROW` statement in the entire file uses a clean, single-quoted literal string or a local variable (absolutely ban line-breaking string concatenation via `+` inside arguments).
- **Business Logic Preservation:** No unintended business rules were removed or altered.
