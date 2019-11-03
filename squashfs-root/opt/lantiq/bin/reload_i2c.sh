#!/bin/sh

DEBUG_LEVEL=${1:-"3"}

rmmod mod_sfp_i2c
insmod mod_sfp_i2c debug=${DEBUG_LEVEL}
