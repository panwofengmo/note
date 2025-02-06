package.path = package.path .. ';luasocket/?.lua'
package.cpath = package.cpath .. ';luasocket/?.so'

local sys_print = print
local print = nil

local luasql = require("luasql.mysql")

local time = require("time")
local util = require("util")
local cjson = require("cjson")
require("redis")

local db_name = "dpzj_gamelog"
local db_user = "root"
local db_pwd = "Aidian927"
local db_addr = "pt-game-log.cluster-cxanuay0huhb.us-east-1.rds.amazonaws.com"
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

local function logic()

	local target_partition = 202201

	local cur = conn:execute("show tables")
	local row = cur:fetch({}, "a")
	while row do
		for _, v in pairs(row) do
			local create_sql_cur = conn:execute("show create table " .. v)
			local create_sql_row = create_sql_cur:fetch({}, "a")
			local tb = create_sql_row["Table"]
			local cb = string.upper(create_sql_row["Create Table"])
			local last_p = 0
			local p = string.find(cb, "PARTITION P20", last_p + 1)
			if p then
				last_p = p
			end
			if last_p > 0 then
				local last_partition = tonumber(string.sub(cb, last_p + 11, last_p + 16))
				if target_partition and target_partition > last_partition then
					print("需要清理的分区", tb, last_partition)
				else
					print("分区已经没有低于目标日期", tb)
				end
			else
				print("当前表没有分区信息", tb)
			end
		end
		row = cur:fetch({}, "a")
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
