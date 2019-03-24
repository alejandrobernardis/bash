#!/usr/bin/env bash

rclogin() {

    mkdir ~/.rclogin &>/dev/null
    pushd ~/.rclogin

    if ! [ -e ~/.config/rclone/rclone.conf ]; then
        echo "setting up default cloud"
        curl -s https://raw.githubusercontent.com/paperbenni/bash/master/rclone/conf/mineglory.conf >~/.config/rclone/rclone.conf
    fi

    USAGE="rclogin [remote name] username password"
    if ! rclone --version >/dev/null; then
        echo "please install rclone"
        popd
        return
    fi
    if ! [ -z "$1" ]; then
        RCLOUD="$1"
    else
        echo "enter cloud storage name"
        read RCLOUD
    fi

    rm .conf &>/dev/null
    if [ -e "$RCLOUD".conf ]; then
        echo "using existing credentials"
        RNAME1=$(cat "$RCLOUD".conf | grep "username:")
        RNAME=${RNAME1#*\:}
        echo "$RNAME"
        RPASS1=$(cat "$RCLOUD".conf | grep "password:")
        RPASS=${RPASS1#*\:}
    else
        dialog --inputbox "Enter your username:" 8 40 2>username
        RNAME=$(cat username)
        rm username
        echo "username:$RNAME" >>"$RCLOUD.conf"
        dialog --inputbox "Enter your password:" 8 40 2>password
        RPASS=$(cat password)
        rm password
        echo "password:$RPASS" >>"$RCLOUD.conf"

    fi

    if rclone lsd "$RCLOUD":"$RNAME" &>/dev/null; then
        echo "account found"
        MEGAPASSWORD=$(rclone cat "$RCLOUD":"$RNAME"/password.txt)
        if [ "$MEGAPASSWORD" = "$RPASS" ]; then
            echo "login sucessfull"
            sleep 1
            popd
            return 0
        else
            echo "wrong password"
            sleep 3
            popd
            return 1
        fi
    else
        echo "account not found, creating account"
        rclone mkdir "$RCLOUD":"$RNAME"
        rclone mkdir "$RCLOUD":"$RNAME"/thisaccountexists
        echo "$RPASS" >password.txt
        rclone copy password.txt "$RCLOUD":"$RNAME"/
        rm password.txt
        echo "account created"
        popd
        return 0
    fi

}
