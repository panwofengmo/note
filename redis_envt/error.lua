package.path = package.path .. ';luasocket/?.lua'
package.cpath = package.cpath .. ';luasocket/?.so'

local time = require("time")
local cjson = require("cjson")
require("util")
require("cutil")
require("redis")

local redis_host = "ph.owfagz.clustercfg.apse1.cache.amazonaws.com"
local redis_port = 6379
local redis_pwd = ""
local redis = Redis.connect(redis_host, redis_port, redis_pwd, true, true)

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

function get_account_map(path)

	local map = {}

	local file = cutil.open(path)
	if file then
		while true do
			local content = cutil.line(file)
			if not content then
				break
			end
			--print(content)

			local account = tonumber(content)
			map[account] = true
		end
	end

	return map
end
--local account_map = get_account_map("/root/usercenter_error_210629.txt")
--local account_map = get_account_map("/root/usercenter_error_210630.txt")
--local account_map = get_account_map("/root/usercenter_error_210701.txt")
--local account_map = get_account_map("/data/pokerclub/tools/usercenter_error_accounts_20220314.txt")

function check_coin_log(path, account_map)

	local map = {}

	local file = cutil.open(path)
	if file then
		while true do
			local content = cutil.line(file)
			if not content then
				break
			end
			--print(content)
			--0      2005    2005    8828587 Salve NZ RE     3685570 3685570 0       金币场带入      1624971568      21062800285682  tongits
			--1      2005    2005    8828587 Salve NZ RE     0       3685570 3685570 金币场带出      1624971568      21062800088264  tongits
			local values = util.split(content, "\t")
			local account = tonumber(values[4])

			if not account_map or (account_map and account_map[account]) then 
				local tg = tonumber(values[1])
				local change = tonumber(values[7])
				local source = values[9]
				local log_time = tonumber(values[10])
				local unique_room_id = tonumber(values[11])
				--if string.find(source, "金币场带", 1, true) and log_time < time.time("2022-04-06 18:00:00") then
				if string.find(source, "排位房间带", 1, true) and log_time < time.time("2022-04-06 18:00:00") then
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
--check_coin_log("/logdata/2022-04-06/coins.log", account_map)

function check_diamond_log1(path)

	local usercenter_count = 40
	local map = {}

	local file = cutil.open(path)
	if file then
		while true do
			local content = cutil.line(file)
			if not content then
				break
			end
			--print(content)
			--0      1005    1005    1268450 kenneth 830     430     400     分销商发放扣除  1625155198      0       2005,2205,13754802
			local values = util.split(content, "\t")
			local account = tonumber(values[4])
			local obj_str = values[12]
			local obj = util.split(obj_str, ",")
			local target_account = tonumber(obj[3])
			local usercenter_index = target_account % usercenter_count + 1
			local log_time = tonumber(values[10])
			--print(account, obj_str, target_account, usercenter_index, time.date(log_time))

			--if usercenter_index == 24 and log_time >= time.time("2021-07-01 21:02:19") and log_time < time.time("2021-07-01 21:42:39") then 
			--if (usercenter_index == 5 or usercenter_index == 7) and log_time >= time.time("2022-03-14 16:10:00") and log_time < time.time("2022-03-14 17:27:00") then 
			if (usercenter_index == 34) and log_time >= time.time("2022-04-06 19:00:00") and log_time < time.time("2022-04-06 23:42:13") then 
				local change = tonumber(values[7])
				local source = values[9]

				local obj = map[target_account]
				if not obj then
					obj = {}
					map[target_account] = obj
				end

				table.insert(obj, {account, change, source, log_time, target_account})
				--print("======", account, change, source, time.date(log_time), log_time, target_account)
				--print(target_account, change)
				--print(account, target_account, change)
			end
		end
	end

	local get_diamond = {}
	for target_account, obj in pairs(map) do
		local diamond = 0
		for i = 1, #obj do
			local info = obj[i]
			local account = info[1]
			local change = info[2]
			local log_time = info[4]

			diamond = diamond + change
			--print(i, account, target_account, change, time.date(log_time), diamond)
		end

		get_diamond[target_account] = diamond
	end

	return get_diamond
end

