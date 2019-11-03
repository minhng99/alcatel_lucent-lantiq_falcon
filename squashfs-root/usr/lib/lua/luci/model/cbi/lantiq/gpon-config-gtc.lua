--[[
LuCI - Lua Configuration Interface

Copyright 2011 Ralph Hempel <ralph.hempel@lantiq.com>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

]]--

require("luci.tools.gpon")

m = Map("gpon")

s = m:section(NamedSection, "ploam", "ploam")

v = s:option(Value, "nPassword", "Password")

v.addremove = false
v.rmempty = false

gtcsng = cli("gtcsng")
s1, s2 = string.match(gtcsng, "(.-) (.+)")
if s2 then
	s1, s2 = string.match(s2, "(.-)=\"(.+)\"")
end

if s2 then
	serial = s:option(Value, "serial_number", "Serial Number")
	serial.value = s2
	serial.addremove = false
end

return m
