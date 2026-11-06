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
Env list without the variables that come from existingSecret, then those variables
as secretKeyRef. Args: (list .Values.pods.<x>.environment <existingSecret> <names...>)
*/}}
{{- define "linkwarden.env" -}}
{{- $envs := index . 0 | default list -}}
{{- $secret := index . 1 -}}
{{- $names := slice . 2 -}}
{{- $out := list -}}
{{- range $envs -}}
{{- if not (and $secret (has .name $names)) -}}
{{- $out = append $out . -}}
{{- end -}}
{{- end -}}
{{- if $secret -}}
{{- range $names -}}
{{- $out = append $out (dict "name" . "valueFrom" (dict "secretKeyRef" (dict "name" $secret "key" .))) -}}
{{- end -}}
{{- end -}}
{{- if $out -}}
{{- toYaml $out -}}
{{- end -}}
{{- end -}}
