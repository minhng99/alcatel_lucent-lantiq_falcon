#!/bin/sh

gpio_export() {
	local pin=$1
	local ret

	test -e /sys/class/gpio/gpio${pin} || {
		ret=`echo ${pin} > /sys/class/gpio/export`
		test -z $ret
	}
}

gpio_direction() {
	local pin=$1
	local dir=$2

	echo ${dir} > /sys/class/gpio/gpio${pin}/direction
}

gpio_edge() {
	local pin=$1
	local edge=$2

	echo ${edge} > /sys/class/gpio/gpio${pin}/edge
}

gpio_setup() {
	gpio_export $1 && {
		if [ $# -gt 1 ]; then
			gpio_direction $1 $2

			if [ $# -gt 2 ]; then
				gpio_edge $1 $3
			fi
		fi
	}
}

################################################
## "main"
################################################

if [ `basename $0` = "gpio_setup.sh" ]; then
	if [ $# -gt 0 ]; then
		echo "Called with $# params: $*"
		gpio_setup $*
		if [ $? -ne 0 ]; then
			echo "'gpio_setup $*' failed!"
		fi
	else
		echo "missing parameters!"
	fi
fi
