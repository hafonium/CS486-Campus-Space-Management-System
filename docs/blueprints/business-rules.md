# System Business Rules & Constraints

### Relationship Cardinalities
* **Users to Bookings (1:N):** A user can have many bookings, but a booking belongs to exactly one user.
* **Spaces to Bookings (1:N):** A space can have many bookings over time.

### Strict Database Constraints (CHECK Rules)
1.  **Temporal Logic:** A booking's `end_time` MUST be strictly greater than its `start_time`.
2.  **Capacity Limit:** A space's `capacity` MUST be greater than 0.
3.  **No Time Travel:** A booking's `start_time` cannot be in the past at the time of insertion.

### Application Logic (Handled via Triggers or Advanced Constraints)
* **No Overlaps:** Two active bookings for the same `space_id` cannot have overlapping time windows.
* **Maintenance Block:** A booking cannot be created if the target space's `current_status` is 'UNDER_MAINTENANCE'.