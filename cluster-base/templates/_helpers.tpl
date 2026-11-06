{{- define "cluster-base.labels" -}}
app.kubernetes.io/name: cluster-base
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version }}
{{- end -}}

{{/* ExternalSecret CRDs may not exist yet on a fresh cluster */}}
{{- define "cluster-base.crdAnnotations" -}}
argocd.argoproj.io/sync-options: SkipDryRunOnMissingResource=true
{{- end -}}
