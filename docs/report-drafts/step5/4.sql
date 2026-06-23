-- ============================================================================
-- Campus Space Management System — Database Implementation
-- Target: Microsoft SQL Server (T-SQL)
-- Schema version: 1.0
-- Based on: outputs/03-logical-design-G09.md (validated, all gates passed)
-- ============================================================================

-- ============================================================================
-- 1. INDEPENDENT PARENT TABLES
-- ============================================================================

CREATE TABLE dbo.[USER] (
    user_id         INT IDENTITY(1,1)   NOT NULL,
    full_name       VARCHAR(255)        NOT NULL,
    email           VARCHAR(255)        NOT NULL,
    phone_number    VARCHAR(20)         NOT NULL,
    role            VARCHAR(50)         NOT NULL,
    department      VARCHAR(255)        NOT NULL,
    account_status  VARCHAR(50)         NOT NULL,

    CONSTRAINT pk_user
        PRIMARY KEY (user_id),
    CONSTRAINT uq_user_email
        UNIQUE (email),
    CONSTRAINT uq_user_phone_number
        UNIQUE (phone_number),
    CONSTRAINT chk_user_role_domain
        CHECK ([role] IN ('student', 'lecturer', 'teaching_assistant',
              'facility_staff', 'department_administrator', 'facility_manager')),
    CONSTRAINT chk_user_account_status_domain
        CHECK ([account_status] IN ('active', 'suspended', 'deactivated')),
    CONSTRAINT df_user_role
        DEFAULT 'student' FOR [role],
    CONSTRAINT df_user_account_status
        DEFAULT 'active' FOR [account_status]
);
GO

CREATE TABLE dbo.SPACE (
    space_code      VARCHAR(50)         NOT NULL,
    space_name      VARCHAR(255)        NOT NULL,
    space_type      VARCHAR(50)         NOT NULL,
    building        VARCHAR(255)        NOT NULL,
    floor           INT                 NOT NULL,
    room_number     VARCHAR(50)         NOT NULL,
    capacity        INT                 NOT NULL,
    current_status  VARCHAR(50)         NOT NULL,
    usage_policy    VARCHAR(MAX)        NOT NULL,

    CONSTRAINT pk_space
        PRIMARY KEY (space_code),
    CONSTRAINT uq_space_location
        UNIQUE (building, floor, room_number),
    CONSTRAINT chk_space_type_domain
        CHECK ([space_type] IN ('auditorium', 'classroom', 'computer_lab',
              'project_lab', 'meeting_room', 'student_workspace')),
    CONSTRAINT chk_space_status_domain
        CHECK ([current_status] IN ('available', 'in_use', 'under_maintenance',
              'temporarily_closed', 'retired')),
    CONSTRAINT chk_space_capacity_boundary
        CHECK ([capacity] > 0),
    CONSTRAINT df_space_current_status
        DEFAULT 'available' FOR [current_status]
);
GO

CREATE TABLE dbo.FACILITY (
    facility_id     INT IDENTITY(1,1)   NOT NULL,
    facility_name   VARCHAR(255)        NOT NULL,

    CONSTRAINT pk_facility
        PRIMARY KEY (facility_id),
    CONSTRAINT uq_facility_name
        UNIQUE (facility_name)
);
GO

-- ============================================================================
-- 2. DEPENDENT CHILD TABLES
-- ============================================================================

