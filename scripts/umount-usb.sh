#!/bin/bash

set -e

lsblkoutput="$(lsblk -nrpo "name,type,size,mountpoint")"
mounteddrives="$(echo "$lsblkoutput" | awk '($2=="part"||$2="crypt")&&$4!~/\/boot|\/home$|SWAP/&&length($4)>1{printf "%s (%s)\n",$4,$3}')"

allunmountable="$(echo "$mounteddrives" | sed "/^$/d;s/ *$//")"
test -n "$allunmountable"

chosen="$(echo "$allunmountable" | rofi -dmenu -p "Unmount which drive?")"
chosen="${chosen%% *}"
test -n "$chosen"

sudo umount -l "/${chosen#*/}"
notify-send "💾 Device unmounted." "$chosen has been unmounted"

cryptid="$(echo "$lsblkoutput" | grep "/${chosen#*/}$")"
cryptid="${cryptid%% *}"
test -b /dev/mapper/"${cryptid##*/}"
sudo cryptsetup close "$cryptid"
notify-send "🔒 Device dencryption closed." "Drive is now securely locked again."
