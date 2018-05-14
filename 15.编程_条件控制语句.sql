use purchase;

-- 1. if语句
/* 基本语法
If 条件表达式1 then 语句块1;
[elseif 条件表达式2 then 语句块2];
...
[else 语句块n]
end if;
*/

select product_id into @pid from product where id='10101';

-- 课堂示例1: 创建函数f, 输入x，如果x<0，计算y=-x;如果x>=0，计算y=x*2，返回y
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


-- 课堂示例2: 创建函数change_price_fn:,输入产品编号product_id，根据sort_id的值计算并返回返利: sort_id为11的产品返利为价格的10%， sort_id为21的产品的产品返利为价格的30%，
-- sort_id为31的产品返利为价格的40%, 其它返回为5%。
delimiter $$
create function cal_rebate_fn (v_p_id char(2)) returns decimal(10,2)
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
select product_id, sort_id, cal_rebate_fn(product_id) as rebate
from product limit 5;

-- 课堂练习1
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

-- (2) 创建函数cal_due_fn，输入订单号，计算该订单折扣后对应的应付款p_due，价格计算方式如下：如果产品数量(quantity)小于10，则p_due = 产品单价 * 数量 * 0.95;
-- 如果数量在10和50之间，则p_due = 产品单价 * 数量 * 0.9; 如果数量大于50，则p_due = 产品单价 * 数量 * 0.8.
delimiter $$
create function cal_due_fn (v_o_id char(50)) returns decimal(10, 2)
	reads sql data
	begin
		declare v_p_price decimal(10, 2) default 1.0;
		declare v_quantity int(8) default 1;
		declare v_due decimal(10, 2) default 0.0;
		select `product`.price, `order`.quantity into v_p_price, v_quantity
		from `order` join `product` on `order`.product_id = `product`.product_id
		where `order`.order_id = v_o_id;
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
select order_id, cal_due_fn(order_id) from `order`;

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

-- 课堂示例3: 创建get_week_fn()函数，使用该函数根据mysql系统时间打印星期几
delimiter $$
create function get_week_fn (week_no int) returns char(20)
no sql
begin
	declare week_day char(20);
  case week_no
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
select now(), get_week_fn(weekday(now())); -- weekday(日期), 0-Mon, 1-Tus....

-- 3. 循环

-- 3.1 while

/*
当条件表达式为true时，反复执行循环体，直到表达式值为false。语法结构：
[循环标签:] while 条件表达式 do
循环体;
end while [循环标签];
*/

-- 课堂示例4：创建函数get_sum_fn，返回整数1到n的累加和
delimiter $$
create function get_sum_fn (n int) returns int
no sql
begin
	declare accum_sum int default 0;
  declare start_num int default 0;
  while start_num < n do
		set start_num = start_num + 1;
        set accum_sum = start_num + accum_sum;
	end while;
  return accum_sum;
end;
$$
delimiter ;

select get_sum_fn(100);

-- 3.2 leave
/* 用于跳出当前的循化语句。语法：
leave 循环标签;
*/

-- 课堂示例5：基于leave语句，创建函数get_sum_fn2，返回整数1到n的累加和
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

-- 3.3 iterate
/* 用于跳出本次循环，继续下次循环。语法：
iterate 循环标签;
*/

-- 课堂示例6：基于iterate，对1~n所有能被3整除的数加和
delimiter $$
create function get_sum_fn3 (n int) returns int
no sql
begin
	declare accum_sum int default 0;
  declare start_num int default 0;
  add_num : while true do
	set start_num = start_num + 1;
    if start_num <= n then
			if (start_num % 3) = 0 then
				set accum_sum = accum_sum + start_num;
			else iterate add_num;
      end if;
		else leave add_num;
    end if;
	end while add_num;
  return accum_sum;
end;
$$
delimiter ;

select get_sum_fn3(100);

-- 3.4 repeat
/*当条件表达式的值为false时，反复执行循环，直到条件表达式的值为true。语法：
[循环标签:]repeate
循环体;
until 条件表达式
end repreat[循环标签];

*/

-- 课堂示例7：基于repeat，实现从1加到n
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

-- 3.5 loop
/* loop通常借助leave语句跳出loop循环。语法：
[循环标签:]loop
循环体;
if 条件表达式 then
	leave [循环标签];
end if;
end loop;

*/

-- 课堂示例8：基于loop，实现从0加到n
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

-- 课堂练习2：
-- 选用一种循环结构，编写函数get_prod_fn，实现从m到n的累乘
-- loop
delimiter $$
create function get_prod_fn (m int, n int) returns int
no sql
begin
	declare accum_sum int default m;
  declare start_num int default 0;
  add_sum : loop
		set start_num = start_num + 1;
    set accum_sum = start_num * accum_sum;
    if start_num = n then
			leave add_sum;
		end if;
	end loop;
  return accum_sum;
end;
$$
delimiter ;

select get_prod_fn(10);
