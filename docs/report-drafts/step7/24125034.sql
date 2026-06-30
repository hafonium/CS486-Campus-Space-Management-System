USE CampusSpaceManagementSystem;
GO

-- 24125034 - Dang Tran Tuan Khoi 

/*
Query 1
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
Query 2
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
Query 3
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
Query 4
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
Query 5
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