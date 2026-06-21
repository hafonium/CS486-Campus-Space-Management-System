# Reference: T-SQL Compliant DBML Syntax Guide

## 1. Absolute Prohibition of Enums
Microsoft SQL Server (T-SQL) does not support native ANSI `ENUM` types. 
* **CRITICAL VIOLATION:** Declaring `Enum name { ... }` blocks anywhere in the DBML script is strictly forbidden.

## 2. Categorical Attribute Mapping
All conceptual categorical variables (e.g., status, type, role, priority, level) must be declared as standard `varchar(50)` (or appropriate contextual length).
* Every categorical attribute must point the reader to Section 3 via the inline `note` parameter:
  ```dbml
  account_role varchar(50) [not null, note: 'Restricted via Section 3 CHECK']
  record_status varchar(30) [not null, default: 'pending', note: 'Restricted via Section 3 CHECK']
  ```

## 3. Conceptual to T-SQL Data Type Translation
* `Integer` / `Surrogate ID` -> `integer`
* `Short String` / `Titles` -> `varchar(255)`
* `Codes` / `Fixed Identifiers` -> `varchar(50)`
* `Long Text` / `Descriptions` -> `text` (or `varchar(max)`)
* `Timestamp` / `Chronology` -> `datetime`
* `Boolean` / `True-False Flag` -> `bit`
* `Monetary` / `Precise Quantity` -> `decimal(18, 2)`

## 4. Initial State Injection
Attributes possessing a natural starting lifecycle state must carry an explicit `default:` definition:
```dbml
activation_status varchar(30) [not null, default: 'active', note: '...']
```