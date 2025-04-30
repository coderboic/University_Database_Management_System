-- University Database System
-- Example SQL Queries demonstrating various SQL concepts

-- 1. Basic Select Queries
-- List all students
SELECT student_id, name, gender, year, email FROM STUDENT;

-- List all departments with their colleges
SELECT d.department_name, c.college_name 
FROM DEPARTMENT d 
JOIN COLLEGE c ON d.college_id = c.college_id;

-- 2. Filtering with WHERE clause
-- Find all male students
SELECT student_id, name, email 
FROM STUDENT 
WHERE gender = 'Male';

-- Find students with due dates in May 2025
SELECT s.student_id, s.name, f.amount, f.due_date 
FROM STUDENT s 
JOIN FEES f ON s.student_id = f.student_id 
WHERE f.due_date BETWEEN TO_DATE('2025-05-01', 'YYYY-MM-DD') AND TO_DATE('2025-05-31', 'YYYY-MM-DD');

-- 3. Aggregation with GROUP BY
-- Count students by department
SELECT d.department_name, COUNT(s.student_id) as student_count
FROM DEPARTMENT d 
LEFT JOIN STUDENT s ON d.department_id = s.department_id
GROUP BY d.department_name;

-- Calculate average marks by department
SELECT d.department_name, AVG(m.marks_obtained) as avg_marks
FROM DEPARTMENT d
JOIN STUDENT s ON d.department_id = s.department_id
JOIN MARKS m ON s.student_id = m.student_id
GROUP BY d.department_name;

-- 4. HAVING clause for filtering aggregated results
-- Find departments with average marks above 80
SELECT d.department_name, AVG(m.marks_obtained) as avg_marks
FROM DEPARTMENT d
JOIN STUDENT s ON d.department_id = s.department_id
JOIN MARKS m ON s.student_id = m.student_id
GROUP BY d.department_name
HAVING AVG(m.marks_obtained) > 80;

-- 5. Complex Joins (Inner, Left, Right, Full)
-- Inner join: Students with their exam results
SELECT s.name, e.subject, m.marks_obtained
FROM STUDENT s
JOIN EXAM e ON s.student_id = e.student_id
JOIN MARKS m ON e.exam_id = m.exam_id;

-- Left join: All students with exam results (including those with no exams)
SELECT s.name, e.subject, m.marks_obtained
FROM STUDENT s
LEFT JOIN EXAM e ON s.student_id = e.student_id
LEFT JOIN MARKS m ON e.exam_id = m.exam_id;

-- 6. Subqueries
-- Find students with marks above the average
SELECT s.student_id, s.name, m.marks_obtained
FROM STUDENT s
JOIN MARKS m ON s.student_id = m.student_id
WHERE m.marks_obtained > (SELECT AVG(marks_obtained) FROM MARKS);

-- Find departments that have students with marks above 90
SELECT DISTINCT d.department_id, d.department_name
FROM DEPARTMENT d
WHERE d.department_id IN (
    SELECT s.department_id
    FROM STUDENT s
    JOIN MARKS m ON s.student_id = m.student_id
    WHERE m.marks_obtained > 90
);

-- 7. Correlated Subqueries
-- Find students who have the highest mark in their department
SELECT s.student_id, s.name, s.department_id, m.marks_obtained
FROM STUDENT s
JOIN MARKS m ON s.student_id = m.student_id
WHERE m.marks_obtained = (
    SELECT MAX(m2.marks_obtained)
    FROM STUDENT s2
    JOIN MARKS m2 ON s2.student_id = m2.student_id
    WHERE s2.department_id = s.department_id
);

-- 8. EXISTS and NOT EXISTS
-- Find students who have borrowed books
SELECT s.student_id, s.name
FROM STUDENT s
WHERE EXISTS (
    SELECT 1
    FROM BORROWS b
    WHERE b.student_id = s.student_id
);

-- Find students who have never been absent
SELECT s.student_id, s.name
FROM STUDENT s
WHERE NOT EXISTS (
    SELECT 1
    FROM ATTENDANCE a
    WHERE a.student_id = s.student_id AND a.status = 'Absent'
);

-- 9. UNION, INTERSECT, MINUS operations
-- Students who are either in UG or have marks above 80
SELECT s.student_id, s.name
FROM STUDENT s
JOIN UG_STUDENT ug ON s.student_id = ug.student_id
UNION
SELECT s.student_id, s.name
FROM STUDENT s
JOIN MARKS m ON s.student_id = m.student_id
WHERE m.marks_obtained > 80;

-- 10. Common Table Expressions (CTE)
-- Calculate department-wise statistics using CTE
WITH DeptStats AS (
    SELECT 
        d.department_id,
        d.department_name,
        COUNT(s.student_id) as student_count,
        AVG(m.marks_obtained) as avg_marks
    FROM DEPARTMENT d
    LEFT JOIN STUDENT s ON d.department_id = s.department_id
    LEFT JOIN MARKS m ON s.student_id = m.student_id
    GROUP BY d.department_id, d.department_name
)
SELECT 
    d.department_name,
    d.student_count,
    d.avg_marks,
    CASE
        WHEN d.avg_marks > 85 THEN 'Excellent'
        WHEN d.avg_marks > 75 THEN 'Good'
        ELSE 'Average'
    END as performance
