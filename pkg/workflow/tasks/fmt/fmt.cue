// Package fmt contains task definitions for performing formatted I/O
// operations.
package fmt

import (
	"github.com/slewiskelly/cuek8s/pkg/workflow/tasks"
)

// Println specifies a task which writes to standard output.
//
// It is the equivalent of Go's [fmt.Println](https://pkg.go.dev/fmt#Println).
#Println: tasks.#Task & {
	$id: "fmt.Println"

	// Text to be written.
	text: string @input()
}
