# Database Design Validation

## 1. Validation Summary

| Area | Entities → Tables | Relationships → FKs/Junction | Keys (PK/FK/CK) | FK Nullability vs Cardinality | Enums / Defaults | Data Types | Business Rules |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| Result | All 5 entities present (+ 1 junction table) | All 9 relationships represented | All PKs & FKs correct; all CKs declared | Nullability matches ERD cardinality for all FKs | All 7 enums match BR values; 4 sensible defaults | Consistent (string→varchar/text, int→integer, datetime preserved) | All 12 rules addressed (7 structural, 5 procedural) |

---

## 2. Structural Mapping

### 2.1 Entities → Tables

| ERD Entity | Schema Table | Status |
| :--- | :--- | :--- |
| USER | `USER` | Present |
| SPACE | `SPACE` | Present |
| FACILITY | `FACILITY` | Present |
| BOOKING | `BOOKING` | Present |
| MAINTENANCE_RECORD | `MAINTENANCE_RECORD` | Present |
| *(M:N junction, added at logical stage)* | `SPACE_FACILITY` | Correct resolution |

No missing tables. No extra tables beyond the intended junction table.

### 2.2 Relationships → Foreign Keys / Junction Tables

| ERD Relationship | Cardinality | Schema Representation | Correct? |
| :--- | :--- | :--- | :--- |
| USER — submits — BOOKING | `||--o{` | `BOOKING.requester_id → USER.user_id` | ✓ |
| USER — decides_on — BOOKING | `\|o--o{` | `BOOKING.decision_staff_id → USER.user_id` (nullable) | ✓ |
| USER — checks_in — BOOKING | `\|o--o{` | `BOOKING.check_in_staff_id → USER.user_id` (nullable) | ✓ |
| USER — completes — BOOKING | `\|o--o{` | `BOOKING.completion_staff_id → USER.user_id` (nullable) | ✓ |
| SPACE — hosts — BOOKING | `\|\|--o{` | `BOOKING.space_code → SPACE.space_code` | ✓ |
| USER — reports — MAINTENANCE_RECORD | `\|\|--o{` | `MAINTENANCE_RECORD.reporter_id → USER.user_id` | ✓ |
| USER — assigned_to — MAINTENANCE_RECORD | `\|o--o{` | `MAINTENANCE_RECORD.assigned_staff_id → USER.user_id` (nullable) | ✓ |
| SPACE — undergoes — MAINTENANCE_RECORD | `\|\|--o{` | `MAINTENANCE_RECORD.space_code → SPACE.space_code` | ✓ |
| SPACE — contains — FACILITY (M:N) | `}\|--\|{` | `SPACE_FACILITY` junction table, composite PK `(space_code, facility_id)` | ✓ |

All 9 ERD relationships are correctly represented. The M:N relationship is properly resolved through the `SPACE_FACILITY` junction table.

### 2.3 FK Nullability Verification

| FK Column | ERD Cardinality (BOOKING/MAINT side) | Schema Nullable? | Match? |
| :--- | :--- | :--- | :--- |
| `requester_id` | `\|\|` (mandatory) | NOT NULL | ✓ |
| `decision_staff_id` | `\|o` (optional) | nullable | ✓ |
| `check_in_staff_id` | `\|o` (optional) | nullable | ✓ |
| `completion_staff_id` | `\|o` (optional) | nullable | ✓ |
| `space_code` (BOOKING) | `\|\|` (mandatory) | NOT NULL | ✓ |
| `reporter_id` | `\|\|` (mandatory) | NOT NULL | ✓ |
| `assigned_staff_id` | `\|o` (optional) | nullable | ✓ |
| `space_code` (MAINT) | `\|\|` (mandatory) | NOT NULL | ✓ |

No mismatches. Every FK nullability setting aligns with the ERD cardinality.

---

## 3. Keys & Relationships

### 3.1 Primary Keys

| Table | PK in Schema | Consensus with ERD |
| :--- | :--- | :--- |
| USER | `user_id` (integer, auto-increment) | ✓ |
| SPACE | `space_code` (varchar) | ✓ |
| FACILITY | `facility_id` (integer, auto-increment) | ✓ |
| BOOKING | `booking_id` (integer, auto-increment) | ✓ |
| MAINTENANCE_RECORD | `maintenance_id` (integer, auto-increment) | ✓ |
| SPACE_FACILITY | `(space_code, facility_id)` (composite) | ✓ (correct M:N resolution) |

