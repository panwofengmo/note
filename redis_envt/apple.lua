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

	local ids = {}
	for i = 1, #list do
		local o = list[i]
		local id = o.id
		local sub = o.sub
		table.insert(ids, sub)
	end

	local cmd = string.format("curl -s 'http://internal-pt-private-important-web-elb-919036738.sa-east-1.elb.amazonaws.com:8080/web/dynamicdispatcher/apple_transfer_batch' -d 'subs=%s'", table.concat(ids, ","))
	local file = io.popen(cmd)
	local content = file:read("*a")
	print("transfer", table.concat(ids, ","), content)
end

function logic()
	--[[
	local file = io.popen("curl -s 'http://internal-pt-private-important-web-elb-919036738.sa-east-1.elb.amazonaws.com:8080/web/dynamicdispatcher/apple_transfer?sub=001268.8ae513d603d84a05ac320c0028d91eba.0815'")
	local content = file:read("*a")
	print("content is", content)
	--]]

	local list = {}

	local cur = redshift_conn:execute("select id,apple from dpzj.game_account where apple is not null and id <3437592 order by id desc")
	local row = cur:fetch({}, "a")
	while row do
		local id = tonumber(row.id)
		local apple = row.apple

		local obj = {}
		obj.id = id
		obj.sub = apple
		table.insert(list, obj)
		if #list == 1000 then
			submit(list)
			list = {}
		end
		row = cur:fetch({}, "a")
	end
	cur:close()

	if #list > 0 then
		submit(list)
	end
	--]]
end

local ok, err = pcall(logic)
if not ok then
	print(err)
else
	print("执行完毕.......")
end

redshift_conn:close()
redshift_env:close()
