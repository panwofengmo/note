1. 函数声明和定义
	+ 声明：返回类型、函数名称和参数(如果有)
	+ 定义：函数体(要执行的代码)
	+ 
	```
		void myFunction() { // 声明
			// 函数的主体（定义）
		}
	```
	+ 可以将函数的声明和定义分开
	+ 示例：
	```
		// 函数声明
		void myFunction();
		
		// 主方法
		int main() {
			myFunction();  // 调用函数
			return 0;
		}
		
		// 函数定义
		void myFunction() {
			cout << "本段代码刚被执行！";
		}
	```

2. 默认参数值
	+ 使用等号（=）来设置默认参数值，如果调用该函数时没有传入参数，那么它会使用默认值
	+ 示例：
	```
		void myFunction(int x, int y = 20) {
			// 函数体
		}
	```

3. 全局变量
	+ 在函数外部创建的变量称为全局变量，属于全局作用域

4. 参数传递
	+ 分类：分为引用传递和值传递
	+ 值传递：实质为拷贝，函数的形参的变化不会影响实参
		+ 指针形参：当执行指针拷贝操作时，拷贝的是指针的值；但可以影响形参指向的对象
			```
				void reset(int *ip)
				{
					*ip = 0;		//改变指针ip所指的对象的值
					ip = NULL;		//只改变了ip的局部拷贝，实参未被改变
				}
			```

	+ 引用传递
		+ 引用操作实际上是作用在引用所引的对象
		+ 使用引用可以避免拷贝
		+ 尽量使用常量引用

	+ 数组形参
		+ 当我们为函数传递一个数组时，实际上传递的是指向数组首元素的指针
			```
			//尽管形式不同，但这三个print函数是等价的
			void print(const int*);
			void print(const int[]);
			void print(const int[10]);
			```
	+ main函数传参
		+ ` int main(int argc, char **argv) {...}`
		+ 实例：如果执行可执行文件prog
			```
			命令行：prog -d -o ofile data0
			那么main函数参数中，argc = 5
			argv[0] = "prog";	argv[1] = "-d"; argv[2] = "-o";
			argv[3] = "ofile"; argv[4] = "data0"; argv[5] = 0;

			argv[0]保存程序的名字，而非用户输入
			最后一个指针之后的元素值保证为0
			```
	+ 含有可变形参的函数
		+ initializer_list：用于函数的实参数量未知但是全部实参的类型都相同
		+ ` void error_msg(initializer_list<string> il)`
		+ 省略符形参: ` void foo(...);`
  
5. 返回类型和return语句
	+ 不要返回局部对象的引用或指针
		+ 函数完成后，它占用的存储空间也随之被释放掉
	+ 使用尾置返回类型
		` auto func(int i) ->int (*)[10];		//func接受一个int类型的实参，返回一个指针，该指针指向含有10个整数的数组`

6. 函数重载
	+ 定义：如果同一作用域内的几个函数名字相同但形参列表不同，我们称之为重载函数
	+ 如果有两个函数，它们的形参列表相同，函数名相同，仅仅返回值不同，则会报错
	+ 一个拥有顶层const的形参无法和另一个没有顶层const的形参区分开来
		```
		Record lookup(Phone);
		Record lookup(const Phone);		//重复声明了Record lookup(Phone)

		Record lookup(Phone*);
		Record lookup(Phone* const);		//重复声明了Record lookup(Phone*)
		```
	+ 如果形参是某种类型的指针或引用，则通过区分其指向的是常量对象还是非常量对象可以实现函数重载
		```
		Record lookup(Account&);					//函数作用于Account的引用
		Record lookup(const Account&);				//新函数，作用于常量引用

		Record lookup(Account&);					//新函数，作用于指向Account的指针
		Record lookup(Account&);					//新函数，作用于指向常量的指针

		//上面的例子中，编译器可以通过实参是否是常量来推断应该调用哪个函数。
		```
	+ 在不同的作用域中无法重载函数名：一旦在当前作用域中找到了所需的名字，编译器救护忽略掉外层作用域的同名实体

7. 默认实参
	+ 一旦某个形参被赋予了默认值，它后面的所有形参都必须有默认值
	+ 声明
		```
		string screen(sz, sz, char = ' ');		//第一个声明
		string screen(sz, sz, char = '*');		//错误：重复声明
		string screen(sz = 24, sz = 80, char);		//正确：添加默认实参，和第一个声明不冲突
		```
		+ 应该在函数声明中指定默认实参，并将该声明放在合适的头文件中

8. 内联函数
	+ 内联函数不能递归

9. constexpr函数
	+ 该函数的返回类型和所有形参的类型都得是字面值类型，而且函数体中必须有且只有一条return语句

10. assert预处理宏
	+ ` assert(expr);`
	+ 如果expr为假：assert输出信息并终止程序的执行

11. static函数
	+ 静态函数，则此函数只会在这个cpp文件被调用，不会被其他地方调用
	+ 如果其他地方调用了这个函数，会报错(除非自己有个相同的static函数)
	+ 如果static有个无定义的函数，则不会发生链接错误
