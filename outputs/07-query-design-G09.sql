USE CampusSpaceManagementSystem;
GO

----------------------------------------------24125005---------------------------------------------------------------------------
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

----------------------------------------------------------------------------------------------------------------------------------------


----------------------------------------------24125008---------------------------------------------------------------------------
/*
Query 6
- Business question: query available space for booking from future start_time to end_time
- Target user: all users who want to see space information for their intented bookings
- Explantion: the users who intend to book a space, they can filter spaces based on their schedule (start_time and end_time) 
to consider between different spaces and choose the best one for their purpose
*/

-- Define your intended booking schedule here
DECLARE @start_time DATETIME = '2026-07-20 08:30:00'; -- Change this to the start time value you want
DECLARE @end_time DATETIME = '2026-07-20 10:30:00';   -- Change this to the end time value you want

SELECT *
FROM dbo.SPACE
WHERE 
    @start_time > GETDATE()
    AND @start_time < @end_time
    AND current_status IN ('available', 'in_use')
    AND space_code NOT IN (
        SELECT space_code 
        FROM dbo.BOOKING
        WHERE 
            (booking_status = 'approved' 
            AND NOT (@end_time <= requested_start_time OR requested_end_time <= @start_time))
            OR
            (booking_status = 'checked_in'
            AND NOT (requested_end_time <= @start_time))

        UNION ALL 
        
        SELECT space_code 
        FROM dbo.MAINTENANCE_RECORD
        WHERE status IN ('reported', 'in_progress')
    );
GO


/*
Query 7
- Business question: query contact information(user_id, fullname, email, phone_number) of requested users whose bookings 
will start within the next week (from tomorrow to the next 8th day)
- Target user: facility staff, facility manager, department administrator
- Explantion: they can use this query to contact to the users who booked these bookings for supports (helping professors), 
crisis management (power cut, fire,...), 
or just remind them 
*/
SELECT 
    U.user_id,
    U.full_name,
    U.email,
    U.phone_number,
    B.booking_id,
    B.requested_start_time
FROM dbo.BOOKING B
JOIN dbo.[USER] U ON U.user_id = B.requester_id
WHERE DATEDIFF(day, GETDATE(), B.requested_start_time) BETWEEN 1 AND 7
    AND B.booking_status = 'approved' 
ORDER BY B.requested_start_time;
GO


/*
Query 8
- Business query: query a ranking for booking count of spaces
- Target users: all user
- Explanation: they can use this query for statistics, space consideration for booking, curiosity,...
*/
WITH BOOKING_COUNT AS (
    SELECT 
        space_code, 
        COUNT(*) AS booking_count
    FROM dbo.BOOKING 
    GROUP BY space_code
)

SELECT 
    S.*,
    ISNULL(BC.booking_count, 0) AS booking_count
FROM dbo.SPACE S
LEFT JOIN BOOKING_COUNT BC ON BC.space_code = S.space_code
ORDER BY booking_count DESC;
GO


/*
Query 9
- Business question: query different types of facility and their amount in a space by the space_code
- Target users: all users who want to see space's facility information 
- Explaination: they can see the conditions of facilities in a space for bookings (a sufficient number of chairs for their needs), 
maintainance (having specific facilities for the space purpose,...)
*/

-- Define the target space code here
DECLARE @facility_space_code VARCHAR(50) = 'AUD-MC-1000'; -- Change this to the space code value you want

SELECT 
    F.facility_name,
    COUNT(*) AS facility_count
FROM dbo.FACILITY F
JOIN dbo.SPACE_FACILITY SF ON F.facility_id = SF.facility_id
WHERE SF.space_code = @facility_space_code
GROUP BY F.facility_name;
GO


/*
Query 10
- Business question: query space usage history
- Target user: facility staff, facility manager, department administrator
- Explanation: if a space is reported to have some damage, these target users can trace back the usage history from the lastest day to find 
people who have responsibility for the damage (let say some bookings for a specific space all have 'initial_condition' like 'the 
projector is broken', then the staff can trace back to the lastest booking which has 'final_condition: the projector is broken', then 
the staff can contact the staff who checked in that space or the person who requested that space by 'requester_id' and 'requester_id')
*/

-- Define the target space code here
DECLARE @history_space_code VARCHAR(50) = 'AUD-MC-1000'; -- Change this to the space code value you want

SELECT 
    booking_id,
    requester_id,
    check_in_staff_id,
    actual_start_time,
    initial_condition,
    completion_staff_id,
    actual_end_time,
    final_condition,
    usage_notes
