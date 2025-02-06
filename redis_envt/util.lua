local modname = "util"
local _M = {}
_G[modname] = _M
setmetatable(_M, {__index = _G})
local _ENV = _M

function serialize(t)

	local mark = {}
	local assign = {}

	local function ser_table(tbl, parent)
		mark[tbl] = parent
		local tmp = {}
		for k, v in pairs(tbl) do
			local keytype = type(k)
			if keytype ~= "table" and keytype ~= "nil" then
				local key = keytype == "number" and "[" .. k .. "]" or "[\"" .. k .. "\"]"
				local vtype = type(v)
				if vtype == "table" then
					local dotkey= parent .. (type(k) == "number" and key or "." .. key)
					if mark[v] then
						table.insert(assign, dotkey .. "=" .. mark[v])
					else
						table.insert(tmp, key .. "=" .. ser_table(v, dotkey))
					end
				else
					local tv = v
					if vtype == "string" then
						tv = string.format('"%s"', string_escape(tv))
					end
					table.insert(tmp, key .. "=" .. tostring(tv))
				end
			end
		end
		return "{" .. table.concat(tmp, ",") .. "}"
	end

	return "local ret=" .. ser_table(t," ret") .. table.concat(assign," ") .. " return ret"
end

function deserialize(str)
	return loadstring(str)()
end

function protobuf_to_table(message)

	local result = {}

	local function _protobuf_to_json(tbl, m)
		local fields = m._fields
		if fields then
			for field, v in pairs(fields) do
				local property_name = field.name
				local vtype = type(v)
				if vtype ~= "table" then
					tbl[property_name] = v
				else
					local t = {}
					tbl[property_name] = _protobuf_to_json(t, v)
				end
			end
		else
			local len = #m
			for k = 1, len do
				local v = m[k]
				local vtype = type(v)
				if vtype ~= "table" then
					table.insert(tbl, v)
				else
					local t = {}
					table.insert(tbl, t)

					_protobuf_to_json(t, v)
				end
			end
		end
		return tbl
	end

	return _protobuf_to_json(result, message)
end

function protobuf_full_to_table(message)

	local result = {}

	local function _protobuf_full_to_table(tbl, m)

		local meta = getmetatable(m)
		local fields = meta._descriptor.fields
		for i = 1, #fields do
			local field = fields[i]
			local label = field.label
			local cpp_type = field.cpp_type
			local property_name = field.name

			if label == 3 then
				local v = m[property_name]
				local len = v and #v or 0
				if len > 0 then
					local arr = {}
					tbl[property_name] = arr

					--10是message类型
					if cpp_type ~= 10 then
						for i = 1, len do
							table.insert(arr, v[i])
						end
					else
						for i = 1, len do
							local t = {}
							_protobuf_full_to_table(t, v[i])
							table.insert(arr, t)
						end
					end
				end
			else
				--10是message类型
				if cpp_type ~= 10 then
					tbl[property_name] = m[property_name]
				else
					local t = {}
					tbl[property_name] = _protobuf_full_to_table(t, m[property_name])
				end
			end
		end

		return tbl
	end

	return _protobuf_full_to_table(result, message)
end

local mysql_escape_char = "[%z\'\"\\\26\b\n\r\t]"
local mysql_escape_replace = {['\0']='\\0', ['\''] = '\\\'', ['\"'] = '\\\"', ['\\'] = '\\\\', ['\26'] = '\\z', ['\b'] = '\\b', ['\n'] = '\\n', ['\r'] = '\\r', ['\t'] = '\\t'}

function mysql_escape(str)
	if not str then
		return
	end

	str = string.gsub(str, mysql_escape_char, mysql_escape_replace)
	return str
end

local escape_char = "[\'\"\\\n\r\t]"
local escape_replace = {['\''] = '\\\'', ['\"'] = '\\\"', ['\\'] = '\\\\', ['\n'] = '\\n', ['\r'] = '\\r', ['\t'] = '\\t'}

function string_escape(str)
	if not str then
		return
	end

	str = string.gsub(str, escape_char, escape_replace)
	return str
end

