# Architectural Trade-offs
*(Copying these into the final PDF proves original engineering thought)*

### 1. Hard Deletes vs. Soft Deletes
* **Debate:** Should users be completely deleted from the database if they leave the university?
* **Decision:** Soft Deletion. We added an `is_active` BOOLEAN column to the `Users` table instead of using `DELETE` queries.
* **Justification:** Hard deleting a user would either orphan their historical booking records or require cascading deletes, which ruins historical campus usage analytics. Soft deletion preserves referential integrity.