FROM DeptStats d;

-- 11. Window Functions
-- Rank students by marks within departments
SELECT 
    s.department_id,
    d.department_name,
    s.student_id,
    s.name,
    m.marks_obtained,
    RANK() OVER (PARTITION BY s.department_id ORDER BY m.marks_obtained DESC) as dept_rank
FROM STUDENT s
JOIN DEPARTMENT d ON s.department_id = d.department_id
JOIN MARKS m ON s.student_id = m.student_id;

-- Calculate running attendance percentage
SELECT 
    s.student_id,
    s.name,
    a.date_of_attendance,
    a.status,
    SUM(CASE WHEN a.status = 'Present' THEN 1 ELSE 0 END) OVER (
        PARTITION BY s.student_id 
        ORDER BY a.date_of_attendance
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) as present_count,
    COUNT(a.attendance_id) OVER (
        PARTITION BY s.student_id 
        ORDER BY a.date_of_attendance
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) as total_days,
    ROUND(
        100 * SUM(CASE WHEN a.status = 'Present' THEN 1 ELSE 0 END) OVER (
            PARTITION BY s.student_id 
            ORDER BY a.date_of_attendance
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) / 
        COUNT(a.attendance_id) OVER (
            PARTITION BY s.student_id 
            ORDER BY a.date_of_attendance
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ), 2
    ) as attendance_percentage
FROM STUDENT s
JOIN ATTENDANCE a ON s.student_id = a.student_id
ORDER BY s.student_id, a.date_of_attendance;

-- 12. Hierarchical Queries 
-- Example of a hierarchical query (assuming staff hierarchy)
-- For demonstration, we'll create a dummy hierarchy by adding some manager IDs to staff
-- This is for illustration only and not part of actual schema

WITH StaffHierarchy AS (
    SELECT 
        staff_id, 
        staff_name, 
        CASE 
            WHEN staff_id > 2 THEN MOD(staff_id - 1, 2) + 1
            ELSE NULL
        END as manager_id
    FROM STAFF
)
SELECT 
    staff_id,
    staff_name,
    manager_id,
    LEVEL as hierarchy_level,
    LPAD(' ', 2 * (LEVEL - 1)) || staff_name as org_chart
FROM StaffHierarchy
START WITH manager_id IS NULL
CONNECT BY PRIOR staff_id = manager_id;

-- 13. CASE expressions
-- Categorize students by performance
SELECT 
    s.student_id, 
    s.name,
    m.marks_obtained,
    CASE 
        WHEN m.marks_obtained >= 90 THEN 'Excellent'
        WHEN m.marks_obtained >= 80 THEN 'Very Good'
        WHEN m.marks_obtained >= 70 THEN 'Good'
        WHEN m.marks_obtained >= 60 THEN 'Average'
        ELSE 'Below Average'
    END as performance_category
FROM STUDENT s
JOIN MARKS m ON s.student_id = m.student_id;

-- 14. Pivoting data (using CASE)
-- Create a pivot table of attendance by date
SELECT 
    s.student_id,
    s.name,
    SUM(CASE WHEN TO_CHAR(a.date_of_attendance, 'YYYY-MM-DD') = '2025-04-01' AND a.status = 'Present' THEN 1 ELSE 0 END) as "2025-04-01",
    SUM(CASE WHEN TO_CHAR(a.date_of_attendance, 'YYYY-MM-DD') = '2025-04-02' AND a.status = 'Present' THEN 1 ELSE 0 END) as "2025-04-02"
FROM STUDENT s
LEFT JOIN ATTENDANCE a ON s.student_id = a.student_id
GROUP BY s.student_id, s.name;

-- 15. Analytical functions
-- Calculate percentile ranks of students based on marks
SELECT 
    s.student_id,
    s.name,
    m.marks_obtained,
    PERCENT_RANK() OVER (ORDER BY m.marks_obtained) as percentile_rank,
    NTILE(4) OVER (ORDER BY m.marks_obtained) as quartile
FROM STUDENT s
JOIN MARKS m ON s.student_id = m.student_id;

-- 16. Complex nested queries
-- Find students who have higher marks than the average of their department
SELECT 
    s.student_id,
    s.name,
    d.department_name,
    m.marks_obtained,
    (SELECT AVG(m2.marks_obtained) 
     FROM MARKS m2
     JOIN STUDENT s2 ON m2.student_id = s2.student_id
     WHERE s2.department_id = s.department_id) as dept_avg_marks
FROM STUDENT s
JOIN DEPARTMENT d ON s.department_id = d.department_id
JOIN MARKS m ON s.student_id = m.student_id
WHERE m.marks_obtained > (
    SELECT AVG(m2.marks_obtained) 
    FROM MARKS m2
    JOIN STUDENT s2 ON m2.student_id = s2.student_id
    WHERE s2.department_id = s.department_id
);

