package.path = package.path .. ';luasocket/?.lua'
package.cpath = package.cpath .. ';luasocket/?.so'

local time = require("time")
local cjson = require("cjson")
require("util")
require("cutil")

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
--local account_map = get_account_map("/data/pokerclub/tools/usercenter_error_accounts_220807.txt")

function check_coin_log(path, account_map, usercenter_count)

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
			local log_time = tonumber(values[10])

			local usercenter_index = account % usercenter_count + 1

			if usercenter_index == 1 then 
			--if usercenter_index == 1 and log_time < time.time("2022-08-07 12:11:40") then 
			--if usercenter_index == 1 and log_time >= time.time("2022-08-07 11:13:49") and log_time < time.time("2022-08-07 12:01:40") then 
			--if not account_map or (account_map and account_map[account]) or (usercenter_count and usercenter_index == 1) then 
				local tg = tonumber(values[1])
				local change = tonumber(values[7])
				local source = values[9]
				local unique_room_id = tonumber(values[11])
				if string.find(source, "金币场带", 1, true) then
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
						local change = o[3]
						local source = o[4]
						local log_time = o[5]
						if t == 1 then
							break
						end
						--print(account, unique_room_id, change, source)
						if log_time > time.time("2022-08-07 12:01:40") then
							--print(account, unique_room_id, change, source, time.date(log_time))
						else
							print(account, unique_room_id, change)
						end
					end
				else
					local change = last_info[3]
					local source = last_info[4]
					local log_time = last_info[5]
					--print(account, unique_room_id, change, source)
					if log_time > time.time("2022-08-07 12:01:40") then
						--print(account, unique_room_id, change, source, time.date(log_time))
					else
						print(account, unique_room_id, change)
					end
				end
			end
		end
	end
end
--check_coin_log("/data/tomcat/webapps/platform_dynamic_data/logger/data/2022-08-07/coins.log", account_map)
--check_coin_log("/data/tomcat/webapps/platform_dynamic_data/logger/data/2022-08-07/coins.log", {}, 3)

function check_diamond_log1(usercenter_count, path)

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

			if usercenter_index == 1 and log_time >= time.time("2022-08-07 11:13:49") and log_time < time.time("2022-08-07 12:01:40") then 
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

function check_diamond_log2(usercenter_count, path)

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

			if usercenter_index == 1 and log_time >= time.time("2022-08-07 11:13:49") and log_time < time.time("2022-08-07 12:01:40") then 
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

	--[root@ip-172-31-7-143 tools]# grep '分销商发放扣除' /logdata/2022-08-07/diamonds.log > franchiser_diamond_kc_20220807.txt
	local get_diamond1 = check_diamond_log1(3, "/data/pokerclub/tools/franchiser_diamond_kc_20220807.txt")
	--[root@ip-172-31-7-143 tools]# grep '分销商发放获得' /logdata/2022-08-07/diamonds.log > franchiser_diamond_hd_20220807.txt
	local get_diamond2 = check_diamond_log2(3, "/data/pokerclub/tools/franchiser_diamond_hd_20220807.txt")

	for account, diamond in pairs(get_diamond1) do
		local get_count = get_diamond2[account] or 0
		local diff = diamond - get_count
		if diff > 0 then
			print(account, diff)
		end
	end
end
--check_diamond_log()

function check_gostar_log(path, account_map)

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

			if account_map[account] then 
				local tg = tonumber(values[1])
				local start_num = tonumber(values[6])
				local change = tonumber(values[7])
				local end_num = tonumber(values[8])
				local source = values[13]
				local log_time = tonumber(values[11])

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
					print(account, prev_end_num - start_num)
				end
				prev_end_num = end_num
			end

		end
	end
end
--check_gostar_log("/logdata/2022-08-07/cashs.log", account_map)

