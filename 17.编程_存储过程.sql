USE mis;
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

-- 把一定数量的数据插入到一个表中
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

CALL insert_many_rows(100);
SELECT * FROM test_table;

delimiter $$
CREATE PROCEDURE dept_count (IN dept_name VARCHAR(20), OUT d_count INTEGER)
READS SQL DATA
BEGIN
	SELECT COUNT(*) INTO d_count
	FROM instructor
	WHERE instructor.dept_name = dept_name;
END;
$$
delimiter ;

SET @dept_name = 'Comp. Sci.';
SET @dept_count = 0;
CALL dept_count(@dept_name, @dept_count);
SELECT @dept_count;

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

-- 更新某一部门所有导师的薪水：如果大于80000，上涨5%；否则，上涨10%。
delimiter $$
CREATE PROCEDURE update_salary_proc (IN dep_name VARCHAR(20))
MODIFIES SQL DATA
BEGIN
	DECLARE i_id INT;
	DECLARE i_salary DECIMAL(8, 2);
	DECLARE state CHAR(20);
	DECLARE salary_curs CURSOR FOR SELECT id, salary FROM instructor WHERE dept_name = dep_name;
	DECLARE CONTINUE HANDLER FOR 1329 SET state = 'Error';  -- continue 发生错误继续运行， exit 发生错误终止程序
	OPEN salary_curs; -- 打开游标
	REPEAT
		FETCH salary_curs INTO i_id, i_salary;  -- 移动游标，获取数据
			IF (i_salary > 80000) THEN 
				SET i_salary = i_salary * 1.05;
			ELSE 
				SET i_salary = i_salary * 1.1;
			END IF;
			UPDATE instructor SET salary = i_salary WHERE id = i_id;
		UNTIL state = 'Error'  -- 判断state的值是否为error，如果是则终止repeat
	END REPEAT;
	CLOSE salary_curs;  -- 关闭游标
END;
$$
delimiter ;

DROP PROCEDURE update_salary_proc;

CALL update_salary_proc('Comp. Sci.');
SELECT * FROM instructor WHERE dept_name='Comp. Sci.';

-- 还原数据
UPDATE instructor SET salary = 92000 WHERE id = 83821;
UPDATE instructor SET salary = 75000 WHERE id = 45565;
UPDATE instructor SET salary = 65000 WHERE id = 10101;

-- 4. 预处理SQL语句
SELECT * FROM student;

PREPARE instructor_pre FROM 'select * from instructor where dept_name=?';
SET @dept = 'Comp. Sci.';
EXECUTE instructor_pre USING @dept;

SELECT * FROM prereq;