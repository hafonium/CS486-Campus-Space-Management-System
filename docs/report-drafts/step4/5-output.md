# Database Design Validation (Step 4)

---

## 1. Validation Status

**VALIDATION FAILED**: Inconsistencies detected. Action required.

---

## 2. Findings & Resolution Plan

| Category | Description of Mismatch | Evidence (Quote Both Sides) | Recommended Fix |
| :--- | :--- | :--- | :--- |
| Internal Inconsistency | ERD Mermaid diagram cardinality for `SPACE }|--|{ FACILITY : "contains"` shows mandatory participation on both sides (`}|` = one-or-more, `|{` = one-or-more), but the ERD Relationship Summary table (line 141) describes optional participation: "Each space *may* contain many facility types; each facility type *may* exist in many spaces." The BR analysis (Section 7, line 106) also states "Participation is optional on the Space side (a space may have no recorded facilities)." The diagram notation contradicts both the ERD text and the BR. | ERD Mermaid line 19: `SPACE }|--|{ FACILITY : "contains"`; ERD Relationship Summary line 141: "Each space *may* contain many facility types; each facility type *may* exist in many spaces." | In `outputs/02-erd-design-G09.md` line 19, change `SPACE }|--|{ FACILITY` to `SPACE }o--o{ FACILITY` to reflect optional participation on both sides, consistent with the Relationship Summary table text and BR analysis. |
| Business Rule Gap | Business Rule 1 ("Each user must have a valid university account to interact with the system") is not explicitly addressed in the logical design. The USER table provides structural support (UNIQUE on `email` and `phone_number`, NOT NULL on required identity fields), but the Procedural Enforcement section (Section 4, lines 191–202) does not mention BR 1 or document how external university account validation is handled. | BR Section 8 line 120: "Each user must have a valid university account to interact with the system."; Logical Design Section 4 (lines 191–202): no entry for BR 1. | Add a Procedural Enforcement item in Section 4 of `outputs/03-logical-design-G09.md` stating: "Business Rule 1 (University Account Validation): External university account authentication (e.g., SSO, LDAP) is enforced at the application authentication layer. The schema enforces uniqueness on `email` and `phone_number` to prevent duplicate accounts but does not independently validate against university systems." |

---

## 3. Action Required

Return to Step 2 (ERD Design) to correct the `SPACE }|--|{ FACILITY` cardinality symbols in the Mermaid diagram (change `}|--|{` to `}o--o{`). Then update Step 3 (Logical Design) to add Procedural Enforcement documentation for Business Rule 1. Re-run validation after both fixes are applied.
