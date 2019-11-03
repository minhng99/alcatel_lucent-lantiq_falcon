#!/bin/sh /etc/rc.common
# Copyright (C) 2011 OpenWrt.org
# Copyright (C) 2011 lantiq.com
START=93

#OMCID_BIN=/opt/lantiq/bin/omcid
OMCI_MGR_BIN=/opt/lantiq/bin/omciLibMgr
OMCI_PARSER_BIN=/opt/lantiq/bin/omciLibParser

status_entry_create() {
	local path=$1

	if [ ! -f "$path" ]; then
		echo >> $path
	fi
	uci set $path.ip_conflicts=status
	uci set $path.dhcp_timeouts=status
	uci set $path.dns_errors=status
}

start() {
	local mib_file
	local uni2lan
	local uni2lan_path
	local omcc_version
	local tmp

	config_load omci

	uni2lan=""
	uni2lan_path="/tmp/uni2lan"

	[ -f "$uni2lan_path" ] && uni2lan="-u $uni2lan_path"

	tmp=`fw_printenv mib_file 2>&- | cut -f2 -d=`
	if [ -f "$tmp" ]; then
		mib_file="$tmp"
	else
		config_get mib_file "default" "mib_file" "/etc/mibs/sfp_alu.ini"
	fi

	config_get tmp "default" "status_file" "/tmp/omci_status"
	status_entry_create "$tmp"

	config_get omcc_version "default" "omcc_version" 160

	logger -t omcid "Use OMCI mib file: $mib_file"
	#${OMCID_BIN} -d3 ${uni2lan} -p $mib_file  -o$omcc_version > /dev/console 2> /dev/console &
	${OMCI_MGR_BIN} > /dev/console 2> /dev/console &
	sleep 5
	${OMCI_PARSER_BIN} > /dev/console 2> /dev/console &
}

stop() {
	killall -q omcid
}
