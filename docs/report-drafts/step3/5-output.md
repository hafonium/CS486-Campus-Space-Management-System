# Logical Database Design - Phase 3.3: Candidate Keys & Domain CHECKs

**Objective:** Identify and tag all candidate keys; extract and document all business-level domain constraints as T-SQL CHECK expressions.

---

## 1. Relational Schema (DBML) - With Candidate Keys & Traceability Notes

*Copy the code below and paste it into [dbdiagram.io](https://dbdiagram.io/) to view the schema.*

```dbml
// Phase 3.3: Candidate Keys & Domain CHECKs
// Candidate key marks [unique] applied, inline traceability notes added
// Strictly NO Enum blocks declared here

// --- Tables ---

Table USER {
  user_id integer [pk, increment]
  full_name varchar(255) [not null]
  email varchar(255) [not null, unique]
  phone_number varchar(20) [not null, unique]
  role varchar(50) [not null, default: 'student', note: 'CHECK ([role] IN (...)) – Section 3']
  department varchar(255) [not null]
  account_status varchar(50) [not null, default: 'active', note: 'CHECK ([account_status] IN (...)) – Section 3']
}

Table SPACE {
  space_code varchar(50) [pk]
  space_name varchar(255) [not null]
  space_type varchar(50) [not null, note: 'CHECK ([space_type] IN (...)) – Section 3']
  building varchar(255) [not null]
  floor integer [not null]
  room_number varchar(50) [not null]
  capacity integer [not null, note: 'CHECK ([capacity] > 0) – Section 3']
  current_status varchar(50) [not null, default: 'available', note: 'CHECK ([current_status] IN (...)) – Section 3']
  usage_policy text [not null]

  Indexes {
    (building, floor, room_number) [unique, name: 'uq_space_location']
  }
}

Table FACILITY {
  facility_id integer [pk, increment]
  facility_name varchar(255) [not null, unique]
}

Table BOOKING {
  booking_id integer [pk, increment]
  requester_id integer [not null]
  space_code varchar(50) [not null]
  decision_staff_id integer
  check_in_staff_id integer
  completion_staff_id integer
  requested_start_time datetime [not null]
  requested_end_time datetime [not null, note: 'CHECK ([requested_start_time] < [requested_end_time]) – Section 3']
  purpose varchar(50) [not null, note: 'CHECK ([purpose] IN (...)) – Section 3']
  expected_participants integer [not null, note: 'CHECK ([expected_participants] > 0) – Section 3']
  booking_status varchar(50) [not null, default: 'pending', note: 'CHECK ([booking_status] IN (...)) – Section 3']
  decision_time datetime
  decision_note text
  rejection_reason text
  actual_start_time datetime
  initial_condition text
  actual_end_time datetime [note: 'CHECK ([actual_start_time] < [actual_end_time]) – Section 3']
  final_condition text
  usage_notes text
}

Table MAINTENANCE_RECORD {
  maintenance_id integer [pk, increment]
  space_code varchar(50) [not null]
  reporter_id integer [not null]
  assigned_staff_id integer
  problem_description text [not null]
  start_time datetime [not null]
  completion_time datetime [note: 'CHECK ([start_time] < [completion_time]) – Section 3']
  status varchar(50) [not null, default: 'reported', note: 'CHECK ([status] IN (...)) – Section 3']
  result_note text
}

Table SPACE_FACILITY {
  space_code varchar(50) [not null]
  facility_id integer [not null]

  Indexes {
    (space_code, facility_id) [pk, name: 'pk_space_facility']
  }
}

// --- Relationships ---

Ref: BOOKING.requester_id > USER.user_id
Ref: BOOKING.decision_staff_id > USER.user_id
Ref: BOOKING.check_in_staff_id > USER.user_id
Ref: BOOKING.completion_staff_id > USER.user_id
Ref: BOOKING.space_code > SPACE.space_code
Ref: MAINTENANCE_RECORD.reporter_id > USER.user_id
Ref: MAINTENANCE_RECORD.assigned_staff_id > USER.user_id
Ref: MAINTENANCE_RECORD.space_code > SPACE.space_code
Ref: SPACE_FACILITY.space_code > SPACE.space_code [delete: cascade]
Ref: SPACE_FACILITY.facility_id > FACILITY.facility_id [delete: cascade]
```

---

## 2. Constraints and Keys Summary

### 2.1 Primary Keys & Candidate Keys

**Candidate Key Inventory (Bi-directional Parity Check):**

* **USER:** PK = `user_id`, CK = `email`, CK = `phone_number`
* **SPACE:** PK = `space_code`, CK = `(building, floor, room_number)` named `uq_space_location`
* **FACILITY:** PK = `facility_id`, CK = `facility_name`
* **BOOKING:** PK = `booking_id` *(no additional candidate keys)*
* **MAINTENANCE_RECORD:** PK = `maintenance_id` *(no additional candidate keys)*
* **SPACE_FACILITY:** PK = `(space_code, facility_id)` named `pk_space_facility` *(no additional candidate keys)*

### 2.2 Foreign Keys & Referential Integrity

| FK Column | Child Table | Parent Table | PK Column | Nullable | Delete Behavior |
|---|---|---|---|---|---|
| `requester_id` | BOOKING | USER | `user_id` | NO | RESTRICT |
| `space_code` | BOOKING | SPACE | `space_code` | NO | RESTRICT |
| `decision_staff_id` | BOOKING | USER | `user_id` | YES | RESTRICT |
| `check_in_staff_id` | BOOKING | USER | `user_id` | YES | RESTRICT |
| `completion_staff_id` | BOOKING | USER | `user_id` | YES | RESTRICT |
| `space_code` | MAINTENANCE_RECORD | SPACE | `space_code` | NO | RESTRICT |
| `reporter_id` | MAINTENANCE_RECORD | USER | `user_id` | NO | RESTRICT |
| `assigned_staff_id` | MAINTENANCE_RECORD | USER | `user_id` | YES | RESTRICT |
| `space_code` | SPACE_FACILITY | SPACE | `space_code` | NO | CASCADE |
| `facility_id` | SPACE_FACILITY | FACILITY | `facility_id` | NO | CASCADE |

---

## 3. Business Integrity Constraints (T-SQL Domain CHECKs)

*Note: Microsoft SQL Server (T-SQL) does not natively support `ENUM` data types. All categorical domains and scalar boundaries are explicitly enforced via single-row table `CHECK` constraints. All multi-row / cross-table constraints are documented in Section 4 (Architectural Assumptions).*

### USER Domain Checks

* **`chk_user_role_domain`**: `CHECK ([role] IN ('student', 'lecturer', 'teaching_assistant', 'facility_staff', 'department_administrator', 'facility_manager'))`
  * Source: Business Requirement Analysis § 3 (Actors)
  * Enforcement: Single-row scalar domain check

* **`chk_user_account_status_domain`**: `CHECK ([account_status] IN ('active', 'suspended', 'deactivated'))`
  * Source: Business Requirement Analysis § 5 (Candidate Attributes - USER)
  * Enforcement: Single-row scalar domain check

### SPACE Domain Checks

* **`chk_space_type_domain`**: `CHECK ([space_type] IN ('auditorium', 'classroom', 'computer_lab', 'project_lab', 'meeting_room', 'student_workspace'))`
  * Source: Business Requirement Analysis § 5 (Candidate Attributes - SPACE)
  * Enforcement: Single-row scalar domain check

* **`chk_space_status_domain`**: `CHECK ([current_status] IN ('available', 'in_use', 'under_maintenance', 'temporarily_closed', 'retired'))`
  * Source: Business Requirement Analysis § 5 (Candidate Attributes - SPACE)
  * Enforcement: Single-row scalar domain check

* **`chk_space_capacity_boundary`**: `CHECK ([capacity] > 0)`
  * Source: Business Requirement Analysis § 5 (Candidate Attributes - SPACE: "capacity" represents physical room capacity)
  * Enforcement: Single-row scalar boundary check (Pattern 1)

### BOOKING Domain Checks

* **`chk_booking_purpose_domain`**: `CHECK ([purpose] IN ('lecture', 'examination', 'seminar', 'workshop', 'meeting', 'student_activity', 'administrative_event'))`
  * Source: Business Requirement Analysis § 5 (Candidate Attributes - BOOKING)
  * Enforcement: Single-row scalar domain check

* **`chk_booking_status_domain`**: `CHECK ([booking_status] IN ('pending', 'approved', 'rejected', 'cancelled', 'checked_in', 'completed', 'no_show'))`
  * Source: Business Requirement Analysis § 5 (Candidate Attributes - BOOKING)
  * Enforcement: Single-row scalar domain check

* **`chk_booking_participants_boundary`**: `CHECK ([expected_participants] > 0)`
  * Source: Business Requirement Analysis § 5 (Candidate Attributes - BOOKING: "expected number of participants")
  * Enforcement: Single-row scalar boundary check (Pattern 1)

* **`chk_booking_timeline_order`**: `CHECK ([requested_start_time] < [requested_end_time])`
  * Source: Business Requirement Analysis § 5 (Candidate Attributes - BOOKING: bookings span a time window)
  * Enforcement: Intra-record chronological progression (Pattern 2: $start < end$)

* **`chk_booking_decision_required_fields`**: `CHECK (NOT ([booking_status] IN ('approved', 'rejected')) OR ([decision_staff_id] IS NOT NULL AND [decision_time] IS NOT NULL AND [decision_note] IS NOT NULL))`
  * Source: Business Requirement Analysis § 2 (System Scope: "Approval and rejection workflow")
  * Enforcement: State-contingent nullability (Pattern 2: $status = 'approved|rejected' \implies fields \neq NULL$)

* **`chk_booking_rejection_reason`**: `CHECK ([booking_status] <> 'rejected' OR [rejection_reason] IS NOT NULL)`
  * Source: Business Requirement Analysis § 2 (System Scope: "Rejection workflow")
  * Enforcement: State-contingent nullability (Pattern 2)

* **`chk_booking_checkin_required_fields`**: `CHECK ([booking_status] <> 'checked_in' OR ([actual_start_time] IS NOT NULL AND [check_in_staff_id] IS NOT NULL AND [initial_condition] IS NOT NULL))`
  * Source: Business Requirement Analysis § 2 (System Scope: "Check-in and session completion recording")
  * Enforcement: State-contingent nullability (Pattern 2)

* **`chk_booking_completion_required_fields`**: `CHECK ([booking_status] <> 'completed' OR ([actual_end_time] IS NOT NULL AND [final_condition] IS NOT NULL))`
  * Source: Business Requirement Analysis § 2 (System Scope: "Check-in and session completion recording")
  * Enforcement: State-contingent nullability (Pattern 2)

* **`chk_booking_actual_timeline_order`**: `CHECK ([actual_start_time] IS NULL OR [actual_end_time] IS NULL OR [actual_start_time] < [actual_end_time])`
  * Source: Business Requirement Analysis § 2 (System Scope: "Historical record keeping for bookings")
  * Enforcement: Intra-record chronological progression with NULL-safe logic (Pattern 2)

### MAINTENANCE_RECORD Domain Checks

* **`chk_maintenance_status_domain`**: `CHECK ([status] IN ('reported', 'in_progress', 'completed'))`
  * Source: Business Requirement Analysis § 5 (Candidate Attributes - MAINTENANCE_RECORD)
  * Enforcement: Single-row scalar domain check

* **`chk_maintenance_timeline_order`**: `CHECK ([completion_time] IS NULL OR [start_time] < [completion_time])`
  * Source: Business Requirement Analysis § 2 (System Scope: "Maintenance issue reporting, assignment, and resolution tracking")
  * Enforcement: Intra-record chronological progression with NULL safety (Pattern 2)

* **`chk_maintenance_completion_required_fields`**: `CHECK ([status] <> 'completed' OR ([completion_time] IS NOT NULL AND [result_note] IS NOT NULL))`
  * Source: Business Requirement Analysis § 2 (System Scope: "Resolution tracking")
  * Enforcement: State-contingent nullability (Pattern 2: $status = 'completed' \implies fields \neq NULL$)

---

## Phase 3.3 Completion Checklist

**Candidate Key Verification (Gate 2):**
1. ✅ DBML → Doc check: Every column carrying `[unique]` is listed in Section 2.1
2. ✅ Doc → DBML check: Every CK listed in Section 2.1 carries `[unique]` in DBML
3. ✅ Composite CKs explicitly named (e.g., `uq_space_location`, `pk_space_facility`)

**Domain CHECK Coverage (Gate 5):**
4. ✅ Every categorical column in DBML has a corresponding `CHECK (... IN (...))` in Section 3
5. ✅ Every scalar boundary (`capacity > 0`) documented in Section 3

**Scalar Boundary Traceability (Gate 6):**
6. ✅ All scalar check columns in DBML carry inline `note:` attributes pointing to Section 3
7. ✅ All temporal progression checks include NULL-safe logic

---

## Notes on Phase 3.3

**Candidate Key Strategy:**
- Single-attribute CKs (email, phone_number, facility_name) are marked inline with `[unique]`
- Composite CKs are declared in explicit `Indexes` blocks with explicit naming conventions
- The triple `(building, floor, room_number)` ensures geo-spatial uniqueness within the space inventory
- No surrogate candidate keys are introduced; all CKs derive from natural business identifiers

**CHECK Constraint Design (Meta-Pattern Mapping):**
- **Pattern 1 (Single-Column):** Role domain, account status, space type, booking purpose, participant count, capacity
- **Pattern 2 (Intra-Record):** Timeline progression checks, state-contingent nullability for lifecycle fields

---

## Next Phase

**→ Proceed to Phase 3.4: Architectural Gate Verification**
- Identify all Pattern 3 (multi-row / cross-table) business rules
- Document procedural enforcement mechanisms (triggers, application logic, stored procedures)
- Create Section 4 (Architectural Assumptions) and Section 5 (Design Notes)
- Execute the 6-point internal validation gate (logical-review-checklist.md)
- Produce the final consolidated Logical Design deliverable: `3.4-output.md`
