# 一、变量与数据类型
1. 变量
	+ 定义方法1: ` var age int = 18	// 定义一个int类型的变量age, 并赋值为18`
	+ 定义方法2: ` var age int	// 定义一个int类型的变量age, 不赋值, 默认值为0`
	+ 定义方法3: ` var age = 18	// 定义一个int类型的变量age, 并赋值为18`
	+ 定义方法4: ` age := 18	// 定义一个int类型的变量age, 并赋值为18`
	+ 注意：
		+ 变量的重复定义会报错
		+ 赋值时如果是和定义类型不匹配，会报错：` var num int = 12.56`
		+ 可以同时定义多个变量：` var a, b int = 1, 2`

2. 全局变量
	+ 定义
		```
		var (
			age int = 18
			name string = "张三"
		)
		```

3. 数据类型介绍
	+ 基本数据类型
		+ 数值类型
			+ 整数类型：
				+ 有符号整数：int8(1字节), int16(2字节), int32(4字节), int64(8字节), rune = int32(4字节)
				+ 无符号整数：uint8(1字节), uint16(2字节), uint32(4字节), uint64(8字节), byte = uint8(1字节)
			+ 浮点数类型：float32(4字节), float64(8字节)
				+ 存储空间和操作系统无关
				+ golang中默认的浮点数类型是float64
				+ 浮点数计算是不精确的
		+ 布尔类型：bool
		+ 字符串类型：string
	+ 复合数据类型
		+ array, slice, map, struct
	+ 其他数据类型
		+ interface, channel, pointer
	+ 常量计数器iota
		+ iota默认值为0。在一组const中，每次定义新的常量，那么它会自动+1
		+ 用于定义枚举类型
		```
		const (
			Mon = iota		//0
			Tue = iota		//1
			Wed = iota		//2
			Thu = 0
			Fri = iota		//4
			Sat				//5
			Sun = iota		//6
		)
		```

4. 类型转换
	+ go语言不存在隐式类型转换，不同类型的变量之间赋值时需要显示转换，并且只有显示转换
	```
	var a int = 10
	var b float32 = float32(a)
	```
	+ 其他类型转换成字符串类型：` var b string = fmt.Sprintf("%d", a)`

5. 杂项
	+ 输出变量的类型: `fmt.Printf("%T", age)`
	+ 输出变量的字节数: `fmt.Println(unsafe.Sizeof(age))`

6. 运算符
	+ 加法运算符(+)
		+ 能够将两个字符串拼接：` str1 := "hello" + "world"`
	+ 取模运算符(%)
		+ a%b = a - b*int(a/b)
	+ 自增操作(++)
		+ ++和--只能在变量的后面，不能写在变量的前面
	+ 其他运算符
		+ &：返回变量的内存地址
		+ *：取指针变量对应的数值
	+ 位运算符
		+ 位清空：a &^ b：对于b上的每个数值，如果为0，则取a对应位上的数值；如果为1，则取0


# 二、流程控制
1. if语句
	+ 语法：
		```
		if 条件表达式 {
			// 代码块1
		} else if 条件表达式 {
			// 代码块2
		} else {
			// 代码块3
		}
		```
	+ 注意：
		+ 条件表达式不需要用括号括起来
		+ 代码块1、2、3可以为空













