#!/usr/bin/env bash

TAG=$1
if [ -z "$TAG" ]
then 
    TAG="latest"
fi

COMMAND="docker run -d \
    -p 8090:8090 \
    -p 8091:8091 \
    -p 2525:25 \
    --network=confluence-net \
    confluence-4-testing:$TAG"

echo $COMMAND
eval $COMMAND