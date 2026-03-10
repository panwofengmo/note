# 一、面向对象编程
1. OOP思想
	+ go语言不是面向对象的语言，只是让大家理解一些面向对象的思想，通过一些方法来模拟面向对象
	+ 核心：封装、继承、多态

2. 继承
	+ 继承需要符合的关系是：is-a，父类更通用，子类更具体
	+ 继承就是子类继承父类的特征和行为，使得子类具有父类的属性和方法，使得子类具有父类相同的行为。子类会具有父类的一般特性也会具有自身的特性
	+ go语言中结构体嵌套
		1. 模拟继承:is-a
		```
			type A struct{
				int_a int
				...
			}
			type B struct{
				A		//匿名字段 B.A
				...
			}
			// B是可以直接访问A的属性的：
			b := B{}
			b.int_a = 10
			fmt.Println(b.int_a)	//10
		```
		2. 聚合关系:has-a
		```
			type C struct{
				int_c int
				...
			}
			type D struct{
				c C		//聚合
				...
			}
			// D是无法直接访问C中的属性的，必须使用D.c.int_c
		```

3. 方法
	+ 方法不等于函数，方法一定要属于某个结构体(类)
	+ 方法需要指定调用者，而函数不需要指定调用者
	+ 方法是某个类的动作，而函数是一个特殊的类型
	+ 方法的定义：
	```
		func (接收者) 方法名(参数列表) (返回值列表) {
			// 方法体
		}

		type Dog struct{
			Name string
			Age int
		}
		// 定义一个方法，方法的调用者是Dog结构体
		func (d Dog) Say() {
			fmt.Println("我是", d.Name, "我今年", d.Age, "岁")
		}
	```
	+ 方法的调用：
	```
		接收者.方法名(参数列表)
	```

4. 方法的重写
	```
	//已知Cat继承animal，而animal有一个方法eat()
	//子类重写父类的方法，子类的方法名和父类同名，即可重写父类的方法
	func (c Cat) eat() {
		fmt.Println("我是", c.Name, "我今年", c.Age, "岁")
	}
	```

5. 接口
	+ 接口就是把一些共性的方法集合在一起定义
	+ 接口的作用：
		1. 定义了一种规范，所有实现了这个接口的结构体都必须实现这个接口的方法
		2. 可以实现多态，即一个接口可以代表多种类型
	+ 接口的定义：
	```
		type 接口名 interface{
			方法名1(参数列表1) (返回值列表1)
			方法名2(参数列表2) (返回值列表2)
			...
		}

		type USB interface{
			input()
			output()
		}

		//鼠标实现USB接口
		type Mouse struct{
			Name string
			Age int
		}
		//结构体实现了接口的全部方法就代表实现了这个接口
		func (m Mouse) input() {
			fmt.Println("mouse input")
		}
		func (m Mouse) output() {
			fmt.Println("mouse output")
		}

		func test(u USB) {
			u.input()
			u.output()
		}
		func main(){
			//通过传入接口实现类来进行调用
			m := Mouse{
				Name: "m1",
				Age:  1,
			}
			//test参数USB类型，如果一个结构体实现了这个接口所有的方法，那这个结构体就是这个接口类型的
			test(m)

			//定义高级类型
			var usb USB
			usb = m
			usb.input()
			usb.output()
			//接口是无法使用实现类的属性的
			usb.Name = "USB"	//error
		}
	```

6. 空接口
	+ 空接口是指没有定义任何方法的接口，所有的类型都实现了空接口，因此空接口可以存储任意类型
	+ any是go语言中的一个空接口类型，它可以存储任意类型`type any = interface{} `
	+ 空接口的定义：
	```
		type empty interface{}
	```


7. 多态
	+ 多态：一个事务拥有多种形态
	+ 例如：猫和狗是多态的，他们既可以是自己，也可以是动物，这个就是多态，一个事务有多种形态
	+ 定义一个类型可以为接口类型的变量，实际上所有实现类都可以赋值给这个对象
	+ 接口的实现类都拥有多态特性：除了自己本身还是他对应接口的类型

8. 接口嵌套
	+ 接口可以嵌套其他接口，形成一个新的接口
	+ 新的接口包含了所有嵌套接口的方法
	+ 新的接口可以被实现类实现
	```
		type A interface{
			test1()
		}
		type B interface{
			test2()
		}
		//接口嵌套
		//C接口包含了A接口和B接口的方法，同时还包含了自己的方法test2()
		//如果要实现接口C，那么需要实现这三个方法。那么这个对象就有3个接口可以转型
		type C interface{
			A
			B
			test2()
		}
		
	```

