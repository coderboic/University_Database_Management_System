-- Practical examples and queries that demonstrate normalization principles

-- ============================================================================
-- FIRST NORMAL FORM (1NF) VERIFICATION
-- ============================================================================

-- Verify that all tables have primary keys and no duplicate rows
-- This query counts primary keys - each should appear exactly once
SELECT 'COLLEGE' AS table_name, college_id AS primary_key, COUNT(*) AS occurrence_count
FROM COLLEGE 
GROUP BY college_id
HAVING COUNT(*) > 1
UNION ALL
SELECT 'DEPARTMENT', department_id, COUNT(*) 
FROM DEPARTMENT 
GROUP BY department_id
HAVING COUNT(*) > 1
UNION ALL
SELECT 'STUDENT', student_id, COUNT(*) 
FROM STUDENT 
GROUP BY student_id
HAVING COUNT(*) > 1;
-- If this query returns no rows, all tables satisfy 1NF in terms of unique primary keys

-- ============================================================================
-- SECOND NORMAL FORM (2NF) VERIFICATION
-- ============================================================================

-- Verify 2NF in tables with composite keys
-- For ENROLL table - check if enrollment_date depends on both student_id and department_id
-- If any row has the same student_id and department_id but different enrollment_date, 
-- it would indicate a 2NF violation
SELECT student_id, department_id, COUNT(DISTINCT enrollment_date) AS different_dates
FROM ENROLL
GROUP BY student_id, department_id
HAVING COUNT(DISTINCT enrollment_date) > 1;
-- No rows indicates 2NF compliance

-- For BORROWS table - check if attributes depend on the full composite key
SELECT student_id, library_id, COUNT(DISTINCT return_date) AS different_dates 
FROM BORROWS
GROUP BY student_id, library_id
HAVING COUNT(DISTINCT return_date) > 1;
-- Some rows may appear since return_date depends on the full key (student_id, library_id, borrow_date)

-- ============================================================================
-- THIRD NORMAL FORM (3NF) VERIFICATION
-- ============================================================================

-- Check for potential transitive dependencies
-- Verify student's college is consistent with their department's college
SELECT s.student_id, s.name,
       s.department_id, d.department_name,
       s.college_id AS student_college_id, 
       d.college_id AS department_college_id
FROM STUDENT s
JOIN DEPARTMENT d ON s.department_id = d.department_id
WHERE s.college_id <> d.college_id;
-- No rows indicates 3NF compliance for these relationships

-- Check that fees don't have transitive dependencies through student
SELECT f.fees_id, f.student_id, f.amount, f.due_date,
       s.department_id, s.college_id
FROM FEES f
JOIN STUDENT s ON f.student_id = s.student_id
ORDER BY f.student_id;
-- This query shows that FEES only has direct dependency on student_id, not on other student attributes

-- ============================================================================
-- BOYCE-CODD NORMAL FORM (BCNF) VERIFICATION
-- ============================================================================

-- BCNF requires that every determinant is a candidate key
-- Check MARKS table to ensure marks_obtained depends only on the primary key (marks_id)
-- and not on the combination of (student_id, exam_id)
SELECT student_id, exam_id, COUNT(DISTINCT marks_obtained) AS different_marks
FROM MARKS
GROUP BY student_id, exam_id
HAVING COUNT(DISTINCT marks_obtained) > 1;
-- If this returns rows, it suggests a student could have multiple marks for the same exam,
-- which is expected in our design (different marking components)

-- ============================================================================
-- DEMONSTRATION OF NORMALIZATION BENEFITS
-- ============================================================================

-- 1. Data integrity through relationships:
-- Show students and their departments - relationship preserved through normalization
SELECT s.student_id, s.name, d.department_name, c.college_name
FROM STUDENT s
JOIN DEPARTMENT d ON s.department_id = d.department_id
JOIN COLLEGE c ON s.college_id = c.college_id;

-- 2. Update efficiency (single update location):
-- Example: When a department head changes, we only update it in one place
SELECT department_id, department_name, hod_name FROM DEPARTMENT;
-- To update: UPDATE DEPARTMENT SET hod_name = 'New HOD Name' WHERE department_id = 1;

-- 3. Consistency through normalization:
-- Show exam scores with consistent student information
SELECT m.marks_id, s.name, s.department_id, e.subject, m.marks_obtained
FROM MARKS m
JOIN STUDENT s ON m.student_id = s.student_id
JOIN EXAM e ON m.exam_id = e.exam_id;

-- ============================================================================
-- DEMONSTRATION OF SPECIALIZED ENTITIES (INHERITANCE IMPLEMENTATION)
-- ============================================================================

-- Show UG students with all their attributes from parent table
SELECT s.student_id, s.name, s.gender, s.year, s.email, d.department_name
FROM STUDENT s
JOIN UG_STUDENT ug ON s.student_id = ug.student_id
JOIN DEPARTMENT d ON s.department_id = d.department_id;

-- Show PG students with all their attributes from parent table
SELECT s.student_id, s.name, s.gender, s.year, s.email, d.department_name
FROM STUDENT s
JOIN PG_STUDENT pg ON s.student_id = pg.student_id
JOIN DEPARTMENT d ON s.department_id = d.department_id;

-- ============================================================================
-- SUMMARY QUERY: DATABASE NORMALIZATION STATISTICS
-- ============================================================================

-- This query counts entities in our normalized structure
SELECT 'Colleges' AS entity_type, COUNT(*) AS count FROM COLLEGE
UNION ALL
SELECT 'Departments', COUNT(*) FROM DEPARTMENT
UNION ALL
SELECT 'Students (Total)', COUNT(*) FROM STUDENT
UNION ALL
SELECT 'UG Students', COUNT(*) FROM UG_STUDENT
UNION ALL
SELECT 'PG Students', COUNT(*) FROM PG_STUDENT
UNION ALL
SELECT 'Faculty Members', COUNT(*) FROM FACULTY
UNION ALL
SELECT 'Staff Members', COUNT(*) FROM STAFF
UNION ALL
SELECT 'Teaching Staff', COUNT(*) FROM TEACHING_STAFF
UNION ALL
SELECT 'Non-Teaching Staff', COUNT(*) FROM NON_TEACHING_STAFF
UNION ALL
SELECT 'Examinations', COUNT(*) FROM EXAM
UNION ALL
SELECT 'Mark Records', COUNT(*) FROM MARKS
UNION ALL
SELECT 'Attendance Records', COUNT(*) FROM ATTENDANCE
ORDER BY entity_type;
