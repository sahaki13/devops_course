#!/usr/bin/env sh

forgejo admin user generate-access-token \
  --username="adminforg" \
  --token-name="jenkins" \
  --scopes="all" \
  --raw

# revoke token
# forgejo admin user delete-access-token \
#   --username=adminforg \
#   --token-name=jenkins

