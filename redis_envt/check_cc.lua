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


function get_data()

	local data = {}

	local file = cutil.open("/logdata/2021-03-14/account_cc.log")
	if not file then
		return
	end

	while true do
		local content = cutil.line(file)
		if not content then
			break
		end

		--133514    0       363043  39      -10     29      牌局带入        1615763833      21031400005587
		local values = util.split(content, "\t")
		local unique_room_id = tonumber(values[9])
		if unique_room_id > 0 then
			local club_id = tonumber(values[1])
			local account = tonumber(values[3])
			local change = values[5]
			local source = values[7]
			local change_time = tonumber(values[8])

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
			obj.club_id = club_id
			obj.account = account
			obj.change = change
			obj.source = source
			obj.change_time = change_time
			table.insert(account_info, obj)
		end

	end

	for unique_room_id, info in pairs(data) do
		local count = 0
		for account, account_info in pairs(info) do
			for i = 1, #account_info do
				local obj = account_info[i]
				local change = obj.change
				count = count + change
			end
		end

		if count ~= 0 then
			print(unique_room_id)
			for account, account_info in pairs(info) do
				local c = 0
				local club_id = 0
				for i = 1, #account_info do
					local obj = account_info[i]

					local account = obj.account
					local change = obj.change
					local source = obj.source
					local change_time = obj.change_time
					c = c + change
					club_id = obj.club_id
					print(unique_room_id, club_id, account, c, source, change)
				end
				print(unique_room_id, club_id, account, c)
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
