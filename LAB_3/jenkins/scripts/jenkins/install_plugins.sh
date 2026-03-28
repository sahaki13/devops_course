#!/usr/bin/env bash

# direct
jenkins-plugin-cli --plugins \
  configuration-as-code \
  gitea

# or from file
jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt

# cp -v /usr/share/jenkins/ref/plugins/* /var/jenkins_home/plugins/

