-- 创新示例数据库和表
CREATE DATABASE stu_grade;
USE stu_grade;

CREATE TABLE `student` (`id` INT(4) PRIMARY KEY,
                        `name` VARCHAR(20) NOT NULL,
                        `grade` FLOAT);

-- 一、插入数据
-- 课堂示例1：运用INSERT语句插入数据时，指定所有字段名
INSERT INTO student(`id`, `name`, `grade`)
	VALUES(2, 'zhangsan', 98.5);

SELECT * FROM student; -- 查看student表中的所有数据

-- 课堂示例2：运用INSERT语句插入数据时，指定所有字段名，打乱顺序
INSERT INTO student(`name`, `grade`, `id`)
	VALUES('lisi', 95, 2);
    
SELECT * FROM student;

-- 课堂示例3：运用INSERT语句插入数据时，不指定字段名, 需严格按字段的顺序提供值
INSERT INTO student
	VALUES(3, 'wangwu', 61.5);
    
SELECT * FROM student;

INSERT INTO student
	VALUES('wanqi', 4, 61.5); # 如果不按指定顺序，则可能发生插入错误

-- 课堂示例4：运用INSERT语句插入数据时，向指定字段中添加值。
INSERT INTO student(`id`, `name`)
	VALUES(4, 'zhaoliu');

SELECT * FROM student;

-- 课堂示例5：运用INSERT语句插入数据时，向指定字段中添加值。(注意字段的约束)
-- name字段上的非空约束
INSERT INTO student(`id`,`grade`)
	VALUES(5,'97');
-- 主键约束
INSERT INTO student(`id`, `name`, `grade`)
	VALUES(4, 'longli', 50); # 键值4已存在

INSERT INTO student(`name`, `grade`)
	VALUES('xiaofang', 99); # 未设置auto_increment的情况下，必须提供主键值
    
-- 课堂示例6：运用INSERT…SET语句为表中指定字段或全部字段添加数据
INSERT INTO student
	SET `id`=5, `name`='boya', `grade`=99;

-- 课堂示例7：运用INSERT语句为student表中所有字段添加三条数据
INSERT INTO student VALUES
		   (6,'lilei',99),
		   (7,'hanmei',100),
		   (8,'poly',40.5);
           
-- 课堂示例8：运用INSERT语句为student表中指定字段增加多条记录
INSERT INTO student (`id`,`name`) VALUES
			(9,'liubei'), 
            (10,'guanyu'), 
            (11,'zhangfei');

-- 课堂练习
CREATE DATABASE purchase;
USE purchase;
DROP TABLE IF EXISTS product;
CREATE TABLE `product` (
  `Product_ID` char(10) PRIMARY KEY,
  `Product_Name` varchar(100) UNIQUE,
  `Product_Code` varchar(10) NOT NULL,
  `Product_Place` varchar(50) DEFAULT NULL,
  `Product_Date` date DEFAULT NULL,
  `Price` float DEFAULT 0,
  `Unit` varchar(20) DEFAULT NULL,
  `Detail` varchar(20) DEFAULT NULL,
  `SubSort_ID` varchar(10) NOT NULL,
  `Sort_ID` varchar(10) NOT NULL);

INSERT INTO product(`product_id`, `product_name`, `product_code`, `product_place`, `product_date`, `price`, `unit`, `detail`, `subsort_id`, `sort_id`) VALUES
  (1035, '商务型U盘128M', 1314027, '上海', '2010/9/10', 325, '片', '1片*1盒', '1314', '13'),
  (1048, '索尼CD-RW刻录盘', 1314040, '上海', '2012/12/1', 15, '片', '1片*1盒', '1314', '13'),
  (1058, 'LG刻录机', 1314050, '惠州', '2015/3/9', 410, '台', '1*1', '1314', '13'),
  (1100, '东芝2868复印机', 1101011, '日本', '2016/6/20', 17250, '台', '1*1', '1101', '11'),
  (1170, '柯达牌喷墨专用纸', '2205027', '美国', '2012/12/12', 56, '包', '100张/10包/箱', '2205', '22');

SELECT * FROM product;

