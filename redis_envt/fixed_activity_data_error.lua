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

local redis_host = "pt-activity.pwft0z.clustercfg.use1.cache.amazonaws.com"
local redis_port = 6379
local redis_pwd = ""

local redis = Redis.connect(redis_host, redis_port, redis_pwd, true, true)

function print(...)

	local info = _G.debug.getinfo(2, "Sl")
	local file = info and info.short_src or "unknown"
	local line = info and info.currentline or 0

	sys_print(file .. ":" .. line, ...)
	io.flush()
end

function scan(pattern, count)

	local cursor = 0 
	return function()
		local response = redis:scan(cursor, {["match"] = pattern, ["count"] = count})
		local next_cursor = tonumber(response[1])
		local keys = response[2]
		cursor = next_cursor

		return cursor == 0, keys
	end 
end

function scan_callback(pattern, count, callback)

	local index = 0 
	local iter = scan(pattern, count)
	while true do
		local eof, keys = iter()
		for i = 1, #keys do
			index = index + 1 
			local key = keys[i]
			if callback(key, index) then
				eof = true
				break
			end 
		end 

		if eof then
			break
		end 
	end 
end

local function logic()

	for i = 100001, 6824551 do
		if i % 1000 == 0 then
			print("当前进度", i)
		end
		local key = "dpzj:silver_bet_bonus_data:" .. i
		local real_0 = redis:hdel(key, "real_0")
		local real_58_0 = redis:hget(key, "real_58_0")
		if real_58_0 and real_58_0 ~= "" then
			local json = cjson.decode(real_58_0)
			local room_type = json["room_type"] or 0
			if room_type == 0 then
				room_type = 58
				json["room_type"] = room_type
				local v = cjson.encode(json)
				redis:hset(key, "real_58_0", v)
				print("fixed real_58_0", i, v)
			end
		end

		local real_58_1 = redis:hget(key, "real_58_1")
		if real_58_1 and real_58_1 ~= "" then
			local json = cjson.decode(real_58_1)
			local room_type = json["room_type"] or 0
			if room_type == 0 then
				room_type = 58
				json["room_type"] = room_type
				local v = cjson.encode(json)
				redis:hset(key, "real_58_1", v)
				print("fixed real_58_1", i, v)
			end
		end
	end
	--local function print_keys(key, count)
	--	print("aaaa", key, count)
	--end

	--scan_callback("dpzj:silver_bet_bonus_data:*", 1000, print_keys)
end

local ok, err = pcall(logic)
if not ok then
	print(err)
else
	print("执行完毕!", time.date(os.time()))
end


redis:quit()
