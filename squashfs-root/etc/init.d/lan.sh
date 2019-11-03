#!/bin/sh /etc/rc.common
# Copyright (C) 2009 OpenWrt.org
# Copyright (C) 2011 lantiq.com

. $IPKG_INSTROOT/lib/falcon.sh

START=91

onu () {
	#echo "onu $*"
	result=`/opt/lantiq/bin/onu $*`
	#echo "result $result"
	status=${result%% *}
	if [ "$status" != "errorcode=0" ]; then
		echo "onu $* failed: $result"
	fi
}

gphy_fw_mode="2" # 11G as default
port_mode_0="0 1 0 0 0" # GPHY0
port_mode_1="2 1 0 0 0" # GPHY1
port_mode_2=""
port_mode_3=""
port_capability_0="1 1 1 1 1 1 1 1"
port_capability_1="1 1 1 1 1 1 1 1"
port_capability_2="1 1 1 1 1 1 1 1"
port_capability_3="1 1 1 1 1 1 1 1"
phy_addr_0="0"
phy_addr_1="1"
phy_addr_2="-1"
phy_addr_3="-1"

clk_delay="0 0"
autoneg_mode="0" # SGMII_NO_ANEG
invrx="0"
invtx="0"
eth_mode="0"

gpon_lan_port_set() {
	[ -n "$3" ] && onu lanpcs $1 $lanpe $2 $3 $clk_delay 1518 1 $autoneg_mode $invtx $invrx $eth_mode && \
		[ -n "$4" ] && onu lanpccs $1 $4
}

gpon_lan_port_disable() {
	[ -n "$2" ] && onu lanpd $1
}

gpon_uni2lan_add() {
	echo "$1 $2" >> /tmp/uni2lan
}

decode_sgmii_mode() {
	local SGMII_PORT=$1

	case $(falcon_sgmii_mode) in
	1)
		eval "port_mode_${SGMII_PORT}=\"4 3 0 0 0\"" # SGMII
		autoneg_mode="1" # SGMII_MAC_ANEG
		;;
	2)
		eval "port_mode_${SGMII_PORT}=\"4 3 1 0 5\"" # SGMII, LAN_MODE_SPEED_2500
		autoneg_mode="0" # SGMII_NO_ANEG
		;;
	3)
		eval "port_mode_${SGMII_PORT}=\"4 14 1 0 4\"" # TBI_SERDES, FIXED
		autoneg_mode="3" # SGMII_SERDES_ANEG
		;;
	4)
		eval "port_mode_${SGMII_PORT}=\"4 14 1 0 4\"" # TBI_SERDES, FIXED
		autoneg_mode="0" # SGMII_NO_ANEG
		;;
	5)
		eval "port_mode_${SGMII_PORT}=\"4 15 1 0 5\"" # TBI_AUTODETECT, LAN_MODE_SPEED_2500
		autoneg_mode="3" # SGMII_SERDES_ANEG
		;;
	*) # default mode, auto
		eval "port_mode_${SGMII_PORT}=\"4 15 0 0 0\"" # TBI_AUTODETECT
		autoneg_mode="3" # SGMII_SERDES_ANEG
		;;
	esac
	eval "port_capability_${SGMII_PORT}=\"\""
	eval "phy_addr_${SGMII_PORT}=\"-1\""
}

