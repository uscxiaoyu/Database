create database temple;

use temple;

create table course(course_id varchar(7) primary key,
                    title varchar(50),
                    dept_name varchar(20),
                    credits decimal(2,0));

create table prereq(course_id varchar(7) primary key,
                    prereq_id varchar(7));

insert into course values('BIO-301', 'Genetics', 'Biology', 4);
insert into course values('CS-190', 'Game Design', 'Comp. Sci.', 4);
insert into course values('CS-315', 'Robotics', 'Comp. Sci.', 3);

select * from course;

insert into prereq values('BIO-301', 'BIO-101');
insert into prereq values('CS-190', 'CS-101');
insert into prereq values('CS-347', 'CS-101');

select * from prereq;

-- 1. 笛卡尔积: table_a, table_b
select * from course, prereq;
select * from course, prereq where course.course_id=prereq.course_id;

-- 2. 自然连接: table_a natural join table_b
select * from course natural join prereq;

-- 3. 内连接: table_a [inner] join table_b
select * from course inner join prereq; -- 等价于笛卡尔积
select * from course join prereq;
select * from course inner join prereq on course.course_id=prereq.course_id;
select * from course join prereq on course.course_id=prereq.course_id;
select * from course natural inner join prereq; -- 错误语法


-- 4. 左连接: left join
select * from course left join prereq; -- 错误语法
select * from course left join prereq on course.course_id=prereq.course_id;
select * from course left outer join prereq on course.course_id=prereq.course_id;
select * from course natural left join prereq;
select * from course natural left outer join prereq;
select * from course natural left join prereq using(course_id); -- 错误语法
select * from course natural left join prereq on course.course_id=prereq.course_id; -- 错误语法

-- 5. 右连接: right join
select * from course right join prereq on course.course_id=prereq.course_id;
select * from course right outer join prereq on course.course_id=prereq.course_id;
select * from course natural right join prereq;
select * from course natural right outer join prereq;

-- 6. 全连接: full join
select * from course full join prereq; -- 等价于笛卡尔积结果
select * from course full join prereq on course.course_id=prereq.course_id; -- 错误语法
select * from course full outer join prereq; -- 错误语法
select * from course full join prereq using(course_id);
