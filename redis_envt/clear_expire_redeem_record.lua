package.path = package.path .. ';/root/redis_envt/?.lua;luasocket/?.lua'
package.cpath = package.cpath .. ';/root/redis_envt/?.so;luasocket/?.so'

require("time")

local db_name = "dpzj_gamelog"
local db_user = "root"
local db_pwd = "Aidian927"
-- 写连接
-- local db_addr = "pt-game-log.cluster-cxanuay0huhb.us-east-1.rds.amazonaws.com"
-- 只读连接
local db_addr = "pt-game-log.cluster-ro-cxanuay0huhb.us-east-1.rds.amazonaws.com"
local db_port = 3306

print("数据表清理脚本执行开始")

local luasql = require("luasql.mysql")
local env = luasql.mysql()
local conn = env:connect(db_name, db_user, db_pwd, db_addr, db_port)
conn:execute("set names utf8mb4")

function logic()
	local now = os.time()
	local check_date = time.date(now - 30 * 86400)
	local sql = string.format("delete from franchiser_redeem_record where date < '%s'", check_date)
	print(string.format("预执行sql:%s", sql))
	-- conn:execute(sql)
end

local ok, err = pcall(logic)
if not ok then
	print(err)
else
	print("franchiser_redeem_record清理脚本执行完毕!")
end

conn:close()
env:close()