### 3.2 Candidate Keys / Unique Constraints

| Table | Candidate Key | Declared? | Justification |
| :--- | :--- | :--- | :--- |
| USER | `email` | Unique constraint present | Documented as Design Assumption #2 |
| USER | `phone_number` | Unique constraint present | Documented as Design Assumption #3 |
| SPACE | `(building, floor, room_number)` | Unique composite index `uq_space_location` | Documented as Design Assumption #5 |
| FACILITY | `facility_name` | Unique constraint present | Documented as Design Assumption #4 |

All candidate keys are properly declared in the schema.

### 3.3 Foreign Key Placement

All FKs are placed on the correct ("many") side of 1:N relationships. BOOKING carries four FK references to USER (requester, decision, check-in, completion), and MAINTENANCE_RECORD carries two (reporter, assigned staff). Each FK role is independently nullable according to its ERD cardinality.

---

## 4. Domains & Constraints

### 4.1 Enum Values vs Business Requirements

| Enum | Schema Values | BR Source Values | Match? |
| :--- | :--- | :--- | :--- |
| `user_role` | student, lecturer, teaching_assistant, facility_staff, department_administrator, facility_manager | BR Section 3 (6 actors) | ✓ |
| `account_status` | active, suspended, deactivated | BR Section 5 | ✓ |
| `space_type` | auditorium, classroom, computer_lab, project_lab, meeting_room, student_workspace | BR Section 5 | ✓ |
| `space_status` | available, in_use, under_maintenance, temporarily_closed, retired | BR Section 5 | ✓ |
| `booking_purpose` | lecture, examination, seminar, workshop, meeting, student_activity, administrative_event | BR Section 5 | ✓ |
| `booking_status` | pending, approved, rejected, cancelled, checked_in, completed, no_show | BR Section 5 | ✓ |
| `maintenance_status` | reported, in_progress, completed | BR Section 9 Assumption | ✓ |

All 7 enums contain exactly the values specified or reasonably assumed in the business requirements.

### 4.2 Default Values

| Column | Default | Rationale | Status |
| :--- | :--- | :--- | :--- |
| `USER.account_status` | `'active'` | Newly registered accounts start active | ✓ |
| `SPACE.current_status` | `'available'` | Newly catalogued spaces are ready | ✓ |
| `BOOKING.booking_status` | `'pending'` | New requests await decision | ✓ |
| `MAINTENANCE_RECORD.status` | `'reported'` | New issues start in reported state | ✓ |

All defaults are logically sound and match the stated business process.

### 4.3 Data Type Consistency

| Abstract Type (ERD) | Concrete Type (Schema) | Appropriate? |
| :--- | :--- | :--- |
| `string` | `varchar` / `text` | ✓ (informational fields use `text`; identifiers use `varchar`) |
| `int` | `integer` | ✓ |
| `datetime` | `datetime` | ✓ |

No type mismatches.

### 4.4 NOT NULL Constraints

