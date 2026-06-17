# ERD Conceptual Review Checklist

## Goal
Validate that the conceptual design correctly maps the business requirements without accidentally introducing logical database constraints (Step 3).

## Final checks

### Entity Integrity
- Are all major candidate entities from Step 1 represented?
- Do the entities represent real-world concepts rather than technical database constructs?
- Does every entity block have a designated Unique Identifier marked with `PK`?

### Attribute Purity (The FK Check)
- **CRITICAL:** Scan every single entity's attribute list. Are there any Foreign Keys? (If an entity has an ID belonging to another entity, it fails this check).

### Relationship Accuracy
- Are all business relationships from Step 1 visually represented by lines?
- Do the relationship lines include a descriptive verb phrase in quotes?
- Are Many-to-Many (M:N) relationships preserved using the `}|--|{` syntax?

### Syntax Validity
- Does the code block start with `erDiagram`?
- Are entity names and attribute names formatted without spaces?

## Pass condition
The conceptual design is ready to hand off to logical schema design only if:
- the visual abstraction maps directly to the business requirements,
- it contains exactly zero Foreign Keys,
- M:N relationships are not artificially resolved into junction tables,
- the Mermaid code can be executed in a live viewer without throwing syntax errors.