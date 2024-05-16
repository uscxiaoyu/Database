use purchase;

-- 1. 在select中使用case...when...

select if(1 < 0, '对', '错');

-- 示例1：查询各产品生产日期对应的星期。
select product_id, product_name, case weekday(Product_Date)
        when 0 then 'Monday'
        when 1 then 'Tuesday'
        when 2 then 'Wednesday'
        when 3 then 'Thursday'
        when 4 then 'Friday'
        when 5 then 'Saturday'
        else 'Sunday' end as week_day
from product
limit 10;

SELECT product_id, product_name, if(weekday(Product_Date) = 0,  'Monday',
						if(weekday(Product_Date) = 1, 'Tuesday',
							if(weekday(Product_Date) = 2, 'Wednesday',
								if(weekday(Product_Date) = 3, 'Thursday',
									if(weekday(Product_Date) = 4, 'Friday',
										if(weekday(Product_Date) = 5, 'Saturday', 'Sunday')))))) as week_day
FROM product
LIMIT 10;

-- 示例2: 查询产地为天津和北京的各类产品的数量和平均价格
select * from product limit 10;

-- 普通解法
select sort_id, count(*) 产品数量_天津, avg(price) 平均价格_天津
from product
where Product_Place = '天津'
group by sort_id;

select sort_id, count(*) 产品数量_北京, avg(price) 平均价格_北京
from product
where Product_Place = '北京'
group by sort_id;

select a.sort_id, a.sort_name,
       ifnull(b.产品数量_天津, 0) 产品数量_天津, b.平均价格_天津 平均价格_天津,
       ifnull(c.产品数量_北京, 0) 产品数量_北京, c.平均价格_北京 平均价格_北京
from sort a left outer join
        (select sort_id, count(*) 产品数量_天津, avg(price) 平均价格_天津
            from product
            where Product_Place = '天津'
            group by sort_id) b on a.sort_id = b.sort_id
    left join
        (select sort_id, count(*) 产品数量_北京, avg(price) 平均价格_北京
            from product
            where Product_Place = '北京'
            group by sort_id) c on a.sort_id = c.sort_id
order by a.sort_id;

-- 使用case when
select sort.sort_id, sort_name,
       sum(case when Product_Place = '天津' then 1 else 0 end) 产品数量_天津,
       avg(case when Product_Place = '天津' then price else null end) 平均价格_天津,
       sum(case when Product_Place = '北京' then 1 else 0 end) 产品数量_北京,
       avg(case when Product_Place = '北京' then price else null end) 平均价格_北京
from sort left join product on sort.sort_id = product.sort_id
group by sort_id
order by sort_id;

-- 使用if()
select sort.sort_id, sort_name,
       sum(if(Product_Place = '天津', 1, 0)) 产品数量_天津,
       avg(if(Product_Place = '天津', price, null)) 平均价格_天津,
       sum(if(Product_Place = '北京', 1, 0)) 产品数量_北京,
       avg(if(Product_Place = '北京', price, null)) 平均价格_北京
from sort left join product on sort.sort_id = product.sort_id
group by sort_id;
 
-- 示例3：查询各类别产品处于低价（价格小于100）、中价（价格介于100至2000之间）和高价（价格大于2000）区间的产品数量
select sort_id, count(case when price < 100 then 1 end) as 低价数量,
       count(case when price >= 100 and price <= 2000 then 1 end) as 中价数量,
       count(case when price > 2000 then 1 end) as 高价数量
from product
group by sort_id
order by Sort_ID;

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
