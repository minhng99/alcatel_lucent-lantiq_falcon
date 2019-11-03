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

s = m:section(NamedSection, "ethernet", "ethernet")

for k=0,3 do
	v = s:option(Flag, "bUNI_PortEnable"..k, "LAN "..k.." - Enable")
	v.addremove = false
	v.rmempty = false
end

return m
