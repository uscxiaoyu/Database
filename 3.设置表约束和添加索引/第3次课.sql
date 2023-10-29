-- 第三次课。请务必先导入上次课的stu_info和purchase数据库。
use stu_info;
drop table if exists student;
CREATE TABLE student(
    id int,
    name varchar(20),
    grade float);

-- 单字段主键：
-- 课堂示例13--将数据表student中id字段设置为主键。
use stu_info;
alter table student modify id int primary key;
desc student;


-- 多字段主键：
-- 课堂示例14--新建数据表example，并创建id字段，属性为INT(10)，并设置为主键。
create table example (id int(10) primary key);
create table example2 (id int(10), 
						primary key (id));
desc example;

-- 多字段主键：
-- 课堂示例15--新建数据表course，创建stu_id、course_id和grade三个字段，其中stu_id和course_id设置为多字段主键。
create table stu_course (stu_id int,
                         course_id int,
                         grade float,
                         primary key (stu_id, course_id));

desc stu_course;

-- 非空约束： 
-- 课堂示例16--将student表的name字段改为非空
ALTER TABLE student change `name` `name` VARCHAR(20) NOT NULL;
-- 或者
ALTER TABLE student MODIFY `name` VARCHAR(20) NOT NULL;

desc student;

-- 唯一性约束：
-- 课堂示例17--将数据表student中name字段设置唯一性约束。
show create table student;
ALTER TABLE student MODIFY `name` VARCHAR(20) UNIQUE;
-- ALTER TABLE student MODIFY `name` VARCHAR(20) NOT NULL UNIQUE;
desc student;

-- 默认值：
-- 课堂示例18：将数据表student中grade字段设置默认约束值为0。
ALTER TABLE student MODIFY grade FLOAT DEFAULT 0;
desc student;



-- 课堂练习
use purchase;
alter table product MODIFY Product_ID CHAR(5) PRIMARY KEY COMMENT '商品编号';
alter table product MODIFY Product_Name VARCHAR(100) UNIQUE COMMENT '商品名称'; -- 有重复记录
alter table product MODIFY Product_Code VARCHAR(10) NOT NULL COMMENT '商品号';
alter table product MODIFY Price DECIMAL(10, 2) DEFAULT 0;
alter table product MODIFY SubSort_ID CHAR(5) NOT NULL COMMENT '子类别ID';
alter table product MODIFY Sort_ID CHAR(2) NOT NULL COMMENT '类别ID';

desc product;


-- 主键的自增auto_increment
-- 课堂示例19：在数据表student中id字段，设置为字段值自动增加。
use stu_info;
alter table student modify id int auto_increment;
desc student;


-- foreign key
USE stu_info;

CREATE TABLE department(
	deptid INT PRIMARY KEY,
  	deptname VARCHAR(40) NOT NULL);

CREATE TABLE student(
    sid INT PRIMARY KEY,
    sname VARCHAR(40),
    deptid INT NOT NULL,
    CONSTRAINT fk_deptid FOREIGN KEY (deptid) REFERENCES department(deptid));

alter table student drop constraint fk_deptid;
show create table student;

desc student;

-- 创建索引
-- 课堂示例20：创建表的时候创建索引。
drop table if exists student;
 CREATE TABLE student(stu_id int(10),
                      name varchar(20),
                      course varchar(50),
					  score float,
                      description varchar(100),
                      INDEX(stu_id),                           #创建普通索引
                      UNIQUE INDEX unique_id(stu_id ASC),      #创建唯一性索引
                      FULLTEXT INDEX fulltext_name(name),      #创建全文索引
                      INDEX single_course(course(50)),         #创建单列索引
                      INDEX multi(stu_id, name(20))            #创建多列索引
                      );

show create table student;

-- 课堂示例21：创建book1。
CREATE TABLE book1(bookid int NOT NULL,
                   bookname varchar(255) NOT NULL,
                   authors varchar(255) NOT NULL,
                   info varchar(255) NOT NULL,
                   comment varchar(255) NOT NULL,
                   publicyear YEAR NOT NULL
                   );

-- 课堂示例21：使用CREATE INDEX 语句在book1表上创建索引。
CREATE INDEX index_id ON book1(bookid);                         #创建普通索引
CREATE UNIQUE INDEX uniqueidx ON book1(bookid);                 #创建唯一性索引
CREATE INDEX singleidx ON book1(comment);                       #创建单列索引
CREATE INDEX mulitidx ON book1(bookname(20), authors(20));      #创建多列索引
CREATE FULLTEXT INDEX fulltextidx ON book1(info);               #创建全文索引

desc book1;

-- 课堂示例22：使用ALTER TABLE语句在已经存在表上创建索引。
-- 先将数据表book1复制为book2表。
CREATE TABLE book2 SELECT * FROM book1;
show create table book2;

-- 添加索引
ALTER TABLE book2 ADD INDEX index_id(bookid);                   #创建普通索引
ALTER TABLE book2 ADD UNIQUE INDEX uniqueidx(bookid);           #创建唯一性索引
ALTER TABLE book2 ADD INDEX singleidx(comment(50));             #创建单列索引
ALTER TABLE book2 ADD INDEX mulitidx(bookname(20),authors(20)); #创建多列索引
ALTER TABLE book2 ADD FULLTEXT INDEX fulltextidx(info);         #创建全文索引

DROP INDEX uniqueidx ON book2;


-- 课堂示例23：删除表book1中名称为fulltextidx的全文索引。
alter table book1 drop index fulltextidx;
-- 课堂示例24：删除表book1中名称为singleidx的单列索引。
drop index singleidx on book1;

-- 课堂练习4
create unique index pcode_idx on product(Product_Code);
create index detail_idx on product(Detail);
create fulltext index pplace_fullidx on product(Product_Place);

show create table book2;