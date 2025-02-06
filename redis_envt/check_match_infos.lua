--require("redis")
package.path = package.path .. ';luasocket/?.lua'
package.cpath = package.cpath .. ';luasocket/?.so'

local sys_print = print
local print = nil

local luasql = require("luasql.mysql")
local cjson = require("cjson")
local cjson_map = cjson:new()
cjson_map.encode_sparse_array(true, 1, 1)

require("redis")
require("util")
require("cutil")
require("time")

local redis_host = "pt.pwft0z.clustercfg.use1.cache.amazonaws.com"
local redis_port = 6379
local redis_pwd = ""
local redis = Redis.connect(redis_host, redis_port, redis_pwd, true, true)

local cache_ro_redis_host = "pt-cache-ro.pwft0z.ng.0001.use1.cache.amazonaws.com"
local cache_ro_redis_port = 6379
local cache_ro_redis = Redis.connect(cache_ro_redis_host, cache_ro_redis_port)

local cache_redis_host = "pt-cache.pwft0z.ng.0001.use1.cache.amazonaws.com"
local cache_redis_port = 6379
local cache_redis = Redis.connect(cache_redis_host, cache_redis_port)

function print(...)

	local info = _G.debug.getinfo(2, "Sl")
	local file = info and info.short_src or "unknown"
	local line = info and info.currentline or 0

	local now = os.time()
	local datestr = time.date(now)
	--sys_print(datestr, file .. ":" .. line, ...)
	sys_print(...)
	io.flush()
end

function is_long_room_id(room_id)

	return room_id >= 1000000
end

function get_room_info(room, key)

    if not room then
        return
    end

    local room_id = room.room_id
    if not room_id then
        return
    end

    if room[key] then
        return room
    end

    local value = cache_ro_redis:hget("cache:info:rooms:" .. room_id, key)
    room[key] = value

    return room
end

function get_room_key_default(room, key, default)
	local value = room[key]
    if not value then
        get_room_info(room, key)
    end    
    return room[key] or default
end        
       
function get_room_key(room, key)
	return get_room_key_default(room, key)
end

function get_room_key_number_default(room, key, default)

    local value = get_room_key_default(room, key)
    return tonumber(value) or default
end

function get_room_key_number(room, key)

	local value = get_room_key_number_default(room, key, 0)
	return value
end

function get_room_infos(room, keys)

	if not room then
		return
	end

	local room_id = room.room_id
	if not room_id then
		return
	end

	local gets = {}
	for i = 1, #keys do
		local k = keys[i]
		if not room[k] then
			table.insert(gets, k)
		end
	end

	local len = #gets
	if len > 0 then
		if len > 1 then
			local values = cache_ro_redis:hmget("cache:info:rooms:" .. room_id, unpack(gets))
			for i = 1, #gets do
				local k = gets[i]
				room[k] = values[i]
			end
		elseif len == 1 then
			local k = gets[1]
			local value = cache_ro_redis:hget("cache:info:rooms:" .. room_id, k)
			room[k] = value
		end
	end

	return room
end

function get_official_match_config_key(match_id)

	return "cache:match:" .. match_id
end

function get_official_match_config_info(match_id)                                                                                                                                      

    local key = get_official_match_config_key(match_id)                                                                                                                                

    local redis_match_info = cache_ro_redis:hget(key, "configs")                                                                                                                 
    if util.is_empty(redis_match_info) then                                                                                                                                            
        print("比赛没有配置信息", match_id)
        return
    end
	--print(redis_match_info)

    local obj = cjson.decode(redis_match_info)
    return obj
end

function get_official_match_config_type_key(room_type, match_id)

    if room_type == 2 then
        return "dpzj:poker_sng:" .. match_id
    elseif room_type == 3 then
        return "dpzj:poker_match:" .. match_id
    elseif room_type == 23 then
        return "dpzj:bingo_sng:" .. match_id
    elseif room_type == 24 then
        return "dpzj:bingo_match:" .. match_id
    elseif room_type == 29 then
        return "dpzj:truco_sng:" .. match_id
    elseif room_type == 30 then
        return "dpzj:truco_match:" .. match_id
    elseif room_type == 41 then
        return "dpzj:domino_sng:" .. match_id
    elseif room_type == 42 then
        return "dpzj:domino_match:" .. match_id
    end

    print("找不到对应的类型比赛", room_type, match_id)
