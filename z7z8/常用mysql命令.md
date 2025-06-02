1. 创建数据库
	+ 语法：` CREATE DATABASE 数据库名;`

2. 创建数据表
	+ 语法:
		```
		CREATE TABLE table_name (
			column1 datatype,
			column2 datatype,
			...
		);
		```
	+ 例子：
		```
		CREATE TABLE msgs(
			id INT AUTO_INCREMENT PRIMARY KEY,
			text TEXT NOT NULL,
		);
		```