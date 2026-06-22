-- =============================================================================
-- Campus Space Management System — Database Implementation
-- Target: Microsoft SQL Server (T-SQL)
-- Based on: Validated Logical Design (Step 3) + Validation Pass (Step 4)
-- =============================================================================

-- =============================================================================
-- DROP statements (reverse dependency order for re-runnability)
-- =============================================================================

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

IF OBJECT_ID('dbo.USER', 'U') IS NOT NULL
    DROP TABLE dbo.[USER];
GO

-- =============================================================================
-- 1. Independent parent tables (no foreign keys to other tables)
-- =============================================================================

CREATE TABLE dbo.[USER] (
    user_id         INT             IDENTITY(1,1)
                        CONSTRAINT pk_user PRIMARY KEY,
    full_name       VARCHAR(255)    NOT NULL,
    email           VARCHAR(255)    NOT NULL,
    phone_number    VARCHAR(20)     NOT NULL,
    role            VARCHAR(50)     NOT NULL
                        CONSTRAINT df_user_role DEFAULT 'student',
    department      VARCHAR(255)    NOT NULL,
    account_status  VARCHAR(50)     NOT NULL
                        CONSTRAINT df_user_account_status DEFAULT 'active',

    CONSTRAINT uq_user_email       UNIQUE (email),
    CONSTRAINT uq_user_phone       UNIQUE (phone_number),
    CONSTRAINT chk_user_role_domain
        CHECK ([role] IN ('student', 'lecturer', 'teaching_assistant',
                          'facility_staff', 'department_administrator', 'facility_manager')),
    CONSTRAINT chk_user_account_status_domain
        CHECK ([account_status] IN ('active', 'suspended', 'deactivated'))
);
GO

CREATE TABLE dbo.SPACE (
    space_code      VARCHAR(50)     NOT NULL
                        CONSTRAINT pk_space PRIMARY KEY,
    space_name      VARCHAR(255)    NOT NULL,
    space_type      VARCHAR(50)     NOT NULL,
    building        VARCHAR(255)    NOT NULL,
    floor           INT             NOT NULL,
    room_number     VARCHAR(50)     NOT NULL,
    capacity        INT             NOT NULL,
    current_status  VARCHAR(50)     NOT NULL
                        CONSTRAINT df_space_current_status DEFAULT 'available',
    usage_policy    VARCHAR(MAX)    NOT NULL,

    CONSTRAINT uq_space_location
        UNIQUE (building, floor, room_number),
    CONSTRAINT chk_space_type_domain
        CHECK ([space_type] IN ('auditorium', 'classroom', 'computer_lab',
                                'project_lab', 'meeting_room', 'student_workspace')),
    CONSTRAINT chk_space_status_domain
        CHECK ([current_status] IN ('available', 'in_use', 'under_maintenance',
                                    'temporarily_closed', 'retired')),
    CONSTRAINT chk_space_capacity_boundary
        CHECK ([capacity] > 0)
);
GO

CREATE TABLE dbo.FACILITY (
    facility_id     INT             IDENTITY(1,1)
                        CONSTRAINT pk_facility PRIMARY KEY,
    facility_name   VARCHAR(255)    NOT NULL,

    CONSTRAINT uq_facility_name UNIQUE (facility_name)
);
GO

-- =============================================================================
-- 2. Dependent child tables (contain foreign key columns)
-- =============================================================================

CREATE TABLE dbo.BOOKING (
    booking_id              INT             IDENTITY(1,1)
                                CONSTRAINT pk_booking PRIMARY KEY,
    requester_id            INT             NOT NULL,
    space_code              VARCHAR(50)     NOT NULL,
    requested_start_time    DATETIME2       NOT NULL,
    requested_end_time      DATETIME2       NOT NULL,
    purpose                 VARCHAR(50)     NOT NULL,
    expected_participants   INT             NOT NULL,
    booking_status          VARCHAR(50)     NOT NULL
                                CONSTRAINT df_booking_booking_status DEFAULT 'pending',
    decision_staff_id       INT             NULL,
    decision_time           DATETIME2       NULL,
    decision_note           VARCHAR(MAX)    NULL,
    rejection_reason        VARCHAR(MAX)    NULL,
    check_in_staff_id       INT             NULL,
    actual_start_time       DATETIME2       NULL,
    initial_condition       VARCHAR(MAX)    NULL,
    completion_staff_id     INT             NULL,
    actual_end_time         DATETIME2       NULL,
    final_condition         VARCHAR(MAX)    NULL,
    usage_notes             VARCHAR(MAX)    NULL,

    CONSTRAINT chk_booking_purpose_domain
        CHECK ([purpose] IN ('lecture', 'examination', 'seminar', 'workshop',
                             'meeting', 'student_activity', 'administrative_event')),
    CONSTRAINT chk_booking_status_domain
        CHECK ([booking_status] IN ('pending', 'approved', 'rejected', 'cancelled',
                                    'checked_in', 'completed', 'no_show')),
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
        CHECK ([booking_status] <> 'rejected' OR [rejection_reason] IS NOT NULL),
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
               OR [actual_start_time] < [actual_end_time])
);
GO

