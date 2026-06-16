---
name: business-requirement-analysis-db
description: Analyze a database project brief and produce a structured Business Requirement Analysis for conceptual database design. Use this skill when the user asks to identify business purpose, actors, entities, attributes, relationships, cardinalities, participation constraints, and business rules from a case description.
---

# Business Requirement Analysis for Database Projects

## Purpose
This skill helps the agent transform an unstructured project brief into a structured business requirement analysis suitable for Phase 1 of database design.

The final output must help the user prepare for:
- conceptual database design,
- ERD construction,
- logical schema design,
- and later SQL implementation.

## When to use
Use this skill when:
- the user provides a system description, project brief, or case study,
- the user asks for business requirement analysis,
- the user asks to identify actors, entities, attributes, relationships, or business rules,
- the task is the first phase of database design.

Do not use this skill when:
- the user only wants SQL syntax,
- the user only asks for query writing,
- the user already has a finished ERD and only wants table conversion,
- the task is unrelated to database analysis.

## Inputs
The agent should expect:
- a business requirement description or project brief,
- optional assignment instructions,
- optional domain constraints from the lecturer or course.

If key information is missing, ask concise clarifying questions before finalizing the analysis.

## Required outputs
The agent must produce these sections in order:

1. Business purpose
2. System scope
3. Actors
4. Candidate entities
5. Candidate attributes for each entity
6. Relationships among entities
7. Cardinalities and participation constraints
8. Business rules
9. Assumptions and ambiguities

## Workflow

### Step 1: Read and segment the requirement
- Read the full requirement carefully.
- Separate background, operational processes, constraints, statuses, and reporting needs.
- Identify nouns as candidate entities and verbs as candidate relationships.
- Identify rule-like statements such as “must”, “cannot”, “should”, “may”, and “only”.

### Step 2: Identify the business purpose
Write a concise business-purpose paragraph of 2–3 sentences.

The paragraph must answer all three questions:
- Why does the organization need this system?
- What operational problem(s) does it solve?
- What business outcome(s) does it support?

The paragraph must:
- summarize the requirement in distilled form,
- focus on organizational purpose and operational control,
- use plain business language,
- avoid implementation details such as tables, SQL, or database structure.

The paragraph must not:
- copy or closely paraphrase the requirement text,
- list features without explaining their purpose,
- describe entity names or schema concepts,
- repeat background details that do not change the core purpose.

Good pattern:
"The system is needed to centralize and control the booking and operational management of shared campus spaces. It solves the current manual coordination problems such as double-booking, unclear approvals, and poor visibility into maintenance status. It supports fair space allocation, operational efficiency, and historical tracking for planning and oversight."

Bad pattern:
"This system manages spaces, bookings, approvals, maintenance, and facility utilization." 
This is only a feature restatement, not a business-purpose summary.

### Step 3: Identify actors
List all human or organizational actors that interact with the system.
For each actor, provide:
- actor name,
- role in the business process,
- typical actions in the system.

If multiple actor types are really roles of one person category, note that they may later be modeled as roles of a User entity.

### Step 4: Identify candidate entities
Extract the major business objects that need stored data.
Include only objects with meaningful attributes, repeated use, or relationships.

For each candidate entity:
- give a short definition,
- explain why it should be stored,
- distinguish strong entities from associative/transactional entities when relevant.

Do not treat every noun as an entity.
Exclude temporary values, interface labels, or purely descriptive phrases.

### Step 5: Identify attributes
For each entity:
- list likely identifying attributes,
- list descriptive attributes,
- list status/time-related attributes if mentioned,
- mark likely primary key candidates if obvious.

Prefer attributes explicitly supported by the requirement.
If an attribute is inferred, mark it as an assumption.

### Step 6: Identify relationships
For each pair of related entities:
- write the relationship using a verb phrase,
- explain the business meaning,
- note whether the relationship is direct or resolved through an associative entity.

Examples:
- User submits Booking
- Space has Facility
- Booking is approved by Staff
- Space has MaintenanceRecord

### Step 7: Determine cardinalities and participation
For each relationship:
- identify whether it is 1:1, 1:N, or M:N,
- identify mandatory or optional participation where possible,
- justify the decision with wording from the requirement.

If the requirement is ambiguous, state the most reasonable assumption and label it clearly.

### Step 8: Extract business rules
Write business rules as short numbered statements.
Rules should be precise, testable, and relevant to later ERD/schema design.

Focus on:
- uniqueness,
- role restrictions,
- status constraints,
- time overlap constraints,
- approval constraints,
- maintenance restrictions,
- history retention,
- validation limits such as capacity.

### Step 9: Flag assumptions and ambiguities
Create a short section listing:
- missing details,
- unclear policies,
- assumptions made by the agent,
- questions the team should confirm before final ERD design.

## Quality rules
The agent must always:
- separate business analysis from logical schema design,
- use domain language from the requirement,
- distinguish actors from entities,
- distinguish entities from attributes,
- explain relationship meaning in plain language,
- include cardinalities only when supported or reasonably inferred,
- mark assumptions explicitly.

The agent must never:
- invent business processes not grounded in the requirement,
- convert directly to SQL in this skill,
- treat every status value as a separate entity,
- confuse a role with a department,
- present uncertain facts as confirmed requirements.

## Output template

Use this structure:

### 1. Business purpose
[short paragraph]

### 2. System scope
- [scope item]
- [scope item]

### 3. Actors
- **Actor name**: [role and actions]

### 4. Candidate entities
- **Entity name**: [definition and rationale]

### 5. Candidate attributes
- **Entity name**: [attribute 1, attribute 2, attribute 3]

### 6. Relationships
- **Entity A — relationship — Entity B**: [explanation]

### 7. Cardinalities and participation
- **Relationship**: [cardinality, participation, justification]

### 8. Business rules
1. [rule]
2. [rule]

### 9. Assumptions and ambiguities
- [assumption or open question]

## Review checklist
Before finishing, verify:
- every actor has a business role,
- every entity has a reason to exist,
- every major process in the requirement is represented,
- rules match the original brief,
- no major constraint is omitted,
- ambiguities are listed clearly.

## Example trigger
User says:
“Analyze this requirement and identify business purpose, actors, entities, attributes, relationships, cardinalities, and business rules.”

Expected behavior:
- read the brief,
- produce the 9 sections above,
- keep the explanation suitable for a university database design report.