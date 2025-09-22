# 一、new和delete
1. 语法
	```
	int* p = new int;       // 分配单个整型
	int* arr = new int[5];  // 分配整型数组

	delete p;      // 释放单个对象
	delete[] arr;  // 释放数组
	```

2. 与malloc/free的区别
	+ new会调用构造函数，delete调用析构函数，而malloc/free仅分配/释放内存，不涉及对象生命周期管理
	+ new返回类型化指针，无需显式转换