local escape_simple_char = "[\n\r\t]"
local escape_simple_replace = {['\n'] = '\\n', ['\r'] = '\\r', ['\t'] = '\\t'}

function string_escape_simple(str)
	if not str then
		return
	end

	str = string.gsub(str, escape_simple_char, escape_simple_replace)
	return str
end

function utfstrlen(str)
	local len = #str
	local left = len
	local count = 0
	local arr = {0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc}

	while left ~= 0 do
		local tmp = string.byte(str, -left)
		local i = #arr
		while arr[i] do
			if tmp >= arr[i] then
				left = left - i
				break
			end
			i = i - 1
		end
		count = count + 1
	end
	return count
end

function trim(s)
	return (string.gsub(s, "^%s*(.-)%s*$", "%1")) 
end

function name_rule(str, num)
	local len = #str
	local while_index = 1
	local left = 1
	local arr = {0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc}

	local left_white = true
	local right_white_count = 0

	local count = 0

	while while_index <= len do
		local tmp = string.byte(str, left)

		local byte_count = 1
		local i = #arr
		while arr[i] do
			if tmp >= arr[i] then
				while_index = while_index + i
				byte_count = i
				break
			end
			i = i - 1
		end

		if tmp == 32 then
			if not left_white then
				right_white_count = right_white_count + 1
			end
		end

		local filter = false

		if byte_count == 1 then
			if not ((tmp >= 48 and tmp <= 57) or (tmp >= 65 and tmp <= 90) or (tmp >= 97 and tmp <= 122) or (tmp >= 33 and tmp <= 47) or (tmp >= 58 and tmp <= 64) or (tmp >= 91 and tmp <= 96) or (tmp >= 123 and tmp <= 126)) then
				if tmp ~= 32 or left_white then
					filter = true
				end
			elseif tmp == 39 or tmp == 92 then
				filter = true
			end
		elseif byte_count == 3 then
			local tmp_1 = string.byte(str, left + 1)
			local tmp_2 = string.byte(str, left + 2)
			if (tmp >= 228 and tmp <= 233) and (tmp_1 >= 128 and tmp_1 <= 191) and (tmp_2 >= 128 and tmp_2 <= 191) then
				if (tmp == 228 and tmp_1 < 184) or (tmp == 233 and (tmp_1 > 190 or (tmp_1 == 190 and tmp_2 > 165))) then
					fliter = true
				end
			else
				filter = true
			end
		else
			filter = true
		end

		if filter then
			if left == 1 then
				str = string.sub(str, left + byte_count)
			else
				str = string.sub(str, 1, left - 1) .. string.sub(str, left + byte_count)
			end
			byte_count = 0
		end

		if tmp ~= 32 and not filter then
			left_white = false
			right_white_count = 0
		end

		left = left + byte_count
		if byte_count > 0 then
			count = count + 1
			if num and num == count then
				str = string.sub(str, 1, left - 1)
				break
			end
		end
	end

	if right_white_count > 0 then
		count = count - right_white_count
		str = string.sub(str, 1, - (right_white_count + 1))
	end

	return str, count
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

function read(filename)

	local file = io.open(filename)
	if file then
		local content = file:read("*a")
		file:close()
		return content
	end
end

function lines_of(filename, separate, filter_end_empty_lines)

	local content = read(filename)
	if content then
		local lines = split(content, separate)
		if filter_end_empty_lines then
			--过滤后面的空行
			for l = #lines, 1, -1 do
				local line = lines[l]
				if not line or line == "" then
					table.remove(lines, l)
				else
					break
				end
			end
		end

		return lines
	end
end

function empty_string(str, default)

	if not str or str == '' then
		return default
	end

	return str
end

function is_empty(str)

	return not str or str == '' and true or false
end

function not_empty(str)

	return str and str ~= '' and true or false
end

function list_has_index(list, obj)

	for i = 1, #list do
		if list[i] == obj then
			return i
		end
	end

	return nil
end

function list_has(list, obj)

	for i = 1, #list do
		if list[i] == obj then
			return true
		end
	end

	return false
end

