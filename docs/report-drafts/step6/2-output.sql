-- ============================================================================
-- Campus Space Management System — Sample Data Preparation
-- Script: Populates all tables with realistic test data
-- Based on: outputs/05-database-implementation-G09.sql
-- ============================================================================

USE CampusSpaceManagement;
GO

-- ============================================================================
-- VARIABLE DECLARATIONS — Capture auto-generated IDENTITY values
-- ============================================================================

DECLARE @U_SarahChen         INT,
        @U_JamesMorrison     INT,
        @U_AliceWang         INT,
        @U_BobKumar          INT,
        @U_CarlosMendez      INT,
        @U_DianaPark         INT,
        @U_EmmaThompson      INT,
        @U_FrankLiu          INT,
        @U_GraceOkafor       INT,
        @U_HenryZhao         INT,
        @U_IreneNovak        INT,
        @U_TomBaker          INT;

DECLARE @F_Projector        INT,
        @F_Whiteboard       INT,
        @F_Microphone       INT,
        @F_Computer         INT,
        @F_AirConditioner   INT,
        @F_Livestreaming    INT,
        @F_SmartBoard       INT,
        @F_VideoConf        INT,
        @F_Speakers         INT,
        @F_DocCamera        INT;

-- ============================================================================
-- 1. TABLE: [USER]
-- Insertion order: 1 (no FK dependencies)
-- ============================================================================

-- Normal Operations: Standard active users across all roles

INSERT INTO dbo.[USER] (full_name, email, phone_number, role, department, account_status)
VALUES ('Dr. Sarah Chen', 'sarah.chen@university.edu', '+1-555-0101', 'lecturer', 'Computer Science', 'active');
SET @U_SarahChen = SCOPE_IDENTITY();

INSERT INTO dbo.[USER] (full_name, email, phone_number, role, department, account_status)
VALUES ('Prof. James Morrison', 'james.morrison@university.edu', '+1-555-0102', 'lecturer', 'Mathematics', 'active');
SET @U_JamesMorrison = SCOPE_IDENTITY();

INSERT INTO dbo.[USER] (full_name, email, phone_number, role, department, account_status)
VALUES ('Alice Wang', 'alice.wang@university.edu', '+1-555-0103', 'teaching_assistant', 'Computer Science', 'active');
SET @U_AliceWang = SCOPE_IDENTITY();

INSERT INTO dbo.[USER] (full_name, email, phone_number, role, department, account_status)
VALUES ('Bob Kumar', 'bob.kumar@university.edu', '+1-555-0104', 'student', 'Computer Science', 'active');
SET @U_BobKumar = SCOPE_IDENTITY();

INSERT INTO dbo.[USER] (full_name, email, phone_number, role, department, account_status)
VALUES ('Carlos Mendez', 'carlos.mendez@university.edu', '+1-555-0105', 'facility_staff', 'Facilities Management', 'active');
SET @U_CarlosMendez = SCOPE_IDENTITY();

INSERT INTO dbo.[USER] (full_name, email, phone_number, role, department, account_status)
VALUES ('Dr. Diana Park', 'diana.park@university.edu', '+1-555-0106', 'facility_manager', 'Facilities Management', 'active');
SET @U_DianaPark = SCOPE_IDENTITY();

INSERT INTO dbo.[USER] (full_name, email, phone_number, role, department, account_status)
VALUES ('Emma Thompson', 'emma.thompson@university.edu', '+1-555-0107', 'department_administrator', 'Computer Science', 'active');
SET @U_EmmaThompson = SCOPE_IDENTITY();

INSERT INTO dbo.[USER] (full_name, email, phone_number, role, department, account_status)
VALUES ('Frank Liu', 'frank.liu@university.edu', '+1-555-0108', 'student', 'Electrical Engineering', 'active');
SET @U_FrankLiu = SCOPE_IDENTITY();

INSERT INTO dbo.[USER] (full_name, email, phone_number, role, department, account_status)
VALUES ('Dr. Grace Okafor', 'grace.okafor@university.edu', '+1-555-0109', 'lecturer', 'Computer Science', 'active');
SET @U_GraceOkafor = SCOPE_IDENTITY();

INSERT INTO dbo.[USER] (full_name, email, phone_number, role, department, account_status)
VALUES ('Tom Baker', 'tom.baker@university.edu', '+1-555-0110', 'facility_staff', 'Facilities Management', 'active');
SET @U_TomBaker = SCOPE_IDENTITY();

-- Exceptional Cases: Accounts in non-active states

INSERT INTO dbo.[USER] (full_name, email, phone_number, role, department, account_status)
VALUES ('Henry Zhao', 'henry.zhao@university.edu', '+1-555-0111', 'student', 'Computer Science', 'suspended');
SET @U_HenryZhao = SCOPE_IDENTITY();
-- Tests: chk_user_account_status_domain accepts 'suspended'; suspended user still stored in system

INSERT INTO dbo.[USER] (full_name, email, phone_number, role, department, account_status)
VALUES ('Irene Novak', 'irene.novak@university.edu', '+1-555-0112', 'facility_staff', 'Facilities Management', 'deactivated');
SET @U_IreneNovak = SCOPE_IDENTITY();
-- Tests: chk_user_account_status_domain accepts 'deactivated'; deactivated staff appear in historical records

-- ============================================================================
-- 2. TABLE: SPACE
-- Insertion order: 1 (no FK dependencies)
-- ============================================================================

