package.path = package.path .. ';luasocket/?.lua'
package.cpath = package.cpath .. ';luasocket/?.so'

local sys_print = print
local print = nil

local cjson = require("cjson")
local cjson_map = cjson:new()
cjson_map.encode_sparse_array(true, 1, 1)

require("redis")
require("util")
require("time")

local redis_host = "pt.pwft0z.clustercfg.use1.cache.amazonaws.com"
local redis_port = 6379
local redis_pwd = ""
local redis = Redis.connect(redis_host, redis_port, redis_pwd, true, true)

local activity_redis_host = "pt-activity.pwft0z.clustercfg.use1.cache.amazonaws.com"
local activity_redis_port = 6379
local activity_redis_pwd = ""
local activity_redis = Redis.connect(activity_redis_host, activity_redis_port, activity_redis_pwd, true, true)

local cache_redis_host = "pt-cache.pwft0z.ng.0001.use1.cache.amazonaws.com"
local cache_redis_port = 6379
local cache_redis = Redis.connect(cache_redis_host, cache_redis_port)

--在线REDIS配置 
online_redis_host = "pt-online.pwft0z.ng.0001.use1.cache.amazonaws.com"
online_redis_port = 6379
online_redis_pwd = "" 
local online_redis = Redis.connect(online_redis_host, online_redis_port)
if online_redis_pwd and online_redis_pwd ~= '' then
	online_redis:auth(online_redis_pwd)
end

function print(...)

	local info = _G.debug.getinfo(2, "Sl")
	local file = info and info.short_src or "unknown"
	local line = info and info.currentline or 0

	--sys_print(file .. ":" .. line, ...)
	sys_print(...)
end

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

--安全获取字符串
--@param value 原字符串
--@param default 默认值(如果不传则默认为空字符串)
--@return 字符串
function get_string_value(value, default)

    local default = default or ""

    return type(value) == "string" and value or default
end

--安全获取数字
--@param value 原数字
--@param default 默认值(如果不传则默认为0)
--@return 数字
function get_number_value(value, default)

    local default = tonumber(default) or 0

    return tonumber(value) or default
end

--json安全解析
--@param str json字符串
--@return data json解析结果
function json_decode(str)

	local data = nil

	local result, err = pcall(function(str) return cjson.decode(str) end, str)
	if result then
		if type(err) == "table" then
			data = err
		else
			log.fatal("json_decode_err", result, str, err)
		end
	else
		log.fatal("json_decode_err", result, str, err)
	end

	return data
end

function get_club_nationality(club_id)

    local club_members = redis:smembers("dpzj:club:member:" .. club_id)
    if not club_members or #club_members == 0 then
        return
    end

    local temp = {}

    for i = 1, #club_members do
        local user_id = club_members[i]
        local user_key = "dpzj:users:" .. user_id
        local nationality = string.upper(redis:hget(user_key, "nationality") or "PE")

        local count = temp[nationality] or 0
        temp[nationality] = count + 1
		print("俱乐部成员国家代码", club_id, user_id, nationality, count, temp[nationality])
    end

    local max_count = 0
    local nationality
    for na, count in pairs(temp) do
        if count > max_count then
            max_count = count
            nationality = na
        end
    end

    return nationality
end

function update_club_nationality()

	local ids = redis:smembers("dpzj:club:ids")
	for i = 1, #ids do
		local club_id = tonumber(ids[i])
		local club_key = "dpzj:club:details:" .. club_id
		local club_nationality = redis:hget(club_key, "club_nationality")
		local nationality = get_club_nationality(club_id)
		print("俱乐部国家代码更新成功", club_id, club_nationality, nationality)
		--redis:hset(club_key, "club_nationality", nationality)
	end
end 
--update_club_nationality()

function set_user_club_count(account, new_club_create_max, new_join_club_max)

    local created_clubs = tonumber(redis:scard("dpzj:club:user:created_clubs:" .. account))
    local joined_clubs = tonumber(redis:scard("dpzj:club:user:joined_clubs:" .. account))

    local user_key = "dpzj:users:" .. account
    local user_info = redis:hmget(user_key, "club_create_max", "join_club_max")
    local club_create_max = user_info[1] or 0
    local join_club_max = user_info[2] or 0
    print(account, created_clubs, joined_clubs, club_create_max, join_club_max)

    --redis:hmset(user_key, "club_create_max", new_club_create_max, "join_club_max", new_join_club_max)
end
--set_user_club_count(1170983, 0, 20)

