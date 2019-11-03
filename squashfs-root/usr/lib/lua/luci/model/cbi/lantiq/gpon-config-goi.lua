--[[
LuCI - Lua Configuration Interface

Copyright 2011 Ralph Hempel <ralph.hempel@lantiq.com>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

]]--

require("luci.tools.gpon")
require("luci.sys")

-- UCI config file /etc/config/goi_config
m = Map("goi_config", "GOI Configuration", "Here you can configure the GPON Optic Interface.")
-- 'transmitter' - section
s = m:section(NamedSection, "transmitter", "transmitter", "Optical Transmitter configuration")

-- 'TxEnableDelay' - option
v = s:option(Value, "TxEnableDelay", "TX FIFO start [bits]")
v.addremove = false -- don't let the user add/remove this option
v.rmempty = false -- don't let the user to remove entry from config file if it is empty

v = s:option(Value, "TxDisableDelay", "TX FIFO stop [bits]")
v.addremove = false -- don't let the user add/remove this option
v.rmempty = false -- don't let the user to remove entry from config file if it is empty

return m
