/*语法：
create trigger 触发器名 触发时间 触发事件 on 表名 for each row
begin
触发程序
end;

a. 触发时间: before / after
b. 触发事件: insert / update / delete
c. for each row: 行级触发器(mysql目前仅支持行级触发器，不支持语句级别的触发器, 如create table)
d. 触发程序中的select语句不能产生结果集
e. 触发程序中可以使用old和new关键字区别更新前后的值
f. old记录是只读的，可以引用，但不能更改。在before触发程序中，可使用"set new.col_name = value"更改new值。但在after触发程序中，不能使用"set new.col_name = value"

*/


-- 不允许员工薪水高于150000

-- update
use progrm;

delimiter $$
create trigger instru_update_before_trigger before update on instructor for each row
begin
	if (new.salary > 150000) then
		set new.salary = old.salary;
		insert into mytable values(0);
    
	end if;
end;
$$
delimiter ;

-- insert
delimiter $$
create trigger instru_insert_before_trigger before insert on instructor for each row
begin
	if (new.salary > 150000) then
		insert into mytable values(0);
	end if;
end;
$$
delimiter ;

show triggers; -- 查看触发器

select * from instructor;

-- 示例
update instructor set salary=165000 where id='10101';

insert into instructor values('11111', 'Steve', 'Finance', 160000);

delete from instructor where id='11111';