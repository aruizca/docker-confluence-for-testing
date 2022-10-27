#!/usr/bin/env bash

source ${BASH_SOURCE%/*}/features/run-confluence-container-common.sh $@

docker-compose -p ${PACKAGE_NAME} up -d ${DATABASE} confluence
docker logs -f confluence_${PACKAGE_NAME}