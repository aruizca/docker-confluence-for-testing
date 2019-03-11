#!/usr/bin/env bash
#-e  Exit immediately if a command exits with a non-zero status.
set -e

function usage
{
    local scriptName=$(basename "$0")
    echo "usage: ${scriptName} x.y.z ENV=VALUE ENV2=VALUE"
    echo "   ";
    echo " Set configuration parameters one after another to personalize the docker container";
    echo " example ${scriptName} 6.1.0 DEBUG_PORT=5006 will set the Confluence version to 6.1.0 opening the 5006 port for debugging";
    echo " If no parameters are set , .env file parameters will be set ";
    echo "   ";
    echo "  -h | --help                   : This message";
}

# Parses command line parameters, but also sets de AWS_PROFILE globally (by exporting it).
# This way, all the upcoming calls to the awscli will be using the selected profile 
function parse_args
{
    # positional args
    args=()
    
    # named args
    while [ "$1" != "" ]; do
        case "$1" in
            [0123456789]*)
                CONFLUENCE_VERSION=$1
                shift 1;;
            -h | --help )    usage;                                      exit;; # quit and show usage
            * )              args+=("$1")                                # if no match, add it to the positional args
        esac
        shift # move to next kv pair
    done
    
    # restore positional args
    set -- "${args[@]}"
    shift 1
}
# Set current folder to parent
cd "$(dirname "$0")"/..

if [[ ! -z "$CONFLUENCE_VERSION" ]]
then
    export CONFLUENCE_VERSION=$CONFLUENCE_VERSION
fi

for env_variable in $@
do
 export ${env_variable}
 echo "set ${env_variable}"
done

docker-compose up confluence