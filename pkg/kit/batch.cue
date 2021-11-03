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
//     spec: image: "loadtester"
// }
// ```
#Batch: X={
	#Base

	spec: {
		#JobSpec, #PodSpec

		// By default a Job resource is generated, but specifying a schedule
		// will generate a CronJob resource instead.
		cron?: {
			// Specifies a CronJob's policy for concurrent execution.
			policy: #CronConcurrencyPolicy @input()

			// Schedule in which the job should execute, in Cron format.
			// See https://en.wikipedia.org/wiki/Cron.
			schedule: string @input()
		}

		// Application's Docker image name, excluding the image registry prefix.
		//
		// The image registry is assumed to be "gcr.io/$SERVICE-prod/".
		image: acme.#Name | *X.metadata.name @input()
	} @input()

	patch: {
		container: {...}
		cron: {...}
		job: {...}
	}

	if X.spec.cron == _|_ {
		resource: "Job": _#Job & {_X: {
			spec: X.spec, metadata: X.metadata, patch: container: X.patch.container
		}} & X.patch.job
	}

	if X.spec.cron != _|_ {
		resource: "CronJob": _#CronJob & {_X: {
			spec: X.spec, metadata: X.metadata, patch: container: X.patch.container
		}} & X.patch.cron
	}
}

// CronConcurrencyPolicy specifies a CronJob's policy for concurrent execution.
//
//  - allow: concurrent executions are allowed
//  - forbid: concurreny executions are not allowed
//  - replace: existing executions will be canceled, before starting a new one
#CronConcurrencyPolicy: *"allow" | "forbid" | "replace"

// Attributes that are common to all resources which contain a JobSpec.
#JobSpec: {
	// Number of completions of the job before signaling overall success.
	//
	// A null completion signals success after a single completion, and allows
	// any number of instances to run in parallel.
	completions: *null | int

	// Maximum number of instances of the job that can be executed in parallel.
	//
	// Number of executing instances may be lower if:
	// (completions - successes) < parallelism
	//
	// Setting parallelism to zero blocks any instances from executing until
	// it is increased.
	parallelism: int | *1

	// Number of seconds before the job is automatically deleted, after is has
	// completed. A null TTL signals that the job should not be automatically
	// deleted.
	ttl: *null | int
}

_#CronJob: k8s.#CronJob & {
	_X: {...}

	metadata: _X.metadata.metadata

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
		_#Primary & {_Y: _X} & _X.patch.container,
		for x in _X.spec.additionalContainers {x},
	]
}

_#Job: k8s.#Job & {
	_X: {...}

	metadata: _X.metadata.metadata

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
		_#Primary & {_Y: _X} & _X.patch.container,
		for x in _X.spec.additionalContainers {x},
	]
}
