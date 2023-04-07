-- 第5次课，单表查询
use purchase;

# 1. SELECT子句
/*列出特定字段名对应数据的语法格式如下:
SELECT 字段名1, 字段名2, ..., 字段名n FROM 表名; */

select 1 + 1, now();
select @@sql_safe_updates;

-- 示例1: 通过列出所有字段名查询product表的数据
select *
from product;

SELECT product_id, product_name, product_code, product_place,
	product_date, price, unit, detail, subsort_id, sort_id
FROM product;

SELECT COUNT(*)
FROM PRODUCT;

-- 示例2：查询指定字段对应的数据
SELECT product_id, product_name, price
FROM product;

-- 示例3：通过*查询product表的所有数据
desc product;

SELECT *
FROM product;

/*
当不需要显示所有查询结果时，可以通过LIMIT限定查询的个数, 语法格式为：
SELECT *|{字段名1,字段名2,……}
FROM 表名
LIMIT m [,n];
*/
-- 示例4: 查询前10个product表中的商品记录
SELECT *
FROM product
LIMIT 10;

-- 2. 按条件查询(where子句)

-- 2.1 带关系运算符的查询：对数据筛选过滤
/* 语法格式:
SELECT 字段名1, 字段名2, ...
FROM 表名
WHERE 条件表达式;

常见的关系运算符号：=、<>、！=、<、<=、>、>=
*/

-- 示例5：查询product表中Product_Place为“天津”的产品信息
SELECT *
FROM product
WHERE product_place = '天津';

-- 示例6：使用SELECT语句查询Product_Name为“京瓷KM-4030复印机”的商品价格
SELECT price
FROM product
WHERE product_name = '京瓷KM-4030复印机';

-- 示例7：查询Product表中Price 大于1000的商品代码和名称
SELECT product_id, product_name
FROM product
WHERE price >= 1000;

-- 注意: 在SQL中，a <= x <= b并不等价于 x >= a and x <= b
-- 请比较以下两个查询结果:
SELECT *
FROM product
WHERE 100 <= price <= 500; -- 返回表中的记录数, 先运算100 <= price，再将运算结果(true或false)与500进行比较

SELECT *
FROM product
WHERE price >= 100 AND price <= 500;

-- 试分别运行以下两个查询：
SELECT * FROM Product WHERE Product_ID >= 1 AND Product_ID <= 200;
SELECT * FROM Product WHERE Product_ID >= '1' AND Product_ID <= '200';

desc product;
-- 理论上而言，字符串类型值小于所有的数值。
SELECT 1 > 'afe12';
/*然而，需要注意SQL中的比较运算会自动转换类型，如果比较运算符左右为数值和能转换为数值的字符串，
则现先将字符串转为数值后比较大小；如果其中的字符串不能转换为数值，则数值一方大于字符串。
如果两方都为字符串数值，也按字符串比较规则确定大小。*/
SELECT 1 = '1', 2 > 'a', 2 > '12', 2 > '12ABC', '2' > '12';

-- 2.2 带in关键字的查询：限定结果在某一集合中
/* 语法格式
SELECT *|字段名1,字段名2,……
FROM 表名
WHERE 字段名 [NOT] IN (元素1,元素2,……) */

-- 示例8：查找product表中产地为天津，北京和日本的商品的全部信息
SELECT *
FROM product
WHERE product_place IN ('天津', '北京', '日本');

-- 补充：查找product表中产地不为天津，北京和日本的商品的全部信息
SELECT *
FROM product
WHERE product_place NOT IN ('天津', '北京', '日本');

-- 子查询：查找product表sort_id属于sort表中sort_id的行
SELECT *
FROM product
WHERE sort_id IN (SELECT sort_id FROM sort);

-- 2.3 带BETWEEN ... AND关键字的查询：限定结果在指定范围
/* 语法格式
SELECT *|{字段名1,字段名2,……}
FROM 表名 WHERE 字段名 [NOT] BETWEEN 值1 AND 值2; */

-- 示例9：查询prodct表中Price值在200和500之间的商品信息
SELECT *
FROM product
WHERE price BETWEEN 200 AND 500;

