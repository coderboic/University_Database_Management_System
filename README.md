# University Database Management System

## Project Overview
This project implements a comprehensive University Database Management System based on the Entity-Relationship diagram provided. The database is designed for Oracle LiveSQL and demonstrates various SQL concepts including normalization, queries, subqueries, joins, triggers, stored procedures, and advanced analytics. A frontend application has also been developed to interact with the database.

## Database Schema
The database schema follows normalization principles (up to 3NF) and includes the following main entities:
- College
- Department
- Student (with UG_STUDENT and PG_STUDENT as specializations)
- Faculty
- Staff (with TEACHING_STAFF and NON_TEACHING_STAFF as specializations)
- Exam and Marks
- Attendance
- Fees
- Hostel (with BOYS_HOSTEL and GIRLS_HOSTEL as specializations)
- Library

## Project Structure
- **Database Components**
  - `01_schema.sql`: Database schema creation script (DDL)
  - `02_sample_data.sql`: Sample data insertion script (DML)
  - `03_queries.sql`: Basic to intermediate SQL queries demonstrating various concepts
  - `04_stored_procedures.sql`: PL/SQL stored procedures and functions
  - `05_triggers.sql`: Database triggers for data integrity and business rules


## Featured SQL Concepts

### 1. Normalization
The database schema follows normalization principles up to Boyce-Codd Normal Form (BCNF):
- 1NF: All tables have primary keys and atomic values
- 2NF: No partial dependencies on primary keys
- 3NF: No transitive dependencies
- BCNF: Every determinant is a candidate key

See detailed analysis in `07_normalization_report.sql`.

### 2. Relationships
Various types of relationships are implemented:
- One-to-Many: College to Department, Department to Student, etc.
- Many-to-Many: Student to Library (via BORROWS relationship)
- Inheritance: Student to UG_STUDENT/PG_STUDENT, Staff to TEACHING_STAFF/NON_TEACHING_STAFF

### 3. SQL Query Concepts
- Basic SELECT queries with filtering (WHERE)
- JOIN operations (INNER, LEFT, RIGHT)
- Aggregation (GROUP BY, HAVING)
- Subqueries (correlated and non-correlated)
- Set operations (UNION, INTERSECT, MINUS)

### 4. Stored Procedures and Functions
The system includes various stored procedures and functions for:
- Student registration and management
- Attendance tracking and reporting
- Exam and marks management
- Department statistics and performance analysis
- Fee management and defaulter tracking

### 5. Triggers
Triggers are implemented for:
- Data validation and integrity
- Automatic updates to related tables
- Business rule enforcement
- Audit trails

## Setup and Usage

### Database Setup
1. Use an Oracle LiveSQL environment or Oracle Database installation
2. Run the scripts in numerical order (01_schema.sql first, then 02_sample_data.sql, etc.)

###  PL/SQL Concepts
- Stored Procedures
- Functions
- Exception Handling
- Transaction Management
- Cursors (implicit and explicit)

### Database Triggers
- Row-level triggers
- Statement-level triggers
- BEFORE and AFTER triggers
- Data validation and business rules enforcement


## Execution Instructions

### Oracle LiveSQL Execution

1. **Create Database Schema**
   - Copy the content of `01_schema.sql` into Oracle LiveSQL worksheet
   - Execute the script to create all tables and relationships

2. **Insert Sample Data**
   - Copy the content of `02_sample_data.sql` into the same worksheet (or a new one)
   - Execute to populate the database with sample data

3. **Run Queries**
   - Copy individual queries from `03_queries.sql` to explore the database
   - Execute each query to see results

4. **Create Stored Procedures**
   - Execute the code in `04_stored_procedures.sql` to create procedures and functions
   - Test procedures using the commented examples at the bottom of the file

5. **Create Triggers**
   - Execute the code in `05_triggers.sql` to create database triggers
   - Test by inserting or updating data to see trigger actions

### Important Notes
- Some features (like materialized views) might not work in Oracle LiveSQL
- For triggers and procedures, you may need to execute each CREATE statement separately
- The forward slash (/) after each PL/SQL block is important for proper execution

## Database Design Decisions

### Inheritance Implementation
We used separate tables with foreign key references to implement inheritance:
- STUDENT → UG_STUDENT/PG_STUDENT
- STAFF → TEACHING_STAFF/NON_TEACHING_STAFF
- HOSTEL → BOYS_HOSTEL/GIRLS_HOSTEL

### Junction Tables
Junction tables were created to handle many-to-many relationships:
- ENROLL (between STUDENT and DEPARTMENT)
- BORROWS (between STUDENT and LIBRARY)

### Indexes
Strategic indexes were created on foreign keys and commonly queried columns to improve performance.

## Future Enhancements
- Implement security through roles and privileges
- Add partitioning for large tables (like ATTENDANCE)
- Implement data archiving strategies
- Create a web interface for data entry and reporting
- Implement more advanced analytics using Oracle Analytics

## Conclusion
This University Database System demonstrates comprehensive database design and implementation using Oracle SQL and PL/SQL. It covers various aspects of database development including normalization, relationships, queries, stored procedures, triggers, and analytics.
