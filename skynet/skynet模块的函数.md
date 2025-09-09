# 前言
1. 位置：由`local skynet = require "skynet"`可知道skynet模块是在\lualib\skynet.lua里
2. skynet的lua API网址：https://github.com/cloudwu/skynet/wiki/LuaAPI
3. 每个 skynet 服务都依赖一个 skynet_context 的 C 对象，它是由 snlua 导入到 lua 虚拟机中的
4. ` require "skynet.manager"`
	+ 这部分 API 只在搭建框架时用到，普通服务并不会使用
	+ 为了兼容老代码，skynet.manager 共享 skynet 名字空间。require 这个模块后，这些额外的 API 依旧放在 skynet 下


# skynet.newservice函数
1. 语法：`skynet.newservice(name, ...)`
2. 功能：创建一个新的服务; 阻塞 API
3. 参数：
	- name：字符串，服务的名称，name 是脚本的名字(不用写 .lua 后缀)
	- ...：可变参数，服务的参数
4. 返回值：地址，新创建的服务的地址


# skynet.name函数
1. 语法：`skynet.name(name, addr)`
2. 功能：为一个地址命名
3. 参数：
	- name：字符串，命名的名称
	- addr：地址，要命名的地址
4. 返回值：无

# skynet.call函数
1. 语法：` skynet.call(addr, type, ...)`
```
local srv = skynet.newservice("login","login", i)
local str_name = "login"..i
skynet.name(str_name, srv)		--为一个地址命名

local address = "login1"
skynet.call(address, "lua", command, ...)
```


# skynet.fork函数

# skynet.self函数

# skynet.send函数

# skynet.dispatch函数

# skynet.retpack函数

# skynet.uniqueservice函数

# skynet.response函数


