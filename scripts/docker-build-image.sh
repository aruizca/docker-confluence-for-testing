#!/usr/bin/env bash

help () {
            echo
            echo "Usage: docker-build-image.sh [options]"
            echo
            echo "Builds the confluence-4-testing image"
            echo
            echo "The following options are available:"
            echo "x.y.z     Confluence version"
            echo
            exit
}

while [ $# -gt 0 ]
do
    case "$1" in
        [0123456789]*)
            CONFLUENCE_VERSION=$1
            shift 1;;
        "-?" | "-h" | "--help" | "-help" | "help")
            help;;
        *)
            shift 1
    esac
done

# Set current folder to parent
cd "$(dirname "$0")"/..

if [[ ! -z "$CONFLUENCE_VERSION" ]]
then
    eval "docker build -t confluence-4-testing:$CONFLUENCE_VERSION ."
else
    docker build -t confluence-4-testing .
fi
