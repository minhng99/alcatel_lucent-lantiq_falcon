#!/bin/sh

for i in $*; do
	version=`strings $i | grep -m1 "@(#)" | sed 's/\(.*\)@(#)\(.*\)/\2/g'`
	echo $version
done

