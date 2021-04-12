use purchase;
set sql_safe_updates = 0;
-- product表的主键约束
select * from product where product_id is null;
delete from product where product_id is null;
alter table product add primary key (product_id);

-- sort表的主键约束
alter table sort add primary key (sort_id);

-- subsort表的主键约束
alter table subsort add primary key (subsort_id);

-- product的sort_id参照sort表的sort_id
select product_id, sort_id from product where sort_id not in (select sort_id from sort);
alter table product 
add constraint fk_sortid foreign key (sort_id) references sort(sort_id);

-- product的subsort_id参照subsort表的subsort_id
select distinct subsort_id 
from product 
where subsort_id not in (select distinct subsort_id from subsort);

insert into subsort(subsort_id, subsort_name, sort_id)
values (3317, 'a', 33), (6412, 'b', 64);

alter table product 
add constraint fk_subsortid foreign key (subsort_id) references subsort(subsort_id);

-- subsort表的sort_id参照sort表的subsort_id
alter table subsort 
add constraint fk_sortid_sort foreign key (sort_id) references sort(sort_id);