-- Normal Operations: Available and in-use spaces of each type

INSERT INTO dbo.SPACE (space_code, space_name, space_type, building, floor, room_number, capacity, current_status, usage_policy)
VALUES ('AUD-101', 'Main Auditorium', 'auditorium', 'Mathematics Building', 1, 'A101', 300, 'available',
        'Priority for seminars, guest lectures, and large academic events. Booking requires at least 14 days advance notice. No food or beverages permitted.');

INSERT INTO dbo.SPACE (space_code, space_name, space_type, building, floor, room_number, capacity, current_status, usage_policy)
VALUES ('CLR-201', 'Classroom 201', 'classroom', 'Computer Science Building', 2, '201', 50, 'available',
        'Standard lecture and tutorial room. Available for regular courses, review sessions, and examinations.');

INSERT INTO dbo.SPACE (space_code, space_name, space_type, building, floor, room_number, capacity, current_status, usage_policy)
VALUES ('CLR-202', 'Classroom 202', 'classroom', 'Computer Science Building', 2, '202', 40, 'in_use',
        'Standard classroom for lectures and tutorials. Projector and whiteboard provided.');

INSERT INTO dbo.SPACE (space_code, space_name, space_type, building, floor, room_number, capacity, current_status, usage_policy)
VALUES ('CMP-301', 'Computer Lab Alpha', 'computer_lab', 'Computer Science Building', 3, '301', 30, 'available',
        'Equipped with 30 workstations running Windows and Linux. Suitable for programming labs, workshops, and software training sessions. No food or drinks near equipment.');

INSERT INTO dbo.SPACE (space_code, space_name, space_type, building, floor, room_number, capacity, current_status, usage_policy)
VALUES ('PRJ-401', 'Project Lab North', 'project_lab', 'Engineering Building', 4, '401', 20, 'available',
        'Open workspace for student capstone and research projects. Access restricted to enrolled project teams. 24/7 badge access for authorized members.');

INSERT INTO dbo.SPACE (space_code, space_name, space_type, building, floor, room_number, capacity, current_status, usage_policy)
VALUES ('MTR-501', 'Executive Meeting Room', 'meeting_room', 'Administration Building', 5, '501', 12, 'available',
        'Executive conference room with video conferencing. Priority for department administration meetings and faculty committees.');

INSERT INTO dbo.SPACE (space_code, space_name, space_type, building, floor, room_number, capacity, current_status, usage_policy)
VALUES ('STW-101', 'Student Workspace A', 'student_workspace', 'Student Center', 1, '101', 25, 'available',
        'Open collaborative workspace for students. First-come, first-served basis during regular hours. Group bookings accepted for student organization activities.');

-- Exceptional Cases: Spaces in non-bookable statuses or with boundary capacity values

INSERT INTO dbo.SPACE (space_code, space_name, space_type, building, floor, room_number, capacity, current_status, usage_policy)
VALUES ('MTR-502', 'Small Boardroom', 'meeting_room', 'Administration Building', 5, '502', 6, 'under_maintenance',
        'Small boardroom for confidential meetings and interviews. Currently under maintenance — air conditioning repair in progress.');
-- Tests: chk_space_status_domain accepts 'under_maintenance'; trigger trg_booking_validation Gate 1 blocks approved bookings

INSERT INTO dbo.SPACE (space_code, space_name, space_type, building, floor, room_number, capacity, current_status, usage_policy)
VALUES ('CLR-103', 'Archived Classroom', 'classroom', 'Old Building', 1, '103', 1, 'retired',
        'Decommissioned classroom pending building renovation. No new bookings accepted.');
-- Tests: chk_space_capacity_boundary allows capacity=1 (boundary); chk_space_status_domain accepts 'retired'; trigger Gate 1 blocks approved bookings

INSERT INTO dbo.SPACE (space_code, space_name, space_type, building, floor, room_number, capacity, current_status, usage_policy)
VALUES ('CMP-302', 'Computer Lab Beta', 'computer_lab', 'Computer Science Building', 3, '302', 25, 'temporarily_closed',
        'Computer lab temporarily closed for network infrastructure upgrade. Expected reopening next semester.');
-- Tests: chk_space_status_domain accepts 'temporarily_closed'; trigger Gate 1 blocks approved bookings

-- ============================================================================
-- 3. TABLE: FACILITY
-- Insertion order: 1 (no FK dependencies)
-- ============================================================================

INSERT INTO dbo.FACILITY (facility_name) VALUES ('Projector');
SET @F_Projector = SCOPE_IDENTITY();

INSERT INTO dbo.FACILITY (facility_name) VALUES ('Whiteboard');
SET @F_Whiteboard = SCOPE_IDENTITY();

INSERT INTO dbo.FACILITY (facility_name) VALUES ('Microphone System');
SET @F_Microphone = SCOPE_IDENTITY();

INSERT INTO dbo.FACILITY (facility_name) VALUES ('Desktop Computer');
SET @F_Computer = SCOPE_IDENTITY();

INSERT INTO dbo.FACILITY (facility_name) VALUES ('Air Conditioner');
SET @F_AirConditioner = SCOPE_IDENTITY();

INSERT INTO dbo.FACILITY (facility_name) VALUES ('Livestreaming Equipment');
SET @F_Livestreaming = SCOPE_IDENTITY();

INSERT INTO dbo.FACILITY (facility_name) VALUES ('Smart Board');
SET @F_SmartBoard = SCOPE_IDENTITY();

