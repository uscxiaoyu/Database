use purchase;

-- 1. 聚合函数
-- 示例1：使用函数统计零售价的平均值，最大值和最小值
SELECT AVG(price), MAX(price), MIN(price) 
FROM product;

select * from product;

-- 示例2：使用count()统计product表中的记录个数
SELECT COUNT(*) FROM product;
SELECT COUNT(product_name) FROM product;
SELECT product_name FROM product where product_name is not null;
SELECT COUNT(*) FROM product WHERE product_name IS NOT NULL; 
SELECT COUNT(*) FROM product WHERE product_name IS NULL; 

-- 示例3: 使用count(distinct())统计product不重复值的个数
SELECT DISTINCT sort_id FROM product;
SELECT COUNT(DISTINCT sort_id) FROM product;

-- 2. 排序ORDER BY
/*
SELECT 字段名1,字段名2,……
FROM 表名
ORDER BY 字段名1 [ASC | DESC]，字段名2 [ASC | DESC]……
*/
-- 示例4： 找出商品名称中含有“理光”和“墨粉”的商品记录， 按零售价降序排列。（理光公司的墨粉产品）
SELECT *
FROM product
WHERE product_name LIKE '%理光%墨粉%' OR product_name LIKE '%墨粉%理光'
ORDER BY price DESC;

SELECT *
FROM product
WHERE product_name REGEXP '(理光.*墨粉)|(墨粉.*理光)'
ORDER BY price DESC;

-- 示例5： 查找product表中的product_id, product_name, product_place, price，返回结果先按product_place降序排列，然后按price升序排序
SELECT product_id, product_name, product_place, price
FROM product
ORDER BY product_place DESC, price ASC;

-- 字符串排序
DESC product;
alter table product modify product_id varchar(25);

select product_id from product limit 10;

SELECT product_id, product_name, product_place, price
FROM product
ORDER BY product_id DESC;

SELECT product_id, product_name, product_place, price
FROM product
ORDER BY CAST(product_id AS UNSIGNED) DESC;  -- 将字符串转换为数值

/*
CAST(字段名 AS 转换类型)函数可以将一个字段进行类型准换。
转换类型可以是
CHAR[(N)] 字符型 
DATE  日期型
DATETIME  日期和时间型
TIME  时间型
DECIMAL  float型
FLOAT float型
SIGNED  有符号int
UNSIGNED 无符号int
*/

SELECT convert('1', signed);

-- 3. 分组GROUP BY
/*
SELECT 字段名1,字段名2,……
FROM 表名
GROUP BY 字段名1，字段名2，……[HAVING 条件表达式];
*/
-- 示例6：按Product_Place分组，显示理光牌墨粉的名称和对应的记录数
SELECT *
FROM product
WHERE product_name LIKE '%理光%墨粉%';

SELECT *
FROM product
WHERE product_name LIKE '%理光%墨粉%'
GROUP BY product_place;

SELECT product_place, COUNT(*), AVG(price)
FROM product
WHERE product_name LIKE '理光%墨粉'
GROUP BY product_place;

-- 示例7：按Product_Place分组，显示各产地对应的产品记录个数
SELECT product_place, COUNT(*)
FROM product
where product_place is not null
GROUP BY product_place
having avg(price) > 100;

-- 示例8：根据product表计算不同产地的商品单价最大值，按Product_place降序排列
SELECT product_place, MAX(price)
FROM product
GROUP BY product_place
ORDER BY product_place DESC;

-- 示例9：根据product表计算不同产地的商品单价最大值，将单价最大值大于100元的产品的产地及单价最大值按Product_ID降序排列
SELECT product_place, MAX(price)
FROM product
GROUP BY product_place 
HAVING MAX(price) > 100;

-- 示例10：查询product表中（类别，子类别）对应的最大商品价格，返回sort_id, subsort_id和对应的最大价格
SELECT sort_id, subsort_id, MAX(price)
FROM product
GROUP BY sort_id, subsort_id;

SELECT subsort_id, AVG(price)
FROM product
GROUP BY subsort_id
limit 10;

-- group_concat()函数：将某一分组中的某一字段对应的所有字符串连接起来，即返回分组中对应字段的所有值
-- 示例11：查询各子类对应的product_name，用逗号连接起来
SELECT subsort_id, group_concat(product_name ORDER BY length(product_name) ASC separator "===")
FROM product 
GROUP BY subsort_id;

show variables like '%sql_mode%';

-- 4. 其它函数
-- 示例12: 数学函数
SELECT ABS(-1);
SELECT SQRT(4);
SELECT MOD(10, 3);
SELECT CEILING(9.3), FLOOR(9.3);
SELECT ROUND(9.328, 2);
SELECT TRUNCATE(9.328, 2);
SELECT SIGN(-8.2), SIGN(0), SIGN(6);

SELECT PI(),SIN(PI()),COS(PI()),TAN(0);

-- 示例13：字符串函数
SELECT LENGTH('abcdef123');  -- 字符串的长度
SELECT CONCAT('背景', '--', '音乐');
SELECT LENGTH(TRIM(' aabdfe '));
SELECT LENGTH(LTRIM(' aabdfe '));
SELECT LENGTH(RTRIM(' aabdfe '));
SELECT REPLACE('背景背景音乐', '背景', '北京');
SELECT SUBSTRING('abcdef123', 1, 3);
SELECT REVERSE('abcdef123');
SELECT LOCATE('c','abcdef123');

