#!/usr/bin/env bash

########################
## paperbash importer ##
########################

if ! [ "${SHELL##*/}" == 'bash' ]; then
    echo "error: shell is not bash"
    return 0
fi

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

# default fetching url
PAPERGIT="https://raw.githubusercontent.com/paperbenni/bash/master"

pbname() {
    if grep -q '\.' <<<"$1"; then
        if grep -q '/' <<<"$1"; then
            if grep -q '\.sh' <<<"$1"; then
                echo "$1"
            else
                echo "${1//\./\/}.sh"
            fi
        else
            if grep -q '\.sh' <<<"$1"; then
                echo "${1%.sh}/$1"
            else
                echo "${1//\./\/}.sh"
            fi
        fi

    else
        if grep -q '/' <<<"$1"; then
            echo "$1.sh"
        else
            echo "$1/$1.sh"
        fi
    fi
}

pb() {
    {
        PAPERENABLE="false"
        case "$1" in
        clear)
            echo clearing the cache
            rm -rf ~/pb
            ;;
        help)
            echo "usage: pb [package name]"
            echo "you can find a list of available packages on my github"
            ;;
        nocache)
            echo "disabling cache"
            NOCACHE="true"
            ;;
        list)
            echo "imported packages:"
            echo "$PAPERLIST"
            ;;
        debug)
            if [ "$2" = "all" ]; then
                PPACKAGES="$(echo "$PAPERLIST" | egrep -o '[^ :]*')"
                echo "refreshing $PPACKAGES"
                for i in $PPACKAGES; do
                    echo "source $i"
                    source ~/workspace/bash/"$i.sh"
                done
            else
                cat ~/workspace/bash/"$2.sh" || (echo "debug package not found" && return 1)
                source ~/workspace/bash/"$2.sh"
            fi
            return 0
            ;;
        offupdate)
            echo "updating offline install"
            cd
            cd workspace
            rm -rf bash
            git clone --depth=1 https://github.com/paperbenni/bash.git
            ;;
        *)
            PAPERENABLE="true"
            if [ -z "$@" ]; then
                echo "usage: pb bashfile"
                return 0
            fi
            pecho "importing $@"
            ;;
        esac
    }

    if [ "$PAPERENABLE" = "false" ]; then
        pecho "done, exiting"
        return 0
    fi

    PAPERPACKAGE=$(pbname "$1")
    pecho "$PAPERPACKAGE"

    # only import once
    if grep -q "$PAPERPACKAGE" <<<"$PAPERLIST"; then
        pecho "$1 already imported"
        return 0
    fi

    if ! [ -e ~/.paperdebug ]; then
        if ! [ -e "~/pb/$PAPERPACKAGE" ] || [ -z "$NOCACHE" ]; then
            if grep -q "/" <<<"$PAPERPACKAGE"; then
                FILEPATH=${PAPERPACKAGE%/*}
                mkdir -p ~/pb/"$FILEPATH"
            fi

            curl -s "$PAPERGIT/$PAPERPACKAGE" >~/pb/"$PAPERPACKAGE"
        else
            pecho "using $PAPERPACKAGE from cache"
        fi

        if grep -q 'pname' <~/pb/"$PAPERPACKAGE"; then
            pecho "script is valid"
            source ~/pb/"$PAPERPACKAGE"
        else
            pecho "$PAPERPACKAGE not a pb package"
        fi
    else
        pecho "using debugging version"
        if ! [ -e ~/.papersilent ]; then
            cat ~/workspace/bash/"$PAPERPACKAGE" || { echo "debug package not found" && return 1; }
        fi
        source ~/workspace/bash/"$PAPERPACKAGE"
    fi

}

pbb() {
    # process multiple packages
    if [ -n "$2" ]; then
        echo "multi import statement"
        for i in $*; do
            echo "importing $i"
            pb $i
        done
    fi
}

pname() {
    PAPERLIST="$PAPERLIST $(pbname $1)\n"
}

psilent() {
    {
        touch ~/.papersilent
        if [ -n "$1" ]; then
            sleep "$1"
        else
            sleep 20
        fi
        rm ~/.papersilent
    } &
}

pecho() {
    if [ -e ~/.papersilent ]; then
        return 0
    else
        echo "$@"
    fi
}

SCRIPTDIR=$(grep -o '.*/' <<<"$0")
pb bash
