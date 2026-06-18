# Candidate Keys, Enums, and Defaults Guide

## Candidate Keys (CK)
A Candidate Key is an attribute, or set of attributes, that uniquely identifies a row but was not chosen as the Primary Key.
1. Scan entities for unique real-world identifiers (e.g., `email`, `phone_number`).
2. Document these as CKs. In DBML, mark them with `[unique]`.
3. Physical locations (e.g., `building`, `floor`, `room_number`) should often form a composite unique constraint.

## Domain Constraints (Enums vs. Strings)
**CRITICAL:** Do NOT use `string` with a `note` for fields that have a specific list of allowed values (like statuses, types, roles).
1. Define a separate `Enum` block.
2. Use the Enum name as the data type for the column.
   *Example:*
   ```dbml
   Enum user_role { student lecturer facility_staff }
   Table USER { role user_role }
```

## Default Values
1. Use `[default: 'your_value']` for statuses that have a logical initial state.
2. *Examples:* `account_status` defaults to `'active'`. `booking_status` defaults to `'pending'`. `maintenance_status` defaults to `'reported'`.