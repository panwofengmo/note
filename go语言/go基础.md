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
	+ 函数外部定义的变量
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
	+ 实例
		```
		var a int = 10
		var b int = 20
		if a > b {
			fmt.Println("a大于b")
		} else {
			fmt.Println("a小于等于b")
		}

		if a := 1; a > 0 {		//a是定义在if的临时变量
			fmt.Println("a是正数")
		}
		```

2. switch语句
	+ 语法：
		```
		switch 变量 {
		case 值1:
			// 代码块1
		case 值2:
			// 代码块2
		default:
			// 代码块3
		}
		```
	+ 注意：
		+ 变量可以是任何类型
		+ 值1、2可以是多个值，用逗号隔开
		+ default可以省略
		+ 每个case后面的代码块执行完毕后，会自动跳出switch语句。不需要break语句
		+ 如果要贯通多个case，需要使用fallthrough语句。fallthrough会强行执行下一个case，不进行case条件的判断
	+ 实例：
		```
		var day int = 3
		switch day {
		case 1, 5:
			fmt.Println("星期一")
		case 2:
			fmt.Println("星期二")
		case 3:
			fmt.Println("星期三")
			fallthrough
		case 4:
			fmt.Println("星期四")
		default:
			fmt.Println("其他天")
		}

		switch {	//switch可以省略条件，默认是Switch true
		case a > b:
			fmt.Println("星期一")
		case a == b:
			fmt.Println("星期二")
		default:
			fmt.Println("其他天")
		}
		```

3. for循环
	+ 语法：
		```
		for 初始化语句; 条件表达式; 迭代语句 {
			// 代码块
		}
		```
	+ 注意：
		+ 初始化语句可以省略
		+ 条件表达式可以省略
		+ 迭代语句可以省略
	+ break: 结束整个循环
	+ continue: 结束本次循环，继续下一次循环
	+ 实例：
		```
		for i := 0; i < 10; i++ {
			fmt.Println(i)
		}

		i := 0
		for i < 10 {
			i++
			fmt.Println(i)
		}
		```


# 三、函数
1. 定义
	+ 语法：
		```
		func 函数名(参数列表) (返回值列表) {
			// 代码块
		}
		```
	+ 注意：
		+ 函数名首字母大写表示公共函数，小写表示私有函数
		+ 参数列表可以为空
		+ 返回值列表可以为空
		+ 函数可以有多个返回值
		+ 直接调用return不带结果，那么则返回函数返回值定义的顺序进行结果返回
	+ 实例：
		```
		func add(a int, b int) int {
			return a + b
		}

		func swap(x, y string) (param2 string, param1 string) {
			return y, x
		}
		a, _ = swap("a", "b")	//只要第一个返回值
		```

2. 可变参数
	+ 语法：`func 函数名(参数列表 ...类型) (返回值列表) {`
	+ 注意：
		+ 可变参数必须是最后一个参数
		+ 调用函数时，可变参数可以传入多个值，也可以传入一个slice
	+ 实例：
		```
		func add(a ...int) int {
			sum := 0
			for i, v := range a {	//i表示索引，是从0开始的；v表示值
				sum += v
			}
			for i := 0; i < len(a); i++ {	//i表示索引，是从0开始的；v表示值
				sum += a[i]
			}
			return sum
		}

		func add(a ...any) int {		//any表示任意类型
		}
		```

3. defer--延迟函数
	+ 语法：`defer 语句`
	+ 功能：等其他语句执行完之后，再来执行defer语句
	+ 作用：处理一些善后的问题，比如错误，文件流关闭等操作
	+ 注意：
		+ defer语句会将语句延迟到函数返回之前执行
		+ defer语句可以有多个，按照先进后出的顺序执行
	+ 实例：
		```
		func main() {
			defer fmt.Println("defer1")
			defer fmt.Println("defer2")
			fmt.Println("main")
		}

		func main() {
			n := 10
			fmt.Println("main, n = ", n)
			defer fmt.Println("n = ", n)	//在defer的时候，函数其实已经被调用了，但是没有执行
			n++
			fmt.Println("main end, n = ", n)
		}
		```

4. 函数的数据类型
	+ 函数在go语言中本身也是一个数据类型
	+ 函数的类型就等于该函数创建的类型，他也可以赋值给其他类型的函数
	+ 函数在go中是一个符合类型，可以看做是一个特殊的变量(指针变量)。var定义、赋值。类型相同即可
	+ 函数类型的样子：`func(参数列表) (返回值列表)`
	+ 变量名：指向一段内存(num ->0x11111aaaa)
	函数名：指向一段函数体的内存地址，是一种特殊类型的变量(num ->0x11111aaaa)
	+ 实例：
		```
		var f func(int, int) int	//定义一个函数类型的变量f
		f = add	//将add函数赋值给f
		fmt.Println(f(1, 2))	//调用f函数
		fmt.Printf("%T\n", add)	//打印add的类型: func(int, int) int
		```