INSERT INTO dbo.FACILITY (facility_name) VALUES ('Video Conferencing System');
SET @F_VideoConf = SCOPE_IDENTITY();

INSERT INTO dbo.FACILITY (facility_name) VALUES ('Ceiling Speakers');
SET @F_Speakers = SCOPE_IDENTITY();

INSERT INTO dbo.FACILITY (facility_name) VALUES ('Document Camera');
SET @F_DocCamera = SCOPE_IDENTITY();

-- ============================================================================
-- 4. TABLE: SPACE_FACILITY (Junction)
-- Insertion order: 2 (depends on SPACE and FACILITY)
-- ============================================================================

-- Normal Operations: Each space gets realistic facility assignments

-- AUD-101: Auditorium facilities
INSERT INTO dbo.SPACE_FACILITY (space_code, facility_id) VALUES ('AUD-101', @F_Projector);
INSERT INTO dbo.SPACE_FACILITY (space_code, facility_id) VALUES ('AUD-101', @F_Microphone);
INSERT INTO dbo.SPACE_FACILITY (space_code, facility_id) VALUES ('AUD-101', @F_Speakers);
INSERT INTO dbo.SPACE_FACILITY (space_code, facility_id) VALUES ('AUD-101', @F_Livestreaming);
INSERT INTO dbo.SPACE_FACILITY (space_code, facility_id) VALUES ('AUD-101', @F_AirConditioner);

-- CLR-201: Classroom facilities
INSERT INTO dbo.SPACE_FACILITY (space_code, facility_id) VALUES ('CLR-201', @F_Projector);
INSERT INTO dbo.SPACE_FACILITY (space_code, facility_id) VALUES ('CLR-201', @F_Whiteboard);
INSERT INTO dbo.SPACE_FACILITY (space_code, facility_id) VALUES ('CLR-201', @F_AirConditioner);
INSERT INTO dbo.SPACE_FACILITY (space_code, facility_id) VALUES ('CLR-201', @F_Computer);

-- CLR-202: Classroom facilities
INSERT INTO dbo.SPACE_FACILITY (space_code, facility_id) VALUES ('CLR-202', @F_Projector);
INSERT INTO dbo.SPACE_FACILITY (space_code, facility_id) VALUES ('CLR-202', @F_Whiteboard);
INSERT INTO dbo.SPACE_FACILITY (space_code, facility_id) VALUES ('CLR-202', @F_AirConditioner);

-- CMP-301: Computer lab facilities
INSERT INTO dbo.SPACE_FACILITY (space_code, facility_id) VALUES ('CMP-301', @F_Computer);
INSERT INTO dbo.SPACE_FACILITY (space_code, facility_id) VALUES ('CMP-301', @F_Projector);
INSERT INTO dbo.SPACE_FACILITY (space_code, facility_id) VALUES ('CMP-301', @F_AirConditioner);
INSERT INTO dbo.SPACE_FACILITY (space_code, facility_id) VALUES ('CMP-301', @F_SmartBoard);

-- PRJ-401: Project lab facilities
INSERT INTO dbo.SPACE_FACILITY (space_code, facility_id) VALUES ('PRJ-401', @F_Computer);
INSERT INTO dbo.SPACE_FACILITY (space_code, facility_id) VALUES ('PRJ-401', @F_Whiteboard);
INSERT INTO dbo.SPACE_FACILITY (space_code, facility_id) VALUES ('PRJ-401', @F_AirConditioner);
INSERT INTO dbo.SPACE_FACILITY (space_code, facility_id) VALUES ('PRJ-401', @F_DocCamera);

-- MTR-501: Meeting room facilities
INSERT INTO dbo.SPACE_FACILITY (space_code, facility_id) VALUES ('MTR-501', @F_VideoConf);
INSERT INTO dbo.SPACE_FACILITY (space_code, facility_id) VALUES ('MTR-501', @F_SmartBoard);
INSERT INTO dbo.SPACE_FACILITY (space_code, facility_id) VALUES ('MTR-501', @F_AirConditioner);

-- STW-101: Student workspace facilities
INSERT INTO dbo.SPACE_FACILITY (space_code, facility_id) VALUES ('STW-101', @F_Whiteboard);
INSERT INTO dbo.SPACE_FACILITY (space_code, facility_id) VALUES ('STW-101', @F_AirConditioner);
INSERT INTO dbo.SPACE_FACILITY (space_code, facility_id) VALUES ('STW-101', @F_Computer);

-- Exceptional Cases: Facilities on non-bookable spaces

-- MTR-502: Under-maintenance meeting room — retains its facility assignments
INSERT INTO dbo.SPACE_FACILITY (space_code, facility_id) VALUES ('MTR-502', @F_VideoConf);
INSERT INTO dbo.SPACE_FACILITY (space_code, facility_id) VALUES ('MTR-502', @F_AirConditioner);
-- Tests: Junction entries remain valid even when parent space is under_maintenance

-- CLR-103: Retired classroom — minimal remaining facilities
INSERT INTO dbo.SPACE_FACILITY (space_code, facility_id) VALUES ('CLR-103', @F_Whiteboard);
-- Tests: Retired space can still have facility associations for historical record-keeping

