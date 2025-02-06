package.path = package.path .. ';luasocket/?.lua'
package.cpath = package.cpath .. ';luasocket/?.so'

local sys_print = print
local print = nil

local luasql = require("luasql.mysql")

require("redis")
require("util")
require("time")
require("cutil")

local db_name = "dpzj"
local db_user = "root"
local db_pwd = "Aidian927"
local db_addr = "pt-game-main.cluster-cxanuay0huhb.us-east-1.rds.amazonaws.com"
local db_port = 3306

local env = luasql.mysql()
local conn = env:connect(db_name, db_user, db_pwd, db_addr, db_port)
conn:execute("set names utf8mb4")

function print(...)

	local info = _G.debug.getinfo(2, "Sl")
	local file = info and info.short_src or "unknown"
	local line = info and info.currentline or 0

	local now = os.time()
	local datestr = time.date(now)
	sys_print(datestr, file .. ":" .. line, ...)
	io.flush()
end

function bigint_new()

	local t = {}
	t[0] = 0
	t[1] = 0

	return t
end

function bigint_add(bg_ori, v)

	local bg = bigint_new()

	local add_low = v
	local add_high = 0
	if type(v) == "table" then
		add_low = v[0]
		add_high = v[1]
	end

	local low = bg_ori[0]
	local high = bg_ori[1]

	local total = low + add_low
	local sign = total > 0 and 1 or -1
	local num = 10000000000
	local l = total
	local h = 0
	if total >= num or total <= -num then
		total = math.abs(total)
		l = (total % num) * sign
		local num_str = tostring(num)
		local total_str = tostring(total)
		h = string.sub(total_str, 0, #total_str - #num_str + 1)
		h = tonumber(h) * sign
	end
	low = l
	high = high + h + add_high

	if low < 0 and high > 0 then
		high = high - 1
		low = low + num
	end

	if low > 0 and high < 0 then
		high = high + 1
		low = low - num
	end

	bg[0] = low
	bg[1] = high

	return bg
end

function bigint_sub(bg_ori, v)

	if type(v) == "table" then
		local bg = bigint_new()
		bg[0] = 0 - v[0]
		bg[1] = 0 - v[1]
		return bigint_add(bg_ori, bg)
	end
	
	return bigint_add(bg_ori, -v)
end

function bigint_tostring(bigint)

	local low = bigint[0]
	local high = bigint[1]

	local str = nil
	if high == 0 then
		str = tostring(low)
	else
		str = string.format("%d%010d", high, math.abs(low))
	end
	return str
end

--支持夏令时
function add_days_dst(t, days)

	local tab = os.date("*t", t)
	tab.day = tab.day + days
	tab.isdst = nil

	return os.time(tab)
end

--before为true时向前推出更早之前的数据
function get_day_after(date, before)

	if date == "2021-01-07" and before then
		local bg = bigint_new()
		bg = bigint_add(bg, 115722074)
		return bg
	end
	local date_time = time.time(date)

	local field = nil
	local query_date = nil
	if before then
		field = "origin"
		query_date = add_days_dst(date_time, 1)
	else
		field = "last"
		query_date = add_days_dst(date_time, -1)
	end

	local sql = string.format("select %s from daily_coin_details where date='%s' limit 1", field, time.date(query_date, true))

	local v = nil

	local cur = conn:execute(sql)
	local row = cur:fetch({}, "a")
	if row then
		v = tonumber(row[field])
	end

	cur:close()

	if not v then
		error("无法推算当前日期的数据:" .. date)
	end

	local bg = bigint_new()
	bg = bigint_add(bg, v)

	return bg
end

function one_day(date, before)

	local bg_origin = get_day_after(date, before)

	local file = cutil.open("/logdata/" .. date .. "/coins.log")
	if not file then
		return
	end

	local bg_add = bigint_new()
	local bg_use = bigint_new()

	local inout = bigint_new()

	while true do
		local content = cutil.line(file)
		if not content then
			break
		end

		local values = util.split(content, "\t")
		--0消耗;1增加
		local type = tonumber(values[1])
		local id = tonumber(values[4])
		local change = tonumber(values[7])
		local source = values[9]
		if source ~= "分销商发放金币扣除" and source ~= "分销商发放金币获得" then
			if type == 0 then
				if string.find(source, "带入") then
					inout = bigint_sub(inout, change)
				else
					bg_use = bigint_add(bg_use, change)
				end
			else
				if string.find(source, "带出") then
					inout = bigint_add(inout, change)
				else
					bg_add = bigint_add(bg_add, change)
				end
			end
		end
	end

	--[[
	if inout[0] > 0 and inout[1] > 0 then
		bg_add = bigint_add(bg_add, inout)
	else
		bg_use = bigint_sub(bg_use, inout)
	end
	--]]
	bg_use = bigint_sub(bg_use, inout)

	local bg_last = bigint_new()

	if before then
		bg_last = bg_origin
		bg_origin = bigint_new()
		bg_origin = bigint_add(bg_origin, bg_last)
		bg_origin = bigint_add(bg_origin, bg_use)
		bg_origin = bigint_sub(bg_origin, bg_add)
	else
		bg_last = bigint_add(bg_last, bg_origin)
		bg_last = bigint_add(bg_last, bg_add)
		bg_last = bigint_sub(bg_last, bg_use)
	end

	print(date, bigint_tostring(bg_origin), bigint_tostring(bg_add), bigint_tostring(bg_use), bigint_tostring(bg_last), bigint_tostring(inout))

	local sql = string.format("insert into daily_coin_details(`date`, `origin`, `add`, `use`, `last`) values('%s', %s, %s, %s, %s)", date, bigint_tostring(bg_origin), bigint_tostring(bg_add), bigint_tostring(bg_use), bigint_tostring(bg_last))
	local status, msg = conn:execute(sql)
	if msg then
		error(msg)
	end
end

begin_date = arg[1]
end_date = arg[2]

function logic()

	local today = time.date(os.time(), true)
	local yesterday = time.date(add_days_dst(time.time(today), -1), true)

	local date = util.is_empty(begin_date) and yesterday or begin_date
	local before_mode = false
	if util.not_empty(begin_date) and util.not_empty(end_date) and time.time(end_date) < time.time(begin_date) then
		before_mode = true
	end
	for i = 1, 60 do
		if not before_mode and date == today then
			break
		end

		print("handle date", date)
		one_day(date, before_mode)

		if before_mode and date == end_date then
			break
		end
		local dt = add_days_dst(time.time(date), before_mode and -1 or 1)
		date = time.date(dt, true)
	end
end

local ok, err = pcall(logic)
if not ok then
	print(err)
else
	print("执行完毕!")
end

conn:close()
env:close()
