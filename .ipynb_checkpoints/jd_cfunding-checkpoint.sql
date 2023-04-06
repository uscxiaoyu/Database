create database jd_crowdfunding character set utf8;
use jd_crowdfunding;

-- 公司表
create table company (
	company_name varchar(100) primary key,
    company_address varchar(255),
    company_phone varchar(15),
    company_hours varchar(40)
	) default character set utf8;

-- 发起者表
create table promoter (
	promoter_name varchar(100) primary key,
    promoter_href varchar(100)
    ) default character set utf8;
    
-- 项目所属类别表
create table sort ( 
	sort_id char(2) primary key,
	sort_name varchar(5)
    ) default character set utf8;
    
insert into sort(sort_id, sort_name)
values ('10', '科技'), ('36', '美食'), ('37', '家电'), ('12', '设计'), ('11', '娱乐'), ('38', '出版'),
	('13', '公益'), ('14', '其它');

select * from sort;

-- 项目状态表
create table state(
	state_id char(2) primary key,
    state_name char(5) not null
    ) default character set utf8;

insert into state(state_id, state_name)
values ('1', '预热中'), ('2', '众筹中'), ('4', '众筹成功'), ('8', '项目成功');

-- 项目表
create table project (
	p_id varchar(6) primary key,
    p_name varchar(100) not null,
    target_fund int(7) not null,
    create_time time,
    end_time time,
    f_state enum('成功', '失败') default null,
    promoter_name varchar(100),
    company_name varchar(100),
    state_id char(2),
    sort_name char(10),
    foreign key (company_name) references company (company_name),
    foreign key (promoter_name) references promoter (promoter_name)
    ) default character set utf8;
    
-- 项目状态表    
create table porject_state (
	p_id varchar(6) not null,
    updateTime time not null,
    now_supporters int(7),
    now_fund int(7),
    now_percent int(4),
    now_praise int(6),
    now_focus int(6),
    primary key (p_id, updateTime),
    foreign key (p_id) references project (p_id)
	) default character set utf8;

-- 项目各档位表    
create table project_indiv (
	p_id varchar(6) not null,
    i_id char(2) not null,
    support_price int(6),
    deliver_info varchar(255),
    lim_num varchar(10),
    redound_info varchar(255),
    primary key (p_id, i_id),
    foreign key (p_id) references project (p_id)
	) default character set utf8;

-- 项目各档位状态表
create table project_indiv_state (
	p_id varchar(6) not null,
    i_id char(2) not null,
    updateTime time not null,
    now_num_sup int(7)
	) default character set utf8;


-- 评论表
create table review(
    p_id varchar(6) not null,
    rev_name varchar(20),
    rev_content varchar(255),
    rev_time time,
    
	) default character set utf8;

-- 参与评论者表
create table reviewer(
	rev_name
    ) default character set utf8;


-- 评论主题表

