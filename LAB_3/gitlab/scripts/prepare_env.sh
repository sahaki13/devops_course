#!/usr/bin/env bash
set -e

ENV_FILE="./.env"

if [ ! -f "$ENV_FILE" ]; then
    touch "$ENV_FILE"
fi

# DIND_IMAGE
if ! grep -q "DIND_IMAGE=" "$ENV_FILE"; then
    echo "DIND_IMAGE=\"docker:$(docker version --format '{{.Client.Version}}')-cli-alpine3.23"\" >> "$ENV_FILE"
    echo "Added DIND_IMAGE to $ENV_FILE"
else
    echo "DIND_IMAGE already exists in $ENV_FILE"
fi

# CURRENT_DIR
if ! grep -q "CURRENT_DIR=" "$ENV_FILE"; then
    echo "CURRENT_DIR=\"$(basename "$(pwd)")"\" >> "$ENV_FILE"
    echo "Added CURRENT_DIR to $ENV_FILE"
else
    echo "CURRENT_DIR already exists in $ENV_FILE"
fi

# GITLAB_ROOT_PASSWORD
if ! grep -q "GITLAB_ROOT_PASSWORD=" "$ENV_FILE"; then
    echo "GITLAB_ROOT_PASSWORD=\"$(head -c 16 /dev/urandom | base64 | tr -d '+/=' | head -c 16)\"" >> "$ENV_FILE"
    echo "Added GITLAB_ROOT_PASSWORD to $ENV_FILE"
else
    echo "GITLAB_ROOT_PASSWORD already exists in $ENV_FILE"
fi

# PERSONAL_ACCESS_TOKEN
if ! grep -q "PERSONAL_ACCESS_TOKEN=" "$ENV_FILE"; then
    echo "PERSONAL_ACCESS_TOKEN=\"<your_token>"\" >> "$ENV_FILE"
    echo "Added PERSONAL_ACCESS_TOKEN to $ENV_FILE"
else
    echo "PERSONAL_ACCESS_TOKEN already exists in $ENV_FILE"
fi

