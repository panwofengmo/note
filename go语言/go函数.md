# 一、fmt包
1. fmt.Printf()
	+ 格式化输出
	+ 语法：`fmt.Printf(format string, a ...interface{}) (n int, err error)`
	+ 参数：
		+ format：格式化字符串
		+ a ...interface{}：要格式化的值
	+ 返回值：
		+ n：写入的字符数
		+ err：写入时遇到的错误
	+ 格式化动词：
		+ %v：值的默认格式
		+ %T：值的类型
		+ %d：十进制整数
		+ %f：浮点数，默认保留6位小数，%.2f保留2位小数；如果小于了当前保留的位数，四舍五入
		+ %s：字符串
		+ %q：带引号的字符串
		+ %x：十六进制整数
		+ %p：指针
		+ %t：布尔值
		+ %c：字符
		+ %b：二进制整数
		+ %o：八进制整数

2. fmt.Println()
	+ 能直接输出数组：`fmt.Println(arr)`

3. fmt.Scan
	+ 从标准输入读取数据并将其存储到指定的变量中
	+ 语法：`fmt.Scan(a ...interface{}) (n int, err error)`
	+ 参数：
		+ a ...interface{}：要存储数据的变量
	+ 返回值：
		+ n：读取的字符数
		+ err：读取时遇到的错误
	+ 注意：
		+ 读取时会自动忽略空格和换行符
		+ 读取字符串时遇到空格或换行符会停止读取
	+ 示例：
		```
		var a int
		var b float32
		var c string
		fmt.Println("请输入一个整数、一个浮点数和一个字符串：")
		fmt.Scan(&a, &b, &c)
		fmt.Printf("你输入的整数是：%d，浮点数是：%f，字符串是：%s\n", a, b, c)
		```










