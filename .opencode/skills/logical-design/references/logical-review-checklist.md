# Reference: Pre-Flight Logical Review Checklist

Before outputting the final Markdown report, the LLM agent must silently execute this 6-point internal validation script against its generated schema:

* [ ] **Gate 1: The T-SQL "No-Enum" Audit**
      Scan the DBML block. Are there any `Enum {}` syntax structures? 
      * *If YES:* Kill the process immediately. Convert those attributes to standard `varchar(50)` and generate SQL `CHECK` expressions inside Section 3.

* [ ] **Gate 2: Candidate Key Bi-Directional Parity**
      * DBML -> Doc check: For every column carrying the `[unique]` tag, verify it is bulleted in Section 2.
      * Doc -> DBML check: For every CK listed in Section 2, verify the DBML code carries the `[unique]` tag.

* [ ] **Gate 3: Referential Delete Behavior Parity**
      Cross-examine the Section 2 FK Summary Table against the DBML `Ref:` statements:
      * Does the text state `RESTRICT` while the DBML code has `[delete: cascade]`? (Fatal mismatch).
      * Standard: Set written text to `RESTRICT` for operational base tables, and `CASCADE` strictly for junction tables.

* [ ] **Gate 4: Mandatory Nullability Alignment**
      * Does Section 2 list a column as `NOT NULL` while the DBML code forgot the `[not null]` tag? 
      * *Action:* Append missing `[not null]` tags into the DBML table definitions.

* [ ] **Gate 5: Categorical Domain Check Coverage**
      Inspect Section 3 (Business Integrity Constraints). Does it contain an explicit `CHECK (column IN (...))` expression for **every single** categorical variable declared in the DBML?

* [ ] **Gate 6: Scalar Boundary Bi-Directional Traceability**
      Scan Section 3 for any mathematical scalar checks (e.g., `capacity > 0`, `expected_participants > 0`). 
      * *Action:* Verify that the corresponding column in the DBML block (Section 1) explicitly carries an inline pointer note matching its predicate: `note: 'CHECK ([column] > 0) – Section 3'`. Do not leave scalar check columns un-noted.