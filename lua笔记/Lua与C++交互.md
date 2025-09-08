# 一、参考文献
https://zhuanlan.zhihu.com/p/1893758690286368623

# 二、交互的基本原理
1. C++ 调用 Lua 脚本
	+ 使用 Lua 的 C API 加载并执行 Lua 脚本
	+ 可以从 Lua 脚本中获取变量或调用函数
	+ 数据通过栈（stack）进行传递

2. Lua 调用 C++ 函数
	+ 将 C++ 函数注册到 Lua 的全局环境中
	+ 注册函数后，Lua 脚本可以直接调用这些函数
	+ 数据同样通过栈进行传递

3. 数据传递
	+ Lua 和 C++ 之间的数据传递是通过栈完成的
	+ C++ 程序可以将数据压入栈中，Lua 脚本可以从栈中读取数据，反之亦然

# 三、编译
1. g++ main.cpp -I/usr/local/include -llua -ldl
	+ /usr/local/include：lua.hpp文件所在的路径

# 四、关键点解析
1. Lua 状态机 (lua_State)
	+ `lua_State` 是 Lua 的核心，表示一个独立的 Lua 运行环境
	+ 每次调用 Lua 脚本时都需要创建一个状态机，并在完成后关闭它
2. 栈操作
	+ Lua 和 C++ 之间的数据传递是通过栈完成的。
	+ 常用的栈操作函数：
		+ `lua_push*`：将数据压入栈中。
		+ `lua_to*`：从栈中读取数据。
		+ `lua_pop`：弹出栈顶元素。
3. 错误处理
	+ 使用 `lua_pcall` 调用 Lua 函数时，可以捕获运行时错误。
	+ 如果 Lua 脚本中有语法错误或运行时异常，可以通过 `lua_tostring` 获取错误信息。
4. 函数注册
	+ 使用 `lua_register` 或 `lua_pushcfunction` 将 C++ 函数注册到 Lua

# 五、总结
1. Lua 和 C++ 的交互主要依赖于 Lua 的 C API。
2. 数据传递通过栈完成，栈操作是交互的核心。
3. C++ 可以调用 Lua 脚本中的函数，也可以将 C++ 函数注册到 Lua 中供其调用。
4. 通过这种方式，Lua 和 C++ 可以高效地协同工作，适用于游戏开发、嵌入式系统等领域。