-- CMP-302: Temporarily closed lab — retains its facility assignments
INSERT INTO dbo.SPACE_FACILITY (space_code, facility_id) VALUES ('CMP-302', @F_Computer);
INSERT INTO dbo.SPACE_FACILITY (space_code, facility_id) VALUES ('CMP-302', @F_Projector);
INSERT INTO dbo.SPACE_FACILITY (space_code, facility_id) VALUES ('CMP-302', @F_AirConditioner);

-- ============================================================================
-- 5. TABLE: BOOKING
-- Insertion order: 3 (depends on USER and SPACE)
-- IMPORTANT: The INSTEAD OF trigger trg_booking_validation validates each
-- INSERT. Approved bookings on unavailable spaces and overlapping approved
-- bookings are rejected at the trigger level (Gates 1 and 2).
-- ============================================================================

-- ---------------------------------------------------------------------------
-- Normal Operations: All booking lifecycle stages
-- ---------------------------------------------------------------------------

-- B1: Past completed (full lifecycle — approved, checked in, completed)
INSERT INTO dbo.BOOKING (
    requester_id, space_code, requested_start_time, requested_end_time,
    purpose, expected_participants, booking_status,
    decision_staff_id, decision_time, decision_note,
    check_in_staff_id, actual_start_time, initial_condition,
    completion_staff_id, actual_end_time, final_condition, usage_notes
)
VALUES (
    @U_SarahChen, 'CLR-201',
    '2026-05-15 09:00:00', '2026-05-15 11:00:00',
    'lecture', 45, 'completed',
    @U_DianaPark, '2026-05-10 14:30:00', 'Approved — regular lecture, no conflicts.',
    @U_CarlosMendez, '2026-05-15 08:55:00', 'Room clean and ready. Projector tested, working.',
    @U_CarlosMendez, '2026-05-15 11:05:00', 'Room left in good condition. Whiteboard erased, chairs arranged.',
    'Lecture on Database Systems. No issues during session.'
);

-- B2: Currently checked in (mid-session)
INSERT INTO dbo.BOOKING (
    requester_id, space_code, requested_start_time, requested_end_time,
    purpose, expected_participants, booking_status,
    decision_staff_id, decision_time, decision_note,
    check_in_staff_id, actual_start_time, initial_condition,
    completion_staff_id, actual_end_time, final_condition, usage_notes
)
VALUES (
    @U_JamesMorrison, 'CMP-301',
    '2026-06-26 13:00:00', '2026-06-26 16:00:00',
    'workshop', 25, 'checked_in',
    @U_DianaPark, '2026-06-22 10:00:00', 'Approved — MATLAB workshop for graduate students.',
    @U_CarlosMendez, '2026-06-26 12:50:00', 'All 30 workstations booted. MATLAB license server verified.',
    NULL, NULL, NULL, NULL
);

-- B3: Future approved (not yet started)
INSERT INTO dbo.BOOKING (
    requester_id, space_code, requested_start_time, requested_end_time,
    purpose, expected_participants, booking_status,
    decision_staff_id, decision_time, decision_note,
    check_in_staff_id, actual_start_time, initial_condition,
    completion_staff_id, actual_end_time, final_condition, usage_notes
)
VALUES (
    @U_GraceOkafor, 'AUD-101',
    '2026-07-10 10:00:00', '2026-07-10 12:00:00',
    'seminar', 120, 'approved',
    @U_DianaPark, '2026-06-26 12:15:00', 'Approved — guest speaker seminar on AI Ethics, confirmed.',
    NULL, NULL, NULL,
    NULL, NULL, NULL, NULL
);

-- B4: Pending (awaiting staff decision)
INSERT INTO dbo.BOOKING (
    requester_id, space_code, requested_start_time, requested_end_time,
    purpose, expected_participants, booking_status,
    decision_staff_id, decision_time, decision_note,
    check_in_staff_id, actual_start_time, initial_condition,
    completion_staff_id, actual_end_time, final_condition, usage_notes
)
VALUES (
    @U_BobKumar, 'PRJ-401',
    '2026-07-15 14:00:00', '2026-07-15 17:00:00',
    'student_activity', 15, 'pending',
    NULL, NULL, NULL,
    NULL, NULL, NULL,
    NULL, NULL, NULL, NULL
);

-- B5: Rejected (with reason)
INSERT INTO dbo.BOOKING (
    requester_id, space_code, requested_start_time, requested_end_time,
    purpose, expected_participants, booking_status,
    decision_staff_id, decision_time, decision_note, rejection_reason,
    check_in_staff_id, actual_start_time, initial_condition,
    completion_staff_id, actual_end_time, final_condition, usage_notes
)
VALUES (
    @U_AliceWang, 'CLR-201',
    '2026-07-20 08:00:00', '2026-07-20 12:00:00',
    'examination', 40, 'rejected',
    @U_DianaPark, '2026-06-26 12:20:00',
    'Rejected after review.',
    'Room seating is fixed and cannot accommodate exam-style individual desk spacing for 40 students.',
    NULL, NULL, NULL,
    NULL, NULL, NULL, NULL
);

-- B6: Cancelled (was approved, then cancelled by requester)
INSERT INTO dbo.BOOKING (
    requester_id, space_code, requested_start_time, requested_end_time,
    purpose, expected_participants, booking_status,
    decision_staff_id, decision_time, decision_note,
    check_in_staff_id, actual_start_time, initial_condition,
    completion_staff_id, actual_end_time, final_condition, usage_notes
)
VALUES (
    @U_FrankLiu, 'STW-101',
    '2026-07-20 09:00:00', '2026-07-20 12:00:00',
    'student_activity', 10, 'cancelled',
    @U_DianaPark, '2026-06-24 09:00:00', 'Approved — IEEE student chapter study group.',
    NULL, NULL, NULL,
    NULL, NULL, NULL, NULL
);

