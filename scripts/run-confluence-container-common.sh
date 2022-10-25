
#!/usr/bin/env bash
#-e  Exit immediately if a command exits with a non-zero status.
set -e

function usage {
  local scriptName=$(basename "$0")
  echo "usage: ${scriptName} x.y.z ENV=VALUE ENV2=VALUE"
  echo "   "
  echo " Set configuration parameters one after another to personalize the docker container"
  echo " example ${scriptName} 6.1.0 DEBUG_PORT=5006 will set the Confluence version to 6.1.0 opening the 5006 port for debugging"
  echo " If no parameters are set , .env file parameters will be set "
  echo "   "
  echo "  -h | --help                   : This message"
}

function getConfluencePorts() {
  if [[ ! -z "${CONFLUENCE_PORTS_LIST}" ]]; then
      confluencePorts=($(echo ${CONFLUENCE_PORTS_LIST} | tr "," "\n"))
      echo ${confluencePorts[*]}
    else
      confluencePorts=(8090 9010 9020 9030 9040 9050)
      echo ${confluencePorts[*]}
  fi
}

function getLdapPorts() {
  if [[ ! -z "${LDAP_PORTS_LIST}" ]]; then
      ldapPorts=($(echo ${LDAP_PORTS_LIST} | tr "," "\n"))
      echo ${ldapPorts[*]}
    else
      ldapPorts=(389 388 387 386 385 384)
      echo ${ldapPorts[*]}
  fi
}

function getPostgresPorts() {
  if [[ ! -z "${POSTGRES_PORTS_LIST}" ]]; then
      postgresPorts=($(echo ${POSTGRES_PORTS_LIST} | tr "," "\n"))
      echo ${postgresPorts[*]}
    else
      postgresPorts=(5432 5543 5654 5765 5876 5987)
      echo ${postgresPorts[*]}
  fi
}

function getDebugPorts() {
  if [[ ! -z "${DEBUG_PORTS_LIST}" ]]; then
      debugPorts=($(echo ${DEBUG_PORTS_LIST} | tr "," "\n"))
      echo ${debugPorts[*]}
    else
      debugPorts=(5006 5007 5008 5009 5010 5011)
      echo ${debugPorts[*]}
  fi
}

## TODO oraclePorts, oracleListenerPorts, mysqlPorts, sqlServerPorts

# By default we ignore the first argument
args="${@:2}"

case "$1" in
[0123456789]*)
  CONFLUENCE_RUN_VERSION=$1
  shift 1
  ;;
-h | --help)
  usage
  exit
  ;; # quit and show usage
*)
  # If none the above then the first argument is an environment variable
  args="${@:1}"
  ;;
esac

# Set current folder to parent
cd "$(dirname "$0")"/..

#load default env varibles
set -o allexport
[[ -f .env ]] && source .env
set +o allexport


confluencePorts=$(getConfluencePorts)
ldapPorts=($(getLdapPorts))
postgresPorts=($(getPostgresPorts))
debugPorts=($(getDebugPorts))

iterator=0
for confluencePort in $confluencePorts
do
  echo "Trying to raise the server up in port -> ${confluencePort}"

  SERVER=localhost PORT=${confluencePort}
  if (: < /dev/tcp/$SERVER/$PORT) 2>/dev/null
  then # Port already used
    echo "port ${confluencePort} already in use, trying another one"
  else # Free port
    export "CONFLUENCE_PORT=${confluencePort}"
    # confluence syncrony port value is the same as confluence port +2
    confluenceSynchronyPort=`expr ${confluencePort} + 2`
    export "CONFLUENCE_SYNCHRONY_PORT=${confluenceSynchronyPort}"
    # taking the value of the array corresponding to the same position as the confluence port list at this time
    export "LDAP_PORT=${ldapPorts[${iterator}]}"
    export "POSTGRES_PORT=${postgresPorts[${iterator}]}"
    export "DEBUG_PORT=${debugPorts[${iterator}]}"
    # TODO oraclePorts, oracleListenerPorts, mysqlPorts, sqlServerPorts exports
    break
  fi
  iterator=`expr ${iterator} + 1`
done

if [[ ! -z "${CONFLUENCE_RUN_VERSION}" ]]; then
  export "CONFLUENCE_VERSION=${CONFLUENCE_RUN_VERSION}"
fi

for env_variable in ${args}
do
    export ${env_variable}
    echo "set environment variable -> ${env_variable}"
done

echo "Starting Confluence version $CONFLUENCE_VERSION"
echo "---------------------------------"



