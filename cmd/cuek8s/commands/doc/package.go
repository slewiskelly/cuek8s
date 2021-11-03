package doc

import (
	"fmt"
	"sort"
	"strings"
	"text/tabwriter"

	"cuelang.org/go/cue"
	"github.com/slewiskelly/cuek8s/internal/cuetil"
)

// Package represents a CUE package.
type Package struct {
	c cue.Value

	name   string
	fields []*Value
}

// Packages maps a package name to a CUE package.
type Packages map[string]*Package

func (p *Package) LongDescription() string {
	return cuetil.LongDescription(p.c)
}

func (p *Package) Name() string {
	return p.name
}

func (p *Package) ShortDescription() string {
	return cuetil.ShortDescription(p.c)
}

func (p *Package) Fields() []*Value {
	sort.Slice(p.fields, func(i, j int) bool {
		return p.fields[i].Name() < p.fields[j].Name()
	})

	return p.fields
}

// Markdown returns a Markdown document compiled from a CUE package.
func (p *Package) Markdown() string {
	w := new(strings.Builder)

	fmt.Fprintf(w, "# %s\n\n", p.Name())
	fmt.Fprintf(w, "```cue\nimport \"%s\"\n```\n\n", p.Name())
	fmt.Fprintf(w, "%s\n\n", p.LongDescription())

	for _, f := range p.Fields() {
		fmt.Fprintf(w, "## %s\n\n", f.Name())
		fmt.Fprintf(w, "%s\n\n", f.LongDescription())
		fmt.Fprintf(w, "%s\n\n", f.Markdown())
	}

	return w.String()
}

func (p *Package) Text() string {
	w := new(strings.Builder)
	tw := tabwriter.NewWriter(w, 0, 8, 1, '\t', 0)

	fmt.Fprintf(w, "\nimport %q\n\n", p.Name())
	fmt.Fprintf(w, "%s\n\n", p.LongDescription())

	fmt.Fprintln(tw, "Name\tDescription")
	fmt.Fprintln(tw, "----\t-----------")

	for _, f := range p.Fields() {
		fmt.Fprintf(tw, "%s\t%s\n", f.Name(), f.ShortDescription())
	}

	tw.Flush()
	return w.String()
}