All NOT NULL constraints (Section 2 of the logical design) are consistent with the ERD cardinality and business rules:
- Every column that is a PK member is implicitly NOT NULL ✓
- `requester_id`, `reporter_id`, and both `space_code` FKs are NOT NULL (mandatory participation on the child side) ✓
- `requested_start_time`, `requested_end_time`, `purpose`, `expected_participants` are NOT NULL (Booking BR #4, BR #5 context) ✓
- `problem_description`, `start_time` are NOT NULL (meaningful maintenance records require these) ✓

---

## 5. Business Rule Coverage

| BR # | Rule | Enforcement Method | Covered? |
| :--- | :--- | :--- | :--- |
| 1 | Valid university account required | USER table + `account_status` enum + `email` unique | ✓ Structural |
| 2 | Unavailable space cannot be booked | Documented as procedural (cross-table trigger/application check) | ✓ Procedural |
| 3 | No overlapping approved bookings | Documented as procedural (multi-row comparison) | ✓ Procedural |
| 4 | `requested_start_time < requested_end_time` | CHECK constraint (Section 3 of logical design) | ✓ Structural |
| 5 | Approval records staff, time, note | CHECK constraint on `booking_status = 'approved'` | ✓ Structural |
| 6 | Rejection reason must be stored | CHECK constraint on `booking_status = 'rejected'` | ✓ Structural |
| 7 | Check-in records staff, time, condition | CHECK constraint on `booking_status = 'checked_in'` | ✓ Structural |
| 8 | Completion records end time, condition | CHECK constraint on `booking_status = 'completed'` | ✓ Structural |
| 9 | Only facility_staff/manager approves/rejects | Documented as procedural (role-based authorization) | ✓ Procedural |
| 10 | Only facility_staff checks in/completes | Documented as procedural (role-based authorization) | ✓ Procedural |
| 11 | Historical records retained | FK RESTRICT semantics prevent parent-row deletion | ✓ Structural |
| 12 | Unique space code | `space_code` PK on SPACE table | ✓ Structural |

All 12 business rules are addressed — 7 are structurally enforced via schema constraints, and 5 are correctly identified as requiring procedural enforcement (triggers, application logic, or stored procedures).

---

## 6. Findings

### 6.1 Validation Status

**VALIDATION PASSED** — The Step 3 logical schema correctly represents the Step 2 ERD and satisfies all Step 1 business rules. Two observations are recorded below; neither breaks the schema's structural correctness.

### 6.2 Observations

| Category | Description | Source of Truth | Recommendation |
| :--- | :--- | :--- | :--- |
| Business Rule Gap (role modeling) | BR Section 3 Note and Section 9 Assumption #1 state "a user may potentially hold multiple roles." Both the ERD and the logical schema model `role` as a single-valued `user_role` enum on the USER table. The logical design acknowledges this as Design Assumption #1 ("this design assumes exactly one canonical role at any given time"). | BR Section 3 & Section 9 | If multi-role support is confirmed as a business requirement, promote `user_role` to a `USER_ROLE` junction table (M:N between USER and a ROLE lookup table). The schema is adequate for single-role operation but cannot represent multi-role users without structural change. |
| ERD Diagram Notation (cosmetic) | The ERD diagram uses `SPACE }\|--\|{ FACILITY` which in Mermaid syntax means mandatory participation (one or more) on both sides. The accompanying relationship summary table correctly describes optional participation: "Each space *may* contain many facility types; each facility type *may* exist in many spaces." The logical schema correctly implements the optional interpretation via the `SPACE_FACILITY` junction table. | ERD Section 1 (diagram) vs ERD Section 2 (summary table) | No corrective action needed for the logical schema — it correctly implements the intended optional semantics. The ERD diagram notation could be updated to `SPACE }o--o{ FACILITY` for consistency with its own summary text, but this is a Step 2 concern. |

---

## 7. Procedural Enforcement Summary

These rules require application logic, triggers, or stored procedures (correctly identified in Logical Design Section 4):

| Rule | Reason |
| :--- | :--- |
| Overlap prevention (BR #3) | Requires cross-row comparison of `(space_code, requested_start_time, requested_end_time)` |
| Space availability gate (BR #2) | Requires cross-table read of `SPACE.current_status` |
| Role-based authorization (BR #9, #10) | Requires reading `USER.role` at action time |
| Booking status state machine | Requires enforcing valid lifecycle transitions (e.g., `completed → pending` is illegal) |
| Maintenance status lifecycle | Requires enforcing forward-only transitions (`completed ↛ reported`) |

---

## 8. Review Checklist

- [x] All 5 ERD entities are represented as tables
- [x] All 9 ERD relationships are represented (as FKs or junction table)
- [x] M:N relationship resolved via correct junction table (`SPACE_FACILITY`)
- [x] All PKs correctly declared
- [x] All FKs placed on correct side of relationships
- [x] FK nullability matches ERD cardinality for every relationship
- [x] All candidate keys declared (`email`, `phone_number`, `facility_name`, composite location)
- [x] All 7 enums match business requirement values
- [x] Data types consistent between ERD (abstract) and schema (concrete)
- [x] All 12 business rules addressed (7 structural, 5 procedural)
- [x] Procedural rules correctly identified and catalogued
- [x] Historical record preservation enforced via RESTRICT semantics
- [x] All findings listed with recommended fixes

---

## 9. Action Required

No corrective action is required for the Step 3 logical schema. The two observations above are documented for awareness:

- The single-valued `role` design is a known simplification; revisit during implementation if multi-role support becomes a confirmed requirement.
- The ERD SPACE-FACILITY cardinality notation mismatch is a Step 2 cosmetic issue; it does not affect the logical schema's correctness.

The project may proceed to Step 5 (Database Definition / DDL).
