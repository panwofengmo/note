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
	+ 后台模式：如果打开后台模式的两项配置，skynet将以后台模式启动。输出日志不再显示在控制台上，而是保存到logger项制定的文件中

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
		+ 例子：` skynet.newservice("debug_console", 8000)`
	+ skynet.start(func)
		+ 用func函数初始化服务
	+ skynet.dispatch(type, func)
		+ 绑定消息处理函数
		+ 例：` skynet.dispatch("lua", function(...))`
	+ skynet.send(addr, type, cmd, ...)
		+ 给其他服务发送消息
		+ 例：` skynet.send(ping1, "lua", "start", "node2", "pong")`
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
	+ socket.listen(host, port)
		+ 监听客户端连接，其中host代表IP地址，port代表端口，它将返回监听socket的标志
		+ 例：``` local listenfd = socket.listen("0.0.0.0", 8888)```
		+ 代表监听8888端口，"0.0.0.0"代表不限制客户端的ip，listenfd保存着监听socket的标识
	+ socket.start(fd, connect)
		+ 新客户端连接时，回调方法connect会被调用。参数fd是socket.listen返回的标识；回调方法connect带有两个参数，第一个参数代表新连接的标识，第二个参数代表新连接的地址
		+ 另外，connect获得一个新连接后并不会立即接收它的数据，需再次调用` socket.start(fd)`才会开始接收
		+ 一般开启监听的完整写法为
		```
			function connect(fd, addr)
				socket.start(fd)
				print(fd.." connect addr:"..addr)
			end

			local listenfd = socket.listen("0.0.0.0", 8888)
			socket.start(listenfd, connect)
		```
	+ socket.read(fd)
		+ 从指定的Socket上读数据，它是个阻塞方法
	+ socket.write(fd, data)
		+ 把数据data置入写队列，Skynet框架会在Socket可写时发送它
	+ socket.close(fd)
		+ 关闭连接，它是个阻塞方法

2. 代码实现
	+ 代码2-5和代码2-6是服务端完整实现：1新连接的处理；2接收数据的处理；3发送数据的处理

# 五、做留言板，使用数据库
1. skynet.db.mysql模块提供操作mysql数据库的API
	+ mysql.connect(args)
		+ 连接数据库。参数args是一个lua表，包含数据库地址、用户名、密码登信息，API会返回数据库对象，用于后序操作
		+ 例如：
		```
		local db = mysql.conncect({
			host = "39.100.116.201",
			port = 3306,
			database = "message_board",
			user = "root",
			password = "123456",
			max_packet_size = 1024 * 1024,
			on_connect = nil
		})
		```
		+ 代表连接地址为39.100.116.201、端口为3306、数据库名为message_board、用户名为root、密码为123456的MySQL数据库
	+ db:query(sql)
		+ 执行SQL语句。db代表mysql.connect返回的对象，参数sql代表SQL语句
		+ 例如：
			```
			local res = db:query("select * from msgs")
			```
		+ 代表查询数据表msgs，返回值res代表查询的结果
			```
			db:query("insert into msgs (text) value (\'hello'\))
			```
		+ 代表把字符串“hello”插入msgs表的text栏位

2. 准备数据库
	+ mysql一开始没有设置root密码，使用：` sudo mysql`进入mysql，然后设置root密码
	+ navicat连接不了mysql：1.要在腾讯云服务开放3306端口；2.在/etc/mysql/my.cnf追加以下代码
		```
		[mysqld]
		skip-name-resolve
		bind-address = 0.0.0.0
		```

3. 代码实现
	+ 实现功能：客户端可通过：1.set命令将数据存到数据库；2.get命令获取数据库msgs表的所有数据
	+ 相应代码：2-8，2-9，2-10

# 六、监控服务状态
1. debug_console服务：调试控制台服务，可以使用这个服务查看节点的内部状态

2. 使用服务：
	+ ` skynet.newservice("debug_console", 8000)`

3. debug_console服务的监控指令
	+ 更多控制台功能见https://github.com/cloudwu/skynet/wiki/DebugConsole
	+ list指令
		+ 用于列出所有的服务
	+ mem指令
		+ 用于显示所有lua服务占用的内存
	+ stat指令
		+ 用于列出所有Lua服务的CPU时间、处理的消息总数(message)、消息队列长度(mqlen)、被挂起的请求数据量(task)等。
	+ netstat
		+ 用于列出网络连接的概况
		+ 可以看到这个服务在监听的端口

# 七、使用节点集群建立分布式系统
0. 更多API参见https://github.com/cloudwu/skynet/wiki/Cluster

1. skynet.cluster模块提供节点间通信的API
	+ cluster.reload(cfg)
		+ 让本节点(重新)加载节点配置，参数cfg是个Lua表，指示集群中各节点的地址
		+ 例如
		```
		cluster.reload({
			node1 = "127.0.0.1:7001",
			node2 = "127.0.0.1:7001",
		})
		```
		+ 指明集群中有名为“node1”和“node2”的两个节点，node1监听本地7001端口，node2监听7002端口
	+ cluster.open(node)
		+ 启动节点。图2-33中的节点1需要调用cluster.open("node1")，节点2需要调用cluster.open("node2")，这样它们才知道自己是cluster.reload中的哪一项，并开启对应端口的监听
	+ cluster.send(node, address, cmd, ...)
		+ 向名为node的节点、地址为address的服务推送一条消息，这里参数cmd代表消息名
	+ cluster.call(node, address, cmd, ...)
		+ 它与cluster.send的功能相似，都是向另一个服务推送消息。不同的是，它是个阻塞方法，会等待对方的回应，对比表2-5可知，通过cluster发送的消息均为“lua”类型，无需指定
	+ cluster.proxy(node, address)
		+ 为远程节点上的服务创建一个本地代理服务，它会返回代理对象，之后可以用skynet.send、skynet.call操作该代理

2. 节点配置
	+ 创建Pconfig.c1和Pconfig.c2两个配置，分别对应两个节点

3. 代码实现
	+ 