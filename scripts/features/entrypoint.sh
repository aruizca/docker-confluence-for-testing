#!/bin/bash
set -euo pipefail
#detect java version
JAVA_VER=$(java -version 2>&1 | sed -n ';s/.* version "\(.*\)\.\(.*\)\..*".*/\1\2/p;')

# Setup Catalina Opts
: ${CATALINA_CONNECTOR_PROXYNAME:=}
: ${CATALINA_CONNECTOR_PROXYPORT:=}
: ${CATALINA_CONNECTOR_SCHEME:=http}
: ${CATALINA_CONNECTOR_SECURE:=false}

: ${CATALINA_OPTS:=}

CATALINA_OPTS="${CATALINA_OPTS} -DcatalinaConnectorProxyName=${CATALINA_CONNECTOR_PROXYNAME}"
CATALINA_OPTS="${CATALINA_OPTS} -DcatalinaConnectorProxyPort=${CATALINA_CONNECTOR_PROXYPORT}"
CATALINA_OPTS="${CATALINA_OPTS} -DcatalinaConnectorScheme=${CATALINA_CONNECTOR_SCHEME}"
CATALINA_OPTS="${CATALINA_OPTS} -DcatalinaConnectorSecure=${CATALINA_CONNECTOR_SECURE}"
if [ "$JAVA_VER" -ge 90 ]; then
    CATALINA_OPTS="${CATALINA_OPTS} -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:5005"
else
    CATALINA_OPTS="${CATALINA_OPTS} -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=5005"
fi

export CATALINA_OPTS
echo "CATALINA_OPTS=$CATALINA_OPTS"

exec "$CONFLUENCE_INSTALL_DIR/bin/start-confluence.sh" "$@"

