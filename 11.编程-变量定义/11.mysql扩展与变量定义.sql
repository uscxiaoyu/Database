-- 一、衍生列（generated column）
/*
在基础列的上，通过一定的运算转换而定义生成的列，即为衍生列。
CREATE TABLE <t_name> (
	col1 <col_type>,
    g_col <col_type> GENERATED ALWAYS AS (<computation on col1>) [stored]
    );

-- 有两种类型的衍生列：stored和virtual。如果不给定，则vitual。stored 意味着有物理空间直接存储生成列的值，可以在上面建立索引；
virtual意味着在查询该字段时生成对应的列值，不能直接在其上建立索引。

生成列的构建可包含字面量、确定性内建函数和操作符、基本列、创建于其前的生成列。

以下不允许出现在生成列定义中：
- 不确性内建函数如current_date(), current_timestamp()等
- 用户自定义存储过程，系统、用户、局部变量等
- 子查询
- 在其后定义的生成列
- auto_increment

使用create table ... like 可保留原表中的生成列定义；使用create table ... select则不能。

生成列不能作为被参照列。

生成列的使用场景：

- 简化和整合查询。复杂条件可通过生成列表示，查询可直接指向该列，从而保证查询条件的一致性。
- 作为复杂条件或运算的物化存储，提前缓存，从而减少查询时间
- 模拟函数索引，如可在json列中的某些子属性创建生成列，进而构建索引。（缺点在于，该属性数据将存储两次）
- 查询优化器可识别出使用了生成列定义的查询，从而可利用创建在生成列上的索引，即便该查询未直接使用该列。
*/

use purchase;

drop table if exists person;
CREATE TABLE person(
	id int primary key,
    first_name varchar(20) not null,
    last_name varchar(20) not null,
    `name` varchar(50) generated always as (concat(first_name, ' ', last_name)) stored,
    index idx_name (`name`));

show create table person;

alter table person modify `name` varchar(50) generated always as (concat(first_name, ' ', last_name)) stored;

show create table person;

delete from person;

insert into person(id, first_name, last_name)
values (1, 'Mike', 'James');

select * from person;

drop table t1;
CREATE TABLE t1 (
  first_name VARCHAR(10),
  last_name VARCHAR(10),
  full_name VARCHAR(255) AS (CONCAT(first_name,' ',last_name)),
  index idx_name(full_name)
);

show create table t1;

CREATE TABLE jemp (
	c JSON,
	g INT GENERATED ALWAYS AS (c->"$.id"),
INDEX i (g));

insert into jemp (c)
values ('{"id": 1, "name":"John"}');

select * from jemp;

