package.path = package.path .. ';luasocket/?.lua'
package.cpath = package.cpath .. ';luasocket/?.so'

local sys_print = print
local print = nil

require("cjson")
require("redis")
require("util")
require("time")

local redis_host = "pt.pwft0z.clustercfg.use1.cache.amazonaws.com"
local redis_port = 6379
local redis_pwd = ""

local redis = Redis.connect(redis_host, redis_port)
if redis_pwd and redis_pwd ~= '' then
	redis:auth(redis_pwd)
end

function print(...)

	local info = _G.debug.getinfo(2, "Sl")
	local file = info and info.short_src or "unknown"
	local line = info and info.currentline or 0

	sys_print(file .. ":" .. line, time.date(os.time()), ...)
	io.flush()
end

local function logic()

	local max_id = 1203468
	local count = 0
	for i = 100001, max_id do
		local account = i
		count = count + 1

		local user_key = "dpzj:users:" .. account
		local avatar = redis:hget(user_key, "avatar")
		if avatar and string.find(avatar, "http:") then
			avatar = string.gsub(avatar, "http:", "https:")
			redis:hset(user_key, "avatar", avatar)
		end

		if count % 1000 == 0 then
			print("当前进度", count)
		end
	end

	for i = 100000, 999999 do
		local club_id = i
		local club_key = "dpzj:club:details:" .. club_id
		local avatar = redis:hget(club_key, "avatar")
		if avatar and string.find(avatar, "http:") then
			avatar = string.gsub(avatar, "http:", "https:")
			redis:hset(club_key, "avatar", avatar)
		end
	end
end

local ok, err = pcall(logic)
if not ok then
	print(err)
else
	print("执行完毕!")
end

redis:quit()
