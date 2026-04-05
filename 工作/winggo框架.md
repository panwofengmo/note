# 零、前言
配合云文档https://nxjy5tl8k2.sg.larksuite.com/docx/UDVodwUwnoPXk8xIGgYlfo4igIf

# 一、整体架构概览

# 二、客户端连接流程
### 2.1 登录流程
1. process_protocol函数
	+ 该函数一共有三个地方，分别是在process_protocol.lua、gamesvr、login
	+ gamesvr和login的函数是一模一样的，包含对客户端的协议处理和服务器协议的处理
	+ process_protocol.lua只有对服务器协议的处理
	+ process_protocol.lua的函数是其他svr都在用的

2. login处理前端请求的流程
	+ 前端连接到c++端，c++调用on_channel_accept函数，login将对应的sock和session保存到data.clients中(on_channel_accept)
	+ c++端调用login的process_protocol函数
	+ 然后调用opens[1]的协议处理，将对应的gamesvr的ip和port返回给前端
	+ 前端根据返回的ip和port，连接到gamesvr，gamesvr将对应的sock和session保存到data.clients中(on_channel_accept)
	+ c++端调用gamesvr的process_protocol函数, 然后调用opens[3]的协议处理


# 三、Lua 服务器架构详解


# 四、数据存储策略

# 五、核心机制：协议处理与协程调度