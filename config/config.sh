#!/usr/bin/env bash
pname config/config

function confset() {
    if ! [ -e "$1" ]; then
        echo "target config file $1 not existing!"
        return 1
    fi
    if [ -z "$3" ]; then
        echo "usage: confset file option value"
    fi
    if grep -q "$2=$3" <"$1"; then
        echo "value $2=$3 already set"
        return 0
    else
        echo "setting $2=$3"
    fi
    NEWVALUE="$2=$3"
    sed -i "/^$2=/c $NEWVALUE" "$1"
    grep "$2" <"$1"
}

# get value from format key:value without a preceding space
# if not found rerurn $3
function confget() {
    if [ -z "$2" ]; then
        return 1
    fi

    if ! [ -e "$1" ] || ! grep -i "$2" <"$1"; then
        if [ -n "$3" ]; then
            echo "$3"
        else
            return 1
        fi
    fi

    grep "$2" <"$1" | egrep -o ':.*' | egrep -o '[^:]*'

}
