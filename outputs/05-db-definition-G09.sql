-- ============================================================================
-- Campus Space Management System — Database Definition (G09)
-- Target: Microsoft SQL Server (T-SQL)
-- ============================================================================

CREATE DATABASE CampusSpaceManagementSystem;
GO
USE CampusSpaceManagementSystem;
GO

SET NOCOUNT ON;

-- ============================================================================
-- DROP phase (reverse dependency order) — re-runnable script
-- ============================================================================

IF OBJECT_ID('dbo.trg_booking_enforce_rules', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_booking_enforce_rules;
GO

IF OBJECT_ID('dbo.SPACE_FACILITY', 'U') IS NOT NULL
    DROP TABLE dbo.SPACE_FACILITY;
GO

IF OBJECT_ID('dbo.MAINTENANCE_RECORD', 'U') IS NOT NULL
    DROP TABLE dbo.MAINTENANCE_RECORD;
GO

IF OBJECT_ID('dbo.BOOKING', 'U') IS NOT NULL
    DROP TABLE dbo.BOOKING;
GO

IF OBJECT_ID('dbo.FACILITY', 'U') IS NOT NULL
    DROP TABLE dbo.FACILITY;
GO

IF OBJECT_ID('dbo.SPACE', 'U') IS NOT NULL
    DROP TABLE dbo.SPACE;
GO

IF OBJECT_ID('dbo.[USER]', 'U') IS NOT NULL
    DROP TABLE dbo.[USER];
GO

-- ============================================================================
-- 1. Independent parent tables
-- ============================================================================

CREATE TABLE dbo.[USER] (
    user_id         INT           IDENTITY(1,1) NOT NULL,
    full_name       VARCHAR(255)  NOT NULL,
    email           VARCHAR(255)  NOT NULL,
    phone_number    VARCHAR(20)   NOT NULL,
    role            VARCHAR(50)   NOT NULL,
    department      VARCHAR(255)  NOT NULL,
    account_status  VARCHAR(50)   NOT NULL
        CONSTRAINT df_user_account_status DEFAULT 'active',

    CONSTRAINT pk_user PRIMARY KEY (user_id),
    CONSTRAINT uq_user_email UNIQUE (email),
    CONSTRAINT uq_user_phone_number UNIQUE (phone_number),
    CONSTRAINT chk_user_role_domain
        CHECK ([role] IN ('student','lecturer','teaching_assistant',
              'facility_staff','department_administrator','facility_manager')),
    CONSTRAINT chk_user_account_status_domain
        CHECK ([account_status] IN ('active','suspended','deactivated'))
);
GO

CREATE TABLE dbo.SPACE (
    space_code      VARCHAR(50)   NOT NULL,
    space_name      VARCHAR(255)  NOT NULL,
    space_type      VARCHAR(50)   NOT NULL,
    building        VARCHAR(255)  NOT NULL,
    floor           INT           NOT NULL,
    room_number     VARCHAR(20)   NOT NULL,
    capacity        INT           NOT NULL,
    current_status  VARCHAR(50)   NOT NULL
        CONSTRAINT df_space_current_status DEFAULT 'available',
    usage_policy    VARCHAR(MAX)  NOT NULL,

    CONSTRAINT pk_space PRIMARY KEY (space_code),
    CONSTRAINT chk_space_type_domain
        CHECK ([space_type] IN ('auditorium','classroom','computer_lab',
              'project_lab','meeting_room','student_workspace')),
    CONSTRAINT chk_space_current_status_domain
        CHECK ([current_status] IN ('available','in_use','under_maintenance',
              'temporarily_closed','retired')),
    CONSTRAINT chk_space_capacity_positive
        CHECK ([capacity] > 0)
);
GO

CREATE TABLE dbo.FACILITY (
    facility_id    INT           IDENTITY(1,1) NOT NULL,
    facility_name  VARCHAR(255)  NOT NULL,

    CONSTRAINT pk_facility PRIMARY KEY (facility_id),
    CONSTRAINT uq_facility_facility_name UNIQUE (facility_name)
);
GO

-- ============================================================================
-- 2. Dependent child tables
-- ============================================================================

CREATE TABLE dbo.BOOKING (
    booking_id             INT           IDENTITY(1,1) NOT NULL,
    requester_id           INT           NOT NULL,
    space_code             VARCHAR(50)   NOT NULL,
    requested_start_time   DATETIME2     NOT NULL,
    requested_end_time     DATETIME2     NOT NULL,
    purpose                VARCHAR(50)   NOT NULL,
    expected_participants  INT           NOT NULL,
    booking_status         VARCHAR(50)   NOT NULL
        CONSTRAINT df_booking_booking_status DEFAULT 'pending',
    decision_staff_id      INT           NULL,
    decision_time          DATETIME2     NULL,
    decision_note          VARCHAR(MAX)  NULL,
    rejection_reason       VARCHAR(255)  NULL,
    actual_start_time      DATETIME2     NULL,
    check_in_staff_id      INT           NULL,
    initial_condition      VARCHAR(MAX)  NULL,
    actual_end_time        DATETIME2     NULL,
    completion_staff_id    INT           NULL,
    final_condition        VARCHAR(MAX)  NULL,
    usage_notes            VARCHAR(MAX)  NULL,

    CONSTRAINT pk_booking PRIMARY KEY (booking_id),
    CONSTRAINT chk_booking_purpose_domain
        CHECK ([purpose] IN ('lecture','examination','seminar','workshop',
              'meeting','student_activity','administrative_event')),
    CONSTRAINT chk_booking_status_domain
        CHECK ([booking_status] IN ('pending','approved','rejected','cancelled',
              'checked_in','completed','no_show')),
    CONSTRAINT chk_booking_participants_positive
        CHECK ([expected_participants] > 0),
    CONSTRAINT chk_booking_requested_timeline_order
        CHECK ([requested_start_time] < [requested_end_time]),
    CONSTRAINT chk_booking_actual_timeline_order
        CHECK ([actual_start_time] IS NULL
               OR [actual_end_time] IS NULL
               OR [actual_start_time] < [actual_end_time]),
    CONSTRAINT chk_booking_decision_fields
        CHECK ([booking_status] NOT IN ('approved','rejected')
               OR ([decision_staff_id] IS NOT NULL
                   AND [decision_time] IS NOT NULL
                   AND [decision_note] IS NOT NULL)),
    CONSTRAINT chk_booking_rejection_reason
        CHECK ([booking_status] <> 'rejected'
               OR [rejection_reason] IS NOT NULL),
    CONSTRAINT chk_booking_checkin_fields
        CHECK ([booking_status] NOT IN ('checked_in','completed')
               OR ([actual_start_time] IS NOT NULL
                   AND [check_in_staff_id] IS NOT NULL
                   AND [initial_condition] IS NOT NULL)),
    CONSTRAINT chk_booking_completion_fields
        CHECK ([booking_status] <> 'completed'
               OR ([actual_end_time] IS NOT NULL
                   AND [completion_staff_id] IS NOT NULL
                   AND [final_condition] IS NOT NULL
                   AND [usage_notes] IS NOT NULL))
);
GO

CREATE TABLE dbo.MAINTENANCE_RECORD (
    maintenance_id     INT           IDENTITY(1,1) NOT NULL,
    space_code         VARCHAR(50)   NOT NULL,
    reporter_id        INT           NOT NULL,
    assigned_staff_id  INT           NULL,
    problem_description VARCHAR(MAX)  NOT NULL,
    start_time         DATETIME2     NOT NULL,
    completion_time    DATETIME2     NULL,
    status             VARCHAR(50)   NOT NULL
        CONSTRAINT df_mr_status DEFAULT 'reported',
    result_note        VARCHAR(MAX)  NULL,

    CONSTRAINT pk_maintenance_record PRIMARY KEY (maintenance_id),
    CONSTRAINT chk_mr_status_domain
        CHECK ([status] IN ('reported','in_progress','completed')),
    CONSTRAINT chk_mr_timeline_order
        CHECK ([completion_time] IS NULL
               OR [start_time] < [completion_time]),
    CONSTRAINT chk_mr_completion_fields
        CHECK ([status] <> 'completed'
               OR ([completion_time] IS NOT NULL
                   AND [result_note] IS NOT NULL))
);
GO

-- ============================================================================
-- 3. Junction table
-- ============================================================================

CREATE TABLE dbo.SPACE_FACILITY (
    space_code   VARCHAR(50) NOT NULL,
    facility_id  INT         NOT NULL,

    CONSTRAINT pk_space_facility PRIMARY KEY (space_code, facility_id)
);
GO

-- ============================================================================
-- 4. Foreign key constraints
-- ============================================================================

-- BOOKING references

ALTER TABLE dbo.BOOKING
    ADD CONSTRAINT fk_booking_requester
        FOREIGN KEY (requester_id) REFERENCES dbo.[USER] (user_id);
GO

ALTER TABLE dbo.BOOKING
    ADD CONSTRAINT fk_booking_space
        FOREIGN KEY (space_code) REFERENCES dbo.SPACE (space_code);
GO

ALTER TABLE dbo.BOOKING
    ADD CONSTRAINT fk_booking_decision_staff
        FOREIGN KEY (decision_staff_id) REFERENCES dbo.[USER] (user_id);
GO

ALTER TABLE dbo.BOOKING
    ADD CONSTRAINT fk_booking_checkin_staff
        FOREIGN KEY (check_in_staff_id) REFERENCES dbo.[USER] (user_id);
GO

ALTER TABLE dbo.BOOKING
    ADD CONSTRAINT fk_booking_completion_staff
        FOREIGN KEY (completion_staff_id) REFERENCES dbo.[USER] (user_id);
GO

-- MAINTENANCE_RECORD references

ALTER TABLE dbo.MAINTENANCE_RECORD
    ADD CONSTRAINT fk_maintenance_record_space
        FOREIGN KEY (space_code) REFERENCES dbo.SPACE (space_code);
GO

ALTER TABLE dbo.MAINTENANCE_RECORD
    ADD CONSTRAINT fk_maintenance_record_reporter
        FOREIGN KEY (reporter_id) REFERENCES dbo.[USER] (user_id);
GO

ALTER TABLE dbo.MAINTENANCE_RECORD
    ADD CONSTRAINT fk_maintenance_record_assigned_staff
        FOREIGN KEY (assigned_staff_id) REFERENCES dbo.[USER] (user_id);
GO

-- SPACE_FACILITY references

ALTER TABLE dbo.SPACE_FACILITY
    ADD CONSTRAINT fk_space_facility_space
        FOREIGN KEY (space_code) REFERENCES dbo.SPACE (space_code)
        ON DELETE CASCADE;
GO

ALTER TABLE dbo.SPACE_FACILITY
    ADD CONSTRAINT fk_space_facility_facility
        FOREIGN KEY (facility_id) REFERENCES dbo.FACILITY (facility_id)
        ON DELETE CASCADE;
GO

-- ============================================================================
-- 5. Indexes
-- ============================================================================

CREATE UNIQUE INDEX uq_space_location
    ON dbo.SPACE (building, floor, room_number);
GO

-- ============================================================================
-- 6. Procedural enforcement trigger
-- ============================================================================

CREATE TRIGGER trg_booking_enforce_rules
ON dbo.BOOKING
INSTEAD OF INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Rule 1: Unavailable space gate
    --   A space with status under_maintenance, temporarily_closed, or retired
    --   cannot be referenced by any booking.
    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN dbo.SPACE s ON i.space_code = s.space_code
        WHERE s.current_status IN ('under_maintenance',
                                   'temporarily_closed',
                                   'retired')
    )
    BEGIN
        ;THROW 50000, 'Cannot create or update a booking referencing a space that is under maintenance, temporarily closed, or retired.', 1;
    END

    -- Rule 2: Overlapping approved booking prevention
    --   The same space must not host two approved bookings whose time periods
    --   overlap (start_a < end_b AND end_a > start_b). Self-exclusion by
    --   booking_id avoids false alarms during UPDATE of an already-approved row.
    IF EXISTS (
        SELECT 1
        FROM inserted i
        WHERE i.booking_status = 'approved'
          AND EXISTS (
              SELECT 1
              FROM dbo.BOOKING b
              WHERE b.space_code = i.space_code
                AND b.booking_status = 'approved'
                AND b.booking_id <> i.booking_id
                AND b.requested_start_time < i.requested_end_time
                AND b.requested_end_time > i.requested_start_time
          )
    )
    BEGIN
        ;THROW 50000, 'Overlapping approved booking already exists for this space during the requested time period.', 1;
    END

    -- Rule 3: Approval / Rejection role authorization
    --   Only users with role facility_staff or facility_manager may be recorded
    --   as the decision staff.
    IF EXISTS (
        SELECT 1
        FROM inserted i
        WHERE i.decision_staff_id IS NOT NULL
          AND NOT EXISTS (
              SELECT 1
              FROM dbo.[USER] u
              WHERE u.user_id = i.decision_staff_id
                AND u.role IN ('facility_staff', 'facility_manager')
          )
    )
    BEGIN
        ;THROW 50000, 'Only a user with role facility_staff or facility_manager may be recorded as the decision staff on a booking.', 1;
    END

    -- Rule 4: Check-in / Completion role authorization
    --   Only users with role facility_staff may be recorded as check-in or
    --   completion staff.
    IF EXISTS (
        SELECT 1
        FROM inserted i
        WHERE (
              i.check_in_staff_id IS NOT NULL
              AND NOT EXISTS (
                  SELECT 1
                  FROM dbo.[USER] u
                  WHERE u.user_id = i.check_in_staff_id
                    AND u.role = 'facility_staff'
              )
          )
          OR (
              i.completion_staff_id IS NOT NULL
              AND NOT EXISTS (
                  SELECT 1
                  FROM dbo.[USER] u
                  WHERE u.user_id = i.completion_staff_id
                    AND u.role = 'facility_staff'
              )
          )
    )
    BEGIN
        ;THROW 50000, 'Only a user with role facility_staff may be recorded as check-in or completion staff on a booking.', 1;
    END

    -- Forward valid operations

    IF EXISTS (SELECT 1 FROM deleted)
    BEGIN
        -- UPDATE: apply new values from inserted
        UPDATE t
        SET
            t.requester_id          = i.requester_id,
            t.space_code            = i.space_code,
            t.requested_start_time  = i.requested_start_time,
            t.requested_end_time    = i.requested_end_time,
            t.purpose               = i.purpose,
            t.expected_participants = i.expected_participants,
            t.booking_status        = i.booking_status,
            t.decision_staff_id     = i.decision_staff_id,
            t.decision_time         = i.decision_time,
            t.decision_note         = i.decision_note,
            t.rejection_reason      = i.rejection_reason,
            t.actual_start_time     = i.actual_start_time,
            t.check_in_staff_id     = i.check_in_staff_id,
            t.initial_condition     = i.initial_condition,
            t.actual_end_time       = i.actual_end_time,
            t.completion_staff_id   = i.completion_staff_id,
            t.final_condition       = i.final_condition,
            t.usage_notes           = i.usage_notes
        FROM dbo.BOOKING t
        INNER JOIN inserted i ON t.booking_id = i.booking_id;
    END
    ELSE
    BEGIN
        -- INSERT
        INSERT INTO dbo.BOOKING (
            requester_id,
            space_code,
            requested_start_time,
            requested_end_time,
            purpose,
            expected_participants,
            booking_status,
            decision_staff_id,
            decision_time,
            decision_note,
            rejection_reason,
            actual_start_time,
            check_in_staff_id,
            initial_condition,
            actual_end_time,
            completion_staff_id,
            final_condition,
            usage_notes
        )
        SELECT
            requester_id,
            space_code,
            requested_start_time,
            requested_end_time,
            purpose,
            expected_participants,
            booking_status,
            decision_staff_id,
            decision_time,
            decision_note,
            rejection_reason,
            actual_start_time,
            check_in_staff_id,
            initial_condition,
            actual_end_time,
            completion_staff_id,
            final_condition,
            usage_notes
        FROM inserted;
    END
