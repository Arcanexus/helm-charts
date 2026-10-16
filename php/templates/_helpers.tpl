{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "app.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "app.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "app.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Base name of the workloads (also their `app` selector label): <chart>-<release>.
*/}}
{{- define "php.workload" -}}
{{- printf "%s-%s" (include "app.name" .) .Release.Name -}}
{{- end -}}

{{/*
Common labels. Pass a dict with "ctx" (root context) and "name".
*/}}
{{- define "php.labels" -}}
app.kubernetes.io/name: {{ .name }}
helm.sh/chart: {{ include "app.chart" .ctx }}
app.kubernetes.io/instance: {{ .ctx.Release.Name }}
app.kubernetes.io/managed-by: {{ .ctx.Release.Service }}
{{- end -}}

{{/*
Name of the Secret holding the MariaDB credentials (keys root-password, username, password).
*/}}
{{- define "php.mariadb.secret" -}}
{{- default (printf "%s-aws-secrets" (include "app.fullname" .)) .Values.mariadb.existingSecret -}}
{{- end -}}

{{/*
TCP readiness/liveness probes. Pass a dict with "port".
*/}}
{{- define "php.tcpProbes" -}}
readinessProbe:
  tcpSocket:
    port: {{ .port }}
  periodSeconds: 10
livenessProbe:
  tcpSocket:
    port: {{ .port }}
  initialDelaySeconds: 30
  periodSeconds: 20
  failureThreshold: 6
{{- end -}}
