# Reference: T-SQL Compliant DBML Syntax Guide

## 1. Absolute Prohibition of Enums
Microsoft SQL Server (T-SQL) does not support native ANSI `ENUM` types. 
* **CRITICAL VIOLATION:** Declaring `Enum name { ... }` blocks anywhere in the DBML script is strictly forbidden.

## 2. AST Bijection & Traceability Note Mounting
To guarantee 100% bi-directional Abstract Syntax Tree (AST) mapping between the DBML schema and Section 3 constraints, every restricted column MUST carry an explicit inline pointer note:
* **Categorical Domains:** Mount pointer notes reflecting the finite membership predicate:
  ```dbml
  role varchar(50) [not null, note: 'CHECK ([role] IN (...)) – Section 3']
  account_status varchar(50) [not null, default: 'active', note: 'CHECK ([account_status] IN (...)) – Section 3']
  ```
* **Scalar Numerical Bounds:** Mount pointer notes strictly reflecting the mathematical limitation:
  ```dbml
  capacity integer [not null, note: 'CHECK ([capacity] > 0) – Section 3']
  expected_participants integer [not null, note: 'CHECK ([expected_participants] > 0) – Section 3']
  ```
* **Intra-Record Chronological Progression:** Mount pointer notes reflecting the temporal dependency:
  ```dbml
  actual_end_time datetime [note: 'CHECK ([actual_start_time] < [actual_end_time]) – Section 3']
  completion_time datetime [note: 'CHECK ([start_time] < [completion_time]) – Section 3']
  ```

## 3. Conceptual to T-SQL Data Type Translation
* `Integer` / `Surrogate ID` -> `integer`
* `Short String` / `Titles` -> `varchar(255)`
* `Codes` / `Fixed Identifiers` -> `varchar(50)`
* `Long Text` / `Descriptions` -> `text`
* `Timestamp` / `Chronology` -> `datetime`
* `Boolean` / `True-False Flag` -> `bit`
* `Monetary` / `Precise Quantity` -> `decimal(18, 2)`

## 4. Initial State Injection
Attributes possessing a natural starting lifecycle state must carry an explicit `default:` definition:
```dbml
activation_status varchar(30) [not null, default: 'active', note: 'CHECK ([activation_status] IN (...)) – Section 3']
```