# Reference: Foreign Key Placement & Referential Semantics

## 1. Topological Declaration (Global End-Block)
Foreign keys **must never** be declared inline inside table attribute lists (e.g., `fk_id int [ref: > PARENT.id]`). They must be aggregated globally under a dedicated `// --- Relationships ---` header at the absolute bottom of the DBML script.
* **Standard Syntax:** `Ref: CHILD_TABLE.fk_column > PARENT_TABLE.pk_column`

## 2. Referential Delete Semantics (T-SQL Standard)
* **Standard Base Entities (The RESTRICT / NO ACTION rule):**
  To preserve institutional audit trails and satisfy historical immutability requirements, standard operational entities must never cascade deletes. 
  * *In DBML:* Omit delete modifiers entirely. (This falls back to T-SQL's native `ON DELETE NO ACTION`, acting as logical `RESTRICT`).
  * *In Section 2 (Foreign Keys table):* Document the Delete Behavior explicitly as **RESTRICT**.
* **Associative Entities (The CASCADE rule):**
  Applies **strictly** to pure intermediate junction tables representing resolved M:N relationships.
  * *In DBML:* `Ref: JUNCTION_TABLE.fk_a > PARENT_A.pk [delete: cascade]`
  * *In Section 2 (Foreign Keys table):* Document explicitly as **CASCADE**.

## 3. Multi-Role Disambiguation
When Table A references Table B multiple times for distinct operational purposes, the foreign key columns in Table A must be named strictly after their specific functional role, **not** the target table's name.
* *Example:* A transaction requires a submitter, an auditor, and a final approver.
  ```dbml
  submitter_id integer [not null]
  auditor_id integer // nullable
  approver_id integer // nullable
  ```