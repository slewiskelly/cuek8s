package kit

import (
	"strings"

	"github.com/slewiskelly/cuek8s/pkg/k8s"

	core_v1 "k8s.io/api/core/v1"
)

// Service specifies a minor abstraction of a Kubernetes Service.
//
// Example:
// ```cue
// Service: kit.#Service & {
//     metadata: Metadata & {
//         serviceID: "acme-echo-jp"
//         name:      "http"
//     }
//
//     spec: {
//         expose: http: {port: 80, targetPort: 8080}
//         selector: App.metadata.labels
//         type: "NodePort"
//     }
// }
// ```
#Service: X={
	#Base

	spec: _#ServiceSpec

	patch: service: _

	resource: "Service": _Service & {_X: {
		spec: X.spec, metadata: X.metadata
	}} & X.patch.service
}

_#ServiceSpec: {
	// Ports exposed by the service.
	expose: {
		[Name=_]: #Port & {name: Name} @input()
	}

	// Label selector used to route traffic to the relevant Pod.
	selector: {
		[string]: string @input()
	}

	// Type of the service.
	type: #ServiceType @input()
}

// ServiceType specifies how the service is exposed.
//
// See https://kubernetes.io/docs/concepts/services-networking/service/#publishing-services-service-types
// for more information on service types.
#ServiceType: *"ClusterIP" | "ExternalName" | "NodePort" | "LoadBalancer"

_Service: k8s.#Service & {
	_X: _

	metadata: _X.metadata.metadata

	spec: {
		ports: [...core_v1.#ServicePort] | *[ for p in _X.spec.expose {
			name:       p.name
			port:       p.port
			protocol:   strings.ToUpper(p.protocol)
			targetPort: p.targetPort
		}]

		selector: _X.spec.selector

		type: _X.spec.type
	}
}
