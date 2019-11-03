#!/bin/sh
#
# Copyright (C) 2014 lantiq.com
#

# disable dying gasp
# needs to be enabled via I2C only if base system supports it
uci set gpon.gtc.nDyingGaspEnable=0
