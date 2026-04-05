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

		//将文件指针移动到文件开头
		file.Seek(0, io.SeekStart)
		//将文件指针移动到文件开头的第3个光标
		file1.Seek(3, io.SeekStart)
	```

6. bufio包
	+ go语言自带的IO操作包。bufio，使用这个包可以大幅提升文件的读写效率
	+ buf: 缓冲区
	+ bufio提供了一个缓冲区，读和写都先在缓冲区中，最后再一次性读取或者写入到文件里，降低访问本地磁盘的次数


# 四、groutine
1. 进程、线程、协程
	+ 程序：指令和数据的一个有序集合。本身没有任何含义，是一个静态的概念
	+ 进程：执行程序的一次执行过程，是动态的概念。是系统资源分配的单位
	+ 线程：一个进程中可以有多个线程，线程之间是并行的。线程是CPU调度和执行的单位
	+ 协程：一个线程中可以有多个协程，协程之间是并发的。协程是用户级的线程，由用户程序自己调度;用户态的轻量级 “伪线程”，由编程语言运行时调度，而非操作系统内核

2. groutine定义
	+ go中使用Goroutine来实现并发编程。Goroutine是一种轻量级的线程，由Go语言运行时管理。它的创建和销毁成本都非常低，能够在一个进程中同时运行成千上万个Goroutine。
	+ 创建Goroutine的成本很小，它就是一段代码，一个函数入口

3. 使用
	+ 在go语言中使用Goroutine非常简单，只需要在函数调用前添加关键字go即可。
	+ 实例
	```
		//定义一个函数
		func sayHello() {
			fmt.Println("hello,world")
		}
		//调用函数
		sayHello()
		//创建一个Goroutine
		go sayHello()
	```

4. 规则
	+ 当新的Goroutine开始时，Goroutine调用立刻返回。与函数不同，go不等待Goroutine执行结束
	+ 当Goroutine调用，并且Goroutine的任何返回值被忽略之后，go立即执行到下一行代码
	+ main的Goroutine应该为其他的Goroutine执行。如果main的Goroutine终止了，程序将被终止，而其他Goroutine将不会执行

5. 锁
	+ 不要以共享内存的方式(即加锁)去通信，而要以通信的方式(即channel)去共享内存
	+ 在Go语言中并不鼓励用锁保护共享状态的方式，在不同的groutine中分享信息(以共享内存的方式去通信)。
	+ 而是鼓励通过channel将共享状态或共享状态的变化在各个groutine之间传递(以通信的方式去共享内存)。
	+ 这样同样能像用锁一样保证在同一时间只有一个groutine访问共享状态
	```
	mutex.Lock()	//加锁
	mutex.Unlock()	//解锁
	```

6. 同步等待
	```
	var wg sync.WaitGroup

	wg.Add(2)	//添加一个groutine
	go func() {
		defer wg.Done()	//在groutine执行结束时调用Done()方法
	}()
	go func() {
		defer wg.Done()	//在groutine执行结束时调用Done()方法
	}()
	wg.Wait()	//等待所有groutine执行结束
	```


# 五、channel
1. 定义通道: ` var 通道名 chan 数据类型`
	+ 定义完后，这个通道只能放指定数据类型的数据

2. 使用规则(存、取)
	+ 一个通道发送和接收数据，默认是阻塞的
	+ 所有channel的发送和接收必须处于不同的Goroutine中。如：在main中使用` data := <- a`, 那么main就不能使用` a <- 100`
	+ ch := make(chan int) 是**无缓冲通道**，它的规则是：
	+ 发送方必须等接收方准备好，才能发送成功；
	+ 接收方必须等发送方准备好，才能接收成功。
	```
		var a chan int
		a = make(chan int)

		a <- 100	//向通道a中发送数据100
		data := <- a	//从通道a中接收数据
	```

3. 注意
	+ go语言不建议我们使用锁机制来解决多线程问题，建议我们使用通道

4. 死锁
	+ 如果创建了chan，没有groutine来使用了，则会出现死锁

5. 关闭通道
	+ 关闭通道后，在该通道阻塞的协程会被唤醒
	```
		close(ch)

		//可以使用for range来遍历通道中的数据
		for v := range ch {	//当通道关闭后，会退出for循环
			fmt.Println(v)
		}
	```

6. 缓冲通道
	+ 非缓冲通道：只能存放一个数据，发送和接收都是阻塞的
	+ 缓冲通道：通道带了一个缓冲区，发送的数据直到缓冲区填满为止才会被阻塞。接收直到缓冲区清空，才会阻塞

7. 定向通道
	+ 定向通道：只能单向发送或接收数据的通道
	+ 定义：`var 通道名 chan <- 数据类型`或`var 通道名 chan chan 数据类型`
	+ 实例
	```
		var a chan <- int
		a = make(chan <- int)

		//只能写，不能读
		a = make(chan <- int)
		//只能读，不能写
		a = make(<-chan int)

		//可以将双向通道传给定向通道
		func testFunc6(ch <-chan int) {
			for data := range ch {
				fmt.Println("读数据", data)
			}
		}
		ch := make(chan int)
		testFunc6(ch)
	```

8. Select
	+ select语句：用于等待多个通道的读写操作，直到有一个操作就绪为止
	+ 和switch类似，只能在通道中使用，case表达式需要是一个通道结果
	+ 语法：
	```
	select {
	case 通道1 <- 数据1:
		//通道1发送数据1
	case 通道2 <- 数据2:
		//通道2发送数据2
	case 通道3 <- 数据3:
		//通道3发送数据3
	default:
		//如果没有通道就绪，执行default语句
	}
	```

9. timer定时器


# 六、反射
1. 定义
	+ 反射机制可以在程序运行的过程中获取信息，如：变量的类型、值；结构体的字段、方法等
	+ 反射机制的使用需要导入`reflect`包
	+ 一般是使用：` reflect.Type`和` reflect.Value`来获取信息和操作值


2. 注意
	+ 反射在正常的开发中很少用到。因为效率低
	+ 开发一些脚手架，自动实现一些底层的判断
	+ 如果我们不知道这个对象的信息，我们可以通过这个对象拿到代码中的一切

3. 为什么不建议使用反射
	+ 和反射相关的代码，不方便阅读
	+ Go语言是静态类型语言，编译器可以找出开发时的错误，如果代码中有大量的反射代码，随时可能存在安全问题
	+ 反射的性能很低，相对于正常的开发，至少慢2-3个数量级
	+ 项目关键位置低耗时，一定不能用反射

4. 反射获取变量信息
	```
	func reflectGetInfo(v interface{}) {
		//1.获取参数的类型
		getType := reflect.TypeOf(v)
		fmt.Println(getType.Name()) //类型信息: "User"
		fmt.Println(getType.Kind()) //找到上级的种类kind："struct"

		//2.获取值
		getValue := reflect.ValueOf(v)
		fmt.Println("获取到value", getValue)

		//获取字段，通过type扒出字段
		for i := 0; i < getType.NumField(); i++ { //Type.NumField()获取这个类型有几个字段
			field := getType.Field(i) //Field(index)得到字段的值
			value := getValue.Field(i).Interface()
			fmt.Printf("字段名：%s, 字段类型：%s, 字段值：%s\n", field.Name, field.Type, value)
		}

		//获取这个结构的方法
		for i := 0; i < getType.NumMethod(); i++ {
			method := getType.Method(i)
			fmt.Printf("方法的名字：%s, 方法的类型：%s\n", method.Name, method.Type)
		}
	}
	```
