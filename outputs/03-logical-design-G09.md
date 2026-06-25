# Logical Database Design (Relational Schema)

---

## 1. Relational Schema (DBML)

*Copy the code below and paste it into [dbdiagram.io](https://dbdiagram.io/) to view the schema.*

```dbml
// Strictly NO Enum blocks declared here

// --- Tables ---

Table USER {
  user_id integer [pk, increment]
  full_name varchar(255) [not null]
  email varchar(255) [not null, unique]
  phone_number varchar(20) [not null, unique]
  role varchar(50) [not null, note: 'CHECK ([role] IN ('student', 'lecturer', 'teaching_assistant', 'facility_staff', 'department_administrator', 'facility_manager')) – Section 3']
  department varchar(255) [not null]
  account_status varchar(50) [not null, default: 'active', note: 'CHECK ([account_status] IN ('active', 'suspended', 'deactivated')) – Section 3']
}

Table SPACE {
  space_code varchar(50) [pk]
  space_name varchar(255) [not null]
  space_type varchar(50) [not null, note: 'CHECK ([space_type] IN ('auditorium', 'classroom', 'computer_lab', 'project_lab', 'meeting_room', 'student_workspace')) – Section 3']
  building varchar(255) [not null]
  floor integer [not null]
  room_number varchar(50) [not null]
  capacity integer [not null, note: 'CHECK ([capacity] > 0) – Section 3']
  current_status varchar(50) [not null, default: 'available', note: 'CHECK ([current_status] IN ('available', 'in_use', 'under_maintenance', 'temporarily_closed', 'retired')) – Section 3']
  usage_policy text

  Indexes {
    (building, floor, room_number) [unique, name: 'uq_space_location']
  }
}

Table FACILITY {
  facility_id integer [pk, increment]
  facility_name varchar(255) [not null, unique]
}

Table SPACE_FACILITY {
  space_code varchar(50) [not null]
  facility_id integer [not null]

  Indexes {
    (space_code, facility_id) [pk, name: 'pk_space_facility']
  }
}

Table BOOKING {
  booking_id integer [pk, increment]
  requester_id integer [not null]
  space_code varchar(50) [not null]
  requested_start_time datetime [not null]
  requested_end_time datetime [not null, note: 'CHECK ([requested_start_time] < [requested_end_time]) – Section 3']
  purpose varchar(50) [not null, note: 'CHECK ([purpose] IN ('lecture', 'examination', 'seminar', 'workshop', 'meeting', 'student_activity', 'administrative_event')) – Section 3']
  expected_participants integer [not null, note: 'CHECK ([expected_participants] > 0) – Section 3']
  booking_status varchar(50) [not null, default: 'pending', note: 'CHECK ([booking_status] IN ('pending', 'approved', 'rejected', 'cancelled', 'checked_in', 'completed', 'no_show')) – Section 3']
  decision_staff_id integer
  decision_time datetime
  decision_note text
  rejection_reason text
  check_in_staff_id integer
  actual_start_time datetime
  initial_condition text
  completion_staff_id integer
  actual_end_time datetime [note: 'CHECK ([actual_start_time] IS NULL OR [actual_end_time] IS NULL OR [actual_start_time] < [actual_end_time]) – Section 3']
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
  completion_time datetime [note: 'CHECK ([completion_time] IS NULL OR [start_time] < [completion_time]) – Section 3']
  status varchar(50) [not null, default: 'reported', note: 'CHECK ([status] IN ('reported', 'in_progress', 'completed')) – Section 3']
  result_note text
}

// --- Relationships ---
// BOOKING referencing SPACE
Ref: BOOKING.space_code > SPACE.space_code

// BOOKING referencing USER (multi-role: requester, approver/rejecter, check-in staff, completion staff)
Ref: BOOKING.requester_id > USER.user_id
Ref: BOOKING.decision_staff_id > USER.user_id
Ref: BOOKING.check_in_staff_id > USER.user_id
Ref: BOOKING.completion_staff_id > USER.user_id

// MAINTENANCE_RECORD referencing SPACE
Ref: MAINTENANCE_RECORD.space_code > SPACE.space_code

// MAINTENANCE_RECORD referencing USER (multi-role: reporter, assigned staff)
Ref: MAINTENANCE_RECORD.reporter_id > USER.user_id
Ref: MAINTENANCE_RECORD.assigned_staff_id > USER.user_id

// SPACE_FACILITY junction table (M:N resolution between SPACE and FACILITY)
Ref: SPACE_FACILITY.space_code > SPACE.space_code [delete: cascade]
Ref: SPACE_FACILITY.facility_id > FACILITY.facility_id [delete: cascade]
```

---

## 2. Constraints and Keys Summary

**Primary Keys & Candidate Keys:**
* **[USER]:** PK = `(user_id)`, CK = `(email)`, CK = `(phone_number)`
* **[SPACE]:** PK = `(space_code)`, CK = `(building, floor, room_number)`
* **[FACILITY]:** PK = `(facility_id)`, CK = `(facility_name)`
* **[SPACE_FACILITY]:** PK = `(space_code, facility_id)`
* **[BOOKING]:** PK = `(booking_id)`
* **[MAINTENANCE_RECORD]:** PK = `(maintenance_id)`

**Foreign Keys & Referential Integrity:**

| FK Column | Child Table | Parent Table | PK Column | Nullable | Delete Behavior |
|---|---|---|---|---|---|
| `requester_id` | BOOKING | USER | user_id | NO | RESTRICT |
| `decision_staff_id` | BOOKING | USER | user_id | YES | RESTRICT |
| `check_in_staff_id` | BOOKING | USER | user_id | YES | RESTRICT |
| `completion_staff_id` | BOOKING | USER | user_id | YES | RESTRICT |
| `space_code` | BOOKING | SPACE | space_code | NO | RESTRICT |
| `space_code` | MAINTENANCE_RECORD | SPACE | space_code | NO | RESTRICT |
| `reporter_id` | MAINTENANCE_RECORD | USER | user_id | NO | RESTRICT |
| `assigned_staff_id` | MAINTENANCE_RECORD | USER | user_id | YES | RESTRICT |
| `space_code` | SPACE_FACILITY | SPACE | space_code | NO | CASCADE |
| `facility_id` | SPACE_FACILITY | FACILITY | facility_id | NO | CASCADE |

**NOT NULL Constraints:**

| Table | NOT NULL Columns |
|---|---|
| USER | `user_id`, `full_name`, `email`, `phone_number`, `role`, `department`, `account_status` |
| SPACE | `space_code`, `space_name`, `space_type`, `building`, `floor`, `room_number`, `capacity`, `current_status` |
| FACILITY | `facility_id`, `facility_name` |
| SPACE_FACILITY | `space_code`, `facility_id` |
| BOOKING | `booking_id`, `requester_id`, `space_code`, `requested_start_time`, `requested_end_time`, `purpose`, `expected_participants`, `booking_status` |
| MAINTENANCE_RECORD | `maintenance_id`, `space_code`, `reporter_id`, `problem_description`, `start_time`, `status` |

---

## 3. Business Integrity Constraints (T-SQL Domain CHECKs)

*Note: As Microsoft SQL Server (T-SQL) does not natively support the `ENUM` data type, categorical domains and scalar boundaries are explicitly enforced via single-row table `CHECK` constraints.*

**USER Domain Checks:**
* **`chk_user_role_domain`**: `CHECK ([role] IN ('student', 'lecturer', 'teaching_assistant', 'facility_staff', 'department_administrator', 'facility_manager'))`
* **`chk_user_account_status_domain`**: `CHECK ([account_status] IN ('active', 'suspended', 'deactivated'))`

**SPACE Domain Checks:**
* **`chk_space_type_domain`**: `CHECK ([space_type] IN ('auditorium', 'classroom', 'computer_lab', 'project_lab', 'meeting_room', 'student_workspace'))`
* **`chk_space_capacity_boundary`**: `CHECK ([capacity] > 0)`
* **`chk_space_current_status_domain`**: `CHECK ([current_status] IN ('available', 'in_use', 'under_maintenance', 'temporarily_closed', 'retired'))`

**BOOKING Domain Checks:**
* **`chk_booking_purpose_domain`**: `CHECK ([purpose] IN ('lecture', 'examination', 'seminar', 'workshop', 'meeting', 'student_activity', 'administrative_event'))`
* **`chk_booking_expected_participants_boundary`**: `CHECK ([expected_participants] > 0)`
* **`chk_booking_status_domain`**: `CHECK ([booking_status] IN ('pending', 'approved', 'rejected', 'cancelled', 'checked_in', 'completed', 'no_show'))`
* **`chk_booking_time_order`**: `CHECK ([requested_start_time] < [requested_end_time])`
* **`chk_booking_actual_time_order`**: `CHECK ([actual_start_time] IS NULL OR [actual_end_time] IS NULL OR [actual_start_time] < [actual_end_time])`
* **`chk_booking_decision_fields`**: `CHECK ([booking_status] NOT IN ('approved', 'rejected') OR ([decision_staff_id] IS NOT NULL AND [decision_time] IS NOT NULL AND [decision_note] IS NOT NULL))`
* **`chk_booking_rejection_reason`**: `CHECK ([booking_status] <> 'rejected' OR [rejection_reason] IS NOT NULL)`
* **`chk_booking_checkin_fields`**: `CHECK ([booking_status] NOT IN ('checked_in', 'completed') OR ([check_in_staff_id] IS NOT NULL AND [actual_start_time] IS NOT NULL AND [initial_condition] IS NOT NULL))`
* **`chk_booking_completion_fields`**: `CHECK ([booking_status] <> 'completed' OR ([completion_staff_id] IS NOT NULL AND [actual_end_time] IS NOT NULL AND [final_condition] IS NOT NULL AND [usage_notes] IS NOT NULL))`

**MAINTENANCE_RECORD Domain Checks:**
* **`chk_maintenance_status_domain`**: `CHECK ([status] IN ('reported', 'in_progress', 'completed'))`
* **`chk_maintenance_time_order`**: `CHECK ([completion_time] IS NULL OR [start_time] < [completion_time])`

---

## 4. Architectural Assumptions

**Procedural Enforcement (Multi-row / Cross-table logic):**

1. **Overlapping Booking Prevention (Business Rule 3):** The same space must not have two approved bookings with overlapping time periods. This requires a cross-tuple temporal overlap check: for any new or updated booking with `booking_status = 'approved'`, the system must verify that no other approved booking for the same space satisfies `requested_start_time < @new_end AND requested_end_time > @new_start`. Enforcement strategy: Application middleware or an `INSTEAD OF INSERT/UPDATE` T-SQL trigger on the `BOOKING` table.

2. **Unavailable Space Booking Gate (Business Rule 2):** A space whose `current_status` is `'under_maintenance'`, `'temporarily_closed'`, or `'retired'` cannot be booked. This requires a cross-table read from `BOOKING` to `SPACE` to inspect the space's current status at the time of booking submission. Enforcement strategy: Application middleware or an `INSTEAD OF INSERT` T-SQL trigger on the `BOOKING` table that joins to `SPACE` and rejects the insert if the space is in an ineligible status.

3. **Role-Based Approval Authorization (Business Rule 9):** Only users whose `role` is `'facility_staff'` or `'facility_manager'` may approve or reject a booking. When `decision_staff_id` is set, the system must verify that the referenced user holds an eligible role. Enforcement strategy: Application middleware or an `AFTER INSERT/UPDATE` T-SQL trigger on the `BOOKING` table that reads the `USER` table's `role` column.

4. **Role-Based Check-In/Completion Authorization (Business Rule 10):** Only users whose `role` is `'facility_staff'` may perform check-in or session completion. When `check_in_staff_id` or `completion_staff_id` is set, the system must verify that the referenced user holds the `'facility_staff'` role (facility managers are implicitly excluded from this operation unless they also hold the `facility_staff` role). Enforcement strategy: Application middleware or an `AFTER INSERT/UPDATE` T-SQL trigger on the `BOOKING` table.

5. **Booking Status State Machine (Progressive Lifecycle):** A booking must transition through its lifecycle in the defined order: `pending` → `approved` (or `rejected`, `cancelled`) → `checked_in` (or `cancelled`, `no_show`) → `completed`. For example, a booking cannot jump from `pending` directly to `completed` without passing through `approved` and `checked_in`. Enforcement strategy: Application middleware or an `INSTEAD OF UPDATE` T-SQL trigger that validates the old-to-new status transition against a whitelist of permitted transitions.

**Design Assumptions:**

1. **Completion Staff Role Relation:** The ERD defines four distinct USER-to-BOOKING roles (`submits`, `decides_on`, `checks_in`, `completes`). The `completion_staff_id` FK column has been physically added to the `BOOKING` table to realize the `completes` relationship, consistent with the existing `requester_id`, `decision_staff_id`, and `check_in_staff_id` pattern. This aligns with the Step 1 assumption that different staff members may handle check-in and completion.

2. **Multi-Role User Accounts:** A single user may hold multiple roles simultaneously (e.g., a lecturer who also serves as facility manager). The `role` attribute is modeled as a single `varchar(50)` column. If the School later requires a user to possess multiple discrete role assignments, the schema should be refactored to introduce a separate `USER_ROLE` associative table. The current design is chosen for simplicity under the explicit Step 1 assumption that multi-role capability is not a hard requirement.

3. **Recurring Bookings Not Supported:** The schema handles only individual, discrete booking requests. Recurring or repeating bookings are outside the current scope, per the Step 1 assumptions.

4. **Facility Maintenance Scope:** Facilities are tracked only as attributes of spaces (via the `SPACE_FACILITY` junction table). Independent maintenance tracking of facility equipment (as distinct from space-level maintenance) is not supported, per the Step 1 assumption.

5. **Nullable Usage Policy:** The `usage_policy` column in `SPACE` is modeled as nullable `text`. While the business requirements mention storing a usage policy per space, no business rule enforces its mandatory presence at the time of space creation, and the policy text may be added or updated later.

6. **Maintenance Assignment Timing:** The `assigned_staff_id` FK is nullable to allow a maintenance record to be created (`reported`) before a staff member is designated to handle it. Assignment is optional at the time of record creation, consistent with the Step 1 cardinality analysis.

---

## 5. Design Notes

1. **M:N Resolution:** The conceptual many-to-many relationship `SPACE }o--o{ FACILITY : "contains"` from the ERD has been physically resolved into the associative junction table `SPACE_FACILITY`. This table carries no surrogate primary key; entity integrity is enforced by the named composite primary key `pk_space_facility` on `(space_code, facility_id)`. Both foreign key references carry `[delete: cascade]` because a junction tuple has no independent existential meaning outside of its parent entities.

2. **Multiple Role Mapping:** The `USER` entity participates in four distinct operational relationships with `BOOKING` (requester, approver/rejecter, check-in staff, completion staff) and two with `MAINTENANCE_RECORD` (reporter, assigned staff). All six foreign key columns follow the multi-role disambiguation rule: each column is named strictly after its functional role (e.g., `decision_staff_id`, `check_in_staff_id`, `completion_staff_id`) rather than the target table name `user_id`.

3. **T-SQL Compliance:** All categorical variables (`role`, `account_status`, `space_type`, `current_status`, `purpose`, `booking_status`, `maintenance status`) are modeled as `varchar(50)` with explicit `CHECK (column IN (...))` constraints declared in Section 3. No `Enum` blocks are used, aligning with Microsoft SQL Server DDL physical standards which do not support ANSI `ENUM` types.

4. **Referential Integrity:** All operational base entity relationships use logical `RESTRICT` (no explicit delete modifier in DBML, translating to T-SQL `ON DELETE NO ACTION`). This preserves institutional audit trails by preventing the accidental deletion of a `USER` or `SPACE` that is referenced by historical `BOOKING` or `MAINTENANCE_RECORD` tuples. Cascade deletion is applied strictly to the `SPACE_FACILITY` junction table, as its tuples are purely associative and must be removed when either parent is deleted.

5. **Candidate Key Selection:** The `USER` table identifies `(email)` and `(phone_number)` as single-attribute candidate keys marked `[unique]`, reflecting the real-world expectation that no two users share the same email address or phone number. The `SPACE` table identifies `(building, floor, room_number)` as a composite candidate key `[unique]`, reflecting the physical uniqueness of room locations within the campus. The `FACILITY` table identifies `(facility_name)` as a candidate key `[unique]` to prevent duplicate facility type entries.

6. **State-Contingent Nullability Enforcement:** Four intra-record `CHECK` constraints on the `BOOKING` table enforce that status-dependent required fields are populated when a booking reaches a specific lifecycle stage: decision fields when approved/rejected, rejection reason when rejected, check-in fields when checked in or completed, and completion fields when completed. These are implemented as single-row `CHECK` constraints using propositional logic (¬P ∨ Q) without cross-table references, making them valid and enforceable at the DDL level.

7. **Default Lifecycle States:** The `account_status` column defaults to `'active'` for new user accounts, `current_status` defaults to `'available'` for new spaces, `booking_status` defaults to `'pending'` for new booking requests, and maintenance `status` defaults to `'reported'` for new maintenance records. These initial state injections align with the natural starting point of each entity's operational lifecycle.
