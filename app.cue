package kube

import (
	core_v1 "k8s.io/api/core/v1"
)

// Contains abstractions on top of various Kubernetes resources.
//
// Available abstractions are:
//  - Application
//  - Config Map
//  - Cron Job
//  - Job
//
// See each type for detailed descriptions, as each abstraction may result in
// the generation of multiple Kubernetes resources.

// base is base configuration that is applicable to all resources.
//
// Fields set at the base level will apply to all resources, where as setting
// them on a per-resource basis will apply only to that resource.
base: {
	// Name of the resource.
	name: string

	// Environment in which the application will be running.
	// The environment may be either "dev", "lab", or "prod".
	environment: #Environment

	// Language of the application's runtime.
	// This is required to configure language specific configuration.
	lang: #Lang

	// Labels that are to be associated with the resource.
	labels: app: name

	// Namespace in which the application will be running.
	// Defaults to a combination of the service and the environment.
	namespace: string | *"\(service)-\(environment)"

	// Region in which the application will be running.
	region: #Region

	// The name of the service in which the application belongs.
	service: string
}

// Application is an abstraction of multiple Kubernetes resources.
//
// Depending on the configuration of the application it may generate the
// following resources:
//  - Deployment
//  - DestinationRule (if Istio is enabled)
//  - HorizontalPodAutoscaler
//  - Pipeline
//  - PodDisruptionBudget
//  - Service (if ports are exposed)
//  - VirtualService (if Istio is enabled)
application: [Name=_]: base & {
	_podSpec

	// Name of the application.
	name: Name

	// Spinnaker specific configuration.
	delivery: #Delivery

	// Docker image name, excluding the image registry prefix.
	// The image registry is assumed to be "gcr.io/$SERVICE-prod/".
	// Defaults to the application's name.
	image: string | *name

	// Minimum number of replicas, as a percentage, that must be available.
	// Replicas cannot be rescheduled until at least the number of repliacs
	// are available.
	// Defaults to "50%".
	minAvailable: string & =~"^([1-9]%$|^[1-9][0-9]%$|^100%)$" | *"50%"

	// Network configuration.
	network: {
		// Whether the application should use the Istio service mesh.
		// Defaults to false.
		istio: bool | *false
	}

	// Scaling configuration.
	scaling: {
		// Minimum number of replicas of the application.
		// This must always be greater than one, and less than or equal to, the
		// maximum number of replicas.
		// Defaults to 2.
		minReplicas: int

		// Maximum number of replicas of the application.
		// This must always be greater than, or equal to, the minimum number of
		// replicas.
		// Defaults to 3.
		maxReplicas: int

		// Target percentage CPU utilization before additional replicas are
		// created.
		// Defaults to "80%".
		targetCPU: string & =~"^([1-9]%$|^[1-9][0-9]%$|^100%)$" | *"80%"
	}

	// Patches to be applied to individual resources.
	// Patches will fail to apply if they have been set by the abstraction.
	patch: {
		deployment: {}
		destinationRule: {}
		horizontalPodAutoscaler: {}
		pipeline: {}
		podDisruptionBudget: {}
		service: {}
		virtualService: {}
	}
}

// ConfigMap is a minor abstraction of a Kubernetes ConfigMap.
configMap: [Name=_]: base & {
	// Name of the config map.
	name: Name

	// Key-value pairs representing the configuration data.
	data: [string]: string

	// Patches to be applied to individual resources.
	// Patches will fail to apply if they have been set by the abstraction.
	patch: configMap: {}
}

// Cron is an abstraction of a Kubernetes CronJob.
cron: [Name=_]: base & {
	_jobSpec
	_podSpec

	// Name of the job.
	name: Name

	// Specifies a CronJob's policy for concurrent execution:
	policy: #CronConcurrencyPolicy

	// Schedule in which the job should execute, in Cron format.
	// See https://en.wikipedia.org/wiki/Cron.
	schedule: string

	// Docker image name, excluding the image registry prefix.
	// The image registry is assumed to be "gcr.io/$SERVICE-prod/".
	// Defaults to the application's name.
	image: string | *Name

	// Network configuration.
	network: {
		// Whether the application should use the Istio service mesh.
		// Defaults to false.
		istio: bool | *false
	}

	// Patches to be applied to individual resources.
	// Patches will fail to apply if they have been set by the abstraction.
	patch: cron: {}
}

// Job is an abstraction of a Kubernetes Job.
job: [Name=_]: base & {
	_jobSpec
	_podSpec

	// Name of the job.
	name: Name

	// Docker image name, excluding the image registry prefix.
	// The image registry is assumed to be "gcr.io/$SERVICE-prod/".
	// Defaults to the application's name.
	image: string | *Name

	// Network configuration.
	network: {
		// Whether the application should use the Istio service mesh.
		// Defaults to false.
		istio: bool | *false
	}

	// Patches to be applied to individual resources.
	// Patches will fail to apply if they have been set by the abstraction.
	patch: job: {}
}

// Attributes that are common to all resources which contain a JobSpec.
_jobSpec: {
	// Number of completions of the job before signalling overall success.
	// A null completion signals success after a single completion, and allows
	// any number of instances to run in parallel.
	completions: *null | int

	// Maximum number of instances of the job that can be executed in parallel.
	// Number of executing instances may be lower if:
	// (completions - successes) < parallelism
	// Setting parallelism to zero blocks any instances from executing until
	// it is increased.
	// Defaults to 1.
	parallelism: int | *1

	// Number of seconds before the job is automatically deleted, after is has
	// completed. A null TTL signals that the job should not be automatically
	// deleted.
	ttl: *null | int
}

