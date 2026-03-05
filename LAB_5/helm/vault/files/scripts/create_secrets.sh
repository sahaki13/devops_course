#!/bin/sh

echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>> CREATE_KV >>>>>>>>>>>>>>>>>>>>>>>>>>>>>"

if [ ! -f "$KEYS_FILE" ]; then
  echo "ERROR: Keys file not found at $KEYS_FILE"
  exit 1
fi

export VAULT_ADDR=http://127.0.0.1:8200
export VAULT_TOKEN=$(sed -n 's|Initial Root Token: \(.*\)|\1|p' $KEYS_FILE)

environments="prod dev sandbox"
for env in $environments; do
    echo "--- Create secrets: $env ---"
    vault secrets enable -path=secrets/$env/echo-server kv-v2 || true

    vault kv put secrets/$env/echo-server/config \
        "${env}secret1=tpl1" \
        "${env}secret2=tpl2"

    # for all services within namespace $env
    echo "--- Upsert policy: $env ---"
    vault policy write read-secret-$env - <<EOF
path "secrets/$env/*" {
capabilities = [ "read" ]
}
EOF

    echo "Check policy $env:"
    vault policy read read-secret-$env

    echo "Check secret $env:"
    vault kv get secrets/$env/echo-server/config
    echo "--------------------------"
done
