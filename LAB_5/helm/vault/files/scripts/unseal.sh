#!/bin/sh

echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> UNSEAL >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"

if [ ! -f "$KEYS_FILE" ]; then
  echo "ERROR: Keys file not found at $KEYS_FILE"
  exit 1
fi

export VAULT_ADDR=http://127.0.0.1:8200

if [ "$HOSTNAME" != "vault-0" ]; then
  is_sealed="true"
  until [ -f "$KEYS_FILE" ] && [ "$is_sealed" == "false" ]; do
    sleep 2 && echo "sealed"
    is_sealed="$(vault status -address=$VAULT_ADDR | grep -i 'sealed' | awk '{print $2}')"
  done
fi

vault_sealed_status=$( vault status | grep -i 'sealed' | awk '{print $2}' )
echo "vault_sealed_status: $vault_sealed_status"
if [ "$vault_sealed_status" == "true" ]; then
  echo "Vault unsealing...."
  vault operator unseal $(sed -n 's|Unseal Key 1: \(.*\)|\1|p' $KEYS_FILE)
  vault operator unseal $(sed -n 's|Unseal Key 2: \(.*\)|\1|p' $KEYS_FILE)
  vault operator unseal $(sed -n 's|Unseal Key 3: \(.*\)|\1|p' $KEYS_FILE)
else
  echo "Vault already unsealed."
fi
