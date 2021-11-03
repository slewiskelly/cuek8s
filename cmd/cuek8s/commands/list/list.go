package list

import (
	"embed"
	"fmt"
	"io"
	"io/fs"
	"os"

	"cuelang.org/go/cue"
	"cuelang.org/go/cue/cuecontext"
	"cuelang.org/go/cuego"
	"github.com/spf13/cobra"

	"github.com/slewiskelly/cuek8s/internal/cuetil"
	"github.com/slewiskelly/cuek8s/internal/loader"
)

func New() *cobra.Command {
	opts := new(options)

	cmd := &cobra.Command{
		Use:   "list [-o FORMAT] INPUT...",
		Short: "Lists Kubernetes resources along with other metadata",
		Long: `Lists Kubernetes resources along with other metadata

Input(s) are the same as those of the ` + "`cue`" + ` tool. See ` + "`cue inputs`" + ` for more information.

If specified, -k or --kind will filter resources by their kind.

If specified, -n or --name will filter resources by their name.

Specifying both will filter resources by both kind and name.
`,
		RunE: func(cmd *cobra.Command, args []string) error {
			return run(args, opts)
		},
	}

	cmd.Flags().StringVarP(&opts.Format, "out", "o", "table", "Output format (json|table)")
	cmd.Flags().StringSliceVarP(&opts.Kinds, "kind", "k", nil, "Kubernetes resource kind(s) to list")
	cmd.Flags().StringSliceVarP(&opts.Names, "name", "n", nil, "Kubernetes resource names(s) to list")

	return cmd
}

func run(args []string, opts *options) error {
	err := cuego.Validate(opts)
	if err != nil {
		return err
	}

	l, err := loader.New()
	if err != nil {
		return err
	}
	defer l.Close()

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

	cueList, err := fs.ReadFile(FS, "list.cue")
	if err != nil {
		return err
	}

	cl, err := cuetil.FillPaths(ctx.CompileBytes(cueList), map[string]interface{}{
		"ls.inputs.format":   opts.Format,
		"ls.inputs.kinds":    opts.Kinds,
		"ls.inputs.names":    opts.Names,
		"ls.inputs.delivery": v.LookupPath(cue.ParsePath("Delivery")),
	})
	if err != nil {
		return err
	}

	txt, err := cl.LookupPath(cue.ParsePath("ls.outputs.text")).String()
	if err != nil {
		return err
	}

	fmt.Fprintln(stdout, txt)

	return nil
}

type options struct {
	Format string `cue:"=~\"(json|table)\""`
	Kinds  []string
	Names  []string
}

var (
	//go:embed list.cue
	FS embed.FS

	stdout io.Writer = os.Stdout
)
