#!/bin/sh /etc/rc.common
# Copyright (C) 2009 OpenWrt.org
# Copyright (C) 2011 lantiq.com

. $IPKG_INSTROOT/lib/falcon.sh

START=91

gpon_led_tx=""
gpon_led_rx=""
mac0_led_act=""
mac0_led_link=""
mac1_led_act=""
mac1_led_link=""

led_set_attr() {
	[ -f "/sys/class/leds/$1/$2" ] && echo "$3" > "/sys/class/leds/$1/$2"
}

led_cfg_set() {
	led_set_attr $1 "trigger" "onu"
	led_set_attr $1 "device_name" "$2"
	led_set_attr $1 "mode" "$3"
}

led_off() {
	led_set_attr $1 "trigger" "none"
	led_set_attr $1 "brightness" 0
}

get_led_configuration() {
	case $(falcon_board_name) in
	easy98000*)
		gpon_led_tx="easy98000:green:2"
		gpon_led_rx="easy98000:green:3"
		mac0_led_act="easy98000-cpld:ge0_act"
		mac0_led_link="easy98000-cpld:ge0_link"
		mac1_led_act="easy98000-cpld:ge1_act"
		mac1_led_link="easy98000-cpld:ge1_link"
		;;
	easy98010|easy98020)
		mac0_led_act="easy98020:ge0_act"
		mac0_led_link="easy98020:ge0_link"
		mac1_led_act="easy98020:ge1_act"
		mac1_led_link="easy98020:ge1_link"
		;;
	esac
}

start() {
	get_led_configuration
	led_cfg_set $gpon_led_tx "gpon" "tx"
	led_cfg_set $gpon_led_rx "gpon" "rx"
	led_cfg_set $mac0_led_act "mac0" "tx rx"
	led_cfg_set $mac0_led_link "mac0" "link"
	led_cfg_set $mac1_led_act "mac1" "tx rx"
	led_cfg_set $mac1_led_link "mac1" "link"
}

stop() {
	get_led_configuration
	led_off $gpon_led_tx
	led_off $gpon_led_rx
}
