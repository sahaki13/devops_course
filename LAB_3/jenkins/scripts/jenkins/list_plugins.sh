#!/usr/bin/env bash

#TODO

curl -s 0.0.0.0:8080/jnlpJars/jenkins-cli.jar > /tmp/jenkins-cli.jar

java -jar /tmp/jenkins-cli.jar -s http://0.0.0.0:8080/ -auth user:pass list-plugins

