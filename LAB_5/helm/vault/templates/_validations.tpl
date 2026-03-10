{{- /*
  Chart validation
*/ -}}

{{- define "vault.validate" -}}

  {{- if eq .Release.Namespace "default" -}}
    {{- fail "\n\n[ERROR] Установка в namespace 'default' запрещена!\n" -}}
  {{- end -}}

  {{- $injectorEnabled := .Values.injector.enabled | default false -}}
  {{- $vsoEnabled := .Values.vso.enabled | default false -}}

  {{- if and $injectorEnabled $vsoEnabled -}}
    {{- fail `
    [ERROR] Нельзя включить Vault Secret Operator и Agent Injector одновременно
    Выбери один:
      - injector.enabled=true (Vault Agent Injector)
      - vso.enabled=true (Vault Secrets Operator)
    ` -}}
  {{- end -}}

{{- end -}}