-- 二、REPLACE`: 插入或更新
/*
基本语法：
REPLACE INTO tbl_name
    [PARTITION (partition_name [, partition_name] ...)]
    [(col_name [, col_name] ...)]
    {VALUES | VALUE} (value_list) [, (value_list)] ...

REPLACE INTO tbl_name
    [PARTITION (partition_name [, partition_name] ...)]
    SET assignment_list

REPLACE INTO tbl_name
    [PARTITION (partition_name [, partition_name] ...)]
    [(col_name [, col_name] ...)]
    SELECT ...

value:
    {expr | DEFAULT}

value_list:
    value [, value] ...

assignment:
    col_name = value

assignment_list:
    assignment [, assignment] ...
*/


Drop table if exists p;

CREATE TABLE p (p_id char(5) primary key,
               p_name varchar(50) unique,
               price decimal(7, 2) not null default 0);
replace into p
values(1, 'a', 1.2), (2, 'b', 5.0); -- 插入

select * from p;

replace into p (p_id, p_name, price)
values(1, 'a', 3); -- 更新p_id值为1，p_name为'a'的行的price值为3

replace into p (p_id, p_name, price)
values(3, 'c', 3.0); -- 相当于insert into

replace into p (p_id, p_name, price)
values(3, 'f', 5), (4, 'e', 8); -- 相当于update和insert into

-- 小心以下更新
replace into p (p_id, p_name, price)
values(3, 'e', 6); -- 更新p_id值为3的行(3, 'f', 3) -> (3, 'e', 6)；更新p_name为'e'的行(4, 'e', 8) -> (3, 'e', 6), 然后去重.

-- 三、临时表
/*
如果需要保存一些查询的中间结果，可以使用临时表`temporary table`。用户在某一次会话（session）中创建的临时表只在该次会话可见，
会话结束时临时表也将自动删除。因此，两个不同的会话可以在同一个数据库中创建相同名称的临时表。注意，临时表的名称可以与正式表相同，
此后数据操作涉及该表名时将优先选择临时表。注意，临时表上不能创建索引。
*/
CREATE TEMPORARY TABLE temp_product (product_id int primary key,
                                     product_name varchar(50),
                                     price decimal(7, 2));

SHOW CREATE TABLE temp_product;
SHOW TABLES;
DROP TEMPORARY TABLE temp_product;

CREATE TEMPORARY TABLE product AS SELECT * FROM product LIMIT 10;
SHOW CREATE TABLE product;

select * from product;
drop temporary table product;

-- 四、变量定义
use purchase;
-- 1. 编程中涉及的数据类型
select @a;

-- 1.1 字符串常量
select 'I\'m a \teacher' as coll, "you're a stude\nt" as col2; -- MySQL推荐使用单引号表示字符串

-- 1.2 数值常量
select 123 as number;

-- 1.3 日期时间常量
select now() as now;
select year(now()), month(now()), day(now()), hour(now()), minute(now()), second(now()) as t_day;

-- 1.4 布尔值
select true, false;

-- 1.5 二进制
select 0b111001, b'111001';

select CONV('10', 10, 2);   -- 10进制转化为2进制 
select bin(8);  -- 把10进制数转化为2进制

-- 1.6 十六进制
select x'41', x'4D7953514C';
select 0x41, 0x4d7953514c;

select CONV('42', 10, 16);   -- 10进制转化为16进制
select hex(42), hex(16);  -- 把10进制数转化为16进制

-- 1.7 null
select null, null > 1;  -- null与任何值进行比较的结果为null

show processlist;
select connection_id();
-- 2. 用户自定义变量
show variables like "%character%";

-- 系统变量
select @@autocommit;
select @@sql_mode;
select @@character_set_database;

-- 2.1 用户会话变量
-- 方法1：set
set @user_name = '张三'; -- 变量数据类型由等号右边表达式的计算结果决定
set @user_name := '张';
select @user_name;

set @user_name = b'11', @age = 18;  -- 同时定义多个变量
select @user_name, @age;

set @age = @age * 3 + 1;  -- 对变量进行更新
select @age;

-- 方法2：select
/*
有两种语法格式：
第一种：select @user_variable1 := expression1 [, @user_variable2 := expression2, ...];
第二种：select experession1 into @user_variable1, experession2 into @user_variable2, ...;

注意和set定义变量的区别：用set定义变量时，直接使用'='；用select定义变量时，使用':='
*/

-- (1) 使用 变量名称 := 变量值

-- 课堂示例1: 使用 变量名称 := 变量值, 定义用户变量a，将其赋值为'b'
select @a := 'b';  -- 用户定义变量a，赋值为'b'
select @a;

-- 注意: := 和 = 的区别
select @a = 'a';  -- 用户定义变量a与'a'进行等值比较的结果，如果a之前定义了，则返回1或0；如果a之前未被定义，则返回null
select @a;

-- (2) 使用 select 变量值 into @变量名称;

-- 课堂示例2：使用 select 变量值 into @变量名称，定义用户变量user_name，赋值为'张三'
select '张三', 19 into @user_name, @age;
select @user_name, @age;

-- 2.2 使用用户会话变量保存sql查询结果
use purchase;
-- 课堂示例3：将product表中的记录数赋值给用户会话变量@product_count
-- 方法1: set @变量名 = select语句
set @product_count = (select count(*) from Product where product_id is not null);
select @product_count as 产品数量;
-- 注意：返回值需要唯一
set @product_count = (select sort_id from Product where product_id is not null group by sort_id);

-- 方法2: select @变量名 := select语句
select @product_count2 := (select count(*) from Product);
select @product_count2 as 产品数量;

-- 方法3: select @变量名 := 聚合函数 from 表
select @product_count3 := count(*) from Product;
select @product_count3 as 产品数量;

-- 方法4：select 聚合函数 into @变量名 from 表
select count(*) into @product_count4 from Product;
select @product_count4 as 产品数量;

-- 方法5：select 聚合函数 from 表 into @变量名
select count(*) from Product into @product_count5;
select @product_count5 as 产品数量;

/*
注意into和:=的区别
*/
select @a:=sort_id from product;  -- 成功，每返回一行，给@a赋值一次
select @a:= (select sort_id from product);  -- 失败，返回多行

select sort_id into @a from product;  -- 失败
select sort_id from product into @a;  -- 失败

-- 课堂示例4: 通过定义用户变量查询product表中的特定行
set @product_code = '1101001';
select * from Product where product_code = @product_code;

select * from Product where product_code = '1101001';

-- 示例5：通过自定义变量查询sort_name为纸张的所有产品信息
select * from sort;
select sort_id into @v_sortid from sort where sort_name = '纸张' limit 1;
select * from product where sort_id = @v_sortid;

select product.* from product join sort on product.sort_id = sort.sort_id
where sort_name = '纸张';

-- 示例6：从`product`表所有记录奇数行构成的集合。
-- 用户会话变量
SELECT row_num, product_id, product_name, price
FROM (SELECT @row_num := @row_num + 1 AS row_num, product_id, product_name, price
	FROM product, (SELECT @row_num := 0) AS r
	order by cast(product_id as unsigned) desc) AS b_product
WHERE row_num mod 2 != 0;

-- 窗口函数
SELECT row_num, product_id, product_name, price
FROM (
    SELECT
        ROW_NUMBER() OVER (ORDER BY CAST(product_id AS unsigned) desc) AS row_num,
        product_id,
        product_name,
        price
    FROM
        product
) AS b_product
WHERE row_num MOD 2 != 0;


SELECT @row_num := @row_num + 1 AS row_num, product_id, product_name, price
FROM product, (SELECT @row_num := 0) AS r
order by price desc;

select @row_num := 0;

-- 解析
SELECT *
from product, (select @row_num := 0) r;

select *
FROM product, (SELECT @row_num := 0) AS r;

select * from product where product_id is null;

SELECT @row_num := 0;

select @row_num := @row_num + 1;

select @row_num;

/*查询各sort_id下产品类别数量排名前5的subsort_id，
返回sort_id, subsort_id, 产品数量, 类别内排名*/
select sort_id, subsort_id, num_product, 排名
from (select sort_id, subsort_id, num_product, 
            if(sort_id = @last_sort_id, 
               if(num_product = @last_num_product, @r, @r := @r+1), 
               @r := 1) 排名,
            @last_sort_id := sort_id,
            @last_num_product := num_product
      from (select sort_id, subsort_id, count(*) num_product
            from product
            group by sort_id, subsort_id
            order by sort_id, num_product desc) x, (select @r:=null, @last_sort_id:=null, @last_num_product:=null) r) a
where 排名 <= 5; # @last_sort_id和@last_num_product分别上一行记录值，有些数量的相同的排名应该相同

select sort_id, subsort_id, num_product, 排名
from (select sort_id, subsort_id, num_product,
            if(sort_id = @last_sort_id,
               if(num_product = @last_num_product, @r, @r := @r+1),
               @r := 1) 排名,
            @last_sort_id := sort_id,
            @last_num_product := num_product
      from (select sort_id, subsort_id, count(*) num_product
            from product
            group by sort_id, subsort_id
            order by sort_id, num_product desc) a) x
where 排名 <= 5;

-- 另一种思路
-- step 1
select a.sort_id, b.subsort_id, count(*) num_product
from sort a left join subsort b on a.sort_id=b.sort_id left join product c on b.subsort_id=c.SubSort_ID
group by a.sort_id, b.SubSort_ID
order by a.sort_id, num_product desc;

-- step 2
select if(@vsortid=sort_id, @row_num:=@row_num + 1, @row_num:=1) `rank`, @vsortid := sort_id, u.*
from (select a.sort_id, b.subsort_id, count(*) num_product
	from sort a left join subsort b on a.sort_id=b.sort_id left join product c on b.subsort_id=c.SubSort_ID
	group by a.sort_id, b.SubSort_ID
	order by sort_id, num_product desc) u, (select @vsortid:=null, @row_num:=null) v;

-- step 3
select sort_id, subsort_id, num_product, `rank`
from    
(select if(@vsortid=sort_id, @row_num:=@row_num + 1, @row_num:=1) `rank`, @vsortid := sort_id, u.*
	from (select a.sort_id, b.subsort_id, count(*) num_product
		from sort a left join subsort b on a.sort_id=b.sort_id left join product c on b.subsort_id=c.SubSort_ID
		group by a.sort_id, b.SubSort_ID
		order by a.sort_id, num_product desc) u, (select @vsortid:=null, @row_num:=null) v) x
where `rank` <=5;

-- mysql 8.0 以上版本可以利用窗口函数实现
select t.*
from (select sort_id,
       subsort_id,
       count(product_id) as num_product,
       dense_rank() over (partition by sort_id order by avg(price) desc) as 平均价格排名,
       dense_rank() over (partition by sort_id order by count(product_id) desc) as 产品类别排名
    from product
    group by sort_id, subsort_id) t
where 产品类别排名 <= 5;

-- 或者使用CTE实现
WITH ProductCounts AS (
    SELECT
        sort_id,
        subsort_id,
        COUNT(*) as num_product
    FROM product
    GROUP BY sort_id, subsort_id
)
SELECT *
FROM (SELECT
        sort_id,
        subsort_id,
        num_product,
        DENSE_RANK() OVER (PARTITION BY sort_id ORDER BY num_product DESC) as 排名
    FROM ProductCounts) x
WHERE 排名 <= 5;

-- 3. 运算符
-- 算术
set @num=15;
select @num + 2, @num - 2, @num * 3, @num / 3;
select @num % 2;
select @num + null, @num - null, @num * null, @num / null, @num % null;
select @num / 0, @num % 0;
select '2012-12-21' + interval '50' day;
select '2012-12-21' - interval '50' day;  -- 2012年12月21日减去50天

select pow(3, 10);

-- 比较
select 'ab '='ab', ' ab'='ab', 'b'>'a';
select '1' = 1, '1' > 0, 1 > '0', '1' > '0';
select null = null, null < null, null is null, null is not null;
select null > 1, null < 1, null = 1;
select null != null, null <> null;
select 'b' between 'a' and 'c';
select 10 not between 5 and 9;
select 1 in (1, 2, 'a');
select 1 not in (1, 2, 'a');
select isnull(null); -- 函数
select 'stud' like 'stud', 'stud' like 'stu_', 'stud' like 'st%';
select 'student' regexp '^t', 'student' regexp '[a-z]'; -- 正则是否匹配模式

-- 逻辑
select 1 and 2, 2 and 0, 2 and true, 0 or true, not 2, not false;
select 1 && 2, 2 && 0, 2 && true, 0 || true, ! 2, ! false;
select null && 2, null || 2, ! null;

select 1 and 0 or 1; -- 运算优先级, 先运算and，后运算or
select 0 or 0 and 1;
select not 1 or 0 and 1;

-- 五、prepared statement 预处理语句
/*
`MySQL5.7`提供了服务器端的预处理语句，有以下优点：

- 预先在服务器端一次定义好语句，产生优化好的执行计划，后面使用的时候只需传递相关参数即可，因此减少了网络传输负担
- 防止`SQL`注入攻击，预处理语句可传输非字符串变量。

定义：`PREPARE <statement_name> FROM '<SQL>'`

> `<SQL>`中的变量用`?`替代，以下`SQL`可以定义在预处理语句的sql字符串中:
>
> - ALTER TABLE 
> - ALTER USER 
> - INSERT
> - SELECT
> - UPDATE
> - DELETE
> - TRUNCATE
> - SET
> - RENAME TABLE
> - {CREATE | RENAME | DROP} DATABASE
> - {CREATE | DROP} TABLE
> - {CREATE | RENAME | DROP} USER 
> - {CREATE | DROP} VIEW
> - SHOW CREATE {PROCEDURE | FUNCTION | EVENT | TABLE | VIEW}
> - ...

执行：`EXECUTE <statement_name> USING @v1, @v2,....`

解绑：`DEALLOCATE  PREPARE <statement_name>`
*/
-- 示例7：定义预处理语句“选取价格大于某一值的所有记录”
prepare stmt_select from "select product_id, product_place, price from product where price > ? order by price";

set @n = 100;
execute stmt_select using @n;

deallocate prepare stmt_select;
/*
注意，`prepare statement`是用户会话级别定义的，即如果未解绑一个`prepare statement`，则在用户中断会话时将自动解绑。
*/

-- 示例8：定义预处理语句“插入产品编号、名称和价格至产品表”
prepare stmt_insert from "insert into product set product_id=?, product_name=?, price=?";

set @pid=9999, @pname='矿泉水', @price=2;
execute stmt_insert using @pid, @pname, @price;

select * from product where product_id =9999;
deallocate prepare stmt_insert;


-- 练习
CREATE TABLE budget(
      项目编号 int primary key,
      项目名称 VARCHAR(50) NOT NULL,
      交通费 DECIMAL(6, 2) NOT NULL DEFAULT 0,
      会议费 DECIMAL(6, 2) NOT NULL DEFAULT 0,
      打印费 DECIMAL(6, 2) NOT NULL DEFAULT 0,
      办公用品费 DECIMAL(6, 2) NOT NULL DEFAULT 0,
      总预算 DECIMAL(7, 2) GENERATED ALWAYS AS (交通费+会议费+打印费+办公用品费) VIRTUAL);

drop table if exists budget;
