-- University Database System
-- Stored Procedures and Functions

-- 1. Procedure to register a new student
CREATE OR REPLACE PROCEDURE register_student(
    p_name IN VARCHAR2,
    p_gender IN VARCHAR2,
    p_year IN NUMBER,
    p_email IN VARCHAR2,
    p_phone IN VARCHAR2,
    p_address IN VARCHAR2,
    p_dept_id IN NUMBER,
    p_college_id IN NUMBER,
    p_student_type IN VARCHAR2, -- 'UG' or 'PG'
    p_student_id OUT NUMBER
)
IS
BEGIN
    -- Insert into Student table
    SELECT student_seq.NEXTVAL INTO p_student_id FROM DUAL;
    
    INSERT INTO STUDENT (
        student_id, name, gender, year, email, phone, address, department_id, college_id
    ) VALUES (
        p_student_id, p_name, p_gender, p_year, p_email, p_phone, p_address, p_dept_id, p_college_id
    );
    
    -- Insert into UG_STUDENT or PG_STUDENT based on student type
    IF p_student_type = 'UG' THEN
        INSERT INTO UG_STUDENT (student_id) VALUES (p_student_id);
    ELSIF p_student_type = 'PG' THEN
        INSERT INTO PG_STUDENT (student_id) VALUES (p_student_id);
    END IF;
    
    -- Update department student count
    UPDATE DEPARTMENT
    SET total_students = total_students + 1
    WHERE department_id = p_dept_id;
    
    -- Also insert into ENROLL table
    INSERT INTO ENROLL (student_id, department_id, enrollment_date)
    VALUES (p_student_id, p_dept_id, SYSDATE);
    
    COMMIT;
    
    DBMS_OUTPUT.PUT_LINE('Student registered successfully with ID: ' || p_student_id);
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error registering student: ' || SQLERRM);
        RAISE;
END register_student;
/

-- 2. Function to calculate student GPA
CREATE OR REPLACE FUNCTION calculate_student_gpa(
    p_student_id IN NUMBER
) RETURN NUMBER
IS
    v_gpa NUMBER;
BEGIN
    SELECT AVG(marks_obtained) / 20 INTO v_gpa
    FROM MARKS
    WHERE student_id = p_student_id;
    
    RETURN v_gpa;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN NULL;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error calculating GPA: ' || SQLERRM);
        RETURN NULL;
END calculate_student_gpa;
/

-- 3. Procedure to record student attendance
CREATE OR REPLACE PROCEDURE record_attendance(
    p_student_id IN NUMBER,
    p_department_id IN NUMBER,
    p_date IN DATE,
    p_status IN VARCHAR2
)
IS
BEGIN
    INSERT INTO ATTENDANCE (
        attendance_id, student_id, date_of_attendance, status, department_id
    ) VALUES (
        attendance_seq.NEXTVAL, p_student_id, p_date, p_status, p_department_id
    );
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Attendance recorded for student ID: ' || p_student_id);
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error recording attendance: ' || SQLERRM);
        RAISE;
END record_attendance;
/

-- 4. Procedure to add exam marks for a student
CREATE OR REPLACE PROCEDURE add_marks(
    p_student_id IN NUMBER,
    p_exam_id IN NUMBER,
    p_marks_obtained IN NUMBER
)
IS
BEGIN
    -- Check if the exam belongs to the student
    DECLARE
        v_exam_owner NUMBER;
    BEGIN
        SELECT student_id INTO v_exam_owner
        FROM EXAM
        WHERE exam_id = p_exam_id;
        
        IF v_exam_owner != p_student_id THEN
            RAISE_APPLICATION_ERROR(-20001, 'Exam does not belong to this student');
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20002, 'Exam not found');
    END;
    
    -- Insert into MARKS table
    INSERT INTO MARKS (
        marks_id, student_id, exam_id, marks_obtained
    ) VALUES (
        marks_seq.NEXTVAL, p_student_id, p_exam_id, p_marks_obtained
    );
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Marks added successfully');
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error adding marks: ' || SQLERRM);
        RAISE;
END add_marks;
/

-- 5. Function to get attendance percentage for a student
CREATE OR REPLACE FUNCTION get_attendance_percentage(
    p_student_id IN NUMBER
) RETURN NUMBER
IS
    v_total_days NUMBER;
    v_present_days NUMBER;
    v_percentage NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_total_days
    FROM ATTENDANCE
    WHERE student_id = p_student_id;
    
    SELECT COUNT(*) INTO v_present_days
    FROM ATTENDANCE
    WHERE student_id = p_student_id AND status = 'Present';
    
    IF v_total_days = 0 THEN
        RETURN 0;
    END IF;
    
    v_percentage := (v_present_days / v_total_days) * 100;
    RETURN v_percentage;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error calculating attendance percentage: ' || SQLERRM);
        RETURN NULL;
END get_attendance_percentage;
/

-- 6. Procedure to generate student report
CREATE OR REPLACE PROCEDURE generate_student_report(
    p_student_id IN NUMBER
)
IS
    v_name VARCHAR2(100);
    v_dept_name VARCHAR2(100);
    v_college_name VARCHAR2(100);
    v_attendance_pct NUMBER;
    v_avg_marks NUMBER;
    v_student_type VARCHAR2(20);
