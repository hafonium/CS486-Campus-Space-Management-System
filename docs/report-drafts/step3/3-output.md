# Logical Database Design (Relational Schema)

---

## 1. Relational Schema (DBML)

*Copy the code below and paste it into [dbdiagram.io](https://dbdiagram.io/) to view the schema.*

```dbml
// --- Enums ---

Enum user_role {
  student
  lecturer
  teaching_assistant
  facility_staff
  department_administrator
  facility_manager
}

Enum account_status {
  active
  suspended
  deactivated
}

Enum space_type {
  auditorium
  classroom
  computer_lab
  project_lab
  meeting_room
  student_workspace
}

Enum space_status {
  available
  in_use
  under_maintenance
  temporarily_closed
  retired
}

Enum booking_purpose {
  lecture
  examination
  seminar
  workshop
  meeting
  student_activity
  administrative_event
}

Enum booking_status {
  pending
  approved
  rejected
  cancelled
  checked_in
  completed
  no_show
}

Enum maintenance_status {
  reported
  in_progress
  completed
}

// --- Tables ---

Table USER {
  user_id integer [pk, increment]
  full_name varchar [not null]
  email varchar [not null, unique]
  phone_number varchar [not null, unique]
  role user_role [not null]
  department varchar [not null]
  account_status account_status [not null, default: 'active']
}

Table SPACE {
  space_code varchar [pk]
  space_name varchar [not null]
  space_type space_type [not null]
  building varchar [not null]
  floor integer [not null]
  room_number varchar [not null]
  capacity integer [not null]
  current_status space_status [not null, default: 'available']
  usage_policy text [not null]

  Indexes {
    (building, floor, room_number) [unique, name: 'uq_space_location']
  }
}

Table FACILITY {
  facility_id integer [pk, increment]
  facility_name varchar [not null, unique]
}

Table BOOKING {
  booking_id integer [pk, increment]
  requester_id integer [not null]
  space_code varchar [not null]
  requested_start_time datetime [not null]
  requested_end_time datetime [not null]
  purpose booking_purpose [not null]
  expected_participants integer [not null]
  booking_status booking_status [not null, default: 'pending']
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
  reporter_id integer [not null]
  space_code varchar [not null]
  assigned_staff_id integer
  problem_description text [not null]
  start_time datetime [not null]
  completion_time datetime
  status maintenance_status [not null, default: 'reported']
  result_note text
}

Table SPACE_FACILITY {
  space_code varchar [not null]
  facility_id integer [not null]

  Indexes {
    (space_code, facility_id) [pk]
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

### Primary Keys & Candidate Keys

* **USER:** PK = `user_id`, CK = `email`, `phone_number`
* **SPACE:** PK = `space_code`, CK = `(building, floor, room_number)`
* **FACILITY:** PK = `facility_id`, CK = `facility_name`
* **BOOKING:** PK = `booking_id`
* **MAINTENANCE_RECORD:** PK = `maintenance_id`
* **SPACE_FACILITY:** PK = `(space_code, facility_id)`

### Foreign Keys & Referential Integrity

| FK Column | Child Table | Parent Table | PK Column | Nullable | Delete Behavior |
|---|---|---|---|---|---|
| `requester_id` | BOOKING | USER | `user_id` | No (mandatory) | RESTRICT |
| `decision_staff_id` | BOOKING | USER | `user_id` | Yes (optional) | RESTRICT |
| `check_in_staff_id` | BOOKING | USER | `user_id` | Yes (optional) | RESTRICT |
| `completion_staff_id` | BOOKING | USER | `user_id` | Yes (optional) | RESTRICT |
| `space_code` | BOOKING | SPACE | `space_code` | No (mandatory) | RESTRICT |
| `reporter_id` | MAINTENANCE_RECORD | USER | `user_id` | No (mandatory) | RESTRICT |
| `assigned_staff_id` | MAINTENANCE_RECORD | USER | `user_id` | Yes (optional) | RESTRICT |
| `space_code` | MAINTENANCE_RECORD | SPACE | `space_code` | No (mandatory) | RESTRICT |
| `space_code` | SPACE_FACILITY | SPACE | `space_code` | No (PK member) | CASCADE |
| `facility_id` | SPACE_FACILITY | FACILITY | `facility_id` | No (PK member) | CASCADE |

### NOT NULL Constraints

| Table | NOT NULL Columns |
|---|---|
| USER | `user_id`, `full_name`, `email`, `phone_number`, `role`, `department`, `account_status` |
| SPACE | `space_code`, `space_name`, `space_type`, `building`, `floor`, `room_number`, `capacity`, `current_status`, `usage_policy` |
| FACILITY | `facility_id`, `facility_name` |
| BOOKING | `booking_id`, `requester_id`, `space_code`, `requested_start_time`, `requested_end_time`, `purpose`, `expected_participants`, `booking_status` |
| MAINTENANCE_RECORD | `maintenance_id`, `reporter_id`, `space_code`, `problem_description`, `start_time`, `status` |
| SPACE_FACILITY | `space_code`, `facility_id` |

---

## 3. Business Integrity Constraints

These constraints are expressible as single-row CHECK clauses in SQL but are not natively renderable in DBML syntax.

### SPACE

* **`capacity > 0`** — A bookable space must be able to accommodate at least one person. A capacity of zero or negative has no business meaning. (Derived from the concept of a usable physical room.)

### BOOKING

* **`requested_start_time < requested_end_time`** — Business Rule #4: the requested time period must be a non-negative interval. A booking whose end time is before or equal to its start time is invalid.
* **`expected_participants > 0`** — A booking must have at least one expected participant. Zero or negative values are meaningless for a space reservation.
* **`actual_end_time IS NULL OR actual_start_time < actual_end_time`** — If the session was completed, the actual start must precede the actual end time.
* **`booking_status = 'approved'`** ⟹ **(**`decision_staff_id IS NOT NULL AND decision_time IS NOT NULL AND decision_note IS NOT NULL`**)** — Business Rule #5 (approval path): an approved booking must record who approved it, when, and with what note.
* **`booking_status = 'rejected'`** ⟹ **(**`decision_staff_id IS NOT NULL AND decision_time IS NOT NULL AND decision_note IS NOT NULL AND rejection_reason IS NOT NULL`**)** — Business Rules #5 and #6 (rejection path): a rejected booking must record who rejected it, when, why (note), and the specific rejection reason.
* **`booking_status = 'checked_in'`** ⟹ **(**`check_in_staff_id IS NOT NULL AND actual_start_time IS NOT NULL AND initial_condition IS NOT NULL`**)** — Business Rule #7: a checked-in booking must record the staff member, actual start time, and initial room condition.
* **`booking_status = 'completed'`** ⟹ **(**`check_in_staff_id IS NOT NULL AND actual_start_time IS NOT NULL AND initial_condition IS NOT NULL AND completion_staff_id IS NOT NULL AND actual_end_time IS NOT NULL AND final_condition IS NOT NULL`**)** — Business Rules #7 and #8: a completed booking implies both check-in and completion fields are recorded.

### MAINTENANCE_RECORD

* **`completion_time IS NULL OR start_time < completion_time`** — When a maintenance record has been completed, the start time must logically precede the completion time.

---

## 4. Architectural Assumptions

### Procedural Enforcement

*These rules cannot be expressed as single-row CHECK constraints and must be enforced via application logic, stored procedures, or database triggers.*

1. **Overlapping Booking Prevention (Business Rule #3):** The same space must not have two bookings both in status `'approved'` (or `'checked_in'`) whose time intervals overlap. This requires comparing `requested_start_time` and `requested_end_time` across *multiple rows* in the BOOKING table. Enforcement strategy: application-level validation before updating `booking_status` to `'approved'`, or a `BEFORE INSERT/UPDATE` trigger that queries existing approved bookings for the same `space_code`.

2. **Space Availability Gate (Business Rule #2):** Before a booking may be transitioned to `'approved'` (or submitted), the target space's `current_status` must not be `'under_maintenance'`, `'temporarily_closed'`, or `'retired'`. This requires a cross-table check between BOOKING and SPACE. Enforcement strategy: application-level validation or a trigger that reads `SPACE.current_status`.

3. **Role-Based Authorization (Business Rules #9 and #10):**
   - Only users whose `role` is `'facility_staff'` or `'facility_manager'` may set `decision_staff_id` and perform approval/rejection.
   - Only users whose `role` is `'facility_staff'` may set `check_in_staff_id` (check-in) or `completion_staff_id` (completion).
   - These rules require reading the USER table at the point of the action. Enforcement strategy: application-level authorization middleware validated against the authenticated user's role.

4. **Booking Status State Machine:** The `booking_status` field must respect a valid lifecycle. Transitions such as `'completed' → 'pending'` or `'rejected' → 'checked_in'` are illegal. Acceptable paths include: `pending → approved → checked_in → completed`, `pending → rejected`, `pending → cancelled`, `pending → no_show`, etc. Enforcement strategy: application-level state machine validation on every status update.

5. **Historical Record Preservation (Business Rule #11):** Rows in BOOKING and MAINTENANCE_RECORD must never be physically deleted; they may only be logically superseded (e.g., by status changes). This is why the FK relationships from BOOKING and MAINTENANCE_RECORD to their parent tables use RESTRICT semantics (the default when no `[delete: cascade]` is specified). A parent USER or SPACE cannot be deleted if it has child records, preserving the audit trail.

### Design Assumptions

1. **Single-Valued User Role:** The USER table models `role` as a single-valued attribute. Although the business requirements analysis notes that "a single user may potentially hold multiple roles," the conceptual ERD treats `role` as a single string per user. This design assumes that at any given time a user account is assigned exactly one canonical role. If multi-role support is later required, `user_role` should be promoted to a separate associative entity forming an M:N relationship with USER.

2. **Email as Unique Candidate Key:** `email` is declared `[unique]` and serves as a candidate key. This assumes that no two users share an institutional email address, which is reasonable for a university system where accounts are tied to unique email identities.

3. **Phone Number as Unique Candidate Key:** `phone_number` is declared `[unique]` and serves as a second candidate key on the USER table. This assumes that each user account is associated with a distinct personal contact number, which is consistent with a university environment where users are issued individual mobile or extension numbers.

4. **Facility Name as Unique:** `facility_name` is declared `[unique]`. This assumes the list of facility types (projector, whiteboard, microphone, etc.) is a controlled, enumerated inventory and no two distinct facility records will carry the same name.

5. **Composite Physical Location as Unique:** The composite index `uq_space_location` on `(building, floor, room_number)` assumes that no two bookable spaces occupy the same physical coordinates within the school. This is a reasonable domain assumption for a building inventory.

6. **No Recurring Bookings:** The design assumes each booking is a single, one-time reservation. The business requirement does not mention recurring or repeating bookings, so no provision is made for patterns, series, or parent-child booking groupings.

7. **Facility Maintenance Tracked at Space Level Only:** Facilities themselves do not carry independent maintenance records. The `MAINTENANCE_RECORD` table links to `SPACE`, not to `FACILITY` or `SPACE_FACILITY`. This reflects the business requirement's framing of maintenance as a property of the physical room ("A space may have maintenance records"), not of individual pieces of equipment.

8. **Different Staff for Different Booking Stages:** The schema allows `requester_id`, `decision_staff_id`, `check_in_staff_id`, and `completion_staff_id` to reference four different users. This reflects the assumption that the person who requests a booking is not necessarily the person who approves, checks in, or completes it. All combinations are valid.

9. **`usage_policy` is Mandatory but Informational:** The `usage_policy` text field on SPACE is marked `[not null]` to ensure every space has a documented usage policy, even if it is a minimal default statement. However, the content of this field is not parsed or enforced by the database engine. Policy enforcement (e.g., restricting certain space types to certain user roles) is a procedural concern outside the schema.

10. **Purpose Values are Exhaustive:** The seven values in Enum `booking_purpose` (lecture, examination, seminar, workshop, meeting, student_activity, administrative_event) are assumed to cover all categories of booking the system needs to support.

11. **Maintenance Status Lifecycle:** The three values in Enum `maintenance_status` (`reported`, `in_progress`, `completed`) are assumed to form a simple forward-only lifecycle. A maintenance record cannot regress from `completed` back to `reported`.

---

## 5. Design Notes

1. **M:N Resolution:** The conceptual many-to-many relationship `SPACE }|--|{ FACILITY : "contains"` is resolved into the junction table `SPACE_FACILITY`. Its composite primary key `(space_code, facility_id)` guarantees that a given facility type cannot be linked to the same space more than once. Both FK columns also serve as PK members, ensuring entity integrity without a synthetic surrogate key. CASCADE delete is applied on both references so that removing a Space or Facility automatically drops the corresponding entries from the junction table — appropriate because these rows have no independent existence.

2. **Multiple Role Mapping (USER ↔ BOOKING):** The USER entity participates in four distinct 1:N relationships with BOOKING, each representing a different business role: *requester* (submits), *decision staff* (decides_on), *check-in staff* (checks_in), and *completion staff* (completes). Relational modeling cannot reuse a single `user_id` FK column to represent all four roles without ambiguity. Therefore BOOKING carries four separately named foreign keys — `requester_id` (NOT NULL — every booking must have a submitter), `decision_staff_id` (nullable — bookings may remain undecided), `check_in_staff_id` (nullable), and `completion_staff_id` (nullable) — all referencing `USER.user_id`. Similarly, `MAINTENANCE_RECORD` carries `reporter_id` (NOT NULL) and `assigned_staff_id` (nullable) for its two USER relationships.

3. **Domain Constraints (Enums & Defaults):** Seven DBML Enums replace the conceptual ERD's plain `string` annotations with strictly constrained value sets for `user_role`, `account_status`, `space_type`, `space_status`, `booking_purpose`, `booking_status`, and `maintenance_status`. Logical defaults are applied to fields that have a natural initial state: `account_status` defaults to `'active'` (a newly registered account is active until suspended or deactivated), `current_status` defaults to `'available'` (a newly catalogued space is assumed ready for booking), `booking_status` defaults to `'pending'` (a newly submitted request awaits decision), and `status` on `MAINTENANCE_RECORD` defaults to `'reported'` (a new maintenance issue begins in the reported state).

4. **Referential Integrity:** All foreign key relationships are declared with global `Ref:` statements at the end of the schema, adhering to strict DBML conventions that forbid inline reference annotations. Non-junction-table relationships (BOOKING and MAINTENANCE_RECORD) rely on the default RESTRICT / NO ACTION behavior — parent rows in USER and SPACE cannot be deleted as long as referenced child rows exist, preserving the historical record-keeping mandated by Business Rule #11. Only the junction table `SPACE_FACILITY` uses `[delete: cascade]`, since its rows are purely associative and have no independent identity. Optional FKs (`decision_staff_id`, `check_in_staff_id`, `completion_staff_id`, `assigned_staff_id`) are left nullable in the schema but are additionally constrained by the conditional CHECK rules documented in Section 3 above.
