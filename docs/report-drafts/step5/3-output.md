-- ============================================================================
-- Database Implementation -- T-SQL DDL
-- Target:  Microsoft SQL Server
-- Source:  Validated Logical Design (outputs/03-logical-design-G09.md)
-- Status:  Step 4 validation passed (outputs/04-design-validation-G09.md)
-- ============================================================================

-- ============================================================================
-- 0. Re-runnable Cleanup (reverse dependency order)
-- ============================================================================

IF OBJECT_ID('dbo.trg_booking_validation', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_booking_validation;
GO

IF OBJECT_ID('dbo.SPACE_FACILITY', 'U') IS NOT NULL
    DROP TABLE dbo.SPACE_FACILITY;
GO

IF OBJECT_ID('dbo.BOOKING', 'U') IS NOT NULL
    DROP TABLE dbo.BOOKING;
GO

IF OBJECT_ID('dbo.MAINTENANCE_RECORD', 'U') IS NOT NULL
    DROP TABLE dbo.MAINTENANCE_RECORD;
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
-- 1. Independent Parent Tables
-- ============================================================================

-- TABLE: USER
CREATE TABLE dbo.[USER] (
    user_id        INT IDENTITY(1,1) NOT NULL,
    full_name      VARCHAR(255)      NOT NULL,
    email          VARCHAR(255)      NOT NULL,
    phone_number   VARCHAR(20)       NOT NULL,
    role           VARCHAR(50)       NOT NULL CONSTRAINT df_user_role DEFAULT 'student',
    department     VARCHAR(255)      NOT NULL,
    account_status VARCHAR(50)       NOT NULL CONSTRAINT df_user_account_status DEFAULT 'active',

    CONSTRAINT pk_user PRIMARY KEY (user_id),
    CONSTRAINT uq_user_email UNIQUE (email),
    CONSTRAINT uq_user_phone_number UNIQUE (phone_number),
    CONSTRAINT chk_user_role_domain CHECK (role IN (
        'student', 'lecturer', 'teaching_assistant',
        'facility_staff', 'department_administrator', 'facility_manager'
    )),
    CONSTRAINT chk_user_account_status_domain CHECK (account_status IN (
        'active', 'suspended', 'deactivated'
    ))
);
GO

-- TABLE: SPACE
CREATE TABLE dbo.SPACE (
    space_code     VARCHAR(50)  NOT NULL,
    space_name     VARCHAR(255) NOT NULL,
    space_type     VARCHAR(50)  NOT NULL,
    building       VARCHAR(255) NOT NULL,
    floor          INT          NOT NULL,
    room_number    VARCHAR(50)  NOT NULL,
    capacity       INT          NOT NULL,
    current_status VARCHAR(50)  NOT NULL CONSTRAINT df_space_current_status DEFAULT 'available',
    usage_policy   VARCHAR(MAX) NOT NULL,

    CONSTRAINT pk_space PRIMARY KEY (space_code),
    CONSTRAINT uq_space_location UNIQUE (building, floor, room_number),
    CONSTRAINT chk_space_type_domain CHECK (space_type IN (
        'auditorium', 'classroom', 'computer_lab',
        'project_lab', 'meeting_room', 'student_workspace'
    )),
    CONSTRAINT chk_space_status_domain CHECK (current_status IN (
        'available', 'in_use', 'under_maintenance',
        'temporarily_closed', 'retired'
    )),
    CONSTRAINT chk_space_capacity_boundary CHECK (capacity > 0)
);
GO

-- TABLE: FACILITY
CREATE TABLE dbo.FACILITY (
    facility_id   INT IDENTITY(1,1) NOT NULL,
    facility_name VARCHAR(255)      NOT NULL,

    CONSTRAINT pk_facility PRIMARY KEY (facility_id),
    CONSTRAINT uq_facility_facility_name UNIQUE (facility_name)
);
GO

-- ============================================================================
-- 2. Dependent Child Tables
-- ============================================================================

-- TABLE: BOOKING
CREATE TABLE dbo.BOOKING (
    booking_id            INT          IDENTITY(1,1) NOT NULL,
    requester_id          INT          NOT NULL,
    space_code            VARCHAR(50)  NOT NULL,
    requested_start_time  DATETIME2    NOT NULL,
    requested_end_time    DATETIME2    NOT NULL,
    purpose               VARCHAR(50)  NOT NULL,
    expected_participants INT          NOT NULL,
    booking_status        VARCHAR(50)  NOT NULL CONSTRAINT df_booking_booking_status DEFAULT 'pending',
    decision_staff_id     INT          NULL,
    decision_time         DATETIME2    NULL,
    decision_note         VARCHAR(MAX) NULL,
    rejection_reason      VARCHAR(MAX) NULL,
    check_in_staff_id     INT          NULL,
    actual_start_time     DATETIME2    NULL,
    initial_condition     VARCHAR(MAX) NULL,
    completion_staff_id   INT          NULL,
    actual_end_time       DATETIME2    NULL,
    final_condition       VARCHAR(MAX) NULL,
    usage_notes           VARCHAR(MAX) NULL,

    CONSTRAINT pk_booking PRIMARY KEY (booking_id),
    CONSTRAINT chk_booking_purpose_domain CHECK (purpose IN (
        'lecture', 'examination', 'seminar', 'workshop',
        'meeting', 'student_activity', 'administrative_event'
    )),
    CONSTRAINT chk_booking_status_domain CHECK (booking_status IN (
        'pending', 'approved', 'rejected', 'cancelled',
        'checked_in', 'completed', 'no_show'
    )),
    CONSTRAINT chk_booking_participants_boundary CHECK (expected_participants > 0),
    CONSTRAINT chk_booking_timeline_order CHECK (requested_start_time < requested_end_time),
    CONSTRAINT chk_booking_decision_required_fields CHECK (
        NOT (booking_status IN ('approved', 'rejected'))
        OR (decision_staff_id IS NOT NULL AND decision_time IS NOT NULL AND decision_note IS NOT NULL)
    ),
    CONSTRAINT chk_booking_rejection_reason CHECK (
        booking_status <> 'rejected' OR rejection_reason IS NOT NULL
    ),
    CONSTRAINT chk_booking_checkin_required_fields CHECK (
        booking_status <> 'checked_in'
        OR (actual_start_time IS NOT NULL AND check_in_staff_id IS NOT NULL AND initial_condition IS NOT NULL)
    ),
    CONSTRAINT chk_booking_completion_required_fields CHECK (
        booking_status <> 'completed'
        OR (actual_end_time IS NOT NULL AND final_condition IS NOT NULL)
    ),
    CONSTRAINT chk_booking_actual_timeline_order CHECK (
        actual_start_time IS NULL OR actual_end_time IS NULL OR actual_start_time < actual_end_time
    )
);
GO

-- TABLE: MAINTENANCE_RECORD
CREATE TABLE dbo.MAINTENANCE_RECORD (
    maintenance_id      INT          IDENTITY(1,1) NOT NULL,
    space_code          VARCHAR(50)  NOT NULL,
    reporter_id         INT          NOT NULL,
    assigned_staff_id   INT          NULL,
    problem_description VARCHAR(MAX) NOT NULL,
    start_time          DATETIME2    NOT NULL,
    completion_time     DATETIME2    NULL,
    status              VARCHAR(50)  NOT NULL CONSTRAINT df_maintenance_record_status DEFAULT 'reported',
    result_note         VARCHAR(MAX) NULL,

    CONSTRAINT pk_maintenance_record PRIMARY KEY (maintenance_id),
    CONSTRAINT chk_maintenance_status_domain CHECK (status IN (
        'reported', 'in_progress', 'completed'
    )),
    CONSTRAINT chk_maintenance_timeline_order CHECK (
        completion_time IS NULL OR start_time < completion_time
    ),
    CONSTRAINT chk_maintenance_completion_required_fields CHECK (
        status <> 'completed' OR (completion_time IS NOT NULL AND result_note IS NOT NULL)
    )
);
GO

-- ============================================================================
-- 3. Junction Table (Resolves SPACE M:N FACILITY)
-- ============================================================================

CREATE TABLE dbo.SPACE_FACILITY (
    space_code  VARCHAR(50) NOT NULL,
    facility_id INT         NOT NULL,

    CONSTRAINT pk_space_facility PRIMARY KEY (space_code, facility_id)
);
GO

-- ============================================================================
-- 4. Foreign Key Constraints
-- ============================================================================

-- BOOKING -> USER  (4 roles, RESTRICT / NO ACTION)
ALTER TABLE dbo.BOOKING
    ADD CONSTRAINT fk_booking_requester
        FOREIGN KEY (requester_id) REFERENCES dbo.[USER] (user_id);

ALTER TABLE dbo.BOOKING
    ADD CONSTRAINT fk_booking_decision_staff
        FOREIGN KEY (decision_staff_id) REFERENCES dbo.[USER] (user_id);

ALTER TABLE dbo.BOOKING
    ADD CONSTRAINT fk_booking_check_in_staff
        FOREIGN KEY (check_in_staff_id) REFERENCES dbo.[USER] (user_id);

ALTER TABLE dbo.BOOKING
    ADD CONSTRAINT fk_booking_completion_staff
        FOREIGN KEY (completion_staff_id) REFERENCES dbo.[USER] (user_id);

-- BOOKING -> SPACE  (RESTRICT / NO ACTION)
ALTER TABLE dbo.BOOKING
    ADD CONSTRAINT fk_booking_space
        FOREIGN KEY (space_code) REFERENCES dbo.SPACE (space_code);

-- MAINTENANCE_RECORD -> USER  (2 roles, RESTRICT / NO ACTION)
ALTER TABLE dbo.MAINTENANCE_RECORD
    ADD CONSTRAINT fk_maintenance_record_reporter
        FOREIGN KEY (reporter_id) REFERENCES dbo.[USER] (user_id);

ALTER TABLE dbo.MAINTENANCE_RECORD
    ADD CONSTRAINT fk_maintenance_record_assigned_staff
        FOREIGN KEY (assigned_staff_id) REFERENCES dbo.[USER] (user_id);

-- MAINTENANCE_RECORD -> SPACE  (RESTRICT / NO ACTION)
ALTER TABLE dbo.MAINTENANCE_RECORD
    ADD CONSTRAINT fk_maintenance_record_space
        FOREIGN KEY (space_code) REFERENCES dbo.SPACE (space_code);

-- SPACE_FACILITY -> SPACE  (CASCADE)
ALTER TABLE dbo.SPACE_FACILITY
    ADD CONSTRAINT fk_space_facility_space
        FOREIGN KEY (space_code) REFERENCES dbo.SPACE (space_code)
        ON DELETE CASCADE;

-- SPACE_FACILITY -> FACILITY  (CASCADE)
ALTER TABLE dbo.SPACE_FACILITY
    ADD CONSTRAINT fk_space_facility_facility
        FOREIGN KEY (facility_id) REFERENCES dbo.FACILITY (facility_id)
        ON DELETE CASCADE;
GO

-- ============================================================================
-- 5. Procedural Enforcement (Triggers)
--
-- BR 2 (Space Availability Gate) and BR 3 (Overlapping Booking Prevention)
-- are combined into a single INSTEAD OF INSERT, UPDATE trigger because
-- T-SQL permits only one INSTEAD OF trigger per operation per table.
-- ============================================================================

CREATE TRIGGER trg_booking_validation
ON dbo.BOOKING
INSTEAD OF INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- BR 2: Space must not be under maintenance, temporarily closed, or retired
    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN dbo.SPACE s ON s.space_code = i.space_code
        WHERE s.current_status IN ('under_maintenance', 'temporarily_closed', 'retired')
    )
    BEGIN
        ;THROW 50000, 'Cannot book a space that is under maintenance, temporarily closed, or retired.', 1;
        ROLLBACK TRANSACTION;
        RETURN;
    END;

    -- BR 3: No overlapping approved bookings for the same space
    --       The i.booking_id IS NULL guard handles INSERT (new rows have no ID yet),
    --       ensuring all existing approved bookings are checked.  For UPDATE the
    --       current row is excluded so an update does not conflict with itself.
    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN dbo.BOOKING b
            ON  b.space_code = i.space_code
            AND (i.booking_id IS NULL OR b.booking_id <> i.booking_id)
            AND b.booking_status = 'approved'
            AND b.requested_start_time < i.requested_end_time
            AND b.requested_end_time   > i.requested_start_time
    )
    BEGIN
        ;THROW 50000, 'Overlapping approved booking exists for the requested space and time.', 1;
        ROLLBACK TRANSACTION;
        RETURN;
    END;

    -- Forward valid operations
    IF EXISTS (SELECT 1 FROM deleted)
    BEGIN
        -- UPDATE path
        UPDATE b
        SET
            requester_id          = i.requester_id,
            space_code            = i.space_code,
            requested_start_time  = i.requested_start_time,
            requested_end_time    = i.requested_end_time,
            purpose               = i.purpose,
            expected_participants = i.expected_participants,
            booking_status        = i.booking_status,
            decision_staff_id     = i.decision_staff_id,
            decision_time         = i.decision_time,
            decision_note         = i.decision_note,
            rejection_reason      = i.rejection_reason,
            check_in_staff_id     = i.check_in_staff_id,
            actual_start_time     = i.actual_start_time,
            initial_condition     = i.initial_condition,
            completion_staff_id   = i.completion_staff_id,
            actual_end_time       = i.actual_end_time,
            final_condition       = i.final_condition,
            usage_notes           = i.usage_notes
        FROM dbo.BOOKING b
        INNER JOIN inserted i ON b.booking_id = i.booking_id;
    END
    ELSE
    BEGIN
        -- INSERT path
        INSERT INTO dbo.BOOKING (
            requester_id, space_code, requested_start_time, requested_end_time,
            purpose, expected_participants, booking_status,
            decision_staff_id, decision_time, decision_note, rejection_reason,
            check_in_staff_id, actual_start_time, initial_condition,
            completion_staff_id, actual_end_time, final_condition, usage_notes
        )
        SELECT
            requester_id, space_code, requested_start_time, requested_end_time,
            purpose, expected_participants, booking_status,
            decision_staff_id, decision_time, decision_note, rejection_reason,
            check_in_staff_id, actual_start_time, initial_condition,
            completion_staff_id, actual_end_time, final_condition, usage_notes
        FROM inserted;
    END;
