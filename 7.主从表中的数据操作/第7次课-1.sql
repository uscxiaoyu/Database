-- 案例
CREATE DATABASE temp;
USE temp;

-- 1. 建立外键联系
/* 建立外键约束语法
ALTER TABLE 表名 ADD CONSTRAINT [外键名] FOREIGN KEY(外键字段名) REFERENCES 外表表名(主键字段名);
注意：(1)建立外键的表必须是InnoDB型的表，不能是临时表。因为MySQL中只有InnoDB型的表才支持外键。
(2)定义外键名时，不能加引号。如：constraint 'FK_ID' 或 constraint " FK_ID "都是错误的。
*/

-- 示例1: 创建`student`表，并构建与`grade`表之间的联系
CREATE DATABASE temp;
USE temp;

CREATE TABLE grade(
    id INT PRIMARY KEY,
    gname VARCHAR(20) NOT NULL
);

CREATE TABLE student(
    sid INT PRIMARY KEY,
    sname VARCHAR(36),
    gid INT NOT NULL,
    CONSTRAINT fk_gid FOREIGN KEY (gid) REFERENCES grade(id));

/* 建立外键的完整格式
ALTER TABLE 表名 ADD CONSTRAINT [外键名] FOREIGN KEY(外键字段名) REFERENCES 外表表名(主键字段名)
[ON DELETE {CASCADE | SET NULL | NO ACTION | RESTRICT}]
[ON UPDATE {CASCADE | SET NULL | NO ACTION | RESTRICT}]

注意：（1）CASCADE: 主表中删除或更新对应的记录时，同时自动地删除或更新从表中匹配的记录。
(2) SET NULL: 主表中删除或更新被参照列记录时，同时将从表中的外键列设为空。
(3) NO ACTION: 拒绝删除或者更新主表被参照列记录，从表也不进行任何操作。
(4) RESTRICT: 拒绝删除或者更新主表被参照列记录。
*/

-- 示例2：删除`student`表的`gid`上的外键约束
/* 基本语法：
ALTER TABLE 表名
DROP FOREIGN KEY 约束名称;
*/

ALTER TABLE student
DROP FOREIGN KEY fk_gid;

SHOW CREATE TABLE student;

-- 练习1
set sql_safe_updates=0;
use purchase;
-- (1) 构建`product`表的主键为`product_id`, `sort`表的主键为`sort_id`, `subsort`表的主键为`subsort_id`
alter table product add primary key (product_id); 
alter table sort add primary key (sort_id);
alter table subsort add primary key (subsort_id);

select *
from product
where product_id is null;

select *
from product
where product_id in (select product_id
    from product
    group by Product_ID
    having count(*) > 1);

delete from product 
where product_id is null;

-- (2) 构建`product`表与`sort`表之间的外键约束`fk_sortid1`，外键为`sort_id`
select product_id, sort_id
from product
where sort_id not in (select sort_id from sort);

insert into sort
set sort_id=95, Sort_name='xx';

alter table product 
add constraint fk_sortid1 foreign key (sort_id) references sort(sort_id);

-- (3) 构建`subsort`表与`sort`表之间的外键约束`fk_sortid2`，外键为`subsort_id`，并设置为`on delete cascade`。
select SubSort_ID, sort_id
from subsort
where sort_id not in (select sort_id from sort);

alter table subsort 
add constraint fk_sortid2 foreign key (sort_id) references sort(sort_id);

-- (4) 构建`product`表与`subsort`表之间的外键约束`fk_subsortid`，外键为`subsort_id` 
show variables like "%foreign%"; -- 如果值为ON，则开启外键约束检查

select distinct subsort_id 
from product 
where subsort_id not in (select distinct subsort_id from subsort);

-- 方法1：在出表中插入记录
insert into subsort(subsort_id, subsort_name, sort_id)
values (9501, 'xxxx', 95);

-- 方法2：删除从表中的记录
DELETE FROM product
WHERE subsort_id = 9501;  -- 删除对应记录

alter table product 
add constraint fk_subsortid foreign key (subsort_id) references subsort(subsort_id);

-- 2. 操作关联表

-- 课堂示例3：使用关联关系查询数据-查询根类别为“办公机器设备”的产品
-- 方法1: 朴素方法
SELECT sort_id 
FROM sort 
WHERE sort_name='办公机器设备';

