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

---

### Iteration 3

#### 1. Issues Encountered
* **Foreign Key anchor columns stripped:** Instructed to withhold `Ref:` declarations per Phase 3.1 boundary rules, the agent over-corrected by removing the underlying scalar FK columns from BOOKING (`requester_id`, `space_code`, `decision_staff_id`, `check_in_staff_id`, `completion_staff_id`) and MAINTENANCE_RECORD (`space_code`, `reporter_id`, `assigned_staff_id`).
* **Junction table omitted:** The SPACE_FACILITY table was not generated in `3-output.md`, leaving the M:N relationship between SPACE and FACILITY unresolved.

#### 2. Root Cause
* The directive "Do NOT declare Foreign Key statements (`Ref:`)" created semantic ambiguity in the agent's attention layers, conflating referential syntax with structural column definitions.
* The Phase 3.1 static mapping workflow had no upstream awareness of Phase 3.2's M:N resolution mandate, causing the associative entity placeholder to be silently dropped.

#### 3. Resolution
* Reformulated the Phase 3.2 prompt to command injection of all scalar FK anchor columns before synthesizing the global referential integrity block.
* Explicitly mandated creation of SPACE_FACILITY with a named composite primary key as a non-negotiable Phase 3.2 deliverable.
* These corrections were successfully applied in `4-output.md`.

---

### Iteration 4

#### 1. Issues Encountered
* **No errors within phase scope.** Phase 3.2 boundary adherence was correct: all 7 BOOKING FK columns injected, all 3 MAINTENANCE_RECORD FK columns injected, SPACE_FACILITY complete with named composite PK, 10 global `Ref:` declarations with correct RESTRICT/CASCADE semantics, and no premature `[unique]` or CHECK constraints.

#### 2. Root Cause
* The strict "Forbidden/Required" markers added to `3.md` after the architectural restructuring successfully prevented scope creep in this phase.

#### 3. Resolution
* No corrective action required. `4-output.md` was accepted as-is and passed to Phase 3.3.

---

### Iteration 5

#### 1. Issues Encountered
* **Primary Key miscited as Candidate Key example:** The Phase 3.3 completion checklist in `5-output.md` cited `pk_space_facility` alongside `uq_space_location` as an example of a named composite Candidate Key. However, `pk_space_facility` is a Primary Key, not a Candidate Key.
* **Incomplete validation checklist:** The 6-gate completion checklist explicitly verified only Gates 2, 5, and 6, omitting Gates 1 (No-Enum), 3 (Delete Behavior), and 4 (Nullability) from the written text, even though the underlying schema passed them.
* **Missing `usage_notes` in completion CHECK:** `chk_booking_completion_required_fields` validated `actual_end_time` and `final_condition` but omitted `usage_notes`, which Business Rule 8 explicitly requires: "must record the actual end time, the final condition of the space, and any usage notes."

#### 2. Root Cause
* The checklist text was hand-authored rather than derived mechanically from `logical-review-checklist.md`, causing the agent to transcribe only the gates it had most recently validated.
* The agent treated all named composite indexes in `Indexes {}` blocks as homogeneous, failing to distinguish `[pk]` from `[unique]` when enumerating examples in prose.
* Business Rule 8 lists three conjunctive requirements joined by "and". The agent extracted only the first two (`actual_end_time`, `final_condition`), dropping `usage_notes` through an attention-dropout pattern identical to the one observed in Iteration 1.

#### 3. Resolution
* Corrected the CK example in the checklist prose, removing `pk_space_facility` and retaining only `uq_space_location`.
* The expanded 6-gate validation block with all gates enumerated was deferred to Phase 3.4 (`6-output.md`).
* The `usage_notes` omission was not caught by any gate and persisted into the final deliverable.

---

### Iteration 6

#### 1. Issues Encountered
* **`usage_notes` omission carried forward to production:** The `chk_booking_completion_required_fields` CHECK in `6-output.md` and `outputs/03-logical-design-G09.md` still reads `CHECK ([booking_status] <> 'completed' OR ([actual_end_time] IS NOT NULL AND [final_condition] IS NOT NULL))`, missing the `AND [usage_notes] IS NOT NULL` required by Business Rule 8.
* **`completion_staff_id` unenforced on completion:** The schema defines a `completion_staff_id` FK column mapping the *"Staff completes Booking"* ERD relationship, but the completion CHECK does not enforce it. Business Rule 10 states only facility staff may complete sessions, creating an architectural expectation the constraint does not meet.
* **Candidate Key count overstatement:** The validation text in `6-output.md` initially claimed "5 candidate keys" when the actual count is 4 (`email`, `phone_number`, `(building, floor, room_number)`, `facility_name`). The composite PK `pk_space_facility` was erroneously included in the CK tally.
* **Production file missing scalar traceability:** `outputs/03-logical-design-G09.md` predated the Phase 3.3 traceability improvements and lacked inline `note:` attributes on five scalar boundary columns, causing a Gate 6 failure.
* **File naming misalignment:** Output files use sequential numbering (`1-output.md` through `6-output.md`) while `3.md` references phase-aligned names (`3.1-output.md` through `3.4-output.md`).

#### 2. Root Cause
* The `usage_notes` omission is a systematic BR-to-CHECK translation gap. The 6-gate checklist has no gate that cross-checks CHECK constraint field lists against their originating business rule text word-by-word.
* Business Rule 8 does not explicitly enumerate `completion_staff_id` as a required field (unlike BR7 which lists `check_in_staff_id`), so the agent did not invent the requirement. However, the ERD models the "completes" relationship explicitly, making the omission architecturally inconsistent.
* The agent miscounted composite PKs as CKs in the bijection audit — a taxonomy error in classifying named index types.
* The production file was an earlier revision that predated Phase 3.3's scalar boundary note injection and was not re-synchronized after the phase-aligned outputs were completed.

#### 3. Resolution
* Corrected Gate 2 CK count from 5 to 4 in both `6-output.md` and `outputs/03-logical-design-G09.md`.
* Regenerated `outputs/03-logical-design-G09.md` from `6-output.md` with all scalar boundary `note:` attributes and specific CHECK references.
* The `usage_notes` and `completion_staff_id` omissions remain unresolved and must be corrected in a future pass by updating `chk_booking_completion_required_fields` to include both fields.
* File renaming to phase-aligned names was documented as a required follow-up action.
