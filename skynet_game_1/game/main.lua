-- 这是一个名为main的actor，功能是网关，处理客户端的连接
local skynet = require "skynet"
local socket = require "skynet.socket"

local function accept(clientfd, addr)
    skynet.newservice("agent", clientfd, addr) -- 启动多个agent服务，但传入的参数clientfd, addr不一样
end

skynet.start(function()
    local listenfd = socket.listen("0.0.0.0", 8888)
    skynet.uniqueservice("redis") -- 整个skynet启动唯一的一个服务
    skynet.uniqueservice("hall")
    socket.start(listenfd, accept) -- 当每一次有新的连接，就会启动accept函数接口
end)
