package plan

import (
	"context"
	"fmt"
	"io"
	"os"

	"cuelang.org/go/cue"
	"cuelang.org/go/cue/cuecontext"
	"cuelang.org/go/tools/flow"
	"github.com/spf13/cobra"

	"github.com/slewiskelly/cuek8s/internal/loader"
	"github.com/slewiskelly/cuek8s/internal/workflow/tasks"
	_ "github.com/slewiskelly/cuek8s/internal/workflow/tasks/registry" // Register tasks
)

func New() *cobra.Command {
	opts := new(options)

	cmd := &cobra.Command{
		Use:   "plan [FLAGS] INPUT...",
		Short: "Plans the deployment of Kubernetes resources.",
		Long: `Plans the deployment of Kubernetes resources.

Input(s) are the same as those of the ` + "`cue`" + ` tool. See ` + "`cue inputs`" + ` for more information.

If specified, -d or --deliverables will plan the deployment of resources for the specific deliverable(s).
`,
		RunE: func(cmd *cobra.Command, args []string) error {
			return run(args, opts)
		},
	}

	cmd.Flags().StringSliceVarP(&opts.Deliverables, "deliverables", "d", nil, "Deliverable(s) to plan")

	return cmd
}

func run(args []string, opts *options) error {
	l, err := loader.New()
	if err != nil {
		return err
	}

	inst, err := l.Load(args...)
	if err != nil {
		return err
	}

	if err := inst.Complete(); err != nil {
		return err
	}

	ctx := cuecontext.New()

	v := ctx.BuildInstance(inst)
	if err := inst.Err; err != nil {
		return err
	}

	if err := v.Validate(); err != nil {
		return err
	}

	d := v.LookupPath(cue.ParsePath("Delivery"))

	it, err := d.Fields(cue.Final(), cue.Concrete(true), cue.ResolveReferences(true))
	if err != nil {
		return err
	}

	for it.Next() {
		if len(opts.Deliverables) > 1 && !contains(opts.Deliverables, it.Selector().String()) {
			continue
		}

		err := flow.New(&flow.Config{Root: cue.ParsePath(fmt.Sprintf("Delivery.%s.plan", it.Selector().String()))}, v, tasks.Func).Run(context.Background())
		if err != nil {
			return err
		}
	}

	return nil
}

func contains(s []string, v string) bool {
	for _, t := range s {
		if t == v {
			return true
		}
	}

	return false
}

type options struct {
	Deliverables []string
}

var (
	stderr io.Writer = os.Stderr
	stdout io.Writer = os.Stdout
)
