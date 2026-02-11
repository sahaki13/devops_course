#!/usr/bin/env sh
set -e

mkdir -p build

SERVICE_VERSION=$(grep 'version' ./version.json | cut -d '"' -f4 | tr '\n' '\0')
echo "SERVICE_VERSION=$SERVICE_VERSION"
go build \
    -ldflags="-s -w -X 'main.buildDate=$(date)' -X 'main.version=$SERVICE_VERSION' " \
    -o ./build/echo_server \
    src/main.go
