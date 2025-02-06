package.path = package.path .. ';luasocket/?.lua'
package.cpath = package.cpath .. ';luasocket/?.so'

local sys_print = print
local print = nil

local cjson = require("cjson")
local cjson_map = cjson:new()
cjson_map.encode_sparse_array(true, 1, 1)

require("util")
require("time")
require("cutil")


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

	local file = cutil.open("/root/redis_envt/silver_0214.log")
	if not file then
		return
	end

	while true do
		local content = cutil.line(file)
		if not content then
			break
		end

		--0       2002    2002    1411088 wilson borges   162850  40800   122050  22021400006234  自由场带入domino        1644892313      0
		--0       2002    2002    1411088 wilson borges   123010  123010  0       22021400006234  自由场rebuydomino       1644893774      0
		--0       2002    2002    1411088 wilson borges   480     480     0       22021400006234  自由场rebuydomino       1644893942      0
		--1       2002    2002    894546  lucas promotor  2068    0       2068    22021400013080  自由场带出poker 1644893953      0
		local values = util.split(content, "\t")

		local tg = tonumber(values[1])
		local account = tonumber(values[4])
		local change = values[7]
		local unique_room_id = tonumber(values[9])
		local source = values[10]
		local change_time = tonumber(values[11])
		if change_time < time.time("2022-02-14 04:30:00") then
			--print(account, change, unique_room_id, source, time.date(change_time))

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
			obj.tg = tg
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
			local last_tg = last_obj.tg
			if last_tg == 0 then
				--print(unique_room_id, account, last_change, last_source)
			    --[
			    if len > 1 then
			        --print(len, unique_room_id, cjson.encode(last_info))
			        local change = 0
			        for i = len, 1, -1 do
			            local inf = account_info[i]
			            local t = inf.tg
			            local ch = inf.change
			            local s = inf.source
			            if t == 1 then
			                break
			            end
			            
			            change = change + ch
			            --print("===", i, unique_room_id, account, change, ch, s, t, time.date(inf.change_time))
			        end
					--print(unique_room_id, account, last_change, last_source)
					print(unique_room_id, account)
			    else
					--print(unique_room_id, account, last_change, last_source)
					print(unique_room_id, account)
			    end
			    --]]
			
			else
			    --if len % 2 ~= 0 then
				--	print("---", unique_room_id, account, last_change, last_source, cjson.encode(account_info))
			    --end
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
