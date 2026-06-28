## Phase 5: Database Implementation
**Environment:** Build Mode | **Model:** deepseek-v4-pro

### Iteration 1

#### 1. Issues Encountered
* **THROW statement syntax error in trigger:** The `trg_booking_enforce_rules` trigger used `THROW` inside `BEGIN...END` blocks without a preceding semicolon. T-SQL requires the statement immediately before `THROW` to be semicolon-terminated, otherwise the parser misinterprets `BEGIN` as part of a Service Broker `BEGIN DIALOG CONVERSATION` construct and raises a syntax error.

#### 2. Root Cause
* The `sql-syntax-quick-reference.md` documents `THROW` usage but does not mention the strict semicolon-termination requirement for the statement *preceding* `THROW`.
* The trigger validation template in the reference shows `THROW` with a trailing semicolon (`THROW 50000, 'message', 1;`) but does not emphasize that the statement before `THROW` must also be semicolon-terminated.
* The agent followed standard T-SQL documentation without applying this specific parser quirk.

#### 3. Resolution
* Prefix each `THROW` statement with a semicolon (`;THROW ...`) inside trigger `BEGIN...END` blocks.
* Add the semicolon-before-THROW rule to `references/sql-syntax-quick-reference.md` in the T-SQL Specifics section.
* Add a T-SQL syntax lint check to `references/step-5-implementation-quality-checks.md` requiring verification of semicolon placement before every `THROW` statement.

### Iteration 2

#### 1. Issues Encountered
* **Reserved keyword conflict on table name `USER`:** The script used `dbo.USER` as a bare identifier. `USER` is a T-SQL reserved keyword (a built-in function that returns the current database user's name). This caused `Incorrect syntax near the keyword 'USER'` during table creation and would silently resolve to the function instead of the table in `SELECT * FROM USER` queries.

#### 2. Root Cause
* The logical design and ERD both use `USER` as the entity/table name without flagging it as a T-SQL reserved keyword.
* No pre-generation identifier check against the [T-SQL reserved keyword list](https://learn.microsoft.com/en-us/sql/t-sql/language-elements/reserved-keywords-transact-sql) exists in the implementation workflow.
* The logical design remained DBMS-agnostic through conceptual/ERD phases, but the implementation phase did not apply a reserved-word escape step before emitting T-SQL DDL.

#### 3. General Solution
When generating T-SQL DDL from logical design identifiers (table names, column names), every identifier must be validated against the T-SQL reserved keyword list. Any match must be escaped with square brackets `[ ]` in all DDL statements — `CREATE TABLE`, `ALTER TABLE ... ADD CONSTRAINT`, `REFERENCES`, and any subsequent DML (`SELECT`, `INSERT`, `UPDATE`).

Common T-SQL reserved keywords that frequently collide with domain entity names: `USER`, `STATUS`, `STATE`, `ORDER`, `GROUP`, `INDEX`, `KEY`, `TABLE`, `VIEW`, `FUNCTION`, `SCHEMA`, `ROLE`, `ROLES`, `LOGIN`, `PASSWORD`, `SESSION`, `SYSTEM`, `ADMIN`.

#### 4. Resolution
* Wrap the reserved table name in square brackets: `dbo.[USER]` replacing all 8 occurrences of `dbo.USER` in `CREATE TABLE`, `ALTER TABLE ... ADD CONSTRAINT ... REFERENCES`, and all future queries.
* Add a pre-generation reserved-keyword verification step to `references/step-5-implementation-quality-checks.md`:
  - Before emitting DDL, cross-reference all table and column names against the T-SQL reserved keyword list.
  - Emit identifiers with `[ ]` escaping for any match.
  - Verify both `CREATE TABLE` names and all `REFERENCES` targets.


### Iteration 5

#### 1. Issues Encountered

* **Missing database creation and setup:** The generated implementation script failed to create the overarching database for the system. It proceeded directly to table creation without provisioning the database container or ensuring a clean environment.

#### 2. Root Cause

* The implementation workflow overlooked the foundational step of explicitly creating the database and resetting its state prior to executing the DDL (Data Definition Language) statements.

#### 3. Resolution

* **Use Predefined Database Name:** Explicitly instruct the agent to always use the exact database name: `CampusSpaceManagementSystem`.
* **Implement Clean State Provisioning:** Prepend the script with statements to safely drop the database if it already exists, ensuring a completely empty and fresh state before recreating it. The script must start with:
```sql
DROP DATABASE IF EXISTS CampusSpaceManagementSystem;
CREATE DATABASE CampusSpaceManagementSystem;
USE CampusSpaceManagementSystem;

```


* **Update Quality Checks:** Add a rule to `references/step-5-implementation-quality-checks.md` requiring the implementation script to always initialize, recreate, and connect to `CampusSpaceManagementSystem` before generating any schema objects.