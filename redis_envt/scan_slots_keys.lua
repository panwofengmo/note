package.path = package.path .. ';/home/mj/other/?.lua'
package.path = package.path .. ';luasocket/?.lua'
package.cpath = package.cpath .. ';luasocket/?.so'

local sys_print = print
local print = nil

local luasql = require("luasql.mysql")
local cjson = require("cjson")
local cjson_map = cjson:new()
cjson_map.encode_sparse_array(true, 1, 1)

require("redis")
require("util")
require("time")

local redis_host = "pt.pwft0z.clustercfg.use1.cache.amazonaws.com"
local redis_port = 6379
local redis_pwd = ""

local redis = Redis.connect(redis_host, redis_port, redis_pwd, true, true)

local activity_redis_host = "pt-activity.pwft0z.clustercfg.use1.cache.amazonaws.com"
local activity_redis_port = 6379
local activity_redis_pwd = ""

local activity_redis = Redis.connect(activity_redis_host, activity_redis_port, activity_redis_pwd, true, true)

function print(...)

	local info = _G.debug.getinfo(2, "Sl")
	local file = info and info.short_src or "unknown"
	local line = info and info.currentline or 0

	sys_print(file .. ":" .. line, ...)
	io.flush()
end

function scan(r, pattern, count)

	local cursor = 0 
	return function()
		local response = r:scan(cursor, {["match"] = pattern, ["count"] = count})
		local next_cursor = tonumber(response[1])
		local keys = response[2]
		cursor = next_cursor

		return cursor == 0, keys
	end 
end

function scan_callback(scan_redis, pattern, count, callback)

	local nodes = scan_redis.cluster_redis
	if not nodes then
		nodes = {}
		local node = {}
		node.redis = scan_redis
		table.insert(nodes, node)
	end

	for i = 1, #nodes do
		local node = nodes[i]
		local r = node.redis

		local index = 0 
		local iter = scan(r, pattern, count)
		while true do
			local eof, keys = iter()
			for i = 1, #keys do
				index = index + 1 
				local key = keys[i]
				if callback(key, index) then
					eof = true
					break
					--return
				end 
			end 

			if eof then
				break
			end 
		end 
	end
end

local function logic()

	local function print_slots_key(key, count)
		print("wingclearkey", key, count)
		if activity_redis:del(key) == 1 then
			print("wingclearkeyok", key, count)
		end
		return
	end

	scan_callback(activity_redis, "dpzj:slots:*", 1000, print_slots_key)

	local max_id = 4470000
	--local max_id = 100001
	for account = 100001, max_id do
		local k = "dpzj:activity_data:" .. account
		local count = activity_redis:hdel(k, "slots_revives", "slots_score")
		if count > 0 then
			print("wingdelactivity", account, count)
		end
	end
end

local ok, err = pcall(logic)
if not ok then
	print(err)
else
	print("执行完毕!", time.date(os.time()))
end


redis:quit()
activity_redis:quit()
