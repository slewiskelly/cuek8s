package kube

import (
	"encoding/yaml"
	"tool/cli"
)

command: dump: {

	var: {
		objects: *"all" | "managed" | "unmanaged" @tag(objects)
	}

	task: print: cli.Print & {
		if var.objects == "all" {
			text: yaml.MarshalStream(allObjects)
		}
		if var.objects == "managed" {
			text: yaml.MarshalStream(managedObjects)
		}
		if var.objects == "unmanaged" {
			text: yaml.MarshalStream(unmanagedObjects)
		}
	}
}
