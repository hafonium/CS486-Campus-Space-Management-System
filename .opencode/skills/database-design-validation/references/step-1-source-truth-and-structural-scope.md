# Step 1 — Structural Mapping & Internal Consistency

**Apply the No-Inference Rule from SKILL.md.** Use only the three current output files as evidence.

## Source-of-truth rules

- Use **only** these three inputs: the requirements analysis output, the conceptual ERD output, and the logical database design output.
- Do not use memory, prior conversation context, unrelated repository files, or intuition.
- If an entity, attribute, relationship, or rule cannot be confirmed from one of these three files, treat it as a finding. Do not invent it.

---

## Part A: Cross-document Structural Mapping

### Entity-to-table mapping

For every entity declared in the ERD (both in the diagram and the data dictionary):
1. Extract the entity name exactly as written.
2. Search the logical schema for a table/entity block with that exact name. (DBML: `Table` blocks; SQL DDL: `CREATE TABLE` statements.)
3. If a table is found, proceed to attribute-to-column mapping.
4. **If no table is found:** Report as `Structural Mapping` — quote the ERD entity name and confirm no schema table with that name exists.

### Attribute-to-column mapping

For every attribute listed in the ERD entity's data dictionary:
1. Extract the attribute name exactly as written (including case, underscores, spacing).
2. Search the corresponding schema table for a column with that exact name.
3. **If found:** Check data type validity (see SKILL.md Data Type Equivalence).
4. **If not found:** Report as `Structural Mapping` — quote ERD attribute and confirm no schema column with that name.
5. **Do not assume a rename.** If ERD says `user_id` but schema has `userId` or `id`, report the mismatch.

### Relationship-to-FK/junction mapping

For every relationship line in the ERD diagram:
1. Note the two participating entity names exactly as shown.
2. Note the cardinality symbols. (Mermaid: `||` = exactly one, `o{` = zero or more, `}|` = one or more, `}o` = zero or more optional.)
3. **For 1:N or 1:1:**
   - Determine which entity is the child (many-side or referenced-side).
   - Search the child table for an FK constraint referencing the parent table's PK.
   - If found, verify it references the correct parent PK.
   - If no FK exists, report as `Structural Mapping`.
4. **For M:N:**
   - Search the schema for a junction table (name typically combines both parent entity names).
   - If found, verify it has both parent PKs as columns with proper constraints.
   - If no junction table exists, report as `Structural Mapping`.
5. **Do not assume** a relationship is resolved by a nearby FK or table.

### Multi-role relationship check

When one entity participates in multiple relationships of the same type with the same other entity (e.g., Employee→Task: creator, reviewer, approver):
1. Confirm the schema has that many separately named FK columns (not one overloaded column).
2. Confirm each FK column name reflects its role (e.g., `created_by_employee_id`, `reviewed_by_employee_id`).
3. Confirm each FK's nullability independently matches its own ERD relationship cardinality.

### Cross-document attribute count

After mapping attributes:
1. Count non-FK attributes in the ERD entity.
2. Count non-FK columns in the schema table.
3. If they differ and the difference is not explained by documented design decisions, record a finding.

---

## Part B: Internal Document Consistency

### Within the ERD

Compare Mermaid diagram cardinality notation against the Relationship Summary table text for every relationship:
- If the diagram symbols indicate mandatory participation (`}|` or `|{`) but the text uses permissive wording ("may", "zero or more", "optional"), report as `Internal Inconsistency`.
- Quote both the diagram line and the summary table text.

### Within the logical design: Enum values vs. prose

Compare schema enum/domain values against the same document's prose in later sections:
- If a Procedural Enforcement or other prose section references a value by name that does **not** match the schema enum definition, report as `Internal Inconsistency`.
- Example: DBML `Enum order_status` has `canceled` but Section 4 references `cancelled`.

### Within the logical design: FK summary table vs. schema

Compare the FK summary table against the schema FK declarations and column definitions:
- Check presence/absence of `[delete: cascade]` or `ON DELETE` behavior.
- Check nullability: if table says `nullable=Yes` but schema has `[not null]`, report as `Internal Inconsistency`.

### Within the logical design: NOT NULL summary table vs. schema

Compare the NOT NULL constraints table against the schema column constraints:
- If the table lists a column as NOT NULL but the schema omits `[not null]` — or vice versa — report as `Internal Inconsistency`.

### Within the logical design: CK summary vs. schema

Compare documented candidate keys against schema `[unique]` annotations or `UNIQUE` indexes:
- If a CK is documented in the summary table but has no corresponding UNIQUE constraint in the schema, report as `Internal Inconsistency`.
