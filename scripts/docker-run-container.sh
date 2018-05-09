#!/usr/bin/env bash

TAG=$1
if [ -z "$TAG" ]
then 
    TAG="latest"
fi

COMMAND="docker run -d \
    -p 8090:8090 \
    confluence-4-testing:$TAG"

echo $COMMAND
eval $COMMAND