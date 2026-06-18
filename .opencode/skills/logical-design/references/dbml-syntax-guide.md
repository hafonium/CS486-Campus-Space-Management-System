# DBML Syntax Guide

## Core Rule
The output relational schema must be formatted using valid DBML (Database Markup Language) syntax.

## Syntax Rules
1. **Table Definition:** `Table TABLE_NAME { column_name data_type [settings] }`
2. **Enums:** Must be defined independently using `Enum enum_name { val1 val2 }`.
3. **Composite Keys/Indexes:** Define inside the table using an `Indexes { (col1, col2) [unique] }` block.
4. **Strict Reference Placement (CRITICAL):** Do NOT use inline references (like `[ref: > Table.col]`) inside the table blocks. All Foreign Key relationships MUST be defined exclusively at the bottom of the document using the global `Ref:` syntax.
   - 1-to-Many (1:N): `Ref: CHILD_TABLE.fk_column > PARENT_TABLE.pk_column`
5. **Referential Actions (Cascade):** Apply `[delete: cascade]` to the `Ref:` definitions for junction tables (e.g., `SPACE_FACILITY`), because deleting a parent record should remove its M:N mapping.
   - Example: `Ref: SPACE_FACILITY.space_code > SPACE.space_code [delete: cascade]`