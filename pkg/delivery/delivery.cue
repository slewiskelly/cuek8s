// Package delivery contains definitions related to the delivery of Kubernetes
// resources.
package delivery

import (
	"github.com/slewiskelly/cuek8s/pkg/k8s"
)

// Method is a method of delivery.
#Method: {
	// Set of tasks which will actually deliver the resources.
	//
	// Tasks are executed in the same order as they are defined.
	apply: [...#Task] @input()

	// Set of tasks which will plan how the resources will be delivered,
	// without actually delivering them.
	//
	// Tasks are executed in the same order as they are defined.
	plan: [...#Task] @input()

	// Resources to be delivered.
	resources: [...k8s.#Resource] @input()

	...
}

// Task is a single step which composes an entire delivery method.
#Task: {
	...
}
