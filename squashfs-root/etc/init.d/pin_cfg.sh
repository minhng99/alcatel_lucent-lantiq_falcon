#!/bin/sh /etc/rc.common
# Copyright (C) 2013 OpenWrt.org
# Copyright (C) 2013 lantiq.com

. $IPKG_INSTROOT/lib/falcon.sh
. $IPKG_INSTROOT/opt/lantiq/bin/gpio_setup.sh
LTQ_BIN=/opt/lantiq/bin

START=94

optic_sfp_pins() {
	local tx_fault_pin
	local tx_disable_pin
        tx_fault_pin=`fw_printenv tx_fault_pin 2>&- | cut -f2 -d=`	
        if [ -z "$tx_fault_pin" ]; then
           config_get tx_fault_pin gpio tx_fault 255
        fi
	config_get tx_disable_pin gpio tx_disable 255
	case $(falcon_asc0_pin_mode) in
	0|2)
		[ "$tx_disable_pin" -eq "33" ] && tx_disable_pin=255
		;;
	esac
	$LTQ_BIN/optic optic_pin_cfg_set $tx_disable_pin $tx_fault_pin
}

force_sfp_on() {
	local mod_def_pin
	config_get mod_def_pin gpio mod_def 32

	case $(falcon_asc0_pin_mode) in
	1|3)
		# set pin32 to LOW (module availability indication)
		gpio_setup $mod_def_pin low
		;;
	esac
}

boot() {
	start "$@"
}

start() {
	case $(falcon_board_name) in
	SFP) # SFP module
		config_load sfp_pins
		optic_sfp_pins
		force_sfp_on
		;;
	*)
		;;
	esac
}
