---
name: logical-design
description: Translate a Conceptual Entity-Relationship Diagram (ERD) into a Relational Schema using DBML syntax. Map entities to tables, resolve M:N relationships, establish Primary/Foreign Keys, define Enums, apply constraints, and document business integrity rules.
---

# Logical Database Design

## Purpose
This skill helps the agent transform a Conceptual ERD (Step 2) into a structured Logical Database Design (Step 3). 

The final output must provide a strict relational schema written in DBML (Database Markup Language) ready for SQL implementation, ensuring all structural rules, referential integrity, and cardinality constraints are mathematically resolvable. It must also document complex business constraints that require procedural enforcement.

## When to use
Use this skill when:
- the user provides a Conceptual ERD and Business Requirement Analysis.
- the user asks to generate a relational schema, tables, map foreign keys, or write DBML.
- the task is specifically designated as "Logical Design" or "Step 3".

Do not use this skill when:
- the user asks for SQL DDL/DML statements (that is Step 5).
- the user is still asking to identify basic entities or draw Mermaid diagrams.

## Inputs
The agent should expect:
- The completed Step 2 Conceptual ERD.
- The completed Step 1 Business Requirements (for constraint validation).

## Workflow

### Step 1: Map Strong Entities
- Convert every strong entity from the ERD into a Relation (Table).
- Identify and mark the Primary Key (PK).
- Ensure no foreign keys are added in this step.

Before this step, read `references/relation-mapping-guide.md`.

### Step 2: Map 1:N and 1:1 Relationships
- Place a Foreign Key (FK) on the "Many" side referencing the Primary Key of the "One" side.
- For relationships involving the same two entities, create distinct, descriptively named Foreign Keys for each role.

Before this step, read `references/foreign-key-placement.md`.

### Step 3: Resolve M:N Relationships
- Create a new Associative Relation (Junction Table) for every Many-to-Many relationship with a Composite Primary Key.

Before this step, read `references/junction-table-rules.md`.

### Step 4: Define Constraints, Candidate Keys, Enums, and Defaults
- Identify Candidate Keys (CK) and define business constraints (e.g., NOT NULL, unique).
- Define Enums for domain-restricted fields and set logical Default values.

Before this step, read `references/candidate-key-constraints.md`.

### Step 5: Draft the Schema in DBML
- Convert the logical design into strict DBML syntax.
- Ensure all references are strictly placed at the bottom of the file.

Before this step, read `references/dbml-syntax-guide.md`.

### Step 6: Identify Business Integrity Constraints & Assumptions
- Review the Step 1 Business Rules to find constraints that cannot be natively enforced via DBML relationships (e.g., `capacity > 0`, `start_time < end_time`).
- Identify complex procedural rules (e.g., preventing overlapping bookings) and document them as requiring Application Logic or Triggers.
- Document any assumptions made regarding Candidate Keys (e.g., assuming a name is universally unique).

### Step 7: Write the Design Notes
- Document the architectural choices, particularly M:N resolution, multi-role FKs, and constraint justifications.

## Output template
Use this exact structure:

### 1. Relational Schema (DBML)
*Copy the code below and paste it into [dbdiagram.io](https://dbdiagram.io/) to view the schema.*

```dbml
// Paste DBML code here
```

### 2. Constraints and Keys Summary

**Primary Keys & Candidate Keys:**
* **[TABLE_NAME]:** PK = `[attribute]`, CK = `[attribute]`

**Foreign Keys & Referential Integrity:**
* `[TABLE].[FK_COLUMN]` references `[TARGET_TABLE].[PK_COLUMN]` *(Notes: Nullability / Cascades)*

**NOT NULL Constraints:**
| Table | NOT NULL Columns |
|---|---|
| [TABLE] | `col1`, `col2` |

### 3. Business Integrity Constraints
List all domain and tuple-level constraints (CHECK constraints) derived from the business rules that are not structurally represented in DBML.
* **[TABLE_NAME]:** `[Condition, e.g., capacity > 0]` - *(Justification)*

### 4. Architectural Assumptions
List complex rules requiring procedural enforcement (Triggers/App Logic) and design assumptions.
* **Procedural Enforcement:** [Explain rules like overlapping bookings].
* **Design Assumptions:** [Explain assumptions like Candidate Key uniqueness scopes].

### 5. Design Notes
1. **M:N Resolution:** [Explain how junction tables were formed].
2. **Multiple Role Mapping:** [Explain how multiple FKs between the same entities were named and mapped].
3. **Domain Constraints (Enums & Defaults):** [Briefly explain the use of DBML Enums and default values].
4. **Referential Integrity:** [Explain cascade behaviors applied].

## Review checklist
Before finishing, read `references/logical-review-checklist.md` and verify:
- M:N relationships are resolved.
- Multi-role foreign keys are distinctly named.
- DBML syntax is strictly valid with global `Ref:` definitions.
- Enums are used instead of string notes.
- Sections 3 (Business Integrity Constraints) and 4 (Architectural Assumptions) are fully populated based on Step 1.