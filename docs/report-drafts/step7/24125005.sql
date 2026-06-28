USE CampusSpaceManagementSystem;
GO

/*
Query 1
- Business question: Which booking requests are currently pending and waiting for a decision?
- Target user: Facility Manager, Facility Staff
- Explanation: This is the most essential query for managers to clear their daily workflow queue. It shows all new requests that need to be approved or rejected.
*/
SELECT 
    booking_id,
    requester_id,
    space_code,
    requested_start_time,
    requested_end_time,
    purpose,
    expected_participants
FROM dbo.BOOKING
WHERE booking_status = 'pending'
ORDER BY requested_start_time ASC;
GO

/*
Query 2
- Business question: Which spaces are currently unavailable due to maintenance, temporary closure, or retirement?
- Target user: Facility Manager, Department Administrator
- Explanation: Provides a quick, essential dashboard view of physical spaces that are out of order, helping staff monitor campus capacity and repair progress.
*/
SELECT 
    space_code,
    space_name,
    space_type,
    current_status
FROM dbo.SPACE
WHERE current_status IN ('under_maintenance', 'temporarily_closed', 'retired')
ORDER BY space_code;
GO

/*
Query 3
- Business question: What are the booking records and their current statuses for a specific user?
- Target user: Student, Lecturer, Teaching Assistant
- Explanation: Essential for regular users to track their own requests, see if they have been approved, or verify the times and rooms for their upcoming events.
*/
DECLARE @TargetUserID INT = 1; -- Replace with the actual user_id logging into the system

SELECT 
    booking_id,
    space_code,
    requested_start_time,
    requested_end_time,
    purpose,
    booking_status
FROM dbo.BOOKING
WHERE requester_id = @TargetUserID
ORDER BY requested_start_time DESC;
GO

/*
Query 4
- Business question: What equipment and facilities are available inside a specific space?
- Target user: All users (Students, Lecturers, Staff)
- Explanation: Helps users verify if a room has the necessary equipment (like a projector, smart board, or livestreaming gear) before they decide to submit a booking.
*/
DECLARE @TargetSpaceCode VARCHAR(50) = 'CR-M3-1006'; -- Replace with the desired space_code

SELECT 
    f.facility_id,
    f.facility_name
FROM dbo.FACILITY f
INNER JOIN dbo.SPACE_FACILITY sf ON f.facility_id = sf.facility_id
WHERE sf.space_code = @TargetSpaceCode
ORDER BY f.facility_name ASC;
GO

/*
Query 5
- Business question: Which approved bookings are scheduled to start on a specific date?
- Target user: Facility Staff
- Explanation: Acts as the essential daily schedule for facility staff on the ground, telling them exactly which rooms they need to visit to perform check-ins and unlock doors[cite: 1, 7].
*/
DECLARE @TargetDate DATE = '2026-01-15'; -- Replace with GETDATE() or a specific date

SELECT 
    b.booking_id,
    s.space_code,
    s.space_name,
    b.requested_start_time,
    b.requested_end_time,
    b.expected_participants
FROM dbo.BOOKING b
INNER JOIN dbo.SPACE s ON b.space_code = s.space_code
WHERE b.booking_status = 'approved'
  AND CAST(b.requested_start_time AS DATE) = @TargetDate
ORDER BY b.requested_start_time ASC;
GO