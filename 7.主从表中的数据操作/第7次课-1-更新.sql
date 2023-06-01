-- 4. 更新数据

-- 示例6：将sort表中sort_id=33更新为sort_id=93.
select * from sort where sort_id=33;

insert into sort(sort_id, sort_name) values (93, '其它');
-- 查看sort_id=33是否被product和subsort表参照
select * from product where sort_id=33 limit 10;
select * from sort where sort_id=33;

-- 查看product表和subsort表中外键约束
show create table product;
show create table subsort;

-- 方法1: on update cascade
update sort set sort_id = 94 where sort_id = 33;

alter table product
drop foreign key fk_sortid1;

alter table product 
add constraint fk_sortid1 foreign key (sort_id) references sort(sort_id) on update cascade;

alter table subsort 
drop foreign key fk_sortid2;

alter table subsort 
add constraint fk_sortid2 foreign key (sort_id) references sort(sort_id) on update cascade;

show create table product;
show create table subsort;

select * from product where sort_id=94 limit 10;
select * from sort where sort_id=94;

select * from sort;

-- 方法2: on update set null
alter table product
drop foreign key fk_sortid1;

alter table product 
add constraint fk_sortid1 foreign key (sort_id) references sort(sort_id) on update set null;

alter table subsort 
drop foreign key fk_sortid2;

alter table subsort 
add constraint fk_sortid2 foreign key (sort_id) references sort(sort_id) on update set null;

update sort set sort_id = 96 where sort_id = 94;


select * from product where sort_id = 94 limit 10;
select * from product where sort_id is null limit 10;
select * from subsort where sort_id is null;