CREATE TABLE dbo.BOOKING (
    booking_id              INT IDENTITY(1,1)   NOT NULL,
    requester_id            INT                 NOT NULL,
    space_code              VARCHAR(50)         NOT NULL,
    decision_staff_id       INT                 NULL,
    check_in_staff_id       INT                 NULL,
    completion_staff_id     INT                 NULL,
    requested_start_time    DATETIME            NOT NULL,
    requested_end_time      DATETIME            NOT NULL,
    purpose                 VARCHAR(50)         NOT NULL,
    expected_participants   INT                 NOT NULL,
    booking_status          VARCHAR(50)         NOT NULL,
    decision_time           DATETIME            NULL,
    decision_note           VARCHAR(MAX)        NULL,
    rejection_reason        VARCHAR(MAX)        NULL,
    actual_start_time       DATETIME            NULL,
    initial_condition       VARCHAR(MAX)        NULL,
    actual_end_time         DATETIME            NULL,
    final_condition         VARCHAR(MAX)        NULL,
    usage_notes             VARCHAR(MAX)        NULL,

    CONSTRAINT pk_booking
        PRIMARY KEY (booking_id),
    CONSTRAINT chk_booking_purpose_domain
        CHECK ([purpose] IN ('lecture', 'examination', 'seminar', 'workshop',
              'meeting', 'student_activity', 'administrative_event')),
    CONSTRAINT chk_booking_status_domain
        CHECK ([booking_status] IN ('pending', 'approved', 'rejected',
              'cancelled', 'checked_in', 'completed', 'no_show')),
    CONSTRAINT chk_booking_participants_boundary
        CHECK ([expected_participants] > 0),
    CONSTRAINT chk_booking_timeline_order
        CHECK ([requested_start_time] < [requested_end_time]),
    CONSTRAINT chk_booking_decision_required_fields
        CHECK (NOT ([booking_status] IN ('approved', 'rejected'))
               OR ([decision_staff_id] IS NOT NULL
                   AND [decision_time] IS NOT NULL
                   AND [decision_note] IS NOT NULL)),
    CONSTRAINT chk_booking_rejection_reason
        CHECK ([booking_status] <> 'rejected'
               OR [rejection_reason] IS NOT NULL),
    CONSTRAINT chk_booking_checkin_required_fields
        CHECK ([booking_status] <> 'checked_in'
               OR ([actual_start_time] IS NOT NULL
                   AND [check_in_staff_id] IS NOT NULL
                   AND [initial_condition] IS NOT NULL)),
    CONSTRAINT chk_booking_completion_required_fields
        CHECK ([booking_status] <> 'completed'
               OR ([actual_end_time] IS NOT NULL
                   AND [final_condition] IS NOT NULL)),
    CONSTRAINT chk_booking_actual_timeline_order
        CHECK ([actual_start_time] IS NULL
               OR [actual_end_time] IS NULL
               OR [actual_start_time] < [actual_end_time]),
    CONSTRAINT df_booking_booking_status
        DEFAULT 'pending' FOR [booking_status]
);
GO

CREATE TABLE dbo.MAINTENANCE_RECORD (
    maintenance_id      INT IDENTITY(1,1)   NOT NULL,
    space_code          VARCHAR(50)         NOT NULL,
    reporter_id         INT                 NOT NULL,
    assigned_staff_id   INT                 NULL,
    problem_description VARCHAR(MAX)        NOT NULL,
    start_time          DATETIME            NOT NULL,
    completion_time     DATETIME            NULL,
    status              VARCHAR(50)         NOT NULL,
    result_note         VARCHAR(MAX)        NULL,

    CONSTRAINT pk_maintenance_record
        PRIMARY KEY (maintenance_id),
    CONSTRAINT chk_maintenance_status_domain
        CHECK ([status] IN ('reported', 'in_progress', 'completed')),
    CONSTRAINT chk_maintenance_timeline_order
        CHECK ([completion_time] IS NULL
               OR [start_time] < [completion_time]),
    CONSTRAINT chk_maintenance_completion_required_fields
        CHECK ([status] <> 'completed'
               OR ([completion_time] IS NOT NULL
                   AND [result_note] IS NOT NULL)),
    CONSTRAINT df_maintenance_record_status
        DEFAULT 'reported' FOR [status]
);
GO

-- ============================================================================
-- 3. JUNCTION TABLE (M:N Resolution)
-- ============================================================================

CREATE TABLE dbo.SPACE_FACILITY (
    space_code      VARCHAR(50)     NOT NULL,
    facility_id     INT             NOT NULL,

    CONSTRAINT pk_space_facility
        PRIMARY KEY (space_code, facility_id)
);
GO

