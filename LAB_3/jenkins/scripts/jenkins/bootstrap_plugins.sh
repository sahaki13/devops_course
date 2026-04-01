#!/usr/bin/env sh

CMD_TIMEOUT="2m"
if [ -f /usr/share/jenkins/ref/plugins.txt ]; then
  echo "Installing plugins..."
  timeout "$CMD_TIMEOUT" jenkins-plugin-cli --verbose --plugin-file /usr/share/jenkins/ref/plugins.txt

  EXIT_CODE=$?
  if [ $EXIT_CODE -eq 124 ]; then
    printf "%s\n\n" ">>> Plugin installation timed out after $CMD_TIMEOUT!"
    exit 1
  elif [ $EXIT_CODE -eq 0 ]; then
    printf "%s\n\n" ">>> Plugin installation OK!"
    # jenkins-plugin-cli --list
  else
    printf "%s\n\n" ">>> Plugin installation failed with exit code: $EXIT_CODE"
    exit 1
  fi
fi

