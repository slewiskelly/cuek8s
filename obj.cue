package kube

import (
	"math"
	"strings"
	"strconv"

	"github.com/slewiskelly/cuek8s/pkg/k8s"
)

// All objects.
allObjects: [ for v in _allObjects for x in v {x}]

// Objects that are managed (deployed via Spinnaker).
managedObjects: [ for v in _managedObjects for x in v {x}]

// Objects that are unmanaged (deployed via `kubectl`).
unmanagedObjects: [ for v in _unmanagedObjects for x in v {x}]

configMaps: {
	for k, x in configMap {
		"\(k)": (_configMap & {X: x}).X.kubernetes & x.patch.configMap
	}
}

cronJobs: {
	for k, x in cron {
		"\(k)": (_cronJob & {X: x}).X.kubernetes & x.patch.cron
	}
}

deployments: {
	for k, x in application {
		"\(k)": (_deployment & {X: x}).X.kubernetes & x.patch.deployment
	}
}

destinationRules: {
	for k, x in application if x.delivery.type == "canary" {
		"\(k)": (_destinationRule & {X: x}).X.kubernetes & x.patch.destinationRule
	}
}

horizontalPodAutoscalers: {
	for k, x in application {
		"\(k)": (_horizontalPodAutoscaler & {X: x}).X.kubernetes & x.patch.horizontalPodAutoscaler
	}
}

jobs: {
	for k, x in job {
		"\(k)": (_job & {X: x}).X.kubernetes & x.patch.job
	}
}

podDisruptionBudgets: {
	for k, x in application {
		"\(k)": (_podDisruptionBudget & {X: x}).X.kubernetes & x.patch.podDisruptionBudget
	}
}

pipelines: {
	for k, x in application {
		"\(k)": (_pipeline & {X: x}).X.kubernetes & x.patch.pipeline
	}
}

services: {
	for k, x in application if len (x.expose) > 0 {
		"\(k)": (_service & {X: x}).X.kubernetes & x.patch.service
	}
}

virtualServices: {
	for k, x in application if x.delivery.type == "canary" {
		"\(k)": (_virtualService & {X: x}).X.kubernetes & x.patch.virtualService
	}
}

_allObjects: [
	managedObjects,
	unmanagedObjects,
]

_managedObjects: [
	cronJobs,
	deployments,
	jobs,
	pipelines,
	services,
	virtualServices,
]

_unmanagedObjects: [
	configMaps,
	destinationRules,
	horizontalPodAutoscalers,
	podDisruptionBudgets,
]

_configMap: X: kubernetes: k8s.#ConfigMap & {
	metadata: {
		labels:    X.labels
		name:      X.name
		namespace: X.namespace
	}

	data: X.data
}

