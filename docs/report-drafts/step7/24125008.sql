USE CampusSpaceManagementSystem;
GO

-- 24125008 - Nguyen Gia Hao


/*
Query 1
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
Query 2
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
Query 3
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
Query 4
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
Query 5
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