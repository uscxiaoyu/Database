-- 视图
USE purchase;
SET SQL_SAFE_UPDATES=0;
-- 创建视图
/*语法格式：
CREATE VIEW 视图名[(视图字段列表)]
AS
SELECT 语句*/

select current_user();

-- 一、创建与查询视图
/*语法：
CREATE [OR REPLACE] [ALGORITHM = {UNDEFINED | MERGE | TEMPTABLE}]
VIEW view_name [(column_list)]
AS SELECT查询语句
[WITH [CASCADE | LOCAL | CHECK OPTION] ];
*/

show tables;
-- 1.1 使用表中所有的字段
-- 示例1: 创建视图view_product
DROP VIEW VIEW_PRODUCT;

CREATE VIEW view_product
AS
SELECT * 
FROM product
WHERE sort_id = 11;

show tables;

-- 查看视图view_product的前10条记录
SELECT * 
FROM view_product
ORDER BY cast(Product_ID as unsigned)
limit 10;

-- 1.2 查看视图结构

-- 示例2：使用DESC[RIBE]查看视图view_product的结构
DESC view_product;
DESC product;

-- 示例3: 使用SHOW CREATE VIEW | TABLE查看view_product的定义
SHOW CREATE VIEW view_product;

-- 1.3 指定表中的某些字段构建视图
-- 示例4：创建视图view_product2，包含product表中的product_id, product_name, product_place, subsort_id
CREATE VIEW view_product2
AS
SELECT product_id, product_name, product_place, subsort_id
FROM product;

SELECT *
FROM view_product2
ORDER BY cast(Product_ID as unsigned)
LIMIT 10;

-- 1.4 结合GROUP BY构建汇总视图
-- 示例5：创建视图sum_product，包含product中product_place和各产地对应的产品数量
CREATE VIEW sum_product
AS
SELECT product_place, count(product_id)
FROM product
GROUP BY product_place;

desc sum_product;

SELECT product_place, `count(product_id)`
FROM sum_product;

SELECT product_place, `count(product_id)`
FROM sum_product; -- count(product_id)需要用反引号包括起来

-- 1.5 在视图中重命名表中的字段

-- 示例6: 创建视图sum_product，包含product中的product_place，各产地对应的产品数量，并命名为num_product
CREATE VIEW sum_product2(product_place, num_product)
AS
SELECT product_place, count(product_id)
FROM product GROUP BY product_place;

desc sum_product2;

SHOW CREATE VIEW sum_product2;

-- 或者
CREATE VIEW sum_product3
AS
SELECT product_place, count(product_id) AS num_product
FROM product GROUP BY product_place;

desc sum_product3;
SHOW CREATE VIEW sum_product3;

SELECT *
FROM sum_product3;

-- 1.6 查询视图
/*视图和表一样，共用相同的查询语法:
SELECT * | 视图字段列表
FROM 视图名称
WHERE 条件表达式;
等价于在AS后查询结构的基础上再进行筛选
*/
-- 示例7: 查看视图sum_product3中的所有记录
SELECT *
FROM sum_product3;

-- 等价于查看
SELECT *
FROM (SELECT product_place, count(product_id) AS num_product
     FROM product
     GROUP BY product_place) AS a; -- a 为衍生表

-- 1.7 在多表上建立视图
-- 示例8：创建视图view_sort_product，包含类别名称和对应的产品数量
CREATE OR REPLACE VIEW view_sort_product
AS
SELECT sort.sort_name, COUNT(product.product_id) AS 产品种类
FROM product JOIN sort ON product.sort_id = sort.sort_id
GROUP BY sort.sort_name;

SELECT *
FROM view_sort_product;

-- 二、修改(重新定义)视图结构
-- 2.1 利用CREATE OR REPLACE VIEW重新定义视图
-- 示例9：重新定义视图view_product，包含product_id, product_name, product_place, sort_id, subsort_id
CREATE OR REPLACE VIEW view_product4
AS
SELECT product_id, product_name, product_place, sort_id, subsort_id
FROM product;