// Attributes that are common to all resources which contain a PodSpec.
_podSpec: {
	additionalContainers: [...core_v1.#Container]

	// Environment variables required by the application.
	// These environment variables are simple key/value pairs.
	env: [string]: string

	// Environment variables that are sourced from ConfigMaps or Secrets.
	envFrom: [...core_v1.#EnvFromSource]

	// Environment variables required by the application.
	// These environment variables are more complex structures than key/value
	// pairs, such as those that reference values from fields or secrets.
	envSpec: [string]: {}

	// Ports exposed by the application.
	// Ports specified here will be exposed by a corresponding service.
	expose: [Name=_]: #Port & {name: Name}

	// Docker image name, excluding the image registry prefix.
	// The image registry is assumed to be "gcr.io/$SERVICE-prod/".
	// Defaults to the application's name.
	image: string

	// Ports exposed by the application.
	// Ports specified here will _not_ be exposed by a corresponding service.
	port: [Name=_]: #Port & {name: Name}

	// Minimum and maximum resources required by the application.
	resources: #Resources

	// CloudSQL configuration.
	sql: {
		// Set of Cloud SQL instances the proxy is to connect.
		instances: [...string]
	}

	// Volumes to be mounted by the application.
	volume: [Name=_]: #Volume & {name: Name}

	// Standard gRPC port is exposed on TCP port 5000.
	expose: grpc: port: 5000

	// Standard monitoring port is exposed on TCP port 18000.
	port: healthz: port: 18000

	// Standard environment variables required by all applications.
	env: GOOGLE_APPLICATION_CREDENTIALS: "/etc/google/service-account.json"
	envSpec: DD_AGENT_HOSTNAME: valueFrom: fieldRef: fieldPath: "spec.nodeName"
	envSpec: FOO_KEY: valueFrom: secretKeyRef: {
		key:      "FOO_KEY"
		name:     "foo-key"
		optional: true
	}

	// Sets the simple key/value pair environment variables to the structure
	// required by a Kubernetes manifest.
	// To be ignored by users.
	envSpec: {
		for k, v in env {
			"\(k)": value: v
		}
	}

	// Standard volume is mounted, containing default GCP credentials.
	volume: "default-service-account": {
		mountPath: "/etc/google"
		source: secret: {
			defaultMode: 420
			secretName:  "default-service-account"
		}
	}
}

// CronConcurrencyPolicy specifies a CronJob's policy for concurrent execution:
//  - allow: concurrent executions are allowed
//  - forbid: concurreny executions are not allowed
//  - replace: existing executions will be cancelled, before starting a new one
// Defaults to allow.
#CronConcurrencyPolicy: *"allow" | "forbid" | "replace"

// Delivery specifies application rollout configuration.
#Delivery: {
	// Type of Spinnaker pipeline used to deploy an application.
	// Defaults to "basic".
	type: *"basic" | "canary"

	// Whether or not judgement stages should be approved by a person.
	// Defaults to true.
	manualJudgement: bool | *true

	// Percentage of additional replicas that may be created during a
	// rollout.
	// Defaults to "50%".
	maxSurge: string & =~"^([1-9]%$|^[1-9][0-9]%$|^100%)$" | *"50%"

	// Percentage of replicas that may be unavailable during a rollout.
	// Defaults to "0%".
	maxUnavailable: string & =~"^([1-9]%$|^[1-9][0-9]%$|^100%)$" | *"0%"

	// List of triggers that will start a new rollout.
	trigger: {
		// Whether automated triggers via Pub/Sub are enabled.
		// Defaults to false.
		enabled: bool | *false

		// Docker image tag regex of which to trigger a rollout.
		// Defaults to "master-.*".
		tag: string | *"master-.*"
	}
}

// Environment specifies the environment in which the resources are to be
// applied.
#Environment: "dev" | "lab" | "prod"

// Lang specifies supported programming languages.
// Defaults to "go".
#Lang: *"go" | "python"

// Port specifies an application's network port configuration.
#Port: {
	// Name of the port.
	name: string

	// Port number in which requests are served.
	port: int

	// Network transport protocol.
	// Defaults to "tcp".
	protocol: *"tcp" | "udp"

	// Port number in which the container is listening on.
	// Defaults to the port number.
	targetPort: int | *port
}

// Region specifies the region in which the application will run.
#Region: "osaka" | *"tokyo"

// Resources specifies an application's resource configuration.
#Resources: {
	// Minimum amount of resources required by an instance of an application.
	// CPU must be defined in millicpu, fractional requests are not permitted.
	// RAM must be defined in mebibytes.
	// Defaults to 500m CPU / 128MiB RAM.
	requests: {
		cpu:    int | *500
		memory: int | *128
	}

	// Maximum amount of resources that can be used by an instance of an
	// application.
	// CPU must be defined in millicpu, fractional limits are not permitted.
	// RAM must be defined in mebibytes.
	// Defaults to 500m CPU / 128MiB RAM.
	limits: {
		cpu:    int | *500
		memory: int | *128
	}

}

// Volume specifies an application's volume mount.
#Volume: {
	// Name of the volume.
	name: string

	// The path in which the volume is to be mounted.
	mountPath: string

	// Whether the volume is read-only.
	// Defaults to true.
	readOnly: bool | *true

	// Source of the volume mount.
	source: core_v1.#VolumeSource
}
