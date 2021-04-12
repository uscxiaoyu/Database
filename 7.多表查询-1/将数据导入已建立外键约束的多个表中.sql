--  附：如何将数据导入至已建立外键约束的多个表中？
create database temp;
use temp;

-- 建表
create table department (id int primary key, 
                         dept_name varchar(20));

create table employee (id int primary key, 
                       emp_name varchar(20), 
                       dept_id int,
						foreign key f_dept_id (dept_id) references department(id));

-- 方法1：明确表之间的参照关系，对于与其它表无参照关系的表可随时导入，对于参照了其它表的从表，
-- 则应先导入主表中的记录（注意，若从表中的外键列出现了主表被参照中没有的值，则外键约束不成功）。
insert into department(id, dept_name) 
values (100, '计算机科学系'), 
(200, '理论物理系');

insert into employee(id, emp_name, dept_id)
values (1, 'xiaoxia', 100), (2, 'tianxi', 200);

-- 方法2：先删除外键约束，导入数据这时候重新创建创建（注意，若表中数据不满足外键约束的限定，
-- 则外键约束创建不成功）。
delete from employee;
delete from department;

insert into employee(id, emp_name, dept_id)
values (1, 'xiaoxia', 100), (2, 'tianxi', 200); -- 不成功，因为有department中没有相应的100，200

-- 删除外键约束
alter table employee drop foreign key f_dept_id;

insert into employee(id, emp_name, dept_id)
values (1, 'xiaoxia', 100), (2, 'tianxi', 200); -- 成功执行

-- 添加外键约束
alter table employee 
add foreign key f_dept_id (dept_id) references department(id); -- 失败

insert into department(id, dept_name) 
values (100, '计算机科学系'), 
(200, '理论物理系');

-- 添加外键约束
alter table employee 
add foreign key f_dept_id (dept_id) references department(id);  -- 成功

-- 方法3（慎用）：设置外键约束失效`set foreign_key_checks=0`，
-- 导入数据之后再让其生效`set foreign_key_checks=1`
-- （注意，这种方式只对新导入的数据进行外键约束检查，
-- 即设置之前导入的从表的外键列的值可存在未出现在主表的值）
show variables like '%foreign_key%';

delete from employee;
delete from department;

insert into employee(id, emp_name, dept_id)
values (1, 'xiaoxia', 100), 
(2, 'tianxi', 200); -- 不成功，因为department中没有相应的100，200

-- 禁止当前连接的外键约束检验
set foreign_key_checks=0;

insert into employee(id, emp_name, dept_id)
values (1, 'xiaoxia', 100), 
(2, 'tianxi', 200); -- 成功执行，因为不执行外键约束检查

-- 启用当前连接的外键约束检验，
set foreign_key_checks=1;  -- 成功更新变量值, 不受之前插入的不满足外键约束的从表记录影响

insert into department(id, dept_name) 
values (100, '计算机科学系'), 
(200, '理论物理系');
