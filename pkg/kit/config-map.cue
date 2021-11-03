package kit

import (
	"github.com/slewiskelly/cuek8s/pkg/k8s"
)

// ConfigMap specifies a minor abstraction of a Kubernetes ConfigMap.
//
// Example:
// ```cue
// ConfigMap: kit.#ConfigMap & {
//     metadata: {
//         name: "config"
//         serviceID: "acme-echo-jp"
//     }
//
//    data: FOO: "BAR"
// }
// ```
#ConfigMap: X={
	#Base

	// Data to be stored.
	data: {
		[string]: string @input()
	}

	patch: configMap: {...}

	resource: "ConfigMap": _#ConfigMap & {_X: {
		data: X.data, metadata: X.metadata
	}} & X.patch.configMap
}

_#ConfigMap: k8s.#ConfigMap & {
	_X: {...}

	metadata: _X.metadata.metadata

	data: _X.data
}
