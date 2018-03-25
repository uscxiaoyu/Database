-- 第5次课，单表查询
use purchase;

-- 1. 语法结构
/*列出特定字段名对应数据的语法格式如下:
SELECT 字段名1, 字段名2, ..., 字段名n FROM 表名; */

-- 课堂示例1: 通过列出所有字段名查询product表的数据
SELECT product_id, product_name, product_code, product_place,
	product_date, price, unit, detail, subsort_id, sort_id
FROM product;

-- 课堂示例2：通过*查询product表的所有数据
SELECT * 
FROM product;

-- 课堂示例3：查询指定字段对应的数据
SELECT product_id, product_name, price
FROM product;

-- 课堂练习1：
-- 查询member表中的所有数据 
SHOW COLUMNS FROM member;

SELECT user_name, user_password, true_name, sex, phone, mobile, email, address, attribute
FROM member;

SELECT *
FROM member;

-- 查询指定字段对应的数据
SELECT user_name, address, email
FROM member;

-- 2. 按条件查询(where子句)

-- 2.1 带关系运算符的查询：对数据筛选过滤
/* 语法格式:
SELECT 字段名1, 字段名2, ...
FROM 表名
WHERE 条件表达式; 

常见的关系运算符号：=、<>、！=、<、<=、>、>=
*/

-- 课堂示例4：查询product表中Product_Place为“天津”的产品信息
SELECT * 
FROM product 
WHERE product_place = '天津';

-- 课堂示例5：使用SELECT语句查询Product_Name为“京瓷KM-4030复印机”的商品价格
SELECT price 
FROM product 
WHERE product_name = '京瓷KM-4030复印机';

-- 课堂示例6：查询Product表中Price 大于1000的商品代码和名称
SELECT product_id, product_name
FROM product
WHERE price >= 1000;

-- 2.2 带in关键字的查询：限定结果在某一集合中
/* 语法格式
SELECT *|字段名1,字段名2,……
FROM 表名
WHERE 字段名 [NOT] IN (元素1,元素2,……) */

-- 课堂示例7：查找product表中产地为天津，北京和日本的商品的全部信息
SELECT *
FROM product
WHERE product_place IN ('天津', '北京', '日本');

-- 补充：查找product表中产地不为天津，北京和日本的商品的全部信息
SELECT *
FROM product
WHERE product_place NOT IN ('天津', '北京', '日本');

-- 2.3 带BETWEEN ... AND关键字的查询：限定结果在指定范围
/* 语法格式
SELECT *|{字段名1,字段名2,……}
FROM 表名 WHERE 字段名 [NOT] BETWEEN 值1 AND 值2; */
 
-- 课堂示例8：查询prodct表中Price值在200和500之间的商品信息
SELECT *
FROM product
WHERE price BETWEEN 200 AND 500;

-- 课堂示例9：查询product表中Price值不在200和500之间的商品信息
SELECT *
FROM product
WHERE price NOT BETWEEN 200 AND 500;

-- 2.4 空值查询：判断某些列值是否为NULL
/* 语法结构：
SELECT *|字段名1,字段名2,……
FROM 表名
WHERE 字段名IS [NOT] NULL; */

-- 课堂示例10：查询product表中Product_Place为空值的商品名称和价格
SELECT product_name, price
FROM product
WHERE product_place IS NULL;

-- 课堂示例11：查询product表中Product_Place不为空值的记录
SELECT product_name, price
FROM product
WHERE product_place IS NOT NULL;

-- 2.5 字段前带DISTINCT关键字的查询：去重复
/* 语法格式
SELECT DISTINCT 字段名 
FROM 表名
[WHERE 条件表达式];
*/

-- 课堂示例12：查询product表中Product_Place字段的值，查询记录不能重复
SELECT DISTINCT product_place
FROM product;

