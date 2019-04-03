create database temple;

use temple;

CREATE TABLE course (
    course_id VARCHAR(7) PRIMARY KEY,
    title VARCHAR(50),
    dept_name VARCHAR(20),
    credits DECIMAL(2 , 0 )
);

CREATE TABLE prereq (
    course_id VARCHAR(7) PRIMARY KEY,
    prereq_id VARCHAR(7)
);

insert into course values('BIO-301', 'Genetics', 'Biology', 4);
insert into course values('CS-190', 'Game Design', 'Comp. Sci.', 4);
insert into course values('CS-315', 'Robotics', 'Comp. Sci.', 3);

SELECT 
    *
FROM
    course;

insert into prereq values('BIO-301', 'BIO-101');
insert into prereq values('CS-190', 'CS-101');
insert into prereq values('CS-347', 'CS-101');

SELECT 
    *
FROM
    prereq;

-- 1. 笛卡尔积: table_a, table_b
SELECT 
    *
FROM
    course,
    prereq;
SELECT 
    *
FROM
    course,
    prereq
WHERE
    course.course_id = prereq.course_id;

-- 2. 自然连接: table_a natural join table_b
SELECT 
    *
FROM
    course
        NATURAL JOIN
    prereq;

-- 3. 内连接: table_a [inner] join table_b
SELECT 
    *
FROM
    course
        INNER JOIN
    prereq;-- 等价于笛卡尔积
SELECT 
    *
FROM
    course
        JOIN
    prereq;
SELECT 
    *
FROM
    course
        INNER JOIN
    prereq ON course.course_id = prereq.course_id;
SELECT 
    *
FROM
    course
        JOIN
    prereq ON course.course_id = prereq.course_id;
select * from course natural inner join prereq; -- 错误语法


-- 4. 左连接: left join
SELECT * from course left join prereq;-- 错误语法

SELECT 
    *
FROM
    course
        LEFT JOIN
    prereq ON course.course_id = prereq.course_id;
SELECT 
    *
FROM
    course
        LEFT OUTER JOIN
    prereq ON course.course_id = prereq.course_id;
SELECT 
    *
FROM
    course
        NATURAL LEFT JOIN
    prereq;
SELECT 
    *
FROM
    course
        NATURAL LEFT OUTER JOIN
    prereq;
select * from course natural left join prereq using(course_id); -- 错误语法
select * from course natural left join prereq on course.course_id=prereq.course_id;-- 错误语法

SELECT 
    *
FROM
    course
        RIGHT JOIN
    prereq ON course.course_id = prereq.course_id;
SELECT 
    *
FROM
    course
        RIGHT OUTER JOIN
    prereq ON course.course_id = prereq.course_id;
SELECT 
    *
FROM
    course
        NATURAL RIGHT JOIN
    prereq;
SELECT 
    *
FROM
    course
        NATURAL RIGHT OUTER JOIN
    prereq;

-- 6. 全连接: full join
SELECT 
    *
FROM
    course full
        JOIN
    prereq;-- 等价于笛卡尔积结果
SELECT 
    *
FROM
    course full
        JOIN
    prereq ON course.course_id = prereq.course_id; -- 错误语法
select * from course full outer join prereq;-- 错误语法
SELECT 
    *
FROM
    course full
        JOIN
    prereq USING (course_id);
