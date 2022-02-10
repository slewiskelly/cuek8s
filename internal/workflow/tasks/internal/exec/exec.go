// Package exec provides a task runner resolver for command execution related
// tasks.
package exec

import (
	"errors"
	"fmt"
	"io"
	"os"
	"os/exec"
	stdexec "os/exec"

	"cuelang.org/go/cue"
	"cuelang.org/go/tools/flow"

	"github.com/slewiskelly/cuek8s/internal/workflow/tasks"
)

func init() {
	tasks.Register("exec.Run", runTaskFunc)
}

func runTaskFunc(v cue.Value) (flow.RunnerFunc, error) {
	return flow.RunnerFunc(func(t *flow.Task) error {
		var arg []string

		if err := t.Value().LookupPath(cue.ParsePath("arg")).Decode(&arg); err != nil {
			return err
		}

		env := make(map[string]string)

		if err := t.Value().LookupPath(cue.ParsePath("env")).Decode(&env); err != nil {
			return err
		}

		name, err := t.Value().LookupPath(cue.ParsePath("name")).String()
		if err != nil {
			return err
		}

		var stdin io.Reader

		if s := t.Value().LookupPath(cue.ParsePath("stdin")); s.Exists() && s.Null() != nil {
			if stdin, err = s.Reader(); err != nil {
				return err
			}
		}
		m := make(map[string]interface{})

		cmd := stdexec.Command(name, arg...)

		if len(env) > 0 {
			cmd.Env = append(os.Environ(), toSlice(env)...)
		}

		cmd.Stdin = stdin

		var exitCode int

		out, err := cmd.Output()
		if err != nil {
			exitCode = -1

			if ee := new(exec.ExitError); errors.As(err, &ee) {
				exitCode = ee.ExitCode()

				if k := t.Value().LookupPath(cue.ParsePath("stderr")).IncompleteKind(); k == cue.StringKind {
					m["stderr"] = string(out)
				} else {
					fmt.Fprintln(stderr, string(out))
				}
			}
		}

		m["exitCode"] = exitCode

		if k := t.Value().LookupPath(cue.ParsePath("stdout")).IncompleteKind(); k == cue.StringKind {
			m["stdout"] = string(out)
		} else {
			fmt.Fprintln(stdout, string(out))
		}

		return t.Fill(m)
	}), nil
}

func toSlice(m map[string]string) []string {
	var s []string

	for k, v := range m {
		s = append(s, fmt.Sprintf("%s=%s", k, v))
	}

	return s
}

var (
	stdout io.Writer = os.Stdout
	stderr io.Writer = os.Stderr
)
