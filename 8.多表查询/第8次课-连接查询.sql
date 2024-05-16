use purchase;

-- 1.交叉连接：CROSS JOIN
/*语法：
SELECT * FROM 表1 CROSS JOIN 表2;
或者
SELECT * FROM 表1, 表2;

注意：需要注意的是，在实际开发中这种业务需求是很少见，一般不会使用交叉连接，而是使用具体的条件对数据进行有目的的查询。

*/

select count(*) from sort;
select count(*) from subsort;

-- 示例1：使用交叉连接，查询根类别表（sort表）和子类别表（subsort表）的所有数据.
SELECT * FROM sort CROSS JOIN subsort limit 35;
SELECT * FROM sort, subsort LIMIT 35;
SELECT * FROM sort INNER JOIN subsort LIMIT 35;
SELECT * FROM sort JOIN subsort LIMIT 35;

select count(*) from sort;
select count(*) from subsort;
select count(*) from sort, subsort;

-- 2.内连接: INNER JOIN
/*语法：
SELECT 查询字段 FROM 表1 [INNER] JOIN 表2 ON 表1.关系字段 = 表2.关系字段;
等价于
SELECT * FROM 表1 CROSS JOIN 表2 WHERE 表1.关系字段 = 表2.关系字段;
*/

-- 示例2：使用内连接，查询根类别表（sort表）和子类别表（subsort表）中的根类别名称和子类别名称。
SELECT *
FROM sort INNER JOIN subsort ON sort.Sort_ID = subsort.Sort_ID;

select count(*)
from subsort join sort on sort.Sort_ID = subsort.Sort_ID;

SELECT Sort_name, SubSort_name
FROM sort CROSS JOIN subsort ON sort.Sort_ID = subsort.Sort_ID;

SELECT Sort_name, SubSort_name
FROM sort JOIN subsort ON sort.Sort_ID = subsort.Sort_ID;

-- 示例3：使用交叉连接，结合where条件语句实现上例的内连接查询sort表和subsort表中的根类别名称和子类别名称。
SELECT *
FROM sort, subsort WHERE sort.Sort_ID = subsort.Sort_ID;

-- 3.外连接: LEFT | RIGHT [OUTER] JOIN
/*语法：
SELECT 所查字段 FROM 表1 LEFT|RIGHT [OUTER] JOIN 表2
ON 表1.关系字段 = 表2.关系字段 WHERE 条件
*/
select * from sort;

insert into sort
values (98, '其它');
-- 示例4：在sort表和subsort表之间使用左连接查询
SELECT *
FROM sort LEFT JOIN subsort ON sort.Sort_ID = subsort.Sort_ID 
ORDER BY sort.sort_id desc;

-- 示例5：在sort表和subsort表之间使用右连接查询
SELECT *
FROM sort RIGHT JOIN subsort ON sort.Sort_ID = subsort.Sort_ID ORDER BY Sort_name;


-- 示例6：利用左外连接和右外连接实现`sort`表和`subsort`表的全连接查询
SELECT *
FROM sort RIGHT JOIN subsort ON sort.Sort_ID = subsort.Sort_ID
UNION
SELECT *
FROM sort LEFT JOIN subsort ON sort.Sort_ID = subsort.Sort_ID;

/*`UNION`, `UNION ALL`都可以实现查询结构的并操作，不同之处在于`UNION`严格执行了集合并的概念，即剔除重复行；
`UNION ALL`不剔除重复行，保留两个表中的所有数据，例如：*/
SELECT * FROM SORT 
UNION 
SELECT * FROM SORT; -- 去重

SELECT * FROM SORT 
UNION ALL 
SELECT * FROM SORT;  -- 不去重

select a.sort_id, count(*)
from (SELECT * FROM SORT 
	UNION
	SELECT * FROM SORT) a
group by a.sort_id
order by a.sort_id;

-- 4. 复合条件连接查询

