# Reference: Conceptual ERD to Relational Mapping Guide

## 1. Strong Entity Transformation
* Map every regular conceptual entity to an independent base table.
* Assign a single-column Primary Key (either a unique natural identifier like `account_code` or a surrogate `id integer [pk, increment]`).

## 2. Weak Entity Transformation
When mapping a Weak Entity (an entity whose existence depends on a Parent Entity):
1. Import the Parent Entity's Primary Key as a mandatory Foreign Key into the Weak Entity table.
2. Form a **Composite Primary Key** combining the imported Parent PK and the Weak Entity's partial discriminator:
   ```dbml
   Table WEAK_DEPENDENT {
     parent_id integer [not null]
     sub_sequence integer [not null]

     Indexes {
       (parent_id, sub_sequence) [pk]
     }
   }
   ```

## 3. Super-type / Sub-type (Inheritance Mapping)
To comply with T-SQL relational performance standards, resolve conceptual inheritance using the **Table-per-Subtype** architecture:
1. Generate a base table for the Super-type containing all shared attributes and the primary key.
2. Generate individual tables for each Sub-type.
3. The Primary Key of each Sub-type table must also act as a Foreign Key referencing the Super-type's PK:
   ```dbml
   Ref: SUB_TYPE.id > SUPER_TYPE.id [delete: cascade]
   ```

## 4. Normalization Audit (3NF Enforcement)
Eliminate all transitive dependencies. If an attribute depends on a non-key attribute (e.g., `department_head_name` stored inside an employee table), extract the non-key attribute into its own master lookup table (`DEPARTMENT`) and point to it via a standard Foreign Key.