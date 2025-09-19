# 一、运算符重载
1. ` []`运算符
	+ ` 类型1 &operator[](类型2)`
	+ 示例：
		+ ` double &operator[](string name)`

2. ` ++`运算符
	+ 语法
	```
	T& operator++();    // 前置自增
	T& operator--();    // 前置自减

	T operator++(int);  // 后置自增
	T operator--(int);  // 后置自减
	```
	+ 通过在运算符函数参数表中是否插入关键字int 来区分这两种方式
	+ 示例
		+ ` Clock& operator++()  //前置自增`
		+ ` Clock operator++(int)	//后置自增`	

3. 强制转换
	+ 语法：` operator 目标类型()`
	+ 示例
	```
	operator int() { return int(r);}
	operator double() { return 2*3.14*r;}
	operator float() { return (float)3.14*r*r;}
	```
	+ 可通过` explicit`关键字限制隐式调用
	+ 如：` int n = object + 1`，object会隐式强制转换为int，而加了` explicit`后，就不会有这种隐式转换

4. 圆括号
	+ 语法：`T operator()(Params...)`
	+ 示例：` void operator() (int a, int b, int c)`

5. 