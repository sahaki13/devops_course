#!/bin/sh

echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> INIT >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"

if [ ! -f "$KEYS_FILE" ]; then
  echo "ERROR: Keys file not found at $KEYS_FILE"
  exit 1
fi

export VAULT_ADDR=http://127.0.0.1:8200

if [ "$HOSTNAME" != "vault-0" ]; then
  echo "Skipping INIT (not vault-0)."
  exit 0
fi

if [ -f "$KEYS_FILE" ]; then
  echo "Vault already initialized."
else
  sleep 10
  echo "Vault initialization..."
  while true
  do
    vault operator init -key-shares=6 -key-threshold=3 >> "$KEYS_FILE" 2>&1
    ret_code=$?
    if [ $ret_code -eq 0 ]; then
      break
    fi
  done
fi
