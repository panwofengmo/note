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

	sys_print(file .. ":" .. line, time.date(os.time()), ...)
	io.flush()
end

local function logic()

	local orders = {}
	local lines = util.lines_of("order.txt", "\n", true)
	for i = 1, #lines do
		local line = lines[i]
		local order_index = string.find(line, "order=")
		local order = string.sub(line, order_index + 6, order_index + 23)

		if not orders[order] then
			orders[order] = true

			local sql = string.format("update recharges set status=1 where order_no='%s'", order)
			local status, msg = conn:execute(sql)
			if msg then
				print("recharge update error", order, status, msg)
			else
				print("recharge success", sql, status, msg)
			end
		end
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
