 use university;
 
 CREATE VIEW faculty AS
    SELECT 
        ID, name, dept_name
    FROM
        instructor;

SELECT 
    *
FROM
    faculty;

SELECT 
    name
FROM
    faculty
WHERE
    dept_name = 'Biology';

SELECT 
    *
FROM
    instructor;

-- 重新定义视图的列名
CREATE VIEW departments_total_salary (dept_name , total_salary) AS
    SELECT 
        dept_name, SUM(salary)
    FROM
        instructor
    GROUP BY dept_name;
    
SELECT 
    *
FROM
    departments_total_salary;

-- 创建2009年秋季体育系开设的课程
CREATE VIEW physics_fall_2009 AS
    SELECT 
        course.course_id, sec_id, building, room_number
    FROM
        course,
        section
    WHERE
        course.course_id = section.course_id
            AND course.dept_name = 'Physics'
            AND section.semester = 'Fall'
            AND section.year = '2009';
    
SELECT 
    *
FROM
    physics_fall_2009;

CREATE VIEW physics_fall_2009_watson AS
    SELECT 
        course_id, room_number
    FROM
        physics_fall_2009
    WHERE
        building = 'Watson';
    
-- 视图更新
insert into faculty values ('30765', 'Green', 'Music');
SELECT 
    *
FROM
    faculty;
SELECT 
    *
FROM
    instructor;

-- 一些视图不能追溯到一张表
CREATE VIEW instructor_info AS
    SELECT 
        ID, name, building
    FROM
        instructor,
        department
    WHERE
        instructor.dept_name = department.dept_name;
    
CREATE VIEW history_instructors AS
    SELECT 
        *
    FROM
        instructor
    WHERE
        dept_name = 'History';
    
insert into history_instructors values ('25566', 'Brown', 'Biology', 100000);

-- 创建表
CREATE TABLE r_course LIKE course;-- 创建一个与course有相同结构的新表r_course

CREATE TABLE r_prereq AS (SELECT * FROM
    prereq);-- 与view类似，创建一个r_prereq的新表
    
SELECT 
    *
FROM
    r_prereq;
