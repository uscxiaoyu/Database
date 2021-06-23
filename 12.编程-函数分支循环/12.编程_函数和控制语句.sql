-- 1. 用户自定义函数
/*语法结构：
create function <func_name> (param1, param2, ...) returns data type
[funciton options]
begin
body;
return sentence;
end;

创建自定义函数时，不能与已有的函数名（包括系统名）重复。建议在自定义函数名中统一添加‘fn_’或者后缀‘_fn’。
函数的参数无需使用declare命令定义，但它仍属于局域变量，且必须提供参数的数据类型。自定义函数如果没有参数，则使用空参数“（）”即可。
函数必须制定返回值的数据类型，且需与return预计中的返回值的数据类型相近（长度可以不同）。

function options:
language sql： 默认选项，用于说明函数体用sql编写。
| [not] deterministic：如果对相同输入得到相同输出结果，则为deterministic，否则为not deterministic(默认值)
| {contains sql ：编码函数体不包含读或写数据的语句（如set） （默认值）
	| no sql ： 表明函数体中不包含sql语句
    | reads sql data ： 包含select查询
    | modifies sql data ：包含update
   }
| sql security 用于指定函数的执行许可
	{ definer 表明函数只能有创建者调用
		| invoker 表明函数可以被其它创建者调用 （默认值）
	}
| comment： 注释
*/
use purchase;
-- 示例1: 定义查询行号：
/*每返回一行，行号+1*/
drop function if exists row_no_fn;

delimiter $$
create function purchase.row_no_fn () returns int
	no sql
	begin
		set @row_no = @row_no + 1;
		return @row_no;
	end;
$$ -- 忘记加上去
delimiter ;

show function status where db='purchase';

set @row_no = 0;
select row_no_fn() as '序号', product_id, product_name, Product_Place 
from Product 
limit 10;

select count(*)
from product;

-- 执行结果等价于
SELECT @row_no := @row_no + 1 as '行号', product_id, product_name, Product_Place
FROM product, (SELECT @row_no := 0) as r
LIMIT 10;

-- 示例2: 定义函数get_product_number_fn, 输入类别编号，输出该类别下的产品数量
drop function if exists get_sum_product_fn;
delimiter $$
create function get_sum_product_fn (p_sortid char(2)) returns int
	reads sql data
	begin
		declare count_number int;
		select count(*) into count_number from Product where sort_id=p_sortid;
		return count_number;
	end;
$$
delimiter ;

select * from Sort;
set @v_sortid = '11';
select @v_sortid as 类别编号, get_sum_product_fn(@v_sortid) as 产品数量;

select sort_id, get_sum_product_fn(sort_id)
from sort;

select sort_id, count(*)
from product
where sort_id is not null
group by sort_id;

-- 示例3: 定义函数get_sum_sort_fn，输入产品编号，返回其产品类别下子类别的数量
drop function if exists get_sum_sort_fn;
delimiter $$
create function get_sum_sort_fn (p_productid char(5)) returns int -- 若在参数中定义varchar，则需提供具体的长度；return和returns类型要一致
	reads sql data  -- 函数需通过sql读取数据
	begin
	  declare v_sortid char(2); 
	  declare v_subsortid int; -- 定义变量，用于存储子类别数量
	  select sort_id into v_sortid from Product where product_id = p_productid;
	  select count(subsort_id) into v_subsortid from SubSort where sort_id = v_sortid;
	  return v_subsortid;
	end;
$$
delimiter ;

select get_sum_sort_fn('1001') as 子类别数量;

select product_id, get_sum_sort_fn(product_id)
from product limit 10;

-- 示例4: 查看用户定义的函数
show function status where definer='root@localhost';  -- 查看某个用户定义的函数
show function status where db='purchase'; -- 查看某个数据库中的函数
show function status where name like 'get_sum%';  -- 查看名称包含get_sum的函数

