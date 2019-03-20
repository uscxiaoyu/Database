# 课后作业1参考答案
### 1. 建表members
USE purchase2;
CREATE TABLE members (
    user_name varchar(50),
    user_password varchar(100),
    true_name varchar(50),
    gender int(2),
    phone char(8),
    mobile char(11),
    email char(50),
    address varchar(255),
    attribute varchar(255)
);

### 2. 修改表

ALTER TABLE members RENAME member;
ALTER TABLE member DROP COLUMN phone;
ALTER TABLE member CHANGE mobile mobile_phone char(11);
ALTER TABLE member MODIFY attribute varchar(125);


# 课后作业2

### 1. 在member表上添加约束
ALTER TABLE member
MODIFY user_name varchar(50) PRIMARY KEY,
MODIFY user_password varchar(100) NOT NULL,
MODIFY email char(50) NOT NULL,
MODIFY gender int DEFAULT 0 COMMENT '0-女, 1-男';

DESC member;

### 2. 在member表上添加索引
ALTER TABLE member
ADD FULLTEXT INDEX addr_idx(address),
ADD INDEX mp_idx(mobile_phone);
-- 或者

CREATE FULLTEXT INDEX addr_dix ON member(address);
CREATE INDEX mp_idx ON member(mobile_phone);


# 课后作业3

### 1. 往member表中插入以下数据
/*
| User_name  | User_password | True_name | Sex  | Phone    | Mobile      | Email               | Address                          | Attribute |
|----------:|--------------:|----------:|-----:|---------:|------------:|--------------------:|---------------------------------:|----------:|
| 16号       | admin123      | 周步新    | 0   | 69342295 | 13311777768 | sffice@gmechina.com | 新疆乌鲁木齐市团结路78号         | NULL      |
| Aya心冷    | Cnhuker-Ker   | 张文倩    | 0   | 63127310 | 13061780039 | xuyn@21stc.com.cn   | 湖北省咸宁市永安大道71号         | NULL      |
| BABY衣     | Q23E1X        | 袁佳丽    | 0   | 88797580 | 13898281589 | weilili@163.com     | 山东潍坊市奎文区胜利东街288号    | NULL      |
| Casper心冷 | *123789       | 陈雯琼    | 0   | 69342295 | 13510643330 | office@bypc.com.cn  | 青海省共和县恰卜恰镇绿洲北路33号 | NULL      |
| 爱飞       | hack521       | 郑珮琪    | 0   | 62014051 | 18146681065 | zpq2001@outlook.com                | 湖北省武汉民院路5号              | NULL      |
*/
### 2. 更新数据
/*
- 将`true_name`为周步新的`sex`字段值更改为'1'
- 将`user_name`为爱飞的`email`更新为'zpq2001@suibe.edu.cn'
*/

### 3. 删除数据
/*
- 删除`user_name`为16号的数据行
*/