-- 示例7：在sort表和subsort表之间使用内连接查询，然后查询类别名称中有'文件'的记录，将查询结果按照Subsort_ID降序排列。
SELECT Sort_name, Subsort_ID, SubSort_name
FROM sort INNER JOIN subsort ON sort.Sort_ID = subsort.Sort_ID
WHERE sort_name LIKE '%文件%' ORDER BY Subsort_ID DESC;

SELECT Sort_name, Subsort_ID, SubSort_name
FROM sort INNER JOIN subsort ON sort.Sort_ID = subsort.Sort_ID AND Sort_name LIKE '%文件%'
ORDER BY Subsort_ID DESC;

SELECT a.sort_name, COUNT(b.subsort_id)
FROM sort a JOIN subsort b ON a.sort_id = b.sort_id AND Sort_name LIKE '%用品%'
GROUP BY a.sort_name
HAVING COUNT(b.subsort_id) > 5
ORDER BY COUNT(b.subsort_id) DESC
LIMIT 5;

-- 等价于
SELECT Sort_name, Subsort_ID, SubSort_name
FROM sort, subsort
WHERE sort.Sort_ID = subsort.Sort_ID AND sort_name LIKE '%文件%'
ORDER BY Subsort_ID DESC;


/*注意，条件定义在`ON`和`WHERE`子句中的区别：对内连接查询，两者无差异；对外连接查询，

- `ON`定义的条件对被驱动表的数据进行筛选，但不对驱动表的数据进行筛选
- `WHERE`则对驱动和被驱动表的数据同时刷选
*/

-- 内连接：执行结果相同
SELECT product_id, product_name, sort.sort_id, sort_name
FROM product JOIN sort ON product.sort_id = sort.sort_id
WHERE sort.sort_id >= 92
ORDER BY cast(product_id as unsigned) desc;

SELECT product_id, product_name, sort.sort_id, sort_name
FROM product JOIN sort ON (product.sort_id = sort.sort_id AND sort.sort_id >= 92)
ORDER BY cast(product_id as unsigned) desc;

-- 外连接：执行结果不同
SELECT count(*)
FROM product;

SELECT count(*)
FROM product LEFT JOIN sort ON product.sort_id = sort.sort_id
ORDER BY cast(product_id as unsigned) desc;  -- 表product中的部分数据未保留

-- sort.sort_id >= 92
SELECT product_id, product_name, product.sort_id, sort.sort_id, sort_name
FROM product LEFT JOIN sort ON product.sort_id = sort.sort_id
WHERE sort.sort_id >= 92
ORDER BY cast(product_id as unsigned) desc;  -- 表product中的部分数据未保留

SELECT product_id, product_name, product.sort_id, sort.sort_id, sort_name
FROM product LEFT JOIN sort ON (product.sort_id = sort.sort_id AND sort.sort_id >= 92)
ORDER BY cast(product_id as unsigned) desc;  -- 表product中的所有数据保留

-- 等价查询: product和sort表按sort_id进行内连接
-- 然后过滤sort_id大于92的记录, 最后与product表按product_id进行左连接
SELECT a.product_id, product_name, a.sort_id, b.sort_id, sort_name
FROM product a LEFT JOIN (SELECT Product_ID, sort.sort_id, sort_name
                        FROM product JOIN sort ON (product.Sort_ID = sort.sort_id and sort.sort_id >= 92)) b
    ON a.Product_ID = b.Product_ID
ORDER BY cast(a.product_id as unsigned) desc;

-- product.sort_id >= 92
SELECT product_id, product_name, product.sort_id, sort.sort_id, sort_name
FROM product LEFT JOIN sort ON product.sort_id = sort.sort_id
WHERE product.sort_id >= 92
ORDER BY cast(product_id as unsigned) desc;  -- 表product中的部分数据未保留

SELECT product_id, product_name, product.sort_id, sort.sort_id, sort_name
FROM product LEFT JOIN sort ON (product.sort_id = sort.sort_id AND product.sort_id >= 92)
ORDER BY cast(product_id as unsigned) desc;  -- 表product中的所有数据保留

SELECT a.product_id, product_name, a.sort_id, b.sort_id, sort_name
FROM product a LEFT JOIN (SELECT Product_ID, sort.sort_id, sort_name
                        FROM product JOIN sort ON (product.Sort_ID = sort.sort_id and product.sort_id >= 92)) b
    ON a.Product_ID = b.Product_ID