-- 示例10：查询product表中Price值不在200和500之间的商品信息
SELECT *
FROM product
WHERE price NOT BETWEEN 200 AND 500;

-- 2.4 空值查询：判断某些列值是否为NULL
/* 语法结构：
SELECT *|字段名1,字段名2,……
FROM 表名
WHERE 字段名IS [NOT] NULL; */

-- 示例11：查询product表中Product_Place为空值的商品名称和价格
SELECT product_name, price, Product_Place
FROM product
WHERE product_place IS NULL;

-- 示例12：查询product表中Product_Place不为空值的记录
SELECT product_name, price, Product_Place
FROM product
WHERE product_place IS NOT NULL;

-- 2.5 字段前带DISTINCT关键字的查询：去重复
/* 语法格式
SELECT DISTINCT 字段名
FROM 表名
[WHERE 条件表达式];
*/

-- 示例13：查询product表中Product_Place字段的值，查询记录不能重复
SELECT distinct product_place
FROM product;

-- DISTINCT关键字作用于多个字段：向量比较，只有DISTINCT关键字后指定的多个字段值都相同，才会被认作是重复记录。
-- 课堂示例14：找出product表中不同的根类别和子类别的组合
SELECT DISTINCT sort_id, subsort_id
FROM product;

-- 3. 匹配字符串
-- 3.1 带LIKE关键字的查询—判断两个字符串是否相匹配
/*
SELECT *|{字段名1,字段名2,……}
FROM 表名
WHERE 字段名 [NOT] LIKE '匹配字符串';

LIKE语法格式中的“匹配字符串”指定用来匹配的字符串，其值可以是一个普通字符串，也可以是包含百分号(%)和下划线(_)等通配字符串;
(1) %: 可以匹配任意长度的字符串，包括空字符串
(2) _: 下划线通配符只匹配单个字符，如果要匹配多个字符，需要使用多个下划线通配符
*/

-- 示例15：查找product表中商品名称含有复印机的商品名称，价格和产地
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

-- 示例16: 找出product表商品名称含有“_”的记录
-- 插入示例行数据
INSERT INTO product(product_id, product_name)
VALUES ('33', '理光_复印机'),
('44', '理光%复印机');

SELECT * FROM PRODUCT WHERE PRODUCT_ID IN ('33', '44');

SET sql_safe_updates = 0;

SELECT *
FROM product
WHERE product_name LIKE '%\%%' OR product_name LIKE '%\_%';

-- 3.2. 利用正则表达式匹配字符串: `regexp`或`rlike`
-- 示例17: 查找product表中product_name末尾字符串为有复印机的商品名称，价格和产地
SELECT product_name, price, product_place
FROM product
WHERE product_name REGEXP '复印机$';

-- 示例18: 查询product表中product_place在江苏的product_name, price和product_place
SELECT *
FROM product
WHERE product_place REGEXP '^江苏';

-- 4. 复合条件
-- 4.1 带AND关键字的多条件查询: 连接两个或者多个查询条件
/* 语法格式
SELECT *|{字段名1,字段名2,……}
FROM 表名
WHERE 条件表达式1 […… AND 条件表达式n];
*/

-- 示例19：找出商品名称含复印机且产地在天津的记录
SELECT *
FROM product
WHERE product_place = '天津' AND product_name LIKE '%复印机%';

-- 或则
SELECT *
FROM product
WHERE product_place = '天津' AND product_name REGEXP '复印机';

-- 4.2 带OR关键字的多条件查询: 记录满足任意一个条件即被查出
/* 语法格式
SELECT *|{字段名1,字段名2,……}
FROM 表名
WHERE 条件表达式1 […… OR 条件表达式n];
*/

-- 示例20：找出product中商品名称含'复印机'或'过胶机'的商品记录
-- 错误写法，注意复合表达式的写法
SELECT *
FROM product
WHERE product_name LIKE '%复印机%';

SELECT *
FROM product
WHERE '%过胶机%';

SELECT *
FROM product
WHERE product_name LIKE '%复印机%' OR '%过胶机%';

