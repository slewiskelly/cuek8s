package kubernetes

import (
	"github.com/slewiskelly/cuek8s/pkg/delivery/stdout"
	"github.com/slewiskelly/cuek8s/pkg/kit"
)

Metadata: kit.#Metadata & {
	serviceID: "details"
}

App: kit.#Application & {
	metadata: Metadata

	spec: env: DO_NOT_ENCRYPT: "true"
}

Delivery: {
	details: stdout.#Delivery & {
		resources: App.resources
	}
}
