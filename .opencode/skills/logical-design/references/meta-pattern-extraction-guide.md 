# Reference: Meta-Pattern Business Logic Extraction Guide

## 1. The Core Philosophy
Relational databases enforce structural integrity via Primary Keys and Foreign Keys. However, real-world business constraints (Business Rules from Step 1) rarely fit into standard DDL tags. 

To prevent LLM hallucination and project overfitting, the agent must never hard-code project specific examples. Instead, it must classify every raw business rule into one of three strict **Meta-Patterns**, and map them to standard **T-SQL implementation mechanisms**.

---

## Pattern 1: Single-Column Value Boundaries (Scalar Domain Checks)

### Definition
A mathematical or categorical limitation imposed strictly on a single scalar attribute, completely independent of any other column in the table.

### Triggering NLP Keywords
* *"must be positive"*, *"cannot exceed..."*, *"minimum value is..."*, *"can only be either X, Y, or Z"*, *"must be a valid percentage"*.

### T-SQL Enforcement Mechanism
Explicit table-level `CHECK` constraint in **Section 3**.

### Transformation Blueprint
* **Raw NLP:** *"An employee's commission rate cannot be higher than 35%."*
* **Meta-Classification:** Single-Column Upper Boundary.
* **Target Output (Section 3):** `chk_employee_commission_max`: `CHECK (commission_rate BETWEEN 0.00 AND 0.35)`

* **Raw NLP:** *"The document priority must be Low, Medium, High, or Urgent."*
* **Meta-Classification:** Categorical Finite Domain. *(Remember: T-SQL bans Enums!)*
* **Target Output (Section 3):** `chk_document_priority_domain`: `CHECK (priority_level IN ('Low', 'Medium', 'High', 'Urgent'))`

---

## Pattern 2: Intra-Record Dependencies (Tuple-Level Checks)

### Definition
A logical, chronological, or mathematical relationship where the validity of **Column B** depends entirely on the state of **Column A** *within the exact same row*.

### Triggering NLP Keywords
* *"if [Col A] is X, then [Col B] must be..."*, *"cannot end before it starts"*, *"is required only when..."*.

### T-SQL Enforcement Mechanism
Explicit table-level `CHECK` constraint using Propositional Logic ($P \implies Q \equiv \neg P \lor Q$) in **Section 3**.

### Transformation Blueprint
* **Raw NLP:** *"A project's actual completion date cannot occur before its official start date."*
* **Meta-Classification:** Intra-Record Chronological Progression.
* **Target Output (Section 3):** `chk_project_timeline_order`: `CHECK (actual_end_date >= start_date)`

* **Raw NLP:** *"If an issue ticket is marked as 'Resolved', the resolution summary text cannot be left empty."*
* **Meta-Classification:** State-Contingent Nullability ($Status = 'Resolved' \implies Summary \neq NULL$).
* **Target Output (Section 3):** `chk_ticket_resolved_summary`: `CHECK (ticket_status <> 'Resolved' OR resolution_summary IS NOT NULL)`

---

## Pattern 3: Multi-Row & Cross-Table Procedural Exclusions

### Definition
Any business rule that cannot be evaluated by looking at a single row in isolation. It requires aggregating *other rows* in the same table, or checking states across *entirely different tables*. 
*(Standard T-SQL CHECK constraints cannot reference other tables or run sub-queries).*

### Triggering NLP Keywords
* *"no two active X can overlap"*, *"a user cannot have more than 5..."*, *"balance cannot drop below the sum of..."*, *"state can only move from Draft -> Submitted -> Approved"*.

### T-SQL Enforcement Mechanism
Documented strictly in **Section 4 (Architectural Assumptions)** as requiring procedural enforcement: **Application Logic, Stored Procedures, or `AFTER / INSTEAD OF` Triggers**.

### Transformation Blueprint
* **Raw NLP:** *"A professor cannot be assigned to teach two different classes happening at the exact same time."*
* **Meta-Classification:** Cross-Tuple Temporal Overlap Exclusion.
* **Target Output (Section 4):**
  * **Rule:** `Preventing Professor Schedule Collision`.
  * **Enforcement Strategy:** Must be enforced via an `INSTEAD OF INSERT/UPDATE` T-SQL Trigger or Application Middleware. The transaction must check: `IF EXISTS (SELECT 1 FROM ClassSchedule WHERE professor_id = @prof_id AND start_time < @new_end AND end_time > @new_start) RAISERROR(...)`.

* **Raw NLP:** *"An order cannot be moved to 'Shipped' if any of its line items are currently 'Out of Stock'."*
* **Meta-Classification:** Cross-Entity Aggregate Gate.
* **Target Output (Section 4):**
  * **Rule:** `Strict Pre-Shipment Stock Gate`.
  * **Enforcement Strategy:** Enforced via a Pre-update Stored Procedure performing an inner join check between `ORDERS` and `ORDER_LINE_ITEMS` prior to committing the status update.

---

## Pre-Flight Agent Checklist for Step 6
When writing Sections 3 and 4, ask yourself:
1. Did I accidentally write a sub-query inside a `CHECK()`? *(If yes, move it to Section 4).*
2. Did I use an `Enum` to solve a finite list? *(If yes, delete it and use Pattern 1 `IN (...)` check).*
3. Is my Boolean check written as `col = true`? *(If yes, fix it to T-SQL standard: `col = 1`).*