USE purchase;
SET SQL_SAFE_UPDATES = 0;

-- 一. 存储过程stored procedure

/*语法格式：
create procedure 存储过程名(参数1, 参数2, ...)
[存储过程选项]
begin
存储过程语句块;
end;

存储过程选项:
language sql
| [not] deterministic
| {contains sql | no sql | reads sql data | modifies sql data}
| sql security {definer | invoker}
| comment '注释'

*/

-- 示例1：把一定数量的数据插入到一个表中
CREATE TABLE test_table (id INT AUTO_INCREMENT PRIMARY KEY, 
	a VARCHAR(10), 
    b VARCHAR(10));
SELECT * FROM test_table;

DROP PROCEDURE IF EXISTS insert_many_rows;
delimiter $$
CREATE PROCEDURE insert_many_rows (IN loops INT)
BEGIN
	DECLARE v1 INT;
    SET v1 = loops;
    WHILE v1 > 0 DO
		INSERT INTO test_table(id, a, b) VALUES (NULL, 'qpq', 'rst');
        SET v1 = v1 - 1;
	END WHILE;
END;
$$
delimiter ;
DROP PROCEDURE insert_many_rows;

-- 插入100行
CALL insert_many_rows(100);
SELECT * FROM test_table;


-- 示例2：构建一个存储过程，实现把某个类别的产品数量写入到1个变量中
DROP PROCEDURE IF EXISTS sort_count_proc;
delimiter $$
CREATE PROCEDURE sort_count_proc (IN v_sort_id VARCHAR(5), OUT v_product_count INTEGER)
READS SQL DATA
BEGIN
	SELECT COUNT(*) INTO v_product_count
	FROM product
	WHERE sort_id = v_sort_id;
END;
$$
delimiter ;

SET @v_sort_id = '11';
#SET @v_product_count = 0;
CALL sort_count_proc(@v_sort_id, @v_product_count);
SELECT @v_product_count;

-- 查看存储过程的创建语句
SHOW CREATE PROCEDURE <proc_name>

-- 根据指定的模式查看所有符合要求的存储过程
SHOW PROCEDURE STATUS [LIKE 匹配模式];

-- 直接在information_schema.routines中查询
SELECT * 
FROM information_schema.routines;

-- 示例3：查看insert_many_row和sort_count_proc的定义
SHOW CREATE PROCEDURE insert_many_rows;
SHOW CREATE PROCEDURE sort_count_proc;

SHOW PROCEDURE STATUS LIKE 'insert%';
SHOW PROCEDURE STATUS LIKE 'sort_count%';

DESC information_schema.routines;

SELECT * 
FROM information_schema.routines 
WHERE ROUTINE_TYPE = 'PROCEDURE' 
AND ROUTINE_SCHEMA='purchase';

-- 示例4: 修改`sort_count_proc`定义
ALTER PROCEDURE sort_count_proc
SQL SECURITY INVOKER
COMMENT '统计某一个类别下的产品数量';

select * from sort;

-- 示例5：为错误状态定义名称
DROP PROCEDURE IF EXISTS exp_proc_1
DELIMITER $$
CREATE PROCEDURE exp_proc_1()
BEGIN
	DECLARE command_not_allowed CONDITION FOR SQLSTATE '42000';  -- SQLSTATE
END
$$
DELIMITER ;

-- 或者
DELIMITER $$
CREATE PROCEDURE exp_proc_2()
BEGIN
	DECLARE command_not_allowed CONDITION FOR 1148; -- MYSQL_ERROR_CODE
END
$$
DELIMITER ;

-- 示例6：定义存储程序，往`sort`表插入数据行，如果插入成功，则设置会话变量为0；如果插入重复值，则设置会话变量为1.
ALTER TABLE sort MODIFY sort_id CHAR(2) PRIMARY KEY;

DROP PROCEDURE IF EXISTS proc_demo;
DELIMITER $$
CREATE PROCEDURE proc_demo(IN v_sortid CHAR(2), IN v_sortname VARCHAR(20))
BEGIN
	DECLARE CONTINUE HANDLER FOR SQLSTATE '23000'
		SET @is_success = 0; -- 如果遇到23000错误，则执行set @num=1，并继续之后的语句
	SET @is_success = 1;
	INSERT INTO sort(sort_id, sort_name) VALUES (v_sortid, v_sortname);