get_gpon_lan_ports() {
	local module
	case $(falcon_board_name) in
	easy98000)
		module=`cat /proc/cpld/xmii`
		case "$module" in
		"RGMII module"*) # GPHY RGMII addon board
			phy_addr_2="4"
			phy_addr_3="5"
			port_mode_2="5 5 0 0 0" # XMII0, RGMII MAC
			port_mode_3="6 5 0 0 0" # XMII1, RGMII MAC
			clk_delay="1 1"
			;;
		"GMII PHY"*) # GPHY GMII addon board
			phy_addr_2="4"
			port_mode_2="5 8 1 0 4" # XMII0, GMII_MAC
			;;
		"MII PHY"*) # GPHY MII addon board
			phy_addr_2="4"
			port_mode_2="5 10 0 0 0" # XMII0, MII_MAC
			;;
		"RMII PHY"*) # GPHY RMII addon board
			phy_addr_2="4"
			phy_addr_3="5"
			port_mode_2="5 6 0 0 0" # RXMII0, RMII_MAC
			port_mode_3="6 6 0 0 0" # RXMII1, RMII_MAC
			;;
		"GMII MAC"*) # Tantos GMII addon board
			port_mode_2="5 9 1 0 4" # XMII0, GMII_PHY
			;;
		"MII MAC"*) # Tantos MII addon board
			port_mode_2="5 11 1 0 4" # XMII0, MII_PHY
			;;
		"TMII MAC"*) # Tantos TMII addon board
			port_mode_2="5 13 1 0 4" # XMII0, TMII_PHY
			;;
		*) # none/unknown
			;;
		esac
		if [ -e "/proc/cpld/sgmii" ]
		then
			module=`cat /proc/cpld/sgmii`
			case "$module" in
			"SGMII"*) # SGMII addon board
				# use SGMII port instead of GPHY0 (0) or RGMII1 (3)
				SGMII_PORT=0
				# assume PHY with MDIO (1) or no MDIO (0)
				MDIO=0
				if [ $MDIO == 1 ]
				then
					eval "port_capability_${SGMII_PORT}=\"1 1 1 1 1 1 1 0\""
					eval "phy_addr_${SGMII_PORT}=\"6\""
					autoneg_mode="1" # SGMII_MAC_ANEG
					eval "port_mode_${SGMII_PORT}=\"4 15 0 0 0\"" # TBI_AUTODETECT
				else
					decode_sgmii_mode ${SGMII_PORT}
				fi
				invrx="0"
				invtx="1"
				eth_mode="0"
				# for debugging: set lower debug level
				#onu onudls 1
				;;
			*) # none/unknown
				;;
			esac
		fi
		;;
	easy98000_4fe) # four times FE
		gphy_fw_mode="1" # 11F firmware
		phy_addr_2="2"
		phy_addr_3="3"
		port_mode_0="0 2 0 0 0" # FEPHY0, EPHY
		port_mode_1="1 2 0 0 0" # FEPHY1, EPHY
		port_mode_2="2 2 0 0 0" # FEPHY2, EPHY
		port_mode_3="3 2 0 0 0" # FEPHY3, EPHY
		clk_delay="1 1"
		;;
	easy98000_serdes) # SERDES Test-config
		decode_sgmii_mode 3
		invrx="0"
		invtx="1"
		eth_mode="0"
		# for debugging: set lower debug level
		onu onudls 1
		;;
	easy98020)
		port_mode_2="5 5 0 0 0" # RXMII0, RGMII MAC
		port_mode_3="6 5 0 0 0" # RXMII1, RGMII MAC
		phy_addr_2="5"
		phy_addr_3="6"
#		Example configuration to swap ports 0 & 1
#		port_mode_0="2 1 0 0 0" # RXMII0, RGMII MAC
#		port_mode_1="0 1 0 0 0" # RXMII1, RGMII MAC
#		phy_addr_0="1"
#		phy_addr_1="0"
		;;
	easy98010)
		phy_addr_1="-1"
		port_mode_1=""
		;;
	G5500)
		phy_addr_0="-1"
		phy_addr_1="-1"
		port_mode_0=""
		port_mode_1=""
		port_mode_2="5 5 1 3 4" # RXMII0, RGMII MAC
		port_mode_3=""
		clk_delay="2 2"
		;;
	MDU*)
		port_mode_0="5 8 1 4 4" # XMII0, GMII
		port_capability_0=""
		phy_addr_0="-1"
		port_mode_1="0 1 0 0 0" # GPHY0
		phy_addr_1="0"
		clk_delay="2 2"
		;;
	SFP) # SFP module
		port_mode_1=""
		port_capability_1=""
		phy_addr_1="-1"
		port_mode_2=""
		port_capability_2=""
		port_mode_3=""
		port_capability_3=""
		phy_addr_3="-1"

		decode_sgmii_mode 0
		invrx="0"
		invtx="0"
		eth_mode="0" # no clock recovery from GPON
		# for debugging: set lower debug level
		#onu onudls 1
		# "disable" the MDIO pins, switch to "gpio, input"
		echo 7 > /sys/class/gpio/export
		echo 8 > /sys/class/gpio/export
		;;
	esac
}

