# 一、iostream
1. cin 和 cout 都属于 iostream库
2. 该库是标准输入/输出流(standard input / output streams)的简称

# 二、string
1. 使用
	+ ` #inlcude <string>`
2. 只有引入头文件string，才能使用string类型变量
3. ` <string>` 库提供了许多函数，允许您对字符串执行各种操作
4. 常用函数
	+ ` at()`：返回字符串中指定索引位置的字符
	+ ` length()`：返回字符串的长度
	+ ` size()`：length() 的别名，同样返回字符串长度
	+ ` max_size()`：返回字符串的最大长度
	+ ` empty()`：检查字符串是否为空
	+ ` append()`：将一个字符串(或字符串的一部分)追加到另一个字符串的末尾
	+ ` substr()`：截取指定位置开始、指定长度的子字符串
	+ ` find()`：查找子字符串或字符首次出现的位置(返回索引值)
	+ ` rfind()`：查找子字符串或字符最后一次出现的位置
	+ ` replace()`：替换字符串中指定范围的字符内容
	+ ` insert()`：在指定位置插入字符串内容
	+ ` erase()`：删除字符串中指定范围的字符
	+ ` compare()`：比较两个字符串

# 三、cmath
1. `<cmath>` 库提供了许多函数，允许你对数字执行数学运算
2. 使用
	+ ` #inlcude <cmath>`


# 四、ctime
1. `<ctime>` 库允许你处理时间和日期
2. 使用
	+ ` #inlcude <ctime>`
3. 常用函数
	+ ` time()`：返回当前时间的时间戳
		+ 示例：
		```
		time_t now = time(0);		//获取现在的时间戳
		
		time_t timestamp;
		time(&timestamp);		// 获取当前日期和时间的时间戳
		```
	+ ` ctime()`：将时间戳转换为可读的日期和时间字符串
		+ 示例：
		```
		char* date = ctime(&timestamp);		// 将时间戳timestamp转换为日期和时间字符串
		```
	+ ` mktime()`：将日期时间结构转换为时间戳
		+ 示例：
		```
		struct tm timeinfo;
		timeinfo.tm_year = 2023 - 1900;		// 年份减去1900
		timeinfo.tm_mon = 11;		// 月份(0-11)
		timeinfo.tm_mday = 25;		// 日期(1-31)
		timeinfo.tm_hour = 12;		// 小时(0-23)
		timeinfo.tm_min = 30;		// 分钟(0-59)
		timeinfo.tm_sec = 0;		// 秒(0-61)
		timeinfo.tm_isdst = -1;		// 夏令时标识符(-1 表示使用计算机的时区设置)
		time_t timestamp = mktime(&timeinfo);		// 将日期时间结构转换为时间戳
		```
