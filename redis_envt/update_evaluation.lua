package.path = package.path .. ';luasocket/?.lua'
package.cpath = package.cpath .. ';luasocket/?.so'

local cjson = require("cjson")
local cjson_map = cjson:new()
cjson_map.encode_sparse_array(true, 1, 1)

require("redis")
require("util")
require("time")

--local redis_host = "127.0.0.1"
--local redis_port = 6479
--local redis_pwd = ""
--
--local redis = Redis.connect(redis_host, redis_port)
--if redis_pwd and redis_pwd ~= '' then
--	redis:auth(redis_pwd)
--end
--
--local redis_host2 = "127.0.0.1"
--local redis_port2 = 6779
--local redis_pwd2 = ""
--
--local activity_redis = Redis.connect(redis_host2, redis_port2)
--if redis_pwd2 and redis_pwd2 ~= '' then
--	activity_redis:auth(redis_pwd2)
--end

local redis_host = "pt.pwft0z.clustercfg.use1.cache.amazonaws.com"
local redis_port = 6379
local redis_pwd = ""
local redis = Redis.connect(redis_host, redis_port, redis_pwd, true, true)

local activity_redis_host = "pt-activity.pwft0z.clustercfg.use1.cache.amazonaws.com"
local activity_redis_port = 6379
local activity_redis_pwd = ""
local activity_redis = Redis.connect(activity_redis_host, activity_redis_port, activity_redis_pwd, true, true)

--mysql
local luasql = require("luasql.mysql")

local mysql_host = "pt-game-log.cluster-ro-cxanuay0huhb.us-east-1.rds.amazonaws.com"
local mysql_port = 3306
local mysql_user = "root"
local mysql_pwd = "Aidian927"
local mysql_dbname = "dpzj_gamelog"

local env = luasql.mysql()
local conn = env:connect(mysql_dbname, mysql_user, mysql_pwd, mysql_host, mysql_port)
conn:execute("set names utf8mb4")

function update_eva_count(account, int_type)

	local sql = "select count(*) from evaluation_record where franchiser=%s and evaluation=%s;"
	sql = string.format(sql, account, int_type)
	local cur = conn:execute(sql)
	local row = cur:fetch({}, "a")
	local int_count = 0
	while row do
		int_count = row["count(*)"]
		row = cur:fetch({}, "a")
	end
	--redis:hset("dpzj:users:" .. account, "evaluation_type" .. int_type, int_count)
	print(account, int_type, int_count)
end

function find_all_franchiser(account)

	local tab_all_franchisers = {}
	local sql = "select distinct franchiser from evaluation_record;"
	sql = string.format(sql, account, int_type)
	local cur = conn:execute(sql)
	local row = cur:fetch({}, "a")
	while row do
		table.insert(tab_all_franchisers, row.franchiser)
	    row = cur:fetch({}, "a")
	end
	return tab_all_franchisers
end

function update_eva_redis_count()

	local tab_all_franchisers = find_all_franchiser(account)
	for i = 1, #tab_all_franchisers do
		local account = tab_all_franchisers[i]
		update_eva_count(account, 1)
		update_eva_count(account, 2)
	end
end

local ok, err = pcall(update_eva_redis_count)
if not ok then
	print(err)
else
	print("执行完毕", time.date(os.time()))
end

conn:close()
env:close()

redis:quit()
