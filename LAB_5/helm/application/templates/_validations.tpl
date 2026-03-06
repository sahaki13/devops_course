{{- define "app.validateNamespace" -}}
  {{- if eq .Release.Namespace "default" -}}
    {{- fail "\n\n[ERROR] Установка в namespace 'default' запрещена!\n" -}}
  {{- end -}}
{{- end -}}

{{- define "app.validateDigest" -}}
{{- $digests := list
  (dict "path" "app.digest" "value" .Values.app.image.digest)
  (dict "path" "app.initContainer.digest" "value" .Values.app.initContainer.digest)
-}}
{{- range $digests -}}
  {{- if not .value -}}
    {{- fail (printf "\n\n[ERROR] %s ОБЯЗАТЕЛЕН!\nУкажи SHA256 digest (64 hex символа).\n" .path) -}}
  {{- else if not (regexMatch "^[a-f0-9]{64}$" .value) -}}
    {{- fail (printf "\n\n[ERROR] Неверный формат %s!\nОжидается: 64 шестнадцатеричных символа (a-f, 0-9), без префикса 'sha256:'.\nПолучено: %s\n" .path .value) -}}
  {{- end -}}
{{- end -}}
{{- end -}}

{{- define "app.validateIngress" -}}
{{- if and .Values.ingress.enabled (ne .Values.service.type "ClusterIP") -}}
{{- fail "\n\n[ERROR] Ingress требует service.type: ClusterIP\n" -}}
{{- end -}}
{{- end -}}

{{- define "app.validateAll" -}}
{{- include "app.validateNamespace" . -}}
{{- include "app.validateDigest" . -}}
{{- include "app.validateIngress" . -}}
{{- end -}}