CREATE TABLE dbo.MAINTENANCE_RECORD (
    maintenance_id      INT             IDENTITY(1,1)
                            CONSTRAINT pk_maintenance_record PRIMARY KEY,
    space_code          VARCHAR(50)     NOT NULL,
    reporter_id         INT             NOT NULL,
    assigned_staff_id   INT             NULL,
    problem_description VARCHAR(MAX)    NOT NULL,
    start_time          DATETIME2       NOT NULL,
    completion_time     DATETIME2       NULL,
    status              VARCHAR(50)     NOT NULL
                            CONSTRAINT df_maintenance_record_status DEFAULT 'reported',
    result_note         VARCHAR(MAX)    NULL,

    CONSTRAINT chk_maintenance_status_domain
        CHECK ([status] IN ('reported', 'in_progress', 'completed')),
    CONSTRAINT chk_maintenance_timeline_order
        CHECK ([completion_time] IS NULL OR [start_time] < [completion_time]),
    CONSTRAINT chk_maintenance_completion_required_fields
        CHECK ([status] <> 'completed'
               OR ([completion_time] IS NOT NULL AND [result_note] IS NOT NULL))
);
GO

-- =============================================================================
-- 3. Junction table (pure associative entity for M:N)
-- =============================================================================

CREATE TABLE dbo.SPACE_FACILITY (
    space_code      VARCHAR(50)     NOT NULL,
    facility_id     INT             NOT NULL,

    CONSTRAINT pk_space_facility PRIMARY KEY (space_code, facility_id)
);
GO

-- =============================================================================
-- 4. Foreign key constraints (ALTER TABLE)
-- =============================================================================

-- BOOKING foreign keys (4x → USER, 1x → SPACE)

ALTER TABLE dbo.BOOKING
    ADD CONSTRAINT fk_booking_requester
        FOREIGN KEY (requester_id) REFERENCES dbo.[USER](user_id);
GO

ALTER TABLE dbo.BOOKING
    ADD CONSTRAINT fk_booking_space
        FOREIGN KEY (space_code) REFERENCES dbo.SPACE(space_code);
GO

ALTER TABLE dbo.BOOKING
    ADD CONSTRAINT fk_booking_decision_staff
        FOREIGN KEY (decision_staff_id) REFERENCES dbo.[USER](user_id);
GO

ALTER TABLE dbo.BOOKING
    ADD CONSTRAINT fk_booking_check_in_staff
        FOREIGN KEY (check_in_staff_id) REFERENCES dbo.[USER](user_id);
GO

ALTER TABLE dbo.BOOKING
    ADD CONSTRAINT fk_booking_completion_staff
        FOREIGN KEY (completion_staff_id) REFERENCES dbo.[USER](user_id);
GO

-- MAINTENANCE_RECORD foreign keys (2x → USER, 1x → SPACE)

ALTER TABLE dbo.MAINTENANCE_RECORD
    ADD CONSTRAINT fk_maintenance_reporter
        FOREIGN KEY (reporter_id) REFERENCES dbo.[USER](user_id);
GO

ALTER TABLE dbo.MAINTENANCE_RECORD
    ADD CONSTRAINT fk_maintenance_assigned_staff
        FOREIGN KEY (assigned_staff_id) REFERENCES dbo.[USER](user_id);
GO

ALTER TABLE dbo.MAINTENANCE_RECORD
    ADD CONSTRAINT fk_maintenance_space
        FOREIGN KEY (space_code) REFERENCES dbo.SPACE(space_code);
GO

-- SPACE_FACILITY foreign keys (1x → SPACE, 1x → FACILITY) with CASCADE

ALTER TABLE dbo.SPACE_FACILITY
    ADD CONSTRAINT fk_space_facility_space
        FOREIGN KEY (space_code) REFERENCES dbo.SPACE(space_code)
        ON DELETE CASCADE;
GO

ALTER TABLE dbo.SPACE_FACILITY
    ADD CONSTRAINT fk_space_facility_facility
        FOREIGN KEY (facility_id) REFERENCES dbo.FACILITY(facility_id)
        ON DELETE CASCADE;
GO

-- =============================================================================
-- 5. Procedural enforcement (triggers for multi-row / cross-table rules)
-- =============================================================================

CREATE TRIGGER dbo.trg_booking_enforce_rules
ON dbo.BOOKING
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Rule: Space Availability Gate (Business Rule 2)
    -- A space with status 'under_maintenance', 'temporarily_closed', or 'retired'
    -- cannot be booked or have its booking updated.
    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN dbo.SPACE s ON i.space_code = s.space_code
        WHERE s.current_status IN ('under_maintenance', 'temporarily_closed', 'retired')
    )
    BEGIN
        THROW 50001, 'Cannot create or update a booking for a space that is under maintenance, temporarily closed, or retired.', 1;
    END

    -- Rule: Overlapping Booking Prevention (Business Rule 3)
    -- The same space must not have two approved bookings whose time periods overlap.
    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN dbo.BOOKING b
            ON i.space_code = b.space_code
            AND b.booking_id <> i.booking_id
            AND b.booking_status = 'approved'
            AND i.requested_start_time < b.requested_end_time
            AND i.requested_end_time > b.requested_start_time
    )
    BEGIN
        THROW 50002, 'The requested time overlaps with an existing approved booking for this space.', 1;
    END
END;
GO

-- =============================================================================
-- 6. Deferred procedural rules (enforced by application middleware)
-- =============================================================================

-- The following business rules are delegated to the application layer per the
-- validated logical design and are NOT implemented as database triggers or
-- stored procedures:
--
--   • Role-Based Authorization Gates (BR 9 & 10):
--     Only facility staff / facility managers may approve/reject bookings.
--     Only facility staff may perform check-in and session completion.
--
--   • Booking State Machine Lifecycle:
--     Valid transitions: pending → (approved | rejected | cancelled);
--     approved → (checked_in | cancelled | no_show);
--     checked_in → (completed | no_show).
--
--   • Maintenance State Machine Lifecycle:
--     Valid transitions: reported → in_progress → completed.
--
--   • Single Role per Session Model:
--     Multi-role switching is managed by the application layer and does not
--     require schema-level enforcement.
--
--   • No Recurring Bookings:
--     The system handles only individual, non-repeating booking requests.
