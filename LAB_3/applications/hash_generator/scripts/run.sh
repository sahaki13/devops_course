#!/usr/bin/env sh
set -e

export APP_PORT="5000"
export TARGET_URL="http://0.0.0.0:3000/echo"

./build/app