-- B7: No-show (approved but requester never checked in)
INSERT INTO dbo.BOOKING (
    requester_id, space_code, requested_start_time, requested_end_time,
    purpose, expected_participants, booking_status,
    decision_staff_id, decision_time, decision_note,
    check_in_staff_id, actual_start_time, initial_condition,
    completion_staff_id, actual_end_time, final_condition, usage_notes
)
VALUES (
    @U_EmmaThompson, 'MTR-501',
    '2026-06-20 10:00:00', '2026-06-20 11:00:00',
    'meeting', 8, 'no_show',
    @U_DianaPark, '2026-06-18 15:45:00', 'Approved — curriculum committee meeting.',
    NULL, NULL, NULL,
    NULL, NULL, NULL, NULL
);

-- B8: Past completed (different staff for check-in vs completion)
INSERT INTO dbo.BOOKING (
    requester_id, space_code, requested_start_time, requested_end_time,
    purpose, expected_participants, booking_status,
    decision_staff_id, decision_time, decision_note,
    check_in_staff_id, actual_start_time, initial_condition,
    completion_staff_id, actual_end_time, final_condition, usage_notes
)
VALUES (
    @U_SarahChen, 'CLR-202',
    '2026-05-20 09:00:00', '2026-05-20 11:00:00',
    'lecture', 38, 'completed',
    @U_DianaPark, '2026-05-16 11:00:00', 'Approved — regular Algorithms lecture, no issues.',
    @U_TomBaker, '2026-05-20 08:50:00', 'Room ready. Projector bulb replaced prior to session.',
    @U_CarlosMendez, '2026-05-20 11:10:00', 'Room clean. All equipment powered down.',
    'Lecture on Graph Algorithms. Students left room tidy.'
);

-- B9: Future approved short meeting (30-minute duration — boundary test)
INSERT INTO dbo.BOOKING (
    requester_id, space_code, requested_start_time, requested_end_time,
    purpose, expected_participants, booking_status,
    decision_staff_id, decision_time, decision_note,
    check_in_staff_id, actual_start_time, initial_condition,
    completion_staff_id, actual_end_time, final_condition, usage_notes
)
VALUES (
    @U_EmmaThompson, 'MTR-501',
    '2026-07-25 14:00:00', '2026-07-25 14:30:00',
    'administrative_event', 4, 'approved',
    @U_DianaPark, '2026-06-26 12:30:00', 'Approved — quick department budget review.',
    NULL, NULL, NULL,
    NULL, NULL, NULL, NULL
);

-- ---------------------------------------------------------------------------
-- Exceptional Cases: Constraint boundaries and trigger edge conditions
-- ---------------------------------------------------------------------------

-- B10: Pending booking on space with current_status = 'under_maintenance' (MTR-502)
INSERT INTO dbo.BOOKING (
    requester_id, space_code, requested_start_time, requested_end_time,
    purpose, expected_participants, booking_status,
    decision_staff_id, decision_time, decision_note,
    check_in_staff_id, actual_start_time, initial_condition,
    completion_staff_id, actual_end_time, final_condition, usage_notes
)
VALUES (
    @U_JamesMorrison, 'MTR-502',
    '2026-07-08 09:00:00', '2026-07-08 11:00:00',
    'meeting', 5, 'pending',
    NULL, NULL, NULL,
    NULL, NULL, NULL,
    NULL, NULL, NULL, NULL
);
-- Tests: trg_booking_validation Gate 1 only blocks booking_status='approved' on unavailable spaces;
--        a pending booking on an under_maintenance space is allowed (decision happens at approval time)

-- B11: Pending booking on space with current_status = 'retired' (CLR-103)
INSERT INTO dbo.BOOKING (
    requester_id, space_code, requested_start_time, requested_end_time,
    purpose, expected_participants, booking_status,
    decision_staff_id, decision_time, decision_note,
    check_in_staff_id, actual_start_time, initial_condition,
    completion_staff_id, actual_end_time, final_condition, usage_notes
)
VALUES (
    @U_FrankLiu, 'CLR-103',
    '2026-07-12 10:00:00', '2026-07-12 12:00:00',
    'student_activity', 3, 'pending',
    NULL, NULL, NULL,
    NULL, NULL, NULL,
    NULL, NULL, NULL, NULL
);
-- Tests: trg_booking_validation Gate 1 only blocks approved bookings on retired spaces

-- B12: Rejected booking on temporarily_closed space (CMP-302) — realistic rejection scenario
INSERT INTO dbo.BOOKING (
    requester_id, space_code, requested_start_time, requested_end_time,
    purpose, expected_participants, booking_status,
    decision_staff_id, decision_time, decision_note, rejection_reason,
    check_in_staff_id, actual_start_time, initial_condition,
    completion_staff_id, actual_end_time, final_condition, usage_notes
)
VALUES (
    @U_AliceWang, 'CMP-302',
    '2026-07-18 13:00:00', '2026-07-18 15:00:00',
    'workshop', 20, 'rejected',
    @U_DianaPark, '2026-06-26 12:35:00',
    'Rejected — space unavailable.',
    'Computer Lab Beta is temporarily closed for network infrastructure upgrade until next semester.',
    NULL, NULL, NULL,
    NULL, NULL, NULL, NULL
);
-- Tests: chk_booking_rejection_reason ensures rejection_reason is NOT NULL when status='rejected';
--        realistic rejection flow via trigger Gate 1 (application layer would block before reaching DB,
--        but the rejection reason documents why it was denied)

