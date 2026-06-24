# Reference: Associative Junction Table Rules (M:N Resolution)

## 1. Decomposition Mandate
Whenever a conceptual Many-to-Many (`M:N`) relationship exists between two entities, it must be decomposed into a 3NF Associative Junction Table.

## 2. Strict DDL Structural Rules
1. **No Surrogate Primary Keys:** A pure junction table must **never** declare a standalone auto-incrementing primary key (e.g., `junction_id integer [pk, increment]`). 
2. **Named Composite Primary Key:** Entity integrity must be enforced by combining the participating foreign keys into a composite primary key declared inside an explicit `Indexes` block carrying a formal DDL constraint name (`[pk, name: 'pk_[table_name]']`).
3. **Mandatory Participation:** All participating foreign key columns must be explicitly typed as `[not null]`.
4. **Cascading Obliteration:** Because the junction tuple possesses no independent existential meaning outside of its parent entities, all foreign key reference definitions must carry `[delete: cascade]`.

## 3. Benchmark Implementation Standard
```dbml
Table SPACE_FACILITY {
  space_code varchar(50) [not null]
  facility_id integer [not null]

  Indexes {
    (space_code, facility_id) [pk, name: 'pk_space_facility']
  }
}

// Global declarations at the bottom:
Ref: SPACE_FACILITY.space_code > SPACE.space_code [delete: cascade]
Ref: SPACE_FACILITY.facility_id > FACILITY.facility_id [delete: cascade]
```