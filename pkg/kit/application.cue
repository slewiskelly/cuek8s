package kit

import (
	"list"
	"math"

	"github.com/slewiskelly/cuek8s/pkg/k8s"
	"github.com/slewiskelly/cuek8s/pkg/acme"
)

// Application is an abstraction of multiple Kubernetes resources.
//
// Depending on the configuration of the application it may generate the
// following resources:
//  - Deployment
//  - DestinationRule (if a service mesh is enabled)
//  - HorizontalPodAutoscaler
//  - PodDisruptionBudget
//  - Service (if ports are exposed)
//  - VirtualService (if a service mesh is enabled)
//
// Example:
// ```cue
// App: kit.#Application & {
//     metadata: {
//         serviceID: "acme-echo-jp"
//         name:      "echo"
//     }
//
//     spec: image: name: "acme-echo-jp"
// }
// ```
#Application: X={
	#Base

	spec: {
		#PodSpec

		// Workload image configuration.
		image: #ImageSpec | *(#ImageSpec & {
			// Application's Docker registry name.
			//
			// Defaults to "gcr.io/$SERVICE_ID-prod/".
			registry: string | *"gcr.io/\(X.metadata.serviceID)-prod"

			// Application's Docker image name.
			//
			// Defaults to the name of the application.
			name: acme.#Name | *X.metadata.name
		}) @input()

		// Minimum number of replicas, as a percentage, that must be available.
		//
		// Replicas cannot be rescheduled until at least the number of repliacs
		// are available.
		minAvailable: string & =~"^([1-9]%$|^[1-9][0-9]%$|^100%)$" | *"50%" @input()

		// Scaling configuration.
		scaling: #ScalingType @input()

		// Update configuration.
		updates: #UpdateType @input()

		// Set standard HTTP port.
		expose: http: port: 9080
	}

	patch: {
		container:               _
		deployment:              _
		destinationRule:         _
		horizontalPodAutoscaler: _
		podDisruptionBudget:     _
		service:                 _
		verticalPodAutoscaler:   _
		virtualService:          _
	}

	// Service
	if len(X.spec.expose) > 0 {
		resource: "Service": (#Service & {
			metadata: X.metadata
			spec: {
				expose: X.spec.expose
				selector: {for k, v in X.metadata.labels if list.Contains(_reservedLabels, k) {"\(k)": v}}
			}
			patch: service: X.patch.service
		}).resource["Service"]
	}

	// Deployment
	resource: "Deployment": _Deployment & {_X: {
		spec: X.spec, metadata: X.metadata, patch: {
			if X.patch.deployment.spec.selector != _|_ {
				deployment: spec: selector: X.patch.deployment.spec.selector
			}
			container: X.patch.container
		}
	}} & X.patch.deployment

	// HorizontalPodAutoscaler
	if X.spec.scaling._type == "horizontal" {
		resource: "HorizontalPodAutoscaler": _HorizontalPodAutoscaler & {_X: {
			spec: X.spec, metadata: X.metadata
		}} & X.patch.horizontalPodAutoscaler
	}

	// PodDisruptionBudget
	if X.spec.scaling._type == "horizontal" {
		resource: "PodDisruptionBudget": _PodDisruptionBudget & {_X: {
			spec: X.spec, metadata: X.metadata
		}} & X.patch.podDisruptionBudget
	}

	if X.spec.scaling._type == "static" {
		if X.spec.scaling.static.replicas != 1 {
			resource: "PodDisruptionBudget": _PodDisruptionBudget & {_X: {
				spec: X.spec, metadata: X.metadata
			}} & X.patch.podDisruptionBudget
		}
	}

	if X.spec.scaling._type == "vertical" {
		if X.spec.scaling.vertical.replicas != 1 {
			resource: "PodDisruptionBudget": _PodDisruptionBudget & {_X: {
				spec: X.spec, metadata: X.metadata
			}} & X.patch.podDisruptionBudget
		}
	}

	// DestinationRule (Istio only)
	if X.spec.network.serviceMesh != null {
		resource: "DestinationRule": _DestinationRule & {_X: {
			spec: X.spec, metadata: X.metadata
		}} & X.patch.destinationRule
	}

	// VerticalPodAutoscaler
	if X.spec.scaling._type == "vertical" {
		resource: "VerticalPodAutoscaler": _VerticalPodAutoscaler & {_X: {
			spec: X.spec, metadata: X.metadata
		}} & X.patch.verticalPodAutoscaler
	}

	// VirtualService (Istio only)
	if X.spec.network.serviceMesh != null {
		resource: "VirtualService": _VirtualService & {_X: {
			spec: X.spec, metadata: X.metadata
		}} & X.patch.virtualService
	}
}

