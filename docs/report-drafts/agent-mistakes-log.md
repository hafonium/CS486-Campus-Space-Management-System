# OpenCode Error & Correction Log
*(Copying these entries into the final PDF satisfies the "Agent Improvement Process" rubric)*

### Error 1: Missing Temporal Check Constraint
* **Phase:** Stage 5 (SQL Generation)
* **What OpenCode did wrong:** Created the `Bookings` table without verifying that `start_time` comes before `end_time`.
* **How we fixed it:** Driver ran the prompt: *"You forgot to enforce time directionality. Alter the Bookings table to add a CHECK constraint ensuring end_time > start_time."*
* **Skill.md Update:** Added a global rule instructing the agent to always add temporal check constraints to any table with two timestamps.