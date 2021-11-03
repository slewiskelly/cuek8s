package create

import (
	"embed"
	"io/fs"
	"os"
	"path/filepath"

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
		Use:   "create (-C COUNTRY -S SERVICE_ID)",
		Short: "Creates a new service",
		Long: `Creates a new service

Input(s) are the same as those of the ` + "`cue`" + ` tool. See ` + "`cue inputs`" + ` for more information.

The directory structure generated is according the platform's logical topology in the given country. 
`,
		RunE: func(cmd *cobra.Command, args []string) error {
			return run(args, opts)
		},
	}

	cmd.Flags().StringVarP(&opts.Country, "country", "C", "", "Country code of where the created service will run")
	cmd.Flags().StringVarP(&opts.ServiceID, "service-id", "S", "", "ID of the service to be created")

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

	inst, err := l.Load("./...")
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

	cueCreate, err := fs.ReadFile(FS, "create.cue")
	if err != nil {
		return err
	}

	cl, err := cuetil.FillPaths(ctx.CompileBytes(cueCreate), map[string]interface{}{
		"dirs.inputs.serviceID": opts.ServiceID,
		"dirs.inputs.country":   opts.Country,
	})
	if err != nil {
		return err
	}

	dirs, err := cl.LookupPath(cue.ParsePath("dirs.outputs.dirs")).List()
	if err != nil {
		return err
	}

	for dirs.Next() {
		dir, err := dirs.Value().String()
		if err != nil {
			return err
		}

		dir = filepath.Join("microservices", dir)

		if err := mkdir(dir); err != nil {
			return err
		}

		if err := touch(filepath.Join(dir, ".gitkeep")); err != nil {
			return err
		}
	}

	return nil
}

func mkdir(d string) error {
	return os.MkdirAll(d, 0755)
}

func touch(f string) error {
	return os.WriteFile(f, nil, 0644)
}

type options struct {
	Country   string `cue:"!=\"\""`
	ServiceID string `cue:"!=\"\""`
}

var (
	//go:embed create.cue
	FS embed.FS
)
