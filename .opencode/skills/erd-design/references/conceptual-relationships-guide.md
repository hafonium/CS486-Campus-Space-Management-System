# Conceptual Relationships Guide

## Goal
Accurately map the business interactions between entities using abstract conceptual links rather than relational database tables.

## Allowing Many-to-Many (M:N)
Conceptual models natively support M:N relationships because they map reality, not databases.
- **Rule:** NEVER resolve M:N relationships into "Junction Tables", "Mapping Tables", or "Associative Entities" unless the requirement explicitly treats that interaction as a distinct, tracked document.
- **Example:** `SPACE` contains many `FACILITIES`, and a `FACILITY` (like a projector) exists in many `SPACES`. Model this directly: `SPACE [M:N] FACILITY`. 

## Verb Phrases
- Every relationship must have a descriptive verb phrase representing the business process.
- Avoid generic terms like "has" or "is related to" if a stronger verb like "submits", "approves", or "undergoes" is available.

## Cardinality Mapping
Translate business rules into strict cardinalities:
- **1:1** (One-to-One): A department has one head manager.
- **1:N** (One-to-Many): A user submits many bookings.
- **M:N** (Many-to-Many): A space contains many facility types, and a facility type exists in many spaces.

## Heuristics
Ask:
1. Can an instance of Entity A interact with multiple instances of Entity B?
2. Can an instance of Entity B interact with multiple instances of Entity A?
3. If both are yes, it is an M:N relationship. Do not create an intermediate table to solve it.

## Self-check
Before finalizing relationships:
- Did I artificially create a "Mapping" entity just to connect two other entities? If yes, delete it and draw an M:N line directly between the main entities.
- Does every relationship line have a descriptive verb phrase in quotes?
- Is the cardinality logically supported by the Step 1 business rules?