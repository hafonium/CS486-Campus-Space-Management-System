# Conceptual Attribute Rules

## Goal
Ensure attributes represent real-world properties of entities without leaking logical database mechanics (like Foreign Keys) into the conceptual design.

## The Foreign Key Ban (CRITICAL)
In conceptual design, entities must NEVER contain attributes that reference other entities.
- **Rule:** Do not add Foreign Keys (FK) or reference IDs to an entity's attribute list.
- **Why:** The relationship line drawn between two entities is the conceptual connection. Adding a Foreign Key duplicates this connection and breaks conceptual abstraction.
- **Example Violation:** Putting `SpaceCode` inside the `MAINTENANCE_RECORD` entity. 
- **Example Fix:** Remove `SpaceCode` from `MAINTENANCE_RECORD`. Rely on the drawn line: `SPACE ||--o{ MAINTENANCE_RECORD`.

## Primary Keys (Unique Identifiers)
- Every strong entity must have one attribute designated as its unique identifier.
- Label this attribute with `PK` or `(PK)` to indicate it is the Primary Key.
- Avoid technical composite keys unless strictly defined by the business logic.

## Heuristics
Ask:
1. Does this attribute physically describe the entity itself?
2. Is this attribute actually just a pointer to another entity? (If yes, it's an FK—remove it).
3. Is the data type abstract enough? (Use `string` or `int`, not `VARCHAR(255)`).

## Self-check
Before finalizing attributes:
- Scan every entity for ID columns that belong to other tables. If you see `UserID` inside `Booking`, delete it.
- Ensure every entity has exactly one clearly marked `PK` attribute.
- Ensure no SQL-specific data types or constraints are used.