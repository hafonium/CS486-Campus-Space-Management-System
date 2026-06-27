-- ============================================================================
-- Campus Space Management System — Sample Data Preparation
-- Target: Microsoft SQL Server (T-SQL)
-- Based on: outputs/05-database-implementation-G09.sql (DDL)
--           outputs/01-business-req-analysis-G09.md (business rules)
--           outputs/03-logical-design-G09.md (logical design)
-- ============================================================================

USE CampusSpaceManagement;
GO

-- ============================================================================
-- 0. PRE-FLIGHT: Disable INSTEAD OF trigger on BOOKING
--    The DDL defines trg_booking_validation as INSTEAD OF INSERT, UPDATE.
--    We disable it during seeding to prevent bulk-insert conflicts, then
--    re-enable it after all BOOKING rows are inserted.
-- ============================================================================

DISABLE TRIGGER dbo.trg_booking_validation ON dbo.BOOKING;
GO

-- ============================================================================
-- 1. USER (independent — no foreign keys)
--    PK: user_id (IDENTITY).  We use IDENTITY_INSERT to control FK values.
-- ============================================================================

SET IDENTITY_INSERT dbo.[USER] ON;
GO

-- Normal Operations
INSERT INTO dbo.[USER] (user_id, full_name, email, phone_number, role, department, account_status) VALUES
(1,  'Alice Johnson',          'alice.johnson@university.edu',          '+1-555-0101', 'student',                   'Computer Science',        'active'),
(2,  'Bob Williams',           'bob.williams@university.edu',           '+1-555-0102', 'student',                   'Computer Science',        'suspended'),
(3,  'Dr. Carol Chen',         'carol.chen@university.edu',             '+1-555-0103', 'lecturer',                  'Computer Science',        'active'),
(4,  'Dr. David Patel',        'david.patel@university.edu',            '+1-555-0104', 'lecturer',                  'Mathematics',             'active'),
(5,  'Eve Martinez',           'eve.martinez@university.edu',           '+1-555-0105', 'teaching_assistant',        'Computer Science',        'active'),
(6,  'Frank Thompson',         'frank.thompson@university.edu',         '+1-555-0106', 'facility_staff',            'Facilities Management',   'active'),
(7,  'Grace Liu',              'grace.liu@university.edu',              '+1-555-0107', 'facility_staff',            'Facilities Management',   'active'),
(8,  'Henry Garcia',           'henry.garcia@university.edu',           '+1-555-0108', 'facility_manager',          'Facilities Management',   'active'),
(9,  'Iris Nakamura',          'iris.nakamura@university.edu',          '+1-555-0109', 'department_administrator',  'Computer Science',        'active');

-- Exceptional Cases
INSERT INTO dbo.[USER] (user_id, full_name, email, phone_number, role, department, account_status) VALUES
(10, 'Jack Robinson',          'jack.robinson@university.edu',          '+1-555-0110', 'student',                   'Computer Science',        'deactivated'),
(11, 'Karen O''Neil',          'karen.oneil@university.edu',            '+1-555-0111', 'student',                   'Physics',                 'active'),
(12, 'Prof. Lakshmi Krishnamurthy-Venkatasubramanian',
                                'long.name@university.edu',              '+1-555-0112', 'lecturer',                  'Electrical Engineering',  'active');

SET IDENTITY_INSERT dbo.[USER] OFF;
GO

-- ============================================================================
-- 2. SPACE (independent — no foreign keys)
--    PK: space_code (natural key, no IDENTITY_INSERT needed)
-- ============================================================================

-- Normal Operations
INSERT INTO dbo.SPACE (space_code, space_name, space_type, building, floor, room_number, capacity, current_status, usage_policy) VALUES
('CS-101',  'CS Lecture Hall 101',   'classroom',          'Computer Science Building', 1, '101', 60,  'available',  'Priority for CS lectures. No food or drinks permitted.'),
('CS-AUD',  'CS Auditorium',         'auditorium',         'Computer Science Building', 1, 'AUD', 200, 'available',  'Large events only. Must be booked at least two weeks in advance.'),
('CS-LAB1', 'CS Computer Lab 1',     'computer_lab',       'Computer Science Building', 2, '201', 30,  'available',  'No food or drinks. Log off workstations after use. Report hardware issues to facility staff.'),
('CS-LAB2', 'CS Project Lab 2',      'project_lab',        'Computer Science Building', 2, '202', 25,  'available',  'Reserved for capstone and research project groups. Extended hours require staff approval.'),
('CS-MEET', 'CS Meeting Room',       'meeting_room',       'Computer Science Building', 3, '301', 12,  'available',  'Maximum two hours per booking session. Clean whiteboard after use.'),
('CS-WORK', 'Student Workspace',     'student_workspace',  'Computer Science Building', 3, '302', 40,  'available',  'Open to all registered CS students. First-come seating when not booked.');

