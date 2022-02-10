package doc

import (
	"errors"
	"fmt"
	"io"
	"io/fs"
	"os"
	"path"
	"path/filepath"
	"sort"
	"strings"
	"text/tabwriter"

	"cuelang.org/go/cue"
	"cuelang.org/go/cue/cuecontext"
	"github.com/spf13/cobra"

	"github.com/slewiskelly/cuek8s"
	"github.com/slewiskelly/cuek8s/internal/cuetil"
	"github.com/slewiskelly/cuek8s/internal/loader"
)

func New() *cobra.Command {
	opts := new(options)

	cmd := &cobra.Command{
		Use:   "doc [FLAGS] [PACKAGE] [DEFINITION]",
		Short: "Displays reference documentation",
		Long: `Displays reference documentation.

If specified, -O or --outfile will output definitions of all packages, in markdown format, to the specified directory.

Otherwise, a single package can be specified to display package definitions.

If neither an output directory nor a package has been specified, a list of all packages will be displayed.
`,
		RunE: func(cmd *cobra.Command, args []string) error {
			return run(args, opts)
		},
	}

	cmd.Flags().BoolVarP(&opts.force, "force", "f", false, "force overwriting files")
	cmd.Flags().StringVarP(&opts.out, "outfile", "O", "", "output directory")

	return cmd
}

func run(args []string, opts *options) error {
	var err error

	l, err = loader.New()
	if err != nil {
		return err
	}

	if opts.out != "" {
		return markdownAll(opts.out, opts.force)
	}

	if len(args) > 0 {
		return textPackage(args[0], args[1:]...)
	}

	return textIndex()
}

func markdownAll(o string, f bool) error {
	pkgs, err := loadAll()
	if err != nil {
		return err
	}

	return writeMarkdown(o, f, pkgs)
}

func textIndex() error {
	pkgs, err := loadAll()
	if err != nil {
		return err
	}

	return writeTextIndex(stdout, pkgs)
}

func textPackage(p string, d ...string) error {
	if pr := filepath.Join(cuek8s.Module, "pkg"); !strings.HasPrefix(p, pr) {
		p = filepath.Join(pr, p)
	}

	pkg, err := getPackage(p)
	if err != nil {
		return err
	}

	return writeText(stdout, pkg, d...)
}

func loadAll() (Packages, error) {
	pkgs := make(Packages)

	err := fs.WalkDir(cuek8s.FS, "pkg", func(p string, d fs.DirEntry, err error) error {
		if err != nil {
			return err
		}

		if !d.IsDir() {
			return nil
		}

		m, err := fs.Glob(cuek8s.FS, filepath.Join(p, "*.cue"))
		if err != nil {
			return err
		}

		if len(m) < 1 {
			return nil
		}

		pkg, err := getPackage(filepath.Join(cuek8s.Module, p))
		if err != nil {
			return err
		}

		pkgs[p] = pkg

		return nil
	})

	return pkgs, err
}

func writeMarkdown(out string, force bool, pkgs Packages) error {
	switch _, err := os.Stat(out); {
	case err == nil:
		if !force {
			return fmt.Errorf("directory %q exists, specify --force to overwrite", out)
		}
		if err := os.RemoveAll(out); err != nil {
			return err
		}
		fallthrough
	case errors.Is(err, fs.ErrNotExist):
		if err := mkdir(out); err != nil {
			return err
		}
	default:
		return err
	}

	files := make(map[string]string)

	for name, pkg := range pkgs {
		if md := pkg.Markdown(); md != "" {
			filename := filepath.Join(out, name, fmt.Sprintf("%s.md", filepath.Base(name)))

			if err := mkdir(filepath.Dir(filename)); err != nil {
				return err
			}

			if err := writeFile(filename, []byte(md)); err != nil {
				return err
			}

			files[name] = filename
		}
	}

	return writeMarkdownIndex(out, files)
}

func writeMarkdownIndex(out string, files map[string]string) error {
	b := new(strings.Builder)

	b.WriteString("# API Reference\n\n")
	b.WriteString("## [go/cuek8s-api](https://golinks.io/cuek8s-api)\n\n")
	for _, k := range sortedKeys(files) {
		r, err := filepath.Rel(out, files[k])
		if err != nil {
			return err
		}

		b.WriteString(fmt.Sprintf("- [%s](%s)\n", k, r))
	}

	return writeFile(filepath.Join(out, "index.md"), []byte(b.String()))
}

func writeText(w io.Writer, p *Package, d ...string) error {
	if len(d) < 1 {
		if txt := p.Text(); txt != "" {
			fmt.Fprintln(w, txt)
		}
		return nil
	}

	for _, v := range p.Fields() {
		if contains(d, v.Name()) {
			if txt := v.LongDescription(); txt != "" {
				fmt.Fprintf(w, "\n%s\n\n", txt)
			}

			if txt := v.Text(); txt != "" {
				fmt.Fprintln(w, txt)
			}
		}
	}

	return nil
}

func writeTextIndex(w io.Writer, pkgs Packages) error {
	tw := tabwriter.NewWriter(stdout, 0, 8, 1, '\t', 0)
	defer tw.Flush()

	fmt.Fprintln(tw, "Name\tDescription")
	fmt.Fprintln(tw, "----\t-----------")

	var lines []string

	for n, p := range pkgs {
		lines = append(lines, fmt.Sprintf("%s\t%s", path.Join(cuek8s.Module, n), p.ShortDescription()))
	}

	sort.Strings(lines)

	for _, l := range lines {
		fmt.Fprintln(tw, l)
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

func fields(val cue.Value) ([]*Value, error) {
	var fields []*Value

	it, err := val.Fields(cue.Definitions(true))
	if err != nil {
		return nil, err
	}

	for it.Next() {
		if !it.Selector().IsDefinition() {
			continue
		}

		val := &Value{c: it.Value()}

		val.c.Walk(func(cv cue.Value) bool {
			v := &Value{c: cv}

			if v.Name() == val.Name() {
				return true
			}

			if !hasInputAttribute(v.c) {
				return false
			}

			if ref, _ := v.c.Reference(); ref != nil {
				if strings.HasPrefix(ref.ImportPath, "k8s.io") {
					return false
				}
			}

			val.values = append(val.values, v)

			return true
		}, nil)

		if err != nil {
			fmt.Println(err)
		}

		fields = append(fields, val)
	}

	return fields, nil
}

func getPackage(p string) (*Package, error) {
	inst, err := l.Load(p)
	if err != nil {
		return nil, err
	}

	v := cuecontext.New().BuildInstance(inst)
	if err := inst.Err; err != nil {
		return nil, err
	}

	fields, err := fields(v)
	if err != nil {
		return nil, err
	}

	return &Package{
		c: v,

		name:   p,
		fields: fields,
	}, nil
}

func hasInputAttribute(v cue.Value) bool {
	return cuetil.ContainsAttribute(v.Attributes(cue.FieldAttr), "input")
}

func mkdir(d string) error {
	return os.MkdirAll(d, 0755)
}

func sortedKeys(m map[string]string) []string {
	var s []string

	for k := range m {
		s = append(s, k)
	}

	sort.Strings(s)

	return s
}

func writeFile(p string, d []byte) error {
	return os.WriteFile(p, d, 0644)
}

type options struct {
	force bool
	out   string
}

var (
	l *loader.Loader

	stdout io.Writer = os.Stdout
)
