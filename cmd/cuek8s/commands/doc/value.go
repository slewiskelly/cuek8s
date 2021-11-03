package doc

import (
	"fmt"
	"strings"
	"text/tabwriter"

	"cuelang.org/go/cue"
	"github.com/slewiskelly/cuek8s/internal/cuetil"
)

// Value represents a CUE value.
type Value struct {
	c cue.Value

	values []*Value
}

func (v *Value) Default() string {
	var dv string

	if v.Type() == "struct" {
		return ""
	}

	if d, ok := v.c.Default(); ok {
		dv = fmt.Sprint(d)
	}

	return dv
}

func (v *Value) LongDescription() string {
	return cuetil.LongDescription(v.c)
}

func (v *Value) Name() string {
	l, _ := v.c.Label()

	return l
}

func (v *Value) Path() string {
	return v.c.Value().Path().String()
}

func (v *Value) ShortDescription() string {
	return cuetil.ShortDescription(v.c)
}

func (v *Value) Type() string {
	if ref, _ := v.c.Reference(); ref != nil {
		_, refPath := v.c.ReferencePath()

		if p := ref.PkgName; p != "" {
			return fmt.Sprintf("%s.%s", ref.PkgName, refPath.String())
		}
	}

	// TODO(slewiskelly): If possible, display list element types.
	// e.g [...string] instead of just `list`.

	if v.c.IsConcrete() {
		return v.c.Kind().String()
	}

	return v.c.IncompleteKind().String()
}

func (v *Value) Values() []*Value {
	return v.values
}

// Markdown returns a Markdown document compiled from a CUE value.
func (v *Value) Markdown() string {
	w := new(strings.Builder)

	fmt.Fprintf(w, "**Type**: `%s`\n\n", v.Type())

	if len(v.Values()) > 0 {
		fmt.Fprintf(w, "|Name|Type|Default|Description|\n")
		fmt.Fprintf(w, "|----|----|-------|-----------|\n")

		for _, v := range v.Values() {
			fmt.Fprintf(w, "|`%s`|%s|%s|%s|\n",
				strings.Join(strings.Split(v.Path(), ".")[1:], "."),
				code(escape(v.Type())),
				func() string {
					if d := v.Default(); d != "" {
						return code(escape(v.Default()))
					}
					return ""
				}(),
				escape(v.LongDescription()))
		}
	}

	return w.String()
}

func (v *Value) Text() string {
	w := new(strings.Builder)
	tw := tabwriter.NewWriter(w, 0, 8, 1, '\t', 0)

	fmt.Fprintln(tw, "Name\tType\tDefault\tDescription")
	fmt.Fprintln(tw, "----\t----\t-------\t-----------")

	if len(v.Values()) > 0 {
		for _, v := range v.Values() {
			fmt.Fprintf(tw, "%s\t%s\t%s\t%s\n",
				strings.Join(strings.Split(v.Path(), ".")[1:], "."),
				v.Type(),
				v.Default(),
				v.ShortDescription(),
			)
		}
	} else {
		fmt.Fprintf(tw, "%s\t%s\t%s\t%s\n",
			strings.Join(strings.Split(v.Path(), ".")[1:], "."),
			v.Type(),
			v.Default(),
			v.ShortDescription(),
		)
	}

	tw.Flush()
	return w.String()
}

func code(s string) string {
	if strings.Contains(s, "<br/>") {
		return fmt.Sprintf("<pre>%s<pre/>", s)
	}

	return fmt.Sprintf("`%s`", s)
}

func escape(s string) string {
	return strings.ReplaceAll(strings.ReplaceAll(s, "|", `\|`), "\n", "<br/>")
}
