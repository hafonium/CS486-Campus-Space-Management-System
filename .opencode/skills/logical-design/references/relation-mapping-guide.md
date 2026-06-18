# Relation Mapping Guide

## Core Rule
Every strong entity in the Conceptual ERD must be converted into a distinct relational table.

## Rules for Mapping Entities
1. **Table Naming:** MUST be strictly UPPER_SNAKE_CASE (e.g., `USER`, `SPACE`, `BOOKING`) to maintain consistency with the Step 2 ERD.
2. **Attribute Naming:** MUST be strictly snake_case (e.g., `user_id`, `requested_start_time`).
3. **Primary Key (PK):** Identify the unique identifier from Step 2. Mark it explicitly as `PK` in the schema.
4. **No Foreign Keys Yet:** Do NOT look at relationships or add any foreign keys during this step. Foreign keys will be handled in Step 2.