function check_diamond_log2(path)

	local usercenter_count = 40
	local map = {}

	local file = cutil.open(path)
	if file then
		while true do
			local content = cutil.line(file)
			if not content then
				break
			end
			--print(content)
			--1   2005    2005    12637920    Eduardo Tancio  21  220 241 分销商发放获得  1639200004  0   2005,2205,10507268
			local values = util.split(content, "\t")
			local account = tonumber(values[4])
			local obj_str = values[12]
			local obj = util.split(obj_str, ",")
			local target_account = tonumber(obj[3])
			local usercenter_index = account % usercenter_count + 1
			local log_time = tonumber(values[10])
			--print(account, obj_str, target_account, usercenter_index, time.date(log_time))

			--if usercenter_index == 24 and log_time >= time.time("2021-07-01 21:02:19") and log_time < time.time("2021-07-01 21:42:39") then 
			--if (usercenter_index == 5 or usercenter_index == 7) and log_time >= time.time("2022-03-14 16:10:00") and log_time < time.time("2022-03-14 17:27:00") then 
			if (usercenter_index == 34) and log_time >= time.time("2022-04-06 19:00:00") and log_time < time.time("2022-04-06 23:42:13") then 
				local change = tonumber(values[7])
				local source = values[9]

				local obj = map[account]
				if not obj then
					obj = {}
					map[account] = obj
				end

				table.insert(obj, {account, change, source, log_time, target_account})
				--print("======", account, change, source, time.date(log_time), log_time, target_account)
				--print(target_account, change)
				--print(account, target_account, change)
			end
		end
	end

	local get_diamond = {}
	for account, obj in pairs(map) do
		local diamond = 0
		for i = 1, #obj do
			local info = obj[i]
			local target_account = info[5]
			local change = info[2]
			local log_time = info[4]

			diamond = diamond + change
			--print(i, account, target_account, change, time.date(log_time), diamond)
		end

		get_diamond[account] = diamond
	end

	return get_diamond
end

function check_diamond_log()

	--[root@ip-172-31-23-250 ~]# grep '分销商发放扣除' /logdata/2022-03-14/diamonds.log > franchiser_diamond_kc_20220314.txt
	local get_diamond1 = check_diamond_log1("/root/franchiser_diamond_kc_20220406.txt")
	--[root@ip-172-31-23-250 ~]# grep '分销商发放获得' /logdata/2022-03-14/diamonds.log > franchiser_diamond_hd_20220314.txt
	local get_diamond2 = check_diamond_log2("/root/franchiser_diamond_hd_20220406.txt")

	for account, diamond in pairs(get_diamond1) do
		local get_count = get_diamond2[account] or 0
		local diff = diamond - get_count
		if diff > 0 then
			print(account, diff)
		end
	end
end
--check_diamond_log()

function check_gostar_log(path)

	--local account_map = get_account_map("/root/redis_envt/usercenter_account_ids.txt")
	--local account_map = get_account_map("/data/pokerclub/tools/usercenter_error_accounts_20220314.txt")

	local map = {}

	local file = cutil.open(path)
	if file then
		while true do
			local content = cutil.line(file)
			if not content then
				break
			end
			--print(content)
			--1       2006    2006    12423160        Reynaldo Abellana       92704   3       92707   0       牌局累计奖励    1639205003      系统    俱乐部牌局返利
			--1       2006    2006    12423160        Reynaldo Abellana       92707   30000   122707  0       活动与比赛奖励  1639208891      系统    MTT比赛奖励
			--1       2006    2006    12423160        Reynaldo Abellana       92707   30000   122707  0       活动与比赛奖励  1639208891      系统    MTT比赛奖励
			local values = util.split(content, "\t")
			local account = tonumber(values[4])
			local log_time = tonumber(values[11])

			--if (not account_map or (account_map and account_map[account])) and log_time < time.time("2022-04-06 18:00:00") then
			if not account_map or (account_map and account_map[account]) then
				local tg = tonumber(values[1])
				local start_num = tonumber(values[6])
				local change = tonumber(values[7])
				local end_num = tonumber(values[8])
				local source = values[13]

				local obj = map[account]
				if not obj then
					obj = {}
					map[account] = obj
				end
				--print("---", tg, account, start_num, change, end_num, source, time.date(log_time))

				table.insert(obj, {tg, account, start_num, change, end_num, source, log_time})
			end
		end
	end

	for account, obj in pairs(map) do
		local prev_end_num = nil
		for i = 1, #obj do
			local values = obj[i]

			local start_num = tonumber(values[3])
			local change = tonumber(values[4])
			local end_num = tonumber(values[5])
			local source = values[6] or ""
			local log_time = tonumber(values[7])
			--print("===", account, prev_end_num, start_num, change, end_num, source, time.date(log_time))

			if not prev_end_num then
				prev_end_num = end_num
			else
				if prev_end_num ~= start_num then
					--print(account, prev_end_num, start_num, change, end_num, source)
					--print(account, prev_end_num - start_num)
					print(account, (prev_end_num - start_num) / 100)
				end
				prev_end_num = end_num
			end

		end
	end