_cronJob: X: kubernetes: k8s.#CronJob & {
	metadata: {
		labels:    X.labels
		name:      X.name
		namespace: X.namespace
	}

	spec: {
		concurrencyPolicy: strings.ToTitle(X.policy)
		schedule:          X.schedule

		jobTemplate: spec: {
			if X.completions != null {
				completions: X.completions
			}

			if X.ttl != null {
				ttlSecondsAfterFinished: X.ttl
			}

			parallelism: X.parallelism

			template: {
				metadata: labels:                         X.labels
				spec: volumes: [ for v in X.volume {name: v.name, v.source}]
			}
		}
	}

	spec: jobTemplate: spec: template: spec: containers: [
		// Primary container.
		{
			name:  X.name
			image: "gcr.io/\(X.service)-prod/\(X.image)"

			envFrom: [ for x in X.envFrom {x}, {
				configMapRef: name: "default-configmap"
			}]

			env: [ for k, v in X.envSpec {v, name: k}]

			if X.network.istio {
				lifecycle: preStop: exec: command: [
					"/bin/sh", "-c",
					"sleep 30; wget -qO- --post-data '' localhost:15000/healthcheck/fail; sleep 45; wget -qO- --post-data '' localhost:15000/healthcheck/ok;",
				]
			}

			ports: [ for k, p in X.expose & X.port {
				containerPort: p.targetPort
				name:          k
				protocol:      strings.ToUpper(p.protocol)
			}]

			resources: {
				requests: {
					cpu:    "\(X.resources.requests.cpu)m"
					memory: "\(X.resources.requests.memory)Mi"
				}
				limits: {
					cpu:    "\(X.resources.limits.cpu)m"
					memory: "\(X.resources.limits.memory)Mi"
				}
			}

			// TODO(slewiskelly): These values likely need to be overriden
			// from time-to-time.
			readinessProbe: {
				failureThreshold: 3
				httpGet: {
					path:   "/healthz/readiness"
					port:   "healthz"
					scheme: "HTTP"
				}
				initialDelaySeconds: 5
				periodSeconds:       10
				successThreshold:    1
				timeoutSeconds:      1
			}

			// TODO(slewiskelly): These values likely need to be overriden
			// from time-to-time.
			livenessProbe: {
				failureThreshold: 3
				httpGet: {
					path:   "/healthz/liveness"
					port:   "healthz"
					scheme: "HTTP"
				}
				initialDelaySeconds: 5
				periodSeconds:       10
				successThreshold:    1
				timeoutSeconds:      1
			}

			securityContext: {
				privileged:             false
				readOnlyRootFilesystem: true
			}

			volumeMounts: [ for v in X.volume {
				name:      v.name
				mountPath: v.mountPath
				readOnly:  v.readOnly
			}]
		},
		// CloudSQL proxy, if any SQL instances have been specified.
		if len(X.sql.instances) > 0 {
			{
				name:  "cloud-sql-proxy"
				image: "gcr.io/cloudsql-docker/gce-proxy:1.17"

				command: [
					"/cloud_sql_proxy",
					"-credential_file=/etc/google/service-account.json",
					"-ip_address_types=PRIVATE",
					"-instances=\(strings.Join(X.sql.instances, ","))",
				]

				volumeMounts: [{
					name:      "default-service-account"
					mountPath: "/etc/google"
					readOnly:  true
				}]
			}
		},
		// Additional containers specified by the user.
		for x in X.additionalContainers {x},
	]
}

_deployment: X: kubernetes: k8s.#Deployment & {
	metadata: {
		labels:    X.labels
		name:      X.name
		namespace: X.namespace
		annotations: {
			if X.network.istio {
				"sidecar.istio.io/inject":           "true"
				"sidecar.istio.io/proxyCPU":         "\(math.Ceil(X.resources.requests.cpu*0.5))m"
				"sidecar.istio.io/proxyCPULimit":    "\(math.Ceil(X.resources.limits.cpu*0.75))m"
				"sidecar.istio.io/proxyMemory":      "256Mi"
				"sidecar.istio.io/proxyMemoryLimit": "512Mi"
			}
		}
	}

	spec: {
		selector: matchLabels: X.labels

		strategy: rollingUpdate: {
			maxSurge:       X.delivery.maxSurge
			maxUnavailable: X.delivery.maxUnavailable
		}

		template: {
			metadata: {
				labels: X.labels
				annotations: {
					"ad.datadoghq.com/\(X.image).init_configs": "[{}]"
					"ad.datadoghq.com/\(X.image).logs":         "\"source\":\"docker\",\"service\":\"\(X.service)\",\"tags\":[\"env:\(X.environment)\"]}]"

					if X.lang == "go" {
						"ad.datadoghq.com\(X.image).check_names": #"["go_expvar"]"#
						"ad.datadoghq.com/\(X.image).instances":  """
				[{"expvar_url":"http://%%host%%:\(X.port.healthz.port)", "metrics":[
				    {"path":"cpustats/cpus", "alias":"go_expvar.cpustats.cpus", "type": "gauge"},
				    {"path":"cpustats/goroutines", "alias":"go_expvar.cpustats.goroutines", "type": "gauge"},
				    {"path":"cpustats/cgo_calls", "alias":"go_expvar.cpustats.cgo_calls", "type": "gauge"},
				    {"path":"cpustats/threads", "alias":"go_expvar.cpustats.threads", "type": "gauge"}]
				}]
				"""
					}
				}
			}

			spec: {
				if X.network.istio {
					terminationGracePeriodSeconds: int & >90 | *90
				}

				volumes: [ for v in X.volume {name: v.name, v.source}]
			}
		}
	}

	spec: template: spec: containers: [
		// Primary container.
		{
			name:  X.name
			image: "gcr.io/\(X.service)-prod/\(X.image)"

			envFrom: [ for x in X.envFrom {x}, {
				configMapRef: name: "default-configmap"
			}]

			env: [ for k, v in X.envSpec {v, name: k}]

			if X.network.istio {
				lifecycle: preStop: exec: command: [
					"/bin/sh", "-c",
					"sleep 30; wget -qO- --post-data '' localhost:15000/healthcheck/fail; sleep 45; wget -qO- --post-data '' localhost:15000/healthcheck/ok;",
				]
			}

			ports: [ for k, p in X.expose & X.port {
				containerPort: p.targetPort
				name:          k
				protocol:      strings.ToUpper(p.protocol)
			}]

			resources: {
				requests: {
					cpu:    "\(X.resources.requests.cpu)m"
					memory: "\(X.resources.requests.memory)Mi"
				}
				limits: {
					cpu:    "\(X.resources.limits.cpu)m"
					memory: "\(X.resources.limits.memory)Mi"
				}
			}

			// TODO(slewiskelly): These values likely need to be overriden
			// from time-to-time.
			readinessProbe: {
				failureThreshold: 3
				httpGet: {
					path:   "/healthz/readiness"
					port:   "healthz"
					scheme: "HTTP"
				}
				initialDelaySeconds: 5
				periodSeconds:       10
				successThreshold:    1
				timeoutSeconds:      1
			}

			// TODO(slewiskelly): These values likely need to be overriden
			// from time-to-time.
			livenessProbe: {
				failureThreshold: 3
				httpGet: {
					path:   "/healthz/liveness"
					port:   "healthz"
					scheme: "HTTP"
				}
				initialDelaySeconds: 5
				periodSeconds:       10
				successThreshold:    1
				timeoutSeconds:      1
			}

			securityContext: {
				privileged:             false
				readOnlyRootFilesystem: true
			}

			volumeMounts: [ for v in X.volume {
				name:      v.name
				mountPath: v.mountPath
				readOnly:  v.readOnly
			}]
		},
		// CloudSQL proxy, if any SQL instances have been specified.
		if len(X.sql.instances) > 0 {
			{
				name:  "cloud-sql-proxy"
				image: "gcr.io/cloudsql-docker/gce-proxy:1.17"

				command: [
					"/cloud_sql_proxy",
					"-credential_file=/etc/google/service-account.json",
					"-ip_address_types=PRIVATE",
					"-instances=\(strings.Join(X.sql.instances, ","))",
				]

				volumeMounts: [{
					name:      "default-service-account"
					mountPath: "/etc/google"
					readOnly:  true
				}]
			}
		},
		// Additional containers specified by the user.
		for x in X.additionalContainers {x},
	]
}

