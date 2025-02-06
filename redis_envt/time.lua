local modname = "time"
local _M = {}
_G[modname] = _M
setmetatable(_M, {__index = _G})
local _ENV = _M

local month_days = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}

--秒数转字符串
function date(time, short)

	return short and os.date("%Y-%m-%d", time) or os.date("%Y-%m-%d %H:%M:%S", time)
end

--字符串转秒数
function time(date)

	local len = #date

	local year = tonumber(string.sub(date, 1, 4))

	local month_pos = string.find(date, "-", 6)
	local month = tonumber(string.sub(date, 6, month_pos - 1))

	local day_pos = string.find(date, " ", month_pos + 1)
	local day = tonumber(string.sub(date, month_pos + 1, day_pos and day_pos - 1 or len))

	local hour = 0
	local min = 0
	local sec = 0

	if day_pos then
		local hour_pos = string.find(date, ":", day_pos + 1)
		hour = tonumber(string.sub(date, day_pos + 1, hour_pos and hour_pos - 1 or len)) or 0

		if hour_pos then
			local min_pos = string.find(date, ":", hour_pos + 1)
			min = tonumber(string.sub(date, hour_pos + 1, min_pos and min_pos - 1 or len)) or 0
			if min_pos then
				local sec_pos = string.find(date, ":", min_pos + 1)
				sec = tonumber(string.sub(date, min_pos + 1, sec_pos and sec_pos - 1 or len)) or 0
			end
		end
	end

	local st = os.time{year = year, month = month, day = day, hour = hour, min = min, sec = sec}

	return st
end

--返回当月第一天的0点秒数
function month_first_day_begin(time)

	local target_tab = os.date("*t", time)
	target_tab.day = 1
	target_tab.hour = 0
	target_tab.min = 0
	target_tab.sec = 0

	return os.time(target_tab)
end

function next_month_first_day_begin(time)

	local target_tab = os.date("*t", time)
	local year = target_tab.year
	local month = target_tab.month

	target_tab.day = 1
	target_tab.hour = 0
	target_tab.min = 0
	target_tab.sec = 0

	local result =  os.time(target_tab)
	local days = get_month_day(year, month)
	result = result + days * 86400

	return result
end

--返回当天的0点秒数
function begin(time)

	local target_tab = os.date("*t", time)
	target_tab.hour = 0
	target_tab.min = 0
	target_tab.sec = 0
	return os.time(target_tab)
end

--返回今天的0点秒数
function today()

	return begin(os.time())
end

--获取系统时区
--@return 系统时区,-3为西三区,8为东八区
function timezone()

	local zone = tonumber(os.date("%z", 0)) / 100
	return zone
end

--转换时间成指定时区
--@param t 时间戳
--@param source_timezone 时间戳t的时区
--@param target_timezone 目标时区
--@return 目标时区的时间戳
function to_timezone(t, source_timezone, target_timezone)

	t = t - source_timezone * 3600 + target_timezone * 3600
	return t
end

--将北京时间转换成本地时间
--@param t 北京时间戳
--@return 本地时间戳
function timezone_china_to_local(t)

	return to_timezone(t, 8, timezone())
end

--将成本地时间转换成北京时间
--@param t 本地时间戳
--@return 北京时间戳
function timezone_local_to_china(t)

	return to_timezone(t, timezone(), 8)
end

--返回本周周一零点秒数
function monday_time()

	local week_number = tonumber(os.date("%w", os.time()))
	week_number = week_number == 0 and 7 or week_number

	local monday_time = today() - (week_number - 1) * 86400

	return monday_time, week_number
end

--返回本周周几零点秒数
function week_time(number)

	number = number or 1

	local week_number = tonumber(os.date("%w", os.time()))
	week_number = week_number == 0 and 7 or week_number

	local week_begin = today() - (week_number - number) * 86400

	return week_begin
end

--返回count周前的周wday
function week_before(time, wday, count, inc)

	local time_tab = os.date("*t",time)
	local time_wday = time_tab.wday
	time_wday = time_wday == 1 and 7 or time_wday - 1

	count = (wday < time_wday or (wday == time_wday and inc))  and count - 1 or count

	local diff = (wday - time_wday) - count * 7
	return time + diff * 86400
end

--返回count周后的周wday
function week_after(time, wday, count, inc)

	local time_tab = os.date("*t",time)
	local time_wday = time_tab.wday
	time_wday = time_wday == 1 and 7 or time_wday - 1

	count = (wday < time_wday or (wday == time_wday and not inc)) and count or count - 1

	local diff = (wday - time_wday) + count * 7
	return time + diff * 86400
end

--返回今天的0点字符串
function today_string()

	return date(begin(os.time()))
end

--比较两个秒数是否属于同一天
function is_same_day(time1, time2)
	
	local t1 = os.date("*t", time1)
	local t2 = os.date("*t", time2)

	return t1.day == t2.day and t1.month == t2.month and t1.year == t2.year
end

--比较两个时间字符串是否属于同一天
function is_same_day_string(date1, date2)

	local d1 = string.sub(date1, 1, 10)
	local d2 = string.sub(date2, 1, 10)

	return d1 == d2
end

--判断日期秒数是否在两个中间
function time_in(t, time_start, time_end)

	return t >= time_start and t < time_end
end

--判断日期是否在两个日期中间
function time_in_string(day, start_day, end_day, exclude_end)

	local t = begin(time(day))
	local s = begin(time(start_day))
	local e = begin(time(end_day))

	local result = exclude_end and t < e or t <= e
	return result and t >= s
end

function diff_days(t1, t2)

	local s1 = begin(t1)
	local s2 = begin(t2)

	return (s2 - s1) / 86400
end

function diff_days_string(date1, date2)

	local s1 = begin(time(date1))
	local s2 = begin(time(date2))

	return (s2 - s1) / 86400
end

--闰年
function is_leap_year(year)

	return (year % 4 == 0 and year % 100 ~= 0) or year % 400 == 0
end

--月份天数
function get_month_day(year, month)

	return (month ~= 2 or not is_leap_year(year)) and month_days[month] or month_days[month] + 1
end

--增加天数
function add_days(time, days)

	return time + days * 86400
end

--增加小时
function add_hours(time, hours)

	return time + hour * 3600
end

--增加分钟
function add_minutes(time, mins)

	return time + mins * 60
end

--增加秒数
function add_seconds(time, secs)

	return time + secs
end

return _M
