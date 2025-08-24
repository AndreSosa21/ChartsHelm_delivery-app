{{- define "db.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "db.fullname" -}}
{{- printf "%s-%s" (include "db.name" .) .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
