-- 案例
CREATE DATABASE chapter05;
USE chapter05;

CREATE TABLE grade(
    id INT(4) NOT NULL PRIMARY KEY,
    name VARCHAR(36)
);

-- 1. 建立外键联系
/* 建立外键约束语法
ALTER TABLE 表名 ADD CONSTRAINT [外键名] FOREIGN KEY(外键字段名) REFERENCES 外表表名(主键字段名);
注意：(1)建立外键的表必须是InnoDB型的表，不能是临时表。因为MySQL中只有InnoDB型的表才支持外键。
(2)定义外键名时，不能加引号。如：constraint 'FK_ID' 或 constraint " FK_ID "都是错误的。
*/

CREATE TABLE student(
    sid INT(4) NOT NULL PRIMARY KEY,
    sname VARCHAR(36),
    gid INT(4) NOT NULL,
    CONSTRAINT FOREIGN KEY (gid) REFERENCES grade(id));

-- 示例1: 为product表的sort_id添加外键约束
USE purchase;

-- 首先，被引用的主表字段应为主键，因此需为sort表的Sort_ID字段添加主键约束，否则建立外键时会提示1215错误
ALTER TABLE sort
MODIFY sort_id CHAR(2) PRIMARY KEY;
-- 然后，为表product的Sort_ID字段添加外键约束
ALTER TABLE product
ADD CONSTRAINT fk_sortid FOREIGN KEY (sort_id) REFERENCES sort(sort_id);
-- 使用show create table 来查看表的构建语句
SHOW CREATE TABLE product;

/* 建立外键的完整格式
ALTER TABLE 表名 ADD CONSTRAINT [外键名] FOREIGN KEY(外键字段名) REFERENCES 外表表名(主键字段名)
[ON DELETE {CASCADE | SET NULL | NO ACTION | RESTRICT}]
[ON UPDATE {CASCADE | SET NULL | NO ACTION | RESTRICT}]

注意：（1）CASCADE: 主表中删除或更新对应的记录时，同时自动地删除或更新从表中匹配的记录。
(2) SET NULL: 主表中删除或更新被参照列记录时，同时将从表中的外键列设为空。
(3) NO ACTION: 拒绝删除或者更新主表被参照列记录，从表也不进行任何操作。
(4) RESTRICT: 拒绝删除或者更新主表被参照列记录。
*/

-- 示例2：删除product表的sort_id上的外键约束
/* 基本语法：
ALTER TABLE 表名
DROP FOREIGN KEY 约束名称;
*/

ALTER TABLE product
DROP FOREIGN KEY fk_sortid;

SHOW CREATE TABLE product;

-- 练习1
-- (2) 再为product表添加Sort_ID的外键约束FK_sortid1
ALTER TABLE product
ADD CONSTRAINT fk_sortid1 Foreign key (sort_id) references sort(sort_id)
ON UPDATE RESTRICT ON DELETE RESTRICT;

-- (3) 使用语句为subsort表的Sort_ID添加引用自sort表外键名为FK_sortid2的外键约束，并设置为on delete cascade参数。
ALTER TABLE subsort
ADD CONSTRAINT fk_sortid2 FOREIGN KEY (sort_id) REFERENCES sort(sort_id)
ON DELETE CASCADE;

-- (4) 为product表添加Subsot_id的引用自subsort表的外键约束FK_subsortid。（注意：主表被引用的列应具有主键约束或唯一性约束。）
ALTER TABLE subsort
MODIFY subsort_id CHAR(5) PRIMARY KEY;

-- 查看product表中subsort_id列是否有subsort表中subsort_id列未包含的值
SELECT DISTINCT subsort_id
FROM product
WHERE subsort_id NOT IN (SELECT DISTINCT subsort_id FROM subsort);

-- 若product表中subsort_id列有subsort表中subsort_id列未包含的值，则进行以下操作:
SET SQL_SAFE_UPDATES=0;

DELETE FROM product
WHERE subsort_id = 3317 OR subsort_id = 6412;  -- 删除对应记录

DELETE FROM product
WHERE subsort_id IS NULL;

-- 最后，才能建立外键联系
ALTER TABLE product
ADD CONSTRAINT fk_subsortid FOREIGN KEY (subsort_id) REFERENCES subsort(subsort_id)
ON DELETE CASCADE ON UPDATE CASCADE;

-- (5) 删除product表中的Subsort_ID的外键约束。
ALTER TABLE product
DROP FOREIGN KEY fk_subsortid;

-- 2. 操作关联表

-- 课堂示例3：为关联表添加数据
-- 在从表中插入主表中没有的值99，提示1452错误，违反外键约束
INSERT INTO product(sort_id) VALUES(99);

SELECT * FROM sort;
-- 为主表新添加sort_id为99的记录，然后再次往从表中插入该记录
INSERT INTO sort(sort_id, sort_name) VALUES (99, '其它类别');
INSERT INTO product(sort_id) VALUES(99);

SELECT *
FROM product
WHERE sort_id = '99';

-- 课堂示例4：使用关联关系查询数据-查询根类别为“办公机器设备”的产品
SELECT sort_id FROM sort WHERE sort_name='办公机器设备';
SELECT * FROM product WHERE sort_id=11;

-- 或者使用子查询
SELECT * FROM product WHERE sort_id IN (SELECT sort_id FROM sort WHERE sort_name='办公机器设备');

-- 或者使用变量保存结果
SELECT sort_id INTO @a FROM sort WHERE sort_name='办公机器设备';
SELECT * FROM product WHERE sort_id=@a;

-- 课堂示例5：为关联表删除数据
-- (1) 删除从表中的sort_id为14的对应记录
-- 直接删除，提示1451错误, 因为product表中有sort_id参照sort中的sort_id
DELETE FROM sort
WHERE sort_id = 14;

SELECT *
FROM product
WHERE sort_id = 14;

-- 首先删除product表中有sort_id为14的记录
DELETE FROM product
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

DELETE FROM sort
WHERE sort_id = 99;

-- (3) 重新设置外键的删除级联类型
ALTER TABLE product
DROP FOREIGN KEY fk_sortid1;

ALTER TABLE product
ADD CONSTRAINT fk_sortid1 FOREIGN KEY (sort_id) REFERENCES sort (sort_id) ON DELETE CASCADE;

select *
from product
where sort_id = 64;

DELETE FROM sort
WHERE sort_id = 64;

SELECT * FROM product WHERE sort_id = 64;

-- 课堂练习2
-- （2）课堂练习1中已为subsort表与sort表添加关联关系（建立外键），修改该外键的参数说明均为RESTRICT。
-- 查看sort表中sort_id是否为主键
SHOW CREATE TABLE sort;
-- 如果不为主键，则修改表结构，设置为主键
ALTER TABLE sort
MODIFY sort_id CHAR(2) PRIMARY KEY;

ALTER TABLE subsort
DROP FOREIGN KEY fk_sortid2;

ALTER TABLE subsort
ADD CONSTRAINT fk_sortid2 FOREIGN KEY (sort_id) REFERENCES sort (sort_id)
ON UPDATE RESTRICT
ON DELETE RESTRICT;
-- （3）向subsort表添加如下表的记录。
SELECT *
FROM sort ORDER BY sort_id DESC;

INSERT INTO sort (sort_id)
VALUES (97), (98), (99); -- 先在主表中添加对应的sort_id值

INSERT INTO subsort(subsort_id, sort_id)
VALUES (9701, 97), (9702, 97), (9801, 98), (9802, 98), (9901, 99), (9902, 99);

-- （4）按照课堂示例5的三种方式逐次删除在sort表中的sort_id为97、98、99的记录。
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
