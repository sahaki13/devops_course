#!/bin/sh

echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>> READ_POLICIES >>>>>>>>>>>>>>>>>>>>>>>>>>>"

if [ ! -f "$KEYS_FILE" ]; then
  echo "ERROR: Keys file not found at $KEYS_FILE"
  exit 1
fi

export VAULT_ADDR=http://127.0.0.1:8200
export VAULT_TOKEN=$(sed -n 's|Initial Root Token: \(.*\)|\1|p' $KEYS_FILE)

for policy in $(vault policy list -format=json | grep -v -E 'root|default' | tr -d '[]",'); do
  echo "============ $policy ============"
  vault policy read "$policy"
  echo -e "============================\n\n"
done
