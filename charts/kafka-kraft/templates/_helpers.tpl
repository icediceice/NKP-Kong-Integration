{{/*
kafka-kraft chart helpers
*/}}

{{/*
Full name for the Kafka StatefulSet and headless service.
Format: <release>-kafka
*/}}
{{- define "kafka-kraft.kafkaFullname" -}}
{{- printf "%s-kafka" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Headless service name (used for pod DNS in StatefulSet).
*/}}
{{- define "kafka-kraft.headlessServiceName" -}}
{{- printf "%s-kafka-headless" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Client service name (ClusterIP for Kafka clients on port 9092).
*/}}
{{- define "kafka-kraft.clientServiceName" -}}
{{- printf "%s-kafka-client" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Schema Registry service name.
*/}}
{{- define "kafka-kraft.srServiceName" -}}
{{- printf "%s-schema-registry" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Control Center service names.
*/}}
{{- define "kafka-kraft.ccServiceName" -}}
{{- printf "%s-control-center" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "kafka-kraft.ccLbServiceName" -}}
{{- printf "%s-cc-lb" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Schema Registry LoadBalancer service name.
*/}}
{{- define "kafka-kraft.srLbServiceName" -}}
{{- printf "%s-sr-lb" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
ConfigMap name for the KRaft cluster ID.
*/}}
{{- define "kafka-kraft.clusterIdConfigMapName" -}}
{{- printf "%s-kafka-cluster-id" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
KRaft controller quorum voters string.
Generates: 0@<release>-kafka-0.<headless-svc>.<ns>.svc.cluster.local:9093,...
*/}}
{{- define "kafka-kraft.quorumVoters" -}}
{{- $voters := list -}}
{{- $release := .Release.Name -}}
{{- $ns := .Release.Namespace -}}
{{- $headless := include "kafka-kraft.headlessServiceName" . -}}
{{- range $i, $_ := until (int .Values.kafka.replicaCount) -}}
  {{- $voter := printf "%d@%s-kafka-%d.%s.%s.svc.cluster.local:9093" $i $release $i $headless $ns -}}
  {{- $voters = append $voters $voter -}}
{{- end -}}
{{- join "," $voters -}}
{{- end -}}

{{/*
Common labels for all resources.
*/}}
{{- define "kafka-kraft.labels" -}}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}
