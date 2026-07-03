USE CampusSpaceManagementSystem;
GO

-- 24125074 - Phuc


/*
Query 1
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
Query 2
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
Query 3
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
Query 4
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