lan_port_mac_cfg_set() {
	local mac=$(uci -q get network.lan${1}.macaddr)

	[ -n "$mac" ] && {
		#echo -e "lan_port_mac_cfg_set $1 \nmac: $mac \nmac2: $(echo $mac | sed -e 's/^/0x/' -e 's/:/ 0x/g')"
		onu lan_port_mac_cfg_set $1 $(echo $mac | sed -e 's/^/0x/' -e 's/:/ 0x/g')
	}
}

gpon_lct_setup() {
	lan_port_mac_cfg_set 0
	lan_port_mac_cfg_set 1
	lan_port_mac_cfg_set 2
	lan_port_mac_cfg_set 3

	# on all boards except eval (easy98000), use ip addr from u-boot
	case $(falcon_board_name) in
	easy98000*)
		case `cat /proc/cpld/ebu` in
		"Ethernet Controller module"*) # dm9000 module
			echo "Found dm9000, don't change lct"
			ifup lct
			return 0
			;;
		*)
			echo "No dm9000"
			;;
		esac
		;;
	esac
	echo "Setup lct"
	local ip=$(awk 'BEGIN{RS=" ";FS="="} $1 == "ip" {print $2}' /proc/cmdline)
	local ipaddr=$(echo $ip | awk 'BEGIN{FS=":"} {print $1}')
	local gateway=$(echo $ip | awk 'BEGIN{FS=":"} {print $3}')
	local netmask=$(echo $ip | awk 'BEGIN{FS=":"} {print $4}')
	[ -n "$ipaddr" ] && uci set network.lct.ipaddr=$ipaddr
	[ -n "$gateway" ] && uci set network.lct.gateway=$gateway
	[ -n "$netmask" ] && uci set network.lct.netmask=$netmask
	[ -n "$ipaddr" -o -n "$gateway" -o -n "$netmask" ] && uci commit network
	ifup lct
}

enable_gpon_lan_ports() {
	local module
	case $(falcon_board_name) in
	MDU*)
		# enable data port towards the Vinax
		# ensure that CLKOC_OEN is enabled
		onu lanpe 0
		# enable the tagging towards the Vinax
		# please refer to the gpe_sce_constants_get command / vinax_tag elemnt
		# by default the tag is configured to 0x8100000A (VLAN ID 10)
		onu gpevtcs 0 1
		;;
	esac
}

boot() {
	get_gpon_lan_ports
	onu lani
	onu lancs $gphy_fw_mode 0 0 1
	lanpe="0"
	start
}

start() {
	if [ "$lanpe" == "" ]
	then
		get_gpon_lan_ports
		lanpe="1"
	fi
	gpon_lan_port_set 0 "$phy_addr_0" "$port_mode_0" "$port_capability_0"
	gpon_lan_port_set 1 "$phy_addr_1" "$port_mode_1" "$port_capability_1"
	gpon_lan_port_set 2 "$phy_addr_2" "$port_mode_2" "$port_capability_2"
	gpon_lan_port_set 3 "$phy_addr_3" "$port_mode_3" "$port_capability_3"
	gpon_lct_setup
	enable_gpon_lan_ports
}

stop() {
	get_gpon_lan_ports
	gpon_lan_port_disable 0 "$port_mode_0"
	gpon_lan_port_disable 1 "$port_mode_1"
	gpon_lan_port_disable 2 "$port_mode_2"
	gpon_lan_port_disable 3 "$port_mode_3"
}
