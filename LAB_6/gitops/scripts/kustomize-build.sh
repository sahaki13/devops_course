#!/usr/bin/env bash

stand="dev"

kustomize build \
          --enable-helm \
          --load-restrictor LoadRestrictionsNone \
          ./values/stands/$stand

# ./values/apps/echo-server/dev/

