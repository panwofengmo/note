package.path = package.path .. ';/home/mj/other/?.lua'
package.path = package.path .. ';luasocket/?.lua'
package.cpath = package.cpath .. ';luasocket/?.so'

local sys_print = print
local print = nil

require("redis")
require("util")
require("time")
local cjson = require("cjson")
local cjson_map = cjson:new()
cjson_map.encode_sparse_array(true, 1, 1)

if not unpack and string.unpack then
	unpack = table.unpack
end

local redis_host = "192.168.61.241"
local redis_port = 6479
local redis_pwd = ""

local redis = Redis.connect(redis_host, redis_port, redis_pwd, true, true)

function print(...)

	local info = _G.debug.getinfo(2, "Sl")
	local file = info and info.short_src or "unknown"
	local line = info and info.currentline or 0

	sys_print(file .. ":" .. line, ...)
	io.flush()
end

--修改损失开始
local function new_set_temp_attr(id, str_attr, o_val, int_delay_time, bool_flush)

	if int_delay_time < 0 then
		return
	end

	local now = os.time()
	local str_save_key = "dpzj:temp_attr:" .. id
	local str_time_attr = string.format("THEAD_%s", str_attr)
	local int_time_end = tonumber(redis:hget(str_save_key, str_time_attr))

	if not int_time_end or now > int_time_end or bool_flush then
		redis:hmset(str_save_key, str_attr, cjson.encode(o_val), str_time_attr, now + int_delay_time)
	else
		redis:hset(str_save_key, str_attr, cjson.encode(o_val))
	end
end

local function new_get_temp_attr(id, str_attr)

	local now = os.time()
	local str_save_key = "dpzj:temp_attr:" .. id
	local str_time_attr = string.format("THEAD_%s", str_attr)

	local tab_infos = redis:hmget(str_save_key, str_attr, str_time_attr)
	local str_val = tab_infos[1]
	local int_time_end = tonumber(tab_infos[2])
	local o_val
	if int_time_end then
		if int_time_end > now then
			if str_val and str_val ~= "" then
				o_val = cjson.decode(str_val)
			end
		else
			redis:hdel(str_save_key, str_attr, str_time_attr)
		end
	end
	return o_val
end

local function json_encode_sparse_array(configs)

	if not configs or type(configs) ~= "table" then
		return ""
	end

	local cjson_temp = cjson:new()
	cjson_temp.encode_sparse_array(true, 1, 1)

	local config_rewards_json = cjson_temp.encode(configs)
	return config_rewards_json or ""
end

local all_silver_info = {}
local function get_activity_time_silver_tab()
	local lines = util.lines_of("./silver.log", "\n", true)
	for i = 1, #lines do
		local tmp = util.split(lines[i], "\t")
		local login_channel = tonumber(tmp[3]) or 0
		local account = tonumber(tmp[4]) or 0
		local add_count = tonumber(tmp[7]) or 0
		local int_process = new_get_temp_attr(account, "DV_1197_bonus_process") or 0
		if login_channel == 2006 and account ~= 0 and add_count > 0 and int_process == 0 then
			local count = all_silver_info[account] or 0
			count = count + add_count
			all_silver_info[account] = count
		end
	end
end

local function write_activity_time_silver_tab()
	local count = 0
	local str = ""
	for account, v in pairs(all_silver_info) do
		count = count + 1
		str = str..", "..account
		if count == 10 then
			util.write("playerList.txt", str)
			count = 0
			str = ""
		end
	end
end

local function fix_task_handle()
	local tab_task = {
		[1] = {28102, 0, 0},
		[2] = {28103, 0, 0},
		[3] = {28104, 0, 0},
	}
	local tab_taskid = {
		28102, 28103, 28104
	}
	for account, int_silver in pairs(all_silver_info) do
		for i, v in pairs(tab_taskid) do
			local tab_task = {
				v, cjson.encode({v, int_silver, 0})
			}
			local task_key = "dpzj:task_dv:" .. account
			redis:hmset(task_key, unpack(tab_task))
		end
		new_set_temp_attr(account, "DV_1197_bonus_process", int_silver, time.time("2024-12-27") - os.time())
	end
end
--修改损失结束

local function logic()
	--test_redis()
	--test_mysql()
	get_activity_time_silver_tab()
	write_activity_time_silver_tab()
	--fix_task_handle()
end

local ok, err = pcall(logic)
if not ok then
	print(err)
else
	print("执行完毕!", time.date(os.time()))
end

redis:quit()
