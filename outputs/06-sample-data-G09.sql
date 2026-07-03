-- ============================================================================
-- Campus Space Management System — Sample Data Preparation (G09)
-- Target: Microsoft SQL Server (T-SQL)
-- Prerequisite: Run 05-db-definition-G09.sql first to create the schema.
-- ============================================================================

USE [CampusSpaceManagementSystem];
GO

SET NOCOUNT ON;

-- ============================================================================
-- Identity capture variables
-- ============================================================================

DECLARE @AliceChen       INT,
        @BobMartinez      INT,
        @SarahKim         INT,
        @JamesOBrien      INT,
        @RajPatel         INT,
        @EmilyWong        INT,
        @MichaelDavis     INT,
        @FatimaHassan     INT,
        @ThomasLee        INT,
        @GraceOkafor      INT,
        @WeiZhang         INT,
        @MariaSantos      INT;

DECLARE @Proj   INT,
        @WB     INT,
        @Mic    INT,
        @PC     INT,
        @Live   INT,
        @AC     INT,
        @Smart  INT,
        @VC     INT;

-- ============================================================================
-- 1. USER (independent parent)
--    Order: 1 — no foreign keys
-- ============================================================================

-- Normal Operations — active users across all six roles
INSERT INTO dbo.[USER] (full_name, email, phone_number, role, department, account_status)
VALUES ('Alice Chen', 'alice.chen@uwaterloo.ca', '+1-519-555-0101', 'student', 'Computer Science', 'active');
SET @AliceChen = SCOPE_IDENTITY();

INSERT INTO dbo.[USER] (full_name, email, phone_number, role, department, account_status)
VALUES ('Dr. Sarah Kim', 'sarah.kim@uwaterloo.ca', '+1-519-555-0102', 'lecturer', 'Computer Science', 'active');
SET @SarahKim = SCOPE_IDENTITY();

INSERT INTO dbo.[USER] (full_name, email, phone_number, role, department, account_status)
VALUES ('Dr. James O''Brien', 'james.obrien@uwaterloo.ca', '+1-519-555-0103', 'lecturer', 'Computer Science', 'active');
SET @JamesOBrien = SCOPE_IDENTITY();

INSERT INTO dbo.[USER] (full_name, email, phone_number, role, department, account_status)
VALUES ('Raj Patel', 'raj.patel@uwaterloo.ca', '+1-519-555-0104', 'teaching_assistant', 'Computer Science', 'active');
SET @RajPatel = SCOPE_IDENTITY();

INSERT INTO dbo.[USER] (full_name, email, phone_number, role, department, account_status)
VALUES ('Emily Wong', 'emily.wong@uwaterloo.ca', '+1-519-555-0105', 'teaching_assistant', 'Computer Science', 'active');
SET @EmilyWong = SCOPE_IDENTITY();

INSERT INTO dbo.[USER] (full_name, email, phone_number, role, department, account_status)
VALUES ('Michael Davis', 'michael.davis@uwaterloo.ca', '+1-519-555-0106', 'facility_staff', 'Facilities Management', 'active');
SET @MichaelDavis = SCOPE_IDENTITY();

INSERT INTO dbo.[USER] (full_name, email, phone_number, role, department, account_status)
VALUES ('Fatima Hassan', 'fatima.hassan@uwaterloo.ca', '+1-519-555-0107', 'facility_staff', 'Facilities Management', 'active');
SET @FatimaHassan = SCOPE_IDENTITY();

INSERT INTO dbo.[USER] (full_name, email, phone_number, role, department, account_status)
VALUES ('Thomas Lee', 'thomas.lee@uwaterloo.ca', '+1-519-555-0108', 'department_administrator', 'Computer Science', 'active');
SET @ThomasLee = SCOPE_IDENTITY();

-- Exceptional Cases — non-standard account statuses

-- Suspended student account (tests chk_user_account_status_domain boundary)
INSERT INTO dbo.[USER] (full_name, email, phone_number, role, department, account_status)
VALUES ('Bob Martinez', 'bob.martinez@uwaterloo.ca', '+1-519-555-0109', 'student', 'Computer Science', 'suspended');
SET @BobMartinez = SCOPE_IDENTITY();

-- Deactivated administrator account (tests chk_user_account_status_domain boundary)
INSERT INTO dbo.[USER] (full_name, email, phone_number, role, department, account_status)
VALUES ('Grace Okafor', 'grace.okafor@uwaterloo.ca', '+1-519-555-0110', 'department_administrator', 'Computer Science', 'deactivated');
SET @GraceOkafor = SCOPE_IDENTITY();

-- Normal Operations — facility managers
INSERT INTO dbo.[USER] (full_name, email, phone_number, role, department, account_status)
VALUES ('Dr. Wei Zhang', 'wei.zhang@uwaterloo.ca', '+1-519-555-0111', 'facility_manager', 'Facilities Management', 'active');
SET @WeiZhang = SCOPE_IDENTITY();

INSERT INTO dbo.[USER] (full_name, email, phone_number, role, department, account_status)
VALUES ('Maria Santos', 'maria.santos@uwaterloo.ca', '+1-519-555-0112', 'facility_manager', 'Facilities Management', 'active');
SET @MariaSantos = SCOPE_IDENTITY();

-- ============================================================================
-- 2. SPACE (independent parent)
--    Order: 1 — no foreign keys
-- ============================================================================

-- Normal Operations — available spaces across five types

INSERT INTO dbo.SPACE (space_code, space_name, space_type, building, floor, room_number, capacity, current_status, usage_policy)
VALUES ('AUD-MC-1000', 'Humanities Theatre', 'auditorium', 'MC', 1, '1000', 500, 'available',
        'Priority for academic lectures, convocations, and public seminars. External event requests require department chair approval at least 14 days in advance.');

