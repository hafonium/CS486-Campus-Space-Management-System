## Logical Database Design
**Environment:** OpenCode (Build Mode) | **Model:** DeepSeek V4 Pro

### Iteration 1

#### 1. Issues Encountered
* **Omission of operational timeline progression for actual session:** The agent correctly enforced the booking request window (`requested_start_time < requested_end_time`) via `chk_booking_timeline_order`, but completely failed to generate a Domain CHECK for the actual usage session (`actual_start_time < actual_end_time`). The `chk_booking_actual_timeline_order` constraint was absent.
* **Unenforced state-contingent nullability in MAINTENANCE_RECORD:** The `status` column could transition to `'completed'` without forcing `completion_time IS NOT NULL` and `result_note IS NOT NULL`. The `chk_maintenance_completion_required_fields` constraint was absent.
* **Anonymous composite Primary Key in SPACE_FACILITY:** The composite primary key in the associative junction table was declared as `(space_code, facility_id) [pk]` without an explicit `name:` parameter, risking system-hashed, unmaintainable constraint IDs in T-SQL.

#### 2. Root Cause
* The reference file `meta-pattern-extraction-guide.md` explained Propositional Logic ($P \implies Q$) conceptually but lacked an explicit mandate to apply it across *all* lifecycle status transitions (both booking and maintenance).
* The T-SQL syntax guide (`dbml-syntax-guide.md`) enforced explicit naming for unique indexes but lacked a rigid rule commanding named constraints for composite Primary Keys inside junction tables.
* The LLM experienced "Attention Drop" regarding secondary physical attributes when operating under the high cognitive load of resolving M:N cardinality.

#### 3. Resolution
* Injected `chk_booking_actual_timeline_order`: `CHECK ([actual_start_time] IS NULL OR [actual_end_time] IS NULL OR [actual_start_time] < [actual_end_time])` with NULL-safe logic.
* Injected `chk_maintenance_completion_required_fields`: `CHECK ([status] <> 'completed' OR ([completion_time] IS NOT NULL AND [result_note] IS NOT NULL))`.
* Enforced strict T-SQL DDL index naming: `(space_code, facility_id) [pk, name: 'pk_space_facility']`.
* These corrections were applied to `1-output.md` and targeted for propagation into `2-output.md`.

---

### Iteration 2

#### 1. Issues Encountered
* **Duplicate output — zero-change regeneration:** `2-output.md` was produced as a byte-for-byte duplicate of `1-output.md` (confirmed via `md5sum`). The correction prompts embedded in `2.md` (which explicitly demanded the three Iteration-1 fixes be applied to `2-output.md`) were silently ignored. The file was regenerated without any delta.
* **Section numbering mismatch (Hallucinated decimal sub-headings):** In the surrounding generation context (not captured in the final `1-output.md`/`2-output.md` text but present in agent reasoning), the agent attempted to nest Section 2 under hallucinated sub-headers `### 2.1 Candidate Keys` and `### 2.2 Foreign Keys`, contradicting the unified Section 2 template mandated by `SKILL.md`.
* **Premature Markdown wrapper termination:** The internal ` ```dbml ` code block collided with the outer Markdown wrapper, causing downstream text from Section 3 onward to spill into unformatted plain text in intermediate rendering passes.

#### 2. Root Cause
* Two reference files (`candidate-key-constraints.md` and `foreign-key-placement.md`) contained legacy hard-coded directives instructing the agent to target "Section 2.1" and "Section 2.2", creating a direct contradiction with the SKILL.md template that specified a single flat Section 2 with subsections.
* The standard 3-backtick (` ``` `) Markdown syntax is inherently incapable of safely encapsulating nested multi-language code blocks without escaping mechanisms, causing rendering artifacts when external tooling re-wraps the document.
* The agent failed to perform a pre-write diff against the correction prompts — it regenerated from its internal model cache rather than reading `1-output.md`, analyzing its defects, and applying targeted fixes.

#### 3. Resolution
* Performed surgical string replacements across `references/candidate-key-constraints.md` and `references/foreign-key-placement.md`, updating `"Section 2.1"` references to `"Section 2 (Primary Keys & Candidate Keys subsection)"` and `"Section 2 (Foreign Keys & Referential Integrity subsection)"`.
* Upgraded the execution prompt to mandate the Super-Block 4-backtick (` ```` `) encapsulation standard for multi-language document rendering, ensuring zero-loss nested code block preservation.
* Adopted a strict pre-write diff protocol: agents must `diff` the previous file against the correction prompts before writing the next staged artifact.
* **Status:** Schema achieved 100% structural parity. Locked and exported to `outputs/03-logical-design-G09.md`.

---

