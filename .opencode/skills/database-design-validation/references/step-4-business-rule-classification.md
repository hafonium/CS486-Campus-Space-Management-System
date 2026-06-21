# Step 4 — Business Rule Classification

## Scope filter: classify before flagging

Work through every numbered business rule in the BR document. For each rule, **first** determine whether it belongs in the database design scope:

### Database-Enforceable
Rules about data integrity, uniqueness, referential integrity, required fields, value ranges, format constraints, or data relationships. These must appear in the logical design — either as schema-level constraints (Structural) or in the Procedural Enforcement section.

### Application-Layer (out of scope)
Rules about:
- External authentication (SSO/LDAP, OAuth, "valid university account")
- User authorization logic (role-based access outside DB)
- UI validation or front-end behaviour
- Application workflow or business process logic that does not touch data constraints

**Do NOT flag Application-Layer rules as validation gaps.** Note them for awareness only. The database schema cannot independently enforce authentication or authorization against external systems.

---

## For Database-Enforceable rules: further classification

Classify each Database-Enforceable rule into one of three sub-categories:

### Structural
The rule is enforced by schema-level constructs:
- PRIMARY KEY or UNIQUE constraint
- FOREIGN KEY with ON DELETE RESTRICT
- NOT NULL constraint
- Single-row CHECK constraint
- Domain constraint (enum, data type)

A structural rule must have a concrete schema artifact. If you cannot point to the exact constraint, do not classify it as structural.

### Procedural
The rule cannot be enforced by single-row constraints and requires:
- Cross-table validation (reads another table at enforcement time)
- Multi-row comparison (compares the new/updated row against other rows in the same table)
- State machine enforcement (validates a transition, not just a state)

A procedural rule must be listed in the logical design's "Procedural Enforcement" section with a named enforcement strategy (trigger, application middleware, stored procedure). If it is not listed there, it is **missing**.

### Missing
A Database-Enforceable rule that appears in the BR but has no corresponding structural constraint **and** no mention in the Procedural Enforcement section. Record as a `Business Rule Gap` finding.

---

## Typical classification reference

| Common business rule pattern | Classification |
| :--- | :--- |
| "X must be unique" | Database-Enforceable → Structural (UNIQUE / PK) |
| "Field A must be before field B" | Database-Enforceable → Structural (CHECK a < b) |
| "If status is X, fields Y and Z must be filled" | Database-Enforceable → Structural (conditional CHECK) |
| "No two rows may have overlapping time ranges" | Database-Enforceable → Procedural (multi-row) |
| "Status must follow lifecycle S1→S2→S3" | Database-Enforceable → Procedural (state machine) |
| "Historical records must never be deleted" | Database-Enforceable → Structural (RESTRICT on FKs) |
| "User must have a valid university account" | Application-Layer (external auth — out of scope) |
| "Only users with role R may perform action A" | Application-Layer (authorization — out of scope) |

---

## Enforcement documentation check

For every rule classified as Database-Enforceable → Procedural:
1. Open the logical design's Section 4 "Procedural Enforcement."
2. Confirm the rule is listed by number (e.g., "Business Rule #3").
3. Confirm a concrete enforcement strategy is named.
4. If a procedural rule lacks an enforcement strategy, record a finding.

---

## Internal working table (do not include in output)

Build this table in memory to track classifications:

| BR # | Rule summary | Scope | Sub-classification | Schema artifact or Procedural ref |
| :--- | :--- | :--- | :--- | :--- |

If any Database-Enforceable row has a blank last column, that BR is a finding.
