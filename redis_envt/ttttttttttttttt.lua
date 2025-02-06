package.path = package.path .. ';luasocket/?.lua'
package.cpath = package.cpath .. ';luasocket/?.so'

local time = require("time")
local cjson = require("cjson")
require("util")
require("cutil")
require("redis")

function split(str, delimiter)

	if str == nil or str == '' or delimiter == nil then
		return nil
	end

	local result = {}
	for match in (str..delimiter):gmatch("(.-)"..delimiter) do
		table.insert(result, match)
	end

	return result
end

function get_room_unique_room_id(path)

	local map = {}

	local file = cutil.open(path)
	if file then
		while true do
			local content = cutil.line(file)
			if not content then
				break
			end

			local id = tonumber(content)
			map[id] = true
		end
	end

	return map
end

-- local unique_room_ids = get_room_unique_room_id("room_unique_id_20230507.log")
local start_time = time.time('2023-10-19 00:00:00')
local end_time = time.time('2023-10-19 04:40:01')

function check_coin_log(path, account_map)

	local map = {}

	local file = cutil.open(path)
	if file then
		while true do
			local content = cutil.line(file)
			if not content then
				break
			end
			local values = util.split(content, "\t")
			local account = tonumber(values[4])

			if not account_map or (account_map and account_map[account]) then 
				local tg = tonumber(values[1])
				local change = tonumber(values[7])
				local source = values[9]
				local log_time = tonumber(values[10])
				local unique_room_id = tonumber(values[11])
				if source and string.find(source, "金币场带", 1, true) and log_time >= start_time and log_time <= end_time then
					local obj = map[account]
					if not obj then
						obj = {}
						map[account] = obj
					end

					local info = obj[unique_room_id]
					if not info then
						info = {}
						obj[unique_room_id] = info
					end

					table.insert(info, {tg, account, change, source, log_time, unique_room_id})
				end
			end
		end
	end

	for account, obj in pairs(map) do
		for unique_room_id, info in pairs(obj) do
			local last_info = info[#info]
			local tg = last_info[1]
			if tg == 0 then
				if #info > 1 then
					for i = #info, 1, -1 do
						local o = info[i]
						local t = o[1]
						local c = o[3]
						local source = o[4]
						if t == 1 then
							break
						end
						print(account, unique_room_id, c, source)
					end
				else
					local change = last_info[3]
					local source = last_info[4]
					print(account, unique_room_id, change, source)
				end
			end
		end
	end
end
check_coin_log("/logdata/2023-10-19/coins.log")


function check_cc_log(path, account_map)

	local map = {}

	local file = cutil.open(path)
	if file then
		while true do
			local content = cutil.line(file)
			if not content then
				break
			end
			local values = util.split(content, "\t")
			local club_id = tonumber(values[1])
			local account = tonumber(values[3])

			if not account_map or (account_map and account_map[account]) then 
				local change = tonumber(values[5])
				local source = values[7]
				local log_time = tonumber(values[8])
				local unique_room_id = tonumber(values[9])
				if string.find(source, "带", 1, true) and log_time >= start_time and log_time <= start_time and (not unique_room_ids or (unique_room_ids[unique_room_id])) then
					local obj = map[account]
					if not obj then
						obj = {}
						map[account] = obj
					end

					local info = obj[unique_room_id]
					if not info then
						info = {}
						obj[unique_room_id] = info
					end

					table.insert(info, {tg, account, change, source, log_time, unique_room_id, club_id})
				end
			end
		end
	end

	for account, obj in pairs(map) do
		for unique_room_id, info in pairs(obj) do
			local last_info = info[#info]
			local change = last_info[3]
			if change < 0 then
				if #info > 1 then
					for i = #info, 1, -1 do
						local o = info[i]
						local c = o[3]
						local source = o[4]
						local log_time = o[5]
						local club_id = o[7]
						if c >= 0 then
							break
						end
						--print(account, unique_room_id, c, source, log_time, time.date(log_time))
						print(club_id, account, unique_room_id, -c, source)
					end
				else
					local source = last_info[4]
					local log_time = last_info[5]
					local club_id = last_info[7]
					--print(account, unique_room_id, change, source, log_time, time.date(log_time))
					print(club_id, account, unique_room_id, -change, source)
				end
			end
		end
	end
end
--check_cc_log("/logdata/2023-05-07/account_cc.log")


function check_silver_log(path, account_map)

	local map = {}

	local file = cutil.open(path)
	if file then
		while true do
			local content = cutil.line(file)
			if not content then
				break
			end
			local values = util.split(content, "\t")
			if values then
				local account = tonumber(values[4])

				if not account_map or (account_map and account_map[account]) then 
					local tg = tonumber(values[1])
					local change = tonumber(values[7])
					local source = values[10]
					local log_time = tonumber(values[11])
					local unique_room_id = tonumber(values[9])
					if source and string.find(source, "带", 1, true) and log_time >= start_time and log_time <= end_time then
						local obj = map[account]
						if not obj then
							obj = {}
							map[account] = obj
						end

						local info = obj[unique_room_id]
						if not info then
							info = {}
							obj[unique_room_id] = info
						end

						table.insert(info, {tg, account, change, source, log_time, unique_room_id})
					end
				end
			end
		end
	end

	for account, obj in pairs(map) do
		for unique_room_id, info in pairs(obj) do
			local last_info = info[#info]
			local tg = last_info[1]
			if tg == 0 then
				if #info > 1 then
					for i = #info, 1, -1 do
						local o = info[i]
						local t = o[1]
						local c = o[3]
						local source = o[4]
						if t == 1 then
							break
						end
						print(account, unique_room_id, c, source)
					end
				else
					local change = last_info[3]
					local source = last_info[4]
					print(account, unique_room_id, change, source)
				end
			end
		end
	end
end
check_silver_log("/logdata/2023-10-19/silver.log")