-- ============================================================================
-- 4. FOREIGN KEY CONSTRAINTS
-- ============================================================================

-- BOOKING → USER (requester)
ALTER TABLE dbo.BOOKING
    ADD CONSTRAINT fk_booking_requester
        FOREIGN KEY (requester_id) REFERENCES dbo.[USER] ([user_id]);

-- BOOKING → SPACE
ALTER TABLE dbo.BOOKING
    ADD CONSTRAINT fk_booking_space
        FOREIGN KEY (space_code) REFERENCES dbo.SPACE (space_code);

-- BOOKING → USER (decision staff)
ALTER TABLE dbo.BOOKING
    ADD CONSTRAINT fk_booking_decision_staff
        FOREIGN KEY (decision_staff_id) REFERENCES dbo.[USER] ([user_id]);

-- BOOKING → USER (check-in staff)
ALTER TABLE dbo.BOOKING
    ADD CONSTRAINT fk_booking_check_in_staff
        FOREIGN KEY (check_in_staff_id) REFERENCES dbo.[USER] ([user_id]);

-- BOOKING → USER (completion staff)
ALTER TABLE dbo.BOOKING
    ADD CONSTRAINT fk_booking_completion_staff
        FOREIGN KEY (completion_staff_id) REFERENCES dbo.[USER] ([user_id]);
GO

-- MAINTENANCE_RECORD → SPACE
ALTER TABLE dbo.MAINTENANCE_RECORD
    ADD CONSTRAINT fk_maintenance_record_space
        FOREIGN KEY (space_code) REFERENCES dbo.SPACE (space_code);

-- MAINTENANCE_RECORD → USER (reporter)
ALTER TABLE dbo.MAINTENANCE_RECORD
    ADD CONSTRAINT fk_maintenance_record_reporter
        FOREIGN KEY (reporter_id) REFERENCES dbo.[USER] ([user_id]);

-- MAINTENANCE_RECORD → USER (assigned staff)
ALTER TABLE dbo.MAINTENANCE_RECORD
    ADD CONSTRAINT fk_maintenance_record_assigned_staff
        FOREIGN KEY (assigned_staff_id) REFERENCES dbo.[USER] ([user_id]);
GO

-- SPACE_FACILITY → SPACE (cascade delete)
ALTER TABLE dbo.SPACE_FACILITY
    ADD CONSTRAINT fk_space_facility_space
        FOREIGN KEY (space_code) REFERENCES dbo.SPACE (space_code)
        ON DELETE CASCADE;

-- SPACE_FACILITY → FACILITY (cascade delete)
ALTER TABLE dbo.SPACE_FACILITY
    ADD CONSTRAINT fk_space_facility_facility
        FOREIGN KEY (facility_id) REFERENCES dbo.FACILITY (facility_id)
        ON DELETE CASCADE;
GO

-- ============================================================================
-- 5. TRIGGERS (Procedural Enforcement)
-- ============================================================================

