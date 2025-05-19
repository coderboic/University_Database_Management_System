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

CREATE OR REPLACE PROCEDURE process_failed_students
IS
    -- Cursor to find students with marks below 40
    CURSOR failed_students_cur IS
        SELECT s.student_id, s.name, s.department_id, 
               d.department_name, m.marks_obtained
        FROM STUDENT s
        JOIN MARKS m ON s.student_id = m.student_id
        JOIN DEPARTMENT d ON s.department_id = d.department_id
        WHERE m.marks_obtained < 40;
        
    v_student_rec failed_students_cur%ROWTYPE;
BEGIN
    OPEN failed_students_cur;
    
    DBMS_OUTPUT.PUT_LINE('=== Failed Students Report ===');
    
    LOOP
        FETCH failed_students_cur INTO v_student_rec;
        EXIT WHEN failed_students_cur%NOTFOUND;
        
        DBMS_OUTPUT.PUT_LINE(
            'Student: ' || v_student_rec.name ||
            ' (ID: ' || v_student_rec.student_id || ')' ||
            ' Department: ' || v_student_rec.department_name ||
            ' Marks: ' || v_student_rec.marks_obtained
        );
        
        -- Send notification (simulated)
        DBMS_OUTPUT.PUT_LINE('Notification sent to student: ' || v_student_rec.student_id);
    END LOOP;
    
    CLOSE failed_students_cur;
END;
/

CREATE OR REPLACE PROCEDURE monitor_low_attendance
IS
    -- Cursor for students with attendance below 75%
    CURSOR low_attendance_cur IS
        SELECT s.student_id, s.name, 
               COUNT(CASE WHEN a.status = 'Present' THEN 1 END) * 100.0 / COUNT(*) as attendance_percent
        FROM STUDENT s
        JOIN ATTENDANCE a ON s.student_id = a.student_id
        GROUP BY s.student_id, s.name
        HAVING COUNT(CASE WHEN a.status = 'Present' THEN 1 END) * 100.0 / COUNT(*) < 75;
        
    v_student_rec low_attendance_cur%ROWTYPE;
BEGIN
    OPEN low_attendance_cur;
    
    DBMS_OUTPUT.PUT_LINE('=== Low Attendance Report ===');
    
    LOOP
        FETCH low_attendance_cur INTO v_student_rec;
        EXIT WHEN low_attendance_cur%NOTFOUND;
        
        DBMS_OUTPUT.PUT_LINE(
            'Student: ' || v_student_rec.name ||
            ' (ID: ' || v_student_rec.student_id || ')' ||
            ' Attendance: ' || ROUND(v_student_rec.attendance_percent, 2) || '%'
        );
    END LOOP;
    
    CLOSE low_attendance_cur;
END;
/

CREATE OR REPLACE PROCEDURE review_department_performance
IS
    -- Cursor for department-wise performance
    CURSOR dept_performance_cur IS
        SELECT d.department_id, d.department_name,
               COUNT(s.student_id) as total_students,
               AVG(m.marks_obtained) as avg_marks,
               MIN(m.marks_obtained) as min_marks,
               MAX(m.marks_obtained) as max_marks
        FROM DEPARTMENT d
        LEFT JOIN STUDENT s ON d.department_id = s.department_id
        LEFT JOIN MARKS m ON s.student_id = m.student_id
        GROUP BY d.department_id, d.department_name;
        
    v_dept_rec dept_performance_cur%ROWTYPE;
BEGIN
    OPEN dept_performance_cur;
    
    DBMS_OUTPUT.PUT_LINE('=== Department Performance Review ===');
    
    LOOP
        FETCH dept_performance_cur INTO v_dept_rec;
        EXIT WHEN dept_performance_cur%NOTFOUND;
        
        DBMS_OUTPUT.PUT_LINE(
            'Department: ' || v_dept_rec.department_name ||
            ' | Avg Marks: ' || ROUND(v_dept_rec.avg_marks, 2) ||
            ' | Students: ' || v_dept_rec.total_students ||
            ' | Range: ' || v_dept_rec.min_marks || '-' || v_dept_rec.max_marks
        );
    END LOOP;
    
    CLOSE dept_performance_cur;
END;
/

CREATE OR REPLACE PROCEDURE track_fee_defaulters
IS
    -- Cursor for students with pending fees
    CURSOR fee_defaulters_cur IS
        SELECT s.student_id, s.name, s.department_id,
               f.amount, f.due_date,
               ROUND(SYSDATE - f.due_date) as days_overdue
        FROM STUDENT s
        JOIN FEES f ON s.student_id = f.student_id
        WHERE f.due_date < SYSDATE
        ORDER BY f.due_date;
        
    v_defaulter_rec fee_defaulters_cur%ROWTYPE;
BEGIN
    OPEN fee_defaulters_cur;
    
    DBMS_OUTPUT.PUT_LINE('=== Fee Defaulters Report ===');
    
    LOOP
        FETCH fee_defaulters_cur INTO v_defaulter_rec;
        EXIT WHEN fee_defaulters_cur%NOTFOUND;
        
        DBMS_OUTPUT.PUT_LINE(
            'Student: ' || v_defaulter_rec.name ||
            ' | Due Amount: ' || v_defaulter_rec.amount ||
            ' | Days Overdue: ' || v_defaulter_rec.days_overdue
        );
    END LOOP;
    
    CLOSE fee_defaulters_cur;
END;
/