### Iteration 3 (Phase 3.1 — Static Base Normalization, `3-output.md`)

#### 1. Issues Encountered
* **Over-correction stripping FK anchor columns:** Instructed to withhold explicit `Ref:` declarations (per Phase 3.1 forbidden scope), the agent over-corrected by removing the underlying scalar Foreign Key columns entirely from BOOKING (`requester_id`, `space_code`, `decision_staff_id`, `check_in_staff_id`, `completion_staff_id`) and MAINTENANCE_RECORD (`space_code`, `reporter_id`, `assigned_staff_id`).
* **Omission of decomposed associative entity:** The agent failed to generate the physical junction table `SPACE_FACILITY` required to resolve the Many-to-Many cardinality between SPACE and FACILITY. Phase 3.1's static mapping workflow lacked an explicit look-ahead mechanism to detect implicit associative tables prior to relationship synthesis.

#### 2. Root Cause
* The directive *"Do NOT declare Foreign Key statements (`Ref:`)"* created an internal semantic ambiguity within the LLM's attention layers, leading it to conflate referential **syntax** (`Ref:`) with structural **scalar column definitions** (the `integer`/`varchar` columns themselves).
* The sequential static mapping workflow, when executed in strict Phase 3.1 isolation, had no upstream awareness of Phase 3.2's M:N resolution mandate, causing the SPACE_FACILITY placeholder to be dropped alongside other deferred elements.

#### 3. Resolution
* Reformulated the Phase 3.2 prompt to command the **immediate injection of all scalar FK anchor columns** into operational tables (BOOKING + MAINTENANCE_RECORD) *before* synthesizing the global referential integrity block.
* Explicitly mandated the creation of `Table SPACE_FACILITY` carrying a named composite Primary Key constraint `pk_space_facility` as a non-negotiable Phase 3.2 deliverable.
* Introduced a new Phase 3.1 pre-flight check: "All candidate FK columns must be listed in the NOTES section as `// TODO: Inject in Phase 3.2`" — preventing silent omission.
* **Output:** `4-output.md` (Phase 3.2) was generated cleanly with all 7 BOOKING FK columns + 3 MAINTENANCE_RECORD FK columns + complete SPACE_FACILITY junction table.

---

### Iteration 4 (Phase 3.2 — Referential Integrity Injection, `4-output.md`)

#### 1. Issues Encountered
* **No errors within phase scope.** Phase 3.2 boundary adherence was correct:
  - ✅ All 7 FK columns injected into BOOKING (4 multi-role references to USER + 1 to SPACE)
  - ✅ All 3 FK columns injected into MAINTENANCE_RECORD (2 to USER + 1 to SPACE)
  - ✅ SPACE_FACILITY junction table complete with named composite PK
  - ✅ 10 global `Ref:` declarations in dedicated relationships block
  - ✅ RESTRICT for operational tables (no `[delete:` modifier), CASCADE for junction table
  - ✅ No `[unique]` tags, no CHECK constraints (correctly deferred to Phase 3.3)

#### 2. Root Cause
* N/A — No defects in this phase. The strict "Forbidden / Required" markers added to SKILL.md after Iteration 3.4 successfully prevented scope creep.

#### 3. Resolution
* N/A — Phase 3.2 output was accepted as-is and passed to Phase 3.3.

---

### Iteration 5 (Phase 3.3 — Candidate Keys & Domain CHECKs, `5-output.md`)

#### 1. Issues Encountered
* **`pk_space_facility` miscited as Candidate Key example:** In the Phase 3.3 Completion Checklist (line 225), the validation text reads: *"Composite CKs explicitly named (e.g., `uq_space_location`, `pk_space_facility`)"*. However, `pk_space_facility` is a **Primary Key** on the SPACE_FACILITY junction table, not a Candidate Key. Citing it alongside the legitimate CK `uq_space_location` creates a false classification.
* **Incomplete 6-gate validation checklist:** The Phase 3.3 Completion Checklist only explicitly verifies Gates 2 (Candidate Key Parity), 5 (Categorical Coverage), and 6 (Scalar Traceability). Gates 1 (No-Enum Audit), 3 (Delete Behavior Parity), and 4 (Nullability Alignment) were omitted from the checklist text, even though the underlying schema passed them.
* **`chk_booking_completion_required_fields` omits `usage_notes`:** Business Rule 8 states *"When a booking session is completed, the system must record the actual end time, the final condition of the space, and any usage notes."* The CHECK constraint `chk_booking_completion_required_fields` validates `actual_end_time IS NOT NULL` and `final_condition IS NOT NULL` but **omits** `usage_notes IS NOT NULL`. This propagates across all output files (1-output.md through 6-output.md) — it was never caught by any gate.