BEGIN
    -- Get student details
    SELECT 
        s.name, d.department_name, c.college_name
    INTO 
        v_name, v_dept_name, v_college_name
    FROM STUDENT s
    JOIN DEPARTMENT d ON s.department_id = d.department_id
    JOIN COLLEGE c ON s.college_id = c.college_id
    WHERE s.student_id = p_student_id;
    
    -- Get attendance percentage
    v_attendance_pct := get_attendance_percentage(p_student_id);
    
    -- Get average marks
    SELECT AVG(marks_obtained) INTO v_avg_marks
    FROM MARKS
    WHERE student_id = p_student_id;
    
    -- Determine student type
    BEGIN
        SELECT 'Undergraduate' INTO v_student_type
        FROM UG_STUDENT
        WHERE student_id = p_student_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            BEGIN
                SELECT 'Postgraduate' INTO v_student_type
                FROM PG_STUDENT
                WHERE student_id = p_student_id;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    v_student_type := 'Unknown';
            END;
    END;
    
    -- Print report
    DBMS_OUTPUT.PUT_LINE('=== STUDENT REPORT ===');
    DBMS_OUTPUT.PUT_LINE('Student ID: ' || p_student_id);
    DBMS_OUTPUT.PUT_LINE('Name: ' || v_name);
    DBMS_OUTPUT.PUT_LINE('Student Type: ' || v_student_type);
    DBMS_OUTPUT.PUT_LINE('Department: ' || v_dept_name);
    DBMS_OUTPUT.PUT_LINE('College: ' || v_college_name);
    DBMS_OUTPUT.PUT_LINE('Attendance: ' || ROUND(v_attendance_pct, 2) || '%');
    DBMS_OUTPUT.PUT_LINE('Average Marks: ' || ROUND(v_avg_marks, 2));
    DBMS_OUTPUT.PUT_LINE('GPA: ' || ROUND(calculate_student_gpa(p_student_id), 2));
    DBMS_OUTPUT.PUT_LINE('=====================');
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Student not found');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error generating report: ' || SQLERRM);
END generate_student_report;
/

-- 7. Procedure to transfer a student to another department
CREATE OR REPLACE PROCEDURE transfer_student(
    p_student_id IN NUMBER,
    p_new_dept_id IN NUMBER
)
IS
    v_old_dept_id NUMBER;
BEGIN
    -- Get current department
    SELECT department_id INTO v_old_dept_id
    FROM STUDENT
    WHERE student_id = p_student_id;
    
    -- Update student record
    UPDATE STUDENT
    SET department_id = p_new_dept_id
    WHERE student_id = p_student_id;
    
    -- Update department counts
    UPDATE DEPARTMENT
    SET total_students = total_students - 1
    WHERE department_id = v_old_dept_id;
    
    UPDATE DEPARTMENT
    SET total_students = total_students + 1
    WHERE department_id = p_new_dept_id;
    
    -- Add new enrollment record
    INSERT INTO ENROLL (student_id, department_id, enrollment_date)
    VALUES (p_student_id, p_new_dept_id, SYSDATE);
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Student transferred successfully');
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Student not found');
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error transferring student: ' || SQLERRM);
        RAISE;
END transfer_student;
/

-- 8. Function to get department statistics
CREATE OR REPLACE FUNCTION get_dept_stats(
    p_dept_id IN NUMBER
) RETURN VARCHAR2
IS
    v_dept_name VARCHAR2(100);
    v_hod_name VARCHAR2(100);
    v_total_students NUMBER;
    v_total_staff NUMBER;
    v_avg_marks NUMBER;
    v_result VARCHAR2(1000);
BEGIN
    -- Get department details
    SELECT 
        department_name, hod_name, total_students, total_staffs
    INTO 
        v_dept_name, v_hod_name, v_total_students, v_total_staff
    FROM DEPARTMENT
    WHERE department_id = p_dept_id;
    
    -- Get average marks of students in this department
    SELECT AVG(m.marks_obtained) INTO v_avg_marks
    FROM MARKS m
    JOIN STUDENT s ON m.student_id = s.student_id
    WHERE s.department_id = p_dept_id;
    
    -- Format result string
    v_result := 'Department: ' || v_dept_name || 
                ', HOD: ' || v_hod_name ||
                ', Students: ' || v_total_students ||
                ', Staff: ' || v_total_staff ||
                ', Avg Marks: ' || ROUND(v_avg_marks, 2);
    
    RETURN v_result;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 'Department not found';
    WHEN OTHERS THEN
        RETURN 'Error getting department stats: ' || SQLERRM;
END get_dept_stats;
/

-- Example of calling these procedures and functions
/*
-- Register a new student
DECLARE
    v_student_id NUMBER;
BEGIN
    register_student(
        'John Doe', 'Male', 1, 'john.doe@email.com', '9876543220', 
        'New Address', 1, 1, 'UG', v_student_id
    );
    DBMS_OUTPUT.PUT_LINE('New Student ID: ' || v_student_id);
END;
/

-- Calculate GPA
DECLARE
    v_gpa NUMBER;
BEGIN
    v_gpa := calculate_student_gpa(1);
    DBMS_OUTPUT.PUT_LINE('Student GPA: ' || v_gpa);
END;
/

-- Generate student report
BEGIN
    generate_student_report(1);
END;
/

-- Get department statistics
DECLARE
    v_stats VARCHAR2(1000);
BEGIN
    v_stats := get_dept_stats(1);
    DBMS_OUTPUT.PUT_LINE(v_stats);
END;
/
*/