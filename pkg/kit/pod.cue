package kit

import (
	core_v1 "k8s.io/api/core/v1"
)

// Attributes that are common to all resources which contain a PodSpec.
#PodSpec: {
	// Containers to be run in addition to the primary container.
	additionalContainers: [...core_v1.#Container] @input()

	// Arguments to the primary container's entrypoint.
	args: [...string] @input()

	// Command that replaces the primary container's entrypoint.
	command: [...string] @input()

	// Environment variables required by the application.
	//
	// These environment variables are simple key/value pairs.
	env: {
		[string]: string @input()
	}

	// Environment variables that are sourced from ConfigMaps or Secrets.
	envFrom: [...core_v1.#EnvFromSource] @input()

	// Environment variables required by the application.
	//
	// These environment variables are more complex structures than key/value
	// pairs, such as those that reference values from fields or secrets.
	envSpec: {
		[string]: _ @input()
	}

	// Ports exposed by the application.
	//
	// Ports specified here will be exposed by a corresponding service.
	expose: {
		[Name=_]: #Port & {name: Name} @input()
	}

	// Initialization containers to be run before the primary (and any
	// additional containers that have been specified) will be started.
	//
	// Initialization containers are run in the order they are specified.
	//
	// All specified initialization containers will be ordered after critical
	// initizaliation container(s) have been run. Critical initializarion
	// containers will be added by the abstraction.
	initContainers: [...core_v1.#Container] @input()

	// Network configuration.
	network: #Network @input()

	// Ports exposed by the application.
	// Ports specified here will _not_ be exposed by a corresponding service.
	port: {
		[Name=_]: #Port & {name: Name} @input()
	}

	// Resources requirements of the application.
	resources: #Resources @input()

	// Tolerations used by scheduler.
	tolerations: {
		// Whether an application uses preemptible nodes.
		preemptible: bool | *false @input()
	} @input()

	// Volumes to be mounted by the application.
	volume: {
		[Name=_]: #Volume & {name: Name} @input()
	}
}
