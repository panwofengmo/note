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

	sys_print(file .. ":" .. line, time.date(os.time()), ...)
	io.flush()
end

local function fixed(date)

	local path = "/logdata/" .. date .. "/silver_rooms.log"
	local file = cutil.open(path)
	if not file then
		print("文件不存在", date, path)
		return
	end

	local wpath = string.format("silver_rooms_%s.log", date)
	local wfile = cutil.open(wpath, "rw")

	local lasttime = time.time(date)
	while true do
		local content = cutil.line(file)
		if not content then
			break
		end

		local update = false

		local values = util.split(content, "\t")
		local datetime = tonumber(values[8]) or 0
		if datetime > 0 then
			lasttime = datetime
		else
			datetime = lasttime
			values[8] = datetime
			update = true
		end

		if #values > 8 then
			for i = 9, 15 do
				values[i] = nil
			end
			update = true
		end

		if update then
			content = table.concat(values, "\t")
		end
		cutil.writeline(wfile, content)
	end

	cutil.close(wfile)
	cutil.close(file)
end

local function logic()

	fixed('2023-02-24')
	fixed('2023-02-25')
	fixed('2023-02-26')
	fixed('2023-02-27')
	fixed('2023-02-28')
end

local ok, err = pcall(logic)
if not ok then
	print(err)
else
	print("执行完毕!")
end
