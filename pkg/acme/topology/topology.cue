package topology

import (
	"github.com/slewiskelly/cuek8s/pkg/acme"
)

ACME: ({
	(acme.#JP): {
		(acme.#Tokyo): {
			(acme.#Development): {
				(acme.#DevTokyo01): {}
			}
			(acme.#Production): {
				(acme.#ProdTokyo01): {}
			}
		}
	}

	(acme.#UK): {
		(acme.#London): {
			(acme.#Development): {
				(acme.#DevLondon01): {}
			}
			(acme.#Production): {
				(acme.#ProdLondon01): {}
			}
		}
	}
})

GCP: ({
	(acme.#JP): {
		(acme.#AsiaNortheast1): {
			(acme.#AsiaNortheast1a): {}
			(acme.#AsiaNortheast1b): {}
			(acme.#AsiaNortheast1c): {}
		}
	}

	(acme.#UK): {
		(acme.#EuropeWest2): {
			(acme.#EuropeWest2a): {}
			(acme.#EuropeWest2b): {}
			(acme.#EuropeWest2c): {}
		}
	}
})
