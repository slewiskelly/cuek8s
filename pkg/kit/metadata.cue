package kit

import (
	"github.com/slewiskelly/cuek8s/pkg/acme"
	"github.com/slewiskelly/cuek8s/pkg/acme/resolve"

	meta_v1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

// Metadata specifies resource metadata.
#Metadata: X={
	// Annotations associated with the resource.
	annotations: {[string]: string} @input()

	// Environment in which the resource belongs.
	environment: acme.#Environment @input()

	// Labels associated with the resource.
	//
	// All resources are labeled with the following and cannot be changed:
	// - app
	// - app.acme.in/name
	// - app.acme.in/part-of
	// - topology.acme.in/environment
	// - topology.acme.in/region
	labels: {[string]: string} @input()

	// Name of the resource.
	name: acme.#Name | *X.serviceID @input()

	// Region in which the resource belongs.
	region: acme.#Region @input()

	// ID of the service in which the resource belongs.
	serviceID: acme.#Name @input()

	// Generated Kubernetes metadata
	metadata: meta_v1.#ObjectMeta

	labels: {
		"app":                          X.name
		"app.acme.in/name":             X.name
		"app.acme.in/part-of":          X.serviceID
		"app.acme.in/version":          "main"
		"topology.acme.in/environment": X.environment
		"topology.acme.in/region":      X.region
		"version":                      "main"
	}

	metadata: {
		annotations: X.annotations
		clusterName: resolve.Cluster[X.environment][X.region]
		name:        X.name
		namespace:   (resolve.Namespace & {environment: X.environment, serviceID: X.serviceID}).namespace
		labels:      X.labels
	}
}

_reservedLabels: [
	"app",
	"app.acme.in/name",
	"app.acme.in/part-of",
	"topology.acme.in/environment",
	"topology.acme.in/region",
	"version",
]
