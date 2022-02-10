package dump

import (
	"embed"
	"fmt"
	"io"
	"io/fs"
	"os"

	"cuelang.org/go/cue"
	"cuelang.org/go/cue/cuecontext"
	"github.com/spf13/cobra"

	"github.com/slewiskelly/cuek8s/internal/cuetil"
	"github.com/slewiskelly/cuek8s/internal/loader"
)

func New() *cobra.Command {
	opts := new(options)

	cmd := &cobra.Command{
		Use:   "dump [FLAGS] INPUT...",
		Short: "Displays generated Kubernetes manifest configuration",
		Long: `Displays generated Kubernetes manifest configuration

Input(s) are the same as those of the ` + "`cue`" + ` tool. See ` + "`cue inputs`" + ` for more information.

If specified, -d or --deliverables will filter resources for the specific deliverable(s).

If specified, -k or --kind will filter resources by their kind.

If specified, -n or --name will filter resources by their name.

Specifying both will filter resources by both kind and name.
`,
		RunE: func(cmd *cobra.Command, args []string) error {
			return run(args, opts)
		},
	}

	cmd.Flags().StringSliceVarP(&opts.Deliverables, "deliverables", "d", nil, "Deliverable(s) to apply")
	cmd.Flags().StringVarP(&opts.Format, "out", "o", "yaml", "output format (json|yaml)")
	cmd.Flags().StringSliceVarP(&opts.Kinds, "kind", "k", nil, "Kubernetes resource kind(s) to list")
	cmd.Flags().StringSliceVarP(&opts.Names, "name", "n", nil, "Kubernetes resource names(s) to list")

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

	cueDump, err := fs.ReadFile(FS, "dump.cue")
	if err != nil {
		return err
	}

	cd, err := cuetil.FillPaths(ctx.CompileBytes(cueDump), map[string]interface{}{
		"dump.inputs.deliverables": opts.Deliverables,
		"dump.inputs.format":       opts.Format,
		"dump.inputs.kinds":        opts.Kinds,
		"dump.inputs.names":        opts.Names,
		"dump.inputs.delivery":     v.LookupPath(cue.ParsePath("Delivery")),
	})
	if err != nil {
		return err
	}

	txt, err := cd.LookupPath(cue.ParsePath("dump.outputs.text")).String()
	if err != nil {
		return err
	}

	fmt.Fprintln(stdout, txt)

	return nil
}

type options struct {
	Deliverables []string
	Format       string `cue:"=~\"(json|yaml)\""`
	Kinds        []string
	Names        []string
}

var (
	//go:embed dump.cue
	FS embed.FS

	stdout io.Writer = os.Stdout
)
