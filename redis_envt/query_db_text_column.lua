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
local db_addr = "pt-game-log.cluster-ro-cxanuay0huhb.us-east-1.rds.amazonaws.com"
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

	local cur = conn:execute("show tables")
	local row = cur:fetch({}, "a")
	while row do
		for _, v in pairs(row) do
			local create_sql_cur = conn:execute("show create table " .. v)
			local create_sql_row = create_sql_cur:fetch({}, "a")
			local tb = create_sql_row["Table"]
			local cb = string.upper(create_sql_row["Create Table"])
			if string.find(cb, "TEXT") or string.find(cb, "BLOB") then
				print(tb)
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
