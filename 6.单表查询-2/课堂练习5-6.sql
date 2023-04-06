use purchase;

-- 单表查询1
-- 1. 找出零售价在500元到1000元的商品记录，显示Product_ID, Product_Name, Price, Product_Place, SubSort_ID
SELECT product_id, product_name, price, product_place, subsort_id
FROM product
WHERE price BETWEEN 500 AND 1000;
-- 或者
SELECT product_id, product_name, price, product_place, subsort_id
FROM product
WHERE price >= 500 AND price <= 1000;

SELECT product_id, product_name, price, product_place, subsort_id
FROM product
WHERE 500 <= price <= 1000;

-- 或者
SELECT product_id, product_name, price, product_place, subsort_id
FROM product
WHERE NOT (price < 500 OR price > 1000);

-- 2. 找出商品名称含“理光”和“墨粉”的商品记录。（理光公司的墨粉产品）
SELECT *
FROM product
WHERE product_name LIKE '%理光%' AND product_name LIKE '%墨粉%';

-- 或者
SELECT *
FROM product
WHERE product_name LIKE '%理光%墨粉%' OR product_name LIKE '%墨粉%理光%';

-- 3. 找出Product_Place不为空的计算器商品记录，显示10条记录
SELECT *
FROM product
WHERE product_place IS NOT NULL AND product_name LIKE '%计算器%'
LIMIT 10;

-- 4. 找出Product_Place的不同值
SELECT DISTINCT product_place
FROM product;

-- 5. 找出价格在1000元以下的商品名称含书柜和价格在1000元到2000元之间的商品名称含保险柜的商品记录
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


-- 单表查询2
-- 1. 查找各品牌复印机的品牌名和最高零售价
SELECT SUBSTRING('abcd', 1, 2);

SELECT SUBSTRING(product_name, 1, 2) 品牌, MAX(price) 最高价格
FROM product
WHERE product_name LIKE '%复印机%'
GROUP BY SUBSTRING(product_name, 1, 2);

-- 2. 查找`Product_Place`和该产地的产品数，显示产品数在100种以上的产地信息
SELECT product_place, COUNT(*)
FROM product
GROUP BY product_place HAVING COUNT(*) >= 100
order by COUNT(*);

-- 3. 根据`product`表计算不同`SubSort_ID`的商品单价平均值（别名为`Avg_Price`），列出前10条记录
SELECT subsort_id, AVG(price) AS avg_price
FROM product
GROUP BY subsort_id
LIMIT 10;

-- 4. 查询`product`表中的`Product_ID, Product_Name`和`Product_Date`字段值，如果`Product_Date`字段的月份大于6则返回下半年，否则返回上半年，并把`if`条件表达式命名为“半年”
SELECT product_id, product_name, product_date, IF(MONTH(product_date)>6, '下半年', '上半年') AS 半年
FROM product;

-- 5. 查找`Product_ID, Product_Name,Product_Date`，并标记`Product_Date`对应的季度，把计算季度的表达式命名为“季度”
SELECT product_id, product_name, product_date, IF(MONTH(product_date)<=3, 1, IF(MONTH(product_date)<=6, 2, IF(MONTH(product_date)<=9, 3, 4))) 季度
FROM product;
-- 或者
SELECT product_id, product_name, product_date, ceiling(Month(product_date)/3) 季度
FROM product;

-- 6. 查找按产地和生产月份分组的零售价平均值，显示`Product_Place`,生产月份和零售价均值，并将生产月份命名为"月份"，零售价均值命名为"均价"
SELECT product_place, MONTH(product_date) AS 月份, AVG(price) 均价
FROM product
GROUP BY product_place, MONTH(product_date);