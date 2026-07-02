{{- define "tailscale-router.fullname" -}}
{{- .Release.Name -}}
{{- end -}}

{{- define "tailscale-router.labels" -}}
app.kubernetes.io/name: tailscale-router
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}
