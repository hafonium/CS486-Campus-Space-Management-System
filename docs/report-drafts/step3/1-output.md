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
  phone_number varchar [not null]
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
  usage_policy text

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
  space_code varchar
  facility_id integer

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

* **USER:** PK = `user_id`, CK = `email`
* **SPACE:** PK = `space_code`, CK = `(building, floor, room_number)`
* **FACILITY:** PK = `facility_id`, CK = `facility_name`
* **BOOKING:** PK = `booking_id`
* **MAINTENANCE_RECORD:** PK = `maintenance_id`
* **SPACE_FACILITY:** PK = `(space_code, facility_id)`

### Foreign Keys & Referential Integrity

| Child Table | FK Column | Parent Table | PK Column | Notes |
|---|---|---|---|---|
| BOOKING | `requester_id` | USER | `user_id` | NOT NULL (mandatory) |
| BOOKING | `decision_staff_id` | USER | `user_id` | Nullable (optional) |
| BOOKING | `check_in_staff_id` | USER | `user_id` | Nullable (optional) |
| BOOKING | `completion_staff_id` | USER | `user_id` | Nullable (optional) |
| BOOKING | `space_code` | SPACE | `space_code` | NOT NULL (mandatory) |
| MAINTENANCE_RECORD | `reporter_id` | USER | `user_id` | NOT NULL (mandatory) |
| MAINTENANCE_RECORD | `assigned_staff_id` | USER | `user_id` | Nullable (optional) |
| MAINTENANCE_RECORD | `space_code` | SPACE | `space_code` | NOT NULL (mandatory) |
| SPACE_FACILITY | `space_code` | SPACE | `space_code` | ON DELETE CASCADE |
| SPACE_FACILITY | `facility_id` | FACILITY | `facility_id` | ON DELETE CASCADE |

### NOT NULL Constraints

| Table | NOT NULL Columns |
|---|---|
| USER | `user_id`, `full_name`, `email`, `phone_number`, `role`, `department`, `account_status` |
| SPACE | `space_code`, `space_name`, `space_type`, `building`, `floor`, `room_number`, `capacity`, `current_status` |
| FACILITY | `facility_id`, `facility_name` |
| BOOKING | `booking_id`, `requester_id`, `space_code`, `requested_start_time`, `requested_end_time`, `purpose`, `expected_participants`, `booking_status` |
| MAINTENANCE_RECORD | `maintenance_id`, `reporter_id`, `space_code`, `problem_description`, `start_time`, `status` |
| SPACE_FACILITY | `space_code`, `facility_id` |

---

## 3. Design Notes

1. **M:N Resolution:** The `SPACE ||--|{ FACILITY` many-to-many relationship from the conceptual ERD is resolved into the junction table `SPACE_FACILITY`. Its composite primary key `(space_code, facility_id)` guarantees that each facility type is linked to a space at most once. Both FK columns are members of the composite PK, ensuring entity integrity through the Indexes block. CASCADE delete is applied on both references so that removing a Space or Facility automatically cleans up its entries in the junction table.

2. **Multiple Role Mapping:** The USER entity participates in four distinct 1:N relationships with BOOKING — as *requester* (`submits`), *decision staff* (`decides_on`), *check-in staff* (`checks_in`), and *completion staff* (`completes`). Relational modeling cannot reuse a single `user_id` FK column to represent these separate roles without ambiguity. Therefore four separate foreign keys are placed in BOOKING: `requester_id` (NOT NULL — every booking must have a requester), `decision_staff_id` (nullable — bookings are not always decided), `check_in_staff_id` (nullable — check-in may not occur), and `completion_staff_id` (nullable — completion may not occur). Similarly, MAINTENANCE_RECORD holds `reporter_id` (NOT NULL) and `assigned_staff_id` (nullable) representing the two USER–MAINTENANCE_RECORD roles. All six FKs reference the same `USER.user_id` column but carry role-specific column names to avoid collisions.

3. **Domain Constraints (Enums & Defaults):** Seven DBML Enums restrict the value sets for roles, statuses, types, and purposes, replacing the conceptual ERD's plain `string` annotations. Logical defaults are applied to initial states: `account_status` defaults to `'active'`, `booking_status` defaults to `'pending'`, `maintenance_status` defaults to `'reported'`, and `current_status` defaults to `'available'`. The composite unique index `uq_space_location` on `(building, floor, room_number)` prevents duplicate room entries in the same physical position.

4. **Referential Integrity:** All foreign key relationships are declared with global `Ref:` statements at the end of the schema, adhering to strict DBML practice. Non-junction-table relationships (BOOKING and MAINTENANCE_RECORD) rely on the database engine's default RESTRICT/NO ACTION behavior — neither users nor spaces can be deleted while they have associated bookings or maintenance records, preserving the historical record-keeping required by the business. Only the junction table `SPACE_FACILITY` uses `[delete: cascade]`, since its rows are purely associative and have no independent existence.
