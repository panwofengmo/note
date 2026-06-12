1. package
	+ 作用：定义该go文件的包名
	+ 用法:`package 包名`

2. 补充fmt包的Println函数

3. 作用域
	+ 当标识符（包括常量、变量、类型、函数名、结构字段等等）以一个大写字母开头，如：Group1，那么使用这种形式的标识符的对象就可以被外部包的代码所使用（客户端程序需要先导入这个包），这被称为导出（像面向对象语言中的 public）；
	+ 标识符如果以小写字母开头，则对包外是不可见的，但是他们在整个包的内部是可见并且可用的（像面向对象语言中的 protected ）。

4. 字符串连接
	```
		fmt.Println("Google" + "Runoob")
	```

5. 格式化字符串
	+ Sprintf函数
		+ 根据格式化参数生成格式化的字符串并返回该字符串
	+ Printf函数
		+ 根据格式化参数生成格式化的字符串并写入标准输出
	```
		var target_url=fmt.Sprintf("Code=%d&endDate=%s", 123, "2020-12-31")

		fmt.Printf("Code=%d&endDate=%s", 123, "2020-12-31")
	```

6. 变量声明和定义
	+ 格式：
		```
			//var identifier type	(指定变量类型)
			var b int
			
			// var v_name = value	(根据值自行判定变量类型)
			var a = "RUNOOB"

			// v_name := value		(:=符号)
			// 如果已经声明过的变量使用:=符号会报错
			intVal := 1
		```
	+ 全局变量是允许声明但不使用的

7. 常量
	+ 定义：
		```
		//const identifier [type] = value
		const b string = "abc"
		```
	+ 枚举
		+ Go 语言没有枚举（enum）关键字，通常使用常量组来实现枚举效果
		```
		const (
			Unknown = 0
			Female = 1
			Male = 2
		)
		```
	+ iota 常量计数器
		+ iota 在 const 关键字出现时将被重置为 0
		```
		const (
			a = iota   // 0
			b          // 1（省略值，默认使用上一行的 iota）
			c          // 2
		)
		const (
			a = iota   // 0
			b          // 1
			c          // 2
			d = "ha"   // 独立值，iota += 1
			e          // "ha"，iota += 1
			f = 100    // 独立值，iota += 1
			g          // 100，iota += 1
			h = iota   // 7，恢复使用 iota 值
			i          // 8
		)
		```

8. 条件语句
	+ if语句和if else语句
	```
	if a < 20 {
		...
	}

	if a < 20 {
		...
	}else if a < 10{
		...
	}else{

	}
	```
	+ switch语句
	```
	var marks int = 90
	switch marks {
		case 90: grade = "A"
		case 80: grade = "B"
		case 50,60,70 : grade = "C"
		default: grade = "D"  
	}
	```
	+ select语句
		+ 每个 case 都必须是一个通道
	```
	select {
		case <- channel1:
			// 执行的代码
		case value := <- channel2:
			// 执行的代码
		case channel3 <- value:
			// 执行的代码
			// 你可以定义任意数量的 case
		default:
			// 所有通道都没有准备好，执行的代码
	}
	```

9. 函数
	+ 格式: ` func function_name( [parameter list] ) [return_types] {...}`
	```
	func swap(x, y string) (string, string) {
		return y, x
	}
	func swap(x *int, y *int){
		...
	}
	```
	+ 引用传递：*int
	+ 函数变量
	```
	getSquareRoot := func(x float64) float64 {
		return math.Sqrt(x)
	}
	fmt.Println(getSquareRoot(9))   // 输出：3
	```
	+ 函数作为实参传递
	```
	func apply(op func(float64, float64) float64, a, b float64) float64 {
		return op(a, b)
	}
	```

10. 作用域
	+ 函数内定义的变量称为局部变量
	+ 函数外定义的变量称为全局变量
	+ 函数定义中的变量称为形式参数

11. 数组
	+ 声明
	```
	var arr [3]int

	var numbers = [5]int{1, 2, 3, 4, 5}

	numbers := [5]int{1, 2, 3, 4, 5}

	var balance = [...]float32{1000.0, 2.0, 3.4, 7.0, 50.0}
	```
	+ 向函数传递数组
	```
	// 形参设定数组大小
	func myFunction(param [10]int) {
    	....
	}

	// 形参未设定数组大小
	func myFunction(param []int) {
		....
	}
	```


















