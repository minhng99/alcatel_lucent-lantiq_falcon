#!/bin/sh
#
# Copyright (C) 2010 OpenWrt.org
#
#

. /lib/falcon.sh

status_led=""

led_set_attr() {
	[ -f "/sys/class/leds/$1/$2" ] && echo "$3" > "/sys/class/leds/$1/$2"
}

status_led_set_timer() {
	led_set_attr $status_led "trigger" "timer"
	led_set_attr $status_led "delay_on" "$1"
	led_set_attr $status_led "delay_off" "$2"
}

status_led_on() {
	led_set_attr $status_led "trigger" "heartbeat"
	led_set_attr $status_led "brightness" 255
}

status_led_off() {
	led_set_attr $status_led "trigger" "none"
	led_set_attr $status_led "brightness" 0
}

get_status_led() {
	case $(falcon_board_name) in
	easy98000*)
		status_led="easy98000:green:5"
		;;
	easy98010|easy98020)
		status_led="easy98020:green:3"
		;;
	95C3AM1)
		status_led="power"
		;;
	MDU*)
		status_led="mdu:green:0"
		;;
	esac;
}

set_state() {
	get_status_led

	case "$1" in
	preinit)
		status_led_set_timer 200 200
		;;
	failsafe)
		status_led_set_timer 50 50
		;;
	done)
		status_led_on
		;;
	esac
}
