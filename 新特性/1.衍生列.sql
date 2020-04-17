-- 1. 衍生列（generated column）
/*
在基础列的上，通过一定的运算转换而定义生成的列，即为衍生列。
CREATE TABLE <t_name> (
	col1 <col_type>,
    g_col <col_type> GENERATED ALWAYS AS (<computation on col1>) [stored]
    );

-- 有两种类型的衍生列：stored和virtual。如果不给定，则vitual。stored 意味着有物理空间直接存储生成列的值，可以在上面建立索引；
virtual意味着在查询该字段时生成对应的列值，不能直接在其上建立索引。

生成列的构建可包含字面量、确定性内建函数和操作符、基本列、创建于其前的生成列。

以下不允许出现在生成列定义中：
- 不确性内建函数如current_date(), current_timestamp()等
- 用户自定义存储过程，系统、用户、局部变量等
- 子查询
- 在其后定义的生成列
- auto_increment

使用create table ... like 可保留原表中的生成列定义；使用create table ... select则不能。

生成列不能作为被参照列。

生成列的使用场景：

- 简化和整合查询。复杂条件可通过生成列表示，查询可直接指向该列，从而保证查询条件的一致性。
- 作为复杂条件或运算的物化存储，提前缓存，从而减少查询时间
- 模拟函数索引，如可在json列中的某些子属性创建生成列，进而构建索引。（缺点在于，该属性数据将存储两次）
- 查询优化器可识别出使用了生成列定义的查询，从而可利用创建在生成列上的索引，即便该查询未直接使用该列。
*/

drop table if exists person;

CREATE TABLE person(
	id int primary key,
    first_name varchar(20) not null,
    last_name varchar(20) not null,
    `name` varchar(50) generated always as (concat(first_name, ' ', last_name)) stored,
    index idx_name (`name`));

alter table person modify `name` varchar(50) generated always as (concat(first_name, ' ', last_name)) stored;

show create table person;

delete from person;
insert into person(id, first_name, last_name)
values (1, 'Mike', 'James');

select * from person;


drop table t1;
CREATE TABLE t1 (
  first_name VARCHAR(10),
  last_name VARCHAR(10),
  full_name VARCHAR(255) AS (CONCAT(first_name,' ',last_name)),
  index idx_name(full_name)
);

show create table t1;

