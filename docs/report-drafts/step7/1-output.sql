USE CampusSpaceManagementSystem;
GO

/*
Query 1
- Business question: Query available space for booking from start_date to end_date (in future)
- Target user: Facility Staff, Facility Manager
- Explanation: Lists all spaces that are currently eligible for booking and have no
  approved booking conflicting with the specified time window. Excludes spaces under
  maintenance, temporarily closed, or retired. Facility staff use this to guide
  requesters toward reservable rooms.
*/
DECLARE @start_date DATETIME = '2026-07-06 08:00:00';
DECLARE @end_date   DATETIME = '2026-07-06 17:00:00';

SELECT
    s.space_code,
    s.space_name,
    s.space_type,
    s.building,
    s.floor,
    s.room_number,
    s.capacity,
    s.current_status
FROM dbo.SPACE s
WHERE s.current_status NOT IN ('under_maintenance', 'temporarily_closed', 'retired')
  AND NOT EXISTS (
      SELECT 1
      FROM dbo.BOOKING b
      WHERE b.space_code = s.space_code
        AND b.booking_status = 'approved'
        AND b.requested_start_time < @end_date
        AND b.requested_end_time   > @start_date
  )
ORDER BY s.building, s.floor, s.room_number;
GO

/*
Query 2
- Business question: Query contact information (user_id, full_name, email,
  phone_number) of requested users whose bookings will start within one week
- Target user: Facility Staff
- Explanation: Returns the contact details of every requester who has an active
  booking scheduled to start in the next seven days. Facility staff use this list
  to send reminders, verify attendance, or prepare space check-in procedures.
*/
SELECT DISTINCT
    u.user_id,
    u.full_name,
    u.email,
    u.phone_number
FROM dbo.[USER] u
INNER JOIN dbo.BOOKING b ON u.user_id = b.requester_id
WHERE b.requested_start_time >= GETDATE()
  AND b.requested_start_time <= DATEADD(DAY, 7, GETDATE())
  AND b.booking_status NOT IN ('cancelled', 'rejected')
ORDER BY u.user_id;
GO

/*
Query 3
- Business question: Query a ranking for booking count of spaces
- Target user: Department Administrator
- Explanation: Ranks every space in the inventory by the total number of bookings
  it has received. Spaces with zero bookings are included and receive the lowest
  rank. Administrators use this report to identify over- or under-utilized rooms
  and support capacity planning decisions.
*/
SELECT
    s.space_code,
    s.space_name,
    COUNT(b.booking_id) AS booking_count,
    RANK() OVER (ORDER BY COUNT(b.booking_id) DESC) AS rank
FROM dbo.SPACE s
LEFT JOIN dbo.BOOKING b ON s.space_code = b.space_code
GROUP BY s.space_code, s.space_name
ORDER BY rank;
GO

/*
Query 4
- Business question: Query different types of facility and their amount in a space
  by a space_code
- Target user: Facility Staff, Facility Manager
- Explanation: For the supplied space, lists every facility type installed in that
  room together with its quantity. Facility staff and managers use this report to
  verify room equipment before approving bookings or assigning maintenance tasks.
*/
DECLARE @space_code VARCHAR(50) = 'CS-101';

SELECT
    sf.space_code,
    sp.space_name,
    f.facility_id,
    f.facility_name,
    COUNT(*) AS amount
FROM dbo.SPACE_FACILITY sf
INNER JOIN dbo.FACILITY f ON sf.facility_id = f.facility_id
INNER JOIN dbo.SPACE sp   ON sf.space_code  = sp.space_code
WHERE sf.space_code = @space_code
GROUP BY sf.space_code, sp.space_name, f.facility_id, f.facility_name
ORDER BY f.facility_name;
GO

/*
Query 5
- Business question: Query space usage history
- Target user: Department Administrator, Facility Manager
- Explanation: Retrieves the complete booking history of the supplied space,
  including requester identity, time windows, purpose, status, and actual session
  timestamps. Administrators and managers use this audit trail for policy reviews,
  utilization analysis, and incident investigation.
*/
DECLARE @history_space_code VARCHAR(50) = 'CS-101';

SELECT
    b.booking_id,
    b.space_code,
    sp.space_name,
    b.requester_id,
    u.full_name AS requester_name,
    b.requested_start_time,
    b.requested_end_time,
    b.purpose,
    b.booking_status,
    b.expected_participants,
    b.actual_start_time,
    b.actual_end_time,
    b.usage_notes
FROM dbo.BOOKING b
INNER JOIN dbo.SPACE sp  ON b.space_code    = sp.space_code
INNER JOIN dbo.[USER] u ON b.requester_id = u.user_id
WHERE b.space_code = @history_space_code
ORDER BY b.requested_start_time DESC;
GO
