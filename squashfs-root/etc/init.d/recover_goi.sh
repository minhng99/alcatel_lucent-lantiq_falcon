#!/bin/sh /etc/rc.common
# Copyright (C) 2010 OpenWrt.org
# Copyright (C) 2011 lantiq.com
START=45

recover_stamp=/etc/optic/.goi_recovered

goi_config_recover() {
	TAR_FILE='/tmp/goi.tar.gz'
	ENV_VARIABLE='goi_config'

	local goi_config
	goi_config=`fw_printenv ${ENV_VARIABLE} 2>&-` || return 1

	echo ${goi_config} | sed "s/^${ENV_VARIABLE}=//" | tr '@' '\n' | uudecode -o ${TAR_FILE} && \
	tar zxf ${TAR_FILE} -C / && \
	rm -f ${TAR_FILE}
}

start () {
	if [ -e /etc/fw_env.config ]; then
		if [ ! -e ${recover_stamp} ]; then
			echo "Recover goi_config from U-Boot"
			goi_config_recover && touch ${recover_stamp}
		fi
	fi
}
