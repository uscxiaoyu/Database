## MySQL编程基础


### 1. 常量
#### 1.1 字符串常量
```sql
use progrm;
-- MySQL推荐使用单引号表示字符串
select 'I\'m a \teacher' as coll, "you're a stude\nt" as col2;
```

#### 1.2 数值常量
```sql
select 123 as number;
```
#### 1.3 日期时间常量
```sql
select now() as now;
```
#### 1.4 布尔值
```sql
select true, false;
```
#### 1.5 二进制
```sql
select 0b111001;
select b'11001';
```
#### 1.6 十六进制
```sql
select x'41', x'4D7953514C';
```
#### 1.7 null
```sql
select null, null > 1;
```
### 2. 用户自定义变量

#### 2.1 用户会话变量
- 方法1：set
```sql
set @user_name = '张三'; -- 变量数据类型由等号右边表达式的计算结果决定
select @user_name;

set @user_name = b'11', @age = 18;
select @user_name, @age;

set @age = @age + 1;
```
- 方法2：select

有两种语法格式：
第一种：select @user_variable1 := expression1 [, @user_variable2 := expression2, ...];
第二种：select experession1 into @user_variable1, experession2 into @user_variable2, ...;

- := 和 = 的区别
```sql
select @a = 'a';
select @a;

select @a := 'a';
select @a;

select @user_name := '张三';
select 19 into @age;
select @user_name, @age;
```
#### 2.2 用户回话变量和sql语句

- 方法1
```sql
set @instru_count = (select count(*) from instructor);
select @instru_count;
```
- 方法2
```sql
select @instru_count := (select count(*) from instructor);
```
- 方法3
```sql
select @instru_count := count(*) from instructor;
```
- 方法4
```sql
select count(*) into @instru_count from instructor;
```
- 方法5
```sql
select count(*) from instructor into @instru_count;
```
- 通过定义变量查询特定行
```sql
set @instru_no = '10101';
select * from instructor where id=@instru_no;
```
### 3. 运算符

- 算术
```sql
set @num=15;
select @num + 2, @num - 2;
select @num + null;
select '2012-12-21' + interval '50' day;
```
- 比较
```sql
select 'ab '='ab', ' ab'='ab', 'b'>'a', null=null, null < null, null is null;
```
- 逻辑
```sql
select 1 and 2, 2 and 0, 2 and true, 0 or true, not 2, not false;
select null and 2, 2 and 0.0, 2 and 'true', 1 xor 2, 1 xor false;
select 1 in (1, 2, 3), 2 between 3 and 4;
```
- 重新定义命令结束符
```sql
delimiter $$
select 1$$
```
