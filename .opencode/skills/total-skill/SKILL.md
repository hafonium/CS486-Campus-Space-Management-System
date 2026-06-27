---
name: total-skill
description: Orchestrate the full 7-step database design and implementation pipeline for the Campus Space Management System. Produces all deliverables in order: BR analysis, ERD, logical design, validation, DDL definition, sample data, and query design.
---

# Total Skill — Campus Space Management System Pipeline

## Purpose
This skill drives the end-to-end 7-step database project workflow. It chains the existing skills in strict order, ensuring each step's output feeds correctly into the next, and writes deliverables to the `results/` directory using the `-G09` suffix convention.

## When to use
Use this skill when:
- the user wants the full pipeline from requirements analysis through query design.
- the user wants to regenerate or audit all 7 deliverables.
- the task spans multiple steps of the database design lifecycle.

Do not use this skill when:
- the user only needs one specific step (use the individual skill instead).

## Inputs
- Project case description / business requirements brief.
- Assignment instructions (e.g., naming convention `-G09`, output directory).
- Confirmation of Microsoft SQL Server (T-SQL) as the target DBMS.

## Workflow — Exact 7-Step Pipeline

### Step 1: Business Requirement Analysis
**Skill:** `business-req-analysis`
**Output file:** `results/01-business-req-analysis-G09.md`

- Load the `business-req-analysis` skill.
- Read the project case description provided by the user.
- Produce Sections 1–9 (Business purpose, System scope, Actors, Candidate entities, Candidate attributes, Relationships, Cardinalities, Business rules, Assumptions).
- Write the output to `results/01-business-req-analysis-G09.md`.
- **Gate:** Before proceeding, confirm Step 1 output exists and is non-empty. If missing, stop and report.
- **Critical Thinking:** Are the entities truly distinct from attributes? Could any candidate entity be merged or split? Do the business rules cover every constraint implied by the case description?

### Step 2: Conceptual ERD Design
**Skill:** `erd-design`
**Output file:** `results/02-erd-design-G09.md`

- Load the `erd-design` skill.
- Read the Step 1 output (`results/01-business-req-analysis-G09.md`) as input.
- Produce Mermaid `erDiagram` block, Conceptual Data Dictionary, and Design Notes.
- Remove all Foreign Keys from entity attribute lists (conceptual purity).
- Preserve all M:N relationships without resolution.
- Write the output to `results/02-erd-design-G09.md`.
- **Gate:** Confirm Step 2 output exists before proceeding.
- **Critical Thinking:** Does every relationship in the ERD match the cardinality described in Step 1? Are any M:N relationships actually 1:N in disguise? Are the verb phrases precise enough to distinguish multi-role relationships?

### Step 3: Logical Database Design
**Skill:** `logical-design`
**Output file:** `results/03-logical-design-G09.md`

- Load the `logical-design` skill.
- Read Step 1 (`01-*.md`) and Step 2 (`02-*.md`) outputs as inputs.
- Produce DBML relational schema, Constraints & Keys Summary, Domain CHECKs, Architectural Assumptions, and Design Notes.
- Resolve M:N relationships into junction tables (e.g., `SPACE_FACILITY`).
- Apply multi-role FK naming disambiguation.
- Mount AST-bijective `note:` pointers for every Section 3 constraint.
- Write the output to `results/03-logical-design-G09.md`.
- **Gate:** Confirm Step 3 output exists before proceeding.
- **Critical Thinking:** Are all candidate keys correctly identified (not just PKs)? Do the CHECK constraints cover every domain enumerated in Step 1? Could any constraint be weakened by future data without the schema catching it? Is the multi-role FK naming unambiguous when reading a query?

### Step 4: Design Validation
**Skill:** `database-design-validation`
**Output file:** `results/04-design-validation-G09.md`

- Load the `database-design-validation` skill.
- Read Steps 1, 2, and 3 outputs (`01-*.md`, `02-*.md`, `03-*.md`) as inputs.
- Cross-validate structural mapping, keys/relationships, domains/constraints, and business rules.
- Use only explicit text in the three source artifacts as evidence — no inference.
- Output either `No errors found.` or a findings table.
- Write the output to `results/04-design-validation-G09.md`.
- **Gate:** If Step 4 reports errors, **do not** proceed to Step 5. Report the findings and stop.
- **Critical Thinking:** Does a clean validation mean the design is correct, or just internally consistent? What real-world scenarios might still slip through despite all checks passing? Are there business rules that cannot be structurally enforced and are merely documented as assumptions?

