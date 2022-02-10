// Package delivery contains definitions related to the delivery of Kubernetes
// resources.
package delivery

import (
	"github.com/slewiskelly/cuek8s/pkg/k8s"
	"github.com/slewiskelly/cuek8s/pkg/workflow/tasks"
)

// Method is a method of delivery.
#Method: {
	// Set of tasks which will actually deliver the resources.
	apply: #Tasks

	// Set of tasks which will plan how the resources will be delivered,
	// without actually delivering them.
	plan: #Tasks

	// Kubernetes resources to be delivered.
	resources: [...k8s.#Resource] @input()

	...
}

// Tasks is a set of tasks required to deliver the resources.
#Tasks: {[Name=string]: tasks.#Task}
