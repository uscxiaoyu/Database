show databases;
use mysql;
show tables;
desc user;
desc db;
DESC tables_priv;
DESC columns_priv;
desc procs_priv;
select * from user;

CREATE USER 'ali'@'localhost' IDENTIFIED BY '11111';
CREATE USER 'ali' IDENTIFIED BY '11111';
select old_password('11111');

select sha('11111');

CREATE USER 'ali_lock'@'localhost' IDENTIFIED BY '11111' ACCOUNT LOCK;
SELECT `user`, `host`, `plugin`, `authentication_string`, `account_locked`,
       max_updates, max_questions, max_connections, password_expired, password_lifetime
FROM mysql.user;

-- 限制其每小时最多可以更新10次
CREATE USER 'bob'@'localhost' IDENTIFIED BY '11111'
WITH MAX_UPDATES_PER_HOUR 10 max_queries_per_hour 15 max_connections_per_hour 20;
-- 查看user表的max_updates字段
SELECT max_updates
FROM mysql.user
WHERE `user`='bob' AND host='localhost';

CREATE USER 'cindy'@'localhost' IDENTIFIED BY '11111'
PASSWORD EXPIRE INTERVAL 180 DAY;

-- mysql5.7运行成功, mysql8运行不成功
GRANT SELECT ON purchase.product
TO 'dog'@'localhost'
IDENTIFIED BY '11111';

select version();
show variables like "%version%";
-- 等价于
-- 创建用户
CREATE USER 'dog'@'localhost'
IDENTIFIED BY '11111';
-- 对该用户赋权
GRANT SELECT ON purchase.product
TO 'dog'@'localhost';

ALTER USER 'ali'@'%' IDENTIFIED BY '22222';
-- 或者
SET PASSWORD FOR 'ali'@'%' = '33333';

SELECT `user`, `host`, `plugin`, `authentication_string` FROM mysql.user;

RENAME USER 'ali'@'localhost' TO 'alice'@'localhost';

DROP USER 'alice'@'localhost';

CREATE USER 'ali'@'localhost' IDENTIFIED BY '11111';

GRANT insert, select ON purchase.product
TO 'ali'@'localhost'
WITH GRANT OPTION;

show grants for ali@localhost;
show grants for 'bob'@'localhost';

select * from user;
select * from tables_priv;

REVOKE INSERT ON purchase.product FROM ali@localhost;

REVOKE ALL PRIVILEGES, GRANT OPTION FROM ali@localhost, 'bob'@'localhost';

select * from sort;

delete product, sort
from product join sort on sort.sort_id=product.sort_id
where sort_name = '办公机器设备';

select * from product JOIN sort ON product.sort_id = sort.sort_id
where sort_name = '纸张';

UPDATE product JOIN sort ON product.sort_id = sort.sort_id
SET price = 1.1 * price
WHERE sort_name = '纸张';