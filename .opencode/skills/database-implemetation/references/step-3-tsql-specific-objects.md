# Step 3 — T-SQL Specific Objects

Convert logical-design constructs that have no direct DBML equivalent into idiomatic T-SQL for Microsoft SQL Server.

## Enum replacement via CHECK constraints

Microsoft SQL Server does not support the `ENUM` data type. The logical design encodes categorical domains as `varchar` columns restricted by `CHECK (... IN (...))` constraints. Implementation steps:

1. For every column with a domain CHECK constraint, confirm the column type is `VARCHAR(50)` (or the size specified in the logical design).
2. Emit the CHECK constraint exactly as documented in the logical design Section 3.
3. Do not create separate lookup tables for these domains unless the validated logical design explicitly includes them.

## AUTO_INCREMENT → IDENTITY

1. Where the logical design uses `[pk, increment]` on an `integer` column, emit `INT IDENTITY(1,1)` in the column definition.
2. The `IDENTITY` property replaces the need for a separate sequence or `AUTO_INCREMENT` keyword.
3. For composite PKs (e.g., junction tables), do not use `IDENTITY` — the PK columns are FKs.

## Business rule cross-reference with BR analysis

Before implementing procedural objects, cross-reference the Business Requirements Analysis output against the logical design:

1. Open the Business Requirements Analysis output (normally `outputs/01-business-req-analysis*.md`).
2. Read Section 8 "Business rules" — list every rule with its BR number (BR 1, BR 2, …).
3. For each rule, determine its enforcement classification:

   | Classification | Condition | Action |
   | :--- | :--- | :--- |
   | **Structural** | Covered by a CHECK, FK, UNIQUE, NOT NULL, or PK in the logical design Section 2–3. | No trigger needed. The constraint is generated in Step 2. |
   | **Procedural** | Listed in the logical design Section 4 "Procedural Enforcement" with an implementation strategy. | Implement as a T-SQL trigger or stored procedure per the documented strategy. |
   | **Deferred** | Classified as Application-Layer in the BR (authentication, authorization, UI logic, workflow) OR the logical design Section 4 explicitly defers it to application middleware. | Do not implement in the database. Document in a `-- Business Rule Coverage` comment block at the end of the script noting the deferral. |
   | **Gap** | Database-Enforceable but missing from both the logical design's structural constraints (Section 2–3) AND procedural enforcement (Section 4). | Report as a gap before generating DDL — the logical design may be incomplete. |

4. After generating the script, add a `-- Business Rule Coverage` comment block at the end mapping each BR number to its enforcement method and the specific constraint/trigger/procedure name.

## Procedural enforcement objects

Review the logical design's Section 4 "Procedural Enforcement" for rules that require T-SQL triggers or stored procedures:

### Triggers

1. **Overlapping booking prevention:** Implement an `INSTEAD OF INSERT, UPDATE` trigger on `BOOKING` that checks for time-range overlaps with existing approved bookings for the same space.
2. **Space availability gate:** Implement an `INSTEAD OF INSERT` trigger on `BOOKING` that joins with `SPACE` and rejects inserts when `SPACE.current_status IN ('under_maintenance', 'temporarily_closed', 'retired')`.
3. Trigger template — use the authoritative template from `references/sql-syntax-quick-reference.md` section "Trigger Validation Template":
   - Always include `SET NOCOUNT ON;` at the top of the trigger body.
   - Use `;THROW 50000, 'message', 1;` (leading semicolon) inside `BEGIN...END` blocks for validation failures.
   - Do not use `RAISERROR` — prefer `;THROW` (SQL Server 2012+).
   - After validation passes, forward the operation (INSERT or UPDATE) from `inserted`.

### State machine enforcement

1. **Booking lifecycle:** The validated logical design delegates booking-status state-machine enforcement to the application layer. Confirm whether this task scope includes implementing it as a T-SQL trigger. If explicitly requested, implement as an `INSTEAD OF UPDATE` trigger that validates transitions against a predefined state map.
2. **Maintenance lifecycle:** Same as above — delegate to application layer unless explicitly requested.

### When to defer

3. If the logical design explicitly states that a procedural rule is enforced by "application middleware," do **not** implement it as a database trigger or procedure. Add a brief comment noting the deferral.
4. If the task scope is "schema implementation only" and does not mention triggers, do not generate trigger code. Note the deferred procedural rules in a short comment at the end of the script.

## Indexes

For every DBML `Indexes { ... }` block that is not already covered by PK or UNIQUE constraints:

1. Composite unique indexes: `CREATE UNIQUE INDEX <name> ON <table> (<cols>)`
2. Non-unique performance indexes: implement only if specified in the logical design. Do not invent indexes for query optimization unless explicitly requested.

## Delete behaviour mapping

| DBML Annotation | T-SQL Equivalent |
| :--- | :--- |
| `[delete: cascade]` | `ON DELETE CASCADE` |
| `[delete: restrict]` | `ON DELETE NO ACTION` (default) |
| No delete annotation | `ON DELETE NO ACTION` |
| `[delete: set null]` | `ON DELETE SET NULL` |
| `[delete: set default]` | `ON DELETE SET DEFAULT` |

For DBML's default `RESTRICT` behaviour (no `[delete: ...]` annotation), the FK clause omits `ON DELETE` entirely, relying on T-SQL's default `NO ACTION`.

## Schema-qualified names

- Use two-part names (`dbo.<table>`) consistently for all object references in FKs and triggers if the target database uses the `dbo` schema.
- If the logical design does not specify a schema, default to `dbo`.