-- DISTINCT关键字作用于多个字段：向量比较，只有DISTINCT关键字后指定的多个字段值都相同，才会被认作是重复记录。
-- 课堂示例13：找出product表中不同的根类别和子类别的组合
SELECT DISTINCT sort_id, subsort_id
FROM product;

-- 2.6 带LIKE关键字的查询—判断两个字符串是否相匹配
/*
SELECT *|{字段名1,字段名2,……}
FROM 表名
WHERE 字段名 [NOT] LIKE '匹配字符串';

LIKE语法格式中的“匹配字符串”指定用来匹配的字符串，其值可以是一个普通字符串，也可以是包含百分号(%)和下划线(_)等通配字符串;
(1) %: 可以匹配任意长度的字符串，包括空字符串
(2) _: 下划线通配符只匹配单个字符，如果要匹配多个字符，需要使用多个下划线通配符
*/

-- 课堂示例14：查找product表中商品名称含有复印机的商品名称，价格和产地
SELECT product_name, price, product_place
FROM product
WHERE product_name LIKE '%复印机%';

SELECT product_id, product_name, price, product_place
FROM product
WHERE product_name LIKE '______复印机';

/* 注意：
百分号和下划线是通配符，它们在通配字符串中有特殊含义，因此，如果要匹配字符串中的百分号和下划线，就需要在通配字符串中使用右斜线(“\”)对百分号和下划线进行转义，
例如，“\%”匹配百分号字面值，“\_”匹配下划线字面值。
*/

-- 课堂示例15: 找出product表商品名称含有“_”的记录
-- 插入示例行数据
INSERT INTO product(product_id, product_name)
VALUES ('33', '理光_复印机'),
('44', '理光%复印机');

SET sql_safe_updates = 0;

DELETE FROM product
WHERE product_id = 44;

SELECT *
FROM product
WHERE product_name LIKE '%\%%';

-- 2.7 带AND关键字的多条件查询: 连接两个或者多个查询条件
/* 语法格式
SELECT *|{字段名1,字段名2,……}
FROM 表名
WHERE 条件表达式1 […… AND 条件表达式n];
*/

-- 课堂示例16：找出商品名称含复印机且产地在天津的记录
SELECT * 
FROM product
WHERE product_place = '天津' AND product_name LIKE '%复印机%';

-- 2.8 带OR关键字的多条件查询: 记录满足任意一个条件即被查出
/* 语法格式
SELECT *|{字段名1,字段名2,……}
FROM 表名
WHERE 条件表达式1 […… OR 条件表达式n];
*/

-- 课堂示例17：找出product中商品名称含'复印机'或'过胶机'的商品记录
-- 错误写法，注意复合表达式的写法
SELECT *
FROM product
WHERE product_name LIKE '%复印机%';

SELECT *
FROM product
WHERE '%过胶机%';

SELECT count(*)
FROM product
WHERE product_name LIKE '%复印机%' OR '%过胶机%';

-- 正确写法
SELECT *
FROM product
WHERE product_name LIKE '%复印机%' OR product_name LIKE '%过胶机%';

SELECT *
FROM product
WHERE (product_name LIKE '%复印机%') OR (product_name LIKE '%过胶机%');

-- 找出product中商品类别为复印机的商品记录
SELECT a.product_id, a.product_name, a.price, a.subsort_id, a.sort_id
FROM product a, subsort b
WHERE a.subsort_id = b.subsort_id AND b.subsort_name = '复印机';

-- OR和AND关键字一起使用的情况
/*
AND的优先级高于OR，因此当两者在一起使用时，应该先运算AND两边的条件表达式，再运算OR两边的条件表达式。
*/

-- 课堂示例18: 找出商品名称含'复印机'和'过胶机'，且产地为天津的的商品记录
SELECT *
FROM product
WHERE product_name LIKE '%复印机%' AND product_place = '天津'
	OR product_name LIKE '%过胶机%' AND product_place = '天津';

-- 等价于
SELECT *
FROM product
WHERE (product_name LIKE '%复印机%' OR product_name LIKE '%过胶机%') AND product_place = '天津';

