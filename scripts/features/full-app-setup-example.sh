#!/usr/bin/env bash

## Set path to the foler where this script is
cd "$(dirname "$0")"

## Spin up and setup Confluence standalone instance
./run-confluence-container-no-logs.sh 7.4.1

## Install app (Comala Boards 2.3.1 as example)
./install-app.sh https://marketplace.atlassian.com/download/apps/1177667/version/983

## Instal app license
./install-app-license.sh com.comalatech.adhoccanvas
