package dump

import (
	"embed"
	"fmt"
	"io"
	"io/fs"
	"os"
	"time"

	"cuelang.org/go/cue"
	"cuelang.org/go/cue/cuecontext"
	"github.com/spf13/cobra"

	"github.com/slewiskelly/cuek8s/internal/cuetil"
	"github.com/slewiskelly/cuek8s/internal/loader"
)

func New() *cobra.Command {
	opts := new(options)

	cmd := &cobra.Command{
		Use:   "dump [-o FORMAT] INPUT...",
		Short: "Displays generated Kubernetes manifest configuration",
		Long: `Displays generated Kubernetes manifest configuration

Input(s) are the same as those of the ` + "`cue`" + ` tool. See ` + "`cue inputs`" + ` for more information.

If specified, -k or --kind will filter resources by their kind.

If specified, -n or --name will filter resources by their name.

Specifying both will filter resources by both kind and name.
`,
		RunE: func(cmd *cobra.Command, args []string) error {
			return run(args, opts)
		},
	}

	cmd.Flags().BoolVar(&opts.Debug, "debug", false, "display debug information")
	cmd.Flags().StringVarP(&opts.Format, "out", "o", "yaml", "output format (json|yaml)")
	cmd.Flags().StringSliceVarP(&opts.Kinds, "kind", "k", nil, "Kubernetes resource kind(s) to list")
	cmd.Flags().StringSliceVarP(&opts.Names, "name", "n", nil, "Kubernetes resource names(s) to list")

	return cmd
}

func run(args []string, opts *options) error {
	start := time.Now()

	var err error

	l, err := loader.New()
	if err != nil {
		return err
	}

	inst, err := l.Load(args...)
	if err != nil {
		return err
	}

	load := time.Now()

	if err := inst.Complete(); err != nil {
		return err
	}

	ctx := cuecontext.New()

	v := ctx.BuildInstance(inst)
	if err := inst.Err; err != nil {
		return err
	}

	build := time.Now()

	if err := v.Validate(); err != nil {
		return err
	}

	validate := time.Now()

	it, err := v.LookupPath(cue.ParsePath("Delivery")).Fields(cue.Final(), cue.Concrete(true), cue.ResolveReferences(true))
	if err != nil {
		return err
	}

	cueDump, err := fs.ReadFile(FS, "dump.cue")
	if err != nil {
		return err
	}

	for it.Next() {
		l := it.Value().LookupPath(cue.ParsePath("resources"))

		cl := ctx.CompileBytes(cueDump)

		cl, err = cuetil.FillPaths(cl, map[string]interface{}{
			"dump.inputs.format":    opts.Format,
			"dump.inputs.kinds":     opts.Kinds,
			"dump.inputs.names":     opts.Names,
			"dump.inputs.resources": l,
		})
		if err != nil {
			return err
		}

		txt, err := cl.LookupPath(cue.ParsePath("dump.outputs.text")).String()
		if err != nil {
			return err
		}

		fmt.Fprintln(stdout, txt)
	}

	complete := time.Now()

	if opts.Debug {
		fmt.Printf("Timing:\n-------\nLoading:\t%v\nBuilding:\t%v\nValidating:\t%v\nIterating:\t%v\nTotal:\t\t%v\n",
			load.Sub(start), build.Sub(load), validate.Sub(build), complete.Sub(validate), complete.Sub(start))
	}

	return nil
}

type options struct {
	Debug  bool
	Format string `cue:"=~\"(json|yaml)\""`
	Kinds  []string
	Names  []string
}

var (
	//go:embed dump.cue
	FS embed.FS

	stdout io.Writer = os.Stdout
)