FROM dbo.BOOKING
WHERE space_code = @history_space_code 
  AND booking_status IN ('completed', 'checked_in')
ORDER BY actual_start_time DESC;
GO

-----------------------------------------------------------------------------------------------------------------------------------

----------------------------------------------24125034-------------------------------------------------------------------------------
/*
Query 11
- Business question: Which available spaces in a specific building have a capacity greater than or equal to a requested threshold (e.g., Building 'B1' with at least 50 seats)?
- Target user: Student, Lecturer, Teaching Assistant
- Explanation: Helps users quickly filter the campus space catalog to find an available room that satisfies their event participant count within their preferred location.
*/
DECLARE @TargetBuilding VARCHAR(255) = 'I'; -- Replace with desired building name
DECLARE @MinCapacity INT = 50;              -- Replace with desired minimum seat count

SELECT 
    space_code,
    space_name,
    space_type,
    floor,
    room_number,
    capacity
FROM dbo.SPACE
WHERE building = @TargetBuilding
  AND capacity >= @MinCapacity
  AND current_status = 'available'
ORDER BY capacity ASC;
GO

/*
Query 12
- Business question: What are the active maintenance records (reported or in-progress) and the physical locations where the problems occurred?
- Target user: Facility Staff, Facility Manager
- Explanation: Allows facility staff to view their daily maintenance backlog, inspect problem descriptions, and prioritize physical repairs across campus buildings.
*/
SELECT 
    m.maintenance_id,
    m.space_code,
    s.space_name,
    s.building,
  s.floor,
    s.room_number,
    m.problem_description,
    m.start_time,
    m.status
FROM dbo.MAINTENANCE_RECORD m
INNER JOIN dbo.SPACE s ON m.space_code = s.space_code
WHERE m.status IN ('reported', 'in_progress')
ORDER BY m.start_time ASC;
GO

/*
Query 13
- Business question: Which checked-in bookings recorded an actual arrival time more than 15 minutes later than the requested start time?
- Target user: Facility Staff, Facility Manager
- Explanation: Tracks room check-in punctuality to detect student groups or staff habitually reserving rooms but arriving late, preventing campus resource waste.
*/
SELECT 
    b.booking_id,
    b.space_code,
    u.full_name AS requester_name,
    u.department,
    b.requested_start_time,
    b.actual_start_time,
    DATEDIFF(minute, b.requested_start_time, b.actual_start_time) AS late_minutes
FROM dbo.BOOKING b
INNER JOIN dbo.[USER] u ON b.requester_id = u.user_id
WHERE b.booking_status IN ('checked_in', 'completed')
  AND b.actual_start_time > DATEADD(MINUTE, 15, b.requested_start_time)
ORDER BY late_minutes DESC;
GO

/*
Query 14
- Business question: Which available spaces have zero approved bookings scheduled for the future?
- Target user: Facility Manager, Department Administrator
- Explanation: Identifies "dead spaces" on campus that are overlooked or unpopular, helping managers investigate underlying infrastructure issues or repurpose the rooms.
*/
SELECT 
    space_code,
    space_name,
    space_type,
    building,
    capacity
FROM dbo.SPACE
WHERE current_status = 'available'
  AND space_code NOT IN (
      SELECT space_code 
      FROM dbo.BOOKING 
      WHERE booking_status = 'approved' 
        AND requested_start_time >= GETDATE()
  )
ORDER BY space_code ASC;
GO

/*
Query 15
- Business question: Which users have submitted booking requests that resulted in 3 or more rejections?
- Target user: Department Administrator, Facility Manager
- Explanation: Flags users who repeatedly fail to comply with campus booking policies or frequently attempt to reserve restricted spaces, prompting administrative review.
*/
SELECT 
    u.user_id,
    u.full_name,
    u.email,
    u.department,
    COUNT(b.booking_id) AS total_rejections
FROM dbo.[USER] u
INNER JOIN dbo.BOOKING b ON u.user_id = b.requester_id
WHERE b.booking_status = 'rejected'
GROUP BY u.user_id, u.full_name, u.email, u.department
HAVING COUNT(b.booking_id) >= 3
ORDER BY total_rejections DESC;
GO

-----------------------------------------------------------------------------------------------------------------------------------

----------------------------------------------24125074---------------------------------------------------------------------------
/*
Query 16
- Business question: Which approved future bookings have expected participants 
  exceeding the capacity of the assigned space?
- Target user: Facility Staff, Facility Manager
- Explanation: Staff and managers can proactively identify over-capacity bookings 
  and either reassign them to a larger space or request a participant reduction 
  before the event takes place.
*/

