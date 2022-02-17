package kubernetes

import (
	"github.com/slewiskelly/cuek8s/pkg/delivery/kubectl"
	"github.com/slewiskelly/cuek8s/pkg/kit"
)

Metadata: kit.#Metadata & {
	serviceID: "reviews"
}

App: Reviews: kit.#Application & {
	metadata: Metadata

	spec: {
		env: LOG_DIR: "/tmp/logs"

		volume: {
			tmp: {
				mountPath: "/tmp"
				readOnly:  false
			}
			"wlp-output": {
				mountPath: "/opt/ibm/wlp/output"
				readOnly:  false
			}
		}
	}

	patch: {
		deployment: spec: template: spec: securityContext: runAsGroup: null
	}
}

Delivery: {
	reviews: kubectl.#Delivery & {
		resources: App.Reviews.resources
	}
}
