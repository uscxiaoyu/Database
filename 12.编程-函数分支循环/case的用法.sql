use student_system;

-- 1. 在select中使用case...when...

select if(1 < 0, '对', '错');

-- 示例1：在student表中查询学生出生在周几。
SELECT s_id, s_name, case weekday(birthday) 
		when 0 then 'Monday'
        when 1 then 'Tuesday'
        when 2 then 'Wednesday'
        when 3 then 'Thursday'
        when 4 then 'Friday'
        when 5 then 'Saturday'
        else 'Sunday' end as week_day
FROM student
LIMIT 10;

SELECT s_id, s_name, if(weekday(birthday) = 0,  'Monday', 
						if(weekday(birthday) = 1, 'Tuesday',
							if(weekday(birthday) = 2, 'Wednesday',
								if(weekday(birthday) = 3, 'Thursday',
									if(weekday(birthday) = 4, 'Friday',
										if(weekday(birthday) = 5, 'Saturday', 'Sunday')))))) as week_day
FROM student
LIMIT 10;

-- 示例2: 查询各门课程男生和女生的平均分
use mis;
select * from student limit 10;
select * from course limit 10; 
select * from takes limit 10;

-- 普通解法
SELECT c_id, c_name, avg(score) 男生平均分
from course natural join takes natural join student
where gender = '男'
group by c_id;

SELECT c_id, c_name, avg(score) 女生平均分
from course natural join takes natural join student
where gender = '女'
group by c_id;

select *
from (SELECT c_id, c_name, avg(score) 男生平均分
		from course natural join takes natural join student
	   where gender = '男'
	group by c_id) a 
natural join (SELECT c_id, c_name, avg(score) 女生平均分
		from course natural join takes natural join student
	   where gender = '女'
	group by c_id) b
order by c_id;


SELECT a.c_id, b.c_name, 男生平均分, 女生平均分
FROM 
(SELECT c_id from course) a
LEFT JOIN
(SELECT c_id, c_name, avg(score) 男生平均分
		from course natural join takes natural join student
	    where gender = '男'
		group by c_id) b
ON a.c_id = b.c_id
LEFT JOIN 
(SELECT c_id, c_name, avg(score) 女生平均分
		from course natural join takes natural join student
		where gender = '女'
		group by c_id) c
ON a.c_id = c.c_id
ORDER BY c_id;


-- 使用case when
SELECT c_id, c_name, avg(case gender when '男' then score else null end) 男生平均分,
	avg(case gender when '女' then score else null end) 女生平均分
from course natural join takes natural join student
group by c_id
order by c_id;

SELECT c_id, c_name, gender, case gender when '男' then score else null end 男生,
	case gender when '女' then score else null end 女生
from course natural join takes natural join student

-- 使用if()
SELECT c_id, c_name, avg(if(gender='男', score, null)) 男生平均分,
	avg(if(gender='女', score, null)) 女生平均分
from course natural join takes natural join student
group by c_id;
 
-- 示例3：查询各门课程优、良、中、及格、不及格、缺考（若没有分数，则视为缺考）的人数
select c_id, c_name, case when score >= 0 and score < 60 then '5-不及格'
						  when score >= 60 and score < 70 then '4-及格'
						  when score >= 70 and score < 80 then '3-中'
						  when score >= 80 and score < 90 then '2-良'
						  when score >= 90 and score <= 100 then '1-优'
						  else '6-缺考' end as 级别,
    count(s_id) 人数
from student natural join takes natural join course
group by c_id, 级别
order by c_id, 级别;

select c_id, c_name, case when score < 60 then '5-不及格'
						  when score < 70 then '4-及格'
						  when score < 80 then '3-中'
						  when score < 90 then '2-良'
						  when score <= 100 then '1-优'
						  else '6-缺考' end as 级别,
    count(s_id) 人数
from student natural join takes natural join course
group by c_id, 级别
order by c_id, 级别;

-- 2. 更新update
create table employee(emp_id int primary key auto_increment, 
	emp_name varchar(50) not null,
    salary decimal(7, 2));

truncate employee;
insert into employee(emp_name, salary)
values('Miles', 30000), ('Jack', 27000), ('Lucy', 22000), ('Mike', 29000);

-- 示例4: 完成下述更新 
/*
假设现在需要根据以下条件对该表的数据进行更新。
1. 对当前工资为30000以上的员工，降薪10%
2. 对当前工资为25000以上且不满28000的员工，加薪20%
*/

set autocommit = 0;
-- 条件1
update employee
set salary = 0.9*salary
where salary >= 30000;

commit;

select * from employee;
-- 条件2
update employee
set salary = 1.2*salary
where salary >= 25000 and salary < 28000;

-- 正确的方法
update employee
set salary = case when salary >= 30000 then 0.9*salary
				  when salary >= 25000 and salary < 28000 then 1.2*salary
				  else salary end;
