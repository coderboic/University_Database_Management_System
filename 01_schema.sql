-- University Database System Schema based on ER Diagram
-- Schema follows normalization principles up to 3NF

-- Drop existing tables (if any) to ensure clean setup
DROP TABLE LIBRARY_RECORDS CASCADE CONSTRAINTS;
DROP TABLE COLLEGE_LIBRARY CASCADE CONSTRAINTS;
DROP TABLE ATTENDANCE CASCADE CONSTRAINTS;
DROP TABLE MARKS CASCADE CONSTRAINTS;
DROP TABLE EXAM CASCADE CONSTRAINTS;
DROP TABLE FEES CASCADE CONSTRAINTS;
DROP TABLE HOSTEL CASCADE CONSTRAINTS;
DROP TABLE GIRLS_HOSTEL CASCADE CONSTRAINTS;
DROP TABLE BOYS_HOSTEL CASCADE CONSTRAINTS;
DROP TABLE ENROLL CASCADE CONSTRAINTS;
DROP TABLE BORROWS CASCADE CONSTRAINTS;
DROP TABLE UG_STUDENT CASCADE CONSTRAINTS;
DROP TABLE PG_STUDENT CASCADE CONSTRAINTS;
DROP TABLE STUDENT CASCADE CONSTRAINTS;
DROP TABLE TEACHING_STAFF CASCADE CONSTRAINTS;
DROP TABLE NON_TEACHING_STAFF CASCADE CONSTRAINTS;
DROP TABLE STAFF CASCADE CONSTRAINTS;
DROP TABLE FACULTY CASCADE CONSTRAINTS;
DROP TABLE DEPARTMENT CASCADE CONSTRAINTS;
DROP TABLE COLLEGE CASCADE CONSTRAINTS;

-- Create COLLEGE table
CREATE TABLE COLLEGE (
    college_id NUMBER PRIMARY KEY,
    college_name VARCHAR2(100) NOT NULL,
    city VARCHAR2(50),
    contact_number VARCHAR2(20)
);

-- Create DEPARTMENT table
CREATE TABLE DEPARTMENT (
    department_id NUMBER PRIMARY KEY,
    department_name VARCHAR2(100) NOT NULL,
    hod_name VARCHAR2(100),
    total_staffs NUMBER,
    total_students NUMBER,
    college_id NUMBER,
    CONSTRAINT fk_department_college FOREIGN KEY (college_id) REFERENCES COLLEGE(college_id)
);

-- Create STUDENT table
CREATE TABLE STUDENT (
    student_id NUMBER PRIMARY KEY,
    name VARCHAR2(100) NOT NULL,
    gender VARCHAR2(10),
    year NUMBER(1),
    email VARCHAR2(100),
    phone VARCHAR2(20),
    address VARCHAR2(200),
    department_id NUMBER,
    college_id NUMBER,
    CONSTRAINT fk_student_department FOREIGN KEY (department_id) REFERENCES DEPARTMENT(department_id),
    CONSTRAINT fk_student_college FOREIGN KEY (college_id) REFERENCES COLLEGE(college_id)
);

-- Create UG_STUDENT table
CREATE TABLE UG_STUDENT (
    student_id NUMBER PRIMARY KEY,
    CONSTRAINT fk_ug_student FOREIGN KEY (student_id) REFERENCES STUDENT(student_id)
);

-- Create PG_STUDENT table
CREATE TABLE PG_STUDENT (
    student_id NUMBER PRIMARY KEY,
    CONSTRAINT fk_pg_student FOREIGN KEY (student_id) REFERENCES STUDENT(student_id)
);

-- Create FACULTY table
CREATE TABLE FACULTY (
    faculty_id NUMBER PRIMARY KEY,
    faculty_name VARCHAR2(100) NOT NULL,
    email VARCHAR2(100),
    phone VARCHAR2(20),
    department_id NUMBER,
    CONSTRAINT fk_faculty_department FOREIGN KEY (department_id) REFERENCES DEPARTMENT(department_id)
);

-- Create STAFF table
CREATE TABLE STAFF (
    staff_id NUMBER PRIMARY KEY,
    staff_name VARCHAR2(100) NOT NULL,
    salary NUMBER(10,2),
    department_id NUMBER,
    CONSTRAINT fk_staff_department FOREIGN KEY (department_id) REFERENCES DEPARTMENT(department_id)
);

-- Create TEACHING_STAFF table
CREATE TABLE TEACHING_STAFF (
    staff_id NUMBER PRIMARY KEY,
    CONSTRAINT fk_teaching_staff FOREIGN KEY (staff_id) REFERENCES STAFF(staff_id)
);

-- Create NON_TEACHING_STAFF table
CREATE TABLE NON_TEACHING_STAFF (
    staff_id NUMBER PRIMARY KEY,
    CONSTRAINT fk_non_teaching_staff FOREIGN KEY (staff_id) REFERENCES STAFF(staff_id)
);

-- Create EXAM table
CREATE TABLE EXAM (
    exam_id NUMBER PRIMARY KEY,
    subject VARCHAR2(100) NOT NULL,
    exam_date DATE,
    student_id NUMBER,
    CONSTRAINT fk_exam_student FOREIGN KEY (student_id) REFERENCES STUDENT(student_id)
);