SHOW TABLES;

-- 2.2 使用ALTER语句修改视图
/*语法：
ALTER [ALGORITHM = {UNIDIFIED | MERGE | TEMPTABLE}]
VIEW view_name [(column_list)]
AS SELECT查询语句
[WITH [CASCADE | LOCAL] CHECK OPTION];

注意：被修改的视图必须要存在
*/
-- 示例10: 修改视图结构view_product, 包含product_id, product_name, product_place
ALTER VIEW view_product
AS
SELECT product_id, product_name, product_place
FROM product;

SELECT *
FROM view_product
ORDER BY CAST(Product_ID AS unsigned);

-- 三、通过视图操作基本表的记录
-- 3.1 更新 UPDATE
-- 示例11：通过view_product把product_place为'国产'的产品记录的对应值更改'国产'
SELECT *
FROM product
WHERE product_place = '国产';

UPDATE view_product
SET product_place = '中国'
WHERE product_place = '国产';

SELECT *
FROM view_product
WHERE product_place='中国' LIMIT 10;

SELECT *
FROM product
WHERE product_place='中国' LIMIT 10;

-- 3.2 插入 INSERT
-- 示例12：通过view_product插入一条product_id = '12345', product_name='3d打印机', product_place='上海'
INSERT INTO view_product(product_id, product_name, product_place)
VALUES ('12345', '3d打印机', '上海');

SELECT *
FROM view_product
WHERE product_name='3d打印机';

SELECT *
FROM product
WHERE product_name='3d打印机';

-- 3.3 删除 DELETE
-- 示例13：通过view_product删除product_name为'3d打印机'的记录
DELETE FROM view_product
WHERE product_name = '3d打印机';

SELECT *
FROM view_product
WHERE product_name='3d打印机';

SELECT product_id, product_name, product_place
FROM product
WHERE product_name='3d打印机';

/*注意：
当视图包含以下结构时，更新操作不能执行：
（1）包含基本表中被定义为非空的列
（2）select语句后的字段列表中使用了数学表达式
（3）select语句后的字段列表中使用了聚合函数
（4）select语句使用了DISTINCT, UNION, TOP, GROUP BY 或 HAVING子句
*/
-- 四、删除视图
/*语法:
DROP VIEW 视图名称;
*/
-- 示例14: 删除视图view_product
DROP VIEW if exists view_product;

SHOW TABLES;

-- 补充1：`algorithm: merge | temptable`
-- 例如：对于`view_product`，如果指定为`merge`算法
CREATE ALGORITHM=MERGE VIEW view_product
AS
SELECT * FROM product
WHERE sort_id = 11;

-- 则对其查询会发生对应定义的替换。如果我们要在该视图上查询价格大于1000的产品，即
SELECT *
FROM view_product
WHERE Price > 1000;

-- 以上语句被替换为
SELECT * 
FROM product 
WHERE sort_id = 11 AND price > 1000;

-- 对于`view_product`，如果指定为`temptable`算法，则以上语句转换为
SELECT *
FROM (SELECT * 
     FROM view_product) a
WHERE price > 1000;  -- a 为衍生表，存在内存中


-- 补充2
-- with check option v.s. without check option
show variables like "%autoc%";  -- 事务自动提交选项，可控制是否将
set autocommit=0;

select *
from product
where Product_ID > 5500;

start transaction;

delete from product
where product_id > 5500;

# commit ;
rollback; -- 回滚到事务开始前的数据库状态，即删除product_id > 6000 的记录前

-- 创建视图view_product: sort_id为11
create or replace view view_product
as
select * from product where sort_id = 11;

start transaction;
insert into view_product(product_id, sort_id)
values (9999, 12); -- 即使sort_id为12也插入成果

select * from product where product_id = 9999; -- 在product表中可以查看到相关记录
select * from view_product where product_id = 9999; -- 在view_product表中不能查看，因为sort_id不为11
rollback; -- 回滚到事务开始前的数据库状态，即未插入(9999, 12)前

