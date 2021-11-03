// Package stdout provides a delivery method which displays resources to the
// terminal's standard output.
package stdout

import (
	"encoding/yaml"
	"tool/cli"

	"github.com/slewiskelly/cuek8s/pkg/k8s"
	"github.com/slewiskelly/cuek8s/pkg/delivery"
)

// Delivery is a method of delivery which displays resources to the
// terminal's standard output.
#Delivery: X=delivery.#Method & {
	apply: [#Print & {resources: X.resources}]

	plan: [#Print & {resources: X.resources}]
}

// Print is a task which displays resources to the terminal's standard output.
#Print: X=cli.Print & {
	// Resources to be displayed.
	resources: [...k8s.#Resource] @input()

	text: yaml.MarshalStream(X.resources)

	...
}
