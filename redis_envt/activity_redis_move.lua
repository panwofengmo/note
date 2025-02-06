package.path = package.path .. ';luasocket/?.lua'
package.cpath = package.cpath .. ';luasocket/?.so'

local sys_print = print
local print = nil

local cjson = require("cjson")
require("redis")
require("util")
require("time")

local source_redis_host = "pt.pwft0z.clustercfg.use1.cache.amazonaws.com"
local source_redis_port = 6379
local source_redis_pwd = ""

local source_redis = Redis.connect(source_redis_host, source_redis_port)
if source_redis_pwd and source_redis_pwd ~= '' then
	source_redis:auth(source_redis_pwd)
end

local target_redis_host = "pt-activity.pwft0z.clustercfg.use1.cache.amazonaws.com"
local target_redis_port = 6379
local target_redis_pwd = ""

local target_redis = Redis.connect(target_redis_host, target_redis_port)
if target_redis_pwd and target_redis_pwd ~= '' then
	target_redis:auth(target_redis_pwd)
end

function print(...)

	local info = _G.debug.getinfo(2, "Sl")
	local file = info and info.short_src or "unknown"
	local line = info and info.currentline or 0

	sys_print(file .. ":" .. line, time.date(os.time()), ...)
	io.flush()
end


local handle_index = tonumber(arg[1]) or 0
local handle_max = tonumber(arg[2]) or 0

local function logic()

	if handle_index <= 0 or handle_max <= 0 then
		return
	end

	print("执行开始!")

	--[[
	if handle_index == 1 then
		local global_temp_data_key = "dpzj:activity_data:global_temp_data"
		local global_temp_data = source_redis:hgetall(global_temp_data_key)
		if global_temp_data then
			for key, value in pairs(global_temp_data) do
				print("global_temp_data", key)
				--target_redis:hset(global_temp_data_key, key, value)
			end
			--source_redis:del(global_temp_data_key)
		end
	end

	handle_index = handle_index == handle_max and 0 or handle_index

	local max_id = 1831507
	local count = 0
	for i = 100001, max_id do
		local account = i
		if account % handle_max == handle_index then
			count = count + 1

			local ac_data_key = "dpzj:activity_data:" .. account
			local ac_data = source_redis:hgetall(ac_data_key)
			if ac_data then
				for key, value in pairs(ac_data) do
					--target_redis:hset(ac_data_key, key, value)
				end
				--source_redis:del(ac_data_key)
			end

			if count % 1000 == 0 then
				print("当前进度", count)
			end
		end
	end
	--]]

	print("logic执行完毕!")
end

local ok, err = pcall(logic)
if not ok then
	print(err)
else
	print("执行完毕!")
end

source_redis:quit()
target_redis:quit()
