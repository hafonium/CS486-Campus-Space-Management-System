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

### Iteration 5

#### 1. Issues Encountered
* **False-positive flagging of application-layer business rule as a database gap:** The agent flagged Business Rule 1 ("Each user must have a valid university account to interact with the system") as an unaddressed schema gap, recommending additions to the Procedural Enforcement section. However, this rule pertains to external authentication (SSO/LDAP) enforced at the application layer, not the database schema. The logical design already enforces uniqueness on `email` and `phone_number`; independent university account validation is out of scope for database design.

#### 2. Root Cause
* The validation prompt lacked a clear scope boundary distinguishing between database-enforceable rules (uniqueness, nullability, referential integrity) and external application-layer rules (authentication, authorization, UI validation). The agent treated all Business Rules as equally enforceable within the database schema.
* The agent exhibited over-capture behaviour: treating every Business Rule as a database-enforceable concern without filtering out application-layer rules, resulting in false-positive validation failures.

#### 3. Resolution
* Add a scope classification to the Step 4 skill: categorize each Business Rule as either "Database-Enforceable" (must appear in schema constraints or Procedural Enforcement) or "Application-Layer" (excluded from DB validation scope, noted for awareness only).
* Calibrate the validation prompt to apply a "scope filter" before flagging: if a Business Rule describes external authentication, authorization logic, or UI-level validation, classify it as Application-Layer and exclude it from the DB validation failure list.

### Iteration 7

#### 1. Issues Encountered
* **False-positive flagging of space-vs-underscore in domain values:** The validation flagged the BR's use of spaces in multi-word role values (e.g., `"teaching assistant"`) as a mismatch against the ERD and logical design's use of underscores (e.g., `"teaching_assistant"`). The same occurred for maintenance status: BR line 66 `"in_progress"` vs. BR line 156 `"in progress"`. However, SQL DDL identifiers and CHECK constraint literals cannot contain spaces, so underscores are the required DDL-safe encoding. The BR's natural-language formatting with spaces is semantically equivalent and does not represent a real discrepancy.

#### 2. Root Cause
* `step-3-domains-and-constraints.md` enforced a strict character-by-character comparison (line 8: "Compare value-by-value, character-by-character. Underscores, casing, spelling — everything must match exactly.") without accounting for the unavoidable prose-to-code encoding gap. BR documents use human-readable spacing in informal prose; ERD and logical design encode those same values as DDL-safe identifiers without spaces. The agent followed the literal "exact match" rule and treated the same semantic value expressed in two contexts (human-readable vs. machine-readable) as different strings.

#### 3. Resolution
* Replace the rigid character-by-character comparison in `references/step-3-domains-and-constraints.md` with a normalization step: convert all spaces to underscores before comparing values. Only flag when the normalized values still differ.
* This generalizes beyond the specific role/maintenance-status case to any multi-word domain value (e.g., `"no show"` → `"no_show"`, `"checked in"` → `"checked_in"`).

