use purchase;

-- 1.交叉连接：CROSS JOIN
/*语法：
SELECT * FROM 表1 CROSS JOIN 表2;
或者
SELECT * FROM 表1, 表2;

注意：需要注意的是，在实际开发中这种业务需求是很少见，一般不会使用交叉连接，而是使用具体的条件对数据进行有目的的查询。

*/

-- 课堂示例1：使用交叉连接，查询根类别表（sort表）和子类别表（subsort表）的所有数据.
SELECT * FROM sort CROSS JOIN subsort limit 35;
SELECT * FROM sort, subsort LIMIT 35;

select count(*) from sort;
select count(*) from subsort;
select count(*) from sort, subsort;

-- 2.内连接: INNER JOIN
/*语法：
SELECT 查询字段 FROM 表1 [INNER] JOIN 表2 ON 表1.关系字段 = 表2.关系字段;
等价于
SELECT * FROM 表1 CROSS JOIN 表2 WHERE 表1.关系字段 = 表2.关系字段;
*/

-- 课堂示例2：使用内连接，查询根类别表（sort表）和子类别表（subsort表）中的根类别名称和子类别名称。
SELECT Sort_name, SubSort_name
FROM sort INNER JOIN subsort ON sort.Sort_ID = subsort.Sort_ID;

-- 课堂示例3：使用交叉连接，结合where条件语句实现上例的内连接查询sort表和subsort表中的根类别名称和子类别名称。
SELECT *
FROM sort, subsort WHERE sort.Sort_ID = subsort.Sort_ID;

-- 3.外连接: LEFT | RIGHT [OUTER] JOIN
/*语法：
SELECT 所查字段 FROM 表1 LEFT|RIGHT [OUTER] JOIN 表2
ON 表1.关系字段 = 表2.关系字段 WHERE 条件
*/

-- 课堂示例4：在sort表和subsort表之间使用左连接查询
SELECT *
FROM sort LEFT JOIN subsort ON sort.Sort_ID = subsort.Sort_ID ORDER BY SubSort_name;

-- 课堂示例5：在sort表和subsort表之间使用右连接查询
SELECT *
FROM sort RIGHT JOIN subsort ON sort.Sort_ID = subsort.Sort_ID ORDER BY Sort_name;

-- 4. 复合条件连接查询

-- 课堂示例6：在sort表和subsort表之间使用内连接查询，然后查询类别名称中有'文件'的记录，将查询结果按照Subsort_ID降序排列。
SELECT Sort_name, Subsort_ID, SubSort_name
FROM sort INNER JOIN subsort ON sort.Sort_ID = subsort.Sort_ID
WHERE sort_name LIKE '%文件%' ORDER BY Subsort_ID DESC;

SELECT a.sort_name, COUNT(b.subsort_id)
FROM sort a JOIN subsort b ON a.sort_id = b.sort_id
WHERE sort_name LIKE '%用品%'
GROUP BY a.sort_name
HAVING COUNT(b.subsort_id) > 5
ORDER BY COUNT(b.subsort_id) DESC
LIMIT 5;

-- 等价于
SELECT Sort_name, Subsort_ID, SubSort_name
FROM sort, subsort
WHERE sort.Sort_ID = subsort.Sort_ID AND sort_name LIKE '%文件%'
ORDER BY Subsort_ID DESC;

-- 补充1：自然连接--寻找量表中相同的字段进行等值连接，去除重复字段
/* 语法:
SELECT 字段列表 FROM 表1 natural join 表2
*/
SELECT * FROM sort natural join subsort limit 5;

SELECT sort.sort_id, sort_name, subsort_id, subsort_name
FROM sort cross join subsort
WHERE sort.sort_id = subsort.sort_id limit 5;

-- 补充2: 多表间的连接
SELECT * FROM product join sort join subsort;

SELECT * FROM product, sort, subsort;

SELECT count(*)
FROM product natural join sort natural join subsort;

SELECT count(*)
FROM product join sort join subsort on product.sort_id=sort.sort_id and sort.sort_id=subsort.sort_id;

SELECT count(*)
FROM product join sort join subsort
WHERE product.sort_id=sort.sort_id and sort.sort_id=subsort.sort_id;

