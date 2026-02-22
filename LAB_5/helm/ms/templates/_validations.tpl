{{- define "ms.validateNamespace" -}}
  {{- if eq .Release.Namespace "default" -}}
    {{- fail "\n\n[ERROR] Установка в namespace 'default' запрещена!\n" -}}
  {{- end -}}
{{- end -}}

{{- define "ms.validateDigest" -}}
{{- $digests := list
  (dict "path" "ms.digest" "value" .Values.ms.digest)
  (dict "path" "ms.initContainer.digest" "value" .Values.ms.initContainer.digest)
-}}
{{- range $digests -}}
  {{- if not .value -}}
    {{- fail (printf "\n\n[ERROR] %s ОБЯЗАТЕЛЕН!\nУкажи SHA256 digest (64 hex символа).\n" .path) -}}
  {{- else if not (regexMatch "^[a-f0-9]{64}$" .value) -}}
    {{- fail (printf "\n\n[ERROR] Неверный формат %s!\nОжидается: 64 шестнадцатеричных символа (a-f, 0-9), без префикса 'sha256:'.\nПолучено: %s\n" .path .value) -}}
  {{- end -}}
{{- end -}}
{{- end -}}

{{- define "ms.validateIngress" -}}
{{- if and .Values.ingress.enabled (ne .Values.service.type "ClusterIP") -}}
{{- fail "\n\n[ERROR] Ingress требует service.type: ClusterIP\n" -}}
{{- end -}}
{{- end -}}

{{- define "ms.validateAll" -}}
{{- include "ms.validateNamespace" . -}}
{{- include "ms.validateDigest" . -}}
{{- include "ms.validateIngress" . -}}
{{- end -}}
