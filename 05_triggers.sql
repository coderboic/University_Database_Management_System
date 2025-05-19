-- University Database System
-- Database Triggers

-- 1. Update department student count
CREATE OR REPLACE TRIGGER trg_update_dept_student_count
AFTER INSERT OR DELETE ON STUDENT
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        UPDATE DEPARTMENT
        SET total_students = total_students + 1
        WHERE department_id = :NEW.department_id;
    ELSIF DELETING THEN
        UPDATE DEPARTMENT
        SET total_students = total_students - 1
        WHERE department_id = :OLD.department_id;
    END IF;
END;
/

-- 2. Validate student data
CREATE OR REPLACE TRIGGER trg_validate_student
BEFORE INSERT OR UPDATE ON STUDENT
FOR EACH ROW
DECLARE
    v_valid_dept BOOLEAN;
    v_valid_college BOOLEAN;
BEGIN
    -- Check department and college
    SELECT CASE WHEN COUNT(*) > 0 THEN TRUE ELSE FALSE END INTO v_valid_dept
    FROM DEPARTMENT WHERE department_id = :NEW.department_id;
    
    SELECT CASE WHEN COUNT(*) > 0 THEN TRUE ELSE FALSE END INTO v_valid_college
    FROM COLLEGE WHERE college_id = :NEW.college_id;
    
    -- Basic validations
    IF :NEW.email NOT LIKE '%@%.%' THEN
        RAISE_APPLICATION_ERROR(-20001, 'Invalid email format');
    END IF;
    
    IF NOT v_valid_dept THEN
        RAISE_APPLICATION_ERROR(-20002, 'Invalid department');
    END IF;
    
    IF NOT v_valid_college THEN
        RAISE_APPLICATION_ERROR(-20003, 'Invalid college');
    END IF;
END;
/

-- 3. Log marks changes
CREATE OR REPLACE TRIGGER trg_log_marks_changes
AFTER INSERT OR UPDATE ON MARKS
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        DBMS_OUTPUT.PUT_LINE('New marks added - Student: ' || :NEW.student_id || 
                            ', Marks: ' || :NEW.marks_obtained);
    ELSE
        DBMS_OUTPUT.PUT_LINE('Marks updated - Student: ' || :NEW.student_id || 
                            ', Old: ' || :OLD.marks_obtained || 
                            ', New: ' || :NEW.marks_obtained);
    END IF;
END;
/

-- 4. Check student enrollment
CREATE OR REPLACE TRIGGER trg_check_enrollment
BEFORE INSERT ON ENROLL
FOR EACH ROW
DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM ENROLL
    WHERE student_id = :NEW.student_id
    AND department_id = :NEW.department_id;
    
    IF v_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20004, 'Student already enrolled');
    END IF;
END;
/

-- 5. Record fee payment
CREATE OR REPLACE TRIGGER trg_record_fee
AFTER INSERT ON FEES
FOR EACH ROW
BEGIN
    DBMS_OUTPUT.PUT_LINE('Fee recorded - Student: ' || :NEW.student_id || 
                         ', Amount: ' || :NEW.amount || 
                         ', Due: ' || TO_CHAR(:NEW.due_date, 'DD-MON-YYYY'));
END;
/
