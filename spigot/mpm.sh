#!/usr/bin/env bash

pname spigot/mpm

pb spigot

# get a file from the mpm repo
getmpm() {
    MMC=${MC:-1.13}
    MPMRAW="raw.githubusercontent.com/paperbenni/mpm/master/spigot/$MMC"
    test -e $1 || wget -q "$MPMRAW/$1"
}

# main mpm command
mpm() {

    MPMLINK="https://raw.githubusercontent.com/paperbenni/mpm/master"
    checkspigot || echo "warning: no spigot installation found"

    if [ "$1" = "-f" ]; then
        if [ -e "mpmfile" ]; then
            while read p; do
                if echo "$p" | grep 'version:'; then
                    MCVERSION=$(echo "$p" | grep -o ':.*' | grep '[^:]*')
                else
                    mpm "$p"
                fi
                echo "$p"
            done <mpmfile
        else
            echo "put your plugin names in mpmfile"
        fi
        return 0
    fi

    MCVERSION="${2:-$(spigotversion)}"
    echo "minecaft version $MCVERSION"
    SPIGOTVERSION="$(spigotversion)"

    mkdir plugins &> /dev/null
    cd plugins

    #check for new version if the plugin is installed
    if [ -e "$1.mpm" ]; then
        OLDVERSION="$(grep version <"$1.mpm" | grep -o '[0-9]*')"
        NEWVERSION="$(curl -s "$MPMLINK/plugins/$1/$MCVERSION/$1.mpm" | grep 'version' | grep -o '[0-9]*')"
        if [ "$OLDVERSION" = "$NEWVERSION" ]; then
            echo "newest version of $1 already installed"
            cd ..
            return 0
        else
            echo "$1 outdated, updating..."
            rm "$1."*
        fi
    fi

    #download metadata
    echo "$MPMLINK/plugins/$1/$MCVERSION/$1.mpm"
    curl -s "$MPMLINK/plugins/$1/$MCVERSION/$1.mpm" >"$1.mpm"
    #cat "$1.mpm"
    #check if the plugin exists
    if ! grep -q 'describe' <"$1.mpm"; then
        echo "plugin $1 not existing on remote"
        cd ..
        rm $1.mpm
        return 1
    fi

    if grep -q "$SPIGOTVERSION" <"$1.mpm"; then
        echo "version check sucessful"
    fi
    wget -q "$MPMLINK/plugins/$1/$MCVERSION/$1.jar"
    echo "installed $1.jar"

    if grep -q 'depend' <"$1.mpm"; then
        echo "plugin needs dependencies"
        DPENDENCIES="$(grep 'depend' <$1.mpm)"
        cd ../
        for i in "$DPENDENCIES"; do
            echo "installing dependency $i"
            pwd
            mpm "${i#**:}"
        done
        cd plugins
    fi

    if grep -q 'hook' <"$1.mpm"; then
        cd ..
        echo "running plugin hooks"
        source <(curl -s "$MPMLINK/plugins/$1/$MCVERSION/hook.sh")
        minehook
        cd plugins
    fi

    cd ..

}

mpupdate() {
    phelp "$1" "usage: mpupdate filename pluginname mcversion" || return 0
    MCPATH="$HOME/workspace/mpm/plugins/$2/1.$3"
    zerocheck "$1" "$2" "$3"
    test -e "$1" || (echo "file $1 not found!" && return 0)
    #clone if mpm does not exist locally
    if ! [ -e ~/workspace/mpm/.git ]; then
        pushd ~
        mkdir workspace
        cd workspace
        git clone --depth=1 https://github.com/paperbenni/mpm.git
        popd
    fi

    #compare hashes if there's no update
    if [ -e "$MCPATH/$2.jar" ]; then
        pb hash
        different "$1" "$MCPATH/$2.jar" || return 1
    else
        echo "no existing version found"
    fi

    test -e ~/workspace/mpm/plugins/"$2"/"1.$3" || mkdir -p ~/workspace/mpm/plugins/"$2"/"1.$3"
    cp "$1" ~/workspace/mpm/plugins/"$2"/1."$3"/"$2".jar
    #generate a new mpm file
    pushd $MCPATH
    if ! [ -e "$2.mpm" ]; then
        touch "$2.mpm"
        APPENDFILE="$2.mpm"
        app "version:1"
        app "mc:1.$3"
        pb dialog
        app "describe:$(textbox description)"
        messagebox "Add dependencies such as vault."
        MCDEP=$(textbox "Enter none for no dependencies")
        while ! [ "$MCDEP" = "none" ]; do
            app "depend:$MCDEP"
            MCDEP=$(textbox "Enter none to quit")
        done
    else
        #update existing mpmfile
        MCVER=$(grep 'version:' <"$2.mpm" | grep -o '[0-9]*')
        echo "updating to version $((MCVER + 1))"
        sed -i 's/version:.*/'"version:$((MCVER + 1))/g" $2.mpm
        cat "$2.mpm"
    fi
    echo "updated $2"
    popd

}