function set_club_manager_max(club_id, new_manager_max)
    local club_key = "dpzj:club:details:" .. club_id
    local info = redis:hmget(club_key, "star_level", "member", "member_max", "manager_max", "master")
    local star_level = tonumber(info[1]) or 0
    local member = tonumber(info[2]) or 0
    local member_max = tonumber(info[3]) or 0
    local manager_max = tonumber(info[4]) or 0
    local master = tonumber(info[5]) or 0
    print("更新前:", master, club_id, star_level, member, member_max, manager_max)

    manager_max = new_manager_max

    print("更新后:", master, club_id, star_level, member, member_max, manager_max)
    --redis:hset(club_key, "manager_max", manager_max)
    --redis:hmset(club_key, "star_level", star_level, "member_max", member_max, "manager_max", manager_max)
end
--set_club_manager_max(857284, 20)

function check_yday_data(c_id, s_t, e_t)

    local now = os.time()

    print("检查开始", time.date(now))

    local clubs = redis:smembers("dpzj:club:yday_datas:clubs")
    for j = 1, #clubs do
        local club_id = tonumber(clubs[j])
        if c_id == 0 or c_id == club_id then
            local data_key = "dpzj:club:yday_datas:" .. club_id
            local info = redis:hmget(data_key, "hands", "diamonds")
            local old_hands = tonumber(info[1]) or 0
            local old_diamonds = tonumber(info[2]) or 0

            local data_player_key = "dpzj:club:yday_datas:" .. club_id .. ":players"
            local old_players = tonumber(redis:scard(data_player_key)) or 0
            print("当前数据", j, club_id, old_hands, old_players, old_diamonds)

            --local s_t = "2020-04-16"
            --local e_t = "2020-04-18"
            local start_time = time.begin(time.time(s_t))
            local end_time = time.begin(time.time(e_t))
            local data_history_key = "dpzj:club:yday_datas:" .. club_id .. ":history"

            local only_check = 1
            if only_check == 1 then
                local list = redis:zrevrangebyscore(data_history_key, end_time, start_time, "withscores")
                for i = 1, #list do
                    local info = list[i]
                    local tt = tonumber(info[2])
                    local json = cjson.decode(info[1])
                    local hands = json.hands or 0
                    local diamonds = json.diamonds or 0
                    local players = json.players or 0
                    print("查看俱乐部昨日数据", i, time.date(tt), club_id, hands, players, diamonds, info[1], info[2])
                end

            else
                old_hands = 0
                old_diamonds = 0
                --redis:hmset(data_key, "hands", old_hands, "diamonds", old_diamonds)
                print("重置数据", j, club_id, old_hands, old_players, old_diamonds)
            end

            print('\n')
        end
    end

    print("检查结束", time.date(os.time()), os.time() - now)
end
--check_yday_data(133514, "2020-10-10", "2020-10-12")

function global_packages()

    local config = {
        ["package61"] = 0,
        ["package62"] = 0,
    }

    local global_packages_key = "dpzj:global_packages"
    local infos = redis:hgetall(global_packages_key)
    for k, v in pairs(infos) do
        local count = config[k]
        --控制更新
        count = 0
        print("礼包数量", k, v, count)
        if count and count > 0 then
            if tonumber(v) >= count then
                --redis:hincrby(global_packages_key, k, -v)
                --redis:hincrby(global_packages_key, k, -count)
                print("更新数量成功", k, v, count)
            else
                print("更新数量失败", k, v, count)
            end
        end
    end
end
--global_packages()

function set_rank_activity_config(activity_id)

    local rank_details_key = "dpzj:rank:config:" .. activity_id
    local infos = redis:hmget(rank_details_key, "rank_type", "negative_mode", "maximum_number", "rank_award", "rank_award_negative", "save_finish_round", "round", "current_round", "room_level", "duration_days")
    local rank_type = tonumber(infos[1]) or 0
    local negative_mode = tonumber(infos[2]) or 0
    local maximum_number = tonumber(infos[3]) or 0
    local config_rank_award = infos[4] or ""
    local config_rank_award_negative = infos[5] or ""
    local save_finish_round = tonumber(infos[6]) or 0
    local round = tonumber(infos[7]) or 0
    local current_round = tonumber(infos[8]) or 0
    local room_level = infos[9] or ""
    local duration_days = tonumber(infos[10]) or 0
    print("config", activity_id, rank_type, negative_mode, maximum_number, save_finish_round, round, current_round, room_level, duration_days)
    --print("config", activity_id, rank_type, negative_mode, maximum_number, config_rank_award, config_rank_award_negative, save_finish_round)
    --redis:hmset(rank_details_key, "maximum_number", 100, "save_finish_round", 1)
    --redis:hmset(rank_details_key, "room_level", "")

     --[[
     local r = 5
     --redis:hset(rank_details_key, "round", r)
 
     local rank_data_list_key = "dpzj:rank:data:" .. activity_id .. ":list"                                                                                                                             
     local list = redis:zrevrange(rank_data_list_key, 0, -1, "withscores")
     if list and #list > 0 then
         for i = 1, #list do
             local obj = list[i] 
             local current_round = tonumber(obj[1]) or 0
             local current_start_time = tonumber(obj[2]) or 0                                                                                                                                           
             print(i, current_round, current_start_time, time.date(current_start_time), time.date(current_start_time + duration_days * 60))
                         
             if current_round > r then
			 	print("===", i, current_round, current_start_time, time.date(current_start_time), time.date(current_start_time + duration_days * 60))
				--redis:zrem(rank_data_list_key, current_round)
             end
         end             
     end
     --]]