END
$$
DELIMITER ;

select * from sort;
DELETE FROM product WHERE SORT_id = 99;
DELETE FROM SORT WHERE SORT_ID = 99;

call proc_demo('99', '其它'); -- 分别执行两次，第一次成功，第二次未成功，但未报错，说明已经处理了异常。
select @is_success;

insert into sort(sort_id)
values(99);

-- 二. 游标cursor
/*
a. 声明游标
declare 游标名 cursor for select 语句
使用declare语句声明游标后，此时与游标对应的select语句并没有执行，mysql服务器内存中并不存在与select语句对应的结果集。
b. 打开游标
open 游标名
此时对应的select语句被执行，mysql服务器内存中存在与select语句对应的结果集。
c. 从游标中提出数据 
fetch 游标名 into 变量名1, 变量名2, ... 
每提取一条记录，游标移到下一条记录的开头。当取出最后一条记录后，如果再次执行fetch语句，则产生"ERROR 1329(02000):No data to fetch"。
d. 关闭游标 
close 游标名 
释放游标打开的数据集，以节省mysql服务器的内存空间。如果没有被明确关闭，则它将再被打开的begin-end语句块的末尾关闭。
*/
SELECT * FROM instructor;

-- 示例7：更新某一类产品的所有产品的价格：如果大于1000，则上涨5%；否则，上涨10%。
DROP PROCEDURE IF EXISTS update_price_proc;
delimiter $$
CREATE PROCEDURE update_price_proc (IN v_sort_name VARCHAR(20))
MODIFIES SQL DATA
BEGIN
	DECLARE v_product_id INT;
	DECLARE v_price DECIMAL(8, 2);
	DECLARE state CHAR(20);
	DECLARE price_cur CURSOR FOR 
		SELECT product_id, price 
        FROM product natural JOIN sort 
        WHERE sort_name = v_sort_name;
	DECLARE CONTINUE HANDLER FOR 1329 SET state = 'Error';  -- continue 发生错误继续运行， exit 发生错误终止程序
	OPEN price_cur; -- 打开游标
	REPEAT
		FETCH price_cur INTO v_product_id, v_price;  -- 移动游标，获取数据
			IF (v_price > 1000) THEN 
				SET v_price = v_price * 1.05;
			ELSE 
				SET v_price = v_price * 1.1;
			END IF;
            
			UPDATE product 
            SET price = v_price 
            WHERE product_id = v_product_id;
		UNTIL state = 'Error'  -- 如果没发生异常，则state为null；如果发生1329异常，state的值为error，此时终止repeat
	END REPEAT;
	CLOSE price_cur;  -- 关闭游标
END;
$$
delimiter ;

SELECT product_id, price 
FROM product natural JOIN sort 
WHERE sort_name = '办公机器设备';

CALL update_price_proc('办公机器设备');
SELECT * FROM sort WHERE sort_name='办公机器设备';

/* 定义存储过程`update_remark_proc`，通过定义游标，逐行更新`orders`表中的价格`remark`：如果`quantity<10`，更新`remark`的值为`'小批量订单'`；
如果`quantity`在10和50之间，更新`remark`的值为`'中批量订单'`；如果`quantity>50`，更新`remark`的值为`'大批量订单'`。*/

-- 3. 触发器

-- 示例8: 不允许`instructor`的薪水值高于150000
DROP TABLE instructor;
CREATE TABLE `instructor` (`id` CHAR(5) PRIMARY KEY, 
                         `name` VARCHAR(20), 
                         `dept_name` VARCHAR(20), 
                         `salary` DECIMAL(8, 2));

INSERT INTO instructor (id, `name`, dept_name, salary)
VALUES ('10101', 'Srinivasan', 'Comp. Sci.', '65000.00'),
      ('12121', 'Wu', 'Finance', '90000.00'),
      ('15151', 'Mozart', 'Music', '40000.00'),
      ('22222', 'Einstein', 'Physics', '95000.00'),
      ('32343', 'EI Said', 'History', '60000.00'),
      ('33456', 'Gold', 'Physics', '87000.00'),
      ('45565', 'Katz', 'Comp. Sci.', '75000.00'),
      ('58583', 'Califieri', 'History', '62000.00'),
      ('76543', 'Singh', 'Finance', '80000.00'),
      ('76766', 'Crick', 'Biology', '72000.00'),
      ('83821', 'Brandt', 'Comp. Sci.', '92000.00'),
      ('98345', 'Kim', 'Elec. Eng.', '80000.00');
      
