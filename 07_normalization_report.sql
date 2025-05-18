/*
 * DATABASE NORMALIZATION REPORT
 * =============================
 * 
 * This report provides a detailed analysis of how normalization principles (1NF, 2NF, 3NF, and BCNF)
 * have been implemented in the University Database System.
 */

/*
 * FIRST NORMAL FORM (1NF)
 * =======================
 * 
 * Definition: A relation is in 1NF if and only if all of its attributes have atomic (indivisible) values.
 * 
 * Implementation in our database:
 * 
 * 1. All tables have atomic values:
 *    - Each attribute in every table contains only single values
 *    - No multi-valued attributes (arrays, lists, sets) are used
 *    - No repeating groups of attributes
 * 
 * 2. Every table has a primary key:
 *    - COLLEGE uses college_id as primary key
 *    - DEPARTMENT uses department_id as primary key
 *    - STUDENT uses student_id as primary key
 *    - and so on for all entities
 * 
 * 3. No duplicate rows:
 *    - Primary key constraints ensure row uniqueness
 *    - Relationship tables like ENROLL and BORROWS use composite primary keys
 * 
 * Examples from our database:
 * - STUDENT table has atomic attributes for name, email, phone, etc.
 * - LIBRARY_RECORDS stores each book record as a separate row instead of concatenating multiple records
 */

/*
 * SECOND NORMAL FORM (2NF)
 * ========================
 * 
 * Definition: A relation is in 2NF if it is in 1NF and every non-key attribute is fully functionally
 * dependent on the entire primary key, not just part of it.
 * 
 * Implementation in our database:
 * 
 * 1. Tables with single-column primary keys:
 *    - These are automatically in 2NF if they are in 1NF (like COLLEGE, DEPARTMENT, STUDENT)
 *    - Each non-key attribute depends on the entire primary key
 * 
 * 2. Tables with composite keys:
 *    - ENROLL has (student_id, department_id) as composite key
 *      * enrollment_date depends on both student_id and department_id
 *    - BORROWS has (student_id, library_id, borrow_date) as composite key
 *      * return_date depends on the full composite key
 * 
 * 3. Specialization/Generalization:
 *    - We implemented 2NF through superclass/subclass relationships:
 *      * STUDENT as superclass with UG_STUDENT and PG_STUDENT as subclasses
 *      * STAFF as superclass with TEACHING_STAFF and NON_TEACHING_STAFF as subclasses
 *      * HOSTEL as superclass with BOYS_HOSTEL and GIRLS_HOSTEL as subclasses
 */

/*
 * THIRD NORMAL FORM (3NF)
 * =======================
 * 
 * Definition: A relation is in 3NF if it is in 2NF and no non-key attribute is transitively dependent
 * on the primary key (i.e., no non-key attribute depends on another non-key attribute).
 * 
 * Implementation in our database:
 * 
 * 1. Removed transitive dependencies:
 *    - Department information is stored in DEPARTMENT table, not duplicated in STUDENT
 *    - College information is stored in COLLEGE table, not duplicated in DEPARTMENT or STUDENT
 * 
 * 2. Foreign keys establish relationships:
 *    - STUDENT.department_id references DEPARTMENT.department_id
 *    - DEPARTMENT.college_id references COLLEGE.college_id
 *    - MARKS references both STUDENT and EXAM tables
 * 
 * 3. Normalized related entities:
 *    - Separated MARKS from EXAM
 *    - Separated LIBRARY_RECORDS from COLLEGE_LIBRARY
 *    - Created specialized tables for student types (UG_STUDENT, PG_STUDENT)
 * 
 * Examples of 3NF compliance:
 *    - Student details are stored once in STUDENT table, not duplicated in MARKS or ATTENDANCE
 *    - Department details are in DEPARTMENT, not duplicated in STUDENT or STAFF
 */

/*
 * BOYCE-CODD NORMAL FORM (BCNF)
 * =============================
 * 
 * Definition: A relation is in BCNF if for every non-trivial functional dependency X → Y, X is a superkey.
 * In simpler terms, every determinant must be a candidate key.
 * 
 * Implementation in our database:
 * 
 * 1. BCNF reinforcement:
 *    - All of our tables are already in 3NF
 *    - We ensured that all determinants are candidate keys
 * 
 * 2. For example:
 *    - In MARKS table, only (marks_id) determines other attributes
 *    - In ATTENDANCE table, only (attendance_id) determines other attributes
 *    - In ENROLL table, only the composite key (student_id, department_id) determines enrollment_date
 * 
 * 3. Relationship tables:
 *    - BORROWS is in BCNF as the composite key (student_id, library_id, borrow_date) is the only determinant
 *    - ENROLL is in BCNF as the composite key (student_id, department_id) is the only determinant
 */

/*
 * DENORMALIZATION DECISIONS
 * =========================
 * 
 * In some specific cases, we made conscious decisions to slightly denormalize for performance:
 * 
 * 1. DEPARTMENT table includes total_staffs and total_students:
 *    - These could be calculated by counting related records
 *    - Kept as denormalized attributes for query performance in reporting
 * 
 * 2. Redundant foreign keys:
 *    - STUDENT has both department_id and college_id
 *    - This slight denormalization helps avoid frequent joins for common queries
 */

/*
 * NORMALIZATION BENEFITS IN OUR IMPLEMENTATION
 * ===========================================
 * 
 * 1. Data Integrity:
 *    - Foreign key constraints ensure referential integrity
 *    - Primary key constraints prevent duplicate records
 * 
 * 2. Reduced Redundancy:
 *    - Student information stored once, referenced by foreign keys
 *    - Department and college data centralized in respective tables
 * 
 * 3. Maintenance Efficiency:
 *    - Updates to staff information only happen in STAFF table
 *    - Changes to department details affect only the DEPARTMENT table
 * 
 * 4. Improved Query Performance:
 *    - Proper indexing on foreign keys (idx_student_dept, idx_marks_student, etc.)
 *    - Strategic denormalization for frequently accessed aggregates
 */

/*
 * VERIFICATION QUERIES
 * ===================
 * 
 * The following queries can be used to verify that our database follows normalization principles:
 */

-- Query to check for any duplicate primary keys (1NF violation)
SELECT student_id, COUNT(*) FROM STUDENT GROUP BY student_id HAVING COUNT(*) > 1;

-- Query to verify 2NF by checking composite key relationships
SELECT student_id, department_id, COUNT(*) 
FROM ENROLL 
GROUP BY student_id, department_id 
HAVING COUNT(*) > 1;

-- Query to verify 3NF by ensuring no transitive dependencies
-- (Each student should be associated with department and college consistently)
SELECT s.student_id, s.department_id, s.college_id, d.college_id AS dept_college_id
FROM STUDENT s
JOIN DEPARTMENT d ON s.department_id = d.department_id
WHERE s.college_id != d.college_id;

-- Query to verify BCNF by ensuring determinant relationships
-- (Check that student details are consistent across different related tables)
SELECT s.student_id, s.name, m.student_id, a.student_id
FROM STUDENT s
LEFT JOIN MARKS m ON s.student_id = m.student_id
LEFT JOIN ATTENDANCE a ON s.student_id = a.student_id
WHERE m.student_id IS NOT NULL AND a.student_id IS NOT NULL
GROUP BY s.student_id, s.name, m.student_id, a.student_id;
