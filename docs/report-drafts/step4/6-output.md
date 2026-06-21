# Database Design Validation

## 1. Validation Status

**VALIDATION FAILED**: Inconsistencies detected. Action required.

## 2. Findings & Resolution Plan

| Category | Description of Inconsistency | Evidence (Quote Both Sides) | Recommended Fix |
| :--- | :--- | :--- | :--- |
| Internal Inconsistency | ERD Mermaid diagram uses mandatory cardinality symbols (`}\|` and `\|{`) for the SPACE–FACILITY relationship, but the ERD Relationship Summary table uses optional wording ("may"). The BR also confirms optional participation on both sides. | ERD diagram (line 19): `SPACE }\|--\|{ FACILITY : "contains"` (symbols `}\|` = one or more / mandatory, `\|{` = one or more / mandatory). ERD Relationship Summary (line 141): "Each space **may** contain many facility types; each facility type **may** exist in many spaces." BR Section 7 (line 107): "a space **may** have no recorded facilities." | In `outputs/02-erd-design-G09.md` line 19, change the Mermaid relationship line from `SPACE }\|--\|{ FACILITY : "contains"` to `SPACE }o--o{ FACILITY : "contains"` (zero or more on both sides) to match the Relationship Summary table and BR's optional-participation statement. |

## 3. Action Required

Return to the ERD design phase (`outputs/02-erd-design-G09.md`) and correct the Mermaid diagram cardinality symbols for the SPACE–FACILITY relationship from `}|--|{` (mandatory both sides) to `}o--o{` (optional both sides). The logical schema is unaffected by this change since junction-table PKs are always NOT NULL regardless of parent-entity participation requirements.
