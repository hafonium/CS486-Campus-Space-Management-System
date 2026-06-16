Business Requirement Analysis: Campus Space Management System
1. Business purpose
The School of Computer Science needs to replace its manual, ad-hoc space-booking process — currently handled via email, phone, and shared spreadsheets — with a centralized database system. The system will automate space availability checks, enforce booking conflict prevention, track maintenance status, and preserve a full audit trail of bookings, approvals, usage sessions, and maintenance activities. This will enable fair allocation of limited physical spaces, reduce scheduling errors, prevent use of unavailable rooms, and give management visibility into facility utilization.
2. System scope
- User account management (registration, role assignment, account status)
- Bookable space inventory with type, location, capacity, status, and usage policy
- Facility/equipment tracking per space
- Booking request submission, approval/rejection workflow, and status lifecycle
- Session check-in and check-out with condition recording and usage notes
- Maintenance record management (reporting, assignment, tracking, resolution)
- Historical record-keeping for bookings and maintenance
- Staff-facing queries: booking history, upcoming bookings, spaces under maintenance, no-show bookings
Build·DeepSeek V4 Pro
- Conflict prevention: no overlapping approved bookings for the same space; no booking of spaces under maintenance, closed, or retired
3. Actors
- Student: requests spaces for student activities and projects; submits booking requests.
- Lecturer: requests spaces for lectures, examinations, seminars, workshops; submits booking requests.
- Teaching Assistant: supports courses; may request spaces for tutorials or lab sessions; submits booking requests.
- Facility Staff: handles day-to-day space operations; reviews and approves/rejects bookings; performs check-in and check-out; reports and handles maintenance issues.
- Department Administrator: oversees departmental activities; may request spaces for administrative events and meetings.
- Facility Manager: oversees facility operations; may have elevated approval authority; defines usage policies.
All actor types are modeled as roles of a single User entity, not as separate entities.
4. Candidate entities
- User — any person with a university account who interacts with the system. Roles include student, lecturer, teaching assistant, facility staff, department administrator, and facility manager. Must be stored because every action (booking, approval, check-in, maintenance reporting) is attributed to a specific user.
- Space — a bookable physical room or area managed by the School. Includes classrooms, computer laboratories, meeting rooms, auditoriums, project laboratories, and student workspaces. Must be stored because it is the central resource being scheduled and maintained. Each space has a unique identity, location, capacity, status, and usage policy.
- Facility — a piece of equipment or amenity available in a space (projector, whiteboard, microphone, computer, livestreaming equipment, air conditioner). Must be stored because the requirement explicitly states "the system should store the list of facilities available in each space." The relationship between Space and Facility is many-to-many: one space may have many facility types, and one facility type may appear in many spaces.
- Booking — a request to reserve a specific space for a defined time period with a stated purpose and expected number of participants. This is the core transactional entity that drives the entire workflow. Must be stored to track the full lifecycle from submission through approval, check-in, completion, or no-show. Historical bookings must be retained.
- MaintenanceRecord — a record of a problem reported for a space, tracking the reporter, assigned staff, problem description, time window, status, and resolution. Must be stored because the requirement mandates maintenance management with historical records. A space under maintenance must be blocked from new bookings.
5. Candidate attributes
- User:
- user_id (PK candidate)
- full_name
- email
- phone_number
- role — one of: student, lecturer, teaching_assistant, facility_staff, department_admin, facility_manager
- department
- account_status — presumably active, suspended, inactive
- Space:
- space_code (PK candidate — "unique space code")
- space_name
- space_type — one of: auditorium, classroom, computer_lab, project_lab, meeting_room, student_workspace
- building
- floor
- room_number
- capacity
- current_status — one of: available, in_use, under_maintenance, temporarily_closed, retired
- usage_policy
- Facility:
- facility_id (PK candidate)
- facility_name — e.g., projector, whiteboard, microphone, computer, livestreaming_equipment, air_conditioner
- Booking:
- booking_id (PK candidate)
- requested_start_time
- requested_end_time
- purpose_of_use — one of: lecture, examination, seminar, workshop, meeting, student_activity, administrative_event
- expected_participants
- status — one of: pending, approved, rejected, cancelled, checked_in, completed, no_show
- decision_time — timestamp when approved or rejected
- decision_note
- rejection_reason
- actual_start_time — recorded at check-in
- checked_in_by — FK to User (facility staff who performed check-in)
- initial_condition — space condition at check-in
- actual_end_time — recorded at completion
- final_condition — space condition at completion
- usage_notes
- MaintenanceRecord:
- maintenance_id (PK candidate)
- problem_description
- start_time — when the problem was reported or maintenance began
- completion_time — when maintenance was finished
- status — presumably: reported, in_progress, resolved, etc. (not explicitly enumerated in the requirement; marked as assumption)
- result_note
6. Relationships
- User — submits — Booking: a user creates a booking request for a space.
- Booking — reserves — Space: a booking request targets one specific space.
- Booking — decided_by — User (approval): a facility staff member or manager approves or rejects a booking.
- Booking — checked_in_by — User: a facility staff member records the check-in for a booking.
- Booking — checked_out_by — User (completion): a facility staff member records the completion of a booking session.
- Space — has — Facility: a space is equipped with one or more facilities (M:N).
- User — reports — MaintenanceRecord: a user (any) reports a maintenance problem for a space.
- MaintenanceRecord — concerns — Space: a maintenance record refers to the affected space.
- User — assigned_to — MaintenanceRecord: a staff member is assigned to handle a maintenance record.
7. Cardinalities and participation
- User submits Booking: 1 : N. One user may submit many bookings; each booking is submitted by exactly one user. Mandatory on the Booking side (every booking must have a requester); optional on the User side (a user may never submit a booking).
- Booking reserves Space: N : 1. Many bookings may target the same space; each booking is for exactly one space. Mandatory on both sides (every booking requires a space; every booking-capable space may receive bookings, though some spaces may never be booked — optional in practice).
- Booking decided_by User (approval): N : 1. Many bookings may be approved/rejected by the same staff member; each decision is made by exactly one staff member. Optional on the Booking side (a booking may remain pending and never be decided); optional on the User side (a staff member may never make a decision).
- Booking checked_in_by User: N : 1. Many bookings may be checked in by the same staff member; each check-in is performed by exactly one staff member. Optional on the Booking side (a booking may be rejected, cancelled, or become a no-show before check-in); optional on the User side.
- Booking checked_out_by User (completion): N : 1. Many bookings may be completed by the same staff member; each completion is performed by exactly one staff member. Optional on the Booking side (a booking must be checked in before it can be completed, and may never reach that state); optional on the User side.
- Space has Facility: M : N. One space may contain many facility types; one facility type may be available in many spaces. Participation is optional on both sides (a space may have no facilities recorded; a facility type may not be present in any space). (Assumption: Facility is modeled as a facility-type entity; resolved through an associative entity SpaceFacility.)
- User reports MaintenanceRecord: 1 : N. One user may report many maintenance issues; each maintenance record has exactly one reporter. Mandatory on the MaintenanceRecord side; optional on the User side.
- MaintenanceRecord concerns Space: N : 1. Many maintenance records may refer to the same space; each record is for exactly one space. Mandatory on the MaintenanceRecord side; optional on the Space side.
- User assigned_to MaintenanceRecord: N : 1. Many maintenance records may be assigned to the same staff member; each record is assigned to exactly one staff member. Optional on the MaintenanceRecord side (a newly reported issue may not yet have an assignee); optional on the User side.
8. Business rules
 1. Each user must have a unique university account (identified by user_id).
 2. Each space must have a unique space_code.
 3. The same space cannot have two bookings both in approved status with overlapping time periods.
 4. A space with current_status of under_maintenance, temporarily_closed, or retired cannot be booked (no new booking may be submitted or approved for that space).
 5. Only a user whose role is facility_staff or facility_manager may approve or reject a booking.
 6. Only a user whose role is facility_staff or facility_manager may perform check-in or check-out for a booking.
 7. When a booking is approved or rejected, the system must record the deciding staff member, decision timestamp, and a decision note; if rejected, a rejection reason must be stored.
 8. A booking must be in approved status before it can be checked in.
 9. A booking must be in checked_in status before it can be completed.
