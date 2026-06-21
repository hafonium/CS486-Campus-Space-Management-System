## Logical Database Design
**Environment:** OpenCode (Build Mode) | **Model:** DeepSeek V4 Pro

### Iteration 1

#### 1. Issues Encountered
* **Omission of operational timeline progression:** The agent correctly enforced the booking request window (`requested_start_time < requested_end_time`), but completely failed to generate a Domain CHECK for the actual usage session (`actual_start_time < actual_end_time`).
* **Unenforced state-contingent nullability:** In `MAINTENANCE_RECORD`, the agent allowed the `status` to transition to `'completed'` without forcing the underlying completion timestamp and result notes to be `IS NOT NULL`.
* **Anonymous composite Primary Key risk:** In the associative table `SPACE_FACILITY`, the composite primary key was declared as `(space_code, facility_id) [pk]` without an explicit `name:` parameter, risking system-hashed, unmaintainable constraint IDs in T-SQL.

#### 2. Root Cause
* The reference file `meta-pattern-extraction-guide.md` explained Propositional Logic ($P \implies Q$) conceptually, but failed to explicitly mandate its application across all lifecycle status transitions.
* The T-SQL syntax guide enforced explicit naming for unique indexes, but lacked a rigid rule commanding named constraints for composite Primary Keys inside junction tables.
* The LLM experienced "Attention Drop" regarding secondary physical attributes when operating under the high cognitive load of resolving M:N cardinality.

#### 3. Resolution
* Inject a targeted secondary prompt commanding the agent to audit all paired temporal attributes for logical progression.
* Formulate an explicit Pattern 2 mathematical check for the maintenance lifecycle: `CHECK (status <> 'completed' OR (completion_time IS NOT NULL AND result_note IS NOT NULL))`.
* Enforce strict T-SQL DDL index naming in the follow-up directive: `(space_code, facility_id) [pk, name: 'pk_space_facility']`.

### Iteration 2

#### 1. Issues Encountered
* **Section numbering mismatch (Hallucinated sub-headings):** The agent successfully generated the verified DBML schema, but attempted to nest Section 2 under hallucinated decimal sub-headers (`### 2.1 Candidate Keys` and `### 2.2 Foreign Keys`), breaking the overarching 5-part template.
* **Premature Markdown wrapper termination:** The agent's internal ` ```dbml ` code block collided with the outer Markdown code-block wrapper, causing the downstream text from Section 3 onwards to spill out as unformatted standard text.

#### 2. Root Cause
* Two reference files (`candidate-key-constraints.md` and `foreign-key-placement.md`) contained legacy hard-coded prompts instructing the agent to point to "Section 2.1" and "Section 2.2", creating a direct contradiction with `SKILL.md`.
* The standard 3-backtick (` ``` `) Markdown syntax is inherently incapable of safely encapsulating nested multi-language code blocks without escaping mechanisms.

#### 3. Resolution
* Perform a surgical string replacement across all `references/*.md` files, updating `"Section 2.1"` to `"Section 2 (Primary Keys & Candidate Keys subsection)"`.
* Upgrade the OpenCode execution prompt to mandate the Super-Block 4-backtick (` ```` `) encapsulation standard to ensure zero-loss multi-language document rendering.
* **Status:** Schema achieved 100% structural and business parity. Locked and formally exported to `outputs/03-logical-design-G09.md`.