-- Exceptional Cases
INSERT INTO dbo.SPACE (space_code, space_name, space_type, building, floor, room_number, capacity, current_status, usage_policy) VALUES
('CS-102',  'CS Seminar Room 102',   'classroom',          'Computer Science Building', 1, '102', 45,  'temporarily_closed', 'Closed for semester-break renovation. Expected reopening: August 2026.'),
('CS-103',  'CS Classroom 103',      'classroom',          'Computer Science Building', 1, '103', 50,  'under_maintenance',  'Air conditioning unit under repair. Do not use until maintenance is completed.'),
('CS-R401', 'Retired Meeting Room',  'meeting_room',       'Computer Science Building', 4, '401', 8,   'retired',            'Permanently closed. Space has been converted to a faculty office.');
GO

-- ============================================================================
-- 3. FACILITY (independent — no foreign keys)
--    PK: facility_id (IDENTITY).  We use IDENTITY_INSERT to control FK values.
-- ============================================================================

SET IDENTITY_INSERT dbo.FACILITY ON;
GO

-- Normal Operations
INSERT INTO dbo.FACILITY (facility_id, facility_name) VALUES
(1, 'Projector'),
(2, 'Whiteboard'),
(3, 'Microphone'),
(4, 'Desktop Computer'),
(5, 'Livestreaming Equipment'),
(6, 'Air Conditioner'),
(7, 'Video Conferencing System'),
(8, 'Smart Board');

SET IDENTITY_INSERT dbo.FACILITY OFF;
GO

-- ============================================================================
-- 4. BOOKING (child of USER and SPACE)
--    PK: booking_id (IDENTITY).  No child tables reference it, so we let the
--    IDENTITY auto-increment.  The INSTEAD OF trigger is disabled (see §0).
--    FK order: USER (requester, staff) and SPACE must already exist.
-- ============================================================================

-- Normal Operations — Full Lifecycle (pending → approved → checked_in → completed)
INSERT INTO dbo.BOOKING (requester_id, space_code, decision_staff_id, check_in_staff_id, completion_staff_id,
    requested_start_time, requested_end_time, purpose, expected_participants, booking_status,
    decision_time, decision_note, rejection_reason,
    actual_start_time, initial_condition, actual_end_time, final_condition, usage_notes) VALUES
(3, 'CS-101',  6, 6, 6, '2026-06-10 09:00', '2026-06-10 11:00', 'lecture',   30, 'completed',
    '2026-06-05 14:00', 'Approved — regular CS301 lecture.', NULL,
    '2026-06-10 08:55', 'Room clean, projector tested and working.', '2026-06-10 11:05', 'Clean, whiteboard erased.', 'CS301: Introduction to Database Systems.');

-- Normal Operations — Full Lifecycle (seminar, different staff for each role)
INSERT INTO dbo.BOOKING (requester_id, space_code, decision_staff_id, check_in_staff_id, completion_staff_id,
    requested_start_time, requested_end_time, purpose, expected_participants, booking_status,
    decision_time, decision_note, rejection_reason,
    actual_start_time, initial_condition, actual_end_time, final_condition, usage_notes) VALUES
(4, 'CS-AUD',  8, 7, 7, '2026-06-12 14:00', '2026-06-12 16:00', 'seminar',   80, 'completed',
    '2026-06-08 10:00', 'Approved — guest speaker seminar on AI ethics.', NULL,
    '2026-06-12 13:50', 'Clean, microphone and livestream tested.', '2026-06-12 16:15', 'Clean, microphone stored, chairs re-aligned.', 'Guest lecture by Prof. R. Kumar on AI Ethics and Society.');

-- Normal Operations — Full Lifecycle (workshop by TA)
INSERT INTO dbo.BOOKING (requester_id, space_code, decision_staff_id, check_in_staff_id, completion_staff_id,
    requested_start_time, requested_end_time, purpose, expected_participants, booking_status,
    decision_time, decision_note, rejection_reason,
    actual_start_time, initial_condition, actual_end_time, final_condition, usage_notes) VALUES
(5, 'CS-LAB1', 6, 6, 6, '2026-06-14 10:00', '2026-06-14 12:00', 'workshop',  15, 'completed',
    '2026-06-09 09:00', 'Approved — Python workshop for undergraduates.', NULL,
    '2026-06-14 10:02', 'All workstations functional, room temperature comfortable.', '2026-06-14 12:00', 'All workstations logged off, chairs pushed in.', 'CS199: Python for Data Science workshop.');

-- Normal Operations — Full Lifecycle (student activity)
INSERT INTO dbo.BOOKING (requester_id, space_code, decision_staff_id, check_in_staff_id, completion_staff_id,
    requested_start_time, requested_end_time, purpose, expected_participants, booking_status,
    decision_time, decision_note, rejection_reason,
    actual_start_time, initial_condition, actual_end_time, final_condition, usage_notes) VALUES
(1, 'CS-WORK', 6, 7, 7, '2026-06-17 09:00', '2026-06-17 12:00', 'student_activity', 15, 'completed',
    '2026-06-12 14:00', 'Approved — ACM student chapter study group.', NULL,
    '2026-06-17 08:55', 'All desks clean, whiteboard markers available.', '2026-06-17 12:10', 'Clean, some chairs moved to group configuration.', 'ACM study group: algorithm problem-solving session.');

-- Normal Operations — Pending (awaiting decision, future date)
INSERT INTO dbo.BOOKING (requester_id, space_code, decision_staff_id, check_in_staff_id, completion_staff_id,
    requested_start_time, requested_end_time, purpose, expected_participants, booking_status,
    decision_time, decision_note, rejection_reason,
    actual_start_time, initial_condition, actual_end_time, final_condition, usage_notes) VALUES
