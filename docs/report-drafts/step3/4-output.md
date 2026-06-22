# Logical Database Design - Phase 3.2: Referential Integrity Injection

**Objective:** Inject all Foreign Key columns into operational tables, complete the junction table structure, and declare global referential semantics.

---

## 1. Relational Schema (DBML) - With FK Injection

*Copy the code below and paste it into [dbdiagram.io](https://dbdiagram.io/) to view the schema.*

```dbml
// Phase 3.2: Referential Integrity Injection
// All FK columns injected, junction table completed, global Ref declarations
// Strictly NO Enum blocks declared here

// --- Tables ---

Table USER {
  user_id integer [pk, increment]
  full_name varchar(255) [not null]
  email varchar(255) [not null]
  phone_number varchar(20) [not null]
  role varchar(50) [not null, default: 'student']
  department varchar(255) [not null]
  account_status varchar(50) [not null, default: 'active']
}

Table SPACE {
  space_code varchar(50) [pk]
  space_name varchar(255) [not null]
  space_type varchar(50) [not null]
  building varchar(255) [not null]
  floor integer [not null]
  room_number varchar(50) [not null]
  capacity integer [not null]
  current_status varchar(50) [not null, default: 'available']
  usage_policy text [not null]
}

Table FACILITY {
  facility_id integer [pk, increment]
  facility_name varchar(255) [not null]
}

Table BOOKING {
  booking_id integer [pk, increment]
  requester_id integer [not null]
  space_code varchar(50) [not null]
  decision_staff_id integer
  check_in_staff_id integer
  completion_staff_id integer
  requested_start_time datetime [not null]
  requested_end_time datetime [not null]
  purpose varchar(50) [not null]
  expected_participants integer [not null]
  booking_status varchar(50) [not null, default: 'pending']
  decision_time datetime
  decision_note text
  rejection_reason text
  actual_start_time datetime
  initial_condition text
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
  status varchar(50) [not null, default: 'reported']
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

// USER–BOOKING: submits (1:N, mandatory on Booking side)
Ref: BOOKING.requester_id > USER.user_id

// USER–BOOKING: decides_on (1:N, optional both sides)
Ref: BOOKING.decision_staff_id > USER.user_id

// USER–BOOKING: checks_in (1:N, optional both sides)
Ref: BOOKING.check_in_staff_id > USER.user_id

// USER–BOOKING: completes (1:N, optional both sides)
Ref: BOOKING.completion_staff_id > USER.user_id

// SPACE–BOOKING: hosts (1:N, mandatory on Booking side)
Ref: BOOKING.space_code > SPACE.space_code

// USER–MAINTENANCE_RECORD: reports (1:N, mandatory on Maintenance side)
Ref: MAINTENANCE_RECORD.reporter_id > USER.user_id

// USER–MAINTENANCE_RECORD: assigned_to (1:N, optional both sides)
Ref: MAINTENANCE_RECORD.assigned_staff_id > USER.user_id

// SPACE–MAINTENANCE_RECORD: undergoes (1:N, mandatory on Maintenance side)
Ref: MAINTENANCE_RECORD.space_code > SPACE.space_code

// SPACE–FACILITY: contains (M:N resolved via junction, cascade on both sides)
Ref: SPACE_FACILITY.space_code > SPACE.space_code [delete: cascade]
Ref: SPACE_FACILITY.facility_id > FACILITY.facility_id [delete: cascade]
```

---

## 2. Constraints and Keys Summary

### 2.1 Primary Keys

* **USER:** PK = `user_id`
* **SPACE:** PK = `space_code`
* **FACILITY:** PK = `facility_id`
* **BOOKING:** PK = `booking_id`
* **MAINTENANCE_RECORD:** PK = `maintenance_id`
* **SPACE_FACILITY:** PK = `(space_code, facility_id)` named `pk_space_facility`

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

### 2.3 Mandatory Columns (NOT NULL)

| Table | NOT NULL Columns |
|---|---|
| USER | `user_id`, `full_name`, `email`, `phone_number`, `role`, `department`, `account_status` |
| SPACE | `space_code`, `space_name`, `space_type`, `building`, `floor`, `room_number`, `capacity`, `current_status`, `usage_policy` |
| FACILITY | `facility_id`, `facility_name` |
| BOOKING | `booking_id`, `requester_id`, `space_code`, `requested_start_time`, `requested_end_time`, `purpose`, `expected_participants`, `booking_status` |
| MAINTENANCE_RECORD | `maintenance_id`, `space_code`, `reporter_id`, `problem_description`, `start_time`, `status` |
| SPACE_FACILITY | `space_code`, `facility_id` |

---

## 3. Phase 3.2 Completion Checklist

**Referential Integrity Verification:**
1. ✅ All FK columns injected into BOOKING (4 multi-role references to USER + 1 to SPACE)
2. ✅ All FK columns injected into MAINTENANCE_RECORD (2 references to USER + 1 to SPACE)
3. ✅ SPACE_FACILITY junction table complete with composite PK `(space_code, facility_id)` named `pk_space_facility`
4. ✅ All `Ref:` declarations aggregated in global relationships block (10 total)
5. ✅ Standard operational tables (USER, SPACE, BOOKING, MAINTENANCE_RECORD) use RESTRICT delete behavior (no `[delete:` modifier)
6. ✅ Pure junction table (SPACE_FACILITY) uses CASCADE delete behavior
7. ✅ All FK columns that are mandatory are marked `[not null]`
8. ✅ Multi-role FK columns in BOOKING named distinctly: `requester_id`, `decision_staff_id`, `check_in_staff_id`, `completion_staff_id`
9. ✅ Section 2 Foreign Keys table precisely reflects all 10 `Ref:` declarations (bijective mapping)

---

## Notes on Phase 3.2

**Multi-Role FK Disambiguation:**
The BOOKING table references USER four times for distinct operational roles:
- `requester_id`: The user who submitted the booking request
- `decision_staff_id`: The staff member who approved or rejected the request
- `check_in_staff_id`: The staff member who performed check-in
- `completion_staff_id`: The staff member who completed the session

Each FK column is named after its **functional role**, not after the target table, ensuring semantic clarity.

**Junction Table Design:**
The `SPACE_FACILITY` table resolves the M:N relationship between SPACE and FACILITY:
- No surrogate key (no auto-incremented `id` column)
- Composite PK derived from both FK columns: `(space_code, facility_id)`
- Explicit naming of the PK constraint: `pk_space_facility`
- Both FK references carry `[delete: cascade]` because the junction tuple holds no independent business meaning outside its parent entities

---

## Next Phase

**→ Proceed to Phase 3.3: Candidate Keys & Domain CHECKs**
- Identify and tag all candidate keys with `[unique]` notation
- Extract and document all business-level domain constraints as T-SQL CHECKs
- Apply inline traceability notes mapping columns to Section 3 constraints
