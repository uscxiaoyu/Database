# 示例数据库: `purchase`

- 数据库包含`Product`, `Sort`, `SubSort`, `Member`, `Order`等表
- 表之间的参照关系
  - `Product`表包含`Sort`的外键`sort_id`, `SubSort`的外键`SubSort_ID`
  - `Order`表包含`Product`的外键`Product_ID`
  - `Sort`表的`Sort_ID`是`SubSort`表的外键`Sort_ID`

- 表的定义
```sql
CREATE TABLE `Sort` (
    `Sort_ID` char(2) primary key,
    `Sort_name` varchar(50)
);

CREATE TABLE `SubSort` (
    `SubSort_ID` char(5), primary key,
    `SubSort_name` varchar(50),
    `Sort_ID` char(2),
    constraint `SubSort_ibfk_1` foreign key (`Sort_ID`) references `Sort` (`Sort_ID`)
);

CREATE TABLE `Product` (
    `Product_ID` int primary key,
    `Product_Name` varchar(100),
    `Product_Code` varchar(10),
    `Product_Place` varchar(255),
    `Product_Date` date,
    `Price` decimal(10,2),
    `Unit` char(5),
    `Detail` varchar(50),
    `SubSort_ID` char(5),
    `Sort_ID` char(2),
    constraint `Product_ibfk_1` foreign key (`SubSort_ID`) references `SubSort` (`SubSort_ID`),
    constraint `Product_ibfk_2` foreign key (`Sort_ID`) references `Sort` (`Sort_ID`)
);

CREATE TABLE `Orders` (
    `Order_ID` varchar(50) primary key,
    `Product_ID` int,
    `Quantity` int(8),
    `User_name` varchar(50),
    `Order_date` date,
    `Consignee` varchar(50),
    `Delivery_address` varchar(255),
    `Phone` char(8),
    `Mobile` char(11),
    `Email` char(50),
    `Remark` varchar(255),
    constraint `Orders_ibfk_1` foreign key (`Product_ID`) references `Product` (`Product_ID`)
);

CREATE TABLE `Member` (
    `User_name` varchar(50) primary key,
    `User_password` varchar(100),
    `True_name` varchar(50),
    `Sex` enum('男','女'),
    `Phone` char(8),
    `Mobile` char(11),
    `Email` char(50),
    `Address` varchar(255),
    `Attribute` varchar(255)
);
```

### Sort表
| 属性名 | 属性类型 | 约束 | 参照关系 |
|--------|----------|------|-----------|
| Sort_ID | char(2) | primary key | - |
| Sort_name | varchar(50) | - | - |

### SubSort表
| 属性名 | 属性类型 | 约束 | 参照关系 |
|--------|----------|------|-----------|
| SubSort_ID | char(5) | primary key | - |
| SubSort_name | varchar(50) | - | - |
| Sort_ID | char(2) | foreign key | 参照Sort表的Sort_ID |

### Product表
| 属性名 | 属性类型 | 约束 | 参照关系 |
|--------|----------|------|-----------|
| Product_ID | int | primary key | - |
| Product_Name | varchar(100) | - | - |
| Product_Code | varchar(10) | - | - |
| Product_Place | varchar(255) | - | - |
| Product_Date | date | - | - |
| Price | decimal(10,2) | - | - |
| Unit | char(5) | - | - |
| Detail | varchar(50) | - | - |
| SubSort_ID | char(5) | foreign key | 参照SubSort表的SubSort_ID |
| Sort_ID | char(2) | foreign key | 参照Sort表的Sort_ID |

### Orders表
| 属性名 | 属性类型 | 约束 | 参照关系 |
|--------|----------|------|-----------|
| Order_ID | varchar(50) | primary key | - |
| Product_ID | int | foreign key | 参照Product表的Product_ID |
| Quantity | int(8) | - | - |
| User_name | varchar(50) | - | - |
| Order_date | date | - | - |
| Consignee | varchar(50) | - | - |
| Delivery_address | varchar(255) | - | - |
| Phone | char(8) | - | - |
| Mobile | char(11) | - | - |
| Email | char(50) | - | - |
| Remark | varchar(255) | - | - |

### Member表
| 属性名 | 属性类型 | 约束 | 参照关系 |
|--------|----------|------|-----------|
| User_name | varchar(50) | primary key | - |
| User_password | varchar(100) | - | - |
| True_name | varchar(50) | - | - |
| Sex | enum('男','女') | - | - |
| Phone | char(8) | - | - |
| Mobile | char(11) | - | - |
| Email | char(50) | - | - |
| Address | varchar(255) | - | - |
| Attribute | varchar(255) | - | - |
