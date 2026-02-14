# 零、 导论
+ 章节:1. SQL; 2. 函数; 3. 约束; 4. 多表查询; 5. 事务
+ DDL(数据定义语言, 用于定义数据库的对象)
+ DML(数据操作语言, 用来对数据库中的数据进行增删改)
+ DQL(数据查询语言, 用于查询数据库中表的数据)

# 一、查询
1. 数据库查询
	+ 查询所有数据库
		+ `SHOW DATABASES;`
	+ 查询当前正在使用的数据库
		+ `SELECT DATABASE();`

2. 表查询
	+ 查询当前数据库中的所有表
		+ `SHOW TABLES;`
	+ 查询表结构
		+ `DESC table_name;`	// 查询表结构
	+ 查询表的详细信息
		+ `SHOW CREATE TABLE table_name;`

# 二、创建
1. 创建数据库
	+ 语法：
		```
		CREATE DATABASE [IF NOT EXISTS] database_name
		[CHARACTER SET charset_name]
		[COLLATE collation_name];
		```
2. 创建表
	+ 语法：
		```
		CREATE TABLE [IF NOT EXISTS] table_name (
			字段1 字段1类型[COMMENT '字段1的注释'],
			字段2 字段2类型[COMMENT '字段2的注释'],
			...
		)[COMMENT '表的注释'];
		```
	+ 示例：
		```
		CREATE TABLE `ab_test` (
			`uid` bigint(20) NOT NULL COMMENT '玩家ID',
			`test_group_name` varchar(10240) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '测试组名字',			`test_id` bigint(20) NOT NULL COMMENT '测试ID',
			`test_group_id` bigint(20) NOT NULL COMMENT '测试组ID',
			`create_time` datetime NOT NULL COMMENT '玩家加入本测试组时间',
			PRIMARY KEY (`uid`) USING BTREE,
			KEY `index_test` (`uid`,`test_group_id`) USING BTREE
		) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
		```

# 三、删除
1. 删除和使用数据库
	+ 删除数据库语法：`DROP DATABASE [IF EXISTS] database_name;`
	+ 使用数据库语法：`USE database_name;`

# 四、数据类型
1. 主要分为三类：数值类型、字符串类型、日期时间类型

2. 数值类型
	1. 整数类型
		+ TINYINT(1 byte), 
		+ SMALLINT(2 bytes)
		+ MEDIUMINT(3 bytes)
		+ INT(4 bytes)
		+ BIGINT(8 bytes)
	2. 浮点数类型
		+ FLOAT(4), DOUBLE(8)
	3. 定点数类型
		+ DECIMAL, NUMERIC

3. 字符串类型
	+ CHAR(定长字符串)
		+ CHAR(10): 占用10个字节, 不足部分用空格填充
	+ VARCHAR(变长字符串)
		+ VARCHAR(10): 最多占用10个字节, 根据存储内容动态调整大小
	+ TEXT(文本字符串)
	+ BLOB(二进制字符串)

4. 日期时间类型
	+ DATE(3): 日期类型, 占用3个字节, 格式为'YYYY-MM-DD'
	+ TIME(4): 时间类型, 占用4个字节, 格式为'HH:MM:SS'
	+ YEAR(1): 年份类型, 占用1个字节, 格式为'YYYY'
	+ DATETIME(8): 日期时间类型, 占用8个字节, 格式为'YYYY-MM-DD HH:MM:SS'
	+ TIMESTAMP(4): 时间戳类型, 占用4个字节, 格式为'YYYY-MM-DD HH:MM:SS'



b站视频：第09