-- B13a & B13b: Back-to-back approved bookings on the same space (CLR-201)
-- Tests: trg_booking_validation Gate 2 overlap detection boundary.
--        Overlap condition is start_time < other_end AND end_time > other_start.
--        With back-to-back: 11:00 < 13:00 AND 11:00 > 11:00 = TRUE AND FALSE → no overlap detected.

INSERT INTO dbo.BOOKING (
    requester_id, space_code, requested_start_time, requested_end_time,
    purpose, expected_participants, booking_status,
    decision_staff_id, decision_time, decision_note,
    check_in_staff_id, actual_start_time, initial_condition,
    completion_staff_id, actual_end_time, final_condition, usage_notes
)
VALUES (
    @U_SarahChen, 'CLR-201',
    '2026-07-05 09:00:00', '2026-07-05 11:00:00',
    'workshop', 30, 'approved',
    @U_DianaPark, '2026-06-26 12:40:00', 'Approved — Python for Data Science workshop, morning block.',
    NULL, NULL, NULL,
    NULL, NULL, NULL, NULL
);

INSERT INTO dbo.BOOKING (
    requester_id, space_code, requested_start_time, requested_end_time,
    purpose, expected_participants, booking_status,
    decision_staff_id, decision_time, decision_note,
    check_in_staff_id, actual_start_time, initial_condition,
    completion_staff_id, actual_end_time, final_condition, usage_notes
)
VALUES (
    @U_JamesMorrison, 'CLR-201',
    '2026-07-05 11:00:00', '2026-07-05 13:00:00',
    'seminar', 25, 'approved',
    @U_DianaPark, '2026-06-26 12:45:00', 'Approved — Applied Linear Algebra seminar, follows morning workshop.',
    NULL, NULL, NULL,
    NULL, NULL, NULL, NULL
);

-- B14: Pending booking whose time range overlaps with an already approved booking (CLR-201)
INSERT INTO dbo.BOOKING (
    requester_id, space_code, requested_start_time, requested_end_time,
    purpose, expected_participants, booking_status,
    decision_staff_id, decision_time, decision_note,
    check_in_staff_id, actual_start_time, initial_condition,
    completion_staff_id, actual_end_time, final_condition, usage_notes
)
VALUES (
    @U_BobKumar, 'CLR-201',
    '2026-07-05 10:00:00', '2026-07-05 12:00:00',
    'student_activity', 10, 'pending',
    NULL, NULL, NULL,
    NULL, NULL, NULL,
    NULL, NULL, NULL, NULL
);
-- Tests: trg_booking_validation Gate 2 overlap check only fires when both the inserted row AND
--        the existing row have booking_status='approved'. A pending booking overlapping an approved
--        booking is allowed at INSERT time. If the application later attempts to change this booking
--        to 'approved', the INSTEAD OF UPDATE trigger would detect the overlap and block it.

-- B15: Boundary test — minimum expected_participants = 1 and very short 30-minute duration
INSERT INTO dbo.BOOKING (
    requester_id, space_code, requested_start_time, requested_end_time,
    purpose, expected_participants, booking_status,
    decision_staff_id, decision_time, decision_note,
    check_in_staff_id, actual_start_time, initial_condition,
    completion_staff_id, actual_end_time, final_condition, usage_notes
)
VALUES (
    @U_HenryZhao, 'MTR-501',
    '2026-08-01 09:00:00', '2026-08-01 09:30:00',
    'meeting', 1, 'pending',
    NULL, NULL, NULL,
    NULL, NULL, NULL,
    NULL, NULL, NULL, NULL
);
-- Tests: chk_booking_participants_boundary allows expected_participants=1 (boundary value);
--        chk_booking_timeline_order allows 30-minute interval (minimum practical duration);
--        suspended user (Henry Zhao) can still submit a booking (account_status not enforced by trigger)

-- ============================================================================
-- 6. TABLE: MAINTENANCE_RECORD
-- Insertion order: 3 (depends on USER and SPACE)
-- ============================================================================

-- ---------------------------------------------------------------------------
-- Normal Operations: Standard maintenance lifecycle stages
-- ---------------------------------------------------------------------------

-- MR1: Newly reported — awaiting assignment
INSERT INTO dbo.MAINTENANCE_RECORD (
    space_code, reporter_id, assigned_staff_id,
    problem_description, start_time, completion_time, status, result_note
)
VALUES (
    'CMP-301', @U_CarlosMendez, NULL,
    'Projector bulb has burnt out. Image is dim and flickering. Needs replacement before next lab session.',
    '2026-06-25 08:00:00', NULL,
    'reported', NULL
);

-- MR2: In progress — staff assigned, work underway
INSERT INTO dbo.MAINTENANCE_RECORD (
    space_code, reporter_id, assigned_staff_id,
    problem_description, start_time, completion_time, status, result_note
)
VALUES (
    'MTR-502', @U_DianaPark, @U_CarlosMendez,
    'Air conditioning unit is running but not cooling. Room temperature reaches 30°C by midday. Thermostat may be faulty.',
    '2026-06-20 09:00:00', NULL,
    'in_progress', NULL
);