_destinationRule: X: kubernetes: {
	apiVersion: "networking.istio.io/v1alpha3"
	kind:       "DestinationRule"

	metadata: {
		labels:    X.labels
		name:      X.name
		namespace: X.namespace
	}

	spec: {
		host: X.name
		subsets: [{
			labels: version: "main"
			name: "main"
		}, {
			labels: version: "baseline"
			name: "baseline"
		}, {
			labels: version: "canary"
			name: "canary"
		}]
	}
}

_horizontalPodAutoscaler: X: kubernetes: k8s.#HorizontalPodAutoscaler & {
	metadata: {
		labels:    X.labels
		name:      X.name
		namespace: X.namespace
	}

	spec: {
		minReplicas: X.scaling.minReplicas
		maxReplicas: X.scaling.maxReplicas

		scaleTargetRef: {
			// Fine to assume that the kind is a Deployment, for now.
			apiVersion: "apps/v1"
			kind:       "Deployment"
			name:       X.name
		}

		targetCPUUtilizationPercentage: strconv.Atoi(strings.TrimSuffix(X.scaling.targetCPU, "%"))
	}
}

_job: X: kubernetes: k8s.#Job & {
	metadata: {
		labels:    X.labels
		name:      X.name
		namespace: X.namespace
	}

	spec: {
		if X.completions != null {
			completions: X.completions
		}

		if X.ttl != null {
			ttlSecondsAfterFinished: X.ttl
		}

		parallelism: X.parallelism

		template: {
			metadata: labels:                         X.labels
			spec: volumes: [ for v in X.volume {name: v.name, v.source}]
		}
	}

	spec: template: spec: containers: [
		// Primary container.
		{
			name:  X.name
			image: "gcr.io/\(X.service)-prod/\(X.image)"

			envFrom: [ for x in X.envFrom {x}, {
				configMapRef: name: "default-configmap"
			}]

			env: [ for k, v in X.envSpec {v, name: k}]

			if X.network.istio {
				lifecycle: preStop: exec: command: [
					"/bin/sh", "-c",
					"sleep 30; wget -qO- --post-data '' localhost:15000/healthcheck/fail; sleep 45; wget -qO- --post-data '' localhost:15000/healthcheck/ok;",
				]
			}

			ports: [ for k, p in X.expose & X.port {
				containerPort: p.targetPort
				name:          k
				protocol:      strings.ToUpper(p.protocol)
			}]

			resources: {
				requests: {
					cpu:    "\(X.resources.requests.cpu)m"
					memory: "\(X.resources.requests.memory)Mi"
				}
				limits: {
					cpu:    "\(X.resources.limits.cpu)m"
					memory: "\(X.resources.limits.memory)Mi"
				}
			}

			// TODO(slewiskelly): These values likely need to be overriden
			// from time-to-time.
			readinessProbe: {
				failureThreshold: 3
				httpGet: {
					path:   "/healthz/readiness"
					port:   "healthz"
					scheme: "HTTP"
				}
				initialDelaySeconds: 5
				periodSeconds:       10
				successThreshold:    1
				timeoutSeconds:      1
			}

			// TODO(slewiskelly): These values likely need to be overriden
			// from time-to-time.
			livenessProbe: {
				failureThreshold: 3
				httpGet: {
					path:   "/healthz/liveness"
					port:   "healthz"
					scheme: "HTTP"
				}
				initialDelaySeconds: 5
				periodSeconds:       10
				successThreshold:    1
				timeoutSeconds:      1
			}

			securityContext: {
				privileged:             false
				readOnlyRootFilesystem: true
			}

			volumeMounts: [ for v in X.volume {
				name:      v.name
				mountPath: v.mountPath
				readOnly:  v.readOnly
			}]
		},
		// CloudSQL proxy, if any SQL instances have been specified.
		if len(X.sql.instances) > 0 {
			{
				name:  "cloud-sql-proxy"
				image: "gcr.io/cloudsql-docker/gce-proxy:1.17"

				command: [
					"/cloud_sql_proxy",
					"-credential_file=/etc/google/service-account.json",
					"-ip_address_types=PRIVATE",
					"-instances=\(strings.Join(X.sql.instances, ","))",
				]

				volumeMounts: [{
					name:      "default-service-account"
					mountPath: "/etc/google"
					readOnly:  true
				}]
			}
		},
		// Additional containers specified by the user.
		for x in X.additionalContainers {x},
	]
}

