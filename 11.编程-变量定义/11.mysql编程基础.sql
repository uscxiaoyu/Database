use purchase;
-- 1. 编程中涉及的数据类型
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

-- 课堂练习1:
-- (1) 请完成课堂示例

-- (2) 将十进制数1239分别转换为二进制和十六进制数
select conv(1239, 10, 2), conv(1239, 10, 16);

-- 2. 用户自定义变量
-- 2.1 用户会话变量
-- 方法1：set
set @user_name = '张三'; -- 变量数据类型由等号右边表达式的计算结果决定
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
set @product_count = (select count(*) from Product);
select @product_count as 产品数量;

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

-- 课堂示例4: 通过定义用户变量查询product表中的特定行
set @product_code = '1101001';
select * from Product where product_code = @product_code;

select * from Product where product_code = '1101001';

-- 课堂示例16：通过自定义变量查询sort_name为纸张的所有产品信息
select * from sort;
select sort_id into @v_sortid from sort where sort_name = '纸张';
select * from product where sort_id = @v_sortid;

select product.* from product join sort on product.sort_id = sort.sort_id
where sort_name = '纸张';

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
select 'student' regexp '^s', 'student' regexp '[a-z]'; -- 正则是否匹配模式


-- 逻辑
select 1 and 2, 2 and 0, 2 and true, 0 or true, not 2, not false;
select 1 && 2, 2 && 0, 2 && true, 0 || true, ! 2, ! false;
select null && 2, null || 2, ! null;

select 1 and 0 or 1; -- 运算优先级, 先运算and，后运算or
select 0 or 0 and 1;
select not 1 or 0 and 1;

-- 4. 重新定义命令结束符
delimiter $$
select 1;
select 2;

delimiter ;

-- 课堂练习2
-- (1) 完成课堂示例
-- (2) 使用课堂示例3中的5种方法，分别定义用户变量count_member1, count_member2, count_member3, count_member4, count_member5，保存member表中的记录数
set @count_member1 = (select count(*) from Member);
select @count_member1;

set @count_member2 := (select count(*) from Member);
select @count_member2;

select @count_member3 := count(*) from Member;
select @count_member3;

select count(*) into @count_member4 from Member;
select @count_member4;

select count(*) from Member into @count_member5;
select @count_member5;