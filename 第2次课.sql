-- 创建表
CREATE DATABASE stu_info;
USE stu_info;
CREATE TABLE tb_grade(id INT(11),
					  name VARCHAR(20),
					  grade FLOAT);

-- 查看表的创建
show create table tb_grade;

-- 查看表结构
desc tb_grade;

-- 课堂练习1
create database purchase;
use purchase;
create table Product (Product_ID char(10),
					  Product_Name varchar(100),
                      Product_Code varchar(10),
                      Price float,
                      Place char(20),
                      Unit varchar(20),
                      Detail varchar(20),
                      SubSort_ID varchar(10),
                      Sort_ID varchar(10),
                      Description varchar(255));  # 关键字和自定义变量对大小写不敏感
desc product;

create table tb_grade (id int(11), name varchar(20), grade float);

-- 修改表名
alter table tb_grade rename to grade;
desc grade;

-- 修改字段名称
alter table grade change `name` `username` varchar(20);
desc grade;

-- 修改字段属性
alter table grade modify id int(20);
desc grade;
alter table grade change column id id int(30);
desc grade;

-- 添加字段
alter table grade add age int(3) after username;
desc grade;

-- 删除字段
alter table grade drop age;
desc grade;

-- 复制表
create table grade_bac select * from grade;
desc grade_bac;

-- 字段排序
ALTER TABLE grade_bac MODIFY username VARCHAR(20) FIRST;
desc grade_bac;
ALTER TABLE grade_bac MODIFY id INT(20) AFTER grade;
desc grade_bac;

-- 删除表
drop table grade_bac;
desc grade;

-- 课堂练习2
alter table product rename to tb_product;
alter table tb_product change column Place Product_Place varchar(50);
alter table tb_product add column Product_Date Date;
alter table tb_product drop column Description;
ALTER TABLE tb_product MODIFY Product_Date DATE AFTER Product_Place;  #修改字段顺序

alter table tb_product rename to product;