-- update
drop trigger if exists instru_update_before_trigger;
delimiter $$
create trigger instru_update_before_trigger before update on instructor for each row
begin
    if (new.salary > 150000) then -- new为更新前的行值
        set new.salary = old.salary;  -- 如果高于150000，则重新更新为原来的值
        insert into mytable values(0); -- 因为mytable未经定义，触发异常，更新操作失败。
    end if;
end;
$$
delimiter ;

-- insert
drop trigger if exists instru_insert_before_trigger;
delimiter $$
create trigger instru_insert_before_trigger before insert on instructor for each row
begin
    if (new.salary > 150000) then
        insert into mytable values(0);  -- 因为mytable未经定义，触发异常，更新操作失败。
    end if;
end;
$$
delimiter ;

-- 
show triggers from purchase; -- 查看触发器

SELECT * 
FROM information_schema.triggers
WHERE EVENT_OBJECT_TABLE = 'instructor';

SELECT * 
FROM information_schema.triggers
WHERE EVENT_OBJECT_TABLE = 'sort'; 

SELECT * 
FROM information_schema.triggers
WHERE EVENT_OBJECT_SCHEMA = 'purchase';  

-- 插入记录
select * from instructor;

update instructor 
set salary=185000 
where id='10101';

insert into instructor 
values('11111', 'Steve', 'Finance', 160000);

delete from instructor 
where id='11111';

-- 示例9：利用触发器实现`sort`表和`subsort`表之间的外键约束：`subsort`表的`sort_id`参照`sort`表的`sort_id`。

/*
- 分析：需要分别定义从表和主表的更新和删除行为（`before`）
  - 主表：
    - 删除一行时，检查从表中是否存在参照值
    - 更新一行时，检查从表中是否存在参照行值，可进一步定义从表的参照值是否也对应更新（cascade）
  - 从表：
    - 新增一行时，检查主表是否存在被参照值，如果不存在，则插入失败。
    - 更新一行时，检查主表是否存在被参照值，如果不存在，则更新失败。
*/
-- sort表上的更新，on update cascade
DROP TRIGGER IF EXISTS sort_update_after_trigger;
DELIMITER $$
CREATE TRIGGER sort_update_after_trigger AFTER UPDATE ON sort FOR EACH ROW -- 此处应该为after，不能为before，与subsort上的定义会冲突
BEGIN
	UPDATE subsort
	SET sort_id = new.sort_id
	WHERE sort_id = old.sort_id;
END;
$$
DELIMITER ;

-- sort表上的删除，on delete cascade
DROP TRIGGER IF EXISTS sort_delete_before_trigger;
DELIMITER $$
CREATE TRIGGER sort_delete_before_trigger BEFORE DELETE ON sort FOR EACH ROW
BEGIN
	DELETE FROM subsort
	WHERE sort_id = old.sort_id;
END;
$$
DELIMITER ;

-- subsort表上的插入
DROP TRIGGER IF EXISTS subsort_insert_before_trigger;
DELIMITER $$
CREATE TRIGGER subsort_insert_before_trigger BEFORE INSERT ON subsort FOR EACH ROW
BEGIN
	SELECT COUNT(*) INTO @row_count 
	FROM sort 
	WHERE sort_id=new.sort_id;
	
	IF (@row_count = 0) THEN
		INSERT INTO mytable VALUES (0);
	END IF;
END;
$$
DELIMITER ;

-- subsort表上的更新
DROP TRIGGER IF EXISTS subsort_update_before_trigger;
DELIMITER $$
CREATE TRIGGER subsort_update_before_trigger BEFORE UPDATE ON subsort FOR EACH ROW
BEGIN
	SELECT COUNT(*) INTO @row_count 
	FROM sort 
	WHERE sort_id=new.sort_id;
	
	IF (@row_count = 0) THEN
		INSERT INTO mytable VALUES (0);
	END IF;
END;
$$
DELIMITER ;

-- 如果subsort和sort表有外键约束，先删除
SHOW CREATE TABLE SORT;
SHOW CREATE TABLE SUBSORT;

