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

	--[[
	local info = _G.debug.getinfo(2, "Sl")
	local file = info and info.short_src or "unknown"
	local line = info and info.currentline or 0

	local now = os.time()
	local datestr = time.date(now)
	sys_print(datestr, file .. ":" .. line, ...)
	--]]
	sys_print(...)
	io.flush()
end


function get_data()

	local data = {}

	local file = cutil.open("/logdata/2021-03-14/coins.log")
	if not file then
		return
	end

	while true do
		local content = cutil.line(file)
		if not content then
			break
		end

		--1   2002    2002    610048  Tonim Marcos    0   1406800 1406800 金币场带出  1615690800  21010800002346  truco
		--0   2002    2002    362359  Ueverton Santos 2012336 2012336 0   金币场带入  1615690800  21010800001951  truco
		local values = util.split(content, "\t")
		local source = values[9]
		if source == "金币场带入" or source == "金币场带出" then
			local account = tonumber(values[4])
			local change = values[7]
			local change_time = tonumber(values[8])
			local unique_room_id = tonumber(values[11])

			local info = data[unique_room_id]
			if not info then
				info = {}
				data[unique_room_id] = info
			end

			local account_info = info[account]
			if not account_info then
				account_info = {}
				info[account] = account_info
			end

			local obj = {}
			obj.account = account
			obj.change = change
			obj.source = source
			obj.change_time = change_time
			table.insert(account_info, obj)
		end

	end

	for unique_room_id, info in pairs(data) do
		for account, account_info in pairs(info) do
			local len = #account_info
			local last_obj = account_info[len]
			local last_source = last_obj.source
			local last_change = last_obj.change
			if last_source == "金币场带入" then
				print(unique_room_id, account, last_change)
			end
		end
	end
end


function logic()

	get_data()
end

local ok, err = pcall(logic)
if not ok then
	print(err)
else
	print("执行完毕!")
end

conn:close()
env:close()