end

function get_official_match_config_info_dpzj(room_type, match_id)                                                                                                                                      

    local key = get_official_match_config_type_key(room_type, match_id)

    local redis_match_info = redis:hget(key, "configs")                                                                                                                 
    if util.is_empty(redis_match_info) then                                                                                                                                            
        print("比赛没有配置信息", match_id)
        return
    end
	--print(redis_match_info)

    local obj = cjson.decode(redis_match_info)
    return obj
end

function get_official_match_type_key(room_type)

	if room_type == 2 then
		return "dpzj:poker_sngs"
	elseif room_type == 3 then
		return "dpzj:poker_matches"
	elseif room_type == 14 then
		return "dpzj:tongits_sngs"
	elseif room_type == 15 then
		return "dpzj:tongits_matches"
	elseif room_type == 17 then
		return "dpzj:pusoy_sngs"
	elseif room_type == 18 then
		return "dpzj:pusoy_matches"
	elseif room_type == 23 then
		return "dpzj:bingo_sngs"
	elseif room_type == 24 then
		return "dpzj:bingo_matches"
	end
end

function clear_official_match_cache(match_id, room_type)

	--房间已关闭、清理比赛信息
	cache_redis:srem("cache:matches", match_id)

	cache_redis:zrem("cache:rooms_matches", match_id)

	cache_redis:zrem("cache:type_matches" .. room_type, match_id)

	cache_redis:zrem("cache:group_matches", match_id)

	cache_redis:del(get_official_match_config_key(match_id))

	if room_type % 3 == 0 then
		cache_redis:zrem("cache:rooms_mtt", match_id)
	elseif room_type % 3 == 2 then
		cache_redis:zrem("cache:rooms_sng", match_id)
	end

	local key = get_official_match_type_key(room_type)
	redis:srem(key, match_id)
end

function close_room(room, check_unique_room_id)

	get_room_infos(room, {"room_id", "club_id", "match_id", "unique_room_id", "room_type", "is_coin_room", "coin_room_key", "founder_account"})
	local room_id = get_room_key_number(room, "room_id")
	local club_id = get_room_key_number(room, "club_id")
	local match_id = get_room_key_number(room, "match_id")
	local unique_room_id = get_room_key_number(room, "unique_room_id")
	local room_type = get_room_key_number(room, "room_type")
	local is_coin_room = get_room_key_number(room, "is_coin_room")
	local founder_account = get_room_key_number(room, "founder_account")

	if unique_room_id ~= check_unique_room_id then
		print("关闭房间不存在", room_type, room_id, unique_room_id, club_id, match_id, is_coin_room, check_unique_room_id)
		return
	end

	local rm = cache_redis:srem("cache:global_rooms", room_id)
	if rm == 0 then
		print("关闭房间不存在", room_type, room_id, unique_room_id, club_id, match_id, is_coin_room, rm)
		return
	end

	print("正在关闭房间", room_type, room_id, unique_room_id, club_id, match_id, is_coin_room, founder_account)

	if founder_account > 0 then
		cache_redis:srem("cache:create_rooms:" .. founder_account, room_id)
		cache_redis:srem("cache:join_rooms:" .. founder_account, room_id)
	end

	local join_accounts_key = "cache:room_accounts:" .. room_id
	local accounts = cache_redis:smembers(join_accounts_key)
	for i = 1, #accounts do
		local account = accounts[i]
		cache_redis:srem("cache:join_rooms:" .. account, room_id)
	end
	cache_redis:del(join_accounts_key)

	--清理俱乐部房间列表
	if club_id > 0 then
		local count = cache_redis:zrem("cache:club_rooms:" .. club_id, room_id)
		print("清除俱乐部房间缓存", club_id, count)
	end

	local room_id_recycle_key = is_long_room_id(room_id) and "cache:distri_room_ids_long" or "cache:distri_room_ids"
	cache_redis:rpush("cache:distri_room_ids", room_id)

	print("关闭房间", room_type, room_id, unique_room_id, club_id, is_coin_room)

	if match_id > 0 then
		if room_type % 3 == 0 then
			clear_official_match_cache(match_id, room_type)
		end
	end

	if is_coin_room == 1 then
		local coin_room_key = room.coin_room_key
		if util.not_empty(coin_room_key) then
			cache_redis:zrem(coin_room_key, room_id)
		else
			print("金币场房间关闭时没有清理", room_type, room_id)
		end
	end

	cache_redis:del("cache:info:rooms:" .. room_id)