ORDER BY cast(a.product_id as unsigned) desc;

-- 补充1：自然连接--寻找量表中相同的字段进行等值连接，去除重复字段
/* 语法:
SELECT 字段列表 FROM 表1 natural join 表2
*/

-- 示例8：对表`sort`和`subsort`进行自然连接(剔除重复列)
select * from sort, subsort limit 5;

SELECT * FROM sort natural join subsort limit 5;

SELECT *
FROM sort JOIN subsort USING(sort_id) LIMIT 5;

SELECT *
FROM sort CROSS JOIN subsort USING(sort_id) LIMIT 5;

SELECT sort.sort_id, sort_name, subsort_id, subsort_name
FROM sort cross join subsort
WHERE sort.sort_id = subsort.sort_id limit 5;

-- 补充2: 多表间的连接

-- 示例9: 多表交叉连接
SELECT * FROM product join sort join subsort;

SELECT * FROM product, sort, subsort;

-- 示例10：多表自然连接
SELECT count(*)
FROM product natural join sort natural join subsort;

-- 示例11：多表内连接
SELECT count(*)
FROM product join sort join subsort on product.sort_id=sort.sort_id and sort.sort_id=subsort.sort_id;

SELECT count(*)
FROM product join sort join subsort
WHERE product.sort_id=sort.sort_id and sort.sort_id=subsort.sort_id;

-- 5. 子查询
-- 示例12：使用IN关键字, 查询子类别名“闹钟”对应的根类别信息。
select *
from product
where sort_id not in (select sort_id from sort);

select * from sort;

SELECT *
FROM sort
WHERE Sort_ID IN ( SELECT Sort_ID
                    FROM subsort
                    WHERE SubSort_name='闹钟');
-- 等价于
SELECT sort.Sort_ID, sort.Sort_name
FROM sort JOIN subsort ON sort.Sort_ID = subsort.Sort_ID
WHERE subsort.SubSort_name = '闹钟';

-- 示例13：使用EXISTS关键字，查询subsort表的sort_id（不）属于sort的所有记录。
SELECT EXISTS (SELECT Sort_ID
                FROM subsort
                WHERE SubSort_ID=99101);

select *
from subsort;

INSERT INTO subsort
SET subsort_id = 9601, SubSort_name='示例子类别', Sort_ID=96;

SELECT *
FROM subsort
WHERE NOT EXISTS (SELECT *
                FROM sort
                WHERE subsort.sort_id=sort.sort_id);

-- 等价于
SELECT l.*
FROM subsort l LEFT JOIN sort r on l.Sort_ID = r.sort_id
WHERE r.sort_id is null;


-- 示例14：使用带ANY关键字的子查询，查询满足以下条件的产地名称：对应单价大于产地为大连的任一产品价格。
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

-- 示例15：使用带ALL关键字的子查询，查询满足以下条件的产地名称：对应单价大于产地为大连的所有产品价格。
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

--
/*
DELETE table1
FROM table1 JOIN table2 ON table1.column1 = table2.column1
WHERE table2.column2 = 'value';

-- 或者
DELETE table1
FROM table1, table2
WHERE table1.column1 = table2.column1 AND table2.column2 = 'value';

-- 如需同时删除table1和table2对应的行，则
DELETE table1, table2
FROM table1 JOIN table2 ON table1.column1 = table2.column1
WHERE table2.column2 = 'value';
*/

-- 示例16: 删除`product`中与`sort`表的`sort_name`为'办公家具'对应的记录。

-- 方法1
set @@autocommit = 0;

select * from sort;

select *
from product
where sort_id IN (SELECT sort_id
                  FROM sort
                  WHERE sort_name = '文娱用品');

DELETE
FROM product
WHERE sort_id IN (SELECT sort_id
                  FROM sort
                  WHERE sort_name = '文娱用品');
rollback;
-- 方法2
DELETE product
FROM sort JOIN product ON sort.sort_id = product.sort_id
WHERE sort_name = '文娱用品';

