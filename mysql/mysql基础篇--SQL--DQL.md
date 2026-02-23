# 零、 导论
+ 章节:1. SQL; 2. 函数; 3. 约束; 4. 多表查询; 5. 事务
+ DDL(数据定义语言, 用于定义数据库的对象)
+ DML(数据操作语言, 用来对数据库中的数据进行增删改)
+ DQL(数据查询语言, 用于查询数据库中表的数据)
+ DQL执行顺序：FROM -> WHERE -> GROUP BY -> SELECT -> ORDER BY -> LIMIT

# 一、DQL语法
1. select语句
	+ 语法：
	```
	SELECT
		字段列表
	FROM
		表名列表 
	WHERE
		条件列表
	GROUP BY
		分组字段列表
	HAVING
		分组后条件列表
	ORDER BY
		排序字段列表
	LIMIT
		分页参数
	```

# 二、DQL-基本查询
1. 语法
	+ 语法1：`SELECT 字段1, 字段2, ... FROM 表名;`
	+ 语法2：`SELECT * FROM 表名;`

2. 设置别名
	+ 语法：`SELECT 字段1 [AS 别名1], 字段2 [AS 别名2], ... FROM 表名;`

3. 去除重复记录
	+ 语法：`SELECT DISTINCT 字段列表 FROM 表名;`


# 三、DQL-条件查询
1. 语法
	+ 语法：`SELECT 字段列表 FROM 表名 WHERE 条件列表;`
	+ 比较运算符条件
		|比较运算符|功能|
		|--|--|
		|>	|大于|
		|>=	|大于等于|
		|<	|小于|
		|<=	|小于等于|
		|=	|等于|
		|<> 或 !=	|不等于|
		|BETWEEN … AND …	|在某个范围内（含最小、最大值）|
		|IN(…)	|在in之后的列表中的值，多选一|
		|LIKE 占位符	|模糊匹配（_匹配单个字符，%匹配任意个字符）|
		|IS NULL	|是NULL|

		|逻辑运算符	|功能|
		|--|--|
		|AND 或 &&	|并且（多个条件同时成立）|
		|OR 或 \|\|	|或者（多个条件任意一个成立）|
		|NOT 或 !	|非，不是|

2. 实例
	+ 查询没有身份证号的员工信息
		```
		SELECT * FROM emp WHERE id_card IS NULL;
		```
	+ 查询姓名为两个字的员工信息
		```
		SELECT * FROM emp WHERE name LIKE '__';	//'_'代表任意一个字符
		```
	+ 查询身份证号最后一位为x的员工信息
		```
		SELECT * FROM emp WHERE idcard LIKE '%x';	//'%'代表任意个字符
		```


# 四、DQL-聚合函数
1. 介绍
	+ 将一列数据组哟喂一个整体，进行纵向计算

2. 语法和使用
	+ 语法：`SELECT 聚合函数(字段列表) FROM 表名;`
	+ 注意：
		+ 聚合函数会忽略NULL值
	+ 聚合函数分类
		|聚合函数|功能|
		|--|--|
		|count()|统计行数|
		|sum()|求和|
		|avg()|求平均值|
		|max()|求最大值|
		|min()|求最小值|


# 五、DQL-分组查询
1. 语法
	+ `SELECT 字段列表 FROM 表名 [WHERE 条件列表] GROUP BY 分组字段列表 [HAVING 分组后条件列表];`
	+ where和having的区别
		+ 执行时机不同：where是分组之前进行过滤，不满足where条件，不参与分组；而having是分组之后进行过滤
		+ 判断条件不同：where不能对聚合函数进行判断，而having可以
	+ 注意：
		+ 分组后条件必须使用聚合函数进行条件判断
		+ 进行分组查询的时候，SELECT语句中只能查询分组字段和聚合函数

2. 实例
	+ 根据性别分组，统计男性员工和女性员工的数量
		```
		SELECT gender, COUNT(*) FROM emp GROUP BY gender;
		```
	+ 根据性别分组，统计男员工和女员工的平均年龄
		```
		SELECT gender, AVG(age) FROM emp GROUP BY gender;
		```
	+ 查询年龄小于45的员工，并根据工作地址分组，获取员工数量大于等于3的工作地址
		```
		SELECT workaddress, count(*) FROM emp WHERE age < 45 GROUP BY workaddress HAVING COUNT(*) >= 3;
		```


# 六、DQL-排序查询
1. 语法
	+ `SELECT 字段列表 FROM 表名 [WHERE 条件列表] ORDER BY 字段1 [ASC|DESC], 字段2 [ASC|DESC], ...;`
	+ 注意：
		+ ASC：升序排序（默认）
		+ DESC：降序排序
		+ 如果是多字段排序，当第一个字段值相同时，才会根据第二个字段进行排序

# 七、DQL-分页查询
1. 语法
	+ `SELECT 字段列表 FROM 表名 LIMIT 起始索引, 查询记录数;`
	+ 注意：
		+ 起始索引从0开始，起始索引 = (查询页码-1) * 每页显示记录数
		+ 每页记录数可以省略，默认是10条记录
		+ 分页查询是数据库的方言，不同数据库有不同的实现，mysql中是LIMIT
		+ 如果查询的是第一页数据，起始索引可以省略，直接简写为` LIMIT 10`
	+ 实例
		+ 查询第1页，每页显示10条记录
			```
			SELECT * FROM emp LIMIT 0, 10;
			```
		+ 查询第2页，每页显示10条记录
			```
			SELECT * FROM emp LIMIT 10, 10;
			```









