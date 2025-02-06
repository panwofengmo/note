package.path = package.path .. ';luasocket/?.lua'
package.cpath = package.cpath .. ';luasocket/?.so'

local time = require("time")
local cjson = require("cjson")
local luasql = require("luasql.postgres")
require("util")
require("cutil")
require("redis")

local start_time = time.time("2024-01-03")
local end_time = time.time("2024-01-13")

-- Redshift
local db_name = "game"
local db_user = "root"
local db_pwd = "Aidian927"
local db_addr = "pt.cexyokp4uur5.us-east-1.redshift.amazonaws.com"
local db_port = 5439

local env = luasql.postgres()
local conn = env:connect(db_name, db_user, db_pwd, db_addr, db_port)

local function logic()

	local cur_time = start_time
	while cur_time <= end_time do
		local cur_time_str = time.date(cur_time, true)
		local next_time_str = time.date(cur_time + 86400, true)
		print(string.format("正在检索%s的limbo数据", cur_time_str))

		local create_time_start = time.date(cur_time)
		local create_time_end = time.date(cur_time + 86400)

		-- 获取分母a
		local sql1 = string.format("select count(distinct u.id) c from dpzj.tbl_user u inner join dpzj_gamelog.log_limbo_inning_account l1 on u.id = l1.uid where l1.start_date = '%s' and u.create_time >= '%s' and u.create_time < '%s'", cur_time_str, create_time_start, create_time_end)
		local cur, err = conn:execute(sql1)
		if err then
			print(err)
			return
		end

		local row = cur:fetch({}, "a")
		local a = tonumber(row.c) or 0
		cur:close()

		if a > 0 then
			-- 获取分子b
			local sql2 = string.format("select count(distinct u.id) c from dpzj.tbl_user u inner join dpzj_gamelog.log_limbo_inning_account l1 on u.id = l1.uid inner join dpzj_gamelog.log_limbo_inning_account l2 on u.id = l2.uid where l1.start_date = '%s' and l2.start_date = '%s' and u.create_time >= '%s' and u.create_time < '%s'", cur_time_str, next_time_str, create_time_start, create_time_end)
			local cur, err = conn:execute(sql2)
			if err then
				print(err)
				return
			end

			local row = cur:fetch({}, "a")
			local b = tonumber(row.c) or 0
			cur:close()

			print(string.format("当天a = %s, b = %s, 次流为%s", a, b, b/a))
		else
			print("当天a = 0, b = 0, 次流为0")
		end
		cur_time = cur_time + 86400
	end
end

local ok, err = pcall(logic)
if not ok then
	print(err)
else
	print("执行完毕!", time.date(os.time()))
end

