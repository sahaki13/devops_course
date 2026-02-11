#!/usr/bin/env bash
set -e

ENV_FILE="./.env"

if [ ! -f $ENV_FILE ]; then
    touch $ENV_FILE
fi

if ! grep -q "DIND_IMAGE=" $ENV_FILE; then
    echo "DIND_IMAGE=docker:$(docker version --format '{{.Client.Version}}')-cli-alpine3.23" >> $ENV_FILE
fi

if ! grep -q "CURRENT_DIR=" $ENV_FILE; then
    echo "CURRENT_DIR=$(basename $(pwd))" >> $ENV_FILE
fi

if ! grep -q "GITLAB_ROOT_PASSWORD=" $ENV_FILE; then
    echo "GITLAB_ROOT_PASSWORD=<your_password>" >> $ENV_FILE
fi

if ! grep -q "PERSONAL_ACCESS_TOKEN=" $ENV_FILE; then
    echo "PERSONAL_ACCESS_TOKEN=<your_token>" >> $ENV_FILE
fi