DELETE FROM SORT WHERE SORT_ID = 93;
SELECT * FROM SORT;
SELECT * FROM SUBSORT WHERE SORT_ID = 93;

-- 插入
insert into subsort(subsort_id, subsort_name, sort_id)
values (9901, 'test', 93); -- 插入失败， error code 1146

insert into sort (sort_id, sort_name)
values (93, 'test-sort'); -- 执行之后

insert into subsort(subsort_id, subsort_name, sort_id)
values (9901, 'test', 93); -- 插入成功

-- 更新
set sql_safe_updates=0;

update sort
set sort_id = 94
where sort_name = 'test-sort';

select * from sort;
select * from subsort where subsort_name = 'test';

-- 更新subsort
update subsort
set sort_id = 94
where subsort_name = 'test'; -- 执行失败， error 1146

-- 删除
select * from sort where sort_name = 'test-sort';

delete from sort
where sort_name = 'test-sort';

select * from sort;
select * from subsort where subsort_name = 'test';


-- 四、事件调度器

-- 示例10：创建一个立即启动的事件。
USE PURCHASE;
SHOW VARIABLES LIKE '%event_scheduler%';

CREATE TABLE demo_tb(id int primary key auto_increment,
                    name varchar(20),
					insert_time timestamp default current_timestamp());
TRUNCATE demo_tb;

SELECT * FROM demo_tb;
SELECT NOW();

DROP EVENT IF EXISTS immediate_event;
DELIMITER $$
CREATE EVENT immediate_event 
ON schedule AT now()
ON completion PRESERVE
DO 
BEGIN
	insert into demo_tb(name) values('demo');
END;
$$
delimiter ;

-- 或者
CREATE EVENT immediate_event ON schedule AT now()
DO insert into demo_tb(name) values('demo');

select * from demo_tb;

-- 示例11：创建一个每10秒执行的事件。
DROP EVENT IF EXISTS interval_event;
DELIMITER $$
CREATE EVENT interval_event ON schedule EVERY 10 SECOND STARTS now()
DO 
BEGIN
	insert into demo_tb(name) values('demo_10_s');
END;
$$
DELIMITER ;

SELECT * FROM demo_tb;

ALTER EVENT interval_event DISABLE; -- 临时关闭事件

-- 示例12：创建一个2020年5月19号起每天`00:00`执行的事件。
TRUNCATE demo_tb;
DROP EVENT IF EXISTS repeat_event_from;
DELIMITER $$
CREATE EVENT repeat_event_from
ON SCHEDULE EVERY 1 DAY STARTS timestamp('2020-05-19 00:00:00')
ON COMPLETION PRESERVE
ENABLE
DO 
BEGIN
	insert into demo_tb(name) values('demo_INTERAL_0000');
END;
$$
DELIMITER ;

SELECT timestamp('2020-12-21 00:00:00') + INTERVAL 1 DAY;
SELECT '2020-12-21 12:00:00' + INTERVAL 1 DAY;
SELECT DATE_ADD('2020-12-21 00:00:01', INTERVAL 1 DAY);
select curdate(), NOW();
SELECT DATE_ADD('2020-12-21 00:00:01', INTERVAL 30 DAY) > DATE_ADD('2020-12-21 00:00:01', INTERVAL 10 DAY);

ALTER EVENT repeat_event_from DISABLE; -- 临时关闭事件

SHOW EVENTS FROM purchase;  -- 查看purchase数据库中的所有事件

SELECT * 
FROM information_schema.events; -- 查看所有事件

SHOW CREATE EVENT interval_event; -- 查看定义

-- 五、应用
-- 示例4： 在存储过程结合临时表实现迭代查询。
use purchase;
CREATE TABLE prereq (course_id varchar(30) primary key, 
                     prereq_id varchar(30));
                     
INSERT INTO prereq(course_id, prereq_id)
VALUES ('BIO-301', 'BIO-101'),
	('BIO-399', 'BIO-101'),
	('CS-190', 'CS-101'),
	('CS-315', 'CS-101'),
	('CS-319', 'CS-101'),
	('CS-347', 'CS-101'),
	('EE-181', 'PHY-101'),
	('CS-101', 'CS-10'),
	('CS-10', 'CS-1');