-- Create MARKS table
CREATE TABLE MARKS (
    marks_id NUMBER PRIMARY KEY,
    student_id NUMBER,
    exam_id NUMBER,
    marks_obtained NUMBER(5,2),
    CONSTRAINT fk_marks_student FOREIGN KEY (student_id) REFERENCES STUDENT(student_id),
    CONSTRAINT fk_marks_exam FOREIGN KEY (exam_id) REFERENCES EXAM(exam_id)
);

-- Create ATTENDANCE table
CREATE TABLE ATTENDANCE (
    attendance_id NUMBER PRIMARY KEY,
    student_id NUMBER,
    date_of_attendance DATE,
    status VARCHAR2(20),
    department_id NUMBER,
    CONSTRAINT fk_attendance_student FOREIGN KEY (student_id) REFERENCES STUDENT(student_id),
    CONSTRAINT fk_attendance_department FOREIGN KEY (department_id) REFERENCES DEPARTMENT(department_id)
);

-- Create FEES table
CREATE TABLE FEES (
    fees_id NUMBER PRIMARY KEY,
    student_id NUMBER,
    amount NUMBER(10,2),
    due_date DATE,
    CONSTRAINT fk_fees_student FOREIGN KEY (student_id) REFERENCES STUDENT(student_id)
);

-- Create HOSTEL table
CREATE TABLE HOSTEL (
    hostel_id NUMBER PRIMARY KEY,
    hostel_details VARCHAR2(200),
    room_number VARCHAR2(20)
);

-- Create GIRLS_HOSTEL table
CREATE TABLE GIRLS_HOSTEL (
    hostel_id NUMBER PRIMARY KEY,
    block_number VARCHAR2(20),
    CONSTRAINT fk_girls_hostel FOREIGN KEY (hostel_id) REFERENCES HOSTEL(hostel_id)
);

-- Create BOYS_HOSTEL table
CREATE TABLE BOYS_HOSTEL (
    hostel_id NUMBER PRIMARY KEY,
    CONSTRAINT fk_boys_hostel FOREIGN KEY (hostel_id) REFERENCES HOSTEL(hostel_id)
);

-- Create COLLEGE_LIBRARY table
CREATE TABLE COLLEGE_LIBRARY (
    library_id NUMBER PRIMARY KEY,
    college_id NUMBER,
    librarian_name VARCHAR2(100),
    CONSTRAINT fk_library_college FOREIGN KEY (college_id) REFERENCES COLLEGE(college_id)
);

-- Create LIBRARY_RECORDS table
CREATE TABLE LIBRARY_RECORDS (
    record_id NUMBER PRIMARY KEY,
    student_id NUMBER,
    library_id NUMBER,
    book_sections VARCHAR2(100),
    issue_date DATE,
    return_date DATE,
    CONSTRAINT fk_records_student FOREIGN KEY (student_id) REFERENCES STUDENT(student_id),
    CONSTRAINT fk_records_library FOREIGN KEY (library_id) REFERENCES COLLEGE_LIBRARY(library_id)
);

-- Create relationships tables
-- ENROLL relationship between STUDENT and DEPARTMENT
CREATE TABLE ENROLL (
    student_id NUMBER,
    department_id NUMBER,
    enrollment_date DATE,
    PRIMARY KEY (student_id, department_id),
    CONSTRAINT fk_enroll_student FOREIGN KEY (student_id) REFERENCES STUDENT(student_id),
    CONSTRAINT fk_enroll_department FOREIGN KEY (department_id) REFERENCES DEPARTMENT(department_id)
);

-- BORROWS relationship between STUDENT and LIBRARY
CREATE TABLE BORROWS (
    student_id NUMBER,
    library_id NUMBER,
    borrow_date DATE,
    return_date DATE,
    PRIMARY KEY (student_id, library_id, borrow_date),
    CONSTRAINT fk_borrows_student FOREIGN KEY (student_id) REFERENCES STUDENT(student_id),
    CONSTRAINT fk_borrows_library FOREIGN KEY (library_id) REFERENCES COLLEGE_LIBRARY(library_id)
);

-- Create sequences for auto-increment IDs
CREATE SEQUENCE college_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE department_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE student_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE faculty_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE staff_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE exam_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE marks_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE attendance_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE fees_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE hostel_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE library_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE record_seq START WITH 1 INCREMENT BY 1;

-- Create indexes for performance optimization
CREATE INDEX idx_student_dept ON STUDENT(department_id);
CREATE INDEX idx_student_college ON STUDENT(college_id);
CREATE INDEX idx_department_college ON DEPARTMENT(college_id);
CREATE INDEX idx_exam_student ON EXAM(student_id);
CREATE INDEX idx_marks_student ON MARKS(student_id);
CREATE INDEX idx_marks_exam ON MARKS(exam_id);
CREATE INDEX idx_attendance_student ON ATTENDANCE(student_id);
CREATE INDEX idx_fees_student ON FEES(student_id);

COMMIT;