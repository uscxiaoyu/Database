-- 一、数据定义

-- 1. 创建 order_management 数据库(2分)
create database order_management;
use order_management;

-- 2. 创建表（22分）
create table waiter (
	w_id int primary key,
	w_name varchar(25),
    gender enum('男', '女'),
    birthday date,
    hire_date date);

create table cooker (
	c_id int primary key,
    c_name varchar(25),
    gender enum('男', '女'),
    birthday date,
    hire_date date);

create table board (
	b_id varchar(10) primary key,
    state enum('有人', '无人'),
    num_customer int
    );

create table dish (
	d_id int primary key,
    d_name varchar(50)
	);

create table service(
	s_id int primary key,
    w_id int,
    b_id varchar(10),
    start_time datetime,
    end_time datetime,
    state varchar(10),
    constraint fk_service_waiter foreign key (w_id) references waiter (w_id),
    constraint fk_service_board foreign key (b_id) references board (b_id)
);

create table `order` (
	o_id int primary key,
    b_id varchar(10),
    d_id int,
    start_time datetime,
    end_time datetime,
    state varchar(10),
    constraint fk_order_board foreign key (b_id) references board (b_id),
    constraint fk_order_dish foreign key (d_id) references dish (d_id)
);

create table `cooking` (
	c_id int primary key,
    o_id int,
    start_time datetime,
    end_time datetime,
    state varchar(10),
    constraint fk_cooking_order foreign key (o_id) references `order` (o_id)
);

-- 3. 删除`waiter`和`cooker`表中的`birthday`字段（6分）
alter table waiter drop birthday;

-- 二、数据操纵
-- 1. 在下表中插入以下记录（12分）
insert into board (b_id, state, num_customer)
values ('A1', '有人', 5),
('A2', '有人', 2),
('A3', '无人', null),
('B1', '有人', 6);

insert into waiter (w_id, w_name, gender, hire_date)
values (101, '王小哥', '男', '2020-10-01'),
(102, '李小妹', '女', '2021-05-10'),
(103, '周小弟', '男', '2018-08-15');

insert into service (s_id, w_id, b_id, start_time, end_time, state)
values (1, 101, 'A1', '2021-10-11 11:20:31', '2021-10-11 12:20:00', '完成'),
(2, 103, 'A2', '2021-10-11 11:22:52', '2021-10-11 12:31:01', '完成'),
(3, 101, 'B1', '2021-10-11 11:30:53', null, '正在服务');

-- 2. `service`表`s_id=3`的服务在`'2021-10-11 12:56:20'已完成`，请更新改行对应的字段。(4分)
update service
set end_time = '2021-10-11 12:56:20'
where s_id=3;

-- 3. 删除`waiter`表中`w_id=101`的记录行。(8分)
delete from service
where w_id=101;

delete from waiter
where w_id=101;

-- 三、数据查询
use student_system;
show tables;
select * from student limit 10;
-- 1. 查询所有学生党员的信息。(6分)
select * from student where is_party_member = '是';

-- 2. 查询1986年1月1日之后出生的学生，返回学号、学生姓名、出生天数、出生日期和生日，按照出生天数升序排序。
-- datediff()可以计算两个日期之间的天数间隔。(6分)
select s_id, s_name, datediff(curdate(), birthday) days, birthday
from student
where birthday > '1986-01-01'
order by days;

-- 3. 查询各年份对应的学生数量，返回4位数年份、学生数量，按学生数量降序排序。(8分)
select year(birthday) 年份, count(s_id) 数量
from student
group by 年份
order by 数量 desc;

-- 4. 查询`工商管理`专业的男党员，返回专业、学号、姓名和奖学金。(6分)
select m_name 专业, s_id 学号, s_name 姓名, scholar 奖学金
from student natural join major
where m_name = '工商管理' and is_party_member = "是";

-- 5. 查询党员和非党员的奖学金总额和奖学金均值(保留2位小数，四舍五入)。(10分)
select if(is_party_member='是', '党员', '非党员') 是否党员, round(sum(scholar), 2) 奖学金总额, round(avg(scholar), 2) 奖学金均值
from student
group by is_party_member;

-- 6. 查询各门课程得分为优良（80分及以上）的人数，返回优良人数大于等于10的课程号、课程名称和优良人数，按良好人数降序排序。(10分)
select c_id, c_name, count(*) 优良人数
from takes natural join course
where score >= 80
group by c_id
having 优良人数 >= 10
order by 优良人数 desc;