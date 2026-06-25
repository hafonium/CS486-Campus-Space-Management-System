# Data Generation Guidelines

## Principles of Realistic Data
- **Avoid placeholder text:** Do not use `test`, `foo`, `bar`, or `user123`. Use realistic names, addresses, and descriptions that match the domain of the application.
- **Internal Consistency:** The relationships between tables should make logical sense. If a booking is created for a room, the booking dates should align logically, and the user assigned should be appropriate for the role.
- **Temporal Realism:** Include dates from the past, present, and future if applicable. Ensure chronological logic (e.g., end dates must occur after start dates).

## Defining Normal Operations
Normal operations represent the "happy path" of the application. The data should demonstrate:
- Standard users interacting with standard core entities.
- Typical transactions or state changes.
- Ensure the bulk of the sample data falls into this category so the system feels populated.

## Designing Exceptional Cases
Exceptional cases test the boundaries and complex constraints of the database. Incorporate rows that specifically target:
- **Constraint Boundaries (`CHECK` / `UNIQUE`):** Design data that tests the limits of `CHECK` constraints (e.g., minimum capacities, allowable status enums) and uniqueness. Insert data that successfully passes but is directly adjacent to the violation threshold.
- **Trigger/Procedural Rules:** If the schema contains triggers or complex business logic (e.g., preventing overlaps, enforcing status hierarchies), provide specialized data rows that test the exact boundaries the triggers look for without breaching them.
- **Boundary values:** Max lengths, large monetary figures, or edge-case temporal constraints (e.g., leap years, very short time intervals).
- **Complex relationships:** A parent entity with zero interactions vs. a parent entity with a maximum/extreme number of interactions.
- **Nullability and Defaults:** Provide rows that omit optional columns to test default behaviors or NULL handling gracefully.