## Phase 4: Database Design Validation
**Environment:** Build Mode | **Model:** GPT-5.4 mini

### Iteration 1

#### 1. Issues Encountered
* **Over-detailed validation output:** The draft included a full review-style report with many sections, even though the requested deliverable only needs raised errors when they exist.
* **Insufficient generalization:** The prompt still reads like it is tuned to this specific case instead of a reusable validation framework for many clients, many requirement sets, and many database-design tasks.
* **Role-modeling ambiguity:** The validation text notes that the BR says a user may hold multiple roles, while the logical schema uses a single-valued `user_role` on `USER`.
* **ERD cardinality notation mismatch:** The validation text notes that the `SPACE-FACILITY` Mermaid notation implies mandatory participation, while the written ERD summary describes the relationship as optional on both sides.

#### 2. Root Cause
* The output template was optimized for exhaustive validation instead of a minimal error-reporting format.
* The prompt language was still anchored to this specific workflow and example instead of using fully generic database-validation terms.
* The schema and the business requirements still disagree on whether `USER.role` is single-valued or multi-valued.
* The ERD diagram notation was not kept in sync with the relationship summary text.

#### 3. Resolution
* Reduce the Step 4 output to a short validation result that lists only actual errors, or says `No errors found.` when none exist.
* Reword the skill so it describes a reusable validation framework for many different requirements and clients, while still fitting into the 7-step workflow.
* Confirm whether multi-role users are a real business requirement; if yes, replace the single enum role with a `USER_ROLE` junction model.
* Align the ERD notation with the intended optional M:N interpretation, or update the summary text so both sources match.

### Iteration 3

#### 1. Issues Encountered
* **Missed error detection after Step 3 was changed:** When the Step 3 output was edited to contain a nullable mandatory foreign key and a changed enum value, the Step 4 output still returned no errors.
* **Stale validation result:** The validation file did not reflect the new schema inconsistency, so the checker failed to surface the changed nullability and domain mismatch.

#### 2. Root Cause
* The validation prompt was still not strict enough about re-evaluating the current Step 3 output against the rule set.
* The validation result was effectively using an older assumption of the schema instead of re-checking the edited logical design.

#### 3. Resolution
* Force Step 4 to compare against the current Step 3 output every time it runs.
* Make any nullability mismatch, enum mismatch, or relationship mismatch an explicit failure, even if the rest of the schema looks valid.
* Regenerate the validation output whenever Step 3 changes, so the report cannot stay on an outdated pass result.


