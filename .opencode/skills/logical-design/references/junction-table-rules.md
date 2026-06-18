# Junction Table (M:N) Resolution Guide

## Core Rule
Relational databases cannot natively implement Many-to-Many (M:N) relationships. Every M:N relationship (e.g., `SPACE }|--|{ FACILITY`) in the Conceptual ERD must be broken down into an associative entity (junction table).

## Rules for Creating Junction Tables
1. **Table Creation:** Create a brand new table.
2. **Table Naming:** Name the table by combining the names of the two related entities in UPPER_SNAKE_CASE (e.g., `SPACE_FACILITY`).
3. **Composite Primary Key:** The Primary Key of this new table must be a Composite Key consisting of the Primary Keys of the two parent entities.
4. **Foreign Key Constraints:** Both columns forming the composite primary key also act as Foreign Keys pointing back to their respective parent tables.