END;
GO

-- ============================================================================
-- Business Rule Coverage
-- ============================================================================
--
-- BR   | Description                                       | Enforcement
-- -----|---------------------------------------------------|----------------------------------------
-- BR 1 | User account stored (user_id, full_name, email,   | Structural: USER table, PK + NOT NULL
--      |   phone, role, department, account_status)        |   + UNIQUE on email & phone_number
-- BR 2 | Space metadata (space_code, name, type, building, | Structural: SPACE table, PK + UNIQUE
--      |   floor, room, capacity, status, policy)          |   on (building, floor, room_number)
-- BR 3 | Space status domain (available, in_use,           | Structural: chk_space_current_status_domain
--      |   under_maintenance, temporarily_closed, retired) |
-- BR 4 | Facility catalogue per space                      | Structural: FACILITY + SPACE_FACILITY
--      |                                                   |   junction table (M:N resolved)
-- BR 5 | Booking submission (space, time range, purpose,   | Structural: BOOKING table + chk_booking_
--      |   participants)                                   |   purpose_domain + chk_booking_participants_
--      |                                                   |   positive + chk_booking_requested_timeline_
--      |                                                   |   order
-- BR 6 | Booking status lifecycle (pending, approved,      | Structural: chk_booking_status_domain +
--      |   rejected, cancelled, checked_in, completed,     |   chk_booking_decision_fields + chk_booking_
--      |   no_show)                                        |   rejection_reason + chk_booking_checkin_
--      |                                                   |   fields + chk_booking_completion_fields
-- BR 7 | No overlapping approved bookings for same space   | Procedural: trg_booking_enforce_rules
--      |                                                   |   (overlap check)
-- BR 8 | Unavailable space cannot be booked                | Procedural: trg_booking_enforce_rules
--      |   (under_maintenance, temporarily_closed,         |   (space availability gate)
--      |    retired)                                       |
-- BR 9 | Approval / Rejection by facility staff/manager    | Structural: FKs decision_staff_id,
--      |                                                   |   + chk_booking_decision_fields
--      |                                                   | Procedural: trg_booking_enforce_rules
--      |                                                   |   (role authorization)
-- BR10 | Rejection reason required when rejected           | Structural: chk_booking_rejection_reason
-- BR11 | Check-in records (actual start, staff, condition) | Structural: chk_booking_checkin_fields
--      |                                                   | Procedural: trg_booking_enforce_rules
--      |                                                   |   (role authorization)
-- BR12 | Completion records (actual end, final condition,  | Structural: chk_booking_completion_fields
--      |   usage notes)                                    | Procedural: trg_booking_enforce_rules
--      |                                                   |   (role authorization)
-- BR13 | Maintenance tracking (space, reporter, assigned,  | Structural: MAINTENANCE_RECORD table +
--      |   description, timeline, status, result)          |   chk_mr_status_domain + chk_mr_timeline_
--      |                                                   |   order + chk_mr_completion_fields
-- BR14 | Historical audit trail (no physical deletes)      | Structural: all base FK relationships use
--      |                                                   |   ON DELETE NO ACTION (RESTRICT semantics)
--
-- Deferred rules (application layer — no DB enforcement):
--   - User authentication (SSO / university account login)
--   - Booking status state-machine transition validation
--     (e.g., pending → approved, not pending → completed)
--   - Maintenance status state-machine transition validation
--   - Capacity-to-participant ratio warnings (human review)
--   - Privilege escalation for multi-role users
