#!/bin/sh /etc/rc.common
# Copyright (C) 2007 OpenWrt.org
# Copyright (C) 2007 lantiq.com

START=99

ldir=/opt/lantiq

start() {
	[ -e ${ldir}/image_version ] && cat ${ldir}/image_version
	[ -e ${ldir}/bin/show_version.sh ] && ${ldir}/bin/show_version.sh
}
