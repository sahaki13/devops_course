#!/bin/sh

echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>> CREATE_KV >>>>>>>>>>>>>>>>>>>>>>>>>>>>>"

if [ ! -f "$KEYS_FILE" ]; then
  echo "ERROR: Keys file not found at $KEYS_FILE"
  exit 1
fi

export VAULT_ADDR=http://127.0.0.1:8200
export VAULT_TOKEN=$(sed -n 's|Initial Root Token: \(.*\)|\1|p' $KEYS_FILE)

applications="echo-server hash-generator"
environments="dev preprod prod"
for env in $environments; do
    echo -e "\n========== Environment: $env =========="

    # for all services within namespace $env
    echo "--- Upsert policy: $env ---"
    vault policy write read-secret-$env - <<EOF
path "secrets/$env/*" {
capabilities = [ "read" ]
}
EOF

    echo "Check policy $env:"
    vault policy read read-secret-$env

    for app_name in $applications; do
        echo -e "\n--- Service: $app_name ---"

        # enable kv engine
        vault secrets enable -path=secrets/$env/$app_name kv-v2 || true

        # write secrets
        vault kv put secrets/$env/$app_name/config \
            "$( echo ${env}_secret_0 | awk '{print toupper($0)}' )=$( xxd -l 8 -p /dev/random )" \
            "$( echo ${env}_secret_1 | awk '{print toupper($0)}' )=$( xxd -l 8 -p /dev/random )" \
            "$( echo ${env}_secret_2 | awk '{print toupper($0)}' )=$( xxd -l 8 -p /dev/random )" \
            "$( echo ${env}_secret_3 | awk '{print toupper($0)}' )=$( xxd -l 8 -p /dev/random )"

        # check
        echo "Check secret $env/$app_name:"
        vault kv get secrets/$env/$app_name/config
    done

    echo -e "\n========== Environment $env: DONE =========="
done
