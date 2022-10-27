#!/usr/bin/env bash

export CONFLUENCE_VERSION=$(curl -s https://marketplace.atlassian.com/rest/2/applications/confluence/versions/latest | jq -r '.version')
echo "$CONFLUENCE_VERSION"