5. 匿名函数
	+ 匿名变量：没有名字的变量
	+ 匿名函数：没有名字的函数
	+ 将匿名函数作为另外一个函数的参数，回调函数
	+ 将匿名函数作为另外一个函数的返回值，可以形成闭包结构
	+ 实例：
		```
		var f func(int, int) int	//定义一个函数类型的变量f
		f = func(a int, b int) int {	//将匿名函数赋值给f
			return a + b
		}
		fmt.Println(f(1, 2))	//调用f函数
		fmt.Printf("%T\n", f)	//打印f的类型: func(int, int) int
		```

6. 回调函数
	+ 回调函数：将一个函数作为参数传递给另外一个函数，在另外一个函数中调用该函数
	+ 实例：
		```
		func add(a int, b int, callback func(int)) {
			callback(a + b)
		}
		add(1, 2, func(res int) {
			fmt.Println(res)
		})
		```

7. 闭包
	+ 闭包：函数嵌套函数，内部函数可以使用外部函数的变量
	+ 局部变量的生命周期会发生变化：正常的局部变量会随着函数的调用而创建，随着函数的结束而销毁。但是闭包结构中的外层函数的局部变量并不会随着外层函数的结束而销毁，因为内层函数还在使用
	+ 闭包结果的返回值是一个函数。这个函数可以调用闭包结构中的变量
	+ 作用：防止变量冲突，全局变量污染
	+ 实例：
		```
		func add(a int) func(int) int {
			return func(b int) int {
				return a + b
			}
		}
		f := add(10)
		fmt.Println(f(20))	//30

		func inc() func() int {
			n := 0
			return func() int {
				n++
				return n
			}
		}
		f1 := inc()
		fmt.Println(f1())	//1
		fmt.Println(f1())	//2
		fmt.Println(f1())	//3		//f1是inc的内层函数，没有被销毁，变量n也没有被销毁

		f2 := inc()
		fmt.Println(f2())	//1
		fmt.Println(f1())	//4
		fmt.Println(f2())	//2
		```

8. 函数中的参数传递
	+ 根据数据类型存储特点
		+ 值类型(拷贝)： int, float, bool, string, array, struct
		+ 引用类型(数据的地址)： slice, map, channel, interface


# 四、数组
1. 数组定义
	+ 定义：数组是一个相同类型数据的有序集合，通过下标取出对应的数据
	+ 语法：`var 数组名 [数组长度] 数组元素类型`
	+ 元素必须是相同类型，不能多个类型混合；any也是类型，可以存放任意类型的数据
	+ 实例：
		```
		var arr [3]int	//定义一个长度为3的int数组

		//赋值
		var arr1 = [3]int{1, 2, 3}
		arr1 := [3]int{1, 2, 3}
		//自动根据数组的长度来确定数组的长度
		arr2 := [...]int{1, 2, 3}
		//只给部分元素赋值，其他元素默认值为0
		arr3 := [3]int{1: 100, 5:500}	//只给下标1和下标5赋值，其他元素默认值为0
		```

2. 相关函数
	+ len()：返回数组的长度
	+ cap()：返回数组的容量

3. 遍历数组元素
	+ 使用for + len循环和 for + range循环
	```
	for i := 0; i < len(arr); i++ {
		fmt.Println(arr[i])
	}
	for i, v := range arr {
		fmt.Println("idx = ", i, ", value = ", v)
	}
	```

4. 多维数组
	+ 定义：数组的元素也是数组，就叫做多维数组
	+ 语法：`var 数组名 [数组长度][数组长度] 数组元素类型`
	+ 实例：
		```
		var arr [3][3]int	//定义一个3*3的int数组

		arr1 := [3][4]int{
			{1, 2, 3, 4},
			{5, 6, 7, 8},
			{9, 10, 11, 12},
		}
		```

# 五、切片slice
1. 切片定义
	+ 定义：切片是一个引用类型，它的底层是一个数组，切片的长度是可以变化的
	+ 语法：`var 切片名 [] 切片元素类型`
	+ 结构：从概念上面来说slice像一个结构体，这个结构体包含了三个元素
		+ 指针：指向数组中slice指定的开始位置
		+ 长度：切片的长度
		+ 容量：切片的容量
	+ 实例：
		```
		var s []int	//定义一个int类型的切片
		```

2. 一些技巧
	+ 判空：` if slice1 == nil{...}`

