package main

import (
	"strings"
	"tool/exec"
)

var: {
	environments: *"dev" | "prod" | "dev,prod" | "prod,dev"             @tag(environments,type=string)
	regions:      "london" | *"tokyo" | "london,tokyo" | "tokyo,london" @tag(regions,type=string)

	_environments: strings.Split(environments, ",")
	_regions:      strings.Split(regions, ",")

	_services: ["details", "productpage", "ratings", "reviews"]
}

// Command up brings up a local k3s environment.
command: up: {
	for environment in var._environments for region in var._regions {
		let _cluster = "\(environment)-\(region)"

		"\(_cluster)": {
			"Create cluster": exec.Run & {
				cmd: "k3d cluster create \(_cluster) --no-lb"
			}

			"Create namespaces": {
				for service in var._services {
					let _namespace = "\(service)-\(environment)"

					"\(_namespace)": exec.Run & {
						$after: command.up["\(_cluster)"]["Create cluster"]
						cmd:    "kubectl create namespace \(_namespace) --context=k3d-\(_cluster)"
					}
				}
			}
		}
	}
}

// Command down tears down the local k3s envrionment.
command: down: {
	for environment in var._environments for region in var._regions {
		let _cluster = "\(environment)-\(region)"

		"\(_cluster)": "Create cluster": exec.Run & {
			cmd: "k3d cluster delete \(_cluster)"
		}
	}
}