# 二、错误与异常
1. 接口的类型断言
	+ 接口断言是：检查一个接口类型的变量是不是符合你的预期值
	+ 被断言的对象必须是接口类型，否则会报错
	+ 如果断言失败，则会抛出panic异常，程序就会停止执行
	+ 类型断言的语法：
	```
		变量.(类型)
		t := i.(T)	//T是类型；i是接口；如果这个接口是类型T，那么就会返回T类型的变量
		//ok是一个bool值，如果断言成功，那么ok为true，否则为false
		//这种情况下，断言失败不会抛出panic异常，而是返回一个零值
		t, ok := i.(T)	//ok是一个bool值，如果断言成功，那么ok为true，否则为false
	```
	+ 类型断言的示例：
	```
		var u USB
		u = m
		//将u转换为Mouse类型
		mouse := u.(Mouse)
		mouse.input()
		mouse.output()
	```

2. type的别名用法
	+ type定义类型
		```
		type User struct		//定义结构体
		type User interface		//定义接口类型
		type Diy (int、string、...)		//定义接口类型

		```
	+ type起别名
		+ 真实在项目的编译过程中，它还是原来的类型
		```
		type xxx = 类型，将某个类型赋值给xxx，相当于这个类型的别名
		type MyInt = int
		```
	+ 类型别名的示例：
	```
		//这是定义了一个新类型MyInt，是int转换过来的，和int一样，但是不能通过int发生操作，类型不同
		//MyInt
		type MyInt int
		var a MyInt
		a = 10
		var b int = 10
		fmt.Println(a + b)		//error，不是同类型相加
		fmt.Println(a + MyInt(b))

		type diyInt = int
		fmt.Println(a + b)		//是同类型相加
	```

3. 错误
	+ 错误：指的是程序中预期会发生的结果，预料之中
	+ 异常：不该出现问题的地方出现了问题，预料之外
	+ 例如：
		+ 打开文件时，文件不存在；这是错误
		+ 打开文件时，文件被其他程序占用；这是错误
	+ 实例
	```
		// 直接返回error类型
		func setAge(age int) error{
			if age < 0 {
				return errors.New("年龄不能小于0")
			}
			...
			return nil
		}

		//使用fmt.Errorf()函数返回错误信息
		error_info1 := fmt.Errorf("错误信息1")
		error_info2 := fmt.Errorf("错误信息2")
		if error_info1 != nil {
			fmt.Println(error_info1)
		}
	```

4. error类型
	+ error是go语言中的一个接口类型，它定义了一个Error()方法，返回一个字符串
	+ 所有实现了Error()方法的类型都可以被转换为error类型
	+ 例如：
	```
		type MyError struct{
			Msg string
		}
		func (e MyError) Error() string{
			return e.Msg
		}

		//自定义一个错误
		func setAge(age int) error{
			if age < 0 {
				return &MyError{"年龄不能小于0"}
			}
			...
			return nil
		}
		err := setAge(-10)
		if err != nil {
			fmt.Println(err)
			ks_err, ok := err.(*MyError)
			if ok {
				fmt.Println(ks_err.Msg)
			}
		}
	```

5. 异常(panic)
	+ 异常：指的是程序中没有预期会发生的结果，预料之外
	+ 程序运行的时候会发生panic
	+ panic函数：用来抛出异常，程序会停止执行
	+ 处理异常：使用panic抛出异常，使用recover接受这个异常来处理
	```
		func panic(v any)
		panic("这是一个异常")	//手动抛出panic，程序终止

		func recover() any		//返回panic传递的值

	```
	+ 例如：
		+ 数组越界
		+ 空指针引用
	+ 实例
	```
		//使用空指针导致panic异常，不会打断后面程序的运行
		func testPanic(num int) {
			//使用recover处理异常
			defer func() {
				msg := recover()
				if msg != nil {
					fmt.Println(msg)
				}
			}()
			defer fmt.Println("testPanic--01")
			defer fmt.Println("testPanic--02")
			fmt.Println("testPanic--03")
			// if num == 1 {
			// 	panic("出现预定的异常----panic")
			// }
			ptr := &num
			fmt.Println(*ptr)
			ptr = nil
			*ptr = 9	//空指针引用，会抛出panic异常
			//下面的步骤不会执行
			defer fmt.Println("testPanic--04")	
			fmt.Println("testPanic--05")

		}
	```

