# Core Database Entities & Attributes

*Note for AI Agent: Use strictly these entities and columns. Do not hallucinate extra fields.*

### 1. Users
* `user_id` (Primary Key, INT, Auto-increment)
* `full_name` (VARCHAR)
* `email` (VARCHAR, Unique)
* `role` (VARCHAR - Must be 'STUDENT', 'FACULTY', or 'ADMIN')