-- 同时删除product, sort中的记录
DELETE product, sort
FROM sort JOIN product ON sort.sort_id = product.sort_id
WHERE sort_name = '文娱用品';

select * from sort where sort_name = '文娱用品';

rollback;

/*
在连接查询中，可以使用 `UPDATE` 语句更新一个或多个表中的数据行。如果要更新连接查询中的某个表的数据行，可以在 `UPDATE` 语句中指定要更新的表，并使用 `JOIN` 子句来连接其他表。下面是一个更新连接查询中某个表的数据行的示例：

```mysql
UPDATE table1 JOIN table2 ON table1.column1 = table2.column1
SET table1.column2 = 'new_value'
WHERE table2.column3 = 'value';

-- 或者
UPDATE table1, table2
SET table1.column2 = 'new_value'
WHERE table1.column1 = table2.column1 AND table2.column3 = 'value';

-- 如需同时更新两个表中的属性，只需在set后面写下对应属性
UPDATE table1, table2
SET table1.column2 = 'new_value', table2.column4 = 'new_value'
WHERE table1.column1 = table2.column1 AND table2.column3 = 'value';
```
在上述示例中，`UPDATE` 语句中指定了要更新的表 `table1`，并使用 `INNER JOIN` 子句连接了另一个表 `table2`。然后，使用 `SET` 子句来指定要更新的列和新值，其中 `table1.column2 = 'new_value'` 表示要将 `table1` 表中所有满足条件的 `column1` 和 `table2` 表中 `column3` 列为 `'value'` 的数据行的 `column2` 列的值更新为 `'new_value'`。
*/
-- 示例17: 更新`product`中与`sort`表的`sort_name`为'纸张'对应的产品价格，在原价格上涨价10%.


-- 方法1
SELECT Product_ID, Price
FROM product
WHERE sort_id IN (SELECT sort_id
                  FROM sort
                  WHERE sort_name = '纸张');

UPDATE product
SET price = 1.1 * price
WHERE sort_id IN (SELECT sort_id
                  FROM sort
                  WHERE sort_name = '纸张');
rollback ;
-- 方法2
UPDATE product JOIN sort ON product.sort_id = sort.sort_id
SET price = 1.1 * price
WHERE sort_name = '纸张';
rollback ;



/*思考：如何实现减和交操作
假定:
- 表`T_A`由`product`表中`sort_id=11`的`product_id, product_name, price`的行构成
- 表`T_B`由`product`表中`price大于1000`的`product_id, product_name, price`的行构成*/

CREATE TABLE t_a AS
SELECT product_id, product_name, price FROM product WHERE sort_id = 11;

CREATE TABLE t_b AS
SELECT product_id, product_name, price FROM product WHERE price > 1000;

select * from t_a;
select * from t_b;

-- 交
SELECT *
FROM t_a NATURAL JOIN t_b;

SELECT product_id, product_name, price
FROM t_a
WHERE (product_id, product_name, price) IN (SELECT product_id, product_name, price
	FROM t_b);

select l.*
from t_a l LEFT JOIN t_b r on l.product_id=r.product_id AND l.product_name=r.product_name AND l.price=r.price
where r.product_id is not null and r.product_name is not null and r.price is not null;

SELECT product_id, product_name, price
FROM t_a AS o
WHERE EXISTS(SELECT product_id
	FROM t_b
	WHERE product_id= o.product_id AND product_name=o.product_name AND price=o.price);

-- 减
SELECT product_id, product_name, price
FROM t_a
WHERE (product_id, product_name, price) NOT IN (SELECT product_id, product_name, price
	FROM t_b);

select l.*
from t_a l LEFT JOIN t_b r on l.product_id=r.product_id AND l.product_name=r.product_name AND l.price=r.price
where r.product_id is null and r.product_name is null and r.price is null;

SELECT product_id, product_name, price
FROM t_a AS o
WHERE NOT EXISTS(SELECT product_id
	FROM t_b
	WHERE product_id= o.product_id AND product_name=o.product_name AND price=o.price);