3. make函数
	+ 定义：make函数是用来创建切片的，它的底层是调用了数组的底层
	+ 语法：`make([]类型, 长度, 容量)`
	+ 实例：
		```
		s1 := make([]int, 3, 5)	//创建一个int类型的切片，长度为3，容量为5
		s1[0] = 1
		s1[5] = 5	//error, 因为这时候底层的数组大小为3
		```

4. 切片扩容
	+ append函数：用来向切片中添加元素
	+ 语法：`append(切片名, 元素1, 元素2, ...)`
	```
		append(切片名, 元素1, 元素2, ...)
		append(切片名, 切片名...)
	```
	+ 实例：
		```
		s1 := make([]int, 3, 5)	//创建一个int类型的切片，长度为3，容量为5
		s1[0] = 1
		s1[5] = 5	//error, 因为这时候底层的数组大小为3
		s1 = append(s1, 6)	//向切片中添加一个元素6
		fmt.Println(s1)	//[1 0 0 6]
		fmt.Println(len(s1))	//4
		fmt.Println(cap(s1))	//5

		s2 := []int{1, 2, 3}
		s1 = append(s1, s2...)	//向切片s1中添加切片s2的元素; slice...解构，可以直接获取slice中的所有元素
		```

5. 切片扩容的内存分析
	+ 每个切片引用了一个底层的数组
	+ 切片本身不存储任何数据，都是底层的数组来存储的，所以修改了切片也就是修改了这个数组中的数据
	+ 向切片中添加数据的时候，如果没有超过容量，直接添加，如果超过了这个容量，就会自动扩容，容量成倍地增加
	+ 切片一旦扩容，就是重新指向一个新的底层数组

6. copy方法
	+ 语法：`copy(目标切片, 源切片)`
	+ 属于深拷贝
	+ 实例：
		```
		s1 := []int{1, 2, 3}
		s2 := make([]int, 3, 5)
		copy(s2, s1)	//将s1中的元素复制到s2中
		fmt.Println(s2)	//[1 2 3]
		```

7. 通过数组创建切片
	+ 如果切片容量内增加元素，会导致原来的数组数据发生修改
	+ 如果切片容量外增加元素，不会导致原来的数组数据发生修改；这时候切片指向新的数组
	```
	arr := [10]int{1, 2, 3, 4, 5, 6, 7, 8, 9, 10}
	//[start, end)
	s1 := arr[1:2]	//创建一个切片，包含数组arr的下标为1的元素到第2个元素（不包含第2个元素）
	s2 := arr[:2]	//创建一个切片，包含数组arr的下标为0的元素到第2个元素（不包含第2个元素）
	s3 := arr[2:]	//创建一个切片，包含数组arr的下标为2的元素到最后一个元素
	s4 := arr[:]		//创建一个切片，包含数组arr的下标为0的元素到最后一个元素

	//s1指向数组的下标为1的元素；s2,s4是指向数组的下标为0的元素；s3指向数组的下标为2的元素；
	//都不是新建数组，而是指向原数组；原数组的元素被改变，切片的元素也会改变
	```

8. 切片：引用类型
	+ 实例
	```
	s1 := []int{1, 2, 3}
	s2 := s1
	fmt.Println(s1)	//[1 2 3]
	fmt.Println(s2)	//[1 2 3]
	s2[0] = 100
	fmt.Println(s1)	//[100 2 3]
	fmt.Println(s2)	//[100 2 3]
	```

9. 深拷贝和浅拷贝
	+ 深拷贝:拷贝的是数据的本身
		+ 值类型的数据，默认都是浅拷贝：array, int, string...
		+ 切片的深拷贝：copy函数
	+ 浅拷贝：拷贝的是数据的地址，会导致多个变量指向同一块内存

10. 查看变量的地址
	```
	//普通变量
	var a int = 10
	fmt.Println(&a)	//变量a的地址
	fmt.Printf("%p\n", &a)	//变量a的地址

	//切片
	a := []int{1, 2, 3}
	fmt.Printf("%p\n", a)		//底层数组首个元素的地址
	fmt.Printf("%p\n", &a[0])	//底层数组首个元素的地址(和上面结果一致)
	fmt.Printf("%p\n", &a)		//切片a的地址

	//指针
	num := 10
	a := &num

	fmt.Printf("a 指向的地址: %p\n", a)		//a 指向的地址（即 num 的地址）
	fmt.Printf("a 自身的地址: %p\n", &a)	//a 自身的地址
	```


# 六、map
1. 定义
	+ 定义：map是一种无序的键值对集合，它的底层是一个哈希表
	+ 类型：` map[键类型]值类型`
	+ 语法：`var 映射名 map[键类型]值类型`
	+ 实例：
		```
		var m map[int]string	//定义一个int类型的键，string类型的值的映射
		```

