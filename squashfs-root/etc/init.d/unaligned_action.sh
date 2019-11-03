#!/bin/sh /etc/rc.common
# Copyright (C) 2013 OpenWrt.org
# Copyright (C) 2013 lantiq.com

START=15

ACTION_QUIET=0
ACTION_SIGNAL=1
ACTION_SHOW=2

boot() {
	echo "MIPS: set unaligned_action to 'SHOW'" > /dev/console
	echo $ACTION_QUIET > /sys/kernel/debug/mips/unaligned_action
}