create or replace view view_product
as
select * from product where sort_id = 11
with check option; -- 默认为cascade选项

start transaction;
insert into view_product(product_id, sort_id)
values (9999, 12); -- 执行不成功
rollback;

-- local v.s cascaded
-- 基于基本表product构建视图view_product
create or replace view view_product
as
select * from product where sort_id = 11;
-- 基于视图view_product创建视图view_view_product, local check会检查当前视图中的条件
create or replace view view_view_product
as
select * from view_product where price > 1000
with local check option;

start transaction;

insert into view_view_product(product_id, price, sort_id)
values (9999, 2000, 12); -- 执行成功：虽然违背view_product的where条件sort_id = 11

insert into view_view_product(product_id, price, sort_id)
values (9998, 200, 11); -- 插入失败：price < 1000，不满足view_view_product的local check

select * from product where product_id = 9999; -- 有结果
select * from view_product where product_id = 9999; -- 无结果
select * from view_view_product where product_id = 9999;  -- 无结果

rollback;

--
create or replace view view_product
as
select * from product where sort_id = 11;

-- 设置cascade check option
create or replace view view_view_product
as
select * from view_product where price > 1000
with cascaded check option;

start transaction;
insert into view_view_product(product_id, price, sort_id)
values (9999, 10000, 12); -- 执行不成功，cascade选项级联检查view_product的条件
rollback;

-- 课堂练习
-- (1) 创建view_member视图, 包含member表中的user_name, sex, email等字段
CREATE VIEW view_member
AS
SELECT user_name, sex, email
FROM member;

-- 利用DESC查看view_member的结构
DESC view_member;

-- 利用SHOW CRAETE VIEW查看view_member的定义
SHOW CREATE VIEW view_member;

-- (2) 创建view_sort视图，包含sort表中的sort_name， 以及其对应的子类别的数量，并命名为num_subsort
CREATE VIEW view_sort
AS
SELECT sort.sort_name, count(subsort.subsort_id) AS num_subsort
FROM sort JOIN subsort ON sort.sort_id = subsort.sort_id
GROUP BY subsort.subsort_id;

-- 或
CREATE VIEW view_sort(sort_name, num_subsort)
AS
SELECT sort.sort_name, count(subsort.subsort_id) AS num_subsort
FROM sort JOIN subsort ON sort.sort_id = subsort.sort_id
GROUP BY sort.sort_name;

-- (3) 在view_sort视图查询类别名称中有'办公'两个字的所有记录
SELECT *
FROM view_sort
WHERE sort_name LIKE '%办公%';

-- (4) 利用CREATE OR REPLACE VIEW创建view_member视图, 包含member表中的user_name, true_name, sex, email等字段
CREATE OR REPLACE VIEW view_member
AS
SELECT user_name, true_name, sex, email
FROM member;

-- 利用ALTER VIEW修改视图view_member，使其包含member表中的user_name, true_name, sex, email, address, phone等字段
ALTER VIEW view_member
AS
SELECT user_name, true_name, sex, email, address, phone
FROM member;

-- (5) 通过view_memeber更新user_name为'饿狼'的记录的true_name为'Mandy'
SELECT * FROM view_member WHERE user_name = '饿狼';

UPDATE view_member
SET true_name = 'Mandy'
WHERE user_name = '饿狼';

SELECT * FROM view_member WHERE user_name = '饿狼';
SELECT * FROM member WHERE user_name = '饿狼';

-- (6) 通过view_memeber插入一条记录，user_name为'风清扬', true_name为'张三丰', sex为'女'
INSERT INTO view_member(user_name, true_name, sex)
VALUES ('风清扬', '张三丰', '女');

SELECT * FROM view_member WHERE user_name = '风清扬';
SELECT * FROM member WHERE user_name = '风清扬';

-- (7) 通过view_memeber删除user_name为'风清扬'的记录
DELETE FROM view_member
WHERE user_name = '风清扬';

-- (8) 删除视图view_memeber
DROP VIEW IF EXISTS view_member;
