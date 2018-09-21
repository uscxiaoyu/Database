use purchase;

-- 查询各产地的平均价格

select 
	product_id, product_name, product_place, price, 
    AVG(price) OVER (partition by product_place) AS avg_price
from product
where product_place is not null
order by product_place, price;


select 
	product_id, product_name, product_place, price, 
    AVG(price) OVER w AS avg_price
from product
where product_place is not null
window w as (partition by product_place)  -- 定义窗口w
order by product_place, price;  

-- 查看各产品价格在所有产地的排名
select 
	product_id, product_name, product_place, price, 
    rank() OVER (order by price) AS price_rank
from product
where product_place is not null
order by product_place, price;

select 
	product_id, product_name, product_place, price, 
    row_number() OVER w AS `row_number`,
    rank() OVER w AS `price_rank`,
    dense_rank() OVER w AS `dense_rank`,
    first_value(price) OVER w AS `first_value`,
    last_value(price) OVER w AS `last_value`,
from product
where product_place is not null
window w as (order by price)
order by product_place, `row_number`, price;

-- 查看各产地各产品价格在该产地的排名
select 
	product_id, product_name, product_place, price, 
    rank() OVER w AS price_rank, 
from product
where product_place is not null
window w as (partition by product_place order by price desc)
order by product_place, price;

