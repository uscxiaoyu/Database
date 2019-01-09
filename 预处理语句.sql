use university;


-- 预处理SQL语句
prepare select_instructor_pre
	from "select * from instructor where dept_name=?";
    
SELECT *
FROM instructor;

-- 利用预处理SQL语句进行查询
SET @dept = 'Comp. Sci.';
EXECUTE select_instructor_pre USING @dept;

-- 释放预处理SQL语句
DROP PREPARE select_instructor_pre;