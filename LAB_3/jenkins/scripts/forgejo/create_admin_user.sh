#!/usr/bin/env sh

forgejo admin user create \
  --admin \
  --username="$FORGEJO_ADMIN_USERNAME" \
  --password="$FORGEJO_ADMIN_PASSWORD" \
  --email="$FORGEJO_ADMIN_EMAIL" \
  --must-change-password=false

