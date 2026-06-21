# Reference: Associative Junction Table Rules (M:N Resolution)

## 1. Decomposition Mandate
Whenever a conceptual Many-to-Many (`M:N`) relationship exists between two entities, it must be decomposed into a 3NF Associative Junction Table.

## 2. Strict DDL Structural Rules
1. **No Surrogate Primary Keys:** A pure junction table must **never** declare a standalone auto-incrementing primary key (e.g., `junction_id integer [pk, increment]`). 
2. **Composite Primary Key:** Entity integrity must be enforced by combining the participating foreign keys into a composite primary key declared inside an explicit `Indexes` block.
3. **Mandatory Participation:** All participating foreign key columns must be explicitly typed as `[not null]`.
4. **Cascading Obliteration:** Because the junction tuple possesses no independent existential meaning outside of its parent entities, all foreign key reference definitions must carry `[delete: cascade]`.

## 3. Benchmark Implementation Standard
```dbml
Table ENTITY_A_ENTITY_B {
  entity_a_id integer [not null]
  entity_b_code varchar(50) [not null]

  Indexes {
    (entity_a_id, entity_b_code) [pk]
  }
}

// Global declarations at the bottom:
Ref: ENTITY_A_ENTITY_B.entity_a_id > ENTITY_A.id [delete: cascade]
Ref: ENTITY_A_ENTITY_B.entity_b_code > ENTITY_B.code [delete: cascade]
```