#### 2. Root Cause
* The Phase 3.3 checklist text was hand-authored by the agent rather than derived mechanically from the 6-gate enumeration in `logical-review-checklist.md`. The agent performed the validation silently for Gates 1, 3, and 4 but failed to transcribe the results into the written checklist.
* The PK/CK taxonomy confusion for `pk_space_facility` stems from the agent treating all named composite indexes in `Indexes {}` blocks as homogeneous — it failed to distinguish `[pk]` from `[unique]` when enumerating examples in prose.
* The `usage_notes` omission is a systematic BR-to-CHECK translation gap: the agent correctly extracted `actual_end_time` and `final_condition` from BR8 but suffered attention dropout on the third required field (`usage_notes`). The 6-gate checklist has no gate that explicitly cross-checks CHECK constraint field lists against their originating business rule text.

#### 3. Resolution
* Corrected `pk_space_facility` to `uq_space_location` as the sole CK example in the checklist prose (applied in `6-output.md`).
* Expanded the Phase 3.4 output (`6-output.md`) to include a complete 6-gate validation block with all gates enumerated and pass/fail results.
* The `usage_notes` omission was **not caught** in any iteration and persists in the final deliverable (`6-output.md`, `outputs/03-logical-design-G09.md`). A future correction must update `chk_booking_completion_required_fields` to: `CHECK ([booking_status] <> 'completed' OR ([actual_end_time] IS NOT NULL AND [final_condition] IS NOT NULL AND [usage_notes] IS NOT NULL))`.

---

### Iteration 6 (Phase 3.4 — Architectural Gate Verification, `6-output.md` / Final Deliverable)

#### 1. Issues Encountered
* **Residual `usage_notes` omission in completion CHECK:** The error from Iteration 5 carried forward into the final deliverable. `chk_booking_completion_required_fields` at line 158 of `6-output.md` still reads `CHECK ([booking_status] <> 'completed' OR ([actual_end_time] IS NOT NULL AND [final_condition] IS NOT NULL))` — `usage_notes IS NOT NULL` remains absent.
* **`completion_staff_id` not enforced on completion:** The schema defines `completion_staff_id` as an FK referencing USER (mapping the *"Staff completes Booking"* relationship from the ERD), and BR10 requires that facility staff perform session completion. However, `chk_booking_completion_required_fields` does not validate `completion_staff_id IS NOT NULL` when status = `'completed'`. While BR8 does not explicitly enumerate `completion_staff_id` as a required record (unlike BR7 which explicitly lists `check_in_staff_id`), the architectural decision to include the FK column creates a semantic expectation of enforcement.
* **Historical file organization mismatch (pre-existing):** Step 3 output files used sequential numbering (`1-output.md` through `6-output.md`) rather than phase-aligned naming (`3.1-output.md` through `3.4-output.md`), creating ambiguity about which file corresponds to which phase boundary. The `3.md` SKILL specification references phase-aligned artifact names, but the actual files use legacy sequential names.

#### 2. Root Cause
* **BR8 parsing gap:** The business rule states *"must record the actual end time, the final condition of the space, and any usage notes"* — three conjunctive requirements joined by "and". The agent's constraint extraction treated this as a 2-field list (end_time + final_condition), dropping `usage_notes` as if it were optional or implied. This is consistent with the "Attention Drop" phenomenon identified in Iteration 1, now recurring on a different BR.
* **BR7/BR8 asymmetry:** BR7 explicitly lists the staff member (`check_in_staff_id`) as a required field, creating a template that the agent followed. BR8 does not, so the agent did not invent the requirement. But the ERD explicitly models a *"completes"* relationship (USER → BOOKING), making the omission architecturally inconsistent regardless of BR8's wording.
* **File naming drift:** The original WBS specified 4-phase execution but the initial execution script used sequential step numbering (1-7 → 1-6 outputs). The phase-aligned names were documented as corrections in the Iteration 3.4 log entry but the actual files were never renamed.

#### 3. Resolution
* **Gate 2 CK count corrected:** The validation text was updated from the erroneous "5 candidate keys" to the accurate "4 candidate keys" (`email`, `phone_number`, `(building, floor, room_number)`, `facility_name`). `pk_space_facility` was correctly excluded from the CK count.
* **All 6 gates formally enumerated** in a dedicated Section 6 validation block with pass/fail results.
* **Production deliverable synchronized:** `outputs/03-logical-design-G09.md` was regenerated from `6-output.md` with full scalar boundary `note:` traceability attributes and specific CHECK references (replacing the earlier generic `'Restricted via Section 3 CHECK'` format).
* **Unresolved — requiring manual correction:**
  1. Add `AND [usage_notes] IS NOT NULL` to `chk_booking_completion_required_fields` (BR8 conformance).
  2. Consider adding `AND [completion_staff_id] IS NOT NULL` to the same CHECK (ERD relationship conformance with BR10).
  3. Rename `1-output.md` → `3.1-output.md`, `3-output.md` → `3.1-output.md` (resolve naming collision), `4-output.md` → `3.2-output.md`, `5-output.md` → `3.3-output.md`, `6-output.md` → `3.4-output.md` to align with SKILL.md staged artifact specifications.
  4. Delete `2-output.md` (byte-identical duplicate of `1-output.md`).

