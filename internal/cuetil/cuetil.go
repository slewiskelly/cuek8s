// Package cuetil contains various helper functions for working with CUE values.
package cuetil

import (
	"bufio"
	"strings"

	"cuelang.org/go/cue"
)

// ContainsAttribute returns true of there is an attribute of the same name
// within the set of given attributes.
func ContainsAttribute(a []cue.Attribute, s string) bool {
	for _, t := range a {
		if t.Name() == s {
			return true
		}
	}

	return false
}

// FillPaths returns an updated value, filling the given paths to their
// corresponding values.
//
// An error is returned if the value fails to validate after all paths have
// been filled.
func FillPaths(v cue.Value, m map[string]interface{}) (cue.Value, error) {
	for p, x := range m {
		v = v.FillPath(cue.ParsePath(p), x)
	}

	// TODO(slewiskelly): Fail fast instead?
	return v, v.Validate()
}

// IsDefinition returns true if the given value is a definition.
func IsDefinition(v cue.Value) bool {
	_, r := v.ReferencePath()

	for _, s := range r.Selectors() {
		if s.IsDefinition() {
			return true
		}
	}

	return false
}

// LongDescription returns the full description of the given value, as derived
// from the value's commentary.
func LongDescription(v cue.Value) string {
	b := new(strings.Builder)

	for _, c := range v.Doc() {
		b.WriteString(strings.TrimSpace(c.Text()))
	}

	return b.String()
}

// ShortDescription returns a short description of the given value (the first
// sentence), as derived from the value's commentary.
func ShortDescription(v cue.Value) string {
	s := bufio.NewScanner(strings.NewReader(strings.Join(strings.Split(LongDescription(v), "\n"), " ")))
	s.Split(splitSentence)
	s.Scan()

	return s.Text()
}

// TODO(slewiskelly): Naive
func splitSentence(data []byte, atEOF bool) (advance int, token []byte, err error) {
	for i := 0; i < len(data); i++ {
		if data[i] == '.' {
			return i + 1, data[:i], nil
		}
	}

	if !atEOF {
		return 0, nil, nil
	}

	return 0, data, bufio.ErrFinalToken
}