// ImageSpec is the full Docker image name with tag that is used in an Application
#ImageSpec: {
	// Application's Docker image name, excluding the image registry prefix.
	name: string

	// The image registry name.
	registry: string

	// The image tag
	tag: *null | string
}

_Deployment: k8s.#Deployment & {
	_X: _

	metadata: _X.metadata.metadata & {
		annotations: {
			"kubectl.kubernetes.io/default-container": _X.metadata.name
		}
	}

	spec: {
		if _X.spec.scaling._type == "static" {
			replicas: _X.spec.scaling.static.replicas
		}

		if _X.spec.scaling._type == "vertical" {
			replicas: _X.spec.scaling.vertical.replicas
		}

		if _X.spec.updates._type == "recreate" {
			strategy: type: "Recreate"
		}

		if _X.spec.updates._type == "rolling" {
			strategy: {
				rollingUpdate: {
					maxSurge:       _X.spec.updates.rolling.maxSurge
					maxUnavailable: _X.spec.updates.rolling.maxUnavailable
				}
				type: "RollingUpdate"
			}
		}

		selector: matchLabels: {
			for k, v in _X.metadata.labels if list.Contains([
					"app.acme.in/name",
					"app.acme.in/version",
			], k) {"\(k)": v}
		}

		template: {
			metadata: {
				annotations: {
					if _X.spec.network.serviceMesh != null {
						"sidecar.istio.io/inject":                          "true"
						"sidecar.istio.io/proxyCPU":                        "\(math.Ceil((_X.spec.resources.requests.cpu*1000)*0.5))m"
						"sidecar.istio.io/proxyCPULimit":                   "\(math.Ceil((_X.spec.resources.limits.cpu*1000)*0.75))m"
						"sidecar.istio.io/proxyMemory":                     "256Mi"
						"sidecar.istio.io/proxyMemoryLimit":                "512Mi"
						"traffic.sidecar.istio.io/excludeOutboundIPRanges": "169.254.169.254/32"
					}
				}
			}

			spec: {
				if _X.spec.tolerations.preemptible {
					tolerations: [{
						key:      "preemptible"
						value:    "true"
						operator: "Equal"
						effect:   "NoSchedule"
					}]
				}

				volumes: [ for v in _X.spec.volume {name: v.name, v.source}]
			}
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

_DestinationRule: k8s.#DestinationRule & {
	_X: _

	metadata: _X.metadata.metadata

	spec: {
		host:    string | *"\(_X.metadata.name).\(_X.metadata.metadata.namespace).svc.cluster.local"
		subsets: [...{}] | *[{
			labels: version: "main"
			name: "main"
		}, {
			labels: version: "baseline"
			name: "baseline"
		}, {
			labels: version: "canary"
			name: "canary"
		}]
	}

}

_PodDisruptionBudget: k8s.#PodDisruptionBudget & {
	_X: _

	metadata: _X.metadata.metadata

	spec: {
		minAvailable: _X.spec.minAvailable
		selector: matchLabels: _X.metadata.labels
	}
}

_VirtualService: k8s.#VirtualService & {
	_X: _

	metadata: _X.metadata.metadata

	spec: {
		hosts: ["\(_X.metadata.name).\(_X.metadata.metadata.namespace).svc.cluster.local"]
		http: [{
			route: [{
				destination: {
					host:   "\(_X.metadata.name).\(_X.metadata.metadata.namespace).svc.cluster.local"
					subset: "main"
				}
				weight: 100
			}, {
				destination: {
					host:   "\(_X.metadata.name).\(_X.metadata.metadata.namespace).svc.cluster.local"
					subset: "canary"
				}
				weight: 0
			}, {
				destination: {
					host:   "\(_X.metadata.name).\(_X.metadata.metadata.namespace).svc.cluster.local"
					subset: "baseline"
				}
				weight: 0
			}]
		}]
	}
}
