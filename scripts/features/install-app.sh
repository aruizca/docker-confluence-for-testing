#!/usr/bin/env bash

APP_LOCATION=""
APP_FILE_PATH="./app-to-install.jar"
CONFLUENCE_BASE_URL="http://localhost:8090/confluence"
CONFLUENCE_USERNAME="admin"
CONFLUENCE_PASSWORD="admin"

help () {
    echo
    echo "Usage: install-app.sh APP_LOCATION [-b CONFLUENCE_BASE_URL] [-u CONFLUENCE_USERNAME] [-p CONFLUENCE_PASSWORD]"
    echo
    echo "Install the provided app in a Confluence instance."
    echo
    echo "APP_LOCATION                  URL or file path to the app JAR file"
    echo "[-b CONFLUENCE_BASE_URL]      Default -> http://localhost:8090/confluence"
    echo "[-u CONFLUENCE_USERNAME]      Default -> admin"
    echo "[-p CONFLUENCE_PASSWORD]      Default -> admin"
    echo
    exit
}

if [[ ! -z "$1" ]]
then
    APP_LOCATION=$1
else
    help
fi

while [ $# -gt 0 ]
do
    case "$1" in
        "-b")
            CONFLUENCE_BASE_URL=$2
            shift 2;;
        "-u")
            CONFLUENCE_USERNAME=$2
            shift 2;;
        "-p")
            CONFLUENCE_PASSWORD=$2
            shift 2;;
        "-?" | "-h" | "--help" | "-help" | "help")
            help;;
        *)
            shift 1
    esac
done

## Download app if required
if [[ $APP_LOCATION == http* ]]
then 
    echo "Downloading from web"
    curl -k -L -o ${APP_FILE_PATH} ${APP_LOCATION}
else
    echo "Using file system"
    APP_FILE_PATH=$APP_LOCATION
fi

## Get UPM token
UPM_TOKEN=$(curl -I --user $CONFLUENCE_USERNAME:$CONFLUENCE_PASSWORD -H 'Accept: application/vnd.atl.plugins.installed+json' $CONFLUENCE_BASE_URL'/rest/plugins/1.0/?os_authType=basic' 2>/dev/null | grep 'upm-token' | cut -d " " -f 2 | tr -d '\r')

## Install the App
curl --user ${CONFLUENCE_USERNAME}:${CONFLUENCE_PASSWORD} -H 'Accept: application/json' ${CONFLUENCE_BASE_URL}'/rest/plugins/1.0/?token='${UPM_TOKEN} -F plugin=@${APP_FILE_PATH}