#!/usr/bin/env bash

# nohup <cmd>  &
tests=(
  'vault-interaction-testpod-init-container'
  # 'vault-interaction-testpod-agent-injector'
  'vault-interaction-testpod-vso'
)

ns=dev
# ns="hash-generator"

for test in ${tests[@]}
do
  echo "<<<<<<<<<<<<<<<<<<<<<<<< Run test $test >>>>>>>>>>>>>>>>>>>>>>>>>>>>"
  helm test --filter name=$test -n vault vault & disown
  until kubectl logs -n "$ns" "$test" 2>/dev/null
  do
    echo "Waiting pod $test..."
    sleep 0.5
  done

  echo -e "\n\n"
  sleep 10
done

