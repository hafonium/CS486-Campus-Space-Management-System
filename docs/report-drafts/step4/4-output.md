# Database Design Validation

---

## 1. Validation Status

**VALIDATION FAILED** — Inconsistencies detected between the Step 3 logical schema and the Step 2 ERD / Step 1 Business Requirements. Action required.

---

## 2. Findings & Resolution Plan

| Category | Description of Inconsistency | Source of Truth (ERD/Req) | Recommended Fix for Schema |
| :--- | :--- | :--- | :--- |
| Domain Constraint (Enum value mismatch) | `Enum booking_status` in the DBML schema uses `missed` as the terminal "did not attend" status value. The ERD data dictionary (line 111), the Business Requirements Section 5 (candidate attributes), BR Section 8 (business rules), BR Section 9 (no-show handling), and even the logical design's own Section 4 Procedural Enforcement (point 4) all consistently use `no_show`. | ERD: `booking_status` — string *(pending / approved / rejected / cancelled / checked_in / completed / **no_show**)*; BR Section 5: `booking_status` (pending / approved / rejected / cancelled / checked_in / completed / **no_show**); BR Section 9: "No-show handling" | In `outputs/03-logical-design-G09.md` line 61, change `missed` to `no_show` in the `Enum booking_status` block. |
| Key / Constraint (Missing NOT NULL) | `BOOKING.requester_id` in the DBML schema (line 105) is declared without `[not null]`. The ERD relationship `USER \|\|--o{ BOOKING : "submits"` indicates mandatory participation on the BOOKING side (every booking must have exactly one requester). The FK summary table (line 177) and the NOT NULL constraints table (line 195) both correctly state `requester_id` is mandatory, but the DBML code does not reflect this. | ERD: `USER \|\|--o{ BOOKING : "submits"` (mandatory on Booking side); BR Section 7: "each booking must be submitted by exactly one user" | In `outputs/03-logical-design-G09.md` line 105, add `[not null]` so it reads `requester_id integer [not null]`. |
| Key / Constraint (Missing CASCADE delete) | `SPACE_FACILITY.facility_id` FK reference in the DBML schema (line 157) is missing `[delete: cascade]`, while the matching `space_code` FK reference (line 156) has it. The FK summary table (line 186) correctly lists CASCADE for both. As a junction table with no independent identity, both FKs should use CASCADE delete so that removing a FACILITY also removes its junction rows. | ERD: M:N relationship resolved via junction table (no attribute of its own); FK summary table (line 186): `facility_id` → CASCADE | In `outputs/03-logical-design-G09.md` line 157, add `[delete: cascade]` so it reads `Ref: SPACE_FACILITY.facility_id > FACILITY.facility_id [delete: cascade]`. |

**Additional observation (not a schema error):**

The ERD diagram uses Mermaid notation `SPACE }|--|{ FACILITY` where `}|` and `|{` mean mandatory participation (one or more) on both sides. However, the ERD relationship summary table (line 141) correctly describes optional participation: "Each space *may* contain many facility types; each facility type *may* exist in many spaces." The logical schema correctly implements the intended optional semantics via the `SPACE_FACILITY` junction table. The ERD diagram notation at `outputs/02-erd-design-G09.md` line 19 should ideally be updated to `SPACE }o--o{ FACILITY` for consistency with its own description, but this does not affect the schema.

---

## 3. Action Required

Return to Step 3 (`outputs/03-logical-design-G09.md`) and apply the three fixes listed above:

1. Line 61: `missed` → `no_show` in `Enum booking_status`
2. Line 105: `requester_id integer` → `requester_id integer [not null]`
3. Line 157: Add `[delete: cascade]` to the `SPACE_FACILITY.facility_id` Ref

Then re-run this validation.
