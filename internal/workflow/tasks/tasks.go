package tasks

import (
	"fmt"
	"sync"

	"cuelang.org/go/cue"
	"cuelang.org/go/tools/flow"
)

// Func resolves and returns the appropriate task runner according to the task
// specified by the given value.
func Func(v cue.Value) (flow.Runner, error) {
	id := v.LookupPath(cue.ParsePath("$id"))
	if !id.Exists() {
		return nil, nil // Value is not a workflow task.
	}

	s, err := id.String()
	if err != nil {
		return nil, err
	}

	fn, ok := funcs.Load(s)
	if !ok {
		return nil, fmt.Errorf("unknown task (%s)", id)
	}

	return fn.(TaskFunc)(v)
}

// Register registers a task with the given ID.
//
// If a task has already been registered with the same ID, the function will
// panic.
func Register(id string, fn TaskFunc) {
	if _, ok := funcs.LoadOrStore(id, fn); ok {
		panic(fmt.Sprintf("task func already registered (%s)", id))
	}
}

// TaskFunc creates a RunnerFunc for the given value, should it define a task.
type TaskFunc func(cue.Value) (flow.RunnerFunc, error)

var funcs sync.Map
