# Reference: Pre-Flight Logical Review Checklist

Before outputting the final Markdown report, the LLM agent must silently execute this 6-point internal validation script against its generated schema:

* [ ] **Gate 1: The T-SQL "No-Enum" Audit**
      Scan the DBML block. Are there any `Enum {}` syntax structures? 
      * *If YES:* Halt generation immediately. Convert those attributes to standard `varchar(50)` and generate SQL `CHECK` expressions inside Section 3.

* [ ] **Gate 2: Candidate Key Bi-Directional Parity**
      * DBML -> Doc check: For every column carrying the `[unique]` tag, verify it is bulleted in Section 2.
      * Doc -> DBML check: For every CK listed in Section 2, verify the DBML code carries the `[unique]` tag.

* [ ] **Gate 3: Referential Delete Behavior Parity**
      Cross-examine the Section 2 FK Summary Table against the DBML `Ref:` statements:
      * Does the text state `RESTRICT` while the DBML code has `[delete: cascade]`? (Fatal mismatch).
      * Standard: Set written text to `RESTRICT` for operational base tables, and `CASCADE` strictly for junction tables.

* [ ] **Gate 4: Structural Section 2 Completeness Audit**
      Verify that Section 2 physically renders **all three** mandatory markdown structural blocks without using decimal sub-headings (`### 2.1`):
      1. Bold Run-in Header: `**Primary Keys & Candidate Keys:**` (Fully populated).
      2. Bold Run-in Header: `**Foreign Keys & Referential Integrity:**` (Fully populated markdown table).
      3. Bold Run-in Header: `**NOT NULL Constraints:**` (Fully populated markdown table mapping all `[not null]` DBML attributes). Never drop the NOT NULL summary table.

* [ ] **Gate 5: Categorical Domain Check Coverage**
      Inspect Section 3 (Business Integrity Constraints). Does it contain an explicit `CHECK (column IN (...))` expression for **every single** categorical variable declared in the DBML?

* [ ] **Gate 6: AST Traceability Pointer Note Bijection**
      Scan Section 3 for any single-row constraints (categorical domains, scalar bounds `> 0`, chronological timeline orders). 
      * *Action:* Verify that the corresponding column in the DBML block explicitly mounts an inline pointer note matching its mathematical predicate: `note: 'CHECK (...) – Section 3'`. Zero un-noted check columns allowed.