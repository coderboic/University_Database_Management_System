-- Insert sample data into the University Database System

-- Insert data into COLLEGE table
INSERT INTO COLLEGE (college_id, college_name, city, contact_number) VALUES (college_seq.NEXTVAL, 'Engineering College', 'Delhi', '011-22334455');
INSERT INTO COLLEGE (college_id, college_name, city, contact_number) VALUES (college_seq.NEXTVAL, 'Science College', 'Mumbai', '022-66778899');
INSERT INTO COLLEGE (college_id, college_name, city, contact_number) VALUES (college_seq.NEXTVAL, 'Arts College', 'Bangalore', '080-11223344');

-- Insert data into DEPARTMENT table
INSERT INTO DEPARTMENT (department_id, department_name, hod_name, total_staffs, total_students, college_id)
VALUES (department_seq.NEXTVAL, 'Computer Science', 'Dr. Rajesh Kumar', 15, 120, 1);

INSERT INTO DEPARTMENT (department_id, department_name, hod_name, total_staffs, total_students, college_id)
VALUES (department_seq.NEXTVAL, 'Electronics', 'Dr. Priya Sharma', 12, 100, 1);

INSERT INTO DEPARTMENT (department_id, department_name, hod_name, total_staffs, total_students, college_id)
VALUES (department_seq.NEXTVAL, 'Physics', 'Dr. Amit Singh', 10, 80, 2);

INSERT INTO DEPARTMENT (department_id, department_name, hod_name, total_staffs, total_students, college_id)
VALUES (department_seq.NEXTVAL, 'Literature', 'Dr. Sunita Gupta', 8, 70, 3);

-- Insert data into STUDENT table
INSERT INTO STUDENT (student_id, name, gender, year, email, phone, address, department_id, college_id)
VALUES (student_seq.NEXTVAL, 'Rahul Sharma', 'Male', 2, 'rahul.sharma@email.com', '9876543210', 'H-123, Sector-15, Delhi', 1, 1);

INSERT INTO STUDENT (student_id, name, gender, year, email, phone, address, department_id, college_id)
VALUES (student_seq.NEXTVAL, 'Priya Patel', 'Female', 3, 'priya.patel@email.com', '9876543211', 'A-45, Andheri, Mumbai', 2, 1);

INSERT INTO STUDENT (student_id, name, gender, year, email, phone, address, department_id, college_id)
VALUES (student_seq.NEXTVAL, 'Amit Kumar', 'Male', 4, 'amit.kumar@email.com', '9876543212', 'B-67, Koramangala, Bangalore', 3, 2);

INSERT INTO STUDENT (student_id, name, gender, year, email, phone, address, department_id, college_id)
VALUES (student_seq.NEXTVAL, 'Neha Singh', 'Female', 2, 'neha.singh@email.com', '9876543213', 'C-89, HSR Layout, Bangalore', 4, 3);

INSERT INTO STUDENT (student_id, name, gender, year, email, phone, address, department_id, college_id)
VALUES (student_seq.NEXTVAL, 'Rajesh Verma', 'Male', 1, 'rajesh.verma@email.com', '9876543214', 'D-12, Rohini, Delhi', 1, 1);

INSERT INTO STUDENT (student_id, name, gender, year, email, phone, address, department_id, college_id)
VALUES (student_seq.NEXTVAL, 'Sneha Reddy', 'Female', 3, 'sneha.reddy@email.com', '9876543215', 'E-23, Bandra, Mumbai', 2, 1);

-- Insert data into UG_STUDENT and PG_STUDENT tables
INSERT INTO UG_STUDENT (student_id) VALUES (1);
INSERT INTO UG_STUDENT (student_id) VALUES (2);
INSERT INTO UG_STUDENT (student_id) VALUES (5);

INSERT INTO PG_STUDENT (student_id) VALUES (3);
INSERT INTO PG_STUDENT (student_id) VALUES (4);
INSERT INTO PG_STUDENT (student_id) VALUES (6);

-- Insert data into FACULTY table
INSERT INTO FACULTY (faculty_id, faculty_name, email, phone, department_id)
VALUES (faculty_seq.NEXTVAL, 'Dr. Vijay Mehta', 'vijay.mehta@college.edu', '9876543216', 1);

