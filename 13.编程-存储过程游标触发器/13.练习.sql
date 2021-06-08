# 练习1
use purchase;
-- 1. 定义存储过程`product_count_proc`，输入参数`v_sort_id`，输出参数`v_sort_count`，语句块中查询给定类别为`v_sort_id`的产品数量，保存至`v_sort_count`。
DELIMITER $$
CREATE PROCEDURE product_count_proc (IN v_sort_id CHAR(5), OUT v_sort_count INT)
READS SQL DATA
BEGIN
	SELECT COUNT(*) INTO v_sort_count
	FROM product
	WHERE sort_id = v_sort_id;
END;
$$
DELIMITER ;

-- 调用
CALL product_count_proc('11', @v_sort_count);
SELECT @v_sort_count;

-- 2. 定义存储过程`delete_expired_records_proc`，无参数，语句块实现对`operate_log`30天前插入的记录的删除。
CREATE TABLE operate_log (id int primary key auto_increment,
                         user_id varchar(50) not null,
                         content varchar(255) not null default '',
                         operate_time timestamp default current_timestamp());

DELIMITER $$
CREATE PROCEDURE delete_expired_records_proc()
MODIFIES SQL DATA
BEGIN
	DELETE FROM operate_log
	WHERE DATE_ADD(operate_time, INTERVAL 30 DAY) > CURRENT_TIMESTAMP();
END;
$$
DELIMITER ;

-- 调用
CALL delete_expired_records_proc();

-- 3. 定义存储过程`update_remark_proc`，通过定义游标，逐行更新`orders`表中的`remark`：如果`quantity<10`，更新`remark`的值为`'小批量订单'`；
-- 如果`quantity`在10和50之间，更新`remark`的值为`'中批量订单'`；如果`quantity>50`，更新`remark`的值为`'大批量订单'`。
DROP PROCEDURE IF EXISTS update_remark_proc;
DELIMITER $$
CREATE PROCEDURE update_remark_proc()
MODIFIES SQL DATA
BEGIN
	DECLARE v_order_id INT;
	DECLARE v_quantity INT;
	DECLARE state TINYINT DEFAULT 1;
	DECLARE order_cur CURSOR FOR SELECT order_id, quantity FROM orders;
	DECLARE CONTINUE HANDLER FOR 1329 SET state = 0;
	
	OPEN order_cur;
	WHILE (state = 1) DO
		FETCH order_cur INTO v_order_id, v_quantity;
		IF (v_quantity < 10 AND v_quantity > 0) THEN
			UPDATE orders 
			SET remark = '小批量订单'
			WHERE order_id = v_order_id;
		ELSEIF (v_quantity >= 10 AND v_quantity <= 50) THEN
			UPDATE orders 
			SET remark = '中批量订单'
			WHERE order_id = v_order_id;
		ELSE
			UPDATE orders 
			SET remark = '大批量订单'
			WHERE order_id = v_order_id;
		END IF;
	END WHILE;
    CLOSE order_cur;
END;
$$
DELIMITER ;

-- 调用
CALL update_remark_proc();
SELECT * FROM orders;

# 练习2
-- 定义触发器`move_product_records_trigger`，实现以下功能：
-- 删除`product`表中的记录后，将被删除的记录插入到`product_his`中，其中`product_his`与`product`有完全相同的属性，且有`insert_time`记录插入时间。

-- 建表product_his
CREATE TABLE product_his SELECT * FROM product WHERE 1=0;
ALTER TABLE product_his 
ADD insert_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP();
-- 触发器定义
DROP TRIGGER IF EXISTS move_product_records_trigger;
DELIMITER $$
CREATE TRIGGER move_product_records_trigger AFTER DELETE 
ON product FOR EACH ROW
BEGIN
	INSERT INTO product_his (product_id, product_name, product_code, product_place, price, product_date, unit, detail, subsort_id, sort_id)
	VALUES (old.product_id, old.product_name, old.product_code, old.product_place, old.price, old.product_date, old.unit, old.detail, old.subsort_id, old.sort_id);
END;
$$
DELIMITER ;

SELECT * FROM PRODUCT LIMIT 10;
DELETE FROM product WHERE product_id = 1;

SELECT * FROM product_his;

INSERT INTO product(product_id, product_name, product_code, product_place, price, product_date, unit, detail, subsort_id, sort_id)
SELECT product_id, product_name, product_code, product_place, price, product_date, unit, detail, subsort_id, sort_id from product_his;

TRUNCATE product_his;

-- 练习3
-- 创建事件`check_product_event`，每天凌晨执行，检查`product`中的记录，如果对应的`sort_id`为空或者`sort_id`不在`sort`表中，则删除对应记录。
DELIMITER $$
CREATE EVENT check_product_event 
ON SCHEDULE EVERY 1 DAY STARTS DATE_ADD(curdate(), INTERVAL 1 DAY)
ON COMPLETION PRESERVE
ENABLE 
COMMENT '创建事件`check_product_event`，每天凌晨执行，检查`product`中的记录，如果对应的`sort_id`为空或者`sort_id`不在`sort`表中，则删除对应记录'
DO
BEGIN
	DELETE FROM product
	WHERE sort_id is null OR
		sort_id NOT IN (SELECT sort_id FROM sort);
