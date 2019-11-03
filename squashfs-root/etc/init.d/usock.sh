#!/bin/sh /etc/rc.common
# Copyright (C) 2011 OpenWrt.org
# Copyright (C) 2011 lantiq.com
START=81

USOCK_BIN=/opt/lantiq/bin/omci_usock_server

start() {
	${USOCK_BIN} > /dev/console 2> /dev/console &
	while true; do
		[ -e /tmp/omci_usock ] && break
	done
}

stop() {
	killall ${USOCK_BIN}
}
