-- University Database System
-- Advanced Analytics and Reports

-- 1. Department Performance Dashboard
-- Generates a comprehensive performance view by department
SELECT 
    d.department_id,
    d.department_name,
    d.hod_name,
    c.college_name,
    d.total_staffs,
    d.total_students,
    COUNT(DISTINCT s.student_id) AS active_students,
    COUNT(DISTINCT m.marks_id) AS total_exams_taken,
    ROUND(AVG(m.marks_obtained), 2) AS avg_marks,
    MAX(m.marks_obtained) AS highest_mark,
    MIN(m.marks_obtained) AS lowest_mark,
    COUNT(DISTINCT CASE WHEN m.marks_obtained >= 90 THEN s.student_id END) AS excellent_students,
    COUNT(DISTINCT CASE WHEN m.marks_obtained < 40 THEN s.student_id END) AS failing_students,
    ROUND(
        COUNT(DISTINCT CASE WHEN a.status = 'Present' THEN a.attendance_id END) * 100.0 /
        NULLIF(COUNT(DISTINCT a.attendance_id), 0), 2
    ) AS attendance_percentage
FROM DEPARTMENT d
JOIN COLLEGE c ON d.college_id = c.college_id
LEFT JOIN STUDENT s ON d.department_id = s.department_id
LEFT JOIN MARKS m ON s.student_id = m.student_id
LEFT JOIN ATTENDANCE a ON s.student_id = a.student_id
GROUP BY d.department_id, d.department_name, d.hod_name, c.college_name, d.total_staffs, d.total_students
ORDER BY avg_marks DESC;

