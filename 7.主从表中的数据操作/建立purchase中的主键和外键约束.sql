use purchase;
set sql_safe_updates = 0;
-- product表的主键约束
select * from product where product_id is null;
delete from product where product_id is null;

select *
from product
where product_id in (select product_id from product group by product_id having count(*) > 1);

delete from product
where product_id in (33, 44) and Sort_ID is null;

alter table product add primary key (product_id);
select count(*) from product;

-- sort表的主键约束
select * from sort;

select sort_id, count(*) 
from sort group by sort_id 
having count(*) > 1;  -- 查看是否有重复值

alter table sort add primary key (sort_id);

-- subsort表的主键约束
alter table subsort add primary key (subsort_id);

-- product的sort_id参照sort表的sort_id
select product_id, sort_id 
from product 
where sort_id not in (select sort_id from sort); -- 是否存在约束外值

select *
from product left join sort on product.sort_id = sort.sort_id
where sort.sort_id is null;  

alter table product 
add constraint fk_sortid foreign key (sort_id) references sort(sort_id);

-- product的subsort_id参照subsort表的subsort_id
select distinct subsort_id, sort_id
from product 
where subsort_id not in (select distinct subsort_id from subsort);

update product
set subsort_id = null
where subsort_id not in (select distinct subsort_id from subsort); -- 设为null

insert into subsort(subsort_id, subsort_name, sort_id)
values (3317, 'a', 33), (6412, 'b', 64);

alter table product 
add constraint fk_subsortid foreign key (subsort_id) references subsort(subsort_id);

-- subsort表的sort_id参照sort表的subsort_id
alter table subsort 
add constraint fk_sortid_sort foreign key (sort_id) references sort(sort_id);

-- on update cascade
delete from sort where sort_id = 93;
insert into sort(sort_id, sort_name) values (93, '其它');

select * from sort;
select * from sort where sort_id = 33;
select * from product where sort_id = 33;
select * from subsort where sort_id = 33;

-- 更新失败
update sort set sort_id = 93 where sort_id = 33;

alter table product
drop foreign key fk_sortid;

alter table product 
add constraint fk_sortid foreign key (sort_id) references sort(sort_id) on update cascade;

alter table subsort 
drop foreign key fk_sortid_sort;

alter table subsort 
add constraint fk_sortid_sort foreign key (sort_id) references sort(sort_id) on update cascade;

-- 再次更新
update sort set sort_id = 93 where sort_id = 33;

select * from product where sort_id=93 limit 10;
select * from sort where sort_id=93;

select * from sort;

-- 还原
update sort set sort_id = 33 where sort_id = 93;

-- on update set null
alter table product
drop foreign key fk_sortid;

alter table product 
add constraint fk_sortid foreign key (sort_id) references sort(sort_id) on update set null;

alter table subsort 
drop foreign key fk_sortid_sort;

alter table subsort 
add constraint fk_sortid_sort foreign key (sort_id) references sort(sort_id) on update set null;

update sort set sort_id = 93 where sort_id = 33;

select * from product where sort_id = 93;
select * from subsort where sort_id = 93;
select * from subsort where sort_id is null;
