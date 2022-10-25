#!/usr/bin/env bash

source run-confluence-container-common.sh $@

packageName="${CONFLUENCE_VERSION//.//-}--${CONFLUENCE_PORT}"

docker-compose -p ${packageName} up -d ${DATABASE} puppeteer-confluence-setup
docker logs -f puppeteer-confluence-setup


