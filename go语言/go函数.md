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

4. 使用switch判断类型
	+ i.(type)必须在switch语句中使用
	```
	func testVarType(i any) {
		switch i.(type) {
		case string:
			fmt.Println("string类型")
		case int:
			fmt.Println("int类型")
		default:
			fmt.Println("任何类型")
		}
	}
	```


# 二、strconv包
1. strconv.ParseInt()
	+ 将字符串转换为整数
	+ 语法：`func ParseInt(s string, base int, bitSize int) (i int64, err error)`
	+ 参数：
		+ s：要转换的字符串
		+ base：进制数，2到36之间的整数
		+ bitSize：结果的位大小，0表示根据字符串的内容自动选择位大小
	+ 返回值：
		+ i：转换后的整数
		+ err：转换时遇到的错误
	+ 示例：
		```
		i, err := strconv.ParseInt("123", 10, 64)
		if err != nil {
			fmt.Println(err)
		} else {
			fmt.Println(i)
		}
		```


# 三、文件操作
1. os.ReadDir()
	+ 读取目录内容
	+ 语法：`func ReadDir(dirname string) (dirs []DirEntry, err error)`
	+ 参数：
		+ dirname：要读取的目录名
	+ 返回值：
		+ dirs：目录下的所有文件和子目录的信息，以DirEntry结构体的切片返回
		+ err：读取时遇到的错误
	+ 示例：
		```
		dirs, err := os.ReadDir("test")
		if err != nil {
			fmt.Println(err)
			return
		}
		fmt.Println(string(data))
		```

2. os.OpenFile()
	+ 打开文件
	+ 语法：`func OpenFile(name string, flag int, perm fs.FileMode) (file *os.File, err error)`
	+ 参数：
		+ name：要打开的文件名
		+ flag：打开文件的模式，如os.O_RDONLY、os.O_WRONLY、os.O_RDWR等
		+ perm：文件权限，如0644、0755、os.ModePerm等
	+ 返回值：
		+ file：打开的文件对象
		+ err：打开时遇到的错误
	+ 示例：
		```
		file, err := os.OpenFile("test.txt", os.O_RDONLY, 0644)
		if err != nil {
			fmt.Println(err)
			return
		}
		defer file.Close()
		```

3. file.Read()
	+ 从文件中读取数据
	+ 语法：`func (f *File) Read(b []byte) (n int, err error)`
	+ 参数：
		+ b：要读取数据的字节切片
	+ 返回值：
		+ n：读取的字节数
		+ err：读取时遇到的错误
	+ 示例：
		```
		buf := make([]byte, 1024)
		n, err := file.Read(buf)
		if err != nil {
			fmt.Println(err)
			return
		}
		fmt.Println(string(buf[:n]))
		```

4. file.Write()
	+ 向文件中写入数据
	+ 语法：`func (f *File) Write(b []byte) (n int, err error)`
	+ 参数：
		+ b：要写入数据的字节切片
	+ 返回值：
		+ n：写入的字节数
		+ err：写入时遇到的错误
	+ 示例：
		```
		buf := []byte("hello world")
		n, err := file.Write(buf)
		if err != nil {
			fmt.Println(err)
			return
		}
		fmt.Println(n)
		```

5. file.Seek()
	+ 移动文件指针
	+ 语法：`func (f *File) Seek(offset int64, whence int) (ret int64, err error)`
	+ 参数：
		+ offset：要移动的字节数
		+ whence：移动的起始位置，0表示文件开头，1表示当前位置，2表示文件末尾
	+ 返回值：
		+ ret：移动后的文件指针位置
		+ err：移动时遇到的错误
	+ 示例：
		```
		file.Seek(0, io.SeekStart)
		//将文件指针移动到文件开头的第3个光标
		file1.Seek(3, io.SeekStart)
		```


# 四、bufio包
1. bufio.NewReader()
	+ 创建一个新的Reader对象
	+ 语法：`func NewReader(rd io.Reader) *Reader`
	+ 参数：
		+ rd：要读取的io.Reader对象
	+ 返回值：
		+ *Reader：新创建的Reader对象
	+ 示例：
		```
		reader := bufio.NewReader(file)

		//读取系统的标准输入
		inputReader := bufio.NewReader(os.Stdin)
		```

2. reader.Read(cache)
	+ 从Reader对象中读取数据到缓存中
	+ 语法：`func (b *Reader) Read(cache []byte) (n int, err error)`
	+ 参数：
		+ cache：要读取数据的缓存切片
	+ 返回值：
		+ n：读取的字节数
		+ err：读取时遇到的错误
	+ 示例：
		```
		cache := make([]byte, 1024)
		n, err := reader.Read(cache)
		if err != nil {
			fmt.Println(err)
			return
		}
		fmt.Println(string(cache[:n]))
		```

# 五、runtime包
1. runtime.GOROOT()
	+ 获取当前Go语言的安装目录
	+ 语法：`func GOROOT() string`
	+ 返回值：
		+ string：当前Go语言的安装目录
	+ 示例：
		```
		fmt.Println(runtime.GOROOT())
		```

2. runtime.GOOS()
	+ 获取当前Go语言的操作系统
	+ 语法：`func GOOS() string`
	+ 返回值：
		+ string：当前Go语言的操作系统
	+ 示例：
		```
		fmt.Println(runtime.GOOS())
		```

3. runtime.Goexit()
	+ 退出当前的Go语言程序
	+ 语法：`func Goexit()`
	+ 返回值：
		+ 无
	+ 示例：
		```
		runtime.Goexit()
		```

4. 






