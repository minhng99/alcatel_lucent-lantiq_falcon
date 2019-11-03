#!/bin/sh

CONFIG_FILE='/etc/goiupgrade.conf'
ENV_VARIABLE='goi_config'

if [ -e /etc/fw_env.config ]
then
	fw_setenv ${ENV_VARIABLE} `tar cz -C / -T ${CONFIG_FILE} | uuencode -m ${ENV_VARIABLE} | tr '\n' '@'`
fi