-- 示例14：日期和时间函数
SELECT NOW();
SELECT CURDATE();
SELECT current_date();

SELECT CURTIME();
SELECT current_time();

SELECT SYSDATE();
SELECT current_timestamp();

SELECT TIME_TO_SEC(CURTIME());
SELECT ADDDATE('2012-12-21', '7');
SELECT SUBDATE('2012/12/21', '7');
SELECT DATE_FORMAT(NOW(),'%m-%d-%y');
SELECT DATE_FORMAT(NOW(),'%b %d %Y %h:%i %p'); -- b为缩写月名
SELECT DATE_FORMAT(NOW(),'%m-%d-%Y'); -- Y 4位年份
SELECT DATE_FORMAT(NOW(),'%d %b %y'); -- y 2位年份
SELECT DATE_FORMAT(NOW(),'%d %b %Y %T:%f'); -- T时间, 24-小时(hh:mm:ss)

-- 示例15：条件判断
SELECT IF(5>6, '对', '错');
SELECT IFNULL(null, '空值'), IFNULL(1, '空值');

-- 让空值排在末尾
SELECT * 
FROM product 
ORDER BY price;

SELECT * 
FROM product 
ORDER BY if(price is null, 0, 1) DESC, price ASC;

-- 示例16:查询Product表中的Product_ID，Product_Name，Sort_ID 和SubSort_ID，
-- 把Sort_ID 和SubSort_ID 用“-”连接起来
SELECT CONCAT(product_id, '===', product_name, '===', sort_id,'--',subsort_id)
FROM product;

-- 示例17:查询product表中的Product_ID, Product_Name和Product_Date字段值，
-- 如果Product_Date字段的月份大于6则返回下半年，否则返回上半年。
SELECT product_id, product_date, product_name,
 IF(MONTH(product_date)>6, '下半年', '上半年')
FROM product;

-- 练习1
-- （1）查找各品牌复印机的品牌名和最高零售价
-- （提示：商品名的前两个字为品牌，按品牌分组可以用group by substring(Product_Name, 1,2）
SELECT SUBSTRING('abcd', 1, 2);

SELECT SUBSTRING(product_name, 1, 2) 品牌, MAX(price) 最高价
FROM product
WHERE product_name LIKE '%复印机%'
GROUP BY SUBSTRING(product_name, 1, 2);

-- （2）查找Product_ID, Product_Name, Product_Date和SubSort_ID，显示第11条到第20条记录。
SELECT product_id, product_name, product_date, subsort_id
FROM product
LIMIT 10, 10;

-- （3）查找Product_Place和该产地的产品数，显示产品数在100种以上的产地信息。
SELECT product_place, COUNT(*)
FROM product
GROUP BY product_place HAVING COUNT(*) >= 100;

-- （4）查找按产地和生产月份分组的零售价平均值，显示Product_Place,生产月份和零售价均值。
SELECT product_place, MONTH(product_date), AVG(price)
FROM product
GROUP BY product_place, MONTH(product_date);

-- 查找Product_ID, Product_Name,Product_Date，并标记Product_Date对应的季度
SELECT product_id, product_name, product_date, IF(MONTH(product_date)<=3, '第1季度',
													IF(MONTH(product_date)<=6, '第2季度',
														IF(MONTH(product_date)<=9, '第3季度', '第4季度')))
FROM product;

-- 或者
SELECT product_id, product_name, product_date, concat('第',ceiling(Month(product_date)/3),'季度') 季度
FROM product;

-- 5. 为表和字段取别名
/*为表起别名的语法格式: 表名 [AS] 别名; */
-- 示例18：给product表起一个别名tb_prod
SELECT tb_prod.product_name, product_place
FROM product AS tb_prod;

-- 示例19: 多表连接时，简化表名
SELECT a.product_id, a.product_name, b.sort_name
FROM product a, sort b
WHERE a.sort_id = b.sort_id;

-- 示例20：给Product_Place字段起一个别名为Place
SELECT product_place AS place
FROM product;

-- 练习2：
-- （1）根据product表计算不同SubSort_ID的商品单价平均值（别名为Avg_Price），列出前10条记录。
SELECT subsort_id, AVG(price) AS avg_price
FROM product
GROUP BY subsort_id
LIMIT 10;

-- （2）查询product表中的Product_ID, Product_Name和Product_Date字段值，如果Product_Date字段的月份大于6则返回下半年，否则返回上半年，并把if条件表达式命名为“半年”。
SELECT product_id, product_name, product_date, IF(MONTH(product_date)>6, '下半年', '上半年') AS '半年'
FROM product;

-- （3）查找Product_ID, Product_Name,Product_Date，并标记Product_Date 对应的季度，把计算季度的表达式命名为“季度”。
SELECT product_id, product_name, product_date, IF(MONTH(product_date)<=3, 1, IF(MONTH(product_date)<=6, 2, IF(MONTH(product_date)<=9, 3, 4))) 季度
FROM product;

-- （4）查找按产地和生产月份分组的零售价平均值，显示Product_Place,生产月份和零售价均值，并将生产月份命名为“月份”，零售价均值命名为“均价”。
SELECT product_place, MONTH(product_date) AS 月份, AVG(price) 均价
FROM product
GROUP BY product_place, MONTH(product_date);

-- 或者
SELECT product_id, product_name, product_date, ceiling(Month(product_date)/3) 季度
FROM product;
SELECT subsort_id, CAST(CONCAT('[', group_concat('"', product_name, '"'), ']') AS JSON) FROM product GROUP BY subsort_id