end

function check_coin_room_info(account)
    --[[
        local room_id = 3201254
        local infos = cache_redis:hmget("cache:info:rooms:" .. room_id, "room_type", "create_time", "start_time_setting")
        local room_type = tonumber(infos[1])
        local create_time = tonumber(infos[2]) or 0
        create_time = create_time == 0 and "" or time.date(create_time)
        local start_time_setting = tonumber(infos[3]) or 0
        start_time_setting = start_time_setting == 0 and "" or time.date(start_time_setting)
        print(i, room_id, room_type, create_time, start_time_setting)

    local configs = cache_redis:hget("cache:match:" .. 407658, "configs")   
    print(configs)
    --]]

    --local account = 4299755
    local cache_test_coin_room_key = "cache:test_coin_room"
    local test_coin_room_time = cache_redis:hget(cache_test_coin_room_key, account)
    print("cache_test_coin_room_key", account, test_coin_room_time)
    --cache_redis:hdel(cache_test_coin_room_key, account)

    local cache_playing_coin_room_key = "cache:playing_coin_room"
    local playing_room_id = tonumber(cache_redis:hget(cache_playing_coin_room_key, account)) or 0
    print("cache_playing_coin_room_key", account, playing_room_id)
    --cache_redis:hdel(cache_playing_coin_room_key, account)

    local cache_slots_coin_room_key = "cache:slots_coin_room"
    local slots_coin_room_time = cache_redis:hget(cache_slots_coin_room_key, account)
    print("cache_slots_coin_room_key", account, slots_coin_room_time)
    --cache_redis:hdel(cache_slots_coin_room_key, account)
	
	local cache_test_free_room_key = "cache:test_free_room"
	local test_free_room_time = cache_redis:hget(cache_test_free_room_key, account)
    print("cache_test_free_room_key", account, test_free_room_time)
    --cache_redis:hdel(cache_test_free_room_key, account)

	local cache_playing_free_room_key = "cache:playing_free_room"
	local playing_free_room_id = cache_redis:hget(cache_playing_free_room_key, account)
    print("cache_playing_free_room_key", account, playing_free_room_id)
    --cache_redis:hdel(cache_playing_free_room_key, account)
end

local function logic()

	--[[
	--local min_id = 127669
	local min_id = 127599
	local max_id = 127768
	for i = 1, max_id - min_id do
		local match_id = min_id + i
		--local match_infos = get_official_match_config_info(match_id)                                                                                                                                      
		local match_infos = get_official_match_config_info_dpzj(42, match_id)
		if match_infos then
			local room_type = match_infos.roomType
			local room_name = match_infos.name
			if room_name == "Torneio por hora - Prêmio 15 Dindin" then
				print(match_id, room_type, room_name, match_infos.startTime)
			end
		end
	end
	--]]
	
	--cache_redis:zrem("cache:free_rooms:40_1_0_4_2_-2_1", 409446)
	--print(cache_redis:hget("cache:playing_coin_room", 2002929))
	
	--[[
	local match_id = 158703
	local room_type = 3
	local key = get_official_match_type_key(room_type)
	--redis:sadd(key, match_id)
	print(match_id, key)
	--]]
	
	--check_coin_room_info(2627711)

	--local str_cache_playing_free_room_key = "cache:playing_free_room"
	--print(cache_redis:hget(str_cache_playing_free_room_key, 6157090))

	--local str_cache_playing_free_room_key = "cache:playing_free_room"
	--local room_id = cache_redis:hget(str_cache_playing_free_room_key, 4241559)
	--if room_id then
	--	print(room_id)
	--	cache_redis:hdel(str_cache_playing_free_room_key, 4241559)
	--end

	--local str_cache_playing_free_room_key = "cache:playing_free_room"
	--cache_redis:del(str_cache_playing_free_room_key)
end


local ok, err = pcall(logic)
if not ok then
	print(err)
else
	print("执行完毕!")
end

redis:quit()
cache_redis:quit()