-- 示例5: 查询完整的函数定义语句
show create function get_sum_sort_fn;
show create function get_sum_product_fn;
  
-- 二. 基本语句

-- 1. if语句
/* 基本语法
If 条件表达式1 then 语句块1;
[elseif 条件表达式2 then 语句块2];
...
[else 语句块n]
end if;
*/

-- 示例6: 创建函数f, 输入x，如果x<0，计算y=-x;如果x>=0，计算y=x*2，返回y
drop function if exists f;
delimiter $$
create function f(x float) returns float
no sql
begin
	declare y float;
	if (x < 0) then
		set y = -x;
	else
		set y = x * 2;
	end if;
	return y;
end;
$$
delimiter ;

select f(5);

-- 示例7: 创建函数change_price_fn,输入产品编号product_id，根据sort_id的值计算并返回返利: sort_id为11的产品返利为价格的10%， sort_id为21的产品的产品返利为价格的30%，
-- sort_id为31的产品返利为价格的40%, 其它返回为5%。
drop function if exists cal_rebate_fn;
delimiter $$
create function cal_rebate_fn (v_p_id char(6)) returns decimal(10,2)
reads sql data
begin
	declare v_sortid char(2);
	declare v_rebate decimal(10, 2);
	select sort_id into v_sortid from product where product_id = v_p_id;
	if (v_sortid='11') then
		select price * 0.1 into v_rebate from product where product_id = v_p_id;
	elseif (v_sortid='21') then
		select price * 0.3 into v_rebate from product where product_id = v_p_id;
	elseif (v_sortid='31') then
		select price * 0.4 into v_rebate from product where product_id = v_p_id;
	else
		select price * 0.05 into v_rebate from product where product_id = v_p_id;
	end if;
	return v_rebate;
end;
$$
delimiter ;

-- 查询前5条记录的返利情况
select product_id, sort_id, price, cal_rebate_fn(product_id) as rebate
from product limit 5;

-- 2. case 语句
/*语法：
case 表达式
when value1 then 语句块1;
when value2 then 语句块2;
...
when value1 then 语句块n-1;
else 语句块n;
end case;
*/

-- 示例8: 创建get_week_fn()函数，使用该函数根据mysql系统时间打印星期几
delimiter $$
create function get_week_fn (p_date date) returns char(20)
no sql
begin
	declare week_day char(20);
	case weekday(p_date)
		when 0 then set week_day = 'Monday';
		when 1 then set week_day = 'Tuesday';
		when 2 then set week_day = 'Wednesday';
		when 3 then set week_day = 'Thursday';
		when 4 then set week_day = 'Friday';
		else set week_day = 'Weekend';
	end case;
	return week_day;
end;
$$
delimiter ;

drop function get_week_fn;

select weekday(now());

select product_id, product_name, product_date, get_week_fn(product_date) as `week`
from Product
limit 10;

-- 2. 循环

-- 2.1 while

/*
当条件表达式为true时，反复执行循环体，直到表达式值为false。语法结构：
[循环标签:] while 条件表达式 do
循环体;
end while [循环标签];
*/

-- 示例9：创建函数get_sum_fn，返回整数1到n的累加和
drop function if exists get_sum_fn;

delimiter $$
create function get_sum_fn (n int) returns int
no sql
begin
	declare accum_sum int default 0;
  	declare start_num int default 0;
  	a: while start_num < n do
		set start_num = start_num + 1;
        set accum_sum = start_num + accum_sum;
	end while a;
	return accum_sum;
end;
$$
delimiter ;

select get_sum_fn(100);

-- 2.2 leave
/* 用于跳出当前的循化语句。语法：
leave 循环标签;
*/

-- 示例10：基于leave语句，创建函数get_sum_fn2，返回整数1到n的累加和
delimiter $$
create function get_sum_fn2 (n int) returns int
no sql
begin
	declare accum_sum int default 0;
  	declare start_num int default 0;
  	add_num : while true do
	set start_num = start_num + 1;
  	set accum_sum = start_num + accum_sum;
  	if (start_num = n) then
			leave add_num;
	end if;
	end while add_num;
	return accum_sum;
