use purchase;

-- 1. if语句
/* 基本语法
If 条件表达式1 then 语句块1;
[elseif 条件表达式2 then 语句块2];
...
[else 语句块n]
end if;
*/

select salary into @sal from instructor where id='10101';

-- 根据不同角色对instructor和student进行查询

delimiter $$
create function get_name_fn2 (id1 varchar(5), role varchar(20)) returns varchar(20)
reads sql data
begin
	declare name1 varchar(20);
    if (role='student') then
		select name into name1 from student where id=id1;
	elseif (role='instructor') then
		select name into name1 from instructor where id=id1;
	else
		set name1='No such role';
	end if;
    return name1;
end;
$$
delimiter ;

drop function get_name_fn2;

select get_name_fn2('10101', 'instructor');

select get_name_fn2('00128', 'student');

select get_name_fn2('12345', 'intructor');


select * from instructor;

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

-- 创建get_week_fn()函数，使用该函数根据mysql系统时间打印星期几
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

select now(), get_week_fn(weekday(now())); -- weekday(日期), 0-Mon, 1-Tus....

select weekday(now());

-- 3. 循环

-- 3.1 while

/*
当条件表达式为true时，反复执行循环体，直到表达式值为false。语法结构：
[循环标签:] while 条件表达式 do
循环体;
end while [循环标签];
*/

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

-- 对1~n所有能被3整除的数加和
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