_pipeline: X: kubernetes: {
	apiVersion: "delivery.platform.acme.in/v1"
	kind:       "Pipeline"

	metadata: {
		name:      X.name
		namespace: X.namespace
	}

	spec: {
		name:     "Deploy \(X.name) to \(X.environment)"
		template: X.delivery.type

		variables: {
			dockerImageName: X.image
			manifestType:    "gcs"
			manifestURL:     "gs://acme-kubernetes/master/cuek8s/microservices/\(X.service)/\(X.environment)/\(X.region)/\(X.name).yaml"
			manualJudgment:  X.delivery.manualJudgement
		}
		if X.delivery.trigger.enabled {
			triggers: pubsub: {
				enabled: true
				tag:     X.delivery.trigger.tag
			}
		}
	}
}

_podDisruptionBudget: X: kubernetes: k8s.#PodDisruptionBudget & {
	metadata: {
		labels:    X.labels
		name:      X.name
		namespace: X.namespace
	}

	spec: {
		minAvailable: X.minAvailable
		selector: matchLabels: X.labels
	}
}

_service: X: kubernetes: k8s.#Service & {
	metadata: {
		labels:    X.labels
		name:      X.name
		namespace: X.namespace
	}

	spec: {
		selector: X.labels

		ports: [ for p in X.expose {
			name:       p.name
			port:       p.port
			protocol:   strings.ToUpper(p.protocol)
			targetPort: p.targetPort
		}]
	}
}

_virtualService: X: kubernetes: {
	apiVersion: "networking.istio.io/v1alpha3"
	kind:       "VirtualService"

	metadata: {
		labels:    X.labels
		name:      X.name
		namespace: X.namespace
	}

	spec: {
		hosts: X.name

		http: [{
			route: [{
				destination: {
					host:   X.name
					subset: "main"
				}
				weight: 100
			}, {
				destination: {
					host:   X.name
					subset: "canary"
				}
				weight: 0
			}, {
				destination: {
					host:   X.name
					subset: "baseline"
				}
				weight: 0
			}]
		}]
	}
}
