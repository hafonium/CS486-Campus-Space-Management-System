# Business Rules Checklist

## Goal
Extract precise, testable business rules from the requirement.

## Common rule categories
Look for rules about:
- uniqueness,
- identity,
- status transitions,
- approvals,
- role restrictions,
- time constraints,
- overlap prevention,
- maintenance blocking,
- history retention,
- validation limits.

## Rule-writing pattern
Write each rule as a short numbered statement.
A good rule should be:
- specific,
- testable,
- relevant to design,
- written in business language.

Good example:
1. A space under maintenance cannot be booked.

Weak example:
1. Spaces and maintenance are related.

## Signals in the requirement
Look for phrases like:
- must
- cannot
- should
- only
- required
- may not
- prevent
- record
- store

These often indicate business rules.

## Typical database-analysis rules
Examples:
- Each user must have a valid university account.
- A booking must record requested start and end times.
- Two approved bookings for the same space must not overlap.
- A rejected booking must store a rejection reason.

## Caution
Do not create rules unless:
- they are explicitly stated, or
- they are a very reasonable inference needed for later design.

If inferred, label them as assumptions.

## Self-check
Before finalizing:
- rules cover all major constraints,
- no key policy is missing,
- rules are not just restated relationships,
- inferred rules are labeled clearly.