function check_silver_log(path)

	local map = {}

	local usercenter_count = 3
	local start_time = "2022-08-07 11:13:49"
	local end_time = "2022-08-07 12:01:40"

	local file = cutil.open(path)
	if file then
		while true do
			local content = cutil.line(file)
			if not content then
				break
			end
			--print(content)
			--0   2005    2005    8828587 SalveNE     3685570 3685570 0       金币场带入      1624971568      21062800285682  tongits
			--1   2005    2005    8828587 SalveNE     0       3685570 3685570 金币场带出      1624971568      21062800088264  tongits
			--0   2002    2002    3067726 DESCULPA    800022  600000  200022  22080600036152  自由场带入poker 1659841215  0
			--1   2004    2004    2778012 Huffaker    192272  80000   272272  22080600023484  自由场带出poker 1659841217  0
			local values = util.split(content, "\t")
			local account = tonumber(values[4])
			local log_time = tonumber(values[11])

			local usercenter_index = account % usercenter_count + 1

			if usercenter_index == 1 then
				local tg = tonumber(values[1])
				local change = tonumber(values[7])
				local source = values[10]
				local unique_room_id = tonumber(values[9])
				if string.find(source, "自由场", 1, true) then
					--print(content)
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
			--print(cjson.encode(info))
			local last_info = info[#info]
			local tg = last_info[1]
			local last_source = last_info[4]
			--0        2002    2002    2978751 Samilo Guilherme        416859  40000   376859  22080700002546  自由场带入poker 1659877344      0
			--0        2002    2002    2978751 Samilo Guilherme        378208  38800   339408  22080700002546  自由场重购带入poker     1659877686      0
			--1        2002    2002    2978751 Samilo Guilherme        339408  38800   378208  22080700002546  自由场重购带入失败退还poker     1659877686      0
			--0        2002    2002    2978751 Samilo Guilherme        378208  38800   339408  22080700002546  自由场重购带入poker     1659877689      0
			--1        2002    2002    2978751 Samilo Guilherme        339408  38800   378208  22080700002546  自由场重购带入失败退还poker     1659877689      0
			--0        2002    2002    2978751 Samilo Guilherme        378208  40000   338208  22080700002546  自由场重购带入poker     1659877696      0
			--0        2002    2002    2978751 Samilo Guilherme        338480  37800   300680  22080700002546  自由场重购带入poker     1659878760      0
			--
			--1 2002    2002    2372727 Kauã    940236  740700  1680936 22080600018947  自由场带出poker 1659842499      0
			--0 2002    2002    2372727 Kauã    1680936 400000  1280936 22080600018947  自由场带入poker 1659842500      0
			--1 2002    2002    2372727 Kauã    1280936 310000  1590936 22080600018947  自由场带出poker 1659842609      0
			--0 2002    2002    2372727 Kauã    1637636 400000  1237636 22080600018947  自由场带入poker 1659849402      0
			--1 2002    2002    2372727 Kauã    1237636 400000  1637636 22080600018947  自由场带出poker 1659849405      0
			--0 2002    2002    2372727 Kauã    1399675 400000  999675  22080600018947  自由场带入poker 1659881481      0
			if not string.find(last_source, "自由场带出", 1, true) then
				print("info_str", cjson.encode(info))
				if #info > 1 then
					local total = 0
					local log_time = 0
					for i = #info, 1, -1 do
						local o = info[i]
						local t = o[1]
						local c = o[3]
						local source = o[4]
						log_time = o[5]
						if t == 1 then
							c = -c
						end
						if t == 1 and string.find(source, "自由场带出", 1, true) then
							break
						end
						total = total + c
						print(account, unique_room_id, c, source, total, time.date(log_time))
					end
					if total > 0 then
						if log_time > time.time(end_time) then
							--print("result", account, unique_room_id, total, time.date(log_time))
						else
							print("result", account, unique_room_id, total)
						end
					end
				else
					local change = last_info[3]
					local source = last_info[4]
					local log_time = last_info[5]
					if log_time > time.time(end_time) then
						--print("result", account, unique_room_id, change, source, time.date(log_time))
					else
						print("result", account, unique_room_id, change)
					end
				end

			end
		end
	end
end
--check_silver_log("/data/tomcat/webapps/platform_dynamic_data/logger/data/2022-08-07/silver.log")

function check_s_log1(usercenter_count, path)

	local map = {}

	local file = cutil.open(path)
	if file then
		while true do
			local content = cutil.line(file)
			if not content then
				break
			end
			--print(content)
			--0   1005    1005    1268450 kenneth 830     430     400     分销商发放扣除  1625155198      0       2005,2205,13754802
			--0   2002    2002    1850273 Leandro 10135575    3000000 7135575 0   分销商发放扣除  1659926642  1834139 2002,2005,1834139
			local values = util.split(content, "\t")
			local tg = tonumber(values[1])
			local account = tonumber(values[4])
			--local obj_str = values[12]
			--local obj = util.split(obj_str, ",")
			--local target_account = tonumber(obj[3])
			local target_account = tonumber(values[12])
			local usercenter_index = target_account % usercenter_count + 1
			local log_time = tonumber(values[11])
			--print(account, obj_str, target_account, usercenter_index, time.date(log_time))

			if usercenter_index == 1 and log_time >= time.time("2022-08-07 11:13:49") and log_time < time.time("2022-08-07 12:01:40") then 
				local change = tonumber(values[7])
				local source = values[9]

				local obj = map[target_account]
				if not obj then
					obj = {}
					map[target_account] = obj
				end

				table.insert(obj, {account, change, source, log_time, target_account, tg})
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
			local tg = info[6]
			if tg == 1 then
				change = -change
			end

			diamond = diamond + change
			print(i, account, target_account, change, time.date(log_time), diamond, tg)
		end
		if diamond > 0 then
			print("===1", target_account, diamond)
		end

		get_diamond[target_account] = diamond
	end

	return get_diamond
end

function check_s_log2(usercenter_count, path)

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
			--local obj_str = values[12]
			--local obj = util.split(obj_str, ",")
			--local target_account = tonumber(obj[3])
			local target_account = tonumber(values[12])
			local usercenter_index = account % usercenter_count + 1
			local log_time = tonumber(values[11])
			--print(account, obj_str, target_account, usercenter_index, time.date(log_time))

			if usercenter_index == 1 and log_time >= time.time("2022-08-07 11:13:49") and log_time < time.time("2022-08-07 12:01:40") then 
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
		if diamond > 0 then
			print("===2", account, diamond)
		end

		get_diamond[account] = diamond
	end

	return get_diamond
end

function check_s_log()

	--[root@ip-172-31-7-143 tools]# grep '分销商发放扣除' /logdata/2022-08-07/silver.log > franchiser_silver_kc_20220807.txt
	local get_diamond1 = check_s_log1(3, "/data/pokerclub/tools/franchiser_silver_kc_20220807.txt")
	--[root@ip-172-31-7-143 tools]# grep '分销商发放获得' /logdata/2022-08-07/silver.log > franchiser_silver_hd_20220807.txt
	local get_diamond2 = check_s_log2(3, "/data/pokerclub/tools/franchiser_silver_hd_20220807.txt")

	for account, diamond in pairs(get_diamond1) do
		local get_count = get_diamond2[account] or 0
		local diff = diamond - get_count
		if diff > 0 then
			print(account, diff)
		end
	end
end
--check_s_log()

--local usercenter_count = 3
--local target_account = 2454555
--local usercenter_index = target_account % usercenter_count + 1
--print(usercenter_count, target_account, usercenter_index)

function check_silver_temp(path)

	local account_map = get_account_map("/root/login_2022_0920.txt")
	local map = {}

	local start_time = "2022-09-20 22:15:00"
	local end_time = "2022-09-20 22:25:00"

	local file = cutil.open("/root/sng_silver_0920.txt")
	if file then
		while true do
			local content = cutil.line(file)
			if not content then
				break
			end
			--print(content)
			--0   2002    2002    3149230 Fabiano Alves   50530   3300    47230   22092000000029  TrucoSNG报名    1663642841  0
    		--1   2002    2002    3739674 Gabriel Ferreira    3400    6000    9400    0   SNG比赛奖励 1663642843  0
			local values = util.split(content, "\t")
			local tg = tonumber(values[1])
			local account = tonumber(values[4])
			local change = tonumber(values[7])
			local unique_room_id = tonumber(values[9])
			local source = values[10]
			local log_time = tonumber(values[11])

			--if account_map[account] then
			if account_map[account] and log_time >= time.time(start_time) and log_time < time.time(end_time) then 
				--print(content)
				local obj = map[account]
				if not obj then
					obj = {}
					map[account] = obj
				end

				table.insert(obj, {tg, account, change, source, log_time, unique_room_id})
			end
		end
	end

	for account, obj in pairs(map) do
		--print(account, cjson.encode(obj))
		local values = obj[#obj]
		local tg = tonumber(values[1])
		local account = tonumber(values[2])
		local change = tonumber(values[3])
		local source = values[4]
		local log_time = tonumber(values[5])
		local unique_room_id = tonumber(values[6])
		--if not string.find(source, "比赛奖励", 1, true) then
		if string.find(source, "SNG报名", 1, true) then
			--for i = 1, #obj do
			--	local values = obj[i]
			--	local tg = tonumber(values[1])
			--	local account = tonumber(values[2])
			--	local change = tonumber(values[3])
			--	local source = values[4]
			--	local log_time = tonumber(values[5])
			--	local unique_room_id = tonumber(values[6])
			--	print(i, tg, account, change, source, log_time, unique_room_id, time.date(log_time))
			--end
			
			--print(tg, account, change, source, log_time, unique_room_id, time.date(log_time))
			print(account, change, source, unique_room_id)
		end
	end
end
--check_silver_temp()
