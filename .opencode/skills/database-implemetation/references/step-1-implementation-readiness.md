# Step 1 — Implementation Readiness

**Gate rule:** Do not produce a final DDL script until Step 4 validation has been accepted.

## Preconditions

Before writing any T-SQL:

1. Locate the Step 4 validation output (normally `outputs/04-design-validation*.md` or equivalent).
2. Read the validation status: `VALIDATION PASSED` or `VALIDATION FAILED`.
3. **If VALIDATION FAILED:** Stop here. Report to the user that Step 5 is not ready and list the unresolved findings. Do not proceed to schema translation.
4. **If VALIDATION PASSED:** Proceed to Step 2.

## Target DBMS verification

5. Confirm the target DBMS is **Microsoft SQL Server (T-SQL)**.
6. If the target is PostgreSQL, MySQL, Oracle, or any other dialect, do not generate a T-SQL script. Ask the user to confirm the target or provide the correct dialect.
7. If no target is specified, assume Microsoft SQL Server as the default (matching the logical design's T-SQL compliance notes).

## Scope confirmation

8. Read the validated logical design output to confirm which objects are in scope:
   - Tables with their columns, types, and constraints
   - Foreign keys with delete behaviour
   - CHECK constraints (domain, boundary, conditional)
   - UNIQUE constraints / candidate keys
   - Procedural enforcement objects (triggers, procedures) — check whether these are in scope for this task
9. **Sample data:** Do not generate sample data (`INSERT` statements) unless the user explicitly requests it.

## Business rule coverage requirements

10. Read the **Business Requirements Analysis output** (normally `outputs/01-business-req-analysis*.md`) Section 8 "Business rules" to cross-reference every business rule against implementation coverage:
    - List every BR by its BR number (BR 1, BR 2, …).
    - **Database-Enforceable** rules must be addressed by the generated script — either as a structural constraint (CHECK, FK, UNIQUE, NOT NULL), a procedural object (trigger, procedure), or a documented deferral with enforcement strategy.
    - **Application-Layer** rules (authentication, authorization, UI validation, workflow logic) are out of scope for the database script. Do not generate triggers or procedures for them — document them as deferred in a comment block.
    - The agent should produce a `-- Business Rule Coverage` comment at the end of the script mapping each BR number to its enforcement method (Structural / Procedural / Deferred).
11. **If a Database-Enforceable BR has no structural constraint and no procedural enforcement:** The logical design may be incomplete. Flag it before generating DDL.

## Anti-drift rule

12. Use **only** the validated logical design as the source of truth for structural implementation (tables, columns, types, keys, CHECKs, FKs). For business rule coverage and procedural enforcement, cross-reference the BR analysis to ensure no database-enforceable rule is missed. Do not pull structure from the ERD, memory, or prior conversation. If the logical design is inconsistent internally (which should have been caught in Step 4), flag it before generating any DDL.
