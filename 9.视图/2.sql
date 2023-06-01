show databases ;

select sort_id, subsort_id, num_product, s_rank
from (select if(@last_sortid = sort_id,
                if(@last_numproduct = num_product, @row_num, @row_num := @row_num + 1),
                @row_num := 1)                  s_rank,
             @last_sortid := sort_id         as sort_id,
             @last_numproduct := num_product as num_product,
             subsort_id
      from (select a.sort_id, b.subsort_id, count(*) num_product
            from sort a
                     left join subsort b on a.sort_id = b.sort_id
                     left join product c on b.subsort_id = c.SubSort_ID
            group by a.sort_id, b.SubSort_ID
            order by a.sort_id, num_product desc) u,
           (select @row_num := null, @last_sortid := null, @last_numproduct := null) v) x
where s_rank <= 5;

-- step 1: u, v
select a.sort_id, b.subsort_id, count(*) num_product
from sort a
         left join subsort b on a.sort_id = b.sort_id
         left join product c on b.subsort_id = c.SubSort_ID
group by a.sort_id, b.SubSort_ID
order by a.sort_id, num_product desc;

select @row_num := null, @last_sortid := null, @last_numproduct := null;

-- step 2: x
select if(@last_sortid = sort_id,
          if(@last_numproduct = num_product, @row_num, @row_num := @row_num + 1),
          @row_num := 1)                  s_rank,
       @last_sortid := sort_id         as sort_id,
       @last_numproduct := num_product as num_product,
       subsort_id
from (select a.sort_id, b.subsort_id, count(*) num_product
      from sort a
               left join subsort b on a.sort_id = b.sort_id
               left join product c on b.subsort_id = c.SubSort_ID
      group by a.sort_id, b.SubSort_ID
      order by a.sort_id, num_product desc) u,
     (select @row_num := null, @last_sortid := null, @last_numproduct := null) v;

-- step 3: filter
select sort_id, subsort_id, num_product, s_rank
from (select if(@last_sortid = sort_id,
                if(@last_numproduct = num_product, @row_num, @row_num := @row_num + 1),
                @row_num := 1)                  s_rank,
             @last_sortid := sort_id         as sort_id,
             @last_numproduct := num_product as num_product,
             subsort_id
      from (select a.sort_id, b.subsort_id, count(*) num_product
            from sort a
                     left join subsort b on a.sort_id = b.sort_id
                     left join product c on b.subsort_id = c.SubSort_ID
            group by a.sort_id, b.SubSort_ID
            order by a.sort_id, num_product desc) u,
           (select @row_num := null, @last_sortid := null, @last_numproduct := null) v) x
where s_rank <= 5;

select sort_id, subsort_id, num_product, 排名
from (select sort_id,
             subsort_id,
             num_product,
             if(sort_id = @last_sort_id,
                if(num_product = @last_num_product, @r, @r := @r + 1), @r := 1) 排名,
             @last_sort_id := sort_id,
             @last_num_product := num_product
      from (select sort_id, subsort_id, count(*) num_product
            from product
            group by sort_id, subsort_id
            order by sort_id, num_product desc) x,
           (select @r := null, @last_sort_id := null, @last_num_product := null) r) a
where 排名 <= 5;
# @last_sort_id和@last_num_product分别上一行记录值，有些数量的行的排名应该相同

-- step 1: 根据subsort_id分组，并按照sort_id排序；初始化用户会话变量
select sort_id, subsort_id, count(*) num_product
from product
group by sort_id, subsort_id
order by sort_id, num_product desc;

select @r := null, @last_sort_id := null, @last_num_product := null;

-- step2: 获取组内排名
select sort_id,
       subsort_id,
       num_product,
       if(sort_id = @last_sort_id,
          if(num_product = @last_num_product, @r, @r := @r + 1), @r := 1) 排名,
       @last_sort_id := sort_id,
       @last_num_product := num_product
from (select sort_id, subsort_id, count(*) num_product
      from product
      group by sort_id, subsort_id
      order by sort_id, num_product desc) x,
     (select @r := null, @last_sort_id := null, @last_num_product := null) r;

-- step3: 过滤
select sort_id, subsort_id, num_product, 排名
from (select sort_id,
             subsort_id,
             num_product,
             if(sort_id = @last_sort_id,
                if(num_product = @last_num_product, @r, @r := @r + 1), @r := 1) 排名,
             @last_sort_id := sort_id,
             @last_num_product := num_product
      from (select sort_id, subsort_id, count(*) num_product
            from product
            group by sort_id, subsort_id
            order by sort_id, num_product desc) x,
           (select @r := null, @last_sort_id := null, @last_num_product := null) r) a
where 排名 <= 5;