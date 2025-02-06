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

function submit(list)

	local data = cjson.encode(list)

	local cmd = string.format("curl -s 'http://internal-pt-private-important-web-elb-919036738.sa-east-1.elb.amazonaws.com:8080/web/dynamicdispatcher/apple_revert_transfer_batch' --data-urlencode 'data=%s'", data)
	local file = io.popen(cmd)
	local content = file:read("*a")
	print("apple revert transfer", data, content)
end

function logic()

	local map = {}

	local cur = redshift_conn:execute("select id,apple from dpzj.game_account where apple is not null and channel_id=1002 order by id desc")
	local row = cur:fetch({}, "a")
	while row do
		local id = tonumber(row.id)
		local apple = row.apple
		map[id] = apple
		row = cur:fetch({}, "a")
	end

	local list = {}

	local lines = util.lines_of("/root/apple_transfer/apple_sm_transfer_origin.log", "\n", true)
	for i = 1, #lines do
		local line = lines[i]
		local values = util.split(line, "\t")
		local id = tonumber(values[3])
		local oldsub = values[4]
		local newsub = map[id]
		if newsub then
			print("apple revert info", id, oldsub, newsub)
			local obj = {}
			obj.id = id
			obj.oldsub = oldsub
			obj.newsub = newsub
			table.insert(list, obj)
			if #list == 1000 then
				submit(list)
				list = {}
			end
		end
	end

	if #list > 0 then
		submit(list)
	end
end

local ok, err = pcall(logic)
if not ok then
	print(err)
else
	print("执行完毕.......")
end

redshift_conn:close()
redshift_env:close()