-- 17. Views for data abstraction
-- Create a view for student performance summary
CREATE OR REPLACE VIEW STUDENT_PERFORMANCE AS
SELECT 
    s.student_id,
    s.name,
    d.department_name,
    c.college_name,
    AVG(m.marks_obtained) as avg_marks,
    COUNT(DISTINCT e.exam_id) as exams_taken,
    MAX(m.marks_obtained) as highest_mark,
    MIN(m.marks_obtained) as lowest_mark
FROM STUDENT s
JOIN DEPARTMENT d ON s.department_id = d.department_id
JOIN COLLEGE c ON s.college_id = c.college_id
LEFT JOIN EXAM e ON s.student_id = e.student_id
LEFT JOIN MARKS m ON e.exam_id = m.exam_id
GROUP BY s.student_id, s.name, d.department_name, c.college_name;

-- Query the view
SELECT * FROM STUDENT_PERFORMANCE;

-- 18. Generating Reports
-- Generate a comprehensive student report
SELECT 
    s.student_id,
    s.name,
    s.email,
    s.phone,
    d.department_name,
    c.college_name,
    (SELECT COUNT(*) FROM ATTENDANCE a WHERE a.student_id = s.student_id AND a.status = 'Present') as attendance_present,
    (SELECT COUNT(*) FROM ATTENDANCE a WHERE a.student_id = s.student_id) as total_attendance,
    ROUND((SELECT COUNT(*) FROM ATTENDANCE a WHERE a.student_id = s.student_id AND a.status = 'Present') / 
          NULLIF((SELECT COUNT(*) FROM ATTENDANCE a WHERE a.student_id = s.student_id), 0) * 100, 2) as attendance_percentage,
    (SELECT AVG(m.marks_obtained) FROM MARKS m WHERE m.student_id = s.student_id) as avg_marks,
    (SELECT f.amount FROM FEES f WHERE f.student_id = s.student_id AND ROWNUM = 1) as fees_amount,
    (SELECT f.due_date FROM FEES f WHERE f.student_id = s.student_id AND ROWNUM = 1) as fees_due_date,
    CASE 
        WHEN EXISTS (SELECT 1 FROM UG_STUDENT ug WHERE ug.student_id = s.student_id) THEN 'Undergraduate'
        WHEN EXISTS (SELECT 1 FROM PG_STUDENT pg WHERE pg.student_id = s.student_id) THEN 'Postgraduate'
        ELSE 'Unknown'
    END as student_type,
    (SELECT COUNT(*) FROM LIBRARY_RECORDS lr WHERE lr.student_id = s.student_id) as library_books_borrowed
FROM STUDENT s
JOIN DEPARTMENT d ON s.department_id = d.department_id
JOIN COLLEGE c ON s.college_id = c.college_id;

-- 19. Finding anomalies and inconsistencies
-- Find students with attendance but no exam records
SELECT 
    s.student_id,
    s.name
FROM STUDENT s
WHERE EXISTS (SELECT 1 FROM ATTENDANCE a WHERE a.student_id = s.student_id)
AND NOT EXISTS (SELECT 1 FROM EXAM e WHERE e.student_id = s.student_id);

-- 20. Data cleansing and quality check
-- Identify missing values or inconsistent data
SELECT 
    'Students with no department' as issue_type,
    COUNT(*) as count
FROM STUDENT
WHERE department_id IS NULL
UNION ALL
SELECT 
    'Students with no email',
    COUNT(*)
FROM STUDENT
WHERE email IS NULL
UNION ALL
SELECT 
    'Departments with no students',
    COUNT(*)
FROM DEPARTMENT d
WHERE NOT EXISTS (SELECT 1 FROM STUDENT s WHERE s.department_id = d.department_id)
UNION ALL
SELECT 
    'Students with no attendance records',
    COUNT(*)
FROM STUDENT s
WHERE NOT EXISTS (SELECT 1 FROM ATTENDANCE a WHERE a.student_id = s.student_id);

-- 21. Recursive Query using Connect By
-- Generate a date range for attendance reporting
SELECT 
    TO_DATE('2025-04-01', 'YYYY-MM-DD') + (LEVEL - 1) as report_date
FROM DUAL
CONNECT BY LEVEL <= 30; -- For 30 days starting from April 1, 2025

-- 22. Materialized View for performance (conceptual, may not execute in LiveSQL)
CREATE MATERIALIZED VIEW MV_STUDENT_SUMMARY
BUILD IMMEDIATE
REFRESH COMPLETE ON DEMAND
AS
SELECT 
    s.student_id,
    s.name,
    d.department_name,
    c.college_name,
    AVG(m.marks_obtained) as avg_marks
FROM STUDENT s
JOIN DEPARTMENT d ON s.department_id = d.department_id
JOIN COLLEGE c ON s.college_id = c.college_id
LEFT JOIN MARKS m ON s.student_id = m.student_id
GROUP BY s.student_id, s.name, d.department_name, c.college_name;