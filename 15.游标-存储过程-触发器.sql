USE purchase;
SET SQL_SAFE_UPDATES = 0;

-- 1. stored procedure

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
CREATE TABLE test_table (id INT AUTO_INCREMENT PRIMARY KEY, a VARCHAR(10), b VARCHAR(10));

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

-- 插入1000行
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


-- 示例3：查看insert_many_row和sort_count_proc的定义
SHOW CREATE PROCEDURE insert_many_rows;
SHOW CREATE PROCEDURE sort_count_proc;

SHOW PROCEDURE STATUS LIKE 'insert%';
SHOW PROCEDURE STATUS LIKE 'sort_count%';

-- 示例4: 修改`sort_count_proc`定义
ALTER PROCEDURE sort_count_proc
SQL SECURITY INVOKER
COMMENT '统计某一个类别下的产品数量';

select * from sort;

-- 示例5：为错误状态定义名称
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

call proc_demo('99', '其它'); -- 分别执行两次，第一次成功，第二次未成功，但未报错，说明已经处理了异常。
select @is_success;

insert into sort(sort_id)
values(99);


-- 2. cursor
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

-- 示例3：更新某一类产品的所有产品的价格：如果大于1000，则上涨5%；否则，上涨10%。
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
SELECT * FROM instructor WHERE dept_name='Comp. Sci.';

-- 示例4： 在存储过程结合临时表实现迭代查询。

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
-- MYSQL5.7以下版本
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


-- 思考：如何利用存储过程结合临时表、预处理语句实现对任意表的迭代查询？
use purchase;
select * from instructor;
