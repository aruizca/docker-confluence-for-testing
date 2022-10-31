#!/usr/bin/env bash

CONFLUENCE_BASE_URL="http://localhost:8090/confluence"
CONFLUENCE_USERNAME="admin"
CONFLUENCE_PASSWORD="admin"
APP_KEY=""
APP_LICENCE="AAABCA0ODAoPeNpdj01PwkAURffzKyZxZ1IyUzARkllQ24gRaQMtGnaP8VEmtjPNfFT59yJVFyzfubkn796Ux0Bz6SmbUM5nbDzj97RISxozHpMUnbSq88poUaLztFEStUN6MJZ2TaiVpu/YY2M6tI6sQrtHmx8qd74EZ+TBIvyUU/AoYs7jiE0jzknWQxMuifA2IBlUbnQ7AulVjwN9AaU9atASs69O2dNFU4wXJLc1aOUGw9w34JwCTTZoe7RPqUgep2X0Vm0n0fNut4gSxl/Jcnj9nFb6Q5tP/Ueu3L+0PHW4ghZFmm2zZV5k6/95CbR7Y9bYGo/zGrV3Ir4jRbDyCA6vt34DO8p3SDAsAhQnJjLD5k9Fr3uaIzkXKf83o5vDdQIUe4XequNCC3D+9ht9ZYhNZFKmnhc=X02dh"

help () {
            echo
            echo "Usage: install-app.sh APP_KEY [-b CONFLUENCE_BASE_URL] [-u CONFLUENCE_USERNAME] [-p CONFLUENCE_PASSWORD] [-l APP_LICENCE]"
            echo
            echo "Install the license for the provided app key in a Confluence instance."
            echo
            echo "APP_KEY                       Key for the app to be licensed"
            echo "[-b CONFLUENCE_BASE_URL]      Default -> http://localhost:8090/confluence"
            echo "[-u CONFLUENCE_USERNAME]      Default -> admin"
            echo "[-p CONFLUENCE_PASSWORD]      Default -> admin"
            echo "[-l APP_LICENCE]              Default -> standard 3 hours timebomb license"
            echo
            exit
}

if [[ ! -z "$1" ]]
then
    APP_KEY=$1
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
        "-l")
            APP_LICENSE=$2
            shift 2;;
        "-?" | "-h" | "--help" | "-help" | "help")
            help;;
        *)
            shift 1
    esac
done

LICENSE_URL="${CONFLUENCE_BASE_URL}/rest/plugins/latest/${APP_KEY}-key/license"
echo "Installing plugin license to ${LICENSE_URL}"
curl -u ${CONFLUENCE_USERNAME}:${CONFLUENCE_PASSWORD} -v -X PUT -d "{\"rawLicense\": \"${APP_LICENCE}\"}" -H "Content-Type: application/vnd.atl.plugins+json" ${LICENSE_URL}