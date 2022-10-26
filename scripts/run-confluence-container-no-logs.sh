#!/usr/bin/env bash

source run-confluence-container-common.sh $@

docker-compose -p ${PACKAGE_NAME} up -d ${DATABASE} puppeteer-confluence-setup
docker logs -f puppeteer-confluence-setup_${PACKAGE_NAME}


