1. OOP
	+ OOP 代表面向对象编程 (Object-Oriented Programming)

2. 访问说明符
	+ 访问说明符用于指定类的成员(属性和方法)的访问权限
	+ 有三种访问说明符：public、private 和 protected
	+ public：成员可以在类的外部访问
	+ private：成员只能在类的内部访问
	+ protected：成员可以在类的内部和派生类的内部访问

3. 类方法
	+ 方法是属于类的函数

4. 封装
	+ 封装可以确保更好地控制数据，因为您可以更改代码的一部分，而不会影响其他部分，从而增加了数据的安全性
	+ 封装还可以隐藏实现细节，从而使代码更易于维护

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
