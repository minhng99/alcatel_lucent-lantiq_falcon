--[[
LuCI - Lua Configuration Interface

Copyright 2011 Ralph Hempel <ralph.hempel@lantiq.com>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

]]--

require("luci.tools.gpon")

m = Map("omci")

s = m:section(NamedSection, "default", "default")
s.anonymous = true
s.addremove = false

v = s:option(Value, "mib_file", "MIB file")
v.addremove = false
v.rmempty = false

return m
