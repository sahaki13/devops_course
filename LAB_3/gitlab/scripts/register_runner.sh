#!/usr/bin/env bash

set -e

if $IS_DEBUG; then
  echo "DEBUG MODE"
  sleep 999999
fi

CONFIG_FILE="/etc/gitlab-runner/config.toml"
SESSION_SERVER_BLOCK='''
[session_server]
  # listen_address = "runner_build_srv_1:8093"
  session_timeout = 1800
  # publish_address = "runner_build_srv_1:8093"
'''

if $IS_REGISTER_RUNNER; then

  payload=`curl --silent -XPOST \
                --url    "http://gitlab:80/api/v4/user/runners" \
                --data   "runner_type=instance_type" \
                --data   "description=docker-runner" \
                --data   "tag_list=docker-runner,shared" \
                --header "PRIVATE-TOKEN: $PERSONAL_ACCESS_TOKEN"`

  RUNNER_TOKEN=`echo $payload | grep -o '"token":"[^"]*' | sed 's/"token":"//'`

  # docker compose называет сеть следующим образом:
  # <dir_name>_<network_name>
  # dir_name - название директории в которой расположен docker-compose.yml
  # network_name - название сети, которое определили в файле docker-compose.yml
  gitlab-runner register \
    --non-interactive \
    --name                docker-runner \
    --url                 http://gitlab:80/ \
    --request-concurrency 1 \
    --token               $RUNNER_TOKEN \
    --executor            docker \
    --docker-volumes      /var/run/docker.sock:/var/run/docker.sock \
    --docker-volumes      /cache \
    --docker-pull-policy  if-not-present \
    --docker-image        $DIND_IMAGE \
    --docker-network-mode ${CURRENT_DIR}_gitlab

  if grep -q "^\[session_server\]" "$CONFIG_FILE"; then
    awk '
      /^\[session_server\]/ { skip=1; next }
      /^\[/ { skip=0 }
      !skip { print }
    ' "$CONFIG_FILE" > "${CONFIG_FILE}.tmp" && mv "${CONFIG_FILE}.tmp" "$CONFIG_FILE"

    echo "$SESSION_SERVER_BLOCK" >> "$CONFIG_FILE"
  fi
fi

# docker inspect --format='{{.Config.Entrypoint}}' gitlab/gitlab-runner
# docker inspect --format='{{.Config.cmd}}'
/usr/bin/dumb-init /entrypoint \
  run \
  --user=gitlab-runner \
  --working-directory=/home/gitlab-runner

