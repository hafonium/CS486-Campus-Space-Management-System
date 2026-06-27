# Sample Data Review Checklist

## Goal
Validate that the sample data scripts are executable, realistic, and meet the testing requirements for both normal and exceptional scenarios.

## Execution and Syntax Checks
To guarantee zero runtime, structural, or syntax errors during execution, the agent MUST validate the entire script against the following strict compilation and data bounds:

* **Dependency Ordering:** Are the `INSERT` statements ordered correctly to satisfy Foreign Key constraints? (Parent tables first, child tables last).
* **Dynamic Key Handling:** Are auto-incrementing primary keys handled dynamically (e.g., using `DECLARE` variables and `SCOPE_IDENTITY()`) rather than forced with hardcoded IDs, ensuring database triggers and security constraints remain fully active?
* **Structural Mapping:** Do the columns specified in the `INSERT INTO table (col1, col2)` match the exact position, count, and data types of the values provided?
* **String & Date Literals:** Do all strings strictly use single quotes (`'`), and are date/datetime formats fully compatible with standard T-SQL usage?
* **Constraint Alignment (CHECK & Domain Pass):** Does every literal value inserted actively comply with all table-level CHECK constraints, domain predicates, and categorical limitations defined in the logical schema (e.g., status values must match allowed IN strings exactly)?
* **Unique & Key Violation Guard:** Do all columns governed by Unique Constraints or Candidate Keys (such as emails, phone numbers, or institutional codes) contain strictly distinct values across all rows to prevent Unique Key violations?
* **Type, Length & Precision Bounds:** Does every single inserted value strictly respect its target column's physical data type, maximum length, and decimal precision (e.g., no string values exceeding the defined VARCHAR limit to prevent truncation errors, and no numeric overflows)?
* **Nullability and Default Compliance:** Does every column marked `NOT NULL` possess an explicit, valid value in the INSERT statement unless it is handled dynamically by a database default constraint?
* **Global Layout Syntax Audit:** Is the entire script completely free from generic syntax defects, including but not limited to: missing closing parentheses `)`, unmatched single quotes `'`, un-declared variables, or trailing commas `,` within bulk INSERT blocks?

## Relevance and Realism Checks
- **CRITICAL:** Scan the dataset for lazy placeholders (`test1`, `asdf`). Are they completely removed and replaced with domain-appropriate realistic data?
- Does the data tell a cohesive story? (e.g., related records match up logically).

## Scenario Coverage Checks
- Is there a clear separation or distinction between Normal Operations and Exceptional Cases?
- Do the Exceptional Cases actually test edge conditions (e.g., boundary values, nullable columns, minimum/maximum lengths)?
- Are all major tables from the schema populated with at least a few records?

## Pass Condition
The sample data is ready to use only if:
- it executes without dependency or syntax errors,
- it represents a realistic snapshot of a production system,
- it actively supports the validation of edge cases and exceptions.