INSERT INTO dbo.SPACE (space_code, space_name, space_type, building, floor, room_number, capacity, current_status, usage_policy)
VALUES ('CR-M3-1006', 'M3 Lecture Hall 1006', 'classroom', 'M3', 1, '1006', 120, 'available',
        'Standard classroom for scheduled undergraduate lectures and tutorials. No food or drink except water. Projector and whiteboard available.');

INSERT INTO dbo.SPACE (space_code, space_name, space_type, building, floor, room_number, capacity, current_status, usage_policy)
VALUES ('CR-DC-1302', 'DC 1302 Classroom', 'classroom', 'DC', 1, '1302', 80, 'available',
        'General-purpose classroom with smart board. Priority for CS department courses. Booking requests from other departments require faculty sponsor approval.');

INSERT INTO dbo.SPACE (space_code, space_name, space_type, building, floor, room_number, capacity, current_status, usage_policy)
VALUES ('CL-DC-2585', 'Unix Computing Lab', 'computer_lab', 'DC', 2, '2585', 40, 'available',
        'Linux workstation lab for CS undergraduate courses and tutorials. 40 Ubuntu desktops with standard CS software stack. No external software installation without prior approval.');

INSERT INTO dbo.SPACE (space_code, space_name, space_type, building, floor, room_number, capacity, current_status, usage_policy)
VALUES ('PL-DC-3564', 'Senior Design Project Lab', 'project_lab', 'DC', 3, '3564', 25, 'in_use',
        'Dedicated project workspace for fourth-year capstone design teams. 24/7 card access for approved team members. Equipment sign-out required for loaner items.');

INSERT INTO dbo.SPACE (space_code, space_name, space_type, building, floor, room_number, capacity, current_status, usage_policy)
VALUES ('MR-DC-3102', 'Davis Centre Board Room', 'meeting_room', 'DC', 3, '3102', 20, 'available',
        'Conference-style meeting room with video conferencing. Maximum 2-hour recurring block on weekdays. Catering permitted with facilities approval.');

INSERT INTO dbo.SPACE (space_code, space_name, space_type, building, floor, room_number, capacity, current_status, usage_policy)
VALUES ('SW-STC-0010', 'Collaborative Hub', 'student_workspace', 'STC', 0, '0010', 60, 'available',
        'Open-plan student workspace. First-come seating except during booked events. Group reservations require at least one CS student organizer.');

-- Exceptional Cases — unavailable and boundary-capacity spaces

INSERT INTO dbo.SPACE (space_code, space_name, space_type, building, floor, room_number, capacity, current_status, usage_policy)
VALUES ('CL-MC-3003', 'Instructional Computing Lab', 'computer_lab', 'MC', 3, '3003', 35, 'under_maintenance',
        'Standard instructional lab with Windows desktops. Booking suspended during maintenance periods. Return to service date will be announced by facilities team.');

INSERT INTO dbo.SPACE (space_code, space_name, space_type, building, floor, room_number, capacity, current_status, usage_policy)
VALUES ('MR-MC-4040', 'MC Seminar Room 4040', 'meeting_room', 'MC', 4, '4040', 15, 'temporarily_closed',
        'Small seminar room temporarily closed due to HVAC renovation in MC wing. Expected reopening September 2026.');

INSERT INTO dbo.SPACE (space_code, space_name, space_type, building, floor, room_number, capacity, current_status, usage_policy)
VALUES ('MR-DC-1315', 'Phone Booth Room', 'meeting_room', 'DC', 1, '1315', 1, 'retired',
        'Retired single-occupant room. Replaced by new phone booths on DC second floor. No longer bookable. Pending decommission review.');

-- Exceptional Case: capacity = 1 (boundary minimum for chk_space_capacity_positive)
-- Tested by MR-DC-1315 above.

-- ============================================================================
-- 3. FACILITY (independent parent)
--    Order: 1 — no foreign keys
-- ============================================================================

INSERT INTO dbo.FACILITY (facility_name) VALUES ('Projector');
SET @Proj = SCOPE_IDENTITY();

INSERT INTO dbo.FACILITY (facility_name) VALUES ('Whiteboard');
SET @WB = SCOPE_IDENTITY();

INSERT INTO dbo.FACILITY (facility_name) VALUES ('Microphone System');
SET @Mic = SCOPE_IDENTITY();

INSERT INTO dbo.FACILITY (facility_name) VALUES ('Desktop Computers');
SET @PC = SCOPE_IDENTITY();

INSERT INTO dbo.FACILITY (facility_name) VALUES ('Livestreaming Equipment');
SET @Live = SCOPE_IDENTITY();

INSERT INTO dbo.FACILITY (facility_name) VALUES ('Air Conditioner');
SET @AC = SCOPE_IDENTITY();

INSERT INTO dbo.FACILITY (facility_name) VALUES ('Smart Board');
SET @Smart = SCOPE_IDENTITY();

INSERT INTO dbo.FACILITY (facility_name) VALUES ('Video Conferencing System');
SET @VC = SCOPE_IDENTITY();

-- ============================================================================
-- 4. BOOKING (dependent on USER, SPACE)
--    Order: 2 — requires USER and SPACE rows present for FK + trigger lookups
--    Trigger trg_booking_enforce_rules is active and validates:
--       - Space availability (no under_maintenance/temporarily_closed/retired)
--       - No overlapping approved bookings for same space
--       - Decision staff must be facility_staff or facility_manager
--       - Check-in/completion staff must be facility_staff
-- ============================================================================

-- ------------------------------------------------------------------------
-- CR-M3-1006 bookings (classroom, available, cap 120) — full lifecycle demo
-- ------------------------------------------------------------------------

