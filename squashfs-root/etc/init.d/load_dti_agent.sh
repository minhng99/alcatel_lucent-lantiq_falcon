#!/bin/sh /etc/rc.common
# Copyright (C) 2011 OpenWrt.org
# Copyright (C) 2011 lantiq.com
START=99

AGENT_BIN="/opt/lantiq/bin/gpon_dti_agent"
AGENT_ARGS="-p9000"

start() {
	start-stop-daemon -S -x $AGENT_BIN -b -- $AGENT_ARGS
}

stop() {
	start-stop-daemon -K -x $AGENT_BIN
}