-- 课堂练习1
-- （2）使用内连接，查询product表和orders表中的订单号、订单时间、商品名称和商品数量。
SELECT product.Product_ID, Order_ID, Order_date, Product_Name, Quantity
FROM product INNER JOIN orders ON product.Product_ID = orders.Product_ID;
-- 等价于
SELECT orders.Order_ID, orders.Order_date, product.Product_Name, orders.Quantity
FROM product, orders
WHERE product.Product_ID = orders.Product_ID;
-- 别名
SELECT b.Order_ID, b.Order_date, a.Product_Name, b.Quantity
FROM product a, orders b
WHERE a.Product_ID = b.Product_ID;

-- （3）在product表和orders表之间使用左连接查询商品id、商品名称、订单号、订单时间和订单数量。
SELECT a.Product_ID, a.Product_Name, b.Order_ID, b.Order_date, b.Quantity
FROM product a LEFT JOIN orders b ON a.Product_ID=b.Product_ID;

-- （4）在product表和orders表之间使用右连接查询商品id、商品名称、订单号、订单时间和订单数量。
SELECT a.Product_ID, a.Product_Name, b.Order_ID, b.Order_date, b.Quantity
FROM product a RIGHT JOIN orders b ON a.Product_ID=b.Product_ID;

-- （5）在member表和orders表之间使用内连接查询订单号、订单时间、商品名id、商品数量和客户真实姓名，并按订单时间降序排列。
SELECT a.Order_ID, a.Order_date, a.Product_ID, a.Quantity, b.True_name
FROM orders a JOIN member b ON a.User_name = b.User_name
ORDER BY a.Order_date;

-- 5. 子查询

-- 课堂示例7：使用IN关键字, 查询子类别名“闹钟”对应的根类别信息。
SELECT *
FROM sort
WHERE Sort_ID IN ( SELECT Sort_ID
                    FROM subsort
                    WHERE SubSort_name='闹钟');
-- 等价于
SELECT sort.Sort_ID, sort.Sort_name
FROM sort JOIN subsort ON sort.Sort_ID = subsort.Sort_ID
WHERE subsort.SubSort_name = '闹钟';

-- 课堂示例8：使用EXISTS关键字，如果存在子类别编号为3101，则查询类别表中所有的记录。
SELECT *
FROM sort
WHERE EXISTS (SELECT Sort_ID
                FROM subsort
                WHERE SubSort_ID=1111101);

-- 课堂示例9：使用带ANY关键字的子查询，查询满足以下条件的产地名称：对应单价大于产地为大连的任一产品价格。
SELECT distinct Product_Place
FROM product
WHERE price > ANY (SELECT price
                    FROM product
                    WHERE Product_Place = '大连');
-- 等价于
SELECT distinct Product_Place
FROM product
WHERE price > (SELECT MIN(price)
                FROM product
                WHERE Product_Place = '大连');

-- 课堂示例10：使用带ALL关键字的子查询，查询满足以下条件的产地名称：对应单价大于产地为大连的所有产品价格。
SELECT distinct Product_Place
FROM product
WHERE price > ALL (SELECT price
                    FROM product
                    WHERE Product_Place = '大连');
-- 等价于
SELECT distinct Product_Place
FROM product
WHERE price > (SELECT MAX(price)
                FROM product
                WHERE Product_Place = '大连');

-- 课堂练习2

-- （1）完成课堂示例。
-- （2）使用IN关键字查询商品产地为“广东”的商品订单信息。
SELECT *
FROM orders
WHERE Product_ID IN (SELECT Product_ID FROM product
                     WHERE product.Product_Place = '广东');
-- 或者
SELECT orders.*
FROM orders JOIN product on orders.Product_ID = product.Product_ID
WHERE product.Product_Place = '广东';

-- （3）使用EXISTS关键字查询是否存在产地为“上海” 的商品订单信息，如果存在，查询所有订单信息。
SELECT *
FROM orders
WHERE EXISTS (SELECT *
            FROM product JOIN orders ON product.Product_ID = orders.Product_ID
            WHERE product.Product_Place = '上海');

-- （4）使用带ANY关键字的子查询，查询商品信息，其中子类别编号大于任一根类别编号为91的子类别编号。（使用product表和subsort表）
SELECT *
FROM product
WHERE SubSort_ID > ANY (SELECT SubSort_ID
                        FROM subsort
                        WHERE Sort_ID = 91);

-- （5）使用带ALL关键字的子查询，查询订单信息，其中商品编号要大于所有产地为“珠海”的商品编号，并按商品编号升序排列。（使用order表和product表）
SELECT *
FROM orders
WHERE Product_ID > ALL (SELECT Product_ID
                        FROM product
                        WHERE Product_Place = '珠海')
ORDER BY Product_ID;
