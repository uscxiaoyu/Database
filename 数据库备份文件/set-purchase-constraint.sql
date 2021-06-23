use purchase;

set sql_safe_updates=0;
-- 1. 设置product的主键为product_id

-- 删除product_id为空的记录
delete from Product
where product_ID is null;

alter table Product modify Product_ID char(5) primary key;

-- 2. 设置product表的product_name和product_code字段非空
-- 不允许product_name为空
delete from Product
where product_name is null;

alter table Product modify product_name varchar(30);

-- 不允许product_code为空
delete from Product
where product_code is null;

alter table Product modify product_code varchar(10) not null;

-- 3. sort表
-- 设置sort表的主键为sort_id
delete from Sort
where sort_id is null;
                        
alter table Sort
modify sort_id char(2) primary key;

-- 4. subsort表
-- 设置主键为subsort_id
delete from SubSort
where subsort_id is null;

alter table SubSort
modify subsort_id char(5) primary key;

-- 5. 设置subsort表的外键约束
alter table SubSort
add constraint fk_1 foreign key(sort_id) references Sort(sort_id);

-- 6. 设置product表的外键约束
alter table Product 
modify sort_id char(2) not null,
modify subsort_id char(5) not null;
-- (1) 设置Product表的外键约束sort_id
-- 先删除subsort_id值不在subsort表中的product记录
delete from Product
where sort_id not in (select sort_id from Sort);

alter table Product
add constraint fk_sortid foreign key (sort_id) references Sort(sort_id);

-- (2) 设置Product表的外键约束subsort_id
-- 先删除sort_id值不在sort表中的product记录
delete from Product 
where subsort_id not in (select subsort_id from SubSort);

alter table Product
add constraint fk_subsortid foreign key (subsort_id) references SubSort(subsort_id);

-- 7. member表
-- 设置主键user_name
delete from Member where user_name is null;
alter table Member modify user_name varchar(50) primary key;

-- 8. order表
-- 主键order_id, 外键product_id, user_name
alter table `Order` 
drop column phone,
drop column mobile,
drop column email;

alter table `Order`
modify order_id varchar(20) primary key;

alter table `Order`
modify product_id char(5) not null,
modify user_name varchar(50) not null;

alter table `Order`
add constraint fk_usrname foreign key (user_name) references Member(user_name);

alter table `Order`
add constraint fk_prodid foreign key (product_id) references Product(product_id);

alter table `Order`
drop foreign key fk_prodid,
drop foreign key fk_usrname;
