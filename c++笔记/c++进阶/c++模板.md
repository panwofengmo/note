# 一、函数重载
1. 语法结构
	```
	template <typename T>						// 模板声明（无分号）
	返回值类型 函数名(参数列表) {					// 函数定义
		函数体;
	}
	```

2. ‌自动推导‌和显式指定
	+ 自动推导‌：编译器根据实参类型自动生成实例化版本
		+ ` int a = Sum(10, 20);  // 推导T为int`
	+ 显式指定‌：当推导失败时需手动指定类型
		+ ` double b = Sum<double>(3.5, 2.5);  // 显式指定T为double`
	+ 示例
	```
	template<class T>				//自动推导
	T compareMax(T a, T b) {...}

	template<>						//显示指定，compareMax("asda", "qweq")就是走这个函数
	const char* compareMax<const char*>(const char* a, const char* b) {...}
	```

