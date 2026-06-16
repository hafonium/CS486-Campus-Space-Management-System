# Analysis Review Checklist

## Goal
Validate that the business requirement analysis is complete, grounded, and useful for conceptual database design.

## Final checks
### Business purpose
- Does it explain why the organization needs the system?
- Does it explain the operational problem?
- Does it explain the intended outcome?
- Is it a business summary rather than a feature list?

### System scope
- Are all major business processes represented?
- Are reporting and history needs included if mentioned?
- Is the scope written in business terms rather than schema terms?

### Actors
- Does each actor have a clear role?
- Are actor types distinguished from entities?
- Are role-based actors consolidated when appropriate?

### Candidate entities
- Does every entity have a business reason to exist?
- Are weak candidates excluded if they are only statuses or labels?
- Are associative or transactional entities identified where needed?

### Attributes
- Are attributes attached to the right entity?
- Are identifying attributes visible?
- Are inferred attributes labeled as assumptions?

### Relationships
- Does each relationship use a meaningful verb phrase?
- Are major processes reflected in the relationships?
- Are many-to-many relationships recognized?

### Cardinalities and participation
- Are relationship descriptions written in plain language?
- Is mandatory or optional participation explained where possible?
- Are ambiguous cases marked as assumptions?

### Business rules
- Do the rules reflect major constraints from the requirement?
- Are they precise and testable?
- Do they avoid logical-design or SQL language?

### Assumptions and ambiguities
- Are unclear points listed explicitly?
- Are important unanswered policy questions surfaced?
- Is the output safe for later ERD design?

## Pass condition
The analysis is ready to hand off to conceptual design only if:
- the output is complete,
- the output is grounded in the requirement,
- no major process or constraint is missing,
- assumptions are visible and limited.