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

local redis_host = "pt-cache.pwft0z.ng.0001.use1.cache.amazonaws.com"
local redis_port = 6379
local redis_pwd = ""

local redis = Redis.connect(redis_host, redis_port)
if redis_pwd and redis_pwd ~= '' then
	redis:auth(redis_pwd)
end

local ro_redis_host = "pt-cache-ro.pwft0z.ng.0001.use1.cache.amazonaws.com"
local ro_redis_port = 6379
local ro_redis_pwd = ""

local ro_redis = Redis.connect(ro_redis_host, ro_redis_port)
if ro_redis_pwd and ro_redis_pwd ~= '' then
	ro_redis:auth(ro_redis_pwd)
end

function print(...)

	local info = _G.debug.getinfo(2, "Sl")
	local file = info and info.short_src or "unknown"
	local line = info and info.currentline or 0

	sys_print(file .. ":" .. line, ...)
end

function scan(pattern, count)

	local cursor = 0 
	return function()
		local response = ro_redis:scan(cursor, {["match"] = pattern, ["count"] = count})
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

	local function print_coin_rooms_key(key, count)
		local rooms = ro_redis:zrange(key, 0, -1)
		for i = 1, #rooms do
			local room_id = tonumber(rooms[i])
			local unique_room_id = tonumber(ro_redis:hget("cache:info:rooms:" .. room_id, "unique_room_id")) or 0
			if unique_room_id > 0 then
				--print("room info right", key, room_id, unique_room_id)
			else
				print("room info error", key, room_id, unique_room_id)
				redis:zrem(key, room_id)
			end
			--[[
			if room_id > 100000000 then
				print("clear room", key, rooms[i])
				redis:zrem(key, room_id)
			elseif room_id < 1000000 then
				print("error room", key, rooms[i])
			end
			--]]
		end
		return
	end

	scan_callback("cache:coin_rooms:*", 1000, print_coin_rooms_key)
end

local ok, err = pcall(logic)
if not ok then
	print(err)
else
	print("执行完毕!", time.date(os.time()))
end


redis:quit()
ro_redis:quit()
