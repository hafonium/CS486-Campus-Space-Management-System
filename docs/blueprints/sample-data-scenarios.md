# Stage 6: Sample Data Test Suite

### Valid Data
- [ ] Insert 5 Users (2 Students, 2 Faculty, 1 Admin).
- [ ] Insert 10 Spaces (Mix of small study rooms and large lecture halls).
- [ ] Insert a valid booking for a Student.
- [ ] Insert a valid, non-overlapping booking for a Faculty member in the same room, but 3 hours later.

### Edge Cases (Must throw SQL Errors)
- [ ] **Test A:** Try to book a room where `start_time` is '14:00' and `end_time` is '13:00'. *(Expect: CHECK constraint failure).*
- [ ] **Test B:** Try to book 'Auditorium A' from 10:00 AM to 12:00 PM, while another user already has it booked from 11:00 AM to 1:00 PM. *(Expect: Overlap overlap trigger/constraint failure).*
- [ ] **Test C:** Try to delete a User who has 4 active bookings. *(Expect: RESTRICT foreign key error).*