-- MR3: Completed — full history preserved
INSERT INTO dbo.MAINTENANCE_RECORD (
    space_code, reporter_id, assigned_staff_id,
    problem_description, start_time, completion_time, status, result_note
)
VALUES (
    'CLR-202', @U_TomBaker, @U_IreneNovak,
    'Whiteboard surface is deeply scratched and stained with permanent marker residue. Writing is barely legible from the back of the room.',
    '2026-05-10 08:00:00', '2026-05-12 16:00:00',
    'completed', 'Replaced entire whiteboard panel with new porcelain steel surface. Old panel disposed of per university recycling policy.'
);

-- ---------------------------------------------------------------------------
-- Exceptional Cases: Constraint boundaries and edge conditions
-- ---------------------------------------------------------------------------

-- MR4: Very short maintenance window (1 minute — boundary test for start_time < completion_time)
INSERT INTO dbo.MAINTENANCE_RECORD (
    space_code, reporter_id, assigned_staff_id,
    problem_description, start_time, completion_time, status, result_note
)
VALUES (
    'AUD-101', @U_EmmaThompson, @U_CarlosMendez,
    'Microphone system producing intermittent crackling noise during lectures. Suspected loose XLR connection at the podium input panel.',
    '2026-07-01 09:00:00', '2026-07-01 09:01:00',
    'completed', 'Loose XLR cable connector at podium input panel was re-seated and tightened. Audio tested — no further crackling.'
);
-- Tests: chk_maintenance_timeline_order requires start_time < completion_time;
--        a 1-minute difference is accepted as the minimum valid interval

-- MR5: Maintenance on a retired space (historical record-keeping)
INSERT INTO dbo.MAINTENANCE_RECORD (
    space_code, reporter_id, assigned_staff_id,
    problem_description, start_time, completion_time, status, result_note
)
VALUES (
    'CLR-103', @U_DianaPark, @U_TomBaker,
    'Water damage to ceiling tiles above the east wall. Brown stains and sagging visible. Possible roof leak from recent heavy rain.',
    '2026-04-01 07:00:00', '2026-04-03 15:00:00',
    'completed', 'Roof leak patched by Facilities contractor. Three damaged ceiling tiles replaced. Space inspected for mold — none detected.'
);
-- Tests: FK to retired space is valid; maintenance history is preserved even after space retirement

-- MR6: Reported with no assigned staff (NULL assigned_staff_id — tests optional FK handling)
INSERT INTO dbo.MAINTENANCE_RECORD (
    space_code, reporter_id, assigned_staff_id,
    problem_description, start_time, completion_time, status, result_note
)
VALUES (
    'CMP-301', @U_CarlosMendez, NULL,
    'Network switch on rack 3 is dropping packets intermittently. Affected workstations 15 through 22 lose connectivity for 2-3 minutes every hour.',
    '2026-06-26 07:00:00', NULL,
    'reported', NULL
);
-- Tests: assigned_staff_id is nullable per schema; maintenance record can exist before a staff member is designated

-- ============================================================================
-- END OF SAMPLE DATA INSERTION
-- ============================================================================