-- 不等价于(找出产地为天津且商品名称含过胶机，以及所有商品名称含复印机的商品记录)
SELECT *
FROM product
WHERE product_name LIKE '%复印机%' OR product_name LIKE '%过胶机%' AND product_place = '天津';

-- 2.9 限定查询返回的记录数
/*当不需要显示所有查询结果时，可以通过LIMIT限定查询的个数, 语法格式为：
SELECT *|{字段名1,字段名2,……}
FROM 表名
WHERE 条件表达式1 OR […… OR 条件表达式n] 
	LIMIT m [,n];

参数m为偏移量（即第一个返回的记录对应的序号），n为返回的个数
*/

-- 课堂示例19: 找出前5个商品名称含复印机且产地为天津的商品记录
SELECT *
FROM product
WHERE product_place = '天津' AND product_name LIKE '%复印机%' LIMIT 5;

-- 2.10 将查询结论写入外部文件
/*
(1) 准备工作：找到'C:\ProgramData\MySQL\MySQL Server 5.7\my.ini' 文件
将其中的变量secure-file-priv的值设置为空"", 设置好之后即可将数据存储到任意文件夹下

(2) 语法格式：
SELECT 字段1, 字段2, ... | *
FROM 表名
WHERE 条件表达式
INTO OUTFILE "文件路径+文件名+扩展名";
*/
SELECT product_id, product_name, product_place, price, sort_id
FROM product
WHERE price > 100
INTO OUTFILE 'E:\1.xls';

-- 课堂练习2
/*
根据product表中的数据完成以下查询：
（1）找出零售价在500元到1000元的商品记录，显示Product_ID, Product_Name, Price, Product_Place, SubSort_ID和Sort_ID，按Price降序排列。
（2）找出商品名称中含有“理光”和“墨粉”的商品记录。（理光公司的墨粉产品）
（3）找出Product_Place不为空的计算器商品记录，显示10条记录。
（4）找出Product_Place的不同值。
（5）找出价格在1000元以下的书柜和价格在1000元到2000元之间的保险柜商品记录。
*/
-- (1) 找出零售价在500元到1000元的商品记录，显示Product_ID, Product_Name, Price, Product_Place, SubSort_ID
SELECT product_id, product_name, price, product_place, subsort_id
FROM product
WHERE price BETWEEN 500 AND 1000;
-- 或者
SELECT product_id, product_name, price, product_place, subsort_id
FROM product
WHERE price >= 500 AND price <= 1000;
-- 或者
SELECT product_id, product_name, price, product_place, subsort_id
FROM product
WHERE NOT (price < 500 OR price > 1000);

-- (2) 找出商品名称含“理光”和“墨粉”的商品记录。（理光公司的墨粉产品）
SELECT *
FROM product
WHERE product_name LIKE '%理光%' AND product_name LIKE '%墨粉%';

-- 或者
SELECT *
FROM product
WHERE product_name LIKE '%理光%墨粉%' OR product_name LIKE '%墨粉%理光%';


-- (3) 找出Product_Place不为空的计算器商品记录，显示10条记录
SELECT *
FROM product
WHERE product_place IS NOT NULL
LIMIT 10;

-- (4) 找出Product_Place的不同值
SELECT DISTINCT product_place
FROM product;

-- (5) 找出价格在1000元以下的商品名称含书柜和价格在1000元到2000元之间的商品名称含保险柜的商品记录
SELECT *
FROM product
WHERE (price <= 1000 AND product_name LIKE '%书柜%') 
	OR (price BETWEEN 1000 AND 2000 AND product_name LIKE '%保险柜%');

-- 或者
SELECT *
FROM product
WHERE price <= 1000 AND product_name LIKE '%书柜%'
UNION
SELECT *
FROM product
WHERE price BETWEEN 1000 AND 2000 AND product_name LIKE '%保险柜%';