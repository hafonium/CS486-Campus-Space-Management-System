# Step 5 — Implementation Quality Checks

Verify the generated T-SQL script against the validated logical design before releasing it as final.

## Completeness check

For every table in the logical design:

1. **Table exists:** Run a mental `SELECT` through the script — confirm a `CREATE TABLE` statement for each logical table.
2. **Column count:** Count columns in the logical design; count column definitions in the `CREATE TABLE` statement. They must match exactly (excluding computed columns, which are not in scope).
3. **No missing columns:** Every attribute column from the logical design appears in the DDL. For FK columns, verify the column name matches the logical design exactly (e.g., `decision_staff_id`, not `decided_by`).
4. **No extra columns:** The script does not add columns absent from the logical design.

## Constraint preservation check

### Primary keys
- [ ] Every PK from the logical design appears as `PRIMARY KEY` in the DDL.
- [ ] Composite PKs use the correct column set.
- [ ] Auto-increment PKs use `IDENTITY(1,1)`.

### Foreign keys
- [ ] Every `Ref:` from the DBML appears as a `FOREIGN KEY` constraint.
- [ ] Each FK references the correct parent table and PK column.
- [ ] Delete behaviour matches: `CASCADE` where specified, `NO ACTION` otherwise.
- [ ] FK column nullability matches the logical design (NOT NULL where the FK summary table says NO; NULL where YES).

### Unique constraints
- [ ] Every CK from the logical design appears as `UNIQUE` (inline or via `ALTER TABLE`).
- [ ] Composite unique constraints use the correct column set.

### CHECK constraints
- [ ] Every documented CHECK from logical design Section 3 appears in the DDL.
- [ ] Predicate logic is identical — same columns, same operators, same values.
- [ ] Constraint names match exactly.

### Defaults
- [ ] Every `[default: '<value>']` from the DBML appears as a `DEFAULT` constraint.
- [ ] Default literals are valid per the column's domain CHECK.

### NOT NULL
- [ ] Every `[not null]` annotation from the DBML maps to `NOT NULL` in the DDL.
- [ ] PK columns are implicitly NOT NULL (IDENTITY columns are automatically NOT NULL in T-SQL).

## Procedural coverage check

1. **Trigger implementation:** For every procedural rule that is in scope for this task, confirm a trigger or procedure exists in the script.
2. **Deferred rules:** For every procedural rule delegated to the application layer per the logical design, confirm a comment is present in the script noting the deferral.
3. **No self-invented triggers:** The script does not contain triggers, procedures, or functions that were not documented in the validated logical design.

## T-SQL syntax and convention check

- [ ] All T-SQL keywords are valid for Microsoft SQL Server (current version, typically 2016+).
- [ ] Constraint names follow a consistent prefix convention (e.g., `pk_`, `fk_`, `uq_`, `chk_`, `df_`).
- [ ] Two-part names (`dbo.<object>`) are used consistently where applicable.
- [ ] All table and column names have been checked against the T-SQL reserved keyword list. Any match is escaped with `[ ]` in `CREATE TABLE`, `REFERENCES`, and all DML statements.
- [ ] `SET NOCOUNT ON` is present in trigger/procedure bodies.
- [ ] `RAISERROR` (or `THROW` for SQL Server 2012+) is used for trigger validation failures.
- [ ] Every `THROW` statement has a semicolon-terminated preceding statement (use `;THROW` inside `BEGIN...END` blocks to satisfy the parser).
- [ ] `GO` batch separators are placed between independent statement groups.

## Business rule coverage check

1. **BR to implementation trace:** For every business rule in the BR analysis Section 8, trace its enforcement in the script:
   - BR N → CHECK constraint `chk_xxx` (Structural)
   - BR N → Trigger `trg_xxx` (Procedural)
   - BR N → Deferred to application layer — documented in script as a `-- Business Rule Coverage` comment
2. **No orphan Database-Enforceable BRs:** Every Database-Enforceable BR must have a corresponding constraint, trigger, or documented deferral in the script. Any BR without coverage is a gap and must be flagged before release.
3. **No over-implementation of Application-Layer BRs:** Authentication (SSO/LDAP), user authorization logic, UI validation, and workflow rules classified as Application-Layer in the BR must NOT have database triggers or procedures generated for them unless the task scope explicitly requests it. Verify no such triggers exist in the script.
4. **BR coverage comment exists:** The script must contain a `-- Business Rule Coverage` comment block at the end listing every BR number with its classification and enforcement location.

## Anti-drift check

Compare the final DDL script against the validated logical design line by line:

- Did any column change type? (e.g., `varchar(50)` → `varchar(100)`)
- Did any constraint get dropped?
- Did any nullable column become NOT NULL (or vice versa)?
- Did any default value change?
- Did any FK reference change parent?

If any drift is found, revert the change to match the logical design. Do not silently "improve" the design during implementation.

## Final gate

If all checklist items pass, the implementation is ready for release. If any item fails, fix the issue and re-check before delivering.
