package kit

import (
	"strings"

	"github.com/slewiskelly/cuek8s/pkg/k8s"

	"k8s.io/apimachinery/pkg/api/resource"
)

// ScalingHorizontal specifies that an application should scale horizontally,
// and the number of repliacs should increase based on CPU utilization.
//
// Example:
// ```cue
// App: kit.#Application & {
//     metadata: {
//         serviceID: "acme-echo-jp"
//         name:      "echo"
//     }
//
//     spec: {
//         scaling: horizontal: {
//             maxReplicas: 4
//             metrics: [{
//                 resource: name: "cpu"
//                 utilization: 70
//             }]
//         }
//     }
// }
// ```
#ScalingHorizontal: {
	_type: "horizontal"

	horizontal: {
		// Minimum number of replicas of the application.
		//
		// This must always be greater than one, and less than or equal to, the
		// maximum number of replicas.
		minReplicas: int | *2 @input()

		// Maximum number of replicas of the application.
		//
		// This must always be greater than, or equal to, the minimum number of
		// replicas.
		maxReplicas: int | *3 @input()

		// Metrics containing the specifications for which to use to calculate
		// the desired replica count.
		//
		// Defaults to scale when replicas are above 80% CPU utilization.
		metrics: [...#ScalingHorizontalMetric] | *[{
			_type:       "resource"
			resource:    "cpu"
			utilization: 80
		}] @input()
	} @input()
}

// ScalingHorizontalMetric specifies that what metrics an application use for
// horizontal scaling.
#ScalingHorizontalMetric: {
	#ScalingHorizontalMetricSource
	#ScalingHorizontalMetricTarget
}

// ScalingHorizontalMetricSource specifies what metric source an application
// use for horizontal scaling.
#ScalingHorizontalMetricSource:
	#ScalingHorizontalMetricSourceResource |
	#ScalingHorizontalMetricSourceExternal

// ScalingHorizontalMetricSourceResource specifies that an application use a
// resource metric as a source for horizontal scaling.
#ScalingHorizontalMetricSourceResource: {
	_type: "resource"

	// Type of resource.
	resource: "cpu" | "memory" @input()
}

// ScalingHorizontalMetricSourceExternal specifies that an application use an
// external metric as a source for horizontal scaling.
#ScalingHorizontalMetricSourceExternal: {
	_type: "external"

	external: {
		// Metric of the external source.
		metric: string @input()

		// Additional parameter to the metrics server for more specific metrics
		// scoping.
		selector: {
			[string]: string @input()
		}
	} @input()
}

// ScalingHorizontalMetricTarget specifies what metric target an application
// use for horizontal scaling.
#ScalingHorizontalMetricTarget:
	#ScalingHorizontalMetricTargetUtilization |
	#ScalingHorizontalMetricTargetValue |
	#ScalingHorizontalMetricTargetAverageValue

// ScalingHorizontalMetricTargetUtilization specifies that an application use
// a utilization as a target of horizontal scaling.
#ScalingHorizontalMetricTargetUtilization: {
	// Target percentage utilization before additional replicas are created.
	// Defaults to 80.
	utilization: int & >0 & <100 | *80 @input()
}

// ScalingHorizontalMetricTargetValue specifies that an application use a value
// as a target of horizontal scaling.
#ScalingHorizontalMetricTargetValue: {
	// Target value before additional replicas are created.
	value: resource.#Quantity @input()
}

// ScalingHorizontalMetricTargetAverageValue specifies that an application use
// an average value as a target of horizontal scaling.
#ScalingHorizontalMetricTargetAverageValue: {
	// Target average value before additional replicas are created.
	averageValue: resource.#Quantity @input()
}

// ScalingStatic specifies that an application should not scale, and the number
// of replicas is static.
#ScalingStatic: {
	_type: "static"

	static: {
		// Number of replicas of the application.
		// Defaults to 2.
		replicas: int | *2 @input()
	} @input()
}

// ScalingType specifies how an application should scale.
#ScalingType:
	*#ScalingHorizontal |
	#ScalingStatic

_#HorizontalPodAutoscaler: k8s.#HorizontalPodAutoscaler & {
	_X: {...}

	metadata: _X.metadata.metadata

	spec: {
		minReplicas: _X.spec.scaling.horizontal.minReplicas
		maxReplicas: _X.spec.scaling.horizontal.maxReplicas

		metrics: [
			for v in _X.spec.scaling.horizontal.metrics {
				{type: strings.ToTitle(v._type)}

				if v.resource != _|_ {
					{resource: name: v.resource}
				}
				if v.external != _|_ {
					{external: metric: {
						name: v.external.metric
						selector: matchLabels: v.external.selector
					}}
				}

				if v.utilization != _|_ {
					{
						"\(v._type)": target: {
							type:               "Utilization"
							averageUtilization: v.utilization
						}
					}
				}
				if v.value != _|_ {
					{
						"\(v._type)": target: {
							type:  "Value"
							value: v.value
						}
					}
				}
				if v.averageValue != _|_ {
					{
						"\(v._type)": target: {
							type:         "AverageValue"
							averageValue: v.averageValue
						}
					}
				}
			},
		]

		scaleTargetRef: {
			apiVersion: string | *"apps/v1"
			kind:       string | *"Deployment"
			name:       _X.metadata.name
		}

	}
}