--
select product_id, product_name, price
from product
where sort_id = 11 and price > 1000;

select product_id, product_name, price
from product
where sort_id = 11 and price <= 1000;

-- 练习1
-- （1）使用内连接，查询product表和orders表中的订单号、订单时间、商品名称和商品数量。
SELECT product.Product_ID, Order_ID, Order_date, Product_Name, Quantity
FROM product INNER JOIN orders ON product.Product_ID = orders.Product_ID;
-- 等价于
SELECT product.Product_ID, orders.Order_ID, orders.Order_date, product.Product_Name, orders.Quantity
FROM product, orders
WHERE product.Product_ID = orders.Product_ID;
-- 别名
SELECT a.Product_ID, b.Order_ID, b.Order_date, a.Product_Name, b.Quantity
FROM product a, orders b
WHERE a.Product_ID = b.Product_ID;

-- （2）在product表和orders表之间使用左连接查询商品id、商品名称、订单号、订单时间和订单数量。
SELECT a.Product_ID, a.Product_Name, b.Order_ID, b.Order_date, b.Quantity
FROM product a LEFT JOIN orders b ON a.Product_ID=b.Product_ID;

-- （3）在product表和orders表之间使用右连接查询商品id、商品名称、订单号、订单时间和订单数量。
SELECT a.Product_ID, a.Product_Name, b.Order_ID, b.Order_date, b.Quantity
FROM product a RIGHT JOIN orders b ON a.Product_ID=b.Product_ID;

-- （4）在member表和orders表之间使用内连接查询订单号、订单时间、商品名id、商品数量和客户真实姓名，并按订单时间降序排列。
SELECT a.Order_ID, a.Order_date, a.Product_ID, a.Quantity, b.True_name
FROM orders a JOIN member b ON a.User_name = b.User_name
ORDER BY a.Order_date DESC;

-- （5）使用IN关键字查询商品产地为“广东”的商品订单信息。
SELECT *
FROM orders
WHERE Product_ID IN (SELECT Product_ID FROM product
                     WHERE product.Product_Place = '广东');
-- 或者
SELECT orders.*
FROM orders JOIN product on orders.Product_ID = product.Product_ID
WHERE product.Product_Place = '广东'
order by Order_ID;

-- （6）使用EXISTS关键字查询是否存在产地为“上海” 的商品订单信息，如果存在，查询所有订单信息。
SELECT *
FROM orders
WHERE EXISTS (SELECT *
            FROM product JOIN purchase.orders o on product.Product_ID = o.Product_ID
            WHERE product.Product_Place = '上海');

-- 查看商品产地为上海的订单信息
SELECT *
FROM orders
WHERE EXISTS (SELECT *
            FROM product
            WHERE product.Product_ID = orders.Product_ID and product.Product_Place = '上海');

SELECT o.*
FROM orders o LEFT JOIN purchase.product p on o.Product_ID = p.Product_ID
WHERE Product_Place = '上海';


-- 利用`exists`子句实现以下查询：若产品存在对应订单，则返回该产品的所有信息
SELECT *
FROM product p
WHERE EXISTS(
  SELECT product_id
  FROM `orders`
  WHERE product_id = p.product_id
);

SELECT p.*
FROM product p NATURAL JOIN `orders` o;

SELECT p.*
FROM product p
WHERE product_id IN (SELECT product_id FROM `orders`);

-- （7）使用`ANY`查询商品价格大于任一`sort_id`为11的商品价格的商品类别名称（使用`product`和`sort`）
SELECT distinct sort_id, sort_name
FROM product NATURAL JOIN sort
WHERE price > ANY(SELECT price FROM product WHERE sort_id=11);

-- （8）使用带ALL关键字的子查询，查询订单信息，其中商品编号要大于所有产地为“珠海”的商品编号，并按商品编号升序排列。（使用order表和product表）
SELECT *
FROM orders
WHERE Product_ID > ALL (SELECT Product_ID
                        FROM product
                        WHERE Product_Place = '珠海')
ORDER BY Product_ID;

SELECT price
FROM product
WHERE Product_Place = '珠海';