### Step 5: Database Definition (DDL)
**Skill:** `database-implementation`
**Output file:** `results/05-db-definition-G09.sql`

- Load the `database-implementation` skill.
- Read Step 3 (logical design) and Step 4 (validation) as inputs.
- Generate executable T-SQL DDL for Microsoft SQL Server:
  - `CREATE DATABASE`, `DROP` phase (re-runnable), tables with all constraints, foreign keys, triggers.
- Implement procedural rules from Section 4 of logical design as T-SQL triggers:
  - `trg_booking_enforce_rules` covering overlapping booking prevention, space availability gate, role-based authorization, and status state machine.
- Write the output to `results/05-db-definition-G09.sql`.
- **Gate:** Confirm Step 5 output exists before proceeding.
- **Critical Thinking:** Does the trigger implementation correctly handle concurrent inserts (race conditions)? Are there any edge cases in the status state machine that could leave a booking in an inconsistent state? Is the `INSTEAD OF` trigger pattern the right choice over `AFTER` triggers for overlap prevention? What happens to existing data when a new constraint is added?

### Step 6: Sample Data Preparation
**Skill:** `sample-data`
**Output file:** `results/06-sample-data-G09.sql`

- Load the `sample-data` skill.
- Read Step 5 DDL (`05-*.sql`) and Step 1 BR analysis (`01-*.md`) as inputs.
- Generate `INSERT INTO` statements in topological dependency order.
- Cover both normal operations (happy path) and exceptional cases (constraint boundary tests).
- Use `DECLARE` variables + `SCOPE_IDENTITY()` — never hardcode `IDENTITY` column values.
- Document scenarios covered (Normal Operations + Exceptional Cases).
- Write the output to `results/06-sample-data-G09.sql`.
- **Gate:** Confirm Step 6 output exists before proceeding.
- **Critical Thinking:** Do the exceptional test cases actually hit every CHECK constraint boundary? Are there valid business scenarios that the sample data silently omits? If this data were run against the schema, would any trigger reject an insert that the CHECK constraints would accept? Is there sufficient data variety to test all multi-role FK relationships?

### Step 7: Query Design
**Skill:** *(none — this step is implemented inline within the total-skill)*
**Output file:** `results/07-query-design-G09.sql`

- Read the full schema from Step 5 (`05-*.sql`) and the business requirements from Step 1 (`01-*.md`).
- Design and write T-SQL queries that demonstrate the system's reporting and operational capabilities, including but not limited to:
  - Upcoming bookings for a given space.
  - Booking history for a given user.
  - Maintenance status of all spaces.
  - No-show bookings within a date range.
  - Spaces currently in use.
  - Overlapping booking detection.
  - Facility inventory for a specific space.
  - Approval workflow status for a given booking.
  - Aggregate reports (e.g., total bookings per space, per month).
- Each query must include a brief header comment explaining its business purpose.
- Write the output to `results/07-query-design-G09.sql`.
- **Critical Thinking:** Do the queries answer real operational questions or just demonstrate SQL syntax? Are there edge cases in the data (nulls, overlapping dates, deleted references) that each query should handle gracefully? Are there performance considerations — do any queries need indexes beyond the PK/FK constraints? Could the same answer be obtained more efficiently with a different join order or filter placement?

## Output Template (per step)

Each step writes to `results/<NN>-<name>-G09.<ext>` using the output format prescribed by its respective skill.

## Naming Convention

| Step | File Pattern | Skill Used |
|:---:|:---|:---|
| 1 | `results/01-business-req-analysis-G09.md` | `business-req-analysis` |
| 2 | `results/02-erd-design-G09.md` | `erd-design` |
| 3 | `results/03-logical-design-G09.md` | `logical-design` |
| 4 | `results/04-design-validation-G09.md` | `database-design-validation` |
| 5 | `results/05-db-definition-G09.sql` | `database-implementation` |
| 6 | `results/06-sample-data-G09.sql` | `sample-data` |
| 7 | `results/07-query-design-G09.sql` | *(inline)* |

## Pre-Flight Checklist

Before starting the pipeline, verify:
- [ ] Project case description / requirements brief is available.
- [ ] Target DBMS is Microsoft SQL Server (T-SQL).
- [ ] `results/` directory exists (create if not).
- [ ] All referenced skills (business-req-analysis, erd-design, logical-design, database-design-validation, database-implementation, sample-data) are present under `.opencode/skills/`.
- [ ] Naming suffix convention is confirmed (e.g., `-G09`).
