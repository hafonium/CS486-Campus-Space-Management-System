# Logical Design Review Checklist

Before finalizing the Logical Database Design output, verify the following:

## 1. Completeness & Naming
- [ ] Are all entities from the ERD represented as tables in UPPER_SNAKE_CASE?
- [ ] Are all M:N relationships fully resolved into junction tables?

## 2. Relationships & FKs
- [ ] Are the multi-role foreign keys named uniquely to prevent column collisions?
- [ ] Do FK nullability settings match the optionality from Step 2?

## 3. DBML Native Features
- [ ] Are Enums used for statuses, roles, and types instead of plain strings?
- [ ] Are logical `default:` values applied to initial statuses?
- [ ] Are all references (`Ref:`) defined at the bottom of the script, rather than inline?
- [ ] Is `[delete: cascade]` applied to the relationships of the junction tables?