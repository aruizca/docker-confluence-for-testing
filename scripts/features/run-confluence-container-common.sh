
#!/usr/bin/env bash
#-e  Exit immediately if a command exits with a non-zero status.
set -e

function usage {
  echo "   "
  local scriptName=$(basename "$0")
  echo "Usage: ${scriptName} -a alias -v x.y.z -e \"[ENV=VALUE ENV2=VALUE]\""
  echo "   "
  echo " Set configuration parameters one after another to personalize the docker container"
  echo " example ${scriptName} -v 9.10.0 -e DEBUG_PORT=5006 will set the Confluence version to 9.10.0 opening the 5006 port for debugging"
  echo " If no parameters are set , .env file parameters will be set "
  echo "   "
  echo "FLAGS:"
  echo "  -v : Confluence version to use | eg: ${scriptName} -v 9.14.0"
  echo "  -a : Alias for the docker container | eg: ${scriptName} -a integrationTests"
  echo "  -e : Environment variables to set | eg: ${scriptName} -e \"CONFLUENCE_PORT=8094 DEBUG_PORT=5008\""
  echo "  -h : Shows this message"
}
##
function getConfluencePorts() {
  # if you have ports lists set in your env variable uses those ports
  if [[ ! -z "${CONFLUENCE_PORTS_LIST}" ]]; then
      confluencePorts=($(echo ${CONFLUENCE_PORTS_LIST} | tr "," "\n"))
      echo ${confluencePorts[*]}
    else
      confluencePorts=(8090 9010 9020 9030 9040 9050)
      echo ${confluencePorts[*]}
  fi
}

function getLdapPorts() {
  # if you have ports lists set in your env variable uses those ports
  if [[ ! -z "${LDAP_PORTS_LIST}" ]]; then
      ldapPorts=($(echo ${LDAP_PORTS_LIST} | tr "," "\n"))
      echo ${ldapPorts[*]}
    else
      ldapPorts=(389 388 387 386 385 384)
      echo ${ldapPorts[*]}
  fi
}

function getPostgresPorts() {
  # if you have ports lists set in your env variable uses those ports
  if [[ ! -z "${POSTGRES_PORTS_LIST}" ]]; then
      postgresPorts=($(echo ${POSTGRES_PORTS_LIST} | tr "," "\n"))
      echo ${postgresPorts[*]}
    else
      postgresPorts=(5432 5543 5654 5765 5876 5987)
      echo ${postgresPorts[*]}
  fi
}

function getDebugPorts() {
  # if you have ports lists set in your env variable uses those ports
  if [[ ! -z "${DEBUG_PORTS_LIST}" ]]; then
      debugPorts=($(echo ${DEBUG_PORTS_LIST} | tr "," "\n"))
      echo ${debugPorts[*]}
    else
      debugPorts=(5006 5007 5008 5009 5010 5011)
      echo ${debugPorts[*]}
  fi
}

## TODO oraclePorts, oracleListenerPorts, mysqlPorts, sqlServerPorts

## Creates a list of used docker confluence ports
function getDockerUsedPorts() {
  dockerContainers=$(docker ps -a --format '{{.Names}}')

  for container in $dockerContainers
  do

    if [[ $container == *"confluence_"* ]]; then
      ## As container name is 'confluence_X.Y.Z--PORT, we trim after the first encounter of '--'
      untrimmedPort=${container#*--}
      ## Taking only the first 4 characters that matches the port
      trimmedPort=${untrimmedPort:0:4}

      dockerConfluencePorts=(${dockerConfluencePorts[@]} ${trimmedPort})

    fi
  done
  echo ${dockerConfluencePorts[*]}
}

## Processes all flags available in this scripts
while getopts 'a:v:e:h:' OPTION; do
  echo "option = ${OPTION}"
  case "$OPTION" in
    a)
      alias="$OPTARG"
      ;;
    v)
      version="$OPTARG"
      case "$version" in
        [0123456789]*)
          CONFLUENCE_RUN_VERSION=${version}
          ;;
        *)
          # If none the above then the first argument is an environment variable
          args="${@:1}"
          ;;
        esac
      ;;
    e)
        set -f # disable glob
        IFS=' ' # split on commas
        env_variables=($OPTARG) ;; # use the split+glob operator
    h)
        usage
        exit
        ;; # quit and show usage
    ?)
      usage
      exit 1
      ;;
  esac
done
shift "$(($OPTIND -1))"

## load all ports lists
confluencePorts=$(getConfluencePorts)
ldapPorts=($(getLdapPorts))
postgresPorts=($(getPostgresPorts))
debugPorts=($(getDebugPorts))
## get list of ports used by Docker
dockerConfluencePorts=($(getDockerUsedPorts))


# Set current folder to parent
cd "$(dirname "$0")"/..

#load default env varibles from .env file
while read envLine; do
  # skips all lines with '#' at the beginning
  [[ $envLine = \#* ]] && continue

  # checks if the user has VOLUME_PATH environment variable already set
  if [[ ${envLine} == *"VOLUME_PATH"* && ! -z "${VOLUME_PATH}" ]]; then
      echo "Using VOLUME_PATH environment variable with value: '${VOLUME_PATH}'"
  else
    export ${envLine}
  fi
done <.env



iterator=0
for confluencePort in $confluencePorts
do

  # Check if confluencePort is available in TCP ports
  SERVER=localhost PORT=${confluencePort}
  if (: < /dev/tcp/$SERVER/$PORT) 2>/dev/null
  then # Port already used
    echo "port ${confluencePort} already in use, trying another one"
  else # Free port in TCP
      # Checks if the free confluence port is not being used by Docker
      if [[ ! " ${dockerConfluencePorts[*]} " =~ " ${confluencePort} " ]]
       then
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
        else
           echo "port ${confluencePort} already in use, trying another one"
      fi
  fi
  iterator=`expr ${iterator} + 1`
done

if [[ ! -z "${CONFLUENCE_RUN_VERSION}" ]]; then
  export "CONFLUENCE_VERSION=${CONFLUENCE_RUN_VERSION}"
fi

for env_variable in "${env_variables[@]}"
do
    export ${env_variable}
    echo "set environment variable -> ${env_variable}"
done

if [[ ! -z "${alias}" ]];
  then
    export "PACKAGE_NAME"="${CONFLUENCE_VERSION//./-}--${CONFLUENCE_PORT}--${alias}"
  else
    export "PACKAGE_NAME"="${CONFLUENCE_VERSION//./-}--${CONFLUENCE_PORT}"
fi

echo "  "
echo "Container name = ${PACKAGE_NAME}"
echo "  "
echo "running server in $(tput setaf 2)http://localhost:${CONFLUENCE_PORT}/confluence"
echo "  "


echo "$(tput setaf 4)Starting Confluence version $CONFLUENCE_VERSION"
echo "---------------------------------"