INSERT INTO FACULTY (faculty_id, faculty_name, email, phone, department_id)
VALUES (faculty_seq.NEXTVAL, 'Dr. Pooja Verma', 'pooja.verma@college.edu', '9876543217', 2);

INSERT INTO FACULTY (faculty_id, faculty_name, email, phone, department_id)
VALUES (faculty_seq.NEXTVAL, 'Dr. Suresh Gupta', 'suresh.gupta@college.edu', '9876543218', 3);

INSERT INTO FACULTY (faculty_id, faculty_name, email, phone, department_id)
VALUES (faculty_seq.NEXTVAL, 'Dr. Meena Iyer', 'meena.iyer@college.edu', '9876543219', 4);

-- Insert data into STAFF table
INSERT INTO STAFF (staff_id, staff_name, salary, department_id)
VALUES (staff_seq.NEXTVAL, 'Ramesh Kumar', 45000, 1);

INSERT INTO STAFF (staff_id, staff_name, salary, department_id)
VALUES (staff_seq.NEXTVAL, 'Suresh Sharma', 40000, 2);

INSERT INTO STAFF (staff_id, staff_name, salary, department_id)
VALUES (staff_seq.NEXTVAL, 'Geeta Patel', 42000, 3);

INSERT INTO STAFF (staff_id, staff_name, salary, department_id)
VALUES (staff_seq.NEXTVAL, 'Anita Singh', 38000, 4);

INSERT INTO STAFF (staff_id, staff_name, salary, department_id)
VALUES (staff_seq.NEXTVAL, 'Vijay Reddy', 35000, 1);

INSERT INTO STAFF (staff_id, staff_name, salary, department_id)
VALUES (staff_seq.NEXTVAL, 'Rajiv Malhotra', 50000, 2);

-- Insert data into TEACHING_STAFF and NON_TEACHING_STAFF tables
INSERT INTO TEACHING_STAFF (staff_id) VALUES (1);
INSERT INTO TEACHING_STAFF (staff_id) VALUES (2);
INSERT INTO TEACHING_STAFF (staff_id) VALUES (3);

INSERT INTO NON_TEACHING_STAFF (staff_id) VALUES (4);
INSERT INTO NON_TEACHING_STAFF (staff_id) VALUES (5);
INSERT INTO NON_TEACHING_STAFF (staff_id) VALUES (6);

-- Insert data into EXAM table
INSERT INTO EXAM (exam_id, subject, exam_date, student_id)
VALUES (exam_seq.NEXTVAL, 'Database Systems', TO_DATE('2025-04-15', 'YYYY-MM-DD'), 1);

INSERT INTO EXAM (exam_id, subject, exam_date, student_id)
VALUES (exam_seq.NEXTVAL, 'Digital Electronics', TO_DATE('2025-04-18', 'YYYY-MM-DD'), 2);

INSERT INTO EXAM (exam_id, subject, exam_date, student_id)
VALUES (exam_seq.NEXTVAL, 'Quantum Physics', TO_DATE('2025-04-20', 'YYYY-MM-DD'), 3);

INSERT INTO EXAM (exam_id, subject, exam_date, student_id)
VALUES (exam_seq.NEXTVAL, 'Modern Literature', TO_DATE('2025-04-22', 'YYYY-MM-DD'), 4);

INSERT INTO EXAM (exam_id, subject, exam_date, student_id)
VALUES (exam_seq.NEXTVAL, 'Programming Fundamentals', TO_DATE('2025-04-25', 'YYYY-MM-DD'), 5);

INSERT INTO EXAM (exam_id, subject, exam_date, student_id)
VALUES (exam_seq.NEXTVAL, 'Microprocessors', TO_DATE('2025-04-28', 'YYYY-MM-DD'), 6);

-- Insert data into MARKS table
INSERT INTO MARKS (marks_id, student_id, exam_id, marks_obtained)
VALUES (marks_seq.NEXTVAL, 1, 1, 85);

INSERT INTO MARKS (marks_id, student_id, exam_id, marks_obtained)
VALUES (marks_seq.NEXTVAL, 2, 2, 78);

INSERT INTO MARKS (marks_id, student_id, exam_id, marks_obtained)
VALUES (marks_seq.NEXTVAL, 3, 3, 92);

INSERT INTO MARKS (marks_id, student_id, exam_id, marks_obtained)
VALUES (marks_seq.NEXTVAL, 4, 4, 88);