end
--check_gostar_log("/logdata/2022-03-14/cashs.log")
--check_gostar_log("/logdata/2022-04-06/cashs.log")

function check_cc_log(path, account_map)

	local map = {}

	local file = cutil.open(path)
	if file then
		while true do
			local content = cutil.line(file)
			if not content then
				break
			end
			--print(content)
			--514491  0   3493186 923 -920    3   牌局带入    1649238127  22040600776110
			--853225  0   15457669    0   126 126 color_game带出  1649238129  22032900443788
			--251098  0   36046217    595 150 745 牌局带出    1649238129  22040600753462
			local values = util.split(content, "\t")
			local club_id = tonumber(values[1])
			local account = tonumber(values[3])

			if not account_map or (account_map and account_map[account]) then 
				local change = tonumber(values[5])
				local source = values[7]
				local log_time = tonumber(values[8])
				local unique_room_id = tonumber(values[9])
				if string.find(source, "带", 1, true) and log_time < time.time("2022-04-06 18:00:00") then
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
--check_cc_log("/logdata/2022-04-06/account_cc.log", account_map)

function check_cgl_log(path)

	local map = {}

	local file = cutil.open(path)
	if file then
		while true do
			local content = cutil.line(file)
			if not content then
				break
			end
			--print(content)
			--info_2022-04-06.9.log:2022-04-06 00:02:17 [140555914358976] INFO  [/home/wing/workspace/dpzj/code_new/core/lua/lua_envt.cpp:28]- ./script/roomsvr/process.lua:4359      color_game自动滚动成功  8005004 883462  8553930 22012000143760  55      5       10      5       20      60      637685  24500500        {"yellow":5}    ["blue","yellow","green"]       nil
			local infos = util.split(content, " ")
			local time_str = '2022-04-06 ' .. infos[2]
			local str = infos[7]
			local values = util.split(str, "\t")
			local club_id = tonumber(values[4])
			local buy_total = tonumber(values[13])
			local total_bet_amount = tonumber(values[14])
			local log_time = time.time(time_str)
			--print(time_str, club_id, buy_total, total_bet_amount, log_time)

			if log_time < time.time("2022-04-06 18:00:00") then
				local obj = map[club_id]
				if not obj then
					obj = {}
					map[club_id] = obj
				end

				local last_log_time = obj.log_time or 0
				if log_time > last_log_time then
					obj.club_id = club_id
					obj.buy_total = buy_total
					obj.total_bet_amount = total_bet_amount
					obj.log_time = log_time
				end
			end

		end
	end

	for club_id, obj in pairs(map) do
		--print(club_id, cjson.encode(obj))
		local diamond = math.floor(obj.buy_total * 0.4)
		if diamond > 0 then
			local club_key = "dpzj:club:details:" .. club_id
			local master = tonumber(redis:hget(club_key, "master")) or 0
			print(club_id, obj.buy_total, diamond, master)
		end
	end
end
--check_cgl_log("/data/pokerclub/tools/cgl.txt")

