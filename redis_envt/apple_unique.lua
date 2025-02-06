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

local redshift_luasql = require("luasql.postgres")
local redshift_db_name = "game"
local redshift_db_user = "root"
local redshift_db_pwd = "Aidian927"
local redshift_db_addr = "pt.cexyokp4uur5.us-east-1.redshift.amazonaws.com"
local redshift_db_port = 5439
local redshift_env = redshift_luasql.postgres()
local redshift_conn = redshift_env:connect(redshift_db_name, redshift_db_user, redshift_db_pwd, redshift_db_addr, redshift_db_port)

function print(...)

	local info = _G.debug.getinfo(2, "Sl")
	local file = info and info.short_src or "unknown"
	local line = info and info.currentline or 0

	local now = os.time()
	local datestr = time.date(now)
	sys_print(datestr, file .. ":" .. line, ...)
	io.flush()
end

function logic()

	local sql = "select lt.id keepid,lt.apple apple,gt.id clearid from (select a.id,a.create_time,t.apple,a.channel_id,row_number() over(partition by a.apple order by create_time) r from (SELECT apple,count(*) c from dpzj.game_account where apple is not null group by apple HAVING c>1) t join dpzj.game_account a on t.apple=a.apple order by apple) lt join (select a.id,a.create_time,t.apple,a.channel_id,row_number() over(partition by a.apple order by create_time) r from (SELECT apple,count(*) c from dpzj.game_account where apple is not null group by apple HAVING c>1) t join dpzj.game_account a on t.apple=a.apple order by apple) gt on lt.apple=gt.apple and lt.r=1 where gt.r > 1 order by lt.apple"
	local cur = redshift_conn:execute(sql)
	local row = cur:fetch({}, "a")
	while row do
		local keepid = tonumber(row.keepid)
		local clearid = tonumber(row.clearid)
		local apple = row.apple

		local cmd = string.format("curl -s 'http://internal-pt-private-important-web-elb-919036738.sa-east-1.elb.amazonaws.com:8080/web/dynamicdispatcher/apple_unique_clear?keepid=%d&clearid=%d&sub=%s'", keepid, clearid, apple)
		local file = io.popen(cmd)
		local content = file:read("*a")
		print("清理apple重复的旧账号", keepid, clearid, apple, content)

		row = cur:fetch({}, "a")
	end
	cur:close()
end

local ok, err = pcall(logic)
if not ok then
	print(err)
else
	print("执行完毕.......")
end

redshift_conn:close()
redshift_env:close()