INSERT INTO MARKS (marks_id, student_id, exam_id, marks_obtained)
VALUES (marks_seq.NEXTVAL, 5, 5, 75);

INSERT INTO MARKS (marks_id, student_id, exam_id, marks_obtained)
VALUES (marks_seq.NEXTVAL, 6, 6, 82);

-- Insert data into ATTENDANCE table
INSERT INTO ATTENDANCE (attendance_id, student_id, date_of_attendance, status, department_id)
VALUES (attendance_seq.NEXTVAL, 1, TO_DATE('2025-04-01', 'YYYY-MM-DD'), 'Present', 1);

INSERT INTO ATTENDANCE (attendance_id, student_id, date_of_attendance, status, department_id)
VALUES (attendance_seq.NEXTVAL, 2, TO_DATE('2025-04-01', 'YYYY-MM-DD'), 'Present', 2);

INSERT INTO ATTENDANCE (attendance_id, student_id, date_of_attendance, status, department_id)
VALUES (attendance_seq.NEXTVAL, 3, TO_DATE('2025-04-01', 'YYYY-MM-DD'), 'Absent', 3);

INSERT INTO ATTENDANCE (attendance_id, student_id, date_of_attendance, status, department_id)
VALUES (attendance_seq.NEXTVAL, 4, TO_DATE('2025-04-01', 'YYYY-MM-DD'), 'Present', 4);

INSERT INTO ATTENDANCE (attendance_id, student_id, date_of_attendance, status, department_id)
VALUES (attendance_seq.NEXTVAL, 5, TO_DATE('2025-04-02', 'YYYY-MM-DD'), 'Present', 1);

INSERT INTO ATTENDANCE (attendance_id, student_id, date_of_attendance, status, department_id)
VALUES (attendance_seq.NEXTVAL, 6, TO_DATE('2025-04-02', 'YYYY-MM-DD'), 'Present', 2);

-- Insert data into FEES table
INSERT INTO FEES (fees_id, student_id, amount, due_date)
VALUES (fees_seq.NEXTVAL, 1, 50000, TO_DATE('2025-05-15', 'YYYY-MM-DD'));

INSERT INTO FEES (fees_id, student_id, amount, due_date)
VALUES (fees_seq.NEXTVAL, 2, 50000, TO_DATE('2025-05-15', 'YYYY-MM-DD'));

INSERT INTO FEES (fees_id, student_id, amount, due_date)
VALUES (fees_seq.NEXTVAL, 3, 60000, TO_DATE('2025-05-20', 'YYYY-MM-DD'));

INSERT INTO FEES (fees_id, student_id, amount, due_date)
VALUES (fees_seq.NEXTVAL, 4, 45000, TO_DATE('2025-05-20', 'YYYY-MM-DD'));

INSERT INTO FEES (fees_id, student_id, amount, due_date)
VALUES (fees_seq.NEXTVAL, 5, 50000, TO_DATE('2025-05-25', 'YYYY-MM-DD'));

INSERT INTO FEES (fees_id, student_id, amount, due_date)
VALUES (fees_seq.NEXTVAL, 6, 50000, TO_DATE('2025-05-25', 'YYYY-MM-DD'));

-- Insert data into HOSTEL table
INSERT INTO HOSTEL (hostel_id, hostel_details, room_number)
VALUES (hostel_seq.NEXTVAL, 'Boys Hostel Block A', 'A-101');

INSERT INTO HOSTEL (hostel_id, hostel_details, room_number)
VALUES (hostel_seq.NEXTVAL, 'Boys Hostel Block A', 'A-102');

INSERT INTO HOSTEL (hostel_id, hostel_details, room_number)
VALUES (hostel_seq.NEXTVAL, 'Girls Hostel Block B', 'B-101');

INSERT INTO HOSTEL (hostel_id, hostel_details, room_number)
VALUES (hostel_seq.NEXTVAL, 'Girls Hostel Block B', 'B-102');

-- Insert data into BOYS_HOSTEL and GIRLS_HOSTEL tables
INSERT INTO BOYS_HOSTEL (hostel_id) VALUES (1);
INSERT INTO BOYS_HOSTEL (hostel_id) VALUES (2);

