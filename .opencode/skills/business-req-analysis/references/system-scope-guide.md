# System Scope Guide

## Goal
Identify what business functions are inside the system’s scope and what outputs or operational capabilities the system is expected to support.

## What to look for
When reading the requirement, identify:
- core operational processes,
- stored business objects,
- approval or review processes,
- tracking and reporting needs,
- status transitions,
- exclusions or implied out-of-scope items.

## Typical scope categories
Use these categories when helpful:
- user/account management,
- resource or inventory management,
- request or transaction management,
- approval workflows,
- monitoring and reporting,
- history and audit trails,
- maintenance or exception handling.

## Scope-writing pattern
Write scope as a short bullet list of capabilities, not as implementation details.

Good example:
- Booking request submission and status tracking
- Approval and rejection workflow
- Historical tracking of booking and maintenance activity

Weak example:
- Table for bookings
- SQL queries for reports
- Composite key design

## Warning signs
A scope section is too weak if it:
- only repeats the system title,
- lists entities instead of business functions,
- includes schema or implementation language,
- ignores reporting or history requirements.

## Self-check
Before finalizing, confirm:
- every major process from the requirement appears in scope,
- reporting needs are covered if mentioned,
- history/audit retention is covered if mentioned,
- no database-implementation terms appear.