{{/*
Determine if the environment should be included in the hostname. "prod" will evaluate as blank
*/}}
{{- define "envname_suffix" -}}
	{{- if hasKey .Values.vanity_hostname "hostname_environment_override" -}}
		{{- if .Values.vanity_hostname.hostname_environment_override -}}
			{{- print "-" .Values.vanity_hostname.hostname_environment_override -}}
		{{- end -}}
	{{- else -}}
		{{- if eq ( required "need .Values.environment" .Values.environment ) "prod" -}}
			{{- print "" -}}
		{{- else -}}
			{{- print "-" .Values.environment -}}
		{{- end -}}
	{{- end -}}
{{- end }}

{{- define "render_cluster_hostname" }}
	{{-  $global       := .global -}}
	{{-  $prefix       := .prefix -}}
	{{- if ( include "using_cluster_hostname" $global ) -}}
		{{ print $prefix "-" $global.Release.Namespace "." ( required "need .Values.nonprod_cluster_domain" $global.Values.nonprod_cluster_domain ) }}
	{{- else }}
		{{- fail "Cannot reference a cluster hostname when .Values.vanity_hostname.vanity_only is set" -}}
	{{- end -}}
{{- end }}

{{- define "render_vanity_hostname" }}
	{{-  $global       := .global -}}
	{{-  $prefix       := .prefix -}}
	{{- if ( include "using_vanity_hostname" $global ) -}}
		{{ print $prefix ( include "envname_suffix" $global ) $global.Values.vanity_hostname.suffix }}
	{{- else }}
		{{- fail "need .Values.vanity_hostname.suffix to be defined" -}}
	{{- end }}
{{- end }}

{{- define "using_cluster_hostname" -}}
	{{- if not ( and .Values.vanity_hostname.suffix .Values.vanity_hostname.vanity_only ) -}}
		{{ print "true" }}
	{{- end -}}
{{- end -}}

{{- define "using_vanity_hostname" -}}
	{{- if .Values.vanity_hostname.suffix -}}
		{{ print "true" }}
	{{- end -}}
{{- end -}}

{{/*
Render a vanity hostname if one exists.
Otherwise use the cluster hostname
*/}}
{{- define "render_canonical_hostname" -}}
	{{-  $global       := .global -}}
	{{-  $prefix       := .prefix -}}
	{{- if ( include "using_vanity_hostname" $global ) -}}
		{{- print ( include "render_vanity_hostname" (dict "global" $global "prefix" $prefix) ) -}}
	{{- else -}}
		{{- print ( include "render_cluster_hostname" (dict "global" $global "prefix" $prefix) ) -}}
	{{- end }}
{{- end }}
