package kit

import (
	"github.com/slewiskelly/cuek8s/pkg/k8s"
)

// Base specifies base configuration for all kit resources (with a minor
// exception being made to the Pipeline resource and its variants).
#Base: X={
	// Metadata about the resource(s).
	metadata: #Metadata @input()

	// Specification used to configure the resource(s).
	spec: _ @input()

	// Patches can be applied to individual resources.
	//
	// Patching is not intended to be the primary method of configuration, it
	// provides a mechanism to reach down directly to the Kubernetes interface
	// for one of the following few reasons:
	// *   Setting values that have not been generated, as they are neither
	//     **required** nor **recommended**
	// *   Overriding **recommended** values
	//     *   Commonly used configuration options are available via `spec`, and
	//         is the way most configuration should be applied by a user
	//
	// Patches will fail to apply if attempting to override **required** values.
	patch: [string]: _

	// Generated Kubernetes resource keyed by the name of the resource.
	resource: [string]: k8s.#Resource

	// Generated Kubernetes resource list.
	resources: [ for _, x in X.resource {x}]
}