10. When check-in occurs, the system must record the actual start time, the checking-in staff member, and the initial space condition.
11. When a session is completed, the system must record the actual end time, the final space condition, and any usage notes.
12. A space under maintenance (i.e., having an unresolved maintenance record) must have its current_status set to under_maintenance, which prevents booking per Rule 4.
13. Each maintenance record must be linked to exactly one space and exactly one reporter.
14. The system must retain historical records of all bookings and maintenance activities (no deletion, only status transitions).
15. The expected_participants for a booking must not exceed the capacity of the selected space.
16. A booking's requested_end_time must be strictly later than its requested_start_time.
9. Assumptions and ambiguities
- User roles: The requirement lists six roles (student, lecturer, teaching assistant, facility staff, department administrator, facility manager) but does not specify whether a user may hold multiple roles simultaneously (e.g., a lecturer who is also a department administrator). Assumed: one user has one primary role at a time.
- Facility modeling: The requirement says "the system should store the list of facilities available in each space" with examples like projector and whiteboard. It is ambiguous whether Facility is a standalone entity (a named equipment type) or an attribute list on Space. Assumed: Facility is a separate entity with an M:N relationship to Space, treated as equipment types.
- Maintenance status values: The requirement mentions maintenance record "status" but does not enumerate the status values. Assumed: at minimum reported, in_progress, and resolved.
- No-show detection: The requirement lists no_show as a booking status but does not explain how or when a booking is marked as no-show (e.g., automatically after a grace period, or manually by staff). Needs clarification.
- Cancellation policy: The cancelled status is mentioned but the requirement does not specify who may cancel a booking, at what stage, or whether cancellation differs from rejection. Assumed: either the requester or staff may cancel a booking that is not yet completed.
- Conflict detection granularity: The requirement says "the same space cannot have two approved bookings with overlapping time periods" but does not address whether back-to-back bookings (end time equals start time of the next) are allowed. Assumed: back-to-back is allowed (strict overlap only).
- Recurring bookings: No mention of repeating weekly or semester-long booking patterns. Assumed: not in scope; each booking is a single occurrence.
- Booking priority or waitlist: No mention of how to resolve competing requests for the same time slot (first-come-first-served, priority by role, etc.). Needs clarification.
- Space capacity enforcement: The rule that expected_participants ≤ capacity is inferred ("expected number of participants" is recorded, and "capacity" is stored) but not explicitly stated as a constraint. Treated as assumed business rule.
- Usage policy: The requirement mentions usage_policy for spaces but does not describe its format, content, or how it affects booking eligibility. Needs clarification.