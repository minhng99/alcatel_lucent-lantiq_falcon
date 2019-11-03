#!/bin/sh

. /lib/falcon.sh

. /opt/lantiq/bin/gpio_setup.sh

DEFAULT_DIRECTION=${1:-low}
board_name=$(falcon_board_name)
mtddev=$(awk 'BEGIN { RS=" "; FS="="; } $1 == "mtdparts" { print $2 }' < /proc/cmdline | awk -F: '{print $1}')

gpio_setup_list() {
	for pin in $1; do
		[ $DEBUG ] && {
			echo gpio_setup $pin $DEFAULT_DIRECTION
		} || {
			gpio_setup $pin $DEFAULT_DIRECTION
			if [ $? -ne 0 ]; then
				echo "gpio_setup $pin failed!"
			fi
		}
	done
}

setup_ebu_pins() {
	local ebu_unused_pins
	case $board_name in
	easy98000)
		# skip most, we need EBU for CPLD and dm9000
		ebu_unused_pins="325"
		;;
	*)
		case $mtddev in
		sflash)
			ebu_unused_pins="300 301 302 303 304 305 306 307 323 324 325 422 424"
			;;
		*nor*)
			ebu_unused_pins="325 400 422"
			;;
		*nand*)
			ebu_unused_pins="300 301 302 303 304 305 306 307 325 400 422"
			;;
		esac
		;;
	esac
	gpio_setup_list "$ebu_unused_pins"
}

easy98000_miimode() {
	local module
	local miimode=none
	module=`cat /proc/cpld/xmii`
	case "$module" in
	"RGMII"*) # GPHY RGMII addon board
		miimode=rgmii
		;;
	"GMII"*) # GPHY GMII addon board or Tantos GMII addon board
		miimode=gmii
		;;
	"MII"*) # GPHY MII addon board or Tantos MII addon board
		miimode=mii
		;;
	"RMII"*) # GPHY RMII addon board
		miimode=rmii
		;;
	"TMII"*) # Tantos TMII addon board
		miimode=mii
		;;
	*) # none/unknown
		;;
	esac

	echo $miimode
}

setup_xmii_pins() {
	local miimode
	local mii_unused_pins

	local mdio_pins="7 8"
	local refclk_pin="224"
	local all_pins="200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223"

	local pins_none="$all_pins $refclk_pin $mdio_pins"
	local pins_rmii="211 216 207 215 218"
	local pins_mii="204 205 206 207 212 213 214 215"

	case $board_name in
	easy98000)
		miimode=$(easy98000_miimode)
		;;
	easy98020|G5500)
		miimode=rgmii
		;;
	*) # also easy98010, easy98000_4fe
		miimode=none
		;;
	esac

	#echo "miimode $miimode"
	eval "mii_unused_pins=\$pins_$miimode"
	gpio_setup_list "$mii_unused_pins"
}

setup_ssc_pins() {
	grep -q spi /proc/modules || {
		gpio_setup_list "102 103 104 105 106"
	}
}

setup_i2c_pins() {
	grep -q i2c /proc/modules || {
		gpio_setup_list "107 108"
	}
}

#echo "board_name $board_name"

setup_ebu_pins
setup_xmii_pins
setup_ssc_pins
setup_i2c_pins
