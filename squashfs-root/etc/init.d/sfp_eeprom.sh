#!/bin/sh /etc/rc.common
# Copyright (C) 2013 OpenWrt.org
# Copyright (C) 2013 lantiq.com

. $IPKG_INSTROOT/lib/falcon.sh
. $IPKG_INSTROOT/etc/functions.sh

START=92
SFP_I2C_BINARY=/opt/lantiq/bin/sfp_i2c

sfp_i2c() {
	#echo "sfp_i2c $*"
	$SFP_I2C_BINARY $*
}

# don't used wrapper above to ensure correct quoting of string
set_string () {
	$SFP_I2C_BINARY -i $1 -s "$2"
}

vendor_config() {
	local name
	local partno
	local revision

	config_get name default vendor_name "Lantiq"
	config_get partno default vendor_partno "Part Number"
	config_get revision default vendor_rev "0000"

	set_string 0 "$name"
	set_string 1 "$partno"
	set_string 2 "$revision"
}

serialnumber_config() {
	local nSerial

	# get serial number from onu driver?
	#onu ...
	#logger -t sfp "Using sfp serial number: $nSerial"

	config_get nSerial default serial_no "no serial number"

	set_string 3 "$nSerial"
}

bitrate_config() {
	local nBitrate

	case $(falcon_sgmii_mode) in
	2|5) # sgmii_fast or sgmii_fast_auto
		nBitrate=25
		;;
	*) # default mode
		nBitrate=10
		;;
	esac

	sfp_i2c -1 -l 1 -i 12 -w $nBitrate
}

boot() {
	local eeprom

	config_load sfp_eeprom

	# reset to default values
	sfp_i2c -d yes
	vendor_config
	serialnumber_config
	bitrate_config
	# activate write protection
	sfp_i2c -i 0 -l 128 -p 1
	sfp_i2c -i 256 -l 128 -p 1
	# activate write protection for dedicated fields
	sfp_i2c -i 366 -p 2 -m 0x87

	config_get eeprom default eeprom 1

	# set current EEPROM
	sfp_i2c -e $eeprom

	start "$@"
}

start() {
	# don't use wrapper to avoid leaving this script active in background
	$SFP_I2C_BINARY -a > /dev/console &
}

stop() {
	killall -TERM sfp_i2c
}

debug() {
	killall -USR1 sfp_i2c
}

peek() {
	killall -USR2 sfp_i2c
}

EXTRA_COMMANDS="debug peek"
EXTRA_HELP="	debug	toggle debug output of monitoring daemon
	peek	trigger single debug output of monitoring daemon
"