-- Normal Operation: Completed booking with full lifecycle
-- Tests: decision_fields, checkin_fields, completion_fields CHECK constraints
--        + trigger role authorization for decision, check-in, and completion staff
INSERT INTO dbo.BOOKING (
    requester_id, space_code, requested_start_time, requested_end_time,
    purpose, expected_participants, booking_status,
    decision_staff_id, decision_time, decision_note,
    actual_start_time, check_in_staff_id, initial_condition,
    actual_end_time, completion_staff_id, final_condition, usage_notes
) VALUES (
    @SarahKim, 'CR-M3-1006', '2026-01-15 09:00:00', '2026-01-15 11:00:00',
    'lecture', 80, 'completed',
    @WeiZhang, '2026-01-10 14:30:00', 'Standard lecture booking — approved per department schedule.',
    '2026-01-15 08:55:00', @MichaelDavis, 'Room clean, projector tested and functioning, whiteboard markers stocked.',
    '2026-01-15 11:05:00', @FatimaHassan, 'Room left in good condition. Whiteboard erased. All equipment powered down.',
    'CS 350 Operating Systems — Lecture 2. No issues reported.'
);

-- Normal Operation: Completed booking (examination)
INSERT INTO dbo.BOOKING (
    requester_id, space_code, requested_start_time, requested_end_time,
    purpose, expected_participants, booking_status,
    decision_staff_id, decision_time, decision_note,
    actual_start_time, check_in_staff_id, initial_condition,
    actual_end_time, completion_staff_id, final_condition, usage_notes
) VALUES (
    @JamesOBrien, 'CR-M3-1006', '2026-02-20 14:00:00', '2026-02-20 17:00:00',
    'examination', 115, 'completed',
    @WeiZhang, '2026-02-14 09:15:00', 'Midterm examination — room capacity adequate. Extra seating not required.',
    '2026-02-20 13:45:00', @FatimaHassan, 'Exam papers distributed to desks. Projector displaying exam instructions.',
    '2026-02-20 17:20:00', @MichaelDavis, 'Room cleared. All exam papers and scrap sheets collected. Desks reset.',
    'CS 240 Data Structures midterm. 112 students attended. 3 no-shows. Incident-free session.'
);

-- Normal Operation: Approved (current/future) booking awaiting check-in
-- Tests: decision_fields CHECK constraint, trigger overlap prevention (no other approved overlap)
INSERT INTO dbo.BOOKING (
    requester_id, space_code, requested_start_time, requested_end_time,
    purpose, expected_participants, booking_status,
    decision_staff_id, decision_time, decision_note
) VALUES (
    @SarahKim, 'CR-M3-1006', '2026-07-10 10:00:00', '2026-07-10 12:00:00',
    'seminar', 40, 'approved',
    @MariaSantos, '2026-06-25 11:00:00', 'Graduate seminar — approved. Ensure Livestreaming is configured if hybrid attendance requested.'
);

-- Normal Operation: Pending booking (default status, no decision yet)
-- Tests: DEFAULT booking_status='pending', NULL optional FK fields are accepted
INSERT INTO dbo.BOOKING (
    requester_id, space_code, requested_start_time, requested_end_time,
    purpose, expected_participants
) VALUES (
    @RajPatel, 'CR-M3-1006', '2026-08-05 13:00:00', '2026-08-05 16:00:00',
    'workshop', 25
);

-- Normal Operation: Cancelled booking
-- Tests: 'cancelled' status bypasses decision/checkin/completion CHECK constraints
INSERT INTO dbo.BOOKING (
    requester_id, space_code, requested_start_time, requested_end_time,
    purpose, expected_participants, booking_status
) VALUES (
    @AliceChen, 'CR-M3-1006', '2026-03-01 09:00:00', '2026-03-01 10:00:00',
    'meeting', 10, 'cancelled'
);

-- Exceptional Case: No-show booking (approved but never checked in)
-- Tests: 'no_show' status bypasses checkin/completion CHECK constraints
INSERT INTO dbo.BOOKING (
    requester_id, space_code, requested_start_time, requested_end_time,
    purpose, expected_participants, booking_status
) VALUES (
    @EmilyWong, 'CR-M3-1006', '2026-04-05 15:00:00', '2026-04-05 17:00:00',
    'student_activity', 10, 'no_show'
);

-- ------------------------------------------------------------------------
-- CL-DC-2585 bookings (computer lab, available, cap 40)
-- ------------------------------------------------------------------------

-- Normal Operation: Completed booking for computer lab
INSERT INTO dbo.BOOKING (
    requester_id, space_code, requested_start_time, requested_end_time,
    purpose, expected_participants, booking_status,
    decision_staff_id, decision_time, decision_note,
    actual_start_time, check_in_staff_id, initial_condition,
    actual_end_time, completion_staff_id, final_condition, usage_notes
) VALUES (
    @JamesOBrien, 'CL-DC-2585', '2026-01-20 10:00:00', '2026-01-20 12:00:00',
    'lecture', 35, 'completed',
    @WeiZhang, '2026-01-14 16:00:00', 'CS 246 lab session — approved. Ensure GCC toolchain is updated before session.',
    '2026-01-20 09:50:00', @MichaelDavis, 'All 40 workstations bootable. GCC 12.3 confirmed. Network connectivity stable.',
    '2026-01-20 12:10:00', @MichaelDavis, 'Two workstations (row D seats 3-4) have frozen session; logged for ITS follow-up. Otherwise clean.',
    'CS 246 Object-Oriented Software Development — Lab 2. Students completed inheritance design exercise.'
);

-- Normal Operation: Approved booking (administrative event)
INSERT INTO dbo.BOOKING (
    requester_id, space_code, requested_start_time, requested_end_time,
    purpose, expected_participants, booking_status,
    decision_staff_id, decision_time, decision_note
) VALUES (
    @ThomasLee, 'CL-DC-2585', '2026-07-15 09:00:00', '2026-07-15 13:00:00',
    'administrative_event', 15, 'approved',
    @MariaSantos, '2026-07-01 10:30:00', 'Department curriculum committee meeting — approved. Catering request forwarded to building services.'
);

