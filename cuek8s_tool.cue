package kubernetes

import (
	"encoding/json"
	"encoding/yaml"
	_list "list"
	"strings"
	"text/tabwriter"
	"tool/cli"

	"github.com/slewiskelly/cuek8s/pkg/acme"
)

command: apply: {
	var: {
		name: acme.#Name & !="" @tag(name,type=string)
	}

	for i, t in Delivery["\(var.name)"].apply {
		"\(i)": t & {if i > 0 {$after: apply["\(i-1)"]}}
	}
}

command: deliverables: cli.Print & {
	text: strings.Join([ for d, _ in Delivery {"\(d)"}], "\n")
}

command: dump: cli.Print & {
	var: {
		format: "json" | *"yaml" @tag(format,type=string)
		kind:   string | *""     @tag(kind,type=string)
		name:   string | *""     @tag(name,type=string)
	}

	_kinds: [ for k in strings.Split(var.kind, ",") {strings.ToLower(k)}]

	_resources: {
		for k, v in Delivery if var.name == "" || var.name == k {
			"\(k)": [ for r in v.resources if var.kind == "" || _list.Contains(_kinds, strings.ToLower(r.kind)) {r}]
		}
	}

	if var.format == "json" {
		text: json.MarshalStream([ for k, v in _resources for r in v {r}])
	}

	if var.format == "yaml" {
		text: yaml.MarshalStream([ for k, v in _resources for r in v {r}])
	}
}

command: {
	ls: list

	list: cli.Print & {
		var: {
			format: "json" | *"pretty" @tag(format,type=string)
			kind:   string | *""       @tag(kind,type=string)
			name:   string | *""       @tag(name,type=string)
		}

		_kinds: [ for k in strings.Split(var.kind, ",") {strings.ToLower(k)}]

		_resources: {
			for k, v in Delivery if var.name == "" || var.name == k {
				"\(k)": [ for r in v.resources if var.kind == "" || _list.Contains(_kinds, strings.ToLower(r.kind)) {r}]
			}
		}

		if var.format == "pretty" {
			text: tabwriter.Write(["Name  \tCluster  \tNamespace  \tKind"] + [
				for k, v in _resources for x in v {
					"\(x.metadata.name)  \t\(x.metadata.clusterName)  \t\(x.metadata.namespace)  \t\(x.kind)"
				},
			])
		}

		if var.format == "json" {
			text: json.Marshal([ for k, v in _resources for x in v {
				name:       x.metadata.name, namespace: x.metadata.namespace
				apiVersion: x.apiVersion, kind:         x.kind
			}])
		}
	}
}

command: plan: {
	var: {
		name: acme.#Name & !="" @tag(name,type=string)
	}

	for i, t in Delivery["\(var.name)"].plan {
		"\(i)": t & {if i > 0 {$after: plan["\(i-1)"]}}
	}
}
