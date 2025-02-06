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

	local path = "/logdata/" .. date .. "/silver.log"
	local file = cutil.open(path)
	if not file then
		print("文件不存在", date, path)
		return
	end

	local accounts = {}

	local wpath = string.format("silver_%s.log", date)
	local wfile = cutil.open(wpath, "rw")

	while true do
		local content = cutil.line(file)
		if not content then
			break
		end

		local values = util.split(content, "\t")
		local prev = tonumber(values[6])
		local change = tonumber(values[7])
		local last = tonumber(values[8])
		local remark = values[10]
		local prev1 = prev
		local change1 = change
		local last1 = last
		local remark1 = remark
		if math.floor(prev) ~= prev or math.ceil(prev) ~= prev then
			prev = math.floor(prev)
		end
		if math.floor(change) ~= change or math.ceil(change) ~= change then
			change = math.floor(change)
		end
		if math.floor(last) ~= last or math.ceil(last) ~= last then
			last = math.floor(last)
		end
		--[[
		if string.find(remark, "拉力赛台费抽取") then
			local vv = util.split(remark, "_")
			local str = vv[#vv]
			if string.find(str, "%.") then
				str = string.format("%d", tonumber(str) * 10000)
				vv[#vv] = str
				remark = table.concat(vv, "_")
			end
		end
		--]]

		local account = tonumber(values[4])
		accounts[account] = last1

		if prev ~= prev1 or change ~= change1 or last ~= last1 or remark ~= remark1 then
			--print("update data", prev, change, last, remark, prev1, change1, last1, remark1, time.date(tonumber(values[11])))
			values[6] = prev
			values[7] = change
			values[8] = last
			values[10] = remark
			content = table.concat(values, "\t")
		end
		cutil.writeline(wfile, content)
	end

	cutil.close(wfile)
	cutil.close(file)

	for account, last in pairs(accounts) do
		if math.floor(last) ~= last or math.ceil(last) ~= last then
			print(account, last)
		end
	end
end

local function logic()

	fixed('2022-10-19')
end

local ok, err = pcall(logic)
if not ok then
	print(err)
else
	print("执行完毕!")
end
