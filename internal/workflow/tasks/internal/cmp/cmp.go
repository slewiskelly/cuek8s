// Package cmp provides a task runner resolver for comparison related tasks.
package cmp

import (
	"cuelang.org/go/cue"
	"cuelang.org/go/tools/flow"
	"github.com/kylelemons/godebug/diff"

	"github.com/slewiskelly/cuek8s/internal/workflow/tasks"
)

func init() {
	tasks.Register("cmp.Diff", diffTaskFunc)
}

func diffTaskFunc(v cue.Value) (flow.RunnerFunc, error) {
	return flow.RunnerFunc(func(t *flow.Task) error {
		x, err := t.Value().LookupPath(cue.ParsePath("x")).String()
		if err != nil {
			return err
		}

		y, err := t.Value().LookupPath(cue.ParsePath("y")).String()
		if err != nil {
			return err
		}

		t.Fill(map[string]string{
			"diff": diff.Diff(x, y),
		})

		return nil
	}), nil
}
