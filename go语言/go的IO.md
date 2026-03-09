# 零、绪论
1. 引用os包
	+ 引用os包是为了使用os包中的函数和类型
	+ 引用os包的语法：
	```
		import (
			"os"
		)
	```

# 一、文件操作
1. 打开文件
	+ 语法: ` func Open(name string) (file *File, err error) `
		+ 如果返回的err为nil，则说明文件打开成功
	+ 打开文件是为了读取文件中的内容或者写入内容到文件中
	+ 无法打开文件的情况(即返回err)：
		+ 文件不存在
		+ 文件被其他程序占用
	+ 实例：
	```
		file, err := os.Open("文件名")
		if err != nil {
			fmt.Println("打开文件失败")
		}
	```