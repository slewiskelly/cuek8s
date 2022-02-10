// Package os contains task definitions for performing operations via the
// operating system.
package os

import (
	"github.com/slewiskelly/cuek8s/pkg/workflow/tasks"
)

// Mkdir specifies a task which creates a directory in the filesystem.
//
// It is the equivalent of Go's [os.MkdirAll](https://pkg.go.dev/os#MkdirAll).
#Mkdir: tasks.#Task & {
	$id: "os.Mkdir"

	// Directory path to be created. All parent paths will be created if they
	// do not yet exist.
	path: string @input()
}

// ReadFile specifies a task which reads a file from the filesystem.
//
// Is is the equivalent of Go's [os.ReadFile](https://pkg.go.dev/os#ReadFile).
#ReadFile: tasks.#Task & {
	$id: "os.ReadFile"

	// Name of the file to create.
	name: string @input()

	// Contents of the file.
	contents: string @output()
}

// WriteFile specifies a task which writes a file to the filesystem.
//
// Is is the equivalent of Go's [os.WriteFile](https://pkg.go.dev/os#WriteFile).
#WriteFile: tasks.#Task & {
	$id: "os.WriteFile"

	// Name of the file to create.
	name: string @input()

	// Data to be written to the file.
	data: string @input()

	// Permission bits of the file.
	perm: uint32 | *0o666 @input()
}
