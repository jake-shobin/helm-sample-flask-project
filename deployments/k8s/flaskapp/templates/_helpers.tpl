{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "flaskapp.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | lower | replace " " "-" | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "flaskapp.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | lower | replace " " "-" | trimSuffix "-" -}}
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
{{- define "flaskapp.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}


{{/*
Return the proper flaskapp image name
*/}}
{{- define "flaskapp.image" -}}
{{- $registryName := .Values.image.registry -}}
{{- $repositoryName := .Values.image.repository -}}
{{- $tag := .Values.image.tag | toString -}}
{{- if $registryName -}}
{{- printf "%s/%s:%s" $registryName $repositoryName $tag -}}
{{- else -}}
{{- printf "%s:%s" $repositoryName $tag -}}
{{- end -}}
{{- end -}}


{{- define "flaskapp.secretName" -}}
{{- include "flaskapp.name" . -}}
{{- end -}}

{{- define "flaskapp.pullSecret" -}}
{{- printf "%s-regcred" (include "flaskapp.name" .) -}}
{{- end -}}

{{- define "flaskapp.imagePullSecrets" -}}
{{- if .Values.image.dockerConfig }}
imagePullSecrets:
  - {{ include "flaskapp.pullSecret" . }}
{{- end -}}
{{- end -}}

{{- define "flaskapp.env" -}}
{{- $secretName := include "flaskapp.secretName" . }}
env:
  {{- range $name, $value := .Values.env }}
  - name: {{ $name }}
    value: {{ $value | quote }}
  {{ end }}
  {{ range $name, $key := .Values.envFromSecret }}
  - name: {{ $name }}
    valueFrom:
      secretKeyRef:
        name: {{ $secretName }}
        key: {{ $key }}
  {{ end }}
{{- end -}}
