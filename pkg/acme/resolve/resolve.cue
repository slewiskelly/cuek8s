// Package resolve provides helpers used to resolve various information.
package resolve

import (
	"strings"

	"github.com/slewiskelly/cuek8s/pkg/acme"
)

// Cluster resolves a cluster name based on the given environment and region.
//
// Example:
// ```
// prodTokyo: #Cluster["production"]["tokyo"]
// ```
Cluster: ({
	(acme.#Dev): {
		(acme.#London): acme.#DevLondon01
		(acme.#Tokyo):  acme.#DevTokyo01
	}

	(acme.#Development): {
		(acme.#London): acme.#DevLondon01
		(acme.#Tokyo):  acme.#DevTokyo01
	}

	(acme.#Prod): {
		(acme.#London): acme.#ProdLondon01
		(acme.#Tokyo):  acme.#ProdTokyo01
	}

	(acme.#Production): {
		(acme.#London): acme.#ProdLondon01
		(acme.#Tokyo):  acme.#ProdTokyo01
	}
})

// Country resolves a country code based on the given country or region.
//
// Example:
// ```
// jp: #Country["tokyo"]
// ```
Country: ({
	(acme.#JP):    (acme.#JP)
	(acme.#Tokyo): (acme.#JP)

	(acme.#UK):     (acme.#UK)
	(acme.#London): (acme.#UK)
})

// FromCluster resolves information based on the given cluster name.
//
// Example:
// ```
// env: (#FromCluster & {cluster: "dev-tokyo-01"}).environment
// ```
#FromCluster: {
	// Cluster name from which information should be resolved.
	cluster: acme.#Cluster

	// Environment in which the cluster belongs.
	environment: LongEnvironment[_t[2]]

	// GCP Region in which the cluster is located.
	gcpRegion: #GCPRegion[_t[3]]

	// Region in which the cluster is located.
	region: _t[3]

	_t: strings.Split(cluster, "-")
}

// FromNamespace resolves information based on the given Kubernetes namespace.
//
// Example:
// ```
// serviceID: (#FromNamespace & {namespace: "acme-echo-jp-prod"}).service
// ```
#FromNamespace: {
	// Kubernetes namespace from which information should be resolved.
	namespace: acme.#Namespace

	// Environment in which the namespace corresponds.
	environment: LongEnvironment[_t[len(_t)-1]]

	// Service ID in which the namespace corresponds.
	serviceID: strings.Join(_t[:len(_t)-1], "-")

	_t: strings.Split(namespace, "-")
}

// GCPRegion resolves a GCP region from the name of the city in which it is
// physically present.
//
// Example:
// ```
// tokyo: #GCPRegion["tokyo"]
// ```
#GCPRegion: {
	london: acme.#EuropeWest2
	tokyo:  acme.#AsiaNortheast1
}

// KubeContext resolves a Kubernetes configuration context name from the given
// environment and region.
//
// Example:
// ```
// ctx: #KubeContext["development"]["tokyo"]
// ```
#KubeContext: {
	(acme.#Dev): {
		(acme.#London): "k3d-dev-london-01"
		(acme.#Tokyo):  "k3d-dev-tokyo-01"
	}

	(acme.#Development): {
		(acme.#London): "k3d-dev-london-01"
		(acme.#Tokyo):  "k3d-dev-tokyo-01"
	}

	(acme.#Prod): {
		(acme.#London): "k3d-prod-london-01"
		(acme.#Tokyo):  "k3d-prod-tokyo-01"
	}

	(acme.#Production): {
		(acme.#London): "k3d-prod-london-01"
		(acme.#Tokyo):  "k3d-prod-tokyo-01"
	}
}

// LongEnvironment resolves a long-form environment name from a short-form name.
//
// Example:
// ```
// env: #LongEnvironment["prod"]
// ```
LongEnvironment: ({
	(acme.#Dev):         acme.#Development
	(acme.#Development): acme.#Development

	(acme.#Prod):       acme.#Production
	(acme.#Production): acme.#Production
})

// Namespace resolves a Kubernetes namespace from the given environment and
// service ID.
//
// Example:
// ```
// ns: (#Namespace & {environment: "development", serviceID: "acme-echo-jp"}).namespace
// ```
Namespace: ({
	// Environment from which the namespace should be resolved.
	environment: acme.#Environment | acme.#Env

	// Service ID from which the namespace should be resolved.
	serviceID: acme.#Name

	// Kubernetes namespace in which the environment and service corresponds.
	namespace: acme.#Namespace & "\(serviceID)-\(ShortEnvironment[environment])"
})

// ShortEnvironment resolves a short-form environment name from a long-form
// name.
//
// Example:
// ```
// env: #ShortEnvironment["development"]
// ```
ShortEnvironment: ({
	(acme.#Dev):         acme.#Dev
	(acme.#Development): acme.#Dev

	(acme.#Prod):       acme.#Prod
	(acme.#Production): acme.#Prod
})
