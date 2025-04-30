-- University Database System
-- Database Triggers

-- 1. Trigger to automatically update the total_students count in DEPARTMENT table
CREATE OR REPLACE TRIGGER trg_update_dept_student_count
AFTER INSERT OR DELETE ON STUDENT
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        -- Increment student count in department
        UPDATE DEPARTMENT
        SET total_students = total_students + 1
        WHERE department_id = :NEW.department_id;
    ELSIF DELETING THEN
        -- Decrement student count in department
        UPDATE DEPARTMENT
        SET total_students = total_students - 1
        WHERE department_id = :OLD.department_id;
    END IF;
END;
/

-- 2. Trigger to validate student data before insertion
CREATE OR REPLACE TRIGGER trg_validate_student
BEFORE INSERT OR UPDATE ON STUDENT
FOR EACH ROW
DECLARE
    v_valid_dept BOOLEAN;
    v_valid_college BOOLEAN;
BEGIN
    -- Check if department exists
    SELECT CASE WHEN COUNT(*) > 0 THEN TRUE ELSE FALSE END INTO v_valid_dept
    FROM DEPARTMENT
    WHERE department_id = :NEW.department_id;
    
    -- Check if college exists
    SELECT CASE WHEN COUNT(*) > 0 THEN TRUE ELSE FALSE END INTO v_valid_college
    FROM COLLEGE
    WHERE college_id = :NEW.college_id;
    
    -- Validate email format (basic check)
    IF :NEW.email IS NOT NULL AND :NEW.email NOT LIKE '%@%.%' THEN
        RAISE_APPLICATION_ERROR(-20001, 'Invalid email format');
    END IF;
    
    -- Validate department
    IF NOT v_valid_dept THEN
        RAISE_APPLICATION_ERROR(-20002, 'Department does not exist');
    END IF;
    
    -- Validate college
    IF NOT v_valid_college THEN
        RAISE_APPLICATION_ERROR(-20003, 'College does not exist');
    END IF;
    
    -- Validate year
    IF :NEW.year NOT BETWEEN 1 AND 5 THEN
        RAISE_APPLICATION_ERROR(-20004, 'Year must be between 1 and 5');
    END IF;
END;
/

-- 3. Trigger to log student marks changes
CREATE OR REPLACE TRIGGER trg_log_marks_changes
AFTER INSERT OR UPDATE ON MARKS
FOR EACH ROW
DECLARE
    v_action VARCHAR2(10);
    v_log_message VARCHAR2(200);
BEGIN
    -- Determine action
    IF INSERTING THEN
        v_action := 'INSERT';
    ELSE
        v_action := 'UPDATE';
    END IF;
    
    -- Create log message
    v_log_message := 'Action: ' || v_action || 
                     ', Student ID: ' || :NEW.student_id || 
                     ', Exam ID: ' || :NEW.exam_id || 
                     ', Marks: ' || :NEW.marks_obtained;
    
    -- In a real system, you might insert this into a log table
    -- For demonstration, we'll output to console
    DBMS_OUTPUT.PUT_LINE('MARK CHANGE LOG: ' || v_log_message);
    
    -- You could create a MARKS_LOG table and insert into it here
    /*
    INSERT INTO MARKS_LOG (
        log_id, action, student_id, exam_id, old_marks, new_marks, change_date
    ) VALUES (
        mark_log_seq.NEXTVAL, v_action, :NEW.student_id, :NEW.exam_id, 
        :OLD.marks_obtained, :NEW.marks_obtained, SYSDATE
    );
    */
END;
/

-- 4. Trigger to enforce hostel type consistency
CREATE OR REPLACE TRIGGER trg_enforce_hostel_type
BEFORE INSERT OR UPDATE ON STUDENT
FOR EACH ROW
DECLARE
    v_gender VARCHAR2(10);
    v_hostel_type VARCHAR2(20);
BEGIN
    -- For demonstration purposes only (not part of actual schema)
    -- In a real system, you'd have a relationship between students and hostels
    NULL;
    /*
    -- This is conceptual code that would work if we had a STUDENT_HOSTEL table
    IF :NEW.hostel_id IS NOT NULL THEN
        -- Get student gender
        v_gender := :NEW.gender;
        
        -- Get hostel type
        SELECT
            CASE
                WHEN EXISTS (SELECT 1 FROM BOYS_HOSTEL WHERE hostel_id = :NEW.hostel_id) THEN 'BOYS'
                WHEN EXISTS (SELECT 1 FROM GIRLS_HOSTEL WHERE hostel_id = :NEW.hostel_id) THEN 'GIRLS'
                ELSE NULL
            END INTO v_hostel_type
        FROM DUAL;
        
        -- Validate gender and hostel type match
        IF (v_gender = 'Male' AND v_hostel_type != 'BOYS') OR 
           (v_gender = 'Female' AND v_hostel_type != 'GIRLS') THEN
            RAISE_APPLICATION_ERROR(-20005, 'Student gender does not match hostel type');
        END IF;
    END IF;
    */
END;
/

-- 5. Trigger to ensure only one active enrollment per student-department combination
CREATE OR REPLACE TRIGGER trg_check_enrollment
BEFORE INSERT ON ENROLL
FOR EACH ROW
DECLARE
    v_count NUMBER;
BEGIN
    -- Check if there's already an active enrollment
    SELECT COUNT(*) INTO v_count
    FROM ENROLL
    WHERE student_id = :NEW.student_id
    AND department_id = :NEW.department_id;
    
    IF v_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20006, 'Student is already enrolled in this department');
    END IF;
END;
/

-- 6. Trigger to automatically update fee status when payment is made
-- This is conceptual and would require additional tables in a real implementation
CREATE OR REPLACE TRIGGER trg_update_fee_status
AFTER INSERT ON FEES
FOR EACH ROW
DECLARE
    PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
    -- For demonstration purposes only
    DBMS_OUTPUT.PUT_LINE('Fee recorded for student ID: ' || :NEW.student_id || 
                         ', Amount: ' || :NEW.amount || 
                         ', Due Date: ' || TO_CHAR(:NEW.due_date, 'YYYY-MM-DD'));
    
    -- In a real system, you might update a FEE_STATUS table or similar
    /*
    INSERT INTO FEE_PAYMENT (
        payment_id, fee_id, student_id, payment_date, amount, payment_method
    ) VALUES (
        payment_seq.NEXTVAL, :NEW.fee_id, :NEW.student_id, SYSDATE, :NEW.amount, 'System'
    );
    */
    
    COMMIT;
END;
/

-- 7. Trigger to maintain data consistency between LIBRARY_RECORDS and BORROWS tables
CREATE OR REPLACE TRIGGER trg_sync_library_borrows
AFTER INSERT OR UPDATE ON LIBRARY_RECORDS
FOR EACH ROW
BEGIN
    -- When a book is issued, add entry to BORROWS
    IF INSERTING THEN
        INSERT INTO BORROWS (student_id, library_id, borrow_date, return_date)
        VALUES (:NEW.student_id, :NEW.library_id, :NEW.issue_date, :NEW.return_date);
    
    -- When a book return date is updated, update BORROWS
    ELSIF UPDATING AND :OLD.return_date != :NEW.return_date THEN
        UPDATE BORROWS
        SET return_date = :NEW.return_date
        WHERE student_id = :NEW.student_id
        AND library_id = :NEW.library_id
        AND borrow_date = :NEW.issue_date;
    END IF;
END;
/