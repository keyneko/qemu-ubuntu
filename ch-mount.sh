#!/bin/bash

function help() {
    echo ""
    echo "usage: ch-mount.sh [-m <path>] [-u <path>] <command> [<args>]"
    echo ""
    echo "For example: bash ch-mount.sh -m /media/sdcard/"
    echo ""
}


while getopts "m:u:" arg
do
    case $arg in
        m)
            echo "I:MOUNTING"
            sudo mount -t proc /proc ${2}proc
            sudo mount -t sysfs /sys ${2}sys
            sudo mount -o bind /dev ${2}dev
            sudo mount -o bind /dev/pts ${2}dev/pts        
            sudo chroot ${2}
            ;;
        u)
            echo "I:UNMOUNTING"
            sudo umount ${2}proc
            sudo umount ${2}sys
            sudo umount ${2}dev/pts
            sudo umount ${2}dev
            ;;
        ?)
            echo "E:Unknow parameter"
            help
            exit 1
    esac
done