-- 2. Student Progress Tracker
-- Tracks student performance over time by exam date
SELECT 
    s.student_id,
    s.name,
    e.subject,
    e.exam_date,
    m.marks_obtained,
    AVG(m.marks_obtained) OVER (
        PARTITION BY s.student_id 
        ORDER BY e.exam_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_average,
    m.marks_obtained - LAG(m.marks_obtained, 1, m.marks_obtained) OVER (
        PARTITION BY s.student_id 
        ORDER BY e.exam_date
    ) AS marks_change,
    RANK() OVER (PARTITION BY e.subject ORDER BY m.marks_obtained DESC) AS subject_rank
FROM STUDENT s
JOIN EXAM e ON s.student_id = e.student_id
JOIN MARKS m ON e.exam_id = m.exam_id
ORDER BY s.student_id, e.exam_date;

-- 3. College Comparative Analysis
-- Compare statistics across different colleges
WITH CollegeStats AS (
    SELECT 
        c.college_id,
        c.college_name,
        COUNT(DISTINCT d.department_id) AS dept_count,
        COUNT(DISTINCT s.student_id) AS student_count,
        COUNT(DISTINCT f.faculty_id) AS faculty_count,
        AVG(m.marks_obtained) AS avg_marks
    FROM COLLEGE c
    LEFT JOIN DEPARTMENT d ON c.college_id = d.college_id
    LEFT JOIN STUDENT s ON d.department_id = s.department_id
    LEFT JOIN FACULTY f ON d.department_id = f.department_id
    LEFT JOIN MARKS m ON s.student_id = m.student_id
    GROUP BY c.college_id, c.college_name
)
SELECT 
    cs.*,
    RANK() OVER (ORDER BY cs.avg_marks DESC) AS performance_rank,
    CASE 
        WHEN cs.avg_marks > 85 THEN 'Top Performer'
        WHEN cs.avg_marks > 75 THEN 'Good Performer'
        WHEN cs.avg_marks > 65 THEN 'Average Performer'
        ELSE 'Needs Improvement'
    END AS performance_category,
    ROUND(cs.student_count / NULLIF(cs.faculty_count, 0), 2) AS student_faculty_ratio
FROM CollegeStats cs
ORDER BY performance_rank;

-- 4. Attendance Correlation Analysis
-- Analyze correlation between attendance and performance
SELECT 
    s.department_id,
    d.department_name,
    s.student_id,
    s.name,
    COUNT(a.attendance_id) AS total_attendance_records,
    SUM(CASE WHEN a.status = 'Present' THEN 1 ELSE 0 END) AS days_present,
    ROUND(
        SUM(CASE WHEN a.status = 'Present' THEN 1 ELSE 0 END) * 100.0 /
        NULLIF(COUNT(a.attendance_id), 0), 2
    ) AS attendance_percentage,
    COUNT(DISTINCT e.exam_id) AS exams_taken,
    ROUND(AVG(m.marks_obtained), 2) AS avg_marks,
    CASE 
        WHEN AVG(m.marks_obtained) >= 90 THEN 'Excellent'
        WHEN AVG(m.marks_obtained) >= 75 THEN 'Very Good'
        WHEN AVG(m.marks_obtained) >= 60 THEN 'Good'
        WHEN AVG(m.marks_obtained) >= 40 THEN 'Average'
        ELSE 'Below Average'
    END AS performance_category
FROM STUDENT s
JOIN DEPARTMENT d ON s.department_id = d.department_id
LEFT JOIN ATTENDANCE a ON s.student_id = a.student_id
LEFT JOIN EXAM e ON s.student_id = e.student_id
LEFT JOIN MARKS m ON e.exam_id = m.exam_id
GROUP BY s.department_id, d.department_name, s.student_id, s.name
ORDER BY attendance_percentage DESC, avg_marks DESC;

-- 5. Staff Performance Analysis
-- For demonstration only - assumptions made about data not present in schema
WITH TeachingEffectiveness AS (
    SELECT 
        ts.staff_id,
        s.staff_name,
        s.department_id,
        d.department_name,
        -- Assuming a conceptual relationship between staff and student performance
        -- This is for demonstration only
        (SELECT AVG(m.marks_obtained)
         FROM MARKS m
         JOIN STUDENT st ON m.student_id = st.student_id
         WHERE st.department_id = s.department_id) AS avg_student_marks,
        (SELECT COUNT(DISTINCT st.student_id)
         FROM STUDENT st
         WHERE st.department_id = s.department_id) AS student_count
    FROM TEACHING_STAFF ts
    JOIN STAFF s ON ts.staff_id = s.staff_id
    JOIN DEPARTMENT d ON s.department_id = d.department_id
)
SELECT 
    te.*,
    RANK() OVER (ORDER BY te.avg_student_marks DESC) AS effectiveness_rank,
    CASE 
        WHEN te.avg_student_marks > 85 THEN 'Highly Effective'
        WHEN te.avg_student_marks > 75 THEN 'Effective'
        WHEN te.avg_student_marks > 65 THEN 'Moderately Effective'
        ELSE 'Needs Improvement'
    END AS effectiveness_rating
FROM TeachingEffectiveness te
ORDER BY effectiveness_rank;

-- 6. Library Usage Analysis
-- Study patterns of library usage across departments
WITH LibraryUsage AS (
    SELECT 
        d.department_id,
        d.department_name,
        COUNT(DISTINCT lr.record_id) AS total_books_borrowed,
        COUNT(DISTINCT s.student_id) AS total_students,
        COUNT(DISTINCT lr.record_id) / NULLIF(COUNT(DISTINCT s.student_id), 0) AS books_per_student,
        AVG(m.marks_obtained) AS avg_marks
    FROM DEPARTMENT d
    JOIN STUDENT s ON d.department_id = s.department_id
    LEFT JOIN LIBRARY_RECORDS lr ON s.student_id = lr.student_id
    LEFT JOIN MARKS m ON s.student_id = m.student_id
    GROUP BY d.department_id, d.department_name
)
SELECT 
    lu.*,
    RANK() OVER (ORDER BY lu.books_per_student DESC) AS library_usage_rank,
    RANK() OVER (ORDER BY lu.avg_marks DESC) AS performance_rank,
    ABS(
        RANK() OVER (ORDER BY lu.books_per_student DESC) - 
        RANK() OVER (ORDER BY lu.avg_marks DESC)
    ) AS rank_difference
FROM LibraryUsage lu
ORDER BY books_per_student DESC;

-- 7. Student Type Analysis (UG vs PG)
-- Compare performance metrics between undergraduate and postgraduate students
SELECT 
    CASE 
        WHEN ug.student_id IS NOT NULL THEN 'Undergraduate'
        WHEN pg.student_id IS NOT NULL THEN 'Postgraduate'
        ELSE 'Unknown'
    END AS student_type,
    COUNT(DISTINCT s.student_id) AS total_students,
    ROUND(AVG(m.marks_obtained), 2) AS avg_marks,
    MIN(m.marks_obtained) AS min_marks,
    MAX(m.marks_obtained) AS max_marks,
    ROUND(STDDEV(m.marks_obtained), 2) AS marks_stddev,
    COUNT(DISTINCT CASE WHEN m.marks_obtained >= 90 THEN s.student_id END) AS excellent_students,
    ROUND(
        SUM(CASE WHEN a.status = 'Present' THEN 1 ELSE 0 END) * 100.0 / 
        NULLIF(COUNT(a.attendance_id), 0), 2
    ) AS attendance_percentage,
    COUNT(DISTINCT lr.record_id) / NULLIF(COUNT(DISTINCT s.student_id), 0) AS books_per_student
FROM STUDENT s
LEFT JOIN UG_STUDENT ug ON s.student_id = ug.student_id
LEFT JOIN PG_STUDENT pg ON s.student_id = pg.student_id
LEFT JOIN MARKS m ON s.student_id = m.student_id
LEFT JOIN ATTENDANCE a ON s.student_id = a.student_id
LEFT JOIN LIBRARY_RECORDS lr ON s.student_id = lr.student_id
GROUP BY CASE 
           WHEN ug.student_id IS NOT NULL THEN 'Undergraduate'
           WHEN pg.student_id IS NOT NULL THEN 'Postgraduate'
           ELSE 'Unknown'
         END;

-- 8. Gender-based Performance Analysis
-- Compare academic performance across genders
SELECT 
    s.gender,
    COUNT(DISTINCT s.student_id) AS total_students,
    ROUND(AVG(m.marks_obtained), 2) AS avg_marks,
    ROUND(MEDIAN(m.marks_obtained), 2) AS median_marks,
    MIN(m.marks_obtained) AS min_marks,
    MAX(m.marks_obtained) AS max_marks,
    ROUND(
        SUM(CASE WHEN a.status = 'Present' THEN 1 ELSE 0 END) * 100.0 / 
        NULLIF(COUNT(a.attendance_id), 0), 2
    ) AS attendance_percentage,
    COUNT(DISTINCT CASE WHEN m.marks_obtained >= 90 THEN s.student_id END) AS excellent_students,
    ROUND(
        COUNT(DISTINCT CASE WHEN m.marks_obtained >= 90 THEN s.student_id END) * 100.0 / 
        NULLIF(COUNT(DISTINCT s.student_id), 0), 2
    ) AS excellent_percentage
FROM STUDENT s
LEFT JOIN MARKS m ON s.student_id = m.student_id
LEFT JOIN ATTENDANCE a ON s.student_id = a.student_id
GROUP BY s.gender
ORDER BY avg_marks DESC;

-- 9. Year-wise Performance Trend
-- Track student performance across different academic years
SELECT 
    s.year,
    COUNT(DISTINCT s.student_id) AS total_students,
    ROUND(AVG(m.marks_obtained), 2) AS avg_marks,
    ROUND(STDDEV(m.marks_obtained), 2) AS marks_stddev,
    MIN(m.marks_obtained) AS min_marks,
    MAX(m.marks_obtained) AS max_marks,
    ROUND(
        SUM(CASE WHEN a.status = 'Present' THEN 1 ELSE 0 END) * 100.0 / 
        NULLIF(COUNT(a.attendance_id), 0), 2
    ) AS attendance_percentage,
    COUNT(DISTINCT CASE WHEN m.marks_obtained >= 90 THEN s.student_id END) AS excellent_students,
    DENSE_RANK() OVER (ORDER BY AVG(m.marks_obtained) DESC) AS performance_rank
FROM STUDENT s
LEFT JOIN MARKS m ON s.student_id = m.student_id
LEFT JOIN ATTENDANCE a ON s.student_id = a.student_id
GROUP BY s.year
ORDER BY s.year;

-- 10. Comprehensive Student Dashboard
-- Create a holistic view of each student's academic profile
WITH StudentAttendance AS (
    SELECT 
        student_id,
        COUNT(*) AS total_days,
        SUM(CASE WHEN status = 'Present' THEN 1 ELSE 0 END) AS days_present,
        ROUND(SUM(CASE WHEN status = 'Present' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS attendance_pct
    FROM ATTENDANCE
    GROUP BY student_id
),
StudentMarks AS (
    SELECT 
        s.student_id,
        COUNT(DISTINCT e.exam_id) AS exams_taken,
        ROUND(AVG(m.marks_obtained), 2) AS avg_marks,
        MAX(m.marks_obtained) AS highest_mark,
        MIN(m.marks_obtained) AS lowest_mark
    FROM STUDENT s
    LEFT JOIN EXAM e ON s.student_id = e.student_id
    LEFT JOIN MARKS m ON e.exam_id = m.exam_id
    GROUP BY s.student_id
),
LibraryActivity AS (
    SELECT 
        student_id,
        COUNT(*) AS books_borrowed
    FROM LIBRARY_RECORDS
    GROUP BY student_id
)
SELECT 
    s.student_id,
    s.name,
    s.gender,
    s.year,
    s.email,
    s.phone,
    d.department_name,
    c.college_name,
    CASE 
        WHEN ug.student_id IS NOT NULL THEN 'Undergraduate'
        WHEN pg.student_id IS NOT NULL THEN 'Postgraduate'
        ELSE 'Unknown'
    END AS student_type,
    sm.exams_taken,
    sm.avg_marks,
    sm.highest_mark,
    sm.lowest_mark,
    sa.attendance_pct,
    la.books_borrowed,
    f.amount AS fees_amount,
    f.due_date AS fees_due_date,
    CASE
        WHEN sm.avg_marks >= 90 THEN 'A+'
        WHEN sm.avg_marks >= 80 THEN 'A'
        WHEN sm.avg_marks >= 70 THEN 'B+'
        WHEN sm.avg_marks >= 60 THEN 'B'
        WHEN sm.avg_marks >= 50 THEN 'C+'
        WHEN sm.avg_marks >= 40 THEN 'C'
        ELSE 'F'
    END AS grade,
    RANK() OVER (PARTITION BY d.department_id ORDER BY sm.avg_marks DESC) AS dept_rank,
    RANK() OVER (PARTITION BY c.college_id ORDER BY sm.avg_marks DESC) AS college_rank,
    RANK() OVER (ORDER BY sm.avg_marks DESC) AS overall_rank
FROM STUDENT s
LEFT JOIN UG_STUDENT ug ON s.student_id = ug.student_id
LEFT JOIN PG_STUDENT pg ON s.student_id = pg.student_id
JOIN DEPARTMENT d ON s.department_id = d.department_id
JOIN COLLEGE c ON s.college_id = c.college_id
LEFT JOIN StudentMarks sm ON s.student_id = sm.student_id
LEFT JOIN StudentAttendance sa ON s.student_id = sa.student_id
LEFT JOIN LibraryActivity la ON s.student_id = la.student_id
LEFT JOIN (
    SELECT student_id, MAX(amount) as amount, MAX(due_date) as due_date
    FROM FEES
    GROUP BY student_id
) f ON s.student_id = f.student_id
ORDER BY sm.avg_marks DESC NULLS LAST;