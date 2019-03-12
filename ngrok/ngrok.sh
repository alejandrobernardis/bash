#!/bin/bash

exegrok() {
    if ngrok --version; then
        ngrok "$@"
    else
        if ! ~/ngrok/ngrok --version; then
            mkdir -p ~/ngrok
            pushd ngrok
            wget https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip
            chmod +x ngrok
            if ! ./ngrok --version; then
                echo "failed"
                return 1
            fi
            popd
        fi
        ~/ngrok/ngrok "$@"
    fi
}

rungrok() {

    mkdir -p ~/.ngrok2

    while true; do
        curl "https://raw.githubusercontent.com/paperbenni/ngrok-docker/master/tokens.txt" >./ngroktokens.txt
        exegrok authtoken $(shuf -n 1 ./ngroktokens.txt)
        rm ./ngroktokens.txt
        sleep 5
        exegrok "$@"
        sleep 5
    done

}

getgrok() {
    echo "getting ngrok adress..."
    curl -s localhost:4040/inspect/http | grep -oP 'window.common[^;]+' | sed 's/^[^\(]*("//' | sed 's/")\s*$//' | sed 's/\\"/"/g' | jq -r ".Session.Tunnels | values | map(.URL) | .[]" | grep "^tcp://" | sed 's/tcp\?:\/\///' >ngrokadress.txt
}
