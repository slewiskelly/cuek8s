// Package kubectl provides delivery methods and tasks to deploy Kubernetes
// resources via kubectl.
package kubectl

import (
	"encoding/yaml"
	"strings"

	"github.com/slewiskelly/cuek8s/pkg/delivery"
	"github.com/slewiskelly/cuek8s/pkg/k8s"
	"github.com/slewiskelly/cuek8s/pkg/workflow/tasks/exec"
)

// Delivery is a delivery method that deploys Kubernetes resources via
// `kubectl`.
//
// Resources delivered via this method will have the following label(s) applied:
// - `app.acme.in/managed-by=kubectl`
#Delivery: X=delivery.#Method & {
	// Use the provided context when deploying resources.
	//
	// If unset the current context of the environment is used.
	context: *null | string & !="" @input()

	// Prune resources that have the folowing label(s) applied:
	// - `app.acme.in/managed-by=kubectl`
	prune: bool | *false @input()

	apply: {
		apply: #Apply & {
			context:   X.context
			dryRun:    false
			prune:     X.prune
			resources: X._resources
		}
	}

	plan: {
		apply: #Apply & {
			context:   X.context
			dryRun:    true
			prune:     X.prune
			resources: X._resources
		}
	}

	_resources: [ for r in X.resources {r & {metadata: labels: "app.acme.in/managed-by": "kubectl"}}]
}

// Apply is a task which executes `kubectl apply`.
#Apply: X=exec.#Run & {
	// Use the provided context when deploying resources.
	//
	// If unset the current context of the environment is used.
	context: *null | string & !="" @input()

	// Perform a client-side dry-run.
	dryRun: bool | *true @input()

	// Prune resources that have the following label selector(s):
	// - app.acme.in/managed-by=kubectl
	prune: bool | *false @input()

	// Kubernetes resources that are to be deployed.
	resources: [...k8s.#Resource] @input()

	_flags: [
		if X.context != null {
			"--context=\(X.context)"
		},

		if X.dryRun {
			"--dry-run=client"
		},

		for x in [
			"--prune=true",
			"--selector=app.acme.in/managed-by=kubectl",
		] if X.prune {x},
	]

	if len(X.resources) > 0 {
		name: "kubectl"
		arg: ["apply", "\(strings.Join(_flags, " "))", "-f", "-"]
	}

	if len(X.resources) < 1 {
		name: "echo"
		arg: ["No resources to apply!"]
	}

	stdin: yaml.MarshalStream(X.resources)
}