# 三、Go语言中的包
1. Go语言中包的本质：相当于文件夹，不同的文件夹可以存放不同的功能代码

2. 导入包的方式
	+ 批量导入包
	```
		import (
			//系统的包
			"包1"
			//自己写的包
			"包2"
			//网上下载的包 github
			...
		)
	```

3. 包名重复怎么办？
	+ 包名重复时，需要使用别名来区分
	```
		import ss "fmt"

		import (
			rand "math/rand"
			. "fmt"			//简便模式，直接使用fmt包中的函数，不需要前缀
			_ "fmt"			//匿名导入，只会执行这个包下的init方法
		)

		...
		Println("hello world")
	```

4. init函数(重点)
	+ init: 初始化，在main方法执行之前执行；设置一些包；初始化一些全局变量；建立一些第三方的连接(数据库连接等)
	+ init函数可以有多个
	+ init函数的执行顺序：
		+ 先执行匿名导入的包的init方法
		+ 再执行当前包的init方法
		+ 最后执行main方法
	+ init函数不需要传入参数，也没有返回值，任何地方都不能调用init()
	+ 单个init被多个地方导入，只会执行一次
	+ 如果导入了多个匿名包，按照main中导入包的顺序来进行执行
	+ 在同一个包下的go文件如果有多个，都有init的情况下，按照文件排放顺序来执行对应的init函数
	+ 实例
	```
		package main

		import (
			"fmt"
		)
	```

# 三、I/O操作
1. 获取文件信息
	```
		//获取文件信息
		fileInfo, err := os.Stat("test.txt")
		if err != nil {
			fmt.Println(err)
			return
		}
		fmt.Println(fileInfo.Name())
		fmt.Println(fileInfo.Size())
	```

2. 文件夹操作
	```
		//新建文件夹
		// error := os.Mkdir("./fileTest", os.ModePerm)
		error := os.Mkdir("/home/panda/gitWorkShop/workspace/golang/src/kuang/commonPack/fileTest", os.ModePerm)
		if error != nil {
			fmt.Println(error)
			return
		}
		fmt.Println("文件夹创建成功")

		//创建层级文件夹
		error2 := os.MkdirAll("./fileTest/a/b/c/d/e", os.ModePerm)

		//删除文件夹
		//只能删除单个空文件夹
		error3 := os.Remove("./fileTest/a/b/c/d/e")

		//如果存在多层文件，removeall相对来说比较危险，删除这个目录下的所有东西
		error3 := os.RemoveAll("./fileTest/")
	```

3. 文件操作
	```
		//创建文件
		//如果文件不存在，就创建再打开；如果文件存在，就打开
		file, err := os.Create("test.txt")
		if err != nil {
			fmt.Println(err)
			return
		}
		defer file.Close()

		//删除文件
		os.Remove("test.txt")
	```

4. 文件的IO操作
	+ 读取：file.Read([]byte), 将file中的数据读取到[]byte中
	```
		//打开文件
		file, err1 := os.Open("./fileTest/test.txt")

		//打开文件：可选权限
		//第二个参数是操作权限，第三个参数是创建文件时的权限
		// O_APPEND:追加
		file2, err2 := os.OpenFile("./fileTest/test.txt", os.O_RDWR|os.O_CREATE, os.ModePerm)

		//循环读取
		for {
			//创建容器来缓存(创建切片，指定大小和容量)
			cache := make([]byte, 2, 1024)
			//读取文件内容
			n, err := file.Read(cache)
			if err == io.EOF {
				break
			}
			fmt.Println("读取数据：", n)
			fmt.Println(string(cache))
		}

		//写入
		str_slice := []byte{67, 68, 69, 70}
		n, err2 := file.Write(str_slice)

		//写入字符串
		str := "hello,world\n what are you doing"
		n3, err3 := file.WriteString(str)
	```

5. 文件偏移
	+ Seek语法：
		+ ` func (f *File) Seek(offset int64, whence int) (ret int64, err error)`
		+ offset: 偏移量
		+ whence: 从哪个位置开始偏移
			+ 0: 从文件开头开始偏移
			+ 1: 从当前位置开始偏移
			+ 2: 从文件末尾开始偏移
	+ 实例
	```
		//打开文件
		file, err1 := os.Open("./fileTest/test.txt")
		if err1 != nil {
			fmt.Println(err1)
			return
		}
		defer file.Close()
	```