---

### Cross-Cutting Architectural Issues (All Iterations)

#### 1. Issues Encountered
* **`1-output.md` and `2-output.md` are byte-identical duplicates:** The correction workflow in `2.md` targeted `2-output.md` with 3 explicit fixes, but the agent produced an identical file with zero changes applied.
* **Heading level inconsistency across iterations:** `1-output.md` and `2-output.md` use `###` (h3) for sections 1-5, while `3-output.md` through `6-output.md` use `##` (h2). The SKILL.md template does not specify a required heading depth.
* **Generic vs. specific `note:` format drift:** `1-output.md` and `2-output.md` use the generic pattern `note: 'Restricted via Section 3 CHECK'` on categorical columns. `5-output.md` and `6-output.md` upgrade to the specific pattern `note: 'CHECK ([col] IN (...)) – Section 3'`. The generic format satisfies Gate 5 (coverage) but fails Gate 6 (specific scalar boundary traceability).
* **Missing scalar boundary `note:` on 5 columns** in `1-output.md` and `2-output.md`: `capacity`, `expected_participants`, `requested_end_time`, `actual_end_time`, `completion_time` all lack `note:` attributes. These were added in `5-output.md` and `6-output.md`.
* **Flat Section 2 structure in early iterations:** `1-output.md` and `2-output.md` present Section 2 as a single flat block without 2.1 (PK/CK), 2.2 (FK), and 2.3 (NOT NULL) subsections. Phase-aligned outputs (`4-output.md` through `6-output.md`) adopt the structured subsection format.
* **Missing constraint source references in Section 3** of `1-output.md` and `2-output.md`: CHECK constraints lack *"Source: Business Requirement Analysis § X"* annotations present in `5-output.md`.

#### 2. Root Cause
* The sequential workflow in legacy `1.md`/`2.md` (Steps 1-7) lacked explicit phase boundaries, staged artifact designations, and "Forbidden/Required" markers. Agents operating under this instruction set had no objective criteria to determine when to stop adding features to a single file.
* The upgrade to the 4-phase granular model (`3.md`) introduced strict phase boundaries but did not include a retroactive file-renaming step, leaving the legacy sequential files in place alongside corrected content.
* The `note:` format was defined as `'Restricted via Section 3 CHECK'` in the legacy `1.md`/`2.md` output template (line 86) but refined to `'CHECK ([col] ...) – Section 3'` in the phase-aligned SKILL.md — the reference template and the skill specification drifted apart.

#### 3. Resolution
* Restructured SKILL.md (`3.md`) from sequential Steps 1-7 to explicit 4-phase architecture (3.1-3.4) with "Purpose", "Inputs", "Scope of Work", "Forbidden", "Required", and "Staged Artifact" sections per phase.
* Verified and aligned all reference files to eliminate legacy "Section 2.1"/"Section 2.2" references.
* Updated `outputs/03-logical-design-G09.md` to incorporate all Phase 3.4 improvements (specific `note:` format, scalar boundary traceability, 6-gate validation).
* **Status:** Schema achieved structural and business parity across all 6 gates (with the noted `usage_notes` exception). Ready for Step 4 compilation pending resolution of the remaining CHECK field omissions.

---

### Unresolved Items (Carried Forward to Step 4)

| # | Issue | Affected Files | Severity |
|---|---|---|---|
| 1 | `chk_booking_completion_required_fields` missing `AND [usage_notes] IS NOT NULL` (BR8) | All outputs (1-6) + production | HIGH |
| 2 | `chk_booking_completion_required_fields` missing `AND [completion_staff_id] IS NOT NULL` (ERD/BR10) | All outputs (1-6) + production | MODERATE |
| 3 | File naming misalignment: sequential vs. phase-aligned names | `1-output.md` through `6-output.md` | LOW |
| 4 | `2-output.md` is a byte-identical duplicate of `1-output.md` | `2-output.md` | LOW |
| 5 | `1-output.md`/`2-output.md` retain poor formatting (flat Section 2, `###` headings) that is superseded by `6-output.md` | `1-output.md`, `2-output.md` | LOW |
