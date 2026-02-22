{{- define "vault.checkNamespace" -}}
  {{- if eq .Release.Namespace "default" -}}
    {{- fail "\n\n[ERROR] Установка в namespace 'default' запрещена!\n" -}}
  {{- end -}}
{{- end -}}
