package.path = package.path .. ';luasocket/?.lua'
package.cpath = package.cpath .. ';luasocket/?.so'

local sys_print = print
local print = nil

local cjson = require("cjson")
local cjson_map = cjson:new()
cjson_map.encode_sparse_array(true, 1, 1)

require("redis")
require("util")
require("time")

function print(...)

	local info = _G.debug.getinfo(2, "Sl")
	local file = info and info.short_src or "unknown"
	local line = info and info.currentline or 0

	sys_print(file .. ":" .. line, ...)
end

local activity_redis_host = "pt-activity.pwft0z.clustercfg.use1.cache.amazonaws.com"
local activity_redis_port = 6379
local activity_redis = Redis.connect(activity_redis_host, activity_redis_port, "", true, true)

function logic()
activity_redis:del("dpzj:slots:data:4189214:37:" .. 100 .. ":details")
activity_redis:del("dpzj:slots:data:13167313:37:" .. 1000 .. ":details")
end

local ok, err = pcall(logic)
if not ok then
	print(err)
else
	print("执行完毕", time.date(os.time()))
end

activity_redis:quit()
