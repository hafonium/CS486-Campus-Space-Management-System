---
name: query-design
description: Act as a deterministic T-SQL Syntax Compiler for Step 7. Ingest human-designed business question concepts passed via prompt, trace relational paths strictly against the locked Step 3 logical schema, protect system keywords, and output an optimized executable SQL script without semantic hallucination.
---

# Query Design & Compilation (Step 7)

## Purpose
This skill defines the operational protocol for compiling Step 7 business queries for the Campus Space Management System targeted strictly at **Microsoft SQL Server (T-SQL)**.

The agent operates strictly as a **Syntax Compiler**, not a business ideator. The human system architect provides the conceptual business questions; the agent's sole responsibility is translating those human intents into valid, index-optimized T-SQL batches verified against the locked Step 3 data dictionary.

## When to use
Use this skill when:
- The user provides the locked Step 3 Logical Design deliverable (`@outputs/03-logical-design-G09.md`).
- The user passes an explicit list of human-curated Business Question concepts in the chat prompt.
- The user inputs an empirical mistakes log commanding query refactoring or bug fixing.

Do not use this skill when:
- The user asks the agent to "brainstorm" or "invent random queries" without providing conceptual inputs.
- The task requires executing physical DDL table creation scripts (Step 5).

## Inputs
The agent requires strictly:
1. **Absolute Schema Baseline:** `@outputs/03-logical-design-G09.md` (The immutable data dictionary).
2. **Human Business Specification:** A textual block passed directly in the user's prompt containing the explicit business concepts to be compiled.
3. **Blacklist:** (Optional) A reference list of existing queries to guarantee zero logical collision.

## Workflow & Compiler Directives

### Pipeline Rule 0: Staging Routing & Preservation
- The agent must never write directly to final production folders or overwrite teammates' files.
- All compilation runs must be routed strictly to: `docs/report-drafts/step7/[iteration_index]-output.sql`.

### Step 1: Symbol Table Extraction (Zero-Hallucination Gate)
- Silently parse `@outputs/03-logical-design-G09.md`.
- Extract an internal symbol table containing only authorized Table names, Column names, and T-SQL Data Types.
- **CRITICAL BOUNDARY:** Any attempt to query a column or table outside this extracted symbol table is a fatal compilation error.

### Step 2: Immutable Specification Ingestion
- Read the Business Question concepts explicitly passed in the user's prompt.
- **ABSOLUTE PROHIBITION:** Do NOT invent, substitute, or modify the core business intent of the user's provided questions. Treat the user's raw concepts as locked institutional specifications.

### Step 3: Relational Path Mapping
- For each ingested human question, map the logical relational algebra path across the Step 3 symbol table.
- Identify the necessary join paths (e.g., `BOOKING` $\rightarrow$ `SPACE` $\rightarrow$ `USER`). Apply correct multi-role FK disambiguation pointers (e.g., `requester_id` vs `decision_staff_id`).

### Step 4: T-SQL Physical Statement Synthesis
Synthesize the SQL batches adhering strictly to Microsoft SQL Server physical execution rules:
- **Database Anchor:** The script header must explicitly declare `USE CampusSpaceManagementSystem;` followed by `GO`.
- **Schema Prefixing:** Every relation must be explicitly prefixed with `dbo.` (e.g., `dbo.SPACE`).
- **Reserved Keyword Protection:** System reserved words must be encapsulated in brackets. Specifically, the user entity MUST be written strictly as `dbo.[USER]`.
- **Batch Isolation:** Every distinct query block must terminate with an explicit `GO` command on a fresh line.
- **Parameter sandboxing:** Test parameters must be declared via `DECLARE @ParamName DataType = Value;` directly above the `SELECT` statement.

### Step 5: Human-in-the-Loop (HITL) Patch Ingestion
- When presented with error logs from SQL Server Management Studio (SSMS) compiler failures, perform a localized syntax patch without altering the underlying business logic.

## Output Template
The output must render purely as an executable T-SQL script:

```sql
USE CampusSpaceManagementSystem;
GO

/*
Query [N]
- Business question: [Exact interrogative concept passed by the user]
- Target user: [Authorized persona mapped from Step 3 USER.role domain]
- Explanation: [Synthesized professional justification of its operational utility]
*/
DECLARE @TestParam VARCHAR(50) = 'SampleValue';

SELECT 
    t1.authorized_col,
    t2.authorized_col
FROM dbo.TABLE_ONE t1
INNER JOIN dbo.TABLE_TWO t2 ON t1.pk_id = t2.fk_id
WHERE t1.target_col = @TestParam;
GO
```

## Pre-Flight Compiler Checklist
Before outputting the `.sql` script, silently verify compliance against these 5 internal compiler gates:
- [ ] **Gate 1 (AST Traceability):** 100% of tables and columns in `SELECT`, `JOIN`, `WHERE`, and `HAVING` clauses physically exist inside `@outputs/03-logical-design-G09.md`.
- [ ] **Gate 2 (Specification Parity):** Exactly 5 queries are generated, and their Business Questions match the human user's prompt input 1:1.
- [ ] **Gate 3 (Keyword Safety):** The user table is rendered strictly as `dbo.[USER]`, never `dbo.USER`.
- [ ] **Gate 4 (Batch Isolation):** An explicit `GO` statement separates `USE` and every individual query batch.
- [ ] **Gate 5 (Comment Closure):** All multi-line documentation blocks `/* ... */` are syntactically closed.