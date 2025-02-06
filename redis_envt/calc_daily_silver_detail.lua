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
local db_addr = "pt-game-main.cluster-ro-cxanuay0huhb.us-east-1.rds.amazonaws.com"
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

date = arg[1]

function logic()

	local map = {}

	local file = cutil.open("/logdata/" .. date .. "/silver.log")
	if not file then
		return
	end

	while true do
		local content = cutil.line(file)
		if not content then
			break
		end
		local values = util.split(content, "\t")
		local id = tonumber(values[4])
		local silver = tonumber(values[6])
		if not map[id] then
			--print("log", id, silver)
			map[id] = silver
		end
	end
	cutil.close(file)

	local sql = "select id,silver from tbl_user where silver>0"
	local cur = conn:execute(sql)
	local row = cur:fetch({}, "a")
	while row do
		local id = tonumber(row.id)
		local silver = tonumber(row.silver)
		if not map[id] then
			map[id] = silver
		end
		--print("db", id, silver)
		row = cur:fetch({}, "a")
	end
	cur:close()

	local t = 0
	local total = bigint_new()
	for id, silver in pairs(map) do
		t = t + silver
		total = bigint_add(total, silver)
		sys_print(id, silver)
	end
	sys_print("total", string.format("%s", bigint_tostring(total)), t)
end

local ok, err = pcall(logic)
if not ok then
	print(err)
else
	print("执行完毕!")
end

conn:close()
env:close()
