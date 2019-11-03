--[[
LuCI - Lua Configuration Interface

Copyright 2011 Ralph Hempel <ralph.hempel@lantiq.com>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

]]--
module("luci.controller.lantiq.gpon", package.seeall)
require("luci.tools.gpon")

function index()
	luci.i18n.loadc("admin-core")
	local i18n = luci.i18n.translate
	entry({"admin", "gpon"}, alias("admin", "gpon", "status"), i18n("GPON"), 80).index = true
	entry({"admin", "gpon", "status"},  call("action_status"), i18n("Status"), 20).index = true
	entry({"admin", "gpon", "laser"}, template("lantiq/gpon-temperature"), i18n("Laser Temperature"), 30).index = true
	entry({"admin", "gpon", "temperature"}, call("action_temperature")).index = true
	entry({"admin", "gpon", "config-omci"}, cbi("lantiq/gpon-config-omci"), i18n("OMCI Configuration"), 40).index = true
	entry({"admin", "gpon", "config-gtc"}, cbi("lantiq/gpon-config-gtc"), i18n("GTC Configuration"), 50).index = true
	entry({"admin", "gpon", "config-lan"}, cbi("lantiq/gpon-config-lan"), i18n("LAN Configuration"), 60).index = true
	entry({"admin", "gpon", "config-goi"}, cbi("lantiq/gpon-config-goi"), i18n("GOI Configuration"), 70).index = true
end

function action_status()
	local vg = split_val(cli("vig"))
	local sg = split_val(cli("ploamsg"))
	luci.template.render("lantiq/gpon-status", {
		gpon_drv_version = trim2(assign_value(vg, "onu_version")),
		gpon_current_state = assign_value(sg, "curr_state"),
	})
end

function action_temperature()
	local fs = require "luci.fs"
	if fs.access("/proc/driver/optic/temperatures") then
	luci.http.prepare_content("application/json")
		local bwc = io.popen("cat /proc/driver/optic/temperatures")
		if bwc then
	luci.http.write("[")
			while true do
				local ln = bwc:read("*l")
				if not ln then break end
				luci.http.write(ln)
			end
	luci.http.write("]")
			bwc:close()
		end
		return
	end
	luci.http.status(404, "No data available")
end


