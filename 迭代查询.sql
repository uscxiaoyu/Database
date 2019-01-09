USE progrm;

CREATE TABLE prereq2 (course_id VARCHAR(7), prereq_id VARCHAR(7));
INSERT INTO prereq2 SELECT * FROM prereq;

SELECT * FROM prereq2;
INSERT INTO prereq2 
VALUES ('BIO-101', 'BIO-011'), ('BIO-011', 'BIO-001');

delimiter $$
CREATE PROCEDURE FindAllPreq (IN cid VARCHAR(7))
	MODIFIES SQL DATA
    BEGIN
		IF NOT EXISTS (SELECT table_name FROM information_schema.TABLES WHERE table_name ='c_prereq') THEN
			CREATE TABLE c_prereq (course_id VARCHAR(7)); -- 如果不存在这张表，创建之
		ELSE DELETE FROM c_prereq; -- 如果存在，则清空上一次查询的内容
        END IF;
        
		CREATE TEMPORARY TABLE temp_0 (course_id VARCHAR(7)); -- 存储要继续查询的课程
        CREATE TEMPORARY TABLE temp_1 (course_id VARCHAR(7)); -- 存储先修课程
        INSERT INTO temp_0 SELECT prereq_id FROM prereq2 WHERE course_id = cid;
        REPEAT
			INSERT INTO c_prereq SELECT * FROM temp_0;
            INSERT INTO temp_1 SELECT prereq2.prereq_id 
								FROM temp_0, prereq2
								WHERE temp_0.course_id = prereq2.course_id
									AND prereq2.prereq_id NOT IN (SELECT * FROM c_prereq); -- 排除已经存储的course_id
			DELETE FROM temp_0;
            INSERT INTO temp_0 SELECT * FROM temp_1;
            DELETE FROM temp_1;
		UNTIL NOT EXISTS (SELECT * FROM temp_0) END REPEAT;
        DROP TABLE temp_0; -- 删除临时表
        DROP TABLE temp_1; -- 删除临时表
	END;
$$
delimiter ;

SELECT * FROM prereq2;
DROP PROCEDURE FindAllPreq;
CALL FindAllPreq('BIO-301');
SELECT * FROM c_prereq;