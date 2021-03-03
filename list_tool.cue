package kube

import (
	"text/tabwriter"
	"tool/cli"
)

command: list: task: print: cli.Print & {
	text: tabwriter.Write(["Namespace  \tName  \tKind"] + [
		for x in allObjects {
			"\(x.metadata.namespace)  \t\(x.metadata.name)  \t\(x.kind)"
		},
	])
}
