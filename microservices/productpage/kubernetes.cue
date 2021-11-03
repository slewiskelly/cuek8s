package kubernetes

import (
	"github.com/slewiskelly/cuek8s/pkg/delivery/kubectl"
	"github.com/slewiskelly/cuek8s/pkg/kit"
)

Metadata: kit.#Metadata & {
	serviceID: "productpage"
}

App: kit.#Application & {
	metadata: Metadata

	spec: {
		env: {
			DETAILS_HOSTNAME: "details.details-dev"
			RATINGS_HOSTNAME: "ratings.ratings-dev"
			REVIEWS_HOSTNAME: "reviews.reviews-dev"
		}

		volume: tmp: mountPath: "/tmp"
	}

	patch: service: spec: type: "NodePort"
}

Delivery: {
	productpage: kubectl.#Delivery & {
		resources: App.resources
	}
}
