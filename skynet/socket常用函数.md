# socket是哪里(require "skynet.socket"的解析)
1. **local socket = require "skynet.socket"**    //加载在lualib/skynet/socket.lua的文件
2. 在\lualib\loader.lua文件中，`package.path , LUA_PATH = LUA_PATH, nil`代码会将package.path设置为LUA_PATH的路径；而config中有对lua_path的设置
3. `lua_path="./skynet/lualib/?.lua;".."./skynet/lualib/?/init.lua"`
4. `require "skynet.socket"`中的`.`会被转换为文件系统的层级分隔符。在Linux系统中，等价于查找路径 `skynet/socket`(或 skynet/socket.lua)
5. `_G.require = (require "skynet.require").require`将lua原本的require替换成skynet的require
6. 总结：Skynet 启动时会在 Lua 虚拟机中初始化 package.path(模块搜索路径),已知```package.path = "./lualib/?.lua;./service/?.lua;..."```,此时`require "skynet.socket"` 会尝试从`lualib/skynet/socket.lua`加载‌

# socket更下层的模块
1. driver模块：`local driver = require "skynet.socketdriver"`，对应的是lua-socket.c的功能

# socket.listen函数
1. 形式：socket.listen(host, port, backlog)
2. host：ip地址，string变量；port：端口；backlog：连接请求队列的最大长度（一般由2到4）
    + 由c层调用c语言的bind和listen函数，并返回文件描述符fd，并将fd的信息加入到全局变量socket_pool中，然后
suspend挂起，等待新连接唤起

# socket.start函数

# socket.write函数

# socket.readline函数