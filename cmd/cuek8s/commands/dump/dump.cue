import (
	"encoding/json"
	"encoding/yaml"
	"list"
	"strings"
)

dump: {
	inputs: {
		deliverables: [...string]
		format: "json" | *"yaml"
		kinds: [...string]
		names: [...string]
		delivery: _
	}

	outputs: text: string

	if inputs.format == "json" {
		outputs: text: json.Marshal(_resources)
	}

	if inputs.format == "yaml" {
		outputs: text: yaml.MarshalStream(_resources)
	}

	_resources: [
		for n, d in inputs.delivery if len(inputs.deliverables) < 1 || list.Contains(inputs.deliverables, n) for r in d.resources if (len(inputs.kinds) < 1 || list.Contains(inputs.kinds, r.kind)) && (len(inputs.names) < 1 || list.Contains(inputs.names, r.metadata.name)) {r},
	]
}