end
--set_rank_activity_config(60)

function get_rank_list()
    local rank_list_key = "dpzj:rank:list:all"
    local list = redis:smembers(rank_list_key)
    local list_json_str = cjson.encode(list)
    print("list_json_str", list_json_str)

    local group = 2
    local group_list = redis:smembers("dpzj:rank:list:group:" .. group)
    local group_list_json_str = cjson.encode(group_list)
    print("group_list_json_str", group_list_json_str)

    local rank_type = 1
    local ac_id = tonumber(redis:zscore("dpzj:rank:list:type:" .. rank_type, group)) or 0
    print(rank_type, ac_id)
    local g = "2"
    local activity_id = "2"
    --redis:srem("dpzj:rank:list:group:" .. g, activity_id)
    --redis:zrem("dpzj:rank:list:type:" .. rank_type, g)
end
--get_rank_list()

function platform_send_mail(mail_path_str, title, content)

    local url = "http://10.22.10.140:8180/feedback/send_mail"
    local cmd = string.format('curl -G --data-urlencode "title=%s" --data-urlencode "content=%s" --data-urlencode "to=%s"  "%s"', title, content, mail_path_str, url)
    os.execute(cmd)
end
--platform_send_mail("597467190@qq.com", "test_title", "test_content")

function check_club_names()

    local key = "dpzj:club:allnames"
    --local club_names = redis:zrevrange(key, 0, -1, "withscores")
    local club_names = redis:zrevrange(key, 0, 10, "withscores")
    for i = 1, #club_names do
        local info = club_names[i]
        local club_id = info[1]
        local club_name = info[2]
        print(i, club_id, club_name)
    end
end
--check_club_names()
--
--local aa = redis:scard("dpzj:activity_data:invite_buy_silver:375015")
--print(aa)

--local account = 375015
--local franchiser_key = "dpzj:franchiser:" .. account
--local franchiser_info = redis:hmget(franchiser_key, "lv", "expiration_time", "status")
--local lv = tonumber(franchiser_info[1])
--local ex_time_str = franchiser_info[2]
--local status = tonumber(franchiser_info[3])
--print(franchiser_key, lv, ex_time_str, status)

