# Sample Data Review Checklist

## Goal
Validate that the sample data scripts are executable, realistic, and meet the testing requirements for both normal and exceptional scenarios.

## Execution and Syntax Checks
- Are the `INSERT` statements ordered correctly to satisfy Foreign Key constraints? (Parent tables first, child tables last).
- Do all strings use single quotes (`'`)? 
- Are date/datetime formats compatible with standard SQL usage?
- Do the columns specified in the `INSERT INTO table (col1, col2)` match the values provided?
- Did you avoid inserting into auto-incrementing identity columns (unless explicitly specifying `IDENTITY_INSERT ON` if required by the RDBMS)?
- If `IDENTITY_INSERT` is used on a table that has an `INSTEAD OF` trigger defined in the schema, is the trigger explicitly disabled before the batch and re-enabled immediately after?

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