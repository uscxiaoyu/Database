-- 视图
USE purchase;

-- 创建视图
/*语法格式：
CREATE VIEW 视图名[(视图字段列表)]
AS
SELECT 语句*/

-- 1. 创建视图
-- 课堂示例1: 创建视图view_product
CREATE VIEW view_product
AS
SELECT * FROM product;

SELECT * FROM view_product LIMIT 10;

-- 2. 指定表中的某些字段构建视图
-- 课堂示例2：创建视图view_product2，包含product表中的product_id, product_name, product_place, subsort_id
CREATE VIEW view_product2
AS
SELECT product_id, product_name, product_place, subsort_id FROM product;

-- 3. 构建汇总视图
-- 课堂示例3：创建视图sum_product，包含product中product_place和各产地对应的产品数量
CREATE VIEW sum_product
AS
SELECT product_place, count(product_id) FROM product GROUP BY product_place;

SELECT * FROM sum_product;

-- 4. 在视图中重命名表中的字段

-- 课堂示例4: 创建视图sum_product，包含product中的product_place，各产地对应的产品数量，并命名为num_product
CREATE VIEW sum_product2(product_place, num_product)
AS
SELECT product_place, count(product_id) FROM product GROUP BY product_place;
-- 或者
CREATE VIEW sum_product3(product_place, num_product)
AS
SELECT product_place, count(product_id) AS num_product
FROM product GROUP BY product_place;

-- 5. 查询视图
/*视图和表一样，共用相同的查询语法:
SELECT * | 视图字段列表
FROM 视图名称
WHERE 条件表达式;
等价于在AS后查询结构的基础上再进行筛选
*/
-- 课堂示例5: 查看视图sum_product3中的所有记录
SELECT *
FROM sum_product3;

-- 等价于查看
SELECT *
FROM (SELECT product_place, count(product_id) AS num_product
FROM product GROUP BY product_place) AS A;

-- 6. 删除视图
/*语法:
DROP VIEW 视图名称;
*/
-- 课堂示例6: 删除视图sum_product3
DROP VIEW sum_product3;

-- 课堂练习1
-- (1) 完成课堂示例

-- (2) 创建view_member视图, 包含member表中的user_name, sex, email等字段
CREATE VIEW view_member
AS
SELECT user_name, sex, email
FROM member;

-- (3) 创建view_sort视图，包含sort表中的sort_id， 以及其对应的子类别的数量，并命名为num_subsort
CREATE VIEW view_sort
AS
SELECT sort.sort_id, count(subsort.subsort_id) AS num_subsort
FROM sort JOIN subsort ON sort.sort_id = subsort.sort_id
GROUP BY subsort.subsort_id;

-- 或
CREATE VIEW view_sort(sort_name,  num_subsort)
AS
SELECT sort.sort_name, count(subsort.subsort_id) AS num_subsort
FROM sort JOIN subsort ON sort.sort_id = subsort.sort_id
GROUP BY sort.sort_name;

-- (4) 在view_sort视图查询类别名称中有'办公'两个字的所有记录
SELECT *
FROM view_sort
WHERE sort_name LIKE '%办公%';