--local list = redis:smembers("dpzj:card_update_ids")
--print(#list)

--local franchiser_count = redis:scard("dpzj:franchisers")
--print(franchiser_count)

--[[
local str_redis_key = "dpzj:franchiser:recommend_franchiser:last_trade:2280303"
local tab_info = redis:zrange(str_redis_key, 0, -1, "withscores")
local tab_last_trade_account_info = {}
for i = 1, #tab_info do
	local int_trade_account = tonumber(tab_info[i][1])
	local int_last_trade_time = tonumber(tab_info[i][2])
	print(int_trade_account, int_last_trade_time)
end
--]]

--[[
local tab_info = redis:hmget("dpzj:franchiser:2023348", "status", "lv")
local int_status = tonumber(tab_info[1]) or 1
local int_lv = tonumber(tab_info[2]) or 0
print(int_status,  int_lv )

print(redis:hget("dpzj:rebates", 2063301))
--]]
--print(activity_redis:hget("dpzj:activity_data:2823784", "conquian_seven_login"))
--print(redis:hget("dpzj:users:2823784", "joinSiMatch"))

--print(cjson.encode(redis:hgetall("dpzj:users:" .. 4427804)))
--local int_count = redis:hget("dpzj:users:3732286", "silver_from_franchiser")
--print(int_count)



--local signup_players_key = "dpzj:match:signup_players:168832"
--local signup_accounts = redis:zrange(signup_players_key, 0, -1, "withscores")
--if signup_accounts and #signup_accounts > 0 then
--	for i = 1, #signup_accounts do
--		local account = signup_accounts[i][1]
--		local room_id = signup_accounts[i][2]
--		print(account, room_id)
--	end
--end

--local purchase = activity_redis:get("dpzj:slots:purchase:event:details:4296715:9:" .. 500)
--print(purchase)

--local sbs = {100, 200, 500, 1000,2000, 3000, 5000, 10000, 15000, 20000, 30000, 40000, 50000, 60000, 80000, 100000, 150000, 200000, 250000}
--for i = 1, #sbs do
--	local sb = sbs[i]
--	local key = "dpzj:slots:purchase:event:details:4296715:9:" .. sb
--	local purchase = activity_redis:get(key)
--	print(sb, purchase)
--end

--local purchase = activity_redis:get("dpzj:slots:data:" .. 4296715 .. ":" .. 9 .. ":buy_free_fin")
--print(purchase)


--local str_redis_key = "dpzj:franchiser:return_rake:1983769"
--local tab_return_rake = redis:hgetall(str_redis_key)
--for str_time_key, int_return_rake in pairs(tab_return_rake) do
--	print(str_time_key, int_return_rake)
--end

function get_franchiser_recent_return_back_rake(account)

	local str_redis_key = "dpzj:franchiser:return_rake:%s"
	str_redis_key = string.format(str_redis_key, account)
	local int_begin = time.begin(os.time())
	local tab_select = {}
	local tab_delete = {}
	for i = 1, 7 do
		table.insert(tab_select, int_begin - (i - 1) * 86400)
	end
	local tab_return_rake = redis:hgetall(str_redis_key)
	local int_return_rake_sum = 0
	if tab_return_rake then
		for str_time_key, int_return_rake in pairs(tab_return_rake) do
			local int_time_begin = tonumber(str_time_key)
			local int_return_rake = tonumber(int_return_rake) or 0
			if int_time_begin then
				if util.list_has(tab_select, int_time_begin) then
					int_return_rake_sum = int_return_rake_sum + int_return_rake
				else
					table.insert(tab_delete, int_time_begin)
				end
			else
				local str_today_time_key = "today_use_quota" .. int_begin
				if str_time_key ~= str_today_time_key then
					table.insert(tab_delete, str_time_key)
				end
			end
		end
	end
	return int_return_rake_sum
end
--print(get_franchiser_recent_return_back_rake(1983769), get_franchiser_recent_return_back_rake(229214))

function get_user_attr(account, str_attr)
	local user_key = "dpzj:users:" .. account
	return redis:hget(user_key, str_attr)
end

function check_ban_silver_abnormal_account(account)

	local bool_same_ip_or_idfa_check = false
	local idfa = redis:hget("dpzj:accounts:" .. account, "idfa") or ""
	local tab_accounts = {}

	local str_have_pay_idfa_key = "dpzj:idfas:paid"
	print("DV-863-1", account, redis:sismember(str_have_pay_idfa_key, idfa))
	if idfa ~= "" and not redis:sismember(str_have_pay_idfa_key, idfa) then
		local idfa_key = "dpzj:idfas:login:" .. idfa
		local int_same_idfa_count = redis:scard(idfa_key)
		if int_same_idfa_count > 3 then
			bool_same_ip_or_idfa_check = true
			local tab_idfa_accounts = redis:smembers(idfa_key)
			for i = 1, #tab_idfa_accounts do
				local int_idfa_account = tonumber(tab_idfa_accounts[i])
				if int_idfa_account ~= account then
					local tab_idfa_info = redis:hmget("dpzj:users:" .. int_idfa_account, "BuySilStore", "silver_from_franchiser")
					if get_number_value(tab_idfa_info[1]) > 0 or get_number_value(tab_idfa_info[2]) > 0 then
						bool_same_ip_or_idfa_check = false
						redis:sadd(str_have_pay_idfa_key, idfa)
						print("DV-863-2", account, str_have_pay_idfa_key, idfa)
					end
				end
			end
		end
	end

	local now = os.time()
	local tab_user_info = redis:hmget("dpzj:users:" ..account, "last_ip",  "BuySilStore", "silver_from_franchiser", "create_time")
	local str_last_ip = get_string_value(tab_user_info[1])
	local int_silver_store = get_number_value(tab_user_info[2])
	local int_silver_franchiser = get_number_value(tab_user_info[3])
	local str_create_time = get_string_value(tab_user_info[4])
	local int_create_time = now
	if str_create_time ~= "" then
		int_create_time = time.time(str_create_time)
	end

	if str_last_ip ~= "" and not bool_same_ip_or_idfa_check then
		local str_last_ip_key = "dpzj:ip:login:" .. str_last_ip
		local int_same_ip_count = redis:scard(str_last_ip_key)
		if int_same_ip_count > 5 then
			local int_create_less_three_day_accounts_count = 0
			local tab_same_ip_accounts = redis:smembers(str_last_ip_key)
			for i = 1, #tab_same_ip_accounts do
				local int_ip_account = tonumber(tab_same_ip_accounts[i])
				local str_ip_create_time = get_string_value(get_user_attr(int_ip_account, "create_time"))
				local int_ip_create_time = now
				if str_ip_create_time ~= "" then
					int_ip_create_time = time.time(str_ip_create_time)
				end
				print("DV-863-3", account, int_create_less_three_day_accounts_count, int_ip_account, now, int_ip_create_time, now - int_ip_create_time)
				if now - int_ip_create_time < 86400 * 3 then
					int_create_less_three_day_accounts_count = int_create_less_three_day_accounts_count + 1
					if int_create_less_three_day_accounts_count >= 2 then
						bool_same_ip_or_idfa_check = true
					end
				end
			end
		end
	end

	print("last", bool_same_ip_or_idfa_check, int_silver_store == 0, int_silver_franchiser == 0, now - int_create_time <= 3 * 86400)
	if bool_same_ip_or_idfa_check and int_silver_store == 0 and int_silver_franchiser == 0 and now - int_create_time <= 3 * 86400 then
		return true
	end

	return false
end
--check_ban_silver_abnormal_account(7225357)

function get_user_attr(account, str_attr)
	local user_key = "dpzj:users:" .. account
	return redis:hget(user_key, str_attr)
end

function check_ban_silver_abnormal_account(account)

	local bool_same_ip_or_idfa_check = false
	local idfa = redis:hget("dpzj:accounts:" .. account, "idfa") or ""
	local tab_accounts = {}

	local str_have_pay_idfa_key = "dpzj:idfas:paid"
	print("DV-863-1", account, redis:sismember(str_have_pay_idfa_key, idfa))
	if idfa ~= "" and not redis:sismember(str_have_pay_idfa_key, idfa) then
		local idfa_key = "dpzj:idfas:login:" .. idfa
		local int_same_idfa_count = redis:scard(idfa_key)
		if int_same_idfa_count > 3 then
			bool_same_ip_or_idfa_check = true
			local tab_idfa_accounts = redis:smembers(idfa_key)
			for i = 1, #tab_idfa_accounts do
				local int_idfa_account = tonumber(tab_idfa_accounts[i])
				if int_idfa_account ~= account then
					local tab_idfa_info = redis:hmget("dpzj:users:" .. int_idfa_account, "BuySilStore", "silver_from_franchiser")
					if get_number_value(tab_idfa_info[1]) > 0 or get_number_value(tab_idfa_info[2]) > 0 then
						bool_same_ip_or_idfa_check = false
						redis:sadd(str_have_pay_idfa_key, idfa)
						print("DV-863-2", account, str_have_pay_idfa_key, idfa)
					end
				end
			end
		end
	end

	local now = os.time()
	local tab_user_info = redis:hmget("dpzj:users:" ..account, "last_ip",  "BuySilStore", "silver_from_franchiser", "create_time")
	local str_last_ip = get_string_value(tab_user_info[1])
	local int_silver_store = get_number_value(tab_user_info[2])
	local int_silver_franchiser = get_number_value(tab_user_info[3])
	local str_create_time = get_string_value(tab_user_info[4])
	local int_create_time = now
	if str_create_time ~= "" then
		int_create_time = time.time(str_create_time)
	end

	if str_last_ip ~= "" and not bool_same_ip_or_idfa_check then
		local str_last_ip_key = "dpzj:ip:login:" .. str_last_ip
		local int_same_ip_count = redis:scard(str_last_ip_key)
		if int_same_ip_count > 5 then
			local int_create_less_three_day_accounts_count = 0
			local tab_same_ip_accounts = redis:smembers(str_last_ip_key)
			for i = 1, #tab_same_ip_accounts do
				local int_ip_account = tonumber(tab_same_ip_accounts[i])
				local str_ip_create_time = get_string_value(get_user_attr(int_ip_account, "create_time"))
				local int_ip_create_time = now
				if str_ip_create_time ~= "" then
					int_ip_create_time = time.time(str_ip_create_time)
				end
				print("DV-863-3", account, int_create_less_three_day_accounts_count, int_ip_account, now, int_ip_create_time, now - int_ip_create_time)
				if now - int_ip_create_time < 86400 * 3 then
					int_create_less_three_day_accounts_count = int_create_less_three_day_accounts_count + 1
					if int_create_less_three_day_accounts_count >= 2 then
						bool_same_ip_or_idfa_check = true
					end
				end
			end
		end
	end

	print("last", bool_same_ip_or_idfa_check, int_silver_store == 0, int_silver_franchiser == 0, now - int_create_time <= 3 * 86400)
	if bool_same_ip_or_idfa_check and int_silver_store == 0 and int_silver_franchiser == 0 and now - int_create_time <= 3 * 86400 then
		return true
	end

	return false
end
--check_ban_silver_abnormal_account(7270053)


--[[
local account = 1783262
local club_id = 295119

local role_club_key = "dpzj:club:member:" .. club_id .. ":" .. account
role_club_position = tonumber(redis:hget(role_club_key, "position")) or 0

local count = 0
local create_room_ids = cache_redis:smembers("cache:create_rooms:" .. account)
local create_room_count = #create_room_ids
for i = 1, create_room_count do
    local room_id = create_room_ids[i]
    local room_club_id = tonumber(cache_redis:hget("cache:info:rooms:" .. room_id, "club_id"))
    if room_club_id then
        if room_club_id == club_id then
            count = count + 1
        end
    end
end
print("俱乐部管理员信息", account, role_club_position, count)
--]]


--local user_sub_roomservers = online_redis:smembers("online:user_sub_roomservers:1734773")
--for i = 1, #user_sub_roomservers do
--    local server_id = tonumber(user_sub_roomservers[i])
--    print(server_id)
--end


function test(account)
    local idfa = redis:hget("dpzj:accounts:" .. account, "idfa") or ""
    local tab_accounts = {}
    if idfa ~= "" then
        local idfa_key = "dpzj:idfas:login:" .. idfa
        tab_accounts = redis:smembers(idfa_key)
        for i = 1, #tab_accounts do
            local int_idfa_account = tab_accounts[i]
            local franchiser_key = "dpzj:franchiser:" .. int_idfa_account
            local tab_franchiser_info = redis:hmget(franchiser_key, "status", "lv", "expiration_time", "banned_reason")
            local int_idfa_franchiser_status = tonumber(tab_franchiser_info[1]) or 1
            local int_idfa_franchiser_lv = get_number_value(tab_franchiser_info[2])
            local str_date = get_string_value(tab_franchiser_info[3])
            local str_ban_reason = get_string_value(tab_franchiser_info[4])
            local int_out_date
            if str_date ~= "" then
                int_out_date = time.time(str_date)
            end
            if int_idfa_franchiser_status == 1 or (int_idfa_franchiser_lv == 7 and int_out_date and now > get_number_value(int_out_date)) then
                print(string.format("account%s", account), int_idfa_account)
            end
        end
    end
end
--test(7509161)
--test(5876249)

--[=[
local tab = {"200.173.211.176", "191.177.167.248", "191.245.80.181", "191.245.70.113", "191.245.92.24", "191.245.76.188", "200.173.204.178", "200.173.209.252", "191.245.95.94", "191.245.72.230", "191.245.72.210", "155.94.250.13", "200.173.197.12", "200.173.204.228", "201.66.33.202", "138.204.75.95", "200.173.206.185", "138.204.75.111", "177.79.59.130", "179.84.207.65", "179.84.202.12", "179.84.192.31", "179.84.206.116", "179.84.207.207", "179.84.207.34", "179.84.207.203", "179.84.195.182", "179.84.204.75", "179.84.198.68", "179.84.197.9", "179.84.203.133", "179.84.207.148", "179.84.207.23", "179.84.203.92", "200.173.207.148", "179.84.206.130", "179.84.199.134", "179.84.200.136", "179.84.197.63", "179.84.197.81", "179.84.200.18", "179.84.192.3", "179.84.194.49", "179.84.194.86", "179.84.194.162", "179.84.206.87", "179.84.203.184", "179.84.196.190", "179.84.192.8", "179.84.206.173", "179.84.199.140", "179.84.194.82", "179.84.194.247", "179.84.199.69", "179.84.200.9", "179.84.196.200", "179.84.206.2", "179.84.206.33", "179.84.206.74", "179.84.196.62", "179.84.207.152", "179.84.196.201", "179.84.207.227", "179.84.197.49", "179.84.207.197", "179.84.194.142", "189.40.71.104", "189.40.71.242", "170.244.202.193", "177.51.210.159", "177.51.208.79", "177.51.208.233", "179.84.201.119", "179.84.207.13", "179.84.203.196", "179.84.207.8", "189.40.70.210", "179.84.198.32", "189.40.68.124", "189.40.69.190", "189.40.70.163", "177.51.196.197", "179.84.196.19", "179.84.192.48", "179.84.194.140", "179.84.197.121", "179.84.207.35", "179.84.205.7", "189.40.71.44", "189.40.71.157", "179.84.193.218", "179.84.192.175", "179.84.205.247", "179.84.194.95", "179.84.197.106", "179.84.205.128", "189.40.68.118", "177.51.208.170", "179.84.206.129", "179.84.207.231", "179.84.203.220", "179.84.194.104", "189.40.70.141", "177.51.209.61", "179.84.200.131", "179.84.196.13", "179.84.203.120", "189.40.70.32", "177.51.209.118", "179.84.199.19", "179.84.204.95", "179.84.204.52", "179.84.193.155", "179.84.199.237", "179.84.202.189", "179.84.192.92", "179.84.205.135", "179.84.205.203", "179.84.194.235", "179.84.196.158", "179.84.206.71", "179.84.196.50", "179.84.206.65", "179.84.207.61", "179.84.206.144", "179.84.207.101", "179.84.194.1", "179.84.198.126", "179.84.203.216", "179.84.203.29", "179.84.196.73", "179.84.202.35", "179.84.202.11", "179.84.196.195", "179.84.196.170", "179.84.202.222", "179.84.197.240", "179.84.195.118", "179.84.203.140", "179.84.197.16", "179.84.202.88", "179.84.196.215", "179.84.195.190", "179.84.200.66", "179.84.196.122", "179.84.200.79", "179.84.197.179", "179.84.199.114", "179.84.200.114", "179.84.204.2", "179.84.193.122", "179.84.198.107", "179.84.202.19", "179.84.202.204", "179.84.199.198", "179.84.192.216", "179.84.192.6", "179.84.201.177", "179.84.193.255", "179.84.205.255", "179.84.196.153", "179.84.207.146", "179.84.207.18", "179.84.197.73", "179.84.198.98", "179.84.198.76", "179.84.200.94", "179.84.197.70", "179.84.203.41", "179.84.194.47", "179.84.194.172", "179.84.194.103", "179.84.194.200", "179.84.197.37", "179.84.207.66", "179.84.203.5", "179.84.203.218", "179.84.203.252", "179.84.195.246", "179.84.205.248", "179.84.196.43", "179.84.202.31", "179.84.202.185", "179.84.207.247", "179.84.207.237", "179.84.199.184", "179.84.199.229", "179.84.199.187", "179.84.204.180", "179.84.193.215", "179.84.199.133", "179.84.202.149", "179.84.192.120", "179.84.205.141", "179.84.192.190", "179.84.201.218", "179.84.206.32", "179.84.206.186", "179.84.196.56", "179.84.203.77", "179.84.202.77", "179.84.206.242", "179.84.197.220", "179.84.200.229", "179.84.207.195", "179.84.207.37", "179.84.201.171", "179.84.207.24", "179.84.205.70", "179.84.197.192", "179.84.206.120", "179.84.206.194", "179.84.194.238", "179.84.203.45", "179.84.197.161", "179.84.195.237", "179.84.206.179", "179.84.195.208", "179.84.202.172", "179.84.200.235", "179.84.192.142", "179.84.205.198", "179.84.199.238", "179.84.204.226", "179.84.196.87", "179.84.193.117", "179.84.197.36", "179.84.198.139", "179.84.202.159", "179.84.199.218", "179.84.199.70", "179.84.199.61", "179.84.205.21", "179.84.194.14", "179.84.194.67", "179.84.200.77", "179.84.200.138", "179.84.197.52", "179.84.203.249", "179.84.194.188", "179.84.197.141", "179.84.196.98", "179.84.192.111", "179.84.202.50", "179.84.202.130", "179.84.200.109", "179.84.196.212", "179.84.205.78", "179.84.207.43", "179.84.192.77", "179.84.205.17", "179.84.200.234", "179.84.198.137", "179.84.199.25", "179.84.194.152", "179.84.205.237", "179.84.205.83", "179.84.200.203", "179.84.202.209", "179.84.197.85", "179.84.196.242", "179.84.200.69", "179.84.200.82", "179.84.195.235", "179.84.195.163", "179.84.202.25", "179.84.195.141", "179.84.196.172", "179.84.200.237", }

print("数据打印开始")
for i = 1, #tab do
	local ip = tab[i]
	--print(i, ip)
	local redis_key = "dpzj:ip:login:" .. ip
	local accounts = redis:smembers(redis_key)
	for i = 1, #accounts do
		print(ip, accounts[i])
	end
	if ip then
		break
	end
end
print("数据打印结束")
--]=]

--print(activity_redis:hget("dpzj:activity_data:1501944", "user_temp_data"))


--[[
function get_user_activity_data(account, ac_key, start_time)

    if not account or not ac_key or not start_time then
        log.error("活动数据缺少字段", account, ac_key, start_time)
    end
    local ac_data_key = "dpzj:activity_data:" .. account
    local ac_data = activity_redis:hget(ac_data_key, ac_key)

    local json = nil
    if ac_data and ac_data ~= "" then
        json = cjson.decode(ac_data)
        local time = json.start_time or nil

        if not time or time < start_time then
            json = nil
            activity_redis:hdel(ac_data_key, ac_key)
        end
    end

    json = json or {}

    return ac_data_key, json
end

function get_temp_attr(id, attr)
    local ac_key = "user_temp_data"
    local ac_data_key, ac_json = get_user_activity_data(id, ac_key, time.time("2020-12-21"))
    local now = os.time()

    local temp_attr_tab = ac_json.attr_tab or {}
    local temp_attr_time_tab = ac_json.attr_time or {}
    local endtime = temp_attr_time_tab[attr]
    if not endtime then
        return
    end

    if now > endtime then
        temp_attr_tab[attr] = nil
        temp_attr_time_tab[attr] = nil

        ac_json.start_time = now
        ac_json.attr_tab = temp_attr_tab
        ac_json.attr_time = temp_attr_time_tab
        local now_json_str = cjson.encode(ac_json)
        activity_redis:hset(ac_data_key, ac_key, now_json_str)
        return
    end

    return temp_attr_tab[attr], endtime
end

--获取三日内玩家silver返利的值
function get_three_day_return_silver(account)

    local now = os.time()
    local int_time_begin = time.begin(now)
    local tab_collect_info = get_temp_attr(account, "returnSilver") or {}

    local int_sum_return = 0
    for i = 1, 3 do
        local str_key = tostring(int_time_begin - (i - 1) * 86400)
        if tab_collect_info[str_key] then
            int_sum_return = int_sum_return + tab_collect_info[str_key]
        end
    end
    return int_sum_return
end



local franchiser = 1834139
local account = 2153410
local now = os.time()
local one_day_trade_players = redis:zcount("dpzj:franchiser:players_of_trade_one_day:" .. franchiser, now - 86400, now)
local tab_info = redis:hmget("dpzj:franchiser:" .. franchiser, "status", "lv")
local int_status = tonumber(tab_info[1]) or 1
local int_lv = tonumber(tab_info[2]) or 0
print("推广员等级状态", int_status, int_lv)
print("24小时返利人数:", one_day_trade_players)

local str_redis_key = "dpzj:franchiser:recommend_franchiser:last_trade:" .. account
local tab_info = redis:zrange(str_redis_key, 0, 2, "withscores") or {}
for i = 1, #tab_info do
    local int_trade_account = tonumber(tab_info[i][1])
    local int_last_trade_time = tonumber(tab_info[i][2])
    local tab_temp_info = redis:hmget("dpzj:users:" .. int_trade_account, "avatar", "forbid")
    local forbid_time = tonumber(tab_temp_info[2]) or 0
    local str_redis_key = string.format("dpzj:franchiser_eva:evaluation_record:%s:%s", int_trade_account, 2) --差评redis key
    local int_negative_comment_count = get_number_value(redis:zscore(str_redis_key, account))
    if int_last_trade_time then
        local str_redis_key2 = "dpzj:franchiser:recommend_franchiser:chat_info"
        local str_json = redis:hget(str_redis_key2, int_trade_account) or ""
        local tab_info = {}
        if str_json ~= "" then
            tab_info = json_decode(str_json)
        end
        print("最近交易推广员信息", int_trade_account, tab_info.name, tab_info.whatsApp, int_last_trade_time, forbid_time, now, int_negative_comment_count)
    else
        print("最近交易推广员信息", int_trade_account, tab_info.name, tab_info.whatsApp, int_last_trade_time, forbid_time, now, int_negative_comment_count)
    end
end
local int_user_have_silver = tonumber(redis:hget("dpzj:users:" .. account, "silver")) or 0
local int_rake = get_three_day_return_silver(franchiser)
print("三天返利数量与存量", int_user_have_silver, int_rake)
--]]

--print(activity_redis:hget("dpzj:activity_data:1834139", "user_temp_data"))

--print("交易关系", redis:sismember("dpzj:silver_trade224165", 2075207)) 
--print("存款", redis:hget("dpzj:franchiser:224165", "silver_store"))
--print("白名单", redis:hget("dpzj:franchiser_shop", 224165))

--local str_redis_key = "dpzj:silver_safe_mode:1778021"
--local tab_log = {}
--tab_log.target = 2653770
--tab_log.silver = 20000
--tab_log.time = 1691003055
--tab_log.type = 6
--local str_json = cjson.encode(tab_log)
--print("分数", redis:zscore(str_redis_key, str_json))


--local function test()
--	local redis_key = "dpzj:franchiser:recommend_franchiser_list_TV"
--	local redis_key2 = "dpzj:franchiser:recommend_franchiser_list_CCV"
--	local filed = {"recommend_franchiser_PT", "recommend_franchiser_PT_two"}
--	local obj = redis:hmget(redis_key, unpack(filed))
--	print(obj[1], obj[2])
--	local obj = redis:hmget(redis_key2, unpack(filed))
--	print(obj[1], obj[2])
--end
--test()

--local str_redis_key = "dpzj:franchiser:return_rake:%s"
--str_redis_key = string.format(str_redis_key, 5603494)
--local tab_return_rake = redis:hgetall(str_redis_key)
--for str_time_key, int_return_rake in pairs(tab_return_rake) do
--	print(str_time_key, int_return_rake)
--end

--local account = 6239732
--local user_infos = redis:hmget("dpzj:users:" .. account, "Chave_Name", "Chave_Pix")
--local Chave_Name = user_infos[1] or ""
--local Chave_Pix = user_infos[2] or ""
--print(account, Chave_Name, Chave_Pix)


redis:quit()
activity_redis:quit()
cache_redis:quit()
online_redis:quit()
