{{- define "hello-nginx.name" -}}
{{ .Chart.Name }}
{{- end }}

{{- define "hello-nginx.fullname" -}}
{{ .Release.Name }}
{{- end }}

{{- define "hello-nginx.labels" -}}
app.kubernetes.io/name: {{ include "hello-nginx.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "hello-nginx.selectorLabels" -}}
app.kubernetes.io/name: {{ include "hello-nginx.name" . }}
app.kubernetes.io/instance: {{ include "hello-nginx.fullname" }}
{{- end }}