SELECT * 
FROM product 
WHERE sort_id=11;

-- 方法2: 使用变量保存结果
SELECT sort_id INTO @a FROM sort WHERE sort_name='办公机器设备';
SELECT * FROM product WHERE sort_id=@a;

-- 方法3：使用子查询
SELECT * 
FROM product 
WHERE sort_id IN (SELECT sort_id 
	FROM sort 
    WHERE sort_name='办公机器设备');

-- 方法4：使用连接查询
select * from product limit 10;

SELECT p.*
FROM product p JOIN sort s ON p.sort_id = s.sort_id
WHERE s.sort_name = '办公机器设备';

-- 课堂示例4：为关联表添加数据
-- 在从表中插入主表中没有的值99，提示1452错误，违反外键约束
INSERT INTO product(sort_id) VALUES(99);

SELECT * FROM sort;
-- 为主表新添加sort_id为99的记录，然后再次往从表中插入该记录
INSERT INTO sort(sort_id, sort_name) VALUES (99, '其它类别');
INSERT INTO product(sort_id) VALUES(99);

SELECT *
FROM product
WHERE sort_id = '99';

-- 课堂示例5：为关联表删除数据
-- (1) 删除从表中的sort_id为14的对应记录
-- 直接删除，提示1451错误, 因为product表中有sort_id参照sort中的sort_id，且subsort表也参照了sort表
DELETE FROM sort
WHERE sort_id = 14;

SELECT *
FROM product
WHERE sort_id = 14;

-- 首先删除product表和subsort表中有sort_id为14的记录
DELETE FROM product
WHERE sort_id = 14;

DELETE FROM subsort
WHERE sort_id = 14;

-- 然后，删除主表中的sort_id为14的记录
DELETE FROM sort
WHERE sort_id = 14;

-- (2) 设置从表中参照列对应值为null
SELECT *
FROM product
WHERE sort_id = 99;

UPDATE product
SET sort_id = NULL
WHERE sort_id = 99;

UPDATE subsort
SET sort_id = NULL
WHERE sort_id = 99;

DELETE FROM sort
WHERE sort_id = 99;

-- (3) 重新设置外键的删除级联类型
ALTER TABLE product
DROP FOREIGN KEY fk_sortid1;

ALTER TABLE product
ADD CONSTRAINT fk_sortid1 FOREIGN KEY (sort_id) REFERENCES sort (sort_id) ON DELETE CASCADE;

ALTER TABLE subsort
DROP FOREIGN KEY fk_sortid2;

ALTER TABLE subsort
ADD CONSTRAINT fk_sortid2 FOREIGN KEY (sort_id) REFERENCES sort (sort_id) ON DELETE CASCADE;
select *
from product
where sort_id = 64;

DELETE FROM sort
WHERE sort_id = 64;

SELECT * FROM product WHERE sort_id = 64;

-- 课堂练习2
-- （5）向subsort表添加如下表的记录。
SELECT *
FROM sort ORDER BY sort_id DESC;

INSERT INTO sort (sort_id)
VALUES (97), (98), (99); -- 先在主表中添加对应的sort_id值

INSERT INTO subsort(subsort_id, sort_id)
VALUES (9701, 97), (9702, 97), (9801, 98), (9802, 98), (9901, 99), (9902, 99);

-- （6）按照课堂示例5的三种方式逐次删除在sort表中的sort_id为97、98、99的记录。
-- 1) 97  删除从表中的对应记录
DELETE FROM subsort
WHERE sort_id = 97;

DELETE FROM sort
WHERE sort_id = 97;

-- 2) 98  设置从表中参照列对应值为null
UPDATE subsort
SET sort_id = NULL
WHERE sort_id = 98;

DELETE FROM sort
WHERE sort_id = 98;

-- 3) 99  重新设置外键的删除级联类型
ALTER TABLE subsort
DROP FOREIGN KEY fk_sortid2;

ALTER TABLE subsort
ADD CONSTRAINT fk_sortid2 FOREIGN KEY (sort_id) REFERENCES sort (sort_id)
ON UPDATE CASCADE
ON DELETE CASCADE;

DELETE FROM sort
WHERE sort_id = 99;

SELECT *
FROM sort ORDER BY sort_id DESC;