2. 创建
	```
	//创建map变量
	var m map[int]string	//定义一个int类型的键，string类型的值的映射
	m := make(map[int]string)	//创建一个int类型的键，string类型的值的映射

	//创建并赋值
	m := map[int]string{		//map[int]string{key:value}
		1: "a",
		2: "b",
	}

	//赋值
	var m map[int]string
	m[1] = "a"		//error:因为这个时候m为空，没有初始化，无法直接赋值

	//赋值
	var m map[int]string
	m = make(map[int]string)	//要使用map，必须创建并初始化
	m[1] = "one"
	```
3. 一些小技巧
	+ 判空：` if map1 == nil{...}`
	+ 判断对应的key是否存在值：` value, ok := map1[key]	//如果key存在，ok为true，value为对应的值；如果key不存在，ok为false，value为值类型的默认值`
	+ 删除数据
		+ 结构：` func delete(m map[Type]Type1, key Type)`
		+ 实例：
			```
			delete(m, 1)	//删除m中键为1的键值对
			```
	+ map的大小：` len(map1)`

4. map遍历
	+ 只能通过for range
	+ map是无序的，每次打印出来的map可能都不一样
	```
	for key, value := range m {
		fmt.Printf("key: %v, value: %v\n", key, value)
	}
	```


# 七、指针
1. 定义
	+ 变量是一种占位符，底层指向是一个内存地址
	+ 语法：`var 指针名 *类型`
	+ 实例：
		```
		var a int = 10
		var p *int = &a	//p是一个指针，指向变量a的地址
		```

2. 数组指针
	+ 数组指针：指向一个数组的指针
	+ 指针数组：数组的每个元素都是一个指针
	+ 实例：
		```
		var a [3]int = [3]int{1, 2, 3}
		var p *[3]int = &a	//p是一个数组指针，指向数组a的地址

		(*p)[0] = 100	//通过数组指针修改数组元素
		```

3. 变量销毁
	+ 当没有任何东西再指向它的时候，定义的变量会销毁，垃圾回收(GC)会回收
	+ 当函数返回局部变量的指针，虽然函数已经调用结束，但是还有其他变量指向那块内存，所以不会被销毁

# 八、结构体
1. 定义
	+ 定义：结构体是一种自定义的数据类型，它可以包含多个不同类型的字段
	+ 类型：`type 结构体名 struct{字段1 类型1; 字段2 类型2; ...}`
	+ 语法：`type 结构体名 struct{字段1 类型1; 字段2 类型2; ...}`
	+ 实例：
		```
		type Person struct{
			Name string
			Age int
		}

		p1 := Person{
			Name: "张三",
			Age:  18,
		}
		var p2 Person
		p2.Name = "李四"
		p2.Age = 20

		fmt.Printf("%T\n", p1)	//如果Person结构体实在main包定义的，打印结果为main.Person
		```

2. 结构体指针
	+ 定义：指向结构体的指针
	+ 语法：`var 指针名 *结构体名`
	+ 实例：
		```
		var p *Person = &p1
		(*p).Name = "王五"
		p.Age = 30
		fmt.Println(p)	//&{王五 30 }
		```

3. 匿名结构体
	```
	s := struct{
		Name string
		Age int
	}{
		Name: "张三",
		Age:  18,
	}
	```

4. 匿名字段
	+ 定义：结构体中没有显示的字段名，只有字段的类型
	+ 语法：`type 结构体名 struct{类型1; 类型2; ...}`
	+ 结构体中的匿名字段，没有名字的字段，这个时候属性类型不能重复
	+ 实例：
		```
		type Person struct{
			string
			int
		}

		p1 := Person{
			"张三",
			18,
		}
		fmt.Println(p1)	//{张三 18}
		fmt.Println(p1.string)
		```

5. 结构体嵌套
	+ 定义：结构体中包含另一个结构体
	+ 实例：
		```
		type Address struct{
			City string
			District string
		}

		type Person struct{
			Name string
			Age int
			Address Address
		}

		//赋值1
		p1 := Person{
			Name: "张三",
			Age:  18,
			Address: Address{
				City: "北京",
				District: "东城区",
			},
		}
		fmt.Println(p1)	//{张三 18 {北京 东城区}}

		//赋值2
		var p2 Person
		p2.Name = "李四"
		p2.Age = 20
		p2.Address = Address{
			City: "北京",
			District: "东城区",
		}
		fmt.Println(p2)	//{李四 20 {北京 东城区}}
		```

6. 结构体导出
	+ 定义：如果结构体的字段名首字母是大写的，那么这个字段就可以被导出，其他包可以访问到
	+ 实例：
		```
		type Person struct{	//可以被导出
			Name string		//可以被导出
			Age int			//可以被导出
			money int		//不能被导出
		}
		```