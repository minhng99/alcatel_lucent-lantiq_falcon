#!/bin/sh

bindir=/opt/lantiq/bin
image_version=/opt/lantiq/image_version

if [ -e $image_version ]; then
	cat $image_version
fi

driver_file_list=`find /lib/modules/*/`

for I in $driver_file_list; do
	if [ -e $I ]; then
		vers=`$bindir/what.sh $I`
		if [ "$vers" != "" ]; then
			echo "$vers"
		fi
	fi
done

appl_file_list="gpe_table_tests gpon_dti_agent onu optic fapi gtop omci_simulate omcid otop ocal gexdump omci_usock_server"

for I in $appl_file_list; do
	if [ -e $bindir/$I ]; then
		vers=`$bindir/what.sh $bindir/$I`
		if [ "$vers" != "" ]; then
			echo "$vers"
		fi
	fi
done
