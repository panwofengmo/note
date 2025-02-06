package.path = package.path .. ';luasocket/?.lua'
package.cpath = package.cpath .. ';luasocket/?.so'

local time = require("time")
local cjson = require("cjson")
local luasql = require("luasql.postgres")
require("util")
require("cutil")
require("redis")

local start_time = time.time("2023-12-21")
local end_time = time.time("2024-01-03")
local path = "/logdata/%s/wheel_record.log"

-- Redshift
local db_name = "game"
local db_user = "root"
local db_pwd = "Aidian927"
local db_addr = "pt.cexyokp4uur5.us-east-1.redshift.amazonaws.com"
local db_port = 5439

local env = luasql.postgres()
local conn = env:connect(db_name, db_user, db_pwd, db_addr, db_port)

function get_user_create_time(start_time)

	local create_time_start = time.date(start_time)
	local create_time_end = time.date(start_time + 86400)

	local sql = string.format("select id from dpzj.tbl_user where create_time>='%s' and create_time < '%s'", create_time_start, create_time_end)
	local cur, err = conn:execute(sql)
	if err then
		print(err)
		return
	end

	local data = {}
	local row = cur:fetch({}, "a")
	while row do
		local uid = tonumber(row.id) or 0
		if uid > 0 then
			table.insert(data, uid)
		end

		row = cur:fetch({}, "a")
	end

	cur:close()
	return data
end

function get_wheel_record_log(start_time, end_time)

	local prev_tab = {}
	local cur_time = start_time
	while cur_time <= end_time + 86400 do
		local cur_time_str = time.date(cur_time, true)
		print(string.format("正在检索%s的转盘数据:", cur_time_str))
		local data = get_user_create_time(cur_time)
		print("当天注册玩家检索完毕", #data)

		local cur_result = {}
		local prev_result = {}
		local cur_path = string.format(path, cur_time_str)
		local cur_file = cutil.open(cur_path)
		if cur_file then
			while true do
				local content = cutil.line(cur_file)
				if not content then
					break
				end

				local values = util.split(content, "\t")
				local wheel_type = tonumber(values[2])
				if wheel_type == 2 then
					local account = tonumber(values[3])
					if account then
						if util.list_has(data, account) and not util.list_has(cur_result, account) then
							table.insert(cur_result, account)
						end
						if util.list_has(prev_tab, account) and not util.list_has(prev_result, account) then
							table.insert(prev_result, account)
						end
					end
				end
			end
		end
		print("当天记录检索完毕", #cur_result, #prev_result)
		print(string.format("a=%s,b=%s,result=%s", #prev_tab, #prev_result, #prev_tab > 0 and #prev_result / #prev_tab or 0))

		prev_tab = cur_result
		cur_time = cur_time + 86400
	end
end

local function logic()
 	get_wheel_record_log(start_time, end_time)
end

local ok, err = pcall(logic)
if not ok then
	print(err)
else
	print("执行完毕!", time.date(os.time()))
end