end;
$$
delimiter ;

select get_sum_fn2(100);

-- 2.3 iterate
/* 用于跳出本次循环，继续下次循环。语法：
iterate 循环标签;
*/

-- 示例11：基于iterate，对1~n所有能被3整除的数加和
delimiter $$
create function get_sum_fn3 (n int) returns int
no sql
begin
	declare accum_sum int default 0;
  	declare start_num int default 0;
  	add_num : while true do
	set start_num = start_num + 1;
    if start_num <= n then
			if (start_num % 3) != 0 then
				iterate add_num;
			end if;
			set accum_sum = accum_sum + start_num;
	else 
		leave add_num;
    end if;
	end while add_num;
  	return accum_sum;
end;
$$
delimiter ;

select get_sum_fn3(100);

-- 2.4 repeat
/*当条件表达式的值为false时，反复执行循环，直到条件表达式的值为true。语法：
[循环标签:]repeate
循环体;
until 条件表达式
end repreat[循环标签];

*/

-- 示例12：基于repeat，实现从1加到n
delimiter $$
create function get_sum_fn4 (n int) returns int
no sql
begin
	declare accum_sum int default 0;
	declare start_num int default 0;
	repeat
		set start_num = start_num + 1;
    set accum_sum = start_num + accum_sum;
	until (start_num = n) end repeat;
  	return accum_sum;
end;
$$
delimiter ;

drop function get_sum_fn4;

select get_sum_fn4(100);

-- 2.5 loop
/* loop通常借助leave语句跳出loop循环。语法：
[循环标签:]loop
循环体;
if 条件表达式 then
	leave [循环标签];
end if;
end loop;

*/

-- 示例13：基于loop，实现从1加到n
delimiter $$
create function get_sum_fn5 (n int) returns int
no sql
begin
	declare accum_sum int default 0;
	declare start_num int default 0;
	add_sum : loop
		set start_num = start_num + 1;
    set accum_sum = start_num + accum_sum;
    if start_num = n then
			leave add_sum;
		end if;
	end loop;
  return accum_sum;
end;
$$
delimiter ;

drop function get_sum_fn5;

select get_sum_fn5(100);

-- 练习1

-- 1.定义函数get_product_number_fn, 输入产地名称，输出该产地下的产品类别数量
drop function if exists get_product_number_fn;
delimiter $$
create function get_product_number_fn (p_place varchar(255)) returns int
	reads sql data
	begin
		declare count_prod int;
		select count(*) into count_prod from product where Product_Place = p_place;
		return count_prod;
	end;
$$
delimiter ;
select get_product_number_fn('上海');

-- 2.定义函数get_member_num_fn，输入省份，返回该省份中的用户数量; 然后查看该函数的定义
select * from member;
desc member;
drop function if exists get_member_num_fn;
delimiter $$
create function get_member_num_fn (p_province char(10)) returns int
	reads sql data
	begin
	  declare v_count int;
	  select count(*) into v_count
	  from member
	  where address like concat(p_province, '%');  -- 利用正则匹配省份
	  return v_count;
	end;
$$
delimiter ;
set @province = '广东';
select @province as 省份, get_member_num_fn(@province) as 会员人数;

show create function get_member_num_fn;

-- 练习2
-- (1) 创建函数func, 输入x，当x < -5时，y = x ** 3; 当 -5 <= x < 5 时， y = x; 当 x >= 5 时，y = 2 * x + 1，返回y
delimiter $$
create function func(x float) returns float
no sql
begin
	declare y float;
	if (x < -5) then
		set y = power(x, 3);
	elseif (x >= 5 and x < 5) then  -- 注意用and运算符
		set y = x;
	else
		set y = 2 * x + 1;
	end if;
	return y;