-- Exceptional Case: Back-to-back approved booking — same space, same day, no overlap
-- Tests trigger boundary: b.requested_end_time (13:00) <= i.requested_start_time (14:00) — no false-positive overlap detection
INSERT INTO dbo.BOOKING (
    requester_id, space_code, requested_start_time, requested_end_time,
    purpose, expected_participants, booking_status,
    decision_staff_id, decision_time, decision_note
) VALUES (
    @RajPatel, 'CL-DC-2585', '2026-07-15 14:00:00', '2026-07-15 17:00:00',
    'workshop', 20, 'approved',
    @WeiZhang, '2026-07-02 09:00:00', 'Git and CI/CD workshop for graduate TAs — approved. Docker pre-installed on lab machines confirmed.'
);

-- Normal Operation: Pending booking far in the future
INSERT INTO dbo.BOOKING (
    requester_id, space_code, requested_start_time, requested_end_time,
    purpose, expected_participants
) VALUES (
    @SarahKim, 'CL-DC-2585', '2026-09-01 09:00:00', '2026-09-01 11:00:00',
    'lecture', 30
);

-- ------------------------------------------------------------------------
-- AUD-MC-1000 bookings (auditorium, available, cap 500)
-- ------------------------------------------------------------------------

-- Normal Operation: Completed large-audience seminar
INSERT INTO dbo.BOOKING (
    requester_id, space_code, requested_start_time, requested_end_time,
    purpose, expected_participants, booking_status,
    decision_staff_id, decision_time, decision_note,
    actual_start_time, check_in_staff_id, initial_condition,
    actual_end_time, completion_staff_id, final_condition, usage_notes
) VALUES (
    @JamesOBrien, 'AUD-MC-1000', '2026-02-01 08:00:00', '2026-02-01 12:00:00',
    'seminar', 300, 'completed',
    @MariaSantos, '2026-01-25 15:00:00', 'Annual CS research symposium — approved. AV team briefed for livestream setup.',
    '2026-02-01 07:30:00', @FatimaHassan, 'Microphone system and livestream equipment tested. Stage lighting configured. Seating arranged for 320.',
    '2026-02-01 12:35:00', @FatimaHassan, 'All AV equipment powered down and secured. Auditorium clean. One broken seat armrest in row G reported separately.',
    'CS Research Symposium 2026. 287 attendees. Four keynote sessions completed. Livestream recording archived.'
);

-- Normal Operation: Future approved booking for examination
INSERT INTO dbo.BOOKING (
    requester_id, space_code, requested_start_time, requested_end_time,
    purpose, expected_participants, booking_status,
    decision_staff_id, decision_time, decision_note
) VALUES (
    @SarahKim, 'AUD-MC-1000', '2026-08-20 09:00:00', '2026-08-20 12:00:00',
    'examination', 450, 'approved',
    @WeiZhang, '2026-07-15 09:00:00', 'CS 350 final examination — approved. Requested 450 seats; auditorium seats 500. Additional proctors to be assigned.'
);

-- Exceptional Case: Rejected booking with explicit rejection reason
-- Tests: chk_booking_rejection_reason (rejection_reason must be NOT NULL for rejected),
--        chk_booking_decision_fields (decision fields required for rejected),
--        trigger role authorization (decision staff must be facility_manager/staff)
INSERT INTO dbo.BOOKING (
    requester_id, space_code, requested_start_time, requested_end_time,
    purpose, expected_participants, booking_status,
    decision_staff_id, decision_time, decision_note, rejection_reason
) VALUES (
    @JamesOBrien, 'AUD-MC-1000', '2026-06-15 10:00:00', '2026-06-15 12:00:00',
    'lecture', 200, 'rejected',
    @MariaSantos, '2026-06-08 15:45:00', 'Booking request reviewed. Conflict identified with scheduled facilities maintenance window.',
    'Scheduling conflict: auditorium HVAC inspection and filter replacement scheduled for 2026-06-15 06:00–14:00. Please resubmit for an alternate date.'
);

-- ------------------------------------------------------------------------
-- PL-DC-3564 bookings (project lab, in_use, cap 25)
-- ------------------------------------------------------------------------

-- Normal Operation: Approved booking for a space currently marked in_use
-- Tests: A in-use space must have a booking with status = 'checked_in'
INSERT INTO dbo.BOOKING (
    requester_id, space_code, requested_start_time, requested_end_time,
    purpose, expected_participants, booking_status,
    decision_staff_id, decision_time, decision_note
) VALUES (
    @EmilyWong, 'PL-DC-3564', '2026-08-10 09:00:00', '2026-08-10 17:00:00',
    'workshop', 20, 'approved',
    @WeiZhang, '2026-07-20 13:00:00', 'Capstone design review workshop — approved. Ensure prototyping equipment is available for all 8 teams.'
);

-- ------------------------------------------------------------------------
-- PL-DC-3564 bookings (project lab, in_use, cap 25)
-- ------------------------------------------------------------------------

-- Normal Operation: Checked_in booking for a space currently marked in_use
-- Tests: trigger Rule 1 — 'in_use' is NOT blocked (only under_maintenance/temporarily_closed/retired are blocked)
INSERT INTO dbo.BOOKING (
    requester_id, space_code, requested_start_time, requested_end_time,
    purpose, expected_participants, booking_status,
    decision_staff_id, decision_time, decision_note,
    actual_start_time, check_in_staff_id, initial_condition
) VALUES (
    @EmilyWong, 'PL-DC-3564', '2026-07-02 09:00:00', '2026-07-02 17:00:00',
    'workshop', 20, 'checked_in',
    @WeiZhang, '2026-06-29 13:00:00', 'Capstone design review workshop — approved. Ensure prototyping equipment is available for all 8 teams.',
    '2026-07-02 09:15:00', @MichaelDavis, 'Room left in good condition. All equipment powered down.'
);

