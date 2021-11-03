// Package kubectl provides delivery methods and tasks to deploy Kubernetes
// resources via kubectl.
package kubectl

import (
	"encoding/yaml"
	"strings"
	"tool/exec"

	"github.com/slewiskelly/cuek8s/pkg/k8s"
	"github.com/slewiskelly/cuek8s/pkg/delivery"
)

// Delivery is a delivery method that deploys Kubernetes resources via kubectl.
#Delivery: X=delivery.#Method & {
	// Use the provided context when deploying resources.
	//
	// If unset the current context of the environment is used.
	context: *null | string @input()

	// Prune resources.
	//
	// Resources will only be pruned if they have the following label(s):
	// - `app.acme.in/managed-by=kubectl`
	prune: bool | *false @input()

	apply: [#Apply & {
		if X.context != null {context: X.context}
		dryRun:    false
		prune:     X.prune
		resources: X._resources
	}]

	plan: [#Apply & {
		if X.context != null {context: X.context}
		dryRun:    true
		prune:     X.prune
		resources: X._resources
	}]

	_resources: [ for r in X.resources {r & {metadata: labels: "app.acme.in/managed-by": "kubectl"}}]
}

// Apply is task which executes `kubectl apply`.
#Apply: X=exec.Run & {
	// Use the provided context when deploying resources.
	//
	// If unset the current context of the environment is used.
	context: *null | string & !="" @input()

	// Perform a client-side dry-run.
	dryRun: bool | *true @input()

	// Prune resources.
	//
	// Resources will only be pruned if they have the following label(s):
	// - `app.acme.in/managed-by=kubectl`
	prune: bool | *false @input()

	// Kubernetes resources that are to be deployed.
	resources: [...k8s.#Resource] @input()

	_flags: [
		if X.context != null {
			"--context=\(context)"
		},

		if X.dryRun {
			"--dry-run=client"
		},

		for x in [
			// TODO(slewiskelly): Pruning does not work on custom resources
			// e.g. DestinationRules and VirtualServices.
			"--prune=true",
			// TODO(slewiskelly): Consider adding user defined selectors.
			"--selector=app.acme.in/managed-by=kubectl",
		] if X.prune {x},
	]

	if len(resources) > 0 {
		cmd: [
			"/bin/bash", "-c",
			"""
            kubectl apply \(strings.Join(_flags, " ")) -f -
            """,
		]
	}

	if len(resources) < 1 {
		cmd: ["echo", "No resources to apply!"]
	}

	stdin: yaml.MarshalStream(X.resources)

	...
}
