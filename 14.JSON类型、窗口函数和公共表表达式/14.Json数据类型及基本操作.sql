use purchase;
CREATE TABLE emp_details (emp_no int primary key,
                         detail json);
                         
insert into emp_details (emp_no, detail)
values (1, '{"location": "IN", "phone": "+15612344321", "email": "abc@example.com", "address": {"line1": "abc", "line2": "xyz street", "city":"Bangalore", "pin": "560103"}}');

-- 注意 -> 和 ->> 的区别
select emp_no, detail->'$.address.pin' pin
from emp_details;

select emp_no, detail->>'$.address.pin' pin
from emp_details;

-- json_pretty()
select emp_no, JSON_PRETTY(detail) 
from emp_details;

select emp_no, detail
from emp_details;

-- 2.1 JSON ARRAY
SELECT JSON_ARRAY("abc", 10, null, true, false);
SELECT CAST('["abc", 10, null, true, false]' as JSON);
SELECT convert('["abc", 10, null, true, false]', JSON);

-- 插入json array值
CREATE TABLE t(id int, c JSON);

-- 插入
INSERT INTO t(c) VALUES('[1, 2, [0, 1]]');  -- 插入数组[1, 2, [0, 1]]
INSERT INTO t SET c = '[1, "2", ["0", 1]]'; -- 插入数组[1, "2", ["0", 1]]

SELECT * FROM t;

-- 查询json属性
SELECT c
FROM t;
SELECT c->'$[0]'
FROM t;
SELECT c->'$[2][0]' 
FROM t;

-- 判断json列中是否包含某个值JSON_CONTAINS
-- 返回c中第二个元素是否为"2"的判断（0或1）
SELECT JSON_CONTAINS(c, '"2"', '$[1]') 
FROM t;

-- 搜索某个子元素的位置
SELECT JSON_SEARCH(c, 'all', '2')
FROM t;

-- 在`json array`中添加元素: `JSON_ARRAY_APPEND,JSON_ARRAY_INSERT `
-- 末尾添加元素JSON_ARRAY_APPEND
SET @j = '["a", ["b", "c"], "d"]';
SELECT JSON_ARRAY_APPEND(@j, '$[2]', 1), JSON_ARRAY_APPEND(@j, '$', 1); 
SELECT C FROM t;

SET @k = '{"a": 1}';
SELECT JSON_ARRAY_APPEND(@k, '$.a', 'z'), JSON_ARRAY_APPEND(@k, '$', 'z');

-- 数组插入元素JSON_ARRAY_INSERT
SET @j = '["a", ["b", "c"], "d"]';
SELECT JSON_ARRAY_INSERT(@j, '$[1][1]', 1), JSON_ARRAY_INSERT(@j, '$[2]', 1);

-- 删除`json array`元素: `JSON_REMOVE`
SELECT JSON_REMOVE(@j, '$[1]'); -- ["a", "d"]
SELECT @j; -- ["a", ["b", "c"], "d"]

-- 2.2 JSON OBJECT
SELECT JSON_OBJECT(1, 'A', 2, 'B');
SELECT JSON_TYPE('{"a":1, "b":2}');

-- NULL
SELECT CAST('null' AS JSON);

-- 查看是否包含某个键，有特殊字符的键必须用双引号，不能用单引号括起来。
CREATE TABLE dynamicDoc (
	docid varchar(25),
    exattrs json
);

SET @col1='$."FAQ.IVR"';
SET @col2='$."FAQ.在线"';
SET @col3='$."FAQ.坐席"';

-- ->
SELECT DOCID, EXATTRS->'$."FAQ.IVR"' AS IVR, 
	EXATTRS->'$."FAQ.在线"' AS 在线 , 
	EXATTRS->'$."FAQ.坐席"' AS 坐席
FROM dynamicDoc 
WHERE JSON_CONTAINS_PATH(EXATTRS, 'ONE', '$."FAQ.IVR"') LIMIT 10;
-- 等价于
SELECT DOCID, JSON_EXTRACT(EXATTRS, '$."FAQ.IVR"') AS IVR, 
	JSON_EXTRACT(EXATTRS, '$."FAQ.在线"') AS 在线 , 
	JSON_EXTRACT(EXATTRS, '$."FAQ.坐席"') AS 坐席
FROM dynamicDoc 
WHERE JSON_CONTAINS_PATH(EXATTRS, 'ONE', '$."FAQ.IVR"') LIMIT 10;