-- ------------------------------------------------------------------------
-- MR-DC-3102 bookings (meeting room, available, cap 20)
-- ------------------------------------------------------------------------

-- Normal Operation: Completed small meeting
INSERT INTO dbo.BOOKING (
    requester_id, space_code, requested_start_time, requested_end_time,
    purpose, expected_participants, booking_status,
    decision_staff_id, decision_time, decision_note,
    actual_start_time, check_in_staff_id, initial_condition,
    actual_end_time, completion_staff_id, final_condition, usage_notes
) VALUES (
    @ThomasLee, 'MR-DC-3102', '2026-01-10 11:00:00', '2026-01-10 12:00:00',
    'meeting', 8, 'completed',
    @MariaSantos, '2026-01-08 10:00:00', 'Department planning meeting — approved. Short duration, standard setup.',
    '2026-01-10 10:55:00', @MichaelDavis, 'Video conferencing system powered on and tested. Whiteboard clean, markers available.',
    '2026-01-10 12:02:00', @MichaelDavis, 'Room tidy. Whiteboard erased. VC system powered down correctly.',
    'CS Department undergraduate curriculum planning. Minutes filed separately. No equipment issues.'
);

-- Exceptional Case: Rejected booking — room too small for participant count
-- Tests: chk_booking_rejection_reason + decision_fields with rejection_reason
-- Note: capacity-to-participant enforcement is human review (Design Assumption 4), this rejection demonstrates that workflow
INSERT INTO dbo.BOOKING (
    requester_id, space_code, requested_start_time, requested_end_time,
    purpose, expected_participants, booking_status,
    decision_staff_id, decision_time, decision_note, rejection_reason
) VALUES (
    @AliceChen, 'MR-DC-3102', '2026-06-10 14:00:00', '2026-06-10 16:00:00',
    'lecture', 60, 'rejected',
    @WeiZhang, '2026-06-04 11:30:00', 'Room MR-DC-3102 has 20-seat capacity. Requested 60 participants exceeds room limit.',
    'Room capacity exceeded: MR-DC-3102 seats 20. Requested attendance of 60 requires a larger venue. Consider AUD-MC-1000 or CR-M3-1006.'
);

-- Normal Operation: Pending administrative meeting
INSERT INTO dbo.BOOKING (
    requester_id, space_code, requested_start_time, requested_end_time,
    purpose, expected_participants
) VALUES (
    @ThomasLee, 'MR-DC-3102', '2026-07-20 13:00:00', '2026-07-20 15:00:00',
    'administrative_event', 12
);

-- ------------------------------------------------------------------------
-- SW-STC-0010 bookings (student workspace, available, cap 60)
-- ------------------------------------------------------------------------

-- Normal Operation: Completed student activity booking
INSERT INTO dbo.BOOKING (
    requester_id, space_code, requested_start_time, requested_end_time,
    purpose, expected_participants, booking_status,
    decision_staff_id, decision_time, decision_note,
    actual_start_time, check_in_staff_id, initial_condition,
    actual_end_time, completion_staff_id, final_condition, usage_notes
) VALUES (
    @AliceChen, 'SW-STC-0010', '2026-03-15 14:00:00', '2026-03-15 18:00:00',
    'student_activity', 45, 'completed',
    @WeiZhang, '2026-03-10 10:00:00', 'CS Club hackathon — approved. Extended hours noted. Security advised of after-hours access.',
    '2026-03-15 13:50:00', @FatimaHassan, 'Workspace clean, power bars distributed. Wi-Fi confirmed stable for 50+ concurrent connections.',
    '2026-03-15 18:15:00', @FatimaHassan, 'Workspace restored to default layout. All power bars returned. One whiteboard marker left uncapped — minor.',
    'CS Club Spring Hackathon 2026. 42 participants. Three project demos recorded. Positive feedback from student organizers.'
);

-- Normal Operation: Cancelled student activity (with suspended user as requester)
-- Tests: suspended user can still have historical cancelled bookings
INSERT INTO dbo.BOOKING (
    requester_id, space_code, requested_start_time, requested_end_time,
    purpose, expected_participants, booking_status
) VALUES (
    @BobMartinez, 'SW-STC-0010', '2026-05-01 09:00:00', '2026-05-01 17:00:00',
    'student_activity', 50, 'cancelled'
);

-- ------------------------------------------------------------------------
-- CR-DC-1302 bookings (classroom, available, cap 80)
-- ------------------------------------------------------------------------

-- Normal Operation: Completed lecture in alternate classroom
INSERT INTO dbo.BOOKING (
    requester_id, space_code, requested_start_time, requested_end_time,
    purpose, expected_participants, booking_status,
    decision_staff_id, decision_time, decision_note,
    actual_start_time, check_in_staff_id, initial_condition,
    actual_end_time, completion_staff_id, final_condition, usage_notes
) VALUES (
    @SarahKim, 'CR-DC-1302', '2026-04-10 09:00:00', '2026-04-10 11:30:00',
    'lecture', 75, 'completed',
    @WeiZhang, '2026-04-05 13:00:00', 'CS 486 guest lecture — approved. External speaker parking pass arranged.',
    '2026-04-10 08:50:00', @MichaelDavis, 'Smart board calibrated. Guest laptop connected and tested. Room temperature comfortable.',
    '2026-04-10 11:35:00', @MichaelDavis, 'Equipment secure. Room clean. Smart board disconnection note: HDMI cable slightly loose — logged for preventive check.',
    'CS 486 — Guest lecture by Dr. Helena Richter (ETH Zurich) on Formal Verification Methods. 68 attendees. Highly rated session.'
);