SELECT a.*, b.*
FROM prereq a JOIN prereq b ON a.course_id = b.prereq_id
WHERE a.course_id = 'CS-101';

select course_id, prereq_id, 0 as lev, course_id as tree_path 
	from prereq 
	where course_id = 'CS-10';

-- MYSQL8以上版本支持以下语法
with recursive tree_course(course_id, prereq_id, lev) as (
	select course_id, prereq_id, 0 as lev
	from prereq 
	where course_id = 'CS-10'
	union all
	select s.course_id, s.prereq_id, p.lev + 1 as lev
	from tree_course p join prereq s on p.course_id = s.prereq_id)
select * from tree_course;

select * from prereq;

USE PURCHASE;
-- MYSQL8及以下版本支持
DROP PROCEDURE IF EXISTS purchase.tree_prereq_proc;

DELIMITER $$
CREATE PROCEDURE tree_prereq_proc(v_course_id varchar(30))
MODIFIES SQL DATA
BEGIN
	DECLARE v_lev INT DEFAULT 0;
	DROP TEMPORARY TABLE IF EXISTS tree_prereq;
	CREATE TEMPORARY TABLE tree_prereq(course_id varchar(30), 
									 prereq_id varchar(30),
									 lev int); -- 用于存储结果
	INSERT INTO tree_prereq(course_id, prereq_id, lev)
	SELECT course_id, prereq_id, v_lev as lev
	FROM prereq
	WHERE course_id = v_course_id; -- 首轮节点对应的子节点
  
	WHILE row_count() > 0 DO
		DROP TEMPORARY TABLE if exists temp;
		CREATE TEMPORARY TABLE temp -- 保存下一次迭代查询的父节点
			SELECT * FROM tree_prereq WHERE lev = v_lev;
		SET v_lev = v_lev + 1; -- 更新层级
		INSERT INTO tree_prereq(course_id, prereq_id, lev)
			SELECT distinct s.course_id, s.prereq_id, v_lev as lev
			FROM temp p JOIN prereq s ON p.course_id = s.prereq_id;
	END WHILE;
END;
$$
DELIMITER ;

CALL tree_prereq_proc('CS-10');
SELECT * FROM tree_prereq;

-- 练习
with recursive tree_course(course_id, prereq_id, lev) as (
	select course_id, prereq_id, 0 as lev
	from prereq 
	where course_id = 'CS-190'
	union all
	select p.course_id, p.prereq_id, s.lev - 1 as lev
	from tree_course s join prereq p on p.course_id = s.prereq_id)
select * from tree_course;

-- 存储过程实现
DROP PROCEDURE IF EXISTS path_prereq_proc;
DELIMITER $$
CREATE PROCEDURE path_prereq_proc(v_course_id varchar(30))
MODIFIES SQL DATA
BEGIN
	DECLARE v_lev INT DEFAULT 0;
	DROP TEMPORARY TABLE IF EXISTS path_prereq;
	CREATE TEMPORARY TABLE path_prereq(course_id varchar(30), 
									 prereq_id varchar(30),
									 lev int); -- 用于存储结果
	INSERT INTO path_prereq(course_id, prereq_id, lev)
	SELECT course_id, prereq_id, v_lev as lev
	FROM prereq
	WHERE course_id = v_course_id; -- 首轮节点对应的子节点
	WHILE row_count() > 0 DO
		DROP TEMPORARY TABLE if exists temp;
		CREATE TEMPORARY TABLE temp -- 保存下一次迭代查询的父节点
			SELECT * FROM path_prereq WHERE lev = v_lev;
		SET v_lev = v_lev - 1; -- 更新层级
		INSERT INTO path_prereq(course_id, prereq_id, lev)
			SELECT distinct p.course_id, p.prereq_id, v_lev as lev
			FROM temp s JOIN prereq p ON p.course_id = s.prereq_id;
	END WHILE;
END;
$$
DELIMITER ;

CALL path_prereq_proc('CS-190');
SELECT * FROM path_prereq;


-- 示例14：`his_log`表中的行数不大于10000
CREATE TABLE his_log(id int primary key auto_increment,
                    userid char(50) not null,
                    operate_time timestamp default current_timestamp());
            
            
