#!/usr/bin/env sh
set -e

rm -Rfv ./build
mkdir build

PKG_PATH="echo-server/internal/config"
SERVICE_VERSION=$(grep 'version' ./version.json | cut -d '"' -f4 | tr -d '\n')
DATE="$(date)" #"$(date +"%d.%m.%Y_%H:%M:%S")"
echo -e "SERVICE_VERSION=$SERVICE_VERSION\nBUILD_DATE=$DATE"
go build \
    -ldflags="-s -w -X '$PKG_PATH.buildDate=$DATE' -X '$PKG_PATH.version=$SERVICE_VERSION' " \
    -o ./build/app \
    ./cmd/server/main.go