-- 9. Procedure to analyze student performance trends
CREATE OR REPLACE PROCEDURE analyze_student_performance(
    p_student_id IN NUMBER
)
IS
    -- Cursor for exam performance over time
    CURSOR performance_cur IS
        SELECT 
            e1.exam_date,
            e1.subject,
            m1.marks_obtained,
            -- Get previous marks using subquery
            (SELECT m2.marks_obtained 
             FROM EXAM e2
             JOIN MARKS m2 ON e2.exam_id = m2.exam_id
             WHERE m2.student_id = p_student_id 
             AND e2.exam_date < e1.exam_date
             ORDER BY e2.exam_date DESC
             FETCH FIRST 1 ROW ONLY) as previous_marks,
            a.status as attendance_status
        FROM EXAM e1
        JOIN MARKS m1 ON e1.exam_id = m1.exam_id
        LEFT JOIN ATTENDANCE a ON e1.exam_date = a.date_of_attendance 
            AND a.student_id = p_student_id
        WHERE m1.student_id = p_student_id
        ORDER BY e1.exam_date;

    -- Variables for cursor and analysis
    v_performance_rec performance_cur%ROWTYPE;
    v_student_name VARCHAR2(100);
    v_total_exams NUMBER := 0;
    v_improving_count NUMBER := 0;
    v_declining_count NUMBER := 0;
    v_absent_count NUMBER := 0;
    v_highest_mark NUMBER := 0;
    v_lowest_mark NUMBER := 100;
BEGIN
    -- Get student name
    SELECT name INTO v_student_name
    FROM STUDENT
    WHERE student_id = p_student_id;

    DBMS_OUTPUT.PUT_LINE('=== Performance Analysis for ' || v_student_name || ' ===');
    DBMS_OUTPUT.PUT_LINE('Exam Performance Timeline:');
    DBMS_OUTPUT.PUT_LINE('----------------------------------------');

    -- Process each exam result
    OPEN performance_cur;
    LOOP
        FETCH performance_cur INTO v_performance_rec;
        EXIT WHEN performance_cur%NOTFOUND;

        -- Count statistics
        v_total_exams := v_total_exams + 1;
        
        IF v_performance_rec.attendance_status = 'Absent' THEN
            v_absent_count := v_absent_count + 1;
        END IF;

        IF v_performance_rec.previous_marks IS NOT NULL THEN
            IF v_performance_rec.marks_obtained > v_performance_rec.previous_marks THEN
                v_improving_count := v_improving_count + 1;
            ELSIF v_performance_rec.marks_obtained < v_performance_rec.previous_marks THEN
                v_declining_count := v_declining_count + 1;
            END IF;
        END IF;

        -- Track highest and lowest marks
        v_highest_mark := GREATEST(v_highest_mark, v_performance_rec.marks_obtained);
        v_lowest_mark := LEAST(v_lowest_mark, v_performance_rec.marks_obtained);

        -- Print exam details
        DBMS_OUTPUT.PUT_LINE(
            'Date: ' || TO_CHAR(v_performance_rec.exam_date, 'DD-MON-YYYY') ||
            ' | Subject: ' || RPAD(v_performance_rec.subject, 15) ||
            ' | Marks: ' || LPAD(v_performance_rec.marks_obtained, 3) ||
            ' | Attendance: ' || NVL(v_performance_rec.attendance_status, 'N/A') ||
            CASE 
                WHEN v_performance_rec.previous_marks IS NOT NULL THEN
                    CASE 
                        WHEN v_performance_rec.marks_obtained > v_performance_rec.previous_marks THEN
                            ' ↑'
                        WHEN v_performance_rec.marks_obtained < v_performance_rec.previous_marks THEN
                            ' ↓'
                        ELSE
                            ' →'
                    END
                ELSE ''
            END
        );
    END LOOP;
    CLOSE performance_cur;

    -- Print summary
    DBMS_OUTPUT.PUT_LINE('----------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Performance Summary:');
    DBMS_OUTPUT.PUT_LINE('Total Exams: ' || v_total_exams);
    DBMS_OUTPUT.PUT_LINE('Highest Mark: ' || v_highest_mark);
    DBMS_OUTPUT.PUT_LINE('Lowest Mark: ' || v_lowest_mark);
    DBMS_OUTPUT.PUT_LINE('Improving Trend Count: ' || v_improving_count);
    DBMS_OUTPUT.PUT_LINE('Declining Trend Count: ' || v_declining_count);
    DBMS_OUTPUT.PUT_LINE('Absences: ' || v_absent_count);
    
    -- Calculate and display performance indicator
    DBMS_OUTPUT.PUT_LINE('Performance Indicator: ' || 
        CASE 
            WHEN v_improving_count > v_declining_count THEN 'Improving ↑'
            WHEN v_improving_count < v_declining_count THEN 'Declining ↓'
            ELSE 'Stable →'
        END
    );
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Student not found or no exam data available');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error analyzing performance: ' || SQLERRM);
END analyze_student_performance;
/

-- Add to the example section:
/*
-- ...existing examples...

-- 1. Process Failed Students Report
BEGIN
    process_failed_students;
END;
/

-- 2. Check Low Attendance Students
BEGIN
    monitor_low_attendance;
END;
/

-- 3. Review Department Performance
BEGIN
    review_department_performance;
END;
/

-- 4. Check Fee Defaulters
BEGIN
    track_fee_defaulters;
END;
/

-- 5. Analyze Individual Student Performance
BEGIN
    analyze_student_performance(1);  -- Replace 1 with the student_id you want to analyze
END;
/
*/

