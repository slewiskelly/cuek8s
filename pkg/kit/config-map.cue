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
	#Base// TODO(slewiskelly): Base contains `spec`, but ConfigMap does not.

	// Data to be stored.
	data: {
		[string]: string @input()
	} @input()

	patch: configMap: _

	resource: "ConfigMap": _ConfigMap & {_X: {
		data: X.data, metadata: X.metadata
	}} & X.patch.configMap
}

_ConfigMap: k8s.#ConfigMap & {
	_X: _

	metadata: _X.metadata.metadata

	data: _X.data
}
