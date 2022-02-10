// Package stdout provides a delivery method which displays resources to the
// terminal's standard output.
package stdout

import (
	"encoding/yaml"

	"github.com/slewiskelly/cuek8s/pkg/delivery"
	"github.com/slewiskelly/cuek8s/pkg/workflow/tasks/fmt"
)

// Delivery is a method of delivery which simply outputs resources to the
// terminal's standard output.
#Delivery: X=delivery.#Method & {
	apply: {
		print: fmt.#Println & {
			text: yaml.MarshalStream(X.resources)
		}
	}

	plan: {
		print: fmt.#Println & {
			text: yaml.MarshalStream(X.resources)
		}
	}
}
