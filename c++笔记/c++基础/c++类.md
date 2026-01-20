1. OOP
	+ OOP 代表面向对象编程 (Object-Oriented Programming)

2. 访问说明符
	+ 访问说明符用于指定类的成员(属性和方法)的访问权限
	+ 有三种访问说明符：public、private 和 protected
	+ public：成员可以在类的外部访问
	+ private：成员只能在类的内部访问
	+ protected：成员可以在类的内部和派生类的内部访问
	+ protected和private的区别：是否可以在派生类(子类)中访问


3. 类方法
	+ 方法是属于类的函数

4. 封装
	+ 封装可以确保更好地控制数据，因为您可以更改代码的一部分，而不会影响其他部分，从而增加了数据的安全性
	+ 封装还可以隐藏实现细节，从而使代码更易于维护
		+ 如果数据成员定义为private，那么只要类的接口不变，用户代码就无须改变
		+ 如果数据成员是public，那么数据成员的变动就可能导致使用了原来数据成员的代码失效

5. 继承
	+ 基类(父类)：被继承的类
	+ 派生类(子类)：从另一个类继承的类
	+ 示例：
	```
		class Vehicle {
			public:
				string brand;
				int year;
		};
		class Car : public Vehicle {		//这里的public可以改为protected或private, 从而改变基类在派生类的权限
			public:
				string model;
		};
	```

6. 多重继承
	+ 一个类也可以从多个基类派生，使用逗号分隔的列表
	+ 示例：` class MyChildClass: public MyClass, public MyOtherClass {};`

7. 多态性
	+ 多个不同的派生类可以修改基类的方法，每个派生类可以对同一个方法有不同的实现方法
	+ https://www.w3school.com.cn/cpp/cpp_polymorphism.asp

8. 文件
	+ fstream
		+ 要使用 `fstream` 库，需要同时包含标准的 `<iostream>` 和 `<fstream>` 头文件
		+ 三个类：`fstream`、`ifstream` 和 `ofstream`
			+ `fstream`：用于读写文件
			+ `ifstream`：用于从文件读取数据
			+ `ofstream`：用于向文件写入数据
	+ 关闭文件:` MyFile.close();`
		+ 可以清理不必要的内存空间
	+ 读取文件
		+ 使用`while` 循环与 `getline()` 函数一起逐行读取文件
		+ ` while(getline(in_stream, str))`

9. 构造函数
	+ 默认构造函数
		+ 只有当类没有定义任何构造函数时，编译器才会自动创建默认构造函数
		+ = default的含义：` sales_data() = default;`
			+ 显式地请求编译器生成默认构造函数
		+ 当类定义了其他构造函数时，默认构造函数就不会被自动创建；这个时候ClassA A; 是错误的
	+ 当某个数据成员被构造函数初始值列表忽略时，该数据成员将被默认初始化
		+ ```
			sales_data(const std::string &s):m_bookNo(s) {}
			sales_data(const std::string &s):m_bookNo(s), m_units_sold(0), m_revenue(0) {}		//与上面的效果相同
		```

10. 友元
	+ 定义和作用：类可以允许其他类或者函数访问它的非公有成员，方法是领其他类或者函数成员它的友元
	+ 用法：只需要增加一条以` friend` 开头的声明语句，就可以将其他类或者函数声明为该类的友元
	+ 声明：友元声明只能出现在类定义的内部。但是，除了类内部的友元声明以外，必须在友元声明之外再专门对函数/类进行一次声明。通常吧友元的声明和类本身放置在同一个头文件中(类的外部)
	+ 示例：
	```
		class MyClass {
			public:
				MyClass(int i) : m_i(i) {}
				friend void MyFriendFunction(MyClass&);		//友元函数
				friend class MyFriendClass;					//友元类
			...
		};
	```

11. 其他特性
	+ 类型成员
		+ ` typedef std::string::size_type pos;		//pos是一个类型成员`
		+ 用来定义类型的成员必须先定义后使用
	+ 可变数据变量(mutable)
		+ mutable变量即使是在const成员函数内，也可以被修改
		```
			class MyClass {
				public:
					MyClass(int i) : m_i(i) {}
					void MyFriendFunction() const {
						m_i = 100;		//在const成员函数内，也可以修改mutable变量
					}
				private:
					mutable int m_i;
			};
		```