INSERT INTO GIRLS_HOSTEL (hostel_id, block_number) VALUES (3, 'B1');
INSERT INTO GIRLS_HOSTEL (hostel_id, block_number) VALUES (4, 'B2');

-- Insert data into COLLEGE_LIBRARY table
INSERT INTO COLLEGE_LIBRARY (library_id, college_id, librarian_name)
VALUES (library_seq.NEXTVAL, 1, 'Mr. Ramesh Joshi');

INSERT INTO COLLEGE_LIBRARY (library_id, college_id, librarian_name)
VALUES (library_seq.NEXTVAL, 2, 'Ms. Anita Desai');

INSERT INTO COLLEGE_LIBRARY (library_id, college_id, librarian_name)
VALUES (library_seq.NEXTVAL, 3, 'Mr. Sudhir Menon');

-- Insert data into LIBRARY_RECORDS table
INSERT INTO LIBRARY_RECORDS (record_id, student_id, library_id, book_sections, issue_date, return_date)
VALUES (record_seq.NEXTVAL, 1, 1, 'Computer Science', TO_DATE('2025-04-05', 'YYYY-MM-DD'), TO_DATE('2025-04-20', 'YYYY-MM-DD'));

INSERT INTO LIBRARY_RECORDS (record_id, student_id, library_id, book_sections, issue_date, return_date)
VALUES (record_seq.NEXTVAL, 2, 1, 'Electronics', TO_DATE('2025-04-06', 'YYYY-MM-DD'), TO_DATE('2025-04-21', 'YYYY-MM-DD'));

INSERT INTO LIBRARY_RECORDS (record_id, student_id, library_id, book_sections, issue_date, return_date)
VALUES (record_seq.NEXTVAL, 3, 2, 'Physics', TO_DATE('2025-04-07', 'YYYY-MM-DD'), TO_DATE('2025-04-22', 'YYYY-MM-DD'));

INSERT INTO LIBRARY_RECORDS (record_id, student_id, library_id, book_sections, issue_date, return_date)
VALUES (record_seq.NEXTVAL, 4, 3, 'Literature', TO_DATE('2025-04-08', 'YYYY-MM-DD'), TO_DATE('2025-04-23', 'YYYY-MM-DD'));

-- Insert data into ENROLL table
INSERT INTO ENROLL (student_id, department_id, enrollment_date)
VALUES (1, 1, TO_DATE('2023-07-15', 'YYYY-MM-DD'));

INSERT INTO ENROLL (student_id, department_id, enrollment_date)
VALUES (2, 2, TO_DATE('2022-07-20', 'YYYY-MM-DD'));

INSERT INTO ENROLL (student_id, department_id, enrollment_date)
VALUES (3, 3, TO_DATE('2021-07-25', 'YYYY-MM-DD'));

INSERT INTO ENROLL (student_id, department_id, enrollment_date)
VALUES (4, 4, TO_DATE('2023-07-30', 'YYYY-MM-DD'));

INSERT INTO ENROLL (student_id, department_id, enrollment_date)
VALUES (5, 1, TO_DATE('2024-07-10', 'YYYY-MM-DD'));

INSERT INTO ENROLL (student_id, department_id, enrollment_date)
VALUES (6, 2, TO_DATE('2022-07-05', 'YYYY-MM-DD'));

-- Insert data into BORROWS table
INSERT INTO BORROWS (student_id, library_id, borrow_date, return_date)
VALUES (1, 1, TO_DATE('2025-04-05', 'YYYY-MM-DD'), TO_DATE('2025-04-20', 'YYYY-MM-DD'));

INSERT INTO BORROWS (student_id, library_id, borrow_date, return_date)
VALUES (2, 1, TO_DATE('2025-04-06', 'YYYY-MM-DD'), TO_DATE('2025-04-21', 'YYYY-MM-DD'));

INSERT INTO BORROWS (student_id, library_id, borrow_date, return_date)
VALUES (3, 2, TO_DATE('2025-04-07', 'YYYY-MM-DD'), TO_DATE('2025-04-22', 'YYYY-MM-DD'));

INSERT INTO BORROWS (student_id, library_id, borrow_date, return_date)
VALUES (4, 3, TO_DATE('2025-04-08', 'YYYY-MM-DD'), TO_DATE('2025-04-23', 'YYYY-MM-DD'));

COMMIT;