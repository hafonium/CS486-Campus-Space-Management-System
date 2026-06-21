# Reference: Candidate Keys & Uniqueness Constraints

## 1. Definition & Identification
A Candidate Key (CK) is a minimal set of attributes that can uniquely identify a tuple in a relation, excluding the designated Primary Key. 
* *Universal Examples:* Institutional Identifiers (Tax ID, Student ID), Digital Contacts (Email, Phone Number), or exact spatial coordinates `(building, floor, room)`.

## 2. DBML Syntax Standard
* **Single-Attribute CK:** Must carry the explicit `[unique]` modifier inside its inline attribute definition.
  ```dbml
  email varchar(120) [not null, unique]
  phone_number varchar(20) [not null, unique]
  ```
* **Composite Candidate Key:** Must be declared inside an explicit `Indexes` block at the bottom of the table definition using the `[unique]` flag.
  ```dbml
  Indexes {
    (parent_code, sub_sequence) [unique, name: 'uq_record_locator']
  }
  ```

## 3. Strict Documentation Synchronization
**Mandatory Verification:** The LLM must ensure a 100% mathematical bijection between the DBML code and Section 2 (Primary Keys & Candidate Keys subsection) of the written report:
1. If an attribute carries `[unique]` in the DBML, it **must** be explicitly bulleted as a Candidate Key in the text.
2. If the text defines an attribute as a Candidate Key, it **must** carry the `[unique]` tag in the DBML block.