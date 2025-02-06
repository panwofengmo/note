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

local function set_scatter4(account, sb, mul_key)

	local free_reels_str = cjson.encode({})
	local repeat_reels_str = cjson.encode({})
	local current_reels = {}
	current_reels.lines_results = {}
	current_reels.accumulated_win = 0
	current_reels.currented_win = 0
	current_reels.reels_results = {7, 11, 8, 13, 8, 13, 8, 10, 7, 7, 14, 2, 13, 6, 13}
	local current_reels_str = cjson.encode(current_reels)

	local kvs = {}
	table.insert(kvs, "scatters_coming")
	table.insert(kvs, 1)
	table.insert(kvs, "respins_coming")
	table.insert(kvs, 0)
	table.insert(kvs, "free_spins")
	table.insert(kvs, 0)
	table.insert(kvs, "free_reels")
	table.insert(kvs, free_reels_str)
	table.insert(kvs, "repeat_spins")
	table.insert(kvs, 0)
	table.insert(kvs, "repeat_reels")
	table.insert(kvs, repeat_reels_str)
	table.insert(kvs, "current_reels")
	table.insert(kvs, current_reels_str)
	table.insert(kvs, "free_length")
	table.insert(kvs, 15)
	table.insert(kvs, "repeat_length")
	table.insert(kvs, 7)
	table.insert(kvs, "windfall_profit")
	table.insert(kvs, 0)
	table.insert(kvs, "user_oper")
	table.insert(kvs, 3)
	table.insert(kvs, "mul_key")
	table.insert(kvs, mul_key)
	table.insert(kvs, "scatter_count")
	table.insert(kvs, "4")
	
	local slots_desktop_inning_key = string.format("dpzj:slots:data:%s:2:%s:details", account, sb) 
	redis:hdel(slots_desktop_inning_key, "rs_map_idx")
	redis:hmset(slots_desktop_inning_key, unpack(kvs))
end

local function set_scatter5(account, sb, mul_key)

	local free_reels_str = cjson.encode({})
	local repeat_reels_str = cjson.encode({})
	local current_reels = {}
	current_reels.lines_results = {}
	current_reels.accumulated_win = 0
	current_reels.currented_win = 0
	current_reels.reels_results = {9, 13, 10, 8, 8, 13, 8, 13, 13, 7, 9, 3, 9, 7, 13}
	local current_reels_str = cjson.encode(current_reels)

	local kvs = {}
	table.insert(kvs, "scatters_coming")
	table.insert(kvs, 1)
	table.insert(kvs, "respins_coming")
	table.insert(kvs, 0)
	table.insert(kvs, "free_spins")
	table.insert(kvs, 0)
	table.insert(kvs, "free_reels")
	table.insert(kvs, free_reels_str)
	table.insert(kvs, "repeat_spins")
	table.insert(kvs, 0)
	table.insert(kvs, "repeat_reels")
	table.insert(kvs, repeat_reels_str)
	table.insert(kvs, "current_reels")
	table.insert(kvs, current_reels_str)
	table.insert(kvs, "free_length")
	table.insert(kvs, 25)
	table.insert(kvs, "repeat_length")
	table.insert(kvs, 10)
	table.insert(kvs, "windfall_profit")
	table.insert(kvs, 0)
	table.insert(kvs, "user_oper")
	table.insert(kvs, 3)
	table.insert(kvs, "mul_key")
	table.insert(kvs, mul_key)
	table.insert(kvs, "scatter_count")
	table.insert(kvs, "5")
	
	local slots_desktop_inning_key = string.format("dpzj:slots:data:%s:2:%s:details", account, sb) 
	redis:hdel(slots_desktop_inning_key, "rs_map_idx")
	redis:hmset(slots_desktop_inning_key, unpack(kvs))
end

local function logic()

	local fixed_config = {
		-- {3998808, 3000, "50-75", "5"},
		-- {12049854, 1000, "40-50", "4"},
		-- {14529912, 500, "100-200", "5"},
		-- {10840792, 2000, "50-75", "4"},
		--[=[
		{9227191, 100, "50-75", "4"},
		{14848446, 500, "10-20", "4"},
		{13900943, 500, "30-40", "5"},
		{5136251, 500, "10-20", "4"},
		{10797911, 500, "20-30", "5"},
		{4057587, 1000, "10-20", "4"},
		{2747234, 1000, "10-20", "4"},
		{6966659, 3000, "10-20", "4"},
		{234619, 20000, "30-40", "4"},
		{14746261, 500, "10-20", "4"},
		{14263781, 500, "30-40", "5"},
		{13081752, 1000, "10-20", "4"},
		{9880359, 30000, "30-40", "5"},
		{9803969, 1000, "50-75", "5"},
		{7953027, 100, "10-20", "4"},
		--]=]
		{14546642, 500, "10-20", "4"},
	}

	for i = 1, #fixed_config do
		local obj = fixed_config[i]
		local account = tonumber(obj[1])
		local sb = tonumber(obj[2])
		local mul_key = obj[3]
		local scatter_count = obj[4]
		if scatter_count == "4" then
			set_scatter4(account, sb, mul_key)
		elseif scatter_count == "5" then
			set_scatter5(account, sb, mul_key)
		end
		print(account, sb, mul_key, scatter_count, "数据修复完成")
	end
end

local ok, err = pcall(logic)
if not ok then
	print(err)
else
	print("执行完毕!", time.date(os.time()))
end

redis:quit()
