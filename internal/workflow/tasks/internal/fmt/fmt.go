// Package fmt provides a task runner resolver for formatted I/O related tasks.
package fmt

import (
	stdfmt "fmt"

	"cuelang.org/go/cue"
	"cuelang.org/go/tools/flow"

	"github.com/slewiskelly/cuek8s/internal/workflow/tasks"
)

func init() {
	tasks.Register("fmt.Println", printlnTaskFunc)
}

func printlnTaskFunc(v cue.Value) (flow.RunnerFunc, error) {
	return flow.RunnerFunc(func(t *flow.Task) error {
		txt, err := t.Value().LookupPath(cue.ParsePath("text")).String()
		if err != nil {
			return err
		}

		stdfmt.Println(txt)

		return nil
	}), nil
}
