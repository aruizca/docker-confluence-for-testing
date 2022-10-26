#!/usr/bin/env bash

source run-confluence-container-common.sh $@

docker-compose -p ${PACKAGE_NAME} up -d ${DATABASE} puppeteer-confluence-setup
docker logs -f puppeteer-confluence-setup
docker logs -f confluence_${PACKAGE_NAME}