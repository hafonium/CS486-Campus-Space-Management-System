# Foreign Key Placement Guide

## Core Rule
Foreign keys (FKs) are used to map 1:N and 1:1 relationships. They must never be used to map M:N relationships.

## Rules for 1:N Relationships
1. **Identify the "Many" side:** In a 1:N relationship, the entity on the "Many" (N) side receives the Foreign Key.
2. **Map the Key:** Take the Primary Key from the "One" (1) side and add it as a column to the "Many" side table.
3. **Nullability:** If participation is mandatory on the N side (`||--`), the FK must be `NOT NULL`. If optional (`|o--`), the FK must be nullable.

## Rules for Multi-Role Relationships (CRITICAL)
If two entities have multiple distinct relationships between them (e.g., `USER` and `BOOKING`), you cannot use the standard primary key name for all of them. Doing so causes column name collisions.
1. **Rename based on role:** Add a descriptive prefix to the foreign key column name indicating the role.
2. **Example mapping:**
   - Relationship "submits": FK = `requester_id`
   - Relationship "decides on": FK = `decision_staff_id`
   - Relationship "checks in": FK = `check_in_staff_id`
   - Relationship "completes": FK = `completion_staff_id`