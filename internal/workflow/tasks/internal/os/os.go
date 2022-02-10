// Package os provides a task runner resolver for operating system operations
// related tasks.
package os

import (
	"io/fs"
	stdos "os"

	"cuelang.org/go/cue"
	"cuelang.org/go/tools/flow"

	"github.com/slewiskelly/cuek8s/internal/workflow/tasks"
)

func init() {
	tasks.Register("os.Mkdir", mkdirTaskFunc)
	tasks.Register("os.ReadFile", readFileTaskFunc)
	tasks.Register("os.WriteFile", writeFileTaskFunc)
}

func mkdirTaskFunc(v cue.Value) (flow.RunnerFunc, error) {
	return flow.RunnerFunc(func(t *flow.Task) error {
		path, err := t.Value().LookupPath(cue.ParsePath("path")).String()
		if err != nil {
			return err
		}

		if err := stdos.MkdirAll(path, 0755); err != nil {
			return err
		}

		return nil
	}), nil
}

func readFileTaskFunc(v cue.Value) (flow.RunnerFunc, error) {
	return flow.RunnerFunc(func(t *flow.Task) error {
		name, err := t.Value().LookupPath(cue.ParsePath("name")).String()
		if err != nil {
			return err
		}

		b, err := stdos.ReadFile(name)
		if err != nil {
			return err
		}

		t.Fill(map[string]string{
			"contents": string(b),
		})

		return nil
	}), nil
}

func writeFileTaskFunc(v cue.Value) (flow.RunnerFunc, error) {
	return flow.RunnerFunc(func(t *flow.Task) error {
		name, err := t.Value().LookupPath(cue.ParsePath("name")).String()
		if err != nil {
			return err
		}

		data, err := t.Value().LookupPath(cue.ParsePath("data")).String()
		if err != nil {
			return err
		}

		perm, err := t.Value().LookupPath(cue.ParsePath("perm")).Int64()
		if err != nil {
			return err
		}

		return stdos.WriteFile(name, []byte(data), fs.FileMode(int32(perm)))
	}), nil
}