DELIMITER $$
CREATE TRIGGER his_log_constant_rows_trigger BEFORE INSERT ON his_log FOR EACH ROW
BEGIN
	SELECT COUNT(*) INTO @num_rows
	FROM his_log;
	IF (@num_rows >= 10000) THEN
		DELETE FROM his_log
		ORDER BY operate_time LIMIT 1;
	END IF;
END;
$$
DELIMITER ;

-- 示例15：每天凌晨定期清理30天前的`his_log`中的记录。
DELIMITER $$
CREATE EVENT delete_log_event
ON SCHEDULE EVERY 1 DAY STARTS CURDATE() + INTERVAL 1 DAY
ON COMPLETION PRESERVE
ENABLE
DO 
BEGIN
	DELETE FROM his_log
	WHERE DATE_ADD(operate_time, INTERVAL 30 DAY) < CURRENT_TIMESTAMP();
END;
$$
DELIMITER ;

-- 示例16：首先，定义存储过程，检查`orders`表的`product_id`都在`product`表中，如果不在，则将对应的行移动到`orders_suspend`表中（`orders_suspend`有`orders`所有字段，且有`insert_time`字段记录移动时间）。
-- 然后，定义事件，在每天`00:00:00`执行该检查。
USE purchase;
-- 定义表orders_suspend
CREATE TABLE orders_suspend SELECT * FROM orders WHERE 1 = 0;
ALTER TABLE orders_suspend ADD insert_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP();

SELECT * FROM orders_suspend;

-- 定义存储过程check_orders_ref_proc: 方法1
DELIMITER $$
CREATE PROCEDURE check_orders_ref1_proc()
MODIFIES SQL DATA
BEGIN
	DECLARE v_diff INT DEFAULT 0;
	-- 检查是否有不符合外键约束的记录
	SELECT COUNT(*) INTO v_diff
	FROM orders a LEFT JOIN product b ON a.product_id = b.product_id
	WHERE b.product_id IS NULL LIMIT 1;
	-- 如果有，则转移问题记录
	IF (v_diff > 0) THEN
		-- 将不符合外键约束的行移至orders_suspend
		INSERT INTO orders_suspend (order_id, product_id, quantity, user_name, order_date, consignee, delivery_address, phone, email, remark, insert_time)
		SELECT a.order_id, a.product_id, a.quantity, a.user_name, a.order_date, a.consignee, a.delivery_address, a.phone, a.email, a.remark, current_timestamp()
		FROM orders a LEFT JOIN product b ON a.product_id = b.product_id
		WHERE b.product_id IS NULL;
		-- 删除orders表中不符合外键约束的行
		DELETE FROM orders
		WHERE product_id NOT IN (SELECT product_id FROM product);
	END IF;
END;
$$
DELIMITER ;

-- 定义存储过程check_orders_ref_proc: 方法2，保存中间结果，更加高效
DELIMITER $$
CREATE PROCEDURE check_orders_ref2_proc()
MODIFIES SQL DATA
BEGIN
	-- 创建临时表orders_temp，保存不符合外键约束的中间结果
	DROP TEMPORARY TABLE IF EXISTS orders_temp;
	CREATE TEMPORARY TABLE orders_temp
	SELECT b.product_id
	FROM orders a LEFT JOIN product b ON a.product_id = b.product_id
	WHERE b.product_id IS NULL LIMIT 1;
	-- row_count()返回上一次数据操纵语句的影响行数, found_rows()返回上一次查询的返回行数
	IF (row_count() > 0) THEN
	-- 将不符合外键约束的行移至orders_suspend
		INSERT INTO orders_suspend (order_id, product_id, quantity, user_name, order_date, consignee, delivery_address, phone, email, remark, insert_time)
		SELECT order_id, product_id, quantity, user_name, order_date, consignee, delivery_address, phone, email, remark, current_timestamp()
		FROM orders_temp;		
		-- 删除orders表中不符合外键约束的行
		DELETE FROM orders
		WHERE product_id IN (SELECT product_id FROM orders_temp);
	END IF;
END;
$$
DELIMITER ;

-- 定义事件repeate_move_orders_event
CREATE EVENT repeate_move_orders_event
ON SCHEDULE EVERY 1 DAY STARTS DATE_ADD(curdate(), INTERVAL 1 DAY)
ON COMPLETION PRESERVE
ENABLE
DO CALL check_orders_ref_proc2();