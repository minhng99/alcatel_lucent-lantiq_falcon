#!/bin/sh /etc/rc.common
# Copyright (C) 2010 OpenWrt.org
# Copyright (C) 2011 lantiq.com
START=50

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

gpio_has_pu() {
	local pin=$1
	grep "gpio-${pin}" /sys/kernel/debug/gpio | grep in |grep -q hi
}

omu() {
	local found=no
	local pull_up=false
	which i2cdump >/dev/null && {
		if i2cdetect -l | grep -q gpio; then
			gpio_has_pu 107 && gpio_has_pu 108 && pull_up=true
		else
			pull_up=true
		fi
		$pull_up && {
			dump=`i2cdump -y 0 0x50 2>/dev/null`
			echo "$dump" |grep -q FIBERXON && found=yes
			echo "$dump" |grep -q SOURCEPHOTON && found=yes
		}
	}
	echo $found
}

EXTRA_COMMANDS="omu"
EXTRA_HELP="	omu	Check if OMU is found"

start() {
	local OpticMode
	. /lib/falcon.sh

	while true; do
		[ -e /dev/optic0 ] && break
	done
	case $(falcon_board_name) in
	easy98000)
		config_load goi_config
		config_get OpticMode global OpticMode undefined
		[ "$OpticMode" == "undefined" ] && {
			echo "check for OMU"
			[ "$(omu)" == "yes" ] && OpticMode=OMU
		}
		;;
	*)	# BOSA mode
		OpticMode=BOSA
		;;
	esac
	case $OpticMode in
	[Oo][Mm][Uu]) # OMU mode
		optic optic_mode_set 1
		;;
	*)	# BOSA mode (default)
		optic optic_mode_set 2
		;;
	esac

	optic config_apply
}
