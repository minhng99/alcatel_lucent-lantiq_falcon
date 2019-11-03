#!/bin/sh
# Copyright (C) 2011 lantiq.com

usage() {
	echo "Usage: $(basename $0) [FILE_NAME] [TFTP_SERVER_IP]"
	echo
	echo "Generate GPON Configuration XML dump file with FILE_NAME name"
	echo "for GPON Configuration Inspector (GCI) and send it to TFTP"
	echo "Server with TFTP_SERVER_IP IP."

	exit
}

do_generate() {
	local file=$1
	
	echo "<dump name='gci_xml_table'>" > $file
	/opt/lantiq/bin/onu xml_table gpe_dscp_decoding_table -1 >> $file
	/opt/lantiq/bin/onu xml_table gpe_pcp_decoding_table -1 >> $file
	/opt/lantiq/bin/onu xml_table gpe_lan_port_table -1 >> $file
	/opt/lantiq/bin/onu xml_table gpe_extended_vlan_table -1 >> $file
	/opt/lantiq/bin/onu xml_table gpe_vlan_rule_table -1 >> $file
	/opt/lantiq/bin/onu xml_table gpe_vlan_treatment_table -1 >> $file
	/opt/lantiq/bin/onu xml_table gpe_bridge_table -1 >> $file
	/opt/lantiq/bin/onu xml_table gpe_bridge_port_table -1 >> $file
	/opt/lantiq/bin/onu xml_table gpe_pmapper_table -1 >> $file
	/opt/lantiq/bin/onu xml_table gpe_us_gem_port_table -1 >> $file
	/opt/lantiq/bin/onu xml_table gpe_ds_gem_port_table -1 >> $file
	/opt/lantiq/bin/onu xml_table gpe_lan_port_table -1 >> $file
	/opt/lantiq/bin/onu xml_wrapper gpe_egress_queue -1 >> $file
	/opt/lantiq/bin/onu xml_wrapper gpe_scheduler -1 >> $file
	/opt/lantiq/bin/onu xml_wrapper gpe_gem_port_id -1 >> $file
	/opt/lantiq/bin/onu xml_wrapper gpe_tcont -1 >> $file
	echo "</dump>" >> $file
}

do_send() {
	local file=$1
	local ip=$2
	
	tftp -p -l $file -r $file $ip
}

do_remove() {
	local file=$1
	
	rm $file
}

if [ "x$1" = "x-h" ]; then
	usage
fi

if [ ! "x$1" = "x" ]; then
	file=$1
else
	file=/gci_xml_table_dump.xml
fi

do_generate $file

if [ ! "x$2" = "x" ]; then
	ip=$2
	do_send $file $ip
	do_remove $file
fi
