#!/bin/bash
#-e  Exit immediately if a command exits with a non-zero status.
set -e

function usage
{
    local scriptName=$(basename "$0")
    echo "usage: ${scriptName} ENV=VALUE ENV2=VALUE"
    echo "   ";
    echo " Set configuration parameters one after another to personalize the docker conatiner";
    echo " example ${scriptName} CONFLUECE_VERSION=6.10.0 DEBUG_PORT=5006 will set tht confluece version opeine the 5006 port";
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
            -h | --help )    usage;                                      exit;; # quit and show usage
            * )              args+=("$1")                                # if no match, add it to the positional args
        esac
        shift # move to next kv pair
    done
    
    # restore positional args
    set -- "${args[@]}"
}
# Set current folder to parent
cd "$(dirname "$0")"/..

for env_variable in $@
do
 export ${env_variable}
 echo "set ${env_variable}"
done

docker-compose up confluence