-- 去掉字符串引号
SELECT DOCID, EXATTRS->>'$."FAQ.IVR"' AS IVR, EXATTRS->>'$."FAQ.在线"' AS 在线 , EXATTRS->>'$."FAQ.坐席"' AS 坐席
FROM dynamicDoc 
WHERE JSON_CONTAINS_PATH(EXATTRS, 'ONE', '$."FAQ.IVR"') 
LIMIT 10;

SELECT DOCID, EXATTRS->>'$."FAQ.IVR"' AS IVR, EXATTRS->>'$."FAQ.在线"' AS 在线 , EXATTRS->>'$."FAQ.坐席"' AS 坐席
FROM dynamicDoc
WHERE EXATTRS->>'$."FAQ.IVR"' is not null
LIMIT 10;

SELECT docid, JSON_STORAGE_SIZE(EXATTRS)
FROM dynamicDoc
WHERE EXATTRS->>'$."FAQ.IVR"' is not null
LIMIT 10;

-- 二、json常用函数和方法
-- JSON_KEYS()查看OBJECT中的键
SELECT DOCID, JSON_KEYS(EXATTRS)
FROM dynamicDoc
WHERE EXATTRS->>'$."FAQ.IVR"' is not null
LIMIT 10;

-- JSON_DEPTH()查看JSON文档的最大深度
SELECT DOCID, JSON_DEPTH(EXATTRS)
FROM dynamicDoc
WHERE EXATTRS->>'$."FAQ.IVR"' is not null
LIMIT 10;

-- 插入元素
SET @l = '{ "a": 1, "b": [2, 3]}';
SELECT JSON_INSERT(@l, '$.a', 10, '$.c', '[true, false]'); -- 已有的不替代，注意c列插入的是字符串
SELECT JSON_INSERT(@l, '$.a', 10, '$.c', CAST('[true, false]' AS JSON));  -- 转换JSON类型

-- 查找JSON对象中元素的个数
SELECT DOCID, JSON_LENGTH(EXATTRS) FROM dynamicDoc LIMIT 20; 

-- JSON转换为MYSQL其它类型
set @v1 = JSON_EXTRACT('{"id": 14, "name": "Aztalan"}', '$.id');
SELECT CAST(@v1 AS UNSIGNED);

-- 更新值 JSON_SET, JSON_INSERT, JSON_REPLACE
SET @j = '{ "a": 1, "b": [2, 3]}';
SELECT JSON_INSERT(@l, '$.a', 10, '$.c', JSON_ARRAY(true, false));  -- a子列保持不变
SELECT JSON_SET(@j, '$.a', 10, '$.c', JSON_ARRAY(true, false)); -- 插入c子列和替换a子列
SELECT JSON_REPLACE(@j, '$.a', 10, '$.c', JSON_ARRAY(true, false)); -- 不插入c子列

-- 三、案例
-- 创建person表
DROP TABLE IF EXISTS person;

CREATE TABLE person(id int PRIMARY key, 
	`name` JSON,
	phones JSON,
	address JSON);

-- 插入2行记录
INSERT INTO person
SET id = 10000, 
	`NAME`='{"last_name": "玲", "middle_name": "", "last_name": "王"}',
	phones = '[13567542345, 159762831000]',
	address = '{"country": "中国", "province": "上海", "city": "松江区", "street": {"street_number": 1900, "street_name": "文翔路", "building":"乐群楼"}}';

INSERT INTO person
SET id = 10001, 
	`NAME`='{"last_name": "小明", "middle_name": "", "last_name": "李"}',
	phones = '[18767542135, 189762831010]',
	address = '{"country": "中国", "province": "上海", "city": "虹口区", "street": {"street_number": 5400, "street_name": "高远路", "building":"之行楼"}}';
	
-- 查询
SELECT id, phones->'$[0]', `name`->'$.last_name', address->'$.street.street_name'
FROM person;

-- 更改王玲
UPDATE person
SET `NAME` = JSON_REPLACE(`NAME`, '$.last_name', '王', '$.first_name', '玲')
WHERE id = 10000;

-- 插入：给id为1000的人添加一个新号码18800001111
UPDATE person
SET `phones` = JSON_ARRAY_APPEND(`phones`, '$', 18800001111)
WHERE id = 10000;

SELECT *
FROM person;

-- 插入array元素：给id为1001的人添加一个新号码18800001112，置于最前位置
UPDATE person
SET `phones` = JSON_ARRAY_INSERT(`phones`, '$[0]', 18800001112)
WHERE id = 10001;

-- 深层更新：更新id为1001的人的地址：building为"行知楼"
SELECT id, address
FROM person;

UPDATE person
SET address = JSON_REPLACE(address, '$.street.building', '行知楼')
WHERE id = 10001;
