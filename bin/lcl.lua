--[[
	This file is part of lcl.

	lcl is free software: you can redistribute it and/or modify
	it under the terms of the GNU Lesser General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.

	lcl is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU Lesser General Public License for more details.

	You should have received a copy of the GNU Lesser General Public License
	along with lcl.  If not, see <http://www.gnu.org/licenses/>.
	
	Copyright (C) 2008 - 2009 Lucas Hermann Negri
--]]

require("_lcl")
--lcl = {}
function lcl.escape_capture(p)
	return p:gsub("(%W)", "%%%1")
end

---
-- Formats a string that represents a number in the current
-- locale to the string the represents a number in the C locale. Doesn't handle
-- changes in scientific notation.
--
-- @param text String representation of a number in the current locale
-- return String representation of the number in the C locale
function lcl.number_to_c(text)
	local ts, dp = lcl.getfield(lcl.THOUSANDS_SEP, lcl.DECIMAL_POINT)
	
	if ts then
		ts = lcl.escape_capture(ts)
		text = text:gsub(ts, "")
	end
	
	if dp then
		dp = lcl.escape_capture(dp)
		text = text:gsub(dp, ".", 1)
	end
	
	return text
end

---
-- Formats a string the represents a number in the C locale
-- to the string that represents a number in the current locale
--
-- @param text Number representation in the C locale
-- @param text Number representation in the current locale
function lcl.c_to_number(text)
	local dp = lcl.getfield(lcl.DECIMAL_POINT)
	text = text:gsub("%.", dp)
	return text
end

---
-- Formats a date to the current locale
--
-- @param year Date year
-- @param month Date month
-- @param day Date day
-- @return Locale-formated date, as a string
function lcl.c_to_date(year, month, day)
	local ct = os.time({["year"] = year, ["month"] = month, ["day"] = day})
	
	return os.date("%x", ct)
end

---
-- Splits a date in the format cp1/cp2/cp3 to the three components, where / is
-- a separator
--
-- @param dateStr String containing the datw
-- @return year, month and day
function lcl.parse_date(dateStr)
	if not dateStr then
		return
	else
		local it1, it2 = dateStr:find("%d+")
		if not it1 or not it2 then return end
		local cp1 = dateStr:sub(it1, it2)
		
		it1, it2 = dateStr:find("%d+", it2 + 2)
		if not it1 or not it2 then return end
		local cp2 = dateStr:sub(it1, it2)
		
		it1, it2 = dateStr:find("%d+", it2 + 2)
		if not it1 or not it2 then return end
		local cp3 = dateStr:sub(it1, it2)
		
		return cp1, cp2, cp3
	end
end

local dummyd = {
	["2003"] = "year", ["03"] = "year", ["3"] = "year",
	["05"] = "month", ["5"] = "month",
	["07"] = "day", ["7"] = "day",
}

---
-- Try to guess the date format of the current locale
--
-- @return Tree components ("year", "month" and "day"), in the order of the
-- current locale
function lcl.get_date_format()
	local ct = os.time{["year"] = 2003, ["month"] = 5, ["day"] = 7}
	local a, b, c = lcl.parse_date(os.date("%x", ct))
	return dummyd[a], dummyd[b], dummyd[c]
end
