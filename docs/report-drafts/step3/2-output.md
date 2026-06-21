# Logical Database Design (Step 3)

---

### 1. Relational Schema (DBML)

*Copy the code below and paste it into [dbdiagram.io](https://dbdiagram.io/) to view the schema.*

```dbml
// Strictly NO Enum blocks declared here

// --- Tables ---

Table USER {
  user_id integer [pk, increment]
  full_name varchar(255) [not null]
  email varchar(255) [not null, unique]
  phone_number varchar(20) [not null, unique]
  role varchar(50) [not null, default: 'student', note: 'Restricted via Section 3 CHECK']
  department varchar(255) [not null]
  account_status varchar(50) [not null, default: 'active', note: 'Restricted via Section 3 CHECK']
}

Table SPACE {
  space_code varchar(50) [pk]
  space_name varchar(255) [not null]
  space_type varchar(50) [not null, note: 'Restricted via Section 3 CHECK']
  building varchar(255) [not null]
  floor integer [not null]
  room_number varchar(50) [not null]
  capacity integer [not null]
  current_status varchar(50) [not null, default: 'available', note: 'Restricted via Section 3 CHECK']
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
  requested_start_time datetime [not null]
  requested_end_time datetime [not null]
  purpose varchar(50) [not null, note: 'Restricted via Section 3 CHECK']
  expected_participants integer [not null]
  booking_status varchar(50) [not null, default: 'pending', note: 'Restricted via Section 3 CHECK']
  decision_staff_id integer
  decision_time datetime
  decision_note text
  rejection_reason text
  check_in_staff_id integer
  actual_start_time datetime
  initial_condition text
  completion_staff_id integer
  actual_end_time datetime
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
  completion_time datetime
  status varchar(50) [not null, default: 'reported', note: 'Restricted via Section 3 CHECK']
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

// USER–BOOKING: submits (1:N, mandatory on Booking)
Ref: BOOKING.requester_id > USER.user_id

// USER–BOOKING: decides_on (1:N, optional both sides)
Ref: BOOKING.decision_staff_id > USER.user_id

// USER–BOOKING: checks_in (1:N, optional both sides)
Ref: BOOKING.check_in_staff_id > USER.user_id

// USER–BOOKING: completes (1:N, optional both sides)
Ref: BOOKING.completion_staff_id > USER.user_id

// SPACE–BOOKING: hosts (1:N, mandatory on Booking)
Ref: BOOKING.space_code > SPACE.space_code

// USER–MAINTENANCE_RECORD: reports (1:N, mandatory on Maintenance)
Ref: MAINTENANCE_RECORD.reporter_id > USER.user_id

// USER–MAINTENANCE_RECORD: assigned_to (1:N, optional both sides)
Ref: MAINTENANCE_RECORD.assigned_staff_id > USER.user_id

// SPACE–MAINTENANCE_RECORD: undergoes (1:N, mandatory on Maintenance)
Ref: MAINTENANCE_RECORD.space_code > SPACE.space_code

// SPACE–FACILITY: contains (M:N resolved via junction, cascade on both sides)
Ref: SPACE_FACILITY.space_code > SPACE.space_code [delete: cascade]
Ref: SPACE_FACILITY.facility_id > FACILITY.facility_id [delete: cascade]
```

### 2. Constraints and Keys Summary

**Primary Keys & Candidate Keys:**

* **USER:** PK = `user_id`, CK = `email`, CK = `phone_number`
* **SPACE:** PK = `space_code`, CK = `(building, floor, room_number)`
* **FACILITY:** PK = `facility_id`, CK = `facility_name`
* **BOOKING:** PK = `booking_id`
* **MAINTENANCE_RECORD:** PK = `maintenance_id`
* **SPACE_FACILITY:** PK = `(space_code, facility_id)`

**Foreign Keys & Referential Integrity:**

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

**NOT NULL Constraints:**

| Table | NOT NULL Columns |
|---|---|
| USER | `user_id`, `full_name`, `email`, `phone_number`, `role`, `department`, `account_status` |
| SPACE | `space_code`, `space_name`, `space_type`, `building`, `floor`, `room_number`, `capacity`, `current_status`, `usage_policy` |
| FACILITY | `facility_id`, `facility_name` |
| BOOKING | `booking_id`, `requester_id`, `space_code`, `requested_start_time`, `requested_end_time`, `purpose`, `expected_participants`, `booking_status` |
| MAINTENANCE_RECORD | `maintenance_id`, `space_code`, `reporter_id`, `problem_description`, `start_time`, `status` |
| SPACE_FACILITY | `space_code`, `facility_id` |

### 3. Business Integrity Constraints (T-SQL Domain CHECKs)

*Note: As Microsoft SQL Server (T-SQL) does not natively support the `ENUM` data type, categorical domains and scalar boundaries are explicitly enforced via single-row table `CHECK` constraints.*

**USER Domain Checks:**

* **`chk_user_role_domain`**: `CHECK ([role] IN ('student', 'lecturer', 'teaching_assistant', 'facility_staff', 'department_administrator', 'facility_manager'))`
* **`chk_user_account_status_domain`**: `CHECK ([account_status] IN ('active', 'suspended', 'deactivated'))`

**SPACE Domain Checks:**

* **`chk_space_type_domain`**: `CHECK ([space_type] IN ('auditorium', 'classroom', 'computer_lab', 'project_lab', 'meeting_room', 'student_workspace'))`
* **`chk_space_status_domain`**: `CHECK ([current_status] IN ('available', 'in_use', 'under_maintenance', 'temporarily_closed', 'retired'))`
* **`chk_space_capacity_boundary`**: `CHECK ([capacity] > 0)`

**BOOKING Domain Checks:**

* **`chk_booking_purpose_domain`**: `CHECK ([purpose] IN ('lecture', 'examination', 'seminar', 'workshop', 'meeting', 'student_activity', 'administrative_event'))`
* **`chk_booking_status_domain`**: `CHECK ([booking_status] IN ('pending', 'approved', 'rejected', 'cancelled', 'checked_in', 'completed', 'no_show'))`
* **`chk_booking_participants_boundary`**: `CHECK ([expected_participants] > 0)`
* **`chk_booking_timeline_order`**: `CHECK ([requested_start_time] < [requested_end_time])`
* **`chk_booking_decision_required_fields`**: `CHECK (NOT ([booking_status] IN ('approved', 'rejected')) OR ([decision_staff_id] IS NOT NULL AND [decision_time] IS NOT NULL AND [decision_note] IS NOT NULL))`
* **`chk_booking_rejection_reason`**: `CHECK ([booking_status] <> 'rejected' OR [rejection_reason] IS NOT NULL)`
* **`chk_booking_checkin_required_fields`**: `CHECK ([booking_status] <> 'checked_in' OR ([actual_start_time] IS NOT NULL AND [check_in_staff_id] IS NOT NULL AND [initial_condition] IS NOT NULL))`
* **`chk_booking_completion_required_fields`**: `CHECK ([booking_status] <> 'completed' OR ([actual_end_time] IS NOT NULL AND [final_condition] IS NOT NULL))`
* **`chk_booking_actual_timeline_order`**: `CHECK ([actual_start_time] IS NULL OR [actual_end_time] IS NULL OR [actual_start_time] < [actual_end_time])`

**MAINTENANCE_RECORD Domain Checks:**

* **`chk_maintenance_status_domain`**: `CHECK ([status] IN ('reported', 'in_progress', 'completed'))`
* **`chk_maintenance_timeline_order`**: `CHECK ([completion_time] IS NULL OR [start_time] < [completion_time])`
* **`chk_maintenance_completion_required_fields`**: `CHECK ([status] <> 'completed' OR ([completion_time] IS NOT NULL AND [result_note] IS NOT NULL))`

### 4. Architectural Assumptions

**Procedural Enforcement (Multi-row / Cross-table logic):**

1. **Overlapping Booking Prevention (Business Rule 3):** The same space must not have two approved bookings whose time periods overlap. This cannot be enforced via a single-row CHECK constraint because it requires scanning *all other rows* in the BOOKING table for the same space. Enforcement strategy: Must be enforced via an `INSTEAD OF INSERT/UPDATE` T-SQL trigger or application middleware that checks: `IF EXISTS (SELECT 1 FROM BOOKING WHERE space_code = @space_code AND booking_status = 'approved' AND booking_id <> @booking_id AND requested_start_time < @new_end AND requested_end_time > @new_start) RAISERROR(...)`.

2. **Space Availability Gate (Business Rule 2):** A space whose `current_status` is `'under_maintenance'`, `'temporarily_closed'`, or `'retired'` cannot be booked. While this could be partially enforced by a CHECK on BOOKING referencing SPACE, standard T-SQL CHECK constraints cannot reference other tables. Enforcement strategy: Application-level validation on booking submission or a pre-insert trigger that joins BOOKING with SPACE to verify `SPACE.current_status NOT IN ('under_maintenance', 'temporarily_closed', 'retired')`.

3. **Role-Based Authorization Gates (Business Rules 9 & 10):** Only facility staff or facility managers may approve/reject a booking (BR 9). Only facility staff may perform check-in and session completion (BR 10). These constraints require knowledge of the acting user's role at the moment of action, which is session/application state, not database state. Enforcement strategy: Application middleware must validate user role before issuing UPDATE statements to BOOKING for these specific operations.

4. **Booking State Machine Lifecycle:** The booking_status must transition through a valid state sequence: `pending` → (`approved` | `rejected` | `cancelled`); `approved` → (`checked_in` | `cancelled` | `no_show`); `checked_in` → (`completed` | `no_show`). Random jumps (e.g., `pending` → `completed`, `rejected` → `checked_in`) must be blocked. Enforcement strategy: Application middleware must validate the current status against the requested new status using a predefined state transition map before issuing UPDATE statements.

5. **Maintenance State Machine Lifecycle:** The maintenance status must follow: `reported` → `in_progress` → `completed`. Direct transitions from `reported` to `completed` are prohibited. Enforcement strategy: Application middleware must validate the current status against the requested new status using a predefined transition map.

**Design Assumptions:**

1. **Single Role per Session Model:** While a user may hold multiple roles in the system (e.g., a lecturer who is also a department administrator), the current design assumes a single active role context per user session. Multi-role switching logic is deferred to the application layer and does not impact the relational schema.

2. **No Recurring Bookings:** The system handles only individual, non-repeating booking requests. Recurring or repeating bookings are out of scope.

3. **Composite Location as Candidate Key for SPACE:** The tuple `(building, floor, room_number)` is declared as a composite unique key, ensuring that no two spaces occupy the same physical room within a building. This complements the surrogate PK `space_code`.

4. **Space Code as Natural Identifier:** The `space_code` in SPACE serves as the primary natural identifier and is used as the FK in BOOKING, MAINTENANCE_RECORD, and SPACE_FACILITY. It is not an auto-increment surrogate; its format (e.g., "CS-101") is managed by application logic or manual entry.

5. **Facility Names are Globally Unique:** Each facility type (e.g., "Projector", "Whiteboard") is uniquely named, enforced via `[unique]` on `facility_name`.

### 5. Design Notes

1. **M:N Resolution:** The `SPACE }|--|{ FACILITY : "contains"` relationship from the conceptual ERD is resolved via the pure associative junction table `SPACE_FACILITY`. It carries a composite PK `(space_code, facility_id)` with no surrogate key, in compliance with 3NF junction-table rules. Both FK references use `[delete: cascade]` because the junction tuple holds no independent existential meaning outside its parent entities.

2. **Multiple Role Mapping:** The BOOKING table references USER four times for distinct operational roles: `requester_id` (the submitter), `decision_staff_id` (the approver/rejecter), `check_in_staff_id` (the check-in staff member), and `completion_staff_id` (the completion staff member). Each FK column is named after its functional role — not after the target table — following the multi-role disambiguation rule. Similarly, MAINTENANCE_RECORD references USER twice: `reporter_id` and `assigned_staff_id`.

3. **T-SQL Compliance:** All categorical variables (role, account_status, space_type, current_status, purpose, booking_status, maintenance status) are modeled as `varchar(50)` with explicit `CHECK (... IN (...))` constraints documented in Section 3. Zero `Enum {}` blocks appear anywhere in the DBML script, aligning strictly with Microsoft SQL Server DDL physical standards.

4. **Referential Integrity:** Standard operational base tables (USER, SPACE, FACILITY, BOOKING, MAINTENANCE_RECORD) default to `RESTRICT` (via omission of delete modifiers in DBML, interpreted as `ON DELETE NO ACTION` in T-SQL). This preserves institutional audit trails and prevents orphaned historical records. The pure associative junction table `SPACE_FACILITY` uses `[delete: cascade]` on both FK references because its tuples possess no independent business meaning outside their parent SPACE and FACILITY rows.

5. **Supporting Lookup Tables Not Needed:** The categorical domains — `role`, `account_status`, `space_type`, `current_status`, `purpose`, `booking_status`, and `maintenance_status` — are enforced via `CHECK` constraints rather than separate lookup tables. This decision is consistent with the T-SQL `CHECK`-based enumeration pattern mandated by the skill and avoids unnecessary join complexity for simple code lists that do not carry additional descriptive attributes.
