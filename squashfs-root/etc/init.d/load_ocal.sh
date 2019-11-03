#!/bin/sh /etc/rc.common
# Copyright (C) 2007 OpenWrt.org
START=99

bindir=/opt/lantiq/bin

optic() {
	#echo "optic $*"
	result=`/opt/lantiq/bin/optic $*`
	#echo "result $result"
	status=${result%% *}
	key=$(echo $status | cut -d= -f1)
	val=$(echo $status | cut -d= -f2)
	if [ "$key" == "errorcode" -a "$val" != "0" ]; then
		echo "optic $* failed: $result"
	fi
}

start() {
	local bertEnable

	${bindir}/ocal > /dev/console 2> /dev/console &
	bertEnable=`fw_printenv bertEnable 2>&- | cut -f2 -d=`		
	if [ -n "$bertEnable" ]; then
	    if [ "$bertEnable" == "1" ]; then
	        sleep 10
		optic bertms 23
	        optic berte
	    fi
	fi
}
