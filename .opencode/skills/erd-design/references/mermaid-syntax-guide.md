# Mermaid.js ERD Syntax Guide

## Goal
Format the conceptual design into a strictly valid Mermaid.js string that can be rendered visually without syntax errors, maintaining consistent casing and readable layout directions.

## Basic Structure
- The block must start with `erDiagram`.
- Do not use markdown bolding (`**`) or italics (`*`) inside the Mermaid code block.

## Relationship Syntax & Directionality
Use exact Mermaid operators for connections:
- `||--||` : One-to-One
- `||--o{` : One-to-Many
- `}|--|{` : Many-to-Many

**Readability Rule (Left-to-Right Layout):**
Mermaid draws diagrams based on the order entities are declared. To make the diagram readable, always place the **independent/parent entity on the left**, and the **dependent/child entity on the right**.
- Format: `PARENT_ENTITY [operator] CHILD_ENTITY : "verb phrase"`
- **GOOD:** `USER ||--o{ BOOKING_REQUEST : "submits"` (Draws cleanly left to right)
- **BAD:** `BOOKING_REQUEST }o--|| USER : "submitted by"` (Draws backward and tangles lines)

## Entity Syntax
Define entities using curly braces. Put attributes inside.
Format:
```mermaid
ENTITY_NAME {
    type AttributeName PK
    type AttributeName
}
```

## Formatting & Casing Rules (CRITICAL)
- **Entity Names:** MUST be strictly UPPER_SNAKE_CASE across the entire output (e.g., USER, MAINTENANCE_RECORD). Do not use TitleCase (e.g., User). This ensures consistency with the Step 1 analysis.
- **Attribute Names:** MUST be strictly snake_case (e.g., user_id, full_name). Do not use spaces.
- **Data Types:** Valid conceptual types: string, int, float, boolean, datetime.

## Self-check
Before generating the Mermaid block:
- Are ALL Entity names strictly UPPER_SNAKE_CASE in both the Mermaid block and the Data Dictionary?
- Are the parent/independent entities placed on the left side of the relationship lines to ensure a clean visual layout?
- Did I remove all spaces from Entity and Attribute names?
- Did I ensure no markdown formatting (like ) leaked inside the Mermaid code block?