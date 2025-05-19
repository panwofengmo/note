# 一、下载、编译、运行 
    1. 下载和编译skynet     (26页)
        + 启动skynet服务端：```./skynet examples/config     #启动skynet(kv数据库范例)```
        + 启动skynet客户端：```lua example/client.lua ```

# 二、理解skynet
1. 节点和服务
	+ 每个skynet进程(操作系统进程)称为一个节点，每个节点可以开启数千个服务。每个服务都是一个actor。

2. 配置文件
	+ 代码文件：1_config
	+ thread字段：表示启动多少个工作线程。通常不要将它设置超过CPU核心数。假设使用的是8核CPU，那么此处设置为8
	+ start字段：主服务。制定skynet系统启动后，开启那个自定义的服务
	+ 可以打开https://github.com/cloudwu/skynet/wiki/Config 查看skynet配置的详细说明
	+ 后台末世：如果打开后台模式的两项配置，skynet将以后台模式启动。输出日志不再显示在控制台上，而是保存到logger项制定的文件中

3. 目录结构
	+ examples：范例。KV数据库范例的部分服务(如main服务、simpledb服务)位于该目录下
	+ service：包含skynet内置的一些服务，比如KV数据库范例用到的launcher、gate
	+ test：测试代码。若遇到某些不懂的功能，可以参考该目录下的代码
	+ 3rd：存放第三方的代码，如lua、jemallic、lpeg等
	+ cservice：存放内置的用C语言编写的服务
	+ luaclib：用C语言编写的程序库，如bson解析、md5解析等
	+ lualib：用lua编写的程序库
	+ lualib-src：luaclib目录下，库文件的源码
	+ service-src：cservice目录下，程序的源码
	+ skynet-src：使用C写的skynet核心代码

4. 启动流程
	+ 1.启动skynet
	+ 2.读取配置文件；如：examples/config
	+ 3.初始化；开启服务bootstrap、launcher等
	+ 4.启动主服务；如：examples/main.lua


# 三、第一个程序PingPong
1. API的用法和说明：https://github.com/cloudwu/skynet/wiki/APIList
2. skynet中8个最重要的API
	+ skynet.newservice(name, ...)
		+ 启动新服务
	+ skynet.start(func)
		+ 用func函数初始化服务
	+ skynet.dispatch(type, func)	(例：skynet.dispatch("lua", function(...)))
		+ 绑定消息处理函数
	+ skynet.send(addr, type, cmd, ...)
		+ 给其他服务发送消息
	+ skynet.call(addr, type, cmd, ...)
		+ 给其他服务发送消息，是一个阻塞方法	
	+ skynet.exit()
		+ 结束当前服务
	+ skynet.self()
		+ 返回当前服务的地址
	+ skynet.error(msg)
		+ 向log服务发送一条消息，即打印日志
3. 代码实现
	+ 1.创建main文件(Pmain.lua)；2.创建服务(ping.lua)；3.修改配置(Pconfig)；4.运行：``` ./skynet examples/Pconfig ```

# 四、写Echo，练习网络编程
1. 网络模块的API
	+ 