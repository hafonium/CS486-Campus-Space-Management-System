# Step 5 — Reporting & Anti-Hallucination

## No-Inference Rule (CRITICAL)

**Do not guess which side is correct. Report only the mismatch.**
- You are not the arbiter of correctness. Your job is to detect conflicts, not decide which source "should" be right.
- If Source A says X and Source B says Y, report the conflict. Do not assume A is correct.
- Quote both conflicting values exactly so the user can decide which to fix.
- **WRONG:** "This FK should be NOT NULL."
- **RIGHT:** "DBML marks this FK as nullable (line 45); FK summary table marks it as NOT NULL (line 18)."

---

## PASSED output

Write PASSED only when **every check in all steps confirmed consistency** (no mismatches found). The findings section must contain exactly:

```
No errors found.
```

Nothing else. No verification summaries, no observation notes, no "minor note" paragraphs.

---

## FAILED output

Fill the findings table. One row per issue. Use only these category values:

| Category | Meaning |
| :--- | :--- |
| `Structural Mapping` | Missing table, missing FK, unresolved M:N, missing attribute/column |
| `Key / Relationship` | Wrong PK, FK on wrong side, missing CK, FK nullability mismatch |
| `Domain Constraint` | Wrong enum value, missing NOT NULL, wrong default, missing CHECK, type mismatch |
| `Business Rule Gap` | Database-Enforceable BR not addressed structurally or procedurally |
| `Internal Inconsistency` | DBML code ≠ summary table, ERD diagram notation ≠ ERD text within same document |

Each row must contain:

| Column | Content |
| :--- | :--- |
| **Category** | Exactly one of the five values above |
| **Description of Mismatch** | What is wrong. Be specific: name the column, table, enum value, or line number. Quote mismatched values. |
| **Evidence (Quote Both Sides)** | Exact quotes from both conflicting sources. "Source A line X: `...`; Source B line Y: `...`" |
| **Recommended Fix** | State exactly what to change and where. "In `outputs/03-logical-design.md` line 61, change `inactive` to `disabled`." |

Do **not** add narrative paragraphs above or below the table unless a finding genuinely requires a multi-sentence explanation that cannot fit in a table cell.

---

## Example finding row

| Category | Description of Mismatch | Evidence (Quote Both Sides) | Recommended Fix |
| :--- | :--- | :--- | :--- |
| Domain Constraint | Enum value mismatch in `order_status`: DBML (line 61) lists `canceled`; ERD data dictionary (line 111) and logical design Section 4 (line 245) both use `cancelled`. | DBML line 61: `'canceled'`; ERD line 111 & logical design line 245: `cancelled` | In DBML line 61, change `'canceled'` to `'cancelled'` or confirm intended spelling and update the conflicting source. |

---

## Anti-Hallucination Gate

Before writing the final output, answer these five questions. Each must be answered **"yes" with evidence**:

1. **FK tracing:** Did I verify every schema FK against an ERD relationship line **and** check its nullability against the Mermaid cardinality symbol?
   - Evidence: ___

2. **Enum verification:** Did I compare every schema enum value — exact spelling, character-by-character — against the BR and ERD value lists?
   - Evidence: ___

3. **FK summary cross-check:** Did I compare every row in the FK summary table against its corresponding schema FK declaration and column constraint?
   - Evidence: ___

4. **NOT NULL cross-check:** Did I compare every row in the NOT NULL summary table against its corresponding schema column annotation?
   - Evidence: ___

5. **ERD diagram vs. text:** Did I compare Mermaid diagram cardinality symbols against the Relationship Summary table text for every ERD relationship line?
   - Evidence: ___

If any answer is *not checked* or lacks concrete evidence, do **not** write the output yet. Go back and check that item first.