(1, 'CS-WORK', NULL, NULL, NULL, '2026-06-28 13:00', '2026-06-28 15:00', 'student_activity', 20, 'pending',
    NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

-- Normal Operations — Rejected (with mandatory rejection reason)
INSERT INTO dbo.BOOKING (requester_id, space_code, decision_staff_id, check_in_staff_id, completion_staff_id,
    requested_start_time, requested_end_time, purpose, expected_participants, booking_status,
    decision_time, decision_note, rejection_reason,
    actual_start_time, initial_condition, actual_end_time, final_condition, usage_notes) VALUES
(5, 'CS-LAB1', 7, NULL, NULL, '2026-06-16 10:00', '2026-06-16 12:00', 'workshop',  25, 'rejected',
    '2026-06-11 16:00', 'Rejected — computer lab scheduled for preventive maintenance during requested window.',
    'Scheduling conflict with planned lab maintenance. Please select an alternative date.',
    NULL, NULL, NULL, NULL, NULL);

-- Normal Operations — Cancelled (from pending, no decision required)
INSERT INTO dbo.BOOKING (requester_id, space_code, decision_staff_id, check_in_staff_id, completion_staff_id,
    requested_start_time, requested_end_time, purpose, expected_participants, booking_status,
    decision_time, decision_note, rejection_reason,
    actual_start_time, initial_condition, actual_end_time, final_condition, usage_notes) VALUES
(3, 'CS-101', NULL, NULL, NULL, '2026-06-18 09:00', '2026-06-18 11:00', 'lecture',   35, 'cancelled',
    NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

-- Normal Operations — Approved (future, not yet checked in)
INSERT INTO dbo.BOOKING (requester_id, space_code, decision_staff_id, check_in_staff_id, completion_staff_id,
    requested_start_time, requested_end_time, purpose, expected_participants, booking_status,
    decision_time, decision_note, rejection_reason,
    actual_start_time, initial_condition, actual_end_time, final_condition, usage_notes) VALUES
(4, 'CS-MEET', 8, NULL, NULL, '2026-06-27 10:00', '2026-06-27 12:00', 'meeting',    8, 'approved',
    '2026-06-23 15:00', 'Approved — curriculum committee meeting.', NULL,
    NULL, NULL, NULL, NULL, NULL);

-- Normal Operations — Currently Checked In (ongoing session)
INSERT INTO dbo.BOOKING (requester_id, space_code, decision_staff_id, check_in_staff_id, completion_staff_id,
    requested_start_time, requested_end_time, purpose, expected_participants, booking_status,
    decision_time, decision_note, rejection_reason,
    actual_start_time, initial_condition, actual_end_time, final_condition, usage_notes) VALUES
(3, 'CS-AUD',  8, 6, NULL, '2026-06-24 13:00', '2026-06-24 16:00', 'examination', 150, 'checked_in',
    '2026-06-20 09:00', 'Approved — CS301 final examination.', NULL,
    '2026-06-24 13:05', 'Exam papers distributed to all rows. Room clean and quiet.', NULL, NULL, NULL);

-- Normal Operations — No-Show (approved but unattended)
INSERT INTO dbo.BOOKING (requester_id, space_code, decision_staff_id, check_in_staff_id, completion_staff_id,
    requested_start_time, requested_end_time, purpose, expected_participants, booking_status,
    decision_time, decision_note, rejection_reason,
    actual_start_time, initial_condition, actual_end_time, final_condition, usage_notes) VALUES
(1, 'CS-LAB2', 7, NULL, NULL, '2026-06-15 14:00', '2026-06-15 16:00', 'student_activity', 12, 'no_show',
    '2026-06-10 11:00', 'Approved — group project work session.', NULL,
    NULL, NULL, NULL, NULL, NULL);

-- Normal Operations — Completed booking with boundary participant count (1)
INSERT INTO dbo.BOOKING (requester_id, space_code, decision_staff_id, check_in_staff_id, completion_staff_id,
    requested_start_time, requested_end_time, purpose, expected_participants, booking_status,
    decision_time, decision_note, rejection_reason,
    actual_start_time, initial_condition, actual_end_time, final_condition, usage_notes) VALUES
(5, 'CS-LAB1', 6, 6, 6, '2026-06-19 09:00', '2026-06-19 10:00', 'workshop',   1, 'completed',
    '2026-06-14 10:00', 'Approved — one-on-one tutoring session.', NULL,
    '2026-06-19 08:58', 'Single workstation powered on and ready.', '2026-06-19 10:00', 'Workstation logged off, room clean.', 'One-on-one Python tutoring for a graduate student.');

-- Normal Operations — Short-notice completed booking (30 minutes)
INSERT INTO dbo.BOOKING (requester_id, space_code, decision_staff_id, check_in_staff_id, completion_staff_id,
    requested_start_time, requested_end_time, purpose, expected_participants, booking_status,
    decision_time, decision_note, rejection_reason,
    actual_start_time, initial_condition, actual_end_time, final_condition, usage_notes) VALUES
(5, 'CS-MEET', 6, 6, 6, '2026-06-20 15:00', '2026-06-20 15:30', 'meeting',    4, 'completed',
    '2026-06-18 09:00', 'Approved — quick stand-up sync.', NULL,
    '2026-06-20 15:00', 'Room clean, conferencing system ready.', '2026-06-20 15:25', 'Clean, conferencing system powered off.', 'Weekly TA coordination stand-up.');

-- Exceptional Case — Back-to-back booking on same space (boundary: no overlap with B1)
-- B1 ends at 11:00; this starts at 11:00.  The trigger overlap check uses strict
-- inequalities (start < end AND end > start), so 11:00 < 11:00 is false → no overlap.
INSERT INTO dbo.BOOKING (requester_id, space_code, decision_staff_id, check_in_staff_id, completion_staff_id,
    requested_start_time, requested_end_time, purpose, expected_participants, booking_status,
    decision_time, decision_note, rejection_reason,
    actual_start_time, initial_condition, actual_end_time, final_condition, usage_notes) VALUES
(4, 'CS-101',  8, 7, 7, '2026-06-10 11:00', '2026-06-10 13:00', 'lecture',   25, 'completed',
    '2026-06-05 15:00', 'Approved — guest lecture on algorithms.', NULL,
    '2026-06-10 11:00', 'Clean, previous session just ended.', '2026-06-10 12:55', 'Clean, whiteboard erased.', 'Guest lecture: Graph Algorithms in Practice.');

-- Exceptional Case — Pending booking on a space that is under_maintenance
-- Tests that pending bookings can be created on unavailable spaces (trigger only
-- validates at approval time).  Updating this to 'approved' should fail.
INSERT INTO dbo.BOOKING (requester_id, space_code, decision_staff_id, check_in_staff_id, completion_staff_id,
    requested_start_time, requested_end_time, purpose, expected_participants, booking_status,
    decision_time, decision_note, rejection_reason,
    actual_start_time, initial_condition, actual_end_time, final_condition, usage_notes) VALUES
(1, 'CS-103', NULL, NULL, NULL, '2026-06-25 10:00', '2026-06-25 12:00', 'student_activity', 10, 'pending',
    NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

-- Exceptional Case — Pending booking on a temporarily_closed space by a suspended user
-- Tests: (a) pending bookings allowed on closed spaces, (b) suspended accounts can
-- still submit booking requests (account status is enforced at application layer).
INSERT INTO dbo.BOOKING (requester_id, space_code, decision_staff_id, check_in_staff_id, completion_staff_id,
    requested_start_time, requested_end_time, purpose, expected_participants, booking_status,
    decision_time, decision_note, rejection_reason,
    actual_start_time, initial_condition, actual_end_time, final_condition, usage_notes) VALUES
(2, 'CS-102', NULL, NULL, NULL, '2026-06-26 14:00', '2026-06-26 16:00', 'student_activity', 15, 'pending',
    NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

-- Exceptional Case — Booking on retired space (pending; tests Space Availability Gate at approval)
INSERT INTO dbo.BOOKING (requester_id, space_code, decision_staff_id, check_in_staff_id, completion_staff_id,
    requested_start_time, requested_end_time, purpose, expected_participants, booking_status,
    decision_time, decision_note, rejection_reason,
    actual_start_time, initial_condition, actual_end_time, final_condition, usage_notes) VALUES
(3, 'CS-R401', NULL, NULL, NULL, '2026-06-30 09:00', '2026-06-30 11:00', 'lecture',   20, 'pending',
    NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

-- Exceptional Case — Pending booking by a deactivated user
-- Tests application-level authorization: DB does not prevent deactivated users from
-- submitting requests, but the application layer should block them.
INSERT INTO dbo.BOOKING (requester_id, space_code, decision_staff_id, check_in_staff_id, completion_staff_id,
    requested_start_time, requested_end_time, purpose, expected_participants, booking_status,
    decision_time, decision_note, rejection_reason,
    actual_start_time, initial_condition, actual_end_time, final_condition, usage_notes) VALUES
(10, 'CS-WORK', NULL, NULL, NULL, '2026-06-29 09:00', '2026-06-29 11:00', 'student_activity', 5, 'pending',
    NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

-- Exceptional Case — Rejected booking where rejection reason tests capacity check
-- Application-level rule: expected_participants exceeds room capacity (20 > 12).
-- Database does not enforce capacity cross-table, but it is a documented business rule.
INSERT INTO dbo.BOOKING (requester_id, space_code, decision_staff_id, check_in_staff_id, completion_staff_id,
    requested_start_time, requested_end_time, purpose, expected_participants, booking_status,
    decision_time, decision_note, rejection_reason,
    actual_start_time, initial_condition, actual_end_time, final_condition, usage_notes) VALUES
(1, 'CS-MEET', 7, NULL, NULL, '2026-06-22 14:00', '2026-06-22 16:00', 'meeting',   20, 'rejected',
    '2026-06-18 10:00', 'Rejected — room capacity exceeded.',
    'Expected 20 participants exceeds the room capacity of 12. Please select a larger venue.',
    NULL, NULL, NULL, NULL, NULL);

-- Exceptional Case — Completed booking with very long usage notes (VARCHAR(MAX) boundary)
INSERT INTO dbo.BOOKING (requester_id, space_code, decision_staff_id, check_in_staff_id, completion_staff_id,
    requested_start_time, requested_end_time, purpose, expected_participants, booking_status,
    decision_time, decision_note, rejection_reason,
    actual_start_time, initial_condition, actual_end_time, final_condition, usage_notes) VALUES
(3, 'CS-101',  6, 6, 6, '2026-06-08 09:00', '2026-06-08 11:00', 'lecture',   30, 'completed',
    '2026-06-03 14:00', 'Approved — regular lecture.', NULL,
    '2026-06-08 08:55', 'Room clean, all equipment functioning.', '2026-06-08 11:05', 'Clean, whiteboard erased, chairs straightened.',
    'CS301 lecture covering relational algebra. Students were engaged with in-class exercises. Whiteboard markers running low — facility staff notified. Projector bulb appears dim; suggested replacement during next maintenance cycle. Room temperature was comfortable throughout. No incidents reported.');

-- ============================================================================
-- 5. MAINTENANCE_RECORD (child of USER and SPACE)
--    PK: maintenance_id (IDENTITY).  No child tables reference it.
-- ============================================================================

-- Normal Operations — Completed maintenance (full lifecycle: reported → in_progress → completed)
INSERT INTO dbo.MAINTENANCE_RECORD (space_code, reporter_id, assigned_staff_id, problem_description, start_time, completion_time, status, result_note) VALUES
('CS-101', 6, 7, 'Projector bulb burned out. Image is dim and flickering.', '2026-06-01 09:00', '2026-06-01 14:00', 'completed',
 'Replaced projector bulb with new OEM unit. Brightness and color calibrated. Tested for 30 minutes — no flickering.');

-- Normal Operations — In-progress maintenance (reported by lecturer, assigned to staff)
INSERT INTO dbo.MAINTENANCE_RECORD (space_code, reporter_id, assigned_staff_id, problem_description, start_time, completion_time, status, result_note) VALUES
('CS-AUD',  3, 6, 'Microphone system producing persistent feedback noise during lectures. Wireless handheld mic is worst affected.', '2026-06-22 10:00', NULL, 'in_progress', NULL);

-- Normal Operations — Reported, not yet assigned (tests NULL assigned_staff_id)
INSERT INTO dbo.MAINTENANCE_RECORD (space_code, reporter_id, assigned_staff_id, problem_description, start_time, completion_time, status, result_note) VALUES
('CS-LAB1', 5, NULL, 'Workstation 5 blue-screens on boot with error code 0xC000021A. All other stations appear normal.', '2026-06-23 14:00', NULL, 'reported', NULL);

-- Normal Operations — In-progress without assigned staff (alternative path)
INSERT INTO dbo.MAINTENANCE_RECORD (space_code, reporter_id, assigned_staff_id, problem_description, start_time, completion_time, status, result_note) VALUES
('CS-WORK', 1, 7, 'Ceiling light panel in the north-east corner is flickering intermittently. Affects approximately four desk positions.', '2026-06-20 08:00', NULL, 'in_progress', NULL);

-- Exceptional Case — Maintenance causing space to be under_maintenance
-- This record IS the reason CS-103 is under_maintenance. Tests the link between
-- maintenance records and space availability (BR 2: spaces under maintenance cannot be booked).
INSERT INTO dbo.MAINTENANCE_RECORD (space_code, reporter_id, assigned_staff_id, problem_description, start_time, completion_time, status, result_note) VALUES
('CS-103', 6, 6, 'Air conditioning unit is not cooling. Room temperature consistently exceeds 30°C during afternoon hours. Thermostat appears unresponsive.', '2026-06-18 08:00', NULL, 'in_progress', NULL);

-- Exceptional Case — Completed with very short turnaround (15 minutes, boundary test)
-- Tests chk_maintenance_timeline_order: start_time < completion_time is satisfied (10:00 < 10:15).
INSERT INTO dbo.MAINTENANCE_RECORD (space_code, reporter_id, assigned_staff_id, problem_description, start_time, completion_time, status, result_note) VALUES
('CS-LAB2', 7, 7, 'Network cable at station 12 is physically damaged — outer sheath is frayed and copper is exposed.', '2026-06-21 10:00', '2026-06-21 10:15', 'completed',
 'Replaced damaged Cat6 cable with new one. Network connectivity verified at 1 Gbps. No other stations affected.');

-- Exceptional Case — Maintenance with NULL completion fields (status=reported, completion_time IS NULL allowed)
-- Tests NULL handling: status <> 'completed', so completion_time and result_note can be NULL.
INSERT INTO dbo.MAINTENANCE_RECORD (space_code, reporter_id, assigned_staff_id, problem_description, start_time, completion_time, status, result_note) VALUES
('CS-MEET', 4, NULL, 'Video conferencing system audio cuts out intermittently during calls. The issue occurs approximately every 15 minutes and lasts 5-10 seconds.', '2026-06-19 09:00', NULL, 'reported', NULL);
GO

-- ============================================================================
-- 6. SPACE_FACILITY (junction table — child of SPACE and FACILITY)
--    Composite PK: (space_code, facility_id).  No IDENTITY columns.
--    FK: CASCADE delete on both parents.
-- ============================================================================

-- Normal Operations — Well-equipped spaces with multiple facilities
INSERT INTO dbo.SPACE_FACILITY (space_code, facility_id) VALUES
-- CS-101: Standard classroom equipment
('CS-101', 1),  -- Projector
('CS-101', 2),  -- Whiteboard
('CS-101', 6),  -- Air Conditioner

-- CS-AUD: Full auditorium setup
('CS-AUD', 1),  -- Projector
('CS-AUD', 3),  -- Microphone
('CS-AUD', 5),  -- Livestreaming Equipment
('CS-AUD', 6),  -- Air Conditioner
('CS-AUD', 7),  -- Video Conferencing System

-- CS-LAB1: Computer lab with smart board
('CS-LAB1', 2), -- Whiteboard
('CS-LAB1', 4), -- Desktop Computer
('CS-LAB1', 6), -- Air Conditioner
('CS-LAB1', 8), -- Smart Board

-- CS-LAB2: Project lab
('CS-LAB2', 2), -- Whiteboard
('CS-LAB2', 4), -- Desktop Computer
('CS-LAB2', 6), -- Air Conditioner

-- CS-MEET: Meeting room
('CS-MEET', 2), -- Whiteboard
('CS-MEET', 6), -- Air Conditioner
('CS-MEET', 7), -- Video Conferencing System

-- CS-WORK: Student workspace
('CS-WORK', 2), -- Whiteboard
('CS-WORK', 6), -- Air Conditioner

-- CS-102: Temporarily closed room — still has facilities recorded
('CS-102', 1),  -- Projector
('CS-102', 2),  -- Whiteboard
('CS-102', 6);  -- Air Conditioner

-- Exceptional Cases — Spaces with minimal or no facilities

-- CS-103: Under-maintenance space — minimal facilities
INSERT INTO dbo.SPACE_FACILITY (space_code, facility_id) VALUES
('CS-103', 2),  -- Whiteboard
('CS-103', 6);  -- Air Conditioner (currently broken — see maintenance record)

-- CS-R401: Retired space — intentionally has NO facilities assigned (zero-row test)
-- No INSERT for CS-R401. Tests the optional participation on the SPACE side.
GO

-- ============================================================================
-- 7. POST-FLIGHT: Re-enable the INSTEAD OF trigger on BOOKING
-- ============================================================================

ENABLE TRIGGER dbo.trg_booking_validation ON dbo.BOOKING;
GO

-- ============================================================================
-- End of Sample Data Preparation
-- Total rows: USER=12, SPACE=9, FACILITY=8, BOOKING=19, MAINTENANCE_RECORD=7,
--             SPACE_FACILITY=23
-- ============================================================================

-- ============================================================================
-- SCENARIO DOCUMENTATION
-- ============================================================================
--
-- NORMAL OPERATIONS COVERED:
--
-- N1: Full Booking Lifecycle (pending → approved → checked_in → completed)
--     Rows: BOOKING rows 1-4 (B1-B4) — four bookings by different requester types
--     (lecturer, lecturer, TA, student) on different space types (classroom,
--     auditorium, computer_lab, student_workspace), each passing through the
--     complete lifecycle with distinct staff members for decision, check-in, and
--     completion.  Demonstrates standard day-to-day operations across all roles.
--
-- N2: Pending Booking Awaiting Decision
--     Row: BOOKING row 5 (B5) — a student activity booking on CS-WORK with a
--     future date (2026-06-28).  All optional decision/check-in/completion fields
--     are NULL.  The booking_status remains 'pending' (the DEFAULT value).
--
-- N3: Rejected Booking with Mandatory Fields
--     Row: BOOKING row 6 (B6) — a TA workshop request rejected by facility staff.
--     Verifies CHECK constraints: decision_staff_id, decision_time, decision_note,
--     and rejection_reason are all populated (as required by
--     chk_booking_decision_required_fields and chk_booking_rejection_reason).
--
-- N4: Cancelled Booking (from Pending)
--     Row: BOOKING row 7 (B7) — a lecturer cancels a booking from pending state.
--     Decision fields are NULL (valid per chk_booking_decision_required_fields
--     since 'cancelled' is not in ('approved', 'rejected')).
--
-- N5: Approved Future Booking (Not Yet Checked In)
--     Row: BOOKING row 8 (B8) — approved with decision fields populated, but
--     check-in and completion fields are NULL.  Demonstrates the intermediate
--     'approved' state before session execution.
--
-- N6: Currently Checked-In Session
--     Row: BOOKING row 9 (B9) — an examination currently in progress.  Verifies
--     chk_booking_checkin_required_fields: actual_start_time, check_in_staff_id,
--     and initial_condition are all populated; actual_end_time and final_condition
--     are NULL.
--
-- N7: No-Show Booking
--     Row: BOOKING row 10 (B10) — an approved booking where the requester never
--     arrived.  Decision fields are populated, but check-in and completion fields
--     are NULL.  Valid per state machine: approved → no_show.
--
-- N8: Completed Maintenance (Full Lifecycle)
--     Row: MAINTENANCE_RECORD row 1 (M1) — reported, assigned, and completed.
--     Verifies chk_maintenance_completion_required_fields: completion_time and
--     result_note are populated when status='completed'.
--
-- N9: In-Progress Maintenance (Assigned)
--     Row: MAINTENANCE_RECORD row 2 (M2) — actively being worked on by assigned
--     staff.  completion_time is NULL (valid per chk_maintenance_timeline_order).
--
-- N10: Reported Maintenance (Unassigned)
--     Row: MAINTENANCE_RECORD row 3 (M3) — reported but not yet assigned to
--     staff.  assigned_staff_id is NULL.
--
-- N11: Well-Equipped Space with Multiple Facilities
--     Rows: SPACE_FACILITY entries for CS-AUD (5 facilities) and CS-LAB1
--     (4 facilities).  Demonstrates the M:N resolution through the junction table.
--
-- N12: Multi-Role Staff Dispatch
--     BOOKING rows 1-4 demonstrate distinct staff members filling the decision,
--     check-in, and completion roles (Frank Thompson = decision/check-in/completion
--     for B1, Henry Garcia = decision for B2, Grace Liu = check-in/completion for
--     B2). Validates the multiple FK references from BOOKING to USER.
--
-- N13: Cross-Department User
--     Row: USER row 11 (Karen O'Neil) — a Physics student using CS spaces.
--     Demonstrates that the system serves users from multiple departments.
--
--
-- EXCEPTIONAL CASES COVERED:
--
-- E1: Back-to-Back Bookings on Same Space (No-Overlap Boundary)
--     Row: BOOKING row 13 (insert #13) on CS-101, 2026-06-10 11:00–13:00.
--     B1 ends at 11:00 on the same space.  The INSTEAD OF trigger uses strict
--     inequalities: b.start < i.end AND b.end > i.start.  Since 11:00 is NOT
--     strictly greater than 11:00, no overlap is detected when two bookings abut
--     at the same minute.  Demonstrates the logical boundary condition of the
--     overlap formula.  (Note: because B1 holds status='completed', the trigger
--     would only check overlap against bookings with status='approved'.  B8 at
--     CS-MEET serves as the pre-existing approved booking for trigger-based
--     overlap testing.)
--     Target: trg_booking_validation Gate 2 overlap formula boundary.
--
-- E2: Pending Booking on Unavailable Space (Under Maintenance)
--     Row: BOOKING row 14 (B14) on CS-103 (current_status='under_maintenance').
--     A pending booking CAN be created on an unavailable space — the trigger only
--     enforces the availability gate (Gate 1) when booking_status='approved'.
--     This row provides a pre-condition for testing that updating B14 to 'approved'
--     is correctly rejected by trg_booking_validation Gate 1 (Space Availability).
--     Target: BR 2, trg_booking_validation Gate 1.
--
-- E3: Pending Booking on Temporarily Closed Space by Suspended User
--     Row: BOOKING row 15 (B15) on CS-102 (current_status='temporarily_closed'),
--     requester_id=2 (Bob Williams, account_status='suspended').
--     Tests: (a) pending bookings allowed on temporarily_closed spaces,
--     (b) suspended accounts can still submit booking requests (no DB-level
--     constraint links account_status to booking ability — enforcement is at the
--     application layer per Logical Design §4.3).
--     Target: BR 2 (space gate), BR 1 (valid account), Logical Design §4.3.
--
-- E4: Pending Booking on Retired Space
--     Row: BOOKING row 16 (B16) on CS-R401 (current_status='retired').
--     Tests that pending bookings can be created on retired spaces, but approval
--     should be blocked by the trigger.  Completes the triad of unavailable space
--     statuses: under_maintenance, temporarily_closed, retired.
--     Target: BR 2, trg_booking_validation Gate 1.
--
-- E5: Deactivated User Booking
--     Row: BOOKING row 17 (B17), requester_id=10 (Jack Robinson,
--     account_status='deactivated').  The database does not reject this booking
--     because account_status is not referenced by any CHECK constraint on BOOKING.
--     Application middleware must enforce that deactivated users cannot submit
--     booking requests.
--     Target: BR 1 (valid university account), Logical Design §4.3.
--
-- E6: Rejected Booking — Capacity Exceeded (Business Rule)
--     Row: BOOKING row 18 (insert #18) on CS-MEET (capacity=12), expected_participants=20.
--     The database schema does not enforce a cross-table capacity check between
--     BOOKING.expected_participants and SPACE.capacity.  This rejection is assumed
--     to be performed at the application layer.  The row validates that the schema
--     itself does not reject the insertion (only business logic at the app layer
--     would enforce this rule).
--     Target: BR regarding expected participants vs capacity.
--
-- E7: Completed Booking with Boundary Participant Count (1)
--     Row: BOOKING row 11 (B11) — expected_participants=1, the minimum valid
--     value.  Tests chk_booking_participants_boundary: CHECK(expected_participants>0).
--     Value 1 is the smallest integer that satisfies the constraint.
--     Target: chk_booking_participants_boundary.
--
-- E8: Short-Duration Booking (30 Minutes)
--     Row: BOOKING row 12 (B12) — requested duration 15:00–15:30 (30 min).
--     Tests chk_booking_timeline_order: requested_start_time < requested_end_time,
--     and chk_booking_actual_timeline_order: actual_start_time (15:00) <
--     actual_end_time (15:25).  Both CHECK constraints satisfied with narrow margin.
--     Target: chk_booking_timeline_order, chk_booking_actual_timeline_order.
--
-- E9: Suspended User Account
--     Row: USER row 2 (Bob Williams) — account_status='suspended'.  Tests the
--     chk_user_account_status_domain CHECK constraint, which permits 'suspended'
--     as a valid account_status value.  The application must enforce that suspended
--     users cannot perform privileged operations.
--     Target: chk_user_account_status_domain.
--
-- E10: Deactivated User Account
--     Row: USER row 10 (Jack Robinson) — account_status='deactivated'.  Tests the
--     chk_user_account_status_domain CHECK constraint.  All three account status
--     values are represented: active, suspended, deactivated.
--     Target: chk_user_account_status_domain.
--
-- E11: Very Long User Full Name (VARCHAR Boundary)
--     Row: USER row 12 — full_name is 46 characters, testing VARCHAR(255) storage.
--     Verifies that compound names with special characters (hyphens) are handled.
--     Target: Column data type boundary.
--
-- E12: Space with Zero Facilities (Optional Participation)
--     Space CS-R401 has NO entries in SPACE_FACILITY.  Tests optional
--     participation on the SPACE side of the M:N relationship.  Verifies that the
--     junction table allows spaces to exist without any facility assignments.
--     Target: Optional participation constraint (Business Req Analysis §7).
--
-- E13: Maintenance Causing Space Unavailability
--     Row: MAINTENANCE_RECORD row 5 (M5) on CS-103 (current_status=
--     'under_maintenance').  Links the maintenance record to the space's
--     unavailable status.  Any attempt to approve a booking on CS-103 should be
--     rejected by the trigger because the space is under_maintenance.
--     Target: BR 2, trg_booking_validation Gate 1, data narrative consistency.
--
-- E14: Completed Maintenance with Very Short Duration
--     Row: MAINTENANCE_RECORD row 6 (M6) — 15 minutes from start to completion.
--     Tests chk_maintenance_timeline_order: start_time (10:00) < completion_time
--     (10:15) with a small margin.  Also tests chk_maintenance_completion_required_fields:
--     status='completed' requires completion_time and result_note (both present).
--     Target: chk_maintenance_timeline_order, chk_maintenance_completion_required_fields.
--
-- E15: Maintenance Record with NULL Completion Fields (Status = 'reported')
--     Row: MAINTENANCE_RECORD row 7 (M7) — status='reported', completion_time IS
--     NULL.  Permitted by chk_maintenance_timeline_order: "completion_time IS NULL
--     OR start_time < completion_time" — the first disjunct is TRUE.
--     Target: chk_maintenance_timeline_order (NULL handling branch).
--
-- E16: In-Progress Maintenance Without Assigned Staff
--     Row: MAINTENANCE_RECORD row 4 (M4) — status='in_progress' but
--     assigned_staff_id IS NULL (assigned_staff_id is nullable per schema).
--     Tests that the schema permits work-in-progress without a formal assignment.
--     Target: NOT NULL constraint on assigned_staff_id (it IS nullable).
--
-- E17: Very Long Usage Notes (VARCHAR(MAX) Boundary)
--     Row: BOOKING row 19 (insert #19) — usage_notes contains 250+ characters of
--     detailed session notes.  Tests VARCHAR(MAX) column capacity.
--     Target: Column data type boundary.
--
-- E18: All Six User Roles Represented
--     USER rows 1-12 cover all six defined roles: student, lecturer,
--     teaching_assistant, facility_staff, department_administrator, and
--     facility_manager.  Tests chk_user_role_domain.
--     Target: chk_user_role_domain.
--
-- E19: All Six Space Types Represented
--     SPACE rows 1-9 cover all six defined types: auditorium, classroom,
--     computer_lab, project_lab, meeting_room, student_workspace.
--     Tests chk_space_type_domain.
--     Target: chk_space_type_domain.
--
-- E20: All Five Space Statuses Represented
--     SPACE statuses: available (CS-101, CS-AUD, CS-LAB1, CS-LAB2, CS-MEET,
--     CS-WORK), under_maintenance (CS-103), temporarily_closed (CS-102),
--     retired (CS-R401).  'in_use' is not explicitly seeded because it is a
--     transient status managed by application logic, but the CHECK constraint
--     permits it.
--     Target: chk_space_status_domain.
--
-- E21: Composite Key Uniqueness on SPACE Location
--     SPACE rows: (building='Computer Science Building', floor=1, room_number='101')
--     appears only once (CS-101).  Tests uq_space_location.
--     Target: uq_space_location UNIQUE constraint.
--
-- E22: Unique Constraints on USER
--     Every email and phone_number is unique across all 12 USER rows.
--     Tests uq_user_email and uq_user_phone_number.
--     Target: uq_user_email, uq_user_phone_number.
--
-- E23: Pre-Existing Approved Booking for Trigger Overlap Testing
--     Row: BOOKING row 8 (insert #8) on CS-MEET, status='approved',
--     2026-06-27 10:00–12:00.  This booking provides the pre-existing approved
--     state against which the trigger's Gate 2 overlap detection is tested:
--     any attempt to INSERT a new approved booking on CS-MEET that overlaps
--     with [10:00, 12:00] should be rejected by trg_booking_validation.
--     Target: trg_booking_validation Gate 2 (live overlap rejection).
