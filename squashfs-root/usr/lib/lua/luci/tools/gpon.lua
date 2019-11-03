
-- module("luci.tools.gpon", package.seeall)
require("luci.util")

--- Trim a string.
-- @return	Trimmed string
function trim(s)
	return (string.gsub(s, "^%s*(.-)%s*$", "%1"))
end

function trim2(s)
	return (string.gsub(s, "^\"(.-)\"$", "%1"))
end

--- Retrieves the output of the onu command.
-- @return	String containing the current buffer
function cli(command)
	local s = "/opt/lantiq/bin/onu " .. command
	return trim(luci.util.exec(s))
end

--- Split the CLI string into a table.
-- @return	Value Table
function split_val(s)
	local t = {}
	local s1, s2, s3, s4
	repeat
		s1, s2 = string.match(s, "(.-) (.+)")
		if s1 then
			s3, s4 = string.match(s1, "(.-)=(.+)")
			if s3 and s4 then
				t[s3] = s4
			end
			s = s2
		else
			s3, s4 = string.match(s, "(.-)=(.+)")
			if s3 and s4 then
				t[s3] = s4
			end
		end
	until s1 == nil
	return t
end

function return_val(s, val)
	if s == nil then return "table is invalid" end
	if val == nil then return "index is invalid" end
	local v = tonumber(val)
	if v == nil then
		return val
	end
	if s[v] == nil then
		return v
	else
		return s[v]
	end
end

function decode_error_code(val)
	local s = {}
	s[-1]="oops"
	return return_val(s, val)
end

function assign_value(t, v)
	if t['errorcode'] == nil then
		return "invalid response"
	end
	if tonumber(t['errorcode']) < 0 then
		return decode_error_code(t['errorcode'])
	end
	if t[v] == nil then
		return "value not found"
	else
		return t[v]
	end
end
