#!/usr/bin/env bash

# pb already sourced?
if [ -z "$PAPERIMPORT" ]; then
    PAPERIMPORT="paperbenni.github.io/bash"
    echo "paperbenni bash importer ready for use!"
else
    echo "paperbenni importer found"
    return 0
fi

if [ -e ~/.paperdebug ]; then
    echo "debugging mode enabled"
fi

PAPERENABLE="false"

# imports bash functions from paperbenni/bash into the script

pb() {

    case "$1" in
    clear)
        echo clearing the cache
        rm -rf ~/pb
        ;;
    help)
        echo "usage: pb filelocationonmygithubbashrepo"
        ;;
    nocache)
        echo "disabling cache"
        NOCACHE="true"
        ;;
    list)
        echo "imported packages:"
        echo "$PAPERLIST"
        ;;
    *)
        PAPERENABLE="true"
        if [ -z "$@" ]; then
            echo "usage: pb bashfile"
            return 0
        fi
        echo "importing $@"
        ;;
    esac

    if echo "$PAPERLIST" | grep "$1"; then
        echo "$1 already imported"
        return 0
    fi

    PAPERLIST=$"$PAPERLIST\n$1"

    if [ "$PAPERENABLE" = "false" ]; then
        echo "done, exiting"
        return 0
    fi

    for FILE in "$@"; do
        if echo "$1" | grep '.sh'; then
            PAPERPACKAGE="$FILE"
        else
            PAPERPACKAGE="$FILE.sh"
        fi
        if ! [ -e ~/.paperdebug ]; then
            if ! [ -e "~/pb/$PAPERPACKAGE" ] || [ -z "$NOCACHE" ]; then
                if echo "$PAPERPACKAGE" | grep -q "/"; then
                    FILEPATH=${PAPERPACKAGE%/*}
                    mkdir -p ~/pb/"$FILEPATH"
                fi
                curl -s "https://raw.githubusercontent.com/paperbenni/bash/master/$PAPERPACKAGE" >~/pb/"$PAPERPACKAGE"
            else
                echo "using $PAPERPACKAGE from cache"
            fi
            source ~/pb/"$PAPERPACKAGE"
        else
            echo "using debugging version"
            source ~/workspace/bash/"$PAPERPACKAGE"
        fi

    done
}
