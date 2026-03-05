#!/bin/sh

echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>> CREATE_USERS >>>>>>>>>>>>>>>>>>>>>>>>>>>"

if [ ! -f "$KEYS_FILE" ]; then
  echo "ERROR: Keys file not found at $KEYS_FILE"
  exit 1
fi

export VAULT_ADDR=http://127.0.0.1:8200
export VAULT_TOKEN=$(sed -n 's|Initial Root Token: \(.*\)|\1|p' $KEYS_FILE)

vault auth enable userpass

vault policy write admin-policy - <<EOF
path "secrets/*" {
  capabilities = ["create", "read", "update", "delete", "list", "patch"]
}
path "sys/*" {
  capabilities = ["create", "read", "update", "delete", "list", "patch"]
}
path "auth/token/*" {
  capabilities = ["create", "read", "update", "delete", "list", "patch"]
}
path "auth/userpass/*" {
  capabilities = ["create", "read", "update", "delete", "list", "patch"]
}
EOF

vault write auth/userpass/users/admin \
      password="admin" \
      policies=admin-policy
vault write auth/userpass/users/admin \
      default_lease_ttl=1h \
      max_lease_ttl=1h

vault policy write dev-policy - <<EOF
path "secrets/dev/*" {
  capabilities = ["create", "read", "update", "delete", "list", "patch"]
}
EOF

vault write auth/userpass/users/dev \
      password="dev" \
      policies=dev-policy
vault write auth/userpass/users/dev \
      default_lease_ttl=1h \
      max_lease_ttl=1h