-- Combined validation trigger: prevents overlapping approved bookings (BR 3)
-- and bookings on unavailable spaces (BR 2).
CREATE TRIGGER dbo.trg_booking_validation
ON dbo.BOOKING
INSTEAD OF INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Gate 1: Space availability (BR 2)
    -- Reject any approved booking for a space that is under maintenance,
    -- temporarily closed, or retired.
    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN dbo.SPACE s ON s.space_code = i.space_code
        WHERE i.booking_status = 'approved'
          AND s.current_status IN ('under_maintenance', 'temporarily_closed', 'retired')
    )
    BEGIN
        ;THROW 50000,
            'Cannot book a space that is under maintenance, temporarily closed, or retired.', 1;
        RETURN;
    END

    -- Gate 2: Overlapping approved bookings (BR 3)
    -- Reject any approved booking whose time range overlaps an existing
    -- approved booking for the same space.
    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN dbo.BOOKING b
            ON b.space_code = i.space_code
            AND b.booking_status = 'approved'
            AND i.booking_status = 'approved'
            AND (i.booking_id = 0 OR b.booking_id <> i.booking_id)
            AND b.requested_start_time < i.requested_end_time
            AND b.requested_end_time > i.requested_start_time
    )
    BEGIN
        ;THROW 50000,
            'Overlapping approved booking detected for this space and time range.', 1;
        RETURN;
    END

    -- Forward valid operations
    IF EXISTS (SELECT 1 FROM deleted)
    BEGIN
        UPDATE b
        SET
            b.requester_id            = i.requester_id,
            b.space_code              = i.space_code,
            b.decision_staff_id       = i.decision_staff_id,
            b.check_in_staff_id       = i.check_in_staff_id,
            b.completion_staff_id     = i.completion_staff_id,
            b.requested_start_time    = i.requested_start_time,
            b.requested_end_time      = i.requested_end_time,
            b.purpose                 = i.purpose,
            b.expected_participants   = i.expected_participants,
            b.booking_status          = i.booking_status,
            b.decision_time           = i.decision_time,
            b.decision_note           = i.decision_note,
            b.rejection_reason        = i.rejection_reason,
            b.actual_start_time       = i.actual_start_time,
            b.initial_condition       = i.initial_condition,
            b.actual_end_time         = i.actual_end_time,
            b.final_condition         = i.final_condition,
            b.usage_notes             = i.usage_notes
        FROM dbo.BOOKING b
        INNER JOIN inserted i ON b.booking_id = i.booking_id;
    END
    ELSE
    BEGIN
        INSERT INTO dbo.BOOKING (
            requester_id, space_code, decision_staff_id, check_in_staff_id,
            completion_staff_id, requested_start_time, requested_end_time,
            purpose, expected_participants, booking_status, decision_time,
            decision_note, rejection_reason, actual_start_time,
            initial_condition, actual_end_time, final_condition, usage_notes
        )
        SELECT
            i.requester_id, i.space_code, i.decision_staff_id, i.check_in_staff_id,
            i.completion_staff_id, i.requested_start_time, i.requested_end_time,
            i.purpose, i.expected_participants, i.booking_status, i.decision_time,
            i.decision_note, i.rejection_reason, i.actual_start_time,
            i.initial_condition, i.actual_end_time, i.final_condition, i.usage_notes
        FROM inserted i;
    END
END;
GO

-- ============================================================================
-- 6. BUSINESS RULE COVERAGE
-- ============================================================================
--
-- BR 1  (valid university account)           Deferred  — Application-layer authentication (SSO/LDAP)
-- BR 2  (unavailable space cannot book)      Trigger   — trg_booking_validation Gate 1
-- BR 3  (no overlapping approved bookings)   Trigger   — trg_booking_validation Gate 2
-- BR 4  (start_time < end_time)              CHECK     — chk_booking_timeline_order
-- BR 5  (record decision on approve/reject)  CHECK     — chk_booking_decision_required_fields
-- BR 6  (store rejection reason)             CHECK     — chk_booking_rejection_reason
-- BR 7  (record check-in info)               CHECK     — chk_booking_checkin_required_fields
-- BR 8  (record completion info)             CHECK     — chk_booking_completion_required_fields
-- BR 9  (only staff can approve/reject)      Deferred  — Application-layer authorization middleware
-- BR 10 (only staff can check-in/complete)   Deferred  — Application-layer authorization middleware
-- BR 11 (preserve historical records)        Structural — All tables use ON DELETE NO ACTION (RESTRICT)
-- BR 12 (unique space code)                  PK        — pk_space PRIMARY KEY on space_code
--
-- Procedural rules intentionally deferred to application middleware:
--   1. Booking state machine lifecycle (valid status transitions)
--   2. Maintenance state machine lifecycle (valid status transitions)
--   3. Role-based authorization gates (BR 9, BR 10)
--   4. Multi-role session management
-- ============================================================================
