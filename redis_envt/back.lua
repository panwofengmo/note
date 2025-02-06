package.path = package.path .. ';luasocket/?.lua'
package.cpath = package.cpath .. ';luasocket/?.so'

local sys_print = print
local print = nil

require("util")
require("time")
require("cutil")

function print(...)

	local info = _G.debug.getinfo(2, "Sl")
	local file = info and info.short_src or "unknown"
	local line = info and info.currentline or 0

	local now = os.time()
	local datestr = time.date(now)
	sys_print(datestr, file .. ":" .. line, ...)
	--sys_print(...)
	io.flush()
end

function logic()

	local map = {}

	local lines = util.lines_of("/root/back.log", "\n", true)
	for i=1, #lines do
		local line = lines[i]
		local values = util.split(line,"\t")
		local fid = values[4]
		local uid = values[12]
		local change = tonumber(values[7])
		local old = map[uid] or 0
		map[uid] = old + change
		--print(fid, uid, change)
	end

	for k, v in pairs(map) do
		sys_print(k, v)
	end
end

local ok, err = pcall(logic)
if not ok then
	print(err)
else
	print("执行完毕!")
end
