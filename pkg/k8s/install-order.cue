package k8s

import "list"

// InstallOrder specifies a list of Kubernetes resources ordered in the order
// in which they should be applied.
#InstallOrder: [
	"PodSecurityPolicy",
	"CustomResourceDefinition",
	"ResourceQuota",
	"LimitRange",
	"Secret",
	"ConfigMap",
	"PersistentVolume",
	"PersistentVolumeClaim",
	"ServiceAccount",
	"ClusterRole",
	"ClusterRoleBinding",
	"Role",
	"RoleBinding",
	"Service",
	"DaemonSet",
	"Pod",
	"ReplicaSet",
	"Deployment",
	"StatefulSet",
	"Job",
	"CronJob",
	"Certificate",
	"Ingress",
	"BackendConfig",
	"DatadogMetric",
	"HorizontalPodAutoscaler",
	"NetworkPolicy",
	"PodDisruptionBudget",

	// kritis.grafeas.io/v1beta1
	"AttestationAuthority",
	"ImageSecurityPolicy",

	// OPA Gatekeeper
	"Config",
	"ConstraintTemplate",

	//Istio CRDs networking.istio.io/v1beta1
	"DestinationRule",
	"VirtualService",

	// Other kinds will be appended here and therefore installed last in an undefined order
	"Elasticsearch",
]

// Sort sorts the given list of Kubernetes resources according to
// `InstallOrder`.
//
// Example:
// ```cue
// sorted: (Sort & {l: resources}).sorted
// ```
#Sort: X=({
	// Resources to be sorted.
	r: [...#Resource] @input()

	// Order in which to sort the resources.
	order: *"install" | "uninstall" @input()

	// Sorted resources.
	sorted: [...#Resource]

	if X.order == "install" {
		sorted: _sorted
	}

	if X.order == "uninstall" {
		sorted: [ for i in list.Range(len(_sorted)-1, -1, -1) {_sorted[i]}]
	}

	_sorted: list.Sort(X.r, {x: #Resource, y: #Resource, less: _#InstallOrderMap[x.kind] < _#InstallOrderMap[y.kind]})
})

// SortStrings sorts the given list of Kubernetes resource kinds according to
// `InstallOrder`.
//
// Example:
// ```cue
// sorted: (Sort & {l: resources}).sorted
// ```
#SortStrings: X=({
	// Resource kinds to be sorted.
	r: [...string] @input()

	// Order in which to sort the resources.
	order: *"install" | "uninstall" @input()

	// Sorted resources.
	sorted: [...string]

	if X.order == "install" {
		sorted: _sorted
	}

	if X.order == "uninstall" {
		sorted: [ for i in list.Range(len(_sorted)-1, -1, -1) {_sorted[i]}]
	}

	_sorted: list.Sort(X.r, {x: string, y: string, less: _#InstallOrderMap[x] < _#InstallOrderMap[y]})
})

_#InstallOrderMap: ({for i, k in #InstallOrder {"\(k)": i}})
