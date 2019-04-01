#!/bin/bash

ngrokdl() {
    mkdir "$HOME"/ngrok &>/dev/null
    cd "$HOME"/ngrok
    echo "downloading ngrok"
    wget https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip -q --show-progress
    unzip *.zip || (echo "unzip utility not found, please install!" && return 1)
    rm *.zip
    if [ -z "$1" ]; then
        chmod +x "$HOME"/ngrok/ngrok
        if ! "$HOME"/ngrok/ngrok --version; then
            echo "failed"
            return 1
        else
            echo "skipping chmod"
        fi
    fi
}

exegrok() {
    if ngrok --version &>/dev/null; then
        ngrok "$@"
    else
        if ! ~/ngrok/ngrok --version &>/dev/null; then
            ngrokdl
        fi
        ~/ngrok/ngrok "$@"
    fi
}

rungrok() {

    mkdir -p ~/.ngrok2

    while true; do
        curl "https://raw.githubusercontent.com/paperbenni/bash/master/ngrok/tokens.txt" >./ngroktokens.txt
        exegrok authtoken $(shuf -n 1 ./ngroktokens.txt)
        rm ./ngroktokens.txt
        sleep 5
        exegrok "$@"
        sleep 5
    done

}

getgrok() {
    curl localhost:4040/api/tunnels | grep -oP 'tcp://.*?:[0-9]*'
}
