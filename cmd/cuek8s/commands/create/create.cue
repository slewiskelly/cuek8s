import (
	"path"

	// TODO(slewiskelly): It seems like imports cannot be resolved when using
	// ctx.CompileBytes or ctx.CompileString.
	//
	// "github.com/slewiskelly/cuek8s/pkg/acme"
	// "github.com/slewiskelly/cuek8s/pkg/acme/topology"
)

dirs: {
	inputs: {
		// TODO(slewiskelly): Use constraints once able to use imports.
		serviceID: string      // acme.#Name
		country:   "jp" | "uk" // acme.#Country
	}

	outputs: dirs: [...string]

	outputs: dirs: [
		for region in _ACME[inputs.country] for environment, x in region for cluster, _ in x {path.Join([inputs.serviceID, environment, cluster])},
	]
}

// TODO(slewiskelly): Remove once able to use imports.
_ACME: ({
	("jp"): {
		("tokyo"): {
			("development"): {
				("dev-tokyo-01"): {}
			}
			("production"): {
				("prod-tokyo-01"): {}
			}
		}
	}

	("uk"): {
		("london"): {
			("development"): {
				("dev-london-01"): {}
			}
			("production"): {
				("prod-london-01"): {}
			}
		}
	}
})