function check_sigup_diamond_log(path, account_map)

	local map = {}

	local file = cutil.open(path)
	if file then
		while true do
			local content = cutil.line(file)
			if not content then
				break
			end
			--print(content)
			--0   2005    2005    21652780    John Garcia Bulan   633 10  623 SNG报名 1649174403  22040600000047
			--0   2005    2005    34785379    Judy Ann Dacapio    330 10  320 SNG报名 1649174403  22040600000041
			--1   2005    2014    21416721    Don Pokz Unico  2   15  17  SNG取消报名 1649174404  22040501476551
			local values = util.split(content, "\t")
			local account = tonumber(values[4])

			if not account_map or (account_map and account_map[account]) then 
				local tg = tonumber(values[1])
				local change = tonumber(values[7])
				local source = values[9]
				local log_time = tonumber(values[10])
				local unique_room_id = tonumber(values[11])
				if log_time < time.time("2022-04-06 18:00:00") then
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
--check_sigup_diamond_log("/root/redis_envt/sigup_diamond_0406.log", account_map)

function check_sigup_cc_log(path, account_map)

	local map = {}

	local file = cutil.open(path)
	if file then
		while true do
			local content = cutil.line(file)
			if not content then
				break
			end
			--print(content)
			--先统计日志 grep -E '报名|奖励' /logdata/2022-04-06/account_cc.log > signup_cc_0406.log
			--0   2005    2005    21652780    John Garcia Bulan   633 10  623 SNG报名 1649174403  22040600000047
			--0   2005    2005    34785379    Judy Ann Dacapio    330 10  320 SNG报名 1649174403  22040600000041
			--1   2005    2014    21416721    Don Pokz Unico  2   15  17  SNG取消报名 1649174404  22040501476551
			--408671  0   14964304    160 -50 110 tongits_sng牌局报名 1649174417  22040501458407
			--920767  0   38383236    483 20  503 tongits_sng牌局退还报名费   1649174417  22040501187280
			local values = util.split(content, "\t")
			local club_id = tonumber(values[1])
			local account = tonumber(values[3])

			if not account_map or (account_map and account_map[account]) then 
				local change = tonumber(values[5])
				local source = values[7]
				local log_time = tonumber(values[8])
				local unique_room_id = tonumber(values[9])

				if log_time < time.time("2022-05-06 11:26:35") then
					local obj = map[unique_room_id]
					if not obj then
						obj = {}
						map[unique_room_id] = obj
					end

					local info = obj[account]
					if not info then
						info = {}
						obj[account] = info
					end

					table.insert(info, {tg, account, change, source, log_time, unique_room_id, club_id})
				end
			end
		end
	end

	for unique_room_id, obj in pairs(map) do
		local is_down = false
		for account, info in pairs(obj) do
			for i = #info, 1, -1 do
				local o = info[i]
				local c = o[3]
				local source = o[4]
				local log_time = o[5]
				local club_id = o[7]
				if string.find(source, "奖励", 1, true) then
					--print(account, unique_room_id, c, source, log_time, time.date(log_time))
					is_down = true
					break
				end
			end
		end

		if not is_down then
			for account, info in pairs(obj) do
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
end
--check_sigup_cc_log("/root/redis_envt/signup_cc_0506.log", account_map)

function recharges_error(path, account_map)

	local configs = require("store")

	local file = cutil.open(path)
	if file then
		while true do
			local content = cutil.line(file)
			if not content then
				break
			end
			--print(content)
--grep '商城购买检查信息' info_2022-04-20.* | awk '{if($14==3&&$15==0) print}'
--info_2022-04-20.102.log:2022-04-20 00:38:33 [139638178058432] INFO  [/home/wing/workspace/dpzj/code_new/core/lua/lua_envt.cpp:28]- ./script/usercenter/process.lua:6248 商城购买检查信息    22543720    2005    2   0   4.2.0   705 3   0   false   PHP 2900    2900    false   table   Met Meya
			local infos = util.split(content, " ")
			local time_str = '2022-04-20 ' .. infos[2]

			local str = infos[7]
			local values = util.split(str, "\t")

			local account = tonumber(values[3])
			local store_id = tonumber(values[8])
			local goods_type = tonumber(values[9])
			local pkg_type = tonumber(values[10])
			local log_time = time.time(time_str)
			if log_time >= time.time("2022-04-20 15:54:25") and log_time <= time.time("2022-04-20 18:05:09") then
				--print(time_str, account, store_id, goods_type, pkg_type, log_time)
				local config = configs[store_id]
				if config  then
					--print(time_str, account, store_id, goods_type, pkg_type, log_time, config.item, config.count)
					print(account, config.item, config.count)
				end
			end
		end
	end
end
--recharges_error("/data/pokerclub/tools/ur4.txt")
