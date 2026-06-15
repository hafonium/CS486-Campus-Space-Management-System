# Core Database Entities & Attributes

Analyze the requirements to identify the business purpose, actors, entities, attributes, relationships, cardinalities, and business rules.

## Business Purpose
The School wants to build a database system to manage the booking and usage of shared campus spaces (classrooms, computer laboratories, meeting rooms, auditoriums). The main goal is to manage these spaces fairly, avoid overlapping bookings, prevent the use of unavailable spaces, and preserve usage and maintenance history.

## Actors
* Student
* Lecturer
* Teaching Assistant
* Facility Staff
* Department Administrator
* Facility Manager

---

## Entities & Attributes

### 1. User
* **Attributes:** User ID (Primary Key), Full Name, Email, Phone Number, Role (student, lecturer, teaching assistant, facility staff, department administrator, or facility manager), Department, Account Status.


### 2. Campus Space
* **Attributes:** Space Code (Primary Key), Space Name, Space Type, Building, Floor, Room Number, Capacity, Current Status(available, in use, under maintenance, temporarily closed, or retired), Usage Policy.

### 3. Facility (Equipment)
* **Attributes:** Facility ID (Primary Key), Facility Name (e.g., projector, whiteboard, microphone, computer, livestreaming equipment, air conditioner).

### 4. Space_Facility (Bridging Entity for Available Facilities)
* **Attributes:** Space Code (Foreign Key), Facility ID (Foreign Key).

### 5. Booking Request
* **Attributes:** Booking ID (Primary Key), Requester ID (Foreign Key - User), Space Code (Foreign Key - Space), Requested Start Time, Requested End Time, Purpose of Use, Expected Number of Participants, Event Type (lecture, examination, seminar, workshop, meeting, student activity, administrative event), Booking Status (pending, approved, rejected, cancelled, checked in, completed, or no-show)

### 6. Booking Approval Details
* **Attributes:** Booking ID (Foreign Key), Approver ID (Foreign Key - User), Decision Time, Decision Note, Rejection Reason.

### 7. Booking Session (Check-in / Check-out)
* **Attributes:** Booking ID (Foreign Key), Check-in Staff ID (Foreign Key - User), Actual Start Time, Initial Condition, Actual End Time, Final Condition, Usage Notes.

### 8. Maintenance Record
* **Attributes:** Maintenance ID (Primary Key), Space Code (Foreign Key - Space), Reporter ID (Foreign Key - User), Assigned Staff ID (Foreign Key - User), Problem Description, Start Time, Completion Time, Status, Result Note.

---

## Relationships & Cardinalities

* **User to Booking Request (Requester):** One-to-Many (1:N). A user can submit many booking requests, but each request is submitted by exactly one user.
* **User to Booking Request (Approver):** One-to-Many (1:N). A staff member/manager can approve many bookings.
* **User to Booking Session (Check-in Staff):** One-to-Many (1:N). A facility staff member can check in/out many sessions.
* **Space to Booking Request:** One-to-Many (1:N). A space can have many booking requests over time, but a single request is for exactly one space.
* **Space to Facility:** Many-to-Many (M:N). A space can have many facilities, and a specific type of facility can be in many spaces. (Resolved via the `Space_Facility` bridging entity).
* **Space to Maintenance Record:** One-to-Many (1:N). A space can have multiple maintenance records over its lifetime.
* **User to Maintenance Record (Reporter):** One-to-Many (1:N). A user can report multiple maintenance issues.
* **User to Maintenance Record (Assigned Staff):** One-to-Many (1:N). A staff member can be assigned to multiple maintenance tasks.

---

## Business Rules

1.  **Account Requirement:** Each user must possess a valid university account to interact with the system.
2.  **Conflict Prevention:** The system must prevent conflicting bookings. The same space cannot have two approved bookings with overlapping time periods.
3.  **Space Availability Constraint:** A space that currently has a status of "under maintenance", "temporarily closed", or "retired" cannot be booked.
4. **Facility Availability:** The system should store the list of 
facilities available in each space.
5.  **Approval Workflow:** A booking request may require formal approval from a facility staff member or manager before its status can be changed to "approved".
6.  **Rejection Documentation:** If a booking is rejected, the system must enforce the logging of the staff member who made the decision, the decision time, a decision note, and the specific rejection reason.
7.  **Session Tracking (Check-in):** To transition a booking to "checked in", the system must record the actual start time, the staff member performing the check-in, and the initial condition of the space.
8.  **Session Tracking (Completion):** To transition a booking to "completed", the system must record the actual end time, the final condition of the space, and any usage notes.
9.  **Maintenance Blocking:** Generating an active maintenance record for a space immediately prevents any further bookings for that space until the maintenance status is completed.