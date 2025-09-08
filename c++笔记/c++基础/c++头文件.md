# 一、iostream
1. cin 和 cout 都属于 iostream库
2. 该库是标准输入/输出流（standard input / output streams）的简称

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
	+ ` append()`：将一个字符串（或字符串的一部分）追加到另一个字符串的末尾
	+ ` substr()`：截取指定位置开始、指定长度的子字符串
	+ ` find()`：查找子字符串或字符首次出现的位置（返回索引值）
	+ ` rfind()`：查找子字符串或字符最后一次出现的位置
	+ ` replace()`：替换字符串中指定范围的字符内容
	+ ` insert()`：在指定位置插入字符串内容
	+ ` erase()`：删除字符串中指定范围的字符
	+ ` compare()`：比较两个字符串

# 三、cmath
1. `<cmath>` 库提供了许多函数，允许你对数字执行数学运算
2. 使用
	+ ` #inlcude <cmath>`