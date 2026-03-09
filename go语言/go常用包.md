# 一、main包
1. main函数所在的包，必须是main包。代表程序的入口
2. main包是程序的入口，其他包不能使用

# 二、package包
1. src：保存项目的源码路径，所有的代码都用包的形式放在这里
2. package声明包在哪里，不需要和文件夹名一致，但是我们尽量使用文件夹的名字
3. 一个目录下的所有go文件的package必须同名
4. 同一个包下的所有go文件的函数，可以直接调用
5. 导入其他包，需要从goworks下面的src目录开始导
6. 如果当前包的函数要给外面的包使用，必须要函数名大写


# 三、Strings包
1. 判断某个字符是否包含指定内容
	```
		str := "hello, world"
		is_exist := strings.Contains(str, "hello")
		fmt.Println(is_exist)
	```

2. 判断某个字符串是否包含了多个字符串中的某一个
	```
		str := "hello, world"
		is_exist := strings.ContainsAny(str, "la")	//不包含a，但是包含l
		fmt.Println(is_exist)
	```

3. 统计这个字符在指定字符串中出现的数量
	```
		str := "hello, world"
		count_int := strings.Count(str, "l")
		fmt.Println(count_int)
	```

4. 判断用什么开头的HasPrefix
	```
		str := "hello, world"
		is_exist = strings.HasPrefix(str, "he")
		fmt.Println(is_exist)
	```

5. 判断用什么结尾的HasSuffix
	```
		str := "hello, world"
		is_exist = strings.HasSuffix(str, "ld")
		fmt.Println(is_exist)
	```

6. 寻找这个字符串第一次出现的位置
	```
		str := "hello, world"
		indx_int := strings.Index(str, ", w")
		fmt.Println(indx_int)
	```

7. 寻找这个字符串最后一次出现的位置
	```
		str := "hello, world"
		indx_int := strings.LastIndex(str, "l")
		fmt.Println(indx_int)
	```

8. 拼接字符串
	```
		str_slice := []string{"a", "b", "c"}
		ret := strings.Join(str_slice, "-")
		fmt.Println("8", ret)
	```

9. 通过某个格式，拆分字符串
	```
		str := "a-b-c"
		ret_slice := strings.Split(str, "-")
		fmt.Println(ret_slice)
	```


# 四、strconv包(字符串转换)
1. 字符串和bool相互转换)
	```
		//1. 转换
		//字符串转bool(解析)
		str := "true"
		flag_bool, _ := strconv.ParseBool(str)
		fmt.Printf("%T, %t\n", flag_bool, flag_bool)

		//bool转字符串(格式化)
		ret_str := strconv.FormatBool(flag_bool)
		fmt.Printf("%T, %s\n", ret_str, ret_str)

		//字符串和数字转换
		strconv.ParseInt("123", 10, 64)			//字符串转数字
		ret_str := strconv.FormatInt(123, 10)	//数字转字符串
		fmt.Printf("%T, %s\n", ret_str, ret_str)
	```

2. 十进制转换字符串
	```
		//十进制转换字符串
		ret_str := strconv.Itoa(10)
		fmt.Printf("%T, %s\n", ret_str, ret_str)

		//字符串转换十进制转
		ret_int, _ := strconv.Atoi("10")
		fmt.Printf("%T, %d\n", ret_int, ret_int)
	```


# 五、time包
1. 时间格式化--返回年月日 时分秒
	```
		//时间格式化
		t := time.Now()
		//go语言诞生的时间作为格式化模板："2006-01-02 15:04:05"
		fmt.Println(t.Format("2006-01-02 15:04:05"))	//2026-03-09 10:34:24
		fmt.Println(t.Format("2006-01-02 03:04:05 PM"))	//12小时制
	```

2. 将字符串解析为时间
	+ ` func Parse(layout, value string) (Time, error) `

3. 获取时间戳
	+ ` func (t Time) Unix() int64 `
	```
		//获取时间戳
		t := time.Now()
		fmt.Println(t.Unix())	//时间戳(秒)
		fmt.Println(t.UnixNano())	//时间戳(纳秒)
	```

4. 通过时间戳，转换成time对象
	+ ` func (t Time) Unix() int64 `
	```
		//通过时间戳，转换成time对象
		t := time.Unix(1678345600, 0)
		fmt.Println(t)	//2023-03-09 00:00:00 +0800 CST
	```

5. 定时器
	+ time.Duration：是time包定义的一个类型，它代表两个时间点之间经过的时间，即时间间隔
	+ 以纳秒为单位
	```
		//定时器
		ticker := time.NewTicker(time.Second)
		defer ticker.Stop()
		for range ticker.C {
			fmt.Println(time.Now().Format("2006-01-02 15:04:05"))
		}
	```

6. 时间操作
	+ time.Duration：是time包定义的一个类型，它代表两个时间点之间经过的时间，即时间间隔
	```
		//时间操作
		//相加
		t := time.Now()
		addNow := now.Add(time.Hour)
		fmt.Println(addNow)

		//相减: 两个时间的差值
		subNow := addNow.Sub(now)
		fmt.Println(subNow)
		fmt.Printf("%T,%v\n", subNow, subNow)

		//比较时间
		fmt.Println(now.Before(addNow))
		fmt.Println(now.After(addNow))
		fmt.Println(now.Equal(addNow))
	```

# 六、随机数
1. 无范围随机数：` num := rand.Int()`

2. 有范围随机数：` num := rand.Intn(100)	//[0,100)`