-- 二、更新数据
-- 课堂示例10：更新student表中id字段值为1的记录。将该记录的name字段的值更新为caocao，grade字段的值更新为50
USE stu_grade;

SELECT * FROM student WHERE `id` = 1;

UPDATE student
SET `name` = 'caocao', `grade` = 50
WHERE `id`=1;

SELECT * FROM student WHERE `id` = 1;

-- 课堂示例11：更新student表中id字段值小于4的记录。将些记录的grade字段的值都更新为100
SELECT * FROM student WHERE `id` < 4;

UPDATE student
SET `grade` = 100
WHERE id < 4;

SELECT * FROM student WHERE `id` < 4;

-- MySQL默认模式是安全更新模式，在该模式下，会导致非主键条件下无法执行更新。要把MySQL数据库设置为非安全更新模式 
SET SQL_SAFE_UPDATES=0;  -- 重置SQL模式
UPDATE student
SET `grade`=90
WHERE `grade`=100;

-- 课堂练习2
USE purchase;

SELECT * FROM product;

-- 惠州->广东
UPDATE product
SET `Product_Place`='广东'
WHERE `Product_Place`='惠州';

SELECT * FROM product;

-- 价格下降10%
UPDATE product
SET `price` = `price` * 0.9;

SELECT * FROM product;

-- 2012以后的产品价格增加20%
UPDATE product
SET `price` = `price` * 1.1
WHERE YEAR(`Product_Date`) > 2012;

SELECT * FROM product;


-- 三、删除数据
USE stu_grade;
-- 首先将student表复制为student_bak1表

CREATE TABLE student_bak1 SELECT * FROM student;

-- 课堂示例12：在student_bak1表中，删除id字段值为11的记录。
DELETE FROM student_bak1
WHERE `id` = 11;

SELECT * FROM student_bak1;

-- 课堂示例13：在student_bak1表中，删除id字段值大于5的所有记录。
DELETE FROM student_bak1
WHERE `id` > 5;

SELECT * FROM student_bak1;

-- 课堂示例14：删除student_bak1表中所有记录。
DELETE FROM student_bak1;


-- TRUNCATE
-- 首先将student表复制为student_bak2表。
CREATE TABLE student_bak2 SELECT * FROM student;

-- 课堂示例15：在student_bak2表中，删除id字段值2到5之间的所有记录(其中值包含2，不包含5)。
SELECT * FROM student_bak2;

DELETE FROM student_bak2
WHERE `id` >= 2 and `grade` < 5;

-- 课堂示例16：使用TRUNCATE删除student_bak2表中所有记录。
TRUNCATE TABLE student_bak2;

SELECT * FROM student_bak2;

-- DELETE和TRUNCATE完全删除表记录的区别：
/* (1) 使用TRUNCATE语句删除表中的数据，再向表中添加记录时，自动增加字段的默认初始值重新由1开始，
使用DELETE语句删除表中所有记录，再向表中添加记录时，自动增加字段的值为删除时该字段的最大值加1;
(2) 使用DELETE语句时，每删除一条记录都会在日志中记录，而使用TRUNCATE语句时，不会在日志中记录删除的内容，
因此TRUNCATE语句的执行效率比DELETE语句高。*/

-- 课堂练习3
USE purchase;

-- 删除product数据表中产地字段为”美国”的记录。
DELETE FROM product
WHERE `Product_Place` = '美国';

SELECT * FROM product;

-- 删除product数据表中产品的价格在100和500之间的记录。
DELETE FROM product
WHERE `Price` >= 100 and `Price` <= 500;
-- 或者用以下条件：
DELETE FROM product
WHERE `Price` between 100 and 500;

SELECT * FROM product;

-- 删除product数据表中上半年生产的产品。
DELETE FROM product
WHERE MONTH(`Product_Date`) <= 6;

SELECT * FROM product;

-- 复制product数据表为product_bak。
CREATE TABLE product_bak SELECT * FROM product;

-- 用TRUNCATE语句删除product_bak数据表中所有记录。
SELECT * FROM product_bak;

TRUNCATE product_bak;