-- ============================================================================
-- SCENARIO DOCUMENTATION
-- ============================================================================
--
-- Normal Operations Covered:
--
-- * Lifecycle — Completed Booking (B1): Sarah Chen's lecture on CLR-201 went through the full
--   lifecycle: pending → approved (Diana Park) → checked_in (Carlos Mendez) → completed
--   (Carlos Mendez). All status-dependent fields are populated at each stage.
--
-- * Lifecycle — Checked-In Booking (B2): James Morrison's workshop on CMP-301 is mid-session,
--   demonstrating the checked_in state with actual_start_time, check_in_staff, and
--   initial_condition filled while completion fields remain NULL.
--
-- * Lifecycle — Future Approved Booking (B3): Grace Okafor's seminar on AUD-101 has been
--   approved but not yet started. Decision fields are populated; check-in and completion
--   fields are NULL.
--
-- * Lifecycle — Pending Booking (B4): Bob Kumar's student activity request on PRJ-401 is
--   awaiting staff review. All decision/check-in/completion fields are NULL.
--
-- * Lifecycle — Rejected Booking (B5): Alice Wang's examination request for CLR-201 was
--   reviewed and rejected with a specific reason. Verifies chk_booking_decision_required_fields
--   and chk_booking_rejection_reason constraints.
--
-- * Lifecycle — Cancelled Booking (B6): Frank Liu's student activity on STW-101 was approved
--   then later cancelled. Decision fields are present (from prior approval), but no operational
--   fields were ever populated.
--
-- * Lifecycle — No-Show Booking (B7): Emma Thompson's meeting on MTR-501 was approved but
--   nobody checked in. The booking transitioned from approved to no_show. Decision fields are
--   present; check-in and completion fields are NULL.
--
-- * Multi-Staff Operations (B1, B8): Two completed bookings demonstrate different staff members
--   handling check-in (Carlos Mendez/Tom Baker) vs. completion (Carlos Mendez) of the same session.
--
-- * Role Coverage: All six user roles are represented — student (Bob Kumar, Frank Liu, Henry Zhao),
--   lecturer (Sarah Chen, James Morrison, Grace Okafor), teaching_assistant (Alice Wang),
--   facility_staff (Carlos Mendez, Tom Baker, Irene Novak), department_administrator
--   (Emma Thompson), and facility_manager (Diana Park).
--
-- * Purpose Coverage: All seven booking purposes are used — lecture (B1, B8), examination (B5),
--   seminar (B3, B13b), workshop (B2, B12, B13a), meeting (B7, B10, B15), student_activity
--   (B4, B6, B11, B14), and administrative_event (B9).
--
-- * Space Type Coverage: All six space types are present — auditorium (AUD-101), classroom
--   (CLR-201, CLR-202, CLR-103), computer_lab (CMP-301, CMP-302), project_lab (PRJ-401),
--   meeting_room (MTR-501, MTR-502), and student_workspace (STW-101).
--
-- * Facility Assignments: The SPACE_FACILITY junction table maps each space to 2-5 realistic
--   facilities, demonstrating M:N relationship resolution.
--
-- * Maintenance Lifecycle: MR1-MR3 demonstrate all three maintenance statuses (reported,
--   in_progress, completed) with reporter and assigned staff relationships.
--
-- * Historical Data: Past bookings (B1, B7, B8) and completed maintenance records (MR3, MR4, MR5)
--   preserve historical records for auditing.
--
-- Exceptional Cases Covered:
--
-- * Trigger Gate 1 — Unavailable Space Booking Prevention (B10, B11, B12):
--   B10 (pending on under_maintenance MTR-502) and B11 (pending on retired CLR-103) verify that
--   the INSTEAD OF INSERT trigger does NOT block pending bookings on unavailable spaces — it only
--   enforces the gate when booking_status='approved'. B12 demonstrates the realistic application
--   flow: a request for a temporarily_closed space (CMP-302) is properly rejected with a clear
--   reason. These cases together test the boundary of trigger Gate 1.
--
-- * Trigger Gate 2 — Overlap Detection Boundary (B13a, B13b, B14):
--   B13a (CLR-201 09:00-11:00) and B13b (CLR-201 11:00-13:00) are back-to-back approved
--   bookings with zero gap. The temporal overlap formula is start1 < end2 AND end1 > start2;
--   with B13a ending at 11:00 and B13b starting at 11:00, the second condition evaluates to
--   FALSE (11:00 > 11:00 is false), so no overlap is detected. This tests the strictly-less-than
--   (not less-than-or-equal) boundary logic. B14 is a pending booking that overlaps B13a's
--   time range; it inserts successfully because Gate 2 only compares approved-to-approved rows.
--   If the application attempts to approve B14, the UPDATE trigger path would detect the overlap.
--
-- * CHECK Constraint Boundary — Minimum Values (B15, CLR-103):
--   B15 tests chk_booking_participants_boundary with expected_participants=1 (the smallest valid
--   positive integer). Space CLR-103 tests chk_space_capacity_boundary with capacity=1.
--
-- * CHECK Constraint — Timeline Integrity (B9, B15, MR4):
--   B9 and B15 demonstrate 30-minute booking durations, testing that
--   chk_booking_timeline_order (requested_start_time < requested_end_time) accepts tight margins.
--   MR4 has a 1-minute maintenance completion window, testing the same boundary for
--   chk_maintenance_timeline_order.
--
-- * CHECK Constraint — Status-Domain Enforcement (all rows):
--   All entries exercise their respective CHECK (col IN (...)) domain constraints for role,
--   account_status, space_type, current_status, purpose, booking_status, and maintenance status.
--
-- * CHECK Constraint — State-Contingent Nullability:
--   Approved and rejected bookings (B1, B2, B3, B5, B6, B7, B8, B9, B12, B13a, B13b) have
--   decision_staff_id, decision_time, and decision_note populated, satisfying
--   chk_booking_decision_required_fields. B5 and B12 additionally test
--   chk_booking_rejection_reason with rejection reasons. Checked-in bookings (B1, B2, B8) have
--   check-in fields populated; completed bookings (B1, B8) have completion fields populated.
--   Pending/cancelled/no_show bookings correctly leave inapplicable fields NULL.
--
-- * UNIQUE Constraints:
--   All 12 users have distinct email addresses and phone numbers. All 10 spaces have distinct
--   (building, floor, room_number) combinations. All 10 facilities have unique names.
--   No duplicate SPACE_FACILITY pairs.
--
-- * NULL FK Handling (MR1, MR6):
--   Both MR1 and MR6 have assigned_staff_id=NULL, verifying that the optional foreign key
--   accepts NULL values. This supports the workflow where a maintenance issue is reported before
--   a staff member is designated.
--
-- * Suspended/Deactivated Account Inclusion (Henry Zhao, Irene Novak):
--   Henry Zhao (suspended student) appears as a booking requester in B15, confirming that
--   account_status is not enforced at the FK or trigger level for booking submission.
--   Irene Novak (deactivated facility staff) appears as an assigned staff member in MR3,
--   preserving historical assignment records.
--
-- * Maintenance on Retired Space (MR5):
--   MR5 records a completed water-damage repair on CLR-103 (retired), validating that
--   maintenance history is preserved independently of space operational status.
--
-- * DEFAULT Value Verification:
--   No explicit account_status was provided for active users (they rely on DEFAULT 'active').
--   However, since the script explicitly sets account_status for all user inserts to ensure
--   clarity, DEFAULT behavior can be observed by omitting the column in ad-hoc testing.
--   Similarly, booking_status defaults to 'pending' and maintenance status defaults to
--   'reported'; these are explicitly set in the script for documentation clarity.

GO
