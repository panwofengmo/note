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

function print(...)

	local info = _G.debug.getinfo(2, "Sl")
	local file = info and info.short_src or "unknown"
	local line = info and info.currentline or 0

	sys_print(file .. ":" .. line, ...)
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

function bingo_template_set()

    local obj1 = {}
	--table.insert(obj1, {1, "1", 15})
	table.insert(obj1, {1, "9", 15})
	table.insert(obj1, {2, "3", 25})
	table.insert(obj1, {3, "7,8", 60, "", "010203060711131925,01030507091113151719212325,010506070910111315161719202125"})
    local info1 = {}
    info1.name = "3 in 1"
    info1.template_id = 1
    info1.template_info = obj1
    info1.order = 1
	info1.group = 1
    print(cjson.encode(info1))

    local obj2 = {}
    --table.insert(obj2, {1, "1,2", 10})
    table.insert(obj2, {1, "9,2", 10})
    table.insert(obj2, {2, "6,5,4", 22, "18"})
    table.insert(obj2, {3, "8", 63})
    table.insert(obj2, {4, "0", 5})
    local info2 = {}
    info2.name = "4 in 1"
    info2.template_id = 2
    info2.template_info = obj2
    info2.order = 2
	info2.group = 2
    print(cjson.encode(info2))

    local obj3 = {}
    --table.insert(obj3, {1, "1,2", 6})
    table.insert(obj3, {1, "9,2", 6})
    table.insert(obj3, {2, "6,5,4", 12, "18"})
    table.insert(obj3, {3, "7", 20, "", "010203060711131925,01030507091113151719212325,010506070910111315161719202125"})
    table.insert(obj3, {4, "8", 58})
    table.insert(obj3, {5, "0", 4})
    local info3 = {}
    info3.name = "5 in 1"
    info3.template_id = 3
    info3.template_info = obj3
    info3.order = 3
	info3.group = 2
    print(cjson.encode(info3))

    local obj4 = {}
    table.insert(obj4, {1, "6,2", 6, "12"})
    table.insert(obj4, {2, "3,6", 8, "15"})
    table.insert(obj4, {3, "6,5,4", 12, "18"})
    table.insert(obj4, {4, "7", 20, "", "010203060711131925,01030507091113151719212325,010506070910111315161719202125"})
    table.insert(obj4, {5, "8", 50})
    table.insert(obj4, {6, "0", 4})
    local info4 = {}
    info4.name = "6 in 1"
    info4.template_id = 4
    info4.template_info = obj4
    info4.order = 4
	info4.group = 3
    print(cjson.encode(info4))


    redis:zadd("dpzj:bingo:templates", os.time(), info1.template_id)
    redis:hmset("dpzj:bingo:template:" .. info1.template_id, "id", info1.template_id, "name", info1.name, "awards", cjson.encode(obj1), "order", info1.order, "group", info1.group)

    redis:zadd("dpzj:bingo:templates", os.time(), info2.template_id)
    redis:hmset("dpzj:bingo:template:" .. info2.template_id, "id", info2.template_id, "name", info2.name, "awards", cjson.encode(obj2), "order", info2.order, "group", info2.group)

    redis:zadd("dpzj:bingo:templates", os.time(), info3.template_id)
    redis:hmset("dpzj:bingo:template:" .. info3.template_id, "id", info3.template_id, "name", info3.name, "awards", cjson.encode(obj3), "order", info3.order, "group", info3.group)

    redis:zadd("dpzj:bingo:templates", os.time(), info4.template_id)
    redis:hmset("dpzj:bingo:template:" .. info4.template_id, "id", info4.template_id, "name", info4.name, "awards", cjson.encode(obj4), "order", info4.order, "group", info4.group)

end
--bingo_template_set()
--{"template_info":[[1,"6,3",15,"12"],[2,"7",25,"","010203060711131925,01030507091113151719212325,010506070910111315161719202125"],[3,"8",60]],"name":"3 in 1","order":1,"group":1,"template_id":1}
--{"template_info":[[1,"1,2",10],[2,"6,5,4",22,"18"],[3,"8",63],[4,"0",5]],"name":"4 in 1","order":2,"group":2,"template_id":2}
--{"template_info":[[1,"1,2",6],[2,"6,5,4",12,"18"],[3,"7",20,"","010203060711131925,01030507091113151719212325,010506070910111315161719202125"],[4,"8",58],[5,"0",4]],"name":"5 in 1","order":3,"group":2,"template_id":3}
--{"template_info":[[1,"6,2",6,"12"],[2,"3,6",8,"15"],[3,"6,5,4",12,"18"],[4,"7",20,"","010203060711131925,01030507091113151719212325,010506070910111315161719202125"],[5,"8",50],[6,"0",4]],"name":"6 in 1","order":4,"group":3,"template_id":4}

redis:quit()