end;
$$
delimiter ;

select func(10);

-- (2) 创建函数cal_due_fn，输入订单号，计算该订单折扣后对应的应付款p_due，价格计算方式如下：如果产品数量(quantity)小于10，则p_due = 产品单价 * 数量 * 0.95;
-- 如果数量在10和50之间，则p_due = 产品单价 * 数量 * 0.9; 如果数量大于50，则p_due = 产品单价 * 数量 * 0.8.
drop function if exists cal_due_fn;
delimiter $$
create function cal_due_fn (v_o_id char(50)) returns decimal(10, 2)
reads sql data
begin
	declare v_p_price decimal(10, 2) default 1.0;
	declare v_quantity int(8) default 1;
	declare v_due decimal(10, 2) default 0.0;
	select price, quantity into v_p_price, v_quantity
	from `orders` join `product` on `orders`.product_id = `product`.product_id
	where order_id = v_o_id;
	if (v_quantity < 10) then
		set v_due = v_p_price * v_quantity * 0.95;
	elseif (v_quantity >= 10 and v_quantity <= 50) then
		set v_due = v_p_price * v_quantity * 0.9;
	else
		set v_due = v_p_price * v_quantity * 0.8;
	end if;
	return v_due;
end;
$$
delimiter ;

-- 查询返回所有订单的应付款
select order_id, cal_due_fn(order_id) from `orders`;

-- 练习3：
-- 选用一种循环结构，编写函数get_prod_fn，实现从m到n的累乘
-- loop
delimiter $$
create function get_prod_fn1 (m int, n int) returns bigint
no sql
begin
	declare accum_sum bigint default 1;
	declare num int default m;
	add_sum : loop
		set accum_sum = num * accum_sum;
        set num = num + 1;
		if num = n + 1 then
			leave add_sum;
		end if;
	end loop;
  	return accum_sum;
end;
$$
delimiter ;
drop function get_prod_fn1;

select get_prod_fn1(10, 15);

-- repeat
delimiter $$
create function get_prod_fn2 (m int, n int) returns bigint
no sql
begin
	declare accum_sum bigint default 1;
	declare num int default m;
	repeat
		set accum_sum = num * accum_sum;
        set num = num + 1;
	until (num = n + 1) end repeat;
  	return accum_sum;
end;
$$
delimiter ;
select get_prod_fn2(10, 15);

-- while
delimiter $$
create function get_prod_fn3 (m int, n int) returns bigint
no sql
begin
	declare accum_sum bigint default 1;
	declare num int default m;
    while num <= n do
		set accum_sum = num * accum_sum;
        set num = num + 1;
	end while;
	return accum_sum;
end;
$$
delimiter ;

drop function get_prod_fn3;

select get_prod_fn3(10, 15);


-- 2. 选择一种循环结构，编写程序求三位水仙花数之和 [^2]。
-- [^2]: 水仙花数: 对应三位数i，如果它的百位、十位和各位立方之和等于它本身，则这个数为水仙花数。例如153，由于1^3^+5^3^+3^3^=155，则153水仙花数。

delimiter $$
create function shuixian_fn(n int) returns int
    no sql
    begin
        declare sum_num int default 0; -- 求和变量初始值为0
        declare num int default 100;
        declare bai int;
        declare shi int;
        declare ge int;
        add_sum : loop
            set bai = num div 100;
            set shi = (num div 10) mod 10;
            set ge =  num mod 10;
            if power(bai, 3) + power(shi, 3) + power(ge, 3) = num then
                set sum_num = sum_num + num;
            end if;
            set num = num + 1;
            if num = n then
                leave add_sum;
            end if;
        end loop;
    return sum_num;
    end;
$$
delimiter ;

drop function shuixian_fn;

select 153 div 100, (153 div 10) mod 10, 153 mod 10;
select shuixian_fn(500);