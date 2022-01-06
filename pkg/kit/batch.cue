package kit

import (
	"strings"

	"github.com/slewiskelly/cuek8s/pkg/k8s"
	"github.com/slewiskelly/cuek8s/pkg/acme"
)

// Batch is an abstraction of multiple Kubernetes resources.
//
// Depending on the configuration of the application it may generate the
// following resources:
//  - CronJob or Job
//
// Example:
// ```cue
// Batch: kit.#Batch & {
//     metadata: {
//         name: "loadtester"
//         serviceID: "acme-echo-jp"
//     }
//
//     spec: image: name: "loadtester"
// }
// ```
#Batch: X={
	#Base

	spec: {
		#BatchSpec, #PodSpec

		// Workload image configuration.
		image: #ImageSpec | *{
			// Application's Docker registry name.
			//
			// Defaults to "gcr.io/$SERVICE_ID-prod/".
			registry: string | *"gcr.io/\(X.metadata.serviceID)-prod"

			// Application's Docker image name.
			//
			// Defaults to the name of the application.
			name: acme.#Name | *X.metadata.name
		} @input()
	}

	patch: {
		container: _
		cron:      _
		job:       _
	}

	if X.spec.cron == null {
		resource: "Job": _Job & {_X: {
			spec: X.spec, metadata: X.metadata, patch: container: X.patch.container
		}} & X.patch.job
	}

	if X.spec.cron != null {
		resource: "CronJob": _CronJob & {_X: {
			spec: X.spec, metadata: X.metadata, patch: container: X.patch.container
		}} & X.patch.cron
	}
}

// CronConcurrencyPolicy specifies a CronJob's policy for concurrent execution:
//  - allow: concurrent executions are allowed
//  - forbid: concurreny executions are not allowed
//  - replace: existing executions will be canceled, before starting a new one
#CronConcurrencyPolicy: *"allow" | "forbid" | "replace"

// Attributes that are common to all resources which contain a JobSpec.
#BatchSpec: {
	// Number of completions of the job before signaling overall success.
	//
	// A null completion signals success after a single completion, and allows
	// any number of instances to run in parallel.
	completions: *null | int @input()

	// By default a Job resource is generated, but specifying a schedule
	// will generate a CronJob resource instead.
	cron: *null | {
		// Specifies a CronJob's policy for concurrent execution.
		policy: #CronConcurrencyPolicy @input()

		// Schedule in which the job should execute, in Cron format.
		// See https://en.wikipedia.org/wiki/Cron.
		schedule: string @input()
	} @input()

	// Maximum number of instances of the job that can be executed in parallel.
	//
	// Number of executing instances may be lower if:
	// (completions - successes) < parallelism
	//
	// Setting parallelism to zero blocks any instances from executing until
	// it is increased.
	parallelism: int | *1 @input()

	// Number of seconds before the job is automatically deleted, after is has
	// completed. A null TTL signals that the job should not be automatically
	// deleted.
	ttl: *null | int @input()
}

_CronJob: k8s.#CronJob & {
	_X: _

	metadata: _X.metadata.metadata & {
		annotations: {
			"kubectl.kubernetes.io/default-container": _X.metadata.name
		}
	}

	spec: {
		concurrencyPolicy: strings.ToTitle(_X.spec.cron.policy)
		schedule:          _X.spec.cron.schedule

		jobTemplate: spec: {
			if _X.spec.completions != null {
				completions: _X.spec.completions
			}

			if _X.spec.ttl != null {
				ttlSecondsAfterFinished: _X.spec.ttl
			}

			parallelism: _X.spec.parallelism

			template: {
				metadata: labels:                               _X.metadata.labels
				spec: volumes: [ for v in _X.spec.volume {name: v.name, v.source}]
			}
		}
	}

	spec: jobTemplate: spec: template: spec: initContainers: [
		for x in _X.spec.initContainers {x},
	]

	spec: jobTemplate: spec: template: spec: containers: [
		_Primary & {_Y: _X} & _X.patch.container,
		for x in _X.spec.additionalContainers {x},
	]
}

_Job: k8s.#Job & {
	_X: _

	metadata: _X.metadata.metadata & {
		annotations: {
			"kubectl.kubernetes.io/default-container": _X.metadata.name
		}
	}

	spec: {
		if _X.spec.completions != null {
			completions: _X.spec.completions
		}

		if _X.spec.ttl != null {
			ttlSecondsAfterFinished: _X.spec.ttl
		}

		parallelism: _X.spec.parallelism

		template: {
			metadata: labels:                               _X.metadata.labels
			spec: volumes: [ for v in _X.spec.volume {name: v.name, v.source}]
		}
	}

	spec: template: spec: initContainers: [
		for x in _X.spec.initContainers {x},
	]

	spec: template: spec: containers: [
		_Primary & {_Y: _X} & _X.patch.container,
		for x in _X.spec.additionalContainers {x},
	]
}
