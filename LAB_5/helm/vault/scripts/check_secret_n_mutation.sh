#!/usr/bin/env bash


echo "Secret:"
kubectl get secret -n vault vault-agent-injector-certs -o jsonpath='{.data.ca\.crt}' | base64 -d
kubectl get secret -n vault vault-agent-injector-certs -o jsonpath='{.data.ca\.crt}' | base64 -d | openssl x509 -noout -fingerprint -sha256

echo "Webhook:"
kubectl get mutatingwebhookconfiguration vault-agent-injector-cfg -o jsonpath='{.webhooks[0].clientConfig.caBundle}' | base64 -d | openssl x509 -noout -fingerprint -sha256

