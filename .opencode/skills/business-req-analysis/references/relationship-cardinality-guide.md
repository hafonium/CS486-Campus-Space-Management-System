# Relationship and Cardinality Guide

## Goal
Explain relationships and participation in plain language.

## Relationship writing pattern
Use this structure:
- Entity A — verb phrase — Entity B

Examples:
- User submits Booking
- Booking reserves Space
- User reports MaintenanceRecord

The verb phrase should express a real business meaning, not a vague association.

## Cardinality in plain language
Instead of symbols, describe:
- whether one instance can be linked to many,
- whether each instance must link to exactly one,
- whether the relationship is optional or required.

Examples:
- One user may submit many bookings, but each booking is submitted by exactly one user.
- One space may appear in many bookings over time, but each booking is for one space.

## Participation
Participation answers whether the relationship is required or optional.

Examples:
- Mandatory on Booking side: every booking must have a requester.
- Optional on User side: some users may never submit a booking.

## Common patterns
### One-to-many
Pattern:
- One parent may have many child records.
- Each child belongs to one parent.

Example:
- One user may report many maintenance records; each maintenance record has one reporter.

### Many-to-many
Pattern:
- One instance on each side may connect to many on the other side.
- Usually later resolved through an associative entity.

Example:
- One space may have many facilities, and one facility type may appear in many spaces.

### One-to-one
Pattern:
- One instance matches at most one instance on the other side.
- Use only if the requirement clearly supports it.

## Justification
Whenever possible, justify the relationship using wording from the requirement.
Do not invent a relationship just because two nouns appear near each other.

## Self-check
Before finalizing:
- every relationship uses a meaningful verb phrase,
- participation is stated where possible,
- ambiguous cases are marked as assumptions,
- many-to-many relationships are identified clearly for later design.