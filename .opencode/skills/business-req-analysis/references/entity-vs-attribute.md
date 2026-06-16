# Entity vs Attribute Guide

## Goal
Help distinguish between:
- entities,
- attributes,
- roles,
- statuses,
- temporary values,
- associative or transactional entities.

## Entity
An entity is a business object that:
- has its own identity,
- has multiple attributes,
- participates in relationships,
- may be stored and reused across transactions.

Examples:
- User
- Space
- Booking
- MaintenanceRecord

## Attribute
An attribute is a property of an entity.
It describes the entity but does not usually stand alone.

Examples:
- user_name
- email
- start_time
- account_status

## Usually not entities
Do not model these as entities unless the requirement gives them independent meaning:
- labels on forms,
- temporary values,
- simple status values,
- descriptive phrases,
- formatting information.

## Role vs entity
A role describes how a user participates in a process.
A role is not automatically a separate entity.

Example:
- Student, Lecturer, and Facility Staff may all be roles of User.

## Associative entity
Use an associative entity when:
- two entities have a many-to-many relationship,
- the relationship may need its own attributes,
- the relationship must be stored directly.

Example:
- SpaceFacility between Space and Facility

## Transactional entity
Use a transactional entity when the requirement describes an event or business transaction over time.

Examples:
- Booking
- MaintenanceRecord

## Heuristics
Ask:
1. Does it have its own identity?
2. Does it have multiple meaningful attributes?
3. Does it participate in more than one relationship?
4. Will the organization want to track it historically?

If mostly yes, it is likely an entity.

## Self-check
Before finalizing:
- make sure every entity has a business reason to exist,
- ensure statuses are not treated as entities,
- ensure actor roles are not split into separate entities unless justified,
- ensure inferred entities are marked as assumptions if not explicit.