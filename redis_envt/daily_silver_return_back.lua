package.path = package.path .. ';luasocket/?.lua'
package.cpath = package.cpath .. ';luasocket/?.so'

local sys_print = print
local print = nil

require("redis")
require("util")
require("time")
require("cutil")

local cjson = require("cjson")

local redis_host = "pt.pwft0z.clustercfg.use1.cache.amazonaws.com"
local redis_port = 6379
local redis_pwd = ""

local redis = Redis.connect(redis_host, redis_port, redis_pwd, true, true)

function print(...)

	local info = _G.debug.getinfo(2, "Sl")
	local file = info and info.short_src or "unknown"
	local line = info and info.currentline or 0

	sys_print(file .. ":" .. line, time.date(os.time()), ...)
	io.flush()
end

-- 发放昨日玩家返利奖励
function reward_yesterday_return_silver(int_upline, int_time_begin)

	local str_redis_key_type = "dpzj:sliver_event:" .. int_upline .. ":collect_silver:" .. int_time_begin

	local tab_event = redis:smembers(str_redis_key_type)
	--redis:del(str_redis_key_type)
	local int_sum_silver = 0
	for i = 1, #tab_event do
		local tab_info = cjson.decode(tab_event[i])
		local int_player_account, int_rake_return, int_silver_event, room_id, int_downline, int_send_time, str_addition_remark = unpack(tab_info)
		int_sum_silver = int_sum_silver + int_rake_return
	end
	if int_sum_silver > 0 then
		--add_silver_event(0, int_upline, int_sum_silver, 7, 0)
		sys_print(int_upline, int_sum_silver)
		io.flush()
	end
end

local function logic()

	local int_time_begin = time.begin(os.time() - 86400)
	print(int_time_begin)
	local str_redis_key_type = "dpzj:sliver_event:collect_silver:member" .. int_time_begin
	local tab_member = redis:smembers(str_redis_key_type)
	--redis:del(str_redis_key_type)
	for i = 1, #tab_member do
		local int_upline = tonumber(tab_member[i]) or 0
		if int_upline > 0 then
			reward_yesterday_return_silver(int_upline, int_time_begin)
		end
	end
end

local ok, err = pcall(logic)
if not ok then
	print(err)
else
	print("执行完毕!")
end

redis:quit()
