#!/usr/bin/env bash
pname wget/fakebrowser

#user agent and stuff to wget files from anti-bot sites
fakebrowser() {
    wget --content-disposition --trust-server-names --header="Accept: text/html" --user-agent="Mozilla/5.0 (Macintosh; Intel Mac OS X 10.8; rv:21.0) Gecko/20100101 Firefox/21.0" "$1"
}
