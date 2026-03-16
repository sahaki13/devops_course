{{- define "vaultApiHlp.initContainer" -}}
initContainers:
  - name: secrets-init
    image: "{{ .Values.app.initContainer.repository }}:{{ .Values.app.initContainer.tag }}@sha256:{{ .Values.app.initContainer.digest }}"
    securityContext:
      capabilities:
        drop: [ ALL ]
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: true
      runAsNonRoot: true
      runAsUser:  65534
      runAsGroup: 65534
    command: [ "/bin/bash", "-c" ]
    args:
      - |
        set -e
        {{- if .Values.app.initContainer.isDebug }}
        sleep 99999
        {{- end }}
        secret_path="secrets/{{ .Release.Namespace }}/{{ include "app.fullname" . }}/data/config"
        vault_addr="{{ .Values.vault.address }}" && \
        role="{{ .Values.vault.role }}" && \
        sa_t=$(cat /run/secrets/kubernetes.io/serviceaccount/token) && \
        v_t=$(curl -f -s -X POST -d "{\"jwt\":\"$sa_t\",\"role\":\"$role\"}" $vault_addr/v1/auth/kubernetes/login | jq -r '.auth.client_token')
        if [ "$v_t" == "null" ] || [ "$v_t" == "" ]; then echo "Auth failed"; exit 1; fi
        curl -s -H "X-Vault-Token: $v_t" $vault_addr/v1/$secret_path | \
        jq -r '.data.data | keys[] as $k | "\($k)=\(.[$k])"' > /empty/.env
        echo "secrets obtained"
    volumeMounts:
      - name: dotenv
        mountPath: /empty
      - name: sa-token # override automountServiceAccountToken to obtain token
        mountPath: /var/run/secrets/kubernetes.io/serviceaccount
        readOnly: true
    resources:
      requests:
        memory: 20Mi
        cpu: 100m
      limits:
        memory: 20Mi
        cpu: 100m
{{- end }}

{{- define "vaultApiHlp.dotenv_file_mount" -}}
- name: dotenv
  mountPath: /empty/.env
  subPath: .env
{{- end }}

{{- define "vaultApiHlp.volumes" -}}
- name: dotenv
  emptyDir:
    medium: "Memory"
    sizeLimit: 1Mi
- name: sa-token
  projected:
    defaultMode: 0444
    sources:
    - serviceAccountToken:
        expirationSeconds: 700
        path: token
{{- end }}
