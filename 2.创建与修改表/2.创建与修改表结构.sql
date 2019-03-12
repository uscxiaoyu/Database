-- 创建表
CREATE DATABASE stu_info;
USE stu_info;
CREATE TABLE tb_grade(id INT(11),
					  name VARCHAR(20),
					  grade FLOAT);

-- 查看表的创建
SHOW CREATE TABLE tb_grade;

-- 查看表结构
DESC tb_grade;

-- 课堂练习1
CREATE DATABASE purchase;
USE purchase;
CREATE TABLE Product (Product_ID CHAR(10) COMMENT '商品编号',
					  Product_Name VARCHAR(100) COMMENT '商品名称',
                      Product_Code VARCHAR(10) COMMENT '商品编码',
                      Price FLOAT COMMENT '价格',
                      Place CHAR(20) COMMENT '产地',
                      Unit VARCHAR(20) COMMENT '单位',
                      Detail VARCHAR(20) COMMENT '规格',
                      SubSort_ID VARCHAR(10) COMMENT '子类别id',
                      Sort_ID VARCHAR(10) COMMENT '跟类别id',
                      Description VARCHAR(255) COMMENT '商品说明');  # 关键字和自定义变量对大小写不敏感
DESC product;

CREATE TABLE tb_grade (id INT(11), name VARCHAR(20), grade FLOAT);

-- 修改表名
ALTER TABLE tb_grade RENAME TO grade;
DESC grade;

-- 修改字段名称
ALTER TABLE grade CHANGE `name` `username` VARCHAR(20);
DESC grade;

-- 修改字段属性
ALTER TABLE grade MODIFY id INT(20);
DESC grade;
ALTER TABLE grade CHANGE COLUMN id id INT(30);
DESC grade;

-- 添加字段
ALTER TABLE grade ADD age INT(3) AFTER username;
DESC grade;

-- 删除字段
ALTER TABLE grade DROP age;
DESC grade;

-- 复制表
CREATE TABLE grade_bac SELECT * FROM grade;
DESC grade_bac;

-- 字段排序
ALTER TABLE grade_bac MODIFY username VARCHAR(20) FIRST;
DESC grade_bac;
ALTER TABLE grade_bac MODIFY id INT(20) AFTER grade;
DESC grade_bac;

-- 删除表
DROP TABLE grade_bac;
DESC grade;

-- 课堂练习2

-- 将数据表Product名修改为tb_product。
ALTER TABLE product RENAME TO tb_product;
-- 修改数据表中字段Place名为Product_Place，数据类型为varchar(50)。
ALTER TABLE tb_product CHANGE COLUMN Place Product_Place VARCHAR(50) COMMENT '产地';
-- 增加Product_Date字段，数据类型为Date。
ALTER TABLE tb_product ADD COLUMN Product_Date DATE COMMENT '生产日期';
-- 删除Description字段。
ALTER TABLE tb_product DROP COLUMN description;
-- 将Product_Place和Product_Date字段位置移动到Price字段之前。
ALTER TABLE tb_product MODIFY Product_Place VARCHAR(50) COMMENT '产地' AFTER Product_Code;
ALTER TABLE tb_product MODIFY Product_Date DATE COMMENT '生产日期' AFTER Product_Place;
