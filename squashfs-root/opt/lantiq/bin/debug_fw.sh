#!/bin/sh


c=x
if [ -n "$1" ] && [ $1 == "i" ]; then
  c=$1
fi

  c="h"
  
while [ $c != "q" ]
do


if [ $c == "h" ]; then
  echo
  echo "ash instead of bash needs additional RETURN key after each single key command"
  echo "debug_fw.sh V0.3 (2011.06.29)"
  echo
  echo "b: break         -> onu sceb 1 && onu scerp 1"
  echo "c: check         -> onu scebc"
  echo "d: dump          -> onu scemg 1 addr"
  echo "e: error and PDU -> onu scemg 2 0xac68, 0xac6c, 0x8210 .. 0x823C"
  echo "g: go            -> onu scer 1"
  echo "i: init          -> load firmware"
  echo "n: new           -> onu scebs 1 addr"
  echo "l: list          -> onu scebp 1"
  echo "p: print         -> onu scerp 1"
  echo "q: quit"
  echo "r: remove        -> onu scebr 1 id"
  echo "s: step          -> onu scess 1 && onu scerp 1"
  echo "t: threads       -> onu scesg"
  echo "j: init micro step -> onu onuccs 1 && onu onudls 0"
  echo "m: micro step    -> onu gpecdsr 0x3F 1"
  echo "v: version       -> onu scevg 1"
fi


#read -p"fdb> " -n 1 c
read -p"fdb> " c
echo -e -n "\n"

if [ $c == "i" ]; then
  onu onu_counters_cfg_set 1
  cd /lib/firmware
  onu sced 0xff falcon_gpe_fw.bin
  onu onurs 32 0xbd610004 0
  onu onurs 32 0xbd620004 0
  onu onurs 32 0xbd630004 0
  onu onurs 32 0xbd640004 0
  onu onurs 32 0xbd650004 0
  onu onurs 32 0xbd660004 0
  onu gpeats 0
  onu sceb 2
  onu scerm 0x111133
  onu scesg
fi

if [ $c == "j" ]; then
  onu onuccs 1
  onu onudls 0
fi

if [ $c == "m" ]; then
  onu gpecdsr 0x3F 1
fi

if [ $c == "b" ]; then
  onu sceb 1 && onu scerp 1
fi

if [ $c == "c" ]; then
  onu scebc
fi

if [ $c == "d" ]; then
  read -p"Memory Address: " addr
  onu scemg 2 $addr
fi

if [ $c == "g" ]; then
  onu scer 1
  sleep 2
  onu scebc
  onu scesg
fi

if [ $c == "e" ]; then
  echo "2*32 bit discard reason:"
  onu scemg 2 0xac68
  onu scemg 2 0xac6c

  echo "meta-TX: byte0=? byte1=QID byte2=OFFS byte3=HDRL"
  onu scemg 2 0x8200
  echo "meta-TX: byte4=QOSL byte5=QOSL byte6=PDUT[6:4],IPN[3:0] byte7=TICK"
  onu scemg 2 0x8204
  echo "meta-TX: byte8=RUC[7:5],CMD[4:2],COL byte9=GPIX byte10,11=PLEN[15:0]"
  onu scemg 2 0x8208
  echo "meta-TX: byte12,13=TLSA[31:16] byte14,15=HLSA[15:0]"
  onu scemg 2 0x820C

  echo "packet payload:"
  onu scemg 2 0x8210
  onu scemg 2 0x8214
  onu scemg 2 0x8218
  onu scemg 2 0x821C
  onu scemg 2 0x8220
  onu scemg 2 0x8224
  onu scemg 2 0x8228
  onu scemg 2 0x822C
  onu scemg 2 0x8230
  onu scemg 2 0x8234
  onu scemg 2 0x8238
  onu scemg 2 0x823C
fi

if [ $c == "l" ]; then
  onu scebp 1
fi

if [ $c == "n" ]; then
  onu sceb 1
  onu scebp 1
  read -p"New Breakpoint at Address: " addr
  onu scebs 1 $addr
  onu scebp 1
  onu scesg
fi

if [ $c == "p" ]; then
  onu scerp 1
  onu scesg
fi

if [ $c == "r" ]; then
  onu sceb 1
  onu scebp 1
  read -p"Remove Breakpoint at Address: " id
  onu scebr 1 $id
  onu scebp 1
fi

if [ $c == "s" ]; then
  onu scess 1
  onu scerp 1
fi

if [ $c == "t" ]; then
  onu scesg
fi

if [ $c == "v" ]; then
  onu scevg 1
fi

done


exit


##sceb      sce_break
#scebc     sce_break_check
#scebg     sce_break_get
#scebm     sce_break_mask
##scebp     sce_break_print
##scebr     sce_break_remove
##scebs     sce_break_set
#sced      sce_download
##scemg     sce_mem_get
#scems     sce_mem_set
#scerg     sce_reg_get
##scerp     sce_reg_print
#scers     sce_reg_set
#scerv     sce_restart_vm
##scer      sce_run
##scerm     sce_run_mask
##scess     sce_single_step
#scesg     sce_status_get
##scevg     sce_version_get


