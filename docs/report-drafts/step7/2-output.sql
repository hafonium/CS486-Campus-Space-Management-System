USE CampusSpaceManagementSystem;
GO

/*
Query 1
- Business question: Which available spaces in a specific building have a capacity
  greater than or equal to a requested threshold (e.g., Building 'B1' with at
  least 50 seats)?
- Target user: Facility Staff, Facility Manager
- Explanation: Filters spaces in a chosen building that are not under maintenance,
  temporarily closed, or retired, and meet a minimum capacity requirement. Staff
  use this when a requester needs a room in a particular building that can
  accommodate a specific number of participants.
*/
DECLARE @building     VARCHAR(255) = 'B1';
DECLARE @min_capacity INTEGER      = 50;

SELECT
    s.space_code,
    s.space_name,
    s.space_type,
    s.floor,
    s.room_number,
    s.capacity,
    s.current_status
FROM dbo.SPACE s
WHERE s.building = @building
  AND s.capacity >= @min_capacity
  AND s.current_status NOT IN ('under_maintenance', 'temporarily_closed', 'retired')
ORDER BY s.floor, s.room_number;
GO

/*
Query 2
- Business question: What are the active maintenance records (reported or
  in-progress) and the physical locations where the problems occurred?
- Target user: Facility Staff, Facility Manager
- Explanation: Lists every maintenance issue that has not yet been completed,
  together with the affected space's building, floor, and room number. Staff use
  this report to prioritise repair assignments and to verify that a room is
  genuinely unavailable before rejecting a booking.
*/
SELECT
    mr.maintenance_id,
    mr.space_code,
    s.space_name,
    s.building,
    s.floor,
    s.room_number,
    mr.problem_description,
    mr.status,
    mr.start_time,
    mr.reporter_id,
    u.full_name AS reporter_name,
    mr.assigned_staff_id,
    au.full_name AS assigned_staff_name
FROM dbo.MAINTENANCE_RECORD mr
INNER JOIN dbo.SPACE s    ON mr.space_code       = s.space_code
INNER JOIN dbo.[USER] u   ON mr.reporter_id       = u.user_id
LEFT  JOIN dbo.[USER] au ON mr.assigned_staff_id = au.user_id
WHERE mr.status IN ('reported', 'in_progress')
ORDER BY mr.start_time DESC;
GO

/*
Query 3
- Business question: Which checked-in bookings recorded an actual arrival time
  more than 15 minutes later than the requested start time?
- Target user: Facility Manager, Department Administrator
- Explanation: Identifies sessions where the requester arrived significantly
  later than the scheduled start. Managers use this data to detect late-arrival
  patterns, enforce usage policies, and decide whether a booking should be
  retrospectively marked as a no-show.
*/
SELECT
    b.booking_id,
    b.space_code,
    s.space_name,
    b.requester_id,
    u.full_name AS requester_name,
    b.requested_start_time,
    b.actual_start_time,
    DATEDIFF(MINUTE, b.requested_start_time, b.actual_start_time) AS minutes_late,
    b.purpose,
    b.expected_participants
FROM dbo.BOOKING b
INNER JOIN dbo.SPACE s  ON b.space_code   = s.space_code
INNER JOIN dbo.[USER] u ON b.requester_id = u.user_id
WHERE b.booking_status = 'checked_in'
  AND b.actual_start_time IS NOT NULL
  AND DATEDIFF(MINUTE, b.requested_start_time, b.actual_start_time) > 15
ORDER BY minutes_late DESC;
GO

/*
Query 4
- Business question: Which available spaces have zero approved bookings scheduled
  for the future?
- Target user: Department Administrator, Facility Manager
- Explanation: Returns every bookable space that currently has no upcoming
  approved reservations. Administrators use this to identify under-utilised rooms
  and proactively suggest them when new booking requests arrive.
*/
SELECT
    s.space_code,
    s.space_name,
    s.space_type,
    s.building,
    s.floor,
    s.room_number,
    s.capacity
FROM dbo.SPACE s
WHERE s.current_status NOT IN ('under_maintenance', 'temporarily_closed', 'retired')
  AND NOT EXISTS (
      SELECT 1
      FROM dbo.BOOKING b
      WHERE b.space_code = s.space_code
        AND b.booking_status = 'approved'
        AND b.requested_start_time >= GETDATE()
  )
ORDER BY s.building, s.floor, s.room_number;
GO

/*
Query 5
- Business question: Which users have submitted booking requests that resulted in
  3 or more rejections?
- Target user: Facility Manager
- Explanation: Identifies requesters whose booking requests have been rejected at
  least three times. Facility managers use this metric to spot policy-compliance
  issues, provide additional booking guidance, or review whether the user's access
  privileges need adjustment.
*/
SELECT
    u.user_id,
    u.full_name,
    u.email,
    u.department,
    COUNT(b.booking_id) AS rejection_count
FROM dbo.[USER] u
INNER JOIN dbo.BOOKING b ON u.user_id = b.requester_id
WHERE b.booking_status = 'rejected'
GROUP BY u.user_id, u.full_name, u.email, u.department
HAVING COUNT(b.booking_id) >= 3
ORDER BY rejection_count DESC;
GO
