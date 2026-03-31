#!/bin/sh

echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> INIT >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"

export VAULT_ADDR=http://127.0.0.1:8200

if [ "$HOSTNAME" != "vault-0" ]; then
  echo "Skipping INIT (not vault-0)."
  exit 0
fi

if [ -f "$KEYS_FILE" ]; then
  echo "Vault already initialized."
else
  sleep 5
  echo "Vault initialization..."

  vault operator init -key-shares=6 -key-threshold=3 > "$KEYS_FILE"
fi

