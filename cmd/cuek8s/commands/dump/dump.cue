import (
	"encoding/json"
	"encoding/yaml"
	"list"
	"strings"
)

dump: {
	inputs: {
		format: "json" | *"yaml"
		kinds: [...string]
		names: [...string]
		resources: [...{...}]
	}

	outputs: text: string

	if inputs.format == "json" {
		outputs: text: json.MarshalStream(_resources)
	}

	if inputs.format == "yaml" {
		outputs: text: yaml.MarshalStream(_resources)
	}

	_resources: [
		for r in inputs.resources if (len(inputs.kinds) < 1 || list.Contains(inputs.kinds, r.kind)) && (len(inputs.names) < 1 || list.Contains(inputs.names, r.metadata.name)) {r},
	]
}