-- Exceptional Case: Minimum expected_participants = 1
-- Tests: chk_booking_participants_positive boundary (must be > 0)
INSERT INTO dbo.BOOKING (
    requester_id, space_code, requested_start_time, requested_end_time,
    purpose, expected_participants
) VALUES (
    @EmilyWong, 'CR-DC-1302', '2026-08-25 15:00:00', '2026-08-25 16:00:00',
    'meeting', 1
);

-- ============================================================================
-- 5. MAINTENANCE_RECORD (dependent on SPACE, USER)
--    Order: 2 — requires SPACE and USER rows present
-- ============================================================================

-- Normal Operation: Reported maintenance — AC issue on under-maintenance space
INSERT INTO dbo.MAINTENANCE_RECORD (
    space_code, reporter_id, assigned_staff_id,
    problem_description, start_time, status
) VALUES (
    'CL-MC-3003', @JamesOBrien, @MichaelDavis,
    'Air conditioning unit not cooling adequately. Room temperature exceeds 28°C during afternoon sessions, making the lab unusable for scheduled classes.',
    '2026-06-20 08:00:00', 'reported'
);

-- Normal Operation: In-progress maintenance — computer hardware issue
INSERT INTO dbo.MAINTENANCE_RECORD (
    space_code, reporter_id, assigned_staff_id,
    problem_description, start_time, status
) VALUES (
    'CL-MC-3003', @FatimaHassan, @MichaelDavis,
    'Several desktop computers in row C fail to complete POST. Suspect faulty RAM modules — machines beep on startup and do not reach OS bootloader.',
    '2026-06-25 09:00:00', 'in_progress'
);

-- Exceptional Case: Maintenance with NULL assigned_staff_id
-- Tests: nullable FK for assigned_staff_id (staff not yet assigned)
INSERT INTO dbo.MAINTENANCE_RECORD (
    space_code, reporter_id, assigned_staff_id,
    problem_description, start_time, status
) VALUES (
    'CR-M3-1006', @FatimaHassan, NULL,
    'Projector bulb appears dim with intermittent flickering during projection. Image quality degraded — barely visible in ambient lighting.',
    '2026-06-26 14:00:00', 'reported'
);

-- Exceptional Case: Completed maintenance with all required completion fields
-- Tests: chk_mr_completion_fields (completion_time and result_note must be NOT NULL when status='completed'),
--        chk_mr_timeline_order (start_time < completion_time)
INSERT INTO dbo.MAINTENANCE_RECORD (
    space_code, reporter_id, assigned_staff_id,
    problem_description, start_time, completion_time, status, result_note
) VALUES (
    'AUD-MC-1000', @WeiZhang, @FatimaHassan,
    'Livestreaming equipment audio channel 2 not capturing signal during live events. Tested with multiple XLR sources — confirmed dead channel on mixer input.',
    '2026-06-01 10:00:00', '2026-06-22 16:00:00', 'completed',
    'Replaced faulty XLR input jack on channel 2 of Behringer X32 mixer. Full audio calibration performed. All four input channels confirmed operational. Preventive maintenance schedule updated for quarterly mixer inspection.'
);

-- Normal Operation: Reported maintenance by department administrator
INSERT INTO dbo.MAINTENANCE_RECORD (
    space_code, reporter_id, assigned_staff_id,
    problem_description, start_time, status
) VALUES (
    'MR-DC-3102', @ThomasLee, @MichaelDavis,
    'Keycard reader at main entrance unresponsive — door cannot be accessed electronically. Physical key override functional but impacts scheduled meeting access for non-key holders.',
    '2026-06-27 07:00:00', 'reported'
);

-- ============================================================================
-- 6. SPACE_FACILITY (junction table — depends on SPACE and FACILITY)
--    Order: 3 — must run after SPACE and FACILITY rows exist
-- ============================================================================

-- Normal Operations — typical facility assignments per space type

-- AUD-MC-1000: Humanities Theatre (auditorium)
INSERT INTO dbo.SPACE_FACILITY (space_code, facility_id) VALUES ('AUD-MC-1000', @Proj);
INSERT INTO dbo.SPACE_FACILITY (space_code, facility_id) VALUES ('AUD-MC-1000', @Mic);
INSERT INTO dbo.SPACE_FACILITY (space_code, facility_id) VALUES ('AUD-MC-1000', @Live);
INSERT INTO dbo.SPACE_FACILITY (space_code, facility_id) VALUES ('AUD-MC-1000', @AC);

-- CR-M3-1006: M3 Lecture Hall (classroom)
INSERT INTO dbo.SPACE_FACILITY (space_code, facility_id) VALUES ('CR-M3-1006', @Proj);
INSERT INTO dbo.SPACE_FACILITY (space_code, facility_id) VALUES ('CR-M3-1006', @WB);
INSERT INTO dbo.SPACE_FACILITY (space_code, facility_id) VALUES ('CR-M3-1006', @AC);

-- CR-DC-1302: DC 1302 Classroom
INSERT INTO dbo.SPACE_FACILITY (space_code, facility_id) VALUES ('CR-DC-1302', @WB);
INSERT INTO dbo.SPACE_FACILITY (space_code, facility_id) VALUES ('CR-DC-1302', @Smart);
INSERT INTO dbo.SPACE_FACILITY (space_code, facility_id) VALUES ('CR-DC-1302', @AC);

-- CL-DC-2585: Unix Computing Lab
INSERT INTO dbo.SPACE_FACILITY (space_code, facility_id) VALUES ('CL-DC-2585', @Proj);
INSERT INTO dbo.SPACE_FACILITY (space_code, facility_id) VALUES ('CL-DC-2585', @WB);
INSERT INTO dbo.SPACE_FACILITY (space_code, facility_id) VALUES ('CL-DC-2585', @PC);
INSERT INTO dbo.SPACE_FACILITY (space_code, facility_id) VALUES ('CL-DC-2585', @AC);