SELECT 
    B.booking_id,
    B.requester_id,
    U.full_name AS requester_name,
    B.space_code,
    S.space_name,
    S.space_type,
    S.capacity AS space_capacity,
    B.expected_participants,
    B.requested_start_time,
    B.requested_end_time,
    B.purpose
FROM dbo.BOOKING B
JOIN dbo.[USER] U ON U.user_id = B.requester_id
JOIN dbo.SPACE S ON S.space_code = B.space_code
WHERE B.booking_status = 'approved'
  AND B.requested_start_time > GETDATE()
  AND B.expected_participants > S.capacity
ORDER BY B.requested_start_time;
GO


/*
Query 17
- Business question: Which approved bookings should have started already 
  but have not been checked in yet?
- Target user: Facility Staff
- Explanation: Staff can identify bookings where the requester has not shown up 
  on time and take follow-up actions such as contacting the requester, 
  releasing the space for walk-in use, or marking the booking as no-show.
*/

SELECT 
    B.booking_id,
    B.requester_id,
    U.full_name AS requester_name,
    U.phone_number,
    U.email,
    B.space_code,
    S.space_name,
    S.building,
    B.requested_start_time,
    B.requested_end_time,
    B.purpose,
    B.expected_participants,
    DATEDIFF(MINUTE, B.requested_start_time, GETDATE()) AS minutes_past_start
FROM dbo.BOOKING B
JOIN dbo.[USER] U ON U.user_id = B.requester_id
JOIN dbo.SPACE S ON S.space_code = B.space_code
WHERE B.booking_status = 'approved'
  AND B.requested_start_time < GETDATE()
ORDER BY B.requested_start_time;
GO


/*
Query 18
- Business question: Which users have the highest number of no-show bookings 
  in the last 6 months?
- Target user: Facility Manager, Department Administrator
- Explanation: Managers and administrators can identify repeat offenders who 
  frequently book spaces but fail to show up, and take appropriate action 
  such as issuing warnings or restricting booking privileges.
*/

SELECT TOP 10
    U.user_id,
    U.full_name,
    U.email,
    U.department,
    U.role,
    COUNT(*) AS no_show_count
FROM dbo.BOOKING B
JOIN dbo.[USER] U ON U.user_id = B.requester_id
WHERE B.booking_status = 'no_show'
  AND B.requested_start_time >= DATEADD(MONTH, -6, GETDATE())
GROUP BY U.user_id, U.full_name, U.email, U.department, U.role
ORDER BY no_show_count DESC;
GO


/*
Query 19
- Business question: How long does each staff member take on average 
  to process booking approvals?
- Target user: Facility Manager
- Explanation: Since the schema does not store the booking submission timestamp,
  the processing lead time is approximated as the hours between the decision 
  and the requested event start time. A larger value indicates the staff member 
  tends to process bookings further in advance. Managers can use this to 
  evaluate staff responsiveness and identify bottlenecks.
*/

SELECT 
    U.user_id,
    U.full_name,
    U.department,
    COUNT(*) AS total_decisions,
    AVG(DATEDIFF(HOUR, B.decision_time, B.requested_start_time)) 
        AS avg_lead_time_hours
FROM dbo.BOOKING B
JOIN dbo.[USER] U ON U.user_id = B.decision_staff_id
WHERE B.booking_status IN ('approved', 'rejected')
  AND B.decision_time IS NOT NULL
GROUP BY U.user_id, U.full_name, U.department
ORDER BY avg_lead_time_hours;
GO


/*
Query 20
- Business question: Which spaces have the highest number of maintenance cases 
  in the last 90 days?
- Target user: Facility Manager, Facility Staff
- Explanation: Staff and managers can identify spaces that require frequent 
  repairs and investigate underlying causes — such as aging infrastructure, 
  heavy usage patterns, or inadequate facilities — and prioritize preventive 
  maintenance or equipment upgrades for those locations.
*/

SELECT TOP 10
    S.space_code,
    S.space_name,
    S.space_type,
    S.building,
    S.floor,
    S.room_number,
    COUNT(*) AS maintenance_count
FROM dbo.MAINTENANCE_RECORD M
JOIN dbo.SPACE S ON S.space_code = M.space_code
WHERE M.start_time >= DATEADD(DAY, -90, GETDATE())
GROUP BY S.space_code, S.space_name, S.space_type, S.building, S.floor, S.room_number
ORDER BY maintenance_count DESC;
GO