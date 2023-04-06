USE purchase;
-- （1）使用内连接，查询product表和orders表中的订单号、订单时间、商品名称和商品数量。
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

-- （2）在product表和orders表之间使用左连接查询商品id、商品名称、订单号、订单时间和商品数量。
SELECT a.Product_ID, a.Product_Name, b.Order_ID, b.Order_date, b.Quantity
FROM product a LEFT JOIN orders b ON a.Product_ID=b.Product_ID;

-- （3）在product表和orders表之间使用右连接查询商品id、商品名称、订单号、订单时间和商品数量。
SELECT a.Product_ID, a.Product_Name, b.Order_ID, b.Order_date, b.Quantity
FROM product a RIGHT JOIN orders b ON a.Product_ID=b.Product_ID;

-- （4）在member表和orders表之间使用内连接查询订单号、订单时间、商品名id、商品数量和客户真实姓名，并按订单时间降序排列。
SELECT a.Order_ID, a.Order_date, a.Product_ID, a.Quantity, b.True_name
FROM orders a JOIN member b ON a.User_name = b.User_name
ORDER BY a.Order_date desc;

-- （5）使用IN关键字查询商品产地为“广东”的商品订单信息。
SELECT *
FROM orders
WHERE Product_ID IN (SELECT Product_ID FROM product
                     WHERE product.Product_Place = '广东');
-- 或者
SELECT orders.*
FROM orders JOIN product on orders.Product_ID = product.Product_ID
WHERE product.Product_Place = '广东';

-- （6）使用EXISTS关键字查询是否存在产地为“上海” 的商品订单信息，如果存在，查询所有订单信息。
SELECT *
FROM orders
WHERE EXISTS (SELECT *
            FROM product JOIN orders ON product.Product_ID = orders.Product_ID
            WHERE product.Product_Place = '上海');
-- 利用`exists`子句实现以下查询：若产品有订单，则返回该产品的所有信息
SELECT *
FROM product p
WHERE EXISTS(
  SELECT product_id
  FROM `order`
  WHERE product_id = p.product_id
);

SELECT p*
FROM product p NATURAL JOIN `order` o;

SELECT p.*
FROM product p
WHERE product_id IN (SELECT product_id FROM `order`);

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

select *
from sort
where sort_id not in (select distinct sort_id from subsort);

select *
from sort
where sort_id in (select distinct sort_id from subsort);