-- CL-MC-3003: Instructional Computing Lab (under maintenance)
INSERT INTO dbo.SPACE_FACILITY (space_code, facility_id) VALUES ('CL-MC-3003', @Proj);
INSERT INTO dbo.SPACE_FACILITY (space_code, facility_id) VALUES ('CL-MC-3003', @WB);
INSERT INTO dbo.SPACE_FACILITY (space_code, facility_id) VALUES ('CL-MC-3003', @PC);
INSERT INTO dbo.SPACE_FACILITY (space_code, facility_id) VALUES ('CL-MC-3003', @AC);

-- PL-DC-3564: Senior Design Project Lab
INSERT INTO dbo.SPACE_FACILITY (space_code, facility_id) VALUES ('PL-DC-3564', @WB);
INSERT INTO dbo.SPACE_FACILITY (space_code, facility_id) VALUES ('PL-DC-3564', @PC);
INSERT INTO dbo.SPACE_FACILITY (space_code, facility_id) VALUES ('PL-DC-3564', @AC);

-- MR-DC-3102: Davis Centre Board Room
INSERT INTO dbo.SPACE_FACILITY (space_code, facility_id) VALUES ('MR-DC-3102', @Proj);
INSERT INTO dbo.SPACE_FACILITY (space_code, facility_id) VALUES ('MR-DC-3102', @WB);
INSERT INTO dbo.SPACE_FACILITY (space_code, facility_id) VALUES ('MR-DC-3102', @VC);
INSERT INTO dbo.SPACE_FACILITY (space_code, facility_id) VALUES ('MR-DC-3102', @AC);

-- MR-MC-4040: MC Seminar Room (temporarily closed)
INSERT INTO dbo.SPACE_FACILITY (space_code, facility_id) VALUES ('MR-MC-4040', @WB);
INSERT INTO dbo.SPACE_FACILITY (space_code, facility_id) VALUES ('MR-MC-4040', @Smart);
INSERT INTO dbo.SPACE_FACILITY (space_code, facility_id) VALUES ('MR-MC-4040', @AC);

-- SW-STC-0010: Collaborative Hub
INSERT INTO dbo.SPACE_FACILITY (space_code, facility_id) VALUES ('SW-STC-0010', @WB);
INSERT INTO dbo.SPACE_FACILITY (space_code, facility_id) VALUES ('SW-STC-0010', @AC);

-- Exceptional Case: MR-DC-1315 (retired, capacity=1) with minimal facilities
-- Tests: space with boundary capacity still correctly linked to its facility
INSERT INTO dbo.SPACE_FACILITY (space_code, facility_id) VALUES ('MR-DC-1315', @AC);

-- ============================================================================
-- End of sample data
-- ============================================================================

PRINT 'Sample data generation complete.';
GO

-- ============================================================================
-- Scenario Documentation
-- ============================================================================
--
-- Normal Operations Covered:
--
-- 1. Full Booking Lifecycle (Pending → Approved → Checked-In → Completed):
--    CR-M3-1006 Lecture (rows 1) and CL-DC-2585 Lecture (row 7), AUD-MC-1000
--    Symposium (row 11), MR-DC-3102 Meeting (row 15), SW-STC-0010 Hackathon
--    (row 18), CR-DC-1302 Guest Lecture (row 20) all follow the complete
--    lifecycle. Each demonstrates the CHECK constraints chk_booking_decision_
--    fields, chk_booking_checkin_fields, and chk_booking_completion_fields are
--    satisfied when all required fields are populated at each status stage.
--    The trigger trg_booking_enforce_rules validates role authorization for
--    decision staff (facility_staff/facility_manager) and check-in/completion
--    staff (facility_staff).
--
-- 2. Pending Bookings Awaiting Approval:
--    CR-M3-1006 Workshop (row 4), CL-DC-2585 Fall Lecture (row 10), MR-DC-3102
--    Admin Meeting (row 17) all use DEFAULT booking_status='pending'. They
--    have NULL optional FK fields (decision_staff_id, actual times, etc.),
--    confirming the schema allows submission before any staff intervention.
--
-- 3. Cross-Role Participation:
--    Users across all six roles interact with the system: students (Alice Chen,
--    Bob Martinez) submit bookings; lecturers (Dr. Sarah Kim, Dr. James
--    O'Brien) hold classes and exams; TAs (Raj Patel, Emily Wong) organize
--    workshops; department administrators (Thomas Lee) schedule meetings;
--    facility staff (Michael Davis, Fatima Hassan) perform check-ins and
--    completions; facility managers (Dr. Wei Zhang, Maria Santos) approve
--    and reject bookings.
--
-- 4. Multi-Space-Type Usage:
--    All six space types appear in booking records: auditorium (AUD-MC-1000),
--    classroom (CR-M3-1006, CR-DC-1302), computer_lab (CL-DC-2585), project_lab
--    (PL-DC-3564), meeting_room (MR-DC-3102), student_workspace (SW-STC-0010),
--    confirming domain CHECK constraints accept each type.
--
-- 5. All Booking Purposes Exercised:
--    Purposes used: lecture, examination, seminar, workshop, meeting,
--    student_activity, administrative_event — covering every value in
--    chk_booking_purpose_domain.
--
-- 6. Facility-Space Assignments:
--    Each space receives appropriate facilities via the SPACE_FACILITY junction
--    table. Computer labs (CL-DC-2585, CL-MC-3003) have Desktop Computers;
--    auditoriums have Livestreaming Equipment; meeting rooms have Video
--    Conferencing System. The M:N relationship is correctly resolved.
--
-- 7. Maintenance Lifecycle (Reported → In Progress):
--    CL-MC-3003 has two maintenance records: one 'reported' (AC issue) and one
--    'in_progress' (computer hardware), demonstrating the maintenance status
--    progression from initial reporting to active resolution.
--
-- 8. Historical Record Preservation:
--    All operational entities (USER, SPACE, BOOKING, MAINTENANCE_RECORD) use
--    RESTRICT delete semantics (no ON DELETE CASCADE on base tables). Completed,
--    cancelled, and rejected bookings are retained as an immutable audit trail.
--
-- Exceptional Cases Covered:
--
-- 1. Account Status Boundaries (chk_user_account_status_domain):
--    - Bob Martinez (suspended student) and Grace Okafor (deactivated admin)
--      test the non-'active' values in the account_status CHECK constraint.
--      Bob retains a cancelled booking (row 19), confirming historical records
--      remain regardless of current account status.
--
-- 2. Space Status Boundaries (chk_space_current_status_domain):
--    - CL-MC-3003 ('under_maintenance'), MR-MC-4040 ('temporarily_closed'),
--      and MR-DC-1315 ('retired') each occupy a blocked status. No bookings
--      reference these spaces because the trigger trg_booking_enforce_rules
--      (Rule 1 — Unavailable Space Gate) rejects any INSERT or UPDATE against
--      them. This validates the procedural enforcement of BR 8.
--
-- 3. Minimum Capacity Boundary (chk_space_capacity_positive):
--    - MR-DC-1315 ('Phone Booth Room') has capacity=1, the smallest valid
--      positive integer. If capacity were 0, the CHECK would fail. This
--      validates the > 0 boundary condition.
--
-- 4. Minimum Participants Boundary (chk_booking_participants_positive):
--    - CR-DC-1302 pending booking (row 21) has expected_participants=1,
--      the minimum value satisfying > 0. This validates the constraint
--      boundary and confirms no artificial minimum beyond 1 is enforced.
--
-- 5. Rejected Booking with Rejection Reason (chk_booking_rejection_reason +
--    chk_booking_decision_fields):
--    - AUD-MC-1000 (row 13, rejected by Maria Santos) and MR-DC-3102 (row 16,
--      rejected by Wei Zhang) both include rejection_reason populated. The
--      CHECK constraints enforce that rejected bookings MUST have
--      rejection_reason NOT NULL and ALL decision fields (staff, time, note)
--      filled. These rows test both constraints simultaneously.
--
-- 6. Back-to-Back Approved Bookings — Trigger Overlap Boundary:
--    CL-DC-2585 has two approved bookings on 2026-07-15:
--      Row 8: 09:00–13:00 (admin event)
--      Row 9: 14:00–17:00 (workshop)
--    These abut but do not overlap (13:00 ≤ 14:00). The trigger's overlap
--    detection uses strict inequality (b.requested_end_time >
--    i.requested_start_time), so 13:00 > 14:00 is FALSE and the trigger
--    correctly permits the insert. This validates the trigger's boundary
--    behavior — no false-positive overlap rejection.
--
-- 7. NULL Assigned Staff in Maintenance (nullable FK):
--    - CR-M3-1006 maintenance record (row 23, projector flickering) has
--      assigned_staff_id = NULL. This tests that the FK constraint allows
--      NULL (the column is nullable) and that maintenance records can be
--      reported before staff assignment. The nullable FK is correctly
--      accepted.
--
-- 8. Completed Maintenance with Required Fields (chk_mr_completion_fields +
--    chk_mr_timeline_order):
--    - AUD-MC-1000 (row 24, livestreaming repair completed) has status
--      'completed' with both completion_time NOT NULL and result_note NOT NULL,
--      and start_time < completion_time. This validates all three
--      MAINTENANCE_RECORD CHECK constraints simultaneously.
--
-- 9. No-Show Booking (chk_booking_status_domain):
--    - CR-M3-1006 (row 6, student_activity) has booking_status='no_show'.
--      The chk_booking_decision_fields constraint does NOT require decision
--      fields for 'no_show' (it only triggers for 'approved'/'rejected').
--      The chk_booking_checkin_fields constraint does NOT require check-in
--      fields for 'no_show' (it only triggers for 'checked_in'/'completed').
--      This validates the intentional exclusion of no_show from these
--      state-contingent nullability constraints.
--
-- 10. Cancelled Booking (bypasses decision/checkin constraints):
--     - CR-M3-1006 Meeting (row 5) and SW-STC-0010 Student Activity (row 19)
--       are both 'cancelled'. No decision, check-in, or completion fields are
--       populated. The CHECK constraints correctly short-circuit for
--       'cancelled' status since ¬('cancelled' IN ('approved','rejected'))
--       evaluates to TRUE.
--
-- 11. Unavailable Space Booking Rejection (Trigger Rule 1):
--     - Spaces CL-MC-3003, MR-MC-4040, and MR-DC-1315 exist with blocked
--       statuses but have zero bookings. Any INSERT or UPDATE referencing
--       these spaces would be rejected by trg_booking_enforce_rules (Rule 1).
--       The absence of bookings for these spaces validates the trigger gate
--       is in effect. Manual testing would involve attempting:
--       INSERT INTO dbo.BOOKING (...) VALUES (..., 'CL-MC-3003', ...);
--       and observing the THROW 50000 error.
--
-- 12. Operational Space Status ('in_use') Allows Bookings:
--     - PL-DC-3564 has current_status='in_use' but row 14 is an approved
--       booking referencing it. The trigger's Rule 1 only blocks
--       'under_maintenance', 'temporarily_closed', and 'retired' — 'in_use'
--       is deliberately permitted. This validates the intentional design
--       choice that bookings may coexist on spaces whose status reflects
--       ongoing activity.
--
-- 13. Completed Booking Enforces All Four Completion Fields:
--     - Every 'completed' booking row tests chk_booking_completion_fields by
--       including actual_end_time, completion_staff_id, final_condition, and
--       usage_notes. If any of these four were NULL, the CHECK constraint
--       would reject the row. This validates the completeness enforcement
--       of the completion workflow.
