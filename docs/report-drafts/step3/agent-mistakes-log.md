## Logical Database Design
**Environment:** Build Mode | **Model:** DeepSeek V4 Pro

### Iteration 1

#### 1. Issues Encountered
* **Missing actual session timeline progression:** The agent enforced the booking request window (`requested_start_time < requested_end_time`) but failed to generate a CHECK for the actual usage session (`actual_start_time < actual_end_time`).
* **Unenforced maintenance state-contingent nullability:** The MAINTENANCE_RECORD status could transition to `'completed'` without requiring `completion_time` and `result_note` to be populated.
* **Anonymous composite primary key:** The SPACE_FACILITY junction table declared `(space_code, facility_id) [pk]` without an explicit `name:` parameter, risking unmaintainable system-generated constraint IDs in T-SQL.
* **Missing scalar boundary traceability notes:** Five columns (`capacity`, `expected_participants`, `requested_end_time`, `actual_end_time`, `completion_time`) lacked inline `note:` attributes pointing to their corresponding Section 3 CHECK constraints.
* **Generic categorical notes:** All categorical columns used the placeholder `note: 'Restricted via Section 3 CHECK'` instead of specific references like `note: 'CHECK ([role] IN (...)) – Section 3'`.

#### 2. Root Cause
* `meta-pattern-extraction-guide.md` explained Propositional Logic conceptually but did not explicitly mandate its application across all lifecycle status transitions.
* `dbml-syntax-guide.md` enforced explicit naming for unique indexes but lacked a rigid rule for composite primary keys inside junction tables.
* The legacy output template in `1.md` defined the note format as `'Restricted via Section 3 CHECK'`, creating a drift from the later specific format required by Gate 6.
* The agent experienced attention dropout on secondary physical attributes when operating under the cognitive load of resolving M:N cardinality.

#### 3. Resolution
* Injected `chk_booking_actual_timeline_order`: `CHECK ([actual_start_time] IS NULL OR [actual_end_time] IS NULL OR [actual_start_time] < [actual_end_time])`.
* Injected `chk_maintenance_completion_required_fields`: `CHECK ([status] <> 'completed' OR ([completion_time] IS NOT NULL AND [result_note] IS NOT NULL))`.
* Enforced explicit index naming: `(space_code, facility_id) [pk, name: 'pk_space_facility']`.
* The scalar boundary notes and specific CHECK references were deferred and later applied in Iteration 5.

---

### Iteration 2

#### 1. Issues Encountered
* **Duplicate output with zero changes applied:** `2-output.md` was produced as a byte-for-byte duplicate of `1-output.md`. The three explicit correction prompts embedded in `2.md` were silently ignored.
* **Hallucinated decimal subsection numbering:** Legacy references in `candidate-key-constraints.md` and `foreign-key-placement.md` instructed the agent to target "Section 2.1" and "Section 2.2", contradicting the unified Section 2 structure mandated by `SKILL.md`.
* **Premature Markdown code-block termination:** The internal ` ```dbml ` block collided with the outer Markdown wrapper, causing Section 3 content to spill into unformatted plain text during intermediate rendering.

#### 2. Root Cause
* The agent regenerated `2-output.md` from its internal model cache instead of reading `1-output.md`, analyzing its defects, and applying the targeted fixes listed in `2.md`.
* `candidate-key-constraints.md` and `foreign-key-placement.md` contained legacy prompts that predated the unified Section 2 template.
* The standard 3-backtick Markdown syntax cannot safely encapsulate nested multi-language code blocks without escaping.

#### 3. Resolution
* Performed surgical string replacements in both reference files, updating "Section 2.1" and "Section 2.2" to point to the correct unified Section 2 subsections.
* Mandated the 4-backtick super-block encapsulation standard for multi-language document rendering.
* Adopted a pre-write diff protocol requiring agents to compare the previous file against correction prompts before generating the next staged artifact.

### Iteration 3

#### 1. Issues Encountered
- **DBML syntax failure due to unescaped single quotes in `note` attributes:** Many column definitions embedded T‑SQL `CHECK` constraints as `note` strings delimited by single quotes (`'...'`), while the constraints themselves contained unescaped single‑quoted enumeration values. This caused the DBML parser to cut the note string prematurely, breaking the entire diagram.
- **Affected columns across several tables:** The error propagated through `role` and `account_status` in USER, `space_type` and `current_status` in SPACE, and `requested_end_time`, `purpose`, `expected_participants`, `booking_status`, `actual_end_time` in BOOKING — all using the pattern `note: 'CHECK (… IN ('value1', …))'`.
- **Untestable state before correction:** The DBML could not be rendered in dbdiagram.io, so none of the logical constraints defined in the notes were visible or usable.

#### 2. Root Cause
- The `dbml‑syntax‑guide.md` used by the agent did not explicitly specify the quoting convention for `note` strings when they contain SQL literals with single quotes.
- The agent directly transcribed T‑SQL constraint examples into single‑quoted DBML strings without escaping, creating a nesting conflict between DBML's string delimiters and the SQL literals inside.
- Previous fixes focused only on constraint completeness and structure, skipping syntax validation on the target rendering tool.

#### 3. Resolution
- Replaced the outer single quotes with double quotes for all affected `note` attributes, preserving the inner single‑quoted SQL literals without escaping. Example:  
  `note: "CHECK ([role] IN ('student', 'lecturer', …)) – Section 3"`.
- An equivalent alternative would be escaping inner single quotes with backslashes (`\'`), but double quotes were chosen for clarity and less visual clutter.
- After the fix, the entire DBML block becomes syntactically valid and can be parsed and rendered by dbdiagram.io without errors.