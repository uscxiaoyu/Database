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
-- 课堂示例1: 定义查询行号：
/*每返回一行，行号+1*/
delimiter $$
create function row_no_fn () returns int
no sql
begin
	set @row_no = @row_no + 1;
    return @row_no;
end;
$$ -- 忘记加上去
delimiter ;

set @row_no = 0;
select row_no_fn() as '序号', product_id, product_name, Product_Place from Product;

-- 课堂示例2: 定义函数get_product_number_fn, 输入类别编号，输出该类别下的产品数量
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

select get_sum_product_fn('11');

-- 课堂练习1
-- (1) 完成课堂示例

-- (2) 

-- 课堂示例3: 定义函数get_sortname_fn，输入产品编号，返回其产品类别下子类别的数量
delimiter $$
create function get_sortname_fn (p_productid char(5)) returns char(5) -- 若在参数中定义varchar，则需提供具体的长度；return和returns类型要一致
reads sql data  -- 函数需通过sql读取数据
begin
	declare v_sortid char(2); -- 函数体内变量声明(局部变量); 因为作为返回值，所以应与returns定义的类型一致
    declare v_subsortid char(5); -- 定义变量，用于存储子类别数量
    select sort_id into v_sortid from Product where product_id = p_productid;
    select count(subsort_id) into v_subsortid from SubSort where sort_id = v_sortid;
    return v_subsortid;
end;
$$
delimiter ;

drop function if exists get_sortname_fn;
select get_sortname_fn('1001') as 子类别数量;

-- 课堂示例4: 查看用户定义的函数
show function status where definer='root@localhost'; 

-- 课堂示例5: 查询完整的函数定义语句
show create function get_choose_number_fn;