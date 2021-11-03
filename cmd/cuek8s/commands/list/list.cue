import (
	"encoding/json"
	"encoding/yaml"
	"list"
	"strings"
	"text/tabwriter"
)

ls: {
	inputs: {
		format: "json" | *"table"
		kinds: [...string]
		names: [...string]
		delivery: _
	}

	outputs: text: string

	if inputs.format == "json" {
		outputs: text: json.Marshal([ for r in _resources {
			name:       r.metadata.name, namespace: r.metadata.namespace
			apiVersion: r.apiVersion, kind:         r.kind
		}])
	}

	if inputs.format == "table" {
		outputs: text: tabwriter.Write(["Name\tCluster\tNamespace\tKind"] + [
				for r in _resources {"\(r.metadata.name)\t\(r.metadata.clusterName)\t\(r.metadata.namespace)\t\(r.kind)"},
		])
	}

	_resources: [
		for d in inputs.delivery for r in d.resources if (len(inputs.kinds) < 1 || list.Contains(inputs.kinds, r.kind)) && (len(inputs.names) < 1 || list.Contains(inputs.names, r.metadata.name)) {r},
	]
}
