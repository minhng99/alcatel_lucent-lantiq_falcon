#!/bin/sh
# Copyright (C) 2011 OpenWrt.org
# Copyright (C) 2011 lantiq.com

falcon_board_name() {
	local machine
	local name

	# take board name from cmdline
	name=$(awk 'BEGIN{RS=" ";FS="="} /boardname/ {print $2}' /proc/cmdline)
	[ -z "$name" ] && {
		# if not define, use cpuinfo
		machine=$(awk 'BEGIN{FS="[ \t]+:[ \t]"} /machine/ {print $2}' /proc/cpuinfo)
		[ -z "$machine" ] && {
			[ -e /proc/device-tree/model ] && {
				machine=$(cat /proc/device-tree/model)
			}
		}
		case "$machine" in
		*EASY98000*)
			name="easy98000"
			;;
		*EASY98010*)
			name="easy98010"
			;;
		*EASY98020*)
			name="easy98020"
			;;
		*95C3AM1*)
			name="95C3AM1"
			;;
		*MDU*)
			name="MDU"
			;;
		*SFP*)
			name="SFP"
			;;
		*)
			name="generic"
			;;
		esac
	}

	echo "$name"
}


# return the (board specific) number of lan ports
falcon_get_number_of_lan_ports() {
	local num="4"

	case $(falcon_board_name) in
	SFP|easy98010)
		num="1"
		;;
	MDU2|MDU3)
		num="1"
		;;
	MDU*)
		num="2"
		;;
	esac

	echo $num
}


# return the (board specific) default interface used for "lct"
falcon_default_lct_get() {
	case $(falcon_get_number_of_lan_ports) in
	1)
		echo "lan0"
		;;
	2)
		echo "lan1"
		;;
	*)
		echo "lan3"
		;;
	esac
}

falcon_sgmii_mode() {
	local retval="0"
	local sgmii_mode=`fw_printenv sgmii_mode 2>&- | cut -f2 -d=`

	case "$sgmii_mode" in
	1|sgmii)
		retval="1"
		;;
	2|sgmii_fast)
		retval="2"
		;;
	3|serdes)
		retval="3"
		;;
	4|serdes_noaneg)
		retval="4"
		;;
	5|sgmii_fast_auto)
		retval="5"
		;;
	esac
	echo $retval
}

falcon_mac_get() {
	local mac_addr=$(awk 'BEGIN{RS=" ";FS="="} $1 == "ethaddr" {print $2}' /proc/cmdline)
	local num_ports=$(falcon_get_number_of_lan_ports)
	local mac_offset

	[ -z "$mac_addr" ] && mac_addr='ac:9a:96:00:00:00'

	case "$1" in
	lan0)
		mac_offset=$(expr $num_ports - 1)
		;;
	lan1)
		mac_offset=$(expr $num_ports - 2)
		;;
	lan2)
		mac_offset=$(expr $num_ports - 3)
		;;
	lan3)
		mac_offset=$(expr $num_ports - 4)
		;;
	wan)
		mac_offset=$(expr $num_ports)
		;;
	*)
		mac_offset=-1
		;;
	esac

	[ $mac_offset -ge 0 ] && \
		echo $mac_addr | awk -v offs=$mac_offset 'BEGIN{FS=":"} {printf "%s:%s:%s:%s:%02x:%s\n", $1,$2,$3,$4,("0x"$5)+offs,$6}'
}

falcon_asc0_pin_mode() {
	local retval="0"
	local asc0_mode=`fw_printenv asc0 2>&- | cut -f2 -d=`

	case "$asc0_mode" in
	0|1|2|3)
		retval="$asc0_mode"
		;;
	esac
	echo $retval
}