END;
GO

-- ============================================================================
-- 6. Deferred Procedural Enforcement (Application Layer)
--
-- The following rules are documented in Section 4 of the logical design
-- as application-layer enforcement and are NOT implemented in the database:
--
--   BR  9 — Role-authorization for approval/rejection:
--           Only facility staff or facility managers may approve/reject a booking.
--           Enforced by application middleware before UPDATE with
--           booking_status IN ('approved', 'rejected').
--
--   BR 10 — Role-authorization for check-in/completion:
--           Only facility staff may perform check-in and session completion.
--           Enforced by application middleware before UPDATE for
--           check-in/completion operations.
--
--   Booking state machine lifecycle:
--     pending  -> (approved | rejected | cancelled)
--     approved -> (checked_in | cancelled | no_show)
--     checked_in -> (completed | no_show)
--     Enforced by application middleware validating state transition map
--     before UPDATE.
--
--   Maintenance state machine lifecycle:
--     reported -> in_progress -> completed
--     Direct jump reported -> completed is prohibited.
--     Enforced by application middleware validating state transition map
--     before UPDATE.
-- ============================================================================

-- ============================================================================
-- 7. Business Rule Coverage
--
-- BR | Rule                                  | Enforcement | Location
-- ---+---------------------------------------+-------------+----------------------------------
--  1 | Valid university account required     | Deferred    | Application-layer SSO / account
--    |                                       |             | provisioning
--  2 | Unavailable space cannot be booked    | Procedural  | trg_booking_validation (INSTEAD
--    |                                       |             | OF INSERT, UPDATE)
--  3 | No overlapping approved bookings      | Procedural  | trg_booking_validation (INSTEAD
--    |                                       |             | OF INSERT, UPDATE)
--  4 | Start time before end time            | Structural  | chk_booking_timeline_order
--  5 | Decision records staff + time + note  | Structural  | chk_booking_decision_required_fields
--  6 | Rejection stores reason               | Structural  | chk_booking_rejection_reason
--  7 | Check-in records start + staff + cond | Structural  | chk_booking_checkin_required_fields
--  8 | Completion records end + condition    | Structural  | chk_booking_completion_required_fields
--  9 | Only facility staff / mgr approves    | Deferred    | Application middleware (role
--    |                                       |             | authorization gate)
-- 10 | Only facility staff checks in/comp.   | Deferred    | Application middleware (role
--    |                                       |             | authorization gate)
-- 11 | Preserve historical records           | Structural  | ON DELETE NO ACTION on all
--    |                                       |             | operational FKs (RESTRICT)
-- 12 | Unique space code                     | Structural  | pk_space PRIMARY KEY (space_code)
-- ============================================================================