END;
$$
DELIMITER ;

-- 练习4

-- 1. 迭代查询父节点
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

-- 2. 通用查询后代节点
DROP PROCEDURE IF EXISTS get_decendent_ids;
DELIMITER $$
CREATE PROCEDURE get_decendent_ids(IN tb VARCHAR(100), IN id_col VARCHAR(100), IN pid_col VARCHAR(100), IN id_value VARCHAR(100))
BEGIN
	-- DECLARE v_lev INT DEFAULT 0; -- 初始层数，id所在层
    DECLARE temptb VARCHAR(100);
    DECLARE temptemptb VARCHAR(100);  
    DECLARE querysql VARCHAR(100); 
    
	SET @v_lev := 0;  -- 初始层数，id所在层，注意因为prepare是会话层有效的，所以应该使用会话变量，使用局部变量会发生异常。
    SET temptb = CONCAT(tb, "_temp");  -- 用于存储树结构结果
    SET temptemptb = CONCAT(tb, "_temptemp");  -- 用于存储单次结果
    SET querysql = CONCAT(' SELECT ', id_col, ",", pid_col, ", @v_lev AS `level` FROM ");  -- select列信息
    
    -- 删除临时表prepare
    SET @stmt_droptemp_text := CONCAT("DROP TEMPORARY TABLE IF EXISTS ", temptb);
    SET @stmt_droptemptemp_text := CONCAT("DROP TEMPORARY TABLE IF EXISTS ", temptemptb);
    -- 创建临时表prepare
    SET @stmt_createtemp_text := CONCAT("CREATE TEMPORARY TABLE ", temptb, querysql, tb, " WHERE ", id_col, "=", id_value); -- 通过select创建存储树结构的临时表
	SET @stmt_createtemptemp_text := CONCAT("CREATE TEMPORARY TABLE ", temptemptb, " SELECT * FROM ", temptb, " WHERE 0 = 1");
	-- 截断temptemptb prepare
    SET @stmt_truncatetemptemp_text := CONCAT("TRUNCATE ", temptemptb);
    -- 插入查询数据prepare
    SET @stmt_inserttemptemp_text := CONCAT("INSERT INTO ", temptemptb, " SELECT * FROM ", temptb, " WHERE `level` = @v_lev - 1");
    SET @stmt_inserttemp_text := CONCAT("INSERT INTO ", temptb, ' SELECT k.', id_col, ", k.", pid_col, ", @v_lev AS `level` FROM ", tb, " k JOIN ", temptemptb, " t ON k.", pid_col, "=t.", id_col); -- 插入节点
    
    -- prepare statement
	PREPARE stmt_droptemp FROM @stmt_droptemp_text; -- 如果存在，删除临时表
    EXECUTE stmt_droptemp;
    
    PREPARE stmt_createtemp FROM @stmt_createtemp_text;  -- 创建临时表
    EXECUTE stmt_createtemp; -- 细节，执行之后才会有temp表，后面的涉及temp表的预处理才能成功，下同
    
    PREPARE stmt_droptemptemp FROM @stmt_droptemptemp_text;  -- 如果存在，删除临时临时表
    EXECUTE stmt_droptemptemp;
    
    PREPARE stmt_createtemptemp FROM @stmt_createtemptemp_text;  -- 创建临时临时表
    EXECUTE stmt_createtemptemp;
    
    PREPARE stmt_truncatetemptemp FROM @stmt_truncatetemptemp_text;  -- 截断临时临时表
    PREPARE stmt_inserttemptemp FROM @stmt_inserttemptemp_text;  -- 插入上一level的节点
    
    PREPARE stmt_inserttemp FROM @stmt_inserttemp_text;  -- 插入上一level节点对应的子节点
	
    -- 循环
	REPEAT
		SET @v_lev = @v_lev + 1;
		EXECUTE stmt_truncatetemptemp;
		EXECUTE stmt_inserttemptemp;
		EXECUTE stmt_inserttemp;
        
	UNTIL ROW_COUNT() = 0
	END REPEAT;
    
    EXECUTE stmt_droptemptemp;
    DEALLOCATE PREPARE stmt_droptemp;
    DEALLOCATE PREPARE stmt_droptemptemp;
    DEALLOCATE PREPARE stmt_createtemp;
    DEALLOCATE PREPARE stmt_createtemptemp;
    DEALLOCATE PREPARE stmt_truncatetemptemp;
    DEALLOCATE PREPARE stmt_inserttemp;
    DEALLOCATE PREPARE stmt_inserttemptemp;
    
END;
$$
DELIMITER ;

-- 示例1
set @tb = "prereq";
set @id_col = "course_id";
set @pid_col = "prereq_id";
set @id_value = "'CS-10'";

call get_decendent_ids(@tb, @id_col, @pid_col, @id_value);

SELECT * FROM prereq_temp;