function object_list_has(list, key, obj)

	for i = 1, #list do
		local o = list[i]
		local v = o[key]
		if v == obj then
			return true
		end
	end

	return false
end

function from_object_list(list, key)

	local result = {}

	for i = 1, #list do
		local obj = list[i]
		local v = obj[key]
		if v ~= nil then
			table.insert(result, v)
		end
	end

	return result
end

function from_object_map(map, key)

	local result = {}

	for _, obj in pairs(map) do
		local v = obj[key]
		if v ~= nil then
			table.insert(result, v)
		end
	end

	return result
end

function from_map_key(map)

	local result = {}

	for k, _ in pairs(map) do
		table.insert(result, k)
	end

	return result
end

function from_map_value(map)

	local result = {}

	for _, v in pairs(map) do
		table.insert(result, v)
	end

	return result
end

function get_gps_distance(lat1, lng1, lat2, lng2)

	local EARTH_RADIUS = 6378.137

	lat1 = lat1 * math.pi / 180
	lng1 = lng1 * math.pi / 180
	lat2 = lat2 * math.pi / 180
	lng2 = lng2 * math.pi / 180

	local a = lat1 - lat2
	local b = lng1 - lng2

	local d = 2 * math.asin(math.sqrt(math.pow(math.sin(a / 2), 2) + math.cos(lat1)*math.cos(lat2)*math.pow(math.sin(b / 2), 2)))
	d = math.floor(d * EARTH_RADIUS * 1000)

	return d
end


BYTE_MIN = -128
BYTE_MAX = 127

UBYTE_MIN = 0
UBYTE_MAX = 255

SHORT_MIN = -32768
SHORT_MAX = 32767

USHORT_MIN = 0
USHORT_MAX = 65535

INT_MIN = -2147483648
INT_MAX = 2147483647

UINT_MIN = 0
UINT_MAX = 4294967295


LONG_MIN = -4503599627370496
LONG_MAX = 4503599627370495

LONG_MIN = 0
LONG_MAX = 9007199254740991

function cnumber_add(min, max, num, value)

	local v = num + value
	while v > max do
		v = v - (max - min + 1)
	end

	while v < min do
		v = v + (max - min + 1)
	end

	return v
end

function byte_incr(num)

	return cnumber_add(BYTE_MIN, BYTE_MAX, num, 1)
end

function ubyte_incr(num)

	return cnumber_add(UBYTE_MIN, UBYTE_MAX, num, 1)
end

function short_incr(num)

	return cnumber_add(SHORT_MIN, SHORT_MAX, num, 1)
end

function ushort_incr(num)

	return cnumber_add(USHORT_MIN, USHORT_MAX, num, 1)
end

function int_incr(num)

	return cnumber_add(INT_MIN, INT_MAX, num, 1)
end

function uint_incr(num)

	return cnumber_add(UINT_MIN, UINT_MAX, num, 1)
end

function long_incr(num)

	return cnumber_add(LONG_MIN, LONG_MAX, num, 1)
end

function Ulong_incr(num)

	return cnumber_add(ULONG_MIN, ULONG_MAX, num, 1)
end


function byte_decr(num)

	return cnumber_add(BYTE_MIN, BYTE_MAX, num, -1)
end

function ubyte_decr(num)

	return cnumber_add(UBYTE_MIN, UBYTE_MAX, num, -1)
end

function short_decr(num)

	return cnumber_add(SHORT_MIN, SHORT_MAX, num, -1)
end

function ushort_decr(num)

	return cnumber_add(USHORT_MIN, USHORT_MAX, num, -1)
end

function int_decr(num)

	return cnumber_add(INT_MIN, INT_MAX, num, -1)
end

function uint_decr(num)

	return cnumber_add(UINT_MIN, UINT_MAX, num, -1)
end

function long_decr(num)

	return cnumber_add(LONG_MIN, LONG_MAX, num, -1)
end

function Ulong_decr(num)

	return cnumber_add(ULONG_MIN, ULONG_MAX, num, -1)
end

function floor(num)
	return math.floor(num + 0.000001)
end

function ceil(num)
	return math.ceil(num - 0.000001)
end

return _M
