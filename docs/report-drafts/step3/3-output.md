# Logical Database Design - Phase 3.1: Static Base Normalization

**Objective:** Map all strong and weak entities from the Conceptual ERD into base relational tables with concrete T-SQL data types. No FK references, no candidate key marks, no domain constraints yet.

---

## 1. Relational Schema (DBML) - Phase 3.1 Tables Only

*Copy the code below and paste it into [dbdiagram.io](https://dbdiagram.io/) to view the schema.*

```dbml
// Phase 3.1: Static Base Normalization
// NO Foreign Key references, NO Candidate Key marks, NO CHECK constraints
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
  problem_description text [not null]
  start_time datetime [not null]
  completion_time datetime
  status varchar(50) [not null, default: 'reported']
  result_note text
}

Table SPACE_FACILITY {
  space_code varchar(50) [not null]
  facility_id integer [not null]
}
```

### Notes on Phase 3.1
- All strong entities (USER, SPACE, FACILITY, BOOKING, MAINTENANCE_RECORD) are mapped to tables.
- The associative entity `SPACE_FACILITY` is created as a placeholder for M:N resolution (junction table structure added in Phase 3.2).
- Categorical columns are modeled as `varchar(50)` (no Enum blocks).
- Default values are set for lifecycle column initial states.
- Mandatory attributes are marked `[not null]` where applicable.
- **FK columns are NOT yet injected** into BOOKING or MAINTENANCE_RECORD (Phase 3.2).
- **No candidate key marks** (`[unique]` tags) appear yet (Phase 3.3).
- **No CHECK constraints** documented yet (Phase 3.3).

---

## 2. Prerequisite Output Validation

**Boundary Check (Phase 3.1 Completion Gate):**
1. ✅ All strong and weak entities from ERD are represented as tables
2. ✅ No `Ref:` statements (FK declarations forbidden at this phase)
3. ✅ No `[unique]` tags (candidate keys deferred to Phase 3.3)
4. ✅ No `CHECK` constraints in DBML (domain CHECKs deferred to Phase 3.3)
5. ✅ Zero `Enum {}` blocks
6. ✅ All mandatory columns marked `[not null]`
7. ✅ Default values set for categorical lifecycle columns

---

## Next Phase

**→ Proceed to Phase 3.2: Referential Integrity Injection**
- Inject FK columns into BOOKING and MAINTENANCE_RECORD
- Complete the SPACE_FACILITY junction table with composite PK
- Declare all global `Ref:` statements in the relationships block
