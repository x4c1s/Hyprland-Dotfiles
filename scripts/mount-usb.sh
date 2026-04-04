#!/bin/bash

IFS='
'
lsblkoutput="$(lsblk -rpo "uuid,name,type,size,label,mountpoint,fstype")"
allluks="$(echo "$lsblkoutput" | grep crypto_LUKS)"

decrypted="$(find /dev/disk/by-id/dm-uuid-CRYPT-LUKS2-* 2>/dev/null | sed "s|.*LUKS2-||;s|-.*||")"

filter() { sed "s/ /:/g" | awk -F':' '$7==""{printf "%s%s (%s) %s\n", $1,$3,$5,$6}'; }

unopenedluks="$(for drive in $allluks; do
    uuid="${drive%% *}"
    uuid="${uuid//-}"
    [ -n "$decrypted" ] && for open in $decrypted; do
        [ "$uuid" = "$open" ] && break 1
    done && continue 1
    echo "🔒 $drive"
done | filter)"

normalparts="$(echo "$lsblkoutput" | grep -v crypto_LUKS | grep 'part\|rom\|crypt' | sed "s/^/💾 /" | filter)"

alldrives="$(echo "$unopenedluks
$normalparts" | sed "/^$/d;s/ *$//")"

set -e
test -n "$alldrives" 

chosen="$(echo "$alldrives" | rofi -dmenu -p "Mount which drive?")"

getmount() {
    mp="$(find /mnt /media /mount /home -maxdepth 1 -type d 2>/dev/null | rofi -dmenu -p "Mount this drive where?")"
    test -n "$mp"
    if [ ! -d "$mp" ]; then
        mkdiryn=$(printf "No\nYes" | rofi -dmenu -p "$mp does not exist. Create it?")
        [ "$mkdiryn" = "Yes" ] && (mkdir -p "$mp" || sudo mkdir -p "$mp")
    fi
}


attemptmount() {
    sudo mount "$chosen" || return 1
    notify-send "💾 Drive mounted." "$chosen mounted."
    exit
}

case "$chosen" in 
    💾*)
        chosen="${chosen%% *}"
        chosen="${chosen:1}"
        parttype="$(echo "$lsblkoutput" | grep "$chosen")"
        attemptmount || getmount

        case "${parttype##* }" in
            vfat) sudo mount -t vfat "$chosen" "$mp" -o rw,umask=0000 ;;
            btrfs) sudo mount "$chosen" "$mp" ;;
            *) sudo mount "$chosen" "$mp" -o uid="$(id -u)",gid="$(id -g)" ;;
        esac
        notify-send "💾 Drive Mounted." "$chosen mounted to $mp"
        ;;

    🔒*)
        chosen="${chosen%% *}"
        chosen="${chosen:1}"

        num="00"
        while true; do
            [ -b "/dev/mapper/usb$num" ] || break
            num="$(printf "%02d" "$((10#$num + 1))")"
        done

        MAPPER="$usb$num"

        ${TERMINAL:-foot} -a floatpattern -w 60x3 sh -c "pass=\$(systemd-ask-password 'Enter Passphrase:'); echo \$pass | sudo cryptsetup open '$chosen' '$MAPPER'" 

        if ! test -b "/dev/mapper/$MAPPER"; then
            notify-send "❌ Decryption Failed" "Could not open $chosen"
            exit 1 
        fi

        FSTYPE="$(blkid -o value -s TYPE "/dev/mapper/$MAPPER" 2>/dev/null)"

        getmount

        case "$FSTYPE" in
            vfat|exfat)
                sudo mount -t "$FSTYPE" "/dev/mapper/$MAPPER" "$mp" -o uid="$(id -u)",gid="$(id -g)",umask=022
                ;;
            ntfs|ntfs-3g)
                sudo mount -t ntfs-3g "/dev/mapper/$MAPPER" "$mp" -o uid="$(id -u)",gid="$(id -g)"
                ;;
            ext2|ext3|ext4|btrfs|xfs)
                sudo mount -t "$FSTYPE" "/dev/mapper/$MAPPER" "$mp"
                ;;
            *)
                sudo mount "/dev/mapper/$MAPPER" "$mp"
        esac


        if mountpoint -q "$mp"; then
            notify-send "🔓 Decrypted Drive Mounted." "$chosen mounted to $mp"
        else
            notify-send "❌ Mount failed." "Could not mount /dev/mapper/$MAPPER to $mp."
            sudo cryptsetup close "$MAPPER"
        fi

        ;;
esac