-- 正确写法
SELECT *
FROM product
WHERE product_name LIKE '%复印机%' OR product_name LIKE '%过胶机%';

SELECT *
FROM product
WHERE (product_name LIKE '%复印机%') OR (product_name LIKE '%过胶机%');

-- 或者
SELECT *
FROM product
WHERE product_name REGEXP '复印机|过胶机';

-- 找出product中商品类别为复印机的商品记录
SELECT a.product_id, a.product_name, a.price, a.subsort_id, b.subsort_name, a.sort_id
FROM product a, subsort b
WHERE a.subsort_id = b.subsort_id AND b.subsort_name = '复印机';

-- OR和AND关键字一起使用的情况
/*
AND的优先级高于OR，因此当两者在一起使用时，应该先运算AND两边的条件表达式，再运算OR两边的条件表达式。
*/

-- 示例21: 找出商品名称含'复印机'或'过胶机'，且产地为天津的的商品记录
SELECT *
FROM product
WHERE product_name LIKE '%复印机%' AND product_place = '天津'
	OR product_name LIKE '%过胶机%' AND product_place = '天津';

-- 等价于
SELECT *
FROM product
WHERE (product_name LIKE '%复印机%' OR product_name LIKE '%过胶机%') AND product_place = '天津';

-- 等价于
SELECT *
FROM product
WHERE product_name REGEXP '复印机|过胶机' AND product_place = '天津';

-- 不等价于(找出产地为天津且商品名称含过胶机，以及所有商品名称含复印机的商品记录)
SELECT *
FROM product
WHERE product_name LIKE '%复印机%' OR product_name LIKE '%过胶机%' AND product_place = '天津';


-- 补充1：将查询结论写入外部文件
/*
(1) 准备工作：找到'C:\ProgramData\MySQL\MySQL Server 5.7\my.ini' 文件
将其中的变量secure-file-priv的值设置为空"", 设置好之后即可将数据存储到任意文件夹下

(2) 语法格式：
SELECT 字段1, 字段2, ... | *
FROM 表名
WHERE 条件表达式
INTO OUTFILE "文件路径+文件名+扩展名" CHARACTER SET 字符集
FILEDS TERMINATED BY 字段值分割符
OPTIONALLY ENCLOSED BY 字符串标识符
LINES TERMINATED BY 换行符;
*/
SELECT product_id, product_name, product_place, price, sort_id
FROM product
WHERE price > 100
INTO OUTFILE 'E:\1.xls' CHARACTER SET gbk
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n';


-- 补充2: 将外部文件写入到mysql表中
/*
(1) 准备工作：文本文件，例如E:\1.csv
(2) 语法格式：
LOAD DATA INFILE "文件路径+文件名+扩展名"
INTO TABLE 表名 CHARACTER SET 字符集
FILEDS TERMINATED BY 字段值分割符
OPTIONALLY ENCLOSED BY 字符串标识符
LINES TERMINATED BY 换行符;
*/
DROP TABLE P1;
CREATE TABLE p1 AS SELECT * FROM product WHERE 1=2;
SHOW CREATE TABLE p1;

LOAD DATA INFILE "E:\1.CSV"
INTO TABLE p1 CHARACTER SET gbk
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n';

-- 课堂练习1

/*
根据product表中的数据完成以下查询：
 (1) 找出零售价在500元到1000元的商品记录，显示Product_ID, Product_Name, Price, Product_Place, SubSort_ID和Sort_ID，按Price降序排列。
 (2) 找出商品名称中含有“理光”和“墨粉”的商品记录。（理光公司的墨粉产品）
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

/*
根据member表中的数据完成以下查询：
 (1) 查询使用163邮箱的所有用户记录。
 
*/
-- （1）查询使用163邮箱的所有用户记录。
SELECT * FROM MEMBER WHERE email LIKE '%@163.com%';
SELECT * FROM MEMBER WHERE email regexp '@163.com';

-- （2）查询地址为上海的用户的user_name, true_name, address.
SELECT * FROM MEMBER WHERE address LIKE '上海%';
SELECT